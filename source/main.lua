import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/frameTimer"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "player"
import "background"
import "lanes"
import "speedometer"

local gfx <const> = playdate.graphics
local ui <const> = playdate.ui

local speedLimit <const> = 50
local gameOverMs <const> = 3000
local gameOverTick <const> = 1000

local screenWidth, screenHeight = playdate.display.getSize()

local gameOverAcc = 0

local background = nil
local player = nil
local lanes = nil
local speedometer = nil

function setUpFonts()
    local varnished = gfx.font.new("fonts/Asheville-Sans-14-Bold")
    assert(varnished)
    gfx.setFont(varnished)
end

function setup()
    setUpFonts()
    ui.crankIndicator:start()

    speedometer = Speedometer(screenWidth, screenHeight)
    lanes = Lanes(screenHeight)
    background = Background()
    local playerPosX = screenWidth / 4

    player = Player(playerPosX)
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
    speedometer:setSkullRatio(gameOverAcc / gameOverMs)

    if gameOverAcc >= gameOverMs then
        print("Game over")
        playdate.stop() 
    end
end

function resetGameOver()
    speedometer:stopFlashing()
    gameOverAcc = 0
    speedometer:setSkullRatio(0)
end

function playdate.update()
    local deltaTime = playdate.getElapsedTime()
    playdate.resetElapsedTime()

    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:update()
        return
    end

    local _, acceleratedChange = playdate.getCrankChange()

    local speed = 0
    if acceleratedChange >= 0 then
        ---@diagnostic disable-next-line: cast-local-type
        speed = acceleratedChange
    end

    background:scroll(speed)

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

    playdate.frameTimer.updateTimers()
    playdate.timer.updateTimers()
end
