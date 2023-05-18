import "CoreLibs/frameTimer"
import "skull"

class('Speedometer').extends()

local gfx <const> = playdate.graphics

-- Higher this is, higher the speed shown in the speedometer.
-- Does not affect the actual speed.
local speedModifier <const> = 10

function Speedometer:init(screenWidth, screenHeight)
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
    self.flashTimer = playdate.frameTimer.new(15, function()
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
        gfx.drawText(string.format("%d", math.floor(speed * speedModifier)), self.posX, self.posY)
    end

    self.skull.sprite:setVisible(self.flashing)
end