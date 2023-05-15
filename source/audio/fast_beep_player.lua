import "sfx_player"

class("FastBeepPlayer").extends("SFXPlayer")

function FastBeepPlayer:init()
    SlowBeepPlayer.super.init(self, "assets/sounds/beep-fast", 1.0)
end
