-- objects/Mission/CampaignProgress.lua
-- Stronghold 2027 - Campaign Progress Tracking
--
-- Tracks which missions the player has completed.
-- Persists between game sessions in campaign_progress.json.
-- Unlocks missions sequentially (must complete mission N to play N+1).

local CampaignProgress = {}

local PROGRESS_FILE = "campaign_progress.json"
local initialized = false

-- Stronghold 2027 v2.5.0: All 21 missions in order (10 Fernhaven + 11 Historical Norman Conquest)
local MISSION_LIST = {
    -- Fernhaven Saga (missions 1-10)
    { key = "campaign.mission1_return_to_fernhaven",   name = "Vrnitev v Fernhaven",      difficulty = 1, era = "Fernhaven Saga" },
    { key = "campaign.mission2_first_defenders",        name = "Prvi branilci",            difficulty = 2, era = "Fernhaven Saga" },
    { key = "campaign.mission3_alliance_with_westmarsh", name = "Zavezništvo z Westmarshem", difficulty = 2, era = "Fernhaven Saga" },
    { key = "campaign.mission4_the_iron_hills",         name = "Železni griči",            difficulty = 3, era = "Fernhaven Saga" },
    { key = "campaign.mission5_the_bandit_king",        name = "Banditski kralj",          difficulty = 5, era = "Fernhaven Saga" },
    { key = "campaign.mission6_betrayal_at_eastvale",   name = "Izdaja pri Eastvalu",      difficulty = 4, era = "Fernhaven Saga" },
    { key = "campaign.mission7_the_northern_pass",      name = "Severni prelaz",           difficulty = 5, era = "Fernhaven Saga" },
    { key = "campaign.mission8_the_cathedral",          name = "Katedrala",                difficulty = 3, era = "Fernhaven Saga" },
    { key = "campaign.mission9_lady_elaras_sacrifice",  name = "Žrtev Lady Elare",         difficulty = 5, era = "Fernhaven Saga" },
    { key = "campaign.mission10_the_throne_of_valdemar", name = "Prestol Valdemarja",      difficulty = 5, era = "Fernhaven Saga" },
    -- Historical: Norman Conquest 1066-1087 (missions 11-21)
    { key = "campaign.mission11_hastings_1066",         name = "Bitka pri Hastingsu (1066)",   difficulty = 4, era = "Norman Conquest" },
    { key = "campaign.mission12_london_1066",           name = "Kronanje v Londonu (1066)",    difficulty = 3, era = "Norman Conquest" },
    { key = "campaign.mission13_harrying_north_1069",   name = "Pustošenje severa (1069)",     difficulty = 5, era = "Norman Conquest" },
    { key = "campaign.mission14_domesday_1086",         name = "Sodni dan Knjiga (1086)",      difficulty = 3, era = "Norman Conquest" },
    { key = "campaign.mission15_welsh_wars_1081",       name = "Valižanski spopadi (1081)",    difficulty = 4, era = "Norman Conquest" },
    { key = "campaign.mission16_robert_rebellion_1078", name = "Robertova vstaja (1078)",      difficulty = 4, era = "Norman Conquest" },
    { key = "campaign.mission17_scottish_borders_1072", name = "Škotska kampanja (1072)",      difficulty = 4, era = "Norman Conquest" },
    { key = "campaign.mission18_danish_invasion_1075",  name = "Danska invazija (1075)",       difficulty = 5, era = "Norman Conquest" },
    { key = "campaign.mission19_earls_revolt_1075",     name = "Vstaja grofov (1075)",         difficulty = 4, era = "Norman Conquest" },
    { key = "campaign.mission20_normandy_defense_1087", name = "Obramba Normandije (1087)",    difficulty = 5, era = "Norman Conquest" },
    { key = "campaign.mission21_legacy_conqueror",      name = "Dediščina Osvajalca (Epilog)", difficulty = 2, era = "Norman Conquest" },
}

-- Progress state
local progress = {
    completedMissions = {},  -- set of mission keys
    currentMission = 1,      -- index of current mission (1-21)
    totalPlaytime = 0,       -- total seconds played
    achievements = {},       -- unlocked achievements
}

function CampaignProgress.init()
    if initialized then return end
    initialized = true
    CampaignProgress.load()
    print("[CampaignProgress] Initialized - " .. CampaignProgress.getCompletedCount() .. "/21 missions completed")
end

-- Load progress from file
function CampaignProgress.load()
    -- Start with defaults
    progress = {
        completedMissions = {},
        currentMission = 1,
        totalPlaytime = 0,
        achievements = {},
    }

    if love.filesystem then
        local content = love.filesystem.read("string", PROGRESS_FILE)
        if content then
            local json = require("libraries.json")
            local ok, loaded = pcall(json.decode, content)
            if ok and type(loaded) == "table" then
                for k, v in pairs(loaded) do
                    progress[k] = v
                end
                print("[CampaignProgress] Progress loaded from " .. PROGRESS_FILE)
            end
        end
    end
end

-- Save progress to file
function CampaignProgress.save()
    if not love.filesystem then return false end
    local json = require("libraries.json")
    local content = json.encode(progress)
    local ok = love.filesystem.write(PROGRESS_FILE, content)
    if ok then
        print("[CampaignProgress] Progress saved")
    end
    return ok
end

-- Mark a mission as completed
function CampaignProgress.completeMission(missionKey)
    if not progress.completedMissions[missionKey] then
        progress.completedMissions[missionKey] = true
        print("[CampaignProgress] Mission completed: " .. missionKey)

        -- Advance current mission
        for i, mission in ipairs(MISSION_LIST) do
            if mission.key == missionKey and i < #MISSION_LIST then
                progress.currentMission = i + 1
                break
            end
        end

        -- Check achievements
        CampaignProgress.checkAchievements()

        CampaignProgress.save()
    end
end

-- Check if a mission is completed
function CampaignProgress.isCompleted(missionKey)
    return progress.completedMissions[missionKey] == true
end

-- Check if a mission is unlocked (previous mission completed)
function CampaignProgress.isUnlocked(missionKey)
    -- First mission is always unlocked
    if missionKey == MISSION_LIST[1].key then return true end

    -- Find the mission index
    local missionIndex = nil
    for i, mission in ipairs(MISSION_LIST) do
        if mission.key == missionKey then
            missionIndex = i
            break
        end
    end

    if not missionIndex then return false end

    -- Previous mission must be completed
    local prevMission = MISSION_LIST[missionIndex - 1]
    if not prevMission then return true end

    return CampaignProgress.isCompleted(prevMission.key)
end

-- Get number of completed missions
function CampaignProgress.getCompletedCount()
    local count = 0
    for _ in pairs(progress.completedMissions) do
        count = count + 1
    end
    return count
end

-- Get current mission index
function CampaignProgress.getCurrentMissionIndex()
    return progress.currentMission or 1
end

-- Get current mission key
function CampaignProgress.getCurrentMissionKey()
    local idx = progress.currentMission or 1
    if MISSION_LIST[idx] then
        return MISSION_LIST[idx].key
    end
    return MISSION_LIST[1].key
end

-- Get all mission info (for UI display)
function CampaignProgress.getMissionList()
    local list = {}
    for i, mission in ipairs(MISSION_LIST) do
        table.insert(list, {
            index = i,
            key = mission.key,
            name = mission.name,
            difficulty = mission.difficulty,
            completed = CampaignProgress.isCompleted(mission.key),
            unlocked = CampaignProgress.isUnlocked(mission.key),
        })
    end
    return list
end

-- Check and unlock achievements
function CampaignProgress.checkAchievements()
    local count = CampaignProgress.getCompletedCount()
    -- Stronghold 2027 v2.3.8: Unlock Steam achievements + show notification
    local SteamWorks = _G.SteamWorks
    local ModernUI = _G.ModernUI or (require("objects.UI.ModernUISystem"))

    if count >= 1 and not progress.achievements["first_victory"] then
        progress.achievements["first_victory"] = true
        print("[CampaignProgress] Achievement unlocked: First Victory!")
        if SteamWorks then pcall(function() SteamWorks.unlockAchievement("first_victory") end) end
        if ModernUI then pcall(function() ModernUI.notifySuccess("Achievement: First Victory!") end) end
    end

    if count >= 5 and not progress.achievements["halfway"] then
        progress.achievements["halfway"] = true
        print("[CampaignProgress] Achievement unlocked: Halfway There!")
        if ModernUI then pcall(function() ModernUI.notifySuccess("Achievement: Halfway There!") end) end
    end

    if count >= 10 and not progress.achievements["king_of_valdemar"] then
        progress.achievements["king_of_valdemar"] = true
        print("[CampaignProgress] Achievement unlocked: King of Valdemar!")
        if SteamWorks then pcall(function() SteamWorks.unlockAchievement("campaign_complete") end) end
        if ModernUI then pcall(function() ModernUI.notifySuccess("Achievement: King of Valdemar!") end) end
        -- Fire game event for other systems
        if _G.GameEventBus then
            pcall(function() _G.GameEventBus.emit("campaign_complete", {count = count}) end)
        end
    end
end

-- Get achievements
function CampaignProgress.getAchievements()
    return {
        first_victory = progress.achievements["first_victory"] == true,
        halfway = progress.achievements["halfway"] == true,
        king_of_valdemar = progress.achievements["king_of_valdemar"] == true,
    }
end

-- Add playtime
function CampaignProgress.addPlaytime(seconds)
    progress.totalPlaytime = (progress.totalPlaytime or 0) + seconds
end

-- Get total playtime
function CampaignProgress.getPlaytime()
    return progress.totalPlaytime or 0
end

-- Reset all progress (for testing)
function CampaignProgress.reset()
    progress = {
        completedMissions = {},
        currentMission = 1,
        totalPlaytime = 0,
        achievements = {},
    }
    CampaignProgress.save()
    print("[CampaignProgress] Progress reset")
end

return CampaignProgress
