-- objects/AI/EconomyAI.lua
-- Stronghold 2027 - AI Economy Manager
--
-- Handles economic decisions for AI factions:
-- - Resource gathering priorities
-- - Building queue management
-- - Worker assignment
-- - Trade decisions
-- - Food management
--
-- Works with AIStrategyController to execute economic plans

local EconomyAI = _G.class("EconomyAI")

-- Resource priorities (which resource to focus on)
local RESOURCE_PRIORITIES = {
    startup = { wood = 0.5, stone = 0.2, food = 0.2, gold = 0.1 },
    economy = { wood = 0.3, stone = 0.2, food = 0.3, gold = 0.2 },
    military = { wood = 0.1, stone = 0.1, food = 0.2, gold = 0.6 },
    trade = { gold = 0.7, wood = 0.1, stone = 0.1, food = 0.1 },
}

-- Building priorities by phase
local BUILD_PRIORITIES = {
    startup = {
        { name = "Woodcutter", count = 3, urgency = 1.0 },
        { name = "Stockpile", count = 2, urgency = 0.9 },
        { name = "Granary", count = 1, urgency = 0.8 },
        { name = "Quarry", count = 2, urgency = 0.7 },
    },
    economy = {
        { name = "WheatFarm", count = 3, urgency = 0.8 },
        { name = "Bakery", count = 2, urgency = 0.7 },
        { name = "IronMine", count = 2, urgency = 0.6 },
        { name = "Market", count = 1, urgency = 0.5 },
        { name = "Brewery", count = 1, urgency = 0.4 },
        { name = "HopsFarm", count = 2, urgency = 0.4 },
    },
    military = {
        { name = "Barracks", count = 1, urgency = 0.9 },
        { name = "Armoury", count = 1, urgency = 0.8 },
        { name = "Fletcher", count = 2, urgency = 0.7 },
        { name = "Blacksmith", count = 2, urgency = 0.7 },
        { name = "StoneBarracks", count = 1, urgency = 0.5 },
    },
    defense = {
        { name = "WoodenWall", count = 8, urgency = 0.9 },
        { name = "SquareTower", count = 3, urgency = 0.7 },
        { name = "StoneGateSouth", count = 1, urgency = 0.6 },
        { name = "RoundTower", count = 2, urgency = 0.5 },
    },
}

function EconomyAI:initialize()
    self.factionStates = {}
    print("[EconomyAI] Initialized")
end

-- Initialize economy state for a faction
function EconomyAI:initFaction(faction, personality)
    self.factionStates[faction] = {
        personality = personality or "balanced",
        phase = "startup",
        buildQueue = {},
        workerAssignments = {},
        tradeHistory = {},
        lastProductionCheck = 0,
        productionRates = { wood = 0, stone = 0, food = 0, gold = 0 },
        consumptionRates = { wood = 0, stone = 0, food = 0, gold = 0 },
    }
end

-- Update economy for a faction
function EconomyAI:update(faction, dt)
    local state = self.factionStates[faction]
    if not state then return end

    -- Update production/consumption rates
    self:updateProductionRates(faction, state)

    -- Determine current economic phase
    self:determinePhase(faction, state)

    -- Process build queue
    self:processBuildQueue(faction, state)

    -- Manage workers
    self:manageWorkers(faction, state)

    -- Trade decisions
    self:evaluateTrade(faction, state)
end

-- Determine which economic phase the faction is in
function EconomyAI:determinePhase(faction, state)
    local resources = self:getResources(faction)

    -- Nil-safe access
    local wood = resources.wood or 0
    local stone = resources.stone or 0
    local food = resources.food or 0
    local gold = resources.gold or 0

    if wood < 50 or stone < 20 then
        state.phase = "startup"
    elseif food < 30 then
        state.phase = "economy"
    elseif gold < 200 then
        state.phase = "economy"
    elseif gold > 500 and wood > 100 then
        state.phase = "military"
    else
        state.phase = "economy"
    end
end

-- Get current resources for a faction
function EconomyAI:getResources(faction)
    -- Stronghold 2027 v2.3.2: Query real game state when available
    if faction == 1 and _G.state and _G.state.resources then
        local r = _G.state.resources
        return {
            wood = r.wood or 0,
            stone = r.stone or 0,
            food = r.food or 0,
            gold = r.gold or 0,
            iron = r.iron or 0,
            pitch = r.pitch or 0,
            ale = r.ale or 0,
            wheat = r.wheat or 0,
            bows = r.bows or 0,
            spears = r.spears or 0,
            swords = r.swords or 0,
            armor = r.armor or 0
        }
    end
    -- AI factions: return tracked state resources, or sensible defaults
    local state = self.factionStates[faction]
    if state and state.resources then
        return state.resources
    end
    -- Default fallback (includes all resources checked by evaluateTrade)
    return { wood = 100, stone = 50, food = 50, gold = 500, iron = 20 }
end

-- Update production rates (per second)
function EconomyAI:updateProductionRates(faction, state)
    -- Calculate based on buildings
    -- In real implementation, this would count actual production buildings
    state.productionRates.wood = 2.0   -- 2 wood/sec
    state.productionRates.stone = 1.0
    state.productionRates.food = 1.5
    state.productionRates.gold = 0.5
end

-- Process build queue
function EconomyAI:processBuildQueue(faction, state)
    local priorities = BUILD_PRIORITIES[state.phase] or BUILD_PRIORITIES.economy

    -- Check each priority
    for _, priority in ipairs(priorities) do
        local currentCount = self:countBuildings(faction, priority.name)
        if currentCount < priority.count then
            -- Add to build queue if not already there
            if not self:isInBuildQueue(state, priority.name) then
                self:queueBuilding(faction, state, priority.name, priority.urgency)
            end
        end
    end
end

-- Count buildings of a type for a faction
function EconomyAI:countBuildings(faction, buildingName)
    if not _G.state or not _G.state.gameObjectList then return 0 end

    local count = 0
    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.faction == faction and obj.class and obj.class.name == buildingName then
            count = count + 1
        end
    end
    return count
end

-- Check if building is already in queue
function EconomyAI:isInBuildQueue(state, buildingName)
    for _, item in ipairs(state.buildQueue) do
        if item.building == buildingName then return true end
    end
    return false
end

-- Queue a building for construction
function EconomyAI:queueBuilding(faction, state, buildingName, urgency)
    table.insert(state.buildQueue, {
        building = buildingName,
        urgency = urgency or 0.5,
        queuedAt = love.timer.getTime(),
    })

    -- Sort by urgency (highest first)
    table.sort(state.buildQueue, function(a, b) return a.urgency > b.urgency end)

    print(string.format("[EconomyAI %d] Queued: %s (urgency: %.2f)", faction, buildingName, urgency or 0.5))
end

-- Manage worker assignments
function EconomyAI:manageWorkers(faction, state)
    local priorities = RESOURCE_PRIORITIES[state.phase] or RESOURCE_PRIORITIES.economy

    -- Determine which resource needs more workers
    local needed = "wood"
    local maxPriority = 0
    for resource, priority in pairs(priorities) do
        if priority > maxPriority then
            maxPriority = priority
            needed = resource
        end
    end

    -- Stronghold 2027 v2.3.7: Actually assign workers to buildings
    if not _G.state or not _G.state.gameObjectList then return end
    local buildingType = nil
    if needed == "wood" then buildingType = "WoodcutterHut"
    elseif needed == "stone" then buildingType = "Quarry"
    elseif needed == "food" then buildingType = "WheatFarm"
    elseif needed == "iron" then buildingType = "IronMine"
    elseif needed == "gold" then buildingType = "Market"
    end
    if buildingType then
        for _, obj in ipairs(_G.state.gameObjectList) do
            if obj.faction == faction and obj.class and obj.class.name == buildingType then
                -- AutoWorker system handles actual assignment if available
                if _G.AutoWorker and _G.AutoWorker.assignToBuilding then
                    pcall(function() _G.AutoWorker.assignToBuilding(obj) end)
                end
                break  -- assign to first matching building
            end
        end
    end
end

-- Evaluate trade opportunities
function EconomyAI:evaluateTrade(faction, state)
    -- Don't trade too often
    if love.timer.getTime() - (state.lastTradeCheck or 0) < 30 then return end
    state.lastTradeCheck = love.timer.getTime()

    local resources = self:getResources(faction)

    -- Nil-safe resource access (default to 0 if missing)
    local wood = resources.wood or 0
    local stone = resources.stone or 0
    local food = resources.food or 0
    local gold = resources.gold or 0
    local iron = resources.iron or 0

    -- Sell excess resources
    if wood > 200 then
        self:sellResource(faction, "wood", 50)
    end
    if stone > 150 then
        self:sellResource(faction, "stone", 30)
    end

    -- Buy needed resources
    if food < 20 and gold > 200 then
        self:buyResource(faction, "food", 30)
    end
    if iron < 10 and gold > 300 then
        self:buyResource(faction, "iron", 20)
    end
end

-- Sell resource at market
function EconomyAI:sellResource(faction, resource, amount)
    local state = self.factionStates[faction]
    if not state then return end
    -- Stronghold 2027 v2.3.7: Actually deduct resource and add gold
    local resources = self:getResources(faction)
    local available = resources[resource] or 0
    if available < amount then return end  -- not enough to sell
    -- Get sell price from DynamicMarket
    local DynamicMarket = _G.DynamicMarket or require("objects.Economy.DynamicMarketSystem")
    local pricePerUnit = 5  -- fallback price
    if DynamicMarket and DynamicMarket.getPrice then
        pricePerUnit = DynamicMarket.getPrice(resource, "sell") or 5
    end
    local totalGold = amount * pricePerUnit
    -- Deduct resource
    if state.resources then
        state.resources[resource] = (state.resources[resource] or 0) - amount
    end
    -- Add gold
    if state.resources then
        state.resources.gold = (state.resources.gold or 0) + totalGold
    end
    -- Record transaction in market (affects supply/demand)
    if DynamicMarket and DynamicMarket.recordTransaction then
        pcall(function() DynamicMarket.recordTransaction(resource, amount, "sell") end)
    end
    table.insert(state.tradeHistory, {
        type = "sell",
        resource = resource,
        amount = amount,
        gold = totalGold,
        time = love.timer.getTime(),
    })
    print(string.format("[EconomyAI %d] Sold %d %s for %d gold", faction, amount, resource, totalGold))
end

-- Buy resource at market
function EconomyAI:buyResource(faction, resource, amount)
    local state = self.factionStates[faction]
    if not state then return end
    -- Stronghold 2027 v2.3.7: Actually deduct gold and add resource
    local resources = self:getResources(faction)
    local availableGold = resources.gold or 0
    -- Get buy price from DynamicMarket
    local DynamicMarket = _G.DynamicMarket or require("objects.Economy.DynamicMarketSystem")
    local pricePerUnit = 5  -- fallback price
    if DynamicMarket and DynamicMarket.getPrice then
        pricePerUnit = DynamicMarket.getPrice(resource, "buy") or 5
    end
    local totalCost = amount * pricePerUnit
    if availableGold < totalCost then return end  -- not enough gold
    -- Deduct gold
    if state.resources then
        state.resources.gold = (state.resources.gold or 0) - totalCost
    end
    -- Add resource
    if state.resources then
        state.resources[resource] = (state.resources[resource] or 0) + amount
    end
    -- Record transaction in market
    if DynamicMarket and DynamicMarket.recordTransaction then
        pcall(function() DynamicMarket.recordTransaction(resource, amount, "buy") end)
    end
    table.insert(state.tradeHistory, {
        type = "buy",
        resource = resource,
        amount = amount,
        gold = totalCost,
        time = love.timer.getTime(),
    })
    print(string.format("[EconomyAI %d] Bought %d %s for %d gold", faction, amount, resource, totalCost))
end

-- Get next building to construct
function EconomyAI:getNextBuild(faction)
    local state = self.factionStates[faction]
    if not state or #state.buildQueue == 0 then return nil end
    return state.buildQueue[1]
end

-- Remove a completed build from queue
function EconomyAI:completeBuild(faction, buildingName)
    local state = self.factionStates[faction]
    if not state then return end

    for i, item in ipairs(state.buildQueue) do
        if item.building == buildingName then
            table.remove(state.buildQueue, i)
            break
        end
    end
end

-- Get economic stats
function EconomyAI:getStats(faction)
    local state = self.factionStates[faction]
    if not state then return nil end

    return {
        phase = state.phase,
        buildQueueSize = #state.buildQueue,
        productionRates = state.productionRates,
        tradeCount = #state.tradeHistory,
        nextBuild = state.buildQueue[1] and state.buildQueue[1].building or "none",
    }
end

return EconomyAI:new()
