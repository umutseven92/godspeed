class('Lanes').extends()

local up <const> = "up"
local down <const> = "down"


function Lanes:init(screenHeight)
    print("Initializing lanes")
    self.lanes = { top = screenHeight / 4, middle = screenHeight / 2, bottom = screenHeight - screenHeight / 4 }
    self.currentLane = self.lanes.middle
end

function Lanes:getCurrentLane()
    return self.currentLane
end

-- Returns whether the lane changed.
function Lanes:setLane(direction)
    local oldLane = self.currentLane
    if direction == up then
        if self.currentLane == self.lanes.middle then
            self.currentLane = self.lanes.top
        elseif self.currentLane == self.lanes.bottom
        then
            self.currentLane = self.lanes.middle
        end
    elseif direction == down then
        if self.currentLane == self.lanes.middle then
            self.currentLane = self.lanes.bottom
        elseif self.currentLane == self.lanes.top
        then
            self.currentLane = self.lanes.middle
        end
    end

    if self.currentLane == oldLane then
        return false
    else
        return true
    end
end
