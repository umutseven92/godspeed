import "CoreLibs/frameTimer"
import "skull"

-- Simple speedometer that flashes when the player is below a certain speed.
class("Speedometer").extends()

local gfx <const> = playdate.graphics
local screenWidth <const>, screenHeight <const> = playdate.display.getSize()

-- How quick the flashing is. Lower this is, more often the flashing.
local flashFrames <const> = 15

function Speedometer:init()
    self.posX = screenWidth * (3.65 / 4)
    self.posY = screenHeight * (3.65 / 4)

    self.skull = Skull(self.posX - 40, self.posY - 8)

    self.skull.sprite:setCenter(0, 0)
    self.skull.sprite:setVisible(false)

    self.hide = false
    self.flashing = false
end

function Speedometer:startFlashing()
    if self.flashing then
        return
    end
    self.flashing = true
    self.hide = true
    self.flashTimer = playdate.frameTimer.new(flashFrames, function()
        self.hide = not self.hide
    end)
    self.flashTimer.repeats = true
end

function Speedometer:stopFlashing()
    if not self.flashing then
        return
    end

    self.flashing = false
    self.hide = false
    self.flashTimer:pause()
    self.flashTimer:remove()
end

function Speedometer:update(speed)
    if not self.hide then
        gfx.drawText(string.format("%d", math.floor(speed)), self.posX, self.posY)
    end

    self.skull.sprite:setVisible(self.flashing)
end

function Speedometer:setSkullRatio(ratio)
    self.skull:setRatio(ratio)
end
