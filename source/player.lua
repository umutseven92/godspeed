import "CoreLibs/math"
import "CoreLibs/animation"
import "CoreLibs/animator"
import "utils"
import "base/base_drawn_collider"
import "lib/AnimatedSprite.lua"

class('Player').extends(BaseDrawnCollider)

local gfx <const> = playdate.graphics

local colGroups <const> = {1}

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

function Player:init(xPosition)

    print("Initializing player")

    self.posX = xPosition
    self.posY = 0
    self.exploding = false
    
    Player.super.init(self, "assets/images/player", 2, self.posX, self.posY, colGroups, {2})
    
    local explosionTable = gfx.imagetable.new("assets/animations/explosion/player/explosion")
    assert(explosionTable)
    
    self.explosionAnimation = AnimatedSprite.new(explosionTable)    
    self.explosionAnimation:setStates({{
        name = "explode",
        loop = 1
    }})
    
end

function Player:moveLerp(y)
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

function Player:move(y)
    self.posY = y
    local actualX, actualY, collisions, length = self.sprite:moveWithCollisions(self.posX, self.posY)

    
    if length > 0 then
        
    end
end

function Player:explode()
    self.sprite:remove()
    self.explosionAnimation:moveTo(self.posX, self.posY) 
    self.explosionAnimation:playAnimation()

    self.exploding = true
end

function Player:update(delta)
    if self.exploding then
        return
    end

    if moveTo ~= nil and moveFrom ~= nil then
        lerpPosT+= (lerpPosConst * delta)

        if lerpPosT > 1 then
            -- Our interpolation is finished; reset everything.
            self:move(moveTo)
            moveTo = nil
            moveFrom = nil
            lerpPosT = 0

        else 
            -- Continue interpolation.
            local ease = easeOutBack(lerpPosT)

            local y = playdate.math.lerp(moveFrom, moveTo, ease)
            self:move(y)
        end
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
