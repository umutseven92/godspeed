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

local background = nil
local player = nil

function setup()
    ui.crankIndicator:start()

    background = Background()
    player = Player()
end

setup()

function playdate.update()  
    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:update() 
        return
    end  
    local _, acceleratedChange = playdate.getCrankChange()

    if acceleratedChange > 0 then
        background:scroll(acceleratedChange / speed_div)
    end

    gfx.sprite.update()
    playdate.timer.updateTimers()

end
