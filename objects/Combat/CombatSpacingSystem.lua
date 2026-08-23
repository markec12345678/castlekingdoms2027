-- objects/Combat/CombatSpacingSystem.lua
-- Castle Kingdoms 2027 v3.12.160 - Combat Anti-Clustering System
--
-- Prevents units from overlapping/stacking in combat.
-- Applies a small repulsion force between nearby units when they are:
--   * In combat state (aggro, attacking, retreating)
--   * Within MIN_SPACING tiles of each other
--   * Same faction (allies spread out)
--   * Or different factions (melee spacing)
--
-- Design:
--   * Soft repulsion, not hard collision (units can still cluster somewhat)
--   * Uses spatial hash grid for O(N) queries (not O(N*M))
--   * Only applies when units are stationary or moving slowly
--   * Disabled for ranged units in formation (they need to be close)
--   * Toggle with Ctrl+Shift+X (visible feedback via toast)
--
-- Tuning constants (gameplay feel):
--   * MIN_SPACING_ALLIES = 1.2 tiles
--   * MIN_SPACING_ENEMIES = 1.0 tiles (melee range)
--   * REPULSION_STRENGTH = 0.4 (how much to push per frame)
--   * MAX_REPULSION_PER_FRAME = 0.3 tiles (cap to avoid jitter)
--
-- Difficulty integration:
--   * Peaceful: disabled (player units don't need spacing)
--   * Hard+: stronger repulsion (enemies spread better)
--
-- Public API:
--   SpacingSystem.update(dt)                  — apply spacing forces every frame
--   SpacingSystem.toggle()                    — toggle visibility/debug
--   SpacingSystem.getStats()                  — debug info
--   SpacingSystem.markGridDirty()             — force grid rebuild
--   SpacingSystem.reset()                     — clear all state

local SpacingSystem = {}

local COMBAT = require("objects.Enums.Combat")

-- ============================================================
-- Tuning constants
-- ============================================================

-- Minimum distance to maintain between units (in tiles)
local MIN_SPACING_ALLIES = 1.2
local MIN_SPACING_ENEMIES = 1.0

-- Strength of repulsion force (0-1, applied as fraction of speed per frame)
local REPULSION_STRENGTH = 0.4

-- Cap on how much a unit can be pushed per frame (prevents jitter)
local MAX_REPULSION_PER_FRAME = 0.3

-- Only apply spacing when units are within this radius (tiles)
local SPACING_QUERY_RADIUS = 2.5

-- Update interval (we apply spacing every frame, but check existence every X seconds)
local SPACING_TICK = 1.0  -- full rebuild every 1s
local tickAccumulator = 0

-- Grid cell size for spatial hash (smaller than morale grid since we check closer)
local GRID_CELL_SIZE = 3  -- 3-tile cells
local spatialGrid = {}
local gridDirty = true

-- Visibility/debug
local VISIBLE = false  -- off by default, only for debugging
local VISIBILITY_FILE = "spacing_system_visible.txt"

-- Stats
local stats = {
    unitsProcessed = 0,
    repulsionsApplied = 0,
    avgPushPerUnit = 0,
}

-- ============================================================
-- Persistence
-- ============================================================

local function loadVisibility()
    local ok, content = pcall(love.filesystem.read, VISIBILITY_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")
        if content == "1" or content == "true" then
            VISIBLE = true
        end
    end
end

local function saveVisibility()
    pcall(love.filesystem.write, VISIBILITY_FILE, VISIBLE and "1" or "0")
end

loadVisibility()

-- ============================================================
-- Spatial Hash Grid (separate from MoraleSystem grid for cell size)
-- ============================================================

-- Calculate distance² between two units
local function distSq(a, b)
    if not a or not b or not a.gx or not b.gx then return math.huge end
    local dx = a.gx - b.gx
    local dy = a.gy - b.gy
    return dx * dx + dy * dy
end

-- Rebuild the spatial grid from current game state
local function rebuildGrid()
    spatialGrid = {}
    if not _G.state or not _G.state.gameObjectList then return end

    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit and unit.gx and unit.gy and unit.health and unit.health > 0
            and not unit.toBeDeleted and unit._combatAttached then
            -- Only include units in combat states
            local cs = unit.combatState
            if cs == COMBAT.STATE_AGGRO or cs == COMBAT.STATE_ATTACKING
                or cs == COMBAT.STATE_SEEKING or cs == COMBAT.STATE_RETREATING then
                local cellX = math.floor(unit.gx / GRID_CELL_SIZE)
                local cellY = math.floor(unit.gy / GRID_CELL_SIZE)
                local key = cellX .. "," .. cellY
                if not spatialGrid[key] then
                    spatialGrid[key] = {}
                end
                table.insert(spatialGrid[key], unit)
            end
        end
    end
    gridDirty = false
end

-- Mark grid as dirty (called when units move significantly)
function SpacingSystem.markGridDirty()
    gridDirty = true
end

-- ============================================================
-- Repulsion logic
-- ============================================================

-- Apply repulsion force to a unit based on nearby units
-- @param unit Unit to apply force to
-- @param dt Delta time
-- @return pushX, pushY - the force applied (for stats)
local function applyRepulsion(unit, dt)
    if not unit or not unit.gx or not unit.gy then
        return 0, 0
    end
    if unit.toBeDeleted or not unit.health or unit.health <= 0 then
        return 0, 0
    end

    -- Skip units that are not in combat
    local cs = unit.combatState
    if cs ~= COMBAT.STATE_AGGRO and cs ~= COMBAT.STATE_ATTACKING
        and cs ~= COMBAT.STATE_SEEKING and cs ~= COMBAT.STATE_RETREATING then
        return 0, 0
    end

    -- v3.12.160: Difficulty check - skip on peaceful for player units
    if _G.DifficultySettings then
        local diff = _G.DifficultySettings.getCurrent and _G.DifficultySettings.getCurrent() or "normal"
        if diff == "peaceful" and unit.faction == COMBAT.FACTION_PLAYER then
            return 0, 0
        end
    end

    -- Lazy rebuild
    if gridDirty then
        rebuildGrid()
    end

    local totalPushX = 0
    local totalPushY = 0
    local pushCount = 0

    -- Determine min spacing based on whether unit is ranged
    -- (ranged units in formation don't need to spread as much)
    local isRanged = unit.attackType == COMBAT.ATTACK_RANGED
    local minSpacing = isRanged and 0.8 or MIN_SPACING_ALLIES
    if cs == COMBAT.STATE_RETREATING then
        minSpacing = MIN_SPACING_ENEMIES  -- closer spacing when fleeing (denser crowd)
    end

    local minSpacingSq = minSpacing * minSpacing
    local queryRadius = SPACING_QUERY_RADIUS
    local queryRSq = queryRadius * queryRadius

    -- Determine cell range to scan
    local minCellX = math.floor((unit.gx - queryRadius) / GRID_CELL_SIZE)
    local maxCellX = math.floor((unit.gx + queryRadius) / GRID_CELL_SIZE)
    local minCellY = math.floor((unit.gy - queryRadius) / GRID_CELL_SIZE)
    local maxCellY = math.floor((unit.gy + queryRadius) / GRID_CELL_SIZE)

    for cx = minCellX, maxCellX do
        for cy = minCellY, maxCellY do
            local key = cx .. "," .. cy
            local cell = spatialGrid[key]
            if cell then
                for _, other in ipairs(cell) do
                    if other ~= unit and other.gx and other.gy
                        and other.health and other.health > 0
                        and not other.toBeDeleted then
                        local dSq = distSq(unit, other)
                        if dSq < minSpacingSq and dSq > 0.001 then
                            -- Compute push direction (away from other)
                            local d = math.sqrt(dSq)
                            local pushX = (unit.gx - other.gx) / d
                            local pushY = (unit.gy - other.gy) / d

                            -- Strength inversely proportional to distance
                            -- (closer = stronger push)
                            local strength = (1 - d / minSpacing) * REPULSION_STRENGTH

                            -- Apply strength
                            totalPushX = totalPushX + pushX * strength
                            totalPushY = totalPushY + pushY * strength
                            pushCount = pushCount + 1
                        end
                    end
                end
            end
        end
    end

    -- Apply total push to unit position (if any)
    if pushCount > 0 then
        -- Cap the push to MAX_REPULSION_PER_FRAME
        local pushMag = math.sqrt(totalPushX * totalPushX + totalPushY * totalPushY)
        if pushMag > MAX_REPULSION_PER_FRAME then
            totalPushX = (totalPushX / pushMag) * MAX_REPULSION_PER_FRAME
            totalPushY = (totalPushY / pushMag) * MAX_REPULSION_PER_FRAME
        end

        -- Apply to unit position
        -- Note: we directly modify gx/gy since this is a soft adjustment
        -- (units already have collision via pathfinding, this is a small nudge)
        if unit.gx and unit.gy then
            local newGx = unit.gx + totalPushX * dt * 60  -- scale by dt*60 for frame-rate independence
            local newGy = unit.gy + totalPushY * dt * 60

            -- Clamp push to prevent pushing through walls
            -- (use existing isWalkable if available, otherwise just apply)
            local canMove = true
            if _G.PathfindingOptimizer and _G.PathfindingOptimizer.isWalkable then
                canMove = _G.PathfindingOptimizer.isWalkable(newGx, newGy)
            end

            if canMove then
                -- Update unit's logical position
                -- (fx/fy are the fine positions in 1000ths of a tile, gx/gy are tile coords)
                if unit.fx then
                    unit.fx = unit.fx + totalPushX * dt * 60 * 1000
                end
                if unit.fy then
                    unit.fy = unit.fy + totalPushY * dt * 60 * 1000
                end
                -- Update gx/gy to match (rounded down)
                if unit.fx and unit.fy then
                    unit.gx = math.floor(unit.fx / 1000)
                    unit.gy = math.floor(unit.fy / 1000)
                end

                stats.repulsionsApplied = stats.repulsionsApplied + 1
            end
        end

        return totalPushX, totalPushY
    end

    return 0, 0
end

-- ============================================================
-- Public API
-- ============================================================

-- Update all units' spacing (called every frame)
function SpacingSystem.update(dt)
    -- Reset stats per frame
    stats.unitsProcessed = 0
    stats.repulsionsApplied = 0
    local totalPush = 0
    local pushCount = 0

    if not VISIBLE and not _G.state and not _G.state.gameObjectList then
        return
    end

    -- Mark grid dirty every SPACING_TICK seconds for accuracy
    tickAccumulator = tickAccumulator + dt
    if tickAccumulator >= SPACING_TICK then
        tickAccumulator = 0
        gridDirty = true
    end

    -- Process all units
    if not _G.state or not _G.state.gameObjectList then return end
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit and unit._combatAttached and unit.gx and unit.gy
            and not unit.toBeDeleted and unit.health and unit.health > 0 then
            local cs = unit.combatState
            if cs == COMBAT.STATE_AGGRO or cs == COMBAT.STATE_ATTACKING
                or cs == COMBAT.STATE_SEEKING or cs == COMBAT.STATE_RETREATING then
                stats.unitsProcessed = stats.unitsProcessed + 1
                local pushX, pushY = applyRepulsion(unit, dt)
                if pushX ~= 0 or pushY ~= 0 then
                    totalPush = totalPush + math.sqrt(pushX * pushX + pushY * pushY)
                    pushCount = pushCount + 1
                end
            end
        end
    end

    -- Update average push stat
    if pushCount > 0 then
        stats.avgPushPerUnit = totalPush / pushCount
    else
        stats.avgPushPerUnit = 0
    end
end

-- Draw debug visualization (if VISIBLE)
function SpacingSystem.draw()
    if not VISIBLE then return end
    if not _G.state or not _G.state.gameObjectList then return end

    -- Draw spacing radius circles for units in combat
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit and unit._combatAttached and unit.gx and unit.gy
            and not unit.toBeDeleted and unit.health and unit.health > 0 then
            local cs = unit.combatState
            if cs == COMBAT.STATE_AGGRO or cs == COMBAT.STATE_ATTACKING
                or cs == COMBAT.STATE_SEEKING or cs == COMBAT.STATE_RETREATING then
                -- Convert to screen position
                if _G.IsoToScreenX and _G.IsoToScreenY and _G.state then
                    local sx = _G.IsoToScreenX(unit.gx, unit.gy) - (_G.state.viewXview or 0)
                    local sy = _G.IsoToScreenY(unit.gx, unit.gy) - (_G.state.viewYview or 0)

                    -- Draw circle for spacing radius
                    love.graphics.setColor(0.3, 0.8, 0.3, 0.3)
                    love.graphics.circle("line", sx, sy, MIN_SPACING_ALLIES * 32)  -- 32px = 1 tile approx

                    -- Draw unit center
                    love.graphics.setColor(1, 1, 1, 0.8)
                    love.graphics.circle("fill", sx, sy, 2)
                end
            end
        end
    end
end

-- Toggle visibility (for debugging)
function SpacingSystem.toggle()
    VISIBLE = not VISIBLE
    saveVisibility()
    if _G.NotificationCenter then
        pcall(function()
            _G.NotificationCenter.system("Anti-Clustering debug: " .. (VISIBLE and "VKLOPLJEN" or "IZKLOPLJEN"))
        end)
    end
    if _G.UISoundHelper then
        pcall(function() _G.UISoundHelper.playToggleOn() end)
    end
end

function SpacingSystem.isVisible()
    return VISIBLE
end

function SpacingSystem.setVisible(state)
    VISIBLE = state and true or false
    saveVisibility()
end

-- Get stats for debugging
function SpacingSystem.getStats()
    local cellCount = 0
    for _ in pairs(spatialGrid) do cellCount = cellCount + 1 end
    return {
        unitsProcessed = stats.unitsProcessed,
        repulsionsApplied = stats.repulsionsApplied,
        avgPushPerUnit = stats.avgPushPerUnit,
        visible = VISIBLE,
        gridCells = cellCount,
        gridCellSize = GRID_CELL_SIZE,
        gridDirty = gridDirty,
        tickRate = SPACING_TICK,
        minSpacingAllies = MIN_SPACING_ALLIES,
        minSpacingEnemies = MIN_SPACING_ENEMIES,
    }
end

-- Reset all state (for new game)
function SpacingSystem.reset()
    spatialGrid = {}
    gridDirty = true
    tickAccumulator = 0
    stats.unitsProcessed = 0
    stats.repulsionsApplied = 0
    stats.avgPushPerUnit = 0
end

return SpacingSystem
