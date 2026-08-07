-- objects/Core/GameEventBus.lua
-- Castle Kingdoms 2027 - Centralized Event Bus
-- Connects ALL game systems through publish/subscribe pattern

local GameEventBus = {}

local listeners = {}
local eventHistory = {}
local maxHistory = 100

function GameEventBus.on(eventName, callback)
    if not listeners[eventName] then listeners[eventName] = {} end
    table.insert(listeners[eventName], callback)
    return function() GameEventBus.off(eventName, callback) end
end

function GameEventBus.off(eventName, callback)
    if not listeners[eventName] then return end
    for i, cb in ipairs(listeners[eventName]) do
        if cb == callback then table.remove(listeners[eventName], i) return end
    end
end

function GameEventBus.emit(eventName, data)
    data = data or {}
    table.insert(eventHistory, {name = eventName, data = data, timestamp = love.timer.getTime()})
    if #eventHistory > maxHistory then table.remove(eventHistory, 1) end
    if listeners[eventName] then
        for _, callback in ipairs(listeners[eventName]) do
            local ok, err = pcall(callback, data)
            if not ok then print("[GameEventBus] Error in '" .. eventName .. "': " .. tostring(err)) end
        end
    end
end

function GameEventBus.getHistory() return eventHistory end
function GameEventBus.clearHistory() eventHistory = {} end
function GameEventBus.getListenerCount(name) return listeners[name] and #listeners[name] or 0 end

function GameEventBus.getRegisteredEvents()
    local events = {}
    for name, _ in pairs(listeners) do table.insert(events, name) end
    table.sort(events)
    return events
end

GameEventBus.EVENTS = {
    UNIT_DAMAGED="unit_damaged", UNIT_KILLED="unit_killed", UNIT_TRAINED="unit_trained",
    BUILDING_BUILT="building_built", BUILDING_DESTROYED="building_destroyed",
    BUILDING_PLACED="building_placed", COMBAT_START="combat_start", COMBAT_END="combat_end",
    RESOURCE_GATHERED="resource_gathered", GOLD_EARNED="gold_earned", GOLD_SPENT="gold_spent",
    TRADE_COMPLETED="trade_completed", LOW_RESOURCES="low_resources",
    MISSION_START="mission_start", MISSION_COMPLETE="mission_complete", MISSION_FAILED="mission_failed",
    OBJECTIVE_COMPLETE="objective_complete", NEW_OBJECTIVE="new_objective",
    VICTORY="victory", DEFEAT="defeat", GAME_START="game_start", GAME_END="game_end",
    GAME_SAVE="game_save", GAME_LOAD="game_load",
    ALLIANCE_FORMED="alliance_formed", WAR_DECLARED="war_declared", PEACE_PROPOSED="peace_proposed",
    TRIBUTE_RECEIVED="tribute_received",
    PLAYER_JOINED="player_joined", PLAYER_LEFT="player_left", CHAT_RECEIVED="chat_received",
    HD_PIPELINE_TOGGLED="hd_pipeline_toggled", QUALITY_CHANGED="quality_changed",
    LANGUAGE_CHANGED="language_changed", ACHIEVEMENT_UNLOCKED="achievement_unlocked",
}

local integrated = false

function GameEventBus.integrateAll()
    if integrated then return end
    integrated = true

    -- Combat → Music + Stats
    GameEventBus.on(GameEventBus.EVENTS.UNIT_DAMAGED, function(data)
        pcall(function() require("objects.Audio.DynamicMusicManager").reportCombat(1) end)
        pcall(function() require("objects.QA.StatisticsDashboard").trackEvent("unit_lost") end)
    end)

    -- Unit killed → Stats + Achievements
    GameEventBus.on(GameEventBus.EVENTS.UNIT_KILLED, function(data)
        pcall(function() require("objects.QA.StatisticsDashboard").trackEvent("unit_killed") end)
        pcall(function() require("objects.Steam.AchievementIntegration").hookEvent("unit_killed") end)
    end)

    -- Building built → Stats + Achievements + VoiceOver
    GameEventBus.on(GameEventBus.EVENTS.BUILDING_BUILT, function(data)
        pcall(function() require("objects.QA.StatisticsDashboard").trackEvent("building_built", data) end)
        pcall(function() require("objects.Steam.AchievementIntegration").hookEvent("building_built", data) end)
        pcall(function()
            if data and data.buildingType then
                require("objects.Audio.SlovenianVoiceOver").buildingComplete(data.buildingType)
            end
        end)
    end)

    -- Victory → Stats + Achievements + Music + VoiceOver
    GameEventBus.on(GameEventBus.EVENTS.VICTORY, function(data)
        pcall(function() require("objects.QA.StatisticsDashboard").trackEvent("game_won", data) end)
        pcall(function() require("objects.Steam.AchievementIntegration").hookEvent("victory", data) end)
        pcall(function() require("objects.Audio.DynamicMusicManager").triggerVictory() end)
        pcall(function() require("objects.Audio.SlovenianVoiceOver").battleWon() end)
    end)

    -- Defeat → Stats + Music + VoiceOver
    GameEventBus.on(GameEventBus.EVENTS.DEFEAT, function(data)
        pcall(function() require("objects.QA.StatisticsDashboard").trackEvent("game_lost", data) end)
        pcall(function() require("objects.Audio.DynamicMusicManager").triggerDefeat() end)
        pcall(function() require("objects.Audio.SlovenianVoiceOver").battleLost() end)
    end)

    -- Alliance → Stats + VoiceOver
    GameEventBus.on(GameEventBus.EVENTS.ALLIANCE_FORMED, function(data)
        pcall(function() require("objects.QA.StatisticsDashboard").trackEvent("alliance_formed") end)
        pcall(function()
            if data and data.playerId then
                require("objects.Audio.SlovenianVoiceOver").allianceFormed(data.playerId)
            end
        end)
    end)

    -- War → Stats + VoiceOver
    GameEventBus.on(GameEventBus.EVENTS.WAR_DECLARED, function(data)
        pcall(function() require("objects.QA.StatisticsDashboard").trackEvent("war_declared") end)
        pcall(function()
            if data and data.playerId then
                require("objects.Audio.SlovenianVoiceOver").warDeclared(data.playerId)
            end
        end)
    end)

    -- Trade → Stats + Achievements
    GameEventBus.on(GameEventBus.EVENTS.TRADE_COMPLETED, function(data)
        pcall(function() require("objects.QA.StatisticsDashboard").trackEvent("trade_completed") end)
        pcall(function() require("objects.Steam.AchievementIntegration").hookEvent("trade_completed") end)
    end)

    -- Gold → Stats + Achievements
    GameEventBus.on(GameEventBus.EVENTS.GOLD_EARNED, function(data)
        pcall(function() require("objects.QA.StatisticsDashboard").trackEvent("gold_earned", data) end)
        if data and data.total and data.total >= 10000 then
            pcall(function() require("objects.Steam.AchievementIntegration").hookEvent("gold_threshold", {amount=data.total}) end)
        end
    end)

    -- Save/Load → VoiceOver
    GameEventBus.on(GameEventBus.EVENTS.GAME_SAVE, function()
        pcall(function() require("objects.Audio.SlovenianVoiceOver").gameSaved() end)
    end)
    GameEventBus.on(GameEventBus.EVENTS.GAME_LOAD, function()
        pcall(function() require("objects.Audio.SlovenianVoiceOver").gameLoaded() end)
    end)

    -- Mission → VoiceOver + Steam
    GameEventBus.on(GameEventBus.EVENTS.OBJECTIVE_COMPLETE, function()
        pcall(function() require("objects.Audio.SlovenianVoiceOver").objectiveComplete() end)
    end)
    GameEventBus.on(GameEventBus.EVENTS.MISSION_COMPLETE, function()
        pcall(function() require("objects.Audio.SlovenianVoiceOver").missionComplete() end)
        pcall(function() require("objects.Steam.SteamWorks").onGameEvent("campaign_complete") end)
    end)

    -- HD pipeline → VoiceOver
    GameEventBus.on(GameEventBus.EVENTS.HD_PIPELINE_TOGGLED, function(data)
        pcall(function()
            local VoiceOver = require("objects.Audio.SlovenianVoiceOver")
            if data and data.enabled then VoiceOver.notify("hd_pipeline_on")
            else VoiceOver.notify("hd_pipeline_off") end
        end)
    end)

    -- Achievement → VoiceOver
    GameEventBus.on(GameEventBus.EVENTS.ACHIEVEMENT_UNLOCKED, function(data)
        pcall(function()
            if data and data.name then
                require("objects.Audio.SlovenianVoiceOver").achievementUnlocked(data.name)
            end
        end)
    end)

    print("[GameEventBus] Integrated (" .. #GameEventBus.getRegisteredEvents() .. " event types)")
end

return GameEventBus
