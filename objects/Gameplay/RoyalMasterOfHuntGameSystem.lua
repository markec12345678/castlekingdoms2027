-- objects/Gameplay/RoyalMasterOfHuntGameSystem.lua
-- Castle Kingdoms 2027 v3.4.2 - Royal Master of Hunt & Game System
--
-- Manages royal hunting preserves, game animals, and organized hunts.
-- Provides food, sport, and prestige through the ancient art of venery.
--
-- Features:
-- - 6 game animal types (deer, boar, fox, hare, pheasant, bear)
-- - 4 hunting preserve buildings (forest, park, warren, menagerie)
-- - Master of Hunt NPC (skill affects hunt success)
-- - 5 hunt types (royal hunt, falcon hunt, bow hunt, spear hunt, drive hunt)
-- - Game population management (sustainable hunting)
-- - Hunting seasons (restrictions by season)
-- - Trophy system (rare kills bring prestige)
-- - Hunting dogs (specialized breeds)
-- - Royal hunting parties

local Hunt = {}

-- ============================================================
-- GAME ANIMAL TYPES
-- ============================================================
local GAME_ANIMALS = {
    deer = {
        name = "Jelen",
        nameEn = "Deer",
        foodValue = 50,
        trophyValue = 10,
        rarity = 2,
        difficulty = 3,
        description = "Najpogostejša divjad za kraljevske lovc.",
    },
    boar = {
        name = "Merjavec",
        nameEn = "Wild Boar",
        foodValue = 80,
        trophyValue = 20,
        rarity = 3,
        difficulty = 5,
        danger = 0.15,
        description = "Nevarna divjad, velika trofeja.",
    },
    fox = {
        name = "Lisica",
        nameEn = "Fox",
        foodValue = 15,
        trophyValue = 15,
        rarity = 2,
        difficulty = 4,
        description = "Hitra in zvita, priljubljena za lov s psi.",
    },
    hare = {
        name = "Zajec",
        nameEn = "Hare",
        foodValue = 20,
        trophyValue = 5,
        rarity = 1,
        difficulty = 2,
        description = "Hitra divjad za vadbo.",
    },
    pheasant = {
        name = "Fazan",
        nameEn = "Pheasant",
        foodValue = 30,
        trophyValue = 12,
        rarity = 3,
        difficulty = 3,
        description = "Ptica za lov s sokoli.",
    },
    bear = {
        name = "Medved",
        nameEn = "Bear",
        foodValue = 150,
        trophyValue = 50,
        rarity = 5,
        difficulty = 9,
        danger = 0.30,
        description = "Najnevarnejša divjad — za najboljše lovce.",
    },
}

-- ============================================================
-- HUNTING PRESERVE BUILDINGS
-- ============================================================
local BUILDINGS = {
    forest = {
        name = "Lovski gozd",
        cost = { gold = 300, wood = 100 },
        upkeep = 10,
        gameCapacity = 50,
        sustainabilityBonus = 0.10,
        description = "Gozd za gojenje divjadi.",
    },
    park = {
        name = "Lovski park",
        cost = { gold = 1000, wood = 200, stone = 200 },
        upkeep = 30,
        gameCapacity = 100,
        sustainabilityBonus = 0.20,
        prestigeBonus = 5,
        description = "Ograjen park za divjad.",
    },
    warren = {
        name = "Zajčji vrt",
        cost = { gold = 200, wood = 50 },
        upkeep = 5,
        gameCapacity = 30,
        sustainabilityBonus = 0.30,
        description = "Vzreja zajcev in majhne divjadi.",
    },
    royal_preserve = {
        name = "Kraljevi rezervat",
        cost = { gold = 5000, wood = 500, stone = 1000 },
        upkeep = 100,
        gameCapacity = 300,
        sustainabilityBonus = 0.40,
        prestigeBonus = 20,
        description = "Veliki kraljevi rezervat z vsemi vrstami divjadi.",
    },
}

-- ============================================================
-- HUNT TYPES
-- ============================================================
local HUNT_TYPES = {
    royal_hunt = {
        name = "Kraljevi lov",
        nameEn = "Royal Hunt",
        duration = 3,
        cost = 500,
        successBonus = 0.20,
        prestigeBonus = 15,
        description = "Veliki organizirani lov z dvorom.",
    },
    falcon_hunt = {
        name = "Sokolarski lov",
        nameEn = "Falcon Hunt",
        duration = 1,
        cost = 100,
        successBonus = 0.15,
        requiresFalcon = true,
        description = "Lov s sokoli za ptice in zajce.",
    },
    bow_hunt = {
        name = "Lokostrelski lov",
        nameEn = "Bow Hunt",
        duration = 2,
        cost = 200,
        successBonus = 0.10,
        description = "Lov z lokom in puščicami.",
    },
    spear_hunt = {
        name = "Kopljični lov",
        nameEn = "Spear Hunt",
        duration = 2,
        cost = 150,
        successBonus = 0.05,
        dangerBonus = 0.10,
        description = "Lov s kopjem za veliko divjad.",
    },
    drive_hunt = {
        name = "Poganjalni lov",
        nameEn = "Drive Hunt",
        duration = 1,
        cost = 300,
        successBonus = 0.25,
        description = "Poganjanje divjadi s psi in lovci.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Hunt.preserves = {}                       -- Built preserves
Hunt.gamePopulations = {}                 -- Animal populations per type
Hunt.masterOfHunt = nil                   -- Hired Master of Hunt NPC
Hunt.activeHunts = {}                     -- Ongoing hunts
Hunt.trophyCollection = {}                -- Trophies collected
Hunt.huntingDogs = {}                     -- Trained dogs
Hunt.totalHunts = 0
Hunt.totalFoodGained = 0
Hunt.totalTrophies = 0
Hunt.totalIncidents = 0
Hunt.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Hunt.init()
    Hunt.preserves = {}
    Hunt.gamePopulations = {}
    -- Initialize populations
    for animalId, _ in pairs(GAME_ANIMALS) do
        Hunt.gamePopulations[animalId] = 20
    end
    Hunt.masterOfHunt = nil
    Hunt.activeHunts = {}
    Hunt.trophyCollection = {}
    Hunt.huntingDogs = {}
    Hunt.totalHunts = 0
    Hunt.totalFoodGained = 0
    Hunt.totalTrophies = 0
    Hunt.totalIncidents = 0
    Hunt.dayTimer = 0
    print("[Hunt] Royal Master of Hunt & Game System initialized (6 animals, 4 preserves, 5 hunts)")
end

-- ============================================================
-- MASTER OF HUNT NPC
-- ============================================================
function Hunt.hireMasterOfHunt(name, skill)
    skill = skill or math.random(40, 90)
    local cost = 400 + skill * 8
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Hunt.masterOfHunt = {
        name = name or ("Mojster lova " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        huntsLed = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Mojster lova najet: %s (spretnost: %d)", Hunt.masterOfHunt.name, skill), "success")
    end
    return true
end

-- ============================================================
-- PRESERVE CONSTRUCTION
-- ============================================================
function Hunt.canBuild(buildingId)
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

function Hunt.build(buildingId)
    local ok, err = Hunt.canBuild(buildingId)
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
    table.insert(Hunt.preserves, {
        type = buildingId,
        builtDay = os.time(),
    })
    -- Increase game populations
    for animalId, _ in pairs(GAME_ANIMALS) do
        Hunt.gamePopulations[animalId] = (Hunt.gamePopulations[animalId] or 0) + 10
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Hunt.getTotalGameCapacity()
    local cap = 0
    for _, p in ipairs(Hunt.preserves) do
        local def = BUILDINGS[p.type]
        if def and def.gameCapacity then cap = cap + def.gameCapacity end
    end
    return cap
end

function Hunt.getSustainabilityBonus()
    local bonus = 0
    for _, p in ipairs(Hunt.preserves) do
        local def = BUILDINGS[p.type]
        if def and def.sustainabilityBonus then bonus = math.max(bonus, def.sustainabilityBonus) end
    end
    return bonus
end

function Hunt.getPrestigeBonus()
    local bonus = 0
    for _, p in ipairs(Hunt.preserves) do
        local def = BUILDINGS[p.type]
        if def and def.prestigeBonus then bonus = bonus + def.prestigeBonus end
    end
    return bonus
end

-- ============================================================
-- GAME POPULATION MANAGEMENT
-- ============================================================
function Hunt.updateGamePopulations()
    local sustainability = Hunt.getSustainabilityBonus()
    local capacity = Hunt.getTotalGameCapacity()
    for animalId, pop in pairs(Hunt.gamePopulations) do
        -- Natural growth (slower if near capacity)
        local growthRate = 0.05 * (1 + sustainability)
        if pop < capacity then
            local growth = math.floor(pop * growthRate)
            Hunt.gamePopulations[animalId] = math.min(capacity, pop + growth)
        end
    end
end

-- ============================================================
-- HUNTING DOGS
-- ============================================================
function Hunt.trainDog(breed, name)
    local breeds = {
        bloodhound = { name = "Krvavi pes", skill = 30, cost = 200 },
        greyhound = { name = "Hrt", skill = 25, cost = 150 },
        mastiff = { name = "Mastif", skill = 20, cost = 300 },
        beagle = { name = "Bigel", skill = 15, cost = 100 },
    }
    local def = breeds[breed]
    if not def then return false, "Neznana pasma" end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - def.cost
    local dog = {
        id = "dog_" .. tostring(os.time()),
        breed = breed,
        name = name or (def.name .. " " .. #Hunt.huntingDogs + 1),
        skill = def.skill,
        trained = 0,
        health = 100,
    }
    table.insert(Hunt.huntingDogs, dog)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Pes urjen: %s (%s)", dog.name, def.name), "success")
    end
    return true
end

function Hunt.getDogBonus()
    local bonus = 0
    for _, d in ipairs(Hunt.huntingDogs) do
        if d.health > 50 then
            bonus = bonus + (d.skill + d.trained) / 100
        end
    end
    return bonus
end

-- ============================================================
-- HUNTING
-- ============================================================
function Hunt.canHunt(huntType, targetAnimal)
    local def = HUNT_TYPES[huntType]
    if not def then return false, "Neznan tip lova" end
    local animal = GAME_ANIMALS[targetAnimal]
    if not animal then return false, "Neznana divjad" end
    if (Hunt.gamePopulations[targetAnimal] or 0) < 5 then
        return false, "Premajhna populacija"
    end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    if not Hunt.masterOfHunt then
        return false, "Potreben mojster lova"
    end
    return true
end

function Hunt.organizeHunt(huntType, targetAnimal)
    local ok, err = Hunt.canHunt(huntType, targetAnimal)
    if not ok then return false, err end
    local def = HUNT_TYPES[huntType]
    local animal = GAME_ANIMALS[targetAnimal]
    _G.state.gold = _G.state.gold - def.cost
    -- Calculate success chance
    local successChance = 0.40 + def.successBonus
    if Hunt.masterOfHunt then
        successChance = successChance + (Hunt.masterOfHunt.skill / 200)
    end
    successChance = successChance + Hunt.getDogBonus() * 0.10
    -- Animal difficulty reduces chance
    successChance = successChance - (animal.difficulty / 20)
    successChance = math.max(0.10, math.min(0.90, successChance))
    local hunt = {
        id = "hunt_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        huntType = huntType,
        huntName = def.name,
        targetAnimal = targetAnimal,
        animalName = animal.name,
        daysRemaining = def.duration,
        successChance = successChance,
        dangerBonus = def.dangerBonus or 0,
        animalDanger = animal.danger or 0,
        foodValue = animal.foodValue,
        trophyValue = animal.trophyValue,
        started = os.time(),
    }
    table.insert(Hunt.activeHunts, hunt)
    Hunt.totalHunts = Hunt.totalHunts + 1
    if Hunt.masterOfHunt then
        Hunt.masterOfHunt.huntsLed = Hunt.masterOfHunt.huntsLed + 1
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Lov organiziran: %s na %s (%.0f%% uspeha)",
                def.name, animal.name, successChance * 100), "info")
    end
    return true
end

function Hunt.completeHunt(hunt)
    -- Roll for danger incident
    local incidentChance = hunt.animalDanger + hunt.dangerBonus
    if math.random() < incidentChance then
        Hunt.totalIncidents = Hunt.totalIncidents + 1
        if _G.state and _G.state.happiness then
            _G.state.happiness = math.max(0, _G.state.happiness - 5)
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                "Lovski incident! Lovca poškodovan.", "warning")
        end
    end
    -- Reduce population
    Hunt.gamePopulations[hunt.targetAnimal] = math.max(0,
        (Hunt.gamePopulations[hunt.targetAnimal] or 0) - math.random(2, 5))
    -- Roll for success
    if math.random() < hunt.successChance then
        -- Success!
        local foodGained = hunt.foodValue * math.random(2, 4)
        if _G.state and _G.state.resources then
            _G.state.resources.food = (_G.state.resources.food or 0) + foodGained
        end
        Hunt.totalFoodGained = Hunt.totalFoodGained + foodGained
        -- Trophy chance
        if math.random() < (hunt.trophyValue / 100) then
            table.insert(Hunt.trophyCollection, {
                animal = hunt.animalName,
                value = hunt.trophyValue,
                acquiredDay = os.time(),
            })
            Hunt.totalTrophies = Hunt.totalTrophies + 1
            if _G.state and _G.state.happiness then
                _G.state.happiness = math.min(100, _G.state.happiness + 3)
            end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("TROFEJA! %s ulovljen — %d prestiža",
                        hunt.animalName, hunt.trophyValue), "rare")
            end
        end
        -- Prestige
        local def = HUNT_TYPES[hunt.huntType]
        if def.prestigeBonus and _G.state and _G.state.happiness then
            _G.state.happiness = math.min(100, _G.state.happiness + (def.prestigeBonus / 5))
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Lov uspešen! %s ulovljen (+%d hrane)",
                    hunt.animalName, foodGained), "success")
        end
        -- Skill progression
        if Hunt.masterOfHunt and math.random() < 0.20 then
            Hunt.masterOfHunt.skill = math.min(100, Hunt.masterOfHunt.skill + 1)
        end
    else
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Lov spodletel: %s pobegnil", hunt.animalName), "warning")
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Hunt.update(dt)
    if not _G.state then return end
    Hunt.dayTimer = Hunt.dayTimer + dt
    if Hunt.dayTimer >= 30 then
        Hunt.dayTimer = 0
        -- Update populations
        Hunt.updateGamePopulations()
        -- Process active hunts
        for i = #Hunt.activeHunts, 1, -1 do
            local h = Hunt.activeHunts[i]
            h.daysRemaining = h.daysRemaining - 1
            if h.daysRemaining <= 0 then
                Hunt.completeHunt(h)
                table.remove(Hunt.activeHunts, i)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, p in ipairs(Hunt.preserves) do
            local def = BUILDINGS[p.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        for _, d in ipairs(Hunt.huntingDogs) do
            totalUpkeep = totalUpkeep + 3
        end
        if Hunt.masterOfHunt then totalUpkeep = totalUpkeep + 25 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Train dogs slowly
        for _, d in ipairs(Hunt.huntingDogs) do
            if d.trained < 50 and math.random() < 0.10 then
                d.trained = d.trained + 1
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Hunt.getAnimalInfo(animalId) return GAME_ANIMALS[animalId] end
function Hunt.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end
function Hunt.getHuntTypeInfo(huntId) return HUNT_TYPES[huntId] end

function Hunt.getStats()
    return {
        numPreserves = #Hunt.preserves,
        gameCapacity = Hunt.getTotalGameCapacity(),
        gamePopulations = Hunt.gamePopulations,
        hasMasterOfHunt = Hunt.masterOfHunt ~= nil,
        masterOfHuntName = Hunt.masterOfHunt and Hunt.masterOfHunt.name or "—",
        masterOfHuntSkill = Hunt.masterOfHunt and Hunt.masterOfHunt.skill or 0,
        activeHunts = #Hunt.activeHunts,
        numDogs = #Hunt.huntingDogs,
        totalHunts = Hunt.totalHunts,
        totalFoodGained = Hunt.totalFoodGained,
        totalTrophies = Hunt.totalTrophies,
        totalIncidents = Hunt.totalIncidents,
        trophyCollection = #Hunt.trophyCollection,
        prestigeBonus = Hunt.getPrestigeBonus(),
    }
end

return Hunt
