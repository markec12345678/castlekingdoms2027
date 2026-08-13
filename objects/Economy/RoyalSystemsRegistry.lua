-- objects/Economy/RoyalSystemsRegistry.lua
-- Castle Kingdoms 2027 - Royal Systems Registry
--
-- Centralized registry that auto-discovers all "Royal X Maker" systems from
-- the global S table (set up in states/game.lua) and provides a unified API
-- for the UI panel and game hooks.
--
-- Key features:
--   * Auto-discovery: scans _G and S for tables that look like Royal systems
--     (have init/update/getStats functions)
--   * Unified stats aggregation
--   * Action dispatch: hireMaker, build, make, sell
--   * Event hook: when any system completes a product, grant bonus gold to
--     the player based on the product's prestige value (real game effect)
--   * Update loop: calls each system's update(dt) and tracks aggregate stats
--
-- Usage:
--   local Registry = require("objects.Economy.RoyalSystemsRegistry")
--   Registry.init()        -- after all S.XMaker = require(...) lines
--   Registry.update(dt)    -- in game.lua update
--   Registry.getStats()    -- for UI

local RoyalSystemsRegistry = {}

-- Discovered systems: list of { key, name, module }
local systems = {}

-- Aggregate stats
local aggregate = {
    totalSystems = 0,
    totalBuildings = 0,
    totalMakers = 0,
    totalProducts = 0,
    totalActiveMaking = 0,
    totalGoldEarned = 0,  -- bonus gold granted by registry hook
}

-- Production history: per-system list of {t, productName, qty, prestige, happiness}
-- Each entry is created when completeMaking() is hooked for that system.
-- Trimmed to last productionHistoryMaxSamples entries (or by time via API).
local productionHistory = {}  -- map: key -> list of entries
local productionHistoryMaxSamples = 300  -- ~5 minutes at 1/sec rate (but actual rate = production rate)
local productionHistoryMaxAge = 600      -- 10 minutes in seconds

-- Subscribe to all "*.completed" events published by Royal systems.
-- Each system publishes "<key>.completed" with payload {productName, prestige, happiness, ...}.
-- We grant the player bonus gold = prestige * 10 (real game effect).
local function onProductCompleted(key, payload)
    if not payload then return end
    local bonus = (payload.prestige or 0) * 10
    if bonus > 0 and _G.state then
        _G.state.gold = (_G.state.gold or 0) + bonus
        aggregate.totalGoldEarned = aggregate.totalGoldEarned + bonus
    end
end

-- Check if a table looks like a Royal Maker system
local function isRoyalSystem(t)
    if type(t) ~= "table" then return false end
    return type(t.init) == "function"
        and type(t.update) == "function"
        and type(t.getStats) == "function"
        and type(t.hireMaker) == "function"
        and type(t.build) == "function"
        and type(t.make) == "function"
end

-- Discover all Royal systems from the S table (passed in) and _G.
-- We expect S to be the local table from states/game.lua that contains all
-- S.XMaker = require("objects.Economy.RoyalXMakerSystem") entries.
-- We also scan _G for any global aliases (_G.XMaker = S.XMaker).
function RoyalSystemsRegistry.init(S)
    systems = {}
    local seen = {}
    local S_table = S or _G.S or {}

    -- Helper to register a system
    local function register(key, module)
        if seen[module] then return end
        if not isRoyalSystem(module) then return end
        seen[module] = true
        -- Derive a Slovenian-friendly display name from the key
        local display = key:gsub("Maker$", ""):gsub("([a-z])([A-Z])", "%1 %2")
        table.insert(systems, {
            key = key,
            name = display,
            module = module,
        })
    end

    -- Scan S table
    for k, v in pairs(S_table) do
        if type(k) == "string" and isRoyalSystem(v) then
            register(k, v)
        end
    end

    -- Scan _G for any global aliases
    for k, v in pairs(_G) do
        if type(k) == "string" and isRoyalSystem(v) then
            register(k, v)
        end
    end

    -- Sort alphabetically by key
    table.sort(systems, function(a, b) return a.key < b.key end)

    aggregate.totalSystems = #systems
    aggregate.totalGoldEarned = 0

    print(string.format("[RoyalSystemsRegistry] Discovered %d Royal systems", #systems))

    -- Subscribe to completion events for each system
    -- Each system publishes "<key>.completed" via _G.GameEventBus.publish
    -- Since GameEventBus requires numeric event IDs (per libraries/eventbus.lua),
    -- we instead hook directly into each system's completeMaking function
    -- via a wrapper.
    for _, sys in ipairs(systems) do
        local orig = sys.module.completeMaking
        if orig and not sys._hooked then
            sys._hooked = true
            sys.module.completeMaking = function(m)
                orig(m)
                -- Grant bonus gold to player based on prestige
                local bonus = (m.prestige or 0) * 10
                if bonus > 0 and _G.state then
                    _G.state.gold = (_G.state.gold or 0) + bonus
                    aggregate.totalGoldEarned = aggregate.totalGoldEarned + bonus
                end
                -- Also boost population cap slightly for high-happiness products
                if (m.happiness or 0) >= 5 and _G.state then
                    _G.state.popularity = math.min(100, (_G.state.popularity or 0) + 1)
                end
                -- Record production history entry for charting
                if not productionHistory[sys.key] then
                    productionHistory[sys.key] = {}
                end
                local hist = productionHistory[sys.key]
                hist[#hist + 1] = {
                    t = love.timer and love.timer.getTime() or 0,
                    productName = m.productName or m.productType or "unknown",
                    qty = m.quantity or 1,
                    prestige = m.prestige or 0,
                    happiness = m.happiness or 0,
                }
                -- Trim by sample count
                if #hist > productionHistoryMaxSamples then
                    table.remove(hist, 1)
                end
            end
        end
    end

    -- Register all Royal product types with the DynamicMarket (lazy import
    -- to avoid require cycle on startup). This makes prices dynamic.
    pcall(function()
        local RMI = require("objects.Economy.RoyalMarketIntegration")
        RMI.init()
    end)

    return RoyalSystemsRegistry
end

function RoyalSystemsRegistry.getSystems()
    return systems
end

function RoyalSystemsRegistry.getAggregate()
    return aggregate
end

-- Update all systems and aggregate stats
function RoyalSystemsRegistry.update(dt)
    aggregate.totalBuildings = 0
    aggregate.totalMakers = 0
    aggregate.totalProducts = 0
    aggregate.totalActiveMaking = 0

    for _, sys in ipairs(systems) do
        -- Update the system
        local ok, err = pcall(sys.module.update, dt)
        if not ok and _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Royal update error in " .. sys.key .. ": " .. tostring(err), "error")
        end

        -- Aggregate stats
        local stats = sys.module.getStats()
        if stats then
            aggregate.totalBuildings = aggregate.totalBuildings + (stats.numBuildings or 0)
            if stats.hasMaker then aggregate.totalMakers = aggregate.totalMakers + 1 end
            aggregate.totalProducts = aggregate.totalProducts + (stats.totalProducts or 0)
            aggregate.totalActiveMaking = aggregate.totalActiveMaking + (stats.activeMaking or 0)
        end
    end
end

-- Dispatch actions to a specific system
function RoyalSystemsRegistry.hireMaker(key, name, skill)
    local sys = nil
    for _, s in ipairs(systems) do
        if s.key == key then sys = s; break end
    end
    if not sys then return false, "Neznan sistem: " .. tostring(key) end
    return sys.module.hireMaker(name, skill)
end

function RoyalSystemsRegistry.build(key, buildingId)
    local sys = nil
    for _, s in ipairs(systems) do
        if s.key == key then sys = s; break end
    end
    if not sys then return false, "Neznan sistem: " .. tostring(key) end
    return sys.module.build(buildingId)
end

function RoyalSystemsRegistry.make(key, productId, qty)
    local sys = nil
    for _, s in ipairs(systems) do
        if s.key == key then sys = s; break end
    end
    if not sys then return false, "Neznan sistem: " .. tostring(key) end
    return sys.module.make(productId, qty)
end

-- Get a system's stats by key
function RoyalSystemsRegistry.getSystemStats(key)
    for _, s in ipairs(systems) do
        if s.key == key then
            local stats = s.module.getStats()
            stats.key = s.key
            stats.displayName = s.name
            return stats
        end
    end
    return nil
end

-- Read local upvalues (PRODUCTS, BUILDINGS) from a system module using debug API.
-- This works because each Royal system file declares:
--   local PRODUCTS = { ... }
--   local BUILDINGS = { ... }
-- at module scope, and these become upvalues of the module's functions.
local function readUpvalues(module)
    local products, buildings
    -- Try several entry points to find the upvalues
    for _, fname in ipairs({ "init", "getStats", "update", "hireMaker", "build", "make" }) do
        local fn = module[fname]
        if type(fn) == "function" then
            local i = 1
            while true do
                local ok, name, value = pcall(debug.getupvalue, fn, i)
                if not ok or not name then break end
                if name == "PRODUCTS" and type(value) == "table" then products = value end
                if name == "BUILDINGS" and type(value) == "table" then buildings = value end
                i = i + 1
                if i > 100 then break end  -- safety
            end
        end
        if products and buildings then break end
    end
    return products or {}, buildings or {}
end

-- Cache for catalogs (read once per system)
local catalogsCache = {}

function RoyalSystemsRegistry.getCatalogs(key)
    if catalogsCache[key] then return catalogsCache[key] end
    for _, s in ipairs(systems) do
        if s.key == key then
            local products, buildings = readUpvalues(s.module)
            catalogsCache[key] = {
                products = products,
                buildings = buildings,
            }
            return catalogsCache[key]
        end
    end
    return nil
end

-- Find systems that have at least one building (so player can immediately make products)
function RoyalSystemsRegistry.getActiveSystems()
    local active = {}
    for _, sys in ipairs(systems) do
        local stats = sys.module.getStats()
        if stats and (stats.numBuildings or 0) > 0 then
            table.insert(active, sys)
        end
    end
    return active
end

-- Find systems that have a maker hired
function RoyalSystemsRegistry.getSystemsHired()
    local hired = {}
    for _, sys in ipairs(systems) do
        local stats = sys.module.getStats()
        if stats and stats.hasMaker then
            table.insert(hired, sys)
        end
    end
    return hired
end

-- ============================================================================
-- SAVE / LOAD PERSISTENCE
-- ============================================================================

-- Serialize all Royal system state into a table that can be saved by bitser.
-- Only saves data that changes during gameplay (maker, buildings, stock, resources,
-- activeMaking, totalProducts, dayTimer). Static data (PRODUCTS, BUILDINGS) is
-- defined in code and doesn't need saving.
function RoyalSystemsRegistry.serialize()
    local data = {}
    data.systems = {}
    data.goldEarned = aggregate.totalGoldEarned or 0
    for _, sys in ipairs(systems) do
        local m = sys.module
        local entry = {
            key = sys.key,
            -- Maker data
            maker = nil,
            -- Buildings (list of {type=id, builtDay=timestamp})
            buildings = nil,
            -- Resource stocks
            ironStock = m.ironStock,
            bronzeStock = m.bronzeStock,
            woodStock = m.woodStock,
            leatherStock = m.leatherStock,
            silverStock = m.silverStock,
            goldStock = m.goldStock,
            jewelStock = m.jewelStock,
            pearlStock = m.pearlStock,
            -- Product stock (dict of productType -> qty)
            productStock = nil,
            -- Active making queue
            activeMaking = nil,
            -- Counters
            totalProducts = m.totalProducts or 0,
            dayTimer = m.dayTimer or 0,
        }
        -- Serialize maker (it's a table or nil)
        if m.maker then
            entry.maker = {
                name = m.maker.name,
                skill = m.maker.skill,
                hiredDay = m.maker.hiredDay,
                itemsMade = m.maker.itemsMade or 0,
            }
        end
        -- Serialize buildings (shallow copy the list)
        if m.buildings and #m.buildings > 0 then
            entry.buildings = {}
            for i, b in ipairs(m.buildings) do
                entry.buildings[i] = { type = b.type, builtDay = b.builtDay }
            end
        end
        -- Serialize productStock (shallow copy)
        if m.productStock then
            entry.productStock = {}
            for k, v in pairs(m.productStock) do
                entry.productStock[k] = v
            end
        end
        -- Serialize activeMaking (shallow copy, strip functions if any)
        if m.activeMaking and #m.activeMaking > 0 then
            entry.activeMaking = {}
            for i, am in ipairs(m.activeMaking) do
                entry.activeMaking[i] = {
                    id = am.id,
                    productType = am.productType,
                    productName = am.productName,
                    cost = am.cost,
                    quantity = am.quantity,
                    food = am.food or 0,
                    prestige = am.prestige or 0,
                    happiness = am.happiness or 0,
                    daysRemaining = am.daysRemaining,
                    started = am.started,
                }
            end
        end
        data.systems[#data.systems + 1] = entry
    end
    return data
end

-- Deserialize Royal system state from a saved table.
-- Called after all systems have been initialized (init() has run), so the
-- module references already exist — we just restore the dynamic state.
function RoyalSystemsRegistry.deserialize(data)
    if not data or not data.systems then return end

    -- Build a lookup: key -> module
    local lookup = {}
    for _, sys in ipairs(systems) do
        lookup[sys.key] = sys.module
    end

    for _, entry in ipairs(data.systems) do
        local m = lookup[entry.key]
        if not m then
            -- System key not found (maybe removed in a newer version). Skip.
            goto continue
        end

        -- Restore resource stocks
        if entry.ironStock ~= nil then m.ironStock = entry.ironStock end
        if entry.bronzeStock ~= nil then m.bronzeStock = entry.bronzeStock end
        if entry.woodStock ~= nil then m.woodStock = entry.woodStock end
        if entry.leatherStock ~= nil then m.leatherStock = entry.leatherStock end
        if entry.silverStock ~= nil then m.silverStock = entry.silverStock end
        if entry.goldStock ~= nil then m.goldStock = entry.goldStock end
        if entry.jewelStock ~= nil then m.jewelStock = entry.jewelStock end
        if entry.pearlStock ~= nil then m.pearlStock = entry.pearlStock end

        -- Restore maker
        if entry.maker then
            m.maker = {
                name = entry.maker.name,
                skill = entry.maker.skill,
                hiredDay = entry.maker.hiredDay,
                itemsMade = entry.maker.itemsMade or 0,
            }
        else
            m.maker = nil
        end

        -- Restore buildings
        if entry.buildings then
            m.buildings = {}
            for i, b in ipairs(entry.buildings) do
                m.buildings[i] = { type = b.type, builtDay = b.builtDay }
            end
        else
            m.buildings = {}
        end

        -- Restore productStock
        if entry.productStock then
            m.productStock = {}
            for k, v in pairs(entry.productStock) do
                m.productStock[k] = v
            end
        else
            m.productStock = {}
        end

        -- Restore activeMaking
        if entry.activeMaking then
            m.activeMaking = {}
            for i, am in ipairs(entry.activeMaking) do
                m.activeMaking[i] = {
                    id = am.id,
                    productType = am.productType,
                    productName = am.productName,
                    cost = am.cost,
                    quantity = am.quantity,
                    food = am.food or 0,
                    prestige = am.prestige or 0,
                    happiness = am.happiness or 0,
                    daysRemaining = am.daysRemaining,
                    started = am.started,
                }
            end
        else
            m.activeMaking = {}
        end

        -- Restore counters
        m.totalProducts = entry.totalProducts or 0
        m.dayTimer = entry.dayTimer or 0

        ::continue::
    end

    -- Restore aggregate gold earned
    if data.goldEarned then
        aggregate.totalGoldEarned = data.goldEarned
    end

    print("[RoyalSystemsRegistry] Deserialized " .. #data.systems .. " system states")
end

-- ============================================================================
-- PRODUCTION HISTORY API
-- ============================================================================

-- Get production history for a system (optionally filtered by time window)
-- @param key string System key
-- @param seconds number Optional: only return entries from last N seconds
-- @return table List of {t, productName, qty, prestige, happiness} entries
function RoyalSystemsRegistry.getProductionHistory(key, seconds)
    local hist = productionHistory[key]
    if not hist then return {} end
    if not seconds then
        -- Also filter by max age to prevent stale data
        local now = (love.timer and love.timer.getTime()) or 0
        local result = {}
        for _, e in ipairs(hist) do
            if now - e.t <= productionHistoryMaxAge then
                result[#result + 1] = e
            end
        end
        return result
    end
    local now = (love.timer and love.timer.getTime()) or 0
    local result = {}
    for _, e in ipairs(hist) do
        if now - e.t <= seconds then
            result[#result + 1] = e
        end
    end
    return result
end

-- Get production stats for a system (aggregated over time window)
-- @param key string System key
-- @param seconds number Optional window (default: 60s)
-- @return table {totalCount, totalQty, totalPrestige, avgPrestige, firstT, lastT, ratePerMin}
--         or nil if no history
function RoyalSystemsRegistry.getProductionStats(key, seconds)
    local window = seconds or 60
    local hist = RoyalSystemsRegistry.getProductionHistory(key, window)
    if #hist == 0 then return nil end

    local totalCount = #hist
    local totalQty = 0
    local totalPrestige = 0
    local totalHappiness = 0
    for _, e in ipairs(hist) do
        totalQty = totalQty + (e.qty or 1)
        totalPrestige = totalPrestige + (e.prestige or 0)
        totalHappiness = totalHappiness + (e.happiness or 0)
    end
    local avgPrestige = totalCount > 0 and (totalPrestige / totalCount) or 0
    local firstT = hist[1].t
    local lastT = hist[#hist].t
    local timeSpan = math.max(1, lastT - firstT)
    -- Rate per minute (extrapolated from window)
    local ratePerMin = (totalCount / timeSpan) * 60

    return {
        totalCount = totalCount,
        totalQty = totalQty,
        totalPrestige = totalPrestige,
        totalHappiness = totalHappiness,
        avgPrestige = avgPrestige,
        firstT = firstT,
        lastT = lastT,
        timeSpan = timeSpan,
        ratePerMin = ratePerMin,
        windowSeconds = window,
    }
end

-- Get aggregate production stats across all systems
-- @param seconds number Optional window (default: 60s)
-- @return table {systemCount, totalCount, totalQty, topSystem}
function RoyalSystemsRegistry.getAggregateProduction(seconds)
    local window = seconds or 60
    local totalCount = 0
    local totalQty = 0
    local systemsActive = 0
    local topKey, topCount = nil, 0
    for _, sys in ipairs(systems) do
        local stats = RoyalSystemsRegistry.getProductionStats(sys.key, window)
        if stats and stats.totalCount > 0 then
            systemsActive = systemsActive + 1
            totalCount = totalCount + stats.totalCount
            totalQty = totalQty + stats.totalQty
            if stats.totalCount > topCount then
                topCount = stats.totalCount
                topKey = sys.key
            end
        end
    end
    return {
        systemsActive = systemsActive,
        totalCount = totalCount,
        totalQty = totalQty,
        topSystem = topKey,
        topCount = topCount,
        windowSeconds = window,
    }
end

-- Get aggregate production history as per-second buckets across all systems.
-- Useful for charting total kingdom-wide production over time.
-- @param seconds number Optional window (default: 60s)
-- @return table { buckets = {qty=, count=} for each second, maxQty=, maxCount=, windowSeconds= }
function RoyalSystemsRegistry.getAggregateProductionHistory(seconds)
    local window = seconds or 60
    local now = (love.timer and love.timer.getTime()) or 0
    -- Initialize buckets: 1 entry per second, oldest first
    local buckets = {}
    for i = 1, window do
        buckets[i] = { qty = 0, count = 0 }
    end

    -- Iterate all systems' history, bucket by age
    for _, sys in ipairs(systems) do
        local hist = productionHistory[sys.key]
        if hist then
            for _, e in ipairs(hist) do
                local age = now - e.t
                if age >= 0 and age < window then
                    local bucketIdx = math.floor(age) + 1
                    if bucketIdx >= 1 and bucketIdx <= window then
                        buckets[bucketIdx].qty = buckets[bucketIdx].qty + (e.qty or 1)
                        buckets[bucketIdx].count = buckets[bucketIdx].count + 1
                    end
                end
            end
        end
    end

    -- Find max for scaling
    local maxQty, maxCount = 1, 1
    for _, b in ipairs(buckets) do
        if b.qty > maxQty then maxQty = b.qty end
        if b.count > maxCount then maxCount = b.count end
    end

    return {
        buckets = buckets,
        maxQty = maxQty,
        maxCount = maxCount,
        windowSeconds = window,
    }
end

-- Clear production history for a system (or all if key is nil)
function RoyalSystemsRegistry.clearProductionHistory(key)
    if key then
        productionHistory[key] = nil
    else
        productionHistory = {}
    end
end

return RoyalSystemsRegistry
