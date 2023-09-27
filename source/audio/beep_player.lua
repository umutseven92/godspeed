import "slow_beep_player"
import "fast_beep_player"

class("BeepPlayer").extends()

function BeepPlayer:init()
    self.slowBeep = SlowBeepPlayer()
    self.fastBeep = FastBeepPlayer()
end

function BeepPlayer:playSlowBeep()
    self.fastBeep.player:stop()
    if not self.slowBeep.player:isPlaying() then
        self.slowBeep.player:play(0)
    end
end

function BeepPlayer:playFastBeep()
    self.slowBeep.player:stop()
    if not self.fastBeep.player:isPlaying() then
        self.fastBeep.player:play(0)
    end
end

function BeepPlayer:stop()
    self.slowBeep.player:stop()
    self.fastBeep.player:stop()
end
