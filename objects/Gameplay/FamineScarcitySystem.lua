-- objects/Gameplay/FamineScarcitySystem.lua
-- Castle Kingdoms 2027 v3.1.2 - Famine & Resource Scarcity System
--
-- Manages food shortages, droughts, blights, and resource scarcity events.
-- Players must use rationing, food imports, and emergency measures to survive.
--
-- Features:
-- - 6 scarcity events (drought, blight, locusts, harsh winter, flood, pestilence)
-- - Rationing system (4 levels: abundance, normal, reduced, starvation)
-- - Food imports & emergency supplies
-- - Starvation casualties (population loss if food runs out)
-- - Recovery programs (replanting, irrigation, grain reserves)
-- - Long-term climate cycle (years of plenty vs years of famine)
-- - Granary reserves (stockpile food for hard times)
-- - Mutual aid pacts with neighboring lords

local Famine = {}

-- ============================================================
-- SCARCITY EVENT DEFINITIONS
-- ============================================================
local SCARCITY_EVENTS = {
    drought = {
        name = "Suša",
        nameEn = "Drought",
        duration = 60,          -- game days
        effect = {
            foodProduction = 0.30,  -- -70% food
            happinessBonus = -10,
            waterShortage = true,
        },
        warningMessage = "Padavin ni več mesecev. Polja se sušijo.",
        icon = "☀",
        color = { 0.85, 0.65, 0.20 },
    },
    blight = {
        name = "Nežit",
        nameEn = "Blight",
        duration = 30,
        effect = {
            foodProduction = 0.20,  -- -80% food
            happinessBonus = -15,
            spreadChance = 0.30,    -- to other regions
        },
        warningMessage = "Nenadna bolezen prizadela polja. Žito gnije!",
        icon = "🍂",
        color = { 0.4, 0.25, 0.10 },
    },
    locusts = {
        name = "Kobilice",
        nameEn = "Locusts",
        duration = 14,
        effect = {
            foodProduction = 0.10,  -- -90% food
            happinessBonus = -20,
            instantLoss = 0.30,     -- 30% of stored food eaten instantly
        },
        warningMessage = "Roj kobilic črní nebesa! Požrejo vse pred seboj!",
        icon = "🦗",
        color = { 0.5, 0.4, 0.15 },
    },
    harsh_winter = {
        name = "Ostra zima",
        nameEn = "Harsh Winter",
        duration = 45,
        effect = {
            foodProduction = 0.50,
            happinessBonus = -12,
            woodConsumption = 2.0,   -- double wood for heating
            unitMovementReduction = 0.7,
        },
        warningMessage = "Zima prihaja zgodaj in ostro. Zaloge se tanjšajo.",
        icon = "❄",
        color = { 0.6, 0.75, 0.95 },
    },
    flood = {
        name = "Poplava",
        nameEn = "Flood",
        duration = 20,
        effect = {
            foodProduction = 0.40,
            happinessBonus = -8,
            buildingDamage = 0.05,   -- 5% of buildings damaged
            diseaseRisk = 1.5,       -- increases disease chance
        },
        warningMessage = "Reka je prestopila bregove. Polja so pod vodo!",
        icon = "🌊",
        color = { 0.3, 0.5, 0.85 },
    },
    pestilence_year = {
        name = "Leto kuge",
        nameEn = "Pestilence Year",
        duration = 90,
        effect = {
            foodProduction = 0.60,
            happinessBonus = -25,
            populationLoss = 0.10,   -- 10% population loss over duration
            tradeReduction = 0.50,
        },
        warningMessage = "Kuga se širi po deželi. Trgovci ne prihajajo več.",
        icon = "☠",
        color = { 0.3, 0.15, 0.25 },
    },
}

-- ============================================================
-- RATIONING LEVELS
-- ============================================================
local RATIONING_LEVELS = {
    abundance = {
        name = "Izobilje",
        foodConsumption = 1.5,   -- 150% consumption
        happinessBonus = 8,
        productivityBonus = 1.20,
    },
    normal = {
        name = "Normalno",
        foodConsumption = 1.0,
        happinessBonus = 0,
        productivityBonus = 1.0,
    },
    reduced = {
        name = "Zmanjšano",
        foodConsumption = 0.6,
        happinessBonus = -5,
        productivityBonus = 0.85,
    },
    starvation = {
        name = "Stradanje",
        foodConsumption = 0.2,
        happinessBonus = -25,
        productivityBonus = 0.50,
        casualtyChance = 0.05,   -- 5% of population dies per day
    },
}

-- ============================================================
-- CLIMATE CYCLE
-- ============================================================
local CLIMATE_PHASES = {
    spring_pleasant = { foodMult = 1.2, next = "summer_warm" },
    summer_warm = { foodMult = 1.1, next = "autumn_bountiful" },
    autumn_bountiful = { foodMult = 1.4, next = "winter_mild" },
    winter_mild = { foodMult = 0.8, next = "spring_pleasant" },
    -- Harsh cycle
    spring_late = { foodMult = 0.7, next = "summer_dry" },
    summer_dry = { foodMult = 0.5, next = "autumn_poor" },
    autumn_poor = { foodMult = 0.6, next = "winter_harsh" },
    winter_harsh = { foodMult = 0.3, next = "spring_pleasant" },  -- back to good cycle
}

-- ============================================================
-- STATE
-- ============================================================
Famine.activeEvents = {}            -- Currently active scarcity events
Famine.rationingLevel = "normal"
Famine.granaryReserves = 0          -- Stockpiled food
Famine.granaryMax = 5000
Famine.granaryBuildings = 0
Famine.climatePhase = "spring_pleasant"
Famine.climateTimer = 0
Famine.dayTimer = 0
Famine.starvationCasualties = 0
Famine.totalEvents = 0
Famine.mutualAidPacts = {}          -- Allies who can send food
Famine.importsActive = {}           -- Active food import contracts

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Famine.init()
    Famine.activeEvents = {}
    Famine.rationingLevel = "normal"
    Famine.granaryReserves = 0
    Famine.granaryMax = 5000
    Famine.granaryBuildings = 0
    Famine.climatePhase = "spring_pleasant"
    Famine.climateTimer = 0
    Famine.dayTimer = 0
    Famine.starvationCasualties = 0
    Famine.totalEvents = 0
    Famine.mutualAidPacts = {}
    Famine.importsActive = {}
    print("[Famine] Famine & Resource Scarcity System initialized (6 events, 4 rationing levels)")
end

-- ============================================================
-- GRANARY MANAGEMENT
-- ============================================================
function Famine.canBuildGranary()
    if not _G.state then return false end
    return (_G.state.gold or 0) >= 400 and
           (_G.state.resources and _G.state.resources.wood or 0) >= 100 and
           (_G.state.resources and _G.state.resources.stone or 0) >= 50
end

function Famine.buildGranary()
    if not Famine.canBuildGranary() then return false, "Premalo surovin" end
    _G.state.gold = _G.state.gold - 400
    _G.state.resources.wood = _G.state.resources.wood - 100
    _G.state.resources.stone = _G.state.resources.stone - 50
    Famine.granaryBuildings = Famine.granaryBuildings + 1
    Famine.granaryMax = Famine.granaryMax + 2000
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Žitnica zgrajena! Kapaciteta: " .. Famine.granaryMax, "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "GRANARY_BUILT", { total = Famine.granaryBuildings })
    end
    return true
end

function Famine.depositToGranary(amount)
    if not _G.state or not _G.state.resources then return false end
    local food = _G.state.resources.food or 0
    local space = Famine.granaryMax - Famine.granaryReserves
    local deposit = math.min(amount, food, space)
    if deposit <= 0 then return false end
    _G.state.resources.food = food - deposit
    Famine.granaryReserves = Famine.granaryReserves + deposit
    return true, deposit
end

function Famine.withdrawFromGranary(amount)
    if Famine.granaryReserves < amount then return false end
    Famine.granaryReserves = Famine.granaryReserves - amount
    if _G.state and _G.state.resources then
        _G.state.resources.food = (_G.state.resources.food or 0) + amount
    end
    return true
end

-- ============================================================
-- SCARCITY EVENT TRIGGERING
-- ============================================================
function Famine.triggerEvent(eventType, duration)
    local def = SCARCITY_EVENTS[eventType]
    if not def then return false, "Neznan event" end
    local event = {
        type = eventType,
        name = def.name,
        daysRemaining = duration or def.duration,
        totalDays = duration or def.duration,
        effect = def.effect,
        icon = def.icon,
        color = def.color,
    }
    table.insert(Famine.activeEvents, event)
    Famine.totalEvents = Famine.totalEvents + 1
    -- Apply instant effects
    if def.effect.instantLoss and _G.state and _G.state.resources then
        local lost = math.floor((_G.state.resources.food or 0) * def.effect.instantLoss)
        _G.state.resources.food = (_G.state.resources.food or 0) - lost
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, string.format("%s: %d hrane požrto!", def.name, lost), "danger")
        end
    end
    if def.effect.buildingDamage and _G.state and _G.state.buildings then
        local damaged = math.floor(#_G.state.buildings * def.effect.buildingDamage)
        if _G.NotificationCenter and damaged > 0 then
            pcall(_G.NotificationCenter.notify, string.format("%s: %d zgradb poškodovanih!", def.name, damaged), "danger")
        end
    end
    -- Default notification
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, def.warningMessage, "danger")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "SCARCITY_EVENT", { type = eventType, duration = event.daysRemaining })
    end
    return true
end

function Famine.rollRandomEvent()
    -- Higher chance during harsh climate phases
    local phase = CLIMATE_PHASES[Famine.climatePhase]
    local baseChance = 0.005
    if phase and phase.foodMult < 0.7 then baseChance = 0.015 end
    -- Increased by low granary reserves
    if Famine.granaryReserves < 100 then baseChance = baseChance * 2 end
    if math.random() < baseChance then
        local events = {}
        for k, _ in pairs(SCARCITY_EVENTS) do
            table.insert(events, k)
        end
        Famine.triggerEvent(events[math.random(#events)])
    end
end

-- ============================================================
-- RATIONING
-- ============================================================
function Famine.setRationing(level)
    if not RATIONING_LEVELS[level] then return false, "Neznana stopnja" end
    local old = Famine.rationingLevel
    Famine.rationingLevel = level
    local r = RATIONING_LEVELS[level]
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Racioniranje: " .. r.name, "info")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "RATIONING_CHANGED", { old = old, new = level })
    end
    return true
end

function Famine.getRationingInfo()
    return RATIONING_LEVELS[Famine.rationingLevel]
end

-- ============================================================
-- FOOD IMPORTS & MUTUAL AID
-- ============================================================
function Famine.orderFoodImport(amount, cost)
    if not _G.state then return false end
    cost = cost or math.floor(amount * 2)  -- 2 gold per food
    if (_G.state.gold or 0) < cost then
        return false, "Premalo zlata za uvoz"
    end
    _G.state.gold = _G.state.gold - cost
    -- Schedule delivery (after 60 seconds = next "day")
    table.insert(Famine.importsActive, {
        amount = amount,
        cost = cost,
        arrivalIn = 60,  -- seconds
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Naročilo hrane: %d enot (cena: %d zlata)", amount, cost), "info")
    end
    return true
end

function Famine.requestMutualAid(allyId)
    if not Famine.mutualAidPacts[allyId] then
        return false, "Ni pakti o pomoči s tem zaveznikom"
    end
    if math.random() < 0.7 then  -- 70% success
        local amount = math.random(100, 500)
        table.insert(Famine.importsActive, {
            amount = amount,
            cost = 0,  -- free from ally
            arrivalIn = 90,
            fromAlly = allyId,
        })
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Zaveznik %s pošilja %d hrane!", tostring(allyId), amount), "success")
        end
        return true
    else
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Zaveznik je zavrnil prošnjo za pomoč.", "warning")
        end
        return false
    end
end

function Famine.signMutualAidPact(allyId)
    Famine.mutualAidPacts[allyId] = true
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Pakt o pomoči podpisan!", "success")
    end
    return true
end

-- ============================================================
-- DAILY PROCESSING
-- ============================================================
function Famine.processDay()
    if not _G.state or not _G.state.resources then return end
    -- Calculate food production multiplier
    local productionMult = 1.0
    local phase = CLIMATE_PHASES[Famine.climatePhase]
    if phase then productionMult = productionMult * phase.foodMult end
    -- Active events reduce production
    for _, event in ipairs(Famine.activeEvents) do
        if event.effect.foodProduction then
            productionMult = productionMult * event.effect.foodProduction
        end
    end
    -- Rationing affects consumption (not production)
    local rationing = RATIONING_LEVELS[Famine.rationingLevel]
    local consumptionMult = rationing.foodConsumption
    -- Apply to state
    local baseFood = (_G.state.resources.foodProduction or 50) * productionMult
    local baseConsumption = (_G.state.population or 100) * 0.5 * consumptionMult
    local netFood = baseFood - baseConsumption
    _G.state.resources.food = (_G.state.resources.food or 0) + netFood
    -- If food is negative, withdraw from granary
    if (_G.state.resources.food or 0) < 0 then
        local deficit = -_G.state.resources.food
        local withdrawn = math.min(deficit, Famine.granaryReserves)
        Famine.granaryReserves = Famine.granaryReserves - withdrawn
        _G.state.resources.food = _G.state.resources.food + withdrawn
        -- Still negative? Starvation!
        if (_G.state.resources.food or 0) < 0 then
            Famine.applyStarvation(-_G.state.resources.food)
            _G.state.resources.food = 0
        end
    end
    -- Apply happiness modifier from rationing
    if _G.state.happiness then
        _G.state.happiness = math.max(0, math.min(100,
            _G.state.happiness + rationing.happinessBonus * 0.1))
    end
    -- Population loss from pestilence year
    for _, event in ipairs(Famine.activeEvents) do
        if event.effect.populationLoss and _G.state.population then
            local loss = math.floor(_G.state.population * event.effect.populationLoss / event.totalDays)
            _G.state.population = math.max(0, _G.state.population - loss)
        end
    end
end

function Famine.applyStarvation(deficit)
    local rationing = RATIONING_LEVELS[Famine.rationingLevel]
    -- Casualties based on rationing level
    local casualtyChance = rationing.casualtyChance or 0.02
    local casualties = math.floor((_G.state.population or 0) * casualtyChance)
    Famine.starvationCasualties = Famine.starvationCasualties + casualties
    if _G.state.population then
        _G.state.population = math.max(0, _G.state.population - casualties)
    end
    if _G.state.happiness then
        _G.state.happiness = math.max(0, _G.state.happiness - 5)
    end
    if _G.NotificationCenter and casualties > 0 then
        pcall(_G.NotificationCenter.notify,
            string.format("STRADANJE! %d prebivalcev umrlo.", casualties), "danger")
    end
end

function Famine.updateEvents(dt)
    for i = #Famine.activeEvents, 1, -1 do
        local event = Famine.activeEvents[i]
        event.daysRemaining = event.daysRemaining - 1
        if event.daysRemaining <= 0 then
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, event.name .. " se končuje.", "success")
            end
            table.remove(Famine.activeEvents, i)
        end
    end
end

function Famine.updateClimateCycle()
    local phase = CLIMATE_PHASES[Famine.climatePhase]
    if phase then
        Famine.climatePhase = phase.next
    end
end

function Famine.updateImports(dt)
    for i = #Famine.importsActive, 1, -1 do
        local imp = Famine.importsActive[i]
        imp.arrivalIn = imp.arrivalIn - dt
        if imp.arrivalIn <= 0 then
            if _G.state and _G.state.resources then
                _G.state.resources.food = (_G.state.resources.food or 0) + imp.amount
            end
            if _G.NotificationCenter then
                local msg = string.format("Dostava hrane prispe: %d enot", imp.amount)
                if imp.fromAlly then
                    msg = string.format("Pomoč od %s: %d hrane", tostring(imp.fromAlly), imp.amount)
                end
                pcall(_G.NotificationCenter.notify, msg, "success")
            end
            table.remove(Famine.importsActive, i)
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Famine.update(dt)
    if not _G.state then return end
    Famine.dayTimer = Famine.dayTimer + dt
    Famine.climateTimer = Famine.climateTimer + dt
    -- Day tick (every 30 sec)
    if Famine.dayTimer >= 30 then
        Famine.dayTimer = 0
        Famine.processDay()
        Famine.updateEvents(1)
        Famine.rollRandomEvent()
    end
    -- Climate cycle (every 90 sec = ~3 days)
    if Famine.climateTimer >= 90 then
        Famine.climateTimer = 0
        Famine.updateClimateCycle()
    end
    -- Imports are real-time
    Famine.updateImports(dt)
end

-- ============================================================
-- HELPERS
-- ============================================================
function Famine.getEventInfo(eventType) return SCARCITY_EVENTS[eventType] end
function Famine.getRationingLevels() return RATIONING_LEVELS end
function Famine.getClimatePhase() return Famine.climatePhase, CLIMATE_PHASES[Famine.climatePhase] end

function Famine.getStats()
    return {
        activeEvents = #Famine.activeEvents,
        rationingLevel = Famine.rationingLevel,
        granaryReserves = Famine.granaryReserves,
        granaryMax = Famine.granaryMax,
        granaryBuildings = Famine.granaryBuildings,
        climatePhase = Famine.climatePhase,
        starvationCasualties = Famine.starvationCasualties,
        totalEvents = Famine.totalEvents,
        pendingImports = #Famine.importsActive,
        mutualAidPacts = #Famine.mutualAidPacts,
    }
end

function Famine.getFoodMultiplier()
    local mult = 1.0
    local phase = CLIMATE_PHASES[Famine.climatePhase]
    if phase then mult = mult * phase.foodMult end
    for _, event in ipairs(Famine.activeEvents) do
        if event.effect.foodProduction then
            mult = mult * event.effect.foodProduction
        end
    end
    return mult
end

return Famine
