-- objects/Combat/CombatIntegration.lua
-- Castle Kingdoms 2027 - Combat System Integration
--
-- This module integrates the combat system into the main game loop.
-- It hooks into states/game.lua to update and draw combat-related entities.
--
-- Usage in states/game.lua:
--   local CombatIntegration = require("objects.Combat.CombatIntegration")
--   CombatIntegration.init()       -- in delayedInit()
--   CombatIntegration.update(dt)   -- in game:update()
--   CombatIntegration.draw()       -- in game:draw()

local COMBAT = require("objects.Enums.Combat")
local CombatController = require("objects.Controllers.CombatController")
local ProjectileController = require("objects.Controllers.ProjectileController")
local AIController = require("objects.Controllers.AIController")
local HealthBarController = require("objects.Controllers.HealthBarController")
local CombatComponent = require("objects.Combat.CombatComponent")

local CombatIntegration = {}

local initialized = false
local combatLog = {}  -- Recent combat events for UI
local maxLogEntries = 10

-- Initialize combat system
function CombatIntegration.init()
    if initialized then return end
    initialized = true

    -- Register controllers globally
    _G.CombatController = CombatController
    _G.ProjectileController = ProjectileController
    _G.AIController = AIController
    _G.HealthBarController = HealthBarController

    -- Hook into unit spawn system to auto-attach combat component
    CombatIntegration.hookUnitSpawning()

    -- Hook into Commander for attack orders
    CombatIntegration.hookCommander()

    print("[CombatIntegration] Combat system initialized")
end

-- Hook into unit spawning to auto-attach CombatComponent
function CombatIntegration.hookUnitSpawning()
    -- We'll attach combat component when military units are recruited
    -- This is done via the recruitment system, not automatically for all units
    -- (workers, animals etc. don't need combat stats)
end

-- Hook into Commander to handle right-click on enemies as attack order
function CombatIntegration.hookCommander()
    if not _G.Commander then
        -- Commander not yet loaded, retry next frame
        return false
    end

    if _G.Commander._combatHooked then return true end
    _G.Commander._combatHooked = true

    -- Store original mousereleased method
    local originalMousereleased = _G.Commander.mousereleased

    _G.Commander.mousereleased = function(self, x, y, button)
        -- Right-click with selected units = attack/move order
        if button == 2 and #self.selectedUnits > 0 then
            local pressGX, pressGY = _G.getTerrainTileOnMouse(x, y)

            -- Check if there's an enemy unit at clicked location
            local enemyUnit = CombatIntegration.findEnemyAt(pressGX, pressGY)

            if enemyUnit then
                -- Issue attack order to all selected units
                for _, unit in ipairs(self.selectedUnits) do
                    if unit._combatAttached then
                        unit.target = enemyUnit
                        unit.combatState = COMBAT.STATE_AGGRO
                        -- Move toward enemy
                        if unit.gotoUserWaypoint then
                            unit:gotoUserWaypoint(enemyUnit.gx, enemyUnit.gy, nil, nil)
                        end
                    end
                end
                CombatIntegration.log(string.format("Attack order: %d units → %s",
                    #self.selectedUnits, enemyUnit.className or "enemy"))
                return true  -- Consume the click
            end
        end

        -- Fall through to original handler
        return originalMousereleased(self, x, y, button)
    end

    print("[CombatIntegration] Commander hooked for attack orders")
    return true
end

-- Find enemy unit at tile position
function CombatIntegration.findEnemyAt(gx, gy)
    if not _G.state or not _G.state.gameObjectList then return nil end
    if not gx or not gy then return nil end

    -- Search radius (in tiles)
    local searchRadius = 2

    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit._combatAttached
            and unit.faction ~= COMBAT.FACTION_PLAYER
            and unit.faction ~= COMBAT.FACTION_NEUTRAL
            and not unit.toBeDeleted
            and unit.health and unit.health > 0
            and unit.gx and unit.gy then

            local dx = unit.gx - gx
            local dy = unit.gy - gy
            local distSq = dx * dx + dy * dy

            if distSq <= searchRadius * searchRadius then
                return unit
            end
        end
    end

    return nil
end

-- Update combat system (called from game:update)
function CombatIntegration.update(dt)
    if not initialized then return end

    -- Update CombatController (handles damage numbers, projectile hits, AI)
    CombatController:update(dt)

    -- Update ProjectileController (moves arrows, bolts, rocks)
    ProjectileController:update(dt)

    -- Update AIController (enemy unit AI)
    AIController:update(dt)

    -- Update HealthBarController (determine which units show health bars)
    HealthBarController:update(dt)

    -- Process combat for all military units (auto-attack if has target)
    if _G.state and _G.state.gameObjectList then
        for _, unit in ipairs(_G.state.gameObjectList) do
            if unit._combatAttached and not unit.toBeDeleted
                and unit.health and unit.health > 0 then

                -- Auto-aggro: if idle and enemy nearby, engage
                if unit.combatState == COMBAT.STATE_IDLE and not unit.playerControlled then
                    local enemy = unit:findNearestEnemy()
                    if enemy then
                        unit.target = enemy
                        unit.combatState = COMBAT.STATE_AGGRO
                    end
                end

                -- If has target, try to attack
                if unit.target and unit.combatState ~= COMBAT.STATE_IDLE then
                    -- Check if target still valid
                    if unit.target.toBeDeleted or (unit.target.health and unit.target.health <= 0) then
                        unit.target = nil
                        unit.combatState = COMBAT.STATE_IDLE
                    else
                        -- Move toward target if out of range
                        local dx = unit.target.gx - unit.gx
                        local dy = unit.target.gy - unit.gy
                        local distSq = dx * dx + dy * dy
                        local range = unit.attackRange + 0.5

                        if distSq <= range * range then
                            -- In range, attack!
                            unit:attackTarget()
                        else
                            -- Out of range, move closer (only if not already moving)
                            if (not unit.moveDir or unit.moveDir == "none")
                                and unit.gotoUserWaypoint then
                                unit:gotoUserWaypoint(unit.target.gx, unit.target.gy, nil, nil)
                            end
                        end
                    end
                end

                -- Retreat if low health
                if unit.health < unit.maxHealth * COMBAT.RETREAT_HEALTH_PERCENT
                    and unit.combatState ~= COMBAT.STATE_RETREATING then
                    unit.combatState = COMBAT.STATE_RETREATING
                    CombatIntegration.log(string.format("%s retreating (HP: %d/%d)",
                        unit.className, math.floor(unit.health), unit.maxHealth))
                end
            end
        end
    end
end

-- Draw combat system (called from game:draw)
function CombatIntegration.draw()
    if not initialized then return end

    -- Draw projectiles (arrows, bolts, rocks in flight)
    ProjectileController:draw()

    -- Draw damage numbers
    CombatController:draw()

    -- Draw health bars
    HealthBarController:draw()
end

-- Spawn a military unit with combat capabilities
-- @param unitClass string Class name (e.g., "Archer", "Knight")
-- @param gx number Global X position
-- @param gy number Global Y position
-- @param faction number COMBAT.FACTION_* constant
-- @return Unit The spawned unit, or nil on failure
function CombatIntegration.spawnUnit(unitClass, gx, gy, faction)
    if not _G.state or not _G.state.gameObjectList then
        print("[CombatIntegration] Cannot spawn: state not ready")
        return nil
    end

    -- Try to load the unit class
    local ok, UnitClass = pcall(require, "objects.Units." .. unitClass)
    if not ok or not UnitClass then
        print("[CombatIntegration] Cannot load unit class: " .. unitClass)
        return nil
    end

    -- Spawn the unit
    local unit = UnitClass:new(gx, gy, faction or COMBAT.FACTION_PLAYER)

    -- Attach combat component
    CombatComponent.attach(unit, unitClass, faction or COMBAT.FACTION_PLAYER)

    -- Register with AI controller if not player unit
    if faction and faction ~= COMBAT.FACTION_PLAYER then
        AIController:registerUnit(unit)
    end

    CombatIntegration.log(string.format("Spawned %s (faction %d) at (%d, %d)",
        unitClass, faction or COMBAT.FACTION_PLAYER, gx, gy))

    return unit
end

-- Spawn a group of enemy units (for testing or scenario triggers)
function CombatIntegration.spawnEnemyGroup(unitClass, count, gx, gy, faction)
    faction = faction or COMBAT.FACTION_ENEMY_1
    local spawned = {}

    for i = 1, count do
        -- Spread units in a small formation
        local offsetX = (i % 3) * 2 - 2
        local offsetY = math.floor(i / 3) * 2
        local unit = CombatIntegration.spawnUnit(unitClass, gx + offsetX, gy + offsetY, faction)
        if unit then
            table.insert(spawned, unit)
        end
    end

    CombatIntegration.log(string.format("Spawned enemy group: %dx %s (faction %d)",
        count, unitClass, faction))

    return spawned
end

-- Add entry to combat log
function CombatIntegration.log(message)
    local entry = {
        time = love.timer.getTime(),
        message = message,
    }
    table.insert(combatLog, entry)

    -- Trim log
    while #combatLog > maxLogEntries do
        table.remove(combatLog, 1)
    end

    print("[Combat] " .. message)
end

-- Get combat log
function CombatIntegration.getCombatLog()
    return combatLog
end

-- Get combat statistics
function CombatIntegration.getStats()
    local stats = CombatController:getStats()
    stats.activeProjectiles = ProjectileController:getCount()
    stats.visibleHealthBars = HealthBarController:getVisibleCount()
    stats.aiStats = AIController:getStats()
    return stats
end

-- Reset combat system (for new game/load)
function CombatIntegration.reset()
    CombatController:reset()
    ProjectileController:clear()
    combatLog = {}
    print("[CombatIntegration] Combat system reset")
end

-- Check if combat system is initialized
function CombatIntegration.isInitialized()
    return initialized
end

-- Castle Kingdoms 2027 v2.4.1: Spawn a projectile (for siege weapons)
-- @param fromGx, fromGy number Source position
-- @param toGx, toGy number Target position
-- @param damage number Damage on impact
-- @param splashRadius number Splash radius (0 = single target)
function CombatIntegration.spawnProjectile(fromGx, fromGy, toGx, toGy, damage, splashRadius)
    if not initialized then return end
    if not ProjectileController then return end
    -- Create a pseudo-attacker for the projectile
    local projectile = {
        gx = fromGx,
        gy = fromGy,
        targetGx = toGx,
        targetGy = toGy,
        damage = damage or 50,
        splashRadius = splashRadius or 0,
        faction = 1,  -- assume player faction for siege weapons
    }
    -- Use ProjectileController to spawn if it has a spawn method
    if ProjectileController.spawn then
        pcall(function() ProjectileController:spawn(projectile) end)
    elseif ProjectileController.add then
        pcall(function() ProjectileController:add(projectile) end)
    end
    -- Log the projectile
    CombatIntegration.log(string.format("Projectile: (%d,%d) -> (%d,%d) dmg=%d splash=%d",
        fromGx, fromGy, toGx, toGy, damage or 0, splashRadius or 0))
end

return CombatIntegration
