-- objects/Economy/RoyalMetalworkerBronzeCastingSystem.lua
-- Castle Kingdoms 2027 v3.7.0 - Royal Metalworker & Bronze Casting System
--
-- Manages bronze casting, metalworking, and bell making.
-- Bronze products provide bells, statues, and military equipment.
--
-- Features:
-- - 6 bronze products (bell, statue, cannon, medallion, chandelier, door)
-- - 8 metal types (copper, tin, bronze, brass, pewter, lead, iron, silver)
-- - 4 metalworking buildings (foundry, smithy, casting hall, royal foundry)
-- - Metalworker NPC (skill affects quality)
-- - Bronze casting (time-based with risk of defects)
-- - Metal alloy management
-- - Bell founding (with sound quality)
-- - Bronze art collection

local Metalworker = {}

local PRODUCTS = {
    bell = { name = "Zvon", metalCost = 20, time = 14, prestige = 15, happiness = 5, faith = 10, description = "Zvon za cerkev ali stolp." },
    statue = { name = "Bronasti kip", metalCost = 30, time = 30, prestige = 25, happiness = 8, description = "Bronasti kip vladarja ali svetnika." },
    cannon = { name = "Top", metalCost = 40, time = 20, militaryBonus = 30, description = "Bronasti top za vojsko." },
    medallion = { name = "Medalja", metalCost = 2, time = 3, prestige = 5, happiness = 2, description = "Spominska medalja." },
    chandelier = { name = "Bronasti luster", metalCost = 15, time = 14, prestige = 15, happiness = 8, description = "Veliki bronasti luster." },
    door = { name = "Bronasta vrata", metalCost = 25, time = 21, prestige = 20, faith = 10, description = "Bogato okrašena cerkvena vrata." },
}

local METALS = {
    copper = { name = "Baker", cost = 20, qualityBonus = 5, description = "Rdečkasta kovina." },
    tin = { name = "Kositer", cost = 30, qualityBonus = 8, description = "Mehka srebrnkasta kovina." },
    bronze = { name = "Bron", cost = 50, qualityBonus = 15, prestige = 5, description = "Zlitina bakra in kositra." },
    brass = { name = "Rumeni bakra", cost = 40, qualityBonus = 12, description = "Zlitina bakra in cinka." },
    pewter = { name = "Pewter", cost = 25, qualityBonus = 8, description = "Zlitina kositra in svinca." },
    lead = { name = "Svinec", cost = 10, qualityBonus = 3, description = "Težka mehka kovina." },
    iron = { name = "Železo", cost = 15, qualityBonus = 7, description = "Pogosta in trdna kovina." },
    silver = { name = "Srebro", cost = 100, qualityBonus = 25, prestige = 10, description = "Plemenita srebrnkasta kovina." },
}

local BUILDINGS = {
    foundry = { name = "Livarna", cost = { gold = 800, wood = 200, stone = 300, iron = 100 }, upkeep = 25, qualityBonus = 10, description = "Visokotemperaturna livarna." },
    smithy = { name = "Kovašnica", cost = { gold = 300, wood = 100, stone = 100, iron = 50 }, upkeep = 10, qualityBonus = 5, description = "Kovaška delavnica." },
    casting_hall = { name = "Livna dvorana", cost = { gold = 2000, wood = 300, stone = 600, iron = 200 }, upkeep = 50, qualityBonus = 25, prestigeBonus = 10, description = "Velika dvorana za litje." },
    royal_foundry = { name = "Kraljevska livarna", cost = { gold = 6000, wood = 500, stone = 1200, iron = 400 }, upkeep = 120, qualityBonus = 40, prestigeBonus = 25, description = "Največja livarna za kralja." },
}

Metalworker.metalStock = {}
Metalworker.products = {}
Metalworker.buildings = {}
Metalworker.metalworker = nil
Metalworker.activeCasting = {}
Metalworker.totalProducts = 0
Metalworker.dayTimer = 0

function Metalworker.init()
    Metalworker.metalStock = {}
    Metalworker.products = {}
    Metalworker.buildings = {}
    Metalworker.metalworker = nil
    Metalworker.activeCasting = {}
    Metalworker.totalProducts = 0
    Metalworker.dayTimer = 0
    print("[Metalworker] Royal Metalworker & Bronze Casting System initialized (6 products, 8 metals, 4 buildings)")
end

function Metalworker.hireMetalworker(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 400 + skill * 8
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Metalworker.metalworker = { name = name or ("Kovinar " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), productsMade = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Kovinar najet: %s (spretnost: %d)", Metalworker.metalworker.name, skill), "success") end
    return true
end

function Metalworker.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Metalworker.build(id) local ok,e = Metalworker.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Metalworker.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Metalworker.getQualityBonus() local b = 0; for _,bd in ipairs(Metalworker.buildings) do local d = BUILDINGS[bd.type]; if d and d.qualityBonus then b = b + d.qualityBonus end end; return b end

function Metalworker.purchaseMetal(metalType, quantity)
    local def = METALS[metalType]
    if not def then return false, "Neznan kovina" end
    quantity = quantity or 1
    local cost = def.cost * quantity
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Metalworker.metalStock[metalType] = (Metalworker.metalStock[metalType] or 0) + quantity
    return true
end

function Metalworker.canCast(productType, metalType)
    local pDef = PRODUCTS[productType]; local mDef = METALS[metalType]
    if not pDef or not mDef then return false, "Neznan produkt ali kovina" end
    if (Metalworker.metalStock[metalType] or 0) < pDef.metalCost then return false, "Premalo kovine" end
    if #Metalworker.buildings == 0 then return false, "Potrebna livarna" end
    if not Metalworker.metalworker then return false, "Potreben kovinar" end
    return true
end

function Metalworker.cast(productType, metalType, title)
    local ok, err = Metalworker.canCast(productType, metalType)
    if not ok then return false, err end
    local pDef = PRODUCTS[productType]; local mDef = METALS[metalType]
    Metalworker.metalStock[metalType] = Metalworker.metalStock[metalType] - pDef.metalCost
    local castTime = pDef.time
    if Metalworker.metalworker then castTime = math.max(1, castTime - math.floor(Metalworker.metalworker.skill / 5)) end
    table.insert(Metalworker.activeCasting, {
        id = "cast_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        productType = productType, productName = pDef.name,
        metalType = metalType, metalName = mDef.name,
        title = title or (pDef.name .. " iz " .. mDef.name),
        metalQuality = mDef.qualityBonus, metalPrestige = mDef.prestige or 0,
        prestige = pDef.prestige or 0, happiness = pDef.happiness or 0,
        faith = pDef.faith or 0, militaryBonus = pDef.militaryBonus or 0,
        daysRemaining = castTime, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Litje: %s iz %s (%d dni)", pDef.name, mDef.name, castTime), "info") end
    return true
end

function Metalworker.completeCasting(c)
    local failChance = 0.10 - (Metalworker.metalworker and Metalworker.metalworker.skill / 600 or 0)
    failChance = math.max(0.02, failChance)
    if math.random() < failChance then
        if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Livarski defekt: %s!", c.title), "danger") end
        return
    end
    local quality = 1.0 + (Metalworker.getQualityBonus() / 100) + (c.metalQuality / 100)
    if Metalworker.metalworker then quality = quality + (Metalworker.metalworker.skill / 200) end
    quality = math.min(2.0, quality)
    local product = { id = c.id, title = c.title, type = c.productName, metal = c.metalName,
        quality = quality, prestige = math.floor((c.prestige + c.metalPrestige) * quality),
        happiness = math.floor(c.happiness * quality), faith = math.floor(c.faith * quality),
        militaryBonus = math.floor(c.militaryBonus * quality), completedDay = os.time() }
    table.insert(Metalworker.products, product)
    Metalworker.totalProducts = Metalworker.totalProducts + 1
    if _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + product.happiness) end
    if product.faith > 0 and _G.Religion then pcall(_G.Religion.addFaith, product.faith) end
    if Metalworker.metalworker then Metalworker.metalworker.productsMade = Metalworker.metalworker.productsMade + 1; if math.random() < 0.15 then Metalworker.metalworker.skill = math.min(100, Metalworker.metalworker.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Livarski produkt dokončan: %s (kakovost: %.1f)", product.title, quality), "success") end
end

function Metalworker.update(dt)
    if not _G.state then return end
    Metalworker.dayTimer = Metalworker.dayTimer + dt
    if Metalworker.dayTimer >= 30 then
        Metalworker.dayTimer = 0
        for i = #Metalworker.activeCasting, 1, -1 do
            local c = Metalworker.activeCasting[i]
            c.daysRemaining = c.daysRemaining - 1
            if c.daysRemaining <= 0 then Metalworker.completeCasting(c); table.remove(Metalworker.activeCasting, i) end
        end
        local totalUpkeep = 0
        for _, bd in ipairs(Metalworker.buildings) do local d = BUILDINGS[bd.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Metalworker.metalworker then totalUpkeep = totalUpkeep + 20 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Metalworker.getProductInfo(id) return PRODUCTS[id] end
function Metalworker.getMetalInfo(id) return METALS[id] end
function Metalworker.getBuildingInfo(id) return BUILDINGS[id] end
function Metalworker.getStats()
    return { numProducts = #Metalworker.products, metalStock = Metalworker.metalStock,
        numBuildings = #Metalworker.buildings, hasMetalworker = Metalworker.metalworker ~= nil,
        metalworkerName = Metalworker.metalworker and Metalworker.metalworker.name or "—",
        metalworkerSkill = Metalworker.metalworker and Metalworker.metalworker.skill or 0,
        activeCasting = #Metalworker.activeCasting, totalProducts = Metalworker.totalProducts }
end

return Metalworker
