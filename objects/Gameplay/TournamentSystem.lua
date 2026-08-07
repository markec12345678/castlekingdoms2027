-- objects/Gameplay/TournamentSystem.lua
-- Stronghold 2027 v2.8.0 - Tournament System
--
-- Periodic tournaments that players can participate in for rewards and prestige.
-- Tournaments occur every game year (4 seasons) and last 5 minutes.
--
-- Tournament types:
-- - Jousting: 1v1 unit combat tournament
-- - Archery: ranged unit accuracy competition
-- - Siege: fastest castle siege competition
-- - Economy: highest gold accumulation
-- - Grand Tournament: combined all categories
--
-- Rewards scale with tournament type and player's final ranking.

local Tournament = {}

local TOURNAMENT_TYPES = {
    jousting = {
        name = "Viteški turnir",
        nameEn = "Jousting Tournament",
        duration = 300,  -- 5 minutes
        description = "1v1 boj med vitezi. Zmagovalec dobi slavo in zlato!",
        entryFee = 100,
        rewards = { first = { gold = 500, prestige = 30 }, second = { gold = 250, prestige = 15 }, third = { gold = 100, prestige = 5 } },
        category = "combat",
    },
    archery = {
        name = "Strelni turnir",
        nameEn = "Archery Contest",
        duration = 240,
        description = "Tekma v natančnosti lokostrelstva. Pokaži svoje veščine!",
        entryFee = 75,
        rewards = { first = { gold = 400, prestige = 25 }, second = { gold = 200, prestige = 12 }, third = { gold = 80, prestige = 4 } },
        category = "combat",
    },
    siege = {
        name = "Oblegovalni turnir",
        nameEn = "Siege Competition",
        duration = 360,
        description = "Najhitrejši oblegalec zmaga! Uniči sovražnikov grad v najkrajšem času.",
        entryFee = 200,
        rewards = { first = { gold = 800, prestige = 40 }, second = { gold = 400, prestige = 20 }, third = { gold = 150, prestige = 8 } },
        category = "combat",
    },
    economy = {
        name = "Trgovski sejem",
        nameEn = "Trade Fair",
        duration = 300,
        description = "Kdor prisluži največ zlata v 5 minutah zmaga!",
        entryFee = 50,
        rewards = { first = { gold = 600, prestige = 20 }, second = { gold = 300, prestige = 10 }, third = { gold = 120, prestige = 4 } },
        category = "economy",
    },
    grand = {
        name = "Veliki turnir",
        nameEn = "Grand Tournament",
        duration = 600,
        description = "Vsestransko tekmovanje — boj, ekonomija in strategija!",
        entryFee = 300,
        rewards = { first = { gold = 1500, prestige = 75 }, second = { gold = 750, prestige = 40 }, third = { gold = 300, prestige = 15 } },
        category = "special",
    },
}

Tournament.TOURNAMENT_TYPES = TOURNAMENT_TYPES

local initialized = false
local currentTournament = nil  -- { type, progress, participants, playerScore }
local tournamentHistory = {}
local nextTournamentTime = 0  -- game time when next tournament triggers
local tournamentInterval = 360  -- 6 minutes between tournaments (game time)

function Tournament.init()
    if initialized then return end
    initialized = true
    nextTournamentTime = tournamentInterval
    print("[Tournament] Initialized — next tournament in " .. tournamentInterval .. "s")
end

-- Check if it's time for a tournament
function Tournament._checkTrigger()
    if currentTournament then return end
    if nextTournamentTime > 0 then
        nextTournamentTime = nextTournamentTime - 1
        return
    end
    -- Trigger a random tournament
    local types = {"jousting", "archery", "siege", "economy", "grand"}
    -- Grand tournament is rarer
    local weights = {3, 3, 2, 3, 1}
    local totalWeight = 0
    for _, w in ipairs(weights) do totalWeight = totalWeight + w end
    local roll = math.random(totalWeight)
    local cumulative = 0
    local selectedType = "jousting"
    for i, t in ipairs(types) do
        cumulative = cumulative + weights[i]
        if roll <= cumulative then
            selectedType = t
            break
        end
    end
    Tournament.start(selectedType)
end

-- Start a tournament
function Tournament.start(tournamentType)
    local config = TOURNAMENT_TYPES[tournamentType]
    if not config then return false end

    -- Check entry fee
    if _G.state and (_G.state.gold or 0) < config.entryFee then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Vstopnina za turnir: " .. config.entryFee .. " zlata")
        end
        nextTournamentTime = 60  -- retry in 1 minute
        return false
    end

    -- Deduct entry fee
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) - config.entryFee
    end

    currentTournament = {
        type = tournamentType,
        config = config,
        timeRemaining = config.duration,
        playerScore = 0,
        aiScores = {},
        playerParticipating = true,
    }

    -- Generate AI participants (3-5)
    local aiCount = math.random(3, 5)
    for i = 1, aiCount do
        local baseScore = math.random(50, 200)
        if config.category == "combat" then
            baseScore = baseScore + math.random(0, 100)
        elseif config.category == "economy" then
            baseScore = baseScore + math.random(0, 150)
        end
        currentTournament.aiScores[i] = baseScore
    end

    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Turnir se začenja: " .. config.name .. " (" .. config.duration .. "s)")
    end
    if _G.VoiceOver then
        pcall(function() _G.VoiceOver.notify("festival_started", config.name) end)
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("tournament_started", { type = tournamentType, name = config.name }) end)
    end

    print("[Tournament] Started: " .. config.name)
    return true
end

-- Update tournament
function Tournament.update(dt)
    if not initialized then return end
    if not currentTournament then
        Tournament._checkTrigger()
        return
    end

    -- Update timer
    currentTournament.timeRemaining = currentTournament.timeRemaining - dt

    -- Accumulate player score based on tournament type
    if currentTournament.playerParticipating then
        local config = currentTournament.config
        if config.category == "combat" then
            -- Score from kills/damage (simulated)
            currentTournament.playerScore = currentTournament.playerScore + dt * math.random(5, 15)
        elseif config.category == "economy" then
            -- Score from gold earned (simulated)
            currentTournament.playerScore = currentTournament.playerScore + dt * math.random(8, 20)
        elseif config.category == "special" then
            -- Grand: combined
            currentTournament.playerScore = currentTournament.playerScore + dt * math.random(10, 25)
        end
    end

    -- AI scores also grow
    for i, _ in ipairs(currentTournament.aiScores) do
        currentTournament.aiScores[i] = currentTournament.aiScores[i] + dt * math.random(3, 12)
    end

    -- Check if tournament ended
    if currentTournament.timeRemaining <= 0 then
        Tournament._end()
    end
end

-- End the tournament and determine rankings
function Tournament._end()
    if not currentTournament then return end

    -- Build ranking
    local rankings = {}
    if currentTournament.playerParticipating then
        table.insert(rankings, { name = "Igralec", score = math.floor(currentTournament.playerScore), isPlayer = true })
    end
    for i, score in ipairs(currentTournament.aiScores) do
        table.insert(rankings, { name = "AI " .. i, score = math.floor(score), isPlayer = false })
    end

    -- Sort by score (descending)
    table.sort(rankings, function(a, b) return a.score > b.score end)

    -- Find player's rank
    local playerRank = 0
    for i, entry in ipairs(rankings) do
        if entry.isPlayer then
            playerRank = i
            break
        end
    end

    -- Give rewards
    local config = currentTournament.config
    local reward = nil
    if playerRank == 1 then reward = config.rewards.first
    elseif playerRank == 2 then reward = config.rewards.second
    elseif playerRank == 3 then reward = config.rewards.third end

    if reward then
        if _G.state and reward.gold then
            _G.state.gold = (_G.state.gold or 0) + reward.gold
        end
        if _G.Prestige and reward.prestige then
            _G.Prestige.award("daily_challenge", reward.prestige)  -- use daily_challenge as multiplier
        end
        if _G.ModernUI then
            local medal = playerRank == 1 and "ZLATO" or playerRank == 2 and "SREBRO" or "BRON"
            _G.ModernUI.notifySuccess("Turnir končan! " .. medal .. " mesto — +" .. (reward.gold or 0) .. "g")
        end
    else
        if _G.ModernUI then
            _G.ModernUI.notifyInfo("Turnir končan. " .. playerRank .. ". mesto — nagrada samo za top 3.")
        end
    end

    -- Record history
    table.insert(tournamentHistory, {
        type = currentTournament.type,
        name = config.name,
        playerRank = playerRank,
        playerScore = math.floor(currentTournament.playerScore),
        timestamp = os.time(),
        reward = reward,
    })
    while #tournamentHistory > 20 do
        table.remove(tournamentHistory, 1)
    end

    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("tournament_ended", {
            type = currentTournament.type,
            playerRank = playerRank,
            rankings = rankings,
        }) end)
    end

    print("[Tournament] Ended — Player rank: " .. playerRank)
    currentTournament = nil
    nextTournamentTime = tournamentInterval
end

-- Forfeit current tournament
function Tournament.forfeit()
    if not currentTournament then return false end
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Turnir opuščen.")
    end
    currentTournament = nil
    nextTournamentTime = tournamentInterval
    return true
end

-- Get current tournament info
function Tournament.getCurrent()
    if not currentTournament then return nil end
    return {
        type = currentTournament.type,
        name = currentTournament.config.name,
        description = currentTournament.config.description,
        timeRemaining = math.ceil(currentTournament.timeRemaining),
        playerScore = math.floor(currentTournament.playerScore),
        category = currentTournament.config.category,
    }
end

-- Get tournament history
function Tournament.getHistory(limit)
    local result = {}
    limit = limit or 10
    for i = math.max(1, #tournamentHistory - limit + 1), #tournamentHistory do
        table.insert(result, tournamentHistory[i])
    end
    return result
end

-- Get stats
function Tournament.getStats()
    local wins = 0
    local participations = #tournamentHistory
    local totalGold = 0
    for _, entry in ipairs(tournamentHistory) do
        if entry.playerRank == 1 then wins = wins + 1 end
        if entry.reward and entry.reward.gold then
            totalGold = totalGold + entry.reward.gold
        end
    end
    return {
        currentActive = currentTournament ~= nil,
        nextIn = math.ceil(nextTournamentTime),
        totalParticipations = participations,
        wins = wins,
        totalGoldEarned = totalGold,
        winRate = participations > 0 and (wins / participations * 100) or 0,
    }
end

-- Force start (for testing/debug)
function Tournament.forceStart(tournamentType)
    if currentTournament then return false end
    nextTournamentTime = 0
    return Tournament.start(tournamentType or "jousting")
end

return Tournament
