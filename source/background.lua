
class('Background').extends()

local gfx <const> = playdate.graphics

local screenWidth = playdate.display.getWidth()

function Background:init()
    Background.super.init(self)

    print("Initializing background")
    self.x = 0

    local bgImage = gfx.image.new("images/background.png")
    self.sprite = gfx.sprite.new(bgImage)
    self.sprite:setCenter(0, 0)
    self.sprite:moveTo(self.x, 0)
    self.sprite:add()

end

function Background:scroll(x)
    self.x -= x
    

    self.sprite:moveBy(-x, 0)
end


