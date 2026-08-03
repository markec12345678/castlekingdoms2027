-- objects/Combat/CombatComponent.lua
-- Stronghold 2027 - Combat Component for Units
--
-- Mixin that adds combat capabilities to any Unit.
-- Usage in Unit:initialize():
--   local CombatComponent = require("objects.Combat.CombatComponent")
--   CombatComponent.attach(self, className, faction)
--
-- This adds: health, maxHealth, faction, combatState, attack(), takeDamage(), die()

local COMBAT = require("objects.Enums.Combat")

local CombatComponent = {}

-- Attach combat capabilities to a unit
-- @param unit The unit to enhance
-- @param className string Unit class name (e.g., "Archer", "Knight")
-- @param faction number One of COMBAT.FACTION_* constants
function CombatComponent.attach(unit, className, faction)
    if unit._combatAttached then return end  -- Already attached
    unit._combatAttached = true

    -- Combat stats
    unit.className = className or unit.class and unit.class.name or "Peasant"
    unit.faction = faction or COMBAT.FACTION_PLAYER
    unit.maxHealth = COMBAT.HEALTH[unit.className] or 50
    unit.health = unit.maxHealth
    unit.armor = COMBAT.ARMOR[unit.className] or 0
    unit.baseDamage = COMBAT.DAMAGE[unit.className] or 10
    unit.attackRange = CombatComponent.getAttackRange(unit.className)
    unit.attackType = CombatComponent.getAttackType(unit.className)
    unit.attackCooldown = CombatComponent.getAttackCooldown(unit.className)

    -- Combat state
    unit.combatState = COMBAT.STATE_IDLE
    unit.target = nil
    unit.lastAttackTime = 0
    unit.kills = 0

    -- Add methods to unit
    unit.takeDamage = CombatComponent.takeDamage
    unit.heal = CombatComponent.heal
    unit.attackTarget = CombatComponent.attackTarget
    unit.findNearestEnemy = CombatComponent.findNearestEnemy
    unit.isInCombat = CombatComponent.isInCombat
    unit.getHealthPercent = CombatComponent.getHealthPercent
    unit.resetCombat = CombatComponent.resetCombat
end

function CombatComponent.getAttackRange(className)
    if className == "Archer" then return COMBAT.RANGE_MEDIUM end
    if className == "Crossbowman" then return COMBAT.RANGE_LONG end
    if className == "Spearman" then return COMBAT.RANGE_SHORT end
    if className == "Pikeman" then return COMBAT.RANGE_SHORT end
    return COMBAT.RANGE_MELEE
end

function CombatComponent.getAttackType(className)
    if className == "Archer" or className == "Crossbowman" then
        return COMBAT.ATTACK_RANGED
    end
    return COMBAT.ATTACK_MELEE
end

function CombatComponent.getAttackCooldown(className)
    local attackType = CombatComponent.getAttackType(className)
    if attackType == COMBAT.ATTACK_RANGED then
        return COMBAT.ATTACK_COOLDOWN_FAST
    end
    return COMBAT.ATTACK_COOLDOWN_DEFAULT
end

function CombatComponent.takeDamage(self, amount, attacker)
    if self.toBeDeleted or self.health <= 0 then return 0 end

    local actualDamage = amount * (1 - (self.armor or 0))
    actualDamage = actualDamage * (0.9 + math.random() * 0.2)
    actualDamage = math.floor(actualDamage + 0.5)

    self.health = self.health - actualDamage

    if attacker and self.combatState == COMBAT.STATE_IDLE then
        self.target = attacker
        self.combatState = COMBAT.STATE_AGGRO
    end

    if _G.CombatController then
        _G.CombatController:spawnDamageNumber(self, actualDamage)
    end

    -- Stronghold 2027: Game feel feedback (screen shake, hit flash)
    if _G.GameFeel then
        _G.GameFeel.onUnitDamaged(self, actualDamage, attacker)
    end

    -- Stronghold 2027: Report combat to music manager + play SFX
    if _G.DynamicMusic then
        _G.DynamicMusic.reportCombat(1)
    end
    if _G.SFXLibrary then
        _G.SFXLibrary.playCombat("sword_hit", self.gx, self.gy)
    end
    -- Stronghold 2027: Award XP to attacker for damage dealt
    if _G.Veterancy and attacker then
        _G.Veterancy.onDamageDealt(attacker, actualDamage)
    end

    if self.health <= 0 then
        self.health = 0
        self.combatState = COMBAT.STATE_DEAD
        if attacker then
            attacker.kills = (attacker.kills or 0) + 1
        end
        -- Stronghold 2027: Game feel feedback for death
        if _G.GameFeel then
            _G.GameFeel.onUnitDeath(self, attacker)
        end
        -- Stronghold 2027: Play death SFX
        if _G.SFXLibrary then
            _G.SFXLibrary.playCombat("death", self.gx, self.gy)
        end
        -- Stronghold 2027: Award kill XP to attacker
        if _G.Veterancy and attacker then
            _G.Veterancy.onKill(attacker, self)
        end
        -- Stronghold 2027: Spawn death visual effect
        if _G.VisualPolish and self.gx and self.gy then
            local sx = _G.IsoToScreenX(self.gx, self.gy) - (_G.state.viewXview or 0)
            local sy = _G.IsoToScreenY(self.gx, self.gy) - (_G.state.viewYview or 0)
            _G.VisualPolish.spawnDeathEffect(sx, sy)
        end
        if self._originalDie then
            self._originalDie(self)
        elseif self.die then
            self:die()
        end
    end

    return actualDamage
end

function CombatComponent.heal(self, amount)
    if self.toBeDeleted or self.health <= 0 then return end
    self.health = math.min(self.maxHealth, self.health + amount)
end

function CombatComponent.attackTarget(self)
    if not self.target then return false end
    if self.target.toBeDeleted or (self.target.health and self.target.health <= 0) then
        self.target = nil
        self.combatState = COMBAT.STATE_IDLE
        return false
    end

    local currentTime = love.timer.getTime()
    if currentTime - (self.lastAttackTime or 0) < self.attackCooldown then
        return false
    end
    self.lastAttackTime = currentTime

    if not self.target.gx or not self.target.gy then return false end
    local dx = self.target.gx - self.gx
    local dy = self.target.gy - self.gy
    local distSq = dx * dx + dy * dy
    local range = self.attackRange + 0.5

    if distSq > range * range then
        self.combatState = COMBAT.STATE_SEEKING
        return false
    end

    self.combatState = COMBAT.STATE_ATTACKING

    if self.attackType == COMBAT.ATTACK_RANGED and _G.ProjectileController then
        if self.className == "Crossbowman" then
            _G.ProjectileController:spawnBolt(self, self.target, self.baseDamage)
        else
            _G.ProjectileController:spawnArrow(self, self.target, self.baseDamage)
        end
        return true
    end

    self.target:takeDamage(self.baseDamage, self)
    return true
end

function CombatComponent.findNearestEnemy(self, range)
    range = range or COMBAT.AGGRO_RANGE
    if not _G.state or not _G.state.gameObjectList then return nil end

    local nearestEnemy = nil
    local nearestDistSq = range * range

    for _, otherUnit in ipairs(_G.state.gameObjectList) do
        if otherUnit ~= self
            and otherUnit._combatAttached
            and otherUnit.faction ~= self.faction
            and otherUnit.faction ~= COMBAT.FACTION_NEUTRAL
            and not otherUnit.toBeDeleted
            and otherUnit.health and otherUnit.health > 0
            and otherUnit.gx and otherUnit.gy then

            local dx = otherUnit.gx - self.gx
            local dy = otherUnit.gy - self.gy
            local distSq = dx * dx + dy * dy

            if distSq < nearestDistSq then
                nearestDistSq = distSq
                nearestEnemy = otherUnit
            end
        end
    end

    return nearestEnemy
end

function CombatComponent.isInCombat(self)
    return self.combatState ~= COMBAT.STATE_IDLE and self.combatState ~= COMBAT.STATE_DEAD
end

function CombatComponent.getHealthPercent(self)
    if not self.maxHealth or self.maxHealth <= 0 then return 0 end
    return math.max(0, math.min(1, self.health / self.maxHealth))
end

function CombatComponent.resetCombat(self)
    self.combatState = COMBAT.STATE_IDLE
    self.target = nil
    self.lastAttackTime = 0
end

return CombatComponent
