-- objects/Gameplay/TournamentJoustingSystem.lua
-- Castle Kingdoms 2027 v3.2.4 - Tournament & Jousting System
--
-- Manages medieval tournaments: jousting, melee, archery competitions.
-- Knights compete for prestige, prizes, and glory.
--
-- Features:
-- - 5 tournament types (joust, melee, archery, grand melee, royal tournament)
-- - 8 knight competitors (NPC + player's knights)
-- - Tournament brackets (single elimination)
-- - Betting system
-- - Prize distribution
-- - Prestige and honor rewards
-- - Injury risk
-- - Tournament fame (long-term reputation)
-- - 6 tournament venues

local Tournament = {}

-- ============================================================
-- TOURNAMENT TYPES
-- ============================================================
local TOURNAMENT_TYPES = {
    joust = {
        name = "Turnir v teku",
        nameEn = "Joust",
        duration = 1,        -- days
        entryFee = 50,
        basePrize = 500,
        prestigeReward = 10,
        injuryRisk = 0.10,
        description = "Klasični dvoboj na kopjah.",
    },
    melee = {
        name = "Melee",
        nameEn = "Melee",
        duration = 2,
        entryFee = 100,
        basePrize = 800,
        prestigeReward = 15,
        injuryRisk = 0.15,
        description = "Skupinski boj pehote.",
    },
    archery = {
        name = "Strelništvo",
        nameEn = "Archery",
        duration = 1,
        entryFee = 30,
        basePrize = 300,
        prestigeReward = 8,
        injuryRisk = 0.02,
        description = "Tekmovalnost v streljanju.",
    },
    grand_melee = {
        name = "Veliki melee",
        nameEn = "Grand Melee",
        duration = 3,
        entryFee = 200,
        basePrize = 2000,
        prestigeReward = 30,
        injuryRisk = 0.25,
        description = "Veliki skupinski boj, zmagovalci vse.",
    },
    royal_tournament = {
        name = "Kraljevi turnir",
        nameEn = "Royal Tournament",
        duration = 5,
        entryFee = 500,
        basePrize = 5000,
        prestigeReward = 50,
        injuryRisk = 0.20,
        description = "Najbolj prestižni turnir, vse discipline.",
    },
}

-- ============================================================
-- TOURNAMENT VENUES
-- ============================================================
local VENUES = {
    village_green = {
        name = "Vaški travnik",
        capacity = 8,
        prestigeBonus = 0,
        description = "Preprost vaški prostor.",
    },
    town_arena = {
        name = "Mestna arena",
        capacity = 16,
        prestigeBonus = 5,
        description = "Mestna arena z gledališči.",
    },
    castle_courtyard = {
        name = "Dvorišče gradu",
        capacity = 12,
        prestigeBonus = 10,
        description = "Gradsko dvorišče, primerno za plemstvo.",
    },
    royal_arena = {
        name = "Kraljeva arena",
        capacity = 32,
        prestigeBonus = 20,
        description = "Velika kraljeva arena.",
    },
    tournament_field = {
        name = "Turnirsko polje",
        capacity = 64,
        prestigeBonus = 30,
        description = "Posebej zgrajeno polje za turnirje.",
    },
    grand_stadium = {
        name = "Veliki stadion",
        capacity = 128,
        prestigeBonus = 50,
        description = "Največji in najbolj prestižni stadion.",
    },
}

-- ============================================================
-- KNIGHT NAMES (for NPC competitors)
-- ============================================================
local KNIGHT_NAMES = {
    "Sir Galahad", "Sir Lancelot", "Sir Gawain", "Sir Percival",
    "Sir Tristan", "Sir Bors", "Sir Bedivere", "Sir Gareth",
    "Sir Kay", "Sir Lamorak", "Sir Gaheris", "Sir Agravain",
    "Sir Caradoc", "Sir Brunor", "Sir Dinadan", "Sir Pelleas",
}

-- ============================================================
-- STATE
-- ============================================================
Tournament.activeTournaments = {}     -- Currently running
Tournament.tournamentHistory = {}     -- Past tournaments
Tournament.playerKnights = {}         -- Player's registered knights
Tournament.activeBets = {}            -- Active bets
Tournament.tournamentFame = 0         -- Long-term fame
Tournament.totalTournaments = 0
Tournament.totalWins = 0
Tournament.totalInjuries = 0
Tournament.totalPrizeMoney = 0
Tournament.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Tournament.init()
    Tournament.activeTournaments = {}
    Tournament.tournamentHistory = {}
    Tournament.playerKnights = {}
    Tournament.activeBets = {}
    Tournament.tournamentFame = 0
    Tournament.totalTournaments = 0
    Tournament.totalWins = 0
    Tournament.totalInjuries = 0
    Tournament.totalPrizeMoney = 0
    Tournament.dayTimer = 0
    print("[Tournament] Tournament & Jousting System initialized (5 types, 6 venues)")
end

-- ============================================================
-- KNIGHT MANAGEMENT
-- ============================================================
function Tournament.recruitKnight(name, skill)
    skill = skill or math.random(30, 90)
    local knight = {
        id = "knight_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        name = name or KNIGHT_NAMES[math.random(#KNIGHT_NAMES)],
        skill = skill,
        health = 100,
        wins = 0,
        losses = 0,
        tournamentsWon = 0,
        recruitedDay = os.time(),
    }
    table.insert(Tournament.playerKnights, knight)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Vitez rekrutiran: %s (spretnost: %d)", knight.name, skill), "success")
    end
    return true, knight.id
end

function Tournament.findKnight(knightId)
    for _, k in ipairs(Tournament.playerKnights) do
        if k.id == knightId then return k end
    end
    return nil
end

-- ============================================================
-- TOURNAMENT ORGANIZATION
-- ============================================================
function Tournament.canOrganize(tournamentType, venueId)
    local def = TOURNAMENT_TYPES[tournamentType]
    if not def then return false, "Neznan tip turnirja" end
    local venue = VENUES[venueId]
    if not venue then return false, "Neznani prostor" end
    -- Check entry fee
    if not _G.state or (_G.state.gold or 0) < def.entryFee then
        return false, "Premalo zlata za vstopnino"
    end
    -- Check venue capacity
    if #Tournament.playerKnights < 1 then
        return false, "Potreben vsaj 1 vitez"
    end
    return true
end

function Tournament.organize(tournamentType, venueId, participantKnightIds)
    local ok, err = Tournament.canOrganize(tournamentType, venueId)
    if not ok then return false, err end
    local def = TOURNAMENT_TYPES[tournamentType]
    local venue = VENUES[venueId]
    -- Pay entry fee
    _G.state.gold = _G.state.gold - def.entryFee
    -- Generate NPC competitors
    local participants = {}
    -- Add player's knights
    for _, kid in ipairs(participantKnightIds or {}) do
        local knight = Tournament.findKnight(kid)
        if knight and knight.health > 50 then
            table.insert(participants, {
                id = knight.id,
                name = knight.name,
                skill = knight.skill,
                isPlayer = true,
                knight = knight,
            })
        end
    end
    -- Add NPCs
    local numNPCs = math.random(4, venue.capacity - #participants)
    for i = 1, numNPCs do
        table.insert(participants, {
            id = "npc_" .. i,
            name = KNIGHT_NAMES[math.random(#KNIGHT_NAMES)] .. " " .. i,
            skill = math.random(30, 95),
            isPlayer = false,
        })
    end
    -- Create tournament
    local tournament = {
        id = "tournament_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = tournamentType,
        typeName = def.name,
        venue = venueId,
        venueName = venue.name,
        daysRemaining = def.duration,
        totalDays = def.duration,
        entryFee = def.entryFee,
        basePrize = def.basePrize,
        prestigeReward = def.prestigeReward + venue.prestigeBonus,
        injuryRisk = def.injuryRisk,
        participants = participants,
        round = 1,
        results = {},
        winner = nil,
        completed = false,
    }
    table.insert(Tournament.activeTournaments, tournament)
    Tournament.totalTournaments = Tournament.totalTournaments + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Turnir organiziran: %s v %s (%d udeležencev)",
                def.name, venue.name, #participants), "important")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "TOURNAMENT_STARTED", {
            type = tournamentType, venue = venueId, participants = #participants,
        })
    end
    return true, tournament.id
end

-- ============================================================
-- TOURNAMENT SIMULATION
-- ============================================================
function Tournament.simulateRound(tournament)
    if tournament.completed then return end
    -- Pair up participants
    local pairs = {}
    local remaining = {}
    for _, p in ipairs(tournament.participants) do
        if not p.eliminated then
            table.insert(remaining, p)
        end
    end
    -- Shuffle
    for i = #remaining, 2, -1 do
        local j = math.random(i)
        remaining[i], remaining[j] = remaining[j], remaining[i]
    end
    -- Pair
    for i = 1, #remaining, 2 do
        if remaining[i + 1] then
            table.insert(pairs, { remaining[i], remaining[i + 1] })
        else
            -- Odd one out advances automatically
            remaining[i].bye = true
        end
    end
    -- Resolve each pair
    for _, pair in ipairs(pairs) do
        local p1, p2 = pair[1], pair[2]
        -- Skill + random
        local p1Score = p1.skill + math.random(0, 30)
        local p2Score = p2.skill + math.random(0, 30)
        local winner, loser
        if p1Score > p2Score then
            winner, loser = p1, p2
        else
            winner, loser = p2, p1
        end
        loser.eliminated = true
        -- Injury check
        if math.random() < tournament.injuryRisk then
            loser.injured = true
            Tournament.totalInjuries = Tournament.totalInjuries + 1
            if loser.isPlayer and loser.knight then
                loser.knight.health = math.max(0, loser.knight.health - math.random(20, 50))
            end
        end
        table.insert(tournament.results, {
            round = tournament.round,
            winner = winner.name,
            loser = loser.name,
            injured = loser.injured or false,
        })
    end
    tournament.round = tournament.round + 1
    -- Check for winner
    local stillIn = 0
    for _, p in ipairs(tournament.participants) do
        if not p.eliminated then stillIn = stillIn + 1 end
    end
    if stillIn <= 1 then
        Tournament.completeTournament(tournament)
    end
end

function Tournament.completeTournament(tournament)
    tournament.completed = true
    -- Find winner
    for _, p in ipairs(tournament.participants) do
        if not p.eliminated then
            tournament.winner = p
            -- Award prizes
            if p.isPlayer and p.knight then
                if _G.state then
                    _G.state.gold = (_G.state.gold or 0) + tournament.basePrize
                end
                Tournament.totalPrizeMoney = Tournament.totalPrizeMoney + tournament.basePrize
                Tournament.totalWins = Tournament.totalWins + 1
                p.knight.tournamentsWon = p.knight.tournamentsWon + 1
                p.knight.wins = p.knight.wins + 1
                Tournament.tournamentFame = Tournament.tournamentFame + tournament.prestigeReward
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        string.format("ZMAGA! %s zmagal na %s! +%d zlata, +%d prestiža",
                            p.name, tournament.typeName, tournament.basePrize,
                            tournament.prestigeReward), "rare")
                end
                if _G.GameEventBus then
                    pcall(_G.GameEventBus.publish, "TOURNAMENT_WON", {
                        knightName = p.name, prize = tournament.basePrize,
                    })
                end
            else
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        string.format("%s zmagal na %s (NPC)", p.name, tournament.typeName), "info")
                end
            end
            break
        end
    end
    -- Update knight records (losses)
    for _, p in ipairs(tournament.participants) do
        if p.isPlayer and p.knight and p.eliminated then
            p.knight.losses = p.knight.losses + 1
        end
    end
    -- Add to history
    table.insert(Tournament.tournamentHistory, {
        type = tournament.type,
        typeName = tournament.typeName,
        venue = tournament.venueName,
        winner = tournament.winner and tournament.winner.name or "—",
        rounds = tournament.round - 1,
        completedDay = os.time(),
    })
end

-- ============================================================
-- BETTING
-- ============================================================
function Tournament.placeBet(knightId, amount)
    if not _G.state or (_G.state.gold or 0) < amount then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - amount
    table.insert(Tournament.activeBets, {
        knightId = knightId,
        amount = amount,
        potentialPayout = math.floor(amount * (2 + math.random())),  -- 2x-3x
    })
    return true
end

function Tournament.resolveBets(tournament)
    if not tournament.winner then return end
    for i = #Tournament.activeBets, 1, -1 do
        local bet = Tournament.activeBets[i]
        if bet.knightId == tournament.winner.id then
            -- Won bet
            if _G.state then
                _G.state.gold = (_G.state.gold or 0) + bet.potentialPayout
            end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("Stava dobljena! +%d zlata", bet.potentialPayout), "success")
            end
        else
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("Stava izgubljena: -%d zlata", bet.amount), "warning")
            end
        end
        table.remove(Tournament.activeBets, i)
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Tournament.update(dt)
    if not _G.state then return end
    Tournament.dayTimer = Tournament.dayTimer + dt
    if Tournament.dayTimer >= 30 then
        Tournament.dayTimer = 0
        -- Process tournaments
        for i = #Tournament.activeTournaments, 1, -1 do
            local t = Tournament.activeTournaments[i]
            if not t.completed then
                t.daysRemaining = t.daysRemaining - 1
                Tournament.simulateRound(t)
                if t.completed then
                    Tournament.resolveBets(t)
                end
                if t.daysRemaining <= 0 and not t.completed then
                    Tournament.completeTournament(t)
                    Tournament.resolveBets(t)
                end
                if t.completed then
                    -- Keep in list briefly for UI, then remove
                    t.cleanupTimer = 60
                end
            else
                t.cleanupTimer = (t.cleanupTimer or 60) - 1
                if t.cleanupTimer <= 0 then
                    table.remove(Tournament.activeTournaments, i)
                end
            end
        end
        -- Heal knights slowly
        for _, k in ipairs(Tournament.playerKnights) do
            if k.health < 100 then
                k.health = math.min(100, k.health + 2)
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Tournament.getTournamentTypeInfo(typeId) return TOURNAMENT_TYPES[typeId] end
function Tournament.getVenueInfo(venueId) return VENUES[venueId] end
function Tournament.getPlayerKnights() return Tournament.playerKnights end

function Tournament.getStats()
    return {
        activeTournaments = #Tournament.activeTournaments,
        totalTournaments = Tournament.totalTournaments,
        totalWins = Tournament.totalWins,
        totalInjuries = Tournament.totalInjuries,
        totalPrizeMoney = Tournament.totalPrizeMoney,
        tournamentFame = Tournament.tournamentFame,
        numKnights = #Tournament.playerKnights,
        activeBets = #Tournament.activeBets,
    }
end

return Tournament
