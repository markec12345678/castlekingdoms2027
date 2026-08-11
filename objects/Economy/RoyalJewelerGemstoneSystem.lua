-- objects/Economy/RoyalJewelerGemstoneSystem.lua
-- Castle Kingdoms 2027 v3.6.2 - Royal Jeweler & Gemstone System
--
-- Manages jewelry making, gemstone cutting, and precious metal working.
-- Jewelry provides prestige, gifts, and trade wealth.
--
-- Features:
-- - 8 gemstone types (diamond, ruby, sapphire, emerald, amethyst, topaz, pearl, garnet)
-- - 6 jewelry types (ring, necklace, crown, brooch, bracelet, earring)
-- - 4 jeweler buildings (workshop, cutting room, vault, royal atelier)
-- - Jeweler NPC (skill affects quality)
-- - Gemstone cutting (time-based with risk)
-- - Precious metal management (gold, silver)
-- - Jewelry appraisal
-- - Royal regalia collection

local Jeweler = {}

-- ============================================================
-- GEMSTONE TYPES
-- ============================================================
local GEMSTONES = {
    diamond = { name = "Diamant", cost = 500, rarity = 5, cutValue = 1000, prestige = 30, description = "Najtrša in najdražja draga kamen." },
    ruby = { name = "Rubin", cost = 300, rarity = 4, cutValue = 600, prestige = 20, description = "Rdeči dragi kamen." },
    sapphire = { name = "Safir", cost = 280, rarity = 4, cutValue = 550, prestige = 18, description = "Modri dragi kamen." },
    emerald = { name = "Smaragd", cost = 320, rarity = 4, cutValue = 650, prestige = 22, description = "Zeleni dragi kamen." },
    amethyst = { name = "Ametist", cost = 80, rarity = 2, cutValue = 150, prestige = 6, description = "Vijolični poldragi kamen." },
    topaz = { name = "Topaz", cost = 100, rarity = 3, cutValue = 200, prestige = 8, description = "Zlati poldragi kamen." },
    pearl = { name = "Biser", cost = 150, rarity = 3, cutValue = 300, prestige = 12, description = "Biser iz morskih školjk." },
    garnet = { name = "Granat", cost = 50, rarity = 2, cutValue = 100, prestige = 4, description = "Temno rdeči poldragi kamen." },
}

-- ============================================================
-- JEWELRY TYPES
-- ============================================================
local JEWELRY = {
    ring = { name = "Prstan", goldCost = 5, gemCost = 1, cost = 200, buildTime = 5, prestige = 5, description = "Prstan z dragim kamen." },
    necklace = { name = "Naglavni okras", goldCost = 15, gemCost = 3, cost = 800, buildTime = 14, prestige = 15, description = "Velika ogrlica." },
    crown = { name = "Krona", goldCost = 50, gemCost = 8, cost = 5000, buildTime = 60, prestige = 50, description = "Kraljeva krona z drago kamen." },
    brooch = { name = "Broška", goldCost = 10, gemCost = 2, cost = 500, buildTime = 10, prestige = 10, description = "Okrasna broška." },
    bracelet = { name = "Zapestnica", goldCost = 8, gemCost = 2, cost = 400, buildTime = 8, prestige = 8, description = "Zapestnica z drago kamen." },
    earring = { name = "Uhani", goldCost = 3, gemCost = 1, cost = 150, buildTime = 4, prestige = 4, description = "Uhan z drago kamen." },
}

-- ============================================================
-- BUILDINGS
-- ============================================================
local BUILDINGS = {
    workshop = { name = "Zlatarska delavnica", cost = { gold = 400, wood = 100, iron = 50 }, upkeep = 15, qualityBonus = 5, description = "Osnovna zlatarna." },
    cutting_room = { name = "Rezilnica", cost = { gold = 1200, wood = 200, stone = 200, iron = 100 }, upkeep = 30, cutBonus = 20, qualityBonus = 15, description = "Za rezanje dragih kamen." },
    vault = { name = "Trezor", cost = { gold = 2000, wood = 300, stone = 800, iron = 200 }, upkeep = 40, storageCapacity = 100, securityBonus = 30, description = "Varni trezor za drago kamen." },
    royal_atelier = { name = "Kraljevski atelje", cost = { gold = 5000, wood = 400, stone = 1000, iron = 300 }, upkeep = 80, qualityBonus = 35, prestigeBonus = 20, description = "Najboljša zlatarna za kralja." },
}

-- ============================================================
-- STATE
-- ============================================================
Jeweler.gemStock = {}
Jeweler.cutGems = {}
Jeweler.jewelryStock = {}
Jeweler.buildings = {}
Jeweler.jeweler = nil
Jeweler.activeCutting = {}
Jeweler.activeMaking = {}
Jeweler.royalRegalia = {}
Jeweler.totalGemsCut = 0
Jeweler.totalJewelryMade = 0
Jeweler.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Jeweler.init()
    Jeweler.gemStock = {}
    Jeweler.cutGems = {}
    Jeweler.jewelryStock = {}
    Jeweler.buildings = {}
    Jeweler.jeweler = nil
    Jeweler.activeCutting = {}
    Jeweler.activeMaking = {}
    Jeweler.royalRegalia = {}
    Jeweler.totalGemsCut = 0
    Jeweler.totalJewelryMade = 0
    Jeweler.dayTimer = 0
    print("[Jeweler] Royal Jeweler & Gemstone System initialized (8 gemstones, 6 jewelry, 4 buildings)")
end

-- ============================================================
-- JEWELER NPC
-- ============================================================
function Jeweler.hireJeweler(name, skill)
    skill = skill or math.random(45, 90)
    local cost = 500 + skill * 10
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Jeweler.jeweler = { name = name or ("Zlatar " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), itemsMade = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Zlatar najet: %s (spretnost: %d)", Jeweler.jeweler.name, skill), "success") end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Jeweler.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Jeweler.build(id) local ok,e = Jeweler.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Jeweler.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Jeweler.getQualityBonus() local b = 0; for _,bd in ipairs(Jeweler.buildings) do local d = BUILDINGS[bd.type]; if d and d.qualityBonus then b = b + d.qualityBonus end end; return b end
function Jeweler.getCutBonus() local b = 0; for _,bd in ipairs(Jeweler.buildings) do local d = BUILDINGS[bd.type]; if d and d.cutBonus then b = b + d.cutBonus end end; return b end

-- ============================================================
-- GEMSTONE PURCHASE
-- ============================================================
function Jeweler.purchaseGem(gemType, quantity)
    local def = GEMSTONES[gemType]
    if not def then return false, "Neznan kamen" end
    quantity = quantity or 1
    local cost = def.cost * quantity
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Jeweler.gemStock[gemType] = (Jeweler.gemStock[gemType] or 0) + quantity
    return true
end

-- ============================================================
-- GEM CUTTING
-- ============================================================
function Jeweler.canCut(gemType, quantity)
    local def = GEMSTONES[gemType]
    if not def then return false, "Neznan kamen" end
    quantity = quantity or 1
    if (Jeweler.gemStock[gemType] or 0) < quantity then return false, "Premalo neobdelanega kamna" end
    if #Jeweler.buildings == 0 then return false, "Potrebna zlatarna" end
    if not Jeweler.jeweler then return false, "Potreben zlatar" end
    return true
end

function Jeweler.cutGem(gemType, quantity)
    quantity = quantity or 1
    local ok, err = Jeweler.canCut(gemType, quantity)
    if not ok then return false, err end
    Jeweler.gemStock[gemType] = Jeweler.gemStock[gemType] - quantity
    local cutTime = 3
    local bonus = Jeweler.getCutBonus()
    if Jeweler.jeweler then bonus = bonus + math.floor(Jeweler.jeweler.skill / 5) end
    cutTime = math.max(1, cutTime - math.floor(bonus / 10))
    table.insert(Jeweler.activeCutting, {
        id = "cut_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        gemType = gemType, gemName = GEMSTONES[gemType].name, quantity = quantity,
        daysRemaining = cutTime, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Rezanje kamna: %d %s (%d dni)", quantity, GEMSTONES[gemType].name, cutTime), "info") end
    return true
end

function Jeweler.completeCutting(c)
    local failChance = 0.15 - (Jeweler.jeweler and Jeweler.jeweler.skill / 500 or 0)
    failChance = math.max(0.02, failChance)
    if math.random() < failChance then
        if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Kamen počil pri rezanju: %s!", c.gemName), "danger") end
        return
    end
    Jeweler.cutGems[c.gemType] = (Jeweler.cutGems[c.gemType] or 0) + c.quantity
    Jeweler.totalGemsCut = Jeweler.totalGemsCut + c.quantity
    if Jeweler.jeweler then Jeweler.jeweler.itemsMade = Jeweler.jeweler.itemsMade + c.quantity; if math.random() < 0.15 then Jeweler.jeweler.skill = math.min(100, Jeweler.jeweler.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Kamen izrezan: %d %s", c.quantity, c.gemName), "success") end
end

-- ============================================================
-- JEWELRY MAKING
-- ============================================================
function Jeweler.canMake(jewelryType, gemType, quantity)
    local def = JEWELRY[jewelryType]
    if not def then return false, "Neznana nakit" end
    quantity = quantity or 1
    if not gemType or (Jeweler.cutGems[gemType] or 0) < def.gemCost * quantity then return false, "Premalo izrezanega kamna" end
    if not _G.state or (_G.state.gold or 0) < def.goldCost * quantity then return false, "Premalo zlata" end
    if not Jeweler.jeweler then return false, "Potreben zlatar" end
    return true
end

function Jeweler.makeJewelry(jewelryType, gemType, quantity)
    quantity = quantity or 1
    local ok, err = Jeweler.canMake(jewelryType, gemType, quantity)
    if not ok then return false, err end
    local def = JEWELRY[jewelryType]
    Jeweler.cutGems[gemType] = Jeweler.cutGems[gemType] - (def.gemCost * quantity)
    _G.state.gold = _G.state.gold - (def.goldCost * quantity)
    local makeTime = def.buildTime
    local bonus = Jeweler.getQualityBonus()
    if Jeweler.jeweler then bonus = bonus + math.floor(Jeweler.jeweler.skill / 5) end
    makeTime = math.max(1, makeTime - math.floor(bonus / 10))
    table.insert(Jeweler.activeMaking, {
        id = "jewel_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        jewelryType = jewelryType, jewelryName = def.name, gemType = gemType,
        quantity = quantity, daysRemaining = makeTime, prestige = def.prestige,
        cost = def.cost, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Izdelava nakita: %d %s (%d dni)", quantity, def.name, makeTime), "info") end
    return true
end

function Jeweler.completeMaking(m)
    local quality = 1.0 + (Jeweler.getQualityBonus() / 100)
    if Jeweler.jeweler then quality = quality + (Jeweler.jeweler.skill / 200) end
    quality = math.min(2.0, quality)
    Jeweler.jewelryStock[m.jewelryType] = Jeweler.jewelryStock[m.jewelryType] or {}
    table.insert(Jeweler.jewelryStock[m.jewelryType], {
        id = m.id, gemType = m.gemType, quality = quality,
        value = math.floor(m.cost * quality), prestige = m.prestige,
    })
    Jeweler.totalJewelryMade = Jeweler.totalJewelryMade + m.quantity
    if Jeweler.jeweler then Jeweler.jeweler.itemsMade = Jeweler.jeweler.itemsMade + m.quantity; if math.random() < 0.15 then Jeweler.jeweler.skill = math.min(100, Jeweler.jeweler.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Nakit izdelan: %d %s (kakovost: %.1f)", m.quantity, m.jewelryName, quality), "success") end
end

-- ============================================================
-- SELL AND ADD TO REGALIA
-- ============================================================
function Jeweler.sellJewelry(jewelryType, index)
    if not Jeweler.jewelryStock[jewelryType] or not Jeweler.jewelryStock[jewelryType][index] then return false, "Nakit ne obstaja" end
    local j = table.remove(Jeweler.jewelryStock[jewelryType], index)
    if _G.state then _G.state.gold = (_G.state.gold or 0) + j.value end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Nakit prodan: %s za %d zlata", jewelryType, j.value), "success") end
    return true
end

function Jeweler.addToRegalia(jewelryType, index)
    if not Jeweler.jewelryStock[jewelryType] or not Jeweler.jewelryStock[jewelryType][index] then return false, "Nakit ne obstaja" end
    local j = table.remove(Jeweler.jewelryStock[jewelryType], index)
    table.insert(Jeweler.royalRegalia, j)
    if _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + j.prestige) end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Nakit dodan v kraljevske regalije: %s (+%d prestiža)", jewelryType, j.prestige), "rare") end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Jeweler.update(dt)
    if not _G.state then return end
    Jeweler.dayTimer = Jeweler.dayTimer + dt
    if Jeweler.dayTimer >= 30 then
        Jeweler.dayTimer = 0
        for i = #Jeweler.activeCutting, 1, -1 do
            local c = Jeweler.activeCutting[i]
            c.daysRemaining = c.daysRemaining - 1
            if c.daysRemaining <= 0 then Jeweler.completeCutting(c); table.remove(Jeweler.activeCutting, i) end
        end
        for i = #Jeweler.activeMaking, 1, -1 do
            local m = Jeweler.activeMaking[i]
            m.daysRemaining = m.daysRemaining - 1
            if m.daysRemaining <= 0 then Jeweler.completeMaking(m); table.remove(Jeweler.activeMaking, i) end
        end
        local totalUpkeep = 0
        for _, b in ipairs(Jeweler.buildings) do local d = BUILDINGS[b.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Jeweler.jeweler then totalUpkeep = totalUpkeep + 20 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Jeweler.getGemstoneInfo(id) return GEMSTONES[id] end
function Jeweler.getJewelryInfo(id) return JEWELRY[id] end
function Jeweler.getBuildingInfo(id) return BUILDINGS[id] end
function Jeweler.getStats()
    return { numBuildings = #Jeweler.buildings, hasJeweler = Jeweler.jeweler ~= nil,
        jewelerName = Jeweler.jeweler and Jeweler.jeweler.name or "—", jewelerSkill = Jeweler.jeweler and Jeweler.jeweler.skill or 0,
        activeCutting = #Jeweler.activeCutting, activeMaking = #Jeweler.activeMaking,
        totalGemsCut = Jeweler.totalGemsCut, totalJewelryMade = Jeweler.totalJewelryMade,
        regaliaSize = #Jeweler.royalRegalia }
end

return Jeweler
