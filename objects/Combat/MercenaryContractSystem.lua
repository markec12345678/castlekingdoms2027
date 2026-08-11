-- objects/Combat/MercenaryContractSystem.lua
-- Castle Kingdoms 2027 v3.1.0 - Mercenary Contract System
--
-- Manages hiring of mercenary companies: contract negotiation, reputation,
-- duration-based employment, and betrayal/defection mechanics.
--
-- Features:
-- - 8 mercenary company types (Hired Swords, Crossbowmen, Pikemen, Cavalry,
--   Siege Engineers, Sappers, Scouts, Bodyguards)
-- - Contract negotiation (price, duration, exclusivity, performance bonuses)
-- - Reputation per company (affects price and reliability)
-- - Betrayal/defection mechanics (low reputation = chance of betrayal)
-- - Performance bonuses (kill-based rewards)
-- - Contract renewal with discounts
-- - Rival lord bidding wars

local Mercenary = {}

-- ============================================================
-- MERCENARY COMPANY DEFINITIONS
-- ============================================================
local COMPANIES = {
    hired_swords = {
        name = "Najemniški mečevci",
        nameEn = "Hired Swords",
        commander = "Stari veteran Henrik",
        origin = "Flandrija",
        color = { 0.6, 0.4, 0.3 },
        baseCost = 200,           -- gold per day
        baseDuration = 30,       -- days
        unitCount = 20,
        unitType = "swordsman",
        strength = 65,
        speed = 1.0,
        description = "Splošno pehotno najemniško podjetje, zanesljivo in poceni.",
        reliability = 0.85,
        specialties = { "frontline", "garrison" },
    },
    crossbowmen = {
        name = "Samostrelci iz Genove",
        nameEn = "Genoese Crossbowmen",
        commander = "Kapitan Marco",
        origin = "Genova",
        color = { 0.3, 0.4, 0.6 },
        baseCost = 350,
        baseDuration = 30,
        unitCount = 15,
        unitType = "crossbowman",
        strength = 50,
        speed = 0.9,
        description = "Profesionalni samostrelci, smrtonosni na daljavo.",
        reliability = 0.90,
        specialties = { "ranged", "siege_defense" },
    },
    pikemen = {
        name = "Švicarski kopjaši",
        nameEn = "Swiss Pikemen",
        commander = "Starešina Ulrich",
        origin = "Švica",
        color = { 0.4, 0.5, 0.4 },
        baseCost = 400,
        baseDuration = 45,
        unitCount = 25,
        unitType = "pikeman",
        strength = 70,
        speed = 0.8,
        description = "Legendarna pehota s kopji, neprimorna za konjenico.",
        reliability = 0.95,
        specialties = { "anti_cavalry", "formation" },
    },
    cavalry = {
        name = "Težka konjenica",
        nameEn = "Heavy Cavalry",
        commander = "Vitez Rudolf",
        origin = "Burgundija",
        color = { 0.5, 0.3, 0.5 },
        baseCost = 600,
        baseDuration = 30,
        unitCount = 12,
        unitType = "knight",
        strength = 90,
        speed = 1.6,
        description = "Težko oklepljeni vitezi na konjih, drage a smrtonosne enote.",
        reliability = 0.80,
        specialties = { "shock", "flanking" },
    },
    siege_engineers = {
        name = "Inženirji oblegovalcev",
        nameEn = "Siege Engineers",
        commander = "Mojster Leonardo",
        origin = "Italija",
        color = { 0.5, 0.5, 0.3 },
        baseCost = 500,
        baseDuration = 60,
        unitCount = 8,
        unitType = "siege_engineer",
        strength = 30,
        speed = 0.6,
        description = "Strokovnjaki za oblegovalne stroje in miniranje zidov.",
        reliability = 0.92,
        specialties = { "siege_offense", "construction" },
    },
    sappers = {
        name = "Saparji",
        nameEn = "Sappers",
        commander = "Stari miner Jaka",
        origin = "Slovenija",
        color = { 0.3, 0.3, 0.3 },
        baseCost = 300,
        baseDuration = 30,
        unitCount = 10,
        unitType = "sapper",
        strength = 25,
        speed = 1.1,
        description = "Specialisti za podkopavanje in rušenje zidov.",
        reliability = 0.88,
        specialties = { "siege_offense", "demolition" },
    },
    scouts = {
        name = "Vreli izvidniki",
        nameEn = "Fleet Scouts",
        commander = "Lovra Sokoje",
        origin = "Madžarska",
        color = { 0.6, 0.5, 0.2 },
        baseCost = 150,
        baseDuration = 20,
        unitCount = 8,
        unitType = "scout",
        strength = 25,
        speed = 2.0,
        description = "Hitri konjeni izvidniki za razvedrilne misije.",
        reliability = 0.75,
        specialties = { "recon", "skirmish" },
    },
    bodyguards = {
        name = "Osebni stražarji",
        nameEn = "Personal Bodyguards",
        commander = "Verni Gorazd",
        origin = "Bavarska",
        color = { 0.4, 0.4, 0.6 },
        baseCost = 800,
        baseDuration = 90,
        unitCount = 6,
        unitType = "elite_guard",
        strength = 100,
        speed = 1.0,
        description = "Elitna garda za zaščito vladarja in plemičev.",
        reliability = 0.99,
        specialties = { "vip_protection", "elite" },
    },
}

-- ============================================================
-- CONTRACT TERMS
-- ============================================================
local CONTRACT_TERMS = {
    short = { days = 14, multiplier = 1.2 },  -- premium for short
    standard = { days = 30, multiplier = 1.0 },
    extended = { days = 90, multiplier = 0.85 },  -- discount for long
    permanent = { days = 365, multiplier = 0.70 },  -- big discount
}

-- ============================================================
-- STATE
-- ============================================================
Mercenary.activeContracts = {}    -- Currently hired mercenaries
Mercenary.reputation = {}         -- Per-company reputation (0-100)
Mercenary.totalHired = 0          -- Total mercenaries hired ever
Mercenary.totalBetrayed = 0       -- Total betrayals
Mercenary.killsThisContract = {}  -- Per-contract kill counter
Mercenary.contractHistory = {}    -- Past contracts log
Mercenary.rivalBidders = {}       -- Active rival lords bidding
Mercenary.updateTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Mercenary.init()
    Mercenary.activeContracts = {}
    Mercenary.reputation = {}
    Mercenary.totalHired = 0
    Mercenary.totalBetrayed = 0
    Mercenary.killsThisContract = {}
    Mercenary.contractHistory = {}
    Mercenary.rivalBidders = {}
    Mercenary.updateTimer = 0
    -- Initialize reputation to 50 (neutral) for all companies
    for id, _ in pairs(COMPANIES) do
        Mercenary.reputation[id] = 50
    end
    print("[Mercenary] Mercenary Contract System initialized (8 companies)")
end

-- ============================================================
-- CONTRACT COST CALCULATION
-- ============================================================
function Mercenary.calculateCost(companyId, termId, options)
    local def = COMPANIES[companyId]
    if not def then return 0 end
    local term = CONTRACT_TERMS[termId] or CONTRACT_TERMS.standard
    options = options or {}
    -- Base cost
    local cost = def.baseCost * term.days * term.multiplier
    -- Exclusivity premium (+50%)
    if options.exclusive then cost = cost * 1.5 end
    -- Performance bonus clause (+30% up-front, gives kill bonus)
    if options.performanceBonus then cost = cost * 1.3 end
    -- Reputation discount (up to -25% at 100 rep)
    local rep = Mercenary.reputation[companyId] or 50
    local repDiscount = 1 - (rep / 100) * 0.25
    cost = cost * repDiscount
    -- Rival bidding war (drives up price)
    if options.rivalBid then
        cost = cost * (1 + options.rivalBid * 0.10)
    end
    return math.floor(cost)
end

function Mercenary.calculateDailyUpkeep(companyId)
    local def = COMPANIES[companyId]
    if not def then return 0 end
    return def.baseCost
end

-- ============================================================
-- HIRING
-- ============================================================
function Mercenary.canHire(companyId, termId, options)
    local def = COMPANIES[companyId]
    if not def then return false, "Neznan podvig" end
    -- Check if already hired
    for _, c in ipairs(Mercenary.activeContracts) do
        if c.companyId == companyId then
            return false, "Podvig že najet"
        end
    end
    -- Check gold
    if not _G.state then return false, "Brez stanja" end
    local cost = Mercenary.calculateCost(companyId, termId, options)
    if (_G.state.gold or 0) < cost then
        return false, string.format("Premalo zlata (potrebnih %d)", cost)
    end
    -- Check reputation floor
    local rep = Mercenary.reputation[companyId] or 50
    if rep < 10 then
        return false, "Podvig noče delati s tabo (premajhen ugled)"
    end
    return true, cost
end

function Mercenary.hire(companyId, termId, options)
    options = options or {}
    local ok, result = Mercenary.canHire(companyId, termId, options)
    if not ok then return false, result end
    local cost = result
    local def = COMPANIES[companyId]
    local term = CONTRACT_TERMS[termId] or CONTRACT_TERMS.standard
    -- Deduct gold
    _G.state.gold = (_G.state.gold or 0) - cost
    -- Create contract
    local contract = {
        id = "mercenaries_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        companyId = companyId,
        companyName = def.name,
        commander = def.commander,
        termId = termId,
        daysRemaining = term.days,
        totalDays = term.days,
        unitCount = def.unitCount,
        unitType = def.unitType,
        strength = def.strength,
        speed = def.speed,
        exclusive = options.exclusive or false,
        performanceBonus = options.performanceBonus or false,
        dailyUpkeep = def.baseCost,
        totalCost = cost,
        kills = 0,
        losses = 0,
        betrayChance = (1 - def.reliability) * (1 - (Mercenary.reputation[companyId] or 50) / 100),
        active = true,
    }
    table.insert(Mercenary.activeContracts, contract)
    Mercenary.totalHired = Mercenary.totalHired + 1
    -- Boost reputation slightly for hiring
    Mercenary.reputation[companyId] = math.min(100, (Mercenary.reputation[companyId] or 50) + 2)
    -- Spawn units if CombatIntegration exists
    if _G.CombatIntegration and _G.CombatIntegration.spawnUnit then
        for i = 1, def.unitCount do
            pcall(_G.CombatIntegration.spawnUnit, def.unitType, 500 + i * 5, 500)
        end
    end
    -- Notify
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Najeti: " .. def.name .. " (" .. def.unitCount .. " enot)", "success")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "MERCENARY_HIRED", {
            companyId = companyId, unitCount = def.unitCount, days = term.days,
        })
    end
    return true, contract.id
end

-- ============================================================
-- CONTRACT MANAGEMENT
-- ============================================================
function Mercenary.cancelContract(contractId)
    for _, c in ipairs(Mercenary.activeContracts) do
        if c.id == contractId and c.active then
            c.active = false
            c.cancelled = true
            -- Reputation penalty for early cancellation
            Mercenary.reputation[c.companyId] = math.max(0,
                (Mercenary.reputation[c.companyId] or 50) - 10)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, "Najemniška pogodba preklicana: " .. c.companyName, "warning")
            end
            return true
        end
    end
    return false
end

function Mercenary.renewContract(contractId, additionalDays)
    for _, c in ipairs(Mercenary.activeContracts) do
        if c.id == contractId and c.active then
            -- Renewal gives 15% discount
            local def = COMPANIES[c.companyId]
            local cost = def.baseCost * additionalDays * 0.85
            if _G.state and (_G.state.gold or 0) >= cost then
                _G.state.gold = _G.state.gold - cost
                c.daysRemaining = c.daysRemaining + additionalDays
                c.totalDays = c.totalDays + additionalDays
                Mercenary.reputation[c.companyId] = math.min(100,
                    (Mercenary.reputation[c.companyId] or 50) + 3)
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        "Pogodba podaljšana za " .. additionalDays .. " dni", "info")
                end
                return true
            end
            return false, "Premalo zlata za podaljšanje"
        end
    end
    return false, "Pogodba ne obstaja"
end

function Mercenary.recordKill(contractId, count)
    count = count or 1
    for _, c in ipairs(Mercenary.activeContracts) do
        if c.id == contractId and c.active then
            c.kills = c.kills + count
            -- Performance bonus payout
            if c.performanceBonus and _G.state then
                local bonus = count * 5  -- 5 gold per kill
                _G.state.gold = (_G.state.gold or 0) + bonus
            end
            return true
        end
    end
    return false
end

function Mercenary.recordLoss(contractId, count)
    count = count or 1
    for _, c in ipairs(Mercenary.activeContracts) do
        if c.id == contractId and c.active then
            c.losses = c.losses + count
            c.unitCount = math.max(0, c.unitCount - count)
            return true
        end
    end
    return false
end

-- ============================================================
-- BETRAYAL MECHANICS
-- ============================================================
function Mercenary.rollBetrayal()
    for _, c in ipairs(Mercenary.activeContracts) do
        if c.active and c.daysRemaining > 0 then
            -- Daily betrayal chance
            local chance = c.betrayChance * 0.005  -- 0.5% of base chance per day
            -- Increase if not paid (low gold)
            if _G.state and (_G.state.gold or 0) < c.dailyUpkeep then
                chance = chance * 3
            end
            -- Increase if taking heavy losses
            if c.losses > c.unitCount * 0.5 then
                chance = chance * 2
            end
            if math.random() < chance then
                Mercenary.triggerBetrayal(c)
            end
        end
    end
end

function Mercenary.triggerBetrayal(contract)
    contract.active = false
    contract.betrayed = true
    Mercenary.totalBetrayed = Mercenary.totalBetrayed + 1
    -- Major reputation hit
    Mercenary.reputation[contract.companyId] = math.max(0,
        (Mercenary.reputation[contract.companyId] or 50) - 30)
    -- Convert mercenary units to enemy
    if _G.CombatIntegration and _G.CombatIntegration.spawnEnemyUnit then
        for i = 1, contract.unitCount do
            pcall(_G.CombatIntegration.spawnEnemyUnit, contract.unitType, 500 + i * 5, 500)
        end
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "IZDAJA! " .. contract.companyName .. " so prestopili k nasprotniku!", "danger")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "MERCENARY_BETRAYED", {
            companyId = contract.companyId, unitCount = contract.unitCount,
        })
    end
end

-- ============================================================
-- DAILY UPKEEP
-- ============================================================
function Mercenary.collectDailyUpkeep()
    local totalUpkeep = 0
    for _, c in ipairs(Mercenary.activeContracts) do
        if c.active then
            totalUpkeep = totalUpkeep + c.dailyUpkeep
        end
    end
    if totalUpkeep > 0 and _G.state then
        if (_G.state.gold or 0) >= totalUpkeep then
            _G.state.gold = _G.state.gold - totalUpkeep
        else
            -- Not enough gold - reputation hit
            for _, c in ipairs(Mercenary.activeContracts) do
                if c.active then
                    Mercenary.reputation[c.companyId] = math.max(0,
                        (Mercenary.reputation[c.companyId] or 50) - 5)
                end
            end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify,
                    string.format("Premalo zlata za najemniške plače! (%d)", totalUpkeep), "warning")
            end
        end
    end
    return totalUpkeep
end

-- ============================================================
-- RIVAL LORD BIDDING WARS
-- ============================================================
function Mercenary.startBiddingWar(companyId)
    local numRivals = math.random(1, 3)
    Mercenary.rivalBidders[companyId] = numRivals
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Aukcija za %s! %d nasprotnikov ponuja", COMPANIES[companyId].name, numRivals),
            "warning")
    end
end

function Mercenary.outbidRivals(companyId, extraGold)
    if not Mercenary.rivalBidders[companyId] then return false, "Ni aktivne aukcije" end
    if _G.state and (_G.state.gold or 0) >= extraGold then
        _G.state.gold = _G.state.gold - extraGold
        Mercenary.rivalBidders[companyId] = Mercenary.rivalBidders[companyId] - 1
        if Mercenary.rivalBidders[companyId] <= 0 then
            Mercenary.rivalBidders[companyId] = nil
            Mercenary.reputation[companyId] = math.min(100,
                (Mercenary.reputation[companyId] or 50) + 5)
        end
        return true
    end
    return false, "Premalo zlata"
end

-- ============================================================
-- CONTRACT COMPLETION
-- ============================================================
function Mercenary.completeContract(contract)
    contract.active = false
    contract.completed = true
    -- Performance-based reputation change
    local rep = Mercenary.reputation[contract.companyId] or 50
    if contract.losses < contract.unitCount * 0.2 then
        -- Minimal losses - good reputation
        rep = math.min(100, rep + 8)
    elseif contract.losses > contract.unitCount * 0.7 then
        -- Heavy losses - poor reputation
        rep = math.max(0, rep - 5)
    else
        rep = math.min(100, rep + 3)
    end
    Mercenary.reputation[contract.companyId] = rep
    -- Add to history
    table.insert(Mercenary.contractHistory, {
        companyId = contract.companyId,
        days = contract.totalDays,
        kills = contract.kills,
        losses = contract.losses,
        completed = true,
    })
    -- Notify
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Najemniška pogodba zaključena: " .. contract.companyName, "info")
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Mercenary.update(dt)
    if not _G.state then return end
    Mercenary.updateTimer = Mercenary.updateTimer + dt
    -- Daily tick (every 30 seconds real time)
    if Mercenary.updateTimer >= 30 then
        Mercenary.updateTimer = 0
        -- Daily upkeep
        Mercenary.collectDailyUpkeep()
        -- Decrement contract days
        for _, c in ipairs(Mercenary.activeContracts) do
            if c.active then
                c.daysRemaining = c.daysRemaining - 1
                if c.daysRemaining <= 0 then
                    Mercenary.completeContract(c)
                end
            end
        end
        -- Roll for betrayal
        Mercenary.rollBetrayal()
        -- Random rival bidding war
        if math.random() < 0.01 then
            local companies = {}
            for id, _ in pairs(COMPANIES) do
                table.insert(companies, id)
            end
            Mercenary.startBiddingWar(companies[math.random(#companies)])
        end
    end
    -- Clean up old contracts
    for i = #Mercenary.activeContracts, 1, -1 do
        local c = Mercenary.activeContracts[i]
        if not c.active then
            c.cleanupTimer = (c.cleanupTimer or 60) - dt
            if c.cleanupTimer <= 0 then
                table.remove(Mercenary.activeContracts, i)
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Mercenary.getCompanyInfo(companyId) return COMPANIES[companyId] end
function Mercenary.getTermInfo(termId) return CONTRACT_TERMS[termId] end

function Mercenary.listAvailable()
    local list = {}
    for id, def in pairs(COMPANIES) do
        local hired = false
        for _, c in ipairs(Mercenary.activeContracts) do
            if c.companyId == id and c.active then hired = true; break end
        end
        if not hired then
            table.insert(list, {
                id = id, name = def.name, commander = def.commander,
                baseCost = def.baseCost, unitCount = def.unitCount,
                reputation = Mercenary.reputation[id] or 50,
                reliability = def.reliability,
            })
        end
    end
    return list
end

function Mercenary.getStats()
    return {
        totalHired = Mercenary.totalHired,
        totalBetrayed = Mercenary.totalBetrayed,
        activeCount = #Mercenary.activeContracts,
        reputation = Mercenary.reputation,
        historyCount = #Mercenary.contractHistory,
    }
end

function Mercenary.getActiveMercenaryBonuses()
    -- Returns combat bonuses from active mercenaries
    local bonuses = {
        attackBonus = 1.0,
        defenseBonus = 1.0,
        speedBonus = 1.0,
        rangedBonus = 1.0,
        siegeBonus = 1.0,
    }
    for _, c in ipairs(Mercenary.activeContracts) do
        if c.active then
            local def = COMPANIES[c.companyId]
            if def then
                if def.specialties then
                    for _, spec in ipairs(def.specialties) do
                        if spec == "frontline" then bonuses.attackBonus = bonuses.attackBonus * 1.05 end
                        if spec == "ranged" then bonuses.rangedBonus = bonuses.rangedBonus * 1.10 end
                        if spec == "anti_cavalry" then bonuses.defenseBonus = bonuses.defenseBonus * 1.08 end
                        if spec == "shock" then bonuses.attackBonus = bonuses.attackBonus * 1.12 end
                        if spec == "siege_offense" then bonuses.siegeBonus = bonuses.siegeBonus * 1.20 end
                        if spec == "elite" then
                            bonuses.attackBonus = bonuses.attackBonus * 1.15
                            bonuses.defenseBonus = bonuses.defenseBonus * 1.15
                        end
                    end
                end
            end
        end
    end
    return bonuses
end

return Mercenary
