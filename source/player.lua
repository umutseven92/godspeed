class('Player').extends()

local gfx <const> = playdate.graphics

local screenWidth, screenHeight = playdate.display.getSize() 
local spriteHalfWidth = nil
local spriteHalfHeight = nil

function Player:init(xPosition)
    Player.super.init(self)
    
    print("Initializing player")

    self.x = xPosition
    self.y = 0

    local playerImage = gfx.image.new("images/player.png")
    self.sprite = gfx.sprite.new(playerImage)
    self.sprite:moveTo(self.x, self.y)
    self.sprite:add()
    
    spriteHalfWidth = self.sprite.width / 2
    spriteHalfHeight = self.sprite.height / 2

end

function Player:move(y)
    self.y = y
    self.sprite:moveTo(self.x, self.y)
end


