
local gfx <const> = playdate.graphics
local screenWidth <const>, screenHeight <const> = playdate.display.getSize()

local scoreDiv <const> = 100
local flashFrames <const> = 15

class("Score").extends()

function Score:init()
    self.posX = screenWidth- screenWidth * (3.8 / 4)
    self.posY = screenHeight * (0.1 / 4)
    self.totalScore = 0
    self.hide = false
    self.flashing = false
end

function Score:addToTotalScore(score)
    self.totalScore += score
end

function Score:startFlashing()
    if self.flashing then
        return
    end
    self.flashing = true
    self.hide = true
    self.flashTimer = playdate.frameTimer.new(flashFrames, function()
        self.hide = not self.hide
    end)
    self.flashTimer.repeats = true
end

function Score:getScore()
    return math.floor(self.totalScore / scoreDiv)
end

function Score:update()
    if not self.hide then
        gfx.drawText(self:getScore(), self.posX, self.posY)
    end
end
