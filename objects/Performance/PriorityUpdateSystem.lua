-- objects/Performance/PriorityUpdateSystem.lua
-- Castle Kingdoms 2027 - Tiered Entity Update System
--
-- Instead of updating every entity every frame (60Hz), entities are
-- assigned to priority tiers:
--
--   HIGH (60 Hz):   Player-controlled, combat-active units
--   MEDIUM (10 Hz): Workers, recently moved units
--   LOW (2 Hz):     Idle civilians, distant AI units
--
-- This reduces update load significantly when many entities exist.
--
-- Usage:
--   local PriorityUpdate = require("objects.Performance.PriorityUpdateSystem")
--   PriorityUpdate.init()
--   PriorityUpdate.registerEntity(unit, "high")
--   PriorityUpdate.update(dt)  -- in game loop

local PriorityUpdateSystem = {}

-- Update frequencies (Hz)
local TIERS = {
    high = {
        frequency = 60,  -- every frame
        interval = 1/60,
        description = "Player units, combat-active",
    },
    medium = {
        frequency = 10,  -- 10 times per second
        interval = 1/10,
        description = "Workers, recently moved",
    },
    low = {
        frequency = 2,   -- 2 times per second
        interval = 1/2,
        description = "Idle civilians, distant AI",
    },
}

-- State
local initialized = false
local enabled = true

-- Entity registry: tier -> list of entities
local entities = {
    high = {},
    medium = {},
    low = {},
}

-- Timers for each tier
local timers = {
    high = 0,
    medium = 0,
    low = 0,
}

-- Stats
local stats = {
    totalEntities = 0,
    updatesThisFrame = 0,
    skippedThisFrame = 0,
    highCount = 0,
    mediumCount = 0,
    lowCount = 0,
}

-- Initialize
function PriorityUpdateSystem.init()
    if initialized then return end
    initialized = true
    print("[PriorityUpdate] Initialized - tiers: high(60Hz), medium(10Hz), low(2Hz)")
end

function PriorityUpdateSystem.setEnabled(state)
    enabled = state
end

-- Register an entity with a priority tier
-- @param entity table The entity to register (must have update method)
-- @param tier string "high", "medium", or "low"
function PriorityUpdateSystem.registerEntity(entity, tier)
    if not TIERS[tier] then
        print("[PriorityUpdate] Invalid tier: " .. tostring(tier))
        return false
    end

    -- Remove from previous tier if exists
    PriorityUpdateSystem.unregisterEntity(entity)

    entity._updateTier = tier
    table.insert(entities[tier], entity)
    stats.totalEntities = stats.totalEntities + 1
    return true
end

-- Unregister an entity
function PriorityUpdateSystem.unregisterEntity(entity)
    if not entity._updateTier then return end
    local tier = entity._updateTier
    for i, e in ipairs(entities[tier]) do
        if e == entity then
            table.remove(entities[tier], i)
            stats.totalEntities = stats.totalEntities - 1
            break
        end
    end
    entity._updateTier = nil
end

-- Change entity's tier (e.g., when combat starts, move to high)
function PriorityUpdateSystem.setTier(entity, newTier)
    if not TIERS[newTier] then return false end
    if entity._updateTier == newTier then return true end
    return PriorityUpdateSystem.registerEntity(entity, newTier)
end

-- Auto-assign tier based on entity state
function PriorityUpdateSystem.autoAssignTier(entity)
    -- Player-controlled units: always high
    if entity.playerControlled then
        return PriorityUpdateSystem.setTier(entity, "high")
    end

    -- Combat-active units: high
    if entity.combatState and entity.combatState ~= "idle" and entity.combatState ~= "dead" then
        return PriorityUpdateSystem.setTier(entity, "high")
    end

    -- Recently moved units: medium
    if entity.moveDir and entity.moveDir ~= "none" then
        return PriorityUpdateSystem.setTier(entity, "medium")
    end

    -- Workers (have a job): medium
    if entity.workplace or entity.job then
        return PriorityUpdateSystem.setTier(entity, "medium")
    end

    -- Everything else (idle civilians, distant AI): low
    return PriorityUpdateSystem.setTier(entity, "low")
end

-- Update all entities based on their tier
-- @param dt number Delta time
function PriorityUpdateSystem.update(dt)
    if not enabled or not initialized then return end

    stats.updatesThisFrame = 0
    stats.skippedThisFrame = 0

    -- HIGH tier: always update
    timers.high = timers.high + dt
    if timers.high >= TIERS.high.interval then
        timers.high = 0
        for _, entity in ipairs(entities.high) do
            if not entity.toBeDeleted and entity.update then
                entity:update(dt)
                stats.updatesThisFrame = stats.updatesThisFrame + 1
            end
        end
    end

    -- MEDIUM tier: update every 100ms
    timers.medium = timers.medium + dt
    if timers.medium >= TIERS.medium.interval then
        local mediumDt = timers.medium  -- use accumulated time
        timers.medium = 0
        for _, entity in ipairs(entities.medium) do
            if not entity.toBeDeleted and entity.update then
                entity:update(mediumDt)
                stats.updatesThisFrame = stats.updatesThisFrame + 1
            end
        end
    else
        stats.skippedThisFrame = stats.skippedThisFrame + #entities.medium
    end

    -- LOW tier: update every 500ms
    timers.low = timers.low + dt
    if timers.low >= TIERS.low.interval then
        local lowDt = timers.low
        timers.low = 0
        for _, entity in ipairs(entities.low) do
            if not entity.toBeDeleted and entity.update then
                entity:update(lowDt)
                stats.updatesThisFrame = stats.updatesThisFrame + 1
            end
        end
    else
        stats.skippedThisFrame = stats.skippedThisFrame + #entities.low
    end

    -- Update counts
    stats.highCount = #entities.high
    stats.mediumCount = #entities.medium
    stats.lowCount = #entities.low
end

-- Cleanup dead entities
function PriorityUpdateSystem.cleanup()
    for tier, list in pairs(entities) do
        for i = #list, 1, -1 do
            if list[i].toBeDeleted or not list[i].health or list[i].health <= 0 then
                table.remove(list, i)
                stats.totalEntities = stats.totalEntities - 1
            end
        end
    end
end

-- Get stats
function PriorityUpdateSystem.getStats()
    return {
        total = stats.totalEntities,
        high = stats.highCount,
        medium = stats.mediumCount,
        low = stats.lowCount,
        updatesThisFrame = stats.updatesThisFrame,
        skippedThisFrame = stats.skippedThisFrame,
        -- How much work we saved this frame
        savingsPercent = stats.totalEntities > 0
            and (stats.skippedThisFrame / (stats.totalEntities + stats.skippedThisFrame)) * 100
            or 0,
    }
end

-- Reset
function PriorityUpdateSystem.reset()
    entities = { high = {}, medium = {}, low = {} }
    timers = { high = 0, medium = 0, low = 0 }
    stats.totalEntities = 0
    print("[PriorityUpdate] Reset")
end

return PriorityUpdateSystem
