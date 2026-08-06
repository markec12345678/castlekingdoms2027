-- objects/Controllers/BuildingManagerSystem.lua
-- Stronghold 2027 v2.7.3 - Building Manager System
--
-- Centralized building management with categorization, statistics, and optimization.
-- Tracks all player buildings, provides filtering, and calculates bonuses.
--
-- Building categories:
-- - Economy: resource production (farms, mines, workshops)
-- - Military: unit production (barracks, guilds)
-- - Defense: walls, towers, gates
-- - Housing: population capacity
-- - Religious: chapels, churches, cathedrals
-- - Storage: stockpiles, granaries, armouries

local BuildingManager = {}

local initialized = false
local buildingCache = {}  -- cached building list, refreshed periodically
local cacheTimer = 0
local cacheInterval = 2.0  -- refresh cache every 2 seconds

-- Building categories
local CATEGORIES = {
    economy = {
        name = "Ekonomija",
        buildings = {
            "Woodcutter", "Quarry", "IronMine", "PitchRig",
            "WheatFarm", "Orchard", "DairyFarm", "HopsFarm", "HunterHut",
            "Windmill", "Bakery", "Brewery", "Inn", "Market",
            "Fletcher", "Poleturner", "Blacksmith", "Armorer",
        },
    },
    military = {
        name = "Vojska",
        buildings = {
            "Barracks", "StoneBarracks", "EngineersGuild", "TunnelersGuild",
            "TournamentArena", "Armoury",
        },
    },
    defense = {
        name = "Obramba",
        buildings = {
            "WoodenWall", "WoodenTower", "SquareTower", "RoundTower",
            "StoneGateSouth", "StoneGateEast", "WatchTower",
        },
    },
    housing = {
        name = "Stanovanja",
        buildings = {"Hovel", "Flat", "Residence", "BigResidence"},
    },
    religious = {
        name = "Religija",
        buildings = {"Chapel", "Church", "Cathedral", "Shrine"},
    },
    storage = {
        name = "Skladišča",
        buildings = {"Stockpile", "Granary"},
    },
    keep = {
        name = "Grad",
        buildings = {"WoodenKeep", "Keep", "Fortress", "Stronghold", "SaxonHall"},
    },
}

BuildingManager.CATEGORIES = CATEGORIES

function BuildingManager.init()
    if initialized then return end
    initialized = true
    BuildingManager._refreshCache()
    print("[BuildingManager] Initialized with " .. #buildingCache .. " buildings")
end

-- Refresh the building cache
function BuildingManager._refreshCache()
    buildingCache = {}
    if not _G.state or not _G.state.gameObjectList then return end

    for _, obj in ipairs(_G.state.gameObjectList) do
        if (not obj.faction or obj.faction == 1) and obj.class and obj.class.name then
            local name = obj.class.name
            local category = BuildingManager._getCategoryForBuilding(name)
            table.insert(buildingCache, {
                object = obj,
                name = name,
                category = category,
                gx = obj.gx,
                gy = obj.gy,
                health = obj.health or 100,
                maxHealth = obj.maxHealth or 100,
                faction = obj.faction or 1,
            })
        end
    end
end

-- Get category for a building type
function BuildingManager._getCategoryForBuilding(buildingName)
    for catId, cat in pairs(CATEGORIES) do
        for _, bname in ipairs(cat.buildings) do
            if bname == buildingName then return catId end
        end
    end
    return "other"
end

-- Update (refresh cache periodically)
function BuildingManager.update(dt)
    if not initialized then return end
    cacheTimer = cacheTimer + dt
    if cacheTimer >= cacheInterval then
        cacheTimer = 0
        BuildingManager._refreshCache()
    end
end

-- Get all buildings
function BuildingManager.getAll()
    return buildingCache
end

-- Get buildings by category
function BuildingManager.getByCategory(category)
    local result = {}
    for _, b in ipairs(buildingCache) do
        if b.category == category then
            table.insert(result, b)
        end
    end
    return result
end

-- Get buildings by name
function BuildingManager.getByName(name)
    local result = {}
    for _, b in ipairs(buildingCache) do
        if b.name == name then
            table.insert(result, b)
        end
    end
    return result
end

-- Count buildings by category
function BuildingManager.countByCategory(category)
    local count = 0
    for _, b in ipairs(buildingCache) do
        if b.category == category then
            count = count + 1
        end
    end
    return count
end

-- Count buildings by name
function BuildingManager.countByName(name)
    local count = 0
    for _, b in ipairs(buildingCache) do
        if b.name == name then
            count = count + 1
        end
    end
    return count
end

-- Get damaged buildings (health < maxHealth)
function BuildingManager.getDamaged()
    local result = {}
    for _, b in ipairs(buildingCache) do
        if b.health < b.maxHealth then
            table.insert(result, b)
        end
    end
    return result
end

-- Get buildings in range of a point
function BuildingManager.getInRange(gx, gy, range)
    local result = {}
    local rangeSq = range * range
    for _, b in ipairs(buildingCache) do
        if b.gx and b.gy then
            local dx = b.gx - gx
            local dy = b.gy - gy
            if dx * dx + dy * dy <= rangeSq then
                table.insert(result, b)
            end
        end
    end
    return result
end

-- Get total building count
function BuildingManager.getTotalCount()
    return #buildingCache
end

-- Get stats summary
function BuildingManager.getStats()
    local stats = {
        total = #buildingCache,
        byCategory = {},
        damaged = 0,
        healthy = 0,
    }
    for _, b in ipairs(buildingCache) do
        stats.byCategory[b.category] = (stats.byCategory[b.category] or 0) + 1
        if b.health < b.maxHealth then
            stats.damaged = stats.damaged + 1
        else
            stats.healthy = stats.healthy + 1
        end
    end
    return stats
end

-- Get housing capacity
function BuildingManager.getHousingCapacity()
    local capacity = 0
    local housingCaps = {Hovel = 4, Flat = 8, Residence = 12, BigResidence = 16}
    for _, b in ipairs(buildingCache) do
        if housingCaps[b.name] then
            capacity = capacity + housingCaps[b.name]
        end
    end
    return capacity
end

-- Get production buildings count
function BuildingManager.getProductionCount()
    return BuildingManager.countByCategory("economy")
end

-- Get defense buildings count
function BuildingManager.getDefenseCount()
    return BuildingManager.countByCategory("defense")
end

-- Get military buildings count
function BuildingManager.getMilitaryCount()
    return BuildingManager.countByCategory("military")
end

-- Repair all damaged buildings (costs gold)
function BuildingManager.repairAll()
    local damaged = BuildingManager.getDamaged()
    if #damaged == 0 then
        if _G.ModernUI then
            _G.ModernUI.notifyInfo("Ni poškodovanih zgradb")
        end
        return false
    end
    -- Calculate repair cost (1 gold per HP missing)
    local totalCost = 0
    for _, b in ipairs(damaged) do
        totalCost = totalCost + (b.maxHealth - b.health)
    end
    if not _G.state or (_G.state.gold or 0) < totalCost then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Popravilo potrebuje " .. totalCost .. " zlata")
        end
        return false
    end
    -- Deduct gold and repair
    _G.state.gold = (_G.state.gold or 0) - totalCost
    for _, b in ipairs(damaged) do
        if b.object and b.object.health then
            b.object.health = b.maxHealth
        end
    end
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Popravljeno " .. #damaged .. " zgradb za " .. totalCost .. " zlata")
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("buildings_repaired", { count = #damaged, cost = totalCost }) end)
    end
    return true
end

return BuildingManager
