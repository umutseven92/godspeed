local sound <const> = playdate.sound

class("SFXPlayer").extends()


function SFXPlayer:init(sfxPath, volume)
    self.player = sound.sampleplayer.new(sfxPath)
    self.player:setVolume(volume)
    assert(self.player)
end

function SFXPlayer:stop()
    self.player:stop()
end