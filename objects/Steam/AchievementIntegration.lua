-- objects/Steam/AchievementIntegration.lua
-- Stronghold 2027 - Achievement Integration
-- Hooks all game events to Steam achievements

local AchievementIntegration = {}

local SteamWorks = nil
local initialized = false
local eventHooks = {}

function AchievementIntegration.init()
    if initialized then return end
    initialized = true

    pcall(function()
        SteamWorks = require("objects.Steam.SteamWorks")
    end)

    if SteamWorks then
        print("[AchievementIntegration] Initialized with SteamWorks")
    else
        print("[AchievementIntegration] Initialized (SteamWorks not available)")
    end

    -- Stronghold 2027 v2.3.9: Subscribe to GameEventBus events
    -- (GameEventBus.integrateAll already calls hookEvent, but we also subscribe
    --  directly to ensure achievements fire even if integrateAll order changes)
    local GameEventBus = _G.GameEventBus
    if GameEventBus then
        pcall(function()
            GameEventBus.on(GameEventBus.EVENTS.BUILDING_BUILT, function(data)
                AchievementIntegration.hookEvent("building_built", data)
            end)
            GameEventBus.on(GameEventBus.EVENTS.UNIT_KILLED, function(data)
                AchievementIntegration.hookEvent("unit_killed", data)
            end)
            GameEventBus.on(GameEventBus.EVENTS.VICTORY, function(data)
                AchievementIntegration.hookEvent("victory", data)
            end)
            GameEventBus.on(GameEventBus.EVENTS.ALLIANCE_FORMED, function(data)
                AchievementIntegration.hookEvent("alliance_formed", data)
            end)
            GameEventBus.on(GameEventBus.EVENTS.TRADE_COMPLETED, function(data)
                AchievementIntegration.hookEvent("trade_completed", data)
            end)
            GameEventBus.on(GameEventBus.EVENTS.GOLD_EARNED, function(data)
                if data and data.total and data.total >= 10000 then
                    AchievementIntegration.hookEvent("gold_threshold", {amount = data.total})
                end
            end)
        end)
        print("[AchievementIntegration] Subscribed to GameEventBus events")
    end
end

-- Hook a game event to achievement checking
function AchievementIntegration.hookEvent(event, data)
    if not initialized or not SteamWorks then return end

    pcall(function()
        SteamWorks.onGameEvent(event, data)
    end)

    -- Additional integration logic
    if event == "building_built" then
        local Stats = require("objects.QA.StatisticsDashboard")
        Stats.trackEvent("building_built", data)

    elseif event == "unit_killed" then
        local Stats = require("objects.QA.StatisticsDashboard")
        Stats.trackEvent("unit_killed")

    elseif event == "victory" then
        local Stats = require("objects.QA.StatisticsDashboard")
        Stats.trackEvent("game_won", data)
        -- Check for no casualties achievement
        if data and data.noCasualties then
            SteamWorks.unlockAchievement("no_casualties")
        end
        -- Check for speed run
        if data and data.duration and data.duration < 600 then
            SteamWorks.unlockAchievement("speed_run")
        end

    elseif event == "alliance_formed" then
        local Stats = require("objects.QA.StatisticsDashboard")
        Stats.trackEvent("alliance_formed")
        -- Check diplomat achievement
        if Stats.getLifetimeStats().totalAlliances and
           Stats.getLifetimeStats().totalAlliances >= 3 then
            SteamWorks.unlockAchievement("diplomate")
        end

    elseif event == "trade_completed" then
        local Stats = require("objects.QA.StatisticsDashboard")
        Stats.trackEvent("trade_completed")
        -- Check trader achievement
        if Stats.getLifetimeStats().totalTrades and
           Stats.getLifetimeStats().totalTrades >= 50 then
            SteamWorks.unlockAchievement("trader")
        end

    elseif event == "gold_threshold" then
        if data and data.amount and data.amount >= 10000 then
            SteamWorks.unlockAchievement("economy_guru")
        end
    end
end

-- Get stats
function AchievementIntegration.getInfo()
    if not SteamWorks then return { available = false } end
    return {
        available = true,
        achievementsUnlocked = SteamWorks.getAchievementCount(),
        info = SteamWorks.getInfo(),
    }
end

return AchievementIntegration
