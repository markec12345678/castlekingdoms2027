-- objects/Economy/RoyalPerfumerFragranceSystem.lua
-- Castle Kingdoms 2027 v3.6.5 - Royal Perfumer & Fragrance System
--
-- Manages perfume making, fragrance blending, and scented products.
-- Perfumes provide happiness, prestige, and diplomatic gifts.
--
-- Features:
-- - 8 fragrance ingredients (rose, lavender, jasmine, sandalwood, musk, amber, frankincense, myrrh)
-- - 6 perfume types (eau de cologne, toilette, parfum, attar, pomander, incense)
-- - 4 perfumer buildings (distillery, workshop, aging cellar, royal perfumery)
-- - Perfumer NPC (skill affects quality)
-- - Fragrance blending (time-based with quality)
-- - Essential oil distillation
-- - Scented gifts for diplomacy
-- - Aroma happiness bonuses

local Perfumer = {}

local INGREDIENTS = {
    rose = { name = "Vrtnica", cost = 20, aromaStrength = 8, description = "Klasična dišeča vrtnica." },
    lavender = { name = "Sivka", cost = 15, aromaStrength = 6, description = "Umirjujoča sivka." },
    jasmine = { name = "Jasmin", cost = 30, aromaStrength = 10, description = "Sladki, cvetlični jasmin." },
    sandalwood = { name = "Sandalovina", cost = 40, aromaStrength = 7, description = "Topel, leseni vonj." },
    musk = { name = "Mošus", cost = 80, aromaStrength = 12, description = "Živalski, močan vonj." },
    amber = { name = "Jantar", cost = 60, aromaStrength = 9, description = "Topel, sladek vonj." },
    frankincense = { name = "Kadilo", cost = 50, aromaStrength = 8, faithBonus = 5, description = "Ceremonialno kadilo." },
    myrrh = { name = "Mira", cost = 55, aromaStrength = 7, faithBonus = 5, description = "Sveto dišavno olje." },
}

local PERFUMES = {
    cologne = { name = "Eau de Cologne", ingredients = 2, time = 5, cost = 100, happiness = 3, description = "Lahka, osvežujoča dišava." },
    toilette = { name = "Eau de Toilette", ingredients = 3, time = 7, cost = 200, happiness = 5, description = "Srednje močna dišava." },
    parfum = { name = "Parfum", ingredients = 4, time = 14, cost = 500, happiness = 8, prestige = 5, description = "Koncentrirana dišava." },
    attar = { name = "Attar", ingredients = 5, time = 30, cost = 1000, happiness = 12, prestige = 10, description = "Najčistejše eterično olje." },
    pomander = { name = "Pomander", ingredients = 3, time = 10, cost = 300, happiness = 6, health = 5, description = "Dišeča krogla proti boleznim." },
    incense = { name = "Kadilo", ingredients = 2, time = 3, cost = 80, happiness = 4, faith = 10, description = "Dišava za cerkev." },
}

local BUILDINGS = {
    distillery = { name = "Destilarna", cost = { gold = 500, wood = 200, copper = 50 }, upkeep = 15, qualityBonus = 10, description = "Za destilacijo eteričnih olj." },
    workshop = { name = "Perfumerska delavnica", cost = { gold = 300, wood = 100 }, upkeep = 10, qualityBonus = 5, description = "Za mešanje dišav." },
    aging_cellar = { name = "Sklep za staranje", cost = { gold = 1500, wood = 200, stone = 400 }, upkeep = 30, agingBonus = 20, qualityBonus = 15, description = "Za staranje parfumov." },
    royal_perfumery = { name = "Kraljevska perfumerija", cost = { gold = 4000, wood = 400, stone = 800 }, upkeep = 80, qualityBonus = 35, prestigeBonus = 15, description = "Najboljša perfumerija." },
}

Perfumer.ingredientStock = {}
Perfumer.perfumeStock = {}
Perfumer.buildings = {}
Perfumer.perfumer = nil
Perfumer.activeBlending = {}
Perfumer.totalPerfumesMade = 0
Perfumer.dayTimer = 0

function Perfumer.init()
    Perfumer.ingredientStock = {}
    Perfumer.perfumeStock = {}
    Perfumer.buildings = {}
    Perfumer.perfumer = nil
    Perfumer.activeBlending = {}
    Perfumer.totalPerfumesMade = 0
    Perfumer.dayTimer = 0
    print("[Perfumer] Royal Perfumer & Fragrance System initialized (8 ingredients, 6 perfumes, 4 buildings)")
end

function Perfumer.hirePerfumer(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 400 + skill * 8
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Perfumer.perfumer = { name = name or ("Perfumist " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), perfumesMade = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Perfumist najet: %s (spretnost: %d)", Perfumer.perfumer.name, skill), "success") end
    return true
end

function Perfumer.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Perfumer.build(id) local ok,e = Perfumer.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Perfumer.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Perfumer.getQualityBonus() local b = 0; for _,bd in ipairs(Perfumer.buildings) do local d = BUILDINGS[bd.type]; if d and d.qualityBonus then b = b + d.qualityBonus end end; return b end

function Perfumer.purchaseIngredient(ingredientType, quantity)
    local def = INGREDIENTS[ingredientType]
    if not def then return false, "Neznana sestavina" end
    quantity = quantity or 1
    local cost = def.cost * quantity
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Perfumer.ingredientStock[ingredientType] = (Perfumer.ingredientStock[ingredientType] or 0) + quantity
    return true
end

function Perfumer.canBlend(perfumeType, ingredients)
    local def = PERFUMES[perfumeType]
    if not def then return false, "Neznan parfum" end
    if not ingredients or #ingredients < def.ingredients then return false, "Potrebnih vsaj " .. def.ingredients .. " sestavin" end
    for _, ing in ipairs(ingredients) do
        if (Perfumer.ingredientStock[ing] or 0) < 1 then return false, "Premalo " .. (INGREDIENTS[ing] and INGREDIENTS[ing].name or ing) end
    end
    if not _G.state or (_G.state.gold or 0) < def.cost then return false, "Premalo zlata" end
    if #Perfumer.buildings == 0 then return false, "Potrebna perfumerska zgradba" end
    if not Perfumer.perfumer then return false, "Potreben perfumist" end
    return true
end

function Perfumer.blend(perfumeType, ingredients)
    local ok, err = Perfumer.canBlend(perfumeType, ingredients)
    if not ok then return false, err end
    local def = PERFUMES[perfumeType]
    _G.state.gold = _G.state.gold - def.cost
    local aromaStrength = 0
    local faithBonus = 0
    for _, ing in ipairs(ingredients) do
        Perfumer.ingredientStock[ing] = Perfumer.ingredientStock[ing] - 1
        local iDef = INGREDIENTS[ing]
        if iDef then
            aromaStrength = aromaStrength + iDef.aromaStrength
            if iDef.faithBonus then faithBonus = faithBonus + iDef.faithBonus end
        end
    end
    local blendTime = def.time
    local bonus = Perfumer.getQualityBonus()
    if Perfumer.perfumer then bonus = bonus + math.floor(Perfumer.perfumer.skill / 5) end
    blendTime = math.max(1, blendTime - math.floor(bonus / 10))
    table.insert(Perfumer.activeBlending, {
        id = "perf_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        perfumeType = perfumeType, perfumeName = def.name,
        daysRemaining = blendTime, happiness = def.happiness, prestige = def.prestige or 0,
        faith = faithBonus + (def.faith or 0), health = def.health or 0,
        aromaStrength = aromaStrength, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Mešanje parfuma: %s (%d dni)", def.name, blendTime), "info") end
    return true
end

function Perfumer.completeBlending(b)
    local quality = 1.0 + (Perfumer.getQualityBonus() / 100) + (b.aromaStrength / 200)
    if Perfumer.perfumer then quality = quality + (Perfumer.perfumer.skill / 200) end
    quality = math.min(2.0, quality)
    Perfumer.perfumeStock[b.perfumeType] = (Perfumer.perfumeStock[b.perfumeType] or 0) + 1
    Perfumer.totalPerfumesMade = Perfumer.totalPerfumesMade + 1
    if Perfumer.perfumer then Perfumer.perfumer.perfumesMade = Perfumer.perfumer.perfumesMade + 1; if math.random() < 0.15 then Perfumer.perfumer.skill = math.min(100, Perfumer.perfumer.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Parfum izdelan: %s (kakovost: %.1f)", b.perfumeName, quality), "success") end
end

function Perfumer.usePerfume(perfumeType)
    if (Perfumer.perfumeStock[perfumeType] or 0) < 1 then return false, "Ni na zalogi" end
    Perfumer.perfumeStock[perfumeType] = Perfumer.perfumeStock[perfumeType] - 1
    local def = PERFUMES[perfumeType]
    if def.happiness and _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + def.happiness) end
    if def.prestige and _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + def.prestige) end
    if def.faith and _G.Religion then pcall(_G.Religion.addFaith, def.faith) end
    if def.health and _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + def.health) end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Parfum uporabljen: " .. def.name, "info") end
    return true
end

function Perfumer.sellPerfume(perfumeType, quantity)
    if (Perfumer.perfumeStock[perfumeType] or 0) < quantity then return false, "Ni dovolj na zalogi" end
    Perfumer.perfumeStock[perfumeType] = Perfumer.perfumeStock[perfumeType] - quantity
    local def = PERFUMES[perfumeType]
    local revenue = def.cost * quantity
    if _G.state then _G.state.gold = (_G.state.gold or 0) + revenue end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Prodano: %d %s za %d zlata", quantity, def.name, revenue), "success") end
    return true
end

function Perfumer.update(dt)
    if not _G.state then return end
    Perfumer.dayTimer = Perfumer.dayTimer + dt
    if Perfumer.dayTimer >= 30 then
        Perfumer.dayTimer = 0
        for i = #Perfumer.activeBlending, 1, -1 do
            local b = Perfumer.activeBlending[i]
            b.daysRemaining = b.daysRemaining - 1
            if b.daysRemaining <= 0 then Perfumer.completeBlending(b); table.remove(Perfumer.activeBlending, i) end
        end
        local totalUpkeep = 0
        for _, bd in ipairs(Perfumer.buildings) do local d = BUILDINGS[bd.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Perfumer.perfumer then totalUpkeep = totalUpkeep + 15 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Perfumer.getIngredientInfo(id) return INGREDIENTS[id] end
function Perfumer.getPerfumeInfo(id) return PERFUMES[id] end
function Perfumer.getBuildingInfo(id) return BUILDINGS[id] end
function Perfumer.getStats()
    return { ingredientStock = Perfumer.ingredientStock, perfumeStock = Perfumer.perfumeStock,
        numBuildings = #Perfumer.buildings, hasPerfumer = Perfumer.perfumer ~= nil,
        perfumerName = Perfumer.perfumer and Perfumer.perfumer.name or "—",
        perfumerSkill = Perfumer.perfumer and Perfumer.perfumer.skill or 0,
        activeBlending = #Perfumer.activeBlending, totalPerfumesMade = Perfumer.totalPerfumesMade }
end

return Perfumer
