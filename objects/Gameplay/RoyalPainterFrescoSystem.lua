-- objects/Gameplay/RoyalPainterFrescoSystem.lua
-- Castle Kingdoms 2027 v3.6.9 - Royal Painter & Fresco System
--
-- Manages painting, frescoes, portraits, and illuminated panels.
-- Paintings provide prestige, happiness, and cultural bonuses.
--
-- Features:
-- - 6 painting types (portrait, fresco, altarpiece, landscape, miniature, icon)
-- - 8 pigment types (vermilion, ultramarine, gold, lead white, ochre, umber, verdigris, carbon black)
-- - 4 painter buildings (studio, fresco workshop, guild hall, royal atelier)
-- - Painter NPC (skill affects quality)
-- - Fresco painting (time-based with plaster curing)
-- - Pigment management
-- - Portrait commissions
-- - Painting collection

local Painter = {}

local PAINTINGS = {
    portrait = { name = "Portret", pigmentCost = 3, time = 14, prestige = 10, happiness = 3, description = "Portret osebe." },
    fresco = { name = "Freska", pigmentCost = 8, time = 30, prestige = 20, happiness = 8, faith = 10, description = "Slika na mokri omet." },
    altarpiece = { name = "Oltarna slika", pigmentCost = 10, time = 45, prestige = 25, faith = 20, description = "Velika cerkvena slika." },
    landscape = { name = "Krajina", pigmentCost = 4, time = 10, prestige = 8, happiness = 5, description = "Slika pokrajine." },
    miniature = { name = "Miniatura", pigmentCost = 2, time = 5, prestige = 5, happiness = 2, description = "Majhna detaljna slika." },
    icon = { name = "Ikona", pigmentCost = 3, time = 12, prestige = 8, faith = 15, description = "Verska ikona." },
}

local PIGMENTS = {
    vermilion = { name = "Cinabarit", cost = 50, intensity = 15, color = "red", description = "Živo rdeča iz živosrebrovega sulfida." },
    ultramarine = { name = "Ultramarine", cost = 200, intensity = 20, prestige = 5, color = "blue", description = "Najdražja modra iz lapis lazuli." },
    gold = { name = "Zlata barva", cost = 100, intensity = 18, prestige = 8, color = "gold", description = "Zlati lističi za ozadja." },
    lead_white = { name = "Svinčeno belo", cost = 20, intensity = 10, color = "white", description = "Bela iz svinčevega karbonata." },
    ochre = { name = "Okra", cost = 10, intensity = 8, color = "yellow", description = "Rumena zemeljska barva." },
    umber = { name = "Umbra", cost = 12, intensity = 8, color = "brown", description = "Rjava zemeljska barva." },
    verdigris = { name = "Verdigris", cost = 30, intensity = 12, color = "green", description = "Zelena iz bakra." },
    carbon_black = { name = "Črno oglje", cost = 5, intensity = 7, color = "black", description = "Črna iz oglja." },
}

local BUILDINGS = {
    studio = { name = "Slikarski atelje", cost = { gold = 300, wood = 100 }, upkeep = 10, qualityBonus = 5, description = "Slikarski delovni prostor." },
    fresco_workshop = { name = "Freskarska delavnica", cost = { gold = 1200, wood = 200, stone = 300 }, upkeep = 30, qualityBonus = 15, description = "Za slikanje fresk na omet." },
    guild_hall = { name = "Cehovska hiša", cost = { gold = 2500, wood = 300, stone = 500 }, upkeep = 50, qualityBonus = 25, prestigeBonus = 10, description = "Cehovska hiša za slikarje." },
    royal_atelier = { name = "Kraljevski atelje", cost = { gold = 5000, wood = 400, stone = 800 }, upkeep = 100, qualityBonus = 40, prestigeBonus = 20, description = "Najboljši slikarski atelje." },
}

Painter.pigmentStock = {}
Painter.paintings = {}
Painter.buildings = {}
Painter.painter = nil
Painter.activePainting = {}
Painter.totalPaintings = 0
Painter.dayTimer = 0

function Painter.init()
    Painter.pigmentStock = {}
    Painter.paintings = {}
    Painter.buildings = {}
    Painter.painter = nil
    Painter.activePainting = {}
    Painter.totalPaintings = 0
    Painter.dayTimer = 0
    print("[Painter] Royal Painter & Fresco System initialized (6 paintings, 8 pigments, 4 buildings)")
end

function Painter.hirePainter(name, skill)
    skill = skill or math.random(45, 90)
    local cost = 400 + skill * 8
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Painter.painter = { name = name or ("Slikar " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), paintingsMade = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Slikar najet: %s (spretnost: %d)", Painter.painter.name, skill), "success") end
    return true
end

function Painter.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Painter.build(id) local ok,e = Painter.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Painter.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Painter.getQualityBonus() local b = 0; for _,bd in ipairs(Painter.buildings) do local d = BUILDINGS[bd.type]; if d and d.qualityBonus then b = b + d.qualityBonus end end; return b end

function Painter.purchasePigment(pigmentType, quantity)
    local def = PIGMENTS[pigmentType]
    if not def then return false, "Neznan pigment" end
    quantity = quantity or 1
    local cost = def.cost * quantity
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Painter.pigmentStock[pigmentType] = (Painter.pigmentStock[pigmentType] or 0) + quantity
    return true
end

function Painter.canPaint(paintingType, pigments)
    local pDef = PAINTINGS[paintingType]
    if not pDef then return false, "Neznana slika" end
    if not pigments or #pigments < pDef.pigmentCost then return false, "Potrebnih vsaj " .. pDef.pigmentCost .. " pigmentov" end
    for _, p in ipairs(pigments) do
        if (Painter.pigmentStock[p] or 0) < 1 then return false, "Premalo " .. (PIGMENTS[p] and PIGMENTS[p].name or p) end
    end
    if #Painter.buildings == 0 then return false, "Potrebna slikarska zgradba" end
    if not Painter.painter then return false, "Potreben slikar" end
    return true
end

function Painter.paint(paintingType, pigments, title)
    local ok, err = Painter.canPaint(paintingType, pigments)
    if not ok then return false, err end
    local pDef = PAINTINGS[paintingType]
    local totalIntensity = 0; local totalPrestige = 0
    for _, p in ipairs(pigments) do
        Painter.pigmentStock[p] = Painter.pigmentStock[p] - 1
        local pDef2 = PIGMENTS[p]
        if pDef2 then totalIntensity = totalIntensity + pDef2.intensity; totalPrestige = totalPrestige + (pDef2.prestige or 0) end
    end
    local paintTime = pDef.time
    if Painter.painter then paintTime = math.max(2, paintTime - math.floor(Painter.painter.skill / 5)) end
    table.insert(Painter.activePainting, {
        id = "paint_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        paintingType = paintingType, paintingName = pDef.name,
        title = title or (pDef.name .. " #" .. (Painter.totalPaintings + 1)),
        pigmentIntensity = totalIntensity, pigmentPrestige = totalPrestige,
        prestige = pDef.prestige, happiness = pDef.happiness, faith = pDef.faith or 0,
        daysRemaining = paintTime, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Slikanje: %s (%d dni)", pDef.name, paintTime), "info") end
    return true
end

function Painter.completePainting(p)
    local quality = 1.0 + (Painter.getQualityBonus() / 100) + (p.pigmentIntensity / 200)
    if Painter.painter then quality = quality + (Painter.painter.skill / 200) end
    quality = math.min(2.5, quality)
    local painting = { id = p.id, title = p.title, type = p.paintingName,
        quality = quality, prestige = math.floor((p.prestige + p.pigmentPrestige) * quality),
        happiness = math.floor(p.happiness * quality), faith = math.floor(p.faith * quality),
        completedDay = os.time() }
    table.insert(Painter.paintings, painting)
    Painter.totalPaintings = Painter.totalPaintings + 1
    if _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + painting.happiness) end
    if painting.faith > 0 and _G.Religion then pcall(_G.Religion.addFaith, painting.faith) end
    if _G.Culture then pcall(function() _G.Culture.culturalPrestige = (_G.Culture.culturalPrestige or 0) + painting.prestige end) end
    if Painter.painter then Painter.painter.paintingsMade = Painter.painter.paintingsMade + 1; if math.random() < 0.15 then Painter.painter.skill = math.min(100, Painter.painter.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Slika dokončana: %s (kakovost: %.1f, +%d prestiža)", painting.title, quality, painting.prestige), "success") end
end

function Painter.update(dt)
    if not _G.state then return end
    Painter.dayTimer = Painter.dayTimer + dt
    if Painter.dayTimer >= 30 then
        Painter.dayTimer = 0
        for i = #Painter.activePainting, 1, -1 do
            local p = Painter.activePainting[i]
            p.daysRemaining = p.daysRemaining - 1
            if p.daysRemaining <= 0 then Painter.completePainting(p); table.remove(Painter.activePainting, i) end
        end
        local totalUpkeep = 0
        for _, bd in ipairs(Painter.buildings) do local d = BUILDINGS[bd.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Painter.painter then totalUpkeep = totalUpkeep + 20 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Painter.getPaintingInfo(id) return PAINTINGS[id] end
function Painter.getPigmentInfo(id) return PIGMENTS[id] end
function Painter.getBuildingInfo(id) return BUILDINGS[id] end
function Painter.getStats()
    return { numPaintings = #Painter.paintings, pigmentStock = Painter.pigmentStock,
        numBuildings = #Painter.buildings, hasPainter = Painter.painter ~= nil,
        painterName = Painter.painter and Painter.painter.name or "—",
        painterSkill = Painter.painter and Painter.painter.skill or 0,
        activePainting = #Painter.activePainting, totalPaintings = Painter.totalPaintings }
end

return Painter
