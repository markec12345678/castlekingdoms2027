-- objects/Economy/RoyalVineyardWineSystem.lua
-- Castle Kingdoms 2027 v3.3.8 - Royal Vineyard & Wine System
--
-- Manages vineyards, wine production, vintages, and wine trade.
-- Wine provides happiness, prestige, and trade income.
--
-- Features:
-- - 6 grape varieties (pinot noir, chardonnay, merlot, riesling, cabernet, muscat)
-- - 4 wine types (table wine, fine wine, vintage wine, royal reserve)
-- - 3 vineyard buildings (vineyard, winery, cellars)
-- - Vintner NPC (skill affects wine quality)
-- - Vintage system (wines improve with age)
-- - Wine aging (cellar storage)
-- - Wine trade (export for gold)
-- - Seasonal production
-- - Wine tasting events

local Vineyard = {}

-- ============================================================
-- GRAPE VARIETIES
-- ============================================================
local GRAPES = {
    pinot_noir = {
        name = "Pinot Noir",
        nameEn = "Pinot Noir",
        cost = 200,
        growthTime = 90,
        baseYield = 20,
        qualityBonus = 15,
        description = "Zahtevna a visokokakovostna sorta.",
    },
    chardonnay = {
        name = "Chardonnay",
        nameEn = "Chardonnay",
        cost = 150,
        growthTime = 80,
        baseYield = 25,
        qualityBonus = 10,
        description = "Priljubljena bela sorta.",
    },
    merlot = {
        name = "Merlot",
        nameEn = "Merlot",
        cost = 120,
        growthTime = 75,
        baseYield = 30,
        qualityBonus = 8,
        description = "Zanesljiva rdeča sorta.",
    },
    riesling = {
        name = "Riesling",
        nameEn = "Riesling",
        cost = 180,
        growthTime = 85,
        baseYield = 22,
        qualityBonus = 12,
        description = "Aromatična bela sorta.",
    },
    cabernet = {
        name = "Cabernet Sauvignon",
        nameEn = "Cabernet Sauvignon",
        cost = 160,
        growthTime = 95,
        baseYield = 28,
        qualityBonus = 14,
        description = "Močna rdeča sorta z dolgo tradicijo.",
    },
    muscat = {
        name = "Muškat",
        nameEn = "Muscat",
        cost = 100,
        growthTime = 70,
        baseYield = 35,
        qualityBonus = 5,
        description = "Sladka sorta za desertna vina.",
    },
}

-- ============================================================
-- WINE TYPES
-- ============================================================
local WINES = {
    table_wine = {
        name = "Namizno vino",
        nameEn = "Table Wine",
        grapesRequired = 5,
        brewTime = 30,
        baseValue = 50,
        happinessBonus = 2,
        description = "Preprosto vino za vsakdanjo uporabo.",
    },
    fine_wine = {
        name = "Dobro vino",
        nameEn = "Fine Wine",
        grapesRequired = 10,
        brewTime = 90,
        baseValue = 200,
        happinessBonus = 5,
        prestigeBonus = 3,
        description = "Kakovostno vino za dvor.",
    },
    vintage_wine = {
        name = "Letnik",
        nameEn = "Vintage Wine",
        grapesRequired = 20,
        brewTime = 365,
        baseValue = 800,
        happinessBonus = 10,
        prestigeBonus = 8,
        agingBonus = 2,  -- improves 2x per year aged
        description = "Vrhunsko vino, boljše z leti.",
    },
    royal_reserve = {
        name = "Kraljevska rezerva",
        nameEn = "Royal Reserve",
        grapesRequired = 50,
        brewTime = 730,  -- 2 years
        baseValue = 3000,
        happinessBonus = 20,
        prestigeBonus = 20,
        agingBonus = 3,
        description = "Najboljše vino, rezervirano za kralja.",
    },
}

-- ============================================================
-- VINEYARD BUILDINGS
-- ============================================================
local BUILDINGS = {
    vineyard = {
        name = "Vinograd",
        cost = { gold = 500, wood = 100 },
        upkeep = 15,
        grapeCapacity = 10,
        qualityBonus = 5,
        description = "Polje za gojenje vinske trte.",
    },
    winery = {
        name = "Vinska klet",
        cost = { gold = 2000, wood = 300, stone = 200 },
        upkeep = 50,
        wineCapacity = 50,
        qualityBonus = 15,
        description = "Klet za predelavo grozdja.",
    },
    aging_cellar = {
        name = "Skladišče za staranje",
        cost = { gold = 5000, wood = 500, stone = 800 },
        upkeep = 100,
        wineCapacity = 200,
        qualityBonus = 30,
        agingBonus = 1.5,  -- 50% faster aging
        description = "Temni hladni podrvm za staranje vin.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Vineyard.activePlantings = {}            -- Grapes being grown
Vineyard.grapeStockpile = {}             -- Stored grapes
Vineyard.wineStockpile = {}              -- Stored wines
Vineyard.activeBrewing = {}              -- Wines being made
Vineyard.buildings = {}                  -- Built buildings
Vineyard.vintner = nil                   -- Hired vintner NPC
Vineyard.totalWineProduced = 0
Vineyard.totalGrapesHarvested = 0
Vineyard.totalWineSold = 0
Vineyard.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Vineyard.init()
    Vineyard.activePlantings = {}
    Vineyard.grapeStockpile = {}
    Vineyard.wineStockpile = {}
    Vineyard.activeBrewing = {}
    Vineyard.buildings = {}
    Vineyard.vintner = nil
    Vineyard.totalWineProduced = 0
    Vineyard.totalGrapesHarvested = 0
    Vineyard.totalWineSold = 0
    Vineyard.dayTimer = 0
    print("[Vineyard] Royal Vineyard & Wine System initialized (6 grapes, 4 wines, 3 buildings)")
end

-- ============================================================
-- VINTNER NPC
-- ============================================================
function Vineyard.hireVintner(name, skill)
    skill = skill or math.random(40, 90)
    local cost = 600 + skill * 10
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Vineyard.vintner = {
        name = name or ("Vinar " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        winesCrafted = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Vinar najet: %s (spretnost: %d)", Vineyard.vintner.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Vineyard.canBuild(buildingId)
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

function Vineyard.build(buildingId)
    local ok, err = Vineyard.canBuild(buildingId)
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
    table.insert(Vineyard.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Vineyard.getQualityBonus()
    local bonus = 0
    for _, b in ipairs(Vineyard.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.qualityBonus then bonus = bonus + def.qualityBonus end
    end
    return bonus
end

function Vineyard.getGrapeCapacity()
    local cap = 0
    for _, b in ipairs(Vineyard.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.grapeCapacity then cap = cap + def.grapeCapacity end
    end
    return cap
end

function Vineyard.getWineCapacity()
    local cap = 10
    for _, b in ipairs(Vineyard.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.wineCapacity then cap = cap + def.wineCapacity end
    end
    return cap
end

function Vineyard.getAgingBonus()
    local bonus = 1.0
    for _, b in ipairs(Vineyard.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.agingBonus then bonus = math.max(bonus, def.agingBonus) end
    end
    return bonus
end

-- ============================================================
-- PLANTING GRAPES
-- ============================================================
function Vineyard.canPlant(grapeType)
    local def = GRAPES[grapeType]
    if not def then return false, "Neznana sorta" end
    if #Vineyard.activePlantings >= Vineyard.getGrapeCapacity() then
        return false, "Vinograd je poln"
    end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata za sadike"
    end
    return true
end

function Vineyard.plantGrapes(grapeType)
    local ok, err = Vineyard.canPlant(grapeType)
    if not ok then return false, err end
    local def = GRAPES[grapeType]
    _G.state.gold = _G.state.gold - def.cost
    local planting = {
        id = "planting_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        grapeType = grapeType,
        daysRemaining = def.growthTime,
        plantedDay = os.time(),
    }
    table.insert(Vineyard.activePlantings, planting)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Posajeno: %s (%d dni do obiranja)", def.name, def.growthTime), "info")
    end
    return true
end

function Vineyard.updatePlantings()
    for i = #Vineyard.activePlantings, 1, -1 do
        local p = Vineyard.activePlantings[i]
        p.daysRemaining = p.daysRemaining - 1
        if p.daysRemaining <= 0 then
            local def = GRAPES[p.grapeType]
            local yield = def.baseYield + math.random(-5, 10)
            -- Quality bonus from buildings
            local qualityMult = 1 + (Vineyard.getQualityBonus() / 100)
            if Vineyard.vintner then
                qualityMult = qualityMult + (Vineyard.vintner.skill / 200)
            end
            yield = math.floor(yield * qualityMult)
            Vineyard.grapeStockpile[p.grapeType] = (Vineyard.grapeStockpile[p.grapeType] or 0) + yield
            Vineyard.totalGrapesHarvested = Vineyard.totalGrapesHarvested + yield
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("Grozdje obrano: %d %s", yield, def.name), "success")
            end
            table.remove(Vineyard.activePlantings, i)
        end
    end
end

-- ============================================================
-- WINE MAKING
-- ============================================================
function Vineyard.canMakeWine(wineType, grapeType)
    local def = WINES[wineType]
    if not def then return false, "Neznano vino" end
    if not grapeType or not GRAPES[grapeType] then
        return false, "Neznana sorta grozdja"
    end
    if (Vineyard.grapeStockpile[grapeType] or 0) < def.grapesRequired then
        return false, "Premalo grozdja"
    end
    -- Need winery
    local hasWinery = false
    for _, b in ipairs(Vineyard.buildings) do
        if b.type == "winery" or b.type == "aging_cellar" then
            hasWinery = true; break
        end
    end
    if not hasWinery then
        return false, "Potrebna vinska klet"
    end
    return true
end

function Vineyard.makeWine(wineType, grapeType)
    local ok, err = Vineyard.canMakeWine(wineType, grapeType)
    if not ok then return false, err end
    local def = WINES[wineType]
    Vineyard.grapeStockpile[grapeType] = Vineyard.grapeStockpile[grapeType] - def.grapesRequired
    local brewing = {
        id = "wine_brew_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        wineType = wineType,
        wineName = def.name,
        grapeType = grapeType,
        daysRemaining = def.brewTime,
        totalDays = def.brewTime,
        baseValue = def.baseValue,
        happinessBonus = def.happinessBonus,
        prestigeBonus = def.prestigeBonus or 0,
        agingBonus = def.agingBonus or 0,
        quality = 1.0,  -- will improve with age
        started = os.time(),
    }
    table.insert(Vineyard.activeBrewing, brewing)
    if Vineyard.vintner then
        Vineyard.vintner.winesCrafted = Vineyard.vintner.winesCrafted + 1
        if math.random() < 0.15 then
            Vineyard.vintner.skill = math.min(100, Vineyard.vintner.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Vino v pripravi: %s iz %s (%d dni)",
                def.name, GRAPES[grapeType].name, def.brewTime), "info")
    end
    return true
end

function Vineyard.completeBrewing(brewing)
    Vineyard.wineStockpile[brewing.wineType] = Vineyard.wineStockpile[brewing.wineType] or {}
    table.insert(Vineyard.wineStockpile[brewing.wineType], {
        id = "wine_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        grapeType = brewing.grapeType,
        quality = brewing.quality,
        value = brewing.baseValue,
        happinessBonus = brewing.happinessBonus,
        prestigeBonus = brewing.prestigeBonus,
        agingBonus = brewing.agingBonus,
        age = 0,  -- will increase over time
        producedDay = os.time(),
    })
    Vineyard.totalWineProduced = Vineyard.totalWineProduced + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Vino pripravljeno: %s!", brewing.wineName), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "WINE_PRODUCED", { type = brewing.wineType })
    end
end

-- ============================================================
-- WINE AGING
-- ============================================================
function Vineyard.ageWines()
    local agingBonus = Vineyard.getAgingBonus()
    for wineType, wines in pairs(Vineyard.wineStockpile) do
        for _, w in ipairs(wines) do
            w.age = w.age + 1
            if w.agingBonus > 0 then
                -- Wine improves with age
                local improvement = w.agingBonus * agingBonus * 0.01
                w.quality = w.quality + improvement
                w.value = math.floor(w.value * (1 + improvement))
                w.happinessBonus = w.happinessBonus + improvement
            end
        end
    end
end

-- ============================================================
-- SELL AND CONSUME WINE
-- ============================================================
function Vineyard.sellWine(wineType, index)
    if not Vineyard.wineStockpile[wineType] or not Vineyard.wineStockpile[wineType][index] then
        return false, "Vino ne obstaja"
    end
    local wine = Vineyard.wineStockpile[wineType][index]
    local sellPrice = math.floor(wine.value * wine.quality)
    if _G.state then
        _G.state.gold = (_G.state.gold or 0) + sellPrice
    end
    Vineyard.totalWineSold = Vineyard.totalWineSold + 1
    table.remove(Vineyard.wineStockpile[wineType], index)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Vino prodano: %s za %d zlata", wineType, sellPrice), "success")
    end
    return true
end

function Vineyard.consumeWine(wineType)
    if not Vineyard.wineStockpile[wineType] or #Vineyard.wineStockpile[wineType] == 0 then
        return false, "Ni vina na zalogi"
    end
    local wine = table.remove(Vineyard.wineStockpile[wineType], 1)
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + wine.happinessBonus)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Vino postreženo: %s (+%d sreče)", wineType, wine.happinessBonus), "info")
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Vineyard.update(dt)
    if not _G.state then return end
    Vineyard.dayTimer = Vineyard.dayTimer + dt
    if Vineyard.dayTimer >= 30 then
        Vineyard.dayTimer = 0
        Vineyard.updatePlantings()
        -- Process brewing
        for i = #Vineyard.activeBrewing, 1, -1 do
            local b = Vineyard.activeBrewing[i]
            b.daysRemaining = b.daysRemaining - 1
            if b.daysRemaining <= 0 then
                Vineyard.completeBrewing(b)
                table.remove(Vineyard.activeBrewing, i)
            end
        end
        -- Age wines
        Vineyard.ageWines()
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Vineyard.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Vineyard.vintner then totalUpkeep = totalUpkeep + 30 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Vineyard.getGrapeInfo(grapeId) return GRAPES[grapeId] end
function Vineyard.getWineInfo(wineId) return WINES[wineId] end
function Vineyard.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Vineyard.getStats()
    local totalWines = 0
    for _, wines in pairs(Vineyard.wineStockpile) do
        totalWines = totalWines + #wines
    end
    return {
        activePlantings = #Vineyard.activePlantings,
        grapeCapacity = Vineyard.getGrapeCapacity(),
        wineCapacity = Vineyard.getWineCapacity(),
        totalWines = totalWines,
        numBuildings = #Vineyard.buildings,
        hasVintner = Vineyard.vintner ~= nil,
        vintnerName = Vineyard.vintner and Vineyard.vintner.name or "—",
        vintnerSkill = Vineyard.vintner and Vineyard.vintner.skill or 0,
        activeBrewing = #Vineyard.activeBrewing,
        totalWineProduced = Vineyard.totalWineProduced,
        totalGrapesHarvested = Vineyard.totalGrapesHarvested,
        totalWineSold = Vineyard.totalWineSold,
    }
end

return Vineyard
