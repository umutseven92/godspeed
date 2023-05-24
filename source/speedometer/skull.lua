import "base/base_drawn"

-- Part of the speedometer, the skull shows the player how close they are to exploding.
class('Skull').extends(BaseDrawn)

function Skull:init(posX, posY)
    Skull.super.init(self, "assets/images/skull", 10, posX, posY)
end

function Skull:setRatio(ratio)
    -- Ratio is a number between 0 and 1 that represent how much of the skull to show.

    local toShow = self.sprite.height * ratio
    self.sprite:setClipRect(self.sprite.x, self.sprite.y, self.sprite.width, toShow)
end
