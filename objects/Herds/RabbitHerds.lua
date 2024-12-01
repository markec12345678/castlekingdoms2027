local Rabbit = require("objects.Units.Rabbit")

local UPDATE_PERIOD = 1
local RABBIT_STAY_PERIOD = 15
local MIGRATION_RADIUS = 10

local RabbitHerds = _G.class("RabbitHerds")
function RabbitHerds:initialize()
    self.updateTimer = UPDATE_PERIOD
    self.initialHerdsSpawned = false
    self.rabbitHerds = {}
end

function RabbitHerds:registerRabbit(rabbit)
    local herd = self.rabbitHerds[rabbit.herdIndex]
    if not herd then
        herd = { ["rabbits"] = {}, ["numberOfRabbits"] = 0 }
        self.rabbitHerds[rabbit.herdIndex] = herd
    end
    herd.rabbits[rabbit] = rabbit
    herd.numberOfRabbits = herd.numberOfRabbits + 1
end

function RabbitHerds:removeRabbit(rabbit)
    local herd = self.rabbitHerds[rabbit.herdIndex]
    herd.rabbits[rabbit] = nil
    herd.numberOfRabbits = herd.numberOfRabbits - 1
end

function RabbitHerds:respawnHerd(herdIndex)
    local pointList = self:defineSpawnPoints()
    local spawnPoint = pointList[herdIndex]
    local herd = self.rabbitHerds[herdIndex]
    if _G.state.map:isWalkable(spawnPoint.gx, spawnPoint.gy) then
        herd.gx = spawnPoint.gx
        herd.gy = spawnPoint.gy
        for i = 1, spawnPoint.numberOfRabbits do
            self:spawnRabbit(spawnPoint.gx, spawnPoint.gy, herdIndex)
        end
    end
end

function RabbitHerds:getHerd(herdIndex)
    return self.rabbitHerds[herdIndex]
end

function RabbitHerds:getHerdPosition(herdIndex)
    return self.rabbitHerds[herdIndex].gx, self.rabbitHerds[herdIndex].gy
end

function RabbitHerds:getRabbitHerds()
    return self.rabbitHerds
end

--TODO: remove as soon spawnpoints can be defined by map data
function RabbitHerds:defineSpawnPoints()
    local pointList = {}
    local mapWidth = _G.state.map:getMapWidthInTiles()
    if mapWidth == 512 then --Fernhaven
        table.insert(pointList, { ["gx"] = 202, ["gy"] = 233, ["numberOfRabbits"] = 5 })
        table.insert(pointList, { ["gx"] = 407, ["gy"] = 426, ["numberOfRabbits"] = 6 })
    elseif mapWidth == 128 then --Grasslands
        --       table.insert(pointList, {["gx"] = 115, ["gy"] = 112, ["numberOfRabbits"] = 5})
    end

    return pointList
end

function RabbitHerds:spawnInitialHerds()
    local pointList = self:defineSpawnPoints()

    for _, v in ipairs(pointList) do
        local herdIndex = #self.rabbitHerds + 1
        if _G.state.map:isWalkable(v.gx, v.gy) then
            self.rabbitHerds[herdIndex] = {
                ["gx"] = v.gx,
                ["gy"] = v.gy,
                ["rabbits"] = {},
                ["waitTimer"] = 0,
                ["migrating"] = false,
                ["numberOfRabbits"] = 0
            }
            for i = 1, v.numberOfRabbits do
                Rabbit:new(v.gx, v.gy, herdIndex)
            end
        end
    end
    self.initialHerdsSpawned = true
end

function RabbitHerds:updateHerds()
    for _, herd in ipairs(self.rabbitHerds) do
        if herd.waitTimer >= RABBIT_STAY_PERIOD and not herd.migrating then
            self:moveHerd(herd)
        else
            herd.waitTimer = herd.waitTimer + _G.dt
        end
    end
end

function RabbitHerds:moveHerd(herd)
    local targetX, targetY
    repeat
        targetX = herd.gx + math.random(-MIGRATION_RADIUS, MIGRATION_RADIUS)
        targetY = herd.gy + math.random(-MIGRATION_RADIUS, MIGRATION_RADIUS)
    until _G.state.map:getWalkable(targetX, targetY) == 0
    herd.gx = targetX
    herd.gy = targetY
    herd.migrating = true
end

function RabbitHerds:herdReachedLocation(herdIndex)
    local herd = self.rabbitHerds[herdIndex]
    herd.waitTimer = 0
    if herd.migrating then
        herd.migrating = false
    end
end

function RabbitHerds:update()
    if self.updateTimer >= UPDATE_PERIOD then
        self.updateTimer = 0
        if not self.initialHerdsSpawned then
            self:spawnInitialHerds()
        end
    else
        self.updateTimer = self.updateTimer + _G.dt
    end
    self:updateHerds()
end

function RabbitHerds:serialize()
    local data = {}
    data.updateTimer = self.updateTimer
    data.initialHerdsSpawned = self.initialHerdsSpawned
    data.rabbitHerds = {}
    for index, herd in ipairs(self.rabbitHerds) do
        local herdData = {
            ["gx"] = herd.gx,
            ["gy"] = herd.gy,
            ["waitTimer"] = herd.waitTimer,
            ["migrating"] = herd.migrating
        }
        data.rabbitHerds[index] = herdData
    end
    return data
end

function RabbitHerds:deserialize(data)
    if data then
        for index, savedHerd in ipairs(data.rabbitHerds) do
            local herd = self.rabbitHerds[index]
            if herd then
                herd.gx = savedHerd.gx
                herd.gy = savedHerd.gy
                herd.waitTimer = savedHerd.waitTimer
                herd.migrating = savedHerd.migrating
            end
        end
        self.initialHerdsSpawned = data.initialHerdsSpawned
        self.updateTimer = data.updateTimer
    end
end

return RabbitHerds:new()
