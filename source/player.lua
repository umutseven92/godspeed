import "CoreLibs/math"
import "CoreLibs/animation"
import "CoreLibs/utilities/where"
import "helpers/utils"
import "base/base_drawn_collider"
import "lib/AnimatedSprite.lua"
import "helpers/lerp_helper"
import "audio/explosion_player"
import "audio/skid_player"

class("Player").extends(BaseDrawnCollider)

local gfx <const> = playdate.graphics
local colGroups <const> = { 1 }

local explosionPlayer = nil
local skidPlayer = nil

function Player:init(posX, posY)
    print("Initializing player")

    self.posX = posX
    self.posY = posY
    self.exploding = false

    Player.super.init(self, "assets/images/player", 2, self.posX, self.posY, colGroups, { 2 })

    local explosionTable = gfx.imagetable.new("assets/animations/explosion/player/explosion")
    assert(explosionTable)

    self.explosionAnimation = AnimatedSprite.new(explosionTable)
    self.explosionAnimation:setStates({ {
        name = "explode",
        loop = 1
    } })

    explosionPlayer = ExplosionPlayer()
    skidPlayer = SkidPlayer()

    self.lerpHelper = LerpHelper(self)
end

function Player:moveLerp(y)
    -- Set target & start LERPing.
    local rotateTo = 0
    if y > self.posY then
        rotateTo = 5
    else
        rotateTo = -5
    end
    skidPlayer:play()

    self.lerpHelper:moveLerp(self.posX, self.posX, self.posY, y, 0, rotateTo, 1.5, 2)
end

function Player:move(x, y)
    -- Move without LERPing.
    self.posX = x
    self.posY = y
    self.sprite:moveWithCollisions(self.posX, self.posY)
end

function Player:rotate(r)
    self.sprite:setRotation(r)
end

function Player:explode()
    self.sprite:remove()
    self.explosionAnimation:moveTo(self.posX, self.posY)
    self.explosionAnimation:playAnimation()
    explosionPlayer:play()

    self.exploding = true
end

function Player:update(delta)
    if self.exploding then
        return
    end

    self.lerpHelper:update(delta)
end
