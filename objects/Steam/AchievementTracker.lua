-- objects/Steam/AchievementTracker.lua
-- Stronghold 2027 v2.7.4 - Achievement Tracker
--
-- Detailed achievement tracking with progress bars, categories, and statistics.
-- Extends SteamWorks with granular progress tracking and display.
--
-- Features:
-- - Progress tracking (e.g., 47/50 trades completed)
-- - Achievement categories (combat, economy, campaign, special)
-- - Rarity tiers (common, rare, epic, legendary)
-- - Unlock dates and statistics
-- - Export/import for backup

local AchievementTracker = {}

-- Achievement definitions with progress tracking
local ACHIEVEMENTS = {
    -- Combat achievements
    first_victory = {
        name = "First Victory", nameSlv = "Prva zmaga",
        desc = "Win your first battle", descSlv = "Zmagaj v svoji prvi bitki",
        category = "combat", rarity = "common",
        progressMax = 1, progressCurrent = 0,
    },
    no_casualties = {
        name = "Flawless", nameSlv = "Brez napak",
        desc = "Win a battle with no losses", descSlv = "Zmagaj brez izgub",
        category = "combat", rarity = "rare",
        progressMax = 1, progressCurrent = 0,
    },
    speed_run = {
        name = "Speed Runner", nameSlv = "Hitrost",
        desc = "Complete mission in under 10 min", descSlv = "Končaj misijo v 10 minutah",
        category = "combat", rarity = "rare",
        progressMax = 1, progressCurrent = 0,
    },
    siege_master = {
        name = "Siege Master", nameSlv = "Mojster obleganja",
        desc = "Destroy 50 buildings with siege weapons",
        descSlv = "Uniči 50 zgradb z oblegovalnimi orožji",
        category = "combat", rarity = "epic",
        progressMax = 50, progressCurrent = 0,
    },
    legendary_army = {
        name = "Legendary Army", nameSlv = "Legendarna armada",
        desc = "Train a Legendary (level 5) unit", descSlv = "Usposobi Legendarno (nivo 5) enoto",
        category = "combat", rarity = "epic",
        progressMax = 1, progressCurrent = 0,
    },
    weather_master = {
        name = "Storm Lord", nameSlv = "Gospodar neviht",
        desc = "Win a battle during a storm", descSlv = "Zmagaj v bitki med nevihto",
        category = "combat", rarity = "rare",
        progressMax = 1, progressCurrent = 0,
    },

    -- Economy achievements
    master_builder = {
        name = "Master Builder", nameSlv = "Mojster gradnje",
        desc = "Build 100 buildings", descSlv = "Zgradi 100 zgradb",
        category = "economy", rarity = "rare",
        progressMax = 100, progressCurrent = 0,
    },
    economy_guru = {
        name = "Economy Guru", nameSlv = "Ekonomski genij",
        desc = "Accumulate 10,000 gold", descSlv = "Zberi 10.000 zlata",
        category = "economy", rarity = "epic",
        progressMax = 10000, progressCurrent = 0,
    },
    trader = {
        name = "Merchant", nameSlv = "Trgovec",
        desc = "Complete 50 trades", descSlv = "Zaključi 50 trgovin",
        category = "economy", rarity = "rare",
        progressMax = 50, progressCurrent = 0,
    },

    -- Campaign achievements
    campaign_complete = {
        name = "Liberator", nameSlv = "Osvoboditelj",
        desc = "Complete the campaign", descSlv = "Končaj kampanjo",
        category = "campaign", rarity = "legendary",
        progressMax = 1, progressCurrent = 0,
    },
    skirmish_trail = {
        name = "Trail Conqueror", nameSlv = "Osvajalec poti",
        desc = "Complete all 15 skirmish missions", descSlv = "Končaj vseh 15 skirmish misij",
        category = "campaign", rarity = "epic",
        progressMax = 15, progressCurrent = 0,
    },
    coop_master = {
        name = "Co-op Master", nameSlv = "Mojster sodelovanja",
        desc = "Complete all 10 co-op missions", descSlv = "Končaj vseh 10 co-op misij",
        category = "campaign", rarity = "epic",
        progressMax = 10, progressCurrent = 0,
    },

    -- Social achievements
    diplomate = {
        name = "Diplomat", nameSlv = "Diplomat",
        desc = "Form 3 alliances in one game", descSlv = "Skleni 3 zavezništva v eni igri",
        category = "social", rarity = "rare",
        progressMax = 3, progressCurrent = 0,
    },
    multiplayer_win = {
        name = "Champion", nameSlv = "Prvak",
        desc = "Win a multiplayer match", descSlv = "Zmagaj v multiplayer tekmi",
        category = "social", rarity = "rare",
        progressMax = 1, progressCurrent = 0,
    },

    -- Special achievements
    hd_enthusiast = {
        name = "Beauty in HD", nameSlv = "HD lepota",
        desc = "Play with HD pipeline for 1 hour", descSlv = "Igraj z HD načinom 1 uro",
        category = "special", rarity = "common",
        progressMax = 3600, progressCurrent = 0,  -- 3600 seconds
    },
}

AchievementTracker.ACHIEVEMENTS = ACHIEVEMENTS

local initialized = false
local unlockedAchievements = {}  -- { id = unlockTimestamp }
local hdPlayTime = 0

function AchievementTracker.init()
    if initialized then return end
    initialized = true
    print("[AchievementTracker] Initialized with " .. AchievementTracker._getCount() .. " achievements")
end

function AchievementTracker._getCount()
    local count = 0
    for _ in pairs(ACHIEVEMENTS) do count = count + 1 end
    return count
end

-- Update progress for an achievement
function AchievementTracker.updateProgress(achievementId, progress)
    local ach = ACHIEVEMENTS[achievementId]
    if not ach then return false end
    if unlockedAchievements[achievementId] then return false end  -- already unlocked

    ach.progressCurrent = math.min(ach.progressMax, progress)

    -- Check if completed
    if ach.progressCurrent >= ach.progressMax then
        AchievementTracker.unlock(achievementId)
    end

    return true
end

-- Add progress to an achievement
function AchievementTracker.addProgress(achievementId, amount)
    local ach = ACHIEVEMENTS[achievementId]
    if not ach then return false end
    return AchievementTracker.updateProgress(achievementId, ach.progressCurrent + (amount or 1))
end

-- Unlock an achievement
function AchievementTracker.unlock(achievementId)
    local ach = ACHIEVEMENTS[achievementId]
    if not ach then return false end
    if unlockedAchievements[achievementId] then return false end  -- already unlocked

    unlockedAchievements[achievementId] = os.time()
    print("[AchievementTracker] UNLOCKED: " .. ach.name)

    -- Notify
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Dosežek: " .. ach.nameSlv .. " (" .. ach.rarity .. ")")
    end

    -- Also unlock in SteamWorks
    if _G.SteamWorks then
        pcall(function() _G.SteamWorks.unlockAchievement(achievementId) end)
    end

    -- Fire event
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("achievement_unlocked", {
            id = achievementId,
            name = ach.name,
            rarity = ach.rarity,
            category = ach.category,
        }) end)
    end

    return true
end

-- Check if achievement is unlocked
function AchievementTracker.isUnlocked(achievementId)
    return unlockedAchievements[achievementId] ~= nil
end

-- Get progress percentage
function AchievementTracker.getProgress(achievementId)
    local ach = ACHIEVEMENTS[achievementId]
    if not ach then return 0 end
    if ach.progressMax == 0 then return 0 end
    return math.min(100, (ach.progressCurrent / ach.progressMax) * 100)
end

-- Get all achievements with status
function AchievementTracker.getAll()
    local result = {}
    for id, ach in pairs(ACHIEVEMENTS) do
        table.insert(result, {
            id = id,
            name = ach.name,
            nameSlv = ach.nameSlv,
            desc = ach.desc,
            descSlv = ach.descSlv,
            category = ach.category,
            rarity = ach.rarity,
            progressCurrent = ach.progressCurrent,
            progressMax = ach.progressMax,
            progressPercent = AchievementTracker.getProgress(id),
            unlocked = AchievementTracker.isUnlocked(id),
            unlockDate = unlockedAchievements[id],
        })
    end
    return result
end

-- Get achievements by category
function AchievementTracker.getByCategory(category)
    local result = {}
    for id, ach in pairs(ACHIEVEMENTS) do
        if ach.category == category then
            table.insert(result, AchievementTracker._getInfo(id))
        end
    end
    return result
end

function AchievementTracker._getInfo(id)
    local ach = ACHIEVEMENTS[id]
    return {
        id = id,
        name = ach.name,
        nameSlv = ach.nameSlv,
        desc = ach.desc,
        descSlv = ach.descSlv,
        category = ach.category,
        rarity = ach.rarity,
        progressCurrent = ach.progressCurrent,
        progressMax = ach.progressMax,
        progressPercent = AchievementTracker.getProgress(id),
        unlocked = AchievementTracker.isUnlocked(id),
        unlockDate = unlockedAchievements[id],
    }
end

-- Get stats
function AchievementTracker.getStats()
    local total = 0
    local unlocked = 0
    local byCategory = {}
    local byRarity = {}

    for id, ach in pairs(ACHIEVEMENTS) do
        total = total + 1
        byCategory[ach.category] = byCategory[ach.category] or {total = 0, unlocked = 0}
        byCategory[ach.category].total = byCategory[ach.category].total + 1
        byRarity[ach.rarity] = byRarity[ach.rarity] or {total = 0, unlocked = 0}
        byRarity[ach.rarity].total = byRarity[ach.rarity].total + 1

        if AchievementTracker.isUnlocked(id) then
            unlocked = unlocked + 1
            byCategory[ach.category].unlocked = byCategory[ach.category].unlocked + 1
            byRarity[ach.rarity].unlocked = byRarity[ach.rarity].unlocked + 1
        end
    end

    return {
        total = total,
        unlocked = unlocked,
        percent = total > 0 and (unlocked / total) * 100 or 0,
        byCategory = byCategory,
        byRarity = byRarity,
    }
end

-- Update HD playtime (called every frame when HD is on)
function AchievementTracker.updateHDTime(dt)
    hdPlayTime = hdPlayTime + dt
    AchievementTracker.updateProgress("hd_enthusiast", math.floor(hdPlayTime))
end

-- Export achievements for backup
function AchievementTracker.export()
    local data = {
        version = 1,
        unlocked = unlockedAchievements,
        progress = {},
        hdPlayTime = hdPlayTime,
    }
    for id, ach in pairs(ACHIEVEMENTS) do
        data.progress[id] = ach.progressCurrent
    end
    return data
end

-- Import achievements from backup
function AchievementTracker.import(data)
    if not data or type(data) ~= "table" then return false end
    unlockedAchievements = data.unlocked or {}
    if data.progress then
        for id, progress in pairs(data.progress) do
            if ACHIEVEMENTS[id] then
                ACHIEVEMENTS[id].progressCurrent = progress
            end
        end
    end
    hdPlayTime = data.hdPlayTime or 0
    print("[AchievementTracker] Imported " .. AchievementTracker.getStats().unlocked .. " unlocked achievements")
    return true
end

return AchievementTracker
