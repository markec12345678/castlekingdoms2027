-- objects/QA/GameAnalyticsDashboard.lua
-- Castle Kingdoms 2027 v2.7.7 - Game Analytics Dashboard
--
-- Real-time analytics dashboard tracking all game metrics.
-- Provides comprehensive statistics for players and developers.
--
-- Tracked categories:
-- - Military: units trained, killed, lost, battles won/lost
-- - Economy: resources gathered, spent, traded, net worth
-- - Construction: buildings built, destroyed, repaired
-- - Diplomacy: alliances, wars, trades, tributes
-- - Time: playtime, mission time, APM (actions per minute)
-- - Efficiency: production rates, waste, bottlenecks

local Analytics = {}

local initialized = false
local sessionData = {}
local lifetimeData = {}
local actionLog = {}  -- recent actions for APM calculation
local updateTimer = 0
local updateInterval = 5.0  -- update derived stats every 5 seconds

-- Initialize session data
local function _initSession()
    sessionData = {
        startTime = os.time(),
        playtime = 0,
        -- Military
        unitsTrained = 0,
        unitsLost = 0,
        enemiesKilled = 0,
        battlesWon = 0,
        battlesLost = 0,
        siegeWeaponsUsed = 0,
        -- Economy
        goldEarned = 0,
        goldSpent = 0,
        resourcesGathered = {},
        resourcesSpent = {},
        tradesCompleted = 0,
        tradeProfit = 0,
        -- Construction
        buildingsBuilt = 0,
        buildingsDestroyed = 0,
        buildingsRepaired = 0,
        -- Diplomacy
        alliancesFormed = 0,
        warsDeclared = 0,
        tributesSent = 0,
        tributesReceived = 0,
        -- Espionage
        spyMissions = 0,
        spySuccesses = 0,
        -- Quests
        questsAccepted = 0,
        questsCompleted = 0,
        -- Technology
        technologiesResearched = 0,
        -- Actions
        totalActions = 0,
        apm = 0,  -- actions per minute
    }
end

function Analytics.init()
    if initialized then return end
    initialized = true
    _initSession()
    Analytics._loadLifetime()
    print("[Analytics] Initialized")
end

-- Load lifetime data from file
function Analytics._loadLifetime()
    local file = love.filesystem.newFile("analytics_lifetime.json")
    if file:open("r") then
        local content = file:read()
        file:close()
        if content then
            local ok, chunk = pcall(load, content)
            if ok and chunk then
                local dataOk, data = pcall(chunk)
                if dataOk and type(data) == "table" then
                    lifetimeData = data
                    return
                end
            end
        end
    end
    lifetimeData = { totalGames = 0, totalPlaytime = 0 }
end

-- Save lifetime data to file
function Analytics._saveLifetime()
    local file = love.filesystem.newFile("analytics_lifetime.json")
    if file:open("w") then
        local lines = {"return {"}
        for k, v in pairs(lifetimeData) do
            if type(v) == "number" then
                table.insert(lines, string.format("  %s = %d,", k, v))
            elseif type(v) == "string" then
                table.insert(lines, string.format("  %s = %q,", k, v))
            end
        end
        table.insert(lines, "}")
        file:write(table.concat(lines, "\n"))
        file:close()
    end
end

-- Record an action (for APM calculation)
function Analytics.recordAction(actionType)
    if not initialized then return end
    sessionData.totalActions = sessionData.totalActions + 1
    table.insert(actionLog, {
        type = actionType or "unknown",
        time = os.time(),
    })
    -- Keep only last 1000 actions
    while #actionLog > 1000 do
        table.remove(actionLog, 1)
    end
end

-- Track specific events
function Analytics.track(eventType, data)
    if not initialized then return end
    data = data or {}

    if eventType == "unit_trained" then
        sessionData.unitsTrained = sessionData.unitsTrained + 1
    elseif eventType == "unit_lost" then
        sessionData.unitsLost = sessionData.unitsLost + 1
    elseif eventType == "enemy_killed" then
        sessionData.enemiesKilled = sessionData.enemiesKilled + 1
    elseif eventType == "battle_won" then
        sessionData.battlesWon = sessionData.battlesWon + 1
    elseif eventType == "battle_lost" then
        sessionData.battlesLost = sessionData.battlesLost + 1
    elseif eventType == "gold_earned" then
        sessionData.goldEarned = sessionData.goldEarned + (data.amount or 0)
    elseif eventType == "gold_spent" then
        sessionData.goldSpent = sessionData.goldSpent + (data.amount or 0)
    elseif eventType == "resource_gathered" then
        local res = data.type or "unknown"
        sessionData.resourcesGathered[res] = (sessionData.resourcesGathered[res] or 0) + (data.amount or 0)
    elseif eventType == "resource_spent" then
        local res = data.type or "unknown"
        sessionData.resourcesSpent[res] = (sessionData.resourcesSpent[res] or 0) + (data.amount or 0)
    elseif eventType == "trade_completed" then
        sessionData.tradesCompleted = sessionData.tradesCompleted + 1
        sessionData.tradeProfit = sessionData.tradeProfit + (data.profit or 0)
    elseif eventType == "building_built" then
        sessionData.buildingsBuilt = sessionData.buildingsBuilt + 1
    elseif eventType == "building_destroyed" then
        sessionData.buildingsDestroyed = sessionData.buildingsDestroyed + 1
    elseif eventType == "building_repaired" then
        sessionData.buildingsRepaired = sessionData.buildingsRepaired + 1
    elseif eventType == "alliance_formed" then
        sessionData.alliancesFormed = sessionData.alliancesFormed + 1
    elseif eventType == "war_declared" then
        sessionData.warsDeclared = sessionData.warsDeclared + 1
    elseif eventType == "tribute_sent" then
        sessionData.tributesSent = sessionData.tributesSent + 1
    elseif eventType == "tribute_received" then
        sessionData.tributesReceived = sessionData.tributesReceived + 1
    elseif eventType == "spy_mission" then
        sessionData.spyMissions = sessionData.spyMissions + 1
        if data.success then sessionData.spySuccesses = sessionData.spySuccesses + 1 end
    elseif eventType == "quest_accepted" then
        sessionData.questsAccepted = sessionData.questsAccepted + 1
    elseif eventType == "quest_completed" then
        sessionData.questsCompleted = sessionData.questsCompleted + 1
    elseif eventType == "technology_researched" then
        sessionData.technologiesResearched = sessionData.technologiesResearched + 1
    end

    Analytics.recordAction(eventType)
end

-- Calculate APM (actions per minute)
function Analytics._calculateAPM()
    local now = os.time()
    local oneMinuteAgo = now - 60
    local count = 0
    for _, action in ipairs(actionLog) do
        if action.time >= oneMinuteAgo then
            count = count + 1
        end
    end
    sessionData.apm = count
end

-- Update
function Analytics.update(dt)
    if not initialized then return end
    sessionData.playtime = sessionData.playtime + dt
    updateTimer = updateTimer + dt
    if updateTimer >= updateInterval then
        updateTimer = 0
        Analytics._calculateAPM()
    end
end

-- Get session stats
function Analytics.getSessionStats()
    local netWorth = 0
    if _G.state then
        netWorth = netWorth + (_G.state.gold or 0)
        if _G.state.resources then
            -- Rough valuation: 1g per resource unit
            for _, amount in pairs(_G.state.resources) do
                netWorth = netWorth + (amount or 0)
            end
        end
    end

    return {
        playtime = sessionData.playtime,
        playtimeFormatted = Analytics._formatTime(sessionData.playtime),
        -- Military
        unitsTrained = sessionData.unitsTrained,
        unitsLost = sessionData.unitsLost,
        enemiesKilled = sessionData.enemiesKilled,
        kdRatio = sessionData.unitsLost > 0 and (sessionData.enemiesKilled / sessionData.unitsLost) or sessionData.enemiesKilled,
        battlesWon = sessionData.battlesWon,
        battlesLost = sessionData.battlesLost,
        -- Economy
        goldEarned = sessionData.goldEarned,
        goldSpent = sessionData.goldSpent,
        goldNet = sessionData.goldEarned - sessionData.goldSpent,
        netWorth = netWorth,
        tradesCompleted = sessionData.tradesCompleted,
        tradeProfit = sessionData.tradeProfit,
        -- Construction
        buildingsBuilt = sessionData.buildingsBuilt,
        buildingsDestroyed = sessionData.buildingsDestroyed,
        buildingsRepaired = sessionData.buildingsRepaired,
        -- Diplomacy
        alliancesFormed = sessionData.alliancesFormed,
        warsDeclared = sessionData.warsDeclared,
        tributesSent = sessionData.tributesSent,
        tributesReceived = sessionData.tributesReceived,
        -- Espionage
        spyMissions = sessionData.spyMissions,
        spySuccessRate = sessionData.spyMissions > 0 and (sessionData.spySuccesses / sessionData.spyMissions * 100) or 0,
        -- Quests
        questsAccepted = sessionData.questsAccepted,
        questsCompleted = sessionData.questsCompleted,
        -- Technology
        technologiesResearched = sessionData.technologiesResearched,
        -- Actions
        totalActions = sessionData.totalActions,
        apm = sessionData.apm,
        -- Resources
        resourcesGathered = sessionData.resourcesGathered,
        resourcesSpent = sessionData.resourcesSpent,
    }
end

-- Format time as HH:MM:SS
function Analytics._formatTime(seconds)
    seconds = math.floor(seconds or 0)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

-- Get lifetime stats
function Analytics.getLifetimeStats()
    return lifetimeData
end

-- Save session to lifetime data
function Analytics.saveSession()
    lifetimeData.totalGames = (lifetimeData.totalGames or 0) + 1
    lifetimeData.totalPlaytime = (lifetimeData.totalPlaytime or 0) + sessionData.playtime
    lifetimeData.totalUnitsTrained = (lifetimeData.totalUnitsTrained or 0) + sessionData.unitsTrained
    lifetimeData.totalEnemiesKilled = (lifetimeData.totalEnemiesKilled or 0) + sessionData.enemiesKilled
    lifetimeData.totalBuildingsBuilt = (lifetimeData.totalBuildingsBuilt or 0) + sessionData.buildingsBuilt
    lifetimeData.totalGoldEarned = (lifetimeData.totalGoldEarned or 0) + sessionData.goldEarned
    lifetimeData.totalTrades = (lifetimeData.totalTrades or 0) + sessionData.tradesCompleted
    lifetimeData.totalBattlesWon = (lifetimeData.totalBattlesWon or 0) + sessionData.battlesWon
    Analytics._saveLifetime()
    print("[Analytics] Session saved to lifetime data")
end

-- Reset session (new game)
function Analytics.resetSession()
    if not initialized then return end
    Analytics.saveSession()
    _initSession()
    actionLog = {}
    print("[Analytics] Session reset")
end

-- Get formatted summary for display
function Analytics.getSummary()
    local s = Analytics.getSessionStats()
    local lines = {}
    table.insert(lines, "=== ANALITIKA IGRE ===")
    table.insert(lines, string.format("Čas igranja: %s", s.playtimeFormatted))
    table.insert(lines, string.format("APM: %d", s.apm))
    table.insert(lines, "")
    table.insert(lines, "--- Vojska ---")
    table.insert(lines, string.format("Usposobljene: %d | Izgubljene: %d", s.unitsTrained, s.unitsLost))
    table.insert(lines, string.format("Ubiti sovražniki: %d | K/D: %.2f", s.enemiesKilled, s.kdRatio))
    table.insert(lines, string.format("Zmage: %d | Porazi: %d", s.battlesWon, s.battlesLost))
    table.insert(lines, "")
    table.insert(lines, "--- Ekonomija ---")
    table.insert(lines, string.format("Zaslužek: %dg | Poraba: %dg | Neto: %dg", s.goldEarned, s.goldSpent, s.goldNet))
    table.insert(lines, string.format("Neto vrednost: %dg", s.netWorth))
    table.insert(lines, string.format("Trgovine: %d | Profit: %dg", s.tradesCompleted, s.tradeProfit))
    table.insert(lines, "")
    table.insert(lines, "--- Gradnja ---")
    table.insert(lines, string.format("Zgrajene: %d | Uničene: %d | Popravljene: %d", s.buildingsBuilt, s.buildingsDestroyed, s.buildingsRepaired))
    table.insert(lines, "")
    table.insert(lines, "--- Diplomacija ---")
    table.insert(lines, string.format("Zavezništva: %d | Vojne: %d", s.alliancesFormed, s.warsDeclared))
    table.insert(lines, string.format("Tributi poslani: %d | Prejeti: %d", s.tributesSent, s.tributesReceived))
    table.insert(lines, "")
    table.insert(lines, "--- Vohunstvo ---")
    table.insert(lines, string.format("Misije: %d | Uspešnost: %.0f%%", s.spyMissions, s.spySuccessRate))
    table.insert(lines, "")
    table.insert(lines, "--- Questi & Tehnologija ---")
    table.insert(lines, string.format("Questi: %d/%d | Tehnologije: %d", s.questsCompleted, s.questsAccepted, s.technologiesResearched))
    return table.concat(lines, "\n")
end

return Analytics
