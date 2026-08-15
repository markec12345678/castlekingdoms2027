-- objects/Economy/SystemDependencies.lua
-- Castle Kingdoms 2027 - Royal System Dependencies (Tech Tree)
--
-- Defines which Royal systems require other systems to be active first.
-- A system is "active" when it has at least one building built.
--
-- Dependencies are checked before:
--   * Hiring a maker (can't hire if dependencies not met)
--   * Building a workshop (can't build if dependencies not met)
--
-- The dependency graph is intentionally lightweight: most systems have no
-- dependencies (they're standalone). Only key "advanced" systems require
-- prerequisite systems, creating a natural progression:
--
--   Metalwork → BellMaker (needs metal bells)
--   Metalwork → ChainmailForger (needs metal rings)
--   Glassmaking → MirrorMaker (needs glass)
--   Pottery → Apothecary (needs ceramic vials)
--   Woodworking → Bookbinder (needs book covers)
--   etc.
--
-- Usage:
--   local Deps = require("objects.Economy.SystemDependencies")
--   local met, missing = Deps.checkDependencies(systemKey)
--   local deps = Deps.getDependencies(systemKey)
--   Deps.registerDependency("BellMaker", {"Metalwork"})

local SystemDependencies = {}

-- Dependency graph: systemKey -> list of prerequisite systemKeys
-- A prerequisite is "met" when that system has at least 1 building.
local dependencyGraph = {
    -- Metalworking chain
    BellMaker        = {"Metalwork"},
    ChainmailForger  = {"Metalwork"},
    SwordPommelMaker = {"Metalwork"},
    GauntletMaker    = {"Metalwork"},

    -- Glass chain
    MirrorMaker      = {"GlassBench"},

    -- Pottery chain
    ApothecaryMortar = {"PotteryWheel"},
    ApothecaryVial   = {"PotteryWheel"},

    -- Woodworking chain
    BookPress        = {"WoodLathe"},
    BookbindingPress = {"WoodLathe"},

    -- Textile chain
    LoomHeddle       = {"SpinningWheel"},
    TapestryLoom     = {"SpinningWheel"},
}

-- Register a dependency at runtime (for modding/extensibility)
-- @param systemKey string The system that has a dependency
-- @param prerequisites table List of systemKeys that must be active
function SystemDependencies.registerDependency(systemKey, prerequisites)
    if not systemKey or not prerequisites then return end
    dependencyGraph[systemKey] = prerequisites
end

-- Get the list of prerequisites for a system
-- @param systemKey string
-- @return table List of prerequisite systemKeys (empty if none)
function SystemDependencies.getDependencies(systemKey)
    return dependencyGraph[systemKey] or {}
end

-- Check if all dependencies for a system are met
-- @param systemKey string
-- @return boolean True if all dependencies are met (or system has no deps)
-- @return table List of unmet dependency keys (empty if all met)
function SystemDependencies.checkDependencies(systemKey)
    local deps = dependencyGraph[systemKey]
    if not deps or #deps == 0 then
        return true, {}
    end

    -- Need access to RoyalSystemsRegistry to check if prerequisite systems
    -- have buildings. Lazy require to avoid circular dependency.
    local Registry = require("objects.Economy.RoyalSystemsRegistry")
    local systems = Registry.getSystems()

    -- Build a lookup: key -> system entry
    local systemMap = {}
    for _, sys in ipairs(systems) do
        systemMap[sys.key] = sys
    end

    local unmet = {}
    for _, prereqKey in ipairs(deps) do
        local prereqSys = systemMap[prereqKey]
        if not prereqSys then
            -- Prerequisite system doesn't exist at all
            table.insert(unmet, prereqKey)
        else
            local stats = prereqSys.module.getStats()
            if not stats or (stats.numBuildings or 0) == 0 then
                table.insert(unmet, prereqKey)
            end
        end
    end

    return #unmet == 0, unmet
end

-- Get a human-readable description of dependencies for UI display
-- @param systemKey string
-- @return string Description (e.g., "Zahteva: Metalwork (✓), GlassBench (✗)")
function SystemDependencies.getDependencyDescription(systemKey)
    local deps = dependencyGraph[systemKey]
    if not deps or #deps == 0 then
        return ""
    end

    local Registry = require("objects.Economy.RoyalSystemsRegistry")
    local systems = Registry.getSystems()
    local systemMap = {}
    for _, sys in ipairs(systems) do
        systemMap[sys.key] = sys
    end

    local parts = {}
    for _, prereqKey in ipairs(deps) do
        local prereqSys = systemMap[prereqKey]
        local met = false
        if prereqSys then
            local stats = prereqSys.module.getStats()
            met = stats and (stats.numBuildings or 0) > 0
        end
        local symbol = met and "✓" or "✗"
        local display = prereqKey:gsub("Maker$", ""):gsub("([a-z])([A-Z])", "%1 %2")
        table.insert(parts, string.format("%s (%s)", display, symbol))
    end

    return "Zahteva: " .. table.concat(parts, ", ")
end

-- Check if a system HAS dependencies (used for UI badge/display)
-- @param systemKey string
-- @return boolean True if system has any dependencies
function SystemDependencies.hasDependencies(systemKey)
    local deps = dependencyGraph[systemKey]
    return deps ~= nil and #deps > 0
end

return SystemDependencies
