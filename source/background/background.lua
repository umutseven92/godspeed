import "base/base_drawn"

class('Background').extends(BaseDrawn)

function Background:init(posX, posY)
    Background.super.init(self, "assets/images/background", -10, posX, posY)
    self.sprite:setCenter(0, 0)
end
