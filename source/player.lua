import "CoreLibs/math"
import "utils"

class('Player').extends()

local gfx <const> = playdate.graphics
local lerpConst <const> = 1.2

local screenWidth, screenHeight = playdate.display.getSize()
local spriteHalfWidth = nil
local spriteHalfHeight = nil

local toMove = nil
local moveFrom = nil
local lerpT = nil

function Player:init(xPosition)
    Player.super.init(self)

    print("Initializing player")

    self.x = xPosition
    self.y = 0

    local playerImage = gfx.image.new("images/player.png")
    self.sprite = gfx.sprite.new(playerImage)
    self.sprite:moveTo(self.x, self.y)
    self.sprite:add()

    spriteHalfWidth = self.sprite.width / 2
    spriteHalfHeight = self.sprite.height / 2
end

function Player:move_lerp(y)
    toMove = y
    moveFrom = self.y
    lerpT = 0
end

function Player:move(y)
    self.y = y
    self.sprite:moveTo(self.x, self.y)
end

function Player:update(delta)
    if toMove ~= nil and moveFrom ~= nil then
        lerpT+= (lerpConst * delta)

        if lerpT > 1 then
            self:move(toMove)
            toMove = nil
            moveFrom = nil
            lerpT = 0
        else 
            local ease = easeOutBack(lerpT)
            local y = playdate.math.lerp(moveFrom, toMove, ease)
            self:move(y)
        end
    end

end
