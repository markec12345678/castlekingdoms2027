-- objects/Config/DifficultyPresets.lua
-- Stronghold 2027 - Difficulty Presets
-- Custom difficulty editor with 6 preset levels

local DifficultyPresets = {}

local PRESETS = {
    story = {
        name = "Zgodba",
        description = "Sproščena izkušnja za uživanje v zgodbi.",
        aiDecisionInterval = 6.0,
        aiResourceEfficiency = 0.40,
        aiCheatBonus = 0,
        aiMaxArmySize = 10,
        aiDefenseResponseTime = 15,
        playerStartingBonus = { gold = 200, wood = 20, stone = 10 },
        aiGracePeriod = 480,  -- 8 minutes
    },
    easy = {
        name = "Lahko",
        description = "Začetniku prijazno. AI je počasen in šibek.",
        aiDecisionInterval = 5.0,
        aiResourceEfficiency = 0.55,
        aiCheatBonus = 0,
        aiMaxArmySize = 12,
        aiDefenseResponseTime = 12,
        playerStartingBonus = { gold = 100, wood = 10 },
        aiGracePeriod = 360,  -- 6 minutes
    },
    normal = {
        name = "Normalno",
        description = "Uravnotežena izkušnja za večino igralcev.",
        aiDecisionInterval = 3.0,
        aiResourceEfficiency = 0.75,
        aiCheatBonus = 0,
        aiMaxArmySize = 22,
        aiDefenseResponseTime = 6,
        playerStartingBonus = {},
        aiGracePeriod = 300,  -- 5 minutes
    },
    hard = {
        name = "Težko",
        description = "AI je agresiven in učinkovit. Za izkušene igralce.",
        aiDecisionInterval = 1.5,
        aiResourceEfficiency = 0.90,
        aiCheatBonus = 0.10,
        aiMaxArmySize = 35,
        aiDefenseResponseTime = 3,
        playerStartingBonus = {},
        aiGracePeriod = 240,  -- 4 minutes
    },
    brutal = {
        name = "Brutalno",
        description = "AI je neusmiljen. Samo za najboljše igralce.",
        aiDecisionInterval = 0.8,
        aiResourceEfficiency = 1.0,
        aiCheatBonus = 0.20,
        aiMaxArmySize = 50,
        aiDefenseResponseTime = 1,
        playerStartingBonus = {},
        aiGracePeriod = 180,  -- 3 minutes
    },
    nightmare = {
        name = "Mora",
        description = "Nemogoče? AI dobi polne bonuse in napada takoj.",
        aiDecisionInterval = 0.5,
        aiResourceEfficiency = 1.2,
        aiCheatBonus = 0.35,
        aiMaxArmySize = 70,
        aiDefenseResponseTime = 0,
        playerStartingBonus = {},
        aiGracePeriod = 60,  -- 1 minute
    },
}

DifficultyPresets.PRESETS = PRESETS

local currentPreset = "normal"
local customSettings = nil
local initialized = false

function DifficultyPresets.init()
    if initialized then return end
    initialized = true
    print("[DifficultyPresets] Initialized with " .. DifficultyPresets._getCount() .. " presets")
end

function DifficultyPresets._getCount()
    local c = 0
    for _ in pairs(PRESETS) do c = c + 1 end
    return c
end

function DifficultyPresets.set(presetName)
    if not PRESETS[presetName] then
        print("[DifficultyPresets] Unknown: " .. tostring(presetName))
        return false
    end

    currentPreset = presetName
    customSettings = nil  -- Clear custom when using preset

    -- Apply to BalanceConfig
    local BalanceConfig = require("objects.Config.BalanceConfig")
    local preset = PRESETS[presetName]

    if BalanceConfig.ai and BalanceConfig.ai.difficulties then
        -- Find matching difficulty in BalanceConfig
        local bcKey = presetName
        if presetName == "story" then bcKey = "easy" end
        if presetName == "nightmare" then bcKey = "brutal" end

        if BalanceConfig.ai.difficulties[bcKey] then
            BalanceConfig.ai.difficulties[bcKey].decisionInterval = preset.aiDecisionInterval
            BalanceConfig.ai.difficulties[bcKey].resourceEfficiency = preset.aiResourceEfficiency
            BalanceConfig.ai.difficulties[bcKey].cheatBonus = preset.aiCheatBonus
            BalanceConfig.ai.difficulties[bcKey].maxArmySize = preset.aiMaxArmySize
            BalanceConfig.ai.difficulties[bcKey].defenseResponseTime = preset.aiDefenseResponseTime
        end
    end

    if BalanceConfig.ai and BalanceConfig.ai.behavior then
        BalanceConfig.ai.behavior.attackGracePeriod = preset.aiGracePeriod
    end

    -- Apply player starting bonus
    if _G.state and preset.playerStartingBonus then
        for res, amount in pairs(preset.playerStartingBonus) do
            if res == "gold" then
                _G.state.gold = (_G.state.gold or 0) + amount
            elseif _G.state.resources then
                _G.state.resources[res] = (_G.state.resources[res] or 0) + amount
            end
        end
    end

    if _G.VoiceOver then
        _G.VoiceOver.notify("difficulty_set", preset.name)
    end

    print("[DifficultyPresets] Set to: " .. presetName .. " (" .. preset.name .. ")")
    return true
end

function DifficultyPresets.getCurrent()
    return currentPreset
end

function DifficultyPresets.getCurrentInfo()
    return customSettings or PRESETS[currentPreset]
end

function DifficultyPresets.getAll()
    local list = {}
    for name, preset in pairs(PRESETS) do
        table.insert(list, {
            name = name,
            displayName = preset.name,
            description = preset.description,
        })
    end
    table.sort(list, function(a, b)
        local order = {"story", "easy", "normal", "hard", "brutal", "nightmare"}
        local ai, bi = 99, 99
        for i, n in ipairs(order) do
            if n == a.name then ai = i end
            if n == b.name then bi = i end
        end
        return ai < bi
    end)
    return list
end

-- Set custom difficulty
function DifficultyPresets.setCustom(settings)
    customSettings = {
        name = "Custom",
        description = "Uporabniško definirana težavnost",
        aiDecisionInterval = settings.aiDecisionInterval or 3.0,
        aiResourceEfficiency = settings.aiResourceEfficiency or 0.75,
        aiCheatBonus = settings.aiCheatBonus or 0,
        aiMaxArmySize = settings.aiMaxArmySize or 25,
        aiDefenseResponseTime = settings.aiDefenseResponseTime or 5,
        playerStartingBonus = settings.playerStartingBonus or {},
        aiGracePeriod = settings.aiGracePeriod or 300,
    }
    currentPreset = "custom"
    print("[DifficultyPresets] Custom difficulty set")
end

function DifficultyPresets.cycle()
    local order = {"story", "easy", "normal", "hard", "brutal", "nightmare"}
    local idx = 1
    for i, p in ipairs(order) do
        if p == currentPreset then idx = i break end
    end
    local next = order[(idx % #order) + 1]
    DifficultyPresets.set(next)
    return next
end

return DifficultyPresets
