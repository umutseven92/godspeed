import "obstacle"

-- This class manages all obstacles & their lifecycles.
class("ObstacleManager").extends()

local screenWidth <const>, _ = playdate.display.getSize()

function ObstacleManager:init(laneMap, onCrashed)
    -- The easy obstacle spawn configurations are all on single lanes.
    self.easySpawnMap = { self.spawnBottom, self.spawnMiddle, self.spawnTop }

    -- Medium configurations also contain multiple obstacles spawning on multiple lanes at the same time.
    self.medSpawnMap = { self.spawnBottom, self.spawnMiddle, self.spawnTop, self.spawnTopBottom, self.spawnBottomMiddle,
        self.spawnTopMiddle }

    -- Hard configurations only contain multiple lanes spawning at the same time.
    self.hardSpawnMap = { self.spawnTopBottom, self.spawnBottomMiddle,
        self.spawnTopMiddle }

    self.currentSpawnMap = self.easySpawnMap
    self.obstacles = {}
    self.laneMap = laneMap
    self.spawnPosX = screenWidth + 100
    self.onCrashed = onCrashed
end

function ObstacleManager:indexLaneMap(i)
    j = 1
    for k, v in pairs(self.laneMap) do
        if i == j then
            return k, v
        end
        j += 1
    end
end

function ObstacleManager:spawnRandom()
    local rand = math.random(#self.currentSpawnMap)
    self.currentSpawnMap[rand](self)
end

function ObstacleManager:spawnObstacle(posX, posY)
    local staggerAmount = math.random(-30, 30)

    local obstacle = Obstacle(posX + staggerAmount, posY, self.onCrashed)
    table.insert(self.obstacles, obstacle)
end

function ObstacleManager:increaseDifficultyToMid()
    self.currentSpawnMap = self.medSpawnMap
end

function ObstacleManager:increaseDifficultyToHard()
    self.currentSpawnMap = self.hardSpawnMap
end

function ObstacleManager:spawnTopBottom()
    self:spawnTop()
    self:spawnBottom()
end

function ObstacleManager:spawnTopMiddle()
    self:spawnTop()
    self:spawnMiddle()
end

function ObstacleManager:spawnBottomMiddle()
    self:spawnBottom()
    self:spawnMiddle()
end

function ObstacleManager:spawnTop()
    self:spawnObstacle(self.spawnPosX, self.laneMap.top)
end

function ObstacleManager:spawnBottom()
    self:spawnObstacle(self.spawnPosX, self.laneMap.bottom)
end

function ObstacleManager:spawnMiddle()
    self:spawnObstacle(self.spawnPosX, self.laneMap.middle)
end

function ObstacleManager:removeOutOfBounds()
    -- Remove all obstacles that are out of the screen.
    local temp = {}
    for k, _ in ipairs(self.obstacles) do
        if self.obstacles[k].posX > 0 and self.obstacles[k].posY > 0 then
            table.insert(temp, self.obstacles[k])
        else
            self.obstacles[k]:remove()
        end
    end

    self.obstacles = temp
end

function ObstacleManager:scroll(speed)
    for _, v in ipairs(self.obstacles) do
        v:moveBy(speed)
    end
end

function ObstacleManager:update(delta)
    for _, v in ipairs(self.obstacles) do
        v:update(delta)
    end
end
