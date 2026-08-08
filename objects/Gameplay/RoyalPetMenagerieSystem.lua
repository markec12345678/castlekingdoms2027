-- objects/Gameplay/RoyalPetMenagerieSystem.lua
-- Castle Kingdoms 2027 v3.3.2 - Royal Pet & Menagerie System
--
-- Manages exotic animals kept by royalty: lions, bears, falcons, hounds.
-- Provides prestige, happiness, and unique bonuses.
--
-- Features:
-- - 8 animal types (lion, bear, falcon, hound, leopard, elephant, monkey, peacock)
-- - 4 menagerie buildings (cage, enclosure, aviary, grand menagerie)
-- - Animal caretakers (NPCs)
-- - Animal training (for performances or hunting)
-- - Animal health and happiness
-- - Breeding program (rare animals)
-- - Public exhibitions (boost happiness and prestige)
-- - Hunting with animals (falcons, hounds)

local Menagerie = {}

-- ============================================================
-- ANIMAL TYPES
-- ============================================================
local ANIMALS = {
    lion = {
        name = "Lev",
        nameEn = "Lion",
        cost = 2000,
        upkeep = 50,
        prestige = 30,
        happinessBonus = 5,
        danger = 0.10,
        lifespan = 600,
        description = "Kralj živali — simbol moči.",
    },
    bear = {
        name = "Medved",
        nameEn = "Bear",
        cost = 800,
        upkeep = 25,
        prestige = 15,
        happinessBonus = 4,
        danger = 0.08,
        lifespan = 500,
        description = "Močan medved za predstave in borbe.",
    },
    falcon = {
        name = "Sokol",
        nameEn = "Falcon",
        cost = 300,
        upkeep = 8,
        prestige = 8,
        happinessBonus = 2,
        danger = 0.01,
        lifespan = 400,
        canHunt = true,
        description = "Sokol za lov in šport.",
    },
    hound = {
        name = "Lovski pes",
        nameEn = "Hound",
        cost = 150,
        upkeep = 5,
        prestige = 3,
        happinessBonus = 3,
        danger = 0.02,
        lifespan = 300,
        canHunt = true,
        description = "Zvesti lovski pes.",
    },
    leopard = {
        name = "Panter",
        nameEn = "Leopard",
        cost = 1500,
        upkeep = 40,
        prestige = 25,
        happinessBonus = 4,
        danger = 0.12,
        lifespan = 550,
        description = "Redki eksotični panter.",
    },
    elephant = {
        name = "Slon",
        nameEn = "Elephant",
        cost = 5000,
        upkeep = 100,
        prestige = 50,
        happinessBonus = 10,
        danger = 0.05,
        lifespan = 800,
        description = "Veliki slon — redkost v Evropi.",
    },
    monkey = {
        name = "Opica",
        nameEn = "Monkey",
        cost = 200,
        upkeep = 4,
        prestige = 5,
        happinessBonus = 6,
        danger = 0.03,
        lifespan = 250,
        description = "Zabavna opica za dvorno razvedrilo.",
    },
    peacock = {
        name = "Pavan",
        nameEn = "Peacock",
        cost = 100,
        upkeep = 2,
        prestige = 4,
        happinessBonus = 3,
        danger = 0.0,
        lifespan = 300,
        description = "Čudovit pavan z razprostrtim perjem.",
    },
}

-- ============================================================
-- MENAGERIE BUILDINGS
-- ============================================================
local BUILDINGS = {
    cage = {
        name = "Kletka",
        cost = { gold = 100, wood = 50 },
        upkeep = 2,
        capacity = 2,
        healthBonus = 0,
        description = "Preprosta kletka za manjše živali.",
    },
    enclosure = {
        name = "Ograja",
        cost = { gold = 500, wood = 200, stone = 100 },
        upkeep = 10,
        capacity = 5,
        healthBonus = 5,
        description = "Odprt prostor za večje živali.",
    },
    aviary = {
        name = "Ptičnjak",
        cost = { gold = 300, wood = 150 },
        upkeep = 5,
        capacity = 10,
        healthBonus = 8,
        description = "Za ptice (sokoli, pavovani).",
    },
    grand_menagerie = {
        name = "Velika menažerija",
        cost = { gold = 3000, wood = 500, stone = 800 },
        upkeep = 50,
        capacity = 20,
        healthBonus = 15,
        prestigeBonus = 10,
        description = "Velika zbirka eksotičnih živali.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Menagerie.animals = {}
Menagerie.buildings = {}
Menagerie.caretakers = {}
Menagerie.activeExhibitions = {}
Menagerie.totalAnimalsOwned = 0
Menagerie.totalDeaths = 0
Menagerie.totalBirths = 0
Menagerie.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Menagerie.init()
    Menagerie.animals = {}
    Menagerie.buildings = {}
    Menagerie.caretakers = {}
    Menagerie.activeExhibitions = {}
    Menagerie.totalAnimalsOwned = 0
    Menagerie.totalDeaths = 0
    Menagerie.totalBirths = 0
    Menagerie.dayTimer = 0
    print("[Menagerie] Royal Pet & Menagerie System initialized (8 animals, 4 buildings)")
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Menagerie.canBuild(buildingId)
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

function Menagerie.build(buildingId)
    local ok, err = Menagerie.canBuild(buildingId)
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
    table.insert(Menagerie.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Menagerie.getTotalCapacity()
    local cap = 0
    for _, b in ipairs(Menagerie.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.capacity then cap = cap + def.capacity end
    end
    return cap
end

function Menagerie.getHealthBonus()
    local bonus = 0
    for _, b in ipairs(Menagerie.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.healthBonus then bonus = math.max(bonus, def.healthBonus) end
    end
    return bonus
end

function Menagerie.getPrestigeBonus()
    local bonus = 0
    for _, b in ipairs(Menagerie.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.prestigeBonus then bonus = bonus + def.prestigeBonus end
    end
    return bonus
end

-- ============================================================
-- ACQUISITION
-- ============================================================
function Menagerie.canAcquire(animalType)
    local def = ANIMALS[animalType]
    if not def then return false, "Neznana žival" end
    if #Menagerie.animals >= Menagerie.getTotalCapacity() then
        return false, "Premajhna menažerija"
    end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    return true
end

function Menagerie.acquire(animalType, customName)
    local ok, err = Menagerie.canAcquire(animalType)
    if not ok then return false, err end
    local def = ANIMALS[animalType]
    _G.state.gold = _G.state.gold - def.cost
    local animal = {
        id = "animal_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = animalType,
        name = customName or (def.name .. " " .. #Menagerie.animals + 1),
        age = 0,
        health = 100,
        happiness = 70,
        training = 0,
        canHunt = def.canHunt or false,
        acquiredDay = os.time(),
    }
    table.insert(Menagerie.animals, animal)
    Menagerie.totalAnimalsOwned = Menagerie.totalAnimalsOwned + 1
    if _G.state and _G.state.happiness and def.happinessBonus then
        _G.state.happiness = math.min(100, _G.state.happiness + def.happinessBonus)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Žival pridobljena: %s (%s)", animal.name, def.name), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "ANIMAL_ACQUIRED", { type = animalType, name = animal.name })
    end
    return true, animal.id
end

function Menagerie.findAnimal(animalId)
    for _, a in ipairs(Menagerie.animals) do
        if a.id == animalId then return a end
    end
    return nil
end

-- ============================================================
-- CARETAKERS
-- ============================================================
function Menagerie.hireCaretaker(name, skill)
    skill = skill or math.random(40, 80)
    local cost = 100 + skill * 3
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    local caretaker = {
        id = "caretaker_" .. tostring(os.time()),
        name = name or ("Skrbnik " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
    }
    table.insert(Menagerie.caretakers, caretaker)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Skrbnik najet: %s (spretnost: %d)", caretaker.name, skill), "success")
    end
    return true
end

function Menagerie.getTotalCaretakerSkill()
    local total = 0
    for _, c in ipairs(Menagerie.caretakers) do
        total = total + c.skill
    end
    return total
end

-- ============================================================
-- EXHIBITIONS
-- ============================================================
function Menagerie.canOrganizeExhibition()
    if #Menagerie.animals == 0 then return false, "Ni živali za predstavo" end
    if not _G.state or (_G.state.gold or 0) < 200 then
        return false, "Premalo zlata"
    end
    return true
end

function Menagerie.organizeExhibition()
    local ok, err = Menagerie.canOrganizeExhibition()
    if not ok then return false, err end
    _G.state.gold = _G.state.gold - 200
    local totalPrestige = 0
    for _, a in ipairs(Menagerie.animals) do
        local def = ANIMALS[a.type]
        if def then totalPrestige = totalPrestige + def.prestige end
    end
    local exhibition = {
        id = "exhib_" .. tostring(os.time()),
        daysRemaining = 2,
        prestigeReward = totalPrestige,
        happinessReward = 10,
        startedDay = os.time(),
    }
    table.insert(Menagerie.activeExhibitions, exhibition)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Predstava organizirana! +%d prestiža", totalPrestige), "important")
    end
    return true
end

function Menagerie.completeExhibition(exhib)
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + exhib.happinessReward)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Predstava končana! +%d sreče", exhib.happinessReward), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "EXHIBITION_COMPLETED", { prestige = exhib.prestigeReward })
    end
end

-- ============================================================
-- HUNTING WITH ANIMALS
-- ============================================================
function Menagerie.organizeHunt()
    local hunters = {}
    for _, a in ipairs(Menagerie.animals) do
        if a.canHunt and a.health > 50 then
            table.insert(hunters, a)
        end
    end
    if #hunters == 0 then return false, "Ni lovskih živali" end
    local foodGained = #hunters * 20
    if _G.state and _G.state.resources then
        _G.state.resources.food = (_G.state.resources.food or 0) + foodGained
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Lov uspešen! +%d hrane", foodGained), "success")
    end
    for _, a in ipairs(hunters) do
        a.health = math.max(0, a.health - 5)
        a.happiness = math.min(100, a.happiness + 10)
    end
    return true
end

-- ============================================================
-- ANIMAL UPDATES
-- ============================================================
function Menagerie.updateAnimals()
    local caretakerSkill = Menagerie.getTotalCaretakerSkill()
    local healthBonus = Menagerie.getHealthBonus()
    for i = #Menagerie.animals, 1, -1 do
        local a = Menagerie.animals[i]
        local def = ANIMALS[a.type]
        if not def then
            table.remove(Menagerie.animals, i)
        else
            a.age = a.age + 1
            local healthChange = (caretakerSkill / math.max(1, #Menagerie.animals) / 10) + (healthBonus / 10)
            if math.random() < (def.danger or 0) * 0.1 then
                a.health = a.health - 10
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        string.format("%s poškodovan(a)!", a.name), "warning")
                end
            end
            a.health = math.min(100, a.health + healthChange)
            a.happiness = math.max(0, math.min(100, a.happiness + 1))
            if a.age >= def.lifespan or a.health <= 0 then
                Menagerie.totalDeaths = Menagerie.totalDeaths + 1
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        string.format("%s umrl(a).", a.name), "warning")
                end
                table.remove(Menagerie.animals, i)
            end
        end
    end
end

-- ============================================================
-- BREEDING
-- ============================================================
function Menagerie.checkBreeding()
    local hasGrand = false
    for _, b in ipairs(Menagerie.buildings) do
        if b.type == "grand_menagerie" then hasGrand = true; break end
    end
    if not hasGrand then return end
    local byType = {}
    for _, a in ipairs(Menagerie.animals) do
        byType[a.type] = (byType[a.type] or 0) + 1
    end
    for animalType, count in pairs(byType) do
        if count >= 2 and #Menagerie.animals < Menagerie.getTotalCapacity() then
            if math.random() < 0.10 then
                local def = ANIMALS[animalType]
                if def then
                    local baby = {
                        id = "animal_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
                        type = animalType,
                        name = def.name .. " mladič " .. math.random(1, 99),
                        age = 0,
                        health = 90,
                        happiness = 80,
                        training = 0,
                        canHunt = def.canHunt or false,
                        acquiredDay = os.time(),
                    }
                    table.insert(Menagerie.animals, baby)
                    Menagerie.totalBirths = Menagerie.totalBirths + 1
                    if _G.NotificationCenter then
                        pcall(_G.NotificationCenter.notify,
                            string.format("Mladič rojen: %s!", baby.name), "rare")
                    end
                end
            end
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Menagerie.update(dt)
    if not _G.state then return end
    Menagerie.dayTimer = Menagerie.dayTimer + dt
    if Menagerie.dayTimer >= 30 then
        Menagerie.dayTimer = 0
        Menagerie.updateAnimals()
        Menagerie.checkBreeding()
        local totalUpkeep = 0
        for _, a in ipairs(Menagerie.animals) do
            local def = ANIMALS[a.type]
            if def then totalUpkeep = totalUpkeep + def.upkeep end
        end
        for _, b in ipairs(Menagerie.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        for _, c in ipairs(Menagerie.caretakers) do
            totalUpkeep = totalUpkeep + 5
        end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        for i = #Menagerie.activeExhibitions, 1, -1 do
            local e = Menagerie.activeExhibitions[i]
            e.daysRemaining = e.daysRemaining - 1
            if e.daysRemaining <= 0 then
                Menagerie.completeExhibition(e)
                table.remove(Menagerie.activeExhibitions, i)
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Menagerie.getAnimalInfo(typeId) return ANIMALS[typeId] end
function Menagerie.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Menagerie.getStats()
    local totalPrestige = Menagerie.getPrestigeBonus()
    for _, a in ipairs(Menagerie.animals) do
        local def = ANIMALS[a.type]
        if def then totalPrestige = totalPrestige + def.prestige end
    end
    return {
        numAnimals = #Menagerie.animals,
        capacity = Menagerie.getTotalCapacity(),
        numBuildings = #Menagerie.buildings,
        numCaretakers = #Menagerie.caretakers,
        activeExhibitions = #Menagerie.activeExhibitions,
        totalAnimalsOwned = Menagerie.totalAnimalsOwned,
        totalDeaths = Menagerie.totalDeaths,
        totalBirths = Menagerie.totalBirths,
        totalPrestige = totalPrestige,
    }
end

return Menagerie
