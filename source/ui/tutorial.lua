import "base/base_drawn"

local gfx <const> = playdate.graphics
local screenWidth <const>, screenHeight <const> = playdate.display.getSize()

-- The tutorial panel that gets shown when the player first opens the game.
class("Tutorial").extends(BaseDrawn)

function Tutorial:init()
    Tutorial.super.init(self, "assets/images/tutorial", 20, screenWidth / 2, screenHeight / 2)
    self.sprite:setVisible(false)
end

function Tutorial:show()
    self.sprite:setVisible(true)

    -- We want the tutorial messages to be black (rather than white, which we set during initialisation), so we revert the color before drawing.
    local original_draw_mode = gfx.getImageDrawMode()

    gfx.setImageDrawMode(playdate.graphics.kDrawModeInverted)
    gfx.drawText("Up & Down to change lanes.", screenWidth / 3, screenHeight / 4.45)
    gfx.drawText("Mash A to speed up.", screenWidth / 3, screenHeight / 2.15)
    gfx.drawText("If you slow down, you die.", screenWidth / 3, screenHeight / 1.4)
    gfx.setImageDrawMode(original_draw_mode)
end

function Tutorial:hide()
    self.sprite:setVisible(false)
end
