-- objects/AI/MilitaryAI.lua
-- Stronghold 2027 - AI Military Manager
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

    -- Decide on action
    if #threats > 0 then
        -- Under threat, defend
        self:orderDefense(faction, state, threats)
    elseif friendlyCount >= 8 and enemyCount > 0 then
        -- Strong enough to attack
        if love.timer.getTime() - state.lastAttack > 120 then  -- 2 min cooldown
            self:orderAttack(faction, state)
        end
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
