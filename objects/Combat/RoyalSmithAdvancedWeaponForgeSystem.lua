-- objects/Combat/RoyalSmithAdvancedWeaponForgeSystem.lua
-- Castle Kingdoms 2027 v3.7.6 - Royal Smith Advanced & Weapon Forge System
--
-- Manages advanced weapon forging, armor crafting, and military equipment.
-- Provides high-quality weapons and armor for the royal army.
--
-- Features:
-- - 6 weapon categories (sword, spear, axe, mace, bow, crossbow)
-- - 8 metal alloys (iron, steel, Damascus, bronze, silver-inlaid, gold-inlaid, enchanted, meteoric)
-- - 4 forge buildings (smithy, armory, weapons forge, royal armory)
-- - Master Smith NPC (skill affects quality)
-- - Weapon forging (time-based with risk of defects)
-- - Armor crafting
-- - Quality grading (common, fine, superior, masterwork, legendary)
-- - Military equipment supply

local Forge = {}

local WEAPONS = {
    sword = { name = "Meč", metalCost = 5, time = 10, attack = 20, cost = 100, description = "Standardni meč." },
    spear = { name = "Kopje", metalCost = 3, time = 5, attack = 15, cost = 50, description = "Dolgo kopje." },
    axe = { name = "Sekira", metalCost = 4, time = 7, attack = 18, cost = 80, description = "Bojna sekira." },
    mace = { name = "Buzdovan", metalCost = 4, time = 6, attack = 16, cost = 70, description = "Težki buzdovan." },
    bow = { name = "Lok", metalCost = 1, time = 5, attack = 12, cost = 40, description = "Dolgi lok." },
    crossbow = { name = "Samostrel", metalCost = 3, time = 12, attack = 25, cost = 150, description = "Samostrel z mehanizmom." },
}

local ALLOYS = {
    iron = { name = "Železo", cost = 15, qualityBonus = 5, description = "Pogost in trden." },
    steel = { name = "Jeklo", cost = 30, qualityBonus = 15, description = "Kaljeno jeklo." },
    damascus = { name = "Damask", cost = 100, qualityBonus = 30, prestige = 5, description = "Vzorcana damask jekla." },
    bronze = { name = "Bron", cost = 25, qualityBonus = 10, description = "Klasična zlitina." },
    silver_inlaid = { name = "Srebrno okrašen", cost = 80, qualityBonus = 20, prestige = 8, faith = 5, description = "S srebrnim okrasjem." },
    gold_inlaid = { name = "Zlato okrašen", cost = 200, qualityBonus = 25, prestige = 15, description = "Z zlatim okrasjem za kralja." },
    enchanted = { name = "Začarano", cost = 500, qualityBonus = 50, prestige = 20, happiness = 5, description = "Z magičnimi lastnostmi." },
    meteoric = { name = "Meteorno železo", cost = 1000, qualityBonus = 60, prestige = 30, description = "Iz meteorita — redko in močno." },
}

local BUILDINGS = {
    smithy = { name = "Kovašnica", cost = { gold = 300, wood = 100, stone = 100, iron = 50 }, upkeep = 10, qualityBonus = 5, description = "Osnovna kovašnica." },
    armory = { name = "Orožarna", cost = { gold = 1000, wood = 200, stone = 300, iron = 100 }, upkeep = 25, qualityBonus = 15, storageCapacity = 50, description = "Skladišče orožja in oklepa." },
    weapons_forge = { name = "Kovašnica orožja", cost = { gold = 2500, wood = 300, stone = 500, iron = 200 }, upkeep = 50, qualityBonus = 30, prestigeBonus = 10, description = "Specializirana za orožje." },
    royal_armory = { name = "Kraljevska orožarna", cost = { gold = 6000, wood = 500, stone = 1000, iron = 400 }, upkeep = 120, qualityBonus = 45, prestigeBonus = 25, description = "Najboljša orožarna za kralja." },
}

Forge.metalStock = {}
Forge.weaponStock = {}
Forge.buildings = {}
Forge.smith = nil
Forge.activeForging = {}
Forge.totalWeaponsForged = 0
Forge.dayTimer = 0

function Forge.init()
    Forge.metalStock = {}
    Forge.weaponStock = {}
    Forge.buildings = {}
    Forge.smith = nil
    Forge.activeForging = {}
    Forge.totalWeaponsForged = 0
    Forge.dayTimer = 0
    print("[Forge] Royal Smith Advanced & Weapon Forge System initialized (6 weapons, 8 alloys, 4 buildings)")
end

function Forge.hireSmith(name, skill)
    skill = skill or math.random(45, 90)
    local cost = 500 + skill * 10
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Forge.smith = { name = name or ("Kovač " .. math.random(1, 99)), skill = skill, hiredDay = os.time(), weaponsForged = 0 }
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Kovač najet: %s (spretnost: %d)", Forge.smith.name, skill), "success") end
    return true
end

function Forge.canBuild(id) local d = BUILDINGS[id]; if not d then return false, "Neznana zgradba" end; if not _G.state then return false, "Brez stanja" end; if _G.state.gold < (d.cost.gold or 0) then return false, "Premalo zlata" end; if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" and (_G.state.resources[r] or 0) < a then return false, "Premalo " .. r end end end; return true end
function Forge.build(id) local ok,e = Forge.canBuild(id); if not ok then return false, e end; local d = BUILDINGS[id]; _G.state.gold = _G.state.gold - (d.cost.gold or 0); if _G.state.resources then for r,a in pairs(d.cost) do if r ~= "gold" then _G.state.resources[r] = (_G.state.resources[r] or 0) - a end end end; table.insert(Forge.buildings, {type = id, builtDay = os.time()}); if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. d.name, "success") end; return true end
function Forge.getQualityBonus() local b = 0; for _,bd in ipairs(Forge.buildings) do local d = BUILDINGS[bd.type]; if d and d.qualityBonus then b = b + d.qualityBonus end end; return b end

function Forge.purchaseMetal(alloyType, quantity)
    local def = ALLOYS[alloyType]
    if not def then return false, "Neznana zlitina" end
    quantity = quantity or 1
    local cost = def.cost * quantity
    if not _G.state or (_G.state.gold or 0) < cost then return false, "Premalo zlata" end
    _G.state.gold = _G.state.gold - cost
    Forge.metalStock[alloyType] = (Forge.metalStock[alloyType] or 0) + quantity
    return true
end

function Forge.canForge(weaponType, alloyType)
    local wDef = WEAPONS[weaponType]; local aDef = ALLOYS[alloyType]
    if not wDef or not aDef then return false, "Neznano orožje ali zlitina" end
    if (Forge.metalStock[alloyType] or 0) < wDef.metalCost then return false, "Premalo kovine" end
    if #Forge.buildings == 0 then return false, "Potrebna kovašnica" end
    if not Forge.smith then return false, "Potreben kovač" end
    return true
end

function Forge.forge(weaponType, alloyType)
    local ok, err = Forge.canForge(weaponType, alloyType)
    if not ok then return false, err end
    local wDef = WEAPONS[weaponType]; local aDef = ALLOYS[alloyType]
    Forge.metalStock[alloyType] = Forge.metalStock[alloyType] - wDef.metalCost
    local forgeTime = wDef.time
    if Forge.smith then forgeTime = math.max(1, forgeTime - math.floor(Forge.smith.skill / 8)) end
    table.insert(Forge.activeForging, {
        id = "forge_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        weaponType = weaponType, weaponName = wDef.name, alloyType = alloyType, alloyName = aDef.name,
        attack = wDef.attack, cost = wDef.cost, alloyQuality = aDef.qualityBonus,
        alloyPrestige = aDef.prestige or 0, alloyFaith = aDef.faith or 0, alloyHappiness = aDef.happiness or 0,
        daysRemaining = forgeTime, started = os.time(),
    })
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Kovanje: %s iz %s (%d dni)", wDef.name, aDef.name, forgeTime), "info") end
    return true
end

function Forge.completeForging(f)
    local failChance = 0.10 - (Forge.smith and Forge.smith.skill / 500 or 0)
    failChance = math.max(0.02, failChance)
    if math.random() < failChance then
        if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Kovanje spodletelo: %s!", f.weaponName), "danger") end
        return
    end
    local quality = 1.0 + (Forge.getQualityBonus() / 100) + (f.alloyQuality / 100)
    if Forge.smith then quality = quality + (Forge.smith.skill / 200) end
    quality = math.min(2.5, quality)
    local grade = "common"
    if quality >= 2.0 then grade = "legendary"
    elseif quality >= 1.7 then grade = "masterwork"
    elseif quality >= 1.4 then grade = "superior"
    elseif quality >= 1.2 then grade = "fine" end
    local weapon = { id = f.id, type = f.weaponName, alloy = f.alloyName, quality = quality, grade = grade,
        attack = math.floor(f.attack * quality), value = math.floor(f.cost * quality * (1 + (f.alloyPrestige / 20))),
        prestige = f.alloyPrestige, faith = f.alloyFaith, happiness = f.alloyHappiness, forgedDay = os.time() }
    Forge.weaponStock[f.weaponType] = Forge.weaponStock[f.weaponType] or {}
    table.insert(Forge.weaponStock[f.weaponType], weapon)
    Forge.totalWeaponsForged = Forge.totalWeaponsForged + 1
    if weapon.happiness > 0 and _G.state and _G.state.happiness then _G.state.happiness = math.min(100, _G.state.happiness + weapon.happiness) end
    if weapon.faith > 0 and _G.Religion then pcall(_G.Religion.addFaith, weapon.faith) end
    if Forge.smith then Forge.smith.weaponsForged = Forge.smith.weaponsForged + 1; if math.random() < 0.15 then Forge.smith.skill = math.min(100, Forge.smith.skill + 1) end end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Orožje skovano: %s %s (%s, kakovost: %.1f)", f.alloyName, f.weaponName, grade, quality), "success") end
end

function Forge.sellWeapon(weaponType, index)
    if not Forge.weaponStock[weaponType] or not Forge.weaponStock[weaponType][index] then return false, "Orožje ne obstaja" end
    local w = table.remove(Forge.weaponStock[weaponType], index)
    if _G.state then _G.state.gold = (_G.state.gold or 0) + w.value end
    if _G.NotificationCenter then pcall(_G.NotificationCenter.notify, string.format("Orožje prodano: %s za %d zlata", w.type, w.value), "success") end
    return true
end

function Forge.update(dt)
    if not _G.state then return end
    Forge.dayTimer = Forge.dayTimer + dt
    if Forge.dayTimer >= 30 then
        Forge.dayTimer = 0
        for i = #Forge.activeForging, 1, -1 do
            local f = Forge.activeForging[i]
            f.daysRemaining = f.daysRemaining - 1
            if f.daysRemaining <= 0 then Forge.completeForging(f); table.remove(Forge.activeForging, i) end
        end
        local totalUpkeep = 0
        for _, bd in ipairs(Forge.buildings) do local d = BUILDINGS[bd.type]; if d and d.upkeep then totalUpkeep = totalUpkeep + d.upkeep end end
        if Forge.smith then totalUpkeep = totalUpkeep + 25 end
        if totalUpkeep > 0 and _G.state then _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep) end
    end
end

function Forge.getWeaponInfo(id) return WEAPONS[id] end
function Forge.getAlloyInfo(id) return ALLOYS[id] end
function Forge.getBuildingInfo(id) return BUILDINGS[id] end
function Forge.getStats()
    local totalWeapons = 0
    for _, weapons in pairs(Forge.weaponStock) do totalWeapons = totalWeapons + #weapons end
    return { numWeapons = totalWeapons, metalStock = Forge.metalStock,
        numBuildings = #Forge.buildings, hasSmith = Forge.smith ~= nil,
        smithName = Forge.smith and Forge.smith.name or "—",
        smithSkill = Forge.smith and Forge.smith.skill or 0,
        activeForging = #Forge.activeForging, totalWeaponsForged = Forge.totalWeaponsForged }
end

return Forge
