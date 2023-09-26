--[[
    Godspeed is a simple game, inspired by the movie Speed, where you drive a bus in the highway full of obstacles. If you go slower than a certain speed, you explode. Hitting obstacles slows you down.
    The game goes on forever, and there is a score. You gain speed by mashing the A or B button, and change lanes by the up & down buttons.
]]

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/frameTimer"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "player"
import "background/background_manager"
import "lanes"
import "ui/message"
import "ui/score"
import "speedometer/speedometer"
import "obstacle/obstacle_manager"

local gfx <const> = playdate.graphics
local ui <const> = playdate.ui
local sound <const> = playdate.sound

local screenWidth <const>, _ = playdate.display.getSize()

local playerSpeed = 0

-- Higher this is, slower the background & obstacles scroll.
local speedDiv <const> = 10

-- Higher this is, the more speed the button input adds.
local speedInputMod <const> = 200

-- How fast the player slows down if the button is not tapped.
local slowMod <const> = 5

-- If the player goes below `speedLimit` for `gameOverMs` / `gameOverTick` seconds, the game is over.
local speedLimit <const> = 50
local gameOverMs <const> = 3000
local gameOverTick <const> = 1000
local gameOverAcc = 0

-- How many frames will the player slow down after hitting obstacles.
local slowTick <const> = 60
local slowTimer = nil

-- How often (in frames) will difficulty increase.
local difficultyIncreaseFreq = 10000
local difficultyTimer = nil

-- How often (in distance) will obstacles spawn.
local spawnFreq = 500

-- Whether if this is the first run of `update()`. Used for initialisation.
local firstRun = true

local gameIsOver = false

-- The distance the player has gone. Gets reset after every time obstacles spawn.
local distance = 0

-- `speedModifier` gets divided by speed to determine player speed. Used for slowing down / speeding up player.
local speedModifier = 1

local backgroundManager = nil
local obstacleManager = nil
local player = nil
local lanes = nil
local speedometer = nil
local message = nil
local score = nil

local musicPlayer = nil

--#region Setup

function setUpClasses()
    speedometer = Speedometer()
    message = Message()
    score = Score()
    lanes = Lanes()
    obstacleManager = ObstacleManager(lanes.laneMap, setSpeedModifier)
    backgroundManager = BackgroundManager()

    player = Player(screenWidth / 4, lanes.laneMap.middle)
end

function setUpFonts()
    local font = gfx.font.new("assets/fonts/Asheville-Sans-14-Bold-White")
    assert(font)
    gfx.setFont(font)
end

function setUpSound()
    musicPlayer = sound.fileplayer.new("assets/sounds/theme")
    assert(musicPlayer)
    musicPlayer:setLoopRange(25.6, 38.4)
    musicPlayer:play(0)
end

function setup()
    setUpFonts()

    setUpClasses()
    setUpSound()
end

--#endregion

function changeLane(direction)
    local changed = lanes:setLane(direction)
    if changed then
        player:moveLerp(lanes.currentLane)
    end
end

function startGameOver(delta)
    -- When the player goes below the limit, we flash the speedometer & show a "progress bar" in the shape of a skull.
    speedometer:startFlashing()
    gameOverAcc += gameOverTick * delta
    speedometer.skull:setRatio(gameOverAcc / gameOverMs)

    if gameOverAcc >= gameOverMs then
        gameOver()
    end
end

function resetGameOver()
    speedometer:stopFlashing()
    gameOverAcc = 0
    speedometer.skull:setRatio(0)
end

function gameOver()
    print(string.format("Game over with score %d.", score.totalScore))
    player:explode()
    message:setRestartText()
    gameOverAcc = 0
    distance = 0
    firstRun = false
    difficultyTimer:pause()
    difficultyTimer:remove()

    if slowTimer ~= nil then
        slowTimer:pause()
        slowTimer:remove()
    end
    gameIsOver = true
end

function updateDifficultyTimer()
    -- This initialises the difficulty timer, which spawns obstacles via the `spawnObstacles` function every `difficultyIncreseFreq` ticks.
    difficultyTimer = playdate.frameTimer.new(difficultyIncreaseFreq, spawnObstacles)
    difficultyTimer.repeats = true
end


function getSpeed()
    -- Get the base speed, which comes from how fast the A or B buttons are being pressed.

    if playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) then
        playerSpeed = speedInputMod
        assert(playerSpeed ~= nil)
    else
        if playerSpeed <= 0 then
            playerSpeed = 0
        else
            playerSpeed -= slowMod
        end
    end

    return playerSpeed
end

function checkInput()
    -- Only two controls, up and down for changing lanes.
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        changeLane("up")
    end
    if playdate.buttonJustPressed(playdate.kButtonDown) then
        changeLane("down")
    end
end

function checkRestartInput()
    if playdate.buttonJustPressed(playdate.kButtonUp) or
        playdate.buttonJustPressed(playdate.kButtonDown) or
        playdate.buttonJustPressed(playdate.kButtonLeft) or
        playdate.buttonJustPressed(playdate.kButtonRight) or
        playdate.buttonJustPressed(playdate.kButtonA) or
        playdate.buttonJustPressed(playdate.kButtonB)
    then
        resetGame()
    end
end

function checkSpeedForGameOver(speed, deltaTime)
    if speed < speedLimit then
        startGameOver(deltaTime)
        message:setSpeedUpText()
    else
        resetGameOver()
        message:reset()
    end
end

function checkDistanceForSpawningObstacles(normSpeed)
    distance += normSpeed

    if distance > spawnFreq then
        obstacleManager:spawnRandom()
        distance = 0
    end
end

function resetGame()
    print("Restarting game")
    message:reset()

    gfx.sprite.removeAll()
    setUpClasses()
    gameIsOver = false
end

function setSpeedModifier(modifier)
    -- Set the speed modifier. The speed modifier will reset back to 1 after `slowTick` ticks.
    print("Slowing down..")
    speedModifier += modifier
    slowTimer = playdate.frameTimer.new(slowTick, function()
        print("Resetting slowdown")
        speedModifier = 1
    end)
end

setup()

function playdate.update()
    local deltaTime = playdate.getElapsedTime()
    playdate.resetElapsedTime()

    if firstRun and not gameIsOver then
        -- Initialisation
        updateDifficultyTimer()
        firstRun = false
    end

    -- This needs to be called before drawing text, or the text won't appear.
    gfx.sprite.update()

    if not gameIsOver then
        -- Main game loop
        local speed = getSpeed()
        speed /= speedModifier
        score:addToTotalScore(speed)

        --[[
        The actual speed can be too much for scrolling & obstacles, so we divide it by `speedDiv`.
        The user will still see the actual speed in the speedometer, but the actual speed of the player & obstacles will be this divided speed.
        --]]
        local normSpeed = speed / speedDiv

        checkDistanceForSpawningObstacles(normSpeed)

        backgroundManager:scroll(normSpeed)
        obstacleManager:scroll(normSpeed)
        obstacleManager:update(deltaTime)
        checkInput()

        checkSpeedForGameOver(speed, deltaTime)

        speedometer:update(speed)
    else
        -- Game over loop
        score:startFlashing()
        checkRestartInput()
    end

    player:update(deltaTime)

    message:update()
    score:update()

    obstacleManager:removeOutOfBounds()

    playdate.frameTimer.updateTimers()
    playdate.timer.updateTimers()
end
