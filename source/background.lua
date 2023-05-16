
class('Background').extends()

local gfx <const> = playdate.graphics

function Background:init()
    Background.super.init(self)

    print("Initializing background")
    self.x = 0
    local bgImage = gfx.image.new("images/background.png")
    self.imageWidth, _ = bgImage:getSize()

    self:spawnSprites(bgImage)
    self:moveSprites()
end

function Background:spawnSprites(bgImage)
    -- Spawn two sprites, which will be placed next to each other.
    local firstSprite = self:spawnSprite(bgImage)
    local secondSprite = self:spawnSprite(bgImage)

    self.sprites = {firstSprite, secondSprite}
end

function Background:spawnSprite(image, xPosition)
    local sprite = gfx.sprite.new(image)
    sprite:setCenter(0, 0)
    sprite:add()

    return sprite
end

function Background:moveSprites()
    for i=1, #self.sprites do
        self.sprites[i]:moveTo(self.x + ((i - 1) * self.imageWidth), 0)
    end
end

function Background:scroll(x)
    if (self.x - x) < -self.imageWidth then
        -- Move the sprites back to origin, to create a scrolling effect.
        self.x = 0
        self:moveSprites()
    end

    self.x -= x

    self:moveSprites()

end


