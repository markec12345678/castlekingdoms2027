-- objects/Economy/RoyalWeaverTextileSystem.lua
-- Castle Kingdoms 2027 v3.5.9 - Royal Weaver & Textile System
--
-- Manages textile production, weaving, tapestries, and fabric goods.
-- Provides clothing, decorations, and trade goods.
--
-- Features:
-- - 6 fabric types (linen, wool, silk, cotton, velvet, brocade)
-- - 8 textile products (cloth, clothing, tapestry, banner, rug, curtain, ...
-- - 4 textile buildings (weaving workshop, dye house, fulling mill, royal loom)
-- - Weaver NPC (skill affects quality)
-- - Raw material management (flax, wool, silk)
-- - Dyeing system (colors and patterns)
-- - Tapestry creation (time-based art)
-- - Textile trade

local Weaver = {}

-- ============================================================
-- FABRIC TYPES
-- ============================================================
local FABRICS = {
    linen = {
        name = "Lan",
        nameEn = "Linen",
        materialCost = 3,
        cost = 15,
        weaveTime = 5,
        qualityBonus = 3,
        description = "Lanena tkanina iz lanu.",
    },
    wool = {
        name = "Volna",
        nameEn = "Wool",
        materialCost = 2,
        cost = 12,
        weaveTime = 4,
        qualityBonus = 4,
        description = "Topla volnena tkanina.",
    },
    silk = {
        name = "Svila",
        nameEn = "Silk",
        materialCost = 5,
        cost = 80,
        weaveTime = 10,
        qualityBonus = 15,
        prestigeBonus = 8,
        description = "Luksuzna svilena tkanina.",
    },
    cotton = {
        name = "Bombaž",
        nameEn = "Cotton",
        materialCost = 3,
        cost = 20,
        weaveTime = 6,
        qualityBonus = 5,
        description = "Mehka bombažna tkanina.",
    },
    velvet = {
        name = "Žamet",
        nameEn = "Velvet",
        materialCost = 6,
        cost = 120,
        weaveTime = 12,
        qualityBonus = 18,
        prestigeBonus = 12,
        description = "Mehki žamet za plemstvo.",
    },
    brocade = {
        name = "Brokat",
        nameEn = "Brocade",
        materialCost = 8,
        cost = 200,
        weaveTime = 20,
        qualityBonus = 25,
        prestigeBonus = 20,
        description = "Bogato vezani brokat za kralje.",
    },
}

-- ============================================================
-- TEXTILE PRODUCTS
-- ============================================================
local PRODUCTS = {
    cloth = { name = "Tkanina", fabricType = "linen", cost = 10, description = "Osnovna tkanina." },
    clothing = { name = "Obleka", fabricType = "wool", cost = 50, happinessBonus = 5, description = "Oblačila za dvor." },
    tapestry = { name = "Tapiserija", fabricType = "brocade", cost = 500, prestigeBonus = 25, weaveTime = 30, description = "Velika umetniška tapiserija." },
    banner = { name = "Zastava", fabricType = "silk", cost = 100, prestigeBonus = 10, description = "Družinska zastava." },
    rug = { name = "Preproga", fabricType = "wool", cost = 80, happinessBonus = 3, description = "Tkana preproga." },
    curtain = { name = "Zavesa", fabricType = "velvet", cost = 150, happinessBonus = 4, description = "Težke žametne zavese." },
    altar_cloth = { name = "Oltarno pregrinjalo", fabricType = "silk", cost = 200, faithBonus = 15, description = "Za cerkvene oltarje." },
    shroud = { name = "Prijem", fabricType = "linen", cost = 30, faithBonus = 5, description = "Za pokope." },
}

-- ============================================================
-- TEXTILE BUILDINGS
-- ============================================================
local BUILDINGS = {
    weaving_workshop = {
        name = "Tkalna delavnica",
        cost = { gold = 300, wood = 200 },
        upkeep = 10,
        productionBonus = 5,
        description = "Delavnica s statvami.",
    },
    dye_house = {
        name = "Barvarska hiša",
        cost = { gold = 800, wood = 200, stone = 200 },
        upkeep = 20,
        dyeBonus = 20,
        qualityBonus = 10,
        description = "Za barvanje tkanin.",
    },
    fulling_mill = {
        name = "Valilnica",
        cost = { gold = 1200, wood = 300, stone = 300 },
        upkeep = 30,
        productionBonus = 15,
        qualityBonus = 15,
        description = "Za obdelavo volne.",
    },
    royal_loom = {
        name = "Kraljevska statva",
        cost = { gold = 3000, wood = 400, stone = 500, iron = 100 },
        upkeep = 60,
        productionBonus = 30,
        qualityBonus = 30,
        prestigeBonus = 15,
        description = "Velika statva za kraljeve tapiserije.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Weaver.materialStockpile = 0
Weaver.fabricStock = {}
Weaver.productStock = {}
Weaver.buildings = {}
Weaver.weaver = nil
Weaver.activeWeaving = {}
Weaver.totalFabricsWoven = 0
Weaver.totalProductsMade = 0
Weaver.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Weaver.init()
    Weaver.materialStockpile = 20
    Weaver.fabricStock = {}
    Weaver.productStock = {}
    Weaver.buildings = {}
    Weaver.weaver = nil
    Weaver.activeWeaving = {}
    Weaver.totalFabricsWoven = 0
    Weaver.totalProductsMade = 0
    Weaver.dayTimer = 0
    print("[Weaver] Royal Weaver & Textile System initialized (6 fabrics, 8 products, 4 buildings)")
end

-- ============================================================
-- WEAVER NPC
-- ============================================================
function Weaver.hireWeaver(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 300 + skill * 6
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Weaver.weaver = {
        name = name or ("Tkalček " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        itemsWoven = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Tkalček najet: %s (spretnost: %d)", Weaver.weaver.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Weaver.canBuild(buildingId)
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

function Weaver.build(buildingId)
    local ok, err = Weaver.canBuild(buildingId)
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
    table.insert(Weaver.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Weaver.getProductionBonus()
    local bonus = 0
    for _, b in ipairs(Weaver.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.productionBonus then bonus = bonus + def.productionBonus end
    end
    return bonus
end

function Weaver.getQualityBonus()
    local bonus = 0
    for _, b in ipairs(Weaver.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.qualityBonus then bonus = bonus + def.qualityBonus end
    end
    return bonus
end

-- ============================================================
-- MATERIAL MANAGEMENT
-- ============================================================
function Weaver.addMaterial(amount)
    Weaver.materialStockpile = Weaver.materialStockpile + amount
end

function Weaver.purchaseMaterial(amount)
    local cost = amount * 4
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Weaver.addMaterial(amount)
    return true
end

-- ============================================================
-- WEAVING FABRIC
-- ============================================================
function Weaver.canWeave(fabricType, quantity)
    local def = FABRICS[fabricType]
    if not def then return false, "Neznana tkanina" end
    quantity = quantity or 1
    if Weaver.materialStockpile < def.materialCost * quantity then
        return false, "Premalo materiala"
    end
    if #Weaver.buildings == 0 then return false, "Potrebna tkalna delavnica" end
    if not Weaver.weaver then return false, "Potreben tkalček" end
    return true
end

function Weaver.weave(fabricType, quantity)
    quantity = quantity or 1
    local ok, err = Weaver.canWeave(fabricType, quantity)
    if not ok then return false, err end
    local def = FABRICS[fabricType]
    Weaver.materialStockpile = Weaver.materialStockpile - (def.materialCost * quantity)
    local weaveTime = def.weaveTime
    local bonus = Weaver.getProductionBonus()
    if Weaver.weaver then
        bonus = bonus + math.floor(Weaver.weaver.skill / 5)
    end
    weaveTime = math.max(1, weaveTime - math.floor(bonus / 10))
    local weaving = {
        id = "weave_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        fabricType = fabricType,
        fabricName = def.name,
        quantity = quantity,
        daysRemaining = weaveTime,
        started = os.time(),
    }
    table.insert(Weaver.activeWeaving, weaving)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Tkanje začeto: %d %s (%d dni)", quantity, def.name, weaveTime), "info")
    end
    return true
end

function Weaver.completeWeaving(weaving)
    local quality = 1.0 + (Weaver.getQualityBonus() / 100)
    if Weaver.weaver then
        quality = quality + (Weaver.weaver.skill / 200)
    end
    quality = math.min(1.8, quality)
    Weaver.fabricStock[weaving.fabricType] = (Weaver.fabricStock[weaving.fabricType] or 0) + weaving.quantity
    Weaver.totalFabricsWoven = Weaver.totalFabricsWoven + weaving.quantity
    if Weaver.weaver then
        Weaver.weaver.itemsWoven = Weaver.weaver.itemsWoven + weaving.quantity
        if math.random() < 0.15 then
            Weaver.weaver.skill = math.min(100, Weaver.weaver.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Tkanina izdelana: %d %s (kakovost: %.1f)", weaving.quantity, weaving.fabricName, quality), "success")
    end
end

-- ============================================================
-- MAKING PRODUCTS
-- ============================================================
function Weaver.canMakeProduct(productId, quantity)
    local def = PRODUCTS[productId]
    if not def then return false, "Neznan produkt" end
    quantity = quantity or 1
    if (Weaver.fabricStock[def.fabricType] or 0) < quantity then
        return false, "Premalo " .. (FABRICS[def.fabricType] and FABRICS[def.fabricType].name or "tkanine")
    end
    if not Weaver.weaver then return false, "Potreben tkalček" end
    return true
end

function Weaver.makeProduct(productId, quantity)
    quantity = quantity or 1
    local ok, err = Weaver.canMakeProduct(productId, quantity)
    if not ok then return false, err end
    local def = PRODUCTS[productId]
    local fabDef = FABRICS[def.fabricType]
    Weaver.fabricStock[def.fabricType] = Weaver.fabricStock[def.fabricType] - quantity
    local makeTime = def.weaveTime or fabDef.weaveTime / 2
    local bonus = Weaver.getProductionBonus()
    if Weaver.weaver then
        bonus = bonus + math.floor(Weaver.weaver.skill / 5)
    end
    makeTime = math.max(1, makeTime - math.floor(bonus / 10))
    local making = {
        id = "product_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        productId = productId,
        productName = def.name,
        fabricType = def.fabricType,
        quantity = quantity,
        daysRemaining = makeTime,
        happinessBonus = def.happinessBonus or 0,
        prestigeBonus = def.prestigeBonus or 0,
        faithBonus = def.faithBonus or 0,
        started = os.time(),
    }
    table.insert(Weaver.activeWeaving, making)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Izdelava: %d %s (%d dni)", quantity, def.name, makeTime), "info")
    end
    return true
end

function Weaver.completeProduct(making)
    local quality = 1.0 + (Weaver.getQualityBonus() / 100)
    if Weaver.weaver then
        quality = quality + (Weaver.weaver.skill / 200)
    end
    quality = math.min(1.8, quality)
    Weaver.productStock[making.productId] = (Weaver.productStock[making.productId] or 0) + making.quantity
    Weaver.totalProductsMade = Weaver.totalProductsMade + making.quantity
    if Weaver.weaver then
        Weaver.weaver.itemsWoven = Weaver.weaver.itemsWoven + making.quantity
        if math.random() < 0.15 then
            Weaver.weaver.skill = math.min(100, Weaver.weaver.skill + 1)
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
function Weaver.sellProduct(productId, quantity)
    if (Weaver.productStock[productId] or 0) < quantity then
        return false, "Ni dovolj na zalogi"
    end
    local def = PRODUCTS[productId]
    Weaver.productStock[productId] = Weaver.productStock[productId] - quantity
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

function Weaver.useProduct(productId, quantity)
    if (Weaver.productStock[productId] or 0) < quantity then
        return false, "Ni dovolj na zalogi"
    end
    Weaver.productStock[productId] = Weaver.productStock[productId] - quantity
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
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Uporabljeno: %d %s", quantity, def.name), "info")
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Weaver.update(dt)
    if not _G.state then return end
    Weaver.dayTimer = Weaver.dayTimer + dt
    if Weaver.dayTimer >= 30 then
        Weaver.dayTimer = 0
        for i = #Weaver.activeWeaving, 1, -1 do
            local w = Weaver.activeWeaving[i]
            w.daysRemaining = w.daysRemaining - 1
            if w.daysRemaining <= 0 then
                if w.productId then
                    Weaver.completeProduct(w)
                else
                    Weaver.completeWeaving(w)
                end
                table.remove(Weaver.activeWeaving, i)
            end
        end
        local totalUpkeep = 0
        for _, b in ipairs(Weaver.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Weaver.weaver then totalUpkeep = totalUpkeep + 15 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Weaver.getFabricInfo(id) return FABRICS[id] end
function Weaver.getProductInfo(id) return PRODUCTS[id] end
function Weaver.getBuildingInfo(id) return BUILDINGS[id] end

function Weaver.getStats()
    return {
        materialStockpile = Weaver.materialStockpile,
        fabricStock = Weaver.fabricStock,
        productStock = Weaver.productStock,
        numBuildings = #Weaver.buildings,
        hasWeaver = Weaver.weaver ~= nil,
        weaverName = Weaver.weaver and Weaver.weaver.name or "—",
        weaverSkill = Weaver.weaver and Weaver.weaver.skill or 0,
        activeWeaving = #Weaver.activeWeaving,
        totalFabricsWoven = Weaver.totalFabricsWoven,
        totalProductsMade = Weaver.totalProductsMade,
    }
end

return Weaver
