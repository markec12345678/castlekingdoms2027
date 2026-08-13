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
local perSystemRevenue = {}         -- key -> gold earned

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
end

return RoyalMarketIntegration
