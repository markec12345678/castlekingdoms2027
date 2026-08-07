-- objects/Controllers/CombatController.lua
-- Castle Kingdoms 2027 - Combat System
--
-- Manages all combat interactions between units and buildings.
-- Handles damage calculation, attack cooldowns, aggro detection, and death.
--
-- Usage:
--   local CombatController = require("objects.Controllers.CombatController")
--   CombatController:initialize()
--   CombatController:update(dt)
--   CombatController:attack(attacker, target)

local COMBAT = require("objects.Enums.Combat")
local EVENTS = require("objects.Enums.Events")
local EventBus = require("libraries.eventbus")

local CombatController = _G.class("CombatController")

function CombatController:initialize()
    self.activeCombats = {}      -- List of ongoing combat pairs
    self.projectilesInFlight = {}  -- Arrows, bolts, etc.
    self.damageNumbers = {}     -- Floating damage indicators
    self.deathList = {}         -- Units to clean up this frame
    self.killsByFaction = {}    -- Kill counters per faction

    -- Statistics
    self.stats = {
        totalAttacks = 0,
        totalKills = 0,
        totalDamage = 0,
        combatStartTime = 0,
    }

    print("CombatController initialized (Castle Kingdoms 2027 combat system)")
end

-- Find nearest enemy in aggro range
function CombatController:findNearestEnemy(unit, aggroRange)
    if not unit or not unit.gx or not unit.gy then return nil end
    if not unit.faction then return nil end

    aggroRange = aggroRange or COMBAT.AGGRO_RANGE
    local nearestEnemy = nil
    local nearestDistance = aggroRange * aggroRange  -- squared for performance

    if not _G.state or not _G.state.gameObjectList then return nil end

    for _, otherUnit in ipairs(_G.state.gameObjectList) do
        if otherUnit ~= unit and otherUnit.faction and otherUnit.faction ~= unit.faction
            and otherUnit.faction ~= COMBAT.FACTION_NEUTRAL
            and not otherUnit.toBeDeleted
            and otherUnit.health and otherUnit.health > 0 then

            local dx = otherUnit.gx - unit.gx
            local dy = otherUnit.gy - unit.gy
            local distSq = dx * dx + dy * dy

            if distSq < nearestDistance then
                nearestDistance = distSq
                nearestEnemy = otherUnit
            end
        end
    end

    return nearestEnemy
end

-- Calculate distance between two entities
function CombatController:distanceBetween(entity1, entity2)
    if not entity1 or not entity2 then return math.huge end
    if not entity1.gx or not entity2.gx then return math.huge end
    local dx = entity1.gx - entity2.gx
    local dy = entity1.gy - entity2.gy
    return math.sqrt(dx * dx + dy * dy)
end

-- Check if target is in attack range
function CombatController:isInRange(attacker, target, attackRange)
    if not attacker or not target then return false end
    local distance = self:distanceBetween(attacker, target)
    return distance <= (attackRange or COMBAT.RANGE_MELEE)
end

-- Get attack range based on unit type
function CombatController:getAttackRange(unit)
    if not unit or not unit.class then return COMBAT.RANGE_MELEE end
    local className = unit.class.name

    if className == "Archer" then return COMBAT.RANGE_MEDIUM end
    if className == "Crossbowman" then return COMBAT.RANGE_LONG end
    if className == "Spearman" then return COMBAT.RANGE_SHORT end
    if className == "Pikeman" then return COMBAT.RANGE_SHORT end

    return COMBAT.RANGE_MELEE  -- Maceman, Swordsman, Knight, Lord
end

-- Get attack type based on unit type
function CombatController:getAttackType(unit)
    if not unit or not unit.class then return COMBAT.ATTACK_MELEE end
    local className = unit.class.name

    if className == "Archer" or className == "Crossbowman" then
        return COMBAT.ATTACK_RANGED
    end

    return COMBAT.ATTACK_MELEE
end

-- Get damage value for unit
function CombatController:getDamage(unit)
    if not unit or not unit.class then return 10 end
    local className = unit.class.name
    return COMBAT.DAMAGE[className] or 10
end

-- Get max health for unit
function CombatController:getMaxHealth(unit)
    if not unit or not unit.class then return 50 end
    local className = unit.class.name
    return COMBAT.HEALTH[className] or 50
end

-- Get armor value for unit
function CombatController:getArmor(unit)
    if not unit or not unit.class then return 0 end
    local className = unit.class.name
    return COMBAT.ARMOR[className] or 0
end

-- Calculate actual damage after armor reduction
function CombatController:calculateDamage(attacker, target)
    local baseDamage = self:getDamage(attacker)
    local armor = self:getArmor(target)

    -- Castle Kingdoms 2027 v2.3.3: Diminishing returns on armor
    -- Old formula: damage * (1 - armor) — heavy armor was too strong
    -- New formula: damage * (1 - armor^1.5 * 0.8) — softer reduction curve
    -- Example: armor=0.45 (Knight) -> reduction = 0.45^1.5 * 0.8 = 0.242 (24.2% reduction)
    --          vs old: 45% reduction
    local armorReduction = math.pow(armor, 1.5) * 0.8
    local actualDamage = baseDamage * (1 - armorReduction)

    -- Add small random variance (±10%)
    local variance = 0.9 + math.random() * 0.2
    actualDamage = actualDamage * variance

    -- Castle Kingdoms 2027 v2.3.3: Minimum damage of 1 (always possible to chip damage)
    actualDamage = math.max(1, actualDamage)

    return math.floor(actualDamage + 0.5)
end

-- Initiate attack from attacker to target
function CombatController:attack(attacker, target)
    if not attacker or not target then return false end
    if attacker.toBeDeleted or target.toBeDeleted then return false end
    if not target.health or target.health <= 0 then return false end

    -- Check cooldown
    if not attacker.lastAttackTime then
        attacker.lastAttackTime = 0
    end

    local currentTime = love.timer.getTime()
    local cooldown = COMBAT.ATTACK_COOLDOWN_DEFAULT
    local attackType = self:getAttackType(attacker)

    if attackType == COMBAT.ATTACK_RANGED then
        cooldown = COMBAT.ATTACK_COOLDOWN_FAST
    elseif attackType == COMBAT.ATTACK_SIEGE then
        cooldown = COMBAT.ATTACK_COOLDOWN_SLOW
    end

    if currentTime - attacker.lastAttackTime < cooldown then
        return false  -- On cooldown
    end

    attacker.lastAttackTime = currentTime
    self.stats.totalAttacks = self.stats.totalAttacks + 1

    -- Fire event
    EventBus:emit(EVENTS.OnUnitAttacked, { attacker = attacker, target = target })

    -- For ranged units, spawn projectile
    if attackType == COMBAT.ATTACK_RANGED then
        self:spawnProjectile(attacker, target)
        return true
    end

    -- For melee, apply damage immediately
    self:applyDamage(attacker, target)
    return true
end

-- Apply damage to target
function CombatController:applyDamage(attacker, target)
    if not target or not target.health or target.health <= 0 then return end

    local damage = self:calculateDamage(attacker, target)
    target.health = target.health - damage

    self.stats.totalDamage = self.stats.totalDamage + damage

    -- Show damage number
    self:spawnDamageNumber(target, damage)

    -- Fire event
    EventBus:emit(EVENTS.OnUnitDamaged, {
        attacker = attacker,
        target = target,
        damage = damage,
        remainingHealth = target.health
    })

    -- Castle Kingdoms 2027 v2.3.3: Award XP to attacker for damage dealt
    if _G.Veterancy and attacker then
        pcall(function() _G.Veterancy.onDamageDealt(attacker, damage) end)
    end
    -- Castle Kingdoms 2027 v2.3.3: Award XP to target for taking damage (defensive veterancy)
    if _G.Veterancy and target then
        pcall(function() _G.Veterancy.onDamageTaken(target, damage) end)
    end

    -- Check for death
    if target.health <= 0 then
        self:onUnitKilled(attacker, target)
    end
end

-- Spawn a projectile (arrow, bolt)
function CombatController:spawnProjectile(attacker, target)
    local projectile = {
        attacker = attacker,
        target = target,
        startX = attacker.gx,
        startY = attacker.gy,
        targetX = target.gx,
        targetY = target.gy,
        progress = 0,
        speed = 8,  -- Tiles per second
        damage = self:calculateDamage(attacker, target),
    }
    table.insert(self.projectilesInFlight, projectile)

    EventBus:emit(EVENTS.OnProjectileFired, {
        attacker = attacker,
        target = target,
        startX = projectile.startX,
        startY = projectile.startY
    })
end

-- Spawn floating damage number
function CombatController:spawnDamageNumber(target, damage)
    if not target.gx or not target.gy then return end

    local damageNum = {
        x = target.gx,
        y = target.gy,
        damage = damage,
        lifetime = 1.0,  -- seconds
        offsetY = 0,
    }
    table.insert(self.damageNumbers, damageNum)
end

-- Handle unit death
function CombatController:onUnitKilled(killer, victim)
    if not victim then return end

    self.stats.totalKills = self.stats.totalKills + 1

    -- Track kills by faction
    if killer and killer.faction then
        self.killsByFaction[killer.faction] = (self.killsByFaction[killer.faction] or 0) + 1
    end

    EventBus:emit(EVENTS.OnUnitKilled, {
        killer = killer,
        victim = victim,
    })

    -- Mark for cleanup
    table.insert(self.deathList, victim)

    -- Call unit's die method if it exists
    if victim.die then
        victim:die()
    end
end

-- Update combat state
function CombatController:update(dt)
    -- Update projectiles
    for i = #self.projectilesInFlight, 1, -1 do
        local proj = self.projectilesInFlight[i]
        proj.progress = proj.progress + proj.speed * dt

        if proj.progress >= 1 then
            -- Projectile hit
            if proj.target and not proj.target.toBeDeleted and proj.target.health > 0 then
                self:applyDamage(proj.attacker, proj.target)
                EventBus:emit(EVENTS.OnProjectileHit, {
                    attacker = proj.attacker,
                    target = proj.target,
                    damage = proj.damage
                })
            end
            table.remove(self.projectilesInFlight, i)
        end
    end

    -- Update damage numbers
    for i = #self.damageNumbers, 1, -1 do
        local dn = self.damageNumbers[i]
        dn.lifetime = dn.lifetime - dt
        dn.offsetY = dn.offsetY + 30 * dt  -- float upward

        if dn.lifetime <= 0 then
            table.remove(self.damageNumbers, i)
        end
    end

    -- Clean up dead units
    for i = #self.deathList, 1, -1 do
        local dead = self.deathList[i]
        if dead and dead.toBeDeleted then
            table.remove(self.deathList, i)
        end
    end

    -- Process AI for all combat units
    if _G.state and _G.state.gameObjectList then
        for _, unit in ipairs(_G.state.gameObjectList) do
            if unit.faction and unit.faction ~= COMBAT.FACTION_NEUTRAL
                and unit.health and unit.health > 0
                and not unit.toBeDeleted then
                self:processUnitAI(unit, dt)
            end
        end
    end
end

-- Process AI for a single unit
function CombatController:processUnitAI(unit, dt)
    -- Initialize combat state if not set
    if not unit.combatState then
        unit.combatState = COMBAT.STATE_IDLE
    end

    -- Skip if unit is player-controlled (player commands take precedence)
    if unit.playerControlled and unit.combatState == COMBAT.STATE_IDLE then
        return
    end

    -- Retreat if low health
    if unit.health and unit.health < (self:getMaxHealth(unit) * COMBAT.RETREAT_HEALTH_PERCENT) then
        unit.combatState = COMBAT.STATE_RETREATING
        -- TODO: Implement retreat movement
        return
    end

    -- Find target if idle
    if unit.combatState == COMBAT.STATE_IDLE then
        local enemy = self:findNearestEnemy(unit)
        if enemy then
            unit.target = enemy
            unit.combatState = COMBAT.STATE_AGGRO
            EventBus:emit(EVENTS.OnCombatStart, { attacker = unit, target = enemy })
        end
    end

    -- If has target, check distance and act
    if unit.combatState == COMBAT.STATE_AGGRO or unit.combatState == COMBAT.STATE_SEEKING then
        if not unit.target or unit.target.toBeDeleted or (unit.target.health and unit.target.health <= 0) then
            unit.target = nil
            unit.combatState = COMBAT.STATE_IDLE
            return
        end

        local attackRange = self:getAttackRange(unit)
        if self:isInRange(unit, unit.target, attackRange) then
            unit.combatState = COMBAT.STATE_ATTACKING
            self:attack(unit, unit.target)
        else
            unit.combatState = COMBAT.STATE_SEEKING
            -- Move toward target (uses existing pathfinding)
            if unit.gotoUserWaypoint and not unit.moveDir or unit.moveDir == "none" then
                if unit.gotoUserWaypoint then
                    unit:gotoUserWaypoint(unit.target.gx, unit.target.gy, nil, nil)
                end
            end
        end
    end
end

-- Draw combat visuals (damage numbers, projectiles)
function CombatController:draw()
    -- Draw damage numbers
    for _, dn in ipairs(self.damageNumbers) do
        local alpha = math.min(1, dn.lifetime)
        love.graphics.setColor(1, 0.2, 0.2, alpha)

        -- Convert world coords to screen coords (simplified)
        local screenX = dn.x * 32 - _G.state.viewXview
        local screenY = dn.y * 16 - _G.state.viewYview - dn.offsetY

        love.graphics.print(tostring(dn.damage), screenX, screenY)
    end

    -- Draw projectiles
    for _, proj in ipairs(self.projectilesInFlight) do
        local currentX = proj.startX + (proj.targetX - proj.startX) * proj.progress
        local currentY = proj.startY + (proj.targetY - proj.startY) * proj.progress

        local screenX = currentX * 32 - _G.state.viewXview
        local screenY = currentY * 16 - _G.state.viewYview

        love.graphics.setColor(0.6, 0.4, 0.2, 1)
        love.graphics.circle("fill", screenX, screenY, 3)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Get combat statistics
function CombatController:getStats()
    return {
        totalAttacks = self.stats.totalAttacks,
        totalKills = self.stats.totalKills,
        totalDamage = self.stats.totalDamage,
        activeProjectiles = #self.projectilesInFlight,
        activeDamageNumbers = #self.damageNumbers,
        killsByFaction = self.killsByFaction,
    }
end

-- Reset combat state (for new game/load)
function CombatController:reset()
    self.activeCombats = {}
    self.projectilesInFlight = {}
    self.damageNumbers = {}
    self.deathList = {}
    self.killsByFaction = {}
    self.stats = {
        totalAttacks = 0,
        totalKills = 0,
        totalDamage = 0,
        combatStartTime = love.timer.getTime(),
    }
end

return CombatController:new()
