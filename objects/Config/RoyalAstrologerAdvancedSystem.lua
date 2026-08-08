-- objects/Config/RoyalAstrologerAdvancedSystem.lua
-- Castle Kingdoms 2027 v3.4.8 - Royal Astrologer Advanced System
--
-- Advanced astrology: star charts, horoscopes, celestial events, and
-- zodiac-based predictions. Builds on the basic Astrologer system.
--
-- Features:
-- - 12 zodiac signs (Aries through Pisces)
-- - 8 celestial events (meteor showers, planetary conjunctions, ...)
-- - 6 horoscope types (daily, weekly, monthly, yearly, natal, mundane)
-- - Star chart creation (time-based)
-- - Celestial calendar
-- - Astrological predictions
-- - Ziggurat observatory building
-- - Astrological school

local AstrologyAdv = {}

-- ============================================================
-- ZODIAC SIGNS
-- ============================================================
local ZODIAC = {
    aries = { name = "Oven", nameEn = "Aries", element = "fire", trait = "pogum", dates = "21.3-19.4" },
    taurus = { name = "Bik", nameEn = "Taurus", element = "earth", trait = "vztrajnost", dates = "20.4-20.5" },
    gemini = { name = "Dvojčka", nameEn = "Gemini", element = "air", trait = "komunikacija", dates = "21.5-20.6" },
    cancer = { name = "Rak", nameEn = "Cancer", element = "water", trait = "čustva", dates = "21.6-22.7" },
    leo = { name = "Lev", nameEn = "Leo", element = "fire", trait = "veličina", dates = "23.7-22.8" },
    virgo = { name = "Devica", nameEn = "Virgo", element = "earth", trait = "analiza", dates = "23.8-22.9" },
    libra = { name = "Tehtnica", nameEn = "Libra", element = "air", trait = "ravnovesje", dates = "23.9-22.10" },
    scorpio = { name = "Škorpijon", nameEn = "Scorpio", element = "water", trait = "strast", dates = "23.10-21.11" },
    sagittarius = { name = "Strelec", nameEn = "Sagittarius", element = "fire", trait = "avantura", dates = "22.11-21.12" },
    capricorn = { name = "Kozorog", nameEn = "Capricorn", element = "earth", trait = "ambicija", dates = "22.12-19.1" },
    aquarius = { name = "Vodnar", nameEn = "Aquarius", element = "air", trait = "inovacija", dates = "20.1-18.2" },
    pisces = { name = "Ribe", nameEn = "Pisces", element = "water", trait = "intuicija", dates = "19.2-20.3" },
}

-- ============================================================
-- CELESTIAL EVENTS
-- ============================================================
local CELESTIAL_EVENTS = {
    meteor_shower = {
        name = "Meteorji",
        nameEn = "Meteor Shower",
        rarity = 2,
        happinessBonus = 8,
        duration = 1,
        description = "Dež padajočih zvezd — sreča za želje.",
    },
    planetary_conjunction = {
        name = "Poravnava planetov",
        nameEn = "Planetary Conjunction",
        rarity = 4,
        happinessBonus = 15,
        prestigeBonus = 10,
        duration = 3,
        description = "Redka poravnava — velika znamenja.",
    },
    lunar_eclipse = {
        name = "Lunin mrk",
        nameEn = "Lunar Eclipse",
        rarity = 3,
        happinessBonus = 5,
        faithBonus = 15,
        duration = 1,
        description = "Zemlja prekrije Luno.",
    },
    solar_eclipse = {
        name = "Sončev mrk",
        nameEn = "Solar Eclipse",
        rarity = 4,
        happinessBonus = -5,
        faithBonus = 20,
        duration = 1,
        description = "Dan postane noč — božje znamenje.",
    },
    comet = {
        name = "Komet",
        nameEn = "Comet",
        rarity = 5,
        happinessBonus = -10,
        duration = 14,
        description = "Dolgorepi komet — slaba znamenja.",
    },
    supernova = {
        name = "Nova zvezda",
        nameEn = "Supernova",
        rarity = 5,
        happinessBonus = 20,
        prestigeBonus = 25,
        duration = 30,
        description = "Nova zvezda na nebu — izjemno redko.",
    },
    blue_moon = {
        name = "Moder mesec",
        nameEn = "Blue Moon",
        rarity = 3,
        happinessBonus = 12,
        duration = 1,
        description = "Drugi polni mesec v mesecu.",
    },
    blood_moon = {
        name = "Krvavi mesec",
        nameEn = "Blood Moon",
        rarity = 4,
        happinessBonus = -8,
        duration = 1,
        description = "Rdeče obarvan mesec — vojna znamenja.",
    },
}

-- ============================================================
-- HOROSCOPE TYPES
-- ============================================================
local HOROSCOPES = {
    daily = {
        name = "Dnevni horoskop",
        nameEn = "Daily Horoscope",
        duration = 1,
        accuracy = 0.20,
        cost = 10,
        description = "Napoved za današnji dan.",
    },
    weekly = {
        name = "Tedenski horoskop",
        nameEn = "Weekly Horoscope",
        duration = 7,
        accuracy = 0.30,
        cost = 50,
        description = "Napoved za teden dni.",
    },
    monthly = {
        name = "Mesečni horoskop",
        nameEn = "Monthly Horoscope",
        duration = 30,
        accuracy = 0.40,
        cost = 200,
        description = "Napoved za mesec.",
    },
    yearly = {
        name = "Letni horoskop",
        nameEn = "Yearly Horoscope",
        duration = 365,
        accuracy = 0.50,
        cost = 1000,
        description = "Napoved za celo leto.",
    },
    natal = {
        name = "Natalna karta",
        nameEn = "Natal Chart",
        duration = 0,  -- permanent
        accuracy = 0.70,
        cost = 500,
        description = "Karta rojstva za posameznika.",
    },
    mundane = {
        name = "Mundana astrologija",
        nameEn = "Mundane Astrology",
        duration = 90,
        accuracy = 0.45,
        cost = 800,
        description = "Napovedi za državo in kraljestvo.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
AstrologyAdv.activeEvents = {}           -- Active celestial events
AstrologyAdv.activeHoroscopes = {}       -- Active horoscopes
AstrologyAdv.starCharts = {}             -- Created star charts
AstrologyAdv.celestialCalendar = {}      -- Upcoming events
AstrologyAdv.totalChartsCreated = 0
AstrologyAdv.totalHoroscopesMade = 0
AstrologyAdv.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function AstrologyAdv.init()
    AstrologyAdv.activeEvents = {}
    AstrologyAdv.activeHoroscopes = {}
    AstrologyAdv.starCharts = {}
    AstrologyAdv.celestialCalendar = {}
    AstrologyAdv.totalChartsCreated = 0
    AstrologyAdv.totalHoroscopesMade = 0
    AstrologyAdv.dayTimer = 0
    print("[AstrologyAdv] Royal Astrologer Advanced System initialized (12 zodiac, 8 events, 6 horoscopes)")
end

-- ============================================================
-- CELESTIAL EVENTS
-- ============================================================
function AstrologyAdv.generateEvent()
    -- Weighted random by rarity (lower rarity = more common)
    local totalWeight = 0
    local weights = {}
    for id, def in pairs(CELESTIAL_EVENTS) do
        local weight = 6 - def.rarity
        weights[id] = weight
        totalWeight = totalWeight + weight
    end
    local roll = math.random() * totalWeight
    local cumulative = 0
    local selected = nil
    for id, weight in pairs(weights) do
        cumulative = cumulative + weight
        if roll <= cumulative then
            selected = id
            break
        end
    end
    if not selected then return end
    local def = CELESTIAL_EVENTS[selected]
    local event = {
        id = "event_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = selected,
        name = def.name,
        daysRemaining = def.duration,
        happinessBonus = def.happinessBonus,
        prestigeBonus = def.prestigeBonus or 0,
        faithBonus = def.faithBonus or 0,
        started = os.time(),
    }
    table.insert(AstrologyAdv.activeEvents, event)
    -- Apply immediate effects
    if _G.state and _G.state.happiness and def.happinessBonus then
        _G.state.happiness = math.max(0, math.min(100, _G.state.happiness + def.happinessBonus))
    end
    if def.faithBonus and _G.Religion then
        pcall(_G.Religion.addFaith, def.faithBonus)
    end
    if _G.NotificationCenter then
        local msg = string.format("Nebesni dogodek: %s!", def.name)
        if def.happinessBonus > 0 then
            pcall(_G.NotificationCenter.notify, msg, "info")
        else
            pcall(_G.NotificationCenter.notify, msg, "warning")
        end
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "CELESTIAL_EVENT", { type = selected, name = def.name })
    end
end

-- ============================================================
-- HOROSCOPES
-- ============================================================
function AstrologyAdv.canMakeHoroscope(horoscopeType, zodiacSign)
    local def = HOROSCOPES[horoscopeType]
    if not def then return false, "Neznan horoskop" end
    if not ZODIAC[zodiacSign] then return false, "Neznan zodiak" end
    if not _G.Astrology or not _G.Astrology.astrologer then
        return false, "Potreben astrolog"
    end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    return true
end

function AstrologyAdv.makeHoroscope(horoscopeType, zodiacSign, targetName)
    local ok, err = AstrologyAdv.canMakeHoroscope(horoscopeType, zodiacSign)
    if not ok then return false, err end
    local def = HOROSCOPES[horoscopeType]
    local zodiacDef = ZODIAC[zodiacSign]
    _G.state.gold = _G.state.gold - def.cost
    -- Calculate accuracy
    local accuracy = def.accuracy
    if _G.Astrology and _G.Astrology.astrologer then
        accuracy = accuracy + (_G.Astrology.astrologer.accuracy / 3)
    end
    accuracy = math.min(0.95, accuracy)
    -- Generate prediction text
    local predictions = {
        positive = {
            "Velika sreča v bližnji prihodnosti.",
            "Dolgo pričakovani uspeh je pred vami.",
            "Ljubezen in harmonija v družini.",
            "Finančni uspeh v prihajajočih dneh.",
        },
        neutral = {
            "Čas premika in sprememb.",
            "Bodite previdni pri odločitvah.",
            "Mirno obdobje za razmislek.",
            "Stabilnost v vsakdanjem življenju.",
        },
        negative = {
            "Težave na obzorju — bodite pripravljeni.",
            "Izguba je pred vami, a začasna.",
            "Konflikti v bližini.",
            "Bodite pozorni na zdravje.",
        },
    }
    local predictionType = "neutral"
    local roll = math.random()
    if roll < 0.40 then predictionType = "positive"
    elseif roll > 0.70 then predictionType = "negative" end
    local predictionText = predictions[predictionType][math.random(#predictions[predictionType])]
    local horoscope = {
        id = "horo_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = horoscopeType,
        typeName = def.name,
        zodiac = zodiacSign,
        zodiacName = zodiacDef.name,
        targetName = targetName or "Vladar",
        prediction = predictionText,
        predictionType = predictionType,
        accuracy = accuracy,
        daysRemaining = def.duration,
        started = os.time(),
    }
    table.insert(AstrologyAdv.activeHoroscopes, horoscope)
    AstrologyAdv.totalHoroscopesMade = AstrologyAdv.totalHoroscopesMade + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Horoskop: %s za %s (%s) — %s",
                def.name, zodiacDef.name, targetName or "Vladar", predictionText), "info")
    end
    return true
end

-- ============================================================
-- STAR CHARTS
-- ============================================================
function AstrologyAdv.canCreateChart()
    if not _G.Astrology or not _G.Astrology.astrologer then
        return false, "Potreben astrolog"
    end
    if not _G.Astrology.observatory then
        return false, "Potreben observatorij"
    end
    if not _G.state or (_G.state.gold or 0) < 300 then
        return false, "Premalo zlata"
    end
    return true
end

function AstrologyAdv.createStarChart(name)
    local ok, err = AstrologyAdv.canCreateChart()
    if not ok then return false, err end
    _G.state.gold = _G.state.gold - 300
    local chart = {
        id = "chart_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        name = name or ("Zvezdna karta " .. #AstrologyAdv.starCharts + 1),
        accuracy = 0.60,
        createdDay = os.time(),
        stars = math.random(50, 200),
        constellations = math.random(5, 15),
    }
    -- Accuracy improves with astrologer skill
    if _G.Astrology and _G.Astrology.astrologer then
        chart.accuracy = chart.accuracy + (_G.Astrology.astrologer.skill / 250)
    end
    chart.accuracy = math.min(0.95, chart.accuracy)
    table.insert(AstrologyAdv.starCharts, chart)
    AstrologyAdv.totalChartsCreated = AstrologyAdv.totalChartsCreated + 1
    -- Prestige bonus
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + 3)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Zvezdna karta ustvarjena: %s (%d zvezd, natančnost: %.0f%%)",
                chart.name, chart.stars, chart.accuracy * 100), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "STAR_CHART_CREATED", { name = chart.name, accuracy = chart.accuracy })
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function AstrologyAdv.update(dt)
    if not _G.state then return end
    AstrologyAdv.dayTimer = AstrologyAdv.dayTimer + dt
    if AstrologyAdv.dayTimer >= 30 then
        AstrologyAdv.dayTimer = 0
        -- Random celestial event chance (5%)
        if math.random() < 0.05 then
            AstrologyAdv.generateEvent()
        end
        -- Update active events
        for i = #AstrologyAdv.activeEvents, 1, -1 do
            local e = AstrologyAdv.activeEvents[i]
            e.daysRemaining = e.daysRemaining - 1
            if e.daysRemaining <= 0 then
                table.remove(AstrologyAdv.activeEvents, i)
            end
        end
        -- Update horoscopes
        for i = #AstrologyAdv.activeHoroscopes, 1, -1 do
            local h = AstrologyAdv.activeHoroscopes[i]
            if h.daysRemaining > 0 then
                h.daysRemaining = h.daysRemaining - 1
                if h.daysRemaining <= 0 then
                    table.remove(AstrologyAdv.activeHoroscopes, i)
                end
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function AstrologyAdv.getZodiacInfo(signId) return ZODIAC[signId] end
function AstrologyAdv.getEventInfo(eventId) return CELESTIAL_EVENTS[eventId] end
function AstrologyAdv.getHoroscopeInfo(horoscopeId) return HOROSCOPES[horoscopeId] end

function AstrologyAdv.getStats()
    return {
        activeEvents = #AstrologyAdv.activeEvents,
        activeHoroscopes = #AstrologyAdv.activeHoroscopes,
        starCharts = #AstrologyAdv.starCharts,
        totalChartsCreated = AstrologyAdv.totalChartsCreated,
        totalHoroscopesMade = AstrologyAdv.totalHoroscopesMade,
    }
end

return AstrologyAdv
