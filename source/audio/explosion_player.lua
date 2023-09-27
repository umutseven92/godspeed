import "sfx_player"

class("ExplosionPlayer").extends("SFXPlayer")

function ExplosionPlayer:init()
    ExplosionPlayer.super.init(self, "assets/sounds/explosion")
end

function ExplosionPlayer:play()
    self.player:play(1)
end
