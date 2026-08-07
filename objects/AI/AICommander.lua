-- objects/AI/AICommander.lua
-- Castle Kingdoms 2027 - AI Execution Layer
--
-- Executes decisions from AIStrategyController, EconomyAI, MilitaryAI:
-- - Places buildings at valid locations
-- - Spawns units at barracks
-- - Issues move/attack orders
-- - Manages worker assignments
--
-- This is the bridge between AI decision-making and actual game state

local COMBAT = require("objects.Enums.Combat")
local CombatIntegration = require("objects.Combat.CombatIntegration")

local AICommander = _G.class("AICommander")

function AICommander:initialize()
    self.factionStates = {}
    print("[AICommander] Initialized")
end

-- Initialize commander state for a faction
function AICommander:initFaction(faction, baseGx, baseGy)
    self.factionStates[faction] = {
        baseGx = baseGx or 50,
        baseGy = baseGy or 50,
        buildAttempts = {},  -- Track failed builds
        spawnedThisFrame = 0,
        maxSpawnsPerFrame = 1,  -- limit to avoid lag
    }
end

-- Update commander (process execution queue)
function AICommander:update(faction, dt)
    local state = self.factionStates[faction]
    if not state then return end

    -- Reset per-frame counter
    state.spawnedThisFrame = 0
end

-- Place a building for a faction
-- @param faction number Faction ID
-- @param buildingName string Building class name
-- @param gx number Optional X position (random near base if not provided)
-- @param gy number Optional Y position
-- @return boolean success
function AICommander:placeBuilding(faction, buildingName, gx, gy)
    local state = self.factionStates[faction]
    if not state then return false end

    -- Find a valid position if not provided
    if not gx or not gy then
        gx, gy = self:findBuildLocation(faction, state)
        if not gx then return false end
    end

    -- Check if position is valid
    if not self:isValidBuildLocation(gx, gy) then
        return false
    end

    -- Try to load building class
    local ok, BuildingClass = pcall(require, "objects.Structures." .. buildingName)
    if not ok or not BuildingClass then
        print(string.format("[AICommander %d] Cannot load building: %s", faction, buildingName))
        return false
    end

    -- Spawn the building
    local building = BuildingClass:new(gx, gy, faction)
    if building then
        building.faction = faction
        print(string.format("[AICommander %d] Placed %s at (%d, %d)",
            faction, buildingName, gx, gy))
        return true
    end

    return false
end

-- Find a valid location to build near the base
function AICommander:findBuildLocation(faction, state)
    -- Try random positions near base
    for attempt = 1, 20 do
        local dx = math.random(-15, 15)
        local dy = math.random(-15, 15)
        local gx = state.baseGx + dx
        local gy = state.baseGy + dy

        if gx > 5 and gy > 5 and self:isValidBuildLocation(gx, gy) then
            return gx, gy
        end
    end

    -- Try farther out
    for attempt = 1, 10 do
        local dx = math.random(-25, 25)
        local dy = math.random(-25, 25)
        local gx = state.baseGx + dx
        local gy = state.baseGy + dy

        if gx > 5 and gy > 5 and self:isValidBuildLocation(gx, gy) then
            return gx, gy
        end
    end

    return nil
end

-- Check if a location is valid for building
function AICommander:isValidBuildLocation(gx, gy)
    if not _G.state or not _G.state.map then return false end

    -- Check map bounds
    if gx < 0 or gy < 0 then return false end
    if gx >= _G.state.map:getMapWidthInTiles() then return false end
    if gy >= _G.state.map:getMapHeightInTiles() then return false end

    -- Check if walkable (no obstacles)
    if not _G.state.map:isWalkable(gx, gy) then
        return false
    end

    -- Check if there's already a building there
    if _G.objectFromSubclassAtGlobal then
        local existing = _G.objectFromSubclassAtGlobal(gx, gy, "Structure")
        if existing then return false end
    end

    return true
end

-- Spawn a military unit for a faction
-- @param faction number Faction ID
-- @param unitType string Unit class name
-- @param gx number Optional spawn X (at barracks if not provided)
-- @param gy number Optional spawn Y
-- @return Unit or nil
function AICommander:spawnUnit(faction, unitType, gx, gy)
    local state = self.factionStates[faction]
    if not state then return nil end

    -- Limit spawns per frame
    if state.spawnedThisFrame >= state.maxSpawnsPerFrame then
        return nil
    end

    -- Find spawn position at a barracks
    if not gx or not gy then
        gx, gy = self:findSpawnLocation(faction, unitType)
        if not gx then return nil end
    end

    -- Use CombatIntegration to spawn the unit
    local unit = CombatIntegration.spawnUnit(unitType, gx, gy, faction)
    if unit then
        state.spawnedThisFrame = state.spawnedThisFrame + 1
        print(string.format("[AICommander %d] Spawned %s at (%d, %d)",
            faction, unitType, gx, gy))
    end

    return unit
end

-- Find a suitable spawn location (at a barracks)
function AICommander:findSpawnLocation(faction, unitType)
    if not _G.state or not _G.state.gameObjectList then return nil end

    -- Find a barracks of this faction
    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.faction == faction and obj.class and obj.class.name then
            local name = obj.class.name
            if name == "Barracks" or name == "StoneBarracks"
                or name == "EngineersGuild" or name == "TunnelersGuild" then
                -- Spawn near the barracks
                local gx = obj.gx + math.random(-2, 2)
                local gy = obj.gy + math.random(-2, 2)
                if self:isValidBuildLocation(gx, gy) then
                    return gx, gy
                end
            end
        end
    end

    -- Fallback: spawn near base
    local state = self.factionStates[faction]
    return state.baseGx + math.random(-5, 5), state.baseGy + math.random(-5, 5)
end

-- Order units to move to a position
-- @param faction number Faction ID
-- @param targetGx number Target X
-- @param targetGy number Target Y
-- @param unitCount number Max units to send (optional, default all)
function AICommander:moveUnits(faction, targetGx, targetGy, unitCount)
    if not _G.state or not _G.state.gameObjectList then return 0 end

    local sent = 0
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit.faction == faction and unit._combatAttached
            and not unit.toBeDeleted
            and unit.health and unit.health > 0 then

            if unitCount and sent >= unitCount then break end

            if unit.gotoUserWaypoint then
                unit:gotoUserWaypoint(targetGx, targetGy, nil, nil)
                sent = sent + 1
            end
        end
    end

    return sent
end

-- Order an attack on a specific position
function AICommander:attackPosition(faction, targetGx, targetGy)
    if not _G.state or not _G.state.gameObjectList then return 0 end

    local sent = 0
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit.faction == faction and unit._combatAttached
            and not unit.toBeDeleted
            and unit.health and unit.health > 0
            and unit.combatState == COMBAT.STATE_IDLE then

            -- Find enemy at target position
            local enemy = CombatIntegration.findEnemyAt(targetGx, targetGy)
            if enemy then
                unit.target = enemy
                unit.combatState = COMBAT.STATE_AGGRO
            end

            -- Move toward target
            if unit.gotoUserWaypoint then
                unit:gotoUserWaypoint(targetGx, targetGy, nil, nil)
            end
            sent = sent + 1
        end
    end

    print(string.format("[AICommander %d] Attack ordered: %d units → (%d, %d)",
        faction, sent, targetGx, targetGy))
    return sent
end

-- Set base location for a faction
function AICommander:setBaseLocation(faction, gx, gy)
    if not self.factionStates[faction] then
        self:initFaction(faction, gx, gy)
    else
        self.factionStates[faction].baseGx = gx
        self.factionStates[faction].baseGy = gy
    end
end

-- Get stats
function AICommander:getStats(faction)
    local state = self.factionStates[faction]
    if not state then return nil end

    return {
        baseGx = state.baseGx,
        baseGy = state.baseGy,
        buildAttempts = #state.buildAttempts,
        spawnedThisFrame = state.spawnedThisFrame,
    }
end

return AICommander:new()
