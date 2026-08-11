-- objects/Combat/RoyalEngineerSiegeWorksSystem.lua
-- Castle Kingdoms 2027 v3.4.9 - Royal Engineer & Siege Works System
--
-- Manages military engineering: siege engines, fortifications, bridges, and
-- military constructions. Provides combat advantages and defensive bonuses.
--
-- Features:
-- - 8 siege engine types (catapult, trebuchet, ballista, siege tower, battering ram, ...)
-- - 6 fortification types (wall, tower, moat, palisade, gatehouse, bastion)
-- - 4 engineering buildings (workshop, arsenal, siege works, military academy)
-- - Master Engineer NPC (skill affects construction)
-- - Bridge and road construction
-- - Siege engine construction (time-based)
-- - Fortification upgrades
-- - Military engineering research
-- - Field engineering (during campaigns)

local Engineer = {}

-- ============================================================
-- SIEGE ENGINE TYPES
-- ============================================================
local SIEGE_ENGINES = {
    catapult = {
        name = "Katapult",
        nameEn = "Catapult",
        cost = 500,
        upkeep = 20,
        buildTime = 14,
        attack = 50,
        range = 8,
        crew = 4,
        description = "Vrzne kamene na sovražnikove zidove.",
    },
    trebuchet = {
        name = "Trebuchet",
        nameEn = "Trebuchet",
        cost = 1200,
        upkeep = 40,
        buildTime = 21,
        attack = 80,
        range = 10,
        crew = 6,
        description = "Najmočnejši oblegovalni stroj.",
    },
    ballista = {
        name = "Balista",
        nameEn = "Ballista",
        cost = 600,
        upkeep = 25,
        buildTime = 10,
        attack = 40,
        range = 12,
        crew = 3,
        description = "Velik lok za streljanje sulic.",
    },
    siege_tower = {
        name = "Oblegovalni stolp",
        nameEn = "Siege Tower",
        cost = 1000,
        upkeep = 30,
        buildTime = 18,
        attack = 20,
        range = 1,
        crew = 10,
        description = "Omogoča vkrcanje na zidove.",
    },
    battering_ram = {
        name = "Oblegovalni oven",
        nameEn = "Battering Ram",
        cost = 400,
        upkeep = 15,
        buildTime = 7,
        attack = 60,
        range = 1,
        crew = 8,
        description = "Za razbijanje vrat.",
    },
    mangonel = {
        name = "Mangonel",
        nameEn = "Mangonel",
        cost = 350,
        upkeep = 15,
        buildTime = 10,
        attack = 35,
        range = 7,
        crew = 3,
        description = "Manjši katapult za hitro gradnjo.",
    },
    bombard = {
        name = "Bombarda",
        nameEn = "Bombard",
        cost = 2500,
        upkeep = 80,
        buildTime = 30,
        attack = 120,
        range = 9,
        crew = 5,
        description = "Zgodnji top — uničujoč a počasen.",
    },
    watch_tower = {
        name = "Stražni stolp",
        nameEn = "Watch Tower",
        cost = 200,
        upkeep = 5,
        buildTime = 5,
        attack = 0,
        range = 15,
        crew = 2,
        visionBonus = 50,
        description = "Za opazovanje sovražnika.",
    },
}

-- ============================================================
-- FORTIFICATION TYPES
-- ============================================================
local FORTIFICATIONS = {
    palisade = {
        name = "Palisada",
        cost = 100,
        buildTime = 3,
        defense = 20,
        hp = 200,
        description = "Lesena palisada za začasno obrambo.",
    },
    stone_wall = {
        name = "Kamniti zid",
        cost = 800,
        buildTime = 14,
        defense = 50,
        hp = 500,
        description = "Stalni kamniti obrambni zid.",
    },
    tower = {
        name = "Obrambni stolp",
        cost = 1200,
        buildTime = 21,
        defense = 70,
        hp = 800,
        range = 8,
        description = "Visok stolp za lokostrelce.",
    },
    moat = {
        name = "Jarek",
        cost = 300,
        buildTime = 7,
        defense = 30,
        hp = 0,
        slowEffect = 0.50,
        description = "Vodni jarek, upočasni napadalce.",
    },
    gatehouse = {
        name = "Vratarnica",
        cost = 1500,
        buildTime = 18,
        defense = 60,
        hp = 600,
        description = "Okrepljena vrata z obrambnim stolpom.",
    },
    bastion = {
        name = "Bastion",
        cost = 3000,
        buildTime = 30,
        defense = 90,
        hp = 1200,
        range = 10,
        description = "Napredna trdnjava za topove.",
    },
}

-- ============================================================
-- ENGINEERING BUILDINGS
-- ============================================================
local BUILDINGS = {
    workshop = {
        name = "Delavnica",
        cost = { gold = 400, wood = 200, stone = 100 },
        upkeep = 15,
        buildBonus = 5,
        description = "Osnovna delavnica za gradnjo.",
    },
    arsenal = {
        name = "Arzenal",
        cost = { gold = 1500, wood = 300, stone = 300, iron = 100 },
        upkeep = 40,
        buildBonus = 15,
        qualityBonus = 10,
        description = "Skladišče in delavnica za orožje.",
    },
    siege_works = {
        name = "Oblegovalna delavnica",
        cost = { gold = 2500, wood = 500, stone = 200, iron = 200 },
        upkeep = 60,
        buildBonus = 25,
        siegeBonus = 0.20,
        description = "Specializirana za oblegovalne stroje.",
    },
    military_academy = {
        name = "Vojaška akademija",
        cost = { gold = 5000, wood = 400, stone = 800, iron = 300 },
        upkeep = 120,
        buildBonus = 40,
        qualityBonus = 25,
        researchBonus = 0.30,
        description = "Šola za vojaške inženirje.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Engineer.builtEngines = {}                -- Owned siege engines
Engineer.builtFortifications = {}         -- Built fortifications
Engineer.buildings = {}                   -- Engineering buildings
Engineer.engineer = nil                   -- Hired Master Engineer NPC
Engineer.activeConstructions = {}         -- Engines/forts being built
Engineer.totalEnginesBuilt = 0
Engineer.totalFortificationsBuilt = 0
Engineer.totalBridgesBuilt = 0
Engineer.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Engineer.init()
    Engineer.builtEngines = {}
    Engineer.builtFortifications = {}
    Engineer.buildings = {}
    Engineer.engineer = nil
    Engineer.activeConstructions = {}
    Engineer.totalEnginesBuilt = 0
    Engineer.totalFortificationsBuilt = 0
    Engineer.totalBridgesBuilt = 0
    Engineer.dayTimer = 0
    print("[Engineer] Royal Engineer & Siege Works System initialized (8 engines, 6 fortifications, 4 buildings)")
end

-- ============================================================
-- MASTER ENGINEER NPC
-- ============================================================
function Engineer.hireEngineer(name, skill)
    skill = skill or math.random(40, 90)
    local cost = 600 + skill * 12
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Engineer.engineer = {
        name = name or ("Inženir " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        constructionsCompleted = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Mojster inženir najet: %s (spretnost: %d)", Engineer.engineer.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Engineer.canBuild(buildingId)
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

function Engineer.build(buildingId)
    local ok, err = Engineer.canBuild(buildingId)
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
    table.insert(Engineer.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Engineer.getBuildBonus()
    local bonus = 0
    for _, b in ipairs(Engineer.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.buildBonus then bonus = bonus + def.buildBonus end
    end
    return bonus
end

function Engineer.getQualityBonus()
    local bonus = 0
    for _, b in ipairs(Engineer.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.qualityBonus then bonus = bonus + def.qualityBonus end
    end
    return bonus
end

function Engineer.getSiegeBonus()
    local bonus = 0
    for _, b in ipairs(Engineer.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.siegeBonus then bonus = bonus + def.siegeBonus end
    end
    return bonus
end

-- ============================================================
-- SIEGE ENGINE CONSTRUCTION
-- ============================================================
function Engineer.canBuildEngine(engineType)
    local def = SIEGE_ENGINES[engineType]
    if not def then return false, "Neznan stroj" end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    if _G.state.resources and (_G.state.resources.wood or 0) < (def.cost / 10) then
        return false, "Premalo lesa"
    end
    -- Need at least a workshop
    if #Engineer.buildings == 0 then
        return false, "Potrebna inženirska zgradba"
    end
    return true
end

function Engineer.buildEngine(engineType)
    local ok, err = Engineer.canBuildEngine(engineType)
    if not ok then return false, err end
    local def = SIEGE_ENGINES[engineType]
    _G.state.gold = _G.state.gold - def.cost
    if _G.state.resources then
        _G.state.resources.wood = (_G.state.resources.wood or 0) - math.floor(def.cost / 10)
        _G.state.resources.iron = (_G.state.resources.iron or 0) - math.floor(def.cost / 20)
    end
    -- Calculate build time (reduced by bonuses)
    local buildTime = def.buildTime
    local buildBonus = Engineer.getBuildBonus()
    if Engineer.engineer then
        buildBonus = buildBonus + math.floor(Engineer.engineer.skill / 5)
    end
    buildTime = math.max(1, buildTime - math.floor(buildBonus / 5))
    local construction = {
        id = "engine_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        engineType = engineType,
        engineName = def.name,
        daysRemaining = buildTime,
        totalDays = buildTime,
        attack = def.attack,
        range = def.range,
        crew = def.crew,
        started = os.time(),
    }
    table.insert(Engineer.activeConstructions, construction)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Gradnja začeta: %s (%d dni)", def.name, buildTime), "info")
    end
    return true
end

function Engineer.completeConstruction(construction)
    local def = SIEGE_ENGINES[construction.engineType]
    if not def then return end
    -- Calculate quality
    local quality = 1.0 + (Engineer.getQualityBonus() / 100)
    if Engineer.engineer then
        quality = quality + (Engineer.engineer.skill / 200)
    end
    quality = math.min(1.5, quality)
    local engine = {
        id = construction.id,
        type = construction.engineType,
        name = construction.engineName,
        attack = math.floor(construction.attack * quality),
        range = construction.range,
        crew = construction.crew,
        quality = quality,
        hp = 100,
        builtDay = os.time(),
    }
    table.insert(Engineer.builtEngines, engine)
    Engineer.totalEnginesBuilt = Engineer.totalEnginesBuilt + 1
    -- Apply siege bonus
    local siegeBonus = Engineer.getSiegeBonus()
    if siegeBonus > 0 then
        engine.attack = math.floor(engine.attack * (1 + siegeBonus))
    end
    if Engineer.engineer then
        Engineer.engineer.constructionsCompleted = Engineer.engineer.constructionsCompleted + 1
        if math.random() < 0.20 then
            Engineer.engineer.skill = math.min(100, Engineer.engineer.skill + 1)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Stroj zgrajen: %s (napad: %d, kakovost: %.1f)",
                construction.engineName, engine.attack, quality), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "SIEGE_ENGINE_BUILT", {
            type = construction.engineType, attack = engine.attack,
        })
    end
end

-- ============================================================
-- FORTIFICATION CONSTRUCTION
-- ============================================================
function Engineer.canBuildFortification(fortType)
    local def = FORTIFICATIONS[fortType]
    if not def then return false, "Neznana utrditev" end
    if not _G.state or (_G.state.gold or 0) < def.cost then
        return false, "Premalo zlata"
    end
    return true
end

function Engineer.buildFortification(fortType, x, y)
    local ok, err = Engineer.canBuildFortification(fortType)
    if not ok then return false, err end
    local def = FORTIFICATIONS[fortType]
    _G.state.gold = _G.state.gold - def.cost
    if _G.state.resources then
        _G.state.resources.stone = (_G.state.resources.stone or 0) - math.floor(def.cost / 5)
        _G.state.resources.wood = (_G.state.resources.wood or 0) - math.floor(def.cost / 10)
    end
    -- Calculate build time
    local buildTime = def.buildTime
    local buildBonus = Engineer.getBuildBonus()
    if Engineer.engineer then
        buildBonus = buildBonus + math.floor(Engineer.engineer.skill / 5)
    end
    buildTime = math.max(1, buildTime - math.floor(buildBonus / 5))
    local construction = {
        id = "fort_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        fortType = fortType,
        fortName = def.name,
        x = x or 0,
        y = y or 0,
        daysRemaining = buildTime,
        totalDays = buildTime,
        defense = def.defense,
        hp = def.hp,
        range = def.range,
        started = os.time(),
        isFortification = true,
    }
    table.insert(Engineer.activeConstructions, construction)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Gradnja utrditve: %s (%d dni)", def.name, buildTime), "info")
    end
    return true
end

function Engineer.completeFortification(construction)
    local def = FORTIFICATIONS[construction.fortType]
    if not def then return end
    local fort = {
        id = construction.id,
        type = construction.fortType,
        name = construction.fortName,
        x = construction.x,
        y = construction.y,
        defense = construction.defense,
        hp = construction.hp,
        maxHp = construction.hp,
        range = construction.range,
        builtDay = os.time(),
    }
    table.insert(Engineer.builtFortifications, fort)
    Engineer.totalFortificationsBuilt = Engineer.totalFortificationsBuilt + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Utrditev zgrajena: %s (obramba: %d)", construction.fortName, construction.defense), "success")
    end
end

-- ============================================================
-- BRIDGE AND ROAD CONSTRUCTION
-- ============================================================
function Engineer.buildBridge(location)
    if not _G.state or (_G.state.gold or 0) < 1000 then
        return false, "Premalo zlata"
    end
    if _G.state.resources and (_G.state.resources.wood or 0) < 200 then
        return false, "Premalo lesa"
    end
    _G.state.gold = _G.state.gold - 1000
    _G.state.resources.wood = _G.state.resources.wood - 200
    Engineer.totalBridgesBuilt = Engineer.totalBridgesBuilt + 1
    -- Movement bonus
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + 5)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Most zgrajen pri %s!", location or "reki"), "success")
    end
    return true
end

-- ============================================================
-- GET TOTAL COMBAT BONUS
-- ============================================================
function Engineer.getTotalAttackBonus()
    local total = 0
    for _, e in ipairs(Engineer.builtEngines) do
        total = total + e.attack
    end
    return total
end

function Engineer.getTotalDefenseBonus()
    local total = 0
    for _, f in ipairs(Engineer.builtFortifications) do
        total = total + f.defense
    end
    return total
end

-- ============================================================
-- UPDATE
-- ============================================================
function Engineer.update(dt)
    if not _G.state then return end
    Engineer.dayTimer = Engineer.dayTimer + dt
    if Engineer.dayTimer >= 30 then
        Engineer.dayTimer = 0
        -- Process constructions
        for i = #Engineer.activeConstructions, 1, -1 do
            local c = Engineer.activeConstructions[i]
            c.daysRemaining = c.daysRemaining - 1
            if c.daysRemaining <= 0 then
                if c.isFortification then
                    Engineer.completeFortification(c)
                else
                    Engineer.completeConstruction(c)
                end
                table.remove(Engineer.activeConstructions, i)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, e in ipairs(Engineer.builtEngines) do
            local def = SIEGE_ENGINES[e.type]
            if def then totalUpkeep = totalUpkeep + def.upkeep end
        end
        for _, b in ipairs(Engineer.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Engineer.engineer then totalUpkeep = totalUpkeep + 30 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Engineer.getEngineInfo(engineId) return SIEGE_ENGINES[engineId] end
function Engineer.getFortificationInfo(fortId) return FORTIFICATIONS[fortId] end
function Engineer.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Engineer.getStats()
    return {
        numEngines = #Engineer.builtEngines,
        numFortifications = #Engineer.builtFortifications,
        numBuildings = #Engineer.buildings,
        activeConstructions = #Engineer.activeConstructions,
        hasEngineer = Engineer.engineer ~= nil,
        engineerName = Engineer.engineer and Engineer.engineer.name or "—",
        engineerSkill = Engineer.engineer and Engineer.engineer.skill or 0,
        totalEnginesBuilt = Engineer.totalEnginesBuilt,
        totalFortificationsBuilt = Engineer.totalFortificationsBuilt,
        totalBridgesBuilt = Engineer.totalBridgesBuilt,
        totalAttackBonus = Engineer.getTotalAttackBonus(),
        totalDefenseBonus = Engineer.getTotalDefenseBonus(),
    }
end

return Engineer
