-- objects/Economy/ProductionChainSystem.lua
-- Stronghold 2027 v2.6.6 - Resource Production Chain System
--
-- Manages production chains where raw materials are processed into refined goods.
-- Example: wheat -> flour -> bread (3-stage chain)
-- Example: iron ore -> iron bars -> weapons (3-stage chain)
--
-- Each chain has:
-- - Raw material (produced by farms/mines)
-- - Processed material (produced by workshops)
-- - Final product (consumed by population/military)

local ProductionChain = {}

-- Production chain definitions
local CHAINS = {
    -- Food chains
    wheat_to_bread = {
        name = "Pšenica → Kruh",
        nameEn = "Wheat to Bread",
        stages = {
            { resource = "wheat",    building = "WheatFarm",  rate = 10 },
            { resource = "flour",    building = "Windmill",   rate = 8,  input = { wheat = 1 } },
            { resource = "bread",    building = "Bakery",     rate = 6,  input = { flour = 1 } },
        },
        finalProduct = "bread",
        category = "food",
    },
    hops_to_ale = {
        name = "Hmelj → Pivo",
        nameEn = "Hops to Ale",
        stages = {
            { resource = "hop",      building = "HopsFarm",   rate = 8 },
            { resource = "ale",      building = "Brewery",    rate = 6,  input = { hop = 1 } },
        },
        finalProduct = "ale",
        category = "food",
    },

    -- Weapon chains
    iron_to_swords = {
        name = "Železo → Meči",
        nameEn = "Iron to Swords",
        stages = {
            { resource = "iron",     building = "IronMine",   rate = 5 },
            { resource = "sword",    building = "Blacksmith", rate = 3,  input = { iron = 2 } },
        },
        finalProduct = "sword",
        category = "weapon",
    },
    wood_to_bows = {
        name = "Les → Loki",
        nameEn = "Wood to Bows",
        stages = {
            { resource = "wood",     building = "Woodcutter", rate = 12 },
            { resource = "bow",      building = "Fletcher",   rate = 6,  input = { wood = 1 } },
        },
        finalProduct = "bow",
        category = "weapon",
    },
    wood_to_pikes = {
        name = "Les → Kopja",
        nameEn = "Wood to Pikes",
        stages = {
            { resource = "wood",     building = "Woodcutter", rate = 12 },
            { resource = "pike",     building = "Poleturner", rate = 8,  input = { wood = 1 } },
        },
        finalProduct = "pike",
        category = "weapon",
    },
    iron_to_armor = {
        name = "Železo → Oklep",
        nameEn = "Iron to Armor",
        stages = {
            { resource = "iron",     building = "IronMine",   rate = 5 },
            { resource = "armor",    building = "Armorer",    rate = 2,  input = { iron = 3 } },
        },
        finalProduct = "armor",
        category = "weapon",
    },

    -- Stone chain (simpler)
    stone_to_towers = {
        name = "Kamen → Stolpi",
        nameEn = "Stone to Towers",
        stages = {
            { resource = "stone",    building = "Quarry",     rate = 8 },
            { resource = "tower",    building = "SquareTower", rate = 0, input = { stone = 25 } },
        },
        finalProduct = "tower",
        category = "building",
    },
}

ProductionChain.CHAINS = CHAINS

local initialized = false
local chainStats = {}

function ProductionChain.init()
    if initialized then return end
    initialized = true
    -- Initialize stats for each chain
    for chainId, chain in pairs(CHAINS) do
        chainStats[chainId] = {
            active = false,
            stageProgress = {},
            bottleneck = nil,
        }
    end
    print("[ProductionChain] Initialized with " .. ProductionChain._getChainCount() .. " chains")
end

function ProductionChain._getChainCount()
    local count = 0
    for _ in pairs(CHAINS) do count = count + 1 end
    return count
end

-- Check if a building exists in player's faction
function ProductionChain._hasBuilding(buildingName)
    if not _G.state or not _G.state.gameObjectList then return false end
    for _, obj in ipairs(_G.state.gameObjectList) do
        if (not obj.faction or obj.faction == 1) and obj.class and obj.class.name == buildingName then
            return true
        end
    end
    return false
end

-- Count buildings of a type
function ProductionChain._countBuildings(buildingName)
    if not _G.state or not _G.state.gameObjectList then return 0 end
    local count = 0
    for _, obj in ipairs(_G.state.gameObjectList) do
        if (not obj.faction or obj.faction == 1) and obj.class and obj.class.name == buildingName then
            count = count + 1
        end
    end
    return count
end

-- Update chain statistics
function ProductionChain.update(dt)
    if not initialized then return end

    for chainId, chain in pairs(CHAINS) do
        local stats = chainStats[chainId]
        local allStagesActive = true
        local bottleneck = nil
        local minRate = math.huge

        for stageIdx, stage in ipairs(chain.stages) do
            local hasBuilding = ProductionChain._hasBuilding(stage.building)
            local buildingCount = ProductionChain._countBuildings(stage.building)
            local rate = stage.rate * buildingCount

            stats.stageProgress[stageIdx] = {
                building = stage.building,
                count = buildingCount,
                rate = rate,
                active = hasBuilding,
            }

            if not hasBuilding then
                allStagesActive = false
            end

            -- Find bottleneck (lowest rate stage)
            if hasBuilding and rate < minRate then
                minRate = rate
                bottleneck = stage.building
            end
        end

        stats.active = allStagesActive
        stats.bottleneck = bottleneck
    end
end

-- Get chain status
function ProductionChain.getChainStatus(chainId)
    local chain = CHAINS[chainId]
    if not chain then return nil end
    local stats = chainStats[chainId]
    if not stats then return nil end

    return {
        id = chainId,
        name = chain.name,
        nameEn = chain.nameEn,
        category = chain.category,
        finalProduct = chain.finalProduct,
        active = stats.active,
        bottleneck = stats.bottleneck,
        stages = stats.stageProgress,
    }
end

-- Get all chain statuses
function ProductionChain.getAllChains()
    local result = {}
    for chainId, _ in pairs(CHAINS) do
        table.insert(result, ProductionChain.getChainStatus(chainId))
    end
    return result
end

-- Get chains by category
function ProductionChain.getChainsByCategory(category)
    local result = {}
    for chainId, chain in pairs(CHAINS) do
        if chain.category == category then
            table.insert(result, ProductionChain.getChainStatus(chainId))
        end
    end
    return result
end

-- Get summary stats
function ProductionChain.getStats()
    local active = 0
    local total = 0
    local bottlenecks = {}
    for chainId, stats in pairs(chainStats) do
        total = total + 1
        if stats.active then active = active + 1 end
        if stats.bottleneck then
            bottlenecks[chainId] = stats.bottleneck
        end
    end
    return {
        totalChains = total,
        activeChains = active,
        bottlenecks = bottlenecks,
    }
end

return ProductionChain
