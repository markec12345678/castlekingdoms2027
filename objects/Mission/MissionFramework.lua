-- objects/Mission/MissionFramework.lua
-- Stronghold 2027 - Mission Framework
--
-- Provides a framework for creating and managing campaign missions:
-- - Objective tracking (build X, gather Y, survive Z minutes, etc.)
-- - Win/lose conditions
-- - Mission events (triggers based on game state)
-- - Story dialogues
-- - Mission rewards
--
-- Usage:
--   local MissionFramework = require("objects.Mission.MissionFramework")
--   MissionFramework.loadMission("mission1_return_to_fernhaven")
--   MissionFramework.update(dt)
--   MissionFramework.draw()

local MissionFramework = {}

-- State
local currentMission = nil
local objectives = {}  -- list of objective tables
local events = {}      -- scripted events
local dialogues = {}   -- story dialogues
local missionState = "inactive"  -- inactive, intro, playing, won, lost
local missionTimer = 0
local nextEventIndex = 1
local nextDialogueIndex = 1

-- Objective types
local OBJECTIVE_TYPES = {
    GATHER_RESOURCES = "gather_resources",      -- collect X of resource Y
    BUILD_BUILDING = "build_building",          -- build X of building Y
    RECRUIT_UNITS = "recruit_units",            -- recruit X of unit Y
    REACH_POPULATION = "reach_population",      -- reach X population
    REACH_GOLD = "reach_gold",                  -- accumulate X gold
    SURVIVE_TIME = "survive_time",              -- survive for X seconds
    DESTROY_BUILDINGS = "destroy_buildings",    -- destroy X enemy buildings
    KILL_UNITS = "kill_units",                  -- kill X enemy units
    REACH_POPULARITY = "reach_popularity",      -- reach X popularity
    PROTECT_BUILDING = "protect_building",      -- keep building Y alive for X seconds
}

-- Load a mission from a mission definition
-- @param missionKey string Mission identifier (e.g., "mission1_return_to_fernhaven")
function MissionFramework.loadMission(missionKey)
    -- Try to load mission definition
    local ok, missionData = pcall(require, "saves.Missions." .. missionKey)
    if not ok or not missionData then
        print("[MissionFramework] Could not load mission: " .. missionKey)
        return false
    end

    currentMission = missionData
    objectives = {}
    events = {}
    dialogues = {}
    missionState = "intro"
    missionTimer = 0
    nextEventIndex = 1
    nextDialogueIndex = 1

    -- Load objectives from mission data
    if missionData.objectives then
        for _, objData in ipairs(missionData.objectives) do
            local objective = {
                id = objData.id or #objectives + 1,
                type = objData.type,
                target = objData.target,
                resource = objData.resource,
                building = objData.building,
                unit = objData.unit,
                count = objData.count or 1,
                duration = objData.duration,
                description = objData.description,
                completed = false,
                failed = false,
                progress = 0,
            }
            table.insert(objectives, objective)
        end
    end

    -- Load events
    if missionData.events then
        events = missionData.events
    end

    -- Load dialogues
    if missionData.dialogues then
        dialogues = missionData.dialogues
    end

    print("[MissionFramework] Loaded mission: " .. (missionData.name or missionKey))
    return true
end

-- Start the mission (after intro)
function MissionFramework.startMission()
    if not currentMission then return end
    missionState = "playing"
    print("[MissionFramework] Mission started: " .. (currentMission.name or "unknown"))

    -- Show first dialogue if any
    if #dialogues > 0 then
        MissionFramework.showNextDialogue()
    end
end

-- Update mission framework
function MissionFramework.update(dt)
    if missionState ~= "playing" then return end

    missionTimer = missionTimer + dt

    -- Update objectives
    MissionFramework.updateObjectives(dt)

    -- Check events
    MissionFramework.checkEvents()

    -- Check win/lose conditions
    MissionFramework.checkWinConditions()
    MissionFramework.checkLoseConditions()
end

-- Update all objectives
function MissionFramework.updateObjectives(dt)
    for _, objective in ipairs(objectives) do
        if not objective.completed and not objective.failed then
            MissionFramework.updateObjective(objective, dt)
        end
    end
end

-- Update a single objective
function MissionFramework.updateObjective(objective, dt)
    if objective.type == OBJECTIVE_TYPES.GATHER_RESOURCES then
        local count = MissionFramework.getResourceCount(objective.resource)
        objective.progress = count
        if count >= objective.count then
            MissionFramework.completeObjective(objective)
        end

    elseif objective.type == OBJECTIVE_TYPES.BUILD_BUILDING then
        local count = MissionFramework.countBuildings(objective.building)
        objective.progress = count
        if count >= objective.count then
            MissionFramework.completeObjective(objective)
        end

    elseif objective.type == OBJECTIVE_TYPES.RECRUIT_UNITS then
        local count = MissionFramework.countUnits(objective.unit)
        objective.progress = count
        if count >= objective.count then
            MissionFramework.completeObjective(objective)
        end

    elseif objective.type == OBJECTIVE_TYPES.REACH_POPULATION then
        local pop = _G.state and _G.state.population or 0
        objective.progress = pop
        if pop >= objective.target then
            MissionFramework.completeObjective(objective)
        end

    elseif objective.type == OBJECTIVE_TYPES.REACH_GOLD then
        local gold = _G.state and _G.state.gold or 0
        objective.progress = gold
        if gold >= objective.target then
            MissionFramework.completeObjective(objective)
        end

    elseif objective.type == OBJECTIVE_TYPES.SURVIVE_TIME then
        objective.progress = missionTimer
        if missionTimer >= objective.duration then
            MissionFramework.completeObjective(objective)
        end

    elseif objective.type == OBJECTIVE_TYPES.REACH_POPULARITY then
        local pop = _G.state and _G.state.popularity or 0
        objective.progress = pop
        if pop >= objective.target then
            MissionFramework.completeObjective(objective)
        end

    elseif objective.type == OBJECTIVE_TYPES.PROTECT_BUILDING then
        -- Check if building still exists
        local exists = MissionFramework.countBuildings(objective.building) > 0
        if not exists then
            objective.failed = true
            MissionFramework.onObjectiveFailed(objective)
        else
            objective.progress = missionTimer
            if missionTimer >= objective.duration then
                MissionFramework.completeObjective(objective)
            end
        end
    end
end

-- Complete an objective
function MissionFramework.completeObjective(objective)
    objective.completed = true
    print("[MissionFramework] Objective completed: " .. objective.description)

    local ModernUI = require("objects.UI.ModernUISystem")
    ModernUI.notifySuccess("Objective complete: " .. objective.description)
end

-- Objective failed
function MissionFramework.onObjectiveFailed(objective)
    print("[MissionFramework] Objective FAILED: " .. objective.description)

    local ModernUI = require("objects.UI.ModernUISystem")
    ModernUI.notifyError("Objective failed: " .. objective.description)
end

-- Check events (scripted triggers)
function MissionFramework.checkEvents()
    while nextEventIndex <= #events do
        local event = events[nextEventIndex]
        if event.triggerTime and missionTimer >= event.triggerTime then
            MissionFramework.triggerEvent(event)
            nextEventIndex = nextEventIndex + 1
        elseif event.triggerCondition and event.triggerCondition() then
            MissionFramework.triggerEvent(event)
            nextEventIndex = nextEventIndex + 1
        else
            break
        end
    end
end

-- Trigger a scripted event
function MissionFramework.triggerEvent(event)
    print("[MissionFramework] Event: " .. (event.name or "unnamed"))

    if event.type == "dialogue" then
        MissionFramework.showDialogue(event.dialogue)

    elseif event.type == "spawn_enemy" then
        MissionFramework.spawnEnemyUnits(event.units, event.location)

    elseif event.type == "give_resources" then
        MissionFramework.giveResources(event.resources)

    elseif event.type == "notification" then
        local ModernUI = require("objects.UI.ModernUISystem")
        ModernUI.notify(event.message, event.notifType or "info", event.duration or 5)

    elseif event.type == "set_weather" then
        local WeatherSystem = require("objects.Weather.WeatherSystem")
        WeatherSystem.setWeather(event.weather)

    elseif event.type == "set_time" then
        local LightingSystem = require("objects.Environment.LightingSystem")
        LightingSystem.setTimePeriod(event.timePeriod)
    end
end

-- Show next dialogue in sequence
function MissionFramework.showNextDialogue()
    if nextDialogueIndex > #dialogues then return end
    MissionFramework.showDialogue(dialogues[nextDialogueIndex])
    nextDialogueIndex = nextDialogueIndex + 1
end

-- Show a dialogue
function MissionFramework.showDialogue(dialogue)
    local ModernUI = require("objects.UI.ModernUISystem")
    local message = dialogue.character .. ": " .. dialogue.text
    ModernUI.notify(message, "info", 8)
    print("[Dialogue] " .. message)
end

-- Spawn enemy units for mission
function MissionFramework.spawnEnemyUnits(unitList, location)
    local CombatIntegration = require("objects.Combat.CombatIntegration")
    local COMBAT = require("objects.Enums.Combat")

    for _, unitInfo in ipairs(unitList) do
        CombatIntegration.spawnUnit(
            unitInfo.type,
            location.gx + (unitInfo.offsetX or 0),
            location.gy + (unitInfo.offsetY or 0),
            unitInfo.faction or COMBAT.FACTION_ENEMY_1
        )
    end
end

-- Give resources to player
function MissionFramework.giveResources(resources)
    if not _G.state then return end
    for resource, amount in pairs(resources) do
        if resource == "gold" then
            _G.state.gold = (_G.state.gold or 0) + amount
        elseif resource == "wood" then
            -- Add to stockpile (would need actual stockpile integration)
        elseif resource == "stone" then
            -- Add to stockpile
        end
    end
end

-- Get resource count
function MissionFramework.getResourceCount(resource)
    -- This would query the actual stockpile
    -- For now, return 0 (placeholder)
    return 0
end

-- Count buildings of a type (player's)
function MissionFramework.countBuildings(buildingName)
    if not _G.state or not _G.state.gameObjectList then return 0 end

    local count = 0
    for _, obj in ipairs(_G.state.gameObjectList) do
        if (not obj.faction or obj.faction == COMBAT.FACTION_PLAYER)  -- COMBAT.FACTION_PLAYER
            and obj.class and obj.class.name == buildingName then
            count = count + 1
        end
    end
    return count
end

-- Count units of a type (player's)
function MissionFramework.countUnits(unitType)
    if not _G.state or not _G.state.gameObjectList then return 0 end

    local count = 0
    for _, obj in ipairs(_G.state.gameObjectList) do
        if (not obj.faction or obj.faction == COMBAT.FACTION_PLAYER)
            and obj.className == unitType then
            count = count + 1
        end
    end
    return count
end

-- Check win conditions
function MissionFramework.checkWinConditions()
    if not currentMission then return end

    -- All objectives completed?
    local allComplete = true
    for _, obj in ipairs(objectives) do
        if not obj.completed then
            allComplete = false
            break
        end
    end

    if allComplete and #objectives > 0 then
        MissionFramework.onMissionWon()
    end
end

-- Check lose conditions
function MissionFramework.checkLoseConditions()
    if not currentMission then return end

    -- Check if any critical objective failed
    for _, obj in ipairs(objectives) do
        if obj.failed and obj.critical then
            MissionFramework.onMissionLost()
            return
        end
    end

    -- Check if keep was destroyed
    if _G.state and _G.state.gameObjectList then
        local hasKeep = false
        for _, obj in ipairs(_G.state.gameObjectList) do
            if (not obj.faction or obj.faction == COMBAT.FACTION_PLAYER) and obj.class and obj.class.name then
                local name = obj.class.name
                if name == "Keep" or name == "WoodenKeep" or name == "SaxonHall" then
                    hasKeep = true
                    break
                end
            end
        end
        if not hasKeep and missionTimer > 5 then  -- grace period at start
            MissionFramework.onMissionLost()
        end
    end
end

-- Mission won
function MissionFramework.onMissionWon()
    if missionState == "won" then return end
    missionState = "won"

    print("[MissionFramework] MISSION WON!")

    local ModernUI = require("objects.UI.ModernUISystem")
    ModernUI.notifySuccess("MISSION COMPLETE! " .. (currentMission.name or ""), 10)

    -- Give rewards
    if currentMission.rewards then
        MissionFramework.giveResources(currentMission.rewards)
    end

    -- Stronghold 2027: Show mission end screen
    local ok, MissionEndScreen = pcall(require, "states.ui.hud.mission_end_screen")
    if ok and MissionEndScreen then
        local stats = {
            time = missionTimer,
            missionName = currentMission.nameSlv or currentMission.name,
            goldEarned = currentMission.rewards and currentMission.rewards.gold or 0,
        }
        MissionEndScreen.show("victory", stats)
    end
end

-- Mission lost
function MissionFramework.onMissionLost()
    if missionState == "lost" then return end
    missionState = "lost"

    print("[MissionFramework] MISSION LOST!")

    local ModernUI = require("objects.UI.ModernUISystem")
    ModernUI.notifyError("MISSION FAILED! " .. (currentMission.name or ""), 10)

    -- Stronghold 2027: Show mission end screen
    local ok, MissionEndScreen = pcall(require, "states.ui.hud.mission_end_screen")
    if ok and MissionEndScreen then
        local stats = {
            time = missionTimer,
            missionName = currentMission.nameSlv or currentMission.name,
        }
        MissionEndScreen.show("defeat", stats)
    end
end

-- Get current mission info
function MissionFramework.getMissionInfo()
    if not currentMission then return nil end

    local completedObjectives = 0
    for _, obj in ipairs(objectives) do
        if obj.completed then completedObjectives = completedObjectives + 1 end
    end

    return {
        name = currentMission.name,
        nameSlv = currentMission.nameSlv,
        description = currentMission.description,
        state = missionState,
        timer = missionTimer,
        objectiveCount = #objectives,
        completedObjectives = completedObjectives,
        objectives = objectives,
    }
end

-- Get current mission state
function MissionFramework.getState()
    return missionState
end

-- End mission (manually)
function MissionFramework.endMission()
    currentMission = nil
    objectives = {}
    events = {}
    dialogues = {}
    missionState = "inactive"
    missionTimer = 0
end

-- Draw mission UI (objectives, timer)
function MissionFramework.draw()
    if missionState == "inactive" or not currentMission then return end

    -- Draw objectives panel (top-right)
    local startX = love.graphics.getWidth() - 280
    local startY = 60

    -- Background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", startX - 5, startY - 5, 270, #objectives * 20 + 50)

    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(currentMission.nameSlv or currentMission.name or "Mission", startX, startY)

    -- Timer
    local minutes = math.floor(missionTimer / 60)
    local seconds = math.floor(missionTimer % 60)
    love.graphics.print(string.format("Time: %d:%02d", minutes, seconds), startX, startY + 20)

    -- Objectives
    for i, obj in ipairs(objectives) do
        local y = startY + 40 + (i - 1) * 20
        local symbol = obj.completed and "✓" or (obj.failed and "✗" or "○")
        local color = obj.completed and {0.3, 1, 0.3} or (obj.failed and {1, 0.3, 0.3} or {1, 1, 1})

        love.graphics.setColor(color[1], color[2], color[3], 1)
        love.graphics.print(symbol .. " " .. obj.description, startX, y)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return MissionFramework
