-- objects/Config/RoyalAlchemistTransmutationSystem.lua
-- Castle Kingdoms 2027 v3.4.1 - Royal Alchemist & Transmutation System
--
-- Manages alchemy: transmutation attempts, elixir brewing, and philosopher's stone research.
-- High risk, high reward system for late-game players.
--
-- Features:
-- - 6 alchemical processes (transmutation, elixir of life, philosopher's stone, ...)
-- - 4 alchemical materials (quicksilver, sulfur, salt, gold)
-- - Alchemist NPC (skill affects success)
-- - Laboratory buildings (with safety bonuses)
-- - Transmutation attempts (lead to gold, rare success)
-- - Elixir brewing (temporary stat boosts)
-- - Philosopher's stone research (legendary quest)
-- - Explosion risk (failed experiments)
-- - Alchemical discoveries

local Alchemist = {}

-- ============================================================
-- ALCHEMICAL PROCESSES
-- ============================================================
local PROCESSES = {
    transmutation = {
        name = "Transmutacija",
        nameEn = "Transmutation",
        goldCost = 500,
        materialsRequired = { quicksilver = 5, sulfur = 3, lead = 10 },
        duration = 30,
        successChance = 0.15,
        explosionRisk = 0.20,
        reward = { gold = 5000 },
        description = "Poskus pretvorbe svinca v zlato.",
    },
    elixir_life = {
        name = "Eliksir življenja",
        nameEn = "Elixir of Life",
        goldCost = 800,
        materialsRequired = { quicksilver = 3, sulfur = 5, salt = 10 },
        duration = 45,
        successChance = 0.20,
        explosionRisk = 0.15,
        reward = { healthBoost = 50, lifespanBonus = 100 },
        description = "Legendarni eliksir za podaljšanje življenja.",
    },
    philosophers_stone = {
        name = "Kamen modrosti",
        nameEn = "Philosopher's Stone",
        goldCost = 5000,
        materialsRequired = { quicksilver = 20, sulfur = 20, salt = 50, gold = 100 },
        duration = 365,
        successChance = 0.05,
        explosionRisk = 0.30,
        reward = { philosophersStone = true, infiniteGold = true },
        description = "Sveti gral alkimije — nesmrtnost in neskončno bogastvo.",
    },
    healing_elixir = {
        name = "Zdravilni eliksir",
        nameEn = "Healing Elixir",
        goldCost = 200,
        materialsRequired = { quicksilver = 1, salt = 5 },
        duration = 14,
        successChance = 0.60,
        explosionRisk = 0.05,
        reward = { healingPotion = 3 },
        description = "Eliksir za zdravljenje ran.",
    },
    strength_elixir = {
        name = "Eliksir moči",
        nameEn = "Strength Elixir",
        goldCost = 400,
        materialsRequired = { sulfur = 3, salt = 5 },
        duration = 21,
        successChance = 0.45,
        explosionRisk = 0.10,
        reward = { strengthPotion = 2 },
        description = "Začasna povečana moč za bojevnike.",
    },
    invisibility = {
        name = "Nevidnost",
        nameEn = "Invisibility",
        goldCost = 1000,
        materialsRequired = { quicksilver = 10, sulfur = 7, salt = 15 },
        duration = 60,
        successChance = 0.10,
        explosionRisk = 0.25,
        reward = { invisibilityPotion = 1 },
        description = "Eliksir nevidnosti za vohune.",
    },
}

-- ============================================================
-- ALCHEMICAL MATERIALS
-- ============================================================
local MATERIALS = {
    quicksilver = {
        name = "Živosrebrni srebro",
        nameEn = "Quicksilver",
        baseValue = 50,
        description = "Živo srebro — ključna alkimistična snov.",
    },
    sulfur = {
        name = "Žveplo",
        nameEn = "Sulfur",
        baseValue = 20,
        description = "Rumena snov za transmutacijo.",
    },
    salt = {
        name = "Sol",
        nameEn = "Salt",
        baseValue = 5,
        description = "Očiščevalna snov.",
    },
    lead = {
        name = "Svinec",
        nameEn = "Lead",
        baseValue = 10,
        description = "Kovina za pretvorbo v zlato.",
    },
}

-- ============================================================
-- LABORATORY BUILDINGS
-- ============================================================
local BUILDINGS = {
    alchemist_hut = {
        name = "Alkimistična koča",
        cost = { gold = 500, wood = 200 },
        upkeep = 15,
        safetyBonus = 5,
        successBonus = 0,
        description = "Preprosta koča za alkimijo.",
    },
    laboratory = {
        name = "Laboratorij",
        cost = { gold = 2500, wood = 300, stone = 500, iron = 100 },
        upkeep = 60,
        safetyBonus = 15,
        successBonus = 5,
        description = "Stalni laboratorij z opremo.",
    },
    grand_laboratory = {
        name = "Veliki laboratorij",
        cost = { gold = 8000, wood = 500, stone = 1500, iron = 300 },
        upkeep = 150,
        safetyBonus = 30,
        successBonus = 15,
        description = "Najnaprednejši laboratorij za vrhunske poskuse.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Alchemist.materialStockpile = {}         -- Stored materials
Alchemist.potionStockpile = {}           -- Stored potions
Alchemist.buildings = {}                 -- Built laboratories
Alchemist.alchemist = nil                -- Hired alchemist NPC
Alchemist.activeExperiments = {}         -- Ongoing experiments
Alchemist.discoveries = {}               -- Alchemical discoveries
Alchemist.totalExperiments = 0
Alchemist.totalSuccesses = 0
Alchemist.totalExplosions = 0
Alchemist.totalGoldTransmuted = 0
Alchemist.hasPhilosophersStone = false
Alchemist.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Alchemist.init()
    Alchemist.materialStockpile = {}
    Alchemist.potionStockpile = {}
    Alchemist.buildings = {}
    Alchemist.alchemist = nil
    Alchemist.activeExperiments = {}
    Alchemist.discoveries = {}
    Alchemist.totalExperiments = 0
    Alchemist.totalSuccesses = 0
    Alchemist.totalExplosions = 0
    Alchemist.totalGoldTransmuted = 0
    Alchemist.hasPhilosophersStone = false
    Alchemist.dayTimer = 0
    print("[Alchemist] Royal Alchemist & Transmutation System initialized (6 processes, 4 materials)")
end

-- ============================================================
-- ALCHEMIST NPC
-- ============================================================
function Alchemist.hireAlchemist(name, skill)
    skill = skill or math.random(40, 85)
    local cost = 1000 + skill * 15
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Alchemist.alchemist = {
        name = name or ("Alkimist " .. math.random(1, 99)),
        skill = skill,
        hiredDay = os.time(),
        experiments = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Alkimist najet: %s (spretnost: %d)", Alchemist.alchemist.name, skill), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Alchemist.canBuild(buildingId)
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

function Alchemist.build(buildingId)
    local ok, err = Alchemist.canBuild(buildingId)
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
    table.insert(Alchemist.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Alchemist.getSafetyBonus()
    local bonus = 0
    for _, b in ipairs(Alchemist.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.safetyBonus then bonus = math.max(bonus, def.safetyBonus) end
    end
    return bonus
end

function Alchemist.getSuccessBonus()
    local bonus = 0
    for _, b in ipairs(Alchemist.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.successBonus then bonus = bonus + def.successBonus end
    end
    return bonus
end

function Alchemist.hasLaboratory()
    return #Alchemist.buildings > 0
end

-- ============================================================
-- MATERIAL MANAGEMENT
-- ============================================================
function Alchemist.addMaterial(materialType, quantity)
    Alchemist.materialStockpile[materialType] = (Alchemist.materialStockpile[materialType] or 0) + quantity
end

function Alchemist.buyMaterial(materialType, quantity)
    local def = MATERIALS[materialType]
    if not def then return false, "Neznan material" end
    local cost = def.baseValue * quantity
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Alchemist.addMaterial(materialType, quantity)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Kupljeno: %d %s", quantity, def.name), "info")
    end
    return true
end

-- ============================================================
-- EXPERIMENTS
-- ============================================================
function Alchemist.canStartExperiment(processId)
    local def = PROCESSES[processId]
    if not def then return false, "Neznan proces" end
    if not Alchemist.hasLaboratory() then
        return false, "Potreben laboratorij"
    end
    if not Alchemist.alchemist then
        return false, "Potreben alkimist"
    end
    -- Check materials
    for mat, qty in pairs(def.materialsRequired) do
        if (Alchemist.materialStockpile[mat] or 0) < qty then
            return false, "Premalo " .. (MATERIALS[mat] and MATERIALS[mat].name or mat)
        end
    end
    if not _G.state or (_G.state.gold or 0) < def.goldCost then
        return false, "Premalo zlata"
    end
    return true
end

function Alchemist.startExperiment(processId)
    local ok, err = Alchemist.canStartExperiment(processId)
    if not ok then return false, err end
    local def = PROCESSES[processId]
    -- Consume materials
    for mat, qty in pairs(def.materialsRequired) do
        Alchemist.materialStockpile[mat] = Alchemist.materialStockpile[mat] - qty
    end
    _G.state.gold = _G.state.gold - def.goldCost
    -- Calculate success chance
    local successChance = def.successChance + (Alchemist.getSuccessBonus() / 100)
    if Alchemist.alchemist then
        successChance = successChance + (Alchemist.alchemist.skill / 200)
    end
    successChance = math.min(0.90, successChance)
    -- Calculate explosion risk
    local explosionRisk = def.explosionRisk - (Alchemist.getSafetyBonus() / 100)
    explosionRisk = math.max(0.02, explosionRisk)
    local experiment = {
        id = "exp_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        processId = processId,
        processName = def.name,
        daysRemaining = def.duration,
        successChance = successChance,
        explosionRisk = explosionRisk,
        reward = def.reward,
        started = os.time(),
    }
    table.insert(Alchemist.activeExperiments, experiment)
    Alchemist.totalExperiments = Alchemist.totalExperiments + 1
    if Alchemist.alchemist then
        Alchemist.alchemist.experiments = Alchemist.alchemist.experiments + 1
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Poskus začet: %s (%.0f%% uspeha, %.0f%% eksplozije)",
                def.name, successChance * 100, explosionRisk * 100), "info")
    end
    return true
end

function Alchemist.completeExperiment(experiment)
    -- Roll for explosion first
    if math.random() < experiment.explosionRisk then
        -- Explosion!
        Alchemist.totalExplosions = Alchemist.totalExplosions + 1
        -- Damage to laboratory
        if _G.state and _G.state.happiness then
            _G.state.happiness = math.max(0, _G.state.happiness - 10)
        end
        -- Possible alchemist injury
        if Alchemist.alchemist and math.random() < 0.30 then
            Alchemist.alchemist.skill = math.max(0, Alchemist.alchemist.skill - 10)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("EKSPLOZIJA! %s poškodovan, -10 spretnosti",
                        Alchemist.alchemist.name), "danger")
            end
        else
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    "EKSPLOZIJA! Poskus spodletel.", "danger")
            end
        end
        return
    end
    -- Roll for success
    if math.random() < experiment.successChance then
        -- Success!
        Alchemist.totalSuccesses = Alchemist.totalSuccesses + 1
        local r = experiment.reward
        if r.gold then
            if _G.state then
                _G.state.gold = (_G.state.gold or 0) + r.gold
            end
            Alchemist.totalGoldTransmuted = Alchemist.totalGoldTransmuted + r.gold
        end
        if r.healingPotion then
            Alchemist.potionStockpile.healing = (Alchemist.potionStockpile.healing or 0) + r.healingPotion
        end
        if r.strengthPotion then
            Alchemist.potionStockpile.strength = (Alchemist.potionStockpile.strength or 0) + r.strengthPotion
        end
        if r.invisibilityPotion then
            Alchemist.potionStockpile.invisibility = (Alchemist.potionStockpile.invisibility or 0) + r.invisibilityPotion
        end
        if r.healthBoost and _G.Guard then
            pcall(function() _G.Guard.rulerHealth = math.min(100, _G.Guard.rulerHealth + r.healthBoost) end)
        end
        if r.philosophersStone then
            Alchemist.hasPhilosophersStone = true
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    "KAMEN MODROSTI USPEL! Neskončno bogastvo doseženo!", "rare")
            end
            if _G.GameEventBus then
                pcall(_G.GameEventBus.publish, "PHILOSOPHERS_STONE", {})
            end
        else
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("POSKUS USPEL: %s!", experiment.processName), "success")
            end
        end
        -- Skill progression on success
        if Alchemist.alchemist and math.random() < 0.30 then
            Alchemist.alchemist.skill = math.min(100, Alchemist.alchemist.skill + 2)
        end
        -- Discovery chance
        if math.random() < 0.10 then
            Alchemist.makeDiscovery()
        end
    else
        -- Failed but no explosion
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Poskus spodletel: %s (brez eksplozije)", experiment.processName), "warning")
        end
    end
end

function Alchemist.makeDiscovery()
    local discoveries = {
        "Nova vrsta kristala",
        "Skrivnostna formula",
        "Raztopljena kovina",
        "Nov postopek destilacije",
        "Skrita lastnost živega srebra",
    }
    local discovery = discoveries[math.random(#discoveries)]
    table.insert(Alchemist.discoveries, {
        name = discovery,
        found = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Alkimistično odkritje: " .. discovery, "rare")
    end
end

-- ============================================================
-- USE POTIONS
-- ============================================================
function Alchemist.usePotion(potionType)
    if (Alchemist.potionStockpile[potionType] or 0) <= 0 then
        return false, "Ni napoja na zalogi"
    end
    Alchemist.potionStockpile[potionType] = Alchemist.potionStockpile[potionType] - 1
    if potionType == "healing" and _G.Guard then
        pcall(function() _G.Guard.rulerHealth = math.min(100, _G.Guard.rulerHealth + 30) end)
    elseif potionType == "strength" and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + 5)
    elseif potionType == "invisibility" then
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Nevidnost aktivna!", "info")
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Napoja uporabljen: " .. potionType, "info")
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Alchemist.update(dt)
    if not _G.state then return end
    Alchemist.dayTimer = Alchemist.dayTimer + dt
    if Alchemist.dayTimer >= 30 then
        Alchemist.dayTimer = 0
        -- Process experiments
        for i = #Alchemist.activeExperiments, 1, -1 do
            local e = Alchemist.activeExperiments[i]
            e.daysRemaining = e.daysRemaining - 1
            if e.daysRemaining <= 0 then
                Alchemist.completeExperiment(e)
                table.remove(Alchemist.activeExperiments, i)
            end
        end
        -- Philosopher's stone infinite gold
        if Alchemist.hasPhilosophersStone and _G.state then
            _G.state.gold = (_G.state.gold or 0) + 500
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Alchemist.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Alchemist.alchemist then totalUpkeep = totalUpkeep + 40 end
        -- Philosopher's stone covers upkeep
        if not Alchemist.hasPhilosophersStone and totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Alchemist.getProcessInfo(processId) return PROCESSES[processId] end
function Alchemist.getMaterialInfo(materialId) return MATERIALS[materialId] end
function Alchemist.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Alchemist.getStats()
    return {
        materialStockpile = Alchemist.materialStockpile,
        potionStockpile = Alchemist.potionStockpile,
        numBuildings = #Alchemist.buildings,
        hasAlchemist = Alchemist.alchemist ~= nil,
        alchemistName = Alchemist.alchemist and Alchemist.alchemist.name or "—",
        alchemistSkill = Alchemist.alchemist and Alchemist.alchemist.skill or 0,
        activeExperiments = #Alchemist.activeExperiments,
        totalExperiments = Alchemist.totalExperiments,
        totalSuccesses = Alchemist.totalSuccesses,
        totalExplosions = Alchemist.totalExplosions,
        totalGoldTransmuted = Alchemist.totalGoldTransmuted,
        hasPhilosophersStone = Alchemist.hasPhilosophersStone,
        numDiscoveries = #Alchemist.discoveries,
    }
end

return Alchemist
