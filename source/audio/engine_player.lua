import "sfx_player"

class("EnginePlayer").extends("SFXPlayer")

local prevSpeed = 0

function EnginePlayer:init()
    EnginePlayer.super.init(self, "assets/sounds/engine", 0.5)
end

function EnginePlayer:play(speed)
    if math.abs(speed - prevSpeed) > 30 then
        self.player:stop()
        prevSpeed = speed
    end
    if not self.player:isPlaying() then
        -- Adjust rate based on the speed, so it sounds more realistic.
        if speed > 150 then
            self.player:play(0, 1)
        elseif speed > 120 then
            self.player:play(0, 0.9)
        elseif speed > 100 then
            self.player:play(0, 0.8)
        elseif speed > 50 then
            self.player:play(0, 0.7)
        else
            self.player:play(0, 0.6)
        end
    end
end
