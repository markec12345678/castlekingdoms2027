-- objects/Economy/RoyalWoodworkerCarpenterSystem.lua
-- Castle Kingdoms 2027 v3.7.7 - Royal Woodworker & Carpenter System
--
-- Manages furniture making, wood carving, and carpentry.
-- Provides furniture, decorative items, and construction components.
--
-- Features:
-- - 6 furniture types (throne, table, chair, chest, bed, cabinet)
-- - 8 wood types (oak, walnut, mahogany, pine, cedar, ebony, cherry, birch)
-- - 4 woodworking buildings (carpentry shop, carving studio, sawmill, royal workshop)
-- - Woodworker NPC (skill affects quality)
-- - Furniture making (time-based with quality)
-- - Wood carving and decoration
-- - Construction components supply

local Woodworker = {}

local FURNITURE = {
    throne = { name = "Prestol", woodCost = 20, time = 30, cost = 1000, prestige = 30, happiness = 5, description = "Kraljevski prestol." },
    table = { name = "Miza", woodCost = 8, time = 7, cost = 200, prestige = 5, happiness = 2, description = "Velika lesena miza." },
    chair = { name = "Stol", woodCost = 3, time = 3, cost = 80, happiness = 1, description = "Leseni stol." },
    chest = { name = "Skrinja", woodCost = 5, time = 5, cost = 150, happiness = 1, description = "Skladiščna skrinja." },
    bed = { name = "Postelja", woodCost = 12, time = 10, cost = 400, happiness = 5, description = "Velika lesena postelja." },
    cabinet = { name = "Omara", woodCost = 10, time = 8, cost = 300, prestige = 3, happiness = 2, description = "Okrasna omara." },
}

local WOODS = {
    oak = { name = "Hrast", cost = 15, qualityBonus = 10, durability = 80, description = "Trdno in trajno." },
    walnut = { name = "Oreh", cost = 40, qualityBonus = 20, prestige = 3, description = "Temno in elegantno." },
    mahogany = { name = "Mahagonij", cost = 80, qualityBonus = 30, prestige = 8, description = "Rdečkasti luksuz." },
    pine = { name = "Bor", cost = 5, qualityBonus = 3, description = "Mehko in poceni." },
    cedar = { name = "Cedra", cost = 30, qualityBonus = 15, aroma = 5, description = "Dišeča in odporna." },
    ebony = { name = "Ebenovina", cost = 200, qualityBonus = 45, prestige = 15, description = "Črna in najdražja." },
    cherry = { name = "Češnja", cost = 50, qualityBonus = 25, prestige = 5, description = "Rdečkasta in lepa." },
    birch = { name = "Breza", cost = 10, qualityBonus = 8, description = "Svetla in prožna." },
}

local BUILDINGS = {
    carpentry_shop = { name = "Mizarska delavnica", cost = { gold = 300, wood = 150 }, upkeep = 10, qualityBonus = 5, description = "Osnovna mizarska delavnica." },
    carving_studio = { name = "Rezbarski atelje", cost = { gold = 1000, wood = 200, stone = 100 }, upkeep = 25, qualityBonus = 20, description = "Za fine rezbarije." },
    sawmill = { name = "Žaga", cost = { gold = 800, wood = 200, stone = 200, iron = 50 }, upkeep = 20, woodProduction = 5, description = "Za predelovo hlodovine." },
    royal_workshop = { name = "Kraljevska delavnica", cost = { gold = 5000, wood = 400, stone = 800 }, upkeep = 100, qualityBonus = 40, prestigeBonus = 20, description = "Najboljša delavnica za kralja." },
}

Woodworker.woodStock = {}
Woodworker.furnitureStock = {}
Woodworker.buildings = {}
Woodworker.woodworker = nil
Woodworker.activeMaking = {}
Woodworker.totalFurniture = 0
Woodworker.dayTimer = 0

function Woodworker.init()
    Woodworker.woodStock = {}
    Woodworker.furnitureStock = {}
    Woodworker.buildings = {}
    Woodworker.woodworker = nil
    Woodworker.activeMaking = {}
    Woodworker.totalFurniture = 0
    Woodworker.dayTimer = 0
    print("[Woodworker] Royal Woodworker & Carpenter System initialized (6 furniture, 8 woods, 4 buildings)")
end

function Woodworker.hireWoodworker(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 300 + skill * 6
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Woodworker.woodworker = { name = name or ("Mizar " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), itemsMade = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Mizar najet: %s (spretnost: %d)", Woodworker.woodworker.name, skill), "success") end
    return true
end

function Woodworker.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Woodworker.build(id) local ok,e = Woodworker.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Woodworker.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Woodworker.getQualityBonus() local b = 0; for _,bd in ipairs(Woodworker.buildings) do local d = BUILDINGS[bd.type]; if d and d.qualityBonus then b = b + d.qualityBonus end end; return b end

function Woodworker.purchaseWood(woodType, quantity)
    local def = WOODS[woodType]; if not def then return false, "Neznano les" end
    quantity = quantity or 1; local cost = def.cost * quantity
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Woodworker.woodStock[woodType] = (Woodworker.woodStock[woodType] or 0) + quantity
    return true
end

function Woodworker.canMake(furnitureType, woodType)
    local fDef = FURNITURE[furnitureType]; local wDef = WOODS[woodType]
    if not fDef or not wDef then return false, "Neznano pohištvo ali les" end
    if (Woodworker.woodStock[woodType] or 0) < fDef.woodCost then return false, "Premalo lesa" end
    if #Woodworker.buildings == 0 then return false, "Potrebna mizarska zgradba" end
    if not Woodworker.woodworker then return false, "Potreben mizar" end
    return true
end

function Woodworker.make(furnitureType, woodType)
    local ok, err = Woodworker.canMake(furnitureType, woodType)
    if not ok then return false, err end
    local fDef = FURNITURE[furnitureType]; local wDef = WOODS[woodType]
    Woodworker.woodStock[woodType] = Woodworker.woodStock[woodType] - fDef.woodCost
    local makeTime = fDef.time
    if Woodworker.woodworker then makeTime = math.max(1, makeTime - math.floor(Woodworker.woodworker.skill / 8)) end
    table.insert(Woodworker.activeMaking, {
        id = "furn_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        furnitureType = furnitureType, furnitureName = fDef.name, woodType = woodType, woodName = wDef.name,
        woodQuality = wDef.qualityBonus, woodPrestige = wDef.prestige or 0, woodAroma = wDef.aroma or 0,
        cost = fDef.cost, prestige = fDef.prestige or 0, happiness = fDef.happiness or 0,
        daysRemaining = makeTime, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Izdelava: %s iz %s (%d dni)", fDef.name, wDef.name, makeTime), "info") end
    return true
end

function Woodworker.completeMaking(m)
    local quality = 1.0 + (Woodworker.getQualityBonus() / 100) + (m.woodQuality / 100)
    if Woodworker.woodworker then quality = quality + (Woodworker.woodworker.skill / 200) end
    quality = math.min(2.5, quality)
    Woodworker.furnitureStock[m.furnitureType] = Woodworker.furnitureStock[m.furnitureType] or {}
    table.insert(Woodworker.furnitureStock[m.furnitureType], {
        id = m.id, wood = m.woodName, quality = quality,
        value = math.floor(m.cost * quality), prestige = math.floor((m.prestige + m.woodPrestige) * quality),
        happiness = math.floor((m.happiness + m.woodAroma) * quality), madeDay = os.time(),
    })
    Woodworker.totalFurniture = Woodworker.totalFurniture + 1
    if Woodworker.woodworker then Woodworker.woodworker.itemsMade = Woodworker.woodworker.itemsMade + 1; if math.random() < 0.15 then Woodworker.woodworker.skill = math.min(100, Woodworker.woodworker.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Pohištvo izdelano: %s %s (kakovost: %.1f)", m.woodName, m.furnitureName, quality), "success") end
end

function Woodworker.sellFurniture(furnitureType, index)
    if not Woodworker.furnitureStock[furnitureType] or not Woodworker.furnitureStock[furnitureType][index] then return false, "Pohištvo ne obstaja" end
    local f = table.remove(Woodworker.furnitureStock[furnitureType], index)
    if _G.state then _G.state.gold = (_G.state.gold or 0) + f.value end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Pohištvo prodano: %s za %d zlata", f.type or furnitureType, f.value), "success") end
    return true
end

function Woodworker.useFurniture(furnitureType, index)
    if not Woodworker.furnitureStock[furnitureType] or not Woodworker.furnitureStock[furnitureType][index] then return false, "Pohištvo ne obstaja" end
    local f = table.remove(Woodworker.furnitureStock[furnitureType], index)
    if _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + f.happiness + f.prestige) end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Pohištvo v uporabi: %s (+%d sreče)", furnitureType, f.happiness + f.prestige), "info") end
    return true
end

function Woodworker.update(dt)
    if not _G.state then return end
    Woodworker.dayTimer = Woodworker.dayTimer + dt
    if Woodworker.dayTimer >= 30 then
        Woodworker.dayTimer = 0
        for i = #Woodworker.activeMaking, 1, -1 do
            local m = Woodworker.activeMaking[i]
            m.daysRemaining = m.daysRemaining - 1
            if m.daysRemaining <= 0 then Woodworker.completeMaking(m); table.remove(Woodworker.activeMaking, i) end
        end
        local totalUpkeep = 0
        for _, bd in ipairs(Woodworker.buildings) do local d = BUILDINGS[bd.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Woodworker.woodworker then totalUpkeep = totalUpkeep + 12 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Woodworker.getFurnitureInfo(id) return FURNITURE[id] end
function Woodworker.getWoodInfo(id) return WOODS[id] end
function Woodworker.getBuildingInfo(id) return BUILDINGS[id] end
function Woodworker.getStats()
    local totalItems = 0
    for _, items in pairs(Woodworker.furnitureStock) do totalItems = totalItems + #items end
    return { numFurniture = totalItems, woodStock = Woodworker.woodStock,
        numBuildings = #Woodworker.buildings, hasWoodworker = Woodworker.woodworker ~= nil,
        woodworkerName = Woodworker.woodworker and Woodworker.woodworker.name or "—",
        woodworkerSkill = Woodworker.woodworker and Woodworker.woodworker.skill or 0,
        activeMaking = #Woodworker.activeMaking, totalFurniture = Woodworker.totalFurniture }
end

return Woodworker
