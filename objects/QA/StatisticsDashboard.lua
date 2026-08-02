-- objects/QA/StatisticsDashboard.lua
-- Stronghold 2027 - Statistics Dashboard
--
-- Tracks player statistics across all game sessions:
-- - Games played, won, lost
-- - Total playtime
-- - Buildings built, units trained, units killed
-- - Resources gathered, gold earned, traded
-- - Multiplayer stats (wins, losses, alliances)
-- - Mission completion stats
-- - Performance metrics (best build time, fastest victory)
--
-- Usage:
--   local Stats = require("objects.QA.StatisticsDashboard")
--   Stats.init()
--   Stats.trackEvent("building_built", {type = "Barracks"})
--   Stats.trackEvent("unit_killed")
--   Stats.save()

local Stats = {}

local STATS_FILE = "player_stats.json"
local initialized = false
local sessionStats = {}
local lifetimeStats = {}

-- Initialize
function Stats.init()
    if initialized then return end
    initialized = true

    -- Reset session stats
    sessionStats = {
        sessionStart = os.time(),
        buildingsBuilt = 0,
        buildingsDestroyed = 0,
        unitsTrained = 0,
        unitsKilled = 0,
        unitsLost = 0,
        resourcesGathered = {},
        goldEarned = 0,
        goldSpent = 0,
        tradesCompleted = 0,
        alliancesFormed = 0,
        warsDeclared = 0,
        combatTime = 0,
        peaceTime = 0,
        maxPopulation = 0,
        maxGold = 0,
    }

    -- Load lifetime stats
    Stats._load()

    print("[StatisticsDashboard] Initialized")
end

-- Track an event
function Stats.trackEvent(eventType, data)
    if not initialized then return end

    data = data or {}

    if eventType == "building_built" then
        sessionStats.buildingsBuilt = sessionStats.buildingsBuilt + 1
        lifetimeStats.totalBuildings = (lifetimeStats.totalBuildings or 0) + 1

    elseif eventType == "building_destroyed" then
        sessionStats.buildingsDestroyed = sessionStats.buildingsDestroyed + 1

    elseif eventType == "unit_trained" then
        sessionStats.unitsTrained = sessionStats.unitsTrained + 1
        lifetimeStats.totalUnitsTrained = (lifetimeStats.totalUnitsTrained or 0) + 1

    elseif eventType == "unit_killed" then
        sessionStats.unitsKilled = sessionStats.unitsKilled + 1
        lifetimeStats.totalKills = (lifetimeStats.totalKills or 0) + 1

    elseif eventType == "unit_lost" then
        sessionStats.unitsLost = sessionStats.unitsLost + 1
        lifetimeStats.totalLosses = (lifetimeStats.totalLosses or 0) + 1

    elseif eventType == "resource_gathered" then
        local resType = data.type or "unknown"
        local amount = data.amount or 0
        sessionStats.resourcesGathered[resType] = (sessionStats.resourcesGathered[resType] or 0) + amount
        lifetimeStats.totalResources = lifetimeStats.totalResources or {}
        lifetimeStats.totalResources[resType] = (lifetimeStats.totalResources[resType] or 0) + amount

    elseif eventType == "gold_earned" then
        local amount = data.amount or 0
        sessionStats.goldEarned = sessionStats.goldEarned + amount
        lifetimeStats.totalGoldEarned = (lifetimeStats.totalGoldEarned or 0) + amount

    elseif eventType == "gold_spent" then
        local amount = data.amount or 0
        sessionStats.goldSpent = sessionStats.goldSpent + amount

    elseif eventType == "trade_completed" then
        sessionStats.tradesCompleted = sessionStats.tradesCompleted + 1
        lifetimeStats.totalTrades = (lifetimeStats.totalTrades or 0) + 1

    elseif eventType == "alliance_formed" then
        sessionStats.alliancesFormed = sessionStats.alliancesFormed + 1
        lifetimeStats.totalAlliances = (lifetimeStats.totalAlliances or 0) + 1

    elseif eventType == "war_declared" then
        sessionStats.warsDeclared = sessionStats.warsDeclared + 1
        lifetimeStats.totalWars = (lifetimeStats.totalWars or 0) + 1

    elseif eventType == "game_won" then
        lifetimeStats.gamesWon = (lifetimeStats.gamesWon or 0) + 1
        lifetimeStats.gamesPlayed = (lifetimeStats.gamesPlayed or 0) + 1
        if data.duration and (not lifetimeStats.fastestVictory or data.duration < lifetimeStats.fastestVictory) then
            lifetimeStats.fastestVictory = data.duration
        end

    elseif eventType == "game_lost" then
        lifetimeStats.gamesLost = (lifetimeStats.gamesLost or 0) + 1
        lifetimeStats.gamesPlayed = (lifetimeStats.gamesPlayed or 0) + 1

    elseif eventType == "mission_completed" then
        local missionId = data.missionId or "unknown"
        lifetimeStats.missionsCompleted = lifetimeStats.missionsCompleted or {}
        lifetimeStats.missionsCompleted[missionId] = true

    elseif eventType == "multiplayer_win" then
        lifetimeStats.multiplayerWins = (lifetimeStats.multiplayerWins or 0) + 1

    elseif eventType == "multiplayer_loss" then
        lifetimeStats.multiplayerLosses = (lifetimeStats.multiplayerLosses or 0) + 1
    end
end

-- Update population/gold tracking (call periodically)
function Stats.updateStats()
    if not initialized then return end

    if _G.state then
        if _G.state.population and _G.state.population > sessionStats.maxPopulation then
            sessionStats.maxPopulation = _G.state.population
        end
        if _G.state.gold and _G.state.gold > sessionStats.maxGold then
            sessionStats.maxGold = _G.state.gold
        end
    end
end

-- Get session stats
function Stats.getSessionStats()
    return sessionStats
end

-- Get lifetime stats
function Stats.getLifetimeStats()
    return lifetimeStats
end

-- Get combined stats for display
function Stats.getDisplayStats()
    local sessionDuration = os.time() - sessionStats.sessionStart
    return {
        session = sessionStats,
        lifetime = lifetimeStats,
        sessionDuration = sessionDuration,
        kdRatio = sessionStats.unitsLost > 0
            and (sessionStats.unitsKilled / sessionStats.unitsLost)
            or sessionStats.unitsKilled,
        lifetimeKdRatio = (lifetimeStats.totalLosses or 0) > 0
            and ((lifetimeStats.totalKills or 0) / (lifetimeStats.totalLosses or 0))
            or (lifetimeStats.totalKills or 0),
        winRate = (lifetimeStats.gamesPlayed or 0) > 0
            and ((lifetimeStats.gamesWon or 0) / (lifetimeStats.gamesPlayed or 0) * 100)
            or 0,
    }
end

-- Save stats to file
function Stats.save()
    local data = {
        lifetime = lifetimeStats,
        lastSaved = os.time(),
    }

    local file = love.filesystem.newFile(STATS_FILE)
    if file:open("w") then
        -- Simple serialization
        local function serialize(tbl, indent)
            indent = indent or ""
            local lines = {}
            for k, v in pairs(tbl) do
                if type(v) == "table" then
                    table.insert(lines, indent .. tostring(k) .. " = {")
                    table.insert(lines, serialize(v, indent .. "  "))
                    table.insert(lines, indent .. "},")
                elseif type(v) == "string" then
                    table.insert(lines, indent .. tostring(k) .. " = " .. '"' .. v .. '",')
                else
                    table.insert(lines, indent .. tostring(k) .. " = " .. tostring(v) .. ",")
                end
            end
            return table.concat(lines, "\n")
        end

        file:write("return {\n" .. serialize(data, "  ") .. "\n}")
        file:close()
    end
end

-- Load stats from file
function Stats._load()
    local file = love.filesystem.newFile(STATS_FILE)
    if file:open("r") then
        local content = file:read()
        file:close()

        if content then
            local ok, chunk = pcall(load, content)
            if ok and chunk then
                local dataOk, data = pcall(chunk)
                if dataOk and type(data) == "table" then
                    lifetimeStats = data.lifetime or {}
                    print("[StatisticsDashboard] Loaded lifetime stats")
                end
            end
        end
    end
end

-- Reset lifetime stats
function Stats.resetLifetime()
    lifetimeStats = {}
    Stats.save()
    print("[StatisticsDashboard] Lifetime stats reset")
end

-- Print stats summary
function Stats.printSummary()
    local display = Stats.getDisplayStats()
    print("\n" .. string.rep("=", 50))
    print("PLAYER STATISTICS")
    print(string.rep("=", 50))

    print("\n-- Session --")
    print(string.format("Duration: %s", os.date("!%H:%M:%S", display.sessionDuration)))
    print(string.format("Buildings built: %d", display.session.buildingsBuilt))
    print(string.format("Units trained: %d", display.session.unitsTrained))
    print(string.format("Units killed: %d", display.session.unitsKilled))
    print(string.format("Units lost: %d", display.session.unitsLost))
    print(string.format("K/D ratio: %.2f", display.kdRatio))
    print(string.format("Gold earned: %d", display.session.goldEarned))
    print(string.format("Trades: %d", display.session.tradesCompleted))

    print("\n-- Lifetime --")
    print(string.format("Games played: %d", display.lifetime.gamesPlayed or 0))
    print(string.format("Games won: %d", display.lifetime.gamesWon or 0))
    print(string.format("Win rate: %.1f%%", display.winRate))
    print(string.format("Total kills: %d", display.lifetime.totalKills or 0))
    print(string.format("Total buildings: %d", display.lifetime.totalBuildings or 0))
    print(string.format("Multiplayer W/L: %d/%d",
        display.lifetime.multiplayerWins or 0, display.lifetime.multiplayerLosses or 0))
    print(string.rep("=", 50))
end

return Stats
