-- objects/Economy/RoyalLeatherworkerTannerySystem.lua
-- Castle Kingdoms 2027 v3.7.1 - Royal Leatherworker & Tannery System
--
-- Manages leather tanning, leather goods production, and hide processing.
-- Leather provides armor, boots, bags, and book covers.
--
-- Features:
-- - 6 leather products (boots, armor, bag, belt, gloves, book cover)
-- - 8 hide types (cow, sheep, goat, deer, pig, calf, horse, exotic)
-- - 4 leatherworking buildings (tannery, workshop, dye shop, royal leatherworks)
-- - Leatherworker NPC (skill affects quality)
-- - Hide tanning (time-based with odor penalty)
-- - Leather quality and durability
-- - Leather dyeing
-- - Product collection

local Leatherworker = {}

local PRODUCTS = {
    boots = { name = "Škornji", leatherCost = 3, time = 5, cost = 50, happiness = 2, description = "Usnjeni škornji." },
    armor = { name = "Usnjena oklepa", leatherCost = 8, time = 14, cost = 200, militaryBonus = 15, description = "Oklep za vojake." },
    bag = { name = "Vrečka", leatherCost = 2, time = 3, cost = 30, happiness = 1, description = "Usnjena vrečka." },
    belt = { name = "Pas", leatherCost = 1, time = 2, cost = 20, happiness = 1, description = "Usnjen pas." },
    gloves = { name = "Rokavice", leatherCost = 2, time = 4, cost = 40, happiness = 2, description = "Usnjene rokavice." },
    book_cover = { name = "Usnjeni vez", leatherCost = 3, time = 5, cost = 60, prestige = 3, description = "Usnjeni vez za knjige." },
}

local HIDES = {
    cow = { name = "Kravje", cost = 15, qualityBonus = 8, durability = 50, description = "Najpogostejša in trdna usnje." },
    sheep = { name = "Ovčje", cost = 10, qualityBonus = 5, durability = 30, description = "Mehko in prožno." },
    goat = { name = "Kozje", cost = 12, qualityBonus = 7, durability = 40, description = "Fino in odporno." },
    deer = { name = "Jelenje", cost = 25, qualityBonus = 12, durability = 45, description = "Mehko in elegantno." },
    pig = { name = "Svinjsko", cost = 8, qualityBonus = 4, durability = 35, description = "Cenejše a odporno." },
    calf = { name = "Teletje", cost = 30, qualityBonus = 15, durability = 40, prestige = 3, description = "Najfinejše mehko usnje." },
    horse = { name = "Konjsko", cost = 20, qualityBonus = 10, durability = 55, description = "Trdno za sedla." },
    exotic = { name = "Egzotično", cost = 100, qualityBonus = 25, durability = 60, prestige = 10, description = "Redke živali (krokodil, noj)." },
}

local BUILDINGS = {
    tannery = { name = "Strojarna", cost = { gold = 300, wood = 150 }, upkeep = 10, odorPenalty = 5, qualityBonus = 5, description = "Za strojenje usnja (smrdi!)." },
    workshop = { name = "Usnjarska delavnica", cost = { gold = 500, wood = 200, iron = 30 }, upkeep = 15, qualityBonus = 10, description = "Za izdelavo usnjenih produktov." },
    dye_shop = { name = "Barvarna usnja", cost = { gold = 1200, wood = 200, stone = 200 }, upkeep = 30, qualityBonus = 20, dyeBonus = 15, description = "Za barvanje in okras usnja." },
    royal_leatherworks = { name = "Kraljevska usnjarna", cost = { gold = 4000, wood = 400, stone = 800, iron = 100 }, upkeep = 80, qualityBonus = 35, prestigeBonus = 15, description = "Najboljša usnjarna za kralja." },
}

Leatherworker.hideStock = {}
Leatherworker.leatherStock = {}
Leatherworker.productStock = {}
Leatherworker.buildings = {}
Leatherworker.leatherworker = nil
Leatherworker.activeTanning = {}
Leatherworker.activeMaking = {}
Leatherworker.totalTanned = 0
Leatherworker.totalProducts = 0
Leatherworker.dayTimer = 0

function Leatherworker.init()
    Leatherworker.hideStock = {}
    Leatherworker.leatherStock = {}
    Leatherworker.productStock = {}
    Leatherworker.buildings = {}
    Leatherworker.leatherworker = nil
    Leatherworker.activeTanning = {}
    Leatherworker.activeMaking = {}
    Leatherworker.totalTanned = 0
    Leatherworker.totalProducts = 0
    Leatherworker.dayTimer = 0
    print("[Leatherworker] Royal Leatherworker & Tannery System initialized (6 products, 8 hides, 4 buildings)")
end

function Leatherworker.hireLeatherworker(name, skill)
    skill = skill or math.random(35, 80)
    local cost = 250 + skill * 5
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Leatherworker.leatherworker = { name = name or ("Usnjar " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), itemsMade = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Usnjar najet: %s (spretnost: %d)", Leatherworker.leatherworker.name, skill), "success") end
    return true
end

function Leatherworker.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Leatherworker.build(id) local ok,e = Leatherworker.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Leatherworker.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Leatherworker.getQualityBonus() local b = 0; for _,bd in ipairs(Leatherworker.buildings) do local d = BUILDINGS[bd.type]; if d and d.qualityBonus then b = b + d.qualityBonus end end; return b end

function Leatherworker.purchaseHide(hideType, quantity)
    local def = HIDES[hideType]
    if not def then return false, "Neznana koža" end
    quantity = quantity or 1
    local cost = def.cost * quantity
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Leatherworker.hideStock[hideType] = (Leatherworker.hideStock[hideType] or 0) + quantity
    return true
end

function Leatherworker.canTan(hideType, quantity)
    local def = HIDES[hideType]
    if not def then return false, "Neznana koža" end
    quantity = quantity or 1
    if (Leatherworker.hideStock[hideType] or 0) < quantity then return false, "Premalo surovih kož" end
    if #Leatherworker.buildings == 0 then return false, "Potrebna strojarna" end
    if not Leatherworker.leatherworker then return false, "Potreben usnjar" end
    return true
end

function Leatherworker.tan(hideType, quantity)
    quantity = quantity or 1
    local ok, err = Leatherworker.canTan(hideType, quantity)
    if not ok then return false, err end
    local def = HIDES[hideType]
    Leatherworker.hideStock[hideType] = Leatherworker.hideStock[hideType] - quantity
    local tanTime = 7
    if Leatherworker.leatherworker then tanTime = math.max(2, tanTime - math.floor(Leatherworker.leatherworker.skill / 10)) end
    table.insert(Leatherworker.activeTanning, {
        id = "tan_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        hideType = hideType, hideName = def.name, quantity = quantity,
        hideQuality = def.qualityBonus, hideDurability = def.durability,
        hidePrestige = def.prestige or 0, daysRemaining = tanTime, started = os.time(),
    })
    -- Odor penalty from tannery
    if _G.state and _G.state.happiness then
        local odor = 0
        for _, b in ipairs(Leatherworker.buildings) do local d = BUILDINGS[b.type]; if d and d.odorPenalty then odor = odor + d.odorPenalty end end
        _G.state.happiness = math.max(0, _G.state.happiness - odor * 0.1)
    end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Strojenje: %d %s (%d dni)", quantity, def.name, tanTime), "info") end
    return true
end

function Leatherworker.completeTanning(t)
    Leatherworker.leatherStock[t.hideType] = (Leatherworker.leatherStock[t.hideType] or 0) + t.quantity
    Leatherworker.totalTanned = Leatherworker.totalTanned + t.quantity
    if Leatherworker.leatherworker then Leatherworker.leatherworker.itemsMade = Leatherworker.leatherworker.itemsMade + t.quantity; if math.random() < 0.15 then Leatherworker.leatherworker.skill = math.min(100, Leatherworker.leatherworker.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Usnje strojeno: %d %s", t.quantity, t.hideName), "success") end
end

function Leatherworker.canMake(productType, hideType)
    local pDef = PRODUCTS[productType]; local hDef = HIDES[hideType]
    if not pDef or not hDef then return false, "Neznan produkt ali koža" end
    if (Leatherworker.leatherStock[hideType] or 0) < pDef.leatherCost then return false, "Premalo usnja" end
    if not Leatherworker.leatherworker then return false, "Potreben usnjar" end
    return true
end

function Leatherworker.make(productType, hideType)
    local ok, err = Leatherworker.canMake(productType, hideType)
    if not ok then return false, err end
    local pDef = PRODUCTS[productType]; local hDef = HIDES[hideType]
    Leatherworker.leatherStock[hideType] = Leatherworker.leatherStock[hideType] - pDef.leatherCost
    local makeTime = pDef.time
    if Leatherworker.leatherworker then makeTime = math.max(1, makeTime - math.floor(Leatherworker.leatherworker.skill / 10)) end
    table.insert(Leatherworker.activeMaking, {
        id = "make_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        productType = productType, productName = pDef.name, hideType = hideType, hideName = hDef.name,
        hideQuality = hDef.qualityBonus, hidePrestige = hDef.prestige or 0,
        cost = pDef.cost, happiness = pDef.happiness or 0, prestige = pDef.prestige or 0,
        militaryBonus = pDef.militaryBonus or 0, daysRemaining = makeTime, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Izdelava: %s iz %s (%d dni)", pDef.name, hDef.name, makeTime), "info") end
    return true
end

function Leatherworker.completeMaking(m)
    local quality = 1.0 + (Leatherworker.getQualityBonus() / 100) + (m.hideQuality / 100)
    if Leatherworker.leatherworker then quality = quality + (Leatherworker.leatherworker.skill / 200) end
    quality = math.min(2.0, quality)
    Leatherworker.productStock[m.productType] = (Leatherworker.productStock[m.productType] or 0) + 1
    Leatherworker.totalProducts = Leatherworker.totalProducts + 1
    if _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + m.happiness) end
    if m.prestige > 0 and _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + m.prestige) end
    if Leatherworker.leatherworker then Leatherworker.leatherworker.itemsMade = Leatherworker.leatherworker.itemsMade + 1; if math.random() < 0.15 then Leatherworker.leatherworker.skill = math.min(100, Leatherworker.leatherworker.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Usnjeni produkt izdelan: %s (kakovost: %.1f)", m.productName, quality), "success") end
end

function Leatherworker.sellProduct(productType, quantity)
    if (Leatherworker.productStock[productType] or 0) < quantity then return false, "Ni dovolj na zalogi" end
    Leatherworker.productStock[productType] = Leatherworker.productStock[productType] - quantity
    local def = PRODUCTS[productType]
    local revenue = def.cost * quantity
    if _G.state then _G.state.gold = (_G.state.gold or 0) + revenue end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Prodano: %d %s za %d zlata", quantity, def.name, revenue), "success") end
    return true
end

function Leatherworker.update(dt)
    if not _G.state then return end
    Leatherworker.dayTimer = Leatherworker.dayTimer + dt
    if Leatherworker.dayTimer >= 30 then
        Leatherworker.dayTimer = 0
        for i = #Leatherworker.activeTanning, 1, -1 do
            local t = Leatherworker.activeTanning[i]
            t.daysRemaining = t.daysRemaining - 1
            if t.daysRemaining <= 0 then Leatherworker.completeTanning(t); table.remove(Leatherworker.activeTanning, i) end
        end
        for i = #Leatherworker.activeMaking, 1, -1 do
            local m = Leatherworker.activeMaking[i]
            m.daysRemaining = m.daysRemaining - 1
            if m.daysRemaining <= 0 then Leatherworker.completeMaking(m); table.remove(Leatherworker.activeMaking, i) end
        end
        local totalUpkeep = 0
        for _, bd in ipairs(Leatherworker.buildings) do local d = BUILDINGS[bd.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Leatherworker.leatherworker then totalUpkeep = totalUpkeep + 10 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Leatherworker.getProductInfo(id) return PRODUCTS[id] end
function Leatherworker.getHideInfo(id) return HIDES[id] end
function Leatherworker.getBuildingInfo(id) return BUILDINGS[id] end
function Leatherworker.getStats()
    return { hideStock = Leatherworker.hideStock, leatherStock = Leatherworker.leatherStock,
        productStock = Leatherworker.productStock, numBuildings = #Leatherworker.buildings,
        hasLeatherworker = Leatherworker.leatherworker ~= nil,
        leatherworkerName = Leatherworker.leatherworker and Leatherworker.leatherworker.name or "—",
        leatherworkerSkill = Leatherworker.leatherworker and Leatherworker.leatherworker.skill or 0,
        activeTanning = #Leatherworker.activeTanning, activeMaking = #Leatherworker.activeMaking,
        totalTanned = Leatherworker.totalTanned, totalProducts = Leatherworker.totalProducts }
end

return Leatherworker
