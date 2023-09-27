import "sfx_player"

class("SlowBeepPlayer").extends("SFXPlayer")

function SlowBeepPlayer:init()
    SlowBeepPlayer.super.init(self, "assets/sounds/beep-slow")
end
