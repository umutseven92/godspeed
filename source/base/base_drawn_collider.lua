import "base_drawn"

local gfx <const> = playdate.graphics

-- Base class for anything that has a sprite & collision.
class("BaseDrawnCollider").extends(BaseDrawn)

function BaseDrawnCollider:init(imageFile, zIndex, posX, posY, colGroups, colWithGroups)
    BaseDrawnCollider.super.init(self, imageFile, zIndex, posX, posY)

    self.sprite:setCollideRect(0, 0, self.sprite:getSize())
    self.sprite:setGroups(colGroups)
    self.sprite:setCollidesWithGroups(colWithGroups)
    self.sprite.collisionResponse = gfx.sprite.kCollisionTypeOverlap

end