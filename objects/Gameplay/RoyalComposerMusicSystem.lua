-- objects/Gameplay/RoyalComposerMusicSystem.lua
-- Castle Kingdoms 2027 v3.4.5 - Royal Composer & Music System
--
-- Manages court musicians, compositions, and musical performances.
-- Music provides happiness, prestige, and cultural bonuses.
--
-- Features:
-- - 6 instrument types (lute, harp, flute, drum, organ, violin)
-- - 8 composition types (mass, madrigal, ballad, dance, anthem, lament, sonata, opera)
-- - Composer NPC (skill affects quality)
-- - Music hall buildings
-- - Composition creation (time-based)
-- - Public performances
-- - Musical patronage
-- - Court orchestra management
-- - Cultural exchange through music

local Music = {}

-- ============================================================
-- INSTRUMENT TYPES
-- ============================================================
local INSTRUMENTS = {
    lute = {
        name = "Lutnja",
        nameEn = "Lute",
        cost = 100,
        upkeep = 2,
        versatility = 0.8,
        description = "Vsestranski instrument za dvorno glasbo.",
    },
    harp = {
        name = "Harfa",
        nameEn = "Harp",
        cost = 300,
        upkeep = 5,
        versatility = 0.6,
        eleganceBonus = 10,
        description = "Elegantna harfa za slovesnosti.",
    },
    flute = {
        name = "Flavta",
        nameEn = "Flute",
        cost = 50,
        upkeep = 1,
        versatility = 0.7,
        description = "Preprosta flavta za prijetne melodije.",
    },
    drum = {
        name = "Boben",
        nameEn = "Drum",
        cost = 80,
        upkeep = 1,
        versatility = 0.5,
        militaryBonus = 5,
        description = "Vojaški boben za morale.",
    },
    organ = {
        name = "Orgle",
        cost = 2000,
        upkeep = 30,
        versatility = 0.9,
        faithBonus = 15,
        description = "Cerkvene orgle za verske obrede.",
    },
    violin = {
        name = "Violina",
        nameEn = "Violin",
        cost = 500,
        upkeep = 8,
        versatility = 0.85,
        eleganceBonus = 15,
        description = "Plemenita violina za klasično glasbo.",
    },
}

-- ============================================================
-- COMPOSITION TYPES
-- ============================================================
local COMPOSITIONS = {
    mass = {
        name = "Maša",
        nameEn = "Mass",
        duration = 30,
        basePrestige = 10,
        happinessBonus = 5,
        faithBonus = 20,
        requires = { "organ" },
        description = "Verska glasbena kompozicija.",
    },
    madrigal = {
        name = "Madrigal",
        nameEn = "Madrigal",
        duration = 14,
        basePrestige = 15,
        happinessBonus = 8,
        requires = { "lute", "violin" },
        description = "Svetovljanska pesem za dvor.",
    },
    ballad = {
        name = "Balada",
        nameEn = "Ballad",
        duration = 10,
        basePrestige = 8,
        happinessBonus = 10,
        requires = { "lute", "flute" },
        description = "Pripovedna pesem o junakih.",
    },
    dance = {
        name = "Ples",
        nameEn = "Dance",
        duration = 7,
        basePrestige = 5,
        happinessBonus = 12,
        requires = { "lute", "drum" },
        description = "Plesna glasba za zabave.",
    },
    anthem = {
        name = "Himna",
        nameEn = "Anthem",
        duration = 21,
        basePrestige = 25,
        happinessBonus = 15,
        militaryBonus = 10,
        requires = { "organ", "drum" },
        description = "Državna himna za slovesnosti.",
    },
    lament = {
        name = "Žalostinka",
        nameEn = "Lament",
        duration = 14,
        basePrestige = 12,
        happinessBonus = -2,  -- sad but meaningful
        requires = { "violin", "flute" },
        description = "Žalostna pesem za žalovanje.",
    },
    sonata = {
        name = "Sonata",
        nameEn = "Sonata",
        duration = 25,
        basePrestige = 20,
        happinessBonus = 8,
        requires = { "violin", "harp" },
        description = "Kompleksna instrumentalna skladba.",
    },
    opera = {
        name = "Opera",
        nameEn = "Opera",
        duration = 60,
        basePrestige = 50,
        happinessBonus = 25,
        requires = { "organ", "violin", "harp" },
        description = "Največja glasbena oblika — celovečerna predstava.",
    },
}

-- ============================================================
-- MUSIC BUILDINGS
-- ============================================================
local BUILDINGS = {
    music_room = {
        name = "Glasbena soba",
        cost = { gold = 500, wood = 200 },
        upkeep = 10,
        capacity = 5,
        qualityBonus = 5,
        description = "Soba za glasbene nastope.",
    },
    concert_hall = {
        name = "Koncertna dvorana",
        cost = { gold = 2500, wood = 400, stone = 500 },
        upkeep = 50,
        capacity = 20,
        qualityBonus = 20,
        prestigeBonus = 10,
        description = "Velika dvorana za koncerte.",
    },
    opera_house = {
        name = "Operna hiša",
        cost = { gold = 10000, wood = 800, stone = 2000 },
        upkeep = 200,
        capacity = 50,
        qualityBonus = 40,
        prestigeBonus = 30,
        description = "Največja glasbena zgradba — za opere.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Music.instruments = {}                    -- Owned instruments
Music.buildings = {}                      -- Built music buildings
Music.composer = nil                      -- Hired composer NPC
Music.activeCompositions = {}             -- Compositions being created
Music.compositionLibrary = {}             -- Completed compositions
Music.orchestra = {}                      -- Court orchestra members
Music.totalCompositions = 0
Music.totalPerformances = 0
Music.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Music.init()
    Music.instruments = {}
    Music.buildings = {}
    Music.composer = nil
    Music.activeCompositions = {}
    Music.compositionLibrary = {}
    Music.orchestra = {}
    Music.totalCompositions = 0
    Music.totalPerformances = 0
    Music.dayTimer = 0
    print("[Music] Royal Composer & Music System initialized (6 instruments, 8 compositions, 3 buildings)")
end

-- ============================================================
-- COMPOSER NPC
-- ============================================================
function Music.hireComposer(name, skill)
    skill = skill or math.random(40, 90)
    local cost = 600 + skill * 12
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Music.composer = {
        name = name or ("Skladatelj " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        compositionsCreated = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Skladatelj najet: %s (spretnost: %d)", Music.composer.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Music.canBuild(buildingId)
    local def = BUILDINGS[buildingId]
    if not def then return false, "Neznana zgradba" end
    if not _G.state then return false, "Brez stanja" end
    if _G.state.gold < (def.cost.gold or 0) then return false, "Premalo zlata" end
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" and (_G.state.resources[res] or 0) < amt then
                return false, "Premalo " .. res
            end
        end
    end
    return true
end

function Music.build(buildingId)
    local ok, err = Music.canBuild(buildingId)
    if not ok then return false, err end
    local def = BUILDINGS[buildingId]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Music.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Music.getQualityBonus()
    local bonus = 0
    for _, b in ipairs(Music.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.qualityBonus then bonus = bonus + def.qualityBonus end
    end
    return bonus
end

function Music.getPrestigeBonus()
    local bonus = 0
    for _, b in ipairs(Music.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.prestigeBonus then bonus = bonus + def.prestigeBonus end
    end
    return bonus
end

-- ============================================================
-- INSTRUMENT ACQUISITION
-- ============================================================
function Music.acquireInstrument(instrumentType)
    local def = INSTRUMENTS[instrumentType]
    if not def then return false, "Neznan instrument" end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - def.cost
    table.insert(Music.instruments, {
        type = instrumentType,
        name = def.name,
        condition = 100,
        acquiredDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Instrument pridobljen: " .. def.name, "success")
    end
    return true
end

function Music.hasInstrument(instrumentType)
    for _, inst in ipairs(Music.instruments) do
        if inst.type == instrumentType and inst.condition > 50 then
            return true
        end
    end
    return false
end

-- ============================================================
-- COMPOSITION CREATION
-- ============================================================
function Music.canCompose(compositionType)
    local def = COMPOSITIONS[compositionType]
    if not def then return false, "Neznana kompozicija" end
    if not Music.composer then return false, "Potreben skladatelj" end
    -- Check required instruments
    for _, inst in ipairs(def.requires or {}) do
        if not Music.hasInstrument(inst) then
            return false, "Manjkajoči instrument: " .. (INSTRUMENTS[inst] and INSTRUMENTS[inst].name or inst)
        end
    end
    return true
end

function Music.compose(compositionType)
    local ok, err = Music.canCompose(compositionType)
    if not ok then return false, err end
    local def = COMPOSITIONS[compositionType]
    local composition = {
        id = "comp_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = compositionType,
        name = def.name,
        daysRemaining = def.duration,
        totalDays = def.duration,
        basePrestige = def.basePrestige,
        happinessBonus = def.happinessBonus,
        faithBonus = def.faithBonus or 0,
        militaryBonus = def.militaryBonus or 0,
        quality = 1.0,
        started = os.time(),
    }
    table.insert(Music.activeCompositions, composition)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Skladba v nastajanju: %s (%d dni)", def.name, def.duration), "info")
    end
    return true
end

function Music.completeComposition(composition)
    -- Calculate quality
    local quality = 1.0
    quality = quality + (Music.getQualityBonus() / 100)
    if Music.composer then
        quality = quality + (Music.composer.skill / 200)
    end
    quality = math.min(2.0, quality)
    composition.quality = quality
    -- Add to library
    table.insert(Music.compositionLibrary, composition)
    Music.totalCompositions = Music.totalCompositions + 1
    -- Composer skill progression
    if Music.composer then
        Music.composer.compositionsCreated = Music.composer.compositionsCreated + 1
        if math.random() < 0.20 then
            Music.composer.skill = math.min(100, Music.composer.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Skladba dokončana: %s (kakovost: %.1f)", composition.name, quality), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "COMPOSITION_COMPLETED", {
            type = composition.type, quality = quality,
        })
    end
end

-- ============================================================
-- PERFORMANCES
-- ============================================================
function Music.perform(compositionIdx)
    if compositionIdx > #Music.compositionLibrary then
        return false, "Skladba ne obstaja"
    end
    local composition = Music.compositionLibrary[compositionIdx]
    if not composition then return false, "Skladba ne obstaja" end
    -- Apply effects
    local qualityMod = composition.quality
    if _G.state and _G.state.happiness then
        local happiness = composition.happinessBonus * qualityMod
        _G.state.happiness = math.max(0, math.min(100, _G.state.happiness + happiness))
    end
    if composition.faithBonus > 0 and _G.Religion then
        pcall(_G.Religion.addFaith, math.floor(composition.faithBonus * qualityMod))
    end
    if _G.state and _G.state.happiness and composition.militaryBonus > 0 then
        _G.state.happiness = math.min(100, _G.state.happiness + composition.militaryBonus * qualityMod / 2)
    end
    Music.totalPerformances = Music.totalPerformances + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Izvedena skladba: %s (kakovost: %.1f)", composition.name, composition.quality), "info")
    end
    return true
end

-- ============================================================
-- ORCHESTRA
-- ============================================================
function Music.hireMusician(name, instrumentType, skill)
    skill = skill or math.random(30, 80)
    local cost = 100 + skill * 3
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    table.insert(Music.orchestra, {
        id = "musician_" .. tostring(os.time()),
        name = name or ("Glasbenik " .. math.random(1, 99)),
        instrument = instrumentType,
        skill = skill,
        hiredDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Glasbenik najet: %s (%s, spretnost: %d)",
                name or "Glasbenik", INSTRUMENTS[instrumentType] and INSTRUMENTS[instrumentType].name or "?", skill), "success")
    end
    return true
end

function Music.getOrchestraBonus()
    local bonus = 0
    for _, m in ipairs(Music.orchestra) do
        bonus = bonus + (m.skill / 100)
    end
    return bonus
end

-- ============================================================
-- UPDATE
-- ============================================================
function Music.update(dt)
    if not _G.state then return end
    Music.dayTimer = Music.dayTimer + dt
    if Music.dayTimer >= 30 then
        Music.dayTimer = 0
        -- Process compositions
        for i = #Music.activeCompositions, 1, -1 do
            local c = Music.activeCompositions[i]
            c.daysRemaining = c.daysRemaining - 1
            if c.daysRemaining <= 0 then
                Music.completeComposition(c)
                table.remove(Music.activeCompositions, i)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, inst in ipairs(Music.instruments) do
            local def = INSTRUMENTS[inst.type]
            if def then totalUpkeep = totalUpkeep + def.upkeep end
        end
        for _, b in ipairs(Music.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        for _, m in ipairs(Music.orchestra) do
            totalUpkeep = totalUpkeep + 5
        end
        if Music.composer then totalUpkeep = totalUpkeep + 30 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Instrument degradation
        for _, inst in ipairs(Music.instruments) do
            inst.condition = math.max(0, inst.condition - 0.5)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Music.getInstrumentInfo(instId) return INSTRUMENTS[instId] end
function Music.getCompositionInfo(compId) return COMPOSITIONS[compId] end
function Music.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Music.getStats()
    return {
        numInstruments = #Music.instruments,
        numBuildings = #Music.buildings,
        hasComposer = Music.composer ~= nil,
        composerName = Music.composer and Music.composer.name or "—",
        composerSkill = Music.composer and Music.composer.skill or 0,
        activeCompositions = #Music.activeCompositions,
        librarySize = #Music.compositionLibrary,
        orchestraSize = #Music.orchestra,
        totalCompositions = Music.totalCompositions,
        totalPerformances = Music.totalPerformances,
        prestigeBonus = Music.getPrestigeBonus(),
    }
end

return Music
