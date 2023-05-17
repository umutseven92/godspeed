import "CoreLibs/frameTimer"
import "skull"

class('Speedometer').extends()

local gfx <const> = playdate.graphics

-- Higher this is, lower the speed shown in the speedometer.
-- Does not affect the actual speed.
local speedDiv <const> = 1.5

function Speedometer:init(screenWidth, screenHeight)
    self.posX = screenWidth * (3.5 / 4)
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
    -- Invert the draw mode & print the speed.
    -- Draw mode is inverted to make the text white, as the font itself is black.
    local originalDrawMode = gfx.getImageDrawMode()

    gfx.setImageDrawMode(playdate.graphics.kDrawModeInverted)

    if not self.hide then
        gfx.drawText(string.format("%d", math.floor(speed / speedDiv)), self.posX, self.posY)
    end
    gfx.setImageDrawMode(originalDrawMode)

    self.skull.sprite:setVisible(self.flashing)
end
