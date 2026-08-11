-- objects/Economy/RoyalDyerColorSystem.lua
-- Castle Kingdoms 2027 v3.6.6 - Royal Dyer & Color System
--
-- Manages dye production, pigment creation, and color theory.
-- Dyes provide colored textiles, paints, and cosmetic products.
--
-- Features:
-- - 8 dye source types (woad, madder, saffron, cochineal, indigo, weld, lac, kermes)
-- - 6 color categories (red, blue, yellow, green, purple, black)
-- - 4 dyer buildings (dye garden, dyer's workshop, vat house, royal dye works)
-- - Dyer NPC (skill affects color intensity)
-- - Dye extraction (time-based from raw materials)
-- - Color mixing (primary to secondary colors)
-- - Pigment trade
-- - Color quality and fastness

local Dyer = {}

local DYE_SOURCES = {
    woad = { name = "Woad", color = "blue", cost = 15, extractionTime = 5, intensity = 7, description = "Rastlina za modro barvo." },
    madder = { name = "Broč", color = "red", cost = 20, extractionTime = 5, intensity = 8, description = "Korenina za rdečo barvo." },
    saffron = { name = "Žafran", cost = 100, extractionTime = 3, color = "yellow", intensity = 10, prestige = 5, description = "Najdražji začimb za rumeno." },
    cochineal = { name = "Košenilj", cost = 80, extractionTime = 4, color = "red", intensity = 12, prestige = 3, description = "Insekt za močno rdečo." },
    indigo = { name = "Indigo", cost = 50, extractionTime = 6, color = "blue", intensity = 10, description = "Tropska rastlina za globoko modro." },
    weld = { name = "Sivka", cost = 10, extractionTime = 3, color = "yellow", intensity = 6, description = "Rastlina za rumeno barvo." },
    lac = { name = "Lak", cost = 60, extractionTime = 5, color = "red", intensity = 9, description = "Smola za škrlatno rdečo." },
    kermes = { name = "Kermes", cost = 70, extractionTime = 4, color = "red", intensity = 11, prestige = 4, description = "Insekt za škrlatno." },
}

local COLORS = {
    red = { name = "Rdeča", prestige = 3, description = "Barva moči in krvi." },
    blue = { name = "Modra", prestige = 5, description = "Barva zvestobe in plemstva." },
    yellow = { name = "Rumena", prestige = 2, description = "Barva zlata in sonca." },
    green = { name = "Zelena", prestige = 2, description = "Barva upanja in narave." },
    purple = { name = "Škrlatna", prestige = 15, description = "Najdražja barva — za kralje." },
    black = { name = "Črna", prestige = 4, description = "Barva žalosti in moči." },
}

local BUILDINGS = {
    dye_garden = { name = "Barvni vrt", cost = { gold = 200, wood = 50 }, upkeep = 5, growthBonus = 10, description = "Vrt za gojenje barvnih rastlin." },
    workshop = { name = "Barvarska delavnica", cost = { gold = 500, wood = 200, stone = 100 }, upkeep = 15, qualityBonus = 10, description = "Delavnica za ekstrakcijo barv." },
    vat_house = { name = "Kadnica", cost = { gold = 1200, wood = 300, stone = 300, iron = 50 }, upkeep = 30, qualityBonus = 20, capacity = 5, description = "Velike kadi za barvanje tkanin." },
    royal_dye_works = { name = "Kraljevska barvarna", cost = { gold = 4000, wood = 400, stone = 800, iron = 100 }, upkeep = 80, qualityBonus = 35, prestigeBonus = 15, description = "Najboljša barvarna za kralja." },
}

Dyer.dyeStock = {}
Dyer.rawStock = {}
Dyer.buildings = {}
Dyer.dyer = nil
Dyer.activeExtraction = {}
Dyer.totalDyesExtracted = 0
Dyer.dayTimer = 0

function Dyer.init()
    Dyer.dyeStock = {}
    Dyer.rawStock = {}
    Dyer.buildings = {}
    Dyer.dyer = nil
    Dyer.activeExtraction = {}
    Dyer.totalDyesExtracted = 0
    Dyer.dayTimer = 0
    print("[Dyer] Royal Dyer & Color System initialized (8 dye sources, 6 colors, 4 buildings)")
end

function Dyer.hireDyer(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 300 + skill * 6
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Dyer.dyer = { name = name or ("Barvar " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), dyesExtracted = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Barvar najet: %s (spretnost: %d)", Dyer.dyer.name, skill), "success") end
    return true
end

function Dyer.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Dyer.build(id) local ok,e = Dyer.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Dyer.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Dyer.getQualityBonus() local b = 0; for _,bd in ipairs(Dyer.buildings) do local d = BUILDINGS[bd.type]; if d and d.qualityBonus then b = b + d.qualityBonus end end; return b end

function Dyer.purchaseRaw(sourceType, quantity)
    local def = DYE_SOURCES[sourceType]
    if not def then return false, "Neznan vir barve" end
    quantity = quantity or 1
    local cost = def.cost * quantity
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Dyer.rawStock[sourceType] = (Dyer.rawStock[sourceType] or 0) + quantity
    return true
end

function Dyer.canExtract(sourceType, quantity)
    local def = DYE_SOURCES[sourceType]
    if not def then return false, "Neznan vir" end
    quantity = quantity or 1
    if (Dyer.rawStock[sourceType] or 0) < quantity then return false, "Premalo surovine" end
    if #Dyer.buildings == 0 then return false, "Potrebna barvarska zgradba" end
    if not Dyer.dyer then return false, "Potreben barvar" end
    return true
end

function Dyer.extract(sourceType, quantity)
    quantity = quantity or 1
    local ok, err = Dyer.canExtract(sourceType, quantity)
    if not ok then return false, err end
    local def = DYE_SOURCES[sourceType]
    Dyer.rawStock[sourceType] = Dyer.rawStock[sourceType] - quantity
    local extractTime = def.extractionTime
    local bonus = Dyer.getQualityBonus()
    if Dyer.dyer then bonus = bonus + math.floor(Dyer.dyer.skill / 5) end
    extractTime = math.max(1, extractTime - math.floor(bonus / 10))
    table.insert(Dyer.activeExtraction, {
        id = "extract_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        sourceType = sourceType, sourceName = def.name, color = def.color,
        intensity = def.intensity, prestige = def.prestige or 0,
        quantity = quantity, daysRemaining = extractTime, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Ekstrakcija barve: %d %s (%d dni)", quantity, def.name, extractTime), "info") end
    return true
end

function Dyer.completeExtraction(e)
    local quality = 1.0 + (Dyer.getQualityBonus() / 100) + (e.intensity / 200)
    if Dyer.dyer then quality = quality + (Dyer.dyer.skill / 200) end
    quality = math.min(2.0, quality)
    Dyer.dyeStock[e.sourceType] = (Dyer.dyeStock[e.sourceType] or 0) + e.quantity
    Dyer.totalDyesExtracted = Dyer.totalDyesExtracted + e.quantity
    if Dyer.dyer then Dyer.dyer.dyesExtracted = Dyer.dyer.dyesExtracted + e.quantity; if math.random() < 0.15 then Dyer.dyer.skill = math.min(100, Dyer.dyer.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Barva izdelana: %d %s (kakovost: %.1f)", e.quantity, e.sourceName, quality), "success") end
end

function Dyer.sellDye(sourceType, quantity)
    if (Dyer.dyeStock[sourceType] or 0) < quantity then return false, "Ni dovolj na zalogi" end
    local def = DYE_SOURCES[sourceType]
    Dyer.dyeStock[sourceType] = Dyer.dyeStock[sourceType] - quantity
    local revenue = def.cost * 2 * quantity
    if _G.state then _G.state.gold = (_G.state.gold or 0) + revenue end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Prodano: %d %s za %d zlata", quantity, def.name, revenue), "success") end
    return true
end

function Dyer.useDye(sourceType, quantity)
    if (Dyer.dyeStock[sourceType] or 0) < quantity then return false, "Ni dovolj na zalogi" end
    Dyer.dyeStock[sourceType] = Dyer.dyeStock[sourceType] - quantity
    local def = DYE_SOURCES[sourceType]
    local colorDef = COLORS[def.color]
    if colorDef and colorDef.prestige and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + colorDef.prestige)
    end
    if def.prestige and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + def.prestige)
    end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Barva uporabljena: %d %s (%s)", quantity, def.name, def.color), "info") end
    return true
end

function Dyer.update(dt)
    if not _G.state then return end
    Dyer.dayTimer = Dyer.dayTimer + dt
    if Dyer.dayTimer >= 30 then
        Dyer.dayTimer = 0
        for i = #Dyer.activeExtraction, 1, -1 do
            local e = Dyer.activeExtraction[i]
            e.daysRemaining = e.daysRemaining - 1
            if e.daysRemaining <= 0 then Dyer.completeExtraction(e); table.remove(Dyer.activeExtraction, i) end
        end
        local totalUpkeep = 0
        for _, bd in ipairs(Dyer.buildings) do local d = BUILDINGS[bd.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Dyer.dyer then totalUpkeep = totalUpkeep + 12 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Dyer.getDyeSourceInfo(id) return DYE_SOURCES[id] end
function Dyer.getColorInfo(id) return COLORS[id] end
function Dyer.getBuildingInfo(id) return BUILDINGS[id] end
function Dyer.getStats()
    return { dyeStock = Dyer.dyeStock, rawStock = Dyer.rawStock,
        numBuildings = #Dyer.buildings, hasDyer = Dyer.dyer ~= nil,
        dyerName = Dyer.dyer and Dyer.dyer.name or "—",
        dyerSkill = Dyer.dyer and Dyer.dyer.skill or 0,
        activeExtraction = #Dyer.activeExtraction, totalDyesExtracted = Dyer.totalDyesExtracted }
end

return Dyer
