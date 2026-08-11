-- objects/Economy/RoyalPotterCeramicsSystem.lua
-- Castle Kingdoms 2027 v3.5.8 - Royal Potter & Ceramics System
--
-- Manages pottery production, ceramic arts, and clay works.
-- Pottery provides storage, dining ware, and decorative items.
--
-- Features:
-- - 6 pottery types (earthenware, stoneware, porcelain, terracotta, faience, majolica)
-- - 8 ceramic products (bowls, plates, jugs, vases, tiles, figures, urns, planters)
-- - 4 pottery buildings (kiln, workshop, glazing shop, royal pottery)
-- - Potter NPC (skill affects quality)
-- - Clay supply management
-- - Firing process (time-based with risk)
-- - Glazing and decoration
-- - Ceramic art collection

local Potter = {}

-- ============================================================
-- POTTERY TYPES
-- ============================================================
local POTTERY = {
    earthenware = {
        name = "Lončarina",
        nameEn = "Earthenware",
        clayCost = 2,
        cost = 10,
        firingTime = 2,
        firingTemp = 1000,
        qualityBonus = 3,
        description = "Preprosta glinena posoda.",
    },
    stoneware = {
        name = "Kamnina",
        nameEn = "Stoneware",
        clayCost = 3,
        cost = 25,
        firingTime = 3,
        firingTemp = 1200,
        qualityBonus = 8,
        description = "Trdna in neprepustna keramika.",
    },
    porcelain = {
        name = "Porcelan",
        nameEn = "Porcelain",
        clayCost = 4,
        cost = 80,
        firingTime = 5,
        firingTemp = 1400,
        qualityBonus = 20,
        prestigeBonus = 10,
        description = "Najfinja in najdražja keramika.",
    },
    terracotta = {
        name = "Terrakota",
        nameEn = "Terracotta",
        clayCost = 3,
        cost = 15,
        firingTime = 2,
        firingTemp = 900,
        qualityBonus = 5,
        description = "Glinene figure in arhitektura.",
    },
    faience = {
        name = "Fajansa",
        nameEn = "Faience",
        clayCost = 3,
        cost = 40,
        firingTime = 4,
        firingTemp = 1100,
        qualityBonus = 12,
        glazeBonus = 15,
        description = "Glazirana keramika z barvami.",
    },
    majolica = {
        name = "Majolika",
        nameEn = "Majolica",
        clayCost = 4,
        cost = 60,
        firingTime = 4,
        firingTemp = 1050,
        qualityBonus = 15,
        glazeBonus = 20,
        prestigeBonus = 5,
        description = "Bogato okrašena glazirana keramika.",
    },
}

-- ============================================================
-- CERAMIC PRODUCTS
-- ============================================================
local PRODUCTS = {
    bowl = { name = "Skleda", potteryType = "earthenware", cost = 5, description = "Preprosta skleda." },
    plate = { name = "Krožnik", potteryType = "earthenware", cost = 8, description = "Za obroke." },
    jug = { name = "Vrč", potteryType = "stoneware", cost = 20, description = "Za shranjevanje tekočin." },
    vase = { name = "Vaza", potteryType = "porcelain", cost = 100, prestigeBonus = 5, description = "Okrasna vaza." },
    tile = { name = "Ploščica", potteryType = "faience", cost = 15, description = "Za talne in stenske obloge." },
    figure = { name = "Figura", potteryType = "terracotta", cost = 50, prestigeBonus = 8, description = "Kip iz terakote." },
    urn = { name = "Urna", potteryType = "stoneware", cost = 80, faithBonus = 10, description = "Za shranjevanje pepela." },
    planter = { name = "Lonček", potteryType = "terracotta", cost = 12, description = "Za sajenje rastlin." },
}

-- ============================================================
-- POTTERY BUILDINGS
-- ============================================================
local BUILDINGS = {
    kiln = {
        name = "Peč",
        cost = { gold = 300, wood = 100, stone = 200 },
        upkeep = 10,
        firingCapacity = 10,
        description = "Glinena peč za žganje keramike.",
    },
    workshop = {
        name = "Lončarska delavnica",
        cost = { gold = 500, wood = 200, stone = 100 },
        upkeep = 15,
        productionBonus = 10,
        qualityBonus = 5,
        description = "Delavnica za oblikovanje gline.",
    },
    glazing_shop = {
        name = "Glazirna delavnica",
        cost = { gold = 1200, wood = 200, stone = 300, iron = 50 },
        upkeep = 30,
        glazeBonus = 25,
        qualityBonus = 15,
        description = "Za glaziranje in barvanje keramike.",
    },
    royal_pottery = {
        name = "Kraljevska lončarija",
        cost = { gold = 3000, wood = 400, stone = 800 },
        upkeep = 60,
        productionBonus = 30,
        qualityBonus = 30,
        prestigeBonus = 15,
        description = "Največja lončarija za kraljeve potrebe.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Potter.clayStockpile = 0
Potter.productStock = {}
Potter.buildings = {}
Potter.potter = nil
Potter.activeFiring = {}
Potter.ceramicCollection = {}
Potter.totalPiecesMade = 0
Potter.totalFiringsFailed = 0
Potter.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Potter.init()
    Potter.clayStockpile = 30
    Potter.productStock = {}
    Potter.buildings = {}
    Potter.potter = nil
    Potter.activeFiring = {}
    Potter.ceramicCollection = {}
    Potter.totalPiecesMade = 0
    Potter.totalFiringsFailed = 0
    Potter.dayTimer = 0
    print("[Potter] Royal Potter & Ceramics System initialized (6 pottery types, 8 products, 4 buildings)")
end

-- ============================================================
-- POTTER NPC
-- ============================================================
function Potter.hirePotter(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 300 + skill * 6
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Potter.potter = {
        name = name or ("Lončar " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        piecesMade = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Lončar najet: %s (spretnost: %d)", Potter.potter.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Potter.canBuild(buildingId)
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

function Potter.build(buildingId)
    local ok, err = Potter.canBuild(buildingId)
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
    table.insert(Potter.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Potter.getProductionBonus()
    local bonus = 0
    for _, b in ipairs(Potter.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.productionBonus then bonus = bonus + def.productionBonus end
    end
    return bonus
end

function Potter.getQualityBonus()
    local bonus = 0
    for _, b in ipairs(Potter.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.qualityBonus then bonus = bonus + def.qualityBonus end
    end
    return bonus
end

function Potter.getGlazeBonus()
    local bonus = 0
    for _, b in ipairs(Potter.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.glazeBonus then bonus = bonus + def.glazeBonus end
    end
    return bonus
end

function Potter.hasKiln()
    for _, b in ipairs(Potter.buildings) do
        if b.type == "kiln" or b.type == "royal_pottery" then return true end
    end
    return false
end

-- ============================================================
-- CLAY MANAGEMENT
-- ============================================================
function Potter.addClay(amount)
    Potter.clayStockpile = Potter.clayStockpile + amount
end

function Potter.purchaseClay(amount)
    local cost = amount * 3
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Potter.addClay(amount)
    return true
end

-- ============================================================
-- POTTERY MAKING
-- ============================================================
function Potter.canMake(potteryType, quantity)
    local def = POTTERY[potteryType]
    if not def then return false, "Neznana keramika" end
    quantity = quantity or 1
    if Potter.clayStockpile < def.clayCost * quantity then
        return false, "Premalo gline"
    end
    if not Potter.hasKiln() then return false, "Potrebna peč" end
    if not Potter.potter then return false, "Potreben lončar" end
    return true
end

function Potter.make(potteryType, quantity)
    quantity = quantity or 1
    local ok, err = Potter.canMake(potteryType, quantity)
    if not ok then return false, err end
    local def = POTTERY[potteryType]
    Potter.clayStockpile = Potter.clayStockpile - (def.clayCost * quantity)
    local firingTime = def.firingTime
    local bonus = Potter.getProductionBonus()
    if Potter.potter then
        bonus = bonus + math.floor(Potter.potter.skill / 5)
    end
    firingTime = math.max(1, firingTime - math.floor(bonus / 10))
    local firing = {
        id = "firing_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        potteryType = potteryType,
        potteryName = def.name,
        quantity = quantity,
        daysRemaining = firingTime,
        firingTemp = def.firingTemp,
        started = os.time(),
    }
    table.insert(Potter.activeFiring, firing)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Žganje začeto: %d %s (%d dni)", quantity, def.name, firingTime), "info")
    end
    return true
end

function Potter.completeFiring(firing)
    -- Calculate quality
    local quality = 1.0 + (Potter.getQualityBonus() / 100)
    if Potter.potter then
        quality = quality + (Potter.potter.skill / 200)
    end
    quality = math.min(1.8, quality)
    -- Failure chance (10% base, reduced by skill)
    local failChance = 0.10
    if Potter.potter then
        failChance = failChance - (Potter.potter.skill / 500)
    end
    failChance = math.max(0.02, failChance)
    if math.random() < failChance then
        -- Firing failed!
        Potter.totalFiringsFailed = Potter.totalFiringsFailed + 1
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Žganje spodletelo: %s — razpoke!", firing.potteryName), "danger")
        end
        return
    end
    -- Success
    Potter.productStock[firing.potteryType] = (Potter.productStock[firing.potteryType] or 0) + firing.quantity
    Potter.totalPiecesMade = Potter.totalPiecesMade + firing.quantity
    if Potter.potter then
        Potter.potter.piecesMade = Potter.potter.piecesMade + firing.quantity
        if math.random() < 0.15 then
            Potter.potter.skill = math.min(100, Potter.potter.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Keramika žgana: %d %s (kakovost: %.1f)", firing.quantity, firing.potteryName, quality), "success")
    end
end

-- ============================================================
-- SELL AND USE
-- ============================================================
function Potter.sell(potteryType, quantity)
    if (Potter.productStock[potteryType] or 0) < quantity then
        return false, "Ni dovolj na zalogi"
    end
    local def = POTTERY[potteryType]
    Potter.productStock[potteryType] = Potter.productStock[potteryType] - quantity
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

function Potter.useAsDecor(potteryType, quantity)
    if (Potter.productStock[potteryType] or 0) < quantity then
        return false, "Ni dovolj na zalogi"
    end
    Potter.productStock[potteryType] = Potter.productStock[potteryType] - quantity
    local def = POTTERY[potteryType]
    if def.prestigeBonus and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + def.prestigeBonus * quantity)
    end
    table.insert(Potter.ceramicCollection, {
        type = potteryType,
        name = def.name,
        addedDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Keramika dodana v zbirko: %d %s", quantity, def.name), "info")
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Potter.update(dt)
    if not _G.state then return end
    Potter.dayTimer = Potter.dayTimer + dt
    if Potter.dayTimer >= 30 then
        Potter.dayTimer = 0
        for i = #Potter.activeFiring, 1, -1 do
            local f = Potter.activeFiring[i]
            f.daysRemaining = f.daysRemaining - 1
            if f.daysRemaining <= 0 then
                Potter.completeFiring(f)
                table.remove(Potter.activeFiring, i)
            end
        end
        local totalUpkeep = 0
        for _, b in ipairs(Potter.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Potter.potter then totalUpkeep = totalUpkeep + 15 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Potter.getPotteryInfo(id) return POTTERY[id] end
function Potter.getProductInfo(id) return PRODUCTS[id] end
function Potter.getBuildingInfo(id) return BUILDINGS[id] end

function Potter.getStats()
    return {
        clayStockpile = Potter.clayStockpile,
        productStock = Potter.productStock,
        numBuildings = #Potter.buildings,
        hasPotter = Potter.potter ~= nil,
        potterName = Potter.potter and Potter.potter.name or "—",
        potterSkill = Potter.potter and Potter.potter.skill or 0,
        activeFiring = #Potter.activeFiring,
        totalPiecesMade = Potter.totalPiecesMade,
        totalFiringsFailed = Potter.totalFiringsFailed,
        collectionSize = #Potter.ceramicCollection,
    }
end

return Potter
