-- objects/Gameplay/RoyalCourtEntertainmentSystem.lua
-- Castle Kingdoms 2027 v3.2.6 - Royal Court Entertainment System
--
-- Manages court entertainers: bards, jesters, musicians, and performers.
-- Each provides happiness, prestige, and unique bonuses.
--
-- Features:
-- - 6 entertainer types (bard, jester, musician, troubadour, dancer, animal tamer)
-- - 8 performance types (songs, jokes, acrobatics, epic tales, ...)
-- - Court reputation system
-- - Patronage (hire/fire entertainers)
-- - Special events (grand performances)
-- - Touring (send entertainers to other courts)
-- - Entertainment buildings (theater, music hall)
-- - Cultural exchange

local Entertainment = {}

-- ============================================================
-- ENTERTAINER TYPES
-- ============================================================
local ENTERTAINERS = {
    bard = {
        name = "Bard",
        nameEn = "Bard",
        hireCost = 300,
        upkeep = 15,
        happinessBonus = 5,
        prestigeBonus = 3,
        performanceTypes = { "epic_tale", "song", "poem" },
        description = "Pripovedovalec zgodb in pesmi.",
    },
    jester = {
        name = "Norček",
        nameEn = "Jester",
        hireCost = 200,
        upkeep = 10,
        happinessBonus = 8,
        prestigeBonus = 1,
        performanceTypes = { "joke", "acrobatics", "satire" },
        description = "Kraljevi norček za zabavo in sprostitev.",
    },
    musician = {
        name = "Glasbenik",
        nameEn = "Musician",
        hireCost = 250,
        upkeep = 12,
        happinessBonus = 6,
        prestigeBonus = 2,
        performanceTypes = { "song", "instrumental", "dance_music" },
        description = "Igra instrumente za dvorno glasbo.",
    },
    troubadour = {
        name = "Trubadur",
        nameEn = "Troubadour",
        hireCost = 500,
        upkeep = 25,
        happinessBonus = 10,
        prestigeBonus = 8,
        performanceTypes = { "epic_tale", "song", "poem", "romance" },
        description = "Plemiški glasbenik z romancami.",
    },
    dancer = {
        name = "Plesalec",
        nameEn = "Dancer",
        hireCost = 350,
        upkeep = 18,
        happinessBonus = 7,
        prestigeBonus = 4,
        performanceTypes = { "dance", "acrobatics" },
        description = "Profesionalni plesalec za dvorne prireditve.",
    },
    animal_tamer = {
        name = "Krotilce živali",
        nameEn = "Animal Tamer",
        hireCost = 600,
        upkeep = 30,
        happinessBonus = 12,
        prestigeBonus = 6,
        performanceTypes = { "animal_show", "acrobatics" },
        description = "Redka predstava z eksotičnimi živalmi.",
    },
}

-- ============================================================
-- PERFORMANCE TYPES
-- ============================================================
local PERFORMANCES = {
    song = {
        name = "Pesem",
        nameEn = "Song",
        duration = 1,         -- days
        happinessBonus = 3,
        prestigeBonus = 1,
        description = "Kratka pesem za dvor.",
    },
    joke = {
        name = "Šala",
        nameEn = "Joke",
        duration = 1,
        happinessBonus = 5,
        prestigeBonus = 0,
        description = "Hitra šala za smeh.",
    },
    epic_tale = {
        name = "Epska pripoved",
        nameEn = "Epic Tale",
        duration = 3,
        happinessBonus = 8,
        prestigeBonus = 5,
        description = "Dolga pripoved o junakih.",
    },
    poem = {
        name = "Pesem",
        nameEn = "Poem",
        duration = 2,
        happinessBonus = 4,
        prestigeBonus = 3,
        description = "Lirična pesem v verzih.",
    },
    acrobatics = {
        name = "Akrobatika",
        nameEn = "Acrobatics",
        duration = 1,
        happinessBonus = 6,
        prestigeBonus = 2,
        description = "Akrobatske veščine za zabavo.",
    },
    satire = {
        name = "Satira",
        nameEn = "Satire",
        duration = 2,
        happinessBonus = 7,
        prestigeBonus = 1,
        riskOfOffense = 0.20,  -- chance to offend nobles
        description = "Satirična predstava, tvegana a zabavna.",
    },
    dance = {
        name = "Ples",
        nameEn = "Dance",
        duration = 1,
        happinessBonus = 5,
        prestigeBonus = 2,
        description = "Plesna predstava.",
    },
    instrumental = {
        name = "Instrumentalna",
        nameEn = "Instrumental",
        duration = 2,
        happinessBonus = 4,
        prestigeBonus = 2,
        description = "Glasba brez besed.",
    },
    dance_music = {
        name = "Plesna glasba",
        nameEn = "Dance Music",
        duration = 2,
        happinessBonus = 6,
        prestigeBonus = 2,
        description = "Glasba za dvorne plese.",
    },
    romance = {
        name = "Romanca",
        nameEn = "Romance",
        duration = 3,
        happinessBonus = 9,
        prestigeBonus = 6,
        description = "Ljubezenska pripoved trubadurja.",
    },
    animal_show = {
        name = "Živalska predstava",
        nameEn = "Animal Show",
        duration = 2,
        happinessBonus = 12,
        prestigeBonus = 8,
        description = "Redka predstava z levom ali medvedom.",
    },
}

-- ============================================================
-- ENTERTAINMENT BUILDINGS
-- ============================================================
local BUILDINGS = {
    court_stage = {
        name = "Dvorna odra",
        cost = { gold = 300, wood = 100 },
        upkeep = 5,
        capacityBonus = 2,
        description = "Preprosta odra za predstave.",
    },
    theater = {
        name = "Gledališče",
        cost = { gold = 2000, wood = 300, stone = 200 },
        upkeep = 30,
        capacityBonus = 5,
        happinessBonus = 5,
        description = "Stalno gledališče za velike predstave.",
    },
    music_hall = {
        name = "Glasbena dvorana",
        cost = { gold = 1500, wood = 200, stone = 100 },
        upkeep = 20,
        capacityBonus = 3,
        happinessBonus = 3,
        description = "Dvorana za glasbene nastope.",
    },
    grand_amphitheater = {
        name = "Veliki amfiteater",
        cost = { gold = 8000, wood = 500, stone = 1500 },
        upkeep = 80,
        capacityBonus = 10,
        happinessBonus = 15,
        description = "Največja prireditvena zgradba.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Entertainment.hiredEntertainers = {}   -- Currently hired
Entertainment.activePerformances = {}  -- Ongoing
Entertainment.entertainmentBuildings = {}  -- Built
Entertainment.courtReputation = 50      -- 0-100
Entertainment.totalPerformances = 0
Entertainment.touringEntertainers = {}  -- Sent to other courts
Entertainment.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Entertainment.init()
    Entertainment.hiredEntertainers = {}
    Entertainment.activePerformances = {}
    Entertainment.entertainmentBuildings = {}
    Entertainment.courtReputation = 50
    Entertainment.totalPerformances = 0
    Entertainment.touringEntertainers = {}
    Entertainment.dayTimer = 0
    print("[Entertainment] Royal Court Entertainment System initialized (6 entertainers, 11 performances)")
end

-- ============================================================
-- HIRING
-- ============================================================
function Entertainment.canHire(entertainerType)
    local def = ENTERTAINERS[entertainerType]
    if not def then return false, "Neznan zabavljalec" end
    if not _G.state or (_G.state.gold or 0) < def.hireCost then
        return false, "Premalo zlata"
    end
    -- Check capacity (based on buildings)
    local cap = Entertainment.getTotalCapacity()
    if #Entertainment.hiredEntertainers >= cap then
        return false, "Dvor je poln zabavljačev"
    end
    return true
end

function Entertainment.hire(entertainerType, customName)
    local ok, err = Entertainment.canHire(entertainerType)
    if not ok then return false, err end
    local def = ENTERTAINERS[entertainerType]
    _G.state.gold = _G.state.gold - def.hireCost
    local entertainer = {
        id = "ent_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = entertainerType,
        name = customName or (def.name .. " " .. math.random(1, 99)),
        skill = math.random(40, 90),
        happinessBonus = def.happinessBonus,
        prestigeBonus = def.prestigeBonus,
        performanceTypes = def.performanceTypes,
        performances = 0,
        hiredDay = os.time(),
        status = "idle",  -- idle, performing, touring
    }
    table.insert(Entertainment.hiredEntertainers, entertainer)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Zabavljalec najet: %s (%s)", entertainer.name, def.name), "success")
    end
    return true, entertainer.id
end

function Entertainment.fire(entertainerId)
    for i, e in ipairs(Entertainment.hiredEntertainers) do
        if e.id == entertainerId then
            table.remove(Entertainment.hiredEntertainers, i)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, "Zabavljalec odpuščen: " .. e.name, "info")
            end
            return true
        end
    end
    return false
end

function Entertainment.findEntertainer(id)
    for _, e in ipairs(Entertainment.hiredEntertainers) do
        if e.id == id then return e end
    end
    return nil
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Entertainment.canBuild(buildingId)
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

function Entertainment.build(buildingId)
    local ok, err = Entertainment.canBuild(buildingId)
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
    table.insert(Entertainment.entertainmentBuildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Entertainment.getTotalCapacity()
    local cap = 3  -- base court capacity
    for _, b in ipairs(Entertainment.entertainmentBuildings) do
        local def = BUILDINGS[b.type]
        if def and def.capacityBonus then cap = cap + def.capacityBonus end
    end
    return cap
end

-- ============================================================
-- PERFORMANCES
-- ============================================================
function Entertainment.canPerform(entertainerId, performanceType)
    local e = Entertainment.findEntertainer(entertainerId)
    if not e then return false, "Zabavljalec ne obstaja" end
    if e.status ~= "idle" then return false, "Zabavljalec ni prost" end
    local def = PERFORMANCES[performanceType]
    if not def then return false, "Neznana predstava" end
    -- Check if entertainer can do this
    local canDo = false
    for _, p in ipairs(e.performanceTypes) do
        if p == performanceType then canDo = true; break end
    end
    if not canDo then return false, "Ta zabavljalec ne more izvesti te predstave" end
    return true
end

function Entertainment.startPerformance(entertainerId, performanceType)
    local ok, err = Entertainment.canPerform(entertainerId, performanceType)
    if not ok then return false, err end
    local e = Entertainment.findEntertainer(entertainerId)
    local def = PERFORMANCES[performanceType]
    -- Calculate bonuses
    local skillBonus = 1 + (e.skill / 200)
    local happiness = math.floor(def.happinessBonus * skillBonus)
    local prestige = math.floor((def.prestigeBonus or 0) * skillBonus)
    local performance = {
        id = "perf_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        entertainerId = entertainerId,
        entertainerName = e.name,
        type = performanceType,
        typeName = def.name,
        daysRemaining = def.duration,
        happinessBonus = happiness,
        prestigeBonus = prestige,
        riskOfOffense = def.riskOfOffense or 0,
        started = os.time(),
    }
    e.status = "performing"
    table.insert(Entertainment.activePerformances, performance)
    Entertainment.totalPerformances = Entertainment.totalPerformances + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Predstava začeta: %s (%s, +%d sreče)",
                def.name, e.name, happiness), "info")
    end
    return true
end

function Entertainment.completePerformance(performance)
    -- Apply happiness bonus
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + performance.happinessBonus)
    end
    -- Apply prestige
    Entertainment.courtReputation = math.min(100, Entertainment.courtReputation + performance.prestigeBonus)
    -- Check for offense
    if performance.riskOfOffense and math.random() < performance.riskOfOffense then
        if _G.state and _G.state.happiness then
            _G.state.happiness = math.max(0, _G.state.happiness - 5)
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                "Predstava žalila plemstvo! -5 sreče", "warning")
        end
    end
    -- Free the entertainer
    local e = Entertainment.findEntertainer(performance.entertainerId)
    if e then
        e.status = "idle"
        e.performances = e.performances + 1
        e.skill = math.min(100, e.skill + 1)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Predstava končana: %s (+%d sreče)",
                performance.typeName, performance.happinessBonus), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "PERFORMANCE_COMPLETED", {
            type = performance.type, entertainer = performance.entertainerName,
        })
    end
end

-- ============================================================
-- TOURING (send to other courts)
-- ============================================================
function Entertainment.sendOnTour(entertainerId, targetFaction, duration)
    local e = Entertainment.findEntertainer(entertainerId)
    if not e then return false, "Zabavljalec ne obstaja" end
    if e.status ~= "idle" then return false, "Zabavljalec ni prost" end
    duration = duration or 30
    e.status = "touring"
    table.insert(Entertainment.touringEntertainers, {
        entertainerId = entertainerId,
        entertainerName = e.name,
        targetFaction = targetFaction,
        daysRemaining = duration,
        totalDays = duration,
    })
    -- Immediate relation boost
    if _G.DiplomacyController then
        pcall(_G.DiplomacyController.changeRelation, targetFaction, 10)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("%s poslan na turnejo k %s", e.name, tostring(targetFaction)), "info")
    end
    return true
end

function Entertainment.updateTouring()
    for i = #Entertainment.touringEntertainers, 1, -1 do
        local t = Entertainment.touringEntertainers[i]
        t.daysRemaining = t.daysRemaining - 1
        if t.daysRemaining <= 0 then
            -- Return home
            local e = Entertainment.findEntertainer(t.entertainerId)
            if e then
                e.status = "idle"
                e.skill = math.min(100, e.skill + 3)
            end
            Entertainment.courtReputation = math.min(100, Entertainment.courtReputation + 5)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    t.entertainerName .. " se vrnil s turneje!", "success")
            end
            table.remove(Entertainment.touringEntertainers, i)
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Entertainment.update(dt)
    if not _G.state then return end
    Entertainment.dayTimer = Entertainment.dayTimer + dt
    if Entertainment.dayTimer >= 30 then
        Entertainment.dayTimer = 0
        -- Process performances
        for i = #Entertainment.activePerformances, 1, -1 do
            local p = Entertainment.activePerformances[i]
            p.daysRemaining = p.daysRemaining - 1
            if p.daysRemaining <= 0 then
                Entertainment.completePerformance(p)
                table.remove(Entertainment.activePerformances, i)
            end
        end
        -- Process touring
        Entertainment.updateTouring()
        -- Pay upkeep
        local totalUpkeep = 0
        for _, e in ipairs(Entertainment.hiredEntertainers) do
            local def = ENTERTAINERS[e.type]
            if def then totalUpkeep = totalUpkeep + def.upkeep end
        end
        for _, b in ipairs(Entertainment.entertainmentBuildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Apply passive happiness from buildings
        local buildingHappiness = 0
        for _, b in ipairs(Entertainment.entertainmentBuildings) do
            local def = BUILDINGS[b.type]
            if def and def.happinessBonus then
                buildingHappiness = buildingHappiness + def.happinessBonus * 0.1
            end
        end
        if buildingHappiness > 0 and _G.state and _G.state.happiness then
            _G.state.happiness = math.min(100, _G.state.happiness + buildingHappiness)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Entertainment.getEntertainerInfo(typeId) return ENTERTAINERS[typeId] end
function Entertainment.getPerformanceInfo(typeId) return PERFORMANCES[typeId] end
function Entertainment.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Entertainment.getStats()
    return {
        numEntertainers = #Entertainment.hiredEntertainers,
        capacity = Entertainment.getTotalCapacity(),
        activePerformances = #Entertainment.activePerformances,
        touringEntertainers = #Entertainment.touringEntertainers,
        numBuildings = #Entertainment.entertainmentBuildings,
        courtReputation = Entertainment.courtReputation,
        totalPerformances = Entertainment.totalPerformances,
    }
end

return Entertainment
