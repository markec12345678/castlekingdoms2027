-- objects/Controllers/AIController.lua
-- Stronghold 2027 - AI for enemy units
--
-- Controls enemy unit behavior: patrolling, aggro detection, attacking player units,
-- retreating when wounded, and group tactics.
--
-- Usage:
--   local AIController = require("objects.Controllers.AIController")
--   AIController:initialize()
--   AIController:update(dt)

local COMBAT = require("objects.Enums.Combat")

local AIController = _G.class("AIController")

function AIController:initialize()
    self.aiUnits = {}  -- List of AI-controlled units
    self.patrolRoutes = {}  -- Predefined patrol routes per faction
    self.groupTactics = {}  -- Group behavior state

    -- AI personality types
    self.aiPersonalities = {
        aggressive = {
            aggroRange = 15,
            retreatHealthPercent = 0.10,
            groupUpThreshold = 3,  -- attacks only with 3+ units
            chaseDuration = 20,    -- seconds to chase before giving up
        },
        defensive = {
            aggroRange = 8,
            retreatHealthPercent = 0.40,
            groupUpThreshold = 2,
            chaseDuration = 8,
        },
        balanced = {
            aggroRange = 12,
            retreatHealthPercent = 0.25,
            groupUpThreshold = 2,
            chaseDuration = 12,
        },
    }

    -- Default personality per faction
    self.factionPersonality = {
        [COMBAT.FACTION_ENEMY_1] = "aggressive",
        [COMBAT.FACTION_ENEMY_2] = "balanced",
        [COMBAT.FACTION_ENEMY_3] = "defensive",
    }

    print("AIController initialized")
end

-- Register a unit for AI control
function AIController:registerUnit(unit)
    if not unit or not unit.faction then return false end
    if unit.faction == COMBAT.FACTION_PLAYER then return false end  -- Don't control player units

    unit.aiState = {
        personality = self.factionPersonality[unit.faction] or "balanced",
        target = nil,
        lastTargetSeen = 0,
        patrolIndex = 1,
        state = "patrol",  -- patrol, aggro, attack, retreat
        groupMembers = {},  -- other units in the same group
    }

    table.insert(self.aiUnits, unit)
    return true
end

-- Unregister a unit
function AIController:unregisterUnit(unit)
    for i, u in ipairs(self.aiUnits) do
        if u == unit then
            table.remove(self.aiUnits, i)
            return true
        end
    end
    return false
end

-- Update all AI units
function AIController:update(dt)
    for _, unit in ipairs(self.aiUnits) do
        if unit and not unit.toBeDeleted and unit.health and unit.health > 0 then
            self:updateUnit(unit, dt)
        end
    end

    -- Clean up dead/removed units
    for i = #self.aiUnits, 1, -1 do
        local unit = self.aiUnits[i]
        if not unit or unit.toBeDeleted or (unit.health and unit.health <= 0) then
            table.remove(self.aiUnits, i)
        end
    end
end

-- Update a single AI unit
function AIController:updateUnit(unit, dt)
    local ai = unit.aiState
    if not ai then return end

    local personality = self.aiPersonalities[ai.personality]

    -- State machine
    if ai.state == "patrol" then
        self:patrolBehavior(unit, dt, personality)
    elseif ai.state == "aggro" then
        self:aggroBehavior(unit, dt, personality)
    elseif ai.state == "attack" then
        self:attackBehavior(unit, dt, personality)
    elseif ai.state == "retreat" then
        self:retreatBehavior(unit, dt, personality)
    end

    -- Check for retreat condition
    local maxHealth = self:getUnitMaxHealth(unit)
    if unit.health < maxHealth * personality.retreatHealthPercent then
        ai.state = "retreat"
    end
end

-- Get max health for unit (delegates to CombatController when available)
function AIController:getUnitMaxHealth(unit)
    if unit.maxHealth then return unit.maxHealth end
    if unit.class then
        return COMBAT.HEALTH[unit.class.name] or 50
    end
    return 50
end

-- Patrol behavior: move along predefined route
function AIController:patrolBehavior(unit, dt, personality)
    -- Look for enemies in aggro range
    local enemy = self:findNearestPlayerUnit(unit, personality.aggroRange)
    if enemy then
        ai_target = enemy
        unit.aiState.target = enemy
        unit.aiState.state = "aggro"
        unit.aiState.lastTargetSeen = love.timer.getTime()
        return
    end

    -- Continue patrol (if route is set)
    local route = self.patrolRoutes[unit.faction]
    if route and #route > 0 then
        local target = route[unit.aiState.patrolIndex]
        if target then
            local dx = target.x - unit.gx
            local dy = target.y - unit.gy
            local distSq = dx * dx + dy * dy

            if distSq < 1 then
                -- Reached waypoint, move to next
                unit.aiState.patrolIndex = (unit.aiState.patrolIndex % #route) + 1
            else
                -- Move toward waypoint
                if unit.gotoUserWaypoint and (not unit.moveDir or unit.moveDir == "none") then
                    unit:gotoUserWaypoint(target.x, target.y, nil, nil)
                end
            end
        end
    end
end

-- Aggro behavior: chase enemy
function AIController:aggroBehavior(unit, dt, personality)
    local target = unit.aiState.target
    if not target or target.toBeDeleted or (target.health and target.health <= 0) then
        -- Target lost
        if love.timer.getTime() - unit.aiState.lastTargetSeen > personality.chaseDuration then
            unit.aiState.state = "patrol"
            unit.aiState.target = nil
        end
        return
    end

    -- Update last seen time
    unit.aiState.lastTargetSeen = love.timer.getTime()

    -- Check if in attack range
    local dx = target.gx - unit.gx
    local dy = target.gy - unit.gy
    local distSq = dx * dx + dy * dy
    local attackRange = COMBAT.RANGE_MELEE + 0.5  -- melee by default

    if unit.class then
        if unit.class.name == "Archer" then attackRange = COMBAT.RANGE_MEDIUM end
        if unit.class.name == "Crossbowman" then attackRange = COMBAT.RANGE_LONG end
    end

    if distSq <= attackRange * attackRange then
        unit.aiState.state = "attack"
    else
        -- Move toward target
        if unit.gotoUserWaypoint and (not unit.moveDir or unit.moveDir == "none") then
            unit:gotoUserWaypoint(target.gx, target.gy, nil, nil)
        end
    end
end

-- Attack behavior: in range, attack target
function AIController:attackBehavior(unit, dt, personality)
    local target = unit.aiState.target
    if not target or target.toBeDeleted or (target.health and target.health <= 0) then
        unit.aiState.state = "patrol"
        unit.aiState.target = nil
        return
    end

    -- Use CombatController if available
    if _G.CombatController then
        _G.CombatController:attack(unit, target)
    end

    -- Check if target moved out of range
    local dx = target.gx - unit.gx
    local dy = target.gy - unit.gy
    local distSq = dx * dx + dy * dy
    local attackRange = COMBAT.RANGE_MELEE + 0.5

    if unit.class then
        if unit.class.name == "Archer" then attackRange = COMBAT.RANGE_MEDIUM end
        if unit.class.name == "Crossbowman" then attackRange = COMBAT.RANGE_LONG end
    end

    if distSq > attackRange * attackRange then
        unit.aiState.state = "aggro"
    end
end

-- Retreat behavior: flee from enemies
function AIController:retreatBehavior(unit, dt, personality)
    -- Find direction away from nearest enemy
    local enemy = self:findNearestPlayerUnit(unit, 20)
    if enemy then
        -- Move away from enemy
        local dx = unit.gx - enemy.gx
        local dy = unit.gy - enemy.gy
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0 then
            local fleeX = unit.gx + (dx / len) * 10
            local fleeY = unit.gy + (dy / len) * 10
            if unit.gotoUserWaypoint and (not unit.moveDir or unit.moveDir == "none") then
                unit:gotoUserWaypoint(fleeX, fleeY, nil, nil)
            end
        end
    else
        -- No enemy nearby, return to patrol
        unit.aiState.state = "patrol"
    end
end

-- Find nearest player unit
function AIController:findNearestPlayerUnit(unit, range)
    if not _G.state or not _G.state.gameObjectList then return nil end

    local nearest = nil
    local nearestDistSq = range * range

    for _, otherUnit in ipairs(_G.state.gameObjectList) do
        if otherUnit ~= unit and otherUnit.faction == COMBAT.FACTION_PLAYER
            and otherUnit.health and otherUnit.health > 0
            and not otherUnit.toBeDeleted then

            local dx = otherUnit.gx - unit.gx
            local dy = otherUnit.gy - unit.gy
            local distSq = dx * dx + dy * dy

            if distSq < nearestDistSq then
                nearestDistSq = distSq
                nearest = otherUnit
            end
        end
    end

    return nearest
end

-- Set patrol route for faction
function AIController:setPatrolRoute(faction, route)
    self.patrolRoutes[faction] = route
end

-- Spawn a group of enemy units at position
function AIController:spawnEnemyGroup(faction, unitClass, count, gx, gy)
    -- Stronghold 2027 v2.5.9: Actually spawn units via CombatIntegration
    local CombatIntegration = _G.CombatIntegration
    if CombatIntegration and CombatIntegration.spawnEnemyGroup then
        CombatIntegration.spawnEnemyGroup(unitClass, count, gx, gy, faction)
        print(string.format("[AIController] Spawned %d %s for faction %d at (%d, %d)",
            count, unitClass, faction, gx, gy))
    else
        -- Fallback: print if CombatIntegration not available
        print(string.format("[AIController] Would spawn %d %s for faction %d at (%d, %d)",
            count, unitClass, faction, gx, gy))
    end
end

-- Get AI stats
function AIController:getStats()
    local stats = {
        totalUnits = #self.aiUnits,
        byState = { patrol = 0, aggro = 0, attack = 0, retreat = 0 },
        byFaction = {},
    }

    for _, unit in ipairs(self.aiUnits) do
        if unit.aiState then
            stats.byState[unit.aiState.state] = (stats.byState[unit.aiState.state] or 0) + 1
            stats.byFaction[unit.faction] = (stats.byFaction[unit.faction] or 0) + 1
        end
    end

    return stats
end

return AIController:new()
