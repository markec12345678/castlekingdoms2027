-- objects/Combat/CombatMoraleSystem.lua
-- Castle Kingdoms 2027 v3.12.156 - Combat Morale System
--
-- Adds a "morale" mechanic to combat. When a unit's faction takes casualties
-- or faces overwhelming odds, individual units may:
--   * Lose morale and fight less effectively (damage penalty)
--   * Break and flee (run away from combat)
--   * Rally back when conditions improve
--
-- Design philosophy (matches Stronghold / Total War morale systems):
--   * Casualties reduce morale (visible to player via morale bar)
--   * Outnumbered units lose morale (ratio-based)
--   * Low health units lose morale (personal survival fear)
--   * Nearby allies boost morale (cohesion)
--   * Lord/Hero nearby boosts morale (leadership)
--   * Being attacked from flank/rear reduces morale (positional)
--
-- Difficulty integration (v3.12.133+):
--   * Peaceful: player units never flee (AI still does)
--   * Easy: player flee threshold lower (40% instead of 25%)
--   * Normal: standard
--   * Hard: enemy flee threshold lower (AI flees less)
--   * Brutal: enemy never flees (player still does)
--
-- Public API:
--   MoraleSystem.update(dt)                          — call every frame
--   MoraleSystem.getMorale(unit)                     — 0-100, current morale
--   MoraleSystem.isFleeing(unit)                     — true if fleeing
--   MoraleSystem.applyStress(unit, amount, source)   — reduce morale
--   MoraleSystem.applyRally(unit, amount, source)    — boost morale
--   MoraleSystem.rallyNearbyUnits(x, y, radius)      — AoE rally (Lord ability)
--   MoraleSystem.getMoraleBar(unit)                  — {x, y, w, h, frac} for UI
--   MoraleSystem.draw()                              — draw morale bars (HUD)
--   MoraleSystem.toggle()                            — toggle visibility (Ctrl+Shift+M)
--   MoraleSystem.reset()                             — clear all tracked units

local MoraleSystem = {}

local COMBAT = require("objects.Enums.Combat")

-- ============================================================
-- Constants & Tuning
-- ============================================================

-- Morale thresholds (0-100 scale, 100 = full morale, 0 = broken)
local MORALE_FULL = 100
local MORALE_HIGH = 75       -- Above: normal combat effectiveness
local MORALE_WAVERING = 50   -- Above: small damage penalty; Below: visible warning
local MORALE_SHAKEN = 35     -- Below: significant damage penalty
local MORALE_BREAKING = 25   -- Below: high chance to flee each tick
local MORALE_BROKEN = 10     -- Below: definitely fleeing
local MORALE_ROUTED = 0      -- Routing (running at full speed away)

-- Damage effectiveness multipliers based on morale
local DAMAGE_MULT_FULL = 1.0      -- 75-100 morale: full damage
local DAMAGE_MULT_WAVERING = 0.85 -- 50-75: -15% damage
local DAMAGE_MULT_SHAKEN = 0.65   -- 25-50: -35% damage
local DAMAGE_MULT_BREAKING = 0.40 -- 10-25: -60% damage
local DAMAGE_MULT_BROKEN = 0.20   -- 0-10: -80% damage

-- Stress events (how much morale each event costs)
local STRESS_DEATH_NEARBY = -8       -- Ally dies within 5 tiles
local STRESS_DEATH_SELF_LOW_HP = -15 -- Personal HP below 25%
local STRESS_OUTNUMBERED = -3       -- Per enemy in 8-tile radius over ally count (per tick, scaled)
local STRESS_FLANKED = -10          -- Attacked from side/rear
local STRESS_SURROUNDED = -12       -- 3+ enemies within 2 tiles
local STRESS_ALLY_FLEEING = -5     -- Ally within 5 tiles is fleeing
local STRESS_NO_COMMANDER = -2      -- No Lord within 15 tiles (per tick, scaled)

-- Rally events (how much morale each event gives)
local RALLY_HEAL = 5                -- Healing received
local RALLY_KILL_NEARBY = 3         -- Ally got a kill within 5 tiles
local RALLY_LORD_NEARBY = 2         -- Lord within 15 tiles (per tick, scaled)
local RALLY_ALLY_DENSITY = 1        -- Per ally in 5-tile radius over enemy count (per tick, scaled)
local RALLY_OUT_OF_COMBAT = 8      -- Per second when no enemy within 10 tiles
local RALLY_FORMATION_BONUS = 3    -- In formation with allies

-- Tick rate (morale updates every X seconds for performance)
local MORALE_TICK = 0.5  -- 2 updates per second per unit
local moraleAccumulator = 0

-- Flee behavior
local FLEE_SPEED_MULT = 1.4   -- Fleeing units move 40% faster
local FLEE_DURATION = 4.0     -- Min seconds of fleeing before rally attempt
local FLEE_DISTANCE = 20     -- Tiles to run before rally attempt

-- Visibility
local VISIBLE = true
local VISIBILITY_FILE = "morale_system_visible.txt"

-- Per-unit state tracking
-- Map: unit → { morale, isFleeing, fleeTimer, fleeStartX, fleeStartY, lastStress, lastRally }
local unitStates = {}

-- Cache of dead units to clean up
local unitsToRemove = {}

-- ============================================================
-- Persistence
-- ============================================================

local function loadVisibility()
    local ok, content = pcall(love.filesystem.read, VISIBILITY_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")
        if content == "0" or content == "false" then
            VISIBLE = false
        end
    end
end

local function saveVisibility()
    pcall(love.filesystem.write, VISIBILITY_FILE, VISIBLE and "1" or "0")
end

loadVisibility()

-- ============================================================
-- Public API
-- ============================================================

-- Get or initialize morale state for a unit
local function getOrCreateState(unit)
    if not unit then return nil end
    if not unitStates[unit] then
        unitStates[unit] = {
            morale = MORALE_FULL,
            isFleeing = false,
            fleeTimer = 0,
            fleeStartX = unit.gx or 0,
            fleeStartY = unit.gy or 0,
            lastStress = 0,
            lastRally = 0,
            damageMult = 1.0,
        }
    end
    return unitStates[unit]
end

-- Get current morale (0-100)
function MoraleSystem.getMorale(unit)
    local state = unitStates[unit]
    if not state then return MORALE_FULL end
    return state.morale
end

-- Is the unit currently fleeing?
function MoraleSystem.isFleeing(unit)
    local state = unitStates[unit]
    return state and state.isFleeing or false
end

-- Get damage multiplier based on morale (used by CombatComponent)
function MoraleSystem.getDamageMultiplier(unit)
    local state = unitStates[unit]
    if not state then return DAMAGE_MULT_FULL end
    if state.isFleeing then return 0 end  -- Fleeing units can't attack
    return state.damageMult
end

-- Apply stress (negative morale change)
-- @param unit Unit to affect
-- @param amount Negative number (e.g., -10 reduces morale by 10)
-- @param source String describing source (for logging): "death", "outnumbered", "flanked", "low_hp", "ally_fleeing"
function MoraleSystem.applyStress(unit, amount, source)
    if not unit then return end
    -- Skip dead units
    if unit.toBeDeleted or (unit.health and unit.health <= 0) then
        return
    end
    -- Skip peaceful mode for player units
    if _G.DifficultySettings then
        local diff = _G.DifficultySettings.getCurrent and _G.DifficultySettings.getCurrent() or "normal"
        if diff == "peaceful" and unit.faction == COMBAT.FACTION_PLAYER then
            return  -- No stress for player on peaceful
        end
    end
    local state = getOrCreateState(unit)
    state.morale = math.max(0, state.morale + amount)
    state.lastStress = os.clock()
end

-- Apply rally (positive morale change)
-- @param unit Unit to affect
-- @param amount Positive number (e.g., +5 boosts morale by 5)
-- @param source String: "heal", "kill", "lord", "ally_density", "out_of_combat", "formation"
function MoraleSystem.applyRally(unit, amount, source)
    if not unit then return end
    if unit.toBeDeleted or (unit.health and unit.health <= 0) then
        return
    end
    local state = getOrCreateState(unit)
    state.morale = math.min(MORALE_FULL, state.morale + amount)
    state.lastRally = os.clock()
end

-- AoE rally (Lord's ability)
function MoraleSystem.rallyNearbyUnits(x, y, radius, amount)
    if not x or not y or not radius then return 0 end
    amount = amount or 25  -- default +25 morale
    local count = 0
    for unit, state in pairs(unitStates) do
        if unit and unit.gx and unit.gy and not unit.toBeDeleted then
            local dx = unit.gx - x
            local dy = unit.gy - y
            local distSq = dx * dx + dy * dy
            if distSq <= radius * radius then
                MoraleSystem.applyRally(unit, amount, "lord_rally")
                count = count + 1
                -- Cancel fleeing
                if state.isFleeing then
                    state.isFleeing = false
                    state.fleeTimer = 0
                end
            end
        end
    end
    -- Show toast notification
    if _G.NotificationCenter and count > 0 then
        pcall(function() _G.NotificationCenter.combat(string.format("Lord rally: %d enot okrepčenih", count)) end)
    end
    return count
end

-- ============================================================
-- v3.12.158: Spatial Hash Grid for performance optimization
-- Reduces O(N*M) neighbor queries to O(N) via spatial bucketing
-- ============================================================

-- Calculate distance² between two units (defined early, used by all queries)
local function distSq(a, b)
    if not a or not b or not a.gx or not b.gx then return math.huge end
    local dx = a.gx - b.gx
    local dy = a.gy - b.gy
    return dx * dx + dy * dy
end

-- Grid cell size (tiles). Larger = fewer cells but more entries per cell.
-- Optimal: roughly equal to the largest query radius (8 tiles for outnumbered check)
local GRID_CELL_SIZE = 8
local spatialGrid = {}  -- key = "cellX,cellY", value = { unit1, unit2, ... }
local gridDirty = true  -- set true when units move (rebuild on next query)

-- Rebuild the spatial grid from current game state
local function rebuildGrid()
    spatialGrid = {}
    if not _G.state or not _G.state.gameObjectList then return end

    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit and unit.gx and unit.gy and unit.health and unit.health > 0
            and not unit.toBeDeleted and unit._combatAttached then
            local cellX = math.floor(unit.gx / GRID_CELL_SIZE)
            local cellY = math.floor(unit.gy / GRID_CELL_SIZE)
            local key = cellX .. "," .. cellY
            if not spatialGrid[key] then
                spatialGrid[key] = {}
            end
            table.insert(spatialGrid[key], unit)
        end
    end
    gridDirty = false
end

-- Mark grid as dirty (called when units move significantly)
-- For performance, we just rebuild on next query rather than incrementally updating
function MoraleSystem.markGridDirty()
    gridDirty = true
end

-- Query nearby units using spatial grid (much faster than full scan)
-- @param unit Unit to query around
-- @param radius number Search radius in tiles
-- @return allies count, enemies count
local function countNearbyOptimized(unit, radius)
    if not unit or not unit.gx or not unit.gy then
        return 0, 0
    end

    if gridDirty then
        rebuildGrid()
    end

    local allies = 0
    local enemies = 0
    local rSq = radius * radius

    -- Determine cell range to scan
    local minCellX = math.floor((unit.gx - radius) / GRID_CELL_SIZE)
    local maxCellX = math.floor((unit.gx + radius) / GRID_CELL_SIZE)
    local minCellY = math.floor((unit.gy - radius) / GRID_CELL_SIZE)
    local maxCellY = math.floor((unit.gy + radius) / GRID_CELL_SIZE)

    -- Iterate over all cells that could contain units within radius
    for cx = minCellX, maxCellX do
        for cy = minCellY, maxCellY do
            local key = cx .. "," .. cy
            local cell = spatialGrid[key]
            if cell then
                for _, obj in ipairs(cell) do
                    if obj ~= unit then
                        local d = distSq(unit, obj)
                        if d <= rSq then
                            if obj.faction == unit.faction then
                                allies = allies + 1
                            elseif obj.faction and obj.faction ~= COMBAT.FACTION_NEUTRAL then
                                enemies = enemies + 1
                            end
                        end
                    end
                end
            end
        end
    end

    return allies, enemies
end

-- Find nearest enemy using spatial grid
-- @param unit Unit
-- @return nearest enemy unit, or nil
local function findNearestEnemyOptimized(unit, maxRadius)
    if not unit or not unit.gx or not unit.gy then return nil end
    maxRadius = maxRadius or 30  -- default 30 tile search

    if gridDirty then
        rebuildGrid()
    end

    local nearest = nil
    local nearestDist = math.huge
    local maxRSq = maxRadius * maxRadius

    -- Spiral search: start at unit's cell, expand outward
    local unitCellX = math.floor(unit.gx / GRID_CELL_SIZE)
    local unitCellY = math.floor(unit.gy / GRID_CELL_SIZE)
    local maxCellOffset = math.ceil(maxRadius / GRID_CELL_SIZE)

    for dx = -maxCellOffset, maxCellOffset do
        for dy = -maxCellOffset, maxCellOffset do
            local key = (unitCellX + dx) .. "," .. (unitCellY + dy)
            local cell = spatialGrid[key]
            if cell then
                for _, obj in ipairs(cell) do
                    if obj ~= unit and obj.faction and obj.faction ~= unit.faction
                        and obj.faction ~= COMBAT.FACTION_NEUTRAL
                        and obj.health and obj.health > 0
                        and not obj.toBeDeleted then
                        local d = distSq(unit, obj)
                        if d <= maxRSq and d < nearestDist then
                            nearestDist = d
                            nearest = obj
                        end
                    end
                end
            end
        end
    end

    return nearest
end

-- ============================================================
-- Internal update logic
-- ============================================================

-- Count nearby units (allies and enemies) for a given unit
-- v3.12.158: Uses spatial grid (was O(N*M), now ~O(N))
local function countNearby(unit, radius, faction)
    return countNearbyOptimized(unit, radius)
end

-- Check if Lord/Hero is nearby
-- v3.12.158: Uses spatial grid
local function hasCommanderNearby(unit, radius)
    if not unit or not unit.gx or not unit.gy then
        return false
    end

    if gridDirty then
        rebuildGrid()
    end

    local rSq = radius * radius
    local minCellX = math.floor((unit.gx - radius) / GRID_CELL_SIZE)
    local maxCellX = math.floor((unit.gx + radius) / GRID_CELL_SIZE)
    local minCellY = math.floor((unit.gy - radius) / GRID_CELL_SIZE)
    local maxCellY = math.floor((unit.gy + radius) / GRID_CELL_SIZE)

    for cx = minCellX, maxCellX do
        for cy = minCellY, maxCellY do
            local key = cx .. "," .. cy
            local cell = spatialGrid[key]
            if cell then
                for _, obj in ipairs(cell) do
                    if obj ~= unit and obj.faction == unit.faction then
                        if obj.className == "Lord" or obj.className == "HeroUnit" or obj.isHero then
                            if distSq(unit, obj) <= rSq then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

-- Check if any nearby ally is fleeing
local function hasFleeingAllyNearby(unit, radius)
    if not unit or not unit.gx then return false end
    local rSq = radius * radius
    for ally, state in pairs(unitStates) do
        if ally ~= unit and ally.faction == unit.faction and state.isFleeing then
            if distSq(unit, ally) <= rSq then
                return true
            end
        end
    end
    return false
end

-- Per-unit tick: calculate stress/rally delta
local function tickUnit(unit, state, dt)
    if not unit or unit.toBeDeleted or (unit.health and unit.health <= 0) then
        return
    end

    -- Skip peaceful player units
    local isPeacefulPlayer = false
    if _G.DifficultySettings then
        local diff = _G.DifficultySettings.getCurrent and _G.DifficultySettings.getCurrent() or "normal"
        if diff == "peaceful" and unit.faction == COMBAT.FACTION_PLAYER then
            isPeacefulPlayer = true
        end
    end
    if isPeacefulPlayer then
        state.morale = MORALE_FULL
        state.isFleeing = false
        state.damageMult = DAMAGE_MULT_FULL
        return
    end

    -- Personal HP check
    if unit.health and unit.maxHealth and unit.health > 0 then
        local hpPct = unit.health / unit.maxHealth
        if hpPct < 0.25 then
            MoraleSystem.applyStress(unit, STRESS_DEATH_SELF_LOW_HP * dt, "low_hp")
        end
    end

    -- Count allies and enemies nearby
    local alliesNear, enemiesNear = countNearby(unit, 8, unit.faction)

    -- Outnumbered (more enemies than allies within 8 tiles)
    if enemiesNear > alliesNear then
        local diff = enemiesNear - alliesNear
        MoraleSystem.applyStress(unit, STRESS_OUTNUMBERED * diff * dt, "outnumbered")
    elseif alliesNear > enemiesNear then
        -- Surplus of allies = small rally
        local surplus = alliesNear - enemiesNear
        MoraleSystem.applyRally(unit, RALLY_ALLY_DENSITY * surplus * dt, "ally_density")
    end

    -- Surrounded (3+ enemies within 2 tiles)
    local _, closeEnemies = countNearby(unit, 2, unit.faction)
    if closeEnemies >= 3 then
        MoraleSystem.applyStress(unit, STRESS_SURROUNDED * dt, "surrounded")
    end

    -- No commander nearby
    if not hasCommanderNearby(unit, 15) then
        MoraleSystem.applyStress(unit, STRESS_NO_COMMANDER * dt, "no_commander")
    else
        MoraleSystem.applyRally(unit, RALLY_LORD_NEARBY * dt, "lord_nearby")
    end

    -- Ally fleeing nearby
    if hasFleeingAllyNearby(unit, 5) then
        MoraleSystem.applyStress(unit, STRESS_ALLY_FLEEING * dt, "ally_fleeing")
    end

    -- Out of combat (no enemy within 10 tiles) = recovery
    local _, farEnemies = countNearby(unit, 10, unit.faction)
    if farEnemies == 0 then
        MoraleSystem.applyRally(unit, RALLY_OUT_OF_COMBAT * dt, "out_of_combat")
        -- Cancel fleeing if we're safe
        if state.isFleeing and state.fleeTimer > FLEE_DURATION then
            state.isFleeing = false
            state.fleeTimer = 0
        end
    end

    -- Update damage multiplier based on current morale
    if state.morale >= MORALE_HIGH then
        state.damageMult = DAMAGE_MULT_FULL
    elseif state.morale >= MORALE_WAVERING then
        state.damageMult = DAMAGE_MULT_WAVERING
    elseif state.morale >= MORALE_SHAKEN then
        state.damageMult = DAMAGE_MULT_SHAKEN
    elseif state.morale >= MORALE_BREAKING then
        state.damageMult = DAMAGE_MULT_BREAKING
    else
        state.damageMult = DAMAGE_MULT_BROKEN
    end

    -- Check flee conditions
    if not state.isFleeing and state.morale <= MORALE_BREAKING then
        -- Brutal AI never flees
        if _G.DifficultySettings then
            local diff = _G.DifficultySettings.getCurrent and _G.DifficultySettings.getCurrent() or "normal"
            if diff == "brutal" and unit.faction ~= COMBAT.FACTION_PLAYER then
                return  -- AI never flees on brutal
            end
        end
        -- Random chance to start fleeing (higher when morale is lower)
        local fleeChance = (MORALE_BREAKING - state.morale) / MORALE_BREAKING * 0.5  -- up to 50% per tick
        if math.random() < fleeChance then
            state.isFleeing = true
            state.fleeTimer = 0
            state.fleeStartX = unit.gx or 0
            state.fleeStartY = unit.gy or 0
            state.lastFleeOrderTime = 0  -- v3.12.159: track when we last issued move order
            -- v3.12.159: Boost walk speed for fleeing units
            if not state.originalStraightSpeed and unit.straightWalkSpeed then
                state.originalStraightSpeed = unit.straightWalkSpeed
                state.originalDiagonalSpeed = unit.diagonalWalkSpeed
                unit.straightWalkSpeed = unit.straightWalkSpeed * FLEE_SPEED_MULT
                unit.diagonalWalkSpeed = unit.diagonalWalkSpeed * FLEE_SPEED_MULT
            end
            -- Notify game systems
            if _G.NotificationCenter and unit.faction == COMBAT.FACTION_PLAYER then
                pcall(function() _G.NotificationCenter.combat("Enota beži!") end)
            end
            if _G.GameFeel then
                pcall(function() _G.GameFeel.onUnitFlee(unit) end)
            end
            -- Set combat state to retreating
            if unit.combatState then
                unit.combatState = COMBAT.STATE_RETREATING
            end
        end
    end

    -- Fleeing behavior
    if state.isFleeing then
        state.fleeTimer = state.fleeTimer + dt
        -- Mark unit as retreating for movement system
        if unit.combatState then
            unit.combatState = COMBAT.STATE_RETREATING
        end

        -- v3.12.159: Periodically issue flee move order (every 0.5s)
        -- Move AWAY from nearest enemy
        state.lastFleeOrderTime = (state.lastFleeOrderTime or 0) + dt
        if state.lastFleeOrderTime >= 0.5 and unit.gx and unit.gy then
            state.lastFleeOrderTime = 0
            -- Find nearest enemy using optimized spatial grid query
            local nearestEnemy = findNearestEnemyOptimized(unit, 15)
            if nearestEnemy and nearestEnemy.gx and nearestEnemy.gy then
                -- Compute flee direction (away from enemy)
                local dx = unit.gx - nearestEnemy.gx
                local dy = unit.gy - nearestEnemy.gy
                local len = math.sqrt(dx * dx + dy * dy)
                if len > 0 then
                    -- Flee 10 tiles in opposite direction
                    local fleeX = math.floor(unit.gx + (dx / len) * 10)
                    local fleeY = math.floor(unit.gy + (dy / len) * 10)
                    -- Clamp to map bounds (assume 0-200 range)
                    fleeX = math.max(5, math.min(195, fleeX))
                    fleeY = math.max(5, math.min(195, fleeY))
                    -- Issue move order (clear current target first)
                    unit.target = nil
                    if unit.gotoUserWaypoint then
                        pcall(function() unit:gotoUserWaypoint(fleeX, fleeY, nil, nil) end)
                    end
                end
            else
                -- No enemy nearby - move towards safer position (rally point or original position)
                -- Just stop fleeing if no enemy within 15 tiles
                if state.fleeTimer >= FLEE_DURATION then
                    state.isFleeing = false
                    state.fleeTimer = 0
                    -- v3.12.159: Restore original walk speed
                    if state.originalStraightSpeed and unit.straightWalkSpeed then
                        unit.straightWalkSpeed = state.originalStraightSpeed
                        unit.diagonalWalkSpeed = state.originalDiagonalSpeed
                        state.originalStraightSpeed = nil
                        state.originalDiagonalSpeed = nil
                    end
                    if unit.combatState then
                        unit.combatState = COMBAT.STATE_IDLE
                    end
                end
            end
        end

        -- Check if unit has fled far enough
        if unit.gx and unit.gy then
            local dx = unit.gx - state.fleeStartX
            local dy = unit.gy - state.fleeStartY
            local fledDist = math.sqrt(dx * dx + dy * dy)
            if fledDist >= FLEE_DISTANCE and state.fleeTimer >= FLEE_DURATION then
                -- Attempt to rally
                if state.morale >= MORALE_WAVERING then
                    state.isFleeing = false
                    state.fleeTimer = 0
                    -- v3.12.159: Restore original walk speed on rally
                    if state.originalStraightSpeed and unit.straightWalkSpeed then
                        unit.straightWalkSpeed = state.originalStraightSpeed
                        unit.diagonalWalkSpeed = state.originalDiagonalSpeed
                        state.originalStraightSpeed = nil
                        state.originalDiagonalSpeed = nil
                    end
                    if unit.combatState then
                        unit.combatState = COMBAT.STATE_IDLE
                    end
                end
            end
        end
    end
end

-- Update all tracked units
function MoraleSystem.update(dt)
    if not VISIBLE and next(unitStates) == nil then
        return  -- Skip if invisible and no units
    end
    moraleAccumulator = moraleAccumulator + dt
    if moraleAccumulator < MORALE_TICK then
        return
    end
    moraleAccumulator = 0

    -- v3.12.158: Mark grid dirty before tick (units have moved since last tick)
    gridDirty = true

    -- Tick all units
    for unit, state in pairs(unitStates) do
        if unit and not unit.toBeDeleted and unit.health and unit.health > 0 then
            tickUnit(unit, state, MORALE_TICK)
        else
            -- Mark dead units for cleanup
            unitsToRemove[unit] = true
        end
    end

    -- Cleanup dead units
    for unit in pairs(unitsToRemove) do
        unitStates[unit] = nil
        unitsToRemove[unit] = nil
    end
end

-- ============================================================
-- Event handlers (called by CombatComponent)
-- ============================================================

-- Called when ANY unit dies (via CombatComponent.takeDamage)
function MoraleSystem.onUnitDeath(deadUnit, attacker)
    if not deadUnit or not deadUnit.gx then return end

    -- Apply stress to nearby allies of the dead unit
    if not _G.state or not _G.state.gameObjectList then return end
    local radius = 5
    local rSq = radius * radius

    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj ~= deadUnit and obj.gx and obj.faction == deadUnit.faction
            and obj.health and obj.health > 0 and not obj.toBeDeleted then
            local dx = obj.gx - deadUnit.gx
            local dy = obj.gy - deadUnit.gy
            if dx * dx + dy * dy <= rSq then
                MoraleSystem.applyStress(obj, STRESS_DEATH_NEARBY, "death_nearby")
            end
        end
    end

    -- Apply rally to nearby allies of the attacker (kill = boost)
    if attacker and attacker.gx and attacker.faction then
        local arSq = radius * radius
        for _, obj in ipairs(_G.state.gameObjectList) do
            if obj ~= attacker and obj.gx and obj.faction == attacker.faction
                and obj.health and obj.health > 0 and not obj.toBeDeleted then
                local dx = obj.gx - attacker.gx
                local dy = obj.gy - attacker.gy
                if dx * dx + dy * dy <= arSq then
                    MoraleSystem.applyRally(obj, RALLY_KILL_NEARBY, "kill_nearby")
                end
            end
        end
    end
end

-- Called when a unit takes damage (CombatComponent.takeDamage)
function MoraleSystem.onUnitDamaged(unit, damage, attacker)
    if not unit then return end
    -- Apply stress proportional to damage taken
    local stress = -math.min(10, damage * 0.3)
    MoraleSystem.applyStress(unit, stress, "damaged")
end

-- Called when a unit is healed
function MoraleSystem.onUnitHealed(unit, amount)
    if not unit then return end
    MoraleSystem.applyRally(unit, RALLY_HEAL, "heal")
end

-- ============================================================
-- UI / HUD
-- ============================================================

-- Get morale bar dimensions for a unit (for UI drawing)
function MoraleSystem.getMoraleBar(unit)
    if not unit then return nil end
    local state = unitStates[unit]
    if not state or not unit.gx or not unit.gy then return nil end

    -- Convert world position to screen position
    if not _G.IsoToScreenX or not _G.IsoToScreenY then return nil end
    local sx = _G.IsoToScreenX(unit.gx, unit.gy) - (_G.state.viewXview or 0)
    local sy = _G.IsoToScreenY(unit.gx, unit.gy) - (_G.state.viewYview or 0)

    return {
        x = sx - 15,
        y = sy - 30,  -- Above the unit
        w = 30,
        h = 3,
        frac = state.morale / MORALE_FULL,
        morale = state.morale,
        isFleeing = state.isFleeing,
    }
end

-- Draw morale bars for all visible units
function MoraleSystem.draw()
    if not VISIBLE then return end
    if not _G.state or not _G.state.gameObjectList then return end

    -- Only draw morale bars for units that are below FULL morale or fleeing
    for unit, state in pairs(unitStates) do
        if unit and unit.gx and unit.gy and not unit.toBeDeleted
            and unit.health and unit.health > 0
            and (state.morale < MORALE_HIGH or state.isFleeing) then
            local bar = MoraleSystem.getMoraleBar(unit)
            if bar then
                -- Determine color based on morale
                local r, g, b, a
                if state.isFleeing then
                    r, g, b, a = 1, 0.2, 0.2, 1  -- Bright red (fleeing)
                elseif state.morale >= MORALE_HIGH then
                    r, g, b, a = 0.3, 0.9, 0.3, 0  -- Green (hidden, full morale)
                elseif state.morale >= MORALE_WAVERING then
                    r, g, b, a = 0.9, 0.85, 0.3, 1  -- Yellow (wavering)
                elseif state.morale >= MORALE_SHAKEN then
                    r, g, b, a = 0.95, 0.6, 0.2, 1  -- Orange (shaken)
                else
                    r, g, b, a = 1, 0.3, 0.2, 1  -- Red (breaking/broken)
                end

                if a > 0 then
                    -- Background
                    love.graphics.setColor(0, 0, 0, 0.7)
                    love.graphics.rectangle("fill", bar.x - 1, bar.y - 1, bar.w + 2, bar.h + 2)
                    -- Fill
                    love.graphics.setColor(r, g, b, a)
                    love.graphics.rectangle("fill", bar.x, bar.y, bar.w * bar.frac, bar.h)
                    -- Border
                    love.graphics.setColor(0, 0, 0, 0.9)
                    love.graphics.setLineWidth(1)
                    love.graphics.rectangle("line", bar.x, bar.y, bar.w, bar.h)
                    love.graphics.setLineWidth(1)

                    -- "FLEE!" label if fleeing
                    if state.isFleeing and _G.smallFont then
                        love.graphics.setFont(_G.smallFont)
                        love.graphics.setColor(1, 0.3, 0.2, 1)
                        love.graphics.print("BEŽI!", bar.x - 4, bar.y - 14)
                    end
                end
            end
        end
    end
end

-- Toggle visibility
function MoraleSystem.toggle()
    VISIBLE = not VISIBLE
    saveVisibility()
    if _G.NotificationCenter then
        pcall(function()
            _G.NotificationCenter.system("Morale sistem: " .. (VISIBLE and "VKLOPLJEN" or "IZKLOPLJEN"))
        end)
    end
    if _G.UISoundHelper then
        pcall(function() _G.UISoundHelper.playToggleOn() end)
    end
end

function MoraleSystem.isVisible()
    return VISIBLE
end

function MoraleSystem.setVisible(state)
    VISIBLE = state and true or false
    saveVisibility()
end

-- Reset all tracked units (e.g., on game restart)
function MoraleSystem.reset()
    unitStates = {}
    unitsToRemove = {}
    moraleAccumulator = 0
end

-- Get stats (for debugging)
function MoraleSystem.getStats()
    local count = 0
    local fleeing = 0
    local avgMorale = 0
    for _, state in pairs(unitStates) do
        count = count + 1
        avgMorale = avgMorale + state.morale
        if state.isFleeing then fleeing = fleeing + 1 end
    end
    -- v3.12.158: Add spatial grid stats
    local cellCount = 0
    for _ in pairs(spatialGrid) do cellCount = cellCount + 1 end
    return {
        trackedUnits = count,
        fleeingUnits = fleeing,
        averageMorale = count > 0 and (avgMorale / count) or 0,
        visible = VISIBLE,
        -- v3.12.158: Performance stats
        gridCells = cellCount,
        gridCellSize = GRID_CELL_SIZE,
        gridDirty = gridDirty,
        tickRate = MORALE_TICK,
    }
end

return MoraleSystem
