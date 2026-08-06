local Deer = require("objects.Units.Deer")
local Bear = require("objects.Units.Bear")

local UPDATE_PERIOD = 1
local DEER_STAY_PERIOD = 20

local DeerHerds = _G.class("DeerHerds")
function DeerHerds:initialize()
    self.updateTimer = UPDATE_PERIOD
    self.initialHerdsSpawned = false
    self.deerHerds = {}
end

function DeerHerds:registerDeer(deer)
    local herd = self.deerHerds[deer.herdIndex]
    if not herd then
        herd = { ["deers"] = {}, ["numberOfDeers"] = 0 }
        self.deerHerds[deer.herdIndex] = herd
    end
    herd.deers[deer] = deer
    herd.numberOfDeers = herd.numberOfDeers + 1
end

function DeerHerds:noDeersLeft()
    for _, herd in ipairs(self.deerHerds) do
        if herd.numberOfDeers > 0 then
            return false
        end
    end
    return true
end

function DeerHerds:removeDeer(deer)
    local herd = self.deerHerds[deer.herdIndex]
    herd.deers[deer] = nil
    herd.numberOfDeers = herd.numberOfDeers - 1
    if self:noDeersLeft() then
        self:respawnHerd(1)
    end
end

function DeerHerds:respawnHerd(herdIndex)
    local pointList = self:defineSpawnPoints()
    local spawnPoint = pointList[herdIndex]
    local herd = self.deerHerds[herdIndex]
    if _G.state.map:isWalkable(spawnPoint.gx, spawnPoint.gy) then
        herd.gx = spawnPoint.gx
        herd.gy = spawnPoint.gy
        for i = 1, spawnPoint.numberOfDeers do
            self:spawnDeer(spawnPoint.gx, spawnPoint.gy, herdIndex)
        end
    end
end

function DeerHerds:getHerdPosition(herdIndex)
    return self.deerHerds[herdIndex].gx, self.deerHerds[herdIndex].gy
end

function DeerHerds:getDeerHerds()
    return self.deerHerds
end

function DeerHerds:spawnDeer(gx, gy, herdIndex)
    local deerChoice = self.deerHerds[herdIndex].numberOfDeers % 3
    local deerAge = nil
    if deerChoice == 0 then
        deerAge = "adult"
    elseif deerChoice == 1 then
        deerAge = "medium"
    else
        deerAge = "baby"
    end
    Deer:new(gx, gy, herdIndex, deerAge)
end

--TODO: remove as soon spawnpoints can be defined by map data
function DeerHerds:defineSpawnPoints()
    local pointList = {}
    local mapWidth = _G.state.map:getMapWidthInTiles()
    if mapWidth == 512 then --Fernhaven
        table.insert(pointList, { ["gx"] = 357, ["gy"] = 331, ["numberOfDeers"] = 10 })
        table.insert(pointList, { ["gx"] = 63, ["gy"] = 265, ["numberOfDeers"] = 7 })
        table.insert(pointList, { ["gx"] = 101, ["gy"] = 109, ["numberOfDeers"] = 9 })
        table.insert(pointList, { ["gx"] = 369, ["gy"] = 35, ["numberOfDeers"] = 3 })
    elseif mapWidth == 128 then --Grasslands
        table.insert(pointList, { ["gx"] = 24, ["gy"] = 86, ["numberOfDeers"] = 5 })
    end

    return pointList
end

function DeerHerds:spawnInitialHerds()
    local pointList = self:defineSpawnPoints()

    for _, v in ipairs(pointList) do
        local herdIndex = #self.deerHerds + 1
        if _G.state.map:isWalkable(v.gx, v.gy) then
            self.deerHerds[herdIndex] = {
                ["gx"] = v.gx,
                ["gy"] = v.gy,
                ["deers"] = {},
                ["waitTimer"] = 0,
                ["migrating"] = false,
                ["numberOfDeers"] = 0
            }
            for i = 1, v.numberOfDeers do
                self:spawnDeer(v.gx, v.gy, herdIndex)
            end
        end
    end
    self.initialHerdsSpawned = true
end

function DeerHerds:updateHerds()
    for _, herd in ipairs(self.deerHerds) do
        if herd.waitTimer >= DEER_STAY_PERIOD and not herd.migrating then
            self:moveHerd(herd)
        else
            herd.waitTimer = herd.waitTimer + _G.dt
        end
    end
end

function DeerHerds:moveHerd(herd)
    local targetX, targetY
    repeat
        targetX = herd.gx + math.random(-30, 30)
        targetY = herd.gy + math.random(-30, 30)
    until _G.state.map:getWalkable(targetX, targetY) == 0
    herd.gx = targetX
    herd.gy = targetY
    herd.migrating = true
end

function DeerHerds:herdReachedLocation(herdIndex)
    local herd = self.deerHerds[herdIndex]
    herd.waitTimer = 0
    if herd.migrating then
        herd.migrating = false
    end
end

function DeerHerds:update()
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

function DeerHerds:serialize()
    local data = {}
    data.updateTimer = self.updateTimer
    data.initialHerdsSpawned = self.initialHerdsSpawned
    data.deerHerds = {}
    for index, herd in ipairs(self.deerHerds) do
        local herdData = {
            ["gx"] = herd.gx,
            ["gy"] = herd.gy,
            ["waitTimer"] = herd.waitTimer,
            ["migrating"] = herd.migrating
        }
        data.deerHerds[index] = herdData
    end
    return data
end

function DeerHerds:deserialize(data)
    if data then
        for index, savedHerd in ipairs(data.deerHerds) do
            local herd = self.deerHerds[index]
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

return DeerHerds:new()
