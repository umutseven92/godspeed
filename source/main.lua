import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "player"
import "background"

local gfx <const> = playdate.graphics
local ui <const> = playdate.ui

local speed_div <const> = 10

local screenWidth, screenHeight = playdate.display.getSize()

local background = nil
local player = nil
local lanes = { top = screenHeight / 4, middle = screenHeight / 2, bottom = screenHeight - screenHeight / 4 }
local currentLane = lanes.middle

function setup()
    ui.crankIndicator:start()

    background = Background()
    local playerPosX = screenWidth / 4

    player = Player(playerPosX)
    player:move(currentLane)
end

setup()

function setLane(direction)
    if direction == "up" then
        if currentLane == lanes.middle then
            currentLane = lanes.top
        elseif currentLane == lanes.bottom
        then
            currentLane = lanes.middle
        end
    elseif direction == "down" then
        if currentLane == lanes.middle then
            currentLane = lanes.bottom
        elseif currentLane == lanes.top
        then
            currentLane = lanes.middle
        end
    end
end

function playdate.update()
    local deltaTime = playdate.getElapsedTime()
    playdate.resetElapsedTime()

    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:update()
        return
    end

    local _, acceleratedChange = playdate.getCrankChange()

    if acceleratedChange > 0 then
        background:scroll(acceleratedChange / speed_div)
    end

    if playdate.buttonJustPressed(playdate.kButtonUp) then
        setLane("up")
        player:move_lerp(currentLane)
    end
    if playdate.buttonJustPressed(playdate.kButtonDown) then
        setLane("down")
        player:move_lerp(currentLane)
    end

    player:update(deltaTime)
    gfx.sprite.update()
    playdate.timer.updateTimers()
end
