import "sfx_player"

class("SkidPlayer").extends("SFXPlayer")

function SkidPlayer:init()
    SkidPlayer.super.init(self, "assets/sounds/skid")
end

function SkidPlayer:play()
    self.player:play(1)
end
