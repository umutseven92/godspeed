import "helpers/utils"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
local ds <const> = playdate.datastore

local screenWidth <const>, screenHeight <const> = playdate.display.getSize()

local highScore = nil
local message <const> = "High Score: %d"
local dataName <const> = "gs-data"

-- UI element that shows the players high score.
class("HighScore").extends()

function HighScore:init()
    self.posX = screenWidth * (3.8 / 4)
    self.posY = screenHeight * (0.1 / 4)
    highScore = self:getInitialHighScore()
end

function HighScore:setHighScore(score)
    if score > highScore then
        local data = {}
        data["high_score"] = score
        ds.write(data, dataName)
        highScore = score
    end
end

function HighScore:update()
    if highScore > 0 then
        gfx.drawTextAligned(string.format(message, highScore), self.posX, self.posY, kTextAlignment.right)
    end
end

function HighScore:getInitialHighScore()
    local data = ds.read(dataName)

    if data == nil then
        -- Create the initial data file.
        local defaultData = {}
        defaultData["high_score"] = 0
        ds.write(defaultData, dataName)
        return 0
    else
        return data["high_score"]
    end
end
