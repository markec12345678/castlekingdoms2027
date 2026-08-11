-- objects/Gameplay/WinterQuartersSystem.lua
-- Castle Kingdoms 2027 v3.1.9 - Winter Quarters & Hibernation System
--
-- Manages the seasonal cycle for armies: armies in the field during winter
-- suffer attrition, morale loss, and supply issues. Players must establish
-- winter quarters or risk losing their forces.
--
-- Features:
-- - 4 season phases (spring, summer, autumn, winter)
-- - Winter attrition (units lose HP, morale, supplies)
-- - Winter quarters (special buildings to house armies)
-- - Supply line management (cut off = heavier attrition)
-- - Army morale effects (winter fatigue)
-- - Hibernation option (army becomes inactive but safe)
-- - Spring offensive (units emerge rested)
-- - Frostbite casualties (severe winters)
-- - Foraging (reduces but damages countryside)

local Winter = {}

-- ============================================================
-- SEASONS
-- ============================================================
local SEASONS = {
    spring = {
        name = "Pomlad",
        nameEn = "Spring",
        duration = 90,  -- game days
        attritionRate = 0,
        moraleChange = 1,
        supplyConsumption = 1.0,
        movementModifier = 1.1,
        description = "Toplo vreme, idealno za vojaške operacije.",
    },
    summer = {
        name = "Poletje",
        nameEn = "Summer",
        duration = 90,
        attritionRate = 0,
        moraleChange = 0,
        supplyConsumption = 1.0,
        movementModifier = 1.0,
        description = "Polna kampanjska sezona.",
    },
    autumn = {
        name = "Jesen",
        nameEn = "Autumn",
        duration = 60,
        attritionRate = 0.5,
        moraleChange = -1,
        supplyConsumption = 1.2,
        movementModifier = 0.9,
        description = "Slabše vreme, težje operacije.",
    },
    winter = {
        name = "Zima",
        nameEn = "Winter",
        duration = 120,
        attritionRate = 3.0,      -- HP per day lost
        moraleChange = -3,
        supplyConsumption = 2.0,
        movementModifier = 0.5,
        frostbiteChance = 0.05,   -- 5% per day, unit takes damage
        description = "Smrtonosna zima — vojska potrebuje zimske kvartire.",
    },
}

-- ============================================================
-- WINTER QUARTER BUILDINGS
-- ============================================================
local QUARTERS = {
    camp = {
        name = "Tabor",
        cost = { gold = 50, wood = 30 },
        upkeep = 2,
        capacity = 50,
        protectionBonus = 0.20,  -- 20% less attrition
        moraleBonus = 1,
        description = "Začasen tabor za manjšo vojsko.",
    },
    barracks = {
        name = "Barake",
        cost = { gold = 300, wood = 150, stone = 100 },
        upkeep = 10,
        capacity = 200,
        protectionBonus = 0.50,
        moraleBonus = 3,
        description = "Stalne barake za vojsko.",
    },
    fortress = {
        name = "Trdnjava",
        cost = { gold = 2000, wood = 300, stone = 800 },
        upkeep = 40,
        capacity = 500,
        protectionBonus = 0.80,
        moraleBonus = 8,
        description = "Velika trdnjava za zimske kvartire.",
    },
    supply_depot = {
        name = "Zalogovnik",
        cost = { gold = 200, wood = 100 },
        upkeep = 5,
        capacity = 0,  -- doesn't house units
        supplyBonus = 100,  -- extra supply storage
        description = "Skladišče za zimske zaloge.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Winter.currentSeason = "spring"
Winter.seasonProgress = 0          -- days into current season
Winter.winterQuarters = {}         -- Built quarters
Winter.hibernatingArmies = {}      -- Armies in winter sleep
Winter.totalAttritionDeaths = 0
Winter.totalFrostbiteCases = 0
Winter.supplies = 500              -- Current supply stockpile
Winter.supplyMax = 2000
Winter.dayTimer = 0
Winter.yearCount = 1

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Winter.init()
    Winter.currentSeason = "spring"
    Winter.seasonProgress = 0
    Winter.winterQuarters = {}
    Winter.hibernatingArmies = {}
    Winter.totalAttritionDeaths = 0
    Winter.totalFrostbiteCases = 0
    Winter.supplies = 500
    Winter.supplyMax = 2000
    Winter.dayTimer = 0
    Winter.yearCount = 1
    print("[Winter] Winter Quarters & Hibernation System initialized (4 seasons, 4 buildings)")
end

-- ============================================================
-- SEASON MANAGEMENT
-- ============================================================
function Winter.advanceSeason()
    local order = { "spring", "summer", "autumn", "winter" }
    local idx = 1
    for i, s in ipairs(order) do
        if s == Winter.currentSeason then idx = i; break end
    end
    idx = idx + 1
    if idx > #order then
        idx = 1
        Winter.yearCount = Winter.yearCount + 1
    end
    Winter.currentSeason = order[idx]
    Winter.seasonProgress = 0
    local def = SEASONS[Winter.currentSeason]
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Letni čas: " .. def.name .. " (leto " .. Winter.yearCount .. ")", "info")
    end
    -- Spring wakeup
    if Winter.currentSeason == "spring" then
        Winter.wakeHibernatingArmies()
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "SEASON_CHANGED", { season = Winter.currentSeason, year = Winter.yearCount })
    end
end

function Winter.getSeasonInfo()
    return SEASONS[Winter.currentSeason]
end

function Winter.isWinter()
    return Winter.currentSeason == "winter"
end

-- ============================================================
-- WINTER QUARTERS
-- ============================================================
function Winter.canBuildQuarter(quarterType)
    local def = QUARTERS[quarterType]
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

function Winter.buildQuarter(quarterType, x, y)
    local ok, err = Winter.canBuildQuarter(quarterType)
    if not ok then return false, err end
    local def = QUARTERS[quarterType]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Winter.winterQuarters, {
        type = quarterType,
        x = x or 0,
        y = y or 0,
        builtDay = os.time(),
    })
    -- Supply depot increases max
    if def.supplyBonus then
        Winter.supplyMax = Winter.supplyMax + def.supplyBonus
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Winter.getTotalQuarterCapacity()
    local cap = 0
    for _, q in ipairs(Winter.winterQuarters) do
        local def = QUARTERS[q.type]
        if def and def.capacity then cap = cap + def.capacity end
    end
    return cap
end

function Winter.getAverageProtection()
    if #Winter.winterQuarters == 0 then return 0 end
    local sum = 0
    for _, q in ipairs(Winter.winterQuarters) do
        local def = QUARTERS[q.type]
        if def and def.protectionBonus then sum = sum + def.protectionBonus end
    end
    return sum / #Winter.winterQuarters
end

-- ============================================================
-- SUPPLY MANAGEMENT
-- ============================================================
function Winter.addSupplies(amount)
    Winter.supplies = math.min(Winter.supplyMax, Winter.supplies + amount)
end

function Winter.consumeSupplies(amount)
    if Winter.supplies >= amount then
        Winter.supplies = Winter.supplies - amount
        return true
    end
    -- Not enough — extra attrition
    Winter.supplies = 0
    return false
end

-- ============================================================
-- ARMY ATTRITION
-- ============================================================
function Winter.applyAttrition()
    if not _G.state then return end
    local season = SEASONS[Winter.currentSeason]
    if season.attritionRate <= 0 then return end
    -- Get total army size
    local armySize = (_G.state.armySize or _G.state.population * 0.1 or 100)
    -- Reduce by quarter capacity (units in quarters are safe)
    local inQuarters = math.min(armySize, Winter.getTotalQuarterCapacity())
    local exposed = armySize - inQuarters
    if exposed <= 0 then return end
    -- Apply protection
    local protection = Winter.getAverageProtection()
    local effectiveAttrition = season.attritionRate * (1 - protection)
    -- Check supplies
    local supplyNeeded = exposed * season.supplyConsumption * 0.5
    local hasSupplies = Winter.consumeSupplies(supplyNeeded)
    if not hasSupplies then
        effectiveAttrition = effectiveAttrition * 2  -- starvation
    end
    -- Calculate casualties
    local casualties = math.floor(exposed * (effectiveAttrition / 100))
    if casualties > 0 then
        Winter.totalAttritionDeaths = Winter.totalAttritionDeaths + casualties
        if _G.state.population then
            _G.state.population = math.max(0, _G.state.population - casualties)
        end
        if _G.state.happiness then
            _G.state.happiness = math.max(0, _G.state.happiness - 1)
        end
        if _G.NotificationCenter and casualties > 5 then
            pcall(_G.NotificationCenter.notify,
                string.format("Atricija: %d vojakov izgubljenih zaradi %s",
                    casualties, season.name), "warning")
        end
    end
    -- Frostbite
    if season.frostbiteChance and math.random() < season.frostbiteChance then
        local frostbite = math.floor(exposed * 0.10)
        Winter.totalFrostbiteCases = Winter.totalFrostbiteCases + frostbite
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Ozebline: %d primerov", frostbite), "warning")
        end
    end
    -- Morale
    if season.moraleChange ~= 0 and _G.state.happiness then
        _G.state.happiness = math.max(0, math.min(100,
            _G.state.happiness + season.moraleChange * 0.5))
    end
end

-- ============================================================
-- HIBERNATION
-- ============================================================
function Winter.hibernateArmy(armyId)
    local army = {
        id = armyId or ("army_" .. tostring(os.time())),
        hibernatedDay = os.time(),
        originalSeason = Winter.currentSeason,
    }
    table.insert(Winter.hibernatingArmies, army)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Vojska v hibernaciji — varna do pomladi.", "info")
    end
    return true
end

function Winter.wakeHibernatingArmies()
    if #Winter.hibernatingArmies == 0 then return end
    -- Spring wakeup — morale boost
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + 5)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Pomlad! %d vojsk zbujenih iz hibernacije.",
                #Winter.hibernatingArmies), "success")
    end
    Winter.hibernatingArmies = {}
end

-- ============================================================
-- FORAGING (damages countryside)
-- ============================================================
function Winter.forage()
    -- Reduces supply need but damages happiness
    local gathered = math.random(50, 150)
    Winter.addSupplies(gathered)
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.max(0, _G.state.happiness - 3)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Rekvizicija: +%d zalog (sreča -3)", gathered), "warning")
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Winter.update(dt)
    if not _G.state then return end
    Winter.dayTimer = Winter.dayTimer + dt
    -- Day tick (every 30 sec)
    if Winter.dayTimer >= 30 then
        Winter.dayTimer = 0
        Winter.seasonProgress = Winter.seasonProgress + 1
        local season = SEASONS[Winter.currentSeason]
        -- Apply attrition
        Winter.applyAttrition()
        -- Check season transition
        if Winter.seasonProgress >= season.duration then
            Winter.advanceSeason()
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Winter.getQuarterInfo(quarterId) return QUARTERS[quarterId] end
function Winter.getSeasons() return SEASONS end

function Winter.getStats()
    return {
        currentSeason = Winter.currentSeason,
        seasonProgress = Winter.seasonProgress,
        yearCount = Winter.yearCount,
        supplies = Winter.supplies,
        supplyMax = Winter.supplyMax,
        numQuarters = #Winter.winterQuarters,
        quarterCapacity = Winter.getTotalQuarterCapacity(),
        hibernatingArmies = #Winter.hibernatingArmies,
        totalAttritionDeaths = Winter.totalAttritionDeaths,
        totalFrostbiteCases = Winter.totalFrostbiteCases,
    }
end

function Winter.getActiveModifiers()
    local season = SEASONS[Winter.currentSeason]
    return {
        movementModifier = season.movementModifier,
        supplyConsumption = season.supplyConsumption,
        attritionRate = season.attritionRate,
        moraleChange = season.moraleChange,
        isWinter = Winter.currentSeason == "winter",
    }
end

return Winter
