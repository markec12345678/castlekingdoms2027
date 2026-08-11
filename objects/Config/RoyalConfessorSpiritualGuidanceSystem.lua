-- objects/Config/RoyalConfessorSpiritualGuidanceSystem.lua
-- Castle Kingdoms 2027 v3.5.3 - Royal Confessor & Spiritual Guidance System
--
-- Manages the royal confessor, spiritual counseling, confession, and absolution.
-- Provides faith bonuses, happiness, and moral authority.
--
-- Features:
-- - 6 sin types (pride, greed, lust, envy, gluttony, wrath)
-- - 8 penance types (prayer, fasting, almsgiving, pilgrimage, ...)
-- - 4 spiritual buildings (chapel, confessional, hermitage, monastery)
-- - Royal Confessor NPC (skill affects absolution quality)
-- - Confession system (reduces guilt, increases happiness)
-- - Spiritual counseling
-- - Moral authority tracking
-- - Indulgence system

local Confessor = {}

-- ============================================================
-- SIN TYPES
-- ============================================================
local SINS = {
    pride = {
        name = "Oholost",
        nameEn = "Pride",
        severity = 5,
        guiltPenalty = 10,
        description = "Prekomerno samozavest in aroganca.",
    },
    greed = {
        name = "Pohlep",
        nameEn = "Greed",
        severity = 4,
        guiltPenalty = 8,
        description = "Prekomerna želja po bogastvu.",
    },
    lust = {
        name = "Pohotljivost",
        nameEn = "Lust",
        severity = 3,
        guiltPenalty = 6,
        description = "Nečisti želje.",
    },
    envy = {
        name = "Zavist",
        nameEn = "Envy",
        severity = 4,
        guiltPenalty = 7,
        description = "Zavidanje drugim.",
    },
    gluttony = {
        name = "Pojedljivost",
        nameEn = "Gluttony",
        severity = 2,
        guiltPenalty = 4,
        description = "Prekomerno uživanje hrane in pijače.",
    },
    wrath = {
        name = "Jes",
        nameEn = "Wrath",
        severity = 5,
        guiltPenalty = 9,
        description = "Nekontrolirana jeza in bes.",
    },
}

-- ============================================================
-- PENANCE TYPES
-- ============================================================
local PENANCES = {
    prayer = {
        name = "Molitev",
        nameEn = "Prayer",
        duration = 3,
        faithCost = 10,
        absolutionBonus = 0.15,
        description = "Določeno število molitev.",
    },
    fasting = {
        name = "Post",
        nameEn = "Fasting",
        duration = 7,
        happinessCost = 3,
        absolutionBonus = 0.20,
        description = "Postenje za spravo.",
    },
    almsgiving = {
        name = "Milostinja",
        nameEn = "Almsgiving",
        duration = 1,
        goldCost = 500,
        absolutionBonus = 0.25,
        happinessBonus = 5,
        description = "Darovanje revnim.",
    },
    pilgrimage = {
        name = "Romanje",
        nameEn = "Pilgrimage",
        duration = 30,
        goldCost = 1000,
        absolutionBonus = 0.40,
        faithBonus = 30,
        description = "Romanje v sveto mesto.",
    },
    self_flagellation = {
        name = "Samobičanje",
        nameEn = "Self-Flagellation",
        duration = 1,
        healthCost = 10,
        absolutionBonus = 0.30,
        description = "Fizično kaznovanje (ekstremno).",
    },
    confession = {
        name = "Spoved",
        nameEn = "Confession",
        duration = 1,
        absolutionBonus = 0.10,
        description = "Izpoved grehov duhovniku.",
    },
    mass_attendance = {
        name = "Maša",
        nameEn = "Mass Attendance",
        duration = 7,
        faithCost = 20,
        absolutionBonus = 0.15,
        description = "Dnevno obiskovanje maše.",
    },
    charitable_work = {
        name = "Dobrodelno delo",
        nameEn = "Charitable Work",
        duration = 14,
        goldCost = 300,
        absolutionBonus = 0.22,
        happinessBonus = 8,
        description = "Delo v dobrorevnih ustanovah.",
    },
}

-- ============================================================
-- SPIRITUAL BUILDINGS
-- ============================================================
local BUILDINGS = {
    chapel = {
        name = "Kapela",
        cost = { gold = 300, wood = 100, stone = 50 },
        upkeep = 10,
        absolutionBonus = 5,
        faithBonus = 5,
        description = "Majhna kapela za osebno molitev.",
    },
    confessional = {
        name = "Spovednica",
        cost = { gold = 500, wood = 200, stone = 100 },
        upkeep = 15,
        absolutionBonus = 15,
        description = "Posebna soba za spoved.",
    },
    hermitage = {
        name = "Puščavnica",
        cost = { gold = 200, wood = 150 },
        upkeep = 5,
        absolutionBonus = 10,
        meditationBonus = 20,
        description = "Samotna hiša za meditacijo.",
    },
    monastery = {
        name = "Samostan",
        cost = { gold = 2000, wood = 400, stone = 600 },
        upkeep = 50,
        absolutionBonus = 25,
        faithBonus = 15,
        prestigeBonus = 10,
        description = "Veliki samostan z redovniki.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Confessor.sinsCommitted = {}              -- Sins needing absolution
Confessor.activePenance = {}              -- Ongoing penances
Confessor.buildings = {}                  -- Built spiritual buildings
Confessor.confessor = nil                 -- Royal Confessor NPC
Confessor.moralAuthority = 50            -- 0-100
Confessor.guiltLevel = 0                  -- 0-100
Confessor.totalAbsolutions = 0
Confessor.totalIndulgences = 0
Confessor.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Confessor.init()
    Confessor.sinsCommitted = {}
    Confessor.activePenance = {}
    Confessor.buildings = {}
    Confessor.confessor = nil
    Confessor.moralAuthority = 50
    Confessor.guiltLevel = 0
    Confessor.totalAbsolutions = 0
    Confessor.totalIndulgences = 0
    Confessor.dayTimer = 0
    print("[Confessor] Royal Confessor & Spiritual Guidance System initialized (6 sins, 8 penances, 4 buildings)")
end

-- ============================================================
-- ROYAL CONFESSOR NPC
-- ============================================================
function Confessor.hireConfessor(name, skill)
    skill = skill or math.random(50, 90)
    local cost = 400 + skill * 8
    if not _G.state or (_G.state.gold or 0) < cost then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - cost
    Confessor.confessor = {
        name = name or ("Spovednik " .. math.random(1, 99)),
        skill = skill,
        piety = math.random(60, 100),
        hiredDay = os.time(),
        absolutionsGiven = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Spovednik najet: %s (spretnost: %d, pobožnost: %d)",
                Confessor.confessor.name, skill, Confessor.confessor.piety), "success")
    end
    return true
end

-- ============================================================
-- BUILDINGS
-- ============================================================
function Confessor.canBuild(buildingId)
    local def = BUILDINGS[buildingId]
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

function Confessor.build(buildingId)
    local ok, err = Confessor.canBuild(buildingId)
    if not ok then return false, err end
    local def = BUILDINGS[buildingId]
    _G.state.gold = _G.state.gold - (def.cost.gold or 0)
    if _G.state.resources then
        for res, amt in pairs(def.cost) do
            if res ~= "gold" then
                _G.state.resources[res] = (_G.state.resources[res] or 0) - amt
            end
        end
    end
    table.insert(Confessor.buildings, {
        type = buildingId,
        builtDay = os.time(),
    })
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Zgrajeno: " .. def.name, "success")
    end
    return true
end

function Confessor.getAbsolutionBonus()
    local bonus = 0
    for _, b in ipairs(Confessor.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.absolutionBonus then bonus = bonus + def.absolutionBonus end
    end
    return bonus
end

function Confessor.getFaithBonus()
    local bonus = 0
    for _, b in ipairs(Confessor.buildings) do
        local def = BUILDINGS[b.type]
        if def and def.faithBonus then bonus = bonus + def.faithBonus end
    end
    return bonus
end

-- ============================================================
-- COMMITTING SINS
-- ============================================================
function Confessor.commitSin(sinType)
    local def = SINS[sinType]
    if not def then return false, "Neznan greh" end
    table.insert(Confessor.sinsCommitted, {
        id = "sin_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = sinType,
        name = def.name,
        severity = def.severity,
        guiltPenalty = def.guiltPenalty,
        committedDay = os.time(),
        absolved = false,
    })
    -- Increase guilt
    Confessor.guiltLevel = math.min(100, Confessor.guiltLevel + def.guiltPenalty)
    -- Happiness penalty from guilt
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.max(0, _G.state.happiness - math.floor(def.guiltPenalty / 3))
    end
    -- Moral authority drops
    Confessor.moralAuthority = math.max(0, Confessor.moralAuthority - def.severity)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Greh storjen: %s (krivda: +%d)", def.name, def.guiltPenalty), "warning")
    end
    return true
end

-- ============================================================
-- PENANCE & ABSOLUTION
-- ============================================================
function Confessor.canAssignPenance(penanceType, sinId)
    local def = PENANCES[penanceType]
    if not def then return false, "Neznana pokora" end
    if not Confessor.confessor then return false, "Potreben spovednik" end
    -- Find sin
    local sin = nil
    for _, s in ipairs(Confessor.sinsCommitted) do
        if s.id == sinId and not s.absolved then sin = s; break end
    end
    if not sin then return false, "Greh ne obstaja ali je že odpuščen" end
    -- Check costs
    if def.goldCost and (not _G.state or (_G.state.gold or 0) < def.goldCost) then
        return false, "Premalo zlata"
    end
    if def.faithCost and _G.Religion and (_G.Religion.faith or 0) < def.faithCost then
        return false, "Premalo vere"
    end
    return true
end

function Confessor.assignPenance(penanceType, sinId)
    local ok, err = Confessor.canAssignPenance(penanceType, sinId)
    if not ok then return false, err end
    local def = PENANCES[penanceType]
    -- Find sin
    local sin = nil
    for _, s in ipairs(Confessor.sinsCommitted) do
        if s.id == sinId and not s.absolved then sin = s; break end
    end
    -- Pay costs
    if def.goldCost and _G.state then
        _G.state.gold = _G.state.gold - def.goldCost
    end
    if def.faithCost and _G.Religion then
        pcall(function() _G.Religion.faith = _G.Religion.faith - def.faithCost end)
    end
    -- Apply immediate effects
    if def.happinessCost and _G.state and _G.state.happiness then
        _G.state.happiness = math.max(0, _G.state.happiness - def.happinessCost)
    end
    if def.healthCost and _G.Guard then
        pcall(function() _G.Guard.rulerHealth = math.max(0, _G.Guard.rulerHealth - def.healthCost) end)
    end
    -- Calculate absolution chance
    local absolutionChance = 0.30 + def.absolutionBonus
    absolutionChance = absolutionChance + (Confessor.getAbsolutionBonus() / 100)
    if Confessor.confessor then
        absolutionChance = absolutionChance + (Confessor.confessor.skill / 200)
        absolutionChance = absolutionChance + (Confessor.confessor.piety / 300)
    end
    absolutionChance = math.max(0.10, math.min(0.95, absolutionChance))
    local penance = {
        id = "penance_" .. tostring(os.time()),
        penanceType = penanceType,
        penanceName = def.name,
        sinId = sinId,
        sinName = sin.name,
        daysRemaining = def.duration,
        absolutionChance = absolutionChance,
        started = os.time(),
    }
    table.insert(Confessor.activePenance, penance)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Pokora določena: %s za %s (%d dni, %.0f%% odpuščanja)",
                def.name, sin.name, def.duration, absolutionChance * 100), "info")
    end
    return true
end

function Confessor.completePenance(penance)
    -- Roll for absolution
    if math.random() < penance.absolutionChance then
        -- Absolved!
        Confessor.totalAbsolutions = Confessor.totalAbsolutions + 1
        -- Mark sin as absolved
        for _, s in ipairs(Confessor.sinsCommitted) do
            if s.id == penance.sinId then
                s.absolved = true
                -- Reduce guilt
                Confessor.guiltLevel = math.max(0, Confessor.guiltLevel - s.guiltPenalty)
                break
            end
        end
        -- Happiness boost from absolution
        if _G.state and _G.state.happiness then
            _G.state.happiness = math.min(100, _G.state.happiness + 5)
        end
        -- Faith boost
        if _G.Religion then
            pcall(_G.Religion.addFaith, 15)
        end
        -- Moral authority recovery
        Confessor.moralAuthority = math.min(100, Confessor.moralAuthority + 5)
        if Confessor.confessor then
            Confessor.confessor.absolutionsGiven = Confessor.confessor.absolutionsGiven + 1
            if math.random() < 0.20 then
                Confessor.confessor.skill = math.min(100, Confessor.confessor.skill + 1)
            end
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Greh odpuščen: %s! (+5 sreče, +15 vere)", penance.sinName), "success")
        end
        if _G.GameEventBus then
            pcall(_G.GameEventBus.publish, "SIN_ABSOLVED", { sinType = penance.sinId })
        end
    else
        -- Not absolved yet
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Pokora končana, a greh še ni odpuščen: %s", penance.sinName), "warning")
        end
    end
end

-- ============================================================
-- INDULGENCES
-- ============================================================
function Confessor.grantIndulgence()
    if not _G.state or (_G.state.gold or 0) < 2000 then
        return false, "Premalo zlata (2000)"
    end
    if not _G.Religion or (_G.Religion.faith or 0) < 50 then
        return false, "Premalo vere (50)"
    end
    _G.state.gold = _G.state.gold - 2000
    pcall(function() _G.Religion.faith = _G.Religion.faith - 50 end)
    -- Absolve all sins
    local absolved = 0
    for _, s in ipairs(Confessor.sinsCommitted) do
        if not s.absolved then
            s.absolved = true
            Confessor.guiltLevel = math.max(0, Confessor.guiltLevel - s.guiltPenalty)
            absolved = absolved + 1
        end
    end
    Confessor.totalIndulgences = Confessor.totalIndulgences + 1
    -- Moral authority drops (indulgences are controversial)
    Confessor.moralAuthority = math.max(0, Confessor.moralAuthority - 10)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Indulgenca podeljena! %d grehov odpuščenih.", absolved), "important")
    end
    return true
end

-- ============================================================
-- SPIRITUAL COUNSELING
-- ============================================================
function Confessor.counsel()
    if not Confessor.confessor then return false, "Potreben spovednik" end
    if not _G.state or (_G.state.gold or 0) < 100 then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - 100
    -- Happiness boost
    if _G.state and _G.state.happiness then
        _G.state.happiness = math.min(100, _G.state.happiness + 5)
    end
    -- Reduce guilt slightly
    Confessor.guiltLevel = math.max(0, Confessor.guiltLevel - 5)
    -- Faith boost
    if _G.Religion then
        pcall(_G.Religion.addFaith, 5)
    end
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Duhovno svetovanje opravljeno.", "info")
    end
    return true
end

-- ============================================================
-- UPDATE
-- ============================================================
function Confessor.update(dt)
    if not _G.state then return end
    Confessor.dayTimer = Confessor.dayTimer + dt
    if Confessor.dayTimer >= 30 then
        Confessor.dayTimer = 0
        -- Process penances
        for i = #Confessor.activePenance, 1, -1 do
            local p = Confessor.activePenance[i]
            p.daysRemaining = p.daysRemaining - 1
            if p.daysRemaining <= 0 then
                Confessor.completePenance(p)
                table.remove(Confessor.activePenance, i)
            end
        end
        -- Clean up absolved sins
        for i = #Confessor.sinsCommitted, 1, -1 do
            local s = Confessor.sinsCommitted[i]
            if s.absolved then
                s.cleanupTimer = (s.cleanupTimer or 30) - 1
                if s.cleanupTimer <= 0 then
                    table.remove(Confessor.sinsCommitted, i)
                end
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, b in ipairs(Confessor.buildings) do
            local def = BUILDINGS[b.type]
            if def and def.upkeep then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Confessor.confessor then totalUpkeep = totalUpkeep + 20 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Apply faith bonus from buildings
        local faithBonus = Confessor.getFaithBonus()
        if faithBonus > 0 and _G.Religion then
            pcall(_G.Religion.addFaith, math.floor(faithBonus / 10))
        end
        -- Guilt slowly increases moral decay
        if Confessor.guiltLevel > 50 and math.random() < 0.10 then
            Confessor.moralAuthority = math.max(0, Confessor.moralAuthority - 1)
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Confessor.getSinInfo(sinId) return SINS[sinId] end
function Confessor.getPenanceInfo(penanceId) return PENANCES[penanceId] end
function Confessor.getBuildingInfo(buildingId) return BUILDINGS[buildingId] end

function Confessor.getStats()
    return {
        unabsolvedSins = (function()
            local count = 0
            for _, s in ipairs(Confessor.sinsCommitted) do
                if not s.absolved then count = count + 1 end
            end
            return count
        end)(),
        activePenance = #Confessor.activePenance,
        numBuildings = #Confessor.buildings,
        hasConfessor = Confessor.confessor ~= nil,
        confessorName = Confessor.confessor and Confessor.confessor.name or "—",
        confessorSkill = Confessor.confessor and Confessor.confessor.skill or 0,
        moralAuthority = Confessor.moralAuthority,
        guiltLevel = Confessor.guiltLevel,
        totalAbsolutions = Confessor.totalAbsolutions,
        totalIndulgences = Confessor.totalIndulgences,
    }
end

return Confessor
