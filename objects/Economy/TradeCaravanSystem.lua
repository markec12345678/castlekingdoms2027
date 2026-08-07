-- objects/Economy/TradeCaravanSystem.lua
-- Castle Kingdoms 2027 - International Trade Caravans
--
-- Allows sending trade caravans to AI factions for better prices:
-- - Higher sell prices than local market
-- - Risk of pirate attack (loses goods)
-- - Requires escort for safety
-- - Travel time based on distance
-- - Builds diplomatic relations
--
-- Usage:
--   local Caravans = require("objects.Economy.TradeCaravanSystem")
--   Caravans.init()
--   Caravans.update(dt)
--   Caravans.send("ai_faction_2", { wood = 50 }, 250, {"Knight", "Archer"})

local COMBAT = require("objects.Enums.Combat")

local TradeCaravanSystem = {}

-- State
local initialized = false
local activeCaravans = {}  -- caravans currently traveling
local completedCaravans = {}  -- log of completed caravans
local nextCaravanId = 1

-- Configuration
local config = {
    baseTravelSpeed = 1.0,  -- tiles per second
    basePirateRisk = 0.10,  -- 10% base risk without escort
    escortRiskReduction = 0.02,  -- each escort unit reduces risk by 2%
    minRisk = 0.01,  -- minimum 1% risk even with full escort
    rewardMultiplier = 1.3,  -- 30% better than local market
    relationBonus = 1,  -- relation increase per successful trade
}

-- Initialize
function TradeCaravanSystem.init()
    if initialized then return end
    initialized = true
    print("[TradeCaravans] Initialized")
end

-- Send a trade caravan
-- @param targetFaction number Faction ID to trade with
-- @param goods table Map of resource -> quantity (e.g., { wood = 50, stone = 20 })
-- @param expectedPayment number Expected gold payment
-- @param escort table Optional list of unit class names (e.g., {"Knight", "Archer"})
-- @return number caravan ID, or nil on failure
function TradeCaravanSystem.send(targetFaction, goods, expectedPayment, escort)
    if not initialized then TradeCaravanSystem.init() end

    -- Find source and target positions
    local sourceGx, sourceGy = TradeCaravanSystem.findPlayerKeep()
    local targetGx, targetGy = TradeCaravanSystem.findFactionKeep(targetFaction)

    if not sourceGx or not targetGx then
        print("[TradeCaravans] Cannot find source or target keep")
        return nil
    end

    -- Calculate distance
    local dx = targetGx - sourceGx
    local dy = targetGy - sourceGy
    local distance = math.sqrt(dx * dx + dy * dy)

    -- Calculate travel time
    local travelTime = distance / config.baseTravelSpeed

    -- Calculate risk
    local escortCount = escort and #escort or 0
    local risk = math.max(config.minRisk,
                          config.basePirateRisk - (escortCount * config.escortRiskReduction))

    -- Calculate actual payment (with reward multiplier)
    local actualPayment = math.floor(expectedPayment * config.rewardMultiplier)

    -- Deduct goods from player
    if not TradeCaravanSystem.deductGoods(goods) then
        print("[TradeCaravans] Insufficient goods")
        return nil
    end

    -- Create caravan
    local caravan = {
        id = nextCaravanId,
        targetFaction = targetFaction,
        goods = goods,
        payment = actualPayment,
        escort = escort or {},
        risk = risk,
        sourceGx = sourceGx,
        sourceGy = sourceGy,
        targetGx = targetGx,
        targetGy = targetGy,
        distance = distance,
        travelTime = travelTime,
        elapsed = 0,
        state = "outbound",  -- outbound, returning, completed, attacked
        startTime = love.timer.getTime(),
    }

    table.insert(activeCaravans, caravan)
    nextCaravanId = nextCaravanId + 1

    local ModernUI = require("objects.UI.ModernUISystem")
    ModernUI.notifyInfo(string.format("Caravan dispatched to faction %d (travel: %ds, risk: %.0f%%)",
        targetFaction, math.floor(travelTime), risk * 100))

    print(string.format("[TradeCaravans] Caravan #%d dispatched: faction %d, %d goods, %d gold, risk %.0f%%",
        caravan.id, targetFaction, TradeCaravanSystem.countGoods(goods), actualPayment, risk * 100))

    return caravan.id
end

-- Update all caravans
function TradeCaravanSystem.update(dt)
    if not initialized then return end

    for i = #activeCaravans, 1, -1 do
        local caravan = activeCaravans[i]
        caravan.elapsed = caravan.elapsed + dt

        if caravan.state == "outbound" then
            if caravan.elapsed >= caravan.travelTime then
                -- Reached destination
                TradeCaravanSystem.onCaravanArrived(caravan)
            end
        elseif caravan.state == "returning" then
            if caravan.elapsed >= caravan.travelTime * 2 then
                -- Returned home
                TradeCaravanSystem.onCaravanReturned(caravan)
                table.remove(activeCaravans, i)
            end
        elseif caravan.state == "attacked" then
            -- Caravan was attacked, remove after short delay
            if caravan.elapsed >= caravan.travelTime + 5 then
                table.remove(activeCaravans, i)
            end
        end
    end
end

-- Caravan arrived at destination
function TradeCaravanSystem.onCaravanArrived(caravan)
    -- Check if caravan was attacked en route
    if math.random() < caravan.risk then
        -- Attack occurred
        caravan.state = "attacked"
        caravan.attackTime = love.timer.getTime()

        local ModernUI = require("objects.UI.ModernUISystem")
        ModernUI.notifyError(string.format("Caravan #%d attacked by pirates! Goods lost.", caravan.id))

        print(string.format("[TradeCaravans] Caravan #%d attacked by pirates!", caravan.id))

        -- Log as completed (failed)
        table.insert(completedCaravans, {
            id = caravan.id,
            targetFaction = caravan.targetFaction,
            goods = caravan.goods,
            payment = 0,
            success = false,
            reason = "pirate_attack",
            time = love.timer.getTime(),
        })
        return
    end

    -- Successful arrival - exchange goods for gold
    caravan.state = "returning"
    caravan.elapsed = caravan.travelTime  -- reset for return trip

    -- Pay player immediately (will receive when caravan returns)
    caravan.paymentReceived = caravan.payment

    local ModernUI = require("objects.UI.ModernUISystem")
    ModernUI.notifySuccess(string.format("Caravan #%d reached destination! Returning with %d gold.",
        caravan.id, caravan.payment))

    print(string.format("[TradeCaravans] Caravan #%d arrived, returning with %d gold",
        caravan.id, caravan.payment))
end

-- Caravan returned home
function TradeCaravanSystem.onCaravanReturned(caravan)
    -- Add gold to player
    if caravan.paymentReceived and _G.state then
        _G.state.gold = (_G.state.gold or 0) + caravan.paymentReceived
    end

    -- Build diplomatic relations
    TradeCaravanSystem.improveRelations(caravan.targetFaction)

    local ModernUI = require("objects.UI.ModernUISystem")
    ModernUI.notifySuccess(string.format("Caravan #%d returned! +%d gold", caravan.id, caravan.paymentReceived))

    print(string.format("[TradeCaravans] Caravan #%d completed: +%d gold", caravan.id, caravan.paymentReceived))

    -- Log as completed (success)
    table.insert(completedCaravans, {
        id = caravan.id,
        targetFaction = caravan.targetFaction,
        goods = caravan.goods,
        payment = caravan.paymentReceived,
        success = true,
        time = love.timer.getTime(),
    })

    -- Limit history
    while #completedCaravans > 20 do
        table.remove(completedCaravans, 1)
    end
end

-- Find player's keep
function TradeCaravanSystem.findPlayerKeep()
    if not _G.state or not _G.state.gameObjectList then return nil end

    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.class and obj.class.name then
            local name = obj.class.name
            if (name == "Keep" or name == "WoodenKeep" or name == "SaxonHall")
                and (not obj.faction or obj.faction == COMBAT.FACTION_PLAYER) then
                return obj.gx, obj.gy
            end
        end
    end
    return nil
end

-- Find a faction's keep
function TradeCaravanSystem.findFactionKeep(faction)
    if not _G.state or not _G.state.gameObjectList then return nil end

    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.faction == faction and obj.class and obj.class.name then
            local name = obj.class.name
            if name == "Keep" or name == "WoodenKeep" or name == "SaxonHall" then
                return obj.gx, obj.gy
            end
        end
    end
    return nil
end

-- Deduct goods from player's stockpile
function TradeCaravanSystem.deductGoods(goods)
    -- Castle Kingdoms 2027 v2.3.4: Actually check and deduct resources from player
    if not _G.state or not _G.state.resources then return false end

    -- First pass: verify all goods are available
    for resource, qty in pairs(goods) do
        local available = _G.state.resources[resource] or 0
        if available < qty then
            local ModernUI = require("objects.UI.ModernUISystem")
            ModernUI.notifyError(string.format("Ni dovolj %s (ima: %d, potrebuje: %d)",
                resource, available, qty))
            return false
        end
    end

    -- Second pass: deduct
    for resource, qty in pairs(goods) do
        _G.state.resources[resource] = _G.state.resources[resource] - qty
    end
    return true
end

-- Count total goods in a goods table
function TradeCaravanSystem.countGoods(goods)
    local count = 0
    for _, qty in pairs(goods) do
        count = count + qty
    end
    return count
end

-- Improve diplomatic relations with a faction
function TradeCaravanSystem.improveRelations(faction)
    -- Castle Kingdoms 2027 v2.3.4: Actually update diplomacy relations
    local DiplomacyController = _G.DiplomacyController or (require("objects.Network.DiplomacyController"))
    if DiplomacyController and DiplomacyController.improveRelations then
        pcall(function() DiplomacyController.improveRelations(faction, 5) end)
    end
    -- Also fire event for other systems
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("trade_completed", {faction = faction}) end)
    end
    print(string.format("[TradeCaravans] Relations with faction %d improved", faction))
end

-- Get active caravans (for UI)
function TradeCaravanSystem.getActiveCaravans()
    local list = {}
    for _, caravan in ipairs(activeCaravans) do
        local progress
        if caravan.state == "outbound" then
            progress = caravan.elapsed / caravan.travelTime
        elseif caravan.state == "returning" then
            progress = (caravan.elapsed - caravan.travelTime) / caravan.travelTime
        else
            progress = 1.0
        end

        table.insert(list, {
            id = caravan.id,
            targetFaction = caravan.targetFaction,
            state = caravan.state,
            progress = math.min(1.0, progress),
            goods = caravan.goods,
            payment = caravan.payment,
            risk = caravan.risk,
            escortCount = #caravan.escort,
            remaining = math.max(0, caravan.travelTime * 2 - caravan.elapsed),
        })
    end
    return list
end

-- Get completed caravans history
function TradeCaravanSystem.getCompletedCaravans()
    return completedCaravans
end

-- Get stats
function TradeCaravanSystem.getStats()
    local totalProfit = 0
    local successCount = 0
    local failCount = 0

    for _, caravan in ipairs(completedCaravans) do
        if caravan.success then
            totalProfit = totalProfit + caravan.payment
            successCount = successCount + 1
        else
            failCount = failCount + 1
        end
    end

    return {
        activeCount = #activeCaravans,
        completedCount = #completedCaravans,
        successCount = successCount,
        failCount = failCount,
        totalProfit = totalProfit,
        successRate = (successCount + failCount) > 0 and (successCount / (successCount + failCount)) or 0,
    }
end

-- Reset (for new game)
function TradeCaravanSystem.reset()
    activeCaravans = {}
    completedCaravans = {}
    nextCaravanId = 1
    print("[TradeCaravans] Reset")
end

-- Calculate estimated payment for goods (UI helper)
function TradeCaravanSystem.estimatePayment(goods)
    local DynamicMarket = require("objects.Economy.DynamicMarketSystem")
    local total = 0
    for resource, quantity in pairs(goods) do
        local price = DynamicMarket.getPrice(resource, "sell")
        total = total + (price * quantity)
    end
    return math.floor(total * config.rewardMultiplier)
end

-- Calculate risk for a caravan (UI helper)
function TradeCaravanSystem.calculateRisk(escort)
    local escortCount = escort and #escort or 0
    return math.max(config.minRisk,
                    config.basePirateRisk - (escortCount * config.escortRiskReduction))
end

return TradeCaravanSystem
