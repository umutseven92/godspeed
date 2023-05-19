import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/frameTimer"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "player"
import "background/background_manager"
import "lanes"
import "message"
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
local gameIsOver = false
local distance = 0

local backgroundManager = nil
local obstacleManager = nil
local player = nil
local lanes = nil
local speedometer = nil
local message = nil
local difficultyTimer = nil

function setUpFonts()
    local varnished = gfx.font.new("assets/fonts/Asheville-Sans-14-Bold-White")
    assert(varnished)
    gfx.setFont(varnished)
end

function initClasses()
    speedometer = Speedometer(screenWidth, screenHeight)
    message = Message(screenWidth, screenHeight)
    lanes = Lanes(screenHeight)

    obstacleManager = ObstacleManager(lanes.laneMap, screenWidth)
    backgroundManager = BackgroundManager()

    player = Player(lanes.laneMap.middle)
    player:move(lanes:getCurrentLane())

end

function setup()
    setUpFonts()
    ui.crankIndicator:start()

    initClasses()
end


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
    player:explode()
    message:setRestartText() 
    gameOverAcc = 0
    distance = 0
    firstRun = false
    difficultyTimer:pause()
    difficultyTimer:remove()

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

function checkSpeed(speed, deltaTime)
    if speed < speedLimit then
        startGameOver(deltaTime)
        message:setSpeedUpText() 
    else
        resetGameOver()
        message:reset()
    end
end 

function checkDistance(normSpeed)
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
        updateDifficultyTimer()
        firstRun = false
    end

    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:update()
        return
    end

    if not gameIsOver then
        local speed = getSpeed()
        local normSpeed = speed / speedDiv

        checkDistance(normSpeed)    

        backgroundManager:scroll(normSpeed)
        obstacleManager:scroll(normSpeed)

        checkInput()

        checkSpeed(speed, deltaTime)


        speedometer:update(normSpeed)
    else
        checkRestartInput()
    end

    player:update(deltaTime)

    gfx.sprite.update()

    message:update()

    obstacleManager:clean()
    playdate.frameTimer.updateTimers()
    playdate.timer.updateTimers()
end
