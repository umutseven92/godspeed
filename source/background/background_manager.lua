import "background"

class('BackgroundManager').extends()

-- Higher this is, slower the background scrolls.
local speedDiv <const> = 10

function BackgroundManager:init()
    print("Initializing background")
    self.x = 0
    
    self.backgrounds = {Background(0, 0), Background(0, 0)}
    self.imageWidth = self.backgrounds[1].sprite.width

    self:moveSprites()
end

function BackgroundManager:moveSprites()
    for i=1, #self.backgrounds do
        self.backgrounds[i].sprite:moveTo(self.x + ((i - 1) * self.imageWidth), 0)
    end
end

function BackgroundManager:scroll(x)
    if (self.x - (x / speedDiv)) < -self.imageWidth then
        -- Move the sprites back to origin, to create a scrolling effect.
        self.x = 0
        self:moveSprites()
    end

    self.x -= (x / speedDiv)

    self:moveSprites()

end


