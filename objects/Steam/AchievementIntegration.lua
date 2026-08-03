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
