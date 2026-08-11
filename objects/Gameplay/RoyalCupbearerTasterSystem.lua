-- objects/Gameplay/RoyalCupbearerTasterSystem.lua
-- Castle Kingdoms 2027 v3.5.6 - Royal Cupbearer & Taster System
--
-- Manages the royal cupbearer, food/beverage tasters, and dining safety.
-- Protects against poisoning and manages the quality of royal dining.
--
-- Features:
-- - 6 beverage types (wine, ale, mead, water, cider, spirits)
-- - 8 dish types (roast, stew, fish, bread, cheese, fruit, game, dessert)
-- - 4 dining buildings (kitchen, pantry, wine cellar, royal dining hall)
-- - Cupbearer NPC (skill affects detection)
-- - Taster system (poison detection)
-- - Dining quality management
-- - Banquet preparation
-- - Beverage aging and storage

local Cupbearer = {}

-- ============================================================
-- BEVERAGE TYPES
-- ============================================================
local BEVERAGES = {
    wine = {
        name = "Vino",
        nameEn = "Wine",
        cost = 20,
        qualityBonus = 5,
        agingPotential = 0.5,
        description = "Dvorno vino iz lastnih vinogradov.",
    },
    ale = {
        name = "Pivo",
        nameEn = "Ale",
        cost = 5,
        qualityBonus = 2,
        agingPotential = 0.1,
        description = "Svetlo pivo za vsakdan.",
    },
    mead = {
        name = "Medovec",
        nameEn = "Mead",
        cost = 30,
        qualityBonus = 8,
        agingPotential = 0.6,
        description = "Medeni napoj za slovesnosti.",
    },
    water = {
        name = "Voda",
        nameEn = "Water",
        cost = 0,
        qualityBonus = 0,
        agingPotential = 0.0,
        description = "Čista izvirska voda.",
    },
    cider = {
        name = "Jabolčnik",
        nameEn = "Cider",
        cost = 10,
        qualityBonus = 3,
        agingPotential = 0.2,
        description = "Jabolčni napoj za vsakdan.",
    },
    spirits = {
        name = "Žgane pijače",
        nameEn = "Spirits",
        cost = 50,
        qualityBonus = 10,
        agingPotential = 0.8,
        description = "Močne žgane pijače za posebne priložnosti.",
    },
}

-- ============================================================
-- DISH TYPES
-- ============================================================
local DISHES = {
    roast = {
        name = "Pečenka",
        nameEn = "Roast",
        cost = 50,
        qualityBonus = 8,
        preparationTime = 4,
        description = "Velika pečenka za slovesnosti.",
    },
    stew = {
        name = "Enolončnica",
        nameEn = "Stew",
        cost = 15,
        qualityBonus = 4,
        preparationTime = 3,
        description = "Gosta enolončnica za vsakdan.",
    },
    fish = {
        name = "Ribe",
        nameEn = "Fish",
        cost = 25,
        qualityBonus = 5,
        preparationTime = 2,
        spoilageRisk = 0.10,
        description = "Sveže ribe — paziti na pokvarljivost.",
    },
    bread = {
        name = "Kruh",
        nameEn = "Bread",
        cost = 5,
        qualityBonus = 2,
        preparationTime = 6,
        description = "Sveže pečen kruh.",
    },
    cheese = {
        name = "Sir",
        nameEn = "Cheese",
        cost = 20,
        qualityBonus = 6,
        agingPotential = 0.7,
        description = "Zreli siri iz lastnih sirarn.",
    },
    fruit = {
        name = "Sadje",
        nameEn = "Fruit",
        cost = 10,
        qualityBonus = 3,
        spoilageRisk = 0.15,
        description = "Sveže sadje — paziti na pokvarljivost.",
    },
    game = {
        name = "Divjačina",
        nameEn = "Game",
        cost = 40,
        qualityBonus = 10,
        preparationTime = 5,
        description = "Divjačina z lovov.",
    },
    dessert = {
        name = "Sladica",
        nameEn = "Dessert",
        cost = 30,
        qualityBonus = 12,
        preparationTime = 3,
        description = "Sladke jedi za konec obroka.",
    },
}

-- ============================================================
-- DINING BUILDINGS
-- ============================================================
local BUILDINGS = {
    kitchen = {
        name = "Kuhinja",
        cost = { gold = 300, wood = 100, stone = 50 },
        upkeep = 10,
        preparationBonus = 5,
        description = "Osnovna kuhinja za pripravo jedi.",
    },
    pantry = {
        name = "Shramba",
        cost = { gold = 200, wood = 150 },
        upkeep = 5,
        storageCapacity = 100,
        spoilageReduction = 0.20,
        description = "Hladna shramba za živila.",
    },
    wine_cellar = {
        name = "Vinska klet",
        cost = { gold = 1000, wood = 200, stone = 400 },
        upkeep = 25,
        storageCapacity = 200,
        agingBonus = 0.30,
        qualityBonus = 10,
        description = "Temni hladni podrvm za staranje vin.",
    },
    royal_dining_hall = {
        name = "Kraljevska jedilnica",
        cost = { gold = 2000, wood = 300, stone = 500 },
        upkeep = 40,
        preparationBonus = 15,
        qualityBonus = 20,
        prestigeBonus = 10,
        description = "Velika jedilnica za kraljevske obroke.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Cupbearer.beverageStock = {}              -- Stored beverages
Cupbearer.dishStock = {}                  -- Stored dishes
Cupbearer.buildings = {}                  -- Built dining buildings
Cupbearer.cupbearer = nil                 -- Royal Cupbearer NPC
Cupbearer.activeMeals = {}                -- Meals being prepared
Cupbearer.diningQuality = 50              -- 0-100
Cupbearer.totalMeals = 0
Cupbearer.totalPoisoningsDetected = 0
Cupbearer.totalPoisoningsMissed = 0
Cupbearer.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Cupbearer.init()
    Cupbearer.beverageStock = {}
    Cupbearer.dishStock = {}
    Cupbearer.buildings = {}
    Cupbearer.cupbearer = nil
    Cupbearer.activeMeals = {}
    Cupbearer.diningQuality = 50
    Cupbearer.totalMeals = 0
    Cupbearer.totalPoisoningsDetected = 0
    Cupbearer.totalPoisoningsMissed = 0
    Cupbearer.dayTimer = 0
    print("[Cupbearer] Royal Cupbearer & Taster System initialized (6 beverages, 8 dishes, 4 buildings)")
end

-- ============================================================
-- CUPBEARER NPC
-- ============================================================
function Cupbearer.hireCupbearer(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 300 + skill * 6
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Cupbearer.cupbearer = {
        name = name or ("Točaj " .. math.random(1, 99)),
        skill = skill,
        detectionRate = 0.40 + (skill / 200),
        hiredDay = os.time(),
        mealsServed = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Točaj najet: %s (spretnost: %d, detekcija: %.0f%%)",
                Cupbearer.cupbearer.name, skill, Cupbearer.cupbearer.detectionRate * 100), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Cupbearer.canBuild(buildingId)
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

function Cupbearer.build(buildingId)
    local ok, err = Cupbearer.canBuild(buildingId)
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
    table.insert(Cupbearer.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Cupbearer.getPreparationBonus()
    local bonus = 0
    for _, b in ipairs(Cupbearer.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.preparationBonus then bonus = bonus + def.preparationBonus end
    end
    return bonus
end

function Cupbearer.getQualityBonus()
    local bonus = 0
    for _, b in ipairs(Cupbearer.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.qualityBonus then bonus = bonus + def.qualityBonus end
    end
    return bonus
end

function Cupbearer.getSpoilageReduction()
    local reduction = 0
    for _, b in ipairs(Cupbearer.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.spoilageReduction then reduction = math.max(reduction, def.spoilageReduction) end
    end
    return reduction
end

-- ============================================================
-- STOCK MANAGEMENT
-- ============================================================
function Cupbearer.purchaseBeverage(beverageType, quantity)
    local def = BEVERAGES[beverageType]
    if not def then return false, "Neznana pijača" end
    local cost = def.cost * quantity
    if cost > 0 and (not _G.state or (_G.state.gold or 0) < cost) then
        return false, "Premalo zlata"
    end
    if cost > 0 and _G.state then
        _G.state.gold = _G.state.gold - cost
    end
    Cupbearer.beverageStock[beverageType] = (Cupbearer.beverageStock[beverageType] or 0) + quantity
    return true
end

function Cupbearer.purchaseDish(dishType, quantity)
    local def = DISHES[dishType]
    if not def then return false, "Neznana jed" end
    local cost = def.cost * quantity
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Cupbearer.dishStock[dishType] = (Cupbearer.dishStock[dishType] or 0) + quantity
    return true
end

-- ============================================================
-- MEAL PREPARATION
-- ============================================================
function Cupbearer.canPrepareMeal(dishType, beverageType)
    if not Cupbearer.cupbearer then return false, "Potreben točaj" end
    if #Cupbearer.buildings == 0 then return false, "Potrebna kuhinja" end
    if (Cupbearer.dishStock[dishType] or 0) < 1 then
        return false, "Ni jedi na zalogi"
    end
    if beverageType and (Cupbearer.beverageStock[beverageType] or 0) < 1 then
        return false, "Ni pijače na zalogi"
    end
    return true
end

function Cupbearer.prepareMeal(dishType, beverageType)
    local ok, err = Cupbearer.canPrepareMeal(dishType, beverageType)
    if not ok then return false, err end
    local dishDef = DISHES[dishType]
    local bevDef = beverageType and BEVERAGES[beverageType]
    -- Consume stock
    Cupbearer.dishStock[dishType] = Cupbearer.dishStock[dishType] - 1
    if beverageType then
        Cupbearer.beverageStock[beverageType] = Cupbearer.beverageStock[beverageType] - 1
    end
    -- Calculate quality
    local quality = 0.5
    quality = quality + (Cupbearer.getQualityBonus() / 100)
    quality = quality + (Cupbearer.cupbearer.skill / 200)
    quality = quality + ((dishDef.qualityBonus or 0) / 100)
    if bevDef then
        quality = quality + ((bevDef.qualityBonus or 0) / 100)
    end
    quality = math.min(1.8, quality)
    -- Calculate preparation time
    local prepTime = dishDef.preparationTime
    local prepBonus = Cupbearer.getPreparationBonus()
    if Cupbearer.cupbearer then
        prepBonus = prepBonus + math.floor(Cupbearer.cupbearer.skill / 10)
    end
    prepTime = math.max(1, prepTime - math.floor(prepBonus / 5))
    local meal = {
        id = "meal_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        dishType = dishType,
        dishName = dishDef.name,
        beverageType = beverageType,
        beverageName = bevDef and bevDef.name or "—",
        daysRemaining = prepTime,
        quality = quality,
        happinessBonus = math.floor(8 * quality),
        started = os.time(),
    }
    table.insert(Cupbearer.activeMeals, meal)
    Cupbearer.totalMeals = Cupbearer.totalMeals + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Obrok v pripravi: %s (%d dni)", dishDef.name, prepTime), "info")
    end
    return true
end

function Cupbearer.completeMeal(meal)
    -- Poison detection check
    local poisonChance = 0.05  -- 5% chance food was poisoned
    local detectionRate = Cupbearer.cupbearer and Cupbearer.cupbearer.detectionRate or 0.30
    if math.random() < poisonChance then
        if math.random() < detectionRate then
            -- Detected!
            Cupbearer.totalPoisoningsDetected = Cupbearer.totalPoisoningsDetected + 1
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    "STRUP ZAZNAN! Obrok zavrnjen.", "success")
            end
            -- Don't serve the meal
            return
        else
            -- Missed!
            Cupbearer.totalPoisoningsMissed = Cupbearer.totalPoisoningsMissed + 1
            if _G.Guard then
                pcall(function() _G.Guard.rulerHealth = math.max(0, _G.Guard.rulerHealth - 30) end)
            end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    "STRUP NEZAZNAN! Vladar zastrupljen!", "danger")
            end
            return
        end
    end
    -- Apply meal effects
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + meal.happinessBonus)
    end
    Cupbearer.diningQuality = math.min(100, Cupbearer.diningQuality + math.floor(meal.quality * 2))
    if Cupbearer.cupbearer then
        Cupbearer.cupbearer.mealsServed = Cupbearer.cupbearer.mealsServed + 1
        if math.random() < 0.15 then
            Cupbearer.cupbearer.skill = math.min(100, Cupbearer.cupbearer.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Obrok postrežen: %s (kakovost: %.1f, +%d sreče)",
                meal.dishName, meal.quality, meal.happinessBonus), "success")
    end
end

-- ============================================================
-- SPOILAGE MANAGEMENT
-- ============================================================
function Cupbearer.checkSpoilage()
    local spoilageReduction = Cupbearer.getSpoilageReduction()
    for dishType, quantity in pairs(Cupbearer.dishStock) do
        local def = DISHES[dishType]
        if def and def.spoilageRisk and def.spoilageRisk > 0 then
            local effectiveRisk = def.spoilageRisk * (1 - spoilageReduction)
            local spoiled = 0
            for _ = 1, quantity do
                if math.random() < effectiveRisk * 0.1 then  -- daily check
                    spoiled = spoiled + 1
                end
            end
            if spoiled > 0 then
                Cupbearer.dishStock[dishType] = quantity - spoiled
                if _G.NotificationCenter and spoiled > 2 then
                    pcall(_G.NotificationCenter.notify,
                        string.format("%d %s pokvarjenih!", spoiled, def.name), "warning")
                end
            end
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Cupbearer.update(dt)
    if not _G.state then return end
    Cupbearer.dayTimer = Cupbearer.dayTimer + dt
    if Cupbearer.dayTimer >= 30 then
        Cupbearer.dayTimer = 0
        -- Process meals
        for i = #Cupbearer.activeMeals, 1, -1 do
            local m = Cupbearer.activeMeals[i]
            m.daysRemaining = m.daysRemaining - 1
            if m.daysRemaining <= 0 then
                Cupbearer.completeMeal(m)
                table.remove(Cupbearer.activeMeals, i)
            end
        end
        -- Check spoilage
        Cupbearer.checkSpoilage()
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Cupbearer.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Cupbearer.cupbearer then totalUpkeep = totalUpkeep + 15 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Dining quality drifts to 50
        if Cupbearer.diningQuality > 50 then
            Cupbearer.diningQuality = Cupbearer.diningQuality - 0.3
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Cupbearer.getBeverageInfo(bevId) return BEVERAGES[bevId] end
function Cupbearer.getDishInfo(dishId) return DISHES[dishId] end
function Cupbearer.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Cupbearer.getStats()
    return {
        beverageStock = Cupbearer.beverageStock,
        dishStock = Cupbearer.dishStock,
        numBuildings = #Cupbearer.buildings,
        hasCupbearer = Cupbearer.cupbearer ~= nil,
        cupbearerName = Cupbearer.cupbearer and Cupbearer.cupbearer.name or "—",
        cupbearerSkill = Cupbearer.cupbearer and Cupbearer.cupbearer.skill or 0,
        cupbearerDetection = Cupbearer.cupbearer and Cupbearer.cupbearer.detectionRate or 0,
        activeMeals = #Cupbearer.activeMeals,
        diningQuality = Cupbearer.diningQuality,
        totalMeals = Cupbearer.totalMeals,
        totalPoisoningsDetected = Cupbearer.totalPoisoningsDetected,
        totalPoisoningsMissed = Cupbearer.totalPoisoningsMissed,
    }
end

return Cupbearer
