-- objects/AI/MilitaryAI.lua
-- Castle Kingdoms 2027 - AI Military Manager
--
-- Handles military decisions for AI factions:
-- - Unit production priorities
-- - Army composition
-- - Attack/defense decisions
-- - Tactical positioning
-- - Target selection

local COMBAT = require("objects.Enums.Combat")

local MilitaryAI = _G.class("MilitaryAI")

-- Army composition templates per personality
local ARMY_COMPOSITIONS = {
    aggressive = {
        { unit = "Maceman", ratio = 0.4 },  -- 40% melee offense
        { unit = "Archer", ratio = 0.3 },   -- 30% ranged
        { unit = "Knight", ratio = 0.2 },   -- 20% heavy cavalry
        { unit = "Spearman", ratio = 0.1 }, -- 10% cheap defenders
    },
    balanced = {
        { unit = "Swordsman", ratio = 0.3 },
        { unit = "Archer", ratio = 0.25 },
        { unit = "Spearman", ratio = 0.2 },
        { unit = "Crossbowman", ratio = 0.15 },
        { unit = "Knight", ratio = 0.1 },
    },
    defensive = {
        { unit = "Pikeman", ratio = 0.35 },   -- defensive infantry
        { unit = "Crossbowman", ratio = 0.3 },-- defensive ranged
        { unit = "Archer", ratio = 0.2 },
        { unit = "Swordsman", ratio = 0.15 },
    },
    economic = {
        { unit = "Mercenary", ratio = 0.4 },  -- buy units instead of training
        { unit = "Knight", ratio = 0.3 },     -- elite units
        { unit = "Crossbowman", ratio = 0.3 },
    },
}

-- Attack formation positions (relative to leader)
local ATTACK_FORMATIONS = {
    line = {
        { 0, 0 }, { 2, 0 }, { -2, 0 }, { 4, 0 }, { -4, 0 },
        { 6, 0 }, { -6, 0 }, { 8, 0 }, { -8, 0 },
    },
    column = {
        { 0, 0 }, { 0, 2 }, { 0, -2 }, { 0, 4 }, { 0, -4 },
        { 0, 6 }, { 0, -6 }, { 0, 8 }, { 0, -8 },
    },
    wedge = {
        { 0, 0 }, { 2, 2 }, { -2, 2 }, { 4, 4 }, { -4, 4 },
        { 6, 6 }, { -6, 6 }, { 8, 8 }, { -8, 8 },
    },
    spread = {
        { 0, 0 }, { 3, 0 }, { -3, 0 }, { 0, 3 }, { 0, -3 },
        { 3, 3 }, { -3, -3 }, { 3, -3 }, { -3, 3 },
    },
}

function MilitaryAI:initialize()
    self.factionStates = {}
    print("[MilitaryAI] Initialized")
end

-- Initialize military state for a faction
function MilitaryAI:initFaction(faction, personality)
    self.factionStates[faction] = {
        personality = personality or "balanced",
        armyComposition = ARMY_COMPOSITIONS[personality] or ARMY_COMPOSITIONS.balanced,
        unitProductionQueue = {},
        currentArmy = {},
        lastAttack = 0,
        lastDefense = 0,
        targetPriority = "keep",  -- keep, military, economy
        formationType = "line",
    }
end

-- Update military AI for a faction
function MilitaryAI:update(faction, dt)
    local state = self.factionStates[faction]
    if not state then return end

    -- Update army composition tracking
    self:updateArmyComposition(faction, state)

    -- Train new units if needed
    self:manageUnitProduction(faction, state)

    -- Tactical decisions
    self:evaluateTacticalSituation(faction, state)
end

-- Update current army composition tracking
function MilitaryAI:updateArmyComposition(faction, state)
    state.currentArmy = {}
    if not _G.state or not _G.state.gameObjectList then return end

    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit.faction == faction and unit._combatAttached then
            local unitType = unit.className or "Unknown"
            if not state.currentArmy[unitType] then
                state.currentArmy[unitType] = 0
            end
            state.currentArmy[unitType] = state.currentArmy[unitType] + 1
        end
    end
end

-- Manage unit production based on desired composition
function MilitaryAI:manageUnitProduction(faction, state)
    local totalArmy = 0
    for _, count in pairs(state.currentArmy) do
        totalArmy = totalArmy + count
    end

    -- Don't exceed army cap (based on difficulty)
    local maxArmy = 30  -- could be modified by difficulty
    if totalArmy >= maxArmy then return end

    -- Find which unit type is most under-represented
    local biggestDeficit = 0
    local neededUnit = nil

    for _, comp in ipairs(state.armyComposition) do
        local desired = comp.ratio * maxArmy
        local current = state.currentArmy[comp.unit] or 0
        local deficit = desired - current
        if deficit > biggestDeficit then
            biggestDeficit = deficit
            neededUnit = comp.unit
        end
    end

    if neededUnit then
        self:queueUnitProduction(faction, state, neededUnit)
    end
end

-- Queue a unit for production
function MilitaryAI:queueUnitProduction(faction, state, unitType)
    -- Check if production building exists
    if not self:hasProductionBuilding(faction, unitType) then
        return false
    end

    table.insert(state.unitProductionQueue, {
        unit = unitType,
        queuedAt = love.timer.getTime(),
    })

    print(string.format("[MilitaryAI %d] Queued unit production: %s", faction, unitType))
    return true
end

-- Check if faction has building to produce this unit
function MilitaryAI:hasProductionBuilding(faction, unitType)
    if not _G.state or not _G.state.gameObjectList then return false end

    -- Map unit types to required buildings
    local buildingRequired = {
        Archer = "Barracks",
        Crossbowman = "Barracks",
        Spearman = "Barracks",
        Pikeman = "StoneBarracks",
        Maceman = "Barracks",
        Swordsman = "StoneBarracks",
        Knight = "StoneBarracks",
        Engineer = "EngineersGuild",
    }

    local required = buildingRequired[unitType] or "Barracks"

    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.faction == faction and obj.class and obj.class.name == required then
            return true
        end
    end

    return false
end

-- Evaluate tactical situation
-- v3.12.157: Now considers faction-wide morale when making decisions
function MilitaryAI:evaluateTacticalSituation(faction, state)
    -- Count friendly vs nearby enemy units
    local friendlyCount = 0
    local enemyCount = 0
    local threats = {}

    if _G.state and _G.state.gameObjectList then
        for _, unit in ipairs(_G.state.gameObjectList) do
            if unit._combatAttached then
                if unit.faction == faction then
                    friendlyCount = friendlyCount + 1
                elseif unit.faction ~= COMBAT.FACTION_NEUTRAL then
                    enemyCount = enemyCount + 1
                    -- Check if near our territory
                    if self:isNearTerritory(faction, unit.gx, unit.gy) then
                        table.insert(threats, unit)
                    end
                end
            end
        end
    end

    -- v3.12.157: Get faction-wide morale state
    local myMorale = self:getFactionMoraleState(faction)
    local enemyMorale = self:getFactionMoraleState(self:findStrongestEnemyFaction(faction))

    -- v3.12.157: Priority 1 - If our morale is BROKEN, retreat immediately
    if myMorale.state == "broken" and friendlyCount > 0 then
        self:orderRetreat(faction, state)
        return
    end

    -- v3.12.157: Priority 2 - If enemy is broken, pursue aggressively (press advantage)
    if enemyMorale.state == "broken" and enemyCount > 0 then
        self:orderPursuit(faction, state)
        return
    end

    -- v3.12.157: Priority 3 - If our morale is shaken, hold position (don't attack)
    if myMorale.state == "shaken" then
        -- Defensive only - don't initiate new attacks
        if #threats > 0 then
            self:orderDefense(faction, state, threats)
        end
        return
    end

    -- v3.12.157: Priority 4 - If enemy is wavering/shaken, attack more aggressively
    -- (lower the threshold for attack)
    local attackThreshold = 8
    if enemyMorale.state == "wavering" then
        attackThreshold = 5  -- Press when enemy wavering
    elseif enemyMorale.state == "shaken" then
        attackThreshold = 3  -- Press harder
    end

    -- Decide on action
    if #threats > 0 then
        -- Under threat, defend
        self:orderDefense(faction, state, threats)
    elseif friendlyCount >= attackThreshold and enemyCount > 0 then
        -- Strong enough to attack
        if love.timer.getTime() - state.lastAttack > 120 then  -- 2 min cooldown
            self:orderAttack(faction, state)
        end
    end
end

-- v3.12.157: Get average morale for a faction (0-100)
-- @param faction number Faction ID
-- @return number Average morale (0-100), or 100 if no units
function MilitaryAI:getFactionMorale(faction)
    if not _G.MoraleSystem then return 100 end
    if not _G.state or not _G.state.gameObjectList then return 100 end

    local totalMorale = 0
    local unitCount = 0
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit.faction == faction and unit._combatAttached
            and unit.health and unit.health > 0
            and not unit.toBeDeleted then
            totalMorale = totalMorale + (_G.MoraleSystem.getMorale(unit) or 100)
            unitCount = unitCount + 1
        end
    end

    if unitCount == 0 then return 100 end
    return totalMorale / unitCount
end

-- v3.12.157: Get faction morale as discrete state
-- @param faction number Faction ID
-- @return table { state = "high"/"wavering"/"shaken"/"breaking"/"broken", avgMorale = number, fleeingCount = number, unitCount = number }
function MilitaryAI:getFactionMoraleState(faction)
    if not _G.MoraleSystem then
        return { state = "high", avgMorale = 100, fleeingCount = 0, unitCount = 0 }
    end
    if not _G.state or not _G.state.gameObjectList then
        return { state = "high", avgMorale = 100, fleeingCount = 0, unitCount = 0 }
    end

    local totalMorale = 0
    local unitCount = 0
    local fleeingCount = 0
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit.faction == faction and unit._combatAttached
            and unit.health and unit.health > 0
            and not unit.toBeDeleted then
            totalMorale = totalMorale + (_G.MoraleSystem.getMorale(unit) or 100)
            unitCount = unitCount + 1
            if _G.MoraleSystem.isFleeing(unit) then
                fleeingCount = fleeingCount + 1
            end
        end
    end

    if unitCount == 0 then
        return { state = "high", avgMorale = 100, fleeingCount = 0, unitCount = 0 }
    end

    local avg = totalMorale / unitCount
    local fleeingRatio = fleeingCount / unitCount
    local stateName
    -- State is determined by the worse of: avg morale OR fleeing ratio
    if avg < 10 or fleeingRatio > 0.5 then
        stateName = "broken"
    elseif avg < 25 or fleeingRatio > 0.25 then
        stateName = "breaking"
    elseif avg < 50 then
        stateName = "shaken"
    elseif avg < 75 then
        stateName = "wavering"
    else
        stateName = "high"
    end

    return {
        state = stateName,
        avgMorale = avg,
        fleeingCount = fleeingCount,
        unitCount = unitCount,
    }
end

-- v3.12.157: Find the strongest enemy faction (by unit count)
-- @param faction number Our faction ID
-- @return number|nil Strongest enemy faction ID
function MilitaryAI:findStrongestEnemyFaction(faction)
    if not _G.state or not _G.state.gameObjectList then return nil end

    local factionCounts = {}
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit._combatAttached and unit.faction and unit.faction ~= faction
            and unit.faction ~= COMBAT.FACTION_NEUTRAL
            and unit.health and unit.health > 0 then
            factionCounts[unit.faction] = (factionCounts[unit.faction] or 0) + 1
        end
    end

    local maxFaction = nil
    local maxCount = 0
    for f, count in pairs(factionCounts) do
        if count > maxCount then
            maxCount = count
            maxFaction = f
        end
    end

    return maxFaction
end

-- v3.12.157: Order all military units to retreat to base
-- Triggered when faction morale is broken (50%+ fleeing or avg morale < 10)
-- @param faction number Faction ID
-- @param state table Faction state
function MilitaryAI:orderRetreat(faction, state)
    local units = self:getMilitaryUnits(faction)
    if #units == 0 then return end

    -- Get faction base position
    local baseGx, baseGy = 50, 50  -- Default fallback
    if state.baseGx then baseGx, baseGy = state.baseGx, state.baseGy end

    -- Find safest direction (away from enemies)
    local avgEnemyX, avgEnemyY, enemyCount = 0, 0, 0
    if _G.state and _G.state.gameObjectList then
        for _, unit in ipairs(units) do
            -- Find nearest enemy to this unit
            local nearestEnemy = nil
            local nearestDist = math.huge
            for _, obj in ipairs(_G.state.gameObjectList) do
                if obj._combatAttached and obj.faction and obj.faction ~= faction
                    and obj.faction ~= COMBAT.FACTION_NEUTRAL
                    and obj.health and obj.health > 0
                    and obj.gx and obj.gy and unit.gx and unit.gy then
                    local dx = obj.gx - unit.gx
                    local dy = obj.gy - unit.gy
                    local d = dx * dx + dy * dy
                    if d < nearestDist then
                        nearestDist = d
                        nearestEnemy = obj
                    end
                end
            end
            if nearestEnemy then
                avgEnemyX = avgEnemyX + nearestEnemy.gx
                avgEnemyY = avgEnemyY + nearestEnemy.gy
                enemyCount = enemyCount + 1
            end
        end
    end

    -- Order each unit to move AWAY from average enemy position, towards base
    for _, unit in ipairs(units) do
        -- Calculate retreat target: opposite direction from enemies, towards base
        local targetX, targetY = baseGx, baseGy
        if enemyCount > 0 and unit.gx and unit.gy then
            local enemyAvgX = avgEnemyX / enemyCount
            local enemyAvgY = avgEnemyY / enemyCount
            -- Direction from enemy to unit (away from enemy)
            local dx = unit.gx - enemyAvgX
            local dy = unit.gy - enemyAvgY
            local len = math.sqrt(dx * dx + dy * dy)
            if len > 0 then
                -- Move 15 tiles in the away direction
                targetX = unit.gx + (dx / len) * 15
                targetY = unit.gy + (dy / len) * 15
                -- Blend with base direction (50% away from enemy, 50% towards base)
                targetX = (targetX + baseGx) / 2
                targetY = (targetY + baseGy) / 2
            end
        end

        -- Clear current target, mark as retreating
        unit.target = nil
        if unit.combatState then
            unit.combatState = COMBAT.STATE_RETREATING
        end

        -- Issue move order
        if unit.gotoUserWaypoint then
            unit:gotoUserWaypoint(math.floor(targetX), math.floor(targetY), nil, nil)
        end
    end

    state.lastRetreat = love.timer.getTime()
    print(string.format("[MilitaryAI %d] RETREAT ordered: %d units retreating (morale broken)",
        faction, #units))

    -- v3.12.164: Play retreat bell at faction base (army-wide signal)
    if _G.ProceduralSFX and state.baseGx and state.baseGy then
        pcall(function() _G.ProceduralSFX.play("retreat_bell", state.baseGx, state.baseGy, 0.7) end)
    end

    -- Notify player if it's an AI faction retreating (visible feedback)
    if _G.NotificationCenter and faction ~= COMBAT.FACTION_PLAYER then
        pcall(function()
            _G.NotificationCenter.combat(string.format(" Sovražnik se umika! (%d enot)", #units))
        end)
    end
end

-- v3.12.157: Order aggressive pursuit of fleeing enemy
-- Triggered when enemy morale is broken (50%+ fleeing or avg morale < 10)
-- @param faction number Faction ID
-- @param state table Faction state
function MilitaryAI:orderPursuit(faction, state)
    if not _G.MoraleSystem then return end
    if not _G.state or not _G.state.gameObjectList then return end

    -- Find all fleeing enemy units
    local fleeingEnemies = {}
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit._combatAttached and unit.faction and unit.faction ~= faction
            and unit.faction ~= COMBAT.FACTION_NEUTRAL
            and unit.health and unit.health > 0
            and not unit.toBeDeleted
            and _G.MoraleSystem.isFleeing(unit) then
            table.insert(fleeingEnemies, unit)
        end
    end

    if #fleeingEnemies == 0 then return end

    -- Order each friendly unit to chase nearest fleeing enemy
    local units = self:getMilitaryUnits(faction)
    if #units == 0 then return end

    local pursuitCount = 0
    for _, unit in ipairs(units) do
        -- Find nearest fleeing enemy
        local nearestFleeing = nil
        local nearestDist = math.huge
        if unit.gx and unit.gy then
            for _, enemy in ipairs(fleeingEnemies) do
                if enemy.gx and enemy.gy then
                    local dx = enemy.gx - unit.gx
                    local dy = enemy.gy - unit.gy
                    local d = dx * dx + dy * dy
                    if d < nearestDist then
                        nearestDist = d
                        nearestFleeing = enemy
                    end
                end
            end
        end

        -- Issue attack order on fleeing enemy (fleeing units can't fight back effectively)
        if nearestFleeing and (unit.combatState == COMBAT.STATE_IDLE
            or unit.combatState == COMBAT.STATE_AGGRO) then
            unit.target = nearestFleeing
            unit.combatState = COMBAT.STATE_AGGRO
            if unit.gotoUserWaypoint and nearestFleeing.gx and nearestFleeing.gy then
                unit:gotoUserWaypoint(nearestFleeing.gx, nearestFleeing.gy, nil, nil)
            end
            pursuitCount = pursuitCount + 1
        end
    end

    state.lastPursuit = love.timer.getTime()
    if pursuitCount > 0 then
        print(string.format("[MilitaryAI %d] PURSUIT ordered: %d units chasing %d fleeing enemies",
            faction, pursuitCount, #fleeingEnemies))
    end
end

-- Check if position is near faction's territory
function MilitaryAI:isNearTerritory(faction, gx, gy)
    if not _G.state or not _G.state.gameObjectList then return false end
    if not gx or not gy then return false end

    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.faction == faction and obj.gx and obj.gy then
            local dx = obj.gx - gx
            local dy = obj.gy - gy
            if dx * dx + dy * dy < 400 then  -- within 20 tiles
                return true
            end
        end
    end
    return false
end

-- Order an attack on enemy
function MilitaryAI:orderAttack(faction, state)
    -- Find best target
    local target = self:findAttackTarget(faction, state)
    if not target then return end

    -- Gather all military units and order attack
    local units = self:getMilitaryUnits(faction)
    if #units < 3 then return end  -- not enough units

    -- Use formation
    local formation = ATTACK_FORMATIONS[state.formationType] or ATTACK_FORMATIONS.line
    for i, unit in ipairs(units) do
        local offset = formation[(i - 1) % #formation + 1]
        local targetX = target.gx + offset[1]
        local targetY = target.gy + offset[2]

        -- Issue attack order
        if unit.target == nil or unit.combatState == COMBAT.STATE_IDLE then
            unit.target = target.unit or target
            unit.combatState = COMBAT.STATE_AGGRO
            if unit.gotoUserWaypoint then
                unit:gotoUserWaypoint(targetX, targetY, nil, nil)
            end
        end
    end

    state.lastAttack = love.timer.getTime()
    print(string.format("[MilitaryAI %d] Attack ordered: %d units → (%d, %d)",
        faction, #units, target.gx, target.gy))
end

-- Find best attack target
function MilitaryAI:findAttackTarget(faction, state)
    if not _G.state or not _G.state.gameObjectList then return nil end

    local targets = {}
    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.faction and obj.faction ~= faction and obj.faction ~= COMBAT.FACTION_NEUTRAL then
            -- Determine target priority
            local priority = 1
            if obj.class and obj.class.name then
                local name = obj.class.name
                if name == "Keep" or name == "WoodenKeep" or name == "SaxonHall" then
                    priority = 10  -- highest priority
                elseif name == "Barracks" or name == "StoneBarracks" then
                    priority = 7
                elseif name == "Stockpile" or name == "Granary" then
                    priority = 5
                elseif name:match("Tower") then
                    priority = 6
                else
                    priority = 3
                end
            end

            table.insert(targets, {
                unit = obj,
                gx = obj.gx,
                gy = obj.gy,
                priority = priority,
            })
        end
    end

    -- Sort by priority (highest first)
    table.sort(targets, function(a, b) return a.priority > b.priority end)

    return targets[1]
end

-- Get all military units for a faction
function MilitaryAI:getMilitaryUnits(faction)
    local units = {}
    if not _G.state or not _G.state.gameObjectList then return units end

    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit.faction == faction and unit._combatAttached
            and unit.className ~= "Peasant"
            and not unit.toBeDeleted
            and unit.health and unit.health > 0 then
            table.insert(units, unit)
        end
    end
    return units
end

-- Order defense against threats
function MilitaryAI:orderDefense(faction, state, threats)
    local units = self:getMilitaryUnits(faction)
    if #units == 0 then return end

    -- Send units to defend against nearest threat
    for i, unit in ipairs(units) do
        local threat = threats[(i - 1) % #threats + 1]
        if threat and unit.combatState == COMBAT.STATE_IDLE then
            unit.target = threat
            unit.combatState = COMBAT.STATE_AGGRO
            if unit.gotoUserWaypoint then
                unit:gotoUserWaypoint(threat.gx, threat.gy, nil, nil)
            end
        end
    end

    state.lastDefense = love.timer.getTime()
    print(string.format("[MilitaryAI %d] Defense ordered: %d units vs %d threats",
        faction, #units, #threats))
end

-- Get next unit to produce
function MilitaryAI:getNextProduction(faction)
    local state = self.factionStates[faction]
    if not state or #state.unitProductionQueue == 0 then return nil end
    return state.unitProductionQueue[1]
end

-- Complete unit production
function MilitaryAI:completeProduction(faction, unitType)
    local state = self.factionStates[faction]
    if not state then return end

    for i, item in ipairs(state.unitProductionQueue) do
        if item.unit == unitType then
            table.remove(state.unitProductionQueue, i)
            break
        end
    end
end

-- Get military stats
function MilitaryAI:getStats(faction)
    local state = self.factionStates[faction]
    if not state then return nil end

    local totalUnits = 0
    for _, count in pairs(state.currentArmy) do
        totalUnits = totalUnits + count
    end

    return {
        personality = state.personality,
        totalUnits = totalUnits,
        armyComposition = state.currentArmy,
        productionQueueSize = #state.unitProductionQueue,
        formation = state.formationType,
        lastAttack = state.lastAttack,
        lastDefense = state.lastDefense,
    }
end

-- Set formation type
function MilitaryAI:setFormation(faction, formationType)
    local state = self.factionStates[faction]
    if state and ATTACK_FORMATIONS[formationType] then
        state.formationType = formationType
    end
end

return MilitaryAI:new()
