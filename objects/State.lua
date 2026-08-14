local bitser = require("libraries.bitser")
local Map = require("objects.Map")
local SaveManager = require("objects.Controllers.SaveManager")
local FOOD = require("objects.Enums.Food")
local WEAPON = require("objects.Enums.Weapon")
local warningTooltip = require("states.ui.warning_tooltip")
local TileKeeper = require("objects.Controllers.TileKeeper")
local CompactArray = require("libraries.compact_array")

---@class State
---@field new fun():State
---@field map Map
---@overload fun():State
local State = _G.class("State")
function State:initialize()
    if _G.state and _G.state ~= self then
        _G.state:cleanupPathfindingThreads()
    end
    self:cleanupPathfindingThreads()
    self.tier = 1
    self.map = Map:new()
    self.thread = love.thread.newThread("libraries/pathfinding_thread.lua")
    self.thread:start("1", self.map:getMapWidthInTiles())
    self.thread2 = love.thread.newThread("libraries/pathfinding_thread.lua")
    self.thread2:start("2", self.map:getMapHeightInTiles())
    self.initialized = false
    self.savename = SaveManager:getNextFreeName()
    self.newGame = true
    self.objectBatch = newAutotable(2)
    self.serializedObjectIds = {}
    self.projectiles = {}
    self.deserializedObjectIds = {}
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
    self.activeEntities = {}
    self.lazyReferences = {}
    self.postitiveBuildings = 0
    self.gameTime = 0 --Represents how long a game running in game time (not real time)
    self.missionNr = nil
    -- TODO: Make the collision map dynamic
    self.resources = {
        ["wood"] = 0,
        ['hop'] = 0,
        ["stone"] = 0,
        ["iron"] = 0,
        ["tar"] = 0,
        ["flour"] = 0,
        ["ale"] = 0,
        ["wheat"] = 0
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
    self.keepX = 0
    self.keepY = 0

    self.vertexKeeper = {}
    self.tileKeeper = {}
    self.cliffKeeper = {}
    for i = 0, _G.chunksWide - 1 do
        self.vertexKeeper[i] = {}
        self.tileKeeper[i] = {}
        self.cliffKeeper[i] = {}
        for o = 0, _G.chunksHigh - 1 do
            self.vertexKeeper[i][o] = CompactArray:new(i, o)
            self.tileKeeper[i][o] = TileKeeper:new(i, o, self.vertexKeeper[i][o])
            self.cliffKeeper[i][o] = TileKeeper:new(i, o, self.vertexKeeper[i][o])
        end
    end

    self:allocateMeshes()
    local Terrain = require("terrain.terrain")
    self.Terrain = Terrain:new(self)
    function _G.getTerrainTileOnMouse(mx, my, ignoreElevation, ignoreStructureOffset)
        return self.Terrain:getTerrainTileOnMouse(mx, my, ignoreElevation, ignoreStructureOffset)
    end

    function _G.terrainSetTileAt(gx, gy, biome, from, force)
        return self.Terrain:terrainSetTileAt(gx, gy, biome, from, force)
    end

    self:updateKeepUpgradeButton()
end

function State:cleanupPathfindingThreads()
    if self.thread then
        _G.channel.mapUpdate:clear()
        _G.channel2.mapUpdate:clear()
        _G.channel.mapUpdate:push("final")
        _G.channel2.mapUpdate:push("final")
        _G.channel.request:clear()
        _G.channel.receive:clear()
        -- send two messages to make sure both threads get a stop message
        _G.channel.request:push({ stop = true })
        _G.channel.request:push({ stop = true })
        if self.thread:isRunning() then self.thread:wait() end
        _G.channel.request:push({ stop = true })
        if self.thread2:isRunning() then self.thread2:wait() end
        _G.channel.request:clear()
        _G.channel.receive:clear()
    end
end

---@private
function State:updateKeepUpgradeButton()
    _G.updateKeepUpgradeButton(self.tier)
end

function State:destroy()
    self:cleanupPathfindingThreads()
    _G.BrushController:initialize()
    _G.BuildController:initialize()
    _G.BuildingManager:initialize()
    _G.Commander:initialize()
    _G.DestructionController:initialize()
    _G.DebugView:initialize()
    local RationController = require("objects.Controllers.RationController")
    RationController:initialize()
    _G.AleController:initialize()
    _G.HerdController:initialize()
    _G.ReligionController:initialize()
    _G.TaxController:initialize()
    _G.TimeController:initialize()
    _G.MissionController:initialize()
    _G.PopularityController:initialize()
    _G.ScribeController:initialize()
    _G.JobController:initialize()
    _G.stockpile:initialize()  --stockpileController
    _G.foodpile:initialize()   -- foodController
    _G.weaponpile:initialize() --WeaponController

    self.vertexKeeper = {}
    self.tileKeeper = {}
    self.cliffKeeper = {}
    for i = 0, _G.chunksWide - 1 do
        self.vertexKeeper[i] = {}
        self.tileKeeper[i] = {}
        self.cliffKeeper[i] = {}
        for o = 0, _G.chunksHigh - 1 do
            self.vertexKeeper[i][o] = CompactArray:new(i, o)
            self.tileKeeper[i][o] = TileKeeper:new(i, o, self.vertexKeeper[i][o])
            self.cliffKeeper[i][o] = TileKeeper:new(i, o, self.vertexKeeper[i][o])
        end
    end
    collectgarbage()
end

function State:allocateMeshes()
    for cx = 0, _G.chunksWide - 1 do
        for cy = 0, _G.chunksHigh - 1 do
            self:allocateMesh(cx, cy)
        end
    end
end

---@private
function State:allocateMesh(cx, cy)
    local chunkX = cx
    local chunkY = cy
    local treeverts = {
        { 0, 0, 0, 0, 1.0, 1.0, 1.0, 1.0, 1.0 },
        { 1, 0, 1, 0, 1.0, 1.0, 1.0, 1.0, 1.0 },
        { 0, 1, 0, 1, 1.0, 1.0, 1.0, 1.0, 1.0 },
        { 1, 1, 1, 1, 1.0, 1.0, 1.0, 1.0, 1.0 }
    }
    if self.objectBatch[chunkX][chunkY] == nil then
        self.objectBatch[chunkX][chunkY] = love.graphics.newMesh(treeverts, "strip", "static")
    end
    local instancemesh = love.graphics.newMesh({ { "InstancePosition", "float", 3 }, { "UVOffset", "float", 2 },
            { "ImageDim",         "float", 2 }, { "ImageShade", "float", 1 },
            { "Scale", "float", 2 }, { "Pallete", "float", 1 } },
        _G.chunkWidth * _G.chunkHeight * self.verticesPerTile + 1000, nil, "dynamic")
    self.objectMesh[chunkX][chunkY] = instancemesh
    self.objectBatch[chunkX][chunkY]:setTexture(objectAtlas)
    self.objectBatch[chunkX][chunkY]:attachAttribute("InstancePosition", instancemesh, "perinstance")
    self.objectBatch[chunkX][chunkY]:attachAttribute("UVOffset", instancemesh, "perinstance")
    self.objectBatch[chunkX][chunkY]:attachAttribute("ImageDim", instancemesh, "perinstance")
    self.objectBatch[chunkX][chunkY]:attachAttribute("ImageShade", instancemesh, "perinstance")
    self.objectBatch[chunkX][chunkY]:attachAttribute("Scale", instancemesh, "perinstance")
    self.objectBatch[chunkX][chunkY]:attachAttribute("Pallete", instancemesh, "perinstance")
end

function State:save()
    return self:serialize()
end

function State:serializeObject(obj)
    if obj and obj._ref then
        -- already serialized
        return obj
    end
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

---Is used to dereference where there's a chance of circular dependency
function State:lazyDereferenceObject(refObj, target, targetKey, callback)
    self.lazyReferences[#self.lazyReferences + 1] = { refObj, target, targetKey, callback }
end

---@private
function State:processLazyReferences()
    for _, v in ipairs(self.lazyReferences) do
        local refObj, target, targetKey, callback = v[1], v[2], v[3], v[4]
        target[targetKey] = self:dereferenceObject(refObj)
        if callback then callback(target) end
    end
    self.lazyReferences = {}
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

function State:serializeActiveEntities()
    local data = {}
    for _, obj in ipairs(self.activeEntities) do
        data[#data + 1] = self:serializeObject(obj)
    end
    return data
end

function State:deserializeActiveEntities(data)
    for _, obj in ipairs(data) do
        _G.state.activeEntities[#_G.state.activeEntities + 1] = self:dereferenceObject(obj)
    end
    return _G.state.activeEntities
end

function State:deserializeObjects(data)
    for cx = 0, _G.chunksWide - 1 do
        for cy = 0, _G.chunksHigh - 1 do
            for i = 0, _G.chunkWidth - 1 do
                for o = 0, _G.chunkWidth - 1 do
                    if data[cx][cy][i][o] then
                        for _, obj in pairs(data[cx][cy][i][o]) do
                            if obj and next(obj) then
                                _G.addObjectAt(cx, cy, i, o, self:dereferenceObject(obj))
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

function State:shadeBuildings()
    local BuildingManager = require("objects.Controllers.BuildingManager")
    for _, v in pairs(BuildingManager.buildings) do
        for _, sv in pairs(v) do
            sv:shadeWithAliases()
        end
    end
end

function State:serialize()
    local metadata = {
        name = self.savename,
        version = _G.version,
        dateCreated = self.dateCreated or os.date("%Y-%m-%d %X"),
        dateModified = os.date("%Y-%m-%d %X"),
        mapName = self.map.name,
        compressed = true,
        isMap = false,
        w = _G.chunksWide,
        h = _G.chunksHigh
    }
    local data = {}
    self.serializedObjectIds = {}
    data.tier = self.tier
    data.activeEntities = self:serializeActiveEntities()
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
    data.religionController = _G.ReligionController:serialize()
    data.herdController = _G.HerdController:serialize()
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
    data.postitiveBuildings = self.postitiveBuildings
    data.gameTime = self.gameTime
    -- Castle Kingdoms 2027: Save Royal Systems state
    local RoyalRegistry = require("objects.Economy.RoyalSystemsRegistry")
    data.royalSystems = RoyalRegistry.serialize()
    -- Castle Kingdoms 2027 v3.11.912: Save Market Dashboard comparison list
    local MarketDashboard = require("states.ui.hud.market_dashboard")
    data.marketDashboard = MarketDashboard.serialize()
    -- Castle Kingdoms 2027 v3.11.913: Save Royal Market auto-sell state
    local RMI = require("objects.Economy.RoyalMarketIntegration")
    data.royalMarket = RMI.serialize()
    -- Castle Kingdoms 2027 v3.11.914: Save DynamicMarket state (prices, inflation, events)
    local DynamicMarket = require("objects.Economy.DynamicMarketSystem")
    data.dynamicMarket = DynamicMarket.serialize()
    -- Castle Kingdoms 2027 v3.11.915: Stamp save version for future migrations
    local SaveVersioner = require("objects.Economy.SaveVersioner")
    SaveVersioner.stamp(data)
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
    self:deserialize(load)
end

function State:deserialize(load)
    -- Castle Kingdoms 2027 v3.11.915: Migrate save data to current version
    -- (stamps version if missing, runs migration chain if needed)
    local SaveVersioner = require("objects.Economy.SaveVersioner")
    SaveVersioner.migrate(load)

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
    self.tier = load.tier or 1
    self.gameTime = load.gameTime or 0
    if load.activeEntities then
        self:deserializeActiveEntities(load.activeEntities)
    end
    if not self.newGame then
        self.resources = load.resources
        self.food = load.food
        self.weapons = load.weapons
        self.notFullStockpiles = load.notFullStockpiles
        self.notFullFoods = load.notFullFoods
        self.notFullArmoury = load.notFullArmoury
        self.popularity = load.popularity
        self.gold = load.gold
        self.postitiveBuildings = load.postitiveBuildings
        _G.spawnPointX, _G.spawnPointY = load.spawnPointX, load.spawnPointY
        local campfireClass = _G.getClassByName(load.campfire.className)
        if campfireClass then
            campfireClass:deserialize(load.campfire)
        else
            print("Campfire is not deserialized")
            love.quit()
        end
        _G.JobController:deserialize(load.jobController)
        _G.TaxController:deserialize(load.taxController)
        local RationController = require("objects.Controllers.RationController")
        RationController:deserialize(load.rationController)
        _G.PopularityController:deserialize(load.popularityController)
        _G.BuildController:deserialize(load.buildController)
        _G.BuildingManager:deserialize(load.buildingManager)
        _G.foodpile:deserialize(load.foodController)
        _G.TimeController:deserialize(load.timeController)
        _G.ReligionController:deserialize(load.religionController)
        _G.HerdController:deserialize(load.herdController)
        if load.weaponController then
            _G.weaponpile:deserialize(load.weaponController)
        end
        _G.stockpile:deserialize(load.stockpileController)
        warningTooltip:HideTooltip()
    end
    _G.offsetX, _G.offsetY = load.offsetX or 0, load.offsetY or 0
    self:deserializeChunkObjects(load.chunkObjects)
    self.object = self:deserializeObjects(load.object)
    _G.state:processLazyReferences()
    -- Castle Kingdoms 2027: Load Royal Systems state
    if load.royalSystems then
        local RoyalRegistry = require("objects.Economy.RoyalSystemsRegistry")
        RoyalRegistry.deserialize(load.royalSystems)
    end
    -- Castle Kingdoms 2027 v3.11.912: Load Market Dashboard comparison list
    if load.marketDashboard then
        local MarketDashboard = require("states.ui.hud.market_dashboard")
        MarketDashboard.deserialize(load.marketDashboard)
    end
    -- Castle Kingdoms 2027 v3.11.913: Load Royal Market auto-sell state
    if load.royalMarket then
        local RMI = require("objects.Economy.RoyalMarketIntegration")
        RMI.deserialize(load.royalMarket)
    end
    -- Castle Kingdoms 2027 v3.11.914: Load DynamicMarket state (prices, inflation, events)
    if load.dynamicMarket then
        local DynamicMarket = require("objects.Economy.DynamicMarketSystem")
        DynamicMarket.deserialize(load.dynamicMarket)
    end
    self.scaleX = load.scaleX
    self.viewXview = load.viewXview
    self.viewYview = load.viewYview
    self.map:forceRefresh()
    collectgarbage()
    _G.channel.mapUpdate:push("final")
    _G.channel2.mapUpdate:push("final")
    self:updateKeepUpgradeButton()
end

local console = require("libraries.console")
console.addCommand("addGold", function()
    _G.state.gold = _G.state.gold + 10000
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:updateGoldCount()
end, "Add 10000 gold.")

return State
