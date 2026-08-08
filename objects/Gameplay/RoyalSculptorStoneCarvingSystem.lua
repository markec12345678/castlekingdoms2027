-- objects/Gameplay/RoyalSculptorStoneCarvingSystem.lua
-- Castle Kingdoms 2027 v3.6.8 - Royal Sculptor & Stone Carving System
--
-- Manages stone carving, sculpture creation, and monument building.
-- Sculptures provide prestige, happiness, and cultural heritage.
--
-- Features:
-- - 6 sculpture types (statue, bust, relief, gargoyle, sarcophagus, monument)
-- - 8 stone materials (marble, granite, sandstone, limestone, alabaster, basalt, porphyry, jade)
-- - 4 sculptor buildings (workshop, quarry, carving studio, royal atelier)
-- - Sculptor NPC (skill affects quality)
-- - Stone carving (time-based with risk of cracking)
-- - Monument construction
-- - Sculpture collection

local Sculptor = {}

local SCULPTURES = {
    statue = { name = "Kip", stoneCost = 10, time = 30, prestige = 15, happiness = 5, description = "Polna plastika osebe ali božanstva." },
    bust = { name = "Poprsje", stoneCost = 3, time = 10, prestige = 8, happiness = 3, description = "Portretno poprsje." },
    relief = { name = "Relief", stoneCost = 5, time = 14, prestige = 10, happiness = 4, description = "Plitvo izklesan prizor." },
    gargoyle = { name = "Gargoj", stoneCost = 4, time = 12, prestige = 5, happiness = 2, faith = 5, description = "Vodna grape z demonsko obliko." },
    sarcophagus = { name = "Sarkofag", stoneCost = 15, time = 45, prestige = 20, faith = 15, description = "Bogato okrašen kamniti grob." },
    monument = { name = "Spomenik", stoneCost = 30, time = 60, prestige = 40, happiness = 10, description = "Veliki javni spomenik." },
}

local STONES = {
    marble = { name = "Marmor", cost = 200, qualityBonus = 25, prestige = 10, description = "Najplemenitejši kamen za kiparstvo." },
    granite = { name = "Granit", cost = 80, qualityBonus = 10, description = "Trd in odporen kamen." },
    sandstone = { name = "Peščenjak", cost = 40, qualityBonus = 5, description = "Mehak in enostaven za obdelavo." },
    limestone = { name = "Apnenec", cost = 30, qualityBonus = 8, description = "Pogost gradbeni kamen." },
    alabaster = { name = "Alabaster", cost = 150, qualityBonus = 20, happiness = 3, description = "Prosojen in eleganten." },
    basalt = { name = "Bazalt", cost = 100, qualityBonus = 12, description = "Temno vulkansko kamen." },
    porphyry = { name = "Porfir", cost = 500, qualityBonus = 35, prestige = 20, description = "Redki cesarski kamen." },
    jade = { name = "Žad", cost = 800, qualityBonus = 40, prestige = 25, description = "Najdražji poldragi kamen." },
}

local BUILDINGS = {
    workshop = { name = "Kiparska delavnica", cost = { gold = 400, wood = 100, stone = 50 }, upkeep = 15, qualityBonus = 5, description = "Osnovna kiparska delavnica." },
    quarry = { name = "Kamnolom", cost = { gold = 1000, wood = 200, iron = 50 }, upkeep = 30, stoneProduction = 5, description = "Za pridobivanje kamna." },
    carving_studio = { name = "Rezbarski atelje", cost = { gold = 2500, wood = 300, stone = 400 }, upkeep = 50, qualityBonus = 25, prestigeBonus = 10, description = "Napreden atelje za kiparstvo." },
    royal_atelier = { name = "Kraljevski atelje", cost = { gold = 6000, wood = 500, stone = 1000 }, upkeep = 120, qualityBonus = 40, prestigeBonus = 25, description = "Najboljši atelje za kralja." },
}

Sculptor.stoneStock = {}
Sculptor.sculptures = {}
Sculptor.buildings = {}
Sculptor.sculptor = nil
Sculptor.activeCarving = {}
Sculptor.totalSculptures = 0
Sculptor.dayTimer = 0

function Sculptor.init()
    Sculptor.stoneStock = {}
    Sculptor.sculptures = {}
    Sculptor.buildings = {}
    Sculptor.sculptor = nil
    Sculptor.activeCarving = {}
    Sculptor.totalSculptures = 0
    Sculptor.dayTimer = 0
    print("[Sculptor] Royal Sculptor & Stone Carving System initialized (6 sculptures, 8 stones, 4 buildings)")
end

function Sculptor.hireSculptor(name, skill)
    skill = skill or math.random(45, 90)
    local cost = 500 + skill * 10
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Sculptor.sculptor = { name = name or ("Kipar " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), sculpturesMade = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Kipar najet: %s (spretnost: %d)", Sculptor.sculptor.name, skill), "success") end
    return true
end

function Sculptor.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Sculptor.build(id) local ok,e = Sculptor.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Sculptor.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Sculptor.getQualityBonus() local b = 0; for _,bd in ipairs(Sculptor.buildings) do local d = BUILDINGS[bd.type]; if d and d.qualityBonus then b = b + d.qualityBonus end end; return b end

function Sculptor.purchaseStone(stoneType, quantity)
    local def = STONES[stoneType]
    if not def then return false, "Neznan kamen" end
    quantity = quantity or 1
    local cost = def.cost * quantity
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Sculptor.stoneStock[stoneType] = (Sculptor.stoneStock[stoneType] or 0) + quantity
    return true
end

function Sculptor.canCarve(sculptureType, stoneType)
    local sDef = SCULPTURES[sculptureType]; local stDef = STONES[stoneType]
    if not sDef or not stDef then return false, "Neznan tip ali kamen" end
    if (Sculptor.stoneStock[stoneType] or 0) < sDef.stoneCost then return false, "Premalo kamna" end
    if #Sculptor.buildings == 0 then return false, "Potrebna kiparska zgradba" end
    if not Sculptor.sculptor then return false, "Potreben kipar" end
    return true
end

function Sculptor.carve(sculptureType, stoneType, title)
    local ok, err = Sculptor.canCarve(sculptureType, stoneType)
    if not ok then return false, err end
    local sDef = SCULPTURES[sculptureType]; local stDef = STONES[stoneType]
    Sculptor.stoneStock[stoneType] = Sculptor.stoneStock[stoneType] - sDef.stoneCost
    local carveTime = sDef.time
    if Sculptor.sculptor then carveTime = math.max(2, carveTime - math.floor(Sculptor.sculptor.skill / 5)) end
    table.insert(Sculptor.activeCarving, {
        id = "sculpt_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        sculptureType = sculptureType, sculptureName = sDef.name,
        stoneType = stoneType, stoneName = stDef.name,
        title = title or (sDef.name .. " iz " .. stDef.name),
        stoneQuality = stDef.qualityBonus, stonePrestige = stDef.prestige or 0,
        stoneHappiness = stDef.happiness or 0,
        prestige = sDef.prestige, happiness = sDef.happiness, faith = sDef.faith or 0,
        daysRemaining = carveTime, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Klesanje: %s iz %s (%d dni)", sDef.name, stDef.name, carveTime), "info") end
    return true
end

function Sculptor.completeCarving(c)
    local failChance = 0.12 - (Sculptor.sculptor and Sculptor.sculptor.skill / 500 or 0)
    failChance = math.max(0.02, failChance)
    if math.random() < failChance then
        if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Kamen počil pri klesanju: %s!", c.title), "danger") end
        return
    end
    local quality = 1.0 + (Sculptor.getQualityBonus() / 100) + (c.stoneQuality / 100)
    if Sculptor.sculptor then quality = quality + (Sculptor.sculptor.skill / 200) end
    quality = math.min(2.5, quality)
    local sculpture = { id = c.id, title = c.title, type = c.sculptureName, stone = c.stoneName,
        quality = quality, prestige = math.floor((c.prestige + c.stonePrestige) * quality),
        happiness = math.floor((c.happiness + c.stoneHappiness) * quality),
        faith = math.floor(c.faith * quality), completedDay = os.time() }
    table.insert(Sculptor.sculptures, sculpture)
    Sculptor.totalSculptures = Sculptor.totalSculptures + 1
    if _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + sculpture.happiness) end
    if sculpture.faith > 0 and _G.Religion then pcall(_G.Religion.addFaith, sculpture.faith) end
    if Sculptor.sculptor then Sculptor.sculptor.sculpturesMade = Sculptor.sculptor.sculpturesMade + 1; if math.random() < 0.15 then Sculptor.sculptor.skill = math.min(100, Sculptor.sculptor.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Kiparstvo dokončano: %s (kakovost: %.1f, +%d prestiža)", sculpture.title, quality, sculpture.prestige), "success") end
end

function Sculptor.update(dt)
    if not _G.state then return end
    Sculptor.dayTimer = Sculptor.dayTimer + dt
    if Sculptor.dayTimer >= 30 then
        Sculptor.dayTimer = 0
        for i = #Sculptor.activeCarving, 1, -1 do
            local c = Sculptor.activeCarving[i]
            c.daysRemaining = c.daysRemaining - 1
            if c.daysRemaining <= 0 then Sculptor.completeCarving(c); table.remove(Sculptor.activeCarving, i) end
        end
        local totalUpkeep = 0
        for _, bd in ipairs(Sculptor.buildings) do local d = BUILDINGS[bd.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Sculptor.sculptor then totalUpkeep = totalUpkeep + 25 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Sculptor.getSculptureInfo(id) return SCULPTURES[id] end
function Sculptor.getStoneInfo(id) return STONES[id] end
function Sculptor.getBuildingInfo(id) return BUILDINGS[id] end
function Sculptor.getStats()
    return { numSculptures = #Sculptor.sculptures, stoneStock = Sculptor.stoneStock,
        numBuildings = #Sculptor.buildings, hasSculptor = Sculptor.sculptor ~= nil,
        sculptorName = Sculptor.sculptor and Sculptor.sculptor.name or "—",
        sculptorSkill = Sculptor.sculptor and Sculptor.sculptor.skill or 0,
        activeCarving = #Sculptor.activeCarving, totalSculptures = Sculptor.totalSculptures }
end

return Sculptor
