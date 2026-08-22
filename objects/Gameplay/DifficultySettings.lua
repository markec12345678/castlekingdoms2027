-- objects/Gameplay/DifficultySettings.lua
-- Castle Kingdoms 2027 v3.12.133 - Difficulty Settings System
--
-- Centralized difficulty modifier system that scales game parameters:
--   * Player gold multiplier (income/expenses)
--   * Production speed multiplier
--   * Build cost multiplier
--   * AI aggression multiplier
--   * Enemy health/damage multiplier
--   * Resource depletion rate
--
-- 5 difficulty levels:
--   * peaceful  — relaxed, no AI aggression, generous resources
--   * easy      — slight bonuses for player, weaker AI
--   * normal    — balanced (default)
--   * hard      — slight AI bonuses, more aggressive
--   * brutal    — AI very aggressive, scarce resources
--
-- Difficulty is persisted in difficulty_setting.txt and applied at game load.
-- Players can change difficulty mid-game (with a warning toast).
--
-- Usage:
--   local Difficulty = require("objects.Gameplay.DifficultySettings")
--   Difficulty.init()
--   Difficulty.set("hard")
--   local mod = Difficulty.getModifier("playerGoldMultiplier")  -- 0.85 for hard

local DifficultySettings = {}

local initialized = false
local currentDifficulty = "normal"
local DIFFICULTY_FILE = "difficulty_setting.txt"

-- Difficulty definitions
-- Each modifier: 1.0 = no change, >1.0 = more, <1.0 = less
local DIFFICULTIES = {
    peaceful = {
        label = "MIRNO",
        labelEn = "Peaceful",
        color = {0.4, 0.85, 0.5},
        icon = "🕊",
        description = "Sproščeno igranje brez AI nasprotnikov, velikodušni viri",
        descriptionEn = "Relaxed gameplay, no AI opponents, generous resources",
        modifiers = {
            playerGoldMultiplier = 1.5,    -- 50% more gold from all sources
            playerProductionMultiplier = 1.3, -- 30% faster production
            playerBuildCostMultiplier = 0.7,  -- 30% cheaper buildings
            playerDamageMultiplier = 1.5,
            playerHealthMultiplier = 1.5,
            enemyDamageMultiplier = 0.5,
            enemyHealthMultiplier = 0.7,
            enemyAggressionMultiplier = 0.0,  -- no AI attacks
            enemySpawnMultiplier = 0.3,
            resourceDepletionMultiplier = 0.5, -- resources deplete slower
            startingGoldBonus = 500,
        },
    },
    easy = {
        label = "LAHKO",
        labelEn = "Easy",
        color = {0.6, 0.9, 0.4},
        icon = "★",
        description = "Rahli bonusi za igralca, šibkejši AI",
        descriptionEn = "Slight bonuses for player, weaker AI",
        modifiers = {
            playerGoldMultiplier = 1.25,
            playerProductionMultiplier = 1.15,
            playerBuildCostMultiplier = 0.85,
            playerDamageMultiplier = 1.2,
            playerHealthMultiplier = 1.2,
            enemyDamageMultiplier = 0.75,
            enemyHealthMultiplier = 0.85,
            enemyAggressionMultiplier = 0.5,
            enemySpawnMultiplier = 0.6,
            resourceDepletionMultiplier = 0.75,
            startingGoldBonus = 200,
        },
    },
    normal = {
        label = "NORMALNO",
        labelEn = "Normal",
        color = {0.85, 0.85, 0.4},
        icon = "⚖",
        description = "Uravnoteženo igranje — default",
        descriptionEn = "Balanced gameplay — default",
        modifiers = {
            playerGoldMultiplier = 1.0,
            playerProductionMultiplier = 1.0,
            playerBuildCostMultiplier = 1.0,
            playerDamageMultiplier = 1.0,
            playerHealthMultiplier = 1.0,
            enemyDamageMultiplier = 1.0,
            enemyHealthMultiplier = 1.0,
            enemyAggressionMultiplier = 1.0,
            enemySpawnMultiplier = 1.0,
            resourceDepletionMultiplier = 1.0,
            startingGoldBonus = 0,
        },
    },
    hard = {
        label = "TEŽKO",
        labelEn = "Hard",
        color = {0.95, 0.6, 0.3},
        icon = "⚔",
        description = "Rahli bonusi za AI, bolj agresivni",
        descriptionEn = "Slight AI bonuses, more aggressive",
        modifiers = {
            playerGoldMultiplier = 0.85,
            playerProductionMultiplier = 0.9,
            playerBuildCostMultiplier = 1.15,
            playerDamageMultiplier = 0.9,
            playerHealthMultiplier = 0.9,
            enemyDamageMultiplier = 1.2,
            enemyHealthMultiplier = 1.15,
            enemyAggressionMultiplier = 1.5,
            enemySpawnMultiplier = 1.3,
            resourceDepletionMultiplier = 1.25,
            startingGoldBonus = 0,
        },
    },
    brutal = {
        label = "BRUTALNO",
        labelEn = "Brutal",
        color = {0.95, 0.3, 0.3},
        icon = "☠",
        description = "Zelo agresiven AI, skromni viri — za mojstre",
        descriptionEn = "Very aggressive AI, scarce resources — for masters",
        modifiers = {
            playerGoldMultiplier = 0.7,
            playerProductionMultiplier = 0.75,
            playerBuildCostMultiplier = 1.35,
            playerDamageMultiplier = 0.8,
            playerHealthMultiplier = 0.75,
            enemyDamageMultiplier = 1.5,
            enemyHealthMultiplier = 1.35,
            enemyAggressionMultiplier = 2.0,
            enemySpawnMultiplier = 1.6,
            resourceDepletionMultiplier = 1.5,
            startingGoldBonus = 0,
        },
    },
}

local DIFFICULTY_ORDER = {"peaceful", "easy", "normal", "hard", "brutal"}

DifficultySettings.DIFFICULTIES = DIFFICULTIES
DifficultySettings.DIFFICULTY_ORDER = DIFFICULTY_ORDER

-- Load persisted difficulty on init
local function loadPersistedDifficulty()
    local ok, content = pcall(love.filesystem.read, DIFFICULTY_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")
        if DIFFICULTIES[content] then
            currentDifficulty = content
            return true
        end
    end
    return false
end

function DifficultySettings.init()
    if initialized then return end
    initialized = true
    loadPersistedDifficulty()
    print("[DifficultySettings] Initialized — current difficulty: " .. currentDifficulty)
end

-- Set the current difficulty
-- @param key string one of: peaceful, easy, normal, hard, brutal
-- @return boolean success
function DifficultySettings.set(key)
    if not DIFFICULTIES[key] then
        return false
    end
    local previous = currentDifficulty
    currentDifficulty = key
    -- Persist
    pcall(love.filesystem.write, DIFFICULTY_FILE, key .. "\n")
    -- Notify via NotificationCenter
    if _G.NotificationCenter then
        local diff = DIFFICULTIES[key]
        pcall(function()
            local priority = key == "brutal" and _G.NotificationCenter.PRIORITY.HIGH
                          or _G.NotificationCenter.PRIORITY.NORMAL
            _G.NotificationCenter.show(
                diff.icon .. " Težavnost: " .. diff.label .. " (" .. diff.labelEn .. ")",
                "system", priority, 5
            )
        end)
    end
    -- Play sound
    if _G.UISoundHelper then
        pcall(function() _G.UISoundHelper.playToggleOn() end)
    end
    print("[DifficultySettings] Difficulty changed: " .. previous .. " -> " .. key)
    return true
end

-- Get the current difficulty key
function DifficultySettings.getCurrent()
    return currentDifficulty
end

-- Get the current difficulty info (label, color, icon, description, modifiers)
function DifficultySettings.getCurrentInfo()
    return DIFFICULTIES[currentDifficulty]
end

-- Get a specific modifier value for the current difficulty
-- @param modifierKey string (e.g. "playerGoldMultiplier")
-- @return number modifier value (1.0 if not found)
function DifficultySettings.getModifier(modifierKey)
    local diff = DIFFICULTIES[currentDifficulty]
    if not diff then return 1.0 end
    return diff.modifiers[modifierKey] or 1.0
end

-- Get a modifier value for a specific difficulty (without changing current)
function DifficultySettings.getModifierFor(difficultyKey, modifierKey)
    local diff = DIFFICULTIES[difficultyKey]
    if not diff then return 1.0 end
    return diff.modifiers[modifierKey] or 1.0
end

-- Get all difficulties info (for UI)
function DifficultySettings.getAll()
    local result = {}
    for _, key in ipairs(DIFFICULTY_ORDER) do
        local diff = DIFFICULTIES[key]
        result[#result + 1] = {
            key = key,
            label = diff.label,
            labelEn = diff.labelEn,
            color = diff.color,
            icon = diff.icon,
            description = diff.description,
            descriptionEn = diff.descriptionEn,
            modifiers = diff.modifiers,
            isCurrent = key == currentDifficulty,
        }
    end
    return result
end

-- Get stats (for stats panel)
function DifficultySettings.getStats()
    local diff = DIFFICULTIES[currentDifficulty]
    return {
        current = currentDifficulty,
        label = diff.label,
        icon = diff.icon,
        color = diff.color,
        totalDifficulties = #DIFFICULTY_ORDER,
    }
end

-- Check if a difficulty is more challenging than another
-- @return boolean true if first is harder than second
function DifficultySettings.isHarderThan(key1, key2)
    local idx1, idx2 = 0, 0
    for i, k in ipairs(DIFFICULTY_ORDER) do
        if k == key1 then idx1 = i end
        if k == key2 then idx2 = i end
    end
    return idx1 > idx2
end

return DifficultySettings
