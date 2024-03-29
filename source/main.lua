--[[
    Godspeed is a simple game, inspired by the movie Speed, where you drive a bus in the highway full of obstacles. If you go slower than a certain speed, you explode. Hitting obstacles slows you down. If you hit obstacles three times, you explode.
    The game goes on forever, and there is a score. You gain speed by mashing the A button, and change lanes by the up & down buttons.
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
import "ui/tutorial"
import "ui/high_score"
import "ui/crash_amount"
import "audio/music_player"
import "audio/engine_player"
import "audio/beep_player"
import "speedometer/speedometer"
import "obstacle/obstacle_manager"

local gfx <const> = playdate.graphics

local screenWidth <const>, _ = playdate.display.getSize()

local playerSpeed = 0

-- Higher this is, slower the background & obstacles scroll.
local speedDiv <const> = 10

-- Higher this is, the more speed the button input adds.
local speedInputMod <const> = 200

-- How fast the player slows down if the button is not tapped.
local slowMod <const> = 8

-- If the player goes below `speedLimit` for `gameOverMs` / `gameOverTick` seconds, the game is over.
local speedLimit <const> = 70

-- If the player goes below `instantLoseLimit`, the game is instantly over.
local instantLoseLimit <const> = 30

local gameOverMs <const> = 3000
local gameOverTick <const> = 1000
local gameOverAcc = 0

-- How many frames will the player slow down after hitting obstacles.
local slowTick <const> = 60
local slowTimer = nil

-- How often (in frames) will difficulty increase.
local difficultyIncreaseFreq = 300
local difficultyTimer = nil

-- How often (in distance) will obstacles spawn.
local spawnFreq = 500

-- How long the initial grace period is for the player. During the initial grace period, we give the player time to speed up, so they do not explode if their speed is 0.
local initialGracePeriod <const> = 30
local initialGraceTimer = nil
local inGracePeriod = true

-- Whether if this is the first run of `update()`. Used for initialisation, will be reset when game is over.
local firstRun = true

-- Whether to show the tutorial. Will not be reset when the game is over.
local showTutorial = true

local gameIsOver = false

-- The distance the player has gone. Gets reset after every time obstacles spawn.
local distance = 0

-- `speedModifier` gets divided by speed to determine player speed. Used for slowing down / speeding up player.
local speedModifier = 1

-- How much to slow down the player after they crash.
local crashSlowMod <const> = 2

-- How many times the player can crash before exploding.
local maxCrashes <const> = 3

local crashes = 0

-- Gameplay classes
local backgroundManager = nil
local obstacleManager = nil
local player = nil
local lanes = nil

-- UI classes
local speedometer = nil
local highScore = nil
local message = nil
local score = nil
local tutorial = nil
local crashAmount = nil

-- Audio classes
local musicPlayer = nil
local enginePlayer = nil
local beepPlayer = nil

local difficulty = 0

function setUpClasses()
    speedometer = Speedometer()
    highScore = HighScore()
    message = Message()
    crashAmount = CrashAmount()
    score = Score()
    lanes = Lanes()
    tutorial = Tutorial()
    obstacleManager = ObstacleManager(lanes.laneMap, onCrashed)
    backgroundManager = BackgroundManager()
    player = Player(screenWidth / 6, lanes.laneMap.middle)

    musicPlayer = MusicPlayer()
    enginePlayer = EnginePlayer()
    beepPlayer = BeepPlayer()
end

function setUpFonts()
    local font = gfx.font.new("assets/fonts/Asheville-Sans-14-Bold-White")
    assert(font)
    gfx.setFont(font)
end

function setup()
    setUpFonts()
    setUpClasses()
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
    speedometer:setSkullRatio(gameOverAcc / gameOverMs)

    if gameOverAcc >= gameOverMs / 1.5 then
        beepPlayer:playFastBeep()
    else
        beepPlayer:playSlowBeep()
    end

    if gameOverAcc >= gameOverMs then
        gameOver()
    end
end

function resetGameOver()
    speedometer:stopFlashing()
    gameOverAcc = 0
    speedometer:setSkullRatio(0)

    beepPlayer:stop()
end

function gameOver()
    print(string.format("Game over with score %d.", score.totalScore))
    enginePlayer:stop()
    beepPlayer:stop()

    player:explode()
    message:setRestartText()
    gameOverAcc = 0
    distance = 0
    firstRun = false
    speedModifier = 1
    crashes = 0

    difficultyTimer:pause()
    difficultyTimer:remove()
    initialGraceTimer:pause()
    initialGraceTimer:remove()
    inGracePeriod = true

    if slowTimer ~= nil then
        slowTimer:pause()
        slowTimer:remove()
    end
    gameIsOver = true

    highScore:setHighScore(score.totalScore)
end

function updateTimers()
    -- This initialises the difficulty timer, which spawns obstacles via the `spawnObstacles` function every `difficultyIncreseFreq` ticks.
    difficultyTimer = playdate.frameTimer.new(difficultyIncreaseFreq, increaseDifficulty)
    difficultyTimer.repeats = true

    initialGraceTimer = playdate.frameTimer.new(initialGracePeriod, disableGracePeriod)
end

function disableGracePeriod()
    inGracePeriod = false
    print("Grace period ended, player can now explode if speed is 0.")
end

function increaseDifficulty()
    difficulty += 1

    if difficulty == 1 then
        -- First difficulty increase is the harder obstacle spawn patterns.
        print("Increasing difficulty to mid, obstacle spawns added.")
        obstacleManager:increaseDifficultyToMid()
        return
    elseif difficulty == 2 then
        -- Second difficulty increase is the hardest obstacle spawn patterns.
        print("Increasing difficulty to hard, obstacle spawns added.")
        obstacleManager:increaseDifficultyToHard()
        return
    else
        -- The rest of the difficulty comes from more frequent spawns.
        spawnFreq -= difficulty * 10
        print(string.format("Increasing difficulty, spawn frequency is now %d.", spawnFreq))
    end
end

function getSpeed()
    -- Get the base speed, which comes from how fast the A button is being pressed.

    if playdate.buttonJustPressed(playdate.kButtonA) then
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
    if playdate.buttonJustPressed(playdate.kButtonB) then
        resetGame()
    end
end

function checkStartInput()
    if playdate.buttonJustPressed(playdate.kButtonA) then
        showTutorial = false
        message:reset()
        tutorial:hide()
        musicPlayer:play()
    end
end

function checkSpeedForGameOver(speed, deltaTime)
    --[[
        There are basically two ways a player can lose that is dependent on speed:
        1) If the player speed goes below `speedLimit` for `gameOverMs` / `gameOverTick` seconds,
        2) If the player speed goes below `instantLoseLimit`. This is to prevent the player from cheesing the game by lighty tapping the button, rather than mashing it.
    --]]

    if speed <= instantLoseLimit and not inGracePeriod then
        -- Game is over if the player stopped.
        gameOver()
    elseif speed < speedLimit then
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
    crashAmount:setCrashAmount(crashes)
    gfx.sprite.removeAll()
    setUpClasses()
    gameIsOver = false
    firstRun = true
end

function onCrashed()
    -- This function is passed to the ObstacleManager, which is then passed into each obstacle. It is called when the player crashes into an obstacle.
    crashes += 1
    crashAmount:setCrashAmount(crashes)

    if crashes >= maxCrashes then
        -- End the game is the player has crashed too much.
        gameOver()
    else
        -- Set the speed modifier. The speed modifier will reset back to 1 after `slowTick` ticks.
        print(string.format("Slowing down by %d..", crashSlowMod))
        speedModifier += crashSlowMod

        if slowTimer ~= nil then
            slowTimer:reset()
        end

        slowTimer = playdate.frameTimer.new(slowTick, function()
            print("Resetting slowdown")
            speedModifier = 1
        end)
    end
end

setup()

function playdate.update()
    local deltaTime = playdate.getElapsedTime()
    playdate.resetElapsedTime()

    -- This needs to be called before drawing text, or the text won"t appear.
    gfx.sprite.update()

    if firstRun and not gameIsOver and not showTutorial then
        -- Initialisation
        updateTimers()
        firstRun = false
    end

    if not gameIsOver and not showTutorial then
        -- Main game loop
        local speed = getSpeed()
        speed /= speedModifier
        score:addToTotalScore(speed)

        enginePlayer:play(speed)

        --[[
        The actual speed can be too much for scrolling & obstacles, so we divide it by `speedDiv`.
        The user will still see the actual speed in the speedometer, but the actual speed of the player & obstacles will be this divided speed.
        --]]
        local normSpeed = speed / speedDiv

        checkDistanceForSpawningObstacles(normSpeed)

        backgroundManager:scroll(normSpeed)
        obstacleManager:scroll(normSpeed)

        -- Since `onCrashed` runs during `scroll`, the player might have exploded at this point.
        if gameIsOver then
            return
        end

        obstacleManager:update(deltaTime)

        if speed > 0 then
            -- We only allow changing lanes if the players is moving.
            checkInput()
        end

        checkSpeedForGameOver(speed, deltaTime)

        speedometer:update(speed)
    elseif gameIsOver and not showTutorial then
        -- Game over loop
        score:startFlashing()
        checkRestartInput()
    elseif not gameIsOver and showTutorial then
        -- Tutorial loop
        tutorial:show()
        message:setStartText()
        checkStartInput()
    end

    player:update(deltaTime)

    message:update()
    if not showTutorial then
        score:update()
        highScore:update()
        crashAmount:update()
    end

    obstacleManager:removeOutOfBounds()

    playdate.frameTimer.updateTimers()
    playdate.timer.updateTimers()
end
