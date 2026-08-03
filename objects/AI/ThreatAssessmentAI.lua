-- objects/AI/ThreatAssessmentAI.lua
-- Stronghold 2027 - Threat Assessment AI
-- AI evaluates player strength and adapts strategy dynamically

local ThreatAI = {}

local initialized = false
local assessmentTimer = 0
local assessmentInterval = 30  -- Assess every 30 seconds
local currentThreat = {}
local playerStrength = {}
local aiAdaptations = {}

function ThreatAI.init()
    if initialized then return end
    initialized = true
    print("[ThreatAI] Initialized (assessment interval: " .. assessmentInterval .. "s)")
end

function ThreatAI.update(dt)
    if not initialized then return end

    assessmentTimer = assessmentTimer + dt
    if assessmentTimer >= assessmentInterval then
        assessmentTimer = 0
        ThreatAI.assess()
    end
end

function ThreatAI.assess()
    if not _G.state then return end

    -- Count player's military units
    local playerUnits = 0
    local playerBuildings = 0
    local militaryBuildings = 0
    local playerGold = _G.state.gold or 0
    local playerPopulation = _G.state.population or 0

    if _G.state.gameObjectList then
        for _, obj in ipairs(_G.state.gameObjectList) do
            if obj.faction == 1 or not obj.faction then
                if obj.class and obj.class.name then
                    local name = obj.class.name
                    -- Count military units
                    if name:match("Archer") or name:match("Crossbow") or name:match("Spear")
                       or name:match("Pikeman") or name:match("Mace") or name:match("Sword")
                       or name:match("Knight") then
                        playerUnits = playerUnits + 1
                    end
                    -- Count buildings
                    if name:match("Barracks") or name:match("Tower") or name:match("Wall") then
                        militaryBuildings = militaryBuildings + 1
                    end
                    playerBuildings = playerBuildings + 1
                end
            end
        end
    end

    -- Calculate threat level (0-100)
    local threatScore = 0
    threatScore = threatScore + playerUnits * 5          -- 5 points per military unit
    threatScore = threatScore + militaryBuildings * 3     -- 3 points per military building
    threatScore = threatScore + math.min(20, playerGold / 100)  -- Up to 20 points for gold
    threatScore = threatScore + math.min(15, playerPopulation / 5)  -- Up to 15 points for pop
    threatScore = math.min(100, threatScore)

    -- Determine threat level
    local threatLevel = "low"
    if threatScore >= 75 then threatLevel = "critical"
    elseif threatScore >= 50 then threatLevel = "high"
    elseif threatScore >= 25 then threatLevel = "medium" end

    -- Store assessment
    currentThreat = {
        score = threatScore,
        level = threatLevel,
        playerUnits = playerUnits,
        playerBuildings = playerBuildings,
        militaryBuildings = militaryBuildings,
        playerGold = playerGold,
        playerPopulation = playerPopulation,
        timestamp = os.time(),
    }

    -- Adapt AI strategy based on threat
    ThreatAI._adapt(threatLevel)

    -- Emit event
    if _G.GameEventBus then
        _G.GameEventBus.emit("threat_assessed", currentThreat)
    end

    print(string.format("[ThreatAI] Threat: %s (%d) | Units: %d | Military: %d | Gold: %d",
        threatLevel, threatScore, playerUnits, militaryBuildings, playerGold))
end

function ThreatAI._adapt(threatLevel)
    local BalanceConfig = require("objects.Config.BalanceConfig")

    if not BalanceConfig.ai then return end

    if threatLevel == "critical" then
        -- Player is very strong — AI becomes defensive
        aiAdaptations = {
            strategy = "defensive",
            attackChance = 0.05,  -- Rarely attacks
            defensePriority = 0.95,
            armyBuildRate = 1.3,  -- Builds army faster
            economyFocus = 0.6,
        }
        if _G.VoiceOver then
            _G.VoiceOver.notify("ai_threat_high", "Igralec je mocan. Okrepiti moramo obrambo.")
        end

    elseif threatLevel == "high" then
        -- Player is strong — AI is cautious
        aiAdaptations = {
            strategy = "cautious",
            attackChance = 0.15,
            defensePriority = 0.85,
            armyBuildRate = 1.1,
            economyFocus = 0.5,
        }

    elseif threatLevel == "medium" then
        -- Balanced
        aiAdaptations = {
            strategy = "balanced",
            attackChance = 0.30,
            defensePriority = 0.70,
            armyBuildRate = 1.0,
            economyFocus = 0.5,
        }

    else  -- low
        -- Player is weak — AI becomes aggressive
        aiAdaptations = {
            strategy = "aggressive",
            attackChance = 0.50,
            defensePriority = 0.50,
            armyBuildRate = 0.9,
            economyFocus = 0.4,
        }
        if _G.VoiceOver then
            _G.VoiceOver.notify("ai_threat_low", "Igralec je slab. Napad!")
        end
    end

    -- Apply to BalanceConfig
    if BalanceConfig.ai.behavior then
        BalanceConfig.ai.behavior.threatAdaptation = aiAdaptations
    end
end

function ThreatAI.getCurrentThreat()
    return currentThreat
end

function ThreatAI.getAdaptations()
    return aiAdaptations
end

function ThreatAI.getStats()
    return {
        assessmentInterval = assessmentInterval,
        timer = assessmentTimer,
        threat = currentThreat,
        adaptations = aiAdaptations,
    }
end

function ThreatAI.setAssessmentInterval(seconds)
    assessmentInterval = math.max(10, seconds)
end

return ThreatAI
