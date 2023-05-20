-- Base class for anything that has a sprite.
class("BaseDrawn").extends()

local gfx <const> = playdate.graphics

function BaseDrawn:init(imageFile, zIndex, posX, posY)
    local image = gfx.image.new(imageFile)
    assert(image)

    self.sprite = gfx.sprite.new(image)
    self.sprite:moveTo(posX, posY)
    self.sprite:setZIndex(zIndex)
    self.sprite:add()
end
