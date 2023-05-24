import "helpers/utils"

local gfx <const> = playdate.graphics
local screenWidth <const>, screenHeight <const> = playdate.display.getSize()

local speedUpText <const> = { "Crank it up!", "Speed up!", "Go! Go! GO!", "I hear beeping!", "Floor it!", "Step on it!", "I'm too young to die!" }
local restartText <const> = "Press any key to restart"

local message = nil

-- UI element that shows text messages to the player. When the player goes below a certain speed we show a random `speedUpText`, and when the game is over, we show `restartText`.
class("Message").extends()

function Message:init()
    self.posX = screenWidth - screenWidth * (3.8 / 4)
    self.posY = screenHeight * (3.65 / 4)
end

function Message:setSpeedUpText()
    if message == nil then
        _, message = getRandomElement(speedUpText)
    end
end

function Message:setRestartText()
    message = restartText
end

function Message:reset()
    message = nil
end


function Message:update()
    if message ~= nil then
        gfx.drawText(message, self.posX, self.posY)
    end
end
