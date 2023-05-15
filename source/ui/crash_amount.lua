local gfx <const> = playdate.graphics
local screenWidth <const>, screenHeight <const> = playdate.display.getSize()

local charToUse <const> = "I "
local crashAmount = 0

-- UI element that shows how many times the player crashed.
class("CrashAmount").extends()

function CrashAmount:init()
    self.posX = (screenWidth / 2) - 10
    self.posY = screenHeight * (0.1 / 4)
end

function CrashAmount:setCrashAmount(amount)
    crashAmount = amount
end

function CrashAmount:update()
    if crashAmount <= 0 then
        return
    end
    local toPrint = string.rep(charToUse, crashAmount)
    gfx.drawText(toPrint, self.posX, self.posY)
end
