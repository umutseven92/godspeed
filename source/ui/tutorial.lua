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

    gfx.drawText("There is a bomb on the bus!", screenWidth - screenWidth * (3.8 / 4), screenHeight * (0.1 / 4))

    gfx.setImageDrawMode(playdate.graphics.kDrawModeInverted)
    gfx.drawText("Up & Down to change lanes.", screenWidth / 3, screenHeight / 4.45)
    gfx.drawText("Mash A to speed up.", screenWidth / 3, screenHeight / 2.15)
    gfx.drawText("If you stop, slow down, or\ncrash thrice, you explode!", screenWidth / 3, screenHeight / 1.5)
    gfx.setImageDrawMode(original_draw_mode)
end

function Tutorial:hide()
    self.sprite:setVisible(false)
end
