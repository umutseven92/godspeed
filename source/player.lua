import "CoreLibs/math"
import "utils"

class('Player').extends()

local gfx <const> = playdate.graphics

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
    Player.super.init(self)

    print("Initializing player")

    self.x = xPosition
    self.y = 0

    local playerImage = gfx.image.new("images/player.png")
    assert(playerImage)

    self.sprite = gfx.sprite.new(playerImage)
    self.sprite:moveTo(self.x, self.y)
    self.sprite:setZIndex(1)
    self.sprite:add()
end

function Player:moveLerp(y)
    -- Set the target position & start interpolation.
    moveTo = y
    moveFrom = self.y
    lerpPosT = 0
    lerpRotT = 0
    rotateFrom = 0
    if y > self.y then
        rotateTo = rotateAmount  
    else
        rotateTo = -rotateAmount
    end
end

function Player:move(y)
    self.y = y
    self.sprite:moveTo(self.x, self.y)
end

function Player:update(delta)
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
