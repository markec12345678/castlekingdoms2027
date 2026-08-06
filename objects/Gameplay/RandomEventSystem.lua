-- objects/Gameplay/RandomEventSystem.lua
-- Stronghold 2027 v2.7.1 - Random Event System
--
-- Triggers random events that affect gameplay unpredictably.
-- Events range from positive (hero unit visits) to negative (plague).
--
-- Event types:
-- - Hero Visit: a hero offers to join your army
-- - Merchant Caravan: special trade offer
-- - Plague: reduces population
-- - Fire: damages random buildings
-- - Earthquake: damages random structures
-- - Golden Age: temporary boost to all production
-- - Refugee Crisis: population spike but happiness drop

local RandomEvent = {}

local EVENTS = {
    hero_visit = {
        name = "Obisk heroja",
        nameEn = "Hero Visit",
        probability = 0.05,  -- 5% per check
        minYear = 2,
        type = "positive",
        description = "Legendarni heroj ponuja, da se pridruži tvoji vojski!",
        effect = function()
            -- Give player a free veteran unit
            if _G.state and _G.state.keepX then
                local CombatIntegration = _G.CombatIntegration
                if CombatIntegration and CombatIntegration.spawnUnit then
                    local heroes = {"Knight", "NormanKnight"}
                    local hero = heroes[math.random(#heroes)]
                    pcall(function()
                        local unit = CombatIntegration.spawnUnit(hero, _G.state.keepX + 3, _G.state.keepY + 3, 1)
                        if unit and _G.Veterancy then
                            pcall(function() _G.Veterancy.awardXP(unit, 500) end)  -- start as veteran
                        end
                    end)
                end
            end
            if _G.ModernUI then
                _G.ModernUI.notifySuccess("Heroj se je pridružil tvoji vojski!")
            end
        end,
    },
    merchant_caravan = {
        name = "Trgovska karavana",
        nameEn = "Merchant Caravan",
        probability = 0.08,
        minYear = 1,
        type = "positive",
        description = "Tuja trgovska karavana ponuja posebne cene!",
        effect = function()
            -- Give player gold
            local gold = math.random(200, 600)
            if _G.state then
                _G.state.gold = (_G.state.gold or 0) + gold
            end
            if _G.ModernUI then
                _G.ModernUI.notifySuccess("Trgovec ti daje " .. gold .. " zlata!")
            end
        end,
    },
    plague = {
        name = "Kuga",
        nameEn = "Plague",
        probability = 0.04,
        minYear = 3,
        type = "negative",
        description = "Kuga izbruja v tvoji deželi! Populacija zmanjšana.",
        effect = function()
            if _G.state then
                local loss = math.floor((_G.state.population or 0) * 0.15)  -- 15% population loss
                _G.state.population = math.max(0, (_G.state.population or 0) - loss)
                _G.state.popularity = math.max(0, (_G.state.popularity or 50) - 10)
                if _G.ModernUI then
                    _G.ModernUI.notifyError("Kuga! -" .. loss .. " populacije, -10 sreče")
                end
            end
        end,
    },
    fire = {
        name = "Požar",
        nameEn = "Fire",
        probability = 0.06,
        minYear = 2,
        type = "negative",
        description = "Požar izbruhne v naselju!",
        effect = function()
            -- Damage random buildings
            if _G.state and _G.state.gameObjectList then
                local damaged = 0
                for _, obj in ipairs(_G.state.gameObjectList) do
                    if (not obj.faction or obj.faction == 1) and obj.class and obj.class.name then
                        if math.random() < 0.10 then  -- 10% chance per building
                            if obj.health then
                                obj.health = obj.health * 0.5  -- lose 50% HP
                                damaged = damaged + 1
                            end
                        end
                    end
                end
                if _G.ModernUI then
                    _G.ModernUI.notifyError("Požar! " .. damaged .. " zgradb poškodovanih")
                end
            end
        end,
    },
    earthquake = {
        name = "Potres",
        nameEn = "Earthquake",
        probability = 0.02,
        minYear = 4,
        type = "negative",
        description = "Potres strese deželo! Zgradbe poškodovane.",
        effect = function()
            if _G.state and _G.state.gameObjectList then
                local damaged = 0
                for _, obj in ipairs(_G.state.gameObjectList) do
                    if (not obj.faction or obj.faction == 1) and obj.class and obj.class.name then
                        if math.random() < 0.20 then  -- 20% chance per building
                            if obj.health then
                                obj.health = obj.health * 0.7  -- lose 30% HP
                                damaged = damaged + 1
                            end
                        end
                    end
                end
                if _G.ModernUI then
                    _G.ModernUI.notifyError("Potres! " .. damaged .. " zgradb poškodovanih")
                end
            end
        end,
    },
    golden_age = {
        name = "Zlata doba",
        nameEn = "Golden Age",
        probability = 0.03,
        minYear = 3,
        type = "positive",
        description = "Zlata doba! Vsa proizvodnja povečana za 120s.",
        effect = function()
            -- Trigger a positive economic event
            local EconomicEvents = _G.EconomicEvents
            if EconomicEvents and EconomicEvents.triggerEvent then
                pcall(function() EconomicEvents.triggerEvent("bumper_harvest") end)
            end
            -- Give gold
            if _G.state then
                _G.state.gold = (_G.state.gold or 0) + 500
            end
            if _G.ModernUI then
                _G.ModernUI.notifySuccess("Zlata doba! +500 zlata, pridelki povečani!")
            end
        end,
    },
    refugee_crisis = {
        name = "begunska kriza",
        nameEn = "Refugee Crisis",
        probability = 0.05,
        minYear = 2,
        type = "mixed",
        description = "Begunci iščejo zatočišče! +20 populacije, -15 sreče.",
        effect = function()
            if _G.state then
                _G.state.population = (_G.state.population or 0) + 20
                _G.state.popularity = math.max(0, (_G.state.popularity or 50) - 15)
            end
            if _G.ModernUI then
                _G.ModernUI.notifyInfo("Begunci! +20 populacije, -15 sreče")
            end
        end,
    },
}

RandomEvent.EVENTS = EVENTS

local initialized = false
local checkTimer = 0
local checkInterval = 120  -- check every 2 minutes
local eventHistory = {}

function RandomEvent.init()
    if initialized then return end
    initialized = true
    print("[RandomEvent] Initialized with " .. RandomEvent._getEventCount() .. " events")
end

function RandomEvent._getEventCount()
    local count = 0
    for _ in pairs(EVENTS) do count = count + 1 end
    return count
end

-- Try to trigger a random event
function RandomEvent.tryTrigger()
    local SeasonalSystem = _G.SeasonalSystem
    local currentYear = (SeasonalSystem and SeasonalSystem.getYear) and SeasonalSystem.getYear() or 1

    -- Build list of possible events
    local possible = {}
    for eventId, event in pairs(EVENTS) do
        if currentYear >= (event.minYear or 1) then
            table.insert(possible, { id = eventId, event = event })
        end
    end

    if #possible == 0 then return end

    -- Pick a random event and roll for it
    for _, entry in ipairs(possible) do
        if math.random() < entry.event.probability then
            RandomEvent.trigger(entry.id)
            return
        end
    end
end

-- Trigger a specific event
function RandomEvent.trigger(eventId)
    local event = EVENTS[eventId]
    if not event then return false end

    print("[RandomEvent] Triggered: " .. event.name)
    if _G.ModernUI then
        _G.ModernUI.notify(event.name .. ": " .. event.description, event.type == "positive" and "success" or "warning", 8)
    end

    -- Apply effect (pcall for safety)
    pcall(event.effect)

    -- Record in history
    table.insert(eventHistory, {
        id = eventId,
        name = event.name,
        type = event.type,
        timestamp = os.time(),
    })
    while #eventHistory > 20 do
        table.remove(eventHistory, 1)
    end

    -- Fire GameEventBus
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("random_event", { id = eventId, name = event.name, type = event.type }) end)
    end

    return true
end

-- Update (check for events periodically)
function RandomEvent.update(dt)
    if not initialized then return end
    checkTimer = checkTimer + dt
    if checkTimer >= checkInterval then
        checkTimer = 0
        RandomEvent.tryTrigger()
    end
end

-- Get event history
function RandomEvent.getHistory()
    return eventHistory
end

-- Get stats
function RandomEvent.getStats()
    local positive = 0
    local negative = 0
    local mixed = 0
    for _, entry in ipairs(eventHistory) do
        if entry.type == "positive" then positive = positive + 1
        elseif entry.type == "negative" then negative = negative + 1
        else mixed = mixed + 1 end
    end
    return {
        totalEvents = #eventHistory,
        positive = positive,
        negative = negative,
        mixed = mixed,
        nextCheckIn = checkInterval - checkTimer,
    }
end

-- Force trigger (for testing)
function RandomEvent.forceTrigger(eventId)
    if eventId then
        return RandomEvent.trigger(eventId)
    else
        RandomEvent.tryTrigger()
    end
end

return RandomEvent
