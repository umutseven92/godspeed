--[[
    Godspeed is a simple game, inspired by the movie Speed, where you drive a bus in the highway full of obstacles. If you go slower than a certain speed, you explode. Hitting obstacles slows you down.
    The game goes on forever, and there is a score. You gain speed by turning the crank, and change lanes by the up & down buttons.
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
local screenWidth <const>, _ = playdate.display.getSize()

-- Higher this is, slower the background & obstacles scroll.
local speedDiv <const> = 10

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

-- `speedModifier` gets divided by crank speed to determine player speed. Useful for slowing down / speeding up player.
local speedModifier = 1

local backgroundManager = nil
local obstacleManager = nil
local player = nil
local lanes = nil
local speedometer = nil
local message = nil
local score = nil

function setUpFonts()
    local font = gfx.font.new("assets/fonts/Asheville-Sans-14-Bold-White")
    assert(font)
    gfx.setFont(font)
end

function setSpeedModifier(modifier)
    print("Slowing down..")
    speedModifier += modifier
    slowTimer = playdate.frameTimer.new(slowTick, function()
        print("Resetting slowdown")
        speedModifier = 1
    end)
end


function initClasses()
    speedometer = Speedometer()
    message = Message()
    score = Score()
    lanes = Lanes()
    obstacleManager = ObstacleManager(lanes.laneMap, setSpeedModifier)
    backgroundManager = BackgroundManager()

    player = Player(screenWidth / 4, lanes.laneMap.middle)
end

function setup()
    setUpFonts()
    ui.crankIndicator:start()

    initClasses()
end


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
    slowTimer:pause()
    slowTimer:remove()
    gameIsOver = true
end

function updateDifficultyTimer()
    difficultyTimer = playdate.frameTimer.new(difficultyIncreaseFreq, spawnObstacles)
    difficultyTimer.repeats = true
end

function getSpeed()
    local _, acceleratedChange = playdate.getCrankChange()

    local speed = 0
    if acceleratedChange >= 0 then
        ---@diagnostic disable-next-line: cast-local-type
        speed = acceleratedChange
        assert(speed ~= nil)
    end

    return speed
end

function checkInput()
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
    distance+= normSpeed

    if distance > spawnFreq then
        obstacleManager:spawnRandom()
        distance = 0
    end

end

function resetGame()
    print("Restarting game")
    message:reset()

    gfx.sprite.removeAll()
    initClasses()
    gameIsOver = false
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

    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:update()
        return
    end

    if not gameIsOver then
        local speed = getSpeed()
        speed /= speedModifier
        score:addToTotalScore(speed)

        -- The actual speed can be too much for scrolling & obstacles, so we normalise it.
        local normSpeed = speed / speedDiv

        checkDistanceForSpawningObstacles(normSpeed)

        backgroundManager:scroll(normSpeed)
        obstacleManager:scroll(normSpeed)
        obstacleManager:update(deltaTime)
        checkInput()

        checkSpeedForGameOver(speed, deltaTime)

        speedometer:update(speed)
    else
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
