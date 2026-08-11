-- objects/Config/DynamicDifficultyAdjuster.lua
-- Castle Kingdoms 2027 v2.9.8 - Dynamic Difficulty Adjuster (DDA)
--
-- Automatically adjusts game difficulty in real-time based on player performance.
-- Keeps the game challenging but never frustrating.
--
-- Features:
-- - Tracks player performance metrics (win rate, resource flow, army ratio)
-- - 5 adjustment factors (AI aggression, resource bonus, enemy stats, spawn rate, event frequency)
-- - Smooth transitions (no sudden difficulty spikes)
-- - Player-configurable target difficulty
-- - Performance history tracking
-- - Visual indicator of current adjustment level

local DDA = {}

-- Adjustment factors (0.5 = easier, 1.0 = normal, 1.5 = harder)
local FACTORS = {
    aiAggression = { current = 1.0, target = 1.0, min = 0.5, max = 1.5, label = "AI Agresivnost" },
    resourceBonus = { current = 1.0, target = 1.0, min = 0.5, max = 1.5, label = "Bonus surovin" },
    enemyHealth = { current = 1.0, target = 1.0, min = 0.7, max = 1.3, label = "HP sovražnikov" },
    enemyDamage = { current = 1.0, target = 1.0, min = 0.7, max = 1.3, label = "DMG sovražnikov" },
    eventFrequency = { current = 1.0, target = 1.0, min = 0.5, max = 1.5, label = "Frekvenca dogodkov" },
}

DDA.FACTORS = FACTORS

local initialized = false
local enabled = true
local smoothing = 0.02  -- how fast adjustments happen (per second)
local updateTimer = 0
local updateInterval = 10.0  -- recalculate every 10 seconds
local performanceHistory = {}
local maxHistory = 30
local playerScore = 0  -- -100 (struggling) to +100 (dominating)
local adjustmentLevel = "Normalno"
local targetDifficulty = 1.0  -- player's chosen difficulty target

function DDA.init()
    if initialized then return end
    initialized = true
    print("[DDA] Initialized — smoothing: " .. smoothing .. ", interval: " .. updateInterval .. "s")
end

-- Calculate player performance score
function DDA._calculateScore()
    local score = 0

    -- Factor 1: Army ratio (player units vs enemy units)
    local playerUnits = 0
    local enemyUnits = 0
    if _G.state and _G.state.gameObjectList then
        for _, obj in ipairs(_G.state.gameObjectList) do
            if obj._combatAttached and obj.health and obj.health > 0 then
                if not obj.faction or obj.faction == 1 then
                    playerUnits = playerUnits + 1
                elseif obj.faction ~= 5 then
                    enemyUnits = enemyUnits + 1
                end
            end
        end
    end
    if enemyUnits > 0 then
        local ratio = playerUnits / enemyUnits
        if ratio > 2.0 then score = score + 30
        elseif ratio > 1.5 then score = score + 15
        elseif ratio < 0.5 then score = score - 30
        elseif ratio < 0.8 then score = score - 15 end
    end

    -- Factor 2: Gold reserves
    if _G.state then
        local gold = _G.state.gold or 0
        if gold > 5000 then score = score + 20
        elseif gold > 2000 then score = score + 10
        elseif gold < 200 then score = score - 20
        elseif gold < 500 then score = score - 10 end
    end

    -- Factor 3: Population
    if _G.state then
        local pop = _G.state.population or 0
        local maxPop = _G.state.maxPopulation or 0
        if maxPop > 0 then
            local popRatio = pop / maxPop
            if popRatio > 0.8 then score = score + 15
            elseif popRatio < 0.3 then score = score - 15 end
        end
    end

    -- Factor 4: Happiness
    if _G.state then
        local happiness = _G.state.popularity or 50
        if happiness > 70 then score = score + 10
        elseif happiness < 30 then score = score - 10 end
    end

    -- Factor 5: Recent combat (from Analytics)
    if _G.Analytics then
        local stats = _G.Analytics.getSessionStats()
        if stats.unitsLost and stats.enemiesKilled then
            if stats.enemiesKilled > 0 then
                local kd = stats.enemiesKilled / math.max(1, stats.unitsLost)
                if kd > 3.0 then score = score + 20
                elseif kd > 1.5 then score = score + 10
                elseif kd < 0.5 then score = score - 20
                elseif kd < 0.8 then score = score - 10 end
            end
        end
    end

    -- Clamp score
    playerScore = math.max(-100, math.min(100, score))

    -- Record in history
    table.insert(performanceHistory, {
        score = playerScore,
        timestamp = os.time(),
    })
    while #performanceHistory > maxHistory do
        table.remove(performanceHistory, 1)
    end

    return playerScore
end

-- Adjust difficulty based on score
function DDA._adjust()
    if not enabled then return end

    local score = DDA._calculateScore()

    -- If player is dominating (high score), make game harder
    -- If player is struggling (low score), make game easier
    -- Scale: score +100 → +50% difficulty, score -100 → -50% difficulty
    local adjustment = 1.0 + (score / 100) * 0.5 * targetDifficulty

    -- Set targets for each factor
    FACTORS.aiAggression.target = math.max(0.5, math.min(1.5, adjustment))
    FACTORS.resourceBonus.target = math.max(0.5, math.min(1.5, 2.0 - adjustment))  -- inverse: more resources when struggling
    FACTORS.enemyHealth.target = math.max(0.7, math.min(1.3, adjustment))
    FACTORS.enemyDamage.target = math.max(0.7, math.min(1.3, adjustment))
    FACTORS.eventFrequency.target = math.max(0.5, math.min(1.5, adjustment))

    -- Determine adjustment level label
    if score > 50 then adjustmentLevel = "Težje (igralec dominira)"
    elseif score > 20 then adjustmentLevel = "Rahlo težje"
    elseif score > -20 then adjustmentLevel = "Normalno"
    elseif score > -50 then adjustmentLevel = "Rahlo lažje"
    else adjustmentLevel = "Lažje (igralec se bori)" end
end

-- Update (smooth transitions)
function DDA.update(dt)
    if not initialized then return end

    -- Smooth factor transitions
    for _, factor in pairs(FACTORS) do
        local diff = factor.target - factor.current
        factor.current = factor.current + diff * smoothing * dt * 60  -- frame-rate independent
    end

    -- Periodic recalculation
    updateTimer = updateTimer + dt
    if updateTimer >= updateInterval then
        updateTimer = 0
        DDA._adjust()
    end
end

-- Get a factor value (for other systems to use)
function DDA.getFactor(factorName)
    if not FACTORS[factorName] then return 1.0 end
    if not enabled then return 1.0 end
    return FACTORS[factorName].current
end

-- Set target difficulty (player preference)
function DDA.setTargetDifficulty(difficulty)
    targetDifficulty = math.max(0.5, math.min(2.0, difficulty))
    return targetDifficulty
end

-- Toggle DDA on/off
function DDA.toggle()
    enabled = not enabled
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Dynamic Difficulty: " .. (enabled and "ON" or "OFF"))
    end
    return enabled
end

-- Force recalculation
function DDA.recalculate()
    return DDA._adjust()
end

-- Get current state
function DDA.getState()
    return {
        enabled = enabled,
        playerScore = playerScore,
        adjustmentLevel = adjustmentLevel,
        targetDifficulty = targetDifficulty,
        factors = {
            aiAggression = FACTORS.aiAggression.current,
            resourceBonus = FACTORS.resourceBonus.current,
            enemyHealth = FACTORS.enemyHealth.current,
            enemyDamage = FACTORS.enemyDamage.current,
            eventFrequency = FACTORS.eventFrequency.current,
        },
        nextUpdateIn = math.ceil(updateInterval - updateTimer),
    }
end

-- Get performance history
function DDA.getHistory()
    return performanceHistory
end

-- Get stats
function DDA.getStats()
    local avgScore = 0
    for _, entry in ipairs(performanceHistory) do
        avgScore = avgScore + entry.score
    end
    avgScore = #performanceHistory > 0 and (avgScore / #performanceHistory) or 0
    return {
        enabled = enabled,
        currentScore = playerScore,
        averageScore = avgScore,
        adjustmentLevel = adjustmentLevel,
        historyCount = #performanceHistory,
        targetDifficulty = targetDifficulty,
    }
end

-- Set smoothing rate
function DDA.setSmoothing(value)
    smoothing = math.max(0.001, math.min(0.1, value))
end

-- Set update interval
function DDA.setUpdateInterval(seconds)
    updateInterval = math.max(5, math.min(60, seconds))
end

return DDA
