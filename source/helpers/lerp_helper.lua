import "easing"

-- Helper class for LERPing. Supports position & rotation.
class("LerpHelper").extends()

function LerpHelper:init(entity)
    -- Entity is the class that will be LERPed.
    self.entity = entity
end

function LerpHelper:moveLerp(currentX, toX, currentY, toY, currentR, toR, lerpPosConst, lerpRotationConst)
    -- Set the target position, rotation & start interpolation.
    self.moveToX, self.moveToY = toX, toY
    self.moveFromX, self.moveFromY = currentX, currentY
    self.rotateFrom, self.rotateTo = currentR, toR

    self.lerpPosT = 0
    self.lerpRotT = 0

    -- LERP const for position
    -- Higher this is, faster the entity changes lanes.
    self.lerpPosConst = lerpPosConst

    -- LERP const for rotation
    -- Higher this is, faster the entity rotates.
    self.lerpRotationConst = lerpRotationConst
end


function LerpHelper:update(delta)
    -- Increment the lerp by one tick.
    if self.moveToX ~= nil and self.moveFromX ~= nil and self.moveToY ~= nil and self.moveFromY ~= nil then
        self.lerpPosT+= (self.lerpPosConst * delta)

        if self.lerpPosT > 1 then
            -- Our interpolation is finished; reset everything.
            self.entity:move(self.moveToX, self.moveToY)
            self.moveToX = nil
            self.moveFromX = nil
            self.moveToY = nil
            self.moveFromY = nil
            self.lerpPosT = 0
        else 
            -- Continue interpolation.
            local ease = easeOutBack(self.lerpPosT)

            local x = playdate.math.lerp(self.moveFromX, self.moveToX, ease)
            local y = playdate.math.lerp(self.moveFromY, self.moveToY, ease)
            self.entity:move(x, y)
        end
    end

    if self.rotateTo ~= nil then
        self.lerpRotT+= (self.lerpRotationConst * delta)
        
        if self.lerpRotT > 1 then

            self.lerpRotT = 0
            if self.rotateTo ~= 0 then
                -- We have rotated, now it is time to rotate back to 0.
                self.rotateFrom = self.rotateTo
                self.rotateTo = 0
            else
                self.rotateTo = nil
                self.rotateFrom = nil
                -- Our interpolation is finished; reset everything.
                self.entity:rotate(0)
            end
        else 
            -- Continue interpolation.
            local ease = easeOutBack(self.lerpRotT)
            local r = playdate.math.lerp(self.rotateFrom, self.rotateTo, ease)
            self.entity:rotate(r)
        end
        
    end
end