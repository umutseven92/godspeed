import "base_drawn"

class("Obstacle").extends(BaseDrawn)

local imagesPath <const> = "assets/images/obstacles/"


function Obstacle:init()
    local imageFiles = playdate.file.listFiles(imagesPath)
    local rand = math.random(#imageFiles)

    local imageFile = imagesPath .. imageFiles[rand]

    Obstacle.super.init(self, imageFile, 1, 200, 200)
end
