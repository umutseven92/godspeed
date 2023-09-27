import "helpers/utils"
import "CoreLibs/math"
import "sfx_player"

class("CrashPlayer").extends("SFXPlayer")

function CrashPlayer:init()
    CrashPlayer.super.init(self, "assets/sounds/crash")
end

function CrashPlayer:play()
    -- We set the rate to random so that every crash sounds different.
    local randRate = math.random() + 0.5
    self.player:setRate(randRate)
    self.player:play(1)
end
