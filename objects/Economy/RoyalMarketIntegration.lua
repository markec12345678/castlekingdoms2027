-- objects/Economy/RoyalMarketIntegration.lua
-- Castle Kingdoms 2027 - Royal Market Integration
--
-- Bridges Royal Maker systems with the DynamicMarketSystem.
--
-- Responsibilities:
--   1. On init(), scan all Royal systems' PRODUCTS catalogs and register each
--      product type with DynamicMarketSystem.registerProduct(). Base price is
--      derived from each product's "cost" field (or prestige * 25 fallback).
--   2. Provide sellStock(key, productType?) — sells stock of one system
--      (or one product) at current market price, records the transaction,
--      and grants gold to the player.
--   3. Provide autoSell(dt) — runs in the registry update loop; every
--      autoSellInterval seconds, sells all stocked Royal products at current
--      market prices. This makes Royal systems passive income generators
--      once they have stock + a maker.
--   4. Track aggregate market revenue per system and overall.
--
-- Usage:
--   local RMI = require("objects.Economy.RoyalMarketIntegration")
--   RMI.init()         -- after RoyalSystemsRegistry.init()
--   RMI.setAutoSell(true)
--   RMI.update(dt)     -- in game.lua update (after RoyalRegistry.update)
--   RMI.sellStock("GlassMaker")  -- manual sell

local DynamicMarket = require("objects.Economy.DynamicMarketSystem")
local RoyalRegistry = require("objects.Economy.RoyalSystemsRegistry")

local RoyalMarketIntegration = {}

-- State
local initialized = false
local autoSellEnabled = false       -- off by default; player toggles via panel
local autoSellInterval = 30.0       -- seconds between auto-sell sweeps
local autoSellTimer = 0.0
local aggregateRevenue = 0          -- total gold earned from Royal sales
local perSystemRevenue = {}         -- key -> gold earned (cumulative)

-- Sales history (per-system list of {t, productType, qty, gold, unitPrice})
-- Used for profit leaderboards and revenue charts.
local salesHistory = {}             -- map: key -> list of entries
local salesHistoryMaxSamples = 300  -- per-system cap (~5 min at 1/s rate)
local salesHistoryMaxAge = 600      -- 10 minutes in seconds

-- Per-product sales history (aggregated across all systems).
-- Used for per-product revenue charts in Market Dashboard.
-- Structure: { [productType] = { {t=<s>, qty=<n>, gold=<n>, unitPrice=<n>}, ... } }
local productSalesHistory = {}
local productSalesHistoryMaxSamples = 300  -- per-product cap
local productSalesHistoryMaxAge = 600      -- 10 minutes

-- Configuration
local config = {
    -- When auto-selling, products with very low price (crashed market) are
    -- held back until price recovers. This is the minimum sell price as a
    -- fraction of the registered base price (0.4 = 40% of base).
    minAutoSellFraction = 0.4,
    -- Maximum units of one product type to auto-sell per sweep (prevents
    -- market flooding which would crash prices).
    maxPerSweep = 20,
}

-- Internal: record a sale in the sales history for charts/leaderboards
-- @param key string System key
-- @param productType string Product type sold
-- @param qty number Units sold
-- @param gold number Total gold earned
-- @param unitPrice number Price per unit
local function recordSale(key, productType, qty, gold, unitPrice)
    if not key or not productType or qty <= 0 then return end
    local now = (love.timer and love.timer.getTime()) or 0
    -- Per-system history
    if not salesHistory[key] then salesHistory[key] = {} end
    local hist = salesHistory[key]
    hist[#hist + 1] = {
        t = now,
        productType = productType,
        qty = qty,
        gold = gold,
        unitPrice = unitPrice,
    }
    -- Trim by sample count
    if #hist > salesHistoryMaxSamples then
        table.remove(hist, 1)
    end
    -- Per-product history (aggregated)
    if not productSalesHistory[productType] then
        productSalesHistory[productType] = {}
    end
    local phist = productSalesHistory[productType]
    phist[#phist + 1] = {
        t = now,
        qty = qty,
        gold = gold,
        unitPrice = unitPrice,
    }
    if #phist > productSalesHistoryMaxSamples then
        table.remove(phist, 1)
    end
end

-- Initialize: register all Royal product types with the DynamicMarket
function RoyalMarketIntegration.init()
    if initialized then return end
    initialized = true

    -- Ensure DynamicMarket is initialized
    DynamicMarket.init()

    local systems = RoyalRegistry.getSystems()
    local registered = 0
    for _, sys in ipairs(systems) do
        local catalogs = RoyalRegistry.getCatalogs(sys.key)
        if catalogs and catalogs.products then
            for _, product in ipairs(catalogs.products) do
                local pt = product.type or product.id
                if pt then
                    -- Base price: prefer product.cost, fall back to prestige*25
                    local basePrice = product.cost or ((product.prestige or 1) * 25)
                    DynamicMarket.registerProduct(pt, basePrice, sys.key)
                    registered = registered + 1
                end
            end
        end
        perSystemRevenue[sys.key] = 0
    end

    print(string.format("[RoyalMarketIntegration] Registered %d Royal product types from %d systems",
        registered, #systems))
end

-- Toggle auto-sell on/off
function RoyalMarketIntegration.setAutoSell(enabled)
    autoSellEnabled = enabled and true or false
    print("[RoyalMarketIntegration] Auto-sell " .. (autoSellEnabled and "ENABLED" or "DISABLED"))
end

function RoyalMarketIntegration.isAutoSellEnabled()
    return autoSellEnabled
end

function RoyalMarketIntegration.setAutoSellInterval(seconds)
    autoSellInterval = math.max(5, tonumber(seconds) or 30)
end

function RoyalMarketIntegration.getAutoSellInterval()
    return autoSellInterval
end

-- Sell all stock of one system (manual action from panel)
-- @param key string System key (e.g., "GlassMaker")
-- @return totalGold earned, totalUnits sold, productsSold count
function RoyalMarketIntegration.sellStock(key)
    if not initialized then RoyalMarketIntegration.init() end

    local sysStats = RoyalRegistry.getSystemStats(key)
    if not sysStats then return 0, 0, 0 end

    -- Access the module directly to read productStock
    local systems = RoyalRegistry.getSystems()
    local module
    for _, s in ipairs(systems) do
        if s.key == key then module = s.module; break end
    end
    if not module or not module.productStock then return 0, 0, 0 end

    local totalGold = 0
    local totalUnits = 0
    local productsSold = 0

    for productType, qty in pairs(module.productStock) do
        if qty > 0 then
            local price = DynamicMarket.getPrice(productType, "sell")
            if price > 0 then
                local gold = price * qty
                totalGold = totalGold + gold
                totalUnits = totalUnits + qty
                productsSold = productsSold + 1
                -- Grant gold to player
                if _G.state then
                    _G.state.gold = (_G.state.gold or 0) + gold
                end
                -- Record transaction (affects future prices)
                DynamicMarket.recordTransaction(productType, qty, "sell")
                -- Record sale in history (for profit leaderboards/charts)
                recordSale(key, productType, qty, gold, price)
                -- Clear stock
                module.productStock[productType] = 0
            end
        end
    end

    if totalGold > 0 then
        aggregateRevenue = aggregateRevenue + totalGold
        perSystemRevenue[key] = (perSystemRevenue[key] or 0) + totalGold
        -- Add gold to circulation (affects inflation)
        DynamicMarket.addGold(totalGold)
    end

    return totalGold, totalUnits, productsSold
end

-- Sell a single product type from a system (manual action)
function RoyalMarketIntegration.sellProduct(key, productType, qty)
    if not initialized then RoyalMarketIntegration.init() end
    local systems = RoyalRegistry.getSystems()
    local module
    for _, s in ipairs(systems) do
        if s.key == key then module = s.module; break end
    end
    if not module or not module.productStock then return 0, 0 end

    local available = module.productStock[productType] or 0
    local toSell = math.min(available, qty or available)
    if toSell <= 0 then return 0, 0 end

    local price = DynamicMarket.getPrice(productType, "sell")
    if price <= 0 then return 0, 0 end

    local gold = price * toSell
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + gold
    end
    DynamicMarket.recordTransaction(productType, toSell, "sell")
    recordSale(key, productType, toSell, gold, price)
    module.productStock[productType] = available - toSell

    aggregateRevenue = aggregateRevenue + gold
    perSystemRevenue[key] = (perSystemRevenue[key] or 0) + gold
    DynamicMarket.addGold(gold)

    return gold, toSell
end

-- Auto-sell sweep: iterate all systems, sell stocked products up to maxPerSweep
-- per product type, but only if the current sell price is above the minimum
-- threshold (don't dump everything when prices are crashed).
local function autoSellSweep()
    local systems = RoyalRegistry.getSystems()
    local totalGold = 0
    local totalUnits = 0

    for _, sys in ipairs(systems) do
        local m = sys.module
        if m and m.productStock then
            for productType, qty in pairs(m.productStock) do
                if qty > 0 then
                    local price = DynamicMarket.getPrice(productType, "sell")
                    local basePrice = DynamicMarket.getRoyalBasePrice(productType)
                    if basePrice > 0 and price >= basePrice * config.minAutoSellFraction then
                        local toSell = math.min(qty, config.maxPerSweep)
                        local gold = price * toSell
                        if _G.state then
                            _G.state.gold = (_G.state.gold or 0) + gold
                        end
                        DynamicMarket.recordTransaction(productType, toSell, "sell")
                        recordSale(sys.key, productType, toSell, gold, price)
                        m.productStock[productType] = qty - toSell
                        totalGold = totalGold + gold
                        totalUnits = totalUnits + toSell
                        perSystemRevenue[sys.key] = (perSystemRevenue[sys.key] or 0) + gold
                    end
                end
            end
        end
    end

    if totalGold > 0 then
        aggregateRevenue = aggregateRevenue + totalGold
        DynamicMarket.addGold(totalGold)
    end

    return totalGold, totalUnits
end

-- Update: called from game.lua update loop
function RoyalMarketIntegration.update(dt)
    if not initialized then return end
    if not autoSellEnabled then return end

    autoSellTimer = autoSellTimer + dt
    if autoSellTimer >= autoSellInterval then
        autoSellTimer = 0
        local gold, units = autoSellSweep()
        if gold > 0 and _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Royal market: sold %d units for %d gold", units, gold),
                "info")
        end
    end
end

-- Get aggregate revenue
function RoyalMarketIntegration.getRevenue()
    return aggregateRevenue
end

-- Get per-system revenue (key -> gold earned)
function RoyalMarketIntegration.getPerSystemRevenue()
    return perSystemRevenue
end

-- Get the current sell price for a product type (convenience wrapper)
function RoyalMarketIntegration.getPrice(productType)
    return DynamicMarket.getPrice(productType, "sell")
end

-- Get market info for a specific product type
function RoyalMarketIntegration.getProductInfo(productType)
    local basePrice = DynamicMarket.getRoyalBasePrice(productType)
    if basePrice == 0 then return nil end
    return {
        productType = productType,
        basePrice = basePrice,
        sellPrice = DynamicMarket.getPrice(productType, "sell"),
        buyPrice = DynamicMarket.getPrice(productType, "buy"),
    }
end

-- Get all stats for UI display
function RoyalMarketIntegration.getStats()
    return {
        autoSellEnabled = autoSellEnabled,
        autoSellInterval = autoSellInterval,
        aggregateRevenue = aggregateRevenue,
        registeredProducts = DynamicMarket.getRoyalStats().registeredProducts,
        totalSold = DynamicMarket.getRoyalStats().totalSold,
        marketStats = DynamicMarket.getStats(),
    }
end

-- Reset (for new game)
function RoyalMarketIntegration.reset()
    aggregateRevenue = 0
    autoSellTimer = 0
    autoSellEnabled = false
    for k, _ in pairs(perSystemRevenue) do
        perSystemRevenue[k] = 0
    end
    salesHistory = {}
    productSalesHistory = {}
end

-- ============================================================================
-- SALES HISTORY API (for profit leaderboards and revenue charts)
-- ============================================================================

-- Get sales history for a system (optionally filtered by time window)
-- @param key string System key
-- @param seconds number Optional: only return entries from last N seconds
-- @return table List of {t, productType, qty, gold, unitPrice} entries
function RoyalMarketIntegration.getSalesHistory(key, seconds)
    local hist = salesHistory[key]
    if not hist then return {} end
    local now = (love.timer and love.timer.getTime()) or 0
    if not seconds then
        -- Filter by max age
        local result = {}
        for _, e in ipairs(hist) do
            if now - e.t <= salesHistoryMaxAge then
                result[#result + 1] = e
            end
        end
        return result
    end
    local result = {}
    for _, e in ipairs(hist) do
        if now - e.t <= seconds then
            result[#result + 1] = e
        end
    end
    return result
end

-- Get revenue stats for a system (aggregated over time window)
-- @param key string System key
-- @param seconds number Optional window (default: 60s)
-- @return table {totalGold, totalQty, saleCount, avgUnitPrice, firstT, lastT, goldPerMin}
--         or nil if no history
function RoyalMarketIntegration.getRevenueStats(key, seconds)
    local window = seconds or 60
    local hist = RoyalMarketIntegration.getSalesHistory(key, window)
    if #hist == 0 then return nil end

    local totalGold = 0
    local totalQty = 0
    for _, e in ipairs(hist) do
        totalGold = totalGold + (e.gold or 0)
        totalQty = totalQty + (e.qty or 0)
    end
    local avgUnitPrice = totalQty > 0 and (totalGold / totalQty) or 0
    local firstT = hist[1].t
    local lastT = hist[#hist].t
    local timeSpan = math.max(1, lastT - firstT)
    local goldPerMin = (totalGold / timeSpan) * 60

    return {
        totalGold = totalGold,
        totalQty = totalQty,
        saleCount = #hist,
        avgUnitPrice = avgUnitPrice,
        firstT = firstT,
        lastT = lastT,
        timeSpan = timeSpan,
        goldPerMin = goldPerMin,
        windowSeconds = window,
    }
end

-- Get top-N most profitable systems in the time window.
-- @param count number Optional: how many to return (default: 10)
-- @param seconds number Optional window (default: 60s)
-- @return table List of {key, name, totalGold, totalQty, saleCount, avgUnitPrice, goldPerMin}
--                 sorted descending by totalGold
function RoyalMarketIntegration.getTopProfitProducers(count, seconds)
    local n = count or 10
    local window = seconds or 60
    local systems = RoyalRegistry.getSystems()
    local list = {}
    for _, sys in ipairs(systems) do
        local stats = RoyalMarketIntegration.getRevenueStats(sys.key, window)
        if stats and stats.totalGold > 0 then
            list[#list + 1] = {
                key = sys.key,
                name = sys.name,
                totalGold = stats.totalGold,
                totalQty = stats.totalQty,
                saleCount = stats.saleCount,
                avgUnitPrice = stats.avgUnitPrice,
                goldPerMin = stats.goldPerMin,
            }
        end
    end
    -- Sort by totalGold descending
    table.sort(list, function(a, b) return a.totalGold > b.totalGold end)
    -- Trim to top N
    local result = {}
    for i = 1, math.min(n, #list) do
        result[i] = list[i]
    end
    return result
end

-- Get aggregate revenue stats across all systems in window
-- @param seconds number Optional window (default: 60s)
-- @return table {systemsActive, totalGold, totalQty, saleCount, topSystem, topGold}
function RoyalMarketIntegration.getAggregateRevenue(seconds)
    local window = seconds or 60
    local totalGold = 0
    local totalQty = 0
    local saleCount = 0
    local systemsActive = 0
    local topKey, topGold = nil, 0
    local systems = RoyalRegistry.getSystems()
    for _, sys in ipairs(systems) do
        local stats = RoyalMarketIntegration.getRevenueStats(sys.key, window)
        if stats and stats.totalGold > 0 then
            systemsActive = systemsActive + 1
            totalGold = totalGold + stats.totalGold
            totalQty = totalQty + stats.totalQty
            saleCount = saleCount + stats.saleCount
            if stats.totalGold > topGold then
                topGold = stats.totalGold
                topKey = sys.key
            end
        end
    end
    return {
        systemsActive = systemsActive,
        totalGold = totalGold,
        totalQty = totalQty,
        saleCount = saleCount,
        topSystem = topKey,
        topGold = topGold,
        windowSeconds = window,
    }
end

-- ============================================================================
-- PER-PRODUCT SALES HISTORY API (for revenue charts in Market Dashboard)
-- ============================================================================

-- Get sales history for a specific product type (aggregated across all systems)
-- @param productType string
-- @param seconds number Optional: only return entries from last N seconds
-- @return table List of {t, qty, gold, unitPrice} entries (oldest first)
function RoyalMarketIntegration.getProductSalesHistory(productType, seconds)
    local hist = productSalesHistory[productType]
    if not hist or #hist == 0 then return {} end
    local now = (love.timer and love.timer.getTime()) or 0
    local maxAge = seconds or productSalesHistoryMaxAge
    local result = {}
    for _, e in ipairs(hist) do
        if now - e.t <= maxAge then
            result[#result + 1] = e
        end
    end
    return result
end

-- Get per-product sales history as per-second buckets (qty and gold).
-- Useful for revenue bar/line charts over time.
-- @param productType string
-- @param seconds number Optional window (default: 60s)
-- @return table { buckets={qty=, gold=, count=}, maxQty=, maxGold=, totalGold=,
--                 totalQty=, avgUnitPrice=, windowSeconds= }
function RoyalMarketIntegration.getProductSalesBuckets(productType, seconds)
    local window = seconds or 60
    local hist = RoyalMarketIntegration.getProductSalesHistory(productType, window)
    -- Initialize buckets: 1 per second
    local buckets = {}
    for i = 1, window do
        buckets[i] = { qty = 0, gold = 0, count = 0 }
    end
    local now = (love.timer and love.timer.getTime()) or 0
    for _, e in ipairs(hist) do
        local age = now - e.t
        if age >= 0 and age < window then
            local idx = math.floor(age) + 1
            if idx >= 1 and idx <= window then
                buckets[idx].qty = buckets[idx].qty + (e.qty or 0)
                buckets[idx].gold = buckets[idx].gold + (e.gold or 0)
                buckets[idx].count = buckets[idx].count + 1
            end
        end
    end
    -- Find max for scaling + totals
    local maxQty, maxGold = 1, 1
    local totalQty, totalGold = 0, 0
    for _, b in ipairs(buckets) do
        if b.qty > maxQty then maxQty = b.qty end
        if b.gold > maxGold then maxGold = b.gold end
        totalQty = totalQty + b.qty
        totalGold = totalGold + b.gold
    end
    local avgUnitPrice = totalQty > 0 and (totalGold / totalQty) or 0
    return {
        buckets = buckets,
        maxQty = maxQty,
        maxGold = maxGold,
        totalQty = totalQty,
        totalGold = totalGold,
        avgUnitPrice = avgUnitPrice,
        windowSeconds = window,
    }
end

-- ============================================================================
-- SAVE / LOAD PERSISTENCE
-- ============================================================================

-- Serialize auto-sell state for saving.
-- Saves: autoSellEnabled, autoSellInterval, aggregateRevenue, perSystemRevenue
-- Note: salesHistory and productSalesHistory are NOT saved (they're transient
-- 60s-window data; would bloat save files for no benefit).
function RoyalMarketIntegration.serialize()
    -- Copy perSystemRevenue to a plain table (in case of metatables)
    local psrCopy = {}
    for k, v in pairs(perSystemRevenue) do
        psrCopy[k] = v
    end
    return {
        autoSellEnabled = autoSellEnabled,
        autoSellInterval = autoSellInterval,
        aggregateRevenue = aggregateRevenue,
        perSystemRevenue = psrCopy,
    }
end

-- Deserialize auto-sell state from a saved table.
-- Called after RMI has been initialized (init() has run).
function RoyalMarketIntegration.deserialize(data)
    if not data then return end
    if type(data.autoSellEnabled) == "boolean" then
        autoSellEnabled = data.autoSellEnabled
    end
    if type(data.autoSellInterval) == "number" and data.autoSellInterval >= 5 then
        autoSellInterval = data.autoSellInterval
    end
    if type(data.aggregateRevenue) == "number" then
        aggregateRevenue = data.aggregateRevenue
    end
    if type(data.perSystemRevenue) == "table" then
        -- Merge into existing perSystemRevenue (init may have already set keys to 0)
        for k, v in pairs(data.perSystemRevenue) do
            if type(v) == "number" then
                perSystemRevenue[k] = v
            end
        end
    end
    -- Reset auto-sell timer so it doesn't immediately fire on load
    autoSellTimer = 0
    print(string.format("[RoyalMarketIntegration] Deserialized: autoSell=%s, interval=%.1fs, revenue=%d",
        tostring(autoSellEnabled), autoSellInterval, aggregateRevenue))
end

return RoyalMarketIntegration
