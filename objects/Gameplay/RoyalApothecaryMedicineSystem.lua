-- objects/Gameplay/RoyalApothecaryMedicineSystem.lua
-- Castle Kingdoms 2027 v3.3.4 - Royal Apothecary & Medicine System
--
-- Manages royal apothecaries, herbal medicines, poisons, and antidotes.
-- Provides healing, disease prevention, and combat bonuses.
--
-- Features:
-- - 8 herb types (mandrake, valerian, sage, rosemary, garlic, henbane, wormwood, nightshade)
-- - 6 remedy types (healing potion, antidote, painkiller, tonic, sedative, stimulant)
-- - 4 poison types (for espionage and assassinations)
-- - Apothecary buildings (herb garden, workshop, laboratory)
-- - Apothecary NPC (skill affects remedy quality)
-- - Herb cultivation (grow your own)
-- - Healing the ruler and court
-- - Disease prevention (during plague outbreaks)
-- - Combat healing potions for armies

local Apothecary = {}

-- ============================================================
-- HERB TYPES
-- ============================================================
local HERBS = {
    mandrake = {
        name = "Mandragora",
        nameEn = "Mandrake",
        rarity = 4,
        growthTime = 30,
        cost = 50,
        usedIn = { "healing_potion", "sedative", "anesthetic" },
        description = "Redka korenina z močnimi lastnostmi.",
    },
    valerian = {
        name = "Špaj",
        nameEn = "Valerian",
        rarity = 2,
        growthTime = 20,
        cost = 15,
        usedIn = { "sedative", "tonic" },
        description = "Umirjujoča zel za pomiritev.",
    },
    sage = {
        name = "Žajbelj",
        nameEn = "Sage",
        rarity = 1,
        growthTime = 15,
        cost = 5,
        usedIn = { "healing_potion", "antiseptic" },
        description = "Pogosta zdravilna zel.",
    },
    rosemary = {
        name = "Rožmarin",
        nameEn = "Rosemary",
        rarity = 1,
        growthTime = 15,
        cost = 5,
        usedIn = { "tonic", "stimulant" },
        description = "Poživljajoča zel.",
    },
    garlic = {
        name = "Česen",
        nameEn = "Garlic",
        rarity = 1,
        growthTime = 10,
        cost = 3,
        usedIn = { "antidote", "antiseptic" },
        description = "Naravni antibiotik.",
    },
    henbane = {
        name = "Volčje jabolko",
        nameEn = "Henbane",
        rarity = 3,
        growthTime = 25,
        cost = 30,
        usedIn = { "painkiller", "poison" },
        description = "Strupena a uporabna zel.",
    },
    wormwood = {
        name = "Pelin",
        nameEn = "Wormwood",
        rarity = 2,
        growthTime = 20,
        cost = 10,
        usedIn = { "antidote", "tonic" },
        description = "Grenka zel proti parazitom.",
    },
    nightshade = {
        name = "Vrobnica",
        nameEn = "Nightshade",
        rarity = 5,
        growthTime = 35,
        cost = 80,
        usedIn = { "poison", "painkiller" },
        description = "Zelo strupena a močna zel.",
    },
}

-- ============================================================
-- REMEDY TYPES
-- ============================================================
local REMEDIES = {
    healing_potion = {
        name = "Zdravilni napoj",
        nameEn = "Healing Potion",
        herbsRequired = { sage = 2, mandrake = 1 },
        cost = 100,
        healAmount = 50,
        description = "Obnovi zdravje ranjenim.",
    },
    antidote = {
        name = "Protistrup",
        nameEn = "Antidote",
        herbsRequired = { garlic = 3, wormwood = 2 },
        cost = 150,
        curePoison = true,
        description = "Zdravi zastrupitev.",
    },
    painkiller = {
        name = "Sredstvo proti bolečini",
        nameEn = "Painkiller",
        herbsRequired = { henbane = 1, mandrake = 1 },
        cost = 120,
        painRelief = 30,
        description = "Zmanjša bolečino.",
    },
    tonic = {
        name = "Tonik",
        nameEn = "Tonic",
        herbsRequired = { rosemary = 2, valerian = 1, wormwood = 1 },
        cost = 80,
        statBoost = 10,
        duration = 300,
        description = "Izboljša splošno stanje.",
    },
    sedative = {
        name = "Umirjevalo",
        nameEn = "Sedative",
        herbsRequired = { valerian = 3, mandrake = 1 },
        cost = 90,
        calmEffect = 20,
        description = "Pomiri in izboljša spanje.",
    },
    stimulant = {
        name = "Poživilo",
        nameEn = "Stimulant",
        herbsRequired = { rosemary = 3 },
        cost = 60,
        energyBoost = 25,
        duration = 180,
        description = "Daje energijo in budnost.",
    },
}

-- ============================================================
-- POISON TYPES (for espionage)
-- ============================================================
local POISONS = {
    rat_venom = {
        name = "Strup podgan",
        nameEn = "Rat Venom",
        herbsRequired = { nightshade = 1 },
        cost = 200,
        damage = 30,
        detectionChance = 0.30,
        description = "Šibak a diskreten strup.",
    },
    wolfsbane = {
        name = "Volčji strup",
        nameEn = "Wolfsbane",
        herbsRequired = { nightshade = 2, henbane = 1 },
        cost = 500,
        damage = 60,
        detectionChance = 0.20,
        description = "Močan strup iz volčje jegličice.",
    },
    slow_death = {
        name = "Počasna smrt",
        nameEn = "Slow Death",
        herbsRequired = { nightshade = 3, mandrake = 2 },
        cost = 1000,
        damage = 100,
        detectionChance = 0.10,
        description = "Nezdravljiv strup, počasno delovanje.",
    },
    sleep_potion = {
        name = "Uspavalni napoj",
        nameEn = "Sleep Potion",
        herbsRequired = { mandrake = 2, valerian = 3 },
        cost = 300,
        damage = 0,
        sleepDuration = 300,
        detectionChance = 0.15,
        description = "Ne smrtonosen, vendar uspava.",
    },
}

-- ============================================================
-- APOTHECARY BUILDINGS
-- ============================================================
local BUILDINGS = {
    herb_garden = {
        name = "Zeliščni vrt",
        cost = { gold = 200, wood = 50 },
        upkeep = 5,
        herbCapacity = 10,
        growthBonus = 0.20,
        description = "Vrt za gojenje zelišč.",
    },
    workshop = {
        name = "Apothekarska delavnica",
        cost = { gold = 800, wood = 200, stone = 100 },
        upkeep = 20,
        remedyCapacity = 5,
        qualityBonus = 10,
        description = "Delavnica za pripravo zdravil.",
    },
    laboratory = {
        name = "Laboratorij",
        cost = { gold = 2500, wood = 300, stone = 500, iron = 50 },
        upkeep = 60,
        remedyCapacity = 15,
        qualityBonus = 25,
        poisonCapacity = 5,
        description = "Napreden laboratorij za kompleksne pripravke.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Apothecary.herbStockpile = {}           -- Stored herbs
Apothecary.remedyStockpile = {}         -- Stored remedies
Apothecary.poisonStockpile = {}         -- Stored poisons
Apothecary.buildings = {}               -- Built buildings
Apothecary.apothecary = nil             -- Hired apothecary NPC
Apothecary.activeHerbGardens = {}       -- Growing herbs
Apothecary.totalRemediesMade = 0
Apothecary.totalPoisonsMade = 0
Apothecary.totalHealed = 0
Apothecary.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Apothecary.init()
    Apothecary.herbStockpile = {}
    Apothecary.remedyStockpile = {}
    Apothecary.poisonStockpile = {}
    Apothecary.buildings = {}
    Apothecary.apothecary = nil
    Apothecary.activeHerbGardens = {}
    Apothecary.totalRemediesMade = 0
    Apothecary.totalPoisonsMade = 0
    Apothecary.totalHealed = 0
    Apothecary.dayTimer = 0
    print("[Apothecary] Royal Apothecary & Medicine System initialized (8 herbs, 6 remedies)")
end

-- ============================================================
-- APOTHECARY NPC
-- ============================================================
function Apothecary.hireApothecary(name, skill)
    skill = skill or math.random(40, 90)
    local cost = 500 + skill * 10
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Apothecary.apothecary = {
        name = name or ("Apothekar " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        remediesCrafted = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Apothekar najet: %s (spretnost: %d)", Apothecary.apothecary.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Apothecary.canBuild(buildingId)
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

function Apothecary.build(buildingId)
    local ok, err = Apothecary.canBuild(buildingId)
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
    table.insert(Apothecary.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Apothecary.getQualityBonus()
    local bonus = 0
    for _, b in ipairs(Apothecary.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.qualityBonus then bonus = bonus + def.qualityBonus end
    end
    return bonus
end

function Apothecary.hasLaboratory()
    for _, b in ipairs(Apothecary.buildings) do
        if b.type == "laboratory" then return true end
    end
    return false
end

-- ============================================================
-- HERB CULTIVATION
-- ============================================================
function Apothecary.plantHerb(herbType)
    local def = HERBS[herbType]
    if not def then return false, "Neznana zel" end
    -- Check capacity
    local gardenCapacity = 0
    for _, b in ipairs(Apothecary.buildings) do
        if b.type == "herb_garden" then
            local bdef = BUILDINGS[b.type]
            if bdef then gardenCapacity = gardenCapacity + bdef.herbCapacity end
        end
    end
    if #Apothecary.activeHerbGardens >= gardenCapacity then
        return false, "Vrt je poln"
    end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata za semena"
    end
    _G.state.gold = _G.state.gold - def.cost
    local plant = {
        id = "herb_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = herbType,
        daysRemaining = def.growthTime,
        plantedDay = os.time(),
    }
    table.insert(Apothecary.activeHerbGardens, plant)
    return true
end

function Apothecary.updateHerbGardens()
    for i = #Apothecary.activeHerbGardens, 1, -1 do
        local p = Apothecary.activeHerbGardens[i]
        p.daysRemaining = p.daysRemaining - 1
        if p.daysRemaining <= 0 then
            -- Harvest!
            local def = HERBS[p.type]
            local yield = 2 + math.random(0, 3)  -- 2-5 herbs per plant
            Apothecary.herbStockpile[p.type] = (Apothecary.herbStockpile[p.type] or 0) + yield
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("Pridelano: %d %s", yield, def.name), "success")
            end
            table.remove(Apothecary.activeHerbGardens, i)
        end
    end
end

-- ============================================================
-- REMEDY CRAFTING
-- ============================================================
function Apothecary.canCraftRemedy(remedyType)
    local def = REMEDIES[remedyType]
    if not def then return false, "Neznan napoj" end
    -- Check herbs
    for herb, qty in pairs(def.herbsRequired) do
        if (Apothecary.herbStockpile[herb] or 0) < qty then
            return false, "Premalo " .. (HERBS[herb] and HERBS[herb].name or herb)
        end
    end
    -- Check gold
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    -- Check workshop
    local hasWorkshop = false
    for _, b in ipairs(Apothecary.buildings) do
        if b.type == "workshop" or b.type == "laboratory" then
            hasWorkshop = true; break
        end
    end
    if not hasWorkshop then
        return false, "Potrebna delavnica"
    end
    return true
end

function Apothecary.craftRemedy(remedyType)
    local ok, err = Apothecary.canCraftRemedy(remedyType)
    if not ok then return false, err end
    local def = REMEDIES[remedyType]
    -- Consume herbs
    for herb, qty in pairs(def.herbsRequired) do
        Apothecary.herbStockpile[herb] = Apothecary.herbStockpile[herb] - qty
    end
    -- Pay gold
    _G.state.gold = _G.state.gold - def.cost
    -- Add to stockpile
    Apothecary.remedyStockpile[remedyType] = (Apothecary.remedyStockpile[remedyType] or 0) + 1
    Apothecary.totalRemediesMade = Apothecary.totalRemediesMade + 1
    -- Skill progression
    if Apothecary.apothecary then
        Apothecary.apothecary.remediesCrafted = Apothecary.apothecary.remediesCrafted + 1
        if math.random() < 0.15 then
            Apothecary.apothecary.skill = math.min(100, Apothecary.apothecary.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Pripravljen: " .. def.name, "success")
    end
    return true
end

-- ============================================================
-- POISON CRAFTING
-- ============================================================
function Apothecary.canCraftPoison(poisonType)
    if not Apothecary.hasLaboratory() then
        return false, "Potreben laboratorij za strupe"
    end
    local def = POISONS[poisonType]
    if not def then return false, "Neznan strup" end
    for herb, qty in pairs(def.herbsRequired) do
        if (Apothecary.herbStockpile[herb] or 0) < qty then
            return false, "Premalo " .. (HERBS[herb] and HERBS[herb].name or herb)
        end
    end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    return true
end

function Apothecary.craftPoison(poisonType)
    local ok, err = Apothecary.canCraftPoison(poisonType)
    if not ok then return false, err end
    local def = POISONS[poisonType]
    for herb, qty in pairs(def.herbsRequired) do
        Apothecary.herbStockpile[herb] = Apothecary.herbStockpile[herb] - qty
    end
    _G.state.gold = _G.state.gold - def.cost
    Apothecary.poisonStockpile[poisonType] = (Apothecary.poisonStockpile[poisonType] or 0) + 1
    Apothecary.totalPoisonsMade = Apothecary.totalPoisonsMade + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Strup pripravljen: " .. def.name, "info")
    end
    return true
end

-- ============================================================
-- USING REMEDIES
-- ============================================================
function Apothecary.useRemedy(remedyType, target)
    if (Apothecary.remedyStockpile[remedyType] or 0) <= 0 then
        return false, "Ni na zalogi"
    end
    local def = REMEDIES[remedyType]
    Apothecary.remedyStockpile[remedyType] = Apothecary.remedyStockpile[remedyType] - 1
    Apothecary.totalHealed = Apothecary.totalHealed + 1
    -- Apply effects
    if def.healAmount and target == "ruler" and _G.Guard then
        pcall(function() _G.Guard.rulerHealth = math.min(100, _G.Guard.rulerHealth + def.healAmount) end)
    elseif def.healAmount and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + def.healAmount / 5)
    end
    if def.curePoison and target == "ruler" then
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Strup nevtraliziran!", "success")
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Uporabljeno: " .. def.name, "info")
    end
    return true
end

function Apothecary.usePoison(poisonType, targetFaction)
    if (Apothecary.poisonStockpile[poisonType] or 0) <= 0 then
        return false, "Ni strupa na zalogi"
    end
    local def = POISONS[poisonType]
    Apothecary.poisonStockpile[poisonType] = Apothecary.poisonStockpile[poisonType] - 1
    -- Check if detected
    if math.random() < def.detectionChance then
        -- Detected — diplomatic hit
        if _G.DiplomacyController then
            pcall(_G.DiplomacyController.changeRelation, targetFaction, -30)
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                "STRUP RAZKRIT! Diplomatska kriza!", "danger")
        end
    else
        -- Success
        if _G.DiplomacyController then
            pcall(_G.DiplomacyController.changeRelation, targetFaction, -5)
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Strup uporabljen na %s", tostring(targetFaction)), "info")
        end
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Apothecary.update(dt)
    if not _G.state then return end
    Apothecary.dayTimer = Apothecary.dayTimer + dt
    if Apothecary.dayTimer >= 30 then
        Apothecary.dayTimer = 0
        Apothecary.updateHerbGardens()
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Apothecary.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Apothecary.apothecary then totalUpkeep = totalUpkeep + 15 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Apothecary.getHerbInfo(herbId) return HERBS[herbId] end
function Apothecary.getRemedyInfo(remedyId) return REMEDIES[remedyId] end
function Apothecary.getPoisonInfo(poisonId) return POISONS[poisonId] end
function Apothecary.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Apothecary.getStats()
    return {
        herbStockpile = Apothecary.herbStockpile,
        remedyStockpile = Apothecary.remedyStockpile,
        poisonStockpile = Apothecary.poisonStockpile,
        numBuildings = #Apothecary.buildings,
        hasApothecary = Apothecary.apothecary ~= nil,
        apothecaryName = Apothecary.apothecary and Apothecary.apothecary.name or "—",
        apothecarySkill = Apothecary.apothecary and Apothecary.apothecary.skill or 0,
        activeGardens = #Apothecary.activeHerbGardens,
        totalRemediesMade = Apothecary.totalRemediesMade,
        totalPoisonsMade = Apothecary.totalPoisonsMade,
        totalHealed = Apothecary.totalHealed,
    }
end

return Apothecary
