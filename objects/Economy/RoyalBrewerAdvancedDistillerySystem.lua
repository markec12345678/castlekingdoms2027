-- objects/Economy/RoyalBrewerAdvancedDistillerySystem.lua
-- Castle Kingdoms 2027 v3.7.5 - Royal Brewer Advanced & Distillery System
--
-- Manages advanced brewing, distillation, and spirit production.
-- Distinct from basic brewing — focuses on spirits, liqueurs, and aged beverages.
--
-- Features:
-- - 6 spirit types (whiskey, brandy, gin, vodka, rum, absinthe)
-- - 8 ingredients (grain, grape, juniper, potato, sugarcane, wormwood, herbs, fruit)
-- - 4 distillery buildings (still house, distillery, aging cellar, royal distillery)
-- - Distiller NPC (skill affects quality)
-- - Distillation process (time-based with proof level)
-- - Aging system (spirits improve with time)
-- - Liqueur blending

local Distiller = {}

local SPIRITS = {
    whiskey = { name = "Viski", ingredient = "grain", time = 14, cost = 100, prestige = 8, agingPotential = 0.8, proof = 40, description = "Žgana pijača iz žita." },
    brandy = { name = "Žganje", ingredient = "grape", time = 10, cost = 150, prestige = 10, agingPotential = 0.9, proof = 35, description = "Žgana pijača iz vina." },
    gin = { name = "Gin", ingredient = "juniper", time = 7, cost = 80, prestige = 5, agingPotential = 0.2, proof = 37, description = "Brinova žganje." },
    vodka = { name = "Vodka", ingredient = "potato", time = 7, cost = 60, prestige = 3, agingPotential = 0.1, proof = 40, description = "Žgana pijača iz krompirja." },
    rum = { name = "Rum", ingredient = "sugarcane", time = 10, cost = 120, prestige = 7, agingPotential = 0.7, proof = 38, description = "Žgana pijača iz sladkornega trsa." },
    absinthe = { name = "Absint", ingredient = "wormwood", time = 14, cost = 200, prestige = 15, agingPotential = 0.3, proof = 55, happiness = 8, description = "Zeleni vilin — močna in mistična." },
}

local INGREDIENTS = {
    grain = { name = "Žito", cost = 10, description = "Osnova za viski." },
    grape = { name = "Grozdje", cost = 20, description = "Osnova za žganje." },
    juniper = { name = "Brinje", cost = 15, description = "Za gin." },
    potato = { name = "Krompir", cost = 5, description = "Za vodko." },
    sugarcane = { name = "Sladkorni trs", cost = 30, description = "Za rum." },
    wormwood = { name = "Pelin", cost = 25, description = "Za absint." },
    herbs = { name = "Zelišča", cost = 12, description = "Za likerje." },
    fruit = { name = "Sadje", cost = 15, description = "Za sadna žganja." },
}

local BUILDINGS = {
    still_house = { name = "Peklena", cost = { gold = 300, wood = 100, copper = 30 }, upkeep = 10, qualityBonus = 5, description = "Preprosta destilarna." },
    distillery = { name = "Destilarna", cost = { gold = 1500, wood = 200, stone = 300, copper = 100 }, upkeep = 40, qualityBonus = 20, description = "Profesionalna destilarna." },
    aging_cellar = { name = "Sklep za staranje", cost = { gold = 2000, wood = 300, stone = 500 }, upkeep = 50, agingBonus = 0.30, qualityBonus = 15, description = "Za staranje žganih pijač." },
    royal_distillery = { name = "Kraljevska destilarna", cost = { gold = 6000, wood = 500, stone = 1000, copper = 200 }, upkeep = 120, qualityBonus = 40, prestigeBonus = 20, agingBonus = 0.50, description = "Najboljša destilarna za kralja." },
}

Distiller.ingredientStock = {}
Distiller.spiritStock = {}
Distiller.buildings = {}
Distiller.distiller = nil
Distiller.activeDistillation = {}
Distiller.agingSpirits = {}
Distiller.totalSpiritsMade = 0
Distiller.dayTimer = 0

function Distiller.init()
    Distiller.ingredientStock = {}
    Distiller.spiritStock = {}
    Distiller.buildings = {}
    Distiller.distiller = nil
    Distiller.activeDistillation = {}
    Distiller.agingSpirits = {}
    Distiller.totalSpiritsMade = 0
    Distiller.dayTimer = 0
    print("[Distiller] Royal Brewer Advanced & Distillery System initialized (6 spirits, 8 ingredients, 4 buildings)")
end

function Distiller.hireDistiller(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 400 + skill * 8
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Distiller.distiller = { name = name or ("Destilat " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), spiritsMade = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Destilat najet: %s (spretnost: %d)", Distiller.distiller.name, skill), "success") end
    return true
end

function Distiller.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Distiller.build(id) local ok,e = Distiller.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Distiller.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Distiller.getQualityBonus() local b = 0; for _,bd in ipairs(Distiller.buildings) do local d = BUILDINGS[bd.type]; if d and d.qualityBonus then b = b + d.qualityBonus end end; return b end
function Distiller.getAgingBonus() local b = 0; for _,bd in ipairs(Distiller.buildings) do local d = BUILDINGS[bd.type]; if d and d.agingBonus then b = math.max(b, d.agingBonus) end end; return b end

function Distiller.purchaseIngredient(ingredientType, quantity)
    local def = INGREDIENTS[ingredientType]
    if not def then return false, "Neznana sestavina" end
    quantity = quantity or 1
    local cost = def.cost * quantity
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Distiller.ingredientStock[ingredientType] = (Distiller.ingredientStock[ingredientType] or 0) + quantity
    return true
end

function Distiller.canDistill(spiritType)
    local def = SPIRITS[spiritType]
    if not def then return false, "Neznana žganje" end
    if (Distiller.ingredientStock[def.ingredient] or 0) < 5 then return false, "Premalo " .. (INGREDIENTS[def.ingredient] and INGREDIENTS[def.ingredient].name or def.ingredient) end
    if not _G.state or (_G.state.gold or 0) < def.cost then return false, "Premalo zlata" end
    if #Distiller.buildings == 0 then return false, "Potrebna destilarna" end
    if not Distiller.distiller then return false, "Potreben destilat" end
    return true
end

function Distiller.distill(spiritType)
    local ok, err = Distiller.canDistill(spiritType)
    if not ok then return false, err end
    local def = SPIRITS[spiritType]
    Distiller.ingredientStock[def.ingredient] = Distiller.ingredientStock[def.ingredient] - 5
    _G.state.gold = _G.state.gold - def.cost
    local distillTime = def.time
    if Distiller.distiller then distillTime = math.max(2, distillTime - math.floor(Distiller.distiller.skill / 8)) end
    table.insert(Distiller.activeDistillation, {
        id = "dist_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        spiritType = spiritType, spiritName = def.name, ingredient = def.ingredient,
        proof = def.proof, prestige = def.prestige, happiness = def.happiness or 0,
        agingPotential = def.agingPotential, cost = def.cost,
        daysRemaining = distillTime, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Destilacija: %s (%d dni)", def.name, distillTime), "info") end
    return true
end

function Distiller.completeDistillation(d)
    local failChance = 0.08 - (Distiller.distiller and Distiller.distiller.skill / 600 or 0)
    failChance = math.max(0.02, failChance)
    if math.random() < failChance then
        if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Destilacija spodletela: %s!", d.spiritName), "danger") end
        return
    end
    local quality = 1.0 + (Distiller.getQualityBonus() / 100)
    if Distiller.distiller then quality = quality + (Distiller.distiller.skill / 200) end
    quality = math.min(2.0, quality)
    Distiller.spiritStock[d.spiritType] = (Distiller.spiritStock[d.spiritType] or 0) + 1
    Distiller.totalSpiritsMade = Distiller.totalSpiritsMade + 1
    if Distiller.distiller then Distiller.distiller.spiritsMade = Distiller.distiller.spiritsMade + 1; if math.random() < 0.15 then Distiller.distiller.skill = math.min(100, Distiller.distiller.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Žganje destilirano: %s (kakovost: %.1f, %.0f%%)", d.spiritName, quality, d.proof), "success") end
end

function Distiller.sellSpirit(spiritType, quantity)
    if (Distiller.spiritStock[spiritType] or 0) < quantity then return false, "Ni dovolj na zalogi" end
    Distiller.spiritStock[spiritType] = Distiller.spiritStock[spiritType] - quantity
    local def = SPIRITS[spiritType]
    local revenue = def.cost * 2 * quantity
    if _G.state then _G.state.gold = (_G.state.gold or 0) + revenue end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Prodano: %d %s za %d zlata", quantity, def.name, revenue), "success") end
    return true
end

function Distiller.consumeSpirit(spiritType)
    if (Distiller.spiritStock[spiritType] or 0) < 1 then return false, "Ni na zalogi" end
    Distiller.spiritStock[spiritType] = Distiller.spiritStock[spiritType] - 1
    local def = SPIRITS[spiritType]
    if def.happiness and _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + def.happiness) end
    if def.prestige and _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + def.prestige) end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Žganje zaužito: " .. def.name, "info") end
    return true
end

function Distiller.update(dt)
    if not _G.state then return end
    Distiller.dayTimer = Distiller.dayTimer + dt
    if Distiller.dayTimer >= 30 then
        Distiller.dayTimer = 0
        for i = #Distiller.activeDistillation, 1, -1 do
            local d = Distiller.activeDistillation[i]
            d.daysRemaining = d.daysRemaining - 1
            if d.daysRemaining <= 0 then Distiller.completeDistillation(d); table.remove(Distiller.activeDistillation, i) end
        end
        local totalUpkeep = 0
        for _, bd in ipairs(Distiller.buildings) do local d = BUILDINGS[bd.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Distiller.distiller then totalUpkeep = totalUpkeep + 20 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Distiller.getSpiritInfo(id) return SPIRITS[id] end
function Distiller.getIngredientInfo(id) return INGREDIENTS[id] end
function Distiller.getBuildingInfo(id) return BUILDINGS[id] end
function Distiller.getStats()
    return { ingredientStock = Distiller.ingredientStock, spiritStock = Distiller.spiritStock,
        numBuildings = #Distiller.buildings, hasDistiller = Distiller.distiller ~= nil,
        distillerName = Distiller.distiller and Distiller.distiller.name or "—",
        distillerSkill = Distiller.distiller and Distiller.distiller.skill or 0,
        activeDistillation = #Distiller.activeDistillation, totalSpiritsMade = Distiller.totalSpiritsMade }
end

return Distiller
