-- objects/Config/RoyalCalligrapherIlluminationSystem.lua
-- Castle Kingdoms 2027 v3.6.3 - Royal Calligrapher & Illumination System
--
-- Manages manuscript production, calligraphy, illumination, and book decoration.
-- Provides knowledge, prestige, and religious bonuses through beautiful manuscripts.
--
-- Features:
-- - 6 manuscript types (bible, psalter, bestiary, chronicle, legal, poetry)
-- - 8 illumination styles (gold leaf, miniatures, borders, initials, ...)
-- - 4 scriptorium buildings (scriptorium, illumination room, bindery, royal scriptorium)
-- - Calligrapher NPC (skill affects quality)
-- - Manuscript copying (time-based production)
-- - Gold leaf application
-- - Ink and vellum supply
-- - Manuscript collection

local Calligraphy = {}

local MANUSCRIPTS = {
    bible = { name = "Biblija", time = 90, cost = 500, prestige = 30, faithBonus = 25, description = "Sveto pismo." },
    psalter = { name = "Psaltir", time = 45, cost = 200, prestige = 15, faithBonus = 15, description = "Knjiga psalmov." },
    bestiary = { name = "Bestiarij", time = 30, cost = 150, prestige = 12, knowledge = 20, description = "Knjiga živali." },
    chronicle = { name = "Kronika", time = 60, cost = 300, prestige = 20, knowledge = 30, description = "Zgodovinski zapis." },
    legal = { name = "Pravna knjiga", time = 25, cost = 100, prestige = 5, knowledge = 15, description = "Zakoni in pravila." },
    poetry = { name = "Pesmarica", time = 20, cost = 80, prestige = 10, happiness = 5, description = "Zbirka pesmi." },
}

local ILLUMINATIONS = {
    gold_leaf = { name = "Zlati listič", cost = 50, qualityBonus = 20, description = "Zlata folija za okras." },
    miniature = { name = "Miniatura", cost = 30, qualityBonus = 15, description = "Majhna slika." },
    border = { name = "Okvir", cost = 15, qualityBonus = 8, description = "Decorativni okvir." },
    initial = { name = "Začetnica", cost = 20, qualityBonus = 10, description = "Okrašena začetna črka." },
    full_page = { name = "Celotna stran", cost = 80, qualityBonus = 25, description = "Iluminirana celotna stran." },
    marginalia = { name = "Robni ornament", cost = 10, qualityBonus = 5, description = "Okras v robovih." },
    historiated = { name = "Historirana začetnica", cost = 60, qualityBonus = 22, description = "Začetnica s prizorom." },
    carpet_page = { name = "Preproga stran", cost = 70, qualityBonus = 18, description = "Geometrijski okras." },
}

local BUILDINGS = {
    scriptorium = { name = "Skriptorij", cost = { gold = 400, wood = 100, stone = 50 }, upkeep = 10, qualityBonus = 5, description = "Soba za pisanje." },
    illumination_room = { name = "Iluminacijska soba", cost = { gold = 1200, wood = 200, stone = 200 }, upkeep = 30, qualityBonus = 20, goldLeafBonus = 15, description = "Za iluminacijo rokopisov." },
    bindery = { name = "Vezava", cost = { gold = 600, wood = 200, leather = 50 }, upkeep = 15, qualityBonus = 10, description = "Za vezavo knjig." },
    royal_scriptorium = { name = "Kraljevski skriptorij", cost = { gold = 4000, wood = 400, stone = 800 }, upkeep = 80, qualityBonus = 35, prestigeBonus = 15, description = "Najboljši skriptorij." },
}

Calligraphy.activeCopying = {}
Calligraphy.completedManuscripts = {}
Calligraphy.buildings = {}
Calligraphy.calligrapher = nil
Calligraphy.vellumStock = 20
Calligraphy.inkStock = 20
Calligraphy.totalManuscripts = 0
Calligraphy.dayTimer = 0

function Calligraphy.init()
    Calligraphy.activeCopying = {}
    Calligraphy.completedManuscripts = {}
    Calligraphy.buildings = {}
    Calligraphy.calligrapher = nil
    Calligraphy.vellumStock = 20
    Calligraphy.inkStock = 20
    Calligraphy.totalManuscripts = 0
    Calligraphy.dayTimer = 0
    print("[Calligraphy] Royal Calligrapher & Illumination System initialized (6 manuscripts, 8 illuminations, 4 buildings)")
end

function Calligraphy.hireCalligrapher(name, skill)
    skill = skill or math.random(45, 90)
    local cost = 400 + skill * 8
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Calligraphy.calligrapher = { name = name or ("Kaligraf " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), manuscriptsCopied = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Kaligraf najet: %s (spretnost: %d)", Calligraphy.calligrapher.name, skill), "success") end
    return true
end

function Calligraphy.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Calligraphy.build(id) local ok,e = Calligraphy.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Calligraphy.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Calligraphy.getQualityBonus() local b = 0; for _,bd in ipairs(Calligraphy.buildings) do local d = BUILDINGS[bd.type]; if d and d.qualityBonus then b = b + d.qualityBonus end end; return b end

function Calligraphy.purchaseVellum(amount) local c = amount * 10; if not _G.state or (_G.state.gold or 0) < c then return false, "Premalo zlata" end; _G.state.gold = _G.state.gold - c; Calligraphy.vellumStock = Calligraphy.vellumStock + amount; return true end
function Calligraphy.purchaseInk(amount) local c = amount * 5; if not _G.state or (_G.state.gold or 0) < c then return false, "Premalo zlata" end; _G.state.gold = _G.state.gold - c; Calligraphy.inkStock = Calligraphy.inkStock + amount; return true end

function Calligraphy.canCopy(manuscriptType, illuminationType)
    local def = MANUSCRIPTS[manuscriptType]
    if not def then return false, "Neznan rokopis" end
    if Calligraphy.vellumStock < 5 then return false, "Premalo pergamenta" end
    if Calligraphy.inkStock < 3 then return false, "Premalo črnila" end
    if #Calligraphy.buildings == 0 then return false, "Potreben skriptorij" end
    if not Calligraphy.calligrapher then return false, "Potreben kaligraf" end
    if not _G.state or (_G.state.gold or 0) < def.cost then return false, "Premalo zlata" end
    return true
end

function Calligraphy.copyManuscript(manuscriptType, illuminationType)
    local ok, err = Calligraphy.canCopy(manuscriptType, illuminationType)
    if not ok then return false, err end
    local def = MANUSCRIPTS[manuscriptType]
    local illu = ILLUMINATIONS[illuminationType]
    Calligraphy.vellumStock = Calligraphy.vellumStock - 5
    Calligraphy.inkStock = Calligraphy.inkStock - 3
    _G.state.gold = _G.state.gold - def.cost
    if illu then _G.state.gold = _G.state.gold - illu.cost end
    local copyTime = def.time
    local bonus = Calligraphy.getQualityBonus()
    if Calligraphy.calligrapher then bonus = bonus + math.floor(Calligraphy.calligrapher.skill / 5) end
    copyTime = math.max(5, copyTime - math.floor(bonus / 3))
    table.insert(Calligraphy.activeCopying, {
        id = "ms_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        manuscriptType = manuscriptType, manuscriptName = def.name,
        illuminationType = illuminationType, illuminationName = illu and illu.name or "brez",
        daysRemaining = copyTime, prestige = def.prestige, faithBonus = def.faithBonus or 0,
        knowledge = def.knowledge or 0, happiness = def.happiness or 0,
        illuQuality = illu and illu.qualityBonus or 0, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Kopiranje rokopisa: %s (%d dni)", def.name, copyTime), "info") end
    return true
end

function Calligraphy.completeCopying(c)
    local quality = 1.0 + (Calligraphy.getQualityBonus() / 100) + (c.illuQuality / 100)
    if Calligraphy.calligrapher then quality = quality + (Calligraphy.calligrapher.skill / 200) end
    quality = math.min(2.0, quality)
    local manuscript = { id = c.id, type = c.manuscriptType, name = c.manuscriptName, illumination = c.illuminationName,
        quality = quality, prestige = math.floor(c.prestige * quality), faithBonus = math.floor(c.faithBonus * quality),
        knowledge = math.floor(c.knowledge * quality), happiness = math.floor(c.happiness * quality), completedDay = os.time() }
    table.insert(Calligraphy.completedManuscripts, manuscript)
    Calligraphy.totalManuscripts = Calligraphy.totalManuscripts + 1
    if _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + manuscript.happiness) end
    if manuscript.faithBonus > 0 and _G.Religion then pcall(_G.Religion.addFaith, manuscript.faithBonus) end
    if manuscript.knowledge > 0 and _G.Culture then pcall(function() _G.Culture.knowledgePoints = (_G.Culture.knowledgePoints or 0) + manuscript.knowledge end) end
    if Calligraphy.calligrapher then Calligraphy.calligrapher.manuscriptsCopied = Calligraphy.calligrapher.manuscriptsCopied + 1; if math.random() < 0.20 then Calligraphy.calligrapher.skill = math.min(100, Calligraphy.calligrapher.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Rokopis dokončan: %s (kakovost: %.1f)", c.manuscriptName, quality), "success") end
end

function Calligraphy.update(dt)
    if not _G.state then return end
    Calligraphy.dayTimer = Calligraphy.dayTimer + dt
    if Calligraphy.dayTimer >= 30 then
        Calligraphy.dayTimer = 0
        for i = #Calligraphy.activeCopying, 1, -1 do
            local c = Calligraphy.activeCopying[i]
            c.daysRemaining = c.daysRemaining - 1
            if c.daysRemaining <= 0 then Calligraphy.completeCopying(c); table.remove(Calligraphy.activeCopying, i) end
        end
        local totalUpkeep = 0
        for _, b in ipairs(Calligraphy.buildings) do local d = BUILDINGS[b.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Calligraphy.calligrapher then totalUpkeep = totalUpkeep + 20 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Calligraphy.getManuscriptInfo(id) return MANUSCRIPTS[id] end
function Calligraphy.getIlluminationInfo(id) return ILLUMINATIONS[id] end
function Calligraphy.getBuildingInfo(id) return BUILDINGS[id] end
function Calligraphy.getStats()
    return { activeCopying = #Calligraphy.activeCopying, completedManuscripts = #Calligraphy.completedManuscripts,
        numBuildings = #Calligraphy.buildings, hasCalligrapher = Calligraphy.calligrapher ~= nil,
        calligrapherName = Calligraphy.calligrapher and Calligraphy.calligrapher.name or "—",
        calligrapherSkill = Calligraphy.calligrapher and Calligraphy.calligrapher.skill or 0,
        vellumStock = Calligraphy.vellumStock, inkStock = Calligraphy.inkStock,
        totalManuscripts = Calligraphy.totalManuscripts }
end

return Calligraphy
