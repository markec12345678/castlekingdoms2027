-- objects/QA/RoyalCartographerMapsSystem.lua
-- Castle Kingdoms 2027 v3.3.5 - Royal Cartographer & Maps System
--
-- Manages map creation, exploration tracking, and geographic knowledge.
-- Maps provide strategic advantages and reveal hidden resources.
--
-- Features:
-- - 6 map types (world, regional, military, trade, treasure, sea charts)
-- - 4 cartographer buildings (scriptorium, map room, observatory, archive)
-- - Cartographer NPC (skill affects map quality)
-- - Exploration tracking (discover new territories)
-- - Map trading (sell/buy maps from other lords)
-- - Treasure maps (random discoveries)
-- - Strategic advantages (better maps = better decisions)
-- - Map accuracy (improves with skill and buildings)

local Cartographer = {}

-- ============================================================
-- MAP TYPES
-- ============================================================
local MAP_TYPES = {
    world_map = {
        name = "Zemljevid sveta",
        nameEn = "World Map",
        baseValue = 1000,
        creationTime = 30,
        accuracyBonus = 0,
        description = "Splošen zemljevid znanih dežel.",
    },
    regional_map = {
        name = "Regionalni zemljevid",
        nameEn = "Regional Map",
        baseValue = 300,
        creationTime = 14,
        accuracyBonus = 5,
        description = "Podroben zemljevid regije.",
    },
    military_map = {
        name = "Vojaški zemljevid",
        nameEn = "Military Map",
        baseValue = 500,
        creationTime = 20,
        accuracyBonus = 10,
        strategicBonus = 15,
        description = "Zemljevid s taktičnimi informacijami.",
    },
    trade_map = {
        name = "Trgovski zemljevid",
        nameEn = "Trade Map",
        baseValue = 400,
        creationTime = 18,
        accuracyBonus = 5,
        tradeBonus = 0.10,
        description = "Zemljevid trgovskih poti in trgov.",
    },
    treasure_map = {
        name = "Zemljevid zaklada",
        nameEn = "Treasure Map",
        baseValue = 2000,
        creationTime = 7,
        accuracyBonus = 0,
        description = "Zemljevid do skritega zaklada.",
    },
    sea_chart = {
        name = "Pomorska karta",
        nameEn = "Sea Chart",
        baseValue = 800,
        creationTime = 25,
        accuracyBonus = 8,
        navalBonus = 0.15,
        description = "Karta za pomorsko navigacijo.",
    },
}

-- ============================================================
-- CARTOGRAPHER BUILDINGS
-- ============================================================
local BUILDINGS = {
    scriptorium = {
        name = "Skriptorij",
        cost = { gold = 400, wood = 100, stone = 50 },
        upkeep = 10,
        mapCapacity = 5,
        accuracyBonus = 5,
        description = "Prostor za risanje zemljevidov.",
    },
    map_room = {
        name = "Kartografska soba",
        cost = { gold = 1500, wood = 200, stone = 300 },
        upkeep = 30,
        mapCapacity = 20,
        accuracyBonus = 15,
        strategicBonus = 5,
        description = "Dvorana z zemljevidi za strategijo.",
    },
    cartographer_archive = {
        name = "Kartografski arhiv",
        cost = { gold = 4000, wood = 400, stone = 800 },
        upkeep = 80,
        mapCapacity = 100,
        accuracyBonus = 30,
        strategicBonus = 15,
        description = "Veliki arhiv vseh zemljevidov.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Cartographer.maps = {}                   -- Owned maps
Cartographer.buildings = {}              -- Built buildings
Cartographer.cartographer = nil          -- Hired cartographer NPC
Cartographer.exploredRegions = {}        -- Discovered regions
Cartographer.activeMapCreations = {}     -- Maps being created
Cartographer.totalMapsCreated = 0
Cartographer.totalTreasuresFound = 0
Cartographer.totalRegionsExplored = 0
Cartographer.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Cartographer.init()
    Cartographer.maps = {}
    Cartographer.buildings = {}
    Cartographer.cartographer = nil
    Cartographer.exploredRegions = {}
    Cartographer.activeMapCreations = {}
    Cartographer.totalMapsCreated = 0
    Cartographer.totalTreasuresFound = 0
    Cartographer.totalRegionsExplored = 0
    Cartographer.dayTimer = 0
    print("[Cartographer] Royal Cartographer & Maps System initialized (6 map types, 3 buildings)")
end

-- ============================================================
-- CARTOGRAPHER NPC
-- ============================================================
function Cartographer.hireCartographer(name, skill)
    skill = skill or math.random(40, 90)
    local cost = 400 + skill * 8
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Cartographer.cartographer = {
        name = name or ("Kartograf " .. math.random(1, 99)),
        skill = skill,
        accuracy = 0.50 + (skill / 200),
        hiredDay = os.time(),
        mapsCreated = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Kartograf najet: %s (spretnost: %d)", Cartographer.cartographer.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Cartographer.canBuild(buildingId)
    local def = BUILDINGS[buildingId]
    if not def then return false, "Neznana zgradba" end
    if not _G.state then return false, "Brez stanja" end
    if _G.state.gold < (def.cost.gold or 0) then return false, "Premalo zlata" end
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" and (_G.state.resources[res] or 0) < amt then
                return false, "Premalo " .. res
            end
        end
    end
    return true
end

function Cartographer.build(buildingId)
    local ok, err = Cartographer.canBuild(buildingId)
    if not ok then return false, err end
    local def = BUILDINGS[buildingId]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Cartographer.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Cartographer.getAccuracyBonus()
    local bonus = 0
    for _, b in ipairs(Cartographer.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.accuracyBonus then bonus = bonus + def.accuracyBonus end
    end
    return bonus
end

function Cartographer.getStrategicBonus()
    local bonus = 0
    for _, b in ipairs(Cartographer.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.strategicBonus then bonus = bonus + def.strategicBonus end
    end
    return bonus
end

function Cartographer.getMapCapacity()
    local cap = 3
    for _, b in ipairs(Cartographer.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.mapCapacity then cap = cap + def.mapCapacity end
    end
    return cap
end

-- ============================================================
-- MAP CREATION
-- ============================================================
function Cartographer.canCreateMap(mapType, region)
    local def = MAP_TYPES[mapType]
    if not def then return false, "Neznan zemljevid" end
    if #Cartographer.maps >= Cartographer.getMapCapacity() then
        return false, "Arhiv je poln"
    end
    if not Cartographer.cartographer then
        return false, "Potreben kartograf"
    end
    -- Need a scriptorium at minimum
    local hasBuilding = false
    for _, b in ipairs(Cartographer.buildings) do
        hasBuilding = true; break
    end
    if not hasBuilding then
        return false, "Potrebna zgradba za kartografijo"
    end
    if not _G.state or (_G.state.gold or 0) < def.baseValue / 2 then
        return false, "Premalo zlata za materiale"
    end
    return true
end

function Cartographer.createMap(mapType, region)
    local ok, err = Cartographer.canCreateMap(mapType, region)
    if not ok then return false, err end
    local def = MAP_TYPES[mapType]
    _G.state.gold = _G.state.gold - math.floor(def.baseValue / 2)
    local creation = {
        id = "creation_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        mapType = mapType,
        mapName = def.name,
        region = region or "splošno",
        daysRemaining = def.creationTime,
        totalDays = def.creationTime,
        started = os.time(),
    }
    table.insert(Cartographer.activeMapCreations, creation)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Kartografiranje začeto: %s (%d dni)", def.name, def.creationTime), "info")
    end
    return true
end

function Cartographer.completeMapCreation(creation)
    local def = MAP_TYPES[creation.mapType]
    if not def then return end
    -- Calculate accuracy
    local accuracy = 0.50
    if Cartographer.cartographer then
        accuracy = Cartographer.cartographer.accuracy
    end
    accuracy = accuracy + (Cartographer.getAccuracyBonus() / 100)
    accuracy = math.min(0.99, accuracy)
    local map = {
        id = "map_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = creation.mapType,
        name = def.name,
        region = creation.region,
        accuracy = accuracy,
        value = def.baseValue,
        strategicBonus = def.strategicBonus or 0,
        tradeBonus = def.tradeBonus or 0,
        navalBonus = def.navalBonus or 0,
        createdDay = os.time(),
    }
    table.insert(Cartographer.maps, map)
    Cartographer.totalMapsCreated = Cartographer.totalMapsCreated + 1
    if Cartographer.cartographer then
        Cartographer.cartographer.mapsCreated = Cartographer.cartographer.mapsCreated + 1
        if math.random() < 0.20 then
            Cartographer.cartographer.skill = math.min(100, Cartographer.cartographer.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Zemljevid dokončan: %s (natančnost: %.0f%%)",
                def.name, accuracy * 100), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "MAP_CREATED", { type = creation.mapType, accuracy = accuracy })
    end
end

-- ============================================================
-- EXPLORATION
-- ============================================================
function Cartographer.exploreRegion(regionName)
    if Cartographer.exploredRegions[regionName] then
        return false, "Regija že raziskana"
    end
    Cartographer.exploredRegions[regionName] = {
        name = regionName,
        exploredDay = os.time(),
        resources = math.random(50, 500),
        danger = math.random(1, 10),
    }
    Cartographer.totalRegionsExplored = Cartographer.totalRegionsExplored + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Regija raziskana: %s!", regionName), "success")
    end
    -- Chance to find treasure
    if math.random() < 0.15 then
        Cartographer.findTreasure(regionName)
    end
    return true
end

function Cartographer.findTreasure(regionName)
    local treasureValue = math.random(500, 5000)
    Cartographer.totalTreasuresFound = Cartographer.totalTreasuresFound + 1
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + treasureValue
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("ZAKLAD NAJDEN v %s! +%d zlata", regionName, treasureValue), "rare")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "TREASURE_FOUND", {
            region = regionName, value = treasureValue,
        })
    end
end

-- ============================================================
-- MAP TRADING
-- ============================================================
function Cartographer.sellMap(mapId)
    for i, m in ipairs(Cartographer.maps) do
        if m.id == mapId then
            local sellPrice = math.floor(m.value * m.accuracy)
            if _G.state then
                _G.state.gold = (_G.state.gold or 0) + sellPrice
            end
            table.remove(Cartographer.maps, i)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("Zemljevid prodan: +%d zlata", sellPrice), "success")
            end
            return true
        end
    end
    return false
end

function Cartographer.buyMap(mapType, accuracy, price)
    local def = MAP_TYPES[mapType]
    if not def then return false, "Neznan zemljevid" end
    if #Cartographer.maps >= Cartographer.getMapCapacity() then
        return false, "Arhiv je poln"
    end
    if not _G.state or (_G.state.gold or 0) < price then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - price
    local map = {
        id = "map_bought_" .. tostring(os.time()),
        type = mapType,
        name = def.name,
        region = "kupljeno",
        accuracy = accuracy or 0.70,
        value = price,
        strategicBonus = def.strategicBonus or 0,
        tradeBonus = def.tradeBonus or 0,
        navalBonus = def.navalBonus or 0,
        createdDay = os.time(),
    }
    table.insert(Cartographer.maps, map)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zemljevid kupljen: " .. def.name, "success")
    end
    return true
end

-- ============================================================
-- STRATEGIC BONUSES
-- ============================================================
function Cartographer.getActiveBonuses()
    local bonuses = {
        strategicBonus = 0,
        tradeBonus = 0,
        navalBonus = 0,
        accuracyBonus = Cartographer.getAccuracyBonus(),
    }
    -- Add building bonuses
    bonuses.strategicBonus = bonuses.strategicBonus + Cartographer.getStrategicBonus()
    -- Add map bonuses (best of each type)
    local bestMilitary = 0
    local bestTrade = 0
    local bestNaval = 0
    for _, m in ipairs(Cartographer.maps) do
        if m.strategicBonus and m.strategicBonus > bestMilitary then
            bestMilitary = m.strategicBonus * m.accuracy
        end
        if m.tradeBonus and m.tradeBonus > bestTrade then
            bestTrade = m.tradeBonus * m.accuracy
        end
        if m.navalBonus and m.navalBonus > bestNaval then
            bestNaval = m.navalBonus * m.accuracy
        end
    end
    bonuses.strategicBonus = bonuses.strategicBonus + bestMilitary
    bonuses.tradeBonus = bestTrade
    bonuses.navalBonus = bestNaval
    return bonuses
end

-- ============================================================
-- UPDATE
-- ============================================================
function Cartographer.update(dt)
    if not _G.state then return end
    Cartographer.dayTimer = Cartographer.dayTimer + dt
    if Cartographer.dayTimer >= 30 then
        Cartographer.dayTimer = 0
        -- Process map creations
        for i = #Cartographer.activeMapCreations, 1, -1 do
            local c = Cartographer.activeMapCreations[i]
            c.daysRemaining = c.daysRemaining - 1
            if c.daysRemaining <= 0 then
                Cartographer.completeMapCreation(c)
                table.remove(Cartographer.activeMapCreations, i)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Cartographer.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Cartographer.cartographer then totalUpkeep = totalUpkeep + 20 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Cartographer.getMapTypeInfo(typeId) return MAP_TYPES[typeId] end
function Cartographer.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Cartographer.getStats()
    return {
        numMaps = #Cartographer.maps,
        mapCapacity = Cartographer.getMapCapacity(),
        numBuildings = #Cartographer.buildings,
        hasCartographer = Cartographer.cartographer ~= nil,
        cartographerName = Cartographer.cartographer and Cartographer.cartographer.name or "—",
        cartographerSkill = Cartographer.cartographer and Cartographer.cartographer.skill or 0,
        activeCreations = #Cartographer.activeMapCreations,
        totalMapsCreated = Cartographer.totalMapsCreated,
        totalTreasuresFound = Cartographer.totalTreasuresFound,
        totalRegionsExplored = Cartographer.totalRegionsExplored,
        strategicBonus = Cartographer.getActiveBonuses().strategicBonus,
    }
end

return Cartographer
