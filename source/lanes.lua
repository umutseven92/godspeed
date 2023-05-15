-- The three lanes the player will drive on. The lanes can be switched by the up & down buttons.
class("Lanes").extends()

local up <const> = "up"
local down <const> = "down"

local _, screenHeight <const> = playdate.display.getSize()

function Lanes:init()
    print("Initializing lanes")
    self.laneMap = { top = screenHeight / 4, middle = screenHeight / 2, bottom = screenHeight - screenHeight / 4 }
    self.currentLane = self.laneMap.middle
end

function Lanes:setLane(direction)
    -- Change the current lane. The player can only change to adjacent lanes, and only if the lane they want to change to is not out of bounds. 
    -- Returns a boolean representing whether the player can change a lane.

    local oldLane = self.currentLane
    if direction == up then
        if self.currentLane == self.laneMap.middle then
            self.currentLane = self.laneMap.top
        elseif self.currentLane == self.laneMap.bottom
        then
            self.currentLane = self.laneMap.middle
        end
    elseif direction == down then
        if self.currentLane == self.laneMap.middle then
            self.currentLane = self.laneMap.bottom
        elseif self.currentLane == self.laneMap.top
        then
            self.currentLane = self.laneMap.middle
        end
    end

    if self.currentLane == oldLane then
        return false
    else
        return true
    end
end
