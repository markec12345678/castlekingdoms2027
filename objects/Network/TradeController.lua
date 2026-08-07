-- objects/Network/TradeController.lua
-- Castle Kingdoms 2027 - Trade System
--
-- Manages resource trading between players in multiplayer games:
-- - Direct trades (offer X for Y)
-- - Gift resources (one-way)
-- - Trade routes (automated recurring trades)
-- - Trade history log
--
-- Usage:
--   local TradeController = require("objects.Network.TradeController")
--   TradeController.init()
--   TradeController.update(dt)
--   TradeController.proposeTrade(targetId, offer, request)
--   TradeController.acceptTrade(tradeId)

local TradeController = {}

local trades = {}           -- Active trade proposals: {id, fromPlayer, toPlayer, offer, request, timestamp}
local tradeRoutes = {}      -- Automated recurring trades
local tradeHistory = {}     -- Completed trades log
local nextTradeId = 1
local myPlayerId = 1
local initialized = false

-- Callbacks
TradeController.onTradeProposed = nil    -- function(trade)
TradeController.onTradeAccepted = nil    -- function(trade)
TradeController.onTradeRejected = nil    -- function(trade)
TradeController.onResourcesReceived = nil -- function(fromId, resources)

-- Initialize
function TradeController.init()
    if initialized then return end
    initialized = true
    trades = {}
    tradeRoutes = {}
    tradeHistory = {}
    nextTradeId = 1
    print("[TradeController] Initialized")
end

-- Set my player ID
function TradeController.setMyPlayerId(id)
    myPlayerId = id
end

function TradeController.getMyPlayerId()
    return myPlayerId
end

-- Propose a trade to another player
-- @param targetId number Target player ID
-- @param offer table Resources I'm offering {wood=100, stone=50}
-- @param request table Resources I want {gold=200}
-- @return number tradeId
function TradeController.proposeTrade(targetId, offer, request)
    if targetId == myPlayerId then return nil end

    local tradeId = nextTradeId
    nextTradeId = nextTradeId + 1

    local trade = {
        id = tradeId,
        fromPlayer = myPlayerId,
        toPlayer = targetId,
        offer = offer or {},
        request = request or {},
        timestamp = os.time(),
        status = "pending",
    }

    trades[tradeId] = trade
    print(string.format("[TradeController] Trade #%d proposed to player %d", tradeId, targetId))

    if TradeController.onTradeProposed then
        TradeController.onTradeProposed(trade)
    end

    return tradeId
end

-- Accept a trade proposal
function TradeController.acceptTrade(tradeId)
    local trade = trades[tradeId]
    if not trade then return false end
    if trade.toPlayer ~= myPlayerId then return false end  -- Not addressed to me
    if trade.status ~= "pending" then return false end

    -- Verify both players have resources
    if not _G.state or not _G.state.resources then return false end

    -- Check if I (receiver) have the requested resources
    for resourceType, amount in pairs(trade.request) do
        local available = _G.state.resources[resourceType] or 0
        if available < amount then
            print(string.format("[TradeController] Not enough %s to accept trade", resourceType))
            return false
        end
    end

    -- Execute trade (local part - deduct what I'm giving)
    for resourceType, amount in pairs(trade.request) do
        _G.state.resources[resourceType] = (_G.state.resources[resourceType] or 0) - amount
    end

    -- Add what I'm receiving
    for resourceType, amount in pairs(trade.offer) do
        _G.state.resources[resourceType] = (_G.state.resources[resourceType] or 0) + amount
    end

    trade.status = "accepted"
    trade.completedTime = os.time()

    -- Add to history
    table.insert(tradeHistory, {
        id = trade.id,
        fromPlayer = trade.fromPlayer,
        toPlayer = trade.toPlayer,
        offer = trade.offer,
        request = trade.request,
        timestamp = trade.timestamp,
        completedTime = trade.completedTime,
        status = "accepted",
    })

    print(string.format("[TradeController] Trade #%d accepted", tradeId))

    if TradeController.onTradeAccepted then
        TradeController.onTradeAccepted(trade)
    end

    if TradeController.onResourcesReceived then
        TradeController.onResourcesReceived(trade.fromPlayer, trade.offer)
    end

    return true
end

-- Reject a trade proposal
function TradeController.rejectTrade(tradeId)
    local trade = trades[tradeId]
    if not trade then return false end
    if trade.toPlayer ~= myPlayerId then return false end

    trade.status = "rejected"
    trade.completedTime = os.time()

    print(string.format("[TradeController] Trade #%d rejected", tradeId))

    if TradeController.onTradeRejected then
        TradeController.onTradeRejected(trade)
    end

    return true
end

-- Cancel a trade (by proposer)
function TradeController.cancelTrade(tradeId)
    local trade = trades[tradeId]
    if not trade then return false end
    if trade.fromPlayer ~= myPlayerId then return false end
    if trade.status ~= "pending" then return false end

    trade.status = "cancelled"
    trade.completedTime = os.time()

    print(string.format("[TradeController] Trade #%d cancelled", tradeId))
    return true
end

-- Gift resources to another player (one-way)
function TradeController.giftResources(targetId, resources)
    if targetId == myPlayerId then return false end
    if not _G.state or not _G.state.resources then return false end

    -- Verify resources
    for resourceType, amount in pairs(resources) do
        local available = _G.state.resources[resourceType] or 0
        if available < amount then
            print(string.format("[TradeController] Not enough %s for gift", resourceType))
            return false
        end
    end

    -- Deduct resources
    for resourceType, amount in pairs(resources) do
        _G.state.resources[resourceType] = _G.state.resources[resourceType] - amount
    end

    print(string.format("[TradeController] Gift sent to player %d", targetId))

    -- Add to history
    table.insert(tradeHistory, {
        fromPlayer = myPlayerId,
        toPlayer = targetId,
        offer = resources,
        request = {},
        timestamp = os.time(),
        completedTime = os.time(),
        status = "gift",
    })

    if TradeController.onResourcesReceived then
        TradeController.onResourcesReceived(myPlayerId, resources)
    end

    return true
end

-- Create a trade route (automated recurring trade)
-- @param targetId number Target player
-- @param offer table Resources I send
-- @param request table Resources I receive
-- @param interval number Seconds between trades
-- @return number routeId
function TradeController.createTradeRoute(targetId, offer, request, interval)
    if targetId == myPlayerId then return nil end

    local routeId = #tradeRoutes + 1
    tradeRoutes[routeId] = {
        id = routeId,
        fromPlayer = myPlayerId,
        toPlayer = targetId,
        offer = offer,
        request = request,
        interval = interval or 60,  -- Default: every 60 seconds
        lastTradeTime = 0,
        active = true,
    }

    print(string.format("[TradeController] Trade route #%d created with player %d (interval: %ds)",
        routeId, targetId, interval or 60))
    return routeId
end

-- Cancel a trade route
function TradeController.cancelTradeRoute(routeId)
    if not tradeRoutes[routeId] then return false end
    tradeRoutes[routeId].active = false
    print(string.format("[TradeController] Trade route #%d cancelled", routeId))
    return true
end

-- Get pending trades (addressed to me)
function TradeController.getPendingTrades()
    local pending = {}
    for _, trade in pairs(trades) do
        if trade.toPlayer == myPlayerId and trade.status == "pending" then
            table.insert(pending, trade)
        end
    end
    return pending
end

-- Get my proposed trades
function TradeController.getMyProposedTrades()
    local proposed = {}
    for _, trade in pairs(trades) do
        if trade.fromPlayer == myPlayerId and trade.status == "pending" then
            table.insert(proposed, trade)
        end
    end
    return proposed
end

-- Get trade history
function TradeController.getHistory()
    return tradeHistory
end

-- Get active trade routes
function TradeController.getTradeRoutes()
    return tradeRoutes
end

-- Update (called every frame)
function TradeController.update(dt)
    -- Process trade routes
    local now = os.time()
    for _, route in pairs(tradeRoutes) do
        if route.active and route.fromPlayer == myPlayerId then
            if now - route.lastTradeTime >= route.interval then
                -- Check if we still have resources
                local canTrade = true
                if _G.state and _G.state.resources then
                    for resourceType, amount in pairs(route.offer) do
                        if (_G.state.resources[resourceType] or 0) < amount then
                            canTrade = false
                            break
                        end
                    end
                end

                if canTrade then
                    TradeController.proposeTrade(route.toPlayer, route.offer, route.request)
                    route.lastTradeTime = now
                end
            end
        end
    end

    -- Clean up old completed trades (keep last 50)
    while #tradeHistory > 50 do
        table.remove(tradeHistory, 1)
    end
end

-- Reset (for new game)
function TradeController.reset()
    trades = {}
    tradeRoutes = {}
    tradeHistory = {}
    nextTradeId = 1
    print("[TradeController] Reset")
end

return TradeController
