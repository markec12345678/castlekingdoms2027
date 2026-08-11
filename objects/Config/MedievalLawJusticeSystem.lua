-- objects/Config/MedievalLawJusticeSystem.lua
-- Castle Kingdoms 2027 v3.2.9 - Medieval Law & Justice System
--
-- Manages trials, punishments, judges, and the legal system.
-- Affects happiness, loyalty, and crime rates.
--
-- Features:
-- - 8 crime types (theft, murder, treason, heresy, smuggling, assault, fraud, witchcraft)
-- - 6 punishment types (fine, stocks, whipping, imprisonment, exile, execution)
-- - Trial system (judge, jury, evidence)
-- - Judge NPC (skill affects outcomes)
-- - Court buildings (courthouse, dungeon)
-- - Crime rate (affected by happiness and enforcement)
-- - Trial outcomes (guilty, innocent, mistrial)
-- - Public opinion (affects happiness based on perceived justice)

local Justice = {}

-- ============================================================
-- CRIME TYPES
-- ============================================================
local CRIMES = {
    theft = {
        name = "Kraja",
        nameEn = "Theft",
        severity = 2,
        baseFine = 50,
        commonness = 0.40,
        description = "Kraja tuje lastnine.",
    },
    murder = {
        name = "Umor",
        nameEn = "Murder",
        severity = 8,
        baseFine = 500,
        commonness = 0.05,
        description = "Ubijanje človeka.",
    },
    treason = {
        name = "Izdaja",
        nameEn = "Treason",
        severity = 10,
        baseFine = 0,
        commonness = 0.02,
        description = "Izdaja kralja ali dežele.",
    },
    heresy = {
        name = "Herezija",
        nameEn = "Heresy",
        severity = 7,
        baseFine = 200,
        commonness = 0.08,
        description = "Verska odklonitev.",
    },
    smuggling = {
        name = "Tihotapljenje",
        nameEn = "Smuggling",
        severity = 4,
        baseFine = 150,
        commonness = 0.15,
        description = "Nelegalna trgovina.",
    },
    assault = {
        name = "Napad",
        nameEn = "Assault",
        severity = 3,
        baseFine = 80,
        commonness = 0.20,
        description = "Fizični napad na osebo.",
    },
    fraud = {
        name = "Goljufija",
        nameEn = "Fraud",
        severity = 3,
        baseFine = 100,
        commonness = 0.08,
        description = "Prevare in lažna zastopanja.",
    },
    witchcraft = {
        name = "Čarovništvo",
        nameEn = "Witchcraft",
        severity = 9,
        baseFine = 0,
        commonness = 0.02,
        description = "Obtožba čarovništva (pogosto napačna).",
    },
}

-- ============================================================
-- PUNISHMENT TYPES
-- ============================================================
local PUNISHMENTS = {
    fine = {
        name = "Globa",
        nameEn = "Fine",
        severityRequired = 1,
        happinessEffect = 1,  -- seen as fair
        description = "Denarna kazen.",
    },
    stocks = {
        name = "Stebra sramote",
        nameEn = "Stocks",
        severityRequired = 2,
        happinessEffect = 2,
        description = "Javno ponižanje v stebrih.",
    },
    whipping = {
        name = "Bičanje",
        nameEn = "Whipping",
        severityRequired = 4,
        happinessEffect = 0,
        description = "Fizično kaznovanje.",
    },
    imprisonment = {
        name = "Zapor",
        nameEn = "Imprisonment",
        severityRequired = 5,
        happinessEffect = 3,
        description = "Kaznovanje z zapiranjem.",
    },
    exile = {
        name = "Izgon",
        nameEn = "Exile",
        severityRequired = 6,
        happinessEffect = 1,
        description = "Pošiljanje v izgnanstvo.",
    },
    execution = {
        name = "Usmrtitev",
        nameEn = "Execution",
        severityRequired = 8,
        happinessEffect = -2,  -- seen as harsh
        description = "Smrtna kazen.",
    },
}

-- ============================================================
-- COURT BUILDINGS
-- ============================================================
local COURT_BUILDINGS = {
    village_court = {
        name = "Vaško sodišče",
        cost = { gold = 200, wood = 100 },
        upkeep = 5,
        trialCapacity = 1,
        justiceBonus = 2,
        description = "Preprosto sodišče za manjše zadeve.",
    },
    town_court = {
        name = "Mestno sodišče",
        cost = { gold = 800, wood = 200, stone = 200 },
        upkeep = 20,
        trialCapacity = 3,
        justiceBonus = 5,
        description = "Stalno mestno sodišče.",
    },
    royal_court = {
        name = "Kraljevo sodišče",
        cost = { gold = 2500, wood = 300, stone = 600 },
        upkeep = 60,
        trialCapacity = 5,
        justiceBonus = 10,
        description = "Visoko sodišče za hujše zadeve.",
    },
    supreme_court = {
        name = "Vrhovno sodišče",
        cost = { gold = 6000, wood = 500, stone = 1500 },
        upkeep = 120,
        trialCapacity = 10,
        justiceBonus = 20,
        description = "Najvišje sodišče v deželi.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Justice.pendingCases = {}              -- Cases awaiting trial
Justice.completedCases = {}            -- Resolved cases
Justice.judges = {}                    -- Hired judges
Justice.courtBuildings = {}            -- Built courts
Justice.crimeRate = 20                 -- 0-100, base crime level
Justice.justiceReputation = 50         -- 0-100, perceived fairness
Justice.totalCases = 0
Justice.totalExecutions = 0
Justice.totalAcquittals = 0
Justice.finesCollected = 0
Justice.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Justice.init()
    Justice.pendingCases = {}
    Justice.completedCases = {}
    Justice.judges = {}
    Justice.courtBuildings = {}
    Justice.crimeRate = 20
    Justice.justiceReputation = 50
    Justice.totalCases = 0
    Justice.totalExecutions = 0
    Justice.totalAcquittals = 0
    Justice.finesCollected = 0
    Justice.dayTimer = 0
    print("[Justice] Medieval Law & Justice System initialized (8 crimes, 6 punishments)")
end

-- ============================================================
-- COURT CONSTRUCTION
-- ============================================================
function Justice.canBuild(buildingId)
    local def = COURT_BUILDINGS[buildingId]
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

function Justice.build(buildingId)
    local ok, err = Justice.canBuild(buildingId)
    if not ok then return false, err end
    local def = COURT_BUILDINGS[buildingId]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Justice.courtBuildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Justice.getTotalTrialCapacity()
    local cap = 1
    for _, b in ipairs(Justice.courtBuildings) do
        local def = COURT_BUILDINGS[b.type]
        if def and def.trialCapacity then cap = cap + def.trialCapacity end
    end
    return cap
end

function Justice.getJusticeBonus()
    local bonus = 0
    for _, b in ipairs(Justice.courtBuildings) do
        local def = COURT_BUILDINGS[b.type]
        if def and def.justiceBonus then bonus = bonus + def.justiceBonus end
    end
    return bonus
end

-- ============================================================
-- JUDGES
-- ============================================================
function Justice.hireJudge(name, skill)
    skill = skill or math.random(40, 90)
    local cost = 300 + skill * 5
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    local judge = {
        id = "judge_" .. tostring(os.time()),
        name = name or ("Sodnik " .. math.random(1, 99)),
        skill = skill,
        integrity = math.random(50, 100),
        casesTried = 0,
        hiredDay = os.time(),
    }
    table.insert(Justice.judges, judge)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Sodnik najet: %s (spretnost: %d)", judge.name, skill), "success")
    end
    return true
end

function Justice.getBestJudge()
    local best = nil
    for _, j in ipairs(Justice.judges) do
        if not best or j.skill > best.skill then best = j end
    end
    return best
end

-- ============================================================
-- CRIME GENERATION
-- ============================================================
function Justice.generateCrimes()
    -- Crime rate affected by happiness and enforcement
    local happiness = (_G.state and _G.state.happiness) or 50
    local crimeModifier = (50 - happiness) / 50  -- lower happiness = more crime
    local numCrimes = math.floor(Justice.crimeRate * crimeModifier * 0.1)
    for _ = 1, numCrimes do
        -- Pick crime type based on commonness
        local roll = math.random()
        local cumulative = 0
        local selectedCrime = nil
        for crimeId, def in pairs(CRIMES) do
            cumulative = cumulative + def.commonness
            if roll <= cumulative then
                selectedCrime = crimeId
                break
            end
        end
        if not selectedCrime then
            -- fallback
            for crimeId, _ in pairs(CRIMES) do
                selectedCrime = crimeId
                break
            end
        end
        -- Create case
        local case = {
            id = "case_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
            crime = selectedCrime,
            crimeName = CRIMES[selectedCrime].name,
            severity = CRIMES[selectedCrime].severity,
            accused = "Obtoženec " .. math.random(1, 999),
            evidence = math.random(20, 80),
            witnesses = math.random(0, 5),
            filedDay = os.time(),
            tried = false,
        }
        table.insert(Justice.pendingCases, case)
        Justice.totalCases = Justice.totalCases + 1
    end
end

-- ============================================================
-- TRIAL SYSTEM
-- ============================================================
function Justice.conductTrial(caseId, punishmentChoice)
    local case = nil
    for i, c in ipairs(Justice.pendingCases) do
        if c.id == caseId then
            case = c
            table.remove(Justice.pendingCases, i)
            break
        end
    end
    if not case then return false, "Zadeva ne obstaja" end
    -- Get best judge
    local judge = Justice.getBestJudge()
    local judgeSkill = judge and judge.skill or 50
    -- Calculate guilt determination
    local evidenceScore = case.evidence + (case.witnesses * 5)
    local guiltChance = (evidenceScore / 100) * (judgeSkill / 80)
    guiltChance = math.max(0.10, math.min(0.95, guiltChance))
    local isGuilty = math.random() < guiltChance
    -- Apply punishment if guilty
    local punishment = PUNISHMENTS[punishmentChoice] or PUNISHMENTS.fine
    if isGuilty then
        -- Check if punishment fits crime
        if punishment.severityRequired > case.severity then
            -- Too harsh
            Justice.justiceReputation = math.max(0, Justice.justiceReputation - 5)
            if _G.state and _G.state.happiness then
                _G.state.happiness = math.max(0, _G.state.happiness - 2)
            end
        elseif punishment.severityRequired < case.severity - 2 then
            -- Too lenient
            Justice.justiceReputation = math.max(0, Justice.justiceReputation - 3)
        else
            -- Appropriate
            Justice.justiceReputation = math.min(100, Justice.justiceReputation + 3)
        end
        -- Apply fine
        if punishment.name == "Globa" then
            local fineAmount = CRIMES[case.crime].baseFine
            if _G.state then
                _G.state.gold = (_G.state.gold or 0) + fineAmount
            end
            Justice.finesCollected = Justice.finesCollected + fineAmount
        end
        -- Track executions
        if punishment.name == "Usmrtitev" then
            Justice.totalExecutions = Justice.totalExecutions + 1
        end
        -- Apply happiness effect
        if _G.state and _G.state.happiness and punishment.happinessEffect ~= 0 then
            _G.state.happiness = math.max(0, math.min(100,
                _G.state.happiness + punishment.happinessEffect))
        end
    else
        -- Acquitted
        Justice.totalAcquittals = Justice.totalAcquittals + 1
        Justice.justiceReputation = math.min(100, Justice.justiceReputation + 2)
    end
    -- Mark case as tried
    case.tried = true
    case.verdict = isGuilty and "kriv" or "nekriv"
    case.punishment = isGuilty and punishment.name or "—"
    case.judge = judge and judge.name or "—"
    if judge then
        judge.casesTried = judge.casesTried + 1
        judge.skill = math.min(100, judge.skill + 1)
    end
    table.insert(Justice.completedCases, case)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Sojenje: %s — %s (%s)", case.accused, case.verdict,
                isGuilty and punishment.name or "oproščen"), "info")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "TRIAL_COMPLETED", {
            crime = case.crime, verdict = case.verdict, punishment = case.punishment,
        })
    end
    return true
end

function Justice.getSuggestedPunishment(case)
    if not case then return "fine" end
    for punId, def in pairs(PUNISHMENTS) do
        if def.severityRequired >= case.severity and
           (def.severityRequired < case.severity + 2) then
            return punId
        end
    end
    return "fine"
end

-- ============================================================
-- UPDATE
-- ============================================================
function Justice.update(dt)
    if not _G.state then return end
    Justice.dayTimer = Justice.dayTimer + dt
    if Justice.dayTimer >= 30 then
        Justice.dayTimer = 0
        -- Generate new crimes
        Justice.generateCrimes()
        -- Crime rate affected by happiness
        local happiness = (_G.state and _G.state.happiness) or 50
        local targetCrime = 50 - happiness
        Justice.crimeRate = Justice.crimeRate + (targetCrime - Justice.crimeRate) * 0.1
        -- Auto-conduct trials for oldest cases
        local capacity = Justice.getTotalTrialCapacity()
        for _ = 1, capacity do
            if #Justice.pendingCases > 0 then
                local case = Justice.pendingCases[1]
                local suggested = Justice.getSuggestedPunishment(case)
                Justice.conductTrial(case.id, suggested)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Justice.courtBuildings) do
            local def = COURT_BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        for _, j in ipairs(Justice.judges) do
            totalUpkeep = totalUpkeep + 10
        end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Clean up old completed cases
        for i = #Justice.completedCases, 1, -1 do
            local c = Justice.completedCases[i]
            c.cleanupTimer = (c.cleanupTimer or 30) - 1
            if c.cleanupTimer <= 0 then
                table.remove(Justice.completedCases, i)
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Justice.getCrimeInfo(crimeId) return CRIMES[crimeId] end
function Justice.getPunishmentInfo(punId) return PUNISHMENTS[punId] end
function Justice.getBuildingInfo(buildingId) return COURT_BUILDINGS[buildingId] end

function Justice.getStats()
    return {
        pendingCases = #Justice.pendingCases,
        completedCases = #Justice.completedCases,
        totalCases = Justice.totalCases,
        totalExecutions = Justice.totalExecutions,
        totalAcquittals = Justice.totalAcquittals,
        finesCollected = Justice.finesCollected,
        crimeRate = Justice.crimeRate,
        justiceReputation = Justice.justiceReputation,
        numJudges = #Justice.judges,
        numCourts = #Justice.courtBuildings,
        trialCapacity = Justice.getTotalTrialCapacity(),
    }
end

return Justice
