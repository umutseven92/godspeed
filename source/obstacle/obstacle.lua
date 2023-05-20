import "base/base_drawn_collider"
import "lib/AnimatedSprite.lua"

class("Obstacle").extends(BaseDrawnCollider)

local gfx <const> = playdate.graphics

local colGroups <const> = {2}

local imagesPath <const> = "assets/images/obstacles/"

function Obstacle:init(posX, posY)
    self.posX = posX
    self.posY = posY
    self.exploding = false
    local imageFiles = playdate.file.listFiles(imagesPath)
    local rand = math.random(#imageFiles)

    local imageFile = imagesPath .. imageFiles[rand]

    Obstacle.super.init(self, imageFile, 1, self.posX, self.posY, colGroups)
    
    local explosionTable = gfx.imagetable.new("assets/animations/explosion/obstacle/explosion")
    assert(explosionTable)
    
    self.explosionAnimation = AnimatedSprite.new(explosionTable)    
    self.explosionAnimation:setStates({{
        name = "explode",
        loop = 1
    }})

end

function Obstacle:moveBy(xAmount)
    self.posX -= xAmount
    self.sprite:moveTo(self.posX, self.posY)
end

function Obstacle:remove()
    self.sprite:remove()
end

function Obstacle:explode()
    self.sprite:remove()
    self.explosionAnimation:moveTo(self.x, self.y) 
    self.explosionAnimation:playAnimation()

    self.exploding = true
end