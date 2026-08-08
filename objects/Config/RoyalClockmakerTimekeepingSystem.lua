-- objects/Config/RoyalClockmakerTimekeepingSystem.lua
-- Castle Kingdoms 2027 v3.6.1 - Royal Clockmaker & Timekeeping System
--
-- Manages clockmaking, timekeeping devices, and the royal calendar.
-- Clocks provide precision, prestige, and scheduling capabilities.
--
-- Features:
-- - 6 clock types (sundial, water clock, hourglass, mechanical, astronomical, turret)
-- - 8 timekeeping products (pocket watch, bell, chime, calendar, astrolabe, ...
-- - 4 clockmaker buildings (workshop, foundry, observatory clock, royal clocktower)
-- - Clockmaker NPC (skill affects accuracy)
-- - Clock construction (time-based with precision)
-- - Calendar management
-- - Time announcements
-- - Precision bonuses (efficiency improvements)

local Clockmaker = {}

-- ============================================================
-- CLOCK TYPES
-- ============================================================
local CLOCKS = {
    sundial = {
        name = "Sončna ura",
        nameEn = "Sundial",
        cost = 50,
        buildTime = 3,
        accuracy = 0.30,
        prestige = 2,
        description = "Preprosta ura, ki deluje podnevi.",
    },
    water_clock = {
        name = "Vodna ura",
        nameEn = "Water Clock",
        cost = 200,
        buildTime = 7,
        accuracy = 0.50,
        prestige = 5,
        description = "Ura z vodo — deluje tudi ponoči.",
    },
    hourglass = {
        name = "Peščena ura",
        nameEn = "Hourglass",
        cost = 100,
        buildTime = 4,
        accuracy = 0.60,
        prestige = 3,
        description = "Natančna peščena ura.",
    },
    mechanical = {
        name = "Mehanska ura",
        nameEn = "Mechanical Clock",
        cost = 800,
        buildTime = 21,
        accuracy = 0.80,
        prestige = 15,
        description = "Ura z uteži in zobniki.",
    },
    astronomical = {
        name = "Astronomska ura",
        nameEn = "Astronomical Clock",
        cost = 3000,
        buildTime = 60,
        accuracy = 0.90,
        prestige = 40,
        description = "Ura z zvezdami in planeti.",
    },
    turret = {
        name = "Stolpna ura",
        nameEn = "Turret Clock",
        cost = 5000,
        buildTime = 90,
        accuracy = 0.85,
        prestige = 50,
        description = "Velika ura za javni stolp.",
    },
}

-- ============================================================
-- TIMEKEEPING PRODUCTS
-- ============================================================
local PRODUCTS = {
    pocket_watch = { name = "Žepna ura", cost = 500, prestigeBonus = 10, buildTime = 14, description = "Osebna prenosna ura." },
    bell = { name = "Zvon", cost = 300, buildTime = 10, happinessBonus = 3, description = "Zvon za oznanjanje ure." },
    chime = { name = "Zvonoglasje", cost = 800, buildTime = 20, happinessBonus = 8, prestigeBonus = 5, description = "Melodično zvonjenje." },
    calendar = { name = "Koledar", cost = 100, buildTime = 5, knowledgeBonus = 10, description = "Natančni koledar." },
    astrolabe = { name = "Astrolab", cost = 1000, buildTime = 25, knowledgeBonus = 25, description = "Naprava za zvezde." },
    chronometer = { name = "Kronometer", cost = 2000, buildTime = 40, knowledgeBonus = 40, prestigeBonus = 15, description = "Najbolj natančna ura." },
    clock_face = { name = "Ciferblat", cost = 200, buildTime = 7, description = "Veliki ciferblat za stolp." },
    pendulum = { name = "Nihalo", cost = 150, buildTime = 5, description = "Nihalo za natančnost ure." },
}

-- ============================================================
-- CLOCKMAKER BUILDINGS
-- ============================================================
local BUILDINGS = {
    workshop = {
        name = "Urarjeva delavnica",
        cost = { gold = 400, wood = 150, iron = 50 },
        upkeep = 15,
        precisionBonus = 5,
        description = "Delavnica za izdelavo ur.",
    },
    foundry = {
        name = "Livarna zvonov",
        cost = { gold = 1500, wood = 300, stone = 300, iron = 200 },
        upkeep = 40,
        precisionBonus = 10,
        qualityBonus = 15,
        description = "Za livanje zvonov in uteži.",
    },
    observatory_clock = {
        name = "Observatorijska ura",
        cost = { gold = 3000, wood = 200, stone = 800, iron = 100 },
        upkeep = 70,
        precisionBonus = 25,
        qualityBonus = 25,
        prestigeBonus = 15,
        description = "Najnatančnejša ura za observatorij.",
    },
    royal_clocktower = {
        name = "Kraljevski stolp z uro",
        cost = { gold = 8000, wood = 500, stone = 2000, iron = 300 },
        upkeep = 150,
        precisionBonus = 40,
        qualityBonus = 40,
        prestigeBonus = 30,
        description = "Veliki javni stolp z uro.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Clockmaker.builtClocks = {}
Clockmaker.productStock = {}
Clockmaker.buildings = {}
Clockmaker.clockmaker = nil
Clockmaker.activeConstruction = {}
Clockmaker.timePrecision = 30  -- 0-100
Clockmaker.totalClocksBuilt = 0
Clockmaker.totalProductsMade = 0
Clockmaker.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Clockmaker.init()
    Clockmaker.builtClocks = {}
    Clockmaker.productStock = {}
    Clockmaker.buildings = {}
    Clockmaker.clockmaker = nil
    Clockmaker.activeConstruction = {}
    Clockmaker.timePrecision = 30
    Clockmaker.totalClocksBuilt = 0
    Clockmaker.totalProductsMade = 0
    Clockmaker.dayTimer = 0
    print("[Clockmaker] Royal Clockmaker & Timekeeping System initialized (6 clocks, 8 products, 4 buildings)")
end

-- ============================================================
-- CLOCKMAKER NPC
-- ============================================================
function Clockmaker.hireClockmaker(name, skill)
    skill = skill or math.random(45, 90)
    local cost = 500 + skill * 10
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Clockmaker.clockmaker = {
        name = name or ("Urar " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        clocksBuilt = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Urar najet: %s (spretnost: %d)", Clockmaker.clockmaker.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Clockmaker.canBuild(buildingId)
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

function Clockmaker.build(buildingId)
    local ok, err = Clockmaker.canBuild(buildingId)
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
    table.insert(Clockmaker.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Clockmaker.getPrecisionBonus()
    local bonus = 0
    for _, b in ipairs(Clockmaker.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.precisionBonus then bonus = bonus + def.precisionBonus end
    end
    return bonus
end

function Clockmaker.getQualityBonus()
    local bonus = 0
    for _, b in ipairs(Clockmaker.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.qualityBonus then bonus = bonus + def.qualityBonus end
    end
    return bonus
end

function Clockmaker.getPrestigeBonus()
    local bonus = 0
    for _, b in ipairs(Clockmaker.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.prestigeBonus then bonus = bonus + def.prestigeBonus end
    end
    return bonus
end

-- ============================================================
-- CLOCK CONSTRUCTION
-- ============================================================
function Clockmaker.canBuildClock(clockType)
    local def = CLOCKS[clockType]
    if not def then return false, "Neznana ura" end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    if #Clockmaker.buildings == 0 then return false, "Potrebna urarska zgradba" end
    if not Clockmaker.clockmaker then return false, "Potreben urar" end
    return true
end

function Clockmaker.buildClock(clockType)
    local ok, err = Clockmaker.canBuildClock(clockType)
    if not ok then return false, err end
    local def = CLOCKS[clockType]
    _G.state.gold = _G.state.gold - def.cost
    if _G.state.resources then
        _G.state.resources.iron = (_G.state.resources.iron or 0) - math.floor(def.cost / 20)
        _G.state.resources.wood = (_G.state.resources.wood or 0) - math.floor(def.cost / 50)
    end
    local buildTime = def.buildTime
    local bonus = Clockmaker.getPrecisionBonus()
    if Clockmaker.clockmaker then
        bonus = bonus + math.floor(Clockmaker.clockmaker.skill / 5)
    end
    buildTime = math.max(1, buildTime - math.floor(bonus / 10))
    local construction = {
        id = "clock_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        clockType = clockType,
        clockName = def.name,
        daysRemaining = buildTime,
        baseAccuracy = def.accuracy,
        prestige = def.prestige,
        started = os.time(),
    }
    table.insert(Clockmaker.activeConstruction, construction)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Gradnja ure: %s (%d dni)", def.name, buildTime), "info")
    end
    return true
end

function Clockmaker.completeClock(construction)
    local accuracy = construction.baseAccuracy
    accuracy = accuracy + (Clockmaker.getPrecisionBonus() / 200)
    if Clockmaker.clockmaker then
        accuracy = accuracy + (Clockmaker.clockmaker.skill / 300)
    end
    accuracy = math.min(0.99, accuracy)
    local clock = {
        id = construction.id,
        type = construction.clockType,
        name = construction.clockName,
        accuracy = accuracy,
        prestige = construction.prestige,
        builtDay = os.time(),
    }
    table.insert(Clockmaker.builtClocks, clock)
    Clockmaker.totalClocksBuilt = Clockmaker.totalClocksBuilt + 1
    -- Update time precision
    Clockmaker.timePrecision = math.min(100, Clockmaker.timePrecision + math.floor(accuracy * 20))
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + math.floor(construction.prestige / 3))
    end
    if Clockmaker.clockmaker then
        Clockmaker.clockmaker.clocksBuilt = Clockmaker.clockmaker.clocksBuilt + 1
        if math.random() < 0.20 then
            Clockmaker.clockmaker.skill = math.min(100, Clockmaker.clockmaker.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Ura zgrajena: %s (natančnost: %.0f%%)", construction.clockName, accuracy * 100), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "CLOCK_BUILT", {
            type = construction.clockType, accuracy = accuracy,
        })
    end
end

-- ============================================================
-- PRODUCT MAKING
-- ============================================================
function Clockmaker.canMakeProduct(productId, quantity)
    local def = PRODUCTS[productId]
    if not def then return false, "Neznan produkt" end
    quantity = quantity or 1
    if not _G.state or (_G.state.gold or 0) < def.cost * quantity / 2 then
        return false, "Premalo zlata za materiale"
    end
    if not Clockmaker.clockmaker then return false, "Potreben urar" end
    return true
end

function Clockmaker.makeProduct(productId, quantity)
    quantity = quantity or 1
    local ok, err = Clockmaker.canMakeProduct(productId, quantity)
    if not ok then return false, err end
    local def = PRODUCTS[productId]
    _G.state.gold = _G.state.gold - math.floor(def.cost * quantity / 2)
    local makeTime = def.buildTime
    local bonus = Clockmaker.getQualityBonus()
    if Clockmaker.clockmaker then
        bonus = bonus + math.floor(Clockmaker.clockmaker.skill / 5)
    end
    makeTime = math.max(1, makeTime - math.floor(bonus / 10))
    local making = {
        id = "product_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        productId = productId,
        productName = def.name,
        quantity = quantity,
        daysRemaining = makeTime,
        cost = def.cost,
        happinessBonus = def.happinessBonus or 0,
        prestigeBonus = def.prestigeBonus or 0,
        knowledgeBonus = def.knowledgeBonus or 0,
        started = os.time(),
    }
    table.insert(Clockmaker.activeConstruction, making)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Izdelava: %d %s (%d dni)", quantity, def.name, makeTime), "info")
    end
    return true
end

function Clockmaker.completeProduct(making)
    Clockmaker.productStock[making.productId] = (Clockmaker.productStock[making.productId] or 0) + making.quantity
    Clockmaker.totalProductsMade = Clockmaker.totalProductsMade + making.quantity
    if Clockmaker.clockmaker and math.random() < 0.15 then
        Clockmaker.clockmaker.skill = math.min(100, Clockmaker.clockmaker.skill + 1)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Produkt izdelan: %d %s", making.quantity, making.productName), "success")
    end
end

-- ============================================================
-- SELL AND USE
-- ============================================================
function Clockmaker.sellProduct(productId, quantity)
    if (Clockmaker.productStock[productId] or 0) < quantity then
        return false, "Ni dovolj na zalogi"
    end
    local def = PRODUCTS[productId]
    Clockmaker.productStock[productId] = Clockmaker.productStock[productId] - quantity
    local revenue = def.cost * quantity
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + revenue
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Prodano: %d %s za %d zlata", quantity, def.name, revenue), "success")
    end
    return true
end

function Clockmaker.useProduct(productId, quantity)
    if (Clockmaker.productStock[productId] or 0) < quantity then
        return false, "Ni dovolj na zalogi"
    end
    Clockmaker.productStock[productId] = Clockmaker.productStock[productId] - quantity
    local def = PRODUCTS[productId]
    if def.happinessBonus and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + def.happinessBonus * quantity)
    end
    if def.prestigeBonus and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + def.prestigeBonus)
    end
    if def.knowledgeBonus and _G.Culture then
        pcall(function() _G.Culture.knowledgePoints = (_G.Culture.knowledgePoints or 0) + def.knowledgeBonus * quantity end)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Uporabljeno: %d %s", quantity, def.name), "info")
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Clockmaker.update(dt)
    if not _G.state then return end
    Clockmaker.dayTimer = Clockmaker.dayTimer + dt
    if Clockmaker.dayTimer >= 30 then
        Clockmaker.dayTimer = 0
        for i = #Clockmaker.activeConstruction, 1, -1 do
            local c = Clockmaker.activeConstruction[i]
            c.daysRemaining = c.daysRemaining - 1
            if c.daysRemaining <= 0 then
                if c.productId then
                    Clockmaker.completeProduct(c)
                else
                    Clockmaker.completeClock(c)
                end
                table.remove(Clockmaker.activeConstruction, i)
            end
        end
        local totalUpkeep = 0
        for _, b in ipairs(Clockmaker.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Clockmaker.clockmaker then totalUpkeep = totalUpkeep + 20 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Time precision slowly improves with clocks
        if #Clockmaker.builtClocks > 0 and Clockmaker.timePrecision < 100 then
            Clockmaker.timePrecision = math.min(100, Clockmaker.timePrecision + 0.5)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Clockmaker.getClockInfo(id) return CLOCKS[id] end
function Clockmaker.getProductInfo(id) return PRODUCTS[id] end
function Clockmaker.getBuildingInfo(id) return BUILDINGS[id] end

function Clockmaker.getStats()
    return {
        numClocks = #Clockmaker.builtClocks,
        productStock = Clockmaker.productStock,
        numBuildings = #Clockmaker.buildings,
        hasClockmaker = Clockmaker.clockmaker ~= nil,
        clockmakerName = Clockmaker.clockmaker and Clockmaker.clockmaker.name or "—",
        clockmakerSkill = Clockmaker.clockmaker and Clockmaker.clockmaker.skill or 0,
        activeConstruction = #Clockmaker.activeConstruction,
        totalClocksBuilt = Clockmaker.totalClocksBuilt,
        totalProductsMade = Clockmaker.totalProductsMade,
        timePrecision = Clockmaker.timePrecision,
        prestigeBonus = Clockmaker.getPrestigeBonus(),
    }
end

return Clockmaker
