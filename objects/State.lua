local bitser = require("libraries.bitser")
local Map = require("objects.Map")
local SaveManager = require("objects.Controllers.SaveManager")
local FOOD = require("objects.Enums.Food")
local WEAPON = require("objects.Enums.Weapon")
local warningTooltip = require("states.ui.warning_tooltip")

---@class State
---@field new fun():State
---@field map Map
---@overload fun():State
local State = _G.class("State")
function State:initialize()
    self.savename = SaveManager:getNextFreeName()
    self.newGame = true
    self.serializedObjectIds = {}
    self.deserializedObjectIds = {}
    self.map = Map:new()
    self.topLeftChunkX = 0
    self.topLeftChunkY = 0
    self.bottomRightChunkX = 0
    self.bottomRightChunkY = 0
    self.object = newAutotable(4)
    self.objectMesh = newAutotable(2)
    self.objectMeshVertIdMap = newAutotable(3)
    self.verticesPerTile = 6
    self.chunkObjects = newAutotable(3)
    self.scaleX = 0.7
    self.viewXview = -100
    self.viewYview = 2000
    self.popularity = 50
    self.gold = 1000
    self.population = 0
    self.maxPopulation = 5
    -- TODO: Make the collision map dynamic
    self.resources = {
        ["wood"] = 0,
        ['hop'] = 0,
        ["stone"] = 0,
        ["iron"] = 0,
        ["tar"] = 0,
        ["flour"] = 0,
        ["ale"] = 0,
        ["wheat"] = 0,
        ["gold"] = self.gold
    }
    self.food = {
        [FOOD.meat] = 0,
        [FOOD.apples] = 0,
        [FOOD.bread] = 0,
        [FOOD.cheese] = 0
    }
    self.notFullStockpiles = {
        ["wood"] = 0,
        ['hop'] = 0,
        ["stone"] = 0,
        ["iron"] = 0,
        ["tar"] = 0,
        ["flour"] = 0,
        ["ale"] = 0,
        ["wheat"] = 0
    }
    self.notFullFoods = {
        [FOOD.meat] = 0,
        [FOOD.apples] = 0,
        [FOOD.bread] = 0,
        [FOOD.cheese] = 0
    }
    self.notFullArmoury = {}
    self.weapons = {}
    for _, v in pairs(WEAPON) do
        self.notFullArmoury[v] = 0
        self.weapons[v] = 0
    end
    self.wheatSeasonCounter = 0
    self.wheatGrowingSeason = false
    self.hopsSeasonCounter = 0
    self.hopsGrowingSeason = false
    self.firstWoodCutterHut = true
    self.firstArmoury = true
    self.firstBuildings = true
    self.keepX = 0
    self.keepY = 0
end

function State:save()
    return self:serialize()
end

function State:serializeObject(obj)
    if not self.serializedObjectIds[obj.id] then
        self.serializedObjectIds[obj.id] = obj:serialize()
        if not self.serializedObjectIds[obj.id] then
            error("Serialized object has no data!")
        end
    end
    return {
        _ref = obj.id,
        info = tostring(obj)
    }
end

function State:dereferenceObject(refObj)
    local ref = refObj._ref
    if not ref and refObj.className then
        -- Probably the object itself
        ref = refObj.id
    end
    -- Check if object has been deserialized already
    if self.deserializedObjectIds[ref] then
        return self.deserializedObjectIds[ref]
    end
    -- Find the object and deserialize it
    if self.rawObjectIds[ref] then
        local obj = self.rawObjectIds[ref]
        if obj and obj.className then
            local object = _G.getClassByName(obj.className)
            if object then
                local ret = object:deserialize(obj)
                self.deserializedObjectCount = self.deserializedObjectCount + 1
                self.deserDebug[obj.className] = (self.deserDebug[obj.className] or 0) + 1
                self.deserializedObjectIds[ref] = ret
                return ret
            end
        end
    end
    error("Did you miss to add the Alias in the Object class exclusion list?\n" ..
        "Couldn't dereference object:" .. tostring(self.rawObjectIds[ref]) .. " with ref obj:" ..
        tostring(_G.inspect(refObj)))
end

function State:serializeChunkObjects()
    local chunkData = {}
    for cx = 0, _G.chunksWide - 1 do
        chunkData[cx] = {}
        for cy = 0, _G.chunksHigh - 1 do
            chunkData[cx][cy] = {}
            local data = chunkData[cx][cy]
            if self.chunkObjects[cx][cy] then
                for _, obj in pairs(_G.state.chunkObjects[cx][cy]) do
                    if self.serializedObjectIds[obj.id] then
                        data[#data + 1] = self.serializedObjectIds[obj.id]
                    else
                        data[#data + 1] = obj:serialize()
                        self.serializedObjectIds[obj.id] = data[#data]
                    end
                end
            end
        end
    end
    return chunkData
end

function State:deserializeChunkObjects(loadData)
    for cx = 0, _G.chunksWide - 1 do
        for cy = 0, _G.chunksHigh - 1 do
            local data = loadData[cx] and loadData[cx][cy]
            if data then
                for _, obj in pairs(data) do
                    if obj and obj.className then
                        local new = self:dereferenceObject(obj)
                        self.chunkObjects[new.cx][new.cy][new] = new
                    end
                end
            end
        end
    end
    return self.chunkObjects
end

function State:deserializeObjects(data)
    for cx = 0, _G.chunksWide - 1 do
        for cy = 0, _G.chunksHigh - 1 do
            for i = 0, _G.chunkWidth - 1 do
                for o = 0, _G.chunkWidth - 1 do
                    if data[cx][cy][i][o] then
                        for _, obj in pairs(data[cx][cy][i][o]) do
                            if obj and next(obj) then
                                self:dereferenceObject(obj)
                            end
                        end
                    end
                end
            end
        end
    end
    return self.object
end

function State:serializeObjects()
    local data = {}
    for cx = 0, _G.chunksWide - 1 do
        data[cx] = {}
        for cy = 0, _G.chunksHigh - 1 do
            data[cx][cy] = {}
            for i = 0, _G.chunkWidth - 1 do
                data[cx][cy][i] = {}
                for o = 0, _G.chunkWidth - 1 do
                    data[cx][cy][i][o] = {}
                    if self.object[cx][cy][i][o] then
                        for _, obj in pairs(self.object[cx][cy][i][o]) do
                            if self.serializedObjectIds[obj.id] then
                                data[cx][cy][i][o][#data[cx][cy][i][o] + 1] = self.serializedObjectIds[obj.id]
                            else
                                local serial = obj:serialize()
                                data[cx][cy][i][o][#data[cx][cy][i][o] + 1] = serial
                                self.serializedObjectIds[obj.id] = serial
                            end
                        end
                    end
                end
            end
        end
    end
    return data
end

function State:serialize()
    local metadata = {
        name = self.savename,
        version = _G.version,
        dateCreated = self.dateCreated or os.date("%Y-%m-%d %X"),
        dateModified = os.date("%Y-%m-%d %X"),
        mapName = self.map.name,
        compressed = true,
        isMap = false
    }
    local data = {}
    self.serializedObjectIds = {}
    data.wheatSeasonCounter = self.wheatSeasonCounter
    data.wheatGrowingSeason = self.wheatGrowingSeason
    data.hopsSeasonCounter = self.hopsSeasonCounter
    data.hopsGrowingSeason = self.hopsGrowingSeason
    data.topLeftChunkX = self.topLeftChunkX
    data.topLeftChunkY = self.topLeftChunkY
    data.bottomRightChunkX = self.bottomRightChunkX
    data.bottomRightChunkY = self.bottomRightChunkY
    data.offsetX, data.offsetY = _G.offsetX, _G.offsetY
    -- if not _G.MAP_EDITOR then
    data.resources = self.resources
    data.food = self.food
    data.weapons = self.weapons
    data.notFullStockpiles = self.notFullStockpiles
    data.notFullFoods = self.notFullFoods
    data.notFullArmoury = self.notFullArmoury
    data.buildController = _G.BuildController:serialize()
    data.stockpileController = _G.stockpile:serialize()
    if not _G.BuildController.start then
        data.spawnPointX, data.spawnPointY = _G.spawnPointX, _G.spawnPointY
        data.campfire = _G.campfire:serialize()
    end
    data.foodController = _G.foodpile:serialize()
    data.weaponController = _G.weaponpile:serialize()
    data.jobController = _G.JobController:serialize()
    data.taxController = _G.TaxController:serialize()
    data.timeController = _G.TimeController:serialize()
    data.buildingManager = _G.BuildingManager:serialize()
    local RationController = require("objects.Controllers.RationController")
    data.rationController = RationController:serialize()
    data.popularityController = _G.PopularityController:serialize()
    -- end
    data.verticesPerTile = self.verticesPerTile
    data.chunkObjects = self:serializeChunkObjects()
    data.object = self:serializeObjects()
    data.scaleX = self.scaleX
    data.viewXview = self.viewXview
    data.viewYview = self.viewYview
    data.serializedObjectIds = self.serializedObjectIds
    data.population = self.population
    data.maxPopulation = self.maxPopulation
    data.popularity = self.popularity
    data.gold = self.gold
    data.map = self.map:serialize()
    data.savename = self.savename
    return data, metadata
end

function State:load(filename, decompress)
    local load = bitser.loadLoveFile(string.lower(filename), decompress)
    if not load then
        error("empty save file data")
    end
    self.savename = load.savename
    if self.savename == "map_Fernhaven" then
        self.savename = SaveManager:getNextFreeName()
    end
    self.map:deserialize(load.map)
    self.deserializedObjectCount = 0
    self.deserDebug = {}
    self.deserializedObjectIds = {}
    self.rawObjectIds = load.serializedObjectIds
    self.wheatSeasonCounter = load.wheatSeasonCounter
    self.wheatGrowingSeason = load.wheatGrowingSeason
    self.hopsSeasonCounter = load.hopsSeasonCounter or 0
    self.hopsGrowingSeason = load.hopsGrowingSeason
    self.topLeftChunkX = load.topLeftChunkX
    self.topLeftChunkY = load.topLeftChunkY
    self.bottomRightChunkX = load.bottomRightChunkX
    self.bottomRightChunkY = load.bottomRightChunkY
    self.verticesPerTile = load.verticesPerTile
    self.maxPopulation = load.maxPopulation
    self.population = load.population
    if not self.newGame then
        self.resources = load.resources
        self.food = load.food
        self.weapons = load.weapons
        self.notFullStockpiles = load.notFullStockpiles
        self.notFullFoods = load.notFullFoods
        self.notFullArmoury = load.notFullArmoury
        self.popularity = load.popularity
        self.gold = load.gold
        _G.JobController:deserialize(load.jobController)
        _G.TaxController:deserialize(load.taxController)
        local RationController = require("objects.Controllers.RationController")
        RationController:deserialize(load.rationController)
        _G.PopularityController:deserialize(load.popularityController)
        _G.BuildController:deserialize(load.buildController)
        _G.BuildingManager:deserialize(load.buildingManager)
        _G.foodpile:deserialize(load.foodController)
        _G.TimeController:deserialize(load.timeController)
        if load.weaponController then
            _G.weaponpile:deserialize(load.weaponController)
        end
        _G.spawnPointX, _G.spawnPointY = load.spawnPointX, load.spawnPointY
        local campfireClass = _G.getClassByName(load.campfire.className)
        if campfireClass then
            campfireClass:deserialize(load.campfire)
        else
            print("Campfire is not deserialized")
            love.quit()
        end
        _G.stockpile:deserialize(load.stockpileController)
        warningTooltip:HideTooltip()
    end
    _G.offsetX, _G.offsetY = load.offsetX, load.offsetY
    self:deserializeChunkObjects(load.chunkObjects)
    self.object = self:deserializeObjects(load.object)
    self.scaleX = load.scaleX
    self.viewXview = load.viewXview
    self.viewYview = load.viewYview
    self.map:forceRefresh()
    collectgarbage()
end

return State
