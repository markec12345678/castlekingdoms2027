-- objects/Gameplay/RoyalFalconerHawkingSystem.lua
-- Castle Kingdoms 2027 v3.3.9 - Royal Falconer & Hawking System
--
-- Manages falconry: training birds of prey, hawking expeditions, and
-- falconer NPCs. Provides food, prestige, and sport.
--
-- Features:
-- - 6 raptor types (peregrine falcon, goshawk, eagle, merlin, sparrowhawk, gyrfalcon)
-- - 4 falconry buildings (mews, aviary, training ground, breeding facility)
-- - Falconer NPC (skill affects training and hunting)
-- - Bird training (obedience, hunting skill)
-- - Hawking expeditions (food + prestige)
-- - Bird breeding (rare raptors)
-- - Bird health and molting
-- - Falconry competitions

local Falconer = {}

-- ============================================================
-- RAPTOR TYPES
-- ============================================================
local RAPTORS = {
    peregrine = {
        name = "Sokol skalnar",
        nameEn = "Peregrine Falcon",
        cost = 800,
        upkeep = 20,
        huntingSkill = 30,
        speed = 2.5,
        prestige = 15,
        lifespan = 400,
        rarity = 3,
        description = "Najhitrejša ptica na svetu.",
    },
    goshawk = {
        name = "Kragulj",
        nameEn = "Goshawk",
        cost = 400,
        upkeep = 12,
        huntingSkill = 25,
        speed = 2.0,
        prestige = 8,
        lifespan = 350,
        rarity = 2,
        description = "Agresiven in učinkovit lovec.",
    },
    eagle = {
        name = "Orel",
        nameEn = "Eagle",
        cost = 2000,
        upkeep = 50,
        huntingSkill = 40,
        speed = 1.8,
        prestige = 30,
        lifespan = 500,
        rarity = 5,
        description = "Kralj ptic — redki in veličasten.",
    },
    merlin = {
        name = "Mali sokol",
        nameEn = "Merlin",
        cost = 200,
        upkeep = 6,
        huntingSkill = 15,
        speed = 2.2,
        prestige = 4,
        lifespan = 250,
        rarity = 1,
        description = "Majhen a hiter sokol.",
    },
    sparrowhawk = {
        name = "Kobac",
        nameEn = "Sparrowhawk",
        cost = 150,
        upkeep = 4,
        huntingSkill = 12,
        speed = 1.8,
        prestige = 3,
        lifespan = 200,
        rarity = 1,
        description = "Majhen lovec za začetnike.",
    },
    gyrfalcon = {
        name = "Polarni sokol",
        nameEn = "Gyrfalcon",
        cost = 3000,
        upkeep = 70,
        huntingSkill = 50,
        speed = 2.8,
        prestige = 40,
        lifespan = 450,
        rarity = 5,
        description = "Največji in najredkeši sokol — kraljevska ptica.",
    },
}

-- ============================================================
-- FALCONRY BUILDINGS
-- ============================================================
local BUILDINGS = {
    mews = {
        name = "Sokolarnica",
        cost = { gold = 400, wood = 200 },
        upkeep = 10,
        capacity = 5,
        healthBonus = 5,
        description = "Hiša za ptice prey.",
    },
    aviary = {
        name = "Letarica",
        cost = { gold = 1500, wood = 400, stone = 200 },
        upkeep = 30,
        capacity = 15,
        healthBonus = 10,
        trainingBonus = 5,
        description = "Velik prostor za letenje in urjenje.",
    },
    training_ground = {
        name = "Urjenišče",
        cost = { gold = 2000, wood = 300, stone = 400 },
        upkeep = 40,
        capacity = 20,
        healthBonus = 8,
        trainingBonus = 20,
        description = "Posebno območje za urjenje ptic.",
    },
    breeding_facility = {
        name = "Reja sokolov",
        cost = { gold = 5000, wood = 500, stone = 800 },
        upkeep = 80,
        capacity = 30,
        healthBonus = 15,
        trainingBonus = 10,
        breedingBonus = 0.30,
        description = "Napredna reja redkih ptic.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Falconer.birds = {}                       -- Owned birds
Falconer.buildings = {}                   -- Built mews/aviaries
Falconer.falconer = nil                   -- Hired falconer NPC
Falconer.activeTrainings = {}             -- Birds in training
Falconer.activeHunts = {}                 -- Active hawking expeditions
Falconer.activeBreedings = {}             -- Breeding pairs
Falconer.totalHunts = 0
Falconer.totalFoodFromHunts = 0
Falconer.totalBirdsBred = 0
Falconer.totalCompetitionsWon = 0
Falconer.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Falconer.init()
    Falconer.birds = {}
    Falconer.buildings = {}
    Falconer.falconer = nil
    Falconer.activeTrainings = {}
    Falconer.activeHunts = {}
    Falconer.activeBreedings = {}
    Falconer.totalHunts = 0
    Falconer.totalFoodFromHunts = 0
    Falconer.totalBirdsBred = 0
    Falconer.totalCompetitionsWon = 0
    Falconer.dayTimer = 0
    print("[Falconer] Royal Falconer & Hawking System initialized (6 raptors, 4 buildings)")
end

-- ============================================================
-- FALCONER NPC
-- ============================================================
function Falconer.hireFalconer(name, skill)
    skill = skill or math.random(40, 90)
    local cost = 400 + skill * 8
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Falconer.falconer = {
        name = name or ("Sokolar " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        birdsTrained = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Sokolar najet: %s (spretnost: %d)", Falconer.falconer.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Falconer.canBuild(buildingId)
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

function Falconer.build(buildingId)
    local ok, err = Falconer.canBuild(buildingId)
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
    table.insert(Falconer.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Falconer.getTotalCapacity()
    local cap = 0
    for _, b in ipairs(Falconer.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.capacity then cap = cap + def.capacity end
    end
    return cap
end

function Falconer.getHealthBonus()
    local bonus = 0
    for _, b in ipairs(Falconer.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.healthBonus then bonus = math.max(bonus, def.healthBonus) end
    end
    return bonus
end

function Falconer.getTrainingBonus()
    local bonus = 0
    for _, b in ipairs(Falconer.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.trainingBonus then bonus = bonus + def.trainingBonus end
    end
    return bonus
end

function Falconer.getBreedingBonus()
    local bonus = 0
    for _, b in ipairs(Falconer.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.breedingBonus then bonus = bonus + def.breedingBonus end
    end
    return bonus
end

-- ============================================================
-- BIRD ACQUISITION
-- ============================================================
function Falconer.canAcquire(raptorType)
    local def = RAPTORS[raptorType]
    if not def then return false, "Neznana ptica" end
    if #Falconer.birds >= Falconer.getTotalCapacity() then
        return false, "Sokolarnica je polna"
    end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    return true
end

function Falconer.acquire(raptorType, customName)
    local ok, err = Falconer.canAcquire(raptorType)
    if not ok then return false, err end
    local def = RAPTORS[raptorType]
    _G.state.gold = _G.state.gold - def.cost
    local bird = {
        id = "bird_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = raptorType,
        name = customName or (def.name .. " " .. #Falconer.birds + 1),
        age = 0,
        health = 100,
        training = 0,
        huntingSkill = def.huntingSkill,
        speed = def.speed,
        prestige = def.prestige,
        molting = false,
        acquiredDay = os.time(),
    }
    table.insert(Falconer.birds, bird)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Ptica pridobljena: %s (%s)", bird.name, def.name), "success")
    end
    return true, bird.id
end

function Falconer.findBird(birdId)
    for _, b in ipairs(Falconer.birds) do
        if b.id == birdId then return b end
    end
    return nil
end

-- ============================================================
-- TRAINING
-- ============================================================
function Falconer.canTrain(birdId)
    local b = Falconer.findBird(birdId)
    if not b then return false, "Ptica ne obstaja" end
    if b.training >= 100 then return false, "Ptica je že popolnoma urjena" end
    if b.molting then return false, "Ptica je v fazi menjave perja" end
    if not Falconer.falconer then return false, "Potreben sokolar" end
    local hasTrainingBuilding = false
    for _, build in ipairs(Falconer.buildings) do
        if build.type ~= "mews" then hasTrainingBuilding = true; break end
    end
    if not hasTrainingBuilding then return false, "Potrebna urjeniška zgradba" end
    return true
end

function Falconer.startTraining(birdId)
    local ok, err = Falconer.canTrain(birdId)
    if not ok then return false, err end
    local training = {
        id = "training_" .. tostring(os.time()),
        birdId = birdId,
        daysRemaining = 10,
        started = os.time(),
    }
    table.insert(Falconer.activeTrainings, training)
    if _G.NotificationCenter then
        local b = Falconer.findBird(birdId)
        pcall(_G.NotificationCenter.notify,
            string.format("Urjenje ptice začeto: %s", b and b.name or "?"), "info")
    end
    return true
end

function Falconer.completeTraining(training)
    local b = Falconer.findBird(training.birdId)
    if not b then return end
    local trainingGain = 15 + Falconer.getTrainingBonus()
    if Falconer.falconer then
        trainingGain = trainingGain + math.floor(Falconer.falconer.skill / 5)
    end
    b.training = math.min(100, b.training + trainingGain)
    b.huntingSkill = b.huntingSkill + math.floor(trainingGain / 3)
    Falconer.totalHunts = Falconer.totalHunts  -- just to track
    if Falconer.falconer then
        Falconer.falconer.birdsTrained = Falconer.falconer.birdsTrained + 1
        if math.random() < 0.15 then
            Falconer.falconer.skill = math.min(100, Falconer.falconer.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Ptica urjena: %s (+%d urjenja)", b.name, trainingGain), "success")
    end
end

-- ============================================================
-- HAWKING (HUNTING)
-- ============================================================
function Falconer.canHunt(birdId)
    local b = Falconer.findBird(birdId)
    if not b then return false, "Ptica ne obstaja" end
    if b.health < 60 then return false, "Ptica ni zdrava" end
    if b.molting then return false, "Ptica menja perje" end
    if b.training < 20 then return false, "Ptica ni dovolj urjena" end
    return true
end

function Falconer.startHunt(birdId)
    local ok, err = Falconer.canHunt(birdId)
    if not ok then return false, err end
    local hunt = {
        id = "hunt_" .. tostring(os.time()),
        birdId = birdId,
        daysRemaining = 2,
        started = os.time(),
    }
    table.insert(Falconer.activeHunts, hunt)
    if _G.NotificationCenter then
        local b = Falconer.findBird(birdId)
        pcall(_G.NotificationCenter.notify,
            string.format("Sokolanje začeto: %s", b and b.name or "?"), "info")
    end
    return true
end

function Falconer.completeHunt(hunt)
    local b = Falconer.findBird(hunt.birdId)
    if not b then return end
    -- Calculate food gain
    local foodGained = b.huntingSkill * (b.training / 50)
    if Falconer.falconer then
        foodGained = foodGained * (1 + Falconer.falconer.skill / 100)
    end
    foodGained = math.floor(foodGained)
    if _G.state and _G.state.resources then
        _G.state.resources.food = (_G.state.resources.food or 0) + foodGained
    end
    Falconer.totalHunts = Falconer.totalHunts + 1
    Falconer.totalFoodFromHunts = Falconer.totalFoodFromHunts + foodGained
    -- Bird tires
    b.health = math.max(0, b.health - 15)
    -- Training boost from real hunting
    b.training = math.min(100, b.training + 2)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Lov uspešen! %s prinesel %d hrane", b.name, foodGained), "success")
    end
end

-- ============================================================
-- BREEDING
-- ============================================================
function Falconer.canBreed(birdId1, birdId2)
    local b1 = Falconer.findBird(birdId1)
    local b2 = Falconer.findBird(birdId2)
    if not b1 or not b2 then return false, "Ptica ne obstaja" end
    if b1.type ~= b2.type then return false, "Različni tipi ptic" end
    local hasBreeding = false
    for _, b in ipairs(Falconer.buildings) do
        if b.type == "breeding_facility" then hasBreeding = true; break end
    end
    if not hasBreeding then return false, "Potrebna reja sokolov" end
    if #Falconer.birds >= Falconer.getTotalCapacity() then
        return false, "Sokolarnica je polna"
    end
    return true
end

function Falconer.startBreeding(birdId1, birdId2)
    local ok, err = Falconer.canBreed(birdId1, birdId2)
    if not ok then return false, err end
    local b1 = Falconer.findBird(birdId1)
    local breeding = {
        id = "breeding_" .. tostring(os.time()),
        parent1 = birdId1,
        parent2 = birdId2,
        raptorType = b1.type,
        daysRemaining = 45,
        started = os.time(),
    }
    table.insert(Falconer.activeBreedings, breeding)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Vzreja začeta: %s", b1.name), "info")
    end
    return true
end

function Falconer.completeBreeding(breeding)
    local def = RAPTORS[breeding.raptorType]
    if not def then return end
    local successChance = 0.40 + Falconer.getBreedingBonus()
    if Falconer.falconer then
        successChance = successChance + (Falconer.falconer.skill / 200)
    end
    if math.random() < successChance then
        local chick = {
            id = "bird_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
            type = breeding.raptorType,
            name = def.name .. " mladič " .. math.random(1, 99),
            age = 0,
            health = 90,
            training = 0,
            huntingSkill = def.huntingSkill * 1.1,  -- slight improvement
            speed = def.speed * 1.05,
            prestige = def.prestige,
            molting = false,
            acquiredDay = os.time(),
            isBred = true,
        }
        table.insert(Falconer.birds, chick)
        Falconer.totalBirdsBred = Falconer.totalBirdsBred + 1
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Mladič vzrejen: %s!", chick.name), "rare")
        end
    else
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Vzreja neuspešna.", "warning")
        end
    end
end

-- ============================================================
-- COMPETITIONS
-- ============================================================
function Falconer.enterCompetition(birdId)
    local b = Falconer.findBird(birdId)
    if not b then return false, "Ptica ne obstaja" end
    if b.health < 80 then return false, "Ptica ni dovolj zdrava" end
    if b.training < 50 then return false, "Ptica ni dovolj urjena" end
    if not _G.state or (_G.state.gold or 0) < 300 then
        return false, "Premalo zlata za vstopnino"
    end
    _G.state.gold = _G.state.gold - 300
    -- Win chance based on training, speed, and skill
    local winChance = 0.20 + (b.training / 200) + (b.speed / 10) + (b.huntingSkill / 200)
    winChance = math.min(0.85, winChance)
    if math.random() < winChance then
        local prize = math.random(500, 2000)
        if _G.state then
            _G.state.gold = (_G.state.gold or 0) + prize
        end
        Falconer.totalCompetitionsWon = Falconer.totalCompetitionsWon + 1
        if _G.state and _G.state.happiness then
            _G.state.happiness = math.min(100, _G.state.happiness + 5)
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("ZMAGA na tekmovanju! %s (+%d zlata)", b.name, prize), "success")
        end
    else
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Poraz na tekmovanju: %s", b.name), "info")
        end
    end
    b.health = math.max(0, b.health - 20)
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Falconer.update(dt)
    if not _G.state then return end
    Falconer.dayTimer = Falconer.dayTimer + dt
    if Falconer.dayTimer >= 30 then
        Falconer.dayTimer = 0
        -- Update birds
        local healthBonus = Falconer.getHealthBonus()
        for i = #Falconer.birds, 1, -1 do
            local b = Falconer.birds[i]
            local def = RAPTORS[b.type]
            if not def then
                table.remove(Falconer.birds, i)
            else
                b.age = b.age + 1
                b.health = math.min(100, b.health + (healthBonus / 10))
                -- Molting (random)
                if not b.molting and math.random() < 0.02 then
                    b.molting = true
                    b.moltingDays = 14
                    if _G.NotificationCenter then
                        pcall(_G.NotificationCenter.notify,
                            string.format("%s menja perje.", b.name), "info")
                    end
                end
                if b.molting then
                    b.moltingDays = b.moltingDays - 1
                    if b.moltingDays <= 0 then
                        b.molting = false
                    end
                end
                -- Death from old age
                if b.age >= def.lifespan then
                    if _G.NotificationCenter then
                        pcall(_G.NotificationCenter.notify,
                            string.format("%s umrl(a) od starosti.", b.name), "warning")
                    end
                    table.remove(Falconer.birds, i)
                end
            end
        end
        -- Process trainings
        for i = #Falconer.activeTrainings, 1, -1 do
            local t = Falconer.activeTrainings[i]
            t.daysRemaining = t.daysRemaining - 1
            if t.daysRemaining <= 0 then
                Falconer.completeTraining(t)
                table.remove(Falconer.activeTrainings, i)
            end
        end
        -- Process hunts
        for i = #Falconer.activeHunts, 1, -1 do
            local h = Falconer.activeHunts[i]
            h.daysRemaining = h.daysRemaining - 1
            if h.daysRemaining <= 0 then
                Falconer.completeHunt(h)
                table.remove(Falconer.activeHunts, i)
            end
        end
        -- Process breedings
        for i = #Falconer.activeBreedings, 1, -1 do
            local b = Falconer.activeBreedings[i]
            b.daysRemaining = b.daysRemaining - 1
            if b.daysRemaining <= 0 then
                Falconer.completeBreeding(b)
                table.remove(Falconer.activeBreedings, i)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Falconer.birds) do
            local def = RAPTORS[b.type]
            if def then totalUpkeep = totalUpkeep + def.upkeep end
        end
        for _, build in ipairs(Falconer.buildings) do
            local def = BUILDINGS[build.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Falconer.falconer then totalUpkeep = totalUpkeep + 25 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Falconer.getRaptorInfo(raptorId) return RAPTORS[raptorId] end
function Falconer.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Falconer.getStats()
    return {
        numBirds = #Falconer.birds,
        capacity = Falconer.getTotalCapacity(),
        numBuildings = #Falconer.buildings,
        hasFalconer = Falconer.falconer ~= nil,
        falconerName = Falconer.falconer and Falconer.falconer.name or "—",
        falconerSkill = Falconer.falconer and Falconer.falconer.skill or 0,
        activeTrainings = #Falconer.activeTrainings,
        activeHunts = #Falconer.activeHunts,
        activeBreedings = #Falconer.activeBreedings,
        totalHunts = Falconer.totalHunts,
        totalFoodFromHunts = Falconer.totalFoodFromHunts,
        totalBirdsBred = Falconer.totalBirdsBred,
        totalCompetitionsWon = Falconer.totalCompetitionsWon,
    }
end

return Falconer
