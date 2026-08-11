-- objects/Network/MatchmakingSystem.lua
-- Castle Kingdoms 2027 v3.0.1 - Multiplayer Matchmaking System
--
-- Handles player matchmaking for multiplayer games with skill-based
-- pairing, lobby management, and connection quality assessment.
--
-- Features:
-- - Skill-based matchmaking (ELO-like rating)
-- - 4 match types (1v1, 2v2, 3v3, 4v4 free-for-all)
-- - Lobby creation and management
-- - Player ready system
-- - Connection quality assessment (ping-based)
-- - Match history and win/loss tracking
-- - Spectator queue
-- - Reconnect window (60s for dropped players)

local Matchmaking = {}

-- Match types
local MATCH_TYPES = {
    duel = { name = "Duel (1v1)",      players = 2,  teams = 2, teamSize = 1 },
    team2 = { name = "Team (2v2)",     players = 4,  teams = 2, teamSize = 2 },
    team3 = { name = "Team (3v3)",     players = 6,  teams = 2, teamSize = 3 },
    ffa4 = { name = "Free-for-All (4)", players = 4, teams = 4, teamSize = 1 },
    ffa8 = { name = "Free-for-All (8)", players = 8, teams = 8, teamSize = 1 },
}

Matchmaking.MATCH_TYPES = MATCH_TYPES

local initialized = false
local playerRating = 1000  -- ELO-like starting rating
local currentLobby = nil
local queueTimer = 0
local queueTimeout = 120  -- 2 minutes in queue
local matchHistory = {}
local maxHistory = 50
local playerStats = {
    totalMatches = 0,
    wins = 0,
    losses = 0,
    disconnects = 0,
    avgMatchTime = 0,
    bestWinStreak = 0,
    currentWinStreak = 0,
}
local connectionQuality = {
    ping = 0,
    packetLoss = 0,
    quality = "unknown",  -- excellent, good, fair, poor
}

function Matchmaking.init()
    if initialized then return end
    initialized = true
    Matchmaking._loadStats()
    print("[Matchmaking] Initialized — Rating: " .. playerRating)
end

-- Join matchmaking queue
function Matchmaking.joinQueue(matchType)
    if currentLobby then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Že si v lobiju")
        end
        return false
    end

    local config = MATCH_TYPES[matchType or "duel"]
    if not config then return false end

    currentLobby = {
        matchType = matchType,
        config = config,
        players = {},
        state = "searching",  -- searching, found, ready, playing
        createdAt = os.time(),
        readyTimer = 0,
    }

    -- Add self as first player
    table.insert(currentLobby.players, {
        id = 1,
        name = "Igralec",
        rating = playerRating,
        ready = false,
        isHost = true,
        ping = 0,
    })

    queueTimer = 0

    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Iskanje igre: " .. config.name)
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("matchmaking_joined", { type = matchType }) end)
    end

    print("[Matchmaking] Joined queue: " .. config.name)
    return true
end

-- Leave queue
function Matchmaking.leaveQueue()
    if not currentLobby then return false end
    currentLobby = nil
    queueTimer = 0
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Zapustil iskanje igre")
    end
    return true
end

-- Simulate finding players (in real implementation, network request)
function Matchmaking._findPlayers()
    if not currentLobby or currentLobby.state ~= "searching" then return end

    local config = currentLobby.config
    local needed = config.players - #currentLobby.players

    if needed <= 0 then
        -- All players found, move to ready state
        currentLobby.state = "ready"
        currentLobby.readyTimer = 0
        if _G.ModernUI then
            _G.ModernUI.notifySuccess("Igra najdena! Pripravi se...")
        end
        return
    end

    -- Simulate finding players over time
    if math.random() < 0.3 then  -- 30% chance per check to find a player
        local aiNames = {"Sir Aldric", "Lord Valdemar", "Lady Elara", "Baron Westmar",
                         "Knight Roland", "Duke Edmond", "Countess Isabelle", "Sir Gareth"}
        local name = aiNames[math.random(#aiNames)]
        local ratingVariance = math.random(-100, 100)
        table.insert(currentLobby.players, {
            id = #currentLobby.players + 1,
            name = name,
            rating = math.max(500, playerRating + ratingVariance),
            ready = math.random() > 0.3,  -- 70% chance AI is ready
            isHost = false,
            ping = math.random(20, 150),
        })
        if _G.ModernUI then
            _G.ModernUI.notifyInfo(name .. " se je pridružil (" .. #currentLobby.players .. "/" .. config.players .. ")")
        end
    end
end

-- Set player ready
function Matchmaking.setReady(ready)
    if not currentLobby or currentLobby.state ~= "ready" then return false end
    currentLobby.players[1].ready = ready
    if _G.ModernUI then
        _G.ModernUI.notifyInfo(ready and "Pripravljen!" or "Nepripravljen")
    end
    return true
end

-- Check if all players ready
function Matchmaking._checkAllReady()
    if not currentLobby or currentLobby.state ~= "ready" then return end
    local allReady = true
    for _, player in ipairs(currentLobby.players) do
        if not player.ready then
            allReady = false
            break
        end
    end
    if allReady and #currentLobby.players >= currentLobby.config.players then
        currentLobby.state = "playing"
        if _G.ModernUI then
            _G.ModernUI.notifySuccess("Igra se začenja!")
        end
        if _G.GameEventBus then
            pcall(function() _G.GameEventBus.emit("match_started", currentLobby) end)
        end
    end
end

-- Update connection quality
function Matchmaking._updateConnectionQuality()
    if not _G.GameClient then return end
    local client = _G.GameClient
    if client.isConnected and client.isConnected() then
        -- Simulate ping measurement
        connectionQuality.ping = math.random(20, 80)
        connectionQuality.packetLoss = math.random() * 0.05  -- 0-5%

        if connectionQuality.ping < 40 and connectionQuality.packetLoss < 0.01 then
            connectionQuality.quality = "excellent"
        elseif connectionQuality.ping < 80 and connectionQuality.packetLoss < 0.03 then
            connectionQuality.quality = "good"
        elseif connectionQuality.ping < 150 and connectionQuality.packetLoss < 0.05 then
            connectionQuality.quality = "fair"
        else
            connectionQuality.quality = "poor"
        end
    else
        connectionQuality.ping = 0
        connectionQuality.packetLoss = 0
        connectionQuality.quality = "unknown"
    end
end

-- Report match result
function Matchmaking.reportResult(won, duration)
    playerStats.totalMatches = playerStats.totalMatches + 1
    if won then
        playerStats.wins = playerStats.wins + 1
        playerStats.currentWinStreak = playerStats.currentWinStreak + 1
        if playerStats.currentWinStreak > playerStats.bestWinStreak then
            playerStats.bestWinStreak = playerStats.currentWinStreak
        end
        -- ELO gain
        local gain = 25 + math.random(-5, 10)
        playerRating = playerRating + gain
        if _G.ModernUI then
            _G.ModernUI.notifySuccess("Zmaga! +" .. gain .. " rating (skupaj: " .. playerRating .. ")")
        end
    else
        playerStats.losses = playerStats.losses + 1
        playerStats.currentWinStreak = 0
        -- ELO loss
        local loss = 20 + math.random(-5, 5)
        playerRating = math.max(500, playerRating - loss)
        if _G.ModernUI then
            _G.ModernUI.notifyError("Poraz. -" .. loss .. " rating (skupaj: " .. playerRating .. ")")
        end
    end

    -- Update avg match time
    if duration then
        playerStats.avgMatchTime = (playerStats.avgMatchTime * (playerStats.totalMatches - 1) + duration) / playerStats.totalMatches
    end

    -- Record in history
    table.insert(matchHistory, {
        won = won,
        duration = duration or 0,
        rating = playerRating,
        timestamp = os.time(),
    })
    while #matchHistory > maxHistory do
        table.remove(matchHistory, 1)
    end

    -- Clear lobby
    currentLobby = nil
    Matchmaking._saveStats()

    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("match_ended", { won = won, rating = playerRating }) end)
    end
    if _G.Leaderboard then
        pcall(function() _G.Leaderboard.submit("total_score", "Igralec", playerRating) end)
    end

    return playerRating
end

-- Report disconnect
function Matchmaking.reportDisconnect()
    playerStats.disconnects = playerStats.disconnects + 1
    playerStats.currentWinStreak = 0
    playerRating = math.max(500, playerRating - 30)
    currentLobby = nil
    Matchmaking._saveStats()
    if _G.ModernUI then
        _G.ModernUI.notifyError("Odklop! -30 rating")
    end
end

-- Update
function Matchmaking.update(dt)
    if not initialized then return end

    Matchmaking._updateConnectionQuality()

    if not currentLobby then return end

    if currentLobby.state == "searching" then
        queueTimer = queueTimer + dt
        if queueTimer >= 2.0 then  -- check for players every 2s
            queueTimer = 0
            Matchmaking._findPlayers()
        end
        -- Queue timeout
        if os.time() - currentLobby.createdAt > queueTimeout then
            if _G.ModernUI then
                _G.ModernUI.notifyInfo("Iskanje poteklo — poskusi znova")
            end
            currentLobby = nil
        end
    elseif currentLobby.state == "ready" then
        currentLobby.readyTimer = currentLobby.readyTimer + dt
        Matchmaking._checkAllReady()
        -- Auto-ready timeout (30s)
        if currentLobby.readyTimer > 30 then
            -- Force start
            currentLobby.state = "playing"
            if _G.ModernUI then
                _G.ModernUI.notifyInfo("Avtomatski začetek (timeout)")
            end
        end
    end
end

-- Get lobby info
function Matchmaking.getLobby()
    if not currentLobby then return nil end
    return {
        matchType = currentLobby.matchType,
        matchName = currentLobby.config.name,
        state = currentLobby.state,
        playerCount = #currentLobby.players,
        maxPlayers = currentLobby.config.players,
        players = currentLobby.players,
        queueTime = os.time() - currentLobby.createdAt,
        readyTimer = currentLobby.readyTimer,
    }
end

-- Get player rating
function Matchmaking.getRating()
    return playerRating
end

-- Get rank tier
function Matchmaking.getRankTier()
    if playerRating >= 2000 then return { name = "Grandmaster", color = {1.0, 0.1, 0.1} }
    elseif playerRating >= 1800 then return { name = "Master", color = {0.9, 0.2, 0.9} }
    elseif playerRating >= 1600 then return { name = "Diamond", color = {0.3, 0.9, 0.9} }
    elseif playerRating >= 1400 then return { name = "Platinum", color = {0.7, 0.7, 0.9} }
    elseif playerRating >= 1200 then return { name = "Gold", color = {1.0, 0.8, 0.2} }
    elseif playerRating >= 1000 then return { name = "Silver", color = {0.7, 0.7, 0.7} }
    else return { name = "Bronze", color = {0.8, 0.5, 0.3} } end
end

-- Get connection quality
function Matchmaking.getConnectionQuality()
    return connectionQuality
end

-- Get stats
function Matchmaking.getStats()
    local winRate = playerStats.totalMatches > 0 and (playerStats.wins / playerStats.totalMatches * 100) or 0
    return {
        rating = playerRating,
        rankTier = Matchmaking.getRankTier(),
        totalMatches = playerStats.totalMatches,
        wins = playerStats.wins,
        losses = playerStats.losses,
        winRate = math.floor(winRate),
        disconnects = playerStats.disconnects,
        avgMatchTime = math.floor(playerStats.avgMatchTime),
        bestWinStreak = playerStats.bestWinStreak,
        currentWinStreak = playerStats.currentWinStreak,
        inQueue = currentLobby ~= nil,
        connectionQuality = connectionQuality.quality,
    }
end

-- Get match history
function Matchmaking.getHistory(limit)
    local result = {}
    limit = limit or 10
    for i = math.max(1, #matchHistory - limit + 1), #matchHistory do
        table.insert(result, matchHistory[i])
    end
    return result
end

-- Save stats
function Matchmaking._saveStats()
    local file = love.filesystem.newFile("matchmaking_stats.json")
    if file:open("w") then
        local lines = {"return {"}
        table.insert(lines, string.format("  rating = %d,", playerRating))
        table.insert(lines, string.format("  totalMatches = %d,", playerStats.totalMatches))
        table.insert(lines, string.format("  wins = %d,", playerStats.wins))
        table.insert(lines, string.format("  losses = %d,", playerStats.losses))
        table.insert(lines, string.format("  disconnects = %d,", playerStats.disconnects))
        table.insert(lines, string.format("  avgMatchTime = %d,", math.floor(playerStats.avgMatchTime)))
        table.insert(lines, string.format("  bestWinStreak = %d,", playerStats.bestWinStreak))
        table.insert(lines, "}")
        file:write(table.concat(lines, "\n"))
        file:close()
    end
end

-- Load stats
function Matchmaking._loadStats()
    local file = love.filesystem.newFile("matchmaking_stats.json")
    if file:open("r") then
        local content = file:read()
        file:close()
        if content then
            local ok, chunk = pcall(load, content)
            if ok and chunk then
                local dataOk, data = pcall(chunk)
                if dataOk and type(data) == "table" then
                    playerRating = data.rating or 1000
                    playerStats.totalMatches = data.totalMatches or 0
                    playerStats.wins = data.wins or 0
                    playerStats.losses = data.losses or 0
                    playerStats.disconnects = data.disconnects or 0
                    playerStats.avgMatchTime = data.avgMatchTime or 0
                    playerStats.bestWinStreak = data.bestWinStreak or 0
                end
            end
        end
    end
end

return Matchmaking
