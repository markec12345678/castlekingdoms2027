-- objects/QA/ChronicleHistorySystem.lua
-- Castle Kingdoms 2027 v3.2.1 - Chronicle & History System
--
-- Records all major game events into a chronicle, generating a story-like
-- history of the player's reign. Useful for end-game summary and immersion.
--
-- Features:
-- - 8 event categories (military, political, economic, religious, social,
--   dynastic, cultural, catastrophic)
-- - Auto-recording from GameEventBus subscriptions
-- - Year-by-year chronicle view
-- - Famous quotes generator
-- - Chronicle export (text format)
-- - Legacy score (history-based scoring)
-- - 6 chronicle qualities (mundane, ordinary, notable, remarkable, legendary, mythic)
-- - Reign summary generator

local Chronicle = {}

-- ============================================================
-- EVENT CATEGORIES
-- ============================================================
local CATEGORIES = {
    military = {
        name = "Vojaško",
        nameEn = "Military",
        color = { 0.7, 0.2, 0.2 },
        icon = "⚔",
    },
    political = {
        name = "Politično",
        nameEn = "Political",
        color = { 0.7, 0.5, 0.1 },
        icon = "👑",
    },
    economic = {
        name = "Ekonomsko",
        nameEn = "Economic",
        color = { 0.5, 0.7, 0.1 },
        icon = "💰",
    },
    religious = {
        name = "Versko",
        nameEn = "Religious",
        color = { 0.8, 0.7, 0.2 },
        icon = "✝",
    },
    social = {
        name = "Socialno",
        nameEn = "Social",
        color = { 0.2, 0.6, 0.7 },
        icon = "👥",
    },
    dynastic = {
        name = "Dinastično",
        nameEn = "Dynastic",
        color = { 0.6, 0.2, 0.7 },
        icon = "🩸",
    },
    cultural = {
        name = "Kulturno",
        nameEn = "Cultural",
        color = { 0.4, 0.5, 0.8 },
        icon = "📚",
    },
    catastrophic = {
        name = "Katastrofalno",
        nameEn = "Catastrophic",
        color = { 0.3, 0.1, 0.1 },
        icon = "☠",
    },
}

-- ============================================================
-- EVENT TEMPLATES (for narrative generation)
-- ============================================================
local TEMPLATES = {
    -- Military
    BATTLE_WON = {
        category = "military",
        template = "Leta {year} je vojska pod {ruler} premagala sovražnika pri {location}. Padlo je {count} sovražnikov.",
        quality = "notable",
    },
    BATTLE_LOST = {
        category = "military",
        template = "Leta {year} je vojska doživela poraz pri {location}. {count} vojakov je padlo.",
        quality = "ordinary",
    },
    SIEGE_COMPLETED = {
        category = "military",
        template = "Leta {year} je {ruler} osvojil grad {location} po dolgem obleganju.",
        quality = "remarkable",
    },
    -- Political
    DECREE_ISSUED = {
        category = "political",
        template = "Leta {year} je {ruler} izdal odlok '{decree_name}'.",
        quality = "ordinary",
    },
    DIPLOMATIC_ALLIANCE = {
        category = "political",
        template = "Leta {year} je bila sklenjena zveza s {faction}.",
        quality = "notable",
    },
    REBELLION_SUPPRESSED = {
        category = "political",
        template = "Leta {year} je {ruler} zatrl {rebellion_type} upor.",
        quality = "notable",
    },
    -- Economic
    MAJOR_TRADE = {
        category = "economic",
        template = "Leta {year} je bila vzpostavljena trgovska pot z {destination}, donos {amount} zlata.",
        quality = "ordinary",
    },
    TREASURY_FULL = {
        category = "economic",
        template = "Leta {year} je zakladnica dosegla {amount} zlata — dežela cveti.",
        quality = "remarkable",
    },
    -- Religious
    HOLY_WAR_DECLARED = {
        category = "religious",
        template = "Leta {year} je {ruler} razglasil sveto vojno!",
        quality = "remarkable",
    },
    RELIC_ACQUIRED = {
        category = "religious",
        template = "Leta {year} je bila pridobljena relikvija '{relic_name}'.",
        quality = "remarkable",
    },
    -- Social
    FESTIVAL_HELD = {
        category = "social",
        template = "Leta {year} je bil prirejen festival '{festival_name}'.",
        quality = "ordinary",
    },
    PLAGUE_OUTBREAK = {
        category = "catastrophic",
        template = "Leta {year} je izbruhnila kuga! {count} prebivalcev je umrlo.",
        quality = "remarkable",
    },
    -- Dynastic
    HEIR_BORN = {
        category = "dynastic",
        template = "Leta {year} se je rodil dedič — {child_name}.",
        quality = "notable",
    },
    MARRIAGE_CONCLUDED = {
        category = "dynastic",
        template = "Leta {year} se je {ruler} poročil z {spouse} iz hiše {house}.",
        quality = "notable",
    },
    RULER_DEATH = {
        category = "dynastic",
        template = "Leta {year} je {ruler} umrl. Oblast prevzema {successor}.",
        quality = "remarkable",
    },
    -- Cultural
    ARTWORK_COMPLETED = {
        category = "cultural",
        template = "Leta {year} je bilo končano umetniško delo '{art_name}'.",
        quality = "notable",
    },
    UNIVERSITY_FOUNDED = {
        category = "cultural",
        template = "Leta {year} je {ruler} ustanovil univerzo.",
        quality = "legendary",
    },
    -- Catastrophic
    FAMINE = {
        category = "catastrophic",
        template = "Leta {year} je lakota prizadela deželo. {count} ljudi je umrlo.",
        quality = "remarkable",
    },
    CIVIL_WAR = {
        category = "catastrophic",
        template = "Leta {year} je izbruhnila državljanska vojna!",
        quality = "legendary",
    },
}

-- ============================================================
-- FAMOUS QUOTES
-- ============================================================
local QUOTES = {
    "Vladarjeva moč leži v modrosti, ne v meču.",
    "Kralj brez ljudstva je le samec z krono.",
    "Sreča podanikov je temelj prestola.",
    "Zima preizkusi moč vsakega kraljestva.",
    "Kdo gradi z gradnjo, gradi zastonj; kdo gradi z ljudmi, gradi za vedno.",
    "Vera drži skupaj, kar meč ne more razdreti.",
    "Bogastvo brez modrosti je le precej težkega zlata.",
    "Zaveznik je vreden deset tisoč vojakov.",
    "Tisti, ki pozabi zgodovino, je obsoen ponavljati jo.",
    "Slava je sen, ki hitro mine; dobra imena pa večnost.",
}

-- ============================================================
-- CHRONICLE QUALITIES
-- ============================================================
local QUALITIES = {
    mundane = { name = "Povprečno", value = 1 },
    ordinary = { name = "Običajno", value = 2 },
    notable = { name = "Omembno", value = 3 },
    remarkable = { name = "Izjemno", value = 5 },
    legendary = { name = "Legendarno", value = 10 },
    mythic = { name = "Mitično", value = 20 },
}

-- ============================================================
-- STATE
-- ============================================================
Chronicle.events = {}              -- All recorded events
Chronicle.currentYear = 1
Chronicle.legacyScore = 0
Chronicle.reignRuler = "Kralj Branislav"
Chronicle.maxEvents = 1000         -- Limit memory

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Chronicle.init()
    Chronicle.events = {}
    Chronicle.currentYear = 1
    Chronicle.legacyScore = 0
    Chronicle.reignRuler = "Kralj Branislav"
    Chronicle.maxEvents = 1000
    -- Subscribe to GameEventBus
    if _G.GameEventBus then
        pcall(function()
            _G.GameEventBus.subscribe("BATTLE_WON", function(data)
                Chronicle.record("BATTLE_WON", data)
            end)
            _G.GameEventBus.subscribe("DECREE_ISSUED", function(data)
                Chronicle.record("DECREE_ISSUED", data)
            end)
            _G.GameEventBus.subscribe("MARRIAGE_CONCLUDED", function(data)
                Chronicle.record("MARRIAGE_CONCLUDED", data)
            end)
            _G.GameEventBus.subscribe("HEIR_BORN", function(data)
                Chronicle.record("HEIR_BORN", data)
            end)
            _G.GameEventBus.subscribe("SUCCESSION", function(data)
                Chronicle.record("RULER_DEATH", data)
            end)
            _G.GameEventBus.subscribe("ARTWORK_COMPLETED", function(data)
                Chronicle.record("ARTWORK_COMPLETED", data)
            end)
            _G.GameEventBus.subscribe("REBELLION_SUPPRESSED", function(data)
                Chronicle.record("REBELLION_SUPPRESSED", data)
            end)
            _G.GameEventBus.subscribe("CIVIL_WAR_STARTED", function(data)
                Chronicle.record("CIVIL_WAR", data)
            end)
            _G.GameEventBus.subscribe("INSTITUTION_BUILT", function(data)
                if data.type == "university" then
                    Chronicle.record("UNIVERSITY_FOUNDED", data)
                end
            end)
            _G.GameEventBus.subscribe("RELIC_ACQUIRED", function(data)
                Chronicle.record("RELIC_ACQUIRED", data)
            end)
            _G.GameEventBus.subscribe("HOLY_DAY", function(data)
                Chronicle.record("FESTIVAL_HELD", { festival_name = data.name })
            end)
            _G.GameEventBus.subscribe("HERESY_OUTBREAK", function(data)
                Chronicle.record("PLAGUE_OUTBREAK", {
                    count = (data.converted or 0),
                })
            end)
        end)
    end
    print("[Chronicle] Chronicle & History System initialized (8 categories, " ..
          #TEMPLATES .. " templates)")
end

-- ============================================================
-- RECORDING
-- ============================================================
function Chronicle.record(eventType, data)
    data = data or {}
    local template = TEMPLATES[eventType]
    if not template then
        -- Generic event
        template = {
            category = "social",
            template = "Leta {year} se je zgodilo: " .. eventType,
            quality = "ordinary",
        }
    end
    local category = CATEGORIES[template.category]
    -- Build narrative
    local narrative = Chronicle.fillTemplate(template.template, data)
    local event = {
        id = "event_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = eventType,
        category = template.category,
        categoryName = category and category.name or "Splošno",
        icon = category and category.icon or "•",
        narrative = narrative,
        year = Chronicle.currentYear,
        timestamp = os.time(),
        quality = template.quality,
        qualityValue = (QUALITIES[template.quality] or QUALITIES.ordinary).value,
        data = data,
    }
    table.insert(Chronicle.events, event)
    -- Update legacy score
    Chronicle.legacyScore = Chronicle.legacyScore + event.qualityValue
    -- Trim if too many
    if #Chronicle.events > Chronicle.maxEvents then
        table.remove(Chronicle.events, 1)
    end
    return true
end

function Chronicle.fillTemplate(template, data)
    local result = template
    -- Replace placeholders
    result = result:gsub("{year}", tostring(Chronicle.currentYear))
    result = result:gsub("{ruler}", Chronicle.reignRuler)
    result = result:gsub("{location}", data.location or "neznana krajina")
    result = result:gsub("{count}", tostring(data.count or math.random(50, 500)))
    result = result:gsub("{faction}", data.faction or "tuja sila")
    result = result:gsub("{destination}", data.destination or "daljne dežele")
    result = result:gsub("{amount}", tostring(data.amount or math.random(100, 1000)))
    result = result:gsub("{decree_name}", data.decree_name or data.id or "odlok")
    result = result:gsub("{rebellion_type}", data.rebellion_type or data.type or "kmečki")
    result = result:gsub("{relic_name}", data.name or "sveta relikvija")
    result = result:gsub("{festival_name}", data.festival_name or "pomladni festival")
    result = result:gsub("{child_name}", data.name or "dedič")
    result = result:gsub("{spouse}", data.spouse or "nevesta")
    result = result:gsub("{house}", data.house or "plemiške hiše")
    result = result:gsub("{successor}", data.newRuler or "naslednik")
    result = result:gsub("{art_name}", data.art_name or data.name or "umetniško delo")
    return result
end

-- ============================================================
-- YEAR MANAGEMENT
-- ============================================================
function Chronicle.advanceYear()
    Chronicle.currentYear = Chronicle.currentYear + 1
end

function Chronicle.setRuler(rulerName)
    Chronicle.reignRuler = rulerName
end

-- ============================================================
-- QUERIES
-- ============================================================
function Chronicle.getEventsByYear(year)
    local result = {}
    for _, e in ipairs(Chronicle.events) do
        if e.year == year then
            table.insert(result, e)
        end
    end
    return result
end

function Chronicle.getEventsByCategory(category)
    local result = {}
    for _, e in ipairs(Chronicle.events) do
        if e.category == category then
            table.insert(result, e)
        end
    end
    return result
end

function Chronicle.getMostImportantEvents(count)
    count = count or 10
    local sorted = {}
    for _, e in ipairs(Chronicle.events) do
        table.insert(sorted, e)
    end
    table.sort(sorted, function(a, b) return a.qualityValue > b.qualityValue end)
    local result = {}
    for i = 1, math.min(count, #sorted) do
        table.insert(result, sorted[i])
    end
    return result
end

function Chronicle.getRandomQuote()
    return QUOTES[math.random(#QUOTES)]
end

-- ============================================================
-- EXPORT
-- ============================================================
function Chronicle.exportToText()
    local lines = {}
    table.insert(lines, "==================================")
    table.insert(lines, "  KRONIKA KRALJEVINE")
    table.insert(lines, "  Vladar: " .. Chronicle.reignRuler)
    table.insert(lines, "  Leto: " .. Chronicle.currentYear)
    table.insert(lines, "  Legacy score: " .. Chronicle.legacyScore)
    table.insert(lines, "==================================")
    table.insert(lines, "")
    -- Group by year
    local byYear = {}
    for _, e in ipairs(Chronicle.events) do
        if not byYear[e.year] then byYear[e.year] = {} end
        table.insert(byYear[e.year], e)
    end
    -- Sort years
    local years = {}
    for y, _ in pairs(byYear) do table.insert(years, y) end
    table.sort(years)
    for _, year in ipairs(years) do
        table.insert(lines, string.format("--- Leto %d ---", year))
        for _, e in ipairs(byYear[year]) do
            table.insert(lines, string.format("  %s [%s] %s",
                e.icon, e.categoryName, e.narrative))
        end
        table.insert(lines, "")
    end
    return table.concat(lines, "\n")
end

function Chronicle.exportToFile(filepath)
    filepath = filepath or "/home/z/my-project/download/chronicle_export.txt"
    local content = Chronicle.exportToText()
    local file = io.open(filepath, "w")
    if file then
        file:write(content)
        file:close()
        return true
    end
    return false
end

-- ============================================================
-- REIGN SUMMARY
-- ============================================================
function Chronicle.generateReignSummary()
    local summary = {
        ruler = Chronicle.reignRuler,
        years = Chronicle.currentYear,
        totalEvents = #Chronicle.events,
        legacyScore = Chronicle.legacyScore,
        legacyRank = Chronicle.getLegacyRank(),
        categoryBreakdown = {},
        topEvents = Chronicle.getMostImportantEvents(5),
        quote = Chronicle.getRandomQuote(),
    }
    -- Category breakdown
    for catId, cat in pairs(CATEGORIES) do
        local count = #Chronicle.getEventsByCategory(catId)
        summary.categoryBreakdown[catId] = {
            name = cat.name,
            count = count,
        }
    end
    return summary
end

function Chronicle.getLegacyRank()
    local score = Chronicle.legacyScore
    if score >= 500 then return "Mitičen vladar"
    elseif score >= 300 then return "Legendaren vladar"
    elseif score >= 200 then return "Izjemen vladar"
    elseif score >= 100 then return "Omembni vladar"
    elseif score >= 50 then return "Običajen vladar"
    else return "Povprečen vladar" end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Chronicle.update(dt)
    -- No real-time update needed; events are recorded via subscriptions
    -- Year tracking could be tied to game time, but for now passive
end

-- ============================================================
-- HELPERS
-- ============================================================
function Chronicle.getCategories() return CATEGORIES end
function Chronicle.getQualities() return QUALITIES end

function Chronicle.getStats()
    return {
        totalEvents = #Chronicle.events,
        currentYear = Chronicle.currentYear,
        legacyScore = Chronicle.legacyScore,
        legacyRank = Chronicle.getLegacyRank(),
        ruler = Chronicle.reignRuler,
    }
end

return Chronicle
