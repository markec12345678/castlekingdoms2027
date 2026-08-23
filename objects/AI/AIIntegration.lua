-- objects/AI/AIIntegration.lua
-- Castle Kingdoms 2027 - AI System Integration
--
-- Coordinates all AI subsystems:
-- - AIStrategyController (high-level decisions)
-- - EconomyAI (resource management)
-- - MilitaryAI (army management)
-- - AICommander (execution)
--
-- This is the main entry point for AI - called from game loop
--
-- Usage:
--   local AIIntegration = require("objects.AI.AIIntegration")
--   AIIntegration.init()
--   AIIntegration.update(dt)
--   AIIntegration.spawnAIFaction("aggressive", "medium", gx, gy)

local AIStrategyController = require("objects.AI.AIStrategyController")
local EconomyAI = require("objects.AI.EconomyAI")
local MilitaryAI = require("objects.AI.MilitaryAI")
local AICommander = require("objects.AI.AICommander")
local AIEnhancements = require("objects.AI.AIEnhancements")

local COMBAT = require("objects.Enums.Combat")

local AIIntegration = {}

local initialized = false

-- Initialize AI system
function AIIntegration.init()
    if initialized then return end
    initialized = true

    -- Register globally
    _G.AIStrategyController = AIStrategyController
    _G.EconomyAI = EconomyAI
    _G.MilitaryAI = MilitaryAI
    _G.AICommander = AICommander
    _G.AIEnhancements = AIEnhancements

    print("[AIIntegration] AI system initialized (with enhancements)")
end

-- Spawn a new AI faction
-- @param personality string "aggressive", "balanced", "defensive", "economic"
-- @param difficulty string "easy", "medium", "hard", "brutal"
-- @param baseGx number Base X position
-- @param baseGy number Base Y position
-- @param faction number Optional faction ID (auto-assigned if not provided)
-- @return number faction ID
function AIIntegration.spawnAIFaction(personality, difficulty, baseGx, baseGy, faction)
    AIIntegration.init()

    -- Auto-assign faction ID
    if not faction then
        faction = COMBAT.FACTION_ENEMY_1
        -- Find next available faction
        for _, f in ipairs({COMBAT.FACTION_ENEMY_1, COMBAT.FACTION_ENEMY_2, COMBAT.FACTION_ENEMY_3}) do
            if not AIStrategyController.factions[f] then
                faction = f
                break
            end
        end
    end

    -- Register with all subsystems
    AIStrategyController:registerFaction(faction, personality, difficulty)
    EconomyAI:initFaction(faction, personality)
    MilitaryAI:initFaction(faction, personality)
    AICommander:initFaction(faction, baseGx, baseGy)

    print(string.format("[AIIntegration] Spawned AI faction %d (%s/%s) at (%d, %d)",
        faction, personality, difficulty, baseGx, baseGy))

    return faction
end

-- Update all AI factions
function AIIntegration.update(dt)
    if not initialized then return end

    -- Update strategy (decision making)
    AIStrategyController:update(dt)

    -- Update each faction's economy and military
    for faction, state in pairs(AIStrategyController.factions) do
        EconomyAI:update(faction, dt)
        MilitaryAI:update(faction, dt)
        AICommander:update(faction, dt)

        -- Castle Kingdoms 2027: AI behavior enhancements
        AIEnhancements.update(faction, state, dt)

        -- Execute pending build orders
        AIIntegration.processBuildOrders(faction)

        -- Execute pending unit production
        AIIntegration.processUnitProduction(faction)
    end
end

-- Process build orders for a faction
function AIIntegration.processBuildOrders(faction)
    -- Get next build from EconomyAI
    local nextBuild = EconomyAI:getNextBuild(faction)
    if not nextBuild then return end

    -- Try to place the building
    local success = AICommander:placeBuilding(faction, nextBuild.building)

    if success then
        EconomyAI:completeBuild(faction, nextBuild.building)
    else
        -- Failed to build, will retry next time
        -- Remove if too many attempts
        if nextBuild.attempts and nextBuild.attempts > 3 then
            EconomyAI:completeBuild(faction, nextBuild.building)
        else
            nextBuild.attempts = (nextBuild.attempts or 0) + 1
        end
    end
end

-- Process unit production for a faction
function AIIntegration.processUnitProduction(faction)
    -- Get next unit to produce from MilitaryAI
    local nextUnit = MilitaryAI:getNextProduction(faction)
    if not nextUnit then return end

    -- Try to spawn the unit
    local unit = AICommander:spawnUnit(faction, nextUnit.unit)

    if unit then
        MilitaryAI:completeProduction(faction, nextUnit.unit)
    end
end

-- Force an AI faction to attack immediately
function AIIntegration.forceAttack(faction)
    local state = AIStrategyController.factions[faction]
    if not state then return false end

    state.state = "attacking"
    state.lastAttack = love.timer.getTime()  -- reset cooldown
    return true
end

-- Get info about all AI factions (for debug)
function AIIntegration.getAllFactionsInfo()
    local list = {}
    for faction, _ in pairs(AIStrategyController.factions) do
        local info = AIStrategyController:getFactionInfo(faction)
        if info then
            info.economy = EconomyAI:getStats(faction)
            info.military = MilitaryAI:getStats(faction)
            info.commander = AICommander:getStats(faction)
            table.insert(list, info)
        end
    end
    return list
end

-- Print debug info to console
function AIIntegration.printDebugInfo()
    print("\n=== AI Debug Info ===")
    local factions = AIIntegration.getAllFactionsInfo()
    if #factions == 0 then
        print("No AI factions active")
        return
    end

    for _, info in ipairs(factions) do
        print(string.format("\nFaction %d (%s/%s):", info.faction, info.personality, info.difficulty))
        print(string.format("  State: %s", info.state))
        print(string.format("  Resources: gold=%d, wood=%d, stone=%d, food=%d",
            info.resources.gold, info.resources.wood, info.resources.stone, info.resources.food))
        print(string.format("  Buildings: %d", info.buildingCount))
        print(string.format("  Army size: %d", info.armySize))
        if info.economy then
            print(string.format("  Economy phase: %s, queue: %d", info.economy.phase, info.economy.buildQueueSize))
            print(string.format("  Next build: %s", info.economy.nextBuild))
        end
        if info.military then
            print(string.format("  Military formation: %s, queue: %d", info.military.formation, info.military.productionQueueSize))
        end
        -- v3.12.157: Print morale info per faction
        if MilitaryAI.getFactionMoraleState then
            local morale = MilitaryAI:getFactionMoraleState(info.faction)
            if morale.unitCount > 0 then
                print(string.format("  Morale: %s (%.0f/100, %d/%d fleeing)",
                    morale.state, morale.avgMorale, morale.fleeingCount, morale.unitCount))
            end
        end
    end
    print("===================\n")
end

-- Check if AI system is initialized
function AIIntegration.isInitialized()
    return initialized
end

-- Reset (for new game)
function AIIntegration.reset()
    -- Clear all faction states
    for faction, _ in pairs(AIStrategyController.factions) do
        AIStrategyController.factions[faction] = nil
        EconomyAI.factionStates[faction] = nil
        MilitaryAI.factionStates[faction] = nil
        AICommander.factionStates[faction] = nil
    end
    print("[AIIntegration] Reset")
end

return AIIntegration
