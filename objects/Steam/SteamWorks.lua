-- objects/Steam/SteamWorks.lua
-- Stronghold 2027 - Steam Integration
--
-- Wrapper for SteamWorks API. Provides:
-- - Achievement tracking
-- - Leaderboard submission
-- - Steam overlay
-- - Workshop mod browsing
-- - Rich presence
--
-- Note: This is a stub implementation. When the game is released on Steam,
-- replace the stub functions with actual SteamWorks API calls using
-- the love-steamworks Lua binding.
--
-- Usage:
--   local SteamWorks = require("objects.Steam.SteamWorks")
--   SteamWorks.init()
--   SteamWorks.unlockAchievement("first_victory")
--   SteamWorks.submitScore("high_score", 15000)

local SteamWorks = {}

local initialized = false
local isSteamRunning = false
local steamId = ""
local achievements = {}
local stats = {}
local richPresence = {}  -- Stronghold 2027 v2.5.0: rich presence data
local overlayUsage = {}  -- Stronghold 2027 v2.5.0: overlay usage tracking

-- Achievement definitions
local ACHIEVEMENTS = {
    first_victory         = { name = "First Victory", desc = "Win your first battle" },
    campaign_complete     = { name = "Liberator", desc = "Complete the campaign" },
    master_builder        = { name = "Master Builder", desc = "Build 100 buildings" },
    economy_guru          = { name = "Economy Guru", desc = "Accumulate 10,000 gold" },
    multiplayer_win       = { name = "Champion", desc = "Win a multiplayer match" },
    no_casualties         = { name = "Flawless", desc = "Win a battle with no losses" },
    speed_run             = { name = "Speed Runner", desc = "Complete mission in under 10 min" },
    diplomate             = { name = "Diplomat", desc = "Form 3 alliances in one game" },
    trader                = { name = "Merchant", desc = "Complete 50 trades" },
    hd_enthusiast         = { name = "Beauty in HD", desc = "Play with HD pipeline for 1 hour" },
    -- Stronghold 2027 v2.5.6: 5 new achievements
    siege_master          = { name = "Siege Master", desc = "Destroy 50 buildings with siege weapons" },
    legendary_army        = { name = "Legendary Army", desc = "Train a Legendary (level 5) unit" },
    skirmish_trail        = { name = "Trail Conqueror", desc = "Complete all 15 skirmish missions" },
    coop_master           = { name = "Co-op Master", desc = "Complete all 10 co-op missions" },
    weather_master        = { name = "Storm Lord", desc = "Win a battle during a storm" },
}

SteamWorks.ACHIEVEMENTS = ACHIEVEMENTS

-- Initialize Steam integration
function SteamWorks.init()
    if initialized then return end
    initialized = true

    -- Try to detect if running through Steam
    -- In production, this would use steamworks.init()
    isSteamRunning = false  -- Stub: set to true when Steam is detected

    -- Load saved achievements
    SteamWorks._loadAchievements()

    print("[SteamWorks] Initialized (running through Steam: " .. tostring(isSteamRunning) .. ")")
end

-- Check if game is running through Steam
function SteamWorks.isSteamRunning()
    return isSteamRunning
end

-- Get Steam ID
function SteamWorks.getSteamId()
    return steamId
end

-- Unlock an achievement
function SteamWorks.unlockAchievement(achievementId)
    if not ACHIEVEMENTS[achievementId] then
        print("[SteamWorks] Unknown achievement: " .. tostring(achievementId))
        return false
    end

    if achievements[achievementId] then
        return false  -- Already unlocked
    end

    achievements[achievementId] = true
    print("[SteamWorks] Achievement unlocked: " .. achievementId .. " - " .. ACHIEVEMENTS[achievementId].name)

    -- In production: steamworks.setAchievement(achievementId)
    SteamWorks._saveAchievements()

    -- Show notification
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Achievement: " .. ACHIEVEMENTS[achievementId].name)
    end

    return true
end

-- Check if achievement is unlocked
function SteamWorks.isAchievementUnlocked(achievementId)
    return achievements[achievementId] == true
end

-- Get all achievements
function SteamWorks.getAllAchievements()
    local result = {}
    for id, def in pairs(ACHIEVEMENTS) do
        result[id] = {
            name = def.name,
            description = def.desc,
            unlocked = achievements[id] == true,
        }
    end
    return result
end

-- Get achievement count
function SteamWorks.getAchievementCount()
    local count = 0
    for _ in pairs(achievements) do
        count = count + 1
    end
    return count
end

-- Set a stat value
function SteamWorks.setStat(statName, value)
    stats[statName] = value
    -- In production: steamworks.setStat(statName, value)
    SteamWorks._saveStats()
end

-- Get a stat value
function SteamWorks.getStat(statName)
    return stats[statName] or 0
end

-- Increment a stat
function SteamWorks.incrementStat(statName, amount)
    amount = amount or 1
    stats[statName] = (stats[statName] or 0) + amount
    SteamWorks._saveStats()
end

-- Submit score to leaderboard
function SteamWorks.submitScore(leaderboardName, score)
    print(string.format("[SteamWorks] Score submitted: %s = %d", leaderboardName, score))
    -- In production: steamworks.uploadScore(leaderboardName, score)
end

-- Set rich presence
function SteamWorks.setRichPresence(key, value)
    -- Stronghold 2027 v2.5.0: Store rich presence locally for display
    if not richPresence then richPresence = {} end
    richPresence[key] = value
    -- In production: steamworks.setRichPresence(key, value)
end

-- Get rich presence value (for UI display)
function SteamWorks.getRichPresence(key)
    return richPresence and richPresence[key] or nil
end

-- Set common rich presence strings
function SteamWorks.setGameStatus(status, details)
    SteamWorks.setRichPresence("steam_display", status)
    SteamWorks.setRichPresence("steam_player_group", details or "")
end

-- Open Steam overlay
function SteamWorks.openOverlay(page)
    -- page: "friends", "community", "players", "settings", "officialgamegroup", "stats"
    print("[SteamWorks] Opening overlay: " .. tostring(page))
    -- Stronghold 2027 v2.5.0: Track overlay usage for analytics
    if not overlayUsage then overlayUsage = {} end
    overlayUsage[page] = (overlayUsage[page] or 0) + 1
    -- In production: steamworks.openOverlay(page)
end

-- Open Steam overlay to a specific URL
function SteamWorks.openOverlayURL(url)
    print("[SteamWorks] Opening overlay URL: " .. tostring(url))
    -- In production: steamworks.openOverlayBrowser(url)
end

-- Stronghold 2027 v2.5.0: Cloud save stub (local file persistence)
function SteamWorks.cloudSave(filename, data)
    -- In production: steamworks.fileWrite(filename, data)
    -- For now: save to love.filesystem (acts as local cloud)
    local file = love.filesystem.newFile("cloud/" .. filename)
    if file:open("w") then
        file:write(data)
        file:close()
        print("[SteamWorks] Cloud save: " .. filename)
        return true
    end
    return false
end

-- Stronghold 2027 v2.5.0: Cloud load stub
function SteamWorks.cloudLoad(filename)
    -- In production: steamworks.fileRead(filename)
    local file = love.filesystem.newFile("cloud/" .. filename)
    if file:open("r") then
        local data = file:read()
        file:close()
        return data
    end
    return nil
end

-- Stronghold 2027 v2.5.0: Check if cloud is available
function SteamWorks.isCloudEnabled()
    -- In production: steamworks.isCloudEnabled()
    return true  -- stub: always available
end

-- Stronghold 2027 v2.5.0: Get overlay usage stats (for analytics)
function SteamWorks.getOverlayUsage()
    return overlayUsage or {}
end

-- Save achievements to file
function SteamWorks._saveAchievements()
    local data = {
        achievements = achievements,
        stats = stats,
    }

    local json = require("objects.Network.NetworkProtocol")
    local file = love.filesystem.newFile("steam_data.json")
    if file:open("w") then
        -- Simple serialization
        local lines = {"return {"}
        table.insert(lines, "  achievements = {")
        for id, unlocked in pairs(achievements) do
            table.insert(lines, string.format("    [%q] = %s,", id, tostring(unlocked)))
        end
        table.insert(lines, "  },")
        table.insert(lines, "  stats = {")
        for name, value in pairs(stats) do
            table.insert(lines, string.format("    [%q] = %s,", name, tostring(value)))
        end
        table.insert(lines, "  },")
        table.insert(lines, "}")
        file:write(table.concat(lines, "\n"))
        file:close()
    end
end

-- Load achievements from file
function SteamWorks._loadAchievements()
    local file = love.filesystem.newFile("steam_data.json")
    if file:open("r") then
        local content = file:read()
        file:close()

        if content then
            local ok, chunk = pcall(load, content)
            if ok and chunk then
                local dataOk, data = pcall(chunk)
                if dataOk and type(data) == "table" then
                    achievements = data.achievements or {}
                    stats = data.stats or {}
                    print("[SteamWorks] Loaded " .. SteamWorks.getAchievementCount() .. " achievements")
                end
            end
        end
    end
end

-- Check and unlock achievement based on game event
function SteamWorks.onGameEvent(event, data)
    if not initialized then return end

    if event == "victory" then
        SteamWorks.unlockAchievement("first_victory")
        if data and data.noCasualties then
            SteamWorks.unlockAchievement("no_casualties")
        end
        if data and data.duration and data.duration < 600 then
            SteamWorks.unlockAchievement("speed_run")
        end

    elseif event == "campaign_complete" then
        SteamWorks.unlockAchievement("campaign_complete")

    elseif event == "building_built" then
        SteamWorks.incrementStat("buildings_built")
        if SteamWorks.getStat("buildings_built") >= 100 then
            SteamWorks.unlockAchievement("master_builder")
        end

    elseif event == "gold_threshold" then
        if data and data.amount >= 10000 then
            SteamWorks.unlockAchievement("economy_guru")
        end

    elseif event == "multiplayer_win" then
        SteamWorks.unlockAchievement("multiplayer_win")

    elseif event == "alliance_formed" then
        SteamWorks.incrementStat("alliances_formed")
        if SteamWorks.getStat("alliances_formed") >= 3 then
            SteamWorks.unlockAchievement("diplomate")
        end

    elseif event == "trade_completed" then
        SteamWorks.incrementStat("trades_completed")
        if SteamWorks.getStat("trades_completed") >= 50 then
            SteamWorks.unlockAchievement("trader")
        end

    -- Stronghold 2027 v2.5.6: New achievement events
    elseif event == "siege_destroy" then
        SteamWorks.incrementStat("buildings_destroyed_siege")
        if SteamWorks.getStat("buildings_destroyed_siege") >= 50 then
            SteamWorks.unlockAchievement("siege_master")
        end

    elseif event == "unit_levelup" then
        if data and data.newLevel and data.newLevel >= 5 then
            SteamWorks.unlockAchievement("legendary_army")
        end

    elseif event == "skirmish_complete" then
        SteamWorks.incrementStat("skirmish_completed")
        if SteamWorks.getStat("skirmish_completed") >= 15 then
            SteamWorks.unlockAchievement("skirmish_trail")
        end

    elseif event == "coop_complete" then
        SteamWorks.incrementStat("coop_completed")
        if SteamWorks.getStat("coop_completed") >= 10 then
            SteamWorks.unlockAchievement("coop_master")
        end

    elseif event == "storm_victory" then
        SteamWorks.unlockAchievement("weather_master")
    end
end

-- Get debug info
function SteamWorks.getInfo()
    return {
        initialized = initialized,
        isSteamRunning = isSteamRunning,
        steamId = steamId,
        achievementsUnlocked = SteamWorks.getAchievementCount(),
        totalAchievements = #ACHIEVEMENTS or 0,
    }
end

return SteamWorks
