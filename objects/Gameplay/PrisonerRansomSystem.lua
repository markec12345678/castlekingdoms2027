-- objects/Gameplay/PrisonerRansomSystem.lua
-- Castle Kingdoms 2027 v3.1.1 - Prisoner & Ransom System
--
-- Manages capture of enemy units, ransom negotiations, prisoner exchanges,
-- and execution/release decisions. Tied to diplomatic relations.
--
-- Features:
-- - 5 prisoner classes (peasant, soldier, knight, lord, royal)
-- - Capture chance based on combat (vs wounded units)
-- - Ransom negotiation (offer, counter-offer, accept/reject)
-- - Prisoner exchange system (one-for-one, multi-for-multi)
-- - Execution mechanic (reputation hit, future capture chance)
-- - Prison maintenance cost (gold per day per prisoner)
-- - Prison capacity (dungeon building required)
-- - Diplomatic modifiers (capture affects relations)
-- - Random ransom events (relatives offering gold)

local Prisoner = {}

-- ============================================================
-- PRISONER CLASSES
-- ============================================================
local PRISONER_CLASSES = {
    peasant = {
        name = "Kmet",
        nameEn = "Peasant",
        ransomValue = 50,
        captureChance = 0.30,
        maintenancePerDay = 1,
        diplomaticWeight = 1,
        description = "Navaden kmet ali delavec. Nizka odkupnina.",
    },
    soldier = {
        name = "Vojak",
        nameEn = "Soldier",
        ransomValue = 200,
        captureChance = 0.15,
        maintenancePerDay = 3,
        diplomaticWeight = 3,
        description = "Navadni pešak. Srednja odkupnina.",
    },
    knight = {
        name = "Vitez",
        nameEn = "Knight",
        ransomValue = 1000,
        captureChance = 0.08,
        maintenancePerDay = 10,
        diplomaticWeight = 10,
        description = "Plemiški vitez. Visoka odkupnina in čast.",
    },
    lord = {
        name = "Plemič",
        nameEn = "Lord",
        ransomValue = 5000,
        captureChance = 0.04,
        maintenancePerDay = 25,
        diplomaticWeight = 25,
        description = "Visoki plemič z družino. Zelo visoka odkupnina.",
    },
    royal = {
        name = "Kraljevska oseba",
        nameEn = "Royal",
        ransomValue = 25000,
        captureChance = 0.01,
        maintenancePerDay = 100,
        diplomaticWeight = 100,
        description = "Član kraljevske družine. Astronomska odkupnina.",
    },
}

-- ============================================================
-- DUNGEON / PRISON BUILDINGS
-- ============================================================
local PRISON_BUILDINGS = {
    stockade = {
        name = "Zapora",
        capacity = 10,
        cost = { gold = 100, wood = 50 },
        upkeep = 2,
        escapeReduction = 0.10,
    },
    dungeon = {
        name = "Temnica",
        capacity = 30,
        cost = { gold = 500, wood = 100, stone = 200 },
        upkeep = 8,
        escapeReduction = 0.30,
    },
    tower = {
        name = "Stolp za jetnike",
        capacity = 75,
        cost = { gold = 1500, wood = 200, stone = 600 },
        upkeep = 20,
        escapeReduction = 0.60,
    },
    fortress_prison = {
        name = "Trdnjavska ječa",
        capacity = 200,
        cost = { gold = 5000, wood = 500, stone = 2000 },
        upkeep = 50,
        escapeReduction = 0.90,
    },
}

-- ============================================================
-- STATE
-- ============================================================
Prisoner.prisoners = {}              -- Captured prisoners
Prisoner.prisonBuildings = {}        -- Built prison buildings
Prisoner.activeNegotiations = {}     -- Active ransom negotiations
Prisoner.exchangeOffers = {}         -- Pending exchange offers
Prisoner.executions = 0              -- Total executions
Prisoner.released = 0                -- Total released
Prisoner.ransomed = 0                -- Total ransomed
Prisoner.totalRansomGold = 0         -- Total ransom received
Prisoner.updateTimer = 0
Prisoner.escapeTimer = 0
Prisoner.reputationWithLords = 50    -- 0-100, affects future captures

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Prisoner.init()
    Prisoner.prisoners = {}
    Prisoner.prisonBuildings = {}
    Prisoner.activeNegotiations = {}
    Prisoner.exchangeOffers = {}
    Prisoner.executions = 0
    Prisoner.released = 0
    Prisoner.ransomed = 0
    Prisoner.totalRansomGold = 0
    Prisoner.updateTimer = 0
    Prisoner.escapeTimer = 0
    Prisoner.reputationWithLords = 50
    print("[Prisoner] Prisoner & Ransom System initialized (5 classes, 4 prisons)")
end

-- ============================================================
-- PRISON CAPACITY
-- ============================================================
function Prisoner.getTotalCapacity()
    local cap = 0
    for _, b in ipairs(Prisoner.prisonBuildings) do
        local def = PRISON_BUILDINGS[b.type]
        if def then cap = cap + def.capacity end
    end
    return cap
end

function Prisoner.getEscapeReduction()
    local r = 0
    for _, b in ipairs(Prisoner.prisonBuildings) do
        local def = PRISON_BUILDINGS[b.type]
        if def then r = r + def.escapeReduction end
    end
    return math.min(0.95, r)
end

function Prisoner.canBuildPrison(buildingType)
    local def = PRISON_BUILDINGS[buildingType]
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

function Prisoner.buildPrison(buildingType, x, y)
    local ok, err = Prisoner.canBuildPrison(buildingType)
    if not ok then return false, err end
    local def = PRISON_BUILDINGS[buildingType]
    -- Deduct resources
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Prisoner.prisonBuildings, {
        type = buildingType, x = x or 0, y = y or 0,
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajena: " .. def.name, "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "PRISON_BUILT", { type = buildingType })
    end
    return true
end

-- ============================================================
-- CAPTURING PRISONERS
-- ============================================================
function Prisoner.attemptCapture(unitType, enemyFaction)
    local classId = Prisoner.classifyUnit(unitType)
    local class = PRISONER_CLASSES[classId]
    if not class then return false end
    -- Adjust capture chance based on reputation
    local repMod = (Prisoner.reputationWithLords - 50) / 200  -- +/- 25% at extremes
    local chance = class.captureChance + repMod
    if math.random() > chance then return false end
    -- Check capacity
    if #Prisoner.prisoners >= Prisoner.getTotalCapacity() then
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Zapora polna! Zapornik izpuščen.", "warning")
        end
        return false
    end
    -- Capture!
    local prisoner = {
        id = "prisoner_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        classId = classId,
        className = class.name,
        unitType = unitType,
        faction = enemyFaction or "unknown",
        ransomValue = class.ransomValue,
        maintenancePerDay = class.maintenancePerDay,
        capturedDay = os.time(),
        health = 100,
        escapeChance = 0.02 * (1 - Prisoner.getEscapeReduction()),
        diplomaticWeight = class.diplomaticWeight,
        negotiationState = "available",  -- available, negotiating, sold, executed, escaped, released
    }
    table.insert(Prisoner.prisoners, prisoner)
    -- Diplomatic hit
    if _G.DiplomacyController and enemyFaction then
        pcall(_G.DiplomacyController.changeRelation, enemyFaction, -class.diplomaticWeight / 5)
    end
    -- Notify
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Zapornik ujet: " .. class.name .. " (" .. class.ransomValue .. " zlata odkupnine)", "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "PRISONER_CAPTURED", {
            classId = classId, faction = enemyFaction, ransomValue = class.ransomValue,
        })
    end
    return true, prisoner.id
end

function Prisoner.classifyUnit(unitType)
    if not unitType then return "peasant" end
    -- Knights / lords / royal
    if unitType:match("king") or unitType:match("royal") or unitType:match("queen") then
        return "royal"
    elseif unitType:match("lord") or unitType:match("noble") or unitType:match("duke") then
        return "lord"
    elseif unitType:match("knight") or unitType:match("paladin") or unitType:match("elite") then
        return "knight"
    elseif unitType:match("soldier") or unitType:match("archer") or unitType:match("swordsman") or
           unitType:match("pikeman") or unitType:match("crossbowman") or unitType:match("scout") then
        return "soldier"
    else
        return "peasant"
    end
end

-- ============================================================
-- RANSOM NEGOTIATIONS
-- ============================================================
function Prisoner.startRansomNegotiation(prisonerId, askAmount)
    askAmount = askAmount or 0
    local prisoner = Prisoner.findPrisoner(prisonerId)
    if not prisoner then return false, "Zapornik ne obstaja" end
    if prisoner.negotiationState ~= "available" then
        return false, "Zapornik ni na voljo za negotiacijo"
    end
    -- Default ask = ransomValue * (1 +/- 20%)
    if askAmount == 0 then
        askAmount = math.floor(prisoner.ransomValue * (0.8 + math.random() * 0.4))
    end
    local negotiation = {
        id = "nego_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        prisonerId = prisonerId,
        askAmount = askAmount,
        originalAsk = askAmount,
        counterOffer = 0,
        round = 1,
        maxRounds = 5,
        faction = prisoner.faction,
        state = "waiting_for_counter",  -- waiting_for_counter, counter_offered, accepted, rejected, expired
        createdDay = os.time(),
    }
    table.insert(Prisoner.activeNegotiations, negotiation)
    prisoner.negotiationState = "negotiating"
    -- Simulate counter-offer from enemy faction
    local repMod = (Prisoner.reputationWithLords - 50) / 100
    local counterMultiplier = 0.5 + math.random() * 0.3 - repMod  -- lower counter if low rep
    counterMultiplier = math.max(0.2, counterMultiplier)
    negotiation.counterOffer = math.floor(askAmount * counterMultiplier)
    negotiation.state = "counter_offered"
    return true, negotiation.id
end

function Prisoner.acceptCounterOffer(negotiationId)
    for _, n in ipairs(Prisoner.activeNegotiations) do
        if n.id == negotiationId and n.state == "counter_offered" then
            n.state = "accepted"
            -- Transfer gold
            if _G.state then
                _G.state.gold = (_G.state.gold or 0) + n.counterOffer
            end
            Prisoner.totalRansomGold = Prisoner.totalRansomGold + n.counterOffer
            Prisoner.ransomed = Prisoner.ransomed + 1
            -- Mark prisoner as sold
            local prisoner = Prisoner.findPrisoner(n.prisonerId)
            if prisoner then
                prisoner.negotiationState = "sold"
                prisoner.soldFor = n.counterOffer
            end
            -- Diplomatic boost
            if _G.DiplomacyController and n.faction then
                pcall(_G.DiplomacyController.changeRelation, n.faction, 5)
            end
            Prisoner.reputationWithLords = math.min(100, Prisoner.reputationWithLords + 2)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("Odkupnina prejeta: %d zlata", n.counterOffer), "success")
            end
            if _G.GameEventBus then
                pcall(_G.GameEventBus.publish, "RANSOM_ACCEPTED", { amount = n.counterOffer })
            end
            return true
        end
    end
    return false
end

function Prisoner.rejectCounterOffer(negotiationId, newAskAmount)
    for _, n in ipairs(Prisoner.activeNegotiations) do
        if n.id == negotiationId and n.state == "counter_offered" then
            n.round = n.round + 1
            if n.round > n.maxRounds then
                n.state = "rejected"
                local prisoner = Prisoner.findPrisoner(n.prisonerId)
                if prisoner then prisoner.negotiationState = "available" end
                return false, "Negovorije spodletela"
            end
            if newAskAmount and newAskAmount > 0 then
                n.askAmount = newAskAmount
            end
            -- Enemy makes new counter
            local reduction = 0.5 + math.random() * 0.2
            n.counterOffer = math.floor(n.askAmount * reduction)
            n.state = "counter_offered"
            return true, n.counterOffer
        end
    end
    return false
end

-- ============================================================
-- PRISONER EXCHANGE
-- ============================================================
function Prisoner.proposeExchange(myPrisonerIds, theirPrisonerIds, targetFaction)
    -- Validate
    local myWeight = 0
    for _, pid in ipairs(myPrisonerIds) do
        local p = Prisoner.findPrisoner(pid)
        if not p or p.negotiationState ~= "available" then
            return false, "Ena od tvojih ponudb je neveljavna"
        end
        myWeight = myWeight + p.diplomaticWeight
    end
    local theirWeight = 0
    for _, pid in ipairs(theirPrisonerIds) do
        -- We don't have their prisoners, so we use class weight
        theirWeight = theirWeight + 5  -- assume soldier weight
    end
    -- Difference must be acceptable
    local diff = math.abs(myWeight - theirWeight)
    if diff > 5 then
        return false, "Neuravnotežena zamenjava (razlika: " .. diff .. ")"
    end
    local offer = {
        id = "exchange_" .. tostring(os.time()),
        myPrisonerIds = myPrisonerIds,
        theirPrisonerIds = theirPrisonerIds,
        faction = targetFaction,
        state = "proposed",
        round = 1,
    }
    table.insert(Prisoner.exchangeOffers, offer)
    -- 60% chance of acceptance if balanced
    if math.random() < 0.6 then
        offer.state = "accepted"
        Prisoner.executeExchange(offer)
    else
        offer.state = "rejected"
    end
    return true, offer.id
end

function Prisoner.executeExchange(offer)
    -- Release our prisoners (they go back)
    for _, pid in ipairs(offer.myPrisonerIds) do
        local p = Prisoner.findPrisoner(pid)
        if p then
            p.negotiationState = "exchanged"
            Prisoner.released = Prisoner.released + 1
        end
    end
    -- Diplomatic boost
    if _G.DiplomacyController and offer.faction then
        pcall(_G.DiplomacyController.changeRelation, offer.faction, 10)
    end
    Prisoner.reputationWithLords = math.min(100, Prisoner.reputationWithLords + 5)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zamenjava zapornikov uspešna!", "success")
    end
end

-- ============================================================
-- EXECUTION
-- ============================================================
function Prisoner.execute(prisonerId)
    local prisoner = Prisoner.findPrisoner(prisonerId)
    if not prisoner then return false, "Zapornik ne obstaja" end
    if prisoner.negotiationState ~= "available" then
        return false, "Zapornik ni na voljo"
    end
    prisoner.negotiationState = "executed"
    prisoner.executionDay = os.time()
    Prisoner.executions = Prisoner.executions + 1
    -- Major diplomatic hit
    if _G.DiplomacyController and prisoner.faction then
        pcall(_G.DiplomacyController.changeRelation, prisoner.faction, -prisoner.diplomaticWeight)
    end
    -- Reputation hit
    Prisoner.reputationWithLords = math.max(0, Prisoner.reputationWithLords - prisoner.diplomaticWeight)
    -- Happiness penalty
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.max(0, _G.state.happiness - 2)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Zapornik usmrčen: " .. prisoner.className .. " (ugled -" .. prisoner.diplomaticWeight .. ")", "danger")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "PRISONER_EXECUTED", {
            classId = prisoner.classId, faction = prisoner.faction,
        })
    end
    return true
end

-- ============================================================
-- RELEASE (MERCY)
-- ============================================================
function Prisoner.release(prisonerId)
    local prisoner = Prisoner.findPrisoner(prisonerId)
    if not prisoner then return false, "Zapornik ne obstaja" end
    if prisoner.negotiationState ~= "available" then
        return false, "Zapornik ni na voljo"
    end
    prisoner.negotiationState = "released"
    Prisoner.released = Prisoner.released + 1
    -- Diplomatic boost
    if _G.DiplomacyController and prisoner.faction then
        pcall(_G.DiplomacyController.changeRelation, prisoner.faction, prisoner.diplomaticWeight / 3)
    end
    Prisoner.reputationWithLords = math.min(100, Prisoner.reputationWithLords + 3)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Zapornik izpuščen: " .. prisoner.className, "info")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "PRISONER_RELEASED", {
            classId = prisoner.classId, faction = prisoner.faction,
        })
    end
    return true
end

-- ============================================================
-- MAINTENANCE & ESCAPE
-- ============================================================
function Prisoner.collectDailyMaintenance()
    local total = 0
    for _, p in ipairs(Prisoner.prisoners) do
        if p.negotiationState == "available" or p.negotiationState == "negotiating" then
            total = total + p.maintenancePerDay
        end
    end
    if total > 0 and _G.state then
        if (_G.state.gold or 0) >= total then
            _G.state.gold = _G.state.gold - total
        else
            -- Can't pay - increased escape chance
            for _, p in ipairs(Prisoner.prisoners) do
                if p.negotiationState == "available" then
                    p.escapeChance = p.escapeChance * 2
                end
            end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, "Premalo zlata za vzdrževanje zapornikov!", "warning")
            end
        end
    end
    return total
end

function Prisoner.rollEscapes()
    for _, p in ipairs(Prisoner.prisoners) do
        if p.negotiationState == "available" then
            if math.random() < (p.escapeChance or 0.01) then
                p.negotiationState = "escaped"
                p.escapeDay = os.time()
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        "Zapornik pobegnil: " .. p.className, "warning")
                end
                if _G.GameEventBus then
                    pcall(_G.GameEventBus.publish, "PRISONER_ESCAPED", {
                        classId = p.classId, faction = p.faction,
                    })
                end
            end
        end
    end
end

-- ============================================================
-- RANDOM RANSOM EVENTS
-- ============================================================
function Prisoner.rollRandomEvents()
    -- Family offers ransom
    if #Prisoner.prisoners > 0 and math.random() < 0.05 then
        local idx = math.random(#Prisoner.prisoners)
        local p = Prisoner.prisoners[idx]
        if p and p.negotiationState == "available" then
            local offer = math.floor(p.ransomValue * (0.6 + math.random() * 0.2))
            -- Auto-negotiation from family
            local nego = {
                id = "nego_family_" .. tostring(os.time()),
                prisonerId = p.id,
                askAmount = offer,
                originalAsk = offer,
                counterOffer = offer,  -- Family offers full
                round = 1,
                maxRounds = 1,
                faction = p.faction,
                state = "counter_offered",
                fromFamily = true,
                createdDay = os.time(),
            }
            table.insert(Prisoner.activeNegotiations, nego)
            p.negotiationState = "negotiating"
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("Družina ponuja %d zlata za %s", offer, p.className), "info")
            end
        end
    end
end

-- ============================================================
-- HELPER
-- ============================================================
function Prisoner.findPrisoner(prisonerId)
    for _, p in ipairs(Prisoner.prisoners) do
        if p.id == prisonerId then return p end
    end
    return nil
end

function Prisoner.getPrisoners()
    return Prisoner.prisoners
end

function Prisoner.getAvailablePrisoners()
    local list = {}
    for _, p in ipairs(Prisoner.prisoners) do
        if p.negotiationState == "available" then
            table.insert(list, p)
        end
    end
    return list
end

function Prisoner.getClassInfo(classId) return PRISONER_CLASSES[classId] end
function Prisoner.getBuildingInfo(buildingId) return PRISON_BUILDINGS[buildingId] end

function Prisoner.getStats()
    return {
        numPrisoners = #Prisoner.prisoners,
        capacity = Prisoner.getTotalCapacity(),
        executions = Prisoner.executions,
        released = Prisoner.released,
        ransomed = Prisoner.ransomed,
        totalRansomGold = Prisoner.totalRansomGold,
        reputationWithLords = Prisoner.reputationWithLords,
        activeNegotiations = #Prisoner.activeNegotiations,
        pendingExchanges = #Prisoner.exchangeOffers,
    }
end

-- ============================================================
-- UPDATE
-- ============================================================
function Prisoner.update(dt)
    if not _G.state then return end
    Prisoner.updateTimer = Prisoner.updateTimer + dt
    Prisoner.escapeTimer = Prisoner.escapeTimer + dt
    -- Daily tick
    if Prisoner.updateTimer >= 30 then
        Prisoner.updateTimer = 0
        Prisoner.collectDailyMaintenance()
        Prisoner.rollRandomEvents()
    end
    -- Escape check every 60 seconds
    if Prisoner.escapeTimer >= 60 then
        Prisoner.escapeTimer = 0
        Prisoner.rollEscapes()
    end
    -- Clean up finalized prisoners
    for i = #Prisoner.prisoners, 1, -1 do
        local p = Prisoner.prisoners[i]
        if p.negotiationState == "sold" or p.negotiationState == "executed" or
           p.negotiationState == "escaped" or p.negotiationState == "released" or
           p.negotiationState == "exchanged" then
            p.cleanupTimer = (p.cleanupTimer or 120) - dt
            if p.cleanupTimer <= 0 then
                table.remove(Prisoner.prisoners, i)
            end
        end
    end
    -- Clean up old negotiations
    for i = #Prisoner.activeNegotiations, 1, -1 do
        local n = Prisoner.activeNegotiations[i]
        if n.state == "accepted" or n.state == "rejected" then
            n.cleanupTimer = (n.cleanupTimer or 60) - dt
            if n.cleanupTimer <= 0 then
                table.remove(Prisoner.activeNegotiations, i)
            end
        end
    end
end

return Prisoner
