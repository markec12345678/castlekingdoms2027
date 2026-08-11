-- objects/Economy/RoyalGlassmakerStainedGlassSystem.lua
-- Castle Kingdoms 2027 v3.6.0 - Royal Glassmaker & Stained Glass System
--
-- Manages glass production, stained glass windows, and glass art.
-- Glass provides windows, vessels, and decorative art.
--
-- Features:
-- - 6 glass types (crown glass, cylinder glass, lead glass, colored, crystal, mirrored)
-- - 8 glass products (windows, vessels, beads, lenses, mirrors, stained glass, ...
-- - 4 glassmaking buildings (furnace, workshop, glazier shop, royal glasshouse)
-- - Glassmaker NPC (skill affects quality)
-- - Sand and flux supply management
-- - Stained glass window creation (time-based art)
-- - Glassblowing (skilled production)
-- - Glass art collection

local Glassmaker = {}

-- ============================================================
-- GLASS TYPES
-- ============================================================
local GLASS_TYPES = {
    crown = {
        name = "Kronska stekla",
        nameEn = "Crown Glass",
        sandCost = 3,
        cost = 20,
        meltTime = 4,
        qualityBonus = 5,
        description = "Vrteno okensko steklo.",
    },
    cylinder = {
        name = "Valjasto steklo",
        nameEn = "Cylinder Glass",
        sandCost = 4,
        cost = 25,
        meltTime = 5,
        qualityBonus = 8,
        description = "Pihano valjasto steklo za okna.",
    },
    lead = {
        name = "Svinčeno steklo",
        nameEn = "Lead Glass",
        sandCost = 5,
        cost = 50,
        meltTime = 6,
        qualityBonus = 15,
        prestigeBonus = 5,
        description = "Kristalno steklo s svincom.",
    },
    colored = {
        name = "Barvno steklo",
        nameEn = "Colored Glass",
        sandCost = 4,
        cost = 40,
        meltTime = 5,
        qualityBonus = 10,
        description = "Barvano steklo za vitraje.",
    },
    crystal = {
        name = "Kristal",
        nameEn = "Crystal",
        sandCost = 6,
        cost = 100,
        meltTime = 8,
        qualityBonus = 25,
        prestigeBonus = 15,
        description = "Najčistejše prosojno steklo.",
    },
    mirrored = {
        name = "Zrcalno steklo",
        nameEn = "Mirrored Glass",
        sandCost = 5,
        cost = 80,
        meltTime = 7,
        qualityBonus = 20,
        prestigeBonus = 10,
        description = "Steklo s kovinsko prevleko za zrcala.",
    },
}

-- ============================================================
-- GLASS PRODUCTS
-- ============================================================
local PRODUCTS = {
    window = { name = "Okno", glassType = "crown", cost = 30, happinessBonus = 2, description = "Okensko steklo." },
    vessel = { name = "Vrč", glassType = "crystal", cost = 60, happinessBonus = 4, description = "Steklen vrč." },
    beads = { name = "Koralde", glassType = "colored", cost = 15, happinessBonus = 2, description = "Steklene koralde." },
    lens = { name = "Leča", glassType = "crystal", cost = 100, knowledgeBonus = 10, description = "Optična leča." },
    mirror = { name = "Zrcalo", glassType = "mirrored", cost = 120, happinessBonus = 8, prestigeBonus = 5, description = "Veliko zrcalo." },
    stained_glass = { name = "Vitraj", glassType = "colored", cost = 500, prestigeBonus = 30, faithBonus = 20, makeTime = 30, description = "Veliki vitraj za cerkev." },
    chandelier = { name = "Luster", glassType = "crystal", cost = 300, prestigeBonus = 20, happinessBonus = 10, makeTime = 20, description = "Kristalni luster." },
    goblet = { name = "Kelih", glassType = "crystal", cost = 80, faithBonus = 10, description = "Ceremonialni kelih." },
}

-- ============================================================
-- GLASSMAKING BUILDINGS
-- ============================================================
local BUILDINGS = {
    furnace = {
        name = "Steklarska peč",
        cost = { gold = 800, wood = 200, stone = 400 },
        upkeep = 25,
        meltCapacity = 10,
        description = "Visokotemperaturna peč za taljenje stekla.",
    },
    workshop = {
        name = "Steklarska delavnica",
        cost = { gold = 500, wood = 200, stone = 200 },
        upkeep = 15,
        productionBonus = 10,
        qualityBonus = 5,
        description = "Delavnica za obdelovo stekla.",
    },
    glazier_shop = {
        name = "Steklarjeva trgovina",
        cost = { gold = 1200, wood = 300, stone = 200, iron = 50 },
        upkeep = 30,
        productionBonus = 15,
        qualityBonus = 15,
        description = "Trgovina z obdelovalnim prostorom.",
    },
    royal_glasshouse = {
        name = "Kraljevska steklarna",
        cost = { gold = 5000, wood = 500, stone = 1200, iron = 200 },
        upkeep = 100,
        productionBonus = 35,
        qualityBonus = 35,
        prestigeBonus = 20,
        description = "Največja steklarna za kraljeve potrebe.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Glassmaker.sandStockpile = 0
Glassmaker.glassStock = {}
Glassmaker.productStock = {}
Glassmaker.buildings = {}
Glassmaker.glassmaker = nil
Glassmaker.activeMelting = {}
Glassmaker.glassCollection = {}
Glassmaker.totalGlassesMade = 0
Glassmaker.totalProductsMade = 0
Glassmaker.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Glassmaker.init()
    Glassmaker.sandStockpile = 20
    Glassmaker.glassStock = {}
    Glassmaker.productStock = {}
    Glassmaker.buildings = {}
    Glassmaker.glassmaker = nil
    Glassmaker.activeMelting = {}
    Glassmaker.glassCollection = {}
    Glassmaker.totalGlassesMade = 0
    Glassmaker.totalProductsMade = 0
    Glassmaker.dayTimer = 0
    print("[Glassmaker] Royal Glassmaker & Stained Glass System initialized (6 glass types, 8 products, 4 buildings)")
end

-- ============================================================
-- GLASSMAKER NPC
-- ============================================================
function Glassmaker.hireGlassmaker(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 400 + skill * 8
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Glassmaker.glassmaker = {
        name = name or ("Steklar " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        itemsMade = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Steklar najet: %s (spretnost: %d)", Glassmaker.glassmaker.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Glassmaker.canBuild(buildingId)
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

function Glassmaker.build(buildingId)
    local ok, err = Glassmaker.canBuild(buildingId)
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
    table.insert(Glassmaker.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Glassmaker.getProductionBonus()
    local bonus = 0
    for _, b in ipairs(Glassmaker.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.productionBonus then bonus = bonus + def.productionBonus end
    end
    return bonus
end

function Glassmaker.getQualityBonus()
    local bonus = 0
    for _, b in ipairs(Glassmaker.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.qualityBonus then bonus = bonus + def.qualityBonus end
    end
    return bonus
end

function Glassmaker.hasFurnace()
    for _, b in ipairs(Glassmaker.buildings) do
        if b.type == "furnace" or b.type == "royal_glasshouse" then return true end
    end
    return false
end

-- ============================================================
-- SAND MANAGEMENT
-- ============================================================
function Glassmaker.addSand(amount)
    Glassmaker.sandStockpile = Glassmaker.sandStockpile + amount
end

function Glassmaker.purchaseSand(amount)
    local cost = amount * 2
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Glassmaker.addSand(amount)
    return true
end

-- ============================================================
-- GLASS MELTING
-- ============================================================
function Glassmaker.canMelt(glassType, quantity)
    local def = GLASS_TYPES[glassType]
    if not def then return false, "Neznano steklo" end
    quantity = quantity or 1
    if Glassmaker.sandStockpile < def.sandCost * quantity then
        return false, "Premalo peska"
    end
    if not Glassmaker.hasFurnace() then return false, "Potrebna peč" end
    if not Glassmaker.glassmaker then return false, "Potreben steklar" end
    return true
end

function Glassmaker.melt(glassType, quantity)
    quantity = quantity or 1
    local ok, err = Glassmaker.canMelt(glassType, quantity)
    if not ok then return false, err end
    local def = GLASS_TYPES[glassType]
    Glassmaker.sandStockpile = Glassmaker.sandStockpile - (def.sandCost * quantity)
    local meltTime = def.meltTime
    local bonus = Glassmaker.getProductionBonus()
    if Glassmaker.glassmaker then
        bonus = bonus + math.floor(Glassmaker.glassmaker.skill / 5)
    end
    meltTime = math.max(1, meltTime - math.floor(bonus / 10))
    local melting = {
        id = "melt_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        glassType = glassType,
        glassName = def.name,
        quantity = quantity,
        daysRemaining = meltTime,
        started = os.time(),
    }
    table.insert(Glassmaker.activeMelting, melting)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Taljenje stekla: %d %s (%d dni)", quantity, def.name, meltTime), "info")
    end
    return true
end

function Glassmaker.completeMelting(melting)
    local quality = 1.0 + (Glassmaker.getQualityBonus() / 100)
    if Glassmaker.glassmaker then
        quality = quality + (Glassmaker.glassmaker.skill / 200)
    end
    quality = math.min(1.8, quality)
    -- 8% failure chance (glass cracking)
    local failChance = 0.08
    if Glassmaker.glassmaker then
        failChance = failChance - (Glassmaker.glassmaker.skill / 600)
    end
    failChance = math.max(0.02, failChance)
    if math.random() < failChance then
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Taljenje spodletelo: %s — razpoke!", melting.glassName), "danger")
        end
        return
    end
    Glassmaker.glassStock[melting.glassType] = (Glassmaker.glassStock[melting.glassType] or 0) + melting.quantity
    Glassmaker.totalGlassesMade = Glassmaker.totalGlassesMade + melting.quantity
    if Glassmaker.glassmaker then
        Glassmaker.glassmaker.itemsMade = Glassmaker.glassmaker.itemsMade + melting.quantity
        if math.random() < 0.15 then
            Glassmaker.glassmaker.skill = math.min(100, Glassmaker.glassmaker.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Steklo izdelano: %d %s (kakovost: %.1f)", melting.quantity, melting.glassName, quality), "success")
    end
end

-- ============================================================
-- PRODUCT MAKING
-- ============================================================
function Glassmaker.canMakeProduct(productId, quantity)
    local def = PRODUCTS[productId]
    if not def then return false, "Neznan produkt" end
    quantity = quantity or 1
    if (Glassmaker.glassStock[def.glassType] or 0) < quantity then
        return false, "Premalo stekla"
    end
    if not Glassmaker.glassmaker then return false, "Potreben steklar" end
    return true
end

function Glassmaker.makeProduct(productId, quantity)
    quantity = quantity or 1
    local ok, err = Glassmaker.canMakeProduct(productId, quantity)
    if not ok then return false, err end
    local def = PRODUCTS[productId]
    Glassmaker.glassStock[def.glassType] = Glassmaker.glassStock[def.glassType] - quantity
    local makeTime = def.makeTime or 3
    local bonus = Glassmaker.getProductionBonus()
    if Glassmaker.glassmaker then
        bonus = bonus + math.floor(Glassmaker.glassmaker.skill / 5)
    end
    makeTime = math.max(1, makeTime - math.floor(bonus / 10))
    local making = {
        id = "product_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        productId = productId,
        productName = def.name,
        quantity = quantity,
        daysRemaining = makeTime,
        happinessBonus = def.happinessBonus or 0,
        prestigeBonus = def.prestigeBonus or 0,
        faithBonus = def.faithBonus or 0,
        knowledgeBonus = def.knowledgeBonus or 0,
        started = os.time(),
    }
    table.insert(Glassmaker.activeMelting, making)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Izdelava: %d %s (%d dni)", quantity, def.name, makeTime), "info")
    end
    return true
end

function Glassmaker.completeProduct(making)
    Glassmaker.productStock[making.productId] = (Glassmaker.productStock[making.productId] or 0) + making.quantity
    Glassmaker.totalProductsMade = Glassmaker.totalProductsMade + making.quantity
    if Glassmaker.glassmaker then
        Glassmaker.glassmaker.itemsMade = Glassmaker.glassmaker.itemsMade + making.quantity
        if math.random() < 0.15 then
            Glassmaker.glassmaker.skill = math.min(100, Glassmaker.glassmaker.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Produkt izdelan: %d %s", making.quantity, making.productName), "success")
    end
end

-- ============================================================
-- SELL AND USE
-- ============================================================
function Glassmaker.sellProduct(productId, quantity)
    if (Glassmaker.productStock[productId] or 0) < quantity then
        return false, "Ni dovolj na zalogi"
    end
    local def = PRODUCTS[productId]
    Glassmaker.productStock[productId] = Glassmaker.productStock[productId] - quantity
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

function Glassmaker.useProduct(productId, quantity)
    if (Glassmaker.productStock[productId] or 0) < quantity then
        return false, "Ni dovolj na zalogi"
    end
    Glassmaker.productStock[productId] = Glassmaker.productStock[productId] - quantity
    local def = PRODUCTS[productId]
    if def.happinessBonus and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + def.happinessBonus * quantity)
    end
    if def.prestigeBonus and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + def.prestigeBonus)
    end
    if def.faithBonus and _G.Religion then
        pcall(_G.Religion.addFaith, def.faithBonus * quantity)
    end
    if def.knowledgeBonus and _G.Culture then
        pcall(function() _G.Culture.knowledgePoints = (_G.Culture.knowledgePoints or 0) + def.knowledgeBonus * quantity end)
    end
    table.insert(Glassmaker.glassCollection, {
        type = productId,
        name = def.name,
        addedDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Steklen produkt uporabljen: %d %s", quantity, def.name), "info")
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Glassmaker.update(dt)
    if not _G.state then return end
    Glassmaker.dayTimer = Glassmaker.dayTimer + dt
    if Glassmaker.dayTimer >= 30 then
        Glassmaker.dayTimer = 0
        for i = #Glassmaker.activeMelting, 1, -1 do
            local m = Glassmaker.activeMelting[i]
            m.daysRemaining = m.daysRemaining - 1
            if m.daysRemaining <= 0 then
                if m.productId then
                    Glassmaker.completeProduct(m)
                else
                    Glassmaker.completeMelting(m)
                end
                table.remove(Glassmaker.activeMelting, i)
            end
        end
        local totalUpkeep = 0
        for _, b in ipairs(Glassmaker.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Glassmaker.glassmaker then totalUpkeep = totalUpkeep + 20 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Glassmaker.getGlassInfo(id) return GLASS_TYPES[id] end
function Glassmaker.getProductInfo(id) return PRODUCTS[id] end
function Glassmaker.getBuildingInfo(id) return BUILDINGS[id] end

function Glassmaker.getStats()
    return {
        sandStockpile = Glassmaker.sandStockpile,
        glassStock = Glassmaker.glassStock,
        productStock = Glassmaker.productStock,
        numBuildings = #Glassmaker.buildings,
        hasGlassmaker = Glassmaker.glassmaker ~= nil,
        glassmakerName = Glassmaker.glassmaker and Glassmaker.glassmaker.name or "—",
        glassmakerSkill = Glassmaker.glassmaker and Glassmaker.glassmaker.skill or 0,
        activeProduction = #Glassmaker.activeMelting,
        totalGlassesMade = Glassmaker.totalGlassesMade,
        totalProductsMade = Glassmaker.totalProductsMade,
        collectionSize = #Glassmaker.glassCollection,
    }
end

return Glassmaker
