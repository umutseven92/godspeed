local sound <const> = playdate.sound

class("SFXPlayer").extends()


function SFXPlayer:init(sfxPath)
    self.player = sound.sampleplayer.new(sfxPath)
    assert(self.player)
end

function SFXPlayer:stop()
    self.player:stop()
end