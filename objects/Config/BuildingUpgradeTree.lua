-- objects/Config/BuildingUpgradeTree.lua
-- Castle Kingdoms 2027 - Building Upgrade Tree
-- Visual tech tree showing building progression and unlocks

local UpgradeTree = {}

-- Building upgrade paths
local UPGRADE_PATHS = {
    -- Keep progression
    keep = {
        current = "WoodenKeep",
        name = "Grad",
        tiers = {
            { building = "WoodenKeep",  tier = 1, cost = { gold = 0   }, unlocks = {"Barracks", "Stockpile", "Granary"} },
            { building = "Keep",         tier = 2, cost = { gold = 500 }, unlocks = {"StoneBarracks", "Market", "Armoury"} },
            { building = "Fortress",     tier = 3, cost = { gold = 1500 }, unlocks = {"EngineersGuild", "TunnelersGuild", "Stable"} },
            { building = "Castle Kingdoms",   tier = 4, cost = { gold = 3000 }, unlocks = {"Cathedral", "BigResidence", "AllBuildings"} },
        },
    },
    -- House progression
    house = {
        current = "Hovel",
        name = "Hiša",
        tiers = {
            { building = "Hovel",       tier = 1, cost = { wood = 6  }, capacity = 4 },
            { building = "Flat",        tier = 2, cost = { wood = 15 }, capacity = 6 },
            { building = "Residence",   tier = 3, cost = { wood = 25, stone = 5 }, capacity = 8 },
            { building = "BigResidence",tier = 4, cost = { wood = 40, stone = 15 }, capacity = 12 },
        },
    },
    -- Barracks progression
    barracks = {
        current = "Barracks",
        name = "Barake",
        tiers = {
            { building = "Barracks",       tier = 1, cost = { wood = 25 }, units = {"Spearman", "Archer"} },
            { building = "StoneBarracks",  tier = 2, cost = { stone = 30 }, units = {"Pikeman", "Crossbowman"} },
        },
    },
    -- Religious progression
    religion = {
        current = "Chapel",
        name = "Religija",
        tiers = {
            { building = "Chapel",    tier = 1, cost = { wood = 20, stone = 30 } },
            { building = "Church",    tier = 2, cost = { wood = 30, stone = 50 } },
            { building = "Cathedral", tier = 3, cost = { wood = 50, stone = 100 } },
        },
    },
    -- Walls progression
    walls = {
        current = "WoodenWall",
        name = "Zidovi",
        tiers = {
            { building = "WoodenWall",     tier = 1, cost = { wood = 5  } },
            { building = "StoneWall",      tier = 2, cost = { stone = 10 } },
        },
    },
    -- Castle Kingdoms 2027 v2.6.1: New upgrade paths
    -- Siege progression
    siege = {
        current = "EngineersGuild",
        name = "Oblegovalna",
        tiers = {
            { building = "EngineersGuild",  tier = 1, cost = { wood = 30, stone = 20 }, units = {"Catapult"} },
            { building = "SiegeWorkshop",   tier = 2, cost = { wood = 50, stone = 40, gold = 200 }, units = {"Trebuchet", "SiegeTower"} },
            { building = "RoyalSiegeGuild", tier = 3, cost = { wood = 80, stone = 60, gold = 500 }, units = {"BatteringRam", "AllSiegeUnits"} },
        },
    },
    -- Economy progression
    economy = {
        current = "Market",
        name = "Ekonomija",
        tiers = {
            { building = "Market",        tier = 1, cost = { wood = 30, stone = 15 }, bonus = "trade_routes" },
            { building = "TradePost",     tier = 2, cost = { wood = 50, stone = 30, gold = 300 }, bonus = "caravan_bonus" },
            { building = "RoyalExchange", tier = 3, cost = { wood = 80, stone = 60, gold = 800 }, bonus = "dynamic_prices" },
        },
    },
}

UpgradeTree.UPGRADE_PATHS = UPGRADE_PATHS
local initialized = false

function UpgradeTree.init()
    if initialized then return end
    initialized = true
    print("[UpgradeTree] Initialized with " .. UpgradeTree._getPathCount() .. " upgrade paths")
end

function UpgradeTree._getPathCount()
    local c = 0
    for _ in pairs(UPGRADE_PATHS) do c = c + 1 end
    return c
end

-- Get upgrade path for a category
function UpgradeTree.getPath(category)
    return UPGRADE_PATHS[category]
end

-- Get current tier for a category
function UpgradeTree.getCurrentTier(category)
    local path = UPGRADE_PATHS[category]
    if not path then return nil end
    for _, tier in ipairs(path.tiers) do
        if tier.building == path.current then
            return tier
        end
    end
    return path.tiers[1]
end

-- Get next available upgrade
function UpgradeTree.getNextUpgrade(category)
    local path = UPGRADE_PATHS[category]
    if not path then return nil end

    local currentTier = 0
    for i, tier in ipairs(path.tiers) do
        if tier.building == path.current then
            currentTier = i
            break
        end
    end

    if currentTier < #path.tiers then
        return path.tiers[currentTier + 1]
    end
    return nil  -- Max tier reached
end

-- Check if upgrade is available
function UpgradeTree.canUpgrade(category)
    local next = UpgradeTree.getNextUpgrade(category)
    if not next then return false end

    -- Check resources
    if _G.state then
        for res, amount in pairs(next.cost or {}) do
            if res == "gold" then
                if (_G.state.gold or 0) < amount then return false end
            elseif _G.state.resources then
                if (_G.state.resources[res] or 0) < amount then return false end
            end
        end
    end

    return true
end

-- Perform upgrade
function UpgradeTree.upgrade(category)
    if not UpgradeTree.canUpgrade(category) then return false end

    local path = UPGRADE_PATHS[category]
    local next = UpgradeTree.getNextUpgrade(category)
    if not next then return false end

    -- Deduct cost
    if _G.state then
        for res, amount in pairs(next.cost or {}) do
            if res == "gold" then
                _G.state.gold = (_G.state.gold or 0) - amount
            elseif _G.state.resources then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amount
            end
        end
    end

    -- Update current
    path.current = next.building

    -- Emit event
    if _G.GameEventBus then
        _G.GameEventBus.emit("building_upgraded", {
            category = category,
            newBuilding = next.building,
            tier = next.tier,
        })
    end

    if _G.VoiceOver then
        _G.VoiceOver.notify("building_upgraded", path.name .. " -> " .. next.building)
    end

    print(string.format("[UpgradeTree] %s upgraded to %s (tier %d)", path.name, next.building, next.tier))
    return true
end

-- Get all paths
function UpgradeTree.getAllPaths()
    local list = {}
    for category, path in pairs(UPGRADE_PATHS) do
        local current = UpgradeTree.getCurrentTier(category)
        local next = UpgradeTree.getNextUpgrade(category)
        table.insert(list, {
            category = category,
            name = path.name,
            currentBuilding = path.current,
            currentTier = current and current.tier or 0,
            canUpgrade = next ~= nil,
            nextBuilding = next and next.building or nil,
            nextCost = next and next.cost or nil,
        })
    end
    return list
end

-- Get buildings unlocked by current tier
function UpgradeTree.getUnlockedBuildings(category)
    local tier = UpgradeTree.getCurrentTier(category)
    if not tier or not tier.unlocks then return {} end
    return tier.unlocks
end

-- Check if a building is unlocked
function UpgradeTree.isBuildingUnlocked(buildingName)
    for category, path in pairs(UPGRADE_PATHS) do
        for _, tier in ipairs(path.tiers) do
            if tier.unlocks then
                for _, unlocked in ipairs(tier.unlocks) do
                    if unlocked == buildingName or unlocked == "AllBuildings" then
                        -- Check if this tier is reached
                        local currentTier = UpgradeTree.getCurrentTier(category)
                        if currentTier and currentTier.tier >= tier.tier then
                            return true
                        end
                    end
                end
            end
        end
    end
    return true  -- Default: unlocked
end

return UpgradeTree
