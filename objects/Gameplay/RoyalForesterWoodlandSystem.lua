-- objects/Gameplay/RoyalForesterWoodlandSystem.lua
-- Castle Kingdoms 2027 v3.4.3 - Royal Forester & Woodland System
--
-- Manages royal forests, timber production, and woodland management.
-- Provides wood, food (foraging), and hunting grounds.
--
-- Features:
-- - 6 tree types (oak, pine, birch, beech, yew, chestnut)
-- - 4 forest buildings (forest lodge, sawmill, charcoal kiln, tree nursery)
-- - Forester NPC (skill affects management)
-- - Sustainable forestry (reforestation)
-- - Timber production (wood resource)
-- - Charcoal production (for smithies)
-- - Foraging (food from forests)
-- - Forest management (thinning, planting)
-- - Seasonal variations

local Forester = {}

-- ============================================================
-- TREE TYPES
-- ============================================================
local TREES = {
    oak = {
        name = "Hrast",
        nameEn = "Oak",
        growthTime = 200,
        woodYield = 30,
        charcoalYield = 20,
        acornFood = 5,
        prestige = 5,
        description = "Močno drevo za gradnjo in ladje.",
    },
    pine = {
        name = "Bor",
        nameEn = "Pine",
        growthTime = 100,
        woodYield = 20,
        charcoalYield = 15,
        resinYield = 5,
        description = "Hitro rastoč iglavec.",
    },
    birch = {
        name = "Breza",
        nameEn = "Birch",
        growthTime = 80,
        woodYield = 12,
        charcoalYield = 10,
        sapYield = 3,
        description = "Hitro rastoča, mehak les.",
    },
    beech = {
        name = "Bukva",
        nameEn = "Beech",
        growthTime = 150,
        woodYield = 25,
        charcoalYield = 25,
        nutFood = 4,
        description = "Odlična za oglje in mast.",
    },
    yew = {
        name = "Tisa",
        nameEn = "Yew",
        growthTime = 300,
        woodYield = 15,
        bowYield = 1,
        prestige = 10,
        description = "Redko drevo za lokove — vojaško pomembno.",
    },
    chestnut = {
        name = "Kostanj",
        nameEn = "Chestnut",
        growthTime = 180,
        woodYield = 22,
        charcoalYield = 18,
        nutFood = 10,
        description = "Hrana in les v enem.",
    },
}

-- ============================================================
-- FOREST BUILDINGS
-- ============================================================
local BUILDINGS = {
    forest_lodge = {
        name = "Gozdarska koča",
        cost = { gold = 200, wood = 100 },
        upkeep = 5,
        managementBonus = 5,
        description = "Baza za gozdarje.",
    },
    sawmill = {
        name = "Žaga",
        cost = { gold = 800, wood = 200, stone = 100 },
        upkeep = 20,
        woodBonus = 0.30,
        description = "Za predelovo hlodovine v deske.",
    },
    charcoal_kiln = {
        name = "Kopica za oglje",
        cost = { gold = 500, wood = 150, stone = 200 },
        upkeep = 15,
        charcoalBonus = 0.50,
        description = "Za proizvodnjo oglja iz lesa.",
    },
    tree_nursery = {
        name = "Drevesnica",
        cost = { gold = 1000, wood = 100, stone = 50 },
        upkeep = 25,
        growthBonus = 0.30,
        description = "Za gojenje sadik in pogozdovanje.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Forester.forests = {}                     -- Forest areas
Forester.buildings = {}                   -- Built buildings
Forester.forester = nil                   -- Hired forester NPC
Forester.activePlantings = {}             -- Trees being grown
Forester.totalWoodHarvested = 0
Forester.totalCharcoalProduced = 0
Forester.totalFoodForaged = 0
Forester.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Forester.init()
    Forester.forests = {}
    Forester.buildings = {}
    Forester.forester = nil
    Forester.activePlantings = {}
    Forester.totalWoodHarvested = 0
    Forester.totalCharcoalProduced = 0
    Forester.totalFoodForaged = 0
    Forester.dayTimer = 0
    -- Start with some basic forests
    Forester.forests = {
        { type = "oak", count = 50, health = 100 },
        { type = "pine", count = 80, health = 100 },
        { type = "birch", count = 40, health = 100 },
    }
    print("[Forester] Royal Forester & Woodland System initialized (6 trees, 4 buildings)")
end

-- ============================================================
-- FORESTER NPC
-- ============================================================
function Forester.hireForester(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 300 + skill * 6
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Forester.forester = {
        name = name or ("Gozdar " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Gozdar najet: %s (spretnost: %d)", Forester.forester.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Forester.canBuild(buildingId)
    local def = BUILDINGS[buildingId]
    if not def then return false, "Neznana zgradba" end
    if not _G.state then return false, "Brez stanja" end
    if _G.state.gold < (def.cost.gold or 0) then return false, "Premalo zlata" end
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" and (_G.state.resources[res] or 0) < amt then
                return false, "Premalo " .. res
            end
        end
    end
    return true
end

function Forester.build(buildingId)
    local ok, err = Forester.canBuild(buildingId)
    if not ok then return false, err end
    local def = BUILDINGS[buildingId]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Forester.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Forester.getWoodBonus()
    local bonus = 0
    for _, b in ipairs(Forester.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.woodBonus then bonus = bonus + def.woodBonus end
    end
    return bonus
end

function Forester.getCharcoalBonus()
    local bonus = 0
    for _, b in ipairs(Forester.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.charcoalBonus then bonus = bonus + def.charcoalBonus end
    end
    return bonus
end

function Forester.getGrowthBonus()
    local bonus = 0
    for _, b in ipairs(Forester.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.growthBonus then bonus = bonus + def.growthBonus end
    end
    return bonus
end

-- ============================================================
-- PLANTING TREES
-- ============================================================
function Forester.canPlant(treeType)
    local def = TREES[treeType]
    if not def then return false, "Neznano drevo" end
    if not _G.state or (_G.state.gold or 0) < 50 then
        return false, "Premalo zlata za sadike"
    end
    return true
end

function Forester.plantTrees(treeType, count)
    count = count or 10
    local ok, err = Forester.canPlant(treeType)
    if not ok then return false, err end
    local def = TREES[treeType]
    local cost = 50 * count / 10
    _G.state.gold = _G.state.gold - math.floor(cost)
    -- Check if forest exists for this type
    local forest = nil
    for _, f in ipairs(Forester.forests) do
        if f.type == treeType then forest = f; break end
    end
    if forest then
        forest.count = forest.count + count
    else
        table.insert(Forester.forests, {
            type = treeType,
            count = count,
            health = 100,
        })
    end
    -- Also add to active plantings for growth tracking
    local planting = {
        id = "plant_" .. tostring(os.time()),
        treeType = treeType,
        count = count,
        daysRemaining = def.growthTime,
        plantedDay = os.time(),
    }
    table.insert(Forester.activePlantings, planting)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Posajeno: %d %s (%d dni do zrelosti)",
                count, def.name, def.growthTime), "info")
    end
    return true
end

function Forester.updatePlantings()
    for i = #Forester.activePlantings, 1, -1 do
        local p = Forester.activePlantings[i]
        p.daysRemaining = p.daysRemaining - 1
        if p.daysRemaining <= 0 then
            -- Trees matured, already added to forest count
            table.remove(Forester.activePlantings, i)
        end
    end
end

-- ============================================================
-- HARVESTING
-- ============================================================
function Forester.harvestWood(treeType, count)
    -- Find forest
    local forest = nil
    for _, f in ipairs(Forester.forests) do
        if f.type == treeType then forest = f; break end
    end
    if not forest or forest.count < count then
        return false, "Ni dovolj dreves"
    end
    local def = TREES[treeType]
    if not def then return false, "Neznano drevo" end
    -- Calculate yield
    local yield = def.woodYield * count
    local bonus = 1 + Forester.getWoodBonus()
    if Forester.forester then
        bonus = bonus + (Forester.forester.skill / 200)
    end
    yield = math.floor(yield * bonus)
    -- Remove trees
    forest.count = forest.count - count
    -- Add wood
    if _G.state and _G.state.resources then
        _G.state.resources.wood = (_G.state.resources.wood or 0) + yield
    end
    Forester.totalWoodHarvested = Forester.totalWoodHarvested + yield
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Pridobljeno: %d lesa iz %d %s", yield, count, def.name), "success")
    end
    return true
end

function Forester.produceCharcoal(treeType, count)
    local forest = nil
    for _, f in ipairs(Forester.forests) do
        if f.type == treeType then forest = f; break end
    end
    if not forest or forest.count < count then
        return false, "Ni dovolj dreves"
    end
    local def = TREES[treeType]
    if not def or not def.charcoalYield then return false, "To drevo ni primerno za oglje" end
    -- Check for kiln
    local hasKiln = false
    for _, b in ipairs(Forester.buildings) do
        if b.type == "charcoal_kiln" then hasKiln = true; break end
    end
    if not hasKiln then return false, "Potrebna kopica za oglje" end
    local yield = def.charcoalYield * count
    local bonus = 1 + Forester.getCharcoalBonus()
    yield = math.floor(yield * bonus)
    forest.count = forest.count - count
    -- Add charcoal (as fuel resource)
    if _G.state and _G.state.resources then
        _G.state.resources.charcoal = (_G.state.resources.charcoal or 0) + yield
    end
    Forester.totalCharcoalProduced = Forester.totalCharcoalProduced + yield
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Proizvedeno: %d oglja iz %d %s", yield, count, def.name), "success")
    end
    return true
end

-- ============================================================
-- FORAGING
-- ============================================================
function Forester.forage()
    local totalFood = 0
    for _, f in ipairs(Forester.forests) do
        local def = TREES[f.type]
        if def then
            local foodPerTree = (def.acornFood or 0) + (def.nutFood or 0)
            if foodPerTree > 0 then
                totalFood = totalFood + (foodPerTree * f.count * 0.1)
            end
        end
    end
    totalFood = math.floor(totalFood)
    if totalFood > 0 and _G.state and _G.state.resources then
        _G.state.resources.food = (_G.state.resources.food or 0) + totalFood
        Forester.totalFoodForaged = Forester.totalFoodForaged + totalFood
    end
    return totalFood
end

-- ============================================================
-- FOREST HEALTH
-- ============================================================
function Forester.updateForestHealth()
    local growthBonus = Forester.getGrowthBonus()
    for _, f in ipairs(Forester.forests) do
        -- Natural regrowth
        local regrowth = math.floor(f.count * 0.02 * (1 + growthBonus))
        if Forester.forester then
            regrowth = regrowth + math.floor(Forester.forester.skill / 20)
        end
        f.count = f.count + regrowth
        -- Health slowly improves
        if f.health < 100 then
            f.health = math.min(100, f.health + 1)
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Forester.update(dt)
    if not _G.state then return end
    Forester.dayTimer = Forester.dayTimer + dt
    if Forester.dayTimer >= 30 then
        Forester.dayTimer = 0
        Forester.updateForestHealth()
        Forester.updatePlantings()
        -- Foraging (passive food)
        Forester.forage()
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Forester.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Forester.forester then totalUpkeep = totalUpkeep + 15 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Forester.getTreeInfo(treeId) return TREES[treeId] end
function Forester.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Forester.getStats()
    local totalTrees = 0
    for _, f in ipairs(Forester.forests) do
        totalTrees = totalTrees + f.count
    end
    return {
        numForests = #Forester.forests,
        totalTrees = totalTrees,
        numBuildings = #Forester.buildings,
        hasForester = Forester.forester ~= nil,
        foresterName = Forester.forester and Forester.forester.name or "—",
        foresterSkill = Forester.forester and Forester.forester.skill or 0,
        activePlantings = #Forester.activePlantings,
        totalWoodHarvested = Forester.totalWoodHarvested,
        totalCharcoalProduced = Forester.totalCharcoalProduced,
        totalFoodForaged = Forester.totalFoodForaged,
    }
end

return Forester
