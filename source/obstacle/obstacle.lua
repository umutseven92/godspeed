import "base_drawn"

class("Obstacle").extends(BaseDrawn)

local imagesPath <const> = "assets/images/obstacles/"


function Obstacle:init(posX, posY)
    self.posX = posX
    self.posY = posY
    local imageFiles = playdate.file.listFiles(imagesPath)
    local rand = math.random(#imageFiles)

    local imageFile = imagesPath .. imageFiles[rand]

    Obstacle.super.init(self, imageFile, 1, self.posX, self.posY)
end

function Obstacle:moveBy(xAmount)
    self.posX -= xAmount
    self.sprite:moveTo(self.posX, self.posY)
end

function Obstacle:remove()
    self.sprite:remove()
end