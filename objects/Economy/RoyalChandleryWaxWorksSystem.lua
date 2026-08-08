-- objects/Economy/RoyalChandleryWaxWorksSystem.lua
-- Castle Kingdoms 2027 v3.5.7 - Royal Chandlery & Wax Works System
--
-- Manages candle making, sealing wax, wax tablets, and wax products.
-- Candles provide light and faith bonuses; sealing wax enables documents.
--
-- Features:
-- - 6 candle types (tallow, beeswax, bayberry, stearin, spermaceti, church candles)
-- - 8 wax products (candles, sealing wax, tablets, sculptures, polish, ...
-- - 4 chandlery buildings (workshop, molding shop, wax storehouse, royal chandlery)
-- - Chandler NPC (skill affects quality)
-- - Candle making (time-based production)
-- - Wax supply management
-- - Scented candles (happiness bonus)
-- - Church candles (faith bonus)

local Chandlery = {}

-- ============================================================
-- CANDLE TYPES
-- ============================================================
local CANDLES = {
    tallow = {
        name = "Lojeva sveča",
        nameEn = "Tallow Candle",
        waxCost = 2,
        cost = 5,
        burnTime = 4,
        lightRadius = 5,
        happinessBonus = 1,
        description = "Cenejša sveča iz živalske maščobe.",
    },
    beeswax = {
        name = "Čebeljavoščena sveča",
        nameEn = "Beeswax Candle",
        waxCost = 3,
        cost = 15,
        burnTime = 8,
        lightRadius = 7,
        happinessBonus = 3,
        faithBonus = 5,
        description = "Visokokakovostna sveča iz čebeljega voska.",
    },
    bayberry = {
        name = "Lovorova sveča",
        nameEn = "Bayberry Candle",
        waxCost = 2,
        cost = 20,
        burnTime = 6,
        lightRadius = 6,
        happinessBonus = 5,
        aromaBonus = 8,
        description = "Dišeča sveča iz lovorja.",
    },
    stearin = {
        name = "Stearinska sveča",
        nameEn = "Stearin Candle",
        waxCost = 4,
        cost = 25,
        burnTime = 12,
        lightRadius = 8,
        happinessBonus = 4,
        description = "Dolgo goreča sveča.",
    },
    spermaceti = {
        name = "Spermacetna sveča",
        nameEn = "Spermaceti Candle",
        waxCost = 5,
        cost = 50,
        burnTime = 15,
        lightRadius = 10,
        happinessBonus = 6,
        prestigeBonus = 5,
        description = "Najsvetlejša in najdražja sveča.",
    },
    church = {
        name = "Cerkvena sveča",
        nameEn = "Church Candle",
        waxCost = 4,
        cost = 30,
        burnTime = 24,
        lightRadius = 9,
        faithBonus = 15,
        happinessBonus = 4,
        description = "Velika sveča za verske obrede.",
    },
}

-- ============================================================
-- WAX PRODUCTS
-- ============================================================
local PRODUCTS = {
    sealing_wax = {
        name = "Pečatni vosek",
        waxCost = 1,
        cost = 10,
        productionTime = 1,
        description = "Za pečatenje dokumentov.",
    },
    wax_tablet = {
        name = "Voščena tablica",
        waxCost = 2,
        cost = 15,
        productionTime = 2,
        description = "Za pisanje in brisanje.",
    },
    wax_sculpture = {
        name = "Voščeni kip",
        waxCost = 10,
        cost = 100,
        productionTime = 7,
        prestigeBonus = 8,
        description = "Umetniški kip iz voska.",
    },
    furniture_polish = {
        name = "Lesni lak",
        waxCost = 2,
        cost = 12,
        productionTime = 1,
        description = "Za nego lesenega pohištva.",
    },
    wax_crayons = {
        name = "Voščene barvice",
        waxCost = 1,
        cost = 8,
        productionTime = 1,
        happinessBonus = 3,
        description = "Za otroke in umetnike.",
    },
    encaustic_paint = {
        name = "Voskova barva",
        waxCost = 3,
        cost = 25,
        productionTime = 3,
        description = "Za slikanje z voskom (enkaustika).",
    },
    wax_seals = {
        name = "Voščeni pečati",
        waxCost = 1,
        cost = 5,
        productionTime = 1,
        description = "Pripravljeni pečati za dokumente.",
    },
    scented_wax = {
        name = "Dišeči vosek",
        waxCost = 3,
        cost = 30,
        productionTime = 2,
        happinessBonus = 8,
        aromaBonus = 10,
        description = "Vosek z eteričnimi olji.",
    },
}

-- ============================================================
-- CHANDLERY BUILDINGS
-- ============================================================
local BUILDINGS = {
    workshop = {
        name = "Svečarna",
        cost = { gold = 200, wood = 100 },
        upkeep = 5,
        productionBonus = 5,
        description = "Preprosta delavnica za sveče.",
    },
    molding_shop = {
        name = "Livarna",
        cost = { gold = 800, wood = 200, stone = 200 },
        upkeep = 20,
        productionBonus = 15,
        qualityBonus = 10,
        description = "Za formno litje sveč.",
    },
    wax_storehouse = {
        name = "Skladišče voska",
        cost = { gold = 500, wood = 150, stone = 100 },
        upkeep = 10,
        storageCapacity = 500,
        preservationBonus = 0.30,
        description = "Hladno skladišče za vosek.",
    },
    royal_chandlery = {
        name = "Kraljevska svečarna",
        cost = { gold = 2500, wood = 400, stone = 600 },
        upkeep = 50,
        productionBonus = 30,
        qualityBonus = 25,
        prestigeBonus = 10,
        description = "Največja svečarna za kraljeve potrebe.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Chandlery.waxStockpile = 0
Chandlery.candleStock = {}
Chandlery.productStock = {}
Chandlery.buildings = {}
Chandlery.chandler = nil
Chandlery.activeProduction = {}
Chandlery.totalCandlesMade = 0
Chandlery.totalProductsMade = 0
Chandlery.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Chandlery.init()
    Chandlery.waxStockpile = 50
    Chandlery.candleStock = {}
    Chandlery.productStock = {}
    Chandlery.buildings = {}
    Chandlery.chandler = nil
    Chandlery.activeProduction = {}
    Chandlery.totalCandlesMade = 0
    Chandlery.totalProductsMade = 0
    Chandlery.dayTimer = 0
    print("[Chandlery] Royal Chandlery & Wax Works System initialized (6 candles, 8 products, 4 buildings)")
end

-- ============================================================
-- CHANDLER NPC
-- ============================================================
function Chandlery.hireChandler(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 300 + skill * 6
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Chandlery.chandler = {
        name = name or ("Svečar " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        itemsCrafted = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Svečar najet: %s (spretnost: %d)", Chandlery.chandler.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Chandlery.canBuild(buildingId)
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

function Chandlery.build(buildingId)
    local ok, err = Chandlery.canBuild(buildingId)
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
    table.insert(Chandlery.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Chandlery.getProductionBonus()
    local bonus = 0
    for _, b in ipairs(Chandlery.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.productionBonus then bonus = bonus + def.productionBonus end
    end
    return bonus
end

function Chandlery.getQualityBonus()
    local bonus = 0
    for _, b in ipairs(Chandlery.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.qualityBonus then bonus = bonus + def.qualityBonus end
    end
    return bonus
end

-- ============================================================
-- WAX MANAGEMENT
-- ============================================================
function Chandlery.addWax(amount)
    Chandlery.waxStockpile = Chandlery.waxStockpile + amount
end

function Chandlery.purchaseWax(amount)
    local cost = amount * 5
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Chandlery.addWax(amount)
    return true
end

-- ============================================================
-- CANDLE MAKING
-- ============================================================
function Chandlery.canMakeCandle(candleType, quantity)
    local def = CANDLES[candleType]
    if not def then return false, "Neznana sveča" end
    quantity = quantity or 1
    if Chandlery.waxStockpile < def.waxCost * quantity then
        return false, "Premalo voska"
    end
    if #Chandlery.buildings == 0 then
        return false, "Potrebna svečarna"
    end
    if not Chandlery.chandler then
        return false, "Potreben svečar"
    end
    return true
end

function Chandlery.makeCandle(candleType, quantity)
    quantity = quantity or 1
    local ok, err = Chandlery.canMakeCandle(candleType, quantity)
    if not ok then return false, err end
    local def = CANDLES[candleType]
    Chandlery.waxStockpile = Chandlery.waxStockpile - (def.waxCost * quantity)
    local productionTime = math.max(1, quantity - math.floor(Chandlery.getProductionBonus() / 5))
    local production = {
        id = "candle_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = "candle",
        candleType = candleType,
        candleName = def.name,
        quantity = quantity,
        daysRemaining = productionTime,
        started = os.time(),
    }
    table.insert(Chandlery.activeProduction, production)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Sveče v izdelavi: %d %s (%d dni)", quantity, def.name, productionTime), "info")
    end
    return true
end

-- ============================================================
-- PRODUCT MAKING
-- ============================================================
function Chandlery.canMakeProduct(productId, quantity)
    local def = PRODUCTS[productId]
    if not def then return false, "Neznan produkt" end
    quantity = quantity or 1
    if Chandlery.waxStockpile < def.waxCost * quantity then
        return false, "Premalo voska"
    end
    if #Chandlery.buildings == 0 then
        return false, "Potrebna svečarna"
    end
    if not Chandlery.chandler then
        return false, "Potreben svečar"
    end
    return true
end

function Chandlery.makeProduct(productId, quantity)
    quantity = quantity or 1
    local ok, err = Chandlery.canMakeProduct(productId, quantity)
    if not ok then return false, err end
    local def = PRODUCTS[productId]
    Chandlery.waxStockpile = Chandlery.waxStockpile - (def.waxCost * quantity)
    local productionTime = math.max(1, def.productionTime * quantity - math.floor(Chandlery.getProductionBonus() / 10))
    local production = {
        id = "product_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = "product",
        productId = productId,
        productName = def.name,
        quantity = quantity,
        daysRemaining = productionTime,
        started = os.time(),
    }
    table.insert(Chandlery.activeProduction, production)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Produkt v izdelavi: %d %s (%d dni)", quantity, def.name, productionTime), "info")
    end
    return true
end

-- ============================================================
-- COMPLETE PRODUCTION
-- ============================================================
function Chandlery.completeProduction(production)
    local quality = 1.0 + (Chandlery.getQualityBonus() / 100)
    if Chandlery.chandler then
        quality = quality + (Chandlery.chandler.skill / 200)
    end
    quality = math.min(1.8, quality)
    if production.type == "candle" then
        local def = CANDLES[production.candleType]
        Chandlery.candleStock[production.candleType] = (Chandlery.candleStock[production.candleType] or 0) + production.quantity
        Chandlery.totalCandlesMade = Chandlery.totalCandlesMade + production.quantity
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Sveče izdelane: %d %s", production.quantity, def.name), "success")
        end
    else
        local def = PRODUCTS[production.productId]
        Chandlery.productStock[production.productId] = (Chandlery.productStock[production.productId] or 0) + production.quantity
        Chandlery.totalProductsMade = Chandlery.totalProductsMade + production.quantity
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Produkt izdelan: %d %s", production.quantity, def.name), "success")
        end
    end
    if Chandlery.chandler then
        Chandlery.chandler.itemsCrafted = Chandlery.chandler.itemsCrafted + production.quantity
        if math.random() < 0.15 then
            Chandlery.chandler.skill = math.min(100, Chandlery.chandler.skill + 1)
        end
    end
end

-- ============================================================
-- USE CANDLES
-- ============================================================
function Chandlery.useCandle(candleType, quantity)
    quantity = quantity or 1
    if (Chandlery.candleStock[candleType] or 0) < quantity then
        return false, "Ni dovolj sveč"
    end
    Chandlery.candleStock[candleType] = Chandlery.candleStock[candleType] - quantity
    local def = CANDLES[candleType]
    if def.happinessBonus and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + def.happinessBonus * quantity)
    end
    if def.faithBonus and _G.Religion then
        pcall(_G.Religion.addFaith, def.faithBonus * quantity)
    end
    if def.prestigeBonus and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + def.prestigeBonus)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Sveče uporabljene: %d %s", quantity, def.name), "info")
    end
    return true
end

-- ============================================================
-- SELL PRODUCTS
-- ============================================================
function Chandlery.sellProduct(productId, quantity)
    if (Chandlery.productStock[productId] or 0) < quantity then
        return false, "Ni dovolj na zalogi"
    end
    local def = PRODUCTS[productId]
    if not def then return false, "Neznan produkt" end
    Chandlery.productStock[productId] = Chandlery.productStock[productId] - quantity
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

-- ============================================================
-- UPDATE
-- ============================================================
function Chandlery.update(dt)
    if not _G.state then return end
    Chandlery.dayTimer = Chandlery.dayTimer + dt
    if Chandlery.dayTimer >= 30 then
        Chandlery.dayTimer = 0
        -- Process production
        for i = #Chandlery.activeProduction, 1, -1 do
            local p = Chandlery.activeProduction[i]
            p.daysRemaining = p.daysRemaining - 1
            if p.daysRemaining <= 0 then
                Chandlery.completeProduction(p)
                table.remove(Chandlery.activeProduction, i)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Chandlery.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Chandlery.chandler then totalUpkeep = totalUpkeep + 12 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Chandlery.getCandleInfo(candleId) return CANDLES[candleId] end
function Chandlery.getProductInfo(productId) return PRODUCTS[productId] end
function Chandlery.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Chandlery.getStats()
    return {
        waxStockpile = Chandlery.waxStockpile,
        candleStock = Chandlery.candleStock,
        productStock = Chandlery.productStock,
        numBuildings = #Chandlery.buildings,
        hasChandler = Chandlery.chandler ~= nil,
        chandlerName = Chandlery.chandler and Chandlery.chandler.name or "—",
        chandlerSkill = Chandlery.chandler and Chandlery.chandler.skill or 0,
        activeProduction = #Chandlery.activeProduction,
        totalCandlesMade = Chandlery.totalCandlesMade,
        totalProductsMade = Chandlery.totalProductsMade,
    }
end

return Chandlery
