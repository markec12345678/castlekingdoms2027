-- objects/Mission/SkirmishTrailSystem.lua
-- Castle Kingdoms 2027 - Skirmish Trail System
-- 10 progressive skirmish missions with increasing difficulty (like Crusader's trail)

local SkirmishTrail = {}

local TRAIL_MISSIONS = {
    { id = 1,  name = "Prvi spopad",         difficulty = 1, aiCount = 1, aiPersonality = "balanced",   aiDifficulty = "easy",   mapSize = "small",  description = "Enostaven 1v1 spopad proti uravnoteženemu nasprotniku." },
    { id = 2,  name = "Dvojna grožnja",      difficulty = 2, aiCount = 2, aiPersonality = "aggressive",  aiDifficulty = "easy",   mapSize = "small",  description = "Dva agresivna nasprotnika napadata hkrati." },
    { id = 3,  name = "Gozdno opolzno",      difficulty = 2, aiCount = 1, aiPersonality = "defensive",   aiDifficulty = "medium", mapSize = "medium", description = "Obrambni nasprotnik z močnimi zidovi. Uporabi oblegovalna orožja." },
    { id = 4,  name = "Trgovski rival",      difficulty = 3, aiCount = 1, aiPersonality = "economic",     aiDifficulty = "medium", mapSize = "medium", description = "Bogat nasprotnik z močno ekonomijo. Premagaj ga preden postane premočan." },
    { id = 5,  name = "Trolna zaseda",       difficulty = 3, aiCount = 3, aiPersonality = "aggressive",  aiDifficulty = "medium", mapSize = "medium", description = "Trije agresivni nasprotniki. Zgradite obrambo hitro!" },
    { id = 6,  name = "Vojni lord",          difficulty = 4, aiCount = 2, aiPersonality = "aggressive",  aiDifficulty = "hard",   mapSize = "large",  description = "Dva težka agresivna nasprotnika na veliki mapi." },
    { id = 7,  name = "Trdnjava v gorah",    difficulty = 4, aiCount = 1, aiPersonality = "defensive",   aiDifficulty = "hard",   mapSize = "large",  description = "Nepremagljiva obramba. Samo najboljši oblegovalci bodo uspeli." },
    { id = 8,  name = "Zavezništvo zla",     difficulty = 5, aiCount = 4, aiPersonality = "balanced",    aiDifficulty = "hard",   mapSize = "large",  description = "Štirje nasprotniki v zavezništvu. Skoraj nemogoče." },
    { id = 9,  name = "Ekonomski kolaps",    difficulty = 5, aiCount = 2, aiPersonality = "economic",    aiDifficulty = "brutal", mapSize = "huge",   description = "Dva brutalna ekonomska nasprotnika na ogromni mapi." },
    { id = 10, name = "Zadnji boj",          difficulty = 5, aiCount = 3, aiPersonality = "aggressive",  aiDifficulty = "brutal", mapSize = "huge",   description = "Trije brutalni agresivni nasprotniki. Končni preizkus." },
    -- Castle Kingdoms 2027 v2.5.3: 5 new skirmish missions using new AI personalities
    { id = 11, name = "Oblegovalni mojster", difficulty = 3, aiCount = 1, aiPersonality = "siege_master", aiDifficulty = "medium", mapSize = "medium", description = "Nasprotnik specializiran za oblegovalna orožja. Zgradite močne zidove!" },
    { id = 12, name = "Čuvar trdnjave",      difficulty = 4, aiCount = 2, aiPersonality = "fortress_keeper", aiDifficulty = "hard", mapSize = "large", description = "Dva nasprotnika z maksimalno fortifikacijo. Trebuchet-i so ključni!" },
    { id = 13, name = "Plenilski napad",     difficulty = 4, aiCount = 3, aiPersonality = "raider",       aiDifficulty = "hard", mapSize = "large",  description = "Trije plenilci napadajo hitro in pogosto. Obramba je nujna!" },
    { id = 14, name = "Diplomatska kriza",   difficulty = 5, aiCount = 2, aiPersonality = "diplomat",     aiDifficulty = "brutal", mapSize = "huge", description = "Diplomati bodo poskušali skleniti zavezništva proti vam. Preprečite to!" },
    { id = 15, name = "Legendarne legije",   difficulty = 5, aiCount = 4, aiPersonality = "aggressive",   aiDifficulty = "legendary", mapSize = "huge", description = "Štirje legendarni agresivci. Najtežji izziv v igri!" },
}

SkirmishTrail.MISSIONS = TRAIL_MISSIONS

local initialized = false
local currentMission = 0
local completedMissions = {}

function SkirmishTrail.init()
    if initialized then return end
    initialized = true

    -- Load completed missions from save
    local file = love.filesystem.newFile("skirmish_progress.txt")
    if file:open("r") then
        local content = file:read()
        file:close()
        if content then
            for missionId in content:gmatch("(%d+)") do
                completedMissions[tonumber(missionId)] = true
            end
        end
    end

    print("[SkirmishTrail] Initialized (" .. SkirmishTrail.getCompletedCount() .. "/" .. #TRAIL_MISSIONS .. " completed)")
end

function SkirmishTrail.start(missionId)
    if not initialized then SkirmishTrail.init() end

    local mission = TRAIL_MISSIONS[missionId]
    if not mission then
        print("[SkirmishTrail] Unknown mission: " .. tostring(missionId))
        return false
    end

    -- Check if unlocked
    if missionId > 1 and not completedMissions[missionId - 1] then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Misija zaklenjena! Koncaj prejsnjo misijo.")
        end
        return false
    end

    currentMission = missionId

    -- Apply mission settings
    local DifficultyPresets = require("objects.Config.DifficultyPresets")
    DifficultyPresets.set(mission.aiDifficulty)

    local MapSizeSelector = require("objects.Gameplay.MapSizeSelector")
    MapSizeSelector.set(mission.mapSize)

    -- Emit event
    if _G.GameEventBus then
        _G.GameEventBus.emit("skirmish_started", {
            missionId = missionId,
            name = mission.name,
            difficulty = mission.difficulty,
            aiCount = mission.aiCount,
        })
    end

    if _G.VoiceOver then
        _G.VoiceOver.notify("skirmish_started", mission.name)
    end

    print(string.format("[SkirmishTrail] Starting: %s (difficulty: %d, AI: %dx %s/%s)",
        mission.name, mission.difficulty, mission.aiCount, mission.aiPersonality, mission.aiDifficulty))

    return true
end

function SkirmishTrail.complete(missionId)
    if not initialized then return end

    missionId = missionId or currentMission
    if not missionId or missionId < 1 or missionId > #TRAIL_MISSIONS then return end

    completedMissions[missionId] = true

    -- Save progress
    local file = love.filesystem.newFile("skirmish_progress.txt")
    if file:open("w") then
        local parts = {}
        for id, _ in pairs(completedMissions) do
            table.insert(parts, tostring(id))
        end
        file:write(table.concat(parts, ","))
        file:close()
    end

    -- Emit event
    if _G.GameEventBus then
        _G.GameEventBus.emit("skirmish_completed", { missionId = missionId })
    end

    -- Check achievements
    if missionId == 10 and _G.SteamWorks then
        _G.SteamWorks.unlockAchievement("campaign_complete")
    end

    if _G.VoiceOver then
        _G.VoiceOver.missionComplete()
    end

    local nextMission = missionId < #TRAIL_MISSIONS and missionId + 1 or nil
    if _G.ModernUI then
        if nextMission then
            _G.ModernUI.notifySuccess("Misija končana! Naslednja: " .. TRAIL_MISSIONS[nextMission].name)
        else
            _G.ModernUI.notifySuccess("Vse skirmish misije končane! Cestitke!")
        end
    end

    print("[SkirmishTrail] Completed: Mission " .. missionId)
end

function SkirmishTrail.getMission(missionId)
    return TRAIL_MISSIONS[missionId]
end

function SkirmishTrail.getAllMissions()
    local list = {}
    for _, mission in ipairs(TRAIL_MISSIONS) do
        table.insert(list, {
            id = mission.id,
            name = mission.name,
            difficulty = mission.difficulty,
            description = mission.description,
            aiCount = mission.aiCount,
            aiPersonality = mission.aiPersonality,
            aiDifficulty = mission.aiDifficulty,
            mapSize = mission.mapSize,
            completed = completedMissions[mission.id] == true,
            unlocked = mission.id == 1 or completedMissions[mission.id - 1] == true,
        })
    end
    return list
end

function SkirmishTrail.isUnlocked(missionId)
    return missionId == 1 or completedMissions[missionId - 1] == true
end

function SkirmishTrail.isCompleted(missionId)
    return completedMissions[missionId] == true
end

function SkirmishTrail.getCompletedCount()
    local count = 0
    for _ in pairs(completedMissions) do count = count + 1 end
    return count
end

function SkirmishTrail.getTotalCount()
    return #TRAIL_MISSIONS
end

function SkirmishTrail.getCurrentMission()
    return currentMission
end

function SkirmishTrail.getProgress()
    return SkirmishTrail.getCompletedCount() / #TRAIL_MISSIONS
end

function SkirmishTrail.reset()
    completedMissions = {}
    currentMission = 0
    love.filesystem.remove("skirmish_progress.txt")
    print("[SkirmishTrail] Progress reset")
end

return SkirmishTrail
