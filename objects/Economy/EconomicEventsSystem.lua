-- objects/Economy/EconomicEventsSystem.lua
-- Castle Kingdoms 2027 - Random Economic Events
--
-- Triggers random events that affect gameplay:
-- - Blight: -50% crop yield for 60s
-- - Bumper harvest: +50% crop yield for 60s
-- - Gold rush: +500 gold instantly
-- - Plague: -10% population
-- - Trade boom: +20% trade prices for 120s
-- - Trade bust: -20% trade prices for 120s
-- - Mild winter: -20% food consumption (only in winter)
-- - Harsh winter: +30% food consumption (only in winter)
-- - Merchant caravan: bonus trade opportunity
-- - Festival: +20 popularity temporarily
--
-- Events trigger randomly based on probability per game year

local EconomicEventsSystem = {}

-- Event definitions
local EVENTS = {
    blight = {
        name = "Blight",
        nameSlv = "Nesreča za pridelke",
        description = "A disease has struck your crops! Food production reduced by 50%.",
        descriptionSlv = "Bolezen je zadela vaše pridelke! Proizvodnja hrane zmanjšana za 50%.",
        probability = 0.15,  -- 15% chance per year
        duration = 60,       -- seconds
        minYear = 2,         -- only after year 2
        seasons = {"spring", "summer"},  -- only in these seasons
        effects = {
            production = { food = 0.5 },
            prices = { wheat = 1.4, flour = 1.3, bread = 1.3 },
        },
        type = "negative",
    },
    bumper_harvest = {
        name = "Bumper Harvest",
        nameSlv = "Bogata letina",
        description = "Excellent weather has produced a bumper harvest! Food production increased by 50%.",
        descriptionSlv = "Odlično vreme je prineslo bogato letino! Proizvodnja hrane povečana za 50%.",
        probability = 0.20,
        duration = 60,
        minYear = 1,
        seasons = {"summer", "autumn"},
        effects = {
            production = { food = 1.5 },
            prices = { wheat = 0.8, flour = 0.85, bread = 0.9 },
        },
        type = "positive",
    },
    gold_rush = {
        name = "Gold Rush",
        nameSlv = "Zlata mrzlica",
        description = "A gold vein has been discovered! +500 gold.",
        descriptionSlv = "Odkrita je bila žila zlata! +500 zlata.",
        probability = 0.10,
        duration = 0,  -- instant
        minYear = 1,
        seasons = nil,  -- any season
        effects = {
            instantGold = 500,
        },
        type = "positive",
    },
    plague = {
        name = "Plague",
        nameSlv = "Kuga",
        description = "A plague has struck your village! 10% of population lost.",
        descriptionSlv = "Kuga je zadela vašo vas! Izgubljenih 10% prebivalstva.",
        probability = 0.08,
        duration = 0,  -- instant
        minYear = 3,
        seasons = nil,
        effects = {
            populationLoss = 0.10,
            prices = { meat = 1.5, cheese = 1.4, bread = 1.3 },
        },
        type = "negative",
    },
    trade_boom = {
        name = "Trade Boom",
        nameSlv = "Trgovski razcvet",
        description = "Trade routes are flourishing! Sell prices increased by 20% for 2 minutes.",
        descriptionSlv = "Trgovske poti cvetijo! Prodajne cene povečane za 20% za 2 minuti.",
        probability = 0.20,
        duration = 120,
        minYear = 1,
        seasons = nil,
        effects = {
            prices = { wood = 1.2, stone = 1.2, iron = 1.2, wheat = 1.2, ale = 1.2 },
        },
        type = "positive",
    },
    trade_bust = {
        name = "Trade Bust",
        nameSlv = "Trgovski zaton",
        description = "Markets are depressed. Sell prices reduced by 20% for 2 minutes.",
        descriptionSlv = "Trgi so depresivni. Prodajne cene zmanjšane za 20% za 2 minuti.",
        probability = 0.20,
        duration = 120,
        minYear = 1,
        seasons = nil,
        effects = {
            prices = { wood = 0.8, stone = 0.8, iron = 0.8, wheat = 0.8, ale = 0.8 },
        },
        type = "negative",
    },
    mild_winter = {
        name = "Mild Winter",
        nameSlv = "Blaga zima",
        description = "The winter is milder than expected. Food consumption reduced by 20%.",
        descriptionSlv = "Zima je milejša od pričakovanj. Poraba hrane zmanjšana za 20%.",
        probability = 0.30,  -- high chance, but only triggers in winter
        duration = 90,
        minYear = 1,
        seasons = {"winter"},
        effects = {
            consumption = { food = 0.8 },
        },
        type = "positive",
    },
    harsh_winter = {
        name = "Harsh Winter",
        nameSlv = "Ostra zima",
        description = "The winter is harsher than expected. Food consumption increased by 30%.",
        descriptionSlv = "Zima je ostrejša od pričakovanj. Poraba hrane povečana za 30%.",
        probability = 0.30,
        duration = 90,
        minYear = 1,
        seasons = {"winter"},
        effects = {
            consumption = { food = 1.3 },
            prices = { wood = 1.4, bread = 1.5 },
        },
        type = "negative",
    },
    merchant_caravan = {
        name = "Merchant Caravan",
        nameSlv = "Trgovska karavana",
        description = "A traveling merchant offers special trade deals!",
        descriptionSlv = "Potujoči trgovec ponuja posebne trgovske ponudbe!",
        probability = 0.15,
        duration = 0,
        minYear = 2,
        seasons = nil,
        effects = {
            instantGold = 200,
            prices = { wood = 0.7, stone = 0.7 },  -- cheap goods available
        },
        type = "positive",
    },
    festival = {
        name = "Festival",
        nameSlv = "Praznik",
        description = "The people celebrate! Popularity increased temporarily.",
        descriptionSlv = "Ljudje praznujejo! Priljubljenost začasno povečana.",
        probability = 0.15,
        duration = 60,
        minYear = 1,
        seasons = {"summer", "autumn"},
        effects = {
            popularity = 20,
        },
        type = "positive",
    },
    -- Castle Kingdoms 2027 v2.5.5: 5 new economic events
    iron_discovery = {
        name = "Iron Discovery",
        nameSlv = "Odkritje železa",
        description = "A rich iron vein has been discovered! Iron production increased.",
        descriptionSlv = "Bogata železna žila je bila odkrita! Proizvodnja železa povečana.",
        probability = 0.08,
        duration = 90,
        minYear = 2,
        seasons = nil,
        effects = {
            production = { iron = 2.0 },
            prices = { iron = 0.6 },
        },
        type = "positive",
    },
    drought = {
        name = "Drought",
        nameSlv = "Suša",
        description = "A severe drought has struck! Food and wood production reduced.",
        descriptionSlv = "Huda suša je zadela! Proizvodnja hrane in lesa zmanjšana.",
        probability = 0.12,
        duration = 75,
        minYear = 2,
        seasons = {"summer"},
        effects = {
            production = { food = 0.4, wood = 0.7 },
            prices = { wheat = 1.5, bread = 1.4, apples = 1.3 },
        },
        type = "negative",
    },
    trade_boom = {
        name = "Trade Boom",
        nameSlv = "Trgovski razcvet",
        description = "Foreign merchants arrive! All prices shift favorably for sellers.",
        descriptionSlv = "Tujci trgovci prihajajo! Vse cene se ugodno premaknejo za prodajalce.",
        probability = 0.10,
        duration = 120,
        minYear = 1,
        seasons = nil,
        effects = {
            prices = { wood = 1.3, stone = 1.3, iron = 1.2, gold = 1.0 },
        },
        type = "positive",
    },
    bandit_raid = {
        name = "Bandit Raid",
        nameSlv = "Napad banditov",
        description = "Bandits have raided your caravans! Gold and goods lost.",
        descriptionSlv = "Banditi so napadli vaše karavane! Zlato in blago izgubljeno.",
        probability = 0.10,
        duration = 0,
        minYear = 3,
        seasons = nil,
        effects = {
            instantGold = -300,
            populationLoss = 0.02,
        },
        type = "negative",
    },
    holy_pilgrimage = {
        name = "Holy Pilgrimage",
        nameSlv = "Sveto romanje",
        description = "A holy pilgrimage passes through! Popularity soars and trade flourishes.",
        descriptionSlv = "Sveto romanje poteka skozi! Priljubljenost naraste in trgovina cveti.",
        probability = 0.05,
        duration = 100,
        minYear = 3,
        seasons = {"spring", "summer"},
        effects = {
            popularity = 30,
            prices = { ale = 0.8, bread = 0.9 },
        },
        type = "positive",
    },
}

-- State
local initialized = false
local activeEvents = {}  -- currently active events
local eventHistory = {}  -- log of past events
local checkTimer = 0
local checkInterval = 30  -- check for new events every 30 seconds

-- Initialize
function EconomicEventsSystem.init()
    if initialized then return end
    initialized = true
    checkTimer = 0
    print("[EconomicEvents] Initialized with " .. #EVENTS .. " possible events")
end

-- Update system
function EconomicEventsSystem.update(dt)
    if not initialized then return end

    checkTimer = checkTimer + dt

    -- Check for new events periodically
    if checkTimer >= checkInterval then
        checkTimer = 0
        EconomicEventsSystem.tryTriggerEvent()
    end

    -- Update active events
    EconomicEventsSystem.updateActiveEvents(dt)
end

-- Try to trigger a random event
function EconomicEventsSystem.tryTriggerEvent()
    local SeasonalSystem = require("objects.Economy.SeasonalSystem")
    local currentSeason = SeasonalSystem.getCurrentSeason()
    local currentYear = SeasonalSystem.getYear()

    -- Build list of possible events
    local possibleEvents = {}
    for eventKey, eventData in pairs(EVENTS) do
        -- Check year requirement
        if currentYear >= (eventData.minYear or 1) then
            -- Check season requirement
            local seasonOk = true
            if eventData.seasons then
                seasonOk = false
                for _, s in ipairs(eventData.seasons) do
                    if s == currentSeason then
                        seasonOk = true
                        break
                    end
                end
            end

            -- Check if event is already active
            local alreadyActive = false
            for _, active in ipairs(activeEvents) do
                if active.key == eventKey then
                    alreadyActive = true
                    break
                end
            end

            if seasonOk and not alreadyActive then
                table.insert(possibleEvents, {
                    key = eventKey,
                    data = eventData,
                })
            end
        end
    end

    if #possibleEvents == 0 then return end

    -- Calculate total probability (normalized)
    local totalProb = 0
    for _, event in ipairs(possibleEvents) do
        totalProb = totalProb + event.data.probability
    end

    -- CheckInterval is 30s, so per check, probability is event.probability / 4 (per year, ~120s)
    -- We want roughly 1 event per year on average
    local roll = math.random()
    local cumulativeProb = 0

    for _, event in ipairs(possibleEvents) do
        local eventChance = (event.data.probability / totalProb) * 0.25  -- 25% chance per check
        cumulativeProb = cumulativeProb + eventChance

        if roll <= cumulativeProb then
            EconomicEventsSystem.triggerEvent(event.key)
            return
        end
    end
end

-- Trigger a specific event
function EconomicEventsSystem.triggerEvent(eventKey)
    local eventData = EVENTS[eventKey]
    if not eventData then return false end

    print("[EconomicEvents] Triggering: " .. eventData.name)

    -- Apply instant effects
    if eventData.effects.instantGold then
        if _G.state then
            _G.state.gold = (_G.state.gold or 0) + eventData.effects.instantGold
        end
    end

    if eventData.effects.populationLoss then
        if _G.state then
            local loss = math.floor((_G.state.population or 0) * eventData.effects.populationLoss)
            _G.state.population = math.max(0, (_G.state.population or 0) - loss)
        end
    end

    if eventData.effects.popularity then
        if _G.state then
            _G.state.popularity = (_G.state.popularity or 50) + eventData.effects.popularity
        end
    end

    -- Apply price modifiers via DynamicMarket
    if eventData.effects.prices then
        local DynamicMarket = require("objects.Economy.DynamicMarketSystem")
        for resource, multiplier in pairs(eventData.effects.prices) do
            DynamicMarket.triggerEvent(resource, multiplier, eventData.duration)
        end
    end

    -- Add to active events if has duration
    if eventData.duration > 0 then
        table.insert(activeEvents, {
            key = eventKey,
            data = eventData,
            startTime = love.timer.getTime(),
            duration = eventData.duration,
        })
    end

    -- Show notification
    local ModernUI = require("objects.UI.ModernUISystem")
    local notifType = eventData.type == "positive" and "success" or "warning"
    ModernUI.notify(eventData.nameSlv .. ": " .. eventData.descriptionSlv, notifType, 8)

    -- Log event
    table.insert(eventHistory, {
        key = eventKey,
        name = eventData.name,
        time = love.timer.getTime(),
        type = eventData.type,
    })

    -- Limit history size
    while #eventHistory > 20 do
        table.remove(eventHistory, 1)
    end

    return true
end

-- Update active events
function EconomicEventsSystem.updateActiveEvents(dt)
    local now = love.timer.getTime()

    for i = #activeEvents, 1, -1 do
        local event = activeEvents[i]
        local elapsed = now - event.startTime

        if elapsed >= event.duration then
            -- Event ended
            print("[EconomicEvents] Event ended: " .. event.data.name)

            -- Remove production/consumption modifiers (they were set via market)
            -- The DynamicMarketSystem handles price recovery automatically

            table.remove(activeEvents, i)
        end
    end
end

-- Get production modifier from active events
function EconomicEventsSystem.getProductionModifier(resourceType)
    local modifier = 1.0
    for _, event in ipairs(activeEvents) do
        if event.data.effects.production and event.data.effects.production[resourceType] then
            modifier = modifier * event.data.effects.production[resourceType]
        end
    end
    return modifier
end

-- Get consumption modifier from active events
function EconomicEventsSystem.getConsumptionModifier(resourceType)
    local modifier = 1.0
    for _, event in ipairs(activeEvents) do
        if event.data.effects.consumption and event.data.effects.consumption[resourceType] then
            modifier = modifier * event.data.effects.consumption[resourceType]
        end
    end
    return modifier
end

-- Get active events
function EconomicEventsSystem.getActiveEvents()
    local list = {}
    for _, event in ipairs(activeEvents) do
        local elapsed = love.timer.getTime() - event.startTime
        table.insert(list, {
            key = event.key,
            name = event.data.name,
            nameSlv = event.data.nameSlv,
            type = event.data.type,
            elapsed = elapsed,
            remaining = event.duration - elapsed,
            duration = event.duration,
        })
    end
    return list
end

-- Get event history
function EconomicEventsSystem.getEventHistory()
    return eventHistory
end

-- Force trigger an event (for testing or scenarios)
function EconomicEventsSystem.forceEvent(eventKey)
    return EconomicEventsSystem.triggerEvent(eventKey)
end

-- Get stats
function EconomicEventsSystem.getStats()
    return {
        activeCount = #activeEvents,
        historyCount = #eventHistory,
        checkInterval = checkInterval,
        nextCheckIn = checkInterval - checkTimer,
    }
end

-- Reset (for new game)
function EconomicEventsSystem.reset()
    activeEvents = {}
    eventHistory = {}
    checkTimer = 0
    print("[EconomicEvents] Reset")
end

-- Get all defined events (for UI or debug)
function EconomicEventsSystem.getAllEvents()
    return EVENTS
end

return EconomicEventsSystem
