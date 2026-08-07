-- objects/Economy/TradeRouteSystem.lua
-- Castle Kingdoms 2027 v2.7.0 - Trade Route Manager
--
-- Persistent trade routes between player and AI factions.
-- Routes automatically generate income over time.
--
-- Route features:
-- - Create persistent trade routes (not one-time caravans)
-- - Route efficiency based on distance, safety, diplomatic relations
-- - Automatic income generation every 60 seconds
-- - Routes can be raided by bandits or enemy factions
-- - Upgrade routes for higher efficiency

local TradeRoute = {}

local initialized = false
local routes = {}  -- [routeId] = { sourceFaction, targetFaction, income, efficiency, ... }
local nextRouteId = 1
local incomeTimer = 0
local incomeInterval = 60  -- generate income every 60 seconds

function TradeRoute.init()
    if initialized then return end
    initialized = true
    print("[TradeRoute] Initialized")
end

-- Create a new trade route
function TradeRoute.createRoute(sourceFaction, targetFaction, routeType)
    local routeId = nextRouteId
    nextRouteId = nextRouteId + 1

    routeType = routeType or "standard"
    local config = {
        standard = { baseIncome = 50,  efficiency = 1.0, cost = 200 },
        luxury   = { baseIncome = 100, efficiency = 1.5, cost = 500 },
        military = { baseIncome = 75,  efficiency = 1.2, cost = 400 },
    }
    local cfg = config[routeType] or config.standard

    -- Check cost
    if _G.state and (_G.state.gold or 0) < cfg.cost then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Ni dovolj zlata za trgovsko pot (" .. cfg.cost .. "g)")
        end
        return nil, "Not enough gold"
    end

    -- Deduct cost
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) - cfg.cost
    end

    -- Calculate distance-based efficiency
    local distance = TradeRoute._calculateDistance(sourceFaction, targetFaction)
    local distanceEfficiency = math.max(0.3, 1.0 - (distance / 200))

    -- Get diplomatic bonus
    local diploBonus = 1.0
    if _G.DiplomaticRelations and _G.DiplomaticRelations.getTradeBonus then
        diploBonus = _G.DiplomaticRelations.getTradeBonus(sourceFaction, targetFaction)
    end

    -- Get seasonal bonus
    local seasonBonus = 1.0
    if _G.SeasonalSystem and _G.SeasonalSystem.getProductionModifier then
        seasonBonus = (_G.SeasonalSystem.getProductionModifier("gold") or 1.0) * 0.5 + 0.5
    end

    routes[routeId] = {
        id = routeId,
        sourceFaction = sourceFaction,
        targetFaction = targetFaction,
        routeType = routeType,
        baseIncome = cfg.baseIncome,
        efficiency = cfg.efficiency * distanceEfficiency * diploBonus * seasonBonus,
        distance = distance,
        incomeGenerated = 0,
        timesRaided = 0,
        active = true,
        created = os.time(),
        upgradeLevel = 0,
    }

    print("[TradeRoute] Created route " .. routeId .. " (" .. routeType .. ") efficiency: " ..
        string.format("%.2f", routes[routeId].efficiency))
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Trgovska pot ustvarjena! (" .. string.format("%.0f%%", routes[routeId].efficiency * 100) .. " učinkovitost)")
    end

    -- Improve diplomatic relations
    if _G.DiplomaticRelations then
        pcall(function() _G.DiplomaticRelations.modifyRelation(sourceFaction, targetFaction, "trade_completed") end)
    end

    return routeId
end

-- Calculate distance between factions
function TradeRoute._calculateDistance(sourceFaction, targetFaction)
    if not _G.state or not _G.state.gameObjectList then return 50 end
    local srcX, srcY, tgtX, tgtY
    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.class and obj.class.name then
            local name = obj.class.name
            if (name == "Keep" or name == "WoodenKeep" or name == "SaxonHall") then
                if obj.faction == sourceFaction and not srcX then
                    srcX, srcY = obj.gx, obj.gy
                elseif obj.faction == targetFaction and not tgtX then
                    tgtX, tgtY = obj.gx, obj.gy
                end
            end
        end
        if srcX and tgtX then break end
    end
    if not srcX or not tgtX then return 50 end
    local dx = tgtX - srcX
    local dy = tgtY - srcY
    return math.sqrt(dx * dx + dy * dy)
end

-- Destroy a trade route
function TradeRoute.destroyRoute(routeId)
    local route = routes[routeId]
    if not route then return false end
    print("[TradeRoute] Destroyed route " .. routeId)
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Trgovska pot zaprta")
    end
    routes[routeId] = nil
    return true
end

-- Upgrade a route for better efficiency
function TradeRoute.upgradeRoute(routeId)
    local route = routes[routeId]
    if not route then return false end
    local upgradeCost = 300 * (route.upgradeLevel + 1)
    if _G.state and (_G.state.gold or 0) < upgradeCost then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Posodobitev potrebuje " .. upgradeCost .. " zlata")
        end
        return false
    end
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) - upgradeCost
    end
    route.upgradeLevel = route.upgradeLevel + 1
    route.efficiency = route.efficiency * 1.15  -- +15% per upgrade
    route.baseIncome = route.baseIncome + 25
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Trgovska pot posodobljena na nivo " .. route.upgradeLevel)
    end
    return true
end

-- Generate income for all active routes
function TradeRoute._generateIncome()
    local totalIncome = 0
    for routeId, route in pairs(routes) do
        if route.active then
            -- Check for raid (5% base chance, modified by diplomacy)
            local raidChance = 0.05
            if _G.DiplomaticRelations then
                local score = _G.DiplomaticRelations.getRelation(route.sourceFaction, route.targetFaction) or 0
                if score < 0 then raidChance = raidChance + 0.10 end  -- hostile = more raids
            end
            if math.random() < raidChance then
                -- Route raided — no income this cycle
                route.timesRaided = route.timesRaided + 1
                if _G.ModernUI then
                    _G.ModernUI.notifyError("Trgovska pot " .. routeId .. " oplenjena!")
                end
                if _G.GameEventBus then
                    pcall(function() _G.GameEventBus.emit("trade_route_raided", { routeId = routeId }) end)
                end
            else
                -- Generate income
                local income = math.floor(route.baseIncome * route.efficiency)
                route.incomeGenerated = route.incomeGenerated + income
                totalIncome = totalIncome + income
            end
        end
    end
    -- Add to player gold
    if totalIncome > 0 and _G.state then
        _G.state.gold = (_G.state.gold or 0) + totalIncome
        if _G.ModernUI then
            _G.ModernUI.notifySuccess("Trgovski dohodek: +" .. totalIncome .. " zlata")
        end
        if _G.GameEventBus then
            pcall(function() _G.GameEventBus.emit("trade_income", { total = totalIncome }) end)
        end
    end
    return totalIncome
end

-- Update (called every frame)
function TradeRoute.update(dt)
    if not initialized then return end
    incomeTimer = incomeTimer + dt
    if incomeTimer >= incomeInterval then
        incomeTimer = 0
        TradeRoute._generateIncome()
    end
end

-- Get route info
function TradeRoute.getRoute(routeId)
    local route = routes[routeId]
    if not route then return nil end
    return {
        id = route.id,
        sourceFaction = route.sourceFaction,
        targetFaction = route.targetFaction,
        routeType = route.routeType,
        efficiency = route.efficiency,
        baseIncome = route.baseIncome,
        incomeGenerated = route.incomeGenerated,
        timesRaided = route.timesRaided,
        active = route.active,
        upgradeLevel = route.upgradeLevel,
        distance = route.distance,
    }
end

-- Get all routes
function TradeRoute.getAllRoutes()
    local result = {}
    for routeId, _ in pairs(routes) do
        table.insert(result, TradeRoute.getRoute(routeId))
    end
    return result
end

-- Get stats
function TradeRoute.getStats()
    local count = 0
    local totalIncome = 0
    local totalRaids = 0
    for _, route in pairs(routes) do
        if route.active then
            count = count + 1
            totalIncome = totalIncome + route.incomeGenerated
            totalRaids = totalRaids + route.timesRaided
        end
    end
    return {
        activeRoutes = count,
        totalIncomeGenerated = totalIncome,
        totalRaids = totalRaids,
        nextIncomeIn = incomeInterval - incomeTimer,
    }
end

return TradeRoute
