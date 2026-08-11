-- objects/Config/RoyalDecreesSystem.lua
-- Castle Kingdoms 2027 v3.1.5 - Royal Decrees & Edicts System
--
-- Manages royal proclamations, laws, edicts, and exemptions that the player
-- can issue. Each decree has lasting effects on the kingdom.
--
-- Features:
-- - 12 decree types (tax reform, conscription, religious tolerance, trade ban, ...)
-- - 4 categories (economic, military, social, religious)
-- - Active decree limits (max 5 active at once)
-- - Decree duration (temporary vs permanent)
-- - Revocation (cancel decrees at cost)
-- - Public opinion reactions
-- - Decree prerequisites (some require research)
-- - Decree chains (combinations unlock bonuses)
-- - Edict fatigue (too many decrees cause unrest)

local Decrees = {}

-- ============================================================
-- DECREE DEFINITIONS
-- ============================================================
local DECREES = {
    -- ECONOMIC
    tax_reform = {
        name = "Davčna reforma",
        nameEn = "Tax Reform",
        category = "economic",
        duration = 90,  -- days
        effect = {
            goldProductionMultiplier = 1.30,
            happinessBonus = -8,
            peasantLoyalty = -5,
        },
        description = "Poveča davke za 30%, vendar zmanjša srečo.",
        prereq = nil,
    },
    trade_subsidy = {
        name = "Trgovinske subvencije",
        nameEn = "Trade Subsidies",
        category = "economic",
        duration = 60,
        effect = {
            tradeVolumeBonus = 0.25,
            goldProductionMultiplier = 0.90,  -- costs gold
            merchantLoyalty = 10,
        },
        description = "Subvencionira trgovino, poveča promet.",
        prereq = nil,
    },
    land_redistribution = {
        name = "Prerazporeditev zemlje",
        nameEn = "Land Redistribution",
        category = "economic",
        duration = 120,
        effect = {
            foodProductionMultiplier = 1.20,
            peasantLoyalty = 15,
            nobleLoyalty = -15,
        },
        description = "Plemiška zemlja se prerazporedi kmetom.",
        prereq = nil,
    },
    -- MILITARY
    conscription = {
        name = "Vpis v vojsko",
        nameEn = "Conscription",
        category = "military",
        duration = 60,
        effect = {
            unitProductionMultiplier = 1.50,
            peasantLoyalty = -10,
            happinessBonus = -5,
            freeUnitsPerDay = 2,
        },
        description = "Obvezno vpisovanje kmetov v vojsko.",
        prereq = nil,
    },
    standing_army = {
        name = "Stoječa vojska",
        nameEn = "Standing Army",
        category = "military",
        duration = 0,  -- permanent
        effect = {
            unitUpkeepMultiplier = 1.20,
            unitQualityBonus = 0.15,
            armyLoyalty = 10,
        },
        description = "Profesionalna stalna vojska namesto fevdalne.",
        prereq = "military_tradition",
    },
    weapon_monopoly = {
        name = "Monopol na orožje",
        nameEn = "Weapon Monopoly",
        category = "military",
        duration = 0,
        effect = {
            weaponProductionBonus = 0.30,
            blacksmithLoyalty = 15,
            happinessBonus = -3,
        },
        description = "Samo država sme proizvajati orožje.",
        prereq = nil,
    },
    -- SOCIAL
    religious_tolerance = {
        name = "Verska strpnost",
        nameEn = "Religious Tolerance",
        category = "social",
        duration = 0,
        effect = {
            happinessBonus = 8,
            heresyReduction = 0.50,
            religionLoyalty = -5,
        },
        description = "Vse vere so enakopravne.",
        prereq = nil,
    },
    serf_emancipation = {
        name = "Osvoboditev tlačanov",
        nameEn = "Serf Emancipation",
        category = "social",
        duration = 0,
        effect = {
            peasantLoyalty = 25,
            happinessBonus = 15,
            foodProductionMultiplier = 0.85,  -- initial disruption
            nobleLoyalty = -25,
        },
        description = "Tlačani postanejo svobodni državljani.",
        prereq = "enlightenment",
    },
    public_works = {
        name = "Javna dela",
        nameEn = "Public Works",
        category = "social",
        duration = 90,
        effect = {
            happinessBonus = 12,
            constructionSpeedBonus = 0.20,
            goldProductionMultiplier = 0.85,
        },
        description = "Država gradi ceste, mostove, vodovode.",
        prereq = nil,
    },
    -- RELIGIOUS
    state_religion = {
        name = "Državna vera",
        nameEn = "State Religion",
        category = "religious",
        duration = 0,
        effect = {
            faithGenerationBonus = 0.50,
            happinessBonus = 5,
            hereticLoyalty = -20,
        },
        description = "Uradna državna vera z ekonomskimi ugodnostmi.",
        prereq = nil,
    },
    inquisition = {
        name = "Inkvizicija",
        nameEn = "Inquisition",
        category = "religious",
        duration = 60,
        effect = {
            heresyReduction = 0.95,
            happinessBonus = -10,
            peasantLoyalty = -8,
            faithGenerationBonus = 0.20,
        },
        description = "Državno preganjanje heretikov.",
        prereq = "state_religion",
    },
    holy_tithe = {
        name = "Sveta desetina",
        nameEn = "Holy Tithe",
        category = "religious",
        duration = 0,
        effect = {
            goldProductionMultiplier = 0.90,  -- 10% to church
            faithGenerationBonus = 0.30,
            churchLoyalty = 20,
        },
        description = "10% vsega prihodka gre cerkvi.",
        prereq = "state_religion",
    },
}

-- ============================================================
-- DECREE CHAINS
-- ============================================================
local DECREE_CHAINS = {
    {
        name = "Razsvetljeni vladar",
        decrees = { "religious_tolerance", "public_works", "serf_emancipation" },
        bonus = { happinessBonus = 10, allLoyalty = 5 },
        description = "Vladar je znan kot razsvetljen.",
    },
    {
        name = "Vojni lord",
        decrees = { "conscription", "standing_army", "weapon_monopoly" },
        bonus = { armyStrength = 0.20, armyLoyalty = 15 },
        description = "Vladar je vojaški genij.",
    },
    {
        name = "Bogataš",
        decrees = { "tax_reform", "trade_subsidy", "holy_tithe" },
        bonus = { goldProductionMultiplier = 1.10 },
        description = "Vladar je znan kot bogat.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Decrees.activeDecrees = {}        -- Currently active
Decrees.decreeHistory = {}        -- Past decrees
Decrees.researchedPrereqs = {}    -- Researched prerequisites
Decrees.edictFatigue = 0          -- 0-100, too many decrees = unrest
Decrees.totalIssued = 0
Decrees.totalRevoked = 0
Decrees.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Decrees.init()
    Decrees.activeDecrees = {}
    Decrees.decreeHistory = {}
    Decrees.researchedPrereqs = {}
    Decrees.edictFatigue = 0
    Decrees.totalIssued = 0
    Decrees.totalRevoked = 0
    Decrees.dayTimer = 0
    print("[Decrees] Royal Decrees & Edicts System initialized (12 decrees, 4 categories)")
end

-- ============================================================
-- DECREE ISSUANCE
-- ============================================================
function Decrees.canIssue(decreeId)
    local def = DECREES[decreeId]
    if not def then return false, "Neznani odlok" end
    -- Check if already active
    for _, d in ipairs(Decrees.activeDecrees) do
        if d.id == decreeId then
            return false, "Odlok že aktiven"
        end
    end
    -- Check max active decrees
    if #Decrees.activeDecrees >= 5 then
        return false, "Preveč aktivnih odlokov (max 5)"
    end
    -- Check prerequisite
    if def.prereq and not Decrees.researchedPrereqs[def.prereq] then
        return false, "Manjka predpogoj: " .. def.prereq
    end
    -- Check edict fatigue
    if Decrees.edictFatigue > 80 then
        return false, "Preveč odlokov — ljudstvo je utrujeno"
    end
    return true
end

function Decrees.issue(decreeId)
    local ok, err = Decrees.canIssue(decreeId)
    if not ok then return false, err end
    local def = DECREES[decreeId]
    local decree = {
        id = decreeId,
        name = def.name,
        category = def.category,
        effect = def.effect,
        daysRemaining = def.duration,  -- 0 = permanent
        totalDays = def.duration,
        issuedDay = os.time(),
        permanent = def.duration == 0,
    }
    table.insert(Decrees.activeDecrees, decree)
    Decrees.totalIssued = Decrees.totalIssued + 1
    -- Increase edict fatigue
    Decrees.edictFatigue = math.min(100, Decrees.edictFatigue + 20)
    -- Apply immediate happiness reaction
    if def.effect.happinessBonus and _G.state and _G.state.happiness then
        _G.state.happiness = math.max(0, math.min(100,
            _G.state.happiness + def.effect.happinessBonus))
    end
    -- Notify
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Odlok izdan: " .. def.name, "important")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "DECREE_ISSUED", {
            id = decreeId, category = def.category,
        })
    end
    -- Check for chain completion
    Decrees.checkChains()
    return true
end

function Decrees.revoke(decreeId)
    for i, d in ipairs(Decrees.activeDecrees) do
        if d.id == decreeId then
            table.remove(Decrees.activeDecrees, i)
            Decrees.totalRevoked = Decrees.totalRevoked + 1
            -- Add to history
            table.insert(Decrees.decreeHistory, {
                id = d.id,
                name = d.name,
                issuedDay = d.issuedDay,
                revokedDay = os.time(),
                reason = "revoked",
            })
            -- Negative reaction from affected parties
            if d.effect.happinessBonus and d.effect.happinessBonus > 0 then
                if _G.state and _G.state.happiness then
                    _G.state.happiness = math.max(0, _G.state.happiness - 3)
                end
            end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, "Odlok preklican: " .. d.name, "info")
            end
            return true
        end
    end
    return false, "Odlok ni aktiven"
end

-- ============================================================
-- PREREQUISITE RESEARCH
-- ============================================================
function Decrees.researchPrereq(prereqId)
    if Decrees.researchedPrereqs[prereqId] then
        return false, "Žea raziskano"
    end
    -- Cost: 1000 gold + 30 days (instant for now)
    if not _G.state or (_G.state.gold or 0) < 1000 then
        return false, "Premalo zlata (1000)"
    end
    _G.state.gold = _G.state.gold - 1000
    Decrees.researchedPrereqs[prereqId] = true
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Raziskano: " .. prereqId, "success")
    end
    return true
end

-- ============================================================
-- DECREE CHAINS
-- ============================================================
function Decrees.checkChains()
    local activeIds = {}
    for _, d in ipairs(Decrees.activeDecrees) do
        table.insert(activeIds, d.id)
    end
    for _, chain in ipairs(DECREE_CHAINS) do
        -- Check if all decrees in chain are active
        local allActive = true
        for _, reqId in ipairs(chain.decrees) do
            local found = false
            for _, aid in ipairs(activeIds) do
                if aid == reqId then found = true; break end
            end
            if not found then allActive = false; break end
        end
        if allActive and not Decrees.chainCompleted then
            Decrees.chainCompleted = Decrees.chainCompleted or {}
            if not Decrees.chainCompleted[chain.name] then
                Decrees.chainCompleted[chain.name] = true
                -- Apply bonus
                if chain.bonus.happinessBonus and _G.state and _G.state.happiness then
                    _G.state.happiness = math.min(100, _G.state.happiness + chain.bonus.happinessBonus)
                end
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify,
                        "VERIGA ODLOKOV! " .. chain.name .. " — " .. chain.description, "rare")
                end
                if _G.GameEventBus then
                    pcall(_G.GameEventBus.publish, "DECREE_CHAIN_COMPLETED", { name = chain.name })
                end
            end
        end
    end
end

-- ============================================================
-- ACTIVE EFFECTS QUERY
-- ============================================================
function Decrees.getActiveEffects()
    local combined = {
        goldProductionMultiplier = 1.0,
        foodProductionMultiplier = 1.0,
        unitProductionMultiplier = 1.0,
        unitUpkeepMultiplier = 1.0,
        tradeVolumeBonus = 0,
        constructionSpeedBonus = 0,
        weaponProductionBonus = 0,
        happinessBonus = 0,
        freeUnitsPerDay = 0,
        heresyReduction = 0,
        faithGenerationBonus = 0,
        allLoyalty = 0,
        armyStrength = 0,
    }
    for _, d in ipairs(Decrees.activeDecrees) do
        local eff = d.effect or {}
        if eff.goldProductionMultiplier then
            combined.goldProductionMultiplier = combined.goldProductionMultiplier * eff.goldProductionMultiplier
        end
        if eff.foodProductionMultiplier then
            combined.foodProductionMultiplier = combined.foodProductionMultiplier * eff.foodProductionMultiplier
        end
        if eff.unitProductionMultiplier then
            combined.unitProductionMultiplier = combined.unitProductionMultiplier * eff.unitProductionMultiplier
        end
        if eff.unitUpkeepMultiplier then
            combined.unitUpkeepMultiplier = combined.unitUpkeepMultiplier * eff.unitUpkeepMultiplier
        end
        for _, key in ipairs({ "tradeVolumeBonus", "constructionSpeedBonus",
            "weaponProductionBonus", "happinessBonus", "freeUnitsPerDay",
            "heresyReduction", "faithGenerationBonus" }) do
            if eff[key] then
                combined[key] = combined[key] + eff[key]
            end
        end
    end
    -- Chain bonuses
    if Decrees.chainCompleted then
        for _, chain in ipairs(DECREE_CHAINS) do
            if Decrees.chainCompleted[chain.name] and chain.bonus then
                for k, v in pairs(chain.bonus) do
                    if type(v) == "number" then
                        combined[k] = (combined[k] or 0) + v
                    end
                end
            end
        end
    end
    return combined
end

-- ============================================================
-- UPDATE
-- ============================================================
function Decrees.update(dt)
    if not _G.state then return end
    Decrees.dayTimer = Decrees.dayTimer + dt
    if Decrees.dayTimer >= 30 then
        Decrees.dayTimer = 0
        -- Decrement durations
        for i = #Decrees.activeDecrees, 1, -1 do
            local d = Decrees.activeDecrees[i]
            if not d.permanent then
                d.daysRemaining = d.daysRemaining - 1
                if d.daysRemaining <= 0 then
                    -- Expired
                    table.insert(Decrees.decreeHistory, {
                        id = d.id,
                        name = d.name,
                        issuedDay = d.issuedDay,
                        revokedDay = os.time(),
                        reason = "expired",
                    })
                    table.remove(Decrees.activeDecrees, i)
                    if _G.NotificationCenter then
                        pcall(_G.NotificationCenter.notify, "Odlok potekel: " .. d.name, "info")
                    end
                end
            end
        end
        -- Reduce edict fatigue
        if Decrees.edictFatigue > 0 then
            Decrees.edictFatigue = math.max(0, Decrees.edictFatigue - 2)
        end
        -- Apply free units from conscription
        local effects = Decrees.getActiveEffects()
        if effects.freeUnitsPerDay > 0 and _G.CombatIntegration and _G.CombatIntegration.spawnUnit then
            for _ = 1, effects.freeUnitsPerDay do
                pcall(_G.CombatIntegration.spawnUnit, "peasant_soldier", 500, 500)
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Decrees.getDecreeInfo(decreeId) return DECREES[decreeId] end

function Decrees.listByCategory(category)
    local result = {}
    for id, def in pairs(DECREES) do
        if def.category == category then
            table.insert(result, { id = id, name = def.name, def = def })
        end
    end
    return result
end

function Decrees.getStats()
    return {
        activeCount = #Decrees.activeDecrees,
        totalIssued = Decrees.totalIssued,
        totalRevoked = Decrees.totalRevoked,
        edictFatigue = Decrees.edictFatigue,
        researchedPrereqs = #Decrees.researchedPrereqs,
        historyCount = #Decrees.decreeHistory,
        chainsCompleted = Decrees.chainCompleted and
            (function()
                local count = 0
                for _ in pairs(Decrees.chainCompleted) do count = count + 1 end
                return count
            end)() or 0,
    }
end

return Decrees
