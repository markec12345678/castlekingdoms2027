-- objects/Config/PopulationSystem.lua
-- Stronghold 2027 v2.6.5 - Population & Happiness System
--
-- Manages population growth, happiness, and taxation effects.
-- Population grows based on housing capacity and food availability.
-- Happiness affects productivity and population growth rate.
--
-- Happiness factors:
-- - Food supply (lack of food = -happiness)
-- - Tax level (higher taxes = -happiness)
-- - Housing (overcrowding = -happiness)
-- - Religion (chapels/churches = +happiness)
-- - Festivals (active festivals = +happiness)
-- - Employment (unemployed = -happiness)

local PopulationSystem = {}

local initialized = false
local currentPopulation = 0
local maxPopulation = 0
local happiness = 50  -- 0-100, 50 = neutral
local growthRate = 0
local lastUpdate = 0
local updateInterval = 5.0  -- update every 5 seconds

-- Happiness modifiers (calculated dynamically)
local happinessModifiers = {}

function PopulationSystem.init()
    if initialized then return end
    initialized = true
    print("[PopulationSystem] Initialized")
end

-- Calculate max population from housing buildings
function PopulationSystem._calculateMaxPop()
    local max = 0
    if _G.state and _G.state.gameObjectList then
        for _, obj in ipairs(_G.state.gameObjectList) do
            if (not obj.faction or obj.faction == 1) and obj.class and obj.class.name then
                local name = obj.class.name
                -- Housing capacity values
                if name == "Hovel" then max = max + 4
                elseif name == "Flat" then max = max + 8
                elseif name == "Residence" then max = max + 12
                elseif name == "BigResidence" then max = max + 16
                end
            end
        end
    end
    return max
end

-- Calculate happiness modifiers
function PopulationSystem._calculateHappiness()
    happinessModifiers = {}
    local total = 50  -- base happiness

    -- Food factor
    local food = 0
    if _G.state and _G.state.resources then
        food = _G.state.resources.food or 0
    end
    if food > 100 then
        happinessModifiers.food = { value = 10, desc = "Izobilje hrane" }
        total = total + 10
    elseif food < 20 then
        happinessModifiers.food = { value = -20, desc = "Pomanjkanje hrane" }
        total = total - 20
    elseif food < 50 then
        happinessModifiers.food = { value = -5, desc = "Nizke zaloge hrane" }
        total = total - 5
    end

    -- Tax factor
    local taxLevel = 0
    if _G.TaxController and _G.TaxController.getTaxLevel then
        taxLevel = _G.TaxController.getTaxLevel() or 0
    end
    -- Tax levels: 0=no tax, 5=normal, 10=very cruel
    if taxLevel <= 4 then
        happinessModifiers.tax = { value = 5, desc = "Nizki davki" }
        total = total + 5
    elseif taxLevel >= 8 then
        happinessModifiers.tax = { value = -15, desc = "Visoki davki" }
        total = total - 15
    elseif taxLevel >= 6 then
        happinessModifiers.tax = { value = -5, desc = "Srednji davki" }
        total = total - 5
    end

    -- Housing factor (overcrowding)
    if currentPopulation > maxPopulation then
        local overflow = currentPopulation - maxPopulation
        local penalty = math.min(20, overflow * 2)
        happinessModifiers.housing = { value = -penalty, desc = "Prenapolnjenost" }
        total = total - penalty
    elseif maxPopulation > currentPopulation + 10 then
        happinessModifiers.housing = { value = 5, desc = "Prostorno stanovanje" }
        total = total + 5
    end

    -- Religion factor
    local religiousBuildings = 0
    if _G.state and _G.state.gameObjectList then
        for _, obj in ipairs(_G.state.gameObjectList) do
            if (not obj.faction or obj.faction == 1) and obj.class and obj.class.name then
                local name = obj.class.name
                if name == "Chapel" then religiousBuildings = religiousBuildings + 1
                elseif name == "Church" then religiousBuildings = religiousBuildings + 2
                elseif name == "Cathedral" then religiousBuildings = religiousBuildings + 5
                end
            end
        end
    end
    if religiousBuildings > 0 then
        local bonus = math.min(15, religiousBuildings * 3)
        happinessModifiers.religion = { value = bonus, desc = "Verske institucije" }
        total = total + bonus
    end

    -- Festival factor
    if _G.FestivalSystem and _G.FestivalSystem.getActiveFestivals then
        local festivals = _G.FestivalSystem.getActiveFestivals()
        if #festivals > 0 then
            happinessModifiers.festival = { value = 10, desc = "Aktivni prazniki" }
            total = total + 10
        end
    end

    -- Clamp happiness 0-100
    happiness = math.max(0, math.min(100, total))
    return happiness
end

-- Calculate population growth rate
function PopulationSystem._calculateGrowthRate()
    -- Growth rate based on happiness and available housing
    local availableHousing = maxPopulation - currentPopulation
    if availableHousing <= 0 then
        growthRate = 0
        return 0
    end

    -- Happiness affects growth: 50+ = positive, <50 = negative
    local happinessFactor = (happiness - 50) / 50  -- -1.0 to 1.0
    growthRate = happinessFactor * 2  -- -2 to +2 per update

    -- Food check — no growth without food
    local food = 0
    if _G.state and _G.state.resources then
        food = _G.state.resources.food or 0
    end
    if food < 10 then
        growthRate = growthRate - 1  -- starvation
    end

    return growthRate
end

-- Update population (called periodically)
function PopulationSystem.update(dt)
    if not initialized then return end
    lastUpdate = lastUpdate + dt
    if lastUpdate < updateInterval then return end
    lastUpdate = 0

    -- Recalculate max pop
    maxPopulation = PopulationSystem._calculateMaxPop()

    -- Recalculate happiness
    PopulationSystem._calculateHappiness()

    -- Calculate and apply growth
    PopulationSystem._calculateGrowthRate()
    local newPop = currentPopulation + growthRate
    currentPopulation = math.max(0, math.min(maxPopulation, math.floor(newPop + 0.5)))

    -- Update game state
    if _G.state then
        _G.state.population = currentPopulation
        _G.state.maxPopulation = maxPopulation
        _G.state.popularity = happiness
    end
end

-- Get current stats
function PopulationSystem.getStats()
    return {
        population = currentPopulation,
        maxPopulation = maxPopulation,
        happiness = happiness,
        growthRate = growthRate,
        happinessModifiers = happinessModifiers,
    }
end

-- Get happiness breakdown for UI
function PopulationSystem.getHappinessBreakdown()
    local breakdown = {
        total = happiness,
        modifiers = {},
    }
    for key, mod in pairs(happinessModifiers) do
        table.insert(breakdown.modifiers, {
            category = key,
            value = mod.value,
            description = mod.desc,
        })
    end
    return breakdown
end

-- Force set population (for testing/load)
function PopulationSystem.setPopulation(pop)
    currentPopulation = pop
    if _G.state then
        _G.state.population = currentPopulation
    end
end

-- Add population (for new houses)
function PopulationSystem.addPopulation(amount)
    currentPopulation = math.min(maxPopulation, currentPopulation + amount)
end

return PopulationSystem
