import "obstacle"

class("ObstacleManager").extends()


function ObstacleManager:init(laneMap, screenWidth, speedDiv)
    self.spawnMap = {self.spawnBottom, self.spawnMiddle, self.spawnTop, self.spawnTopBottom, self.spawnBottomMiddle, self.spawnTopMiddle, self.spawnStaggered}

    self.obstacles = {}
    self.laneMap = laneMap
    self.screenWidth = screenWidth
    self.spawnPosX = screenWidth + 100
    self.speedDiv = speedDiv
end

function ObstacleManager:indexLaneMap(i)
    j = 1
    for k, v in pairs(self.laneMap) do
        if i == j then
            return k, v
        end
        j+=1
    end
end

function ObstacleManager:spawnRandom()
    local rand = math.random(#self.spawnMap)
    self.spawnMap[rand](self)
end

function ObstacleManager:spawnObstacle(posX, posY)
    local obstacle = Obstacle(posX, posY)
    table.insert(self.obstacles, obstacle)
end

function ObstacleManager:spawnObstacles(amount, offset)
    for i = 1, amount do
        local rand = math.random(3)
        local _, v = self:indexLaneMap(rand)
        self:spawnObstacle(self.spawnPosX + (i * offset), v)
    end
end

function ObstacleManager:spawnStaggered()
    local staggerAmount = 300 + math.random(-30, 30)
    self:spawnObstacles(3, staggerAmount)
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

function ObstacleManager:clean()
    local temp = {}
    for k,_ in ipairs(self.obstacles) do
        if self.obstacles[k].posX > 0 then
            table.insert(temp, self.obstacles[k])
        else
            self.obstacles[k]:remove()
        end
    end

    self.obstacles = temp
end

function ObstacleManager:scroll(speed)

    for _,v in ipairs(self.obstacles) do
        v:moveBy(speed / self.speedDiv)
    end
end