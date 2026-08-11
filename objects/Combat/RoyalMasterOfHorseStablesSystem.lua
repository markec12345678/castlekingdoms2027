-- objects/Combat/RoyalMasterOfHorseStablesSystem.lua
-- Castle Kingdoms 2027 v3.3.6 - Royal Master of Horse & Stables System
--
-- Manages royal stables, horse breeding, cavalry training, and equestrian events.
-- Horses provide speed, combat bonuses, and prestige.
--
-- Features:
-- - 6 horse types (destrier, courser, palfrey, rouncey, sumpter, warhorse)
-- - 4 stable buildings (paddock, stable, riding hall, breeding farm)
-- - Master of Horse NPC (skill affects training and breeding)
-- - Horse breeding (rare combinations)
-- - Horse training (combat and speed bonuses)
-- - Equestrian events (races, shows)
-- - Cavalry unit bonuses
-- - Horse trading
-- - Horse health and age

local Stables = {}

-- ============================================================
-- HORSE TYPES
-- ============================================================
local HORSES = {
    destrier = {
        name = "Bojni konj",
        nameEn = "Destrier",
        cost = 500,
        upkeep = 15,
        speed = 1.2,
        combatBonus = 25,
        prestige = 10,
        lifespan = 500,
        description = "Najboljši bojni konj — močan in pogum.",
    },
    courser = {
        name = "Hitrovec",
        nameEn = "Courser",
        cost = 300,
        upkeep = 10,
        speed = 1.5,
        combatBonus = 15,
        prestige = 8,
        lifespan = 450,
        description = "Hitri konj za lov in boj.",
    },
    palfrey = {
        name = "Palfrej",
        nameEn = "Palfrey",
        cost = 200,
        upkeep = 8,
        speed = 1.3,
        combatBonus = 5,
        prestige = 12,
        lifespan = 500,
        description = "Udobjen konj za plemstvo.",
    },
    rouncey = {
        name = "Konj za vse namene",
        nameEn = "Rouncey",
        cost = 100,
        upkeep = 5,
        speed = 1.2,
        combatBonus = 8,
        prestige = 3,
        lifespan = 400,
        description = "Vsestranski konj za navadne viteze.",
    },
    sumpter = {
        name = "Tovorni konj",
        nameEn = "Sumpter",
        cost = 50,
        upkeep = 3,
        speed = 0.8,
        combatBonus = 0,
        prestige = 0,
        cargoCapacity = 200,
        lifespan = 400,
        description = "Konj za prevoz blaga.",
    },
    warhorse = {
        name = "Težki bojni konj",
        nameEn = "Warhorse",
        cost = 1000,
        upkeep = 25,
        speed = 1.0,
        combatBonus = 40,
        prestige = 20,
        lifespan = 550,
        description = "Najmočnejši konj — redki in dragi.",
    },
}

-- ============================================================
-- STABLE BUILDINGS
-- ============================================================
local BUILDINGS = {
    paddock = {
        name = "Pašnik",
        cost = { gold = 100, wood = 50 },
        upkeep = 2,
        capacity = 5,
        healthBonus = 5,
        description = "Preprost pašnik za konje.",
    },
    stable = {
        name = "Hlev",
        cost = { gold = 500, wood = 200, stone = 100 },
        upkeep = 15,
        capacity = 20,
        healthBonus = 10,
        trainingBonus = 5,
        description = "Stalni hlev s prostori.",
    },
    riding_hall = {
        name = "Jahalna dvorana",
        cost = { gold = 2000, wood = 400, stone = 500 },
        upkeep = 40,
        capacity = 30,
        healthBonus = 15,
        trainingBonus = 20,
        prestigeBonus = 10,
        description = "Dvorana za urjenje konj.",
    },
    breeding_farm = {
        name = "Reja konj",
        cost = { gold = 5000, wood = 600, stone = 1000 },
        upkeep = 100,
        capacity = 50,
        healthBonus = 20,
        breedingBonus = 0.30,
        description = "Velika farma za vzrejo konj.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Stables.horses = {}                      -- Owned horses
Stables.buildings = {}                   -- Built stables
Stables.masterOfHorse = nil              -- Hired Master of Horse NPC
Stables.activeBreedings = {}             -- Ongoing breeding
Stables.activeTrainings = {}             -- Horses in training
Stables.activeEvents = {}                -- Equestrian events
Stables.totalHorsesBred = 0
Stables.totalHorsesTrained = 0
Stables.totalEventsWon = 0
Stables.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Stables.init()
    Stables.horses = {}
    Stables.buildings = {}
    Stables.masterOfHorse = nil
    Stables.activeBreedings = {}
    Stables.activeTrainings = {}
    Stables.activeEvents = {}
    Stables.totalHorsesBred = 0
    Stables.totalHorsesTrained = 0
    Stables.totalEventsWon = 0
    Stables.dayTimer = 0
    print("[Stables] Royal Master of Horse & Stables System initialized (6 horse types, 4 buildings)")
end

-- ============================================================
-- MASTER OF HORSE
-- ============================================================
function Stables.hireMasterOfHorse(name, skill)
    skill = skill or math.random(40, 90)
    local cost = 500 + skill * 8
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Stables.masterOfHorse = {
        name = name or ("Mojster konj " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        horsesTrained = 0,
        horsesBred = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Mojster konj najet: %s (spretnost: %d)", Stables.masterOfHorse.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Stables.canBuild(buildingId)
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

function Stables.build(buildingId)
    local ok, err = Stables.canBuild(buildingId)
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
    table.insert(Stables.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Stables.getTotalCapacity()
    local cap = 0
    for _, b in ipairs(Stables.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.capacity then cap = cap + def.capacity end
    end
    return cap
end

function Stables.getHealthBonus()
    local bonus = 0
    for _, b in ipairs(Stables.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.healthBonus then bonus = math.max(bonus, def.healthBonus) end
    end
    return bonus
end

function Stables.getTrainingBonus()
    local bonus = 0
    for _, b in ipairs(Stables.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.trainingBonus then bonus = bonus + def.trainingBonus end
    end
    return bonus
end

function Stables.getBreedingBonus()
    local bonus = 0
    for _, b in ipairs(Stables.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.breedingBonus then bonus = bonus + def.breedingBonus end
    end
    return bonus
end

-- ============================================================
-- HORSE ACQUISITION
-- ============================================================
function Stables.canAcquire(horseType)
    local def = HORSES[horseType]
    if not def then return false, "Neznan konj" end
    if #Stables.horses >= Stables.getTotalCapacity() then
        return false, "Hlev je poln"
    end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    return true
end

function Stables.acquire(horseType, customName)
    local ok, err = Stables.canAcquire(horseType)
    if not ok then return false, err end
    local def = HORSES[horseType]
    _G.state.gold = _G.state.gold - def.cost
    local horse = {
        id = "horse_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = horseType,
        name = customName or (def.name .. " " .. #Stables.horses + 1),
        age = 0,
        health = 100,
        training = 0,
        speed = def.speed,
        combatBonus = def.combatBonus,
        prestige = def.prestige,
        acquiredDay = os.time(),
    }
    table.insert(Stables.horses, horse)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Konj pridobljen: %s (%s)", horse.name, def.name), "success")
    end
    return true, horse.id
end

function Stables.findHorse(horseId)
    for _, h in ipairs(Stables.horses) do
        if h.id == horseId then return h end
    end
    return nil
end

-- ============================================================
-- TRAINING
-- ============================================================
function Stables.canTrain(horseId)
    local h = Stables.findHorse(horseId)
    if not h then return false, "Konj ne obstaja" end
    if h.training >= 100 then return false, "Konj je že popolnoma urjen" end
    -- Need riding hall or stable
    local canTrain = false
    for _, b in ipairs(Stables.buildings) do
        if b.type == "riding_hall" or b.type == "stable" then
            canTrain = true; break
        end
    end
    if not canTrain then return false, "Potrebna jahalna dvorana" end
    if not Stables.masterOfHorse then
        return false, "Potreben mojster konj"
    end
    return true
end

function Stables.startTraining(horseId)
    local ok, err = Stables.canTrain(horseId)
    if not ok then return false, err end
    local training = {
        id = "training_" .. tostring(os.time()),
        horseId = horseId,
        daysRemaining = 14,
        totalDays = 14,
        started = os.time(),
    }
    table.insert(Stables.activeTrainings, training)
    if _G.NotificationCenter then
        local h = Stables.findHorse(horseId)
        pcall(_G.NotificationCenter.notify,
            string.format("Urjenje konja začeto: %s", h and h.name or "?"), "info")
    end
    return true
end

function Stables.completeTraining(training)
    local h = Stables.findHorse(training.horseId)
    if not h then return end
    -- Increase training level
    local trainingGain = 20 + Stables.getTrainingBonus()
    if Stables.masterOfHorse then
        trainingGain = trainingGain + math.floor(Stables.masterOfHorse.skill / 5)
    end
    h.training = math.min(100, h.training + trainingGain)
    -- Apply bonuses from training
    h.combatBonus = h.combatBonus + math.floor(trainingGain / 5)
    h.speed = h.speed + (trainingGain / 200)
    Stables.totalHorsesTrained = Stables.totalHorsesTrained + 1
    if Stables.masterOfHorse then
        Stables.masterOfHorse.horsesTrained = Stables.masterOfHorse.horsesTrained + 1
        if math.random() < 0.15 then
            Stables.masterOfHorse.skill = math.min(100, Stables.masterOfHorse.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Konj urjen: %s (+%d urjenja)", h.name, trainingGain), "success")
    end
end

-- ============================================================
-- BREEDING
-- ============================================================
function Stables.canBreed(horseId1, horseId2)
    local h1 = Stables.findHorse(horseId1)
    local h2 = Stables.findHorse(horseId2)
    if not h1 or not h2 then return false, "Konj ne obstaja" end
    if h1.type ~= h2.type then
        return false, "Različni tipi konjev"
    end
    -- Need breeding farm
    local hasFarm = false
    for _, b in ipairs(Stables.buildings) do
        if b.type == "breeding_farm" then hasFarm = true; break end
    end
    if not hasFarm then return false, "Potrebna farma za rejo" end
    if #Stables.horses >= Stables.getTotalCapacity() then
        return false, "Hlev je poln"
    end
    return true
end

function Stables.startBreeding(horseId1, horseId2)
    local ok, err = Stables.canBreed(horseId1, horseId2)
    if not ok then return false, err end
    local h1 = Stables.findHorse(horseId1)
    local breeding = {
        id = "breeding_" .. tostring(os.time()),
        parent1 = horseId1,
        parent2 = horseId2,
        horseType = h1.type,
        daysRemaining = 30,
        totalDays = 30,
        started = os.time(),
    }
    table.insert(Stables.activeBreedings, breeding)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Vzreja začeta: %s", h1.name), "info")
    end
    return true
end

function Stables.completeBreeding(breeding)
    local def = HORSES[breeding.horseType]
    if not def then return end
    -- Success chance based on breeding bonus
    local successChance = 0.50 + Stables.getBreedingBonus()
    if Stables.masterOfHorse then
        successChance = successChance + (Stables.masterOfHorse.skill / 200)
    end
    if math.random() < successChance then
        -- Foal born!
        local foal = {
            id = "horse_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
            type = breeding.horseType,
            name = def.name .. " žrebič " .. math.random(1, 99),
            age = 0,
            health = 95,
            training = 0,
            speed = def.speed * 1.05,  -- slight improvement from breeding
            combatBonus = def.combatBonus,
            prestige = def.prestige,
            acquiredDay = os.time(),
            isBred = true,
        }
        table.insert(Stables.horses, foal)
        Stables.totalHorsesBred = Stables.totalHorsesBred + 1
        if Stables.masterOfHorse then
            Stables.masterOfHorse.horsesBred = Stables.masterOfHorse.horsesBred + 1
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Žrebič rojen: %s!", foal.name), "rare")
        end
        if _G.GameEventBus then
            pcall(_G.GameEventBus.publish, "HORSE_BRED", { type = breeding.horseType, name = foal.name })
        end
    else
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Vzreja neuspešna.", "warning")
        end
    end
end

-- ============================================================
-- EQUESTRIAN EVENTS
-- ============================================================
function Stables.organizeEvent(eventType, horseId)
    local h = Stables.findHorse(horseId)
    if not h then return false, "Konj ne obstaja" end
    if h.health < 70 then return false, "Konj ni zdrav" end
    if not _G.state or (_G.state.gold or 0) < 200 then
        return false, "Premalo zlata za prireditev"
    end
    _G.state.gold = _G.state.gold - 200
    local event = {
        id = "event_" .. tostring(os.time()),
        type = eventType or "race",
        horseId = horseId,
        horseName = h.name,
        daysRemaining = 3,
        started = os.time(),
    }
    table.insert(Stables.activeEvents, event)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Konjeniška prireditev organizirana: %s", h.name), "info")
    end
    return true
end

function Stables.completeEvent(event)
    local h = Stables.findHorse(event.horseId)
    if not h then return end
    -- Win chance based on training and speed
    local winChance = 0.30 + (h.training / 200) + ((h.speed - 1.0) / 2)
    winChance = math.min(0.90, winChance)
    if math.random() < winChance then
        -- Won!
        local prize = math.random(300, 1000)
        if _G.state then
            _G.state.gold = (_G.state.gold or 0) + prize
        end
        Stables.totalEventsWon = Stables.totalEventsWon + 1
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("ZMAGA na prireditvi! %s (+%d zlata)", h.name, prize), "success")
        end
    else
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Poraz na prireditvi: %s", h.name), "info")
        end
    end
    -- Horse tires
    h.health = math.max(0, h.health - 10)
end

-- ============================================================
-- HORSE UPDATES
-- ============================================================
function Stables.updateHorses()
    local healthBonus = Stables.getHealthBonus()
    for i = #Stables.horses, 1, -1 do
        local h = Stables.horses[i]
        local def = HORSES[h.type]
        if not def then
            table.remove(Stables.horses, i)
        else
            h.age = h.age + 1
            -- Health affected by buildings
            h.health = math.min(100, h.health + (healthBonus / 10))
            -- Death from old age
            if h.age >= def.lifespan then
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        string.format("%s umrl(a) od starosti.", h.name), "warning")
                end
                table.remove(Stables.horses, i)
            end
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Stables.update(dt)
    if not _G.state then return end
    Stables.dayTimer = Stables.dayTimer + dt
    if Stables.dayTimer >= 30 then
        Stables.dayTimer = 0
        Stables.updateHorses()
        -- Process trainings
        for i = #Stables.activeTrainings, 1, -1 do
            local t = Stables.activeTrainings[i]
            t.daysRemaining = t.daysRemaining - 1
            if t.daysRemaining <= 0 then
                Stables.completeTraining(t)
                table.remove(Stables.activeTrainings, i)
            end
        end
        -- Process breedings
        for i = #Stables.activeBreedings, 1, -1 do
            local b = Stables.activeBreedings[i]
            b.daysRemaining = b.daysRemaining - 1
            if b.daysRemaining <= 0 then
                Stables.completeBreeding(b)
                table.remove(Stables.activeBreedings, i)
            end
        end
        -- Process events
        for i = #Stables.activeEvents, 1, -1 do
            local e = Stables.activeEvents[i]
            e.daysRemaining = e.daysRemaining - 1
            if e.daysRemaining <= 0 then
                Stables.completeEvent(e)
                table.remove(Stables.activeEvents, i)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, h in ipairs(Stables.horses) do
            local def = HORSES[h.type]
            if def then totalUpkeep = totalUpkeep + def.upkeep end
        end
        for _, b in ipairs(Stables.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Stables.masterOfHorse then totalUpkeep = totalUpkeep + 25 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Stables.getHorseInfo(typeId) return HORSES[typeId] end
function Stables.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Stables.getActiveBonuses()
    local bonuses = {
        cavalrySpeedBonus = 1.0,
        cavalryCombatBonus = 0,
        cavalryPrestige = 0,
    }
    for _, h in ipairs(Stables.horses) do
        if h.health > 50 then
            bonuses.cavalrySpeedBonus = math.max(bonuses.cavalrySpeedBonus, h.speed)
            bonuses.cavalryCombatBonus = math.max(bonuses.cavalryCombatBonus, h.combatBonus)
            bonuses.cavalryPrestige = bonuses.cavalryPrestige + h.prestige
        end
    end
    return bonuses
end

function Stables.getStats()
    return {
        numHorses = #Stables.horses,
        capacity = Stables.getTotalCapacity(),
        numBuildings = #Stables.buildings,
        hasMasterOfHorse = Stables.masterOfHorse ~= nil,
        masterOfHorseName = Stables.masterOfHorse and Stables.masterOfHorse.name or "—",
        masterOfHorseSkill = Stables.masterOfHorse and Stables.masterOfHorse.skill or 0,
        activeTrainings = #Stables.activeTrainings,
        activeBreedings = #Stables.activeBreedings,
        activeEvents = #Stables.activeEvents,
        totalHorsesBred = Stables.totalHorsesBred,
        totalHorsesTrained = Stables.totalHorsesTrained,
        totalEventsWon = Stables.totalEventsWon,
    }
end

return Stables
