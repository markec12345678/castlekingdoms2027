-- objects/Gameplay/DiseaseHealthSystem.lua
-- Castle Kingdoms 2027 v3.0.7 - Disease & Health System
--
-- Manages disease outbreaks, health infrastructure, and population wellness.
-- Diseases can spread through populations and affect productivity.
--
-- Features:
-- - 6 disease types with different effects
-- - Health infrastructure (apothecaries, healers, clean water)
-- - Disease spread simulation (proximity-based)
-- - Quarantine system (isolate infected areas)
-- - Cure research (spend gold to develop cures)
-- - Health rating (affects population growth and productivity)
-- - Sanitation upgrades (reduce disease chance)

local Disease = {}

-- Disease definitions
local DISEASES = {
    plague = {
        name = "Kuga",
        nameEn = "Plague",
        mortality = 0.15,  -- 15% of infected die
        spreadRate = 0.08,  -- 8% per day spread chance
        duration = 30,  -- days
        symptoms = "Visoka vročina, otekle bezgavke",
        effect = { happinessBonus = -20, production = 0.5 },
    },
    dysentery = {
        name = "Dizenterija",
        nameEn = "Dysentery",
        mortality = 0.05,
        spreadRate = 0.12,
        duration = 15,
        symptoms = "Driska, dehidracija",
        effect = { happinessBonus = -10, production = 0.7 },
    },
    influenza = {
        name = "Gripa",
        nameEn = "Influenza",
        mortality = 0.02,
        spreadRate = 0.15,
        duration = 10,
        symptoms = "Vročina, kašelj, utrujenost",
        effect = { happinessBonus = -5, production = 0.8 },
    },
    smallpox = {
        name = "Črne koze",
        nameEn = "Smallpox",
        mortality = 0.25,
        spreadRate = 0.10,
        duration = 25,
        symptoms = "Izpuščaji, visoka vročina",
        effect = { happinessBonus = -25, production = 0.4 },
    },
    famine_fever = {
        name = "Lakotna vročica",
        nameEn = "Famine Fever",
        mortality = 0.08,
        spreadRate = 0.06,
        duration = 20,
        symptoms = "Šibkost, omotica (povezano s lakoto)",
        effect = { happinessBonus = -15, production = 0.6 },
    },
    cholera = {
        name = "Kolera",
        nameEn = "Cholera",
        mortality = 0.10,
        spreadRate = 0.14,
        duration = 18,
        symptoms = "Huda driska, dehidracija (voda)",
        effect = { happinessBonus = -15, production = 0.5 },
    },
}

Disease.DISEASES = DISEASES

-- Health infrastructure
local INFRASTRUCTURE = {
    apothecary = { name = "Apotheka",      cost = 200, diseaseReduction = 0.15, healRate = 0.05 },
    healer_hut = { name = "Zdravilnica",   cost = 150, diseaseReduction = 0.10, healRate = 0.08 },
    clean_well = { name = "Čisti vodnjak", cost = 100, diseaseReduction = 0.20, healRate = 0.0 },
    hospital = { name = "Bolnišnica",      cost = 800, diseaseReduction = 0.35, healRate = 0.15 },
    sewer = { name = "Kanalizacija",       cost = 500, diseaseReduction = 0.25, healRate = 0.0 },
}

Disease.INFRASTRUCTURE = INFRASTRUCTURE

local initialized = false
local activeDiseases = {}  -- { { type, infectedCount, duration, spreadTimer } }
local healthRating = 80  -- 0-100, higher = healthier
local infrastructure = {}  -- { apothecary = 0, healer_hut = 0, ... }
local quarantines = {}  -- { gx, gy, radius }
local cureResearch = {}  -- { [diseaseType] = progress (0-100) }
local outbreakTimer = 0
local outbreakInterval = 300  -- check for outbreaks every 5 minutes
local totalDeaths = 0
local totalOutbreaks = 0

function Disease.init()
    if initialized then return end
    initialized = true
    -- Initialize infrastructure counts
    for infraType, _ in pairs(INFRASTRUCTURE) do
        infrastructure[infraType] = 0
    end
    print("[Disease] Initialized with " .. Disease._getDiseaseCount() .. " diseases, " .. Disease._getInfraCount() .. " infrastructure types")
end

function Disease._getDiseaseCount()
    local count = 0
    for _ in pairs(DISEASES) do count = count + 1 end
    return count
end

function Disease._getInfraCount()
    local count = 0
    for _ in pairs(INFRASTRUCTURE) do count = count + 1 end
    return count
end

-- Trigger a disease outbreak
function Disease.triggerOutbreak(diseaseType, initialInfected)
    local disease = DISEASES[diseaseType]
    if not disease then return false end

    -- Check if already active
    for _, active in ipairs(activeDiseases) do
        if active.type == diseaseType then
            -- Increase infected count
            active.infectedCount = active.infectedCount + (initialInfected or 5)
            return true
        end
    end

    local outbreak = {
        type = diseaseType,
        name = disease.name,
        infectedCount = initialInfected or math.random(3, 10),
        duration = disease.duration,
        elapsed = 0,
        spreadTimer = 0,
        totalInfected = initialInfected or 5,
        totalDied = 0,
    }

    table.insert(activeDiseases, outbreak)
    totalOutbreaks = totalOutbreaks + 1

    if _G.ModernUI then
        _G.ModernUI.notifyError("IZBRUH: " .. disease.name .. "! " .. outbreak.infectedCount .. " okuženih")
    end
    if _G.VoiceOver then
        pcall(function() _G.VoiceOver.notify("plague") end)
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("disease_outbreak", { type = diseaseType, name = disease.name }) end)
    end
    if _G.Analytics then
        pcall(function() _G.Analytics.track("random_event", { type = "disease", disease = diseaseType }) end)
    end

    print("[Disease] Outbreak: " .. disease.name .. " (" .. outbreak.infectedCount .. " infected)")
    return true
end

-- Check for random outbreak
function Disease._checkRandomOutbreak()
    if not _G.state then return end

    -- Calculate disease chance based on health rating and infrastructure
    local baseChance = 0.05  -- 5% base chance
    local healthModifier = (100 - healthRating) / 100 * 0.10  -- up to +10% if health is bad
    local infraReduction = Disease._getTotalDiseaseReduction()
    local popModifier = 0
    if _G.state.population then
        popModifier = math.min(0.05, (_G.state.population or 0) / 1000)  -- more pop = more chance
    end

    local totalChance = (baseChance + healthModifier + popModifier) * (1 - infraReduction)
    totalChance = math.max(0.01, math.min(0.30, totalChance))

    if math.random() < totalChance then
        -- Pick a disease (weighted by severity)
        local diseaseKeys = {}
        for k, _ in pairs(DISEASES) do table.insert(diseaseKeys, k) end
        local selected = diseaseKeys[math.random(#diseaseKeys)]
        Disease.triggerOutbreak(selected)
    end
end

-- Get total disease reduction from infrastructure
function Disease._getTotalDiseaseReduction()
    local total = 0
    for infraType, count in pairs(infrastructure) do
        local def = INFRASTRUCTURE[infraType]
        if def and count > 0 then
            total = total + def.diseaseReduction * math.min(1.0, count * 0.3)
        end
    end
    return math.min(0.8, total)  -- max 80% reduction
end

-- Get total heal rate from infrastructure
function Disease._getTotalHealRate()
    local total = 0
    for infraType, count in pairs(infrastructure) do
        local def = INFRASTRUCTURE[infraType]
        if def and count > 0 then
            total = total + def.healRate * math.min(1.0, count * 0.3)
        end
    end
    return total
end

-- Build health infrastructure
function Disease.buildInfrastructure(infraType)
    local def = INFRASTRUCTURE[infraType]
    if not def then return false end

    if _G.state and (_G.state.gold or 0) < def.cost then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Ni dovolj zlata (" .. def.cost .. "g)")
        end
        return false
    end

    _G.state.gold = (_G.state.gold or 0) - def.cost
    infrastructure[infraType] = (infrastructure[infraType] or 0) + 1

    -- Recalculate health rating
    Disease._recalculateHealthRating()

    if _G.ModernUI then
        _G.ModernUI.notifySuccess(def.name .. " zgrajena (skupaj: " .. infrastructure[infraType] .. ")")
    end
    return true
end

-- Recalculate health rating
function Disease._recalculateHealthRating()
    local baseHealth = 50
    local infraBonus = Disease._getTotalDiseaseReduction() * 50  -- up to +40
    local diseasePenalty = #activeDiseases * 10

    healthRating = math.max(0, math.min(100, baseHealth + infraBonus - diseasePenalty))
end

-- Quarantine an area
function Disease.quarantine(gx, gy, radius)
    local q = {
        gx = gx,
        gy = gy,
        radius = radius or 10,
        active = true,
        created = os.time(),
    }
    table.insert(quarantines, q)
    -- Quarantine reduces happiness but stops spread
    if _G.state then
        _G.state.popularity = math.max(0, (_G.state.popularity or 50) - 5)
    end
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Karantena vzpostavljena (radius: " .. q.radius .. ")")
    end
    return true
end

-- Research cure
function Disease.researchCure(diseaseType)
    local cost = 300
    if _G.state and (_G.state.gold or 0) < cost then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Raziskava zdravila: " .. cost .. "g potrebno")
        end
        return false
    end
    _G.state.gold = (_G.state.gold or 0) - cost

    if not cureResearch[diseaseType] then
        cureResearch[diseaseType] = 0
    end
    cureResearch[diseaseType] = cureResearch[diseaseType] + 25

    if cureResearch[diseaseType] >= 100 then
        -- Cure found! Remove disease
        for i, active in ipairs(activeDiseases) do
            if active.type == diseaseType then
                if _G.ModernUI then
                    _G.ModernUI.notifySuccess("Zdravilo za " .. active.name .. " odkrito!")
                end
                table.remove(activeDiseases, i)
                break
            end
        end
        cureResearch[diseaseType] = 100
        if _G.Prestige then
            pcall(function() _G.Prestige.award("achievement_rare") end)
        end
    else
        if _G.ModernUI then
            _G.ModernUI.notifyInfo("Raziskava zdravila: " .. cureResearch[diseaseType] .. "/100")
        end
    end
    return true
end

-- Update diseases
function Disease.update(dt)
    if not initialized then return end

    -- Check for random outbreaks
    outbreakTimer = outbreakTimer + dt
    if outbreakTimer >= outbreakInterval then
        outbreakTimer = 0
        Disease._checkRandomOutbreak()
    end

    -- Update active diseases
    for i = #activeDiseases, 1, -1 do
        local active = activeDiseases[i]
        local disease = DISEASES[active.type]

        -- Update duration
        active.elapsed = active.elapsed + dt
        active.spreadTimer = active.spreadTimer + dt

        -- Spread disease (every 5 seconds = 1 "day")
        if active.spreadTimer >= 5 then
            active.spreadTimer = 0
            local spreadChance = disease.spreadRate
            -- Reduce spread with infrastructure
            spreadChance = spreadChance * (1 - Disease._getTotalDiseaseReduction())
            -- Reduce with quarantine
            if #quarantines > 0 then
                spreadChance = spreadChance * 0.3
            end

            if math.random() < spreadChance then
                local newInfections = math.random(1, 5)
                active.infectedCount = active.infectedCount + newInfections
                active.totalInfected = active.totalInfected + newInfections
            end

            -- Deaths
            local deaths = math.floor(active.infectedCount * disease.mortality * 0.1)  -- 10% of mortality per day
            if deaths > 0 then
                active.infectedCount = active.infectedCount - deaths
                active.totalDied = active.totalDied + deaths
                totalDeaths = totalDeaths + deaths
                if _G.state then
                    _G.state.population = math.max(0, (_G.state.population or 0) - deaths)
                end
            end

            -- Heal rate from infrastructure
            local healed = math.floor(active.infectedCount * Disease._getTotalHealRate())
            if healed > 0 then
                active.infectedCount = active.infectedCount - healed
            end

            -- Apply effects to state
            if _G.state and disease.effect then
                if disease.effect.happinessBonus then
                    -- Don't apply directly, just track
                end
            end
        end

        -- Check if disease ended
        if active.elapsed >= active.duration or active.infectedCount <= 0 then
            if _G.ModernUI then
                _G.ModernUI.notifyInfo(active.name .. " je ponehala. " .. active.totalDied .. " smrti, " .. active.totalInfected .. " okuženih skupno.")
            end
            if _G.GameEventBus then
                pcall(function() _G.GameEventBus.emit("disease_ended", { type = active.type, totalDied = active.totalDied }) end)
            end
            table.remove(activeDiseases, i)
        end
    end

    -- Recalculate health rating
    Disease._recalculateHealthRating()

    -- Apply health effects
    if _G.state and healthRating < 50 then
        -- Low health reduces population growth
        -- PopulationSystem will check healthRating
    end
end

-- Get active diseases
function Disease.getActiveDiseases()
    local result = {}
    for _, active in ipairs(activeDiseases) do
        local disease = DISEASES[active.type]
        table.insert(result, {
            type = active.type,
            name = active.name,
            infectedCount = active.infectedCount,
            totalInfected = active.totalInfected,
            totalDied = active.totalDied,
            duration = math.floor(active.elapsed) .. "/" .. active.duration,
            cureProgress = cureResearch[active.type] or 0,
        })
    end
    return result
end

-- Get health rating
function Disease.getHealthRating()
    return math.floor(healthRating)
end

-- Get infrastructure
function Disease.getInfrastructure()
    local result = {}
    for infraType, count in pairs(infrastructure) do
        local def = INFRASTRUCTURE[infraType]
        if def then
            table.insert(result, {
                type = infraType,
                name = def.name,
                count = count,
                cost = def.cost,
                diseaseReduction = def.diseaseReduction,
                healRate = def.healRate,
            })
        end
    end
    return result
end

-- Get production modifier (from diseases)
function Disease.getProductionModifier()
    local modifier = 1.0
    for _, active in ipairs(activeDiseases) do
        local disease = DISEASES[active.type]
        if disease and disease.effect and disease.effect.production then
            -- Scale by infection rate
            local infectionRate = math.min(1.0, active.infectedCount / 50)
            modifier = modifier * (1.0 - (1.0 - disease.effect.production) * infectionRate)
        end
    end
    return modifier
end

-- Get happiness modifier (from diseases)
function Disease.getHappinessModifier()
    local modifier = 0
    for _, active in ipairs(activeDiseases) do
        local disease = DISEASES[active.type]
        if disease and disease.effect and disease.effect.happinessBonus then
            modifier = modifier + disease.effect.happinessBonus
        end
    end
    return modifier
end

-- Get stats
function Disease.getStats()
    return {
        healthRating = math.floor(healthRating),
        activeDiseases = #activeDiseases,
        totalOutbreaks = totalOutbreaks,
        totalDeaths = totalDeaths,
        infrastructureCount = Disease._countInfrastructure(),
        quarantineCount = #quarantines,
        cureCount = Disease._countCures(),
        diseaseTypes = Disease._getDiseaseCount(),
        nextOutbreakCheck = math.ceil(outbreakInterval - outbreakTimer),
    }
end

function Disease._countInfrastructure()
    local count = 0
    for _, c in pairs(infrastructure) do count = count + c end
    return count
end

function Disease._countCures()
    local count = 0
    for _, progress in pairs(cureResearch) do
        if progress >= 100 then count = count + 1 end
    end
    return count
end

return Disease
