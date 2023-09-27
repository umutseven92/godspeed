local gfx <const> = playdate.graphics
local screenWidth <const>, screenHeight <const> = playdate.display.getSize()

local message <const> = "Score: %d"

-- This gets divided by the score before being added to the total score. Without it the score gets too large.
local scoreDiv <const> = 100

-- How quick the flashing is. Lower this is, more often the flashing.
local flashFrames <const> = 15

-- UI element that shows the score. Flashes after the game is over.
class("Score").extends()

function Score:init()
    self.posX = screenWidth - screenWidth * (3.8 / 4)
    self.posY = screenHeight * (0.1 / 4)
    self.totalScore = 0
    self.hide = false
    self.flashing = false
end

function Score:addToTotalScore(score)
    self.totalScore += math.floor(score / scoreDiv)
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

function Score:update()
    if not self.hide then
        gfx.drawText(string.format(message, self.totalScore), self.posX, self.posY)
    end
end
