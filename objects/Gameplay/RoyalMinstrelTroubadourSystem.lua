-- objects/Gameplay/RoyalMinstrelTroubadourSystem.lua
-- Castle Kingdoms 2027 v3.5.4 - Royal Minstrel & Troubadour System
--
-- Manages traveling musicians, troubadours, and itinerant performers.
-- Distinct from court musicians — these travel between courts spreading news and songs.
--
-- Features:
-- - 6 minstrel types (troubadour, jongleur, minnesinger, bard, gleeman, skald)
-- - 8 song types (love, heroic, comic, elegy, ballad, drinking, morning, evening)
-- - 4 performance venues (tavern, market square, castle gate, crossroads)
-- - Minstrel NPC management (hire, send touring, receive visiting)
-- - Song composition
-- - News spreading (minstrels carry news between courts)
-- - Reputation system
-- - Patronage and tips

local Minstrel = {}

-- ============================================================
-- MINSTREL TYPES
-- ============================================================
local MINSTRELS = {
    troubadour = {
        name = "Trubadur",
        nameEn = "Troubadour",
        cost = 300,
        upkeep = 15,
        skill = 60,
        prestige = 8,
        description = "Plemiški glasbenik z romancami.",
    },
    jongleur = {
        name = "Žongler",
        nameEn = "Jongleur",
        cost = 100,
        upkeep = 5,
        skill = 40,
        prestige = 2,
        description = "Potujoči zabavalec z akrobacijami.",
    },
    minnesinger = {
        name = "Minnesinger",
        nameEn = "Minnesinger",
        cost = 400,
        upkeep = 20,
        skill = 65,
        prestige = 10,
        description = "Nemški dvorni pevec ljubezni.",
    },
    bard = {
        name = "Bard",
        nameEn = "Bard",
        cost = 350,
        upkeep = 18,
        skill = 55,
        prestige = 7,
        description = "Pripovedovalec zgodb in epskih pesmi.",
    },
    gleeman = {
        name = "Gliman",
        nameEn = "Gleeman",
        cost = 150,
        upkeep = 8,
        skill = 45,
        prestige = 3,
        description = "Anglosaški potujoči glasbenik.",
    },
    skald = {
        name = "Skald",
        nameEn = "Skald",
        cost = 500,
        upkeep = 25,
        skill = 70,
        prestige = 12,
        description = "Nordijski pesnik in zgodovinar.",
    },
}

-- ============================================================
-- SONG TYPES
-- ============================================================
local SONGS = {
    love = {
        name = "Ljubezenska pesem",
        nameEn = "Love Song",
        duration = 5,
        happinessBonus = 8,
        description = "Romantična pesem o ljubezni.",
    },
    heroic = {
        name = "Junaška pesem",
        nameEn = "Heroic Song",
        duration = 10,
        happinessBonus = 6,
        moraleBonus = 10,
        description = "Pripoved o junaštvih.",
    },
    comic = {
        name = "Šaljiva pesem",
        nameEn = "Comic Song",
        duration = 5,
        happinessBonus = 12,
        description = "Zabavna pesem za smeh.",
    },
    elegy = {
        name = "Elegija",
        nameEn = "Elegy",
        duration = 8,
        happinessBonus = -2,
        faithBonus = 5,
        description = "Žalostinka za mrtve.",
    },
    ballad = {
        name = "Balada",
        nameEn = "Ballad",
        duration = 7,
        happinessBonus = 7,
        prestigeBonus = 5,
        description = "Pripovedna pesem o dogodkih.",
    },
    drinking = {
        name = "Pijančevanje",
        nameEn = "Drinking Song",
        duration = 5,
        happinessBonus = 10,
        description = "Vesela pesem za krčme.",
    },
    morning = {
        name = "Jutranja pesem",
        nameEn = "Morning Song",
        duration = 3,
        happinessBonus = 5,
        description = "Pesem za dobro jutro.",
    },
    evening = {
        name = "Večerna pesem",
        nameEn = "Evening Song",
        duration = 4,
        happinessBonus = 6,
        description = "Pesem za mirno večer.",
    },
}

-- ============================================================
-- PERFORMANCE VENUES
-- ============================================================
local VENUES = {
    tavern = {
        name = "Krčma",
        cost = 200,
        audienceSize = 20,
        tipsBonus = 10,
        description = "Lokalna krčma za navadne ljudi.",
    },
    market_square = {
        name = "Trg",
        cost = 0,
        audienceSize = 100,
        tipsBonus = 15,
        description = "Javni trg za velike audience.",
    },
    castle_gate = {
        name = "Vrata gradu",
        cost = 100,
        audienceSize = 50,
        tipsBonus = 25,
        prestigeBonus = 5,
        description = "Pred vrati gradu.",
    },
    crossroads = {
        name = "Rižišče",
        cost = 0,
        audienceSize = 30,
        tipsBonus = 8,
        newsBonus = 20,
        description = "Potujoči glasbeniki na rižiščih.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Minstrel.minstrels = {}                    -- Hired minstrels
Minstrel.activePerformances = {}           -- Ongoing performances
Minstrel.visitingMinstrels = {}            -- Minstrels from other courts
Minstrel.songLibrary = {}                  -- Composed songs
Minstrel.newsItems = {}                    -- News carried by minstrels
Minstrel.reputation = 50                   -- 0-100
Minstrel.totalPerformances = 0
Minstrel.totalTipsEarned = 0
Minstrel.totalSongsComposed = 0
Minstrel.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Minstrel.init()
    Minstrel.minstrels = {}
    Minstrel.activePerformances = {}
    Minstrel.visitingMinstrels = {}
    Minstrel.songLibrary = {}
    Minstrel.newsItems = {}
    Minstrel.reputation = 50
    Minstrel.totalPerformances = 0
    Minstrel.totalTipsEarned = 0
    Minstrel.totalSongsComposed = 0
    Minstrel.dayTimer = 0
    print("[Minstrel] Royal Minstrel & Troubadour System initialized (6 minstrels, 8 songs, 4 venues)")
end

-- ============================================================
-- HIRING MINSTRELS
-- ============================================================
function Minstrel.canHire(minstrelType)
    local def = MINSTRELS[minstrelType]
    if not def then return false, "Neznan glasbenik" end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    return true
end

function Minstrel.hire(minstrelType, customName)
    local ok, err = Minstrel.canHire(minstrelType)
    if not ok then return false, err end
    local def = MINSTRELS[minstrelType]
    _G.state.gold = _G.state.gold - def.cost
    local minstrel = {
        id = "minstrel_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = minstrelType,
        name = customName or (def.name .. " " .. #Minstrel.minstrels + 1),
        skill = def.skill + math.random(-5, 10),
        prestige = def.prestige,
        status = "available",  -- available, performing, touring, resting
        energy = 100,
        hiredDay = os.time(),
        performances = 0,
    }
    table.insert(Minstrel.minstrels, minstrel)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Glasbenik najet: %s (%s)", minstrel.name, def.name), "success")
    end
    return true
end

function Minstrel.findMinstrel(minstrelId)
    for _, m in ipairs(Minstrel.minstrels) do
        if m.id == minstrelId then return m end
    end
    return nil
end

-- ============================================================
-- PERFORMING
-- ============================================================
function Minstrel.canPerform(minstrelId, songType, venueId)
    local m = Minstrel.findMinstrel(minstrelId)
    if not m then return false, "Glasbenik ne obstaja" end
    if m.status ~= "available" then return false, "Glasbenik ni prost" end
    if m.energy < 20 then return false, "Glasbenik je preutrujen" end
    local songDef = SONGS[songType]
    if not songDef then return false, "Neznana pesem" end
    local venueDef = VENUES[venueId]
    if not venueDef then return false, "Neznan kraj" end
    if venueDef.cost > 0 and (not _G.state or (_G.state.gold or 0) < venueDef.cost) then
        return false, "Premalo zlata za najem kraja"
    end
    return true
end

function Minstrel.perform(minstrelId, songType, venueId)
    local ok, err = Minstrel.canPerform(minstrelId, songType, venueId)
    if not ok then return false, err end
    local m = Minstrel.findMinstrel(minstrelId)
    local songDef = SONGS[songType]
    local venueDef = VENUES[venueId]
    if venueDef.cost > 0 and _G.state then
        _G.state.gold = _G.state.gold - venueDef.cost
    end
    -- Calculate tips
    local tips = venueDef.tipsBonus + math.random(0, m.skill / 2)
    tips = math.floor(tips * (venueDef.audienceSize / 20))
    -- Calculate quality
    local quality = 0.5 + (m.skill / 100) + (Minstrel.reputation / 200)
    quality = math.min(1.5, quality)
    local performance = {
        id = "perf_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        minstrelId = minstrelId,
        minstrelName = m.name,
        songType = songType,
        songName = songDef.name,
        venue = venueId,
        venueName = venueDef.name,
        daysRemaining = songDef.duration,
        expectedTips = tips,
        happinessBonus = math.floor(songDef.happinessBonus * quality),
        moraleBonus = math.floor((songDef.moraleBonus or 0) * quality),
        prestigeBonus = math.floor((songDef.prestigeBonus or 0) * quality),
        faithBonus = math.floor((songDef.faithBonus or 0) * quality),
        quality = quality,
        started = os.time(),
    }
    table.insert(Minstrel.activePerformances, performance)
    m.status = "performing"
    m.energy = math.max(0, m.energy - 20)
    Minstrel.totalPerformances = Minstrel.totalPerformances + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Nastop: %s poje %s pri %s",
                m.name, songDef.name, venueDef.name), "info")
    end
    return true
end

function Minstrel.completePerformance(performance)
    local m = Minstrel.findMinstrel(performance.minstrelId)
    -- Apply effects
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.max(0, math.min(100, _G.state.happiness + performance.happinessBonus))
    end
    if performance.faithBonus > 0 and _G.Religion then
        pcall(_G.Religion.addFaith, performance.faithBonus)
    end
    -- Tips
    local actualTips = performance.expectedTips + math.random(-10, 20)
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + actualTips
    end
    Minstrel.totalTipsEarned = Minstrel.totalTipsEarned + actualTips
    -- Reputation gain
    Minstrel.reputation = math.min(100, Minstrel.reputation + math.floor(performance.quality))
    if m then
        m.status = "available"
        m.performances = m.performances + 1
        -- Energy recovery
        m.energy = math.min(100, m.energy + 30)
        -- Skill progression
        if math.random() < 0.15 then
            m.skill = math.min(100, m.skill + 1)
        end
    end
    -- News chance
    if math.random() < 0.30 then
        Minstrel.receiveNews()
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Nastop končan: %s (+%d sreče, +%d zlata)",
                performance.songName, performance.happinessBonus, actualTips), "success")
    end
end

-- ============================================================
-- SONG COMPOSITION
-- ============================================================
function Minstrel.composeSong(minstrelId, songType)
    local m = Minstrel.findMinstrel(minstrelId)
    if not m then return false, "Glasbenik ne obstaja" end
    if m.energy < 40 then return false, "Glasbenik je preutrujen" end
    local songDef = SONGS[songType]
    if not songDef then return false, "Neznana pesem" end
    m.energy = m.energy - 30
    local quality = 0.5 + (m.skill / 100) + math.random() * 0.3
    quality = math.min(1.5, quality)
    local song = {
        id = "song_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = songType,
        name = songDef.name .. " #" .. (#Minstrel.songLibrary + 1),
        quality = quality,
        happinessBonus = math.floor(songDef.happinessBonus * quality),
        composer = m.name,
        composedDay = os.time(),
    }
    table.insert(Minstrel.songLibrary, song)
    Minstrel.totalSongsComposed = Minstrel.totalSongsComposed + 1
    -- Prestige
    Minstrel.reputation = math.min(100, Minstrel.reputation + 2)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Pesem skomponirana: %s (kakovost: %.1f)", song.name, quality), "success")
    end
    return true
end

-- ============================================================
-- TOURING
-- ============================================================
function Minstrel.sendOnTour(minstrelId, targetFaction)
    local m = Minstrel.findMinstrel(minstrelId)
    if not m then return false, "Glasbenik ne obstaja" end
    if m.status ~= "available" then return false, "Glasbenik ni prost" end
    m.status = "touring"
    m.tourTarget = targetFaction or "neighboring court"
    m.tourDaysRemaining = 30
    -- Immediate diplomatic boost
    if _G.DiplomacyController then
        pcall(_G.DiplomacyController.changeRelation, targetFaction, 5)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("%s poslan na turnejo k %s", m.name, tostring(targetFaction)), "info")
    end
    return true
end

function Minstrel.updateTouring()
    for _, m in ipairs(Minstrel.minstrels) do
        if m.status == "touring" then
            m.tourDaysRemaining = (m.tourDaysRemaining or 0) - 1
            if m.tourDaysRemaining <= 0 then
                -- Return from tour with reputation and news
                m.status = "available"
                m.energy = 100
                Minstrel.reputation = math.min(100, Minstrel.reputation + 5)
                -- Receive news from the visited court
                Minstrel.receiveNews()
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        string.format("%s se vrnil s turneje! +5 ugleda", m.name), "success")
                end
            end
        end
    end
end

-- ============================================================
-- VISITING MINSTRELS & NEWS
-- ============================================================
function Minstrel.receiveVisitingMinstrel()
    local types = {}
    for id, _ in pairs(MINSTRELS) do
        table.insert(types, id)
    end
    local selectedType = types[math.random(#types)]
    local def = MINSTRELS[selectedType]
    local visitor = {
        id = "visitor_" .. tostring(os.time()),
        type = selectedType,
        name = def.name .. " iz tujine",
        skill = def.skill + math.random(-10, 10),
        stayDuration = 5,
        offersSong = math.random() < 0.60,
    }
    table.insert(Minstrel.visitingMinstrels, visitor)
    -- Happiness boost from visiting performer
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + 3)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Gostujoči glasbenik: %s", visitor.name), "info")
    end
end

function Minstrel.receiveNews()
    local newsTypes = {
        "Poroka v sosednji deželi",
        "Gladovna stavka na severu",
        "Novi zakoni v cesarstvu",
        "Bitka na vzhodni meji",
        "Romarska procesija prihaja",
        "Trgovec je našel zaklad",
        "Kuga v daljni deželi",
        "Mir med dvema kraljestvoma",
    }
    local news = newsTypes[math.random(#newsTypes)]
    table.insert(Minstrel.newsItems, {
        text = news,
        receivedDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Glasbenik prinaša novice: " .. news, "info")
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Minstrel.update(dt)
    if not _G.state then return end
    Minstrel.dayTimer = Minstrel.dayTimer + dt
    if Minstrel.dayTimer >= 30 then
        Minstrel.dayTimer = 0
        -- Process performances
        for i = #Minstrel.activePerformances, 1, -1 do
            local p = Minstrel.activePerformances[i]
            p.daysRemaining = p.daysRemaining - 1
            if p.daysRemaining <= 0 then
                Minstrel.completePerformance(p)
                table.remove(Minstrel.activePerformances, i)
            end
        end
        -- Update touring
        Minstrel.updateTouring()
        -- Energy recovery for available minstrels
        for _, m in ipairs(Minstrel.minstrels) do
            if m.status == "available" and m.energy < 100 then
                m.energy = math.min(100, m.energy + 10)
            end
        end
        -- Update visiting minstrels
        for i = #Minstrel.visitingMinstrels, 1, -1 do
            local v = Minstrel.visitingMinstrels[i]
            v.stayDuration = v.stayDuration - 1
            if v.stayDuration <= 0 then
                table.remove(Minstrel.visitingMinstrels, i)
            end
        end
        -- Random visiting minstrel chance
        if math.random() < 0.10 then
            Minstrel.receiveVisitingMinstrel()
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, m in ipairs(Minstrel.minstrels) do
            if m.status ~= "touring" then
                local def = MINSTRELS[m.type]
                if def then totalUpkeep = totalUpkeep + def.upkeep end
            end
        end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Reputation slowly drifts to 50
        if Minstrel.reputation > 50 then
            Minstrel.reputation = Minstrel.reputation - 0.2
        elseif Minstrel.reputation < 50 then
            Minstrel.reputation = Minstrel.reputation + 0.1
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Minstrel.getMinstrelInfo(typeId) return MINSTRELS[typeId] end
function Minstrel.getSongInfo(songId) return SONGS[songId] end
function Minstrel.getVenueInfo(venueId) return VENUES[venueId] end

function Minstrel.getStats()
    return {
        numMinstrels = #Minstrel.minstrels,
        activePerformances = #Minstrel.activePerformances,
        visitingMinstrels = #Minstrel.visitingMinstrels,
        songLibrarySize = #Minstrel.songLibrary,
        newsItems = #Minstrel.newsItems,
        reputation = Minstrel.reputation,
        totalPerformances = Minstrel.totalPerformances,
        totalTipsEarned = Minstrel.totalTipsEarned,
        totalSongsComposed = Minstrel.totalSongsComposed,
    }
end

return Minstrel
