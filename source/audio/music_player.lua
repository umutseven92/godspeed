local sound <const> = playdate.sound

class("MusicPlayer").extends()

local musicPlayer = nil

function MusicPlayer:init()
    musicPlayer = sound.fileplayer.new("assets/music/theme")
    assert(musicPlayer)
    musicPlayer:setLoopRange(25.6, 38.4)
end

function MusicPlayer:play()
    musicPlayer:play(0)
end
