import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/frameTimer"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "player"
import "background/background_manager"
import "lanes"
import "speedometer/speedometer"
import "obstacle/obstacle_manager"

local gfx <const> = playdate.graphics
local ui <const> = playdate.ui

-- Higher this is, slower the background & obstacles scroll.
local speedDiv <const> = 10

local speedLimit <const> = 50
local gameOverMs <const> = 3000
local gameOverTick <const> = 1000

local screenWidth, screenHeight = playdate.display.getSize()

local difficultyIncreaseFreq = 10000
local spawnFreq = 500
local gameOverAcc = 0
local firstRun = true

local backgroundManager = nil
local obstacleManager = nil
local player = nil
local lanes = nil
local speedometer = nil

local difficultyTimer = nil

function setUpFonts()
    local varnished = gfx.font.new("assets/fonts/Asheville-Sans-14-Bold")
    assert(varnished)
    gfx.setFont(varnished)
end

function setup()
    setUpFonts()
    ui.crankIndicator:start()

    speedometer = Speedometer(screenWidth, screenHeight)
    lanes = Lanes(screenHeight)

    obstacleManager = ObstacleManager(lanes.laneMap, screenWidth,speedDiv)
    backgroundManager = BackgroundManager(speedDiv)

    player = Player(lanes.laneMap.middle)
    player:move(lanes:getCurrentLane())

end

setup()

function changeLane(direction)
    local changed = lanes:setLane(direction)
    if changed then
        player:moveLerp(lanes:getCurrentLane())
    end
end

function startGameOver(delta) 
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
    print("Game over!")

    difficultyTimer:pause()
    difficultyTimer:remove()
    playdate.stop()
end

function updateDifficultyTimer()
    difficultyTimer = playdate.frameTimer.new(difficultyIncreaseFreq, spawnObstacles)
    difficultyTimer.repeats = true
end

local distance = 0

function playdate.update()
    local deltaTime = playdate.getElapsedTime()
    playdate.resetElapsedTime()

    if firstRun then
        updateDifficultyTimer()
        firstRun = false
    end

    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:update()
        return
    end

    local _, acceleratedChange = playdate.getCrankChange()

    local speed = 0
    if acceleratedChange >= 0 then
        ---@diagnostic disable-next-line: cast-local-type
        speed = acceleratedChange
        assert(speed ~= nil)
    end

    distance+= (speed / speedDiv)

    if distance > spawnFreq then
        obstacleManager:spawnRandom()
        distance = 0
    end

    backgroundManager:scroll(speed)
    obstacleManager:scroll(speed)

    if playdate.buttonJustPressed(playdate.kButtonUp) then
        changeLane("up")
    end
    if playdate.buttonJustPressed(playdate.kButtonDown) then
        changeLane("down")
    end

    if speed < speedLimit then
        startGameOver(deltaTime)
    else
        resetGameOver()
    end

    player:update(deltaTime)

    gfx.sprite.update()

    speedometer:update(speed)

    obstacleManager:clean()
    playdate.frameTimer.updateTimers()
    playdate.timer.updateTimers()
end
