-- objects/Mission/CampaignProgress.lua
-- Stronghold 2027 - Campaign Progress Tracking
--
-- Tracks which missions the player has completed.
-- Persists between game sessions in campaign_progress.json.
-- Unlocks missions sequentially (must complete mission N to play N+1).

local CampaignProgress = {}

local PROGRESS_FILE = "campaign_progress.json"
local initialized = false

-- All 10 missions in order
local MISSION_LIST = {
    { key = "campaign.mission1_return_to_fernhaven",   name = "Vrnitev v Fernhaven",      difficulty = 1 },
    { key = "campaign.mission2_first_defenders",        name = "Prvi branilci",            difficulty = 2 },
    { key = "campaign.mission3_alliance_with_westmarsh", name = "Zavezništvo z Westmarshem", difficulty = 2 },
    { key = "campaign.mission4_the_iron_hills",         name = "Železni griči",            difficulty = 3 },
    { key = "campaign.mission5_the_bandit_king",        name = "Banditski kralj",          difficulty = 5 },
    { key = "campaign.mission6_betrayal_at_eastvale",   name = "Izdaja pri Eastvalu",      difficulty = 4 },
    { key = "campaign.mission7_the_northern_pass",      name = "Severni prelaz",           difficulty = 5 },
    { key = "campaign.mission8_the_cathedral",          name = "Katedrala",                difficulty = 3 },
    { key = "campaign.mission9_lady_elaras_sacrifice",  name = "Žrtev Lady Elare",         difficulty = 5 },
    { key = "campaign.mission10_the_throne_of_valdemar", name = "Prestol Valdemarja",      difficulty = 5 },
}

-- Progress state
local progress = {
    completedMissions = {},  -- set of mission keys
    currentMission = 1,      -- index of current mission (1-10)
    totalPlaytime = 0,       -- total seconds played
    achievements = {},       -- unlocked achievements
}

function CampaignProgress.init()
    if initialized then return end
    initialized = true
    CampaignProgress.load()
    print("[CampaignProgress] Initialized - " .. CampaignProgress.getCompletedCount() .. "/10 missions completed")
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

    if count >= 1 and not progress.achievements["first_victory"] then
        progress.achievements["first_victory"] = true
        print("[CampaignProgress] Achievement unlocked: First Victory!")
    end

    if count >= 5 and not progress.achievements["halfway"] then
        progress.achievements["halfway"] = true
        print("[CampaignProgress] Achievement unlocked: Halfway There!")
    end

    if count >= 10 and not progress.achievements["king_of_valdemar"] then
        progress.achievements["king_of_valdemar"] = true
        print("[CampaignProgress] Achievement unlocked: King of Valdemar!")
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
