-- objects/Economy/DynamicMarketSystem.lua
-- Castle Kingdoms 2027 - Dynamic Market System
--
-- Replaces static goodsPrices with dynamic pricing based on:
-- - Supply/demand (more sellers = lower price)
-- - Seasonal modifiers (winter = expensive food)
-- - Random events (blight, gold rush)
-- - Inflation (more gold in circulation = higher prices)
-- - Trade volume (recent activity affects prices)
--
-- Usage:
--   local DynamicMarket = require("objects.Economy.DynamicMarketSystem")
--   DynamicMarket.init()
--   DynamicMarket.update(dt)
--   local price = DynamicMarket.getPrice("wood", "buy")
--   DynamicMarket.recordTransaction("wood", 50, "sell")

local basePrices = require("objects.Enums.goodsPrices")

local DynamicMarketSystem = {}

-- State
local initialized = false
local priceModifiers = {}  -- per-resource modifiers
local tradeHistory = {}    -- recent transactions for supply/demand
local inflationRate = 1.0  -- grows with gold circulation
local totalGoldInCirculation = 5000  -- starting gold amount

-- Price history (sampled every config.historySampleInterval seconds)
-- Structure: { [productType] = { {t=<seconds>, sell=<n>, buy=<n>}, ... } }
local priceHistory = {}
local priceHistorySampleTimer = 0
local priceHistoryMaxSamples = 120  -- 2 minutes at 1s sampling

-- Configuration
local config = {
    historyDuration = 60,        -- seconds to remember transactions
    supplyDemandImpact = 0.4,    -- max 40% price change from supply/demand
    seasonalImpact = 0.2,        -- max 20% price change from season
    eventImpact = 0.5,           -- max 50% price change from events
    inflationImpact = 0.3,       -- max 30% price change from inflation
    inflationRate = 0.0001,      -- 0.01% per second baseline inflation
    transactionPriceImpact = 0.01, -- each unit traded affects price by 1%
    priceRecoveryRate = 0.05,    -- prices recover 5% per second toward base
    historySampleInterval = 1.0, -- sample price history every 1 second
}

-- Initialize
function DynamicMarketSystem.init()
    if initialized then return end
    initialized = true

    -- Initialize modifiers for each resource
    for resource, _ in pairs(basePrices) do
        priceModifiers[resource] = {
            base = 1.0,
            supplyDemand = 1.0,
            seasonal = 1.0,
            event = 1.0,
            inflation = 1.0,
            current = 1.0,
        }
        tradeHistory[resource] = {}
    end

    print("[DynamicMarket] Initialized with " .. #priceModifiers .. " resources")
end

-- Get current price for a resource
-- @param resource string Resource name (e.g., "wood", "stone", "gold")
-- @param transactionType string "buy" or "sell"
-- @return number Price in gold
function DynamicMarketSystem.getPrice(resource, transactionType)
    if not initialized then DynamicMarketSystem.init() end

    local baseData = basePrices[resource]
    if not baseData then
        return 0  -- unknown resource
    end

    local basePrice = baseData.gold or 0
    local modifier = priceModifiers[resource]
    if not modifier then
        return basePrice
    end

    -- Calculate final modifier
    local finalModifier = modifier.base *
                          modifier.supplyDemand *
                          modifier.seasonal *
                          modifier.event *
                          modifier.inflation

    -- Update current for debug
    modifier.current = finalModifier

    local finalPrice = math.floor(basePrice * finalModifier + 0.5)

    -- Sell price is lower than buy price (market spread)
    if transactionType == "sell" then
        finalPrice = math.floor(finalPrice * 0.7 + 0.5)  -- 70% of buy price
    end

    -- Ensure minimum price of 1
    return math.max(1, finalPrice)
end

-- Get price modifier info for debug
function DynamicMarketSystem.getPriceInfo(resource)
    if not priceModifiers[resource] then return nil end
    return {
        resource = resource,
        base = basePrices[resource] and basePrices[resource].gold or 0,
        buy = DynamicMarketSystem.getPrice(resource, "buy"),
        sell = DynamicMarketSystem.getPrice(resource, "sell"),
        modifiers = priceModifiers[resource],
    }
end

-- Record a transaction (affects supply/demand)
-- @param resource string Resource name
-- @param quantity number Amount traded
-- @param transactionType string "buy" or "sell"
function DynamicMarketSystem.recordTransaction(resource, quantity, transactionType)
    if not initialized then return end
    if not priceModifiers[resource] then return end

    table.insert(tradeHistory[resource], {
        quantity = quantity,
        type = transactionType,
        time = love.timer.getTime(),
    })

    -- Immediately affect price
    local impact = config.transactionPriceImpact
    if transactionType == "buy" then
        -- Buying increases price
        priceModifiers[resource].supplyDemand = priceModifiers[resource].supplyDemand +
            (impact * quantity / 10)
    else
        -- Selling decreases price
        priceModifiers[resource].supplyDemand = priceModifiers[resource].supplyDemand -
            (impact * quantity / 10)
    end

    -- Clamp supplyDemand modifier
    local sd = priceModifiers[resource].supplyDemand
    local maxChange = 1 + config.supplyDemandImpact
    local minChange = 1 - config.supplyDemandImpact
    priceModifiers[resource].supplyDemand = math.max(minChange, math.min(maxChange, sd))
end

-- Update market (called every frame)
function DynamicMarketSystem.update(dt)
    if not initialized then return end

    local now = love.timer.getTime()

    -- Update each resource
    for resource, modifier in pairs(priceModifiers) do
        -- Clean up old trade history
        local history = tradeHistory[resource]
        for i = #history, 1, -1 do
            if now - history[i].time > config.historyDuration then
                table.remove(history, i)
            end
        end

        -- Calculate supply/demand from recent history
        local netDemand = 0
        for _, transaction in ipairs(history) do
            if transaction.type == "buy" then
                netDemand = netDemand + transaction.quantity
            else
                netDemand = netDemand - transaction.quantity
            end
        end

        -- Target supply/demand modifier based on net demand
        -- More demand = higher price
        local targetSD = 1.0 + math.max(-config.supplyDemandImpact,
                                        math.min(config.supplyDemandImpact,
                                                 netDemand / 100))

        -- Smoothly recover toward target
        local currentSD = modifier.supplyDemand
        modifier.supplyDemand = currentSD + (targetSD - currentSD) * config.priceRecoveryRate * dt

        -- Inflation slowly recovers toward 1.0
        modifier.inflation = modifier.inflation + (1.0 - modifier.inflation) * 0.01 * dt
    end

    -- Update global inflation (slow growth)
    inflationRate = inflationRate + config.inflationRate * dt
    if inflationRate > 1.0 + config.inflationImpact then
        inflationRate = 1.0 + config.inflationImpact
    end

    -- Apply inflation to all resources
    for _, modifier in pairs(priceModifiers) do
        modifier.inflation = inflationRate
    end

    -- Sample price history every config.historySampleInterval seconds
    priceHistorySampleTimer = priceHistorySampleTimer + dt
    if priceHistorySampleTimer >= config.historySampleInterval then
        priceHistorySampleTimer = 0
        for resource, _ in pairs(priceModifiers) do
            if not priceHistory[resource] then
                priceHistory[resource] = {}
            end
            local entry = {
                t = now,
                sell = DynamicMarketSystem.getPrice(resource, "sell"),
                buy = DynamicMarketSystem.getPrice(resource, "buy"),
            }
            local hist = priceHistory[resource]
            hist[#hist + 1] = entry
            -- Trim to max samples
            if #hist > priceHistoryMaxSamples then
                table.remove(hist, 1)
            end
        end
    end
end

-- Get price history for a product (last N seconds)
-- @param productType string Resource/product name
-- @param seconds number Optional: only return samples from last N seconds (default: all)
-- @return table List of {t, sell, buy} entries (oldest first)
function DynamicMarketSystem.getProductHistory(productType, seconds)
    if not initialized then return {} end
    local hist = priceHistory[productType]
    if not hist or #hist == 0 then return {} end
    if not seconds then return hist end
    local now = love.timer.getTime()
    local result = {}
    for _, entry in ipairs(hist) do
        if now - entry.t <= seconds then
            result[#result + 1] = entry
        end
    end
    return result
end

-- Get price history stats (min, max, avg, trend) for a product
-- @param productType string
-- @param seconds number Optional window
-- @return table {min, max, avg, current, trend} or nil if no history
function DynamicMarketSystem.getProductHistoryStats(productType, seconds)
    local hist = DynamicMarketSystem.getProductHistory(productType, seconds)
    if #hist == 0 then return nil end
    local min, max, sum = nil, nil, 0
    for _, e in ipairs(hist) do
        if min == nil or e.sell < min then min = e.sell end
        if max == nil or e.sell > max then max = e.sell end
        sum = sum + e.sell
    end
    local avg = sum / #hist
    local current = hist[#hist].sell
    local first = hist[1].sell
    local trend = current - first  -- positive = rising, negative = falling
    return {
        min = min,
        max = max,
        avg = avg,
        current = current,
        first = first,
        trend = trend,
        sampleCount = #hist,
    }
end

-- Set seasonal modifier for a resource
-- @param resource string Resource name
-- @param multiplier number Price multiplier (e.g., 1.2 for 20% more expensive)
function DynamicMarketSystem.setSeasonalModifier(resource, multiplier)
    if not priceModifiers[resource] then return end
    local maxChange = 1 + config.seasonalImpact
    local minChange = 1 - config.seasonalImpact
    priceModifiers[resource].seasonal = math.max(minChange, math.min(maxChange, multiplier))
end

-- Trigger an event modifier for a resource
-- @param resource string Resource name (or "all" for all resources)
-- @param multiplier number Price multiplier
-- @param duration number Duration in seconds
function DynamicMarketSystem.triggerEvent(resource, multiplier, duration)
    if resource == "all" then
        for res, _ in pairs(priceModifiers) do
            DynamicMarketSystem.triggerEvent(res, multiplier, duration)
        end
        return
    end

    if not priceModifiers[resource] then return end

    local maxChange = 1 + config.eventImpact
    local minChange = 1 - config.eventImpact
    local clampedMultiplier = math.max(minChange, math.min(maxChange, multiplier))

    priceModifiers[resource].event = clampedMultiplier

    -- Schedule recovery
    local startTime = love.timer.getTime()
    local originalEvent = clampedMultiplier

    -- Store the timer in a simple way (we'll check it in update)
    if not DynamicMarketSystem._eventTimers then
        DynamicMarketSystem._eventTimers = {}
    end
    table.insert(DynamicMarketSystem._eventTimers, {
        resource = resource,
        startTime = startTime,
        duration = duration or 60,
        originalMultiplier = originalEvent,
    })

    print(string.format("[DynamicMarket] Event triggered: %s price x%.2f for %ds",
        resource, clampedMultiplier, duration or 60))
end

-- Check and recover event modifiers
function DynamicMarketSystem.updateEvents()
    if not DynamicMarketSystem._eventTimers then return end

    local now = love.timer.getTime()
    for i = #DynamicMarketSystem._eventTimers, 1, -1 do
        local timer = DynamicMarketSystem._eventTimers[i]
        local elapsed = now - timer.startTime
        local progress = elapsed / timer.duration

        if progress >= 1.0 then
            -- Event ended, reset modifier
            if priceModifiers[timer.resource] then
                priceModifiers[timer.resource].event = 1.0
            end
            table.remove(DynamicMarketSystem._eventTimers, i)
        else
            -- Gradually recover toward 1.0
            if priceModifiers[timer.resource] then
                local current = timer.originalMultiplier
                local target = 1.0
                local interpolated = current + (target - current) * progress
                priceModifiers[timer.resource].event = interpolated
            end
        end
    end
end

-- Add gold to circulation (affects inflation)
function DynamicMarketSystem.addGold(amount)
    totalGoldInCirculation = totalGoldInCirculation + amount
    -- More gold = higher inflation
    local targetInflation = 1.0 + (totalGoldInCirculation / 100000) * config.inflationImpact
    targetInflation = math.min(1.0 + config.inflationImpact, targetInflation)
    inflationRate = inflationRate + (targetInflation - inflationRate) * 0.1
end

-- Remove gold from circulation
function DynamicMarketSystem.removeGold(amount)
    totalGoldInCirculation = math.max(1000, totalGoldInCirculation - amount)
end

-- Get all prices (for UI display)
function DynamicMarketSystem.getAllPrices()
    local prices = {}
    for resource, _ in pairs(basePrices) do
        prices[resource] = {
            buy = DynamicMarketSystem.getPrice(resource, "buy"),
            sell = DynamicMarketSystem.getPrice(resource, "sell"),
            modifier = priceModifiers[resource] and priceModifiers[resource].current or 1.0,
        }
    end
    return prices
end

-- Get market stats
function DynamicMarketSystem.getStats()
    local stats = {
        inflation = inflationRate,
        totalGold = totalGoldInCirculation,
        activeEvents = DynamicMarketSystem._eventTimers and #DynamicMarketSystem._eventTimers or 0,
        resourceCount = #priceModifiers,
    }

    -- Find most volatile resource
    local maxVolatility = 0
    local mostVolatile = "none"
    for resource, modifier in pairs(priceModifiers) do
        local volatility = math.abs(modifier.current - 1.0)
        if volatility > maxVolatility then
            maxVolatility = volatility
            mostVolatile = resource
        end
    end
    stats.mostVolatile = mostVolatile
    stats.maxVolatility = maxVolatility

    return stats
end

-- Reset market (for new game)
function DynamicMarketSystem.reset()
    inflationRate = 1.0
    totalGoldInCirculation = 5000
    DynamicMarketSystem._eventTimers = {}

    for resource, _ in pairs(priceModifiers) do
        priceModifiers[resource].supplyDemand = 1.0
        priceModifiers[resource].seasonal = 1.0
        priceModifiers[resource].event = 1.0
        priceModifiers[resource].inflation = 1.0
        priceModifiers[resource].current = 1.0
        tradeHistory[resource] = {}
        priceHistory[resource] = {}
    end
    priceHistorySampleTimer = 0

    print("[DynamicMarket] Reset")
end

-- Get base price (for reference)
function DynamicMarketSystem.getBasePrice(resource)
    local data = basePrices[resource]
    return data and data.gold or 0
end

-- ============================================================================
-- ROYAL PRODUCT REGISTRATION
-- ============================================================================
-- Royal Maker systems produce "luxury goods" (chalice, ornament, instrument,
-- etc.) that are not in the base goodsPrices table. We register them here
-- so the market can track supply/demand and offer dynamic prices.
-- The base price is derived from the product's "prestige" stat (prestige * 25)
-- if no explicit base price is supplied.

local royalProducts = {}  -- map: productType -> { basePrice=, source=, lastSold=, totalSold= }

function DynamicMarketSystem.registerProduct(productType, basePrice, source)
    if not productType then return end
    if royalProducts[productType] then
        -- Already registered; only update base price if explicitly given
        if basePrice and basePrice > 0 then
            royalProducts[productType].basePrice = basePrice
        end
        return
    end
    local price = basePrice
    if not price or price <= 0 then
        price = 50  -- default fallback
    end
    royalProducts[productType] = {
        basePrice = price,
        source = source or "unknown",
        lastSold = 0,
        totalSold = 0,
    }
    -- Also create a price modifier entry so supply/demand tracking works
    if not priceModifiers[productType] then
        priceModifiers[productType] = {
            base = 1.0,
            supplyDemand = 1.0,
            seasonal = 1.0,
            event = 1.0,
            inflation = 1.0,
            current = 1.0,
        }
        tradeHistory[productType] = {}
    end
end

-- Check if a product type is registered (either base or Royal)
function DynamicMarketSystem.isRegistered(productType)
    return basePrices[productType] ~= nil or royalProducts[productType] ~= nil
end

-- Get the base price for a Royal product (falls back to 0 if unknown)
function DynamicMarketSystem.getRoyalBasePrice(productType)
    local rp = royalProducts[productType]
    return rp and rp.basePrice or 0
end

-- List all registered Royal product types (for debug / UI)
function DynamicMarketSystem.listRoyalProducts()
    local list = {}
    for pt, info in pairs(royalProducts) do
        list[#list + 1] = {
            productType = pt,
            basePrice = info.basePrice,
            source = info.source,
            lastSold = info.lastSold,
            totalSold = info.totalSold,
            currentSell = DynamicMarketSystem.getPrice(pt, "sell"),
            currentBuy = DynamicMarketSystem.getPrice(pt, "buy"),
        }
    end
    table.sort(list, function(a, b) return a.productType < b.productType end)
    return list
end

-- Royal product stats (total sold, count, etc.)
function DynamicMarketSystem.getRoyalStats()
    local count = 0
    local totalSold = 0
    local totalRevenue = 0
    for pt, info in pairs(royalProducts) do
        count = count + 1
        totalSold = totalSold + (info.totalSold or 0)
        totalRevenue = totalRevenue + (info.totalRevenue or 0)
    end
    return {
        registeredProducts = count,
        totalSold = totalSold,
        totalRevenue = totalRevenue,
    }
end

-- Override getPrice so it falls back to royalProducts when basePrices lacks the key.
-- We do this by wrapping the existing function rather than rewriting it.
local _originalGetPrice = DynamicMarketSystem.getPrice
DynamicMarketSystem.getPrice = function(resource, transactionType)
    if not initialized then DynamicMarketSystem.init() end
    -- If base price is missing but Royal product exists, synthesize a price
    if not basePrices[resource] and royalProducts[resource] then
        local rp = royalProducts[resource]
        local modifier = priceModifiers[resource] or {
            base = 1.0, supplyDemand = 1.0, seasonal = 1.0, event = 1.0, inflation = 1.0, current = 1.0
        }
        local finalModifier = modifier.base * modifier.supplyDemand *
                              modifier.seasonal * modifier.event * modifier.inflation
        modifier.current = finalModifier
        local finalPrice = math.floor(rp.basePrice * finalModifier + 0.5)
        if transactionType == "sell" then
            finalPrice = math.floor(finalPrice * 0.7 + 0.5)
        end
        return math.max(1, finalPrice)
    end
    return _originalGetPrice(resource, transactionType)
end

-- Wrap recordTransaction so Royal sales update royalProducts stats
local _originalRecord = DynamicMarketSystem.recordTransaction
DynamicMarketSystem.recordTransaction = function(resource, quantity, transactionType)
    _originalRecord(resource, quantity, transactionType)
    if royalProducts[resource] and transactionType == "sell" then
        royalProducts[resource].lastSold = love.timer.getTime()
        royalProducts[resource].totalSold = (royalProducts[resource].totalSold or 0) + quantity
        -- Track revenue for stats
        local price = DynamicMarketSystem.getPrice(resource, "sell")
        royalProducts[resource].totalRevenue = (royalProducts[resource].totalRevenue or 0) + (price * quantity)
    end
end

return DynamicMarketSystem
