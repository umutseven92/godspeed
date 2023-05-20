import "base_drawn"

-- Base class for anything that has a sprite & collision.
class("BaseDrawnCollider").extends(BaseDrawn)

function BaseDrawnCollider:init(imageFile, zIndex, posX, posY, colGroups)
    BaseDrawnCollider.super.init(self, imageFile, zIndex, posX, posY)

    self.sprite:setCollideRect(posX, posY, self.sprite:getSize())
    self.sprite:setGroups(colGroups)
end
