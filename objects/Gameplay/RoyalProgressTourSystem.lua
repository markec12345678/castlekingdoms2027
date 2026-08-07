-- objects/Gameplay/RoyalProgressTourSystem.lua
-- Castle Kingdoms 2027 v3.2.8 - Royal Progress & Tour System
--
-- Manages royal progresses — the king travels through provinces to display
-- power, hear petitions, and boost loyalty. Risky but rewarding.
--
-- Features:
-- - 6 destination types (capital, provinces, vassal lands, frontier, holy sites, foreign courts)
-- - Progress preparation (cost, entourage size, gifts)
-- - Travel mechanics (time, risk, events)
-- - Public appearances (boost loyalty and happiness)
-- - Petition hearing (random events with choices)
-- - Progress entourage (courtiers, guards, servants)
-- - Diplomatic progresses (visit foreign courts)
-- - Progress prestige

local Progress = {}

-- ============================================================
-- DESTINATION TYPES
-- ============================================================
local DESTINATIONS = {
    capital = {
        name = "Glavno mesto",
        nameEn = "Capital",
        travelDays = 1,
        cost = 200,
        loyaltyBonus = 5,
        happinessBonus = 3,
        risk = 0.02,
        description = "Kratek obisk glavnega mesta.",
    },
    province = {
        name = "Provinca",
        nameEn = "Province",
        travelDays = 5,
        cost = 500,
        loyaltyBonus = 15,
        happinessBonus = 8,
        risk = 0.05,
        description = "Obisk province za dvig lokalne lojalnosti.",
    },
    vassal = {
        name = "Vazalska dežela",
        nameEn = "Vassal Lands",
        travelDays = 7,
        cost = 800,
        loyaltyBonus = 20,
        happinessBonus = 10,
        risk = 0.08,
        description = "Obisk vazala, krepi odnose.",
    },
    frontier = {
        name = "Meja",
        nameEn = "Frontier",
        travelDays = 10,
        cost = 1200,
        loyaltyBonus = 25,
        happinessBonus = 5,
        risk = 0.15,
        description = "Obisk meje, dvigne moralo vojakov.",
    },
    holy_site = {
        name = "Sveto mesto",
        nameEn = "Holy Site",
        travelDays = 14,
        cost = 1500,
        loyaltyBonus = 10,
        happinessBonus = 20,
        faithBonus = 30,
        risk = 0.10,
        description = "Romanje k svetemu mestu.",
    },
    foreign_court = {
        name = "Tuj dvor",
        nameEn = "Foreign Court",
        travelDays = 21,
        cost = 3000,
        loyaltyBonus = 0,
        happinessBonus = 5,
        diplomaticBonus = 20,
        risk = 0.12,
        description = "Diplomatski obisk tujega dvora.",
    },
}

-- ============================================================
-- ENTOURAGE MEMBERS
-- ============================================================
local ENTOURAGE = {
    guards = { name = "Telesni stražarji", cost = 100, safetyBonus = 0.20, description = "Zaščita na poti." },
    courtiers = { name = "Dvorjani", cost = 200, prestigeBonus = 5, description = "Prikaz moči dvora." },
    servants = { name = "Služabniki", cost = 50, comfortBonus = 5, description = "Udobje na poti." },
    bard = { name = "Bard", cost = 150, happinessBonus = 3, description = "Zabava na poti." },
    cook = { name = "Kuhar", cost = 80, healthBonus = 5, description = "Dobra hrana." },
    priest = { name = "Duhovnik", cost = 100, faithBonus = 10, description = "Verska podpora." },
}

-- ============================================================
-- PETITION TYPES (random events during progress)
-- ============================================================
local PETITIONS = {
    land_dispute = {
        text = "Dva kmeta se prepirata o meji njiv. Kako odločaš?",
        options = {
            { text = "Razdeli po pol", effect = { happiness = 2, loyalty = -1 } },
            { text = "Dodeli starejšemu", effect = { happiness = -1, loyalty = 2 } },
            { text = "Zavrnitev", effect = { happiness = -3, loyalty = -2 } },
        },
    },
    tax_complaint = {
        text = "Kmetje prosijo za znižanje davkov.",
        options = {
            { text = "Ustvari znižanje", effect = { happiness = 5, gold = -200 } },
            { text = "Zavrni", effect = { happiness = -3, loyalty = -3 } },
            { text = "Odobri delno", effect = { happiness = 2, gold = -100 } },
        },
    },
    bandit_report = {
        text = "Prijavljeni razbojniki v gozdu.",
        options = {
            { text = "Pošlji vojake", effect = { happiness = 3, gold = -100 } },
            { text = "Ignoriraj", effect = { happiness = -2, loyalty = -2 } },
        },
    },
    miracle_claim = {
        text = "Lokalni vaščan trdi, da je videl čudež.",
        options = {
            { text = "Razglasi čudež", effect = { faith = 10, happiness = 3 } },
            { text = "Zavrni", effect = { faith = -5, happiness = -1 } },
        },
    },
    gift_offering = {
        text = "Vaščani ti ponujajo darila.",
        options = {
            { text = "Sprejmi z zahvalo", effect = { happiness = 3, gold = 50 } },
            { text = "Zavrni in daruj nazaj", effect = { happiness = 5, gold = -100 } },
        },
    },
}

-- ============================================================
-- STATE
-- ============================================================
Progress.activeProgress = nil            -- Current progress (only one at a time)
Progress.progressHistory = {}            -- Past progresses
Progress.totalProgresses = 0
Progress.progressPrestige = 0
Progress.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Progress.init()
    Progress.activeProgress = nil
    Progress.progressHistory = {}
    Progress.totalProgresses = 0
    Progress.progressPrestige = 0
    Progress.dayTimer = 0
    print("[Progress] Royal Progress & Tour System initialized (6 destinations, 6 entourage)")
end

-- ============================================================
-- STARTING A PROGRESS
-- ============================================================
function Progress.canStart(destinationId, entourageChoices)
    local def = DESTINATIONS[destinationId]
    if not def then return false, "Neznan cilj" end
    if Progress.activeProgress then
        return false, "Že na poti"
    end
    -- Calculate total cost
    local totalCost = def.cost
    for _, choice in ipairs(entourageChoices or {}) do
        local e = ENTOURAGE[choice]
        if e then totalCost = totalCost + e.cost end
    end
    if not _G.state or (_G.state.gold or 0) < totalCost then
        return false, "Premalo zlata"
    end
    return true, totalCost
end

function Progress.start(destinationId, entourageChoices)
    local ok, result = Progress.canStart(destinationId, entourageChoices)
    if not ok then return false, result end
    local totalCost = result
    local def = DESTINATIONS[destinationId]
    -- Pay cost
    _G.state.gold = _G.state.gold - totalCost
    -- Calculate bonuses
    local safetyBonus = 0
    local prestigeBonus = 0
    local comfortBonus = 0
    local happinessBonus = 0
    local healthBonus = 0
    local faithBonus = 0
    local entourageList = {}
    for _, choice in ipairs(entourageChoices or {}) do
        local e = ENTOURAGE[choice]
        if e then
            table.insert(entourageList, e.name)
            if e.safetyBonus then safetyBonus = safetyBonus + e.safetyBonus end
            if e.prestigeBonus then prestigeBonus = prestigeBonus + e.prestigeBonus end
            if e.comfortBonus then comfortBonus = comfortBonus + e.comfortBonus end
            if e.happinessBonus then happinessBonus = happinessBonus + e.happinessBonus end
            if e.healthBonus then healthBonus = healthBonus + e.healthBonus end
            if e.faithBonus then faithBonus = faithBonus + e.faithBonus end
        end
    end
    Progress.activeProgress = {
        id = "progress_" .. tostring(os.time()),
        destination = destinationId,
        destinationName = def.name,
        daysRemaining = def.travelDays,
        totalDays = def.travelDays,
        risk = math.max(0.01, def.risk - safetyBonus),
        loyaltyBonus = def.loyaltyBonus,
        happinessBonus = def.happinessBonus + happinessBonus,
        faithBonus = (def.faithBonus or 0) + faithBonus,
        diplomaticBonus = def.diplomaticBonus or 0,
        prestigeBonus = prestigeBonus,
        healthBonus = healthBonus,
        comfortBonus = comfortBonus,
        entourage = entourageList,
        petitions = {},
        started = os.time(),
    }
    Progress.totalProgresses = Progress.totalProgresses + 1
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Kraljeva potovanje začeto: %s (%d dni)",
                def.name, def.travelDays), "important")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "ROYAL_PROGRESS_STARTED", { destination = destinationId })
    end
    return true
end

-- ============================================================
-- PROGRESS SIMULATION
-- ============================================================
function Progress.simulateDay()
    if not Progress.activeProgress then return end
    local p = Progress.activeProgress
    -- Random petition chance (20% per day)
    if math.random() < 0.20 then
        Progress.triggerPetition()
    end
    -- Random incident chance
    if math.random() < p.risk then
        Progress.triggerIncident()
    end
end

function Progress.triggerPetition()
    local p = Progress.activeProgress
    if not p then return end
    local petitionKeys = {}
    for k, _ in pairs(PETITIONS) do
        table.insert(petitionKeys, k)
    end
    local petition = PETITIONS[petitionKeys[math.random(#petitionKeys)]]
    -- Auto-resolve with random option (in real game, player would choose)
    local option = petition.options[math.random(#petition.options)]
    -- Apply effects
    local eff = option.effect or {}
    if eff.happiness and _G.state and _G.state.happiness then
        _G.state.happiness = math.max(0, math.min(100, _G.state.happiness + eff.happiness))
    end
    if eff.loyalty then
        -- Affect general loyalty (via happiness proxy)
        if _G.state and _G.state.happiness then
            _G.state.happiness = math.max(0, _G.state.happiness + eff.loyalty * 0.5)
        end
    end
    if eff.gold and _G.state then
        _G.state.gold = math.max(0, (_G.state.gold or 0) + eff.gold)
    end
    if eff.faith and _G.Religion then
        pcall(_G.Religion.addFaith, eff.faith)
    end
    table.insert(p.petitions, {
        text = petition.text,
        choice = option.text,
        effect = eff,
    })
end

function Progress.triggerIncident()
    local p = Progress.activeProgress
    if not p then return end
    local incidents = {
        { text = "Kolo se je zlomilo", effect = { daysAdded = 1 } },
        { text = "Nevihta na poti", effect = { daysAdded = 2, health = -2 } },
        { text = "Razbojniki napadli!", effect = { gold = -200, safetyIssue = true } },
        { text = "Bolezen v spremstvu", effect = { health = -5 } },
        { text = "Most je bil podrli", effect = { daysAdded = 1 } },
    }
    local incident = incidents[math.random(#incidents)]
    local eff = incident.effect
    if eff.daysAdded then
        p.daysRemaining = p.daysRemaining + eff.daysAdded
    end
    if eff.gold and _G.state then
        _G.state.gold = math.max(0, (_G.state.gold or 0) + eff.gold)
    end
    if eff.health and _G.state and _G.state.happiness then
        _G.state.happiness = math.max(0, _G.state.happiness + eff.health)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, " Incident: " .. incident.text, "warning")
    end
end

function Progress.completeProgress()
    local p = Progress.activeProgress
    if not p then return end
    -- Apply bonuses
    if p.loyaltyBonus > 0 and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + p.loyaltyBonus)
    end
    if p.happinessBonus > 0 and _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + p.happinessBonus)
    end
    if p.faithBonus > 0 and _G.Religion then
        pcall(_G.Religion.addFaith, p.faithBonus)
    end
    if p.diplomaticBonus > 0 and _G.DiplomacyController then
        -- Generic boost to all factions
        pcall(_G.DiplomacyController.changeRelation, "all", p.diplomaticBonus)
    end
    Progress.progressPrestige = Progress.progressPrestige + p.prestigeBonus + 5
    -- Add to history
    table.insert(Progress.progressHistory, {
        destination = p.destinationName,
        days = p.totalDays,
        petitions = #p.petitions,
        completedDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Kraljevo potovanje končano: %s (+%d prestiža, %d peticij)",
                p.destinationName, p.prestigeBonus + 5, #p.petitions), "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "ROYAL_PROGRESS_COMPLETED", {
            destination = p.destination, prestige = p.prestigeBonus,
        })
    end
    Progress.activeProgress = nil
end

-- ============================================================
-- UPDATE
-- ============================================================
function Progress.update(dt)
    if not _G.state then return end
    Progress.dayTimer = Progress.dayTimer + dt
    if Progress.dayTimer >= 30 then
        Progress.dayTimer = 0
        if Progress.activeProgress then
            Progress.activeProgress.daysRemaining = Progress.activeProgress.daysRemaining - 1
            Progress.simulateDay()
            if Progress.activeProgress.daysRemaining <= 0 then
                Progress.completeProgress()
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Progress.getDestinationInfo(id) return DESTINATIONS[id] end
function Progress.getEntourageInfo(id) return ENTOURAGE[id] end
function Progress.getPetitions() return PETITIONS end

function Progress.getStats()
    return {
        activeProgress = Progress.activeProgress ~= nil,
        currentDestination = Progress.activeProgress and Progress.activeProgress.destinationName or "—",
        daysRemaining = Progress.activeProgress and Progress.activeProgress.daysRemaining or 0,
        totalProgresses = Progress.totalProgresses,
        progressPrestige = Progress.progressPrestige,
        historyCount = #Progress.progressHistory,
    }
end

return Progress
