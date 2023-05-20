import "base/base_drawn_collider"
import "lib/AnimatedSprite.lua"
import "utils"

class("Obstacle").extends(BaseDrawnCollider)

local gfx <const> = playdate.graphics

local colGroups <const> = {2}
local imagesPath <const> = "assets/images/obstacles/"

-- LERP const for position
-- Higher this is, faster the player changes lanes.
local lerpPosConst <const> = 1.5

-- t value for position LERP
local lerpPosT = nil

-- LERP const for rotation
-- Higher this is, faster the player rotates.
local lerpRotationConst <const> = 2

-- t value for rotation LERP
local lerpRotT = nil

-- How much to rotate
local rotateAmount <const> = 5

local moveFrom = nil
local moveTo = nil
local rotateFrom = nil
local rotateTo = nil

function Obstacle:init(posX, posY)
    self.posX = posX
    self.posY = posY
    self.skidding = false
    local imageFiles = playdate.file.listFiles(imagesPath)
    local rand = math.random(#imageFiles)

    local imageFile = imagesPath .. imageFiles[rand]

    Obstacle.super.init(self, imageFile, 1, self.posX, self.posY, colGroups, {1})
end

function Obstacle:moveBy(xAmount)
    self.posX -= xAmount
    self:move(self.posY)
end

function Obstacle:move(posY)
    self.sprite:moveTo(self.posX, posY)
    local actualX, actualY, collisions, length = self.sprite:moveWithCollisions(self.posX, posY)
    if length > 0 then
        self:skid()
    end
end

function Obstacle:remove()
    self.sprite:remove()
end

function Obstacle:skid()
    self.skidding = true
    self:moveLerp(-100)
end

function Obstacle:update(delta)
    if moveTo ~= nil and moveFrom ~= nil then
        lerpPosT+= (lerpPosConst * delta)

        -- Continue interpolation.
        local ease = easeOutBack(lerpPosT)

        local y = playdate.math.lerp(moveFrom, moveTo, ease)
        self:move(y)
    end

    if rotateTo ~= nil then
        lerpRotT+= (lerpRotationConst * delta)
        
        if lerpRotT > 1 then

            lerpRotT = 0
            if rotateTo ~= 0 then
                -- We have rotated, now it is time to rotate back to 0.
                rotateFrom = rotateTo
                rotateTo = 0
            else
                rotateTo = nil
                -- Our interpolation is finished; reset everything.
                self.sprite:setRotation(0)

            end
        else 
            -- Continue interpolation.
            local ease = easeOutBack(lerpRotT)
            local r = playdate.math.lerp(rotateFrom, rotateTo, ease)
            self.sprite:setRotation(r)
        end
        
    end
end


function Obstacle:moveLerp(y)
    -- Set the target position & start interpolation.
    moveTo = y
    moveFrom = self.posY
    lerpPosT = 0
    lerpRotT = 0
    rotateFrom = 0
    if y > self.posY then
        rotateTo = rotateAmount  
    else
        rotateTo = -rotateAmount
    end
end