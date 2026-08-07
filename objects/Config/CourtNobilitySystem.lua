-- objects/Config/CourtNobilitySystem.lua
-- Castle Kingdoms 2027 v3.0.6 - Court & Nobility System
--
-- Royal court management with advisors, marriages, heirs, and political intrigue.
-- Adds depth to kingdom management beyond military and economy.
--
-- Features:
-- - 6 advisor types with unique passive bonuses
-- - Marriage system (diplomatic alliances through marriage)
-- - Heir system (succession line for campaign continuity)
-- - Court events (banquets, tournaments, scandals)
-- - Noble factions (rival houses with influence)
-- - Court prestige (affects happiness and diplomacy)
-- - Assassination plots (risky political moves)

local Court = {}

-- Advisor types
local ADVISOR_TYPES = {
    chancellor = {
        name = "Kancler",
        nameEn = "Chancellor",
        bonus = { diplomacyBonus = 1.20, taxEfficiency = 1.10 },
        desc = "+20% diplomacija, +10% davki",
        cost = 800,
    },
    marshal = {
        name = "Maršal",
        nameEn = "Marshal",
        bonus = { unitProduction = 1.15, defenseBonus = 1.15, unitDamage = 1.10 },
        desc = "+15% produkcija enot, +15% obramba, +10% damage",
        cost = 800,
    },
    steward = {
        name = "Upravitelj",
        nameEn = "Steward",
        bonus = { taxEfficiency = 1.25, buildSpeed = 1.10, foodProduction = 1.10 },
        desc = "+25% davki, +10% gradnja, +10% hrana",
        cost = 800,
    },
    spymaster = {
        name = "Mojster vohunov",
        nameEn = "Spymaster",
        bonus = { espionageBonus = 1.50, counterSpyBonus = 1.30 },
        desc = "+50% vohunstvo, +30% protivohunstvo",
        cost = 1000,
    },
    chaplain = {
        name = "Kaplan",
        nameEn = "Court Chaplain",
        bonus = { happinessBonus = 1.20, researchSpeed = 1.15 },
        desc = "+20% sreča, +15% raziskovanje",
        cost = 700,
    },
    treasurer = {
        name = "Zakladnik",
        nameEn = "Treasurer",
        bonus = { taxEfficiency = 1.15, tradeBonus = 1.20, goldIncome = 1.10 },
        desc = "+15% davki, +20% trgovina, +10% zlato",
        cost = 900,
    },
}

Court.ADVISOR_TYPES = ADVISOR_TYPES

-- Noble houses (rival factions in court)
local NOBLE_HOUSES = {
    { name = "Hiša Hohenfels",   influence = 50, relation = 0,  trait = "militaristic" },
    { name = "Hiša Beaumont",    influence = 40, relation = 10, trait = "economic" },
    { name = "Hiša Ashwood",     influence = 35, relation = -5, trait = "diplomatic" },
    { name = "Hiša Blackstone",  influence = 30, relation = 0,  trait = "ambitious" },
    { name = "Hiša Stormwind",   influence = 25, relation = 5,  trait = "pious" },
}

Court.NOBLE_HOUSES = NOBLE_HOUSES

-- Court events
local COURT_EVENTS = {
    banquet = { name = "Banket",          desc = "Veliki banket na dvoru",          happinessBoost = 5,  cost = 200,  prestigeGain = 5 },
    tournament = { name = "Turnir",       desc = "Dvorni viteški turnir",           happinessBoost = 10, cost = 400,  prestigeGain = 10 },
    scandal = { name = "Škandal",         desc = "Dvorni škandal!",                 happinessBoost = -15, cost = 0,   prestigeGain = -10 },
    wedding = { name = "Svatba",          desc = "Kraljevska svatba",               happinessBoost = 20, cost = 1000, prestigeGain = 25 },
    coronation = { name = "Kronanje",     desc = "Slavnostno kronanje",             happinessBoost = 30, cost = 2000, prestigeGain = 50 },
    plague = { name = "Kuga na dvoru",    desc = "Bolezen izbruja na dvoru",        happinessBoost = -20, cost = 0,   prestigeGain = -15 },
    foreign_dignitary = { name = "Tuj obisk", desc = "Obisk tujega dostojanstvenika", happinessBoost = 5, cost = 100, prestigeGain = 8 },
}

Court.COURT_EVENTS = COURT_EVENTS

local initialized = false
local advisors = {}  -- recruited advisors
local nextAdvisorId = 1
local courtPrestige = 50  -- 0-100
local courtHappiness = 50
local marriages = {}  -- active marriage alliances
local heirs = {}  -- succession line
local courtEventTimer = 0
local courtEventInterval = 180  -- 3 minutes between random events
local activePlots = {}  -- assassination plots
local nobleRelations = {}  -- [houseName] = relation score

function Court.init()
    if initialized then return end
    initialized = true
    -- Initialize noble relations
    for _, house in ipairs(NOBLE_HOUSES) do
        nobleRelations[house.name] = house.relation
    end
    print("[Court] Initialized with " .. Court._getAdvisorCount() .. " advisor types, " .. #NOBLE_HOUSES .. " noble houses")
end

function Court._getAdvisorCount()
    local count = 0
    for _ in pairs(ADVISOR_TYPES) do count = count + 1 end
    return count
end

-- Recruit an advisor
function Court.recruitAdvisor(advisorType)
    local def = ADVISOR_TYPES[advisorType]
    if not def then return nil, "Unknown advisor type" end

    -- Check if slot already filled (one per type)
    for _, adv in ipairs(advisors) do
        if adv.type == advisorType then
            return nil, "Pozicija že zasedena"
        end
    end

    -- Check cost
    if _G.state and (_G.state.gold or 0) < def.cost then
        return nil, "Ni dovolj zlata (" .. def.cost .. "g)"
    end
    _G.state.gold = (_G.state.gold or 0) - def.cost

    local advisorId = nextAdvisorId
    nextAdvisorId = nextAdvisorId + 1

    local advisor = {
        id = advisorId,
        type = advisorType,
        name = Court._generateName(),
        loyalty = 75,
        level = 1,
        bonuses = def.bonus,
        recruitedAt = os.time(),
    }

    table.insert(advisors, advisor)

    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Svetovalnik imenovan: " .. advisor.name .. " (" .. def.name .. ")")
    end
    if _G.Prestige then
        pcall(function() _G.Prestige.award("achievement_common") end)
    end

    return advisorId
end

-- Generate advisor name
function Court._generateName()
    local firstNames = {"Thomas", "Henry", "William", "Richard", "Edward", "Geoffrey",
                        "Simon", "Walter", "Hubert", "Reginald", "Oliver", "Philip"}
    local titles = {"von Regensburg", "de Clermont", "of Winchester", "the Elder",
                    "the Younger", "Ironheart", "Goldwell", "Blackmere"}
    return firstNames[math.random(#firstNames)] .. " " .. titles[math.random(#titles)]
end

-- Get aggregated advisor bonus
function Court.getBonus(bonusName)
    local total = 1.0
    for _, adv in ipairs(advisors) do
        if adv.bonuses[bonusName] then
            local levelMult = 1.0 + (adv.level - 1) * 0.03
            total = total * (adv.bonuses[bonusName] * levelMult)
        end
    end
    return total
end

-- Level up advisor
function Court.levelUpAdvisor(advisorId)
    for _, adv in ipairs(advisors) do
        if adv.id == advisorId then
            if adv.level >= 5 then return false end
            adv.level = adv.level + 1
            if _G.ModernUI then
                _G.ModernUI.notifySuccess(adv.name .. " napredoval na nivo " .. adv.level)
            end
            return true
        end
    end
    return false
end

-- Arrange marriage
function Court.arrangeMarriage(targetFaction, targetName)
    local marriage = {
        id = #marriages + 1,
        targetFaction = targetFaction,
        targetName = targetName or "Princesa Isabella",
        partnerName = Court._generateName(),
        duration = 0,
        active = true,
        relationBoost = 20,
        createdAt = os.time(),
    }
    table.insert(marriages, marriage)

    -- Improve diplomatic relations
    if _G.DiplomaticRelations then
        pcall(function() _G.DiplomaticRelations.modifyRelation(1, targetFaction, "alliance_formed") end)
    end

    -- Boost court happiness and prestige
    courtHappiness = math.min(100, courtHappiness + 15)
    courtPrestige = math.min(100, courtPrestige + 10)

    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Svatba! " .. marriage.partnerName .. " × " .. marriage.targetName)
    end
    if _G.Prestige then
        pcall(function() _G.Prestige.award("achievement_rare") end)
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("marriage_arranged", marriage) end)
    end

    return marriage.id
end

-- Add heir to succession line
function Court.addHeir(name, age)
    local heir = {
        name = name or "Princ " .. (#heirs + 1),
        age = age or math.random(1, 15),
        successionOrder = #heirs + 1,
        bornAt = os.time(),
    }
    table.insert(heirs, heir)
    courtPrestige = math.min(100, courtPrestige + 5)
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Rodil se je dedič: " .. heir.name)
    end
    return heir
end

-- Trigger a court event
function Court.triggerEvent(eventType)
    local event = COURT_EVENTS[eventType]
    if not event then return false end

    -- Apply costs
    if event.cost > 0 and _G.state then
        if (_G.state.gold or 0) < event.cost then
            if _G.ModernUI then _G.ModernUI.notifyError("Ni dovolj zlata (" .. event.cost .. "g)") end
            return false
        end
        _G.state.gold = (_G.state.gold or 0) - event.cost
    end

    -- Apply effects
    courtHappiness = math.max(0, math.min(100, courtHappiness + event.happinessBoost))
    courtPrestige = math.max(0, math.min(100, courtPrestige + event.prestigeGain))

    -- Apply happiness to game state
    if _G.state then
        _G.state.popularity = math.max(0, math.min(100, (_G.state.popularity or 50) + event.happinessBoost))
    end

    -- Apply prestige
    if _G.Prestige and event.prestigeGain > 0 then
        pcall(function() _G.Prestige.award("achievement_common", event.prestigeGain / 5) end)
    end

    if _G.ModernUI then
        local notifType = event.happinessBoost >= 0 and "success" or "error"
        _G.ModernUI.notify(event.name .. ": " .. event.desc, notifType, 6)
    end
    if _G.GameEventBus then
        pcall(function() _G.GameEventBus.emit("court_event", { type = eventType, event = event }) end)
    end

    return true
end

-- Start assassination plot
function Court.startPlot(targetFaction, plotType)
    local plot = {
        id = #activePlots + 1,
        targetFaction = targetFaction,
        type = plotType or "assassinate_leader",
        successChance = 0.3,
        timeRemaining = 60,  -- 60 seconds to execute
        discovered = false,
    }

    -- Boost success chance with spymaster
    local spyBonus = Court.getBonus("espionageBonus")
    plot.successChance = math.min(0.8, plot.successChance * (spyBonus - 0.5))

    table.insert(activePlots, plot)

    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Zarota začeta (uspeh: " .. math.floor(plot.successChance * 100) .. "%)")
    end

    return plot.id
end

-- Update court
function Court.update(dt)
    if not initialized then return end

    -- Random court events
    courtEventTimer = courtEventTimer + dt
    if courtEventTimer >= courtEventInterval then
        courtEventTimer = 0
        local eventKeys = {}
        for k, _ in pairs(COURT_EVENTS) do table.insert(eventKeys, k) end
        local randomEvent = eventKeys[math.random(#eventKeys)]
        Court.triggerEvent(randomEvent)
    end

    -- Update plots
    for i = #activePlots, 1, -1 do
        local plot = activePlots[i]
        plot.timeRemaining = plot.timeRemaining - dt
        if plot.timeRemaining <= 0 then
            -- Execute plot
            if math.random() < plot.successChance then
                if _G.ModernUI then
                    _G.ModernUI.notifySuccess("Zarota uspešna!")
                end
                if _G.DiplomaticRelations then
                    pcall(function() _G.DiplomaticRelations.modifyRelation(1, plot.targetFaction, "assassination_attempt", -40) end)
                end
            else
                -- Plot failed — discovered
                plot.discovered = true
                if _G.ModernUI then
                    _G.ModernUI.notifyError("Zarota odkrita! Odnosi poslabšani")
                end
                if _G.DiplomaticRelations then
                    pcall(function() _G.DiplomaticRelations.modifyRelation(1, plot.targetFaction, "assassination_attempt", -30) end)
                end
                courtPrestige = math.max(0, courtPrestige - 10)
            end
            table.remove(activePlots, i)
        end
    end

    -- Court prestige slowly drifts toward 50
    if courtPrestige > 50 then courtPrestige = courtPrestige - dt * 0.01
    elseif courtPrestige < 50 then courtPrestige = courtPrestige + dt * 0.005 end

    -- Advisor loyalty drift
    for _, adv in ipairs(advisors) do
        if adv.loyalty > 50 then adv.loyalty = adv.loyalty - dt * 0.01
        elseif adv.loyalty < 50 then adv.loyalty = adv.loyalty + dt * 0.005 end
    end
end

-- Get court state
function Court.getState()
    return {
        prestige = math.floor(courtPrestige),
        happiness = math.floor(courtHappiness),
        advisorCount = #advisors,
        activeMarriages = #marriages,
        heirCount = #heirs,
        activePlots = #activePlots,
        nextEventIn = math.ceil(courtEventInterval - courtEventTimer),
    }
end

-- Get all advisors
function Court.getAdvisors()
    local result = {}
    for _, adv in ipairs(advisors) do
        local def = ADVISOR_TYPES[adv.type]
        table.insert(result, {
            id = adv.id,
            name = adv.name,
            type = adv.type,
            typeName = def and def.name or adv.type,
            level = adv.level,
            loyalty = math.floor(adv.loyalty),
            bonuses = adv.bonuses,
        })
    end
    return result
end

-- Get heirs
function Court.getHeirs()
    return heirs
end

-- Get noble houses
function Court.getNobleHouses()
    local result = {}
    for _, house in ipairs(NOBLE_HOUSES) do
        table.insert(result, {
            name = house.name,
            influence = house.influence,
            relation = nobleRelations[house.name] or 0,
            trait = house.trait,
        })
    end
    return result
end

-- Get marriages
function Court.getMarriages()
    return marriages
end

-- Get stats
function Court.getStats()
    return {
        totalAdvisors = #advisors,
        advisorTypesAvailable = Court._getAdvisorCount(),
        courtPrestige = math.floor(courtPrestige),
        courtHappiness = math.floor(courtHappiness),
        totalMarriages = #marriages,
        totalHeirs = #heirs,
        activePlots = #activePlots,
        nobleHouses = #NOBLE_HOUSES,
        courtEventTypes = 7,
    }
end

return Court
