-- objects/Gameplay/RoyalJesterAdvancedCourtComedySystem.lua
-- Castle Kingdoms 2027 v3.5.5 - Royal Jester Advanced & Court Comedy System
--
-- Advanced jester system: comedy routines, satire, improvisation, and
-- the delicate art of mocking the powerful without consequence.
--
-- Features:
-- - 8 joke types (slapstick, wordplay, satire, observational, dark, puns, physical, absurd)
-- - 6 jester archetypes (fool, trickster, wit, buffoon, satirist, madman)
-- - 4 comedy venues (throne room, great hall, garden stage, market)
-- - Jester NPC with comedy skill and risk management
-- - Routine composition
-- - Audience reaction system
-- - Political satire (risky but effective)
-- - Jester immunity (license to mock)

local Comedy = {}

-- ============================================================
-- JOKE TYPES
-- ============================================================
local JOKES = {
    slapstick = {
        name = "Pohabljenje",
        nameEn = "Slapstick",
        happinessBonus = 8,
        offenseRisk = 0.05,
        description = "Fizična komedija — padci, udarci, zmešnjave.",
    },
    wordplay = {
        name = "Besedne igre",
        nameEn = "Wordplay",
        happinessBonus = 6,
        offenseRisk = 0.03,
        intellectualBonus = 5,
        description = "Pametne besedne igre in dvojne pomeni.",
    },
    satire = {
        name = "Satira",
        nameEn = "Satire",
        happinessBonus = 10,
        offenseRisk = 0.30,
        politicalBonus = 15,
        description = "Izpostavljanje nepravilnosti — tvegano.",
    },
    observational = {
        name = "Opazovalna",
        nameEn = "Observational",
        happinessBonus = 7,
        offenseRisk = 0.08,
        description = "Šale iz vsakdanjega življenja.",
    },
    dark = {
        name = "Črna",
        nameEn = "Dark Humor",
        happinessBonus = 5,
        offenseRisk = 0.20,
        description = "Šale o smrti in boleznini — ne za vse.",
    },
    puns = {
        name = "Igre besed",
        nameEn = "Puns",
        happinessBonus = 4,
        offenseRisk = 0.02,
        description = "Preproste besedne igre.",
    },
    physical = {
        name = "Telesna",
        nameEn = "Physical Comedy",
        happinessBonus = 9,
        offenseRisk = 0.05,
        description = "Mimika, geste, telesne gibe.",
    },
    absurd = {
        name = "Absurdna",
        nameEn = "Absurdist",
        happinessBonus = 7,
        offenseRisk = 0.10,
        intellectualBonus = 8,
        description = "Nesmiselne in nenavadne šale.",
    },
}

-- ============================================================
-- JESTER ARCHETYPES
-- ============================================================
local ARCHETYPES = {
    fool = {
        name = "Norček",
        nameEn = "Fool",
        cost = 100,
        upkeep = 5,
        comedySkill = 40,
        immunity = 0.30,
        description = "Klasični dvorni norček.",
    },
    trickster = {
        name = "Prebrisanež",
        nameEn = "Trickster",
        cost = 250,
        upkeep = 12,
        comedySkill = 55,
        immunity = 0.40,
        description = "Pridevščki in zvijače.",
    },
    wit = {
        name = "Dušjak",
        nameEn = "Wit",
        cost = 400,
        upkeep = 20,
        comedySkill = 70,
        immunity = 0.50,
        description = "Pametne in ostre opazke.",
    },
    buffoon = {
        name = "Bedak",
        nameEn = "Buffoon",
        cost = 150,
        upkeep = 8,
        comedySkill = 45,
        immunity = 0.35,
        description = "Gromko in neumno."
    },
    satirist = {
        name = "Satirik",
        nameEn = "Satirist",
        cost = 600,
        upkeep = 30,
        comedySkill = 75,
        immunity = 0.60,
        description = "Specialist za politično satiro.",
    },
    madman = {
        name = "Norec",
        nameEn = "Madman",
        cost = 300,
        upkeep = 15,
        comedySkill = 60,
        immunity = 0.70,
        description = "Nepredvidljiv in blazen — visoka imuniteta.",
    },
}

-- ============================================================
-- COMEDY VENUES
-- ============================================================
local VENUES = {
    throne_room = {
        name = "Prestolna dvorana",
        audienceSize = 30,
        prestigeBonus = 5,
        riskMultiplier = 1.5,
        description = "Najboljše občinstvo, a najbolj tvegano.",
    },
    great_hall = {
        name = "Velika dvorana",
        audienceSize = 100,
        prestigeBonus = 3,
        riskMultiplier = 1.0,
        description = "Veliko občinstvo, zmerno tveganje.",
    },
    garden_stage = {
        name = "Vrtni oder",
        audienceSize = 50,
        prestigeBonus = 2,
        riskMultiplier = 0.8,
        description = "Sproščeno okolje, manj tveganja.",
    },
    market = {
        name = "Trg",
        audienceSize = 200,
        prestigeBonus = 1,
        riskMultiplier = 0.5,
        tipsBonus = 20,
        description = "Javni nastop — veliko občinstvo, malo tveganja.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Comedy.jesters = {}                       -- Hired jesters
Comedy.activeRoutines = {}                -- Ongoing performances
Comedy.comedyLibrary = {}                 -- Composed routines
Comedy.totalJokes = 0
Comedy.totalOffenses = 0
Comedy.totalLaughs = 0
Comedy.courtMorale = 50                   -- 0-100
Comedy.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Comedy.init()
    Comedy.jesters = {}
    Comedy.activeRoutines = {}
    Comedy.comedyLibrary = {}
    Comedy.totalJokes = 0
    Comedy.totalOffenses = 0
    Comedy.totalLaughs = 0
    Comedy.courtMorale = 50
    Comedy.dayTimer = 0
    print("[Comedy] Royal Jester Advanced & Court Comedy System initialized (8 jokes, 6 archetypes, 4 venues)")
end

-- ============================================================
-- HIRING JESTERS
-- ============================================================
function Comedy.canHire(archetype)
    local def = ARCHETYPES[archetype]
    if not def then return false, "Neznan tip norčka" end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    return true
end

function Comedy.hire(archetype, customName)
    local ok, err = Comedy.canHire(archetype)
    if not ok then return false, err end
    local def = ARCHETYPES[archetype]
    _G.state.gold = _G.state.gold - def.cost
    local jester = {
        id = "jester_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        archetype = archetype,
        name = customName or (def.name .. " " .. #Comedy.jesters + 1),
        comedySkill = def.comedySkill + math.random(-5, 10),
        immunity = def.immunity,
        energy = 100,
        status = "available",
        hiredDay = os.time(),
        routinesPerformed = 0,
    }
    table.insert(Comedy.jesters, jester)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Norček najet: %s (%s)", jester.name, def.name), "success")
    end
    return true
end

function Comedy.findJester(jesterId)
    for _, j in ipairs(Comedy.jesters) do
        if j.id == jesterId then return j end
    end
    return nil
end

-- ============================================================
-- PERFORMING ROUTINES
-- ============================================================
function Comedy.canPerform(jesterId, jokeType, venueId)
    local j = Comedy.findJester(jesterId)
    if not j then return false, "Norček ne obstaja" end
    if j.status ~= "available" then return false, "Norček ni prost" end
    if j.energy < 20 then return false, "Norček je preutrujen" end
    local jokeDef = JOKES[jokeType]
    if not jokeDef then return false, "Neznana šala" end
    local venueDef = VENUES[venueId]
    if not venueDef then return false, "Neznan kraj" end
    return true
end

function Comedy.perform(jesterId, jokeType, venueId)
    local ok, err = Comedy.canPerform(jesterId, jokeType, venueId)
    if not ok then return false, err end
    local j = Comedy.findJester(jesterId)
    local jokeDef = JOKES[jokeType]
    local venueDef = VENUES[venueId]
    -- Calculate success and offense
    local successChance = 0.50 + (j.comedySkill / 200)
    local offenseChance = jokeDef.offenseRisk * venueDef.riskMultiplier * (1 - j.immunity)
    -- Calculate happiness effect
    local happinessBonus = jokeDef.happinessBonus
    local quality = 0.5 + (j.comedySkill / 100) + math.random() * 0.3
    quality = math.min(1.5, quality)
    local routine = {
        id = "routine_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        jesterId = jesterId,
        jesterName = j.name,
        jokeType = jokeType,
        jokeName = jokeDef.name,
        venue = venueId,
        venueName = venueDef.name,
        daysRemaining = 2,
        successChance = successChance,
        offenseChance = offenseChance,
        happinessBonus = math.floor(happinessBonus * quality),
        prestigeBonus = math.floor((venueDef.prestigeBonus or 0) * quality),
        tipsBonus = math.floor((venueDef.tipsBonus or 0) * quality),
        intellectualBonus = math.floor((jokeDef.intellectualBonus or 0) * quality),
        politicalBonus = math.floor((jokeDef.politicalBonus or 0) * quality),
        quality = quality,
        started = os.time(),
    }
    table.insert(Comedy.activeRoutines, routine)
    j.status = "performing"
    j.energy = math.max(0, j.energy - 25)
    Comedy.totalJokes = Comedy.totalJokes + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Norček nastopa: %s (%s pri %s)",
                j.name, jokeDef.name, venueDef.name), "info")
    end
    return true
end

function Comedy.completeRoutine(routine)
    local j = Comedy.findJester(routine.jesterId)
    -- Roll for offense first
    if math.random() < routine.offenseChance then
        -- Offended someone!
        Comedy.totalOffenses = Comedy.totalOffenses + 1
        if _G.state and _G.state.happiness then
            _G.state.happiness = math.max(0, _G.state.happiness - 10)
        end
        Comedy.courtMorale = math.max(0, Comedy.courtMorale - 5)
        -- Jester might be punished
        if math.random() < (1 - (j and j.immunity or 0)) then
            -- Punished
            if j then
                j.energy = math.max(0, j.energy - 30)
                if math.random() < 0.10 then
                    j.status = "expelled"
                    if _G.NotificationCenter then
                        pcall(_G.NotificationCenter.notify,
                            string.format("Norček izgnan: %s! Preveč je žalil.", j.name), "danger")
                    end
                else
                    j.status = "available"
                    if _G.NotificationCenter then
                        pcall(_G.NotificationCenter.notify,
                            string.format("Norček žalil občinstvo: %s", j.name), "warning")
                    end
                end
            end
        else
            -- Immunity protected them
            if j then j.status = "available" end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    "Norček je žalil, a imunost ga ščiti.", "info")
            end
        end
        return
    end
    -- Roll for success
    if math.random() < routine.successChance then
        -- Success!
        Comedy.totalLaughs = Comedy.totalLaughs + 1
        if _G.state and _G.state.happiness then
            _G.state.happiness = math.min(100, _G.state.happiness + routine.happinessBonus)
        end
        Comedy.courtMorale = math.min(100, Comedy.courtMorale + math.floor(routine.happinessBonus / 2))
        -- Tips
        if routine.tipsBonus > 0 and _G.state then
            _G.state.gold = (_G.state.gold or 0) + routine.tipsBonus
        end
        if j then
            j.status = "available"
            j.routinesPerformed = j.routinesPerformed + 1
            j.energy = math.min(100, j.energy + 20)
            if math.random() < 0.15 then
                j.comedySkill = math.min(100, j.comedySkill + 1)
            end
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Norček nasmejal občinstvo: %s (+%d sreče)",
                    routine.jesterName, routine.happinessBonus), "success")
        end
    else
        -- Failed (no offense, but no laughs either)
        if j then j.status = "available" end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Norček ni nasmejal: %s", routine.jesterName), "info")
        end
    end
end

-- ============================================================
-- ROUTINE COMPOSITION
-- ============================================================
function Comedy.composeRoutine(jesterId, jokeType)
    local j = Comedy.findJester(jesterId)
    if not j then return false, "Norček ne obstaja" end
    if j.energy < 30 then return false, "Norček je preutrujen" end
    local jokeDef = JOKES[jokeType]
    if not jokeDef then return false, "Neznana šala" end
    j.energy = j.energy - 20
    local quality = 0.5 + (j.comedySkill / 100) + math.random() * 0.4
    quality = math.min(1.8, quality)
    local routine = {
        id = "routine_comp_" .. tostring(os.time()),
        jokeType = jokeType,
        name = jokeDef.name .. " #" .. (#Comedy.comedyLibrary + 1),
        quality = quality,
        happinessBonus = math.floor(jokeDef.happinessBonus * quality),
        offenseRisk = jokeDef.offenseRisk / quality,  -- better quality = less risk
        composer = j.name,
        composedDay = os.time(),
    }
    table.insert(Comedy.comedyLibrary, routine)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Rutina skomponirana: %s (kakovost: %.1f)", routine.name, quality), "success")
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Comedy.update(dt)
    if not _G.state then return end
    Comedy.dayTimer = Comedy.dayTimer + dt
    if Comedy.dayTimer >= 30 then
        Comedy.dayTimer = 0
        -- Process routines
        for i = #Comedy.activeRoutines, 1, -1 do
            local r = Comedy.activeRoutines[i]
            r.daysRemaining = r.daysRemaining - 1
            if r.daysRemaining <= 0 then
                Comedy.completeRoutine(r)
                table.remove(Comedy.activeRoutines, i)
            end
        end
        -- Remove expelled jesters
        for i = #Comedy.jesters, 1, -1 do
            if Comedy.jesters[i].status == "expelled" then
                Comedy.jesters[i].cleanupTimer = (Comedy.jesters[i].cleanupTimer or 30) - 1
                if Comedy.jesters[i].cleanupTimer <= 0 then
                    table.remove(Comedy.jesters, i)
                end
            end
        end
        -- Energy recovery
        for _, j in ipairs(Comedy.jesters) do
            if j.status == "available" and j.energy < 100 then
                j.energy = math.min(100, j.energy + 10)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, j in ipairs(Comedy.jesters) do
            if j.status ~= "expelled" then
                local def = ARCHETYPES[j.archetype]
                if def then totalUpkeep = totalUpkeep + def.upkeep end
            end
        end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Court morale drifts to 50
        if Comedy.courtMorale > 50 then
            Comedy.courtMorale = Comedy.courtMorale - 0.5
        elseif Comedy.courtMorale < 50 then
            Comedy.courtMorale = Comedy.courtMorale + 0.3
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Comedy.getJokeInfo(jokeId) return JOKES[jokeId] end
function Comedy.getArchetypeInfo(archId) return ARCHETYPES[archId] end
function Comedy.getVenueInfo(venueId) return VENUES[venueId] end

function Comedy.getStats()
    return {
        numJesters = #Comedy.jesters,
        activeRoutines = #Comedy.activeRoutines,
        comedyLibrarySize = #Comedy.comedyLibrary,
        totalJokes = Comedy.totalJokes,
        totalOffenses = Comedy.totalOffenses,
        totalLaughs = Comedy.totalLaughs,
        courtMorale = Comedy.courtMorale,
    }
end

return Comedy
