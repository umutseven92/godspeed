import "base/base_drawn_collider"
import "lib/AnimatedSprite.lua"
import "helpers/utils"
import "helpers/lerp_helper"
import "audio/crash_player"

class("Obstacle").extends(BaseDrawnCollider)

local _, screenHeight <const> = playdate.display.getSize()

local colGroups <const> = {2}
local imagesPath <const> = "assets/images/obstacles/"

local crashPlayer = nil

function Obstacle:init(posX, posY, speedModifierFunc)
    self.posX = posX
    self.posY = posY
    self.skidding = false
    local imageFiles = playdate.file.listFiles(imagesPath)
    local rand = math.random(#imageFiles)

    local imageFile = imagesPath .. imageFiles[rand]

    Obstacle.super.init(self, imageFile, 1, self.posX, self.posY, colGroups, {1})
    crashPlayer = CrashPlayer()
    self.lerpHelper = LerpHelper(self)
    self.speedModifierFunc = speedModifierFunc

    self.collided = false
end

function Obstacle:moveBy(xAmount)
    self.posX -= xAmount
    self:move(self.posX, self.posY)
end

function Obstacle:move(posX, posY)
    self.posX = posX
    self.posY = posY
    local _, _, _, length = self.sprite:moveWithCollisions(posX, posY)

    if self.collided then
        -- Each obstacle can be collided only once, so return if we already did.
        return
    end

    if length > 0 then
        crashPlayer:play()
        self.speedModifierFunc(2)
        self:skid()
    end
end

function Obstacle:moveLerp(y)
    -- Set the target position & start interpolation.
    local rotateTo = 0
    if y > self.posY then
        rotateTo = 5 
    else
        rotateTo = -5
    end
    
    self.lerpHelper:moveLerp(self.posX, self.posX, self.posY, y, 0, rotateTo, 2, 2)
end

function Obstacle:remove()
    self.sprite:remove()
end

function Obstacle:skid()
    self.collided = true
    self.skidding = true
    if self.posY > screenHeight / 2 then
        self:moveLerp(screenHeight + 20)
    else
        self:moveLerp(-20)
    end
end

function Obstacle:update(delta)
    if self.skidding then
        self.lerpHelper:update(delta)
    end
end

function Obstacle:rotate(r)
    self.sprite:setRotation(r)    
end