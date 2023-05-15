class('Player').extends()

local gfx <const> = playdate.graphics

local screenWidth, screenHeight = playdate.display.getSize() 
local spriteHalfWidth = nil
local spriteHalfHeight = nil

function Player:init()
    Player.super.init(self)
    
    print("Initializing player")

    self.x = screenWidth / 4
    self.y = screenHeight / 2

    local playerImage = gfx.image.new("images/player.png")
    self.sprite = gfx.sprite.new(playerImage)
    self.sprite:moveTo(self.x, self.y)
    self.sprite:add()
    
    spriteHalfWidth = self.sprite.width / 2
    spriteHalfHeight = self.sprite.height / 2

end

function Player:move(x, y)

    if self.x + x <= screenWidth - spriteHalfWidth and self.x + x >= spriteHalfWidth then
        self.x += x
    end
    if self.y + y <= screenHeight - spriteHalfHeight and self.y + y >= spriteHalfHeight  then
        self.y += y
    end

    self.sprite:moveTo(self.x, self.y)
end


