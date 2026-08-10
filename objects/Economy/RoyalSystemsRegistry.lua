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
            end
        end
    end

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

return RoyalSystemsRegistry
