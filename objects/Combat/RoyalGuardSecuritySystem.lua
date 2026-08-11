-- objects/Combat/RoyalGuardSecuritySystem.lua
-- Castle Kingdoms 2027 v3.3.0 - Royal Guard & Personal Security System
--
-- Manages the king's personal protection: royal guards, assassination plot
-- detection, food tasters, and escape routes.
--
-- Features:
-- - 5 guard types (household, elite, foreign, mercenary, knight commander)
-- - 6 threat types (assassin, poison, mob, rival lord, heretic, foreign agent)
-- - Guard assignments (patrol, escort, palace, travel)
-- - Plot detection (chance to discover assassination attempts)
-- - Food taster (poison protection)
-- - Escape routes (emergency evacuation)
-- - Security level (affects threat neutralization)
-- - Guard training (skill improvement)

local Guard = {}

-- ============================================================
-- GUARD TYPES
-- ============================================================
local GUARD_TYPES = {
    household = {
        name = "Dvorna straža",
        nameEn = "Household Guard",
        hireCost = 200,
        upkeep = 10,
        skill = 50,
        loyalty = 80,
        detectionBonus = 5,
        description = "Zvesta dvorna straža.",
    },
    elite = {
        name = "Elitna straža",
        nameEn = "Elite Guard",
        hireCost = 800,
        upkeep = 40,
        skill = 85,
        loyalty = 90,
        detectionBonus = 15,
        description = "Najboljši vojaki za osebno zaščito.",
    },
    foreign = {
        name = "Tuja straža",
        nameEn = "Foreign Guard",
        hireCost = 500,
        upkeep = 25,
        skill = 70,
        loyalty = 60,  -- less loyal but no local ties
        detectionBonus = 10,
        description = "Tuji najemniki, manj verjetno za zaroto.",
    },
    mercenary = {
        name = "Najemniška straža",
        nameEn = "Mercenary Guard",
        hireCost = 400,
        upkeep = 30,
        skill = 65,
        loyalty = 50,
        detectionBonus = 8,
        description = "Plačanci, zanesljivi dokler se plača.",
    },
    knight_commander = {
        name = "Viteški poveljnik",
        nameEn = "Knight Commander",
        hireCost = 1500,
        upkeep = 60,
        skill = 95,
        loyalty = 95,
        detectionBonus = 25,
        leadershipBonus = 0.20,
        description = "Izkušen poveljnik, vodi druge stražarje.",
    },
}

-- ============================================================
-- THREAT TYPES
-- ============================================================
local THREAT_TYPES = {
    assassin = {
        name = "Morilec",
        nameEn = "Assassin",
        baseChance = 0.10,
        detectionDifficulty = 0.40,
        damageIfSuccess = 50,  -- health damage to ruler
        description = "Profesionalni morilec poslan da ubije vladarja.",
    },
    poison = {
        name = "Strup",
        nameEn = "Poison",
        baseChance = 0.08,
        detectionDifficulty = 0.30,
        damageIfSuccess = 30,
        description = "Strup v hrani ali pijači.",
    },
    mob = {
        name = "Tropa",
        nameEn = "Mob",
        baseChance = 0.15,
        detectionDifficulty = 0.20,
        damageIfSuccess = 25,
        description = "Jurišna tropa napadalcev.",
    },
    rival_lord = {
        name = "Rivalni lord",
        nameEn = "Rival Lord",
        baseChance = 0.05,
        detectionDifficulty = 0.50,
        damageIfSuccess = 40,
        description = "Napad rivalnega plemiča.",
    },
    heretic = {
        name = "Heretik",
        nameEn = "Heretic",
        baseChance = 0.07,
        detectionDifficulty = 0.35,
        damageIfSuccess = 35,
        description = "Verski fanatik.",
    },
    foreign_agent = {
        name = "Tuj agent",
        nameEn = "Foreign Agent",
        baseChance = 0.06,
        detectionDifficulty = 0.55,
        damageIfSuccess = 45,
        description = "Agent tuje sile.",
    },
}

-- ============================================================
-- ASSIGNMENT TYPES
-- ============================================================
local ASSIGNMENTS = {
    patrol = { name = "Patrulja", effectiveness = 1.0, description = "Patruliranje palače." },
    escort = { name = "Spremljevalec", effectiveness = 1.5, description = "Neposredna zaščita vladarja." },
    palace = { name = "Palača", effectiveness = 1.2, description = "Varovanje palače." },
    travel = { name = "Potovanje", effectiveness = 0.8, description = "Spremljevanje na poti." },
    investigation = { name = "Preiskava", effectiveness = 2.0, description = "Aktivno iskanje zarot." },
}

-- ============================================================
-- STATE
-- ============================================================
Guard.guards = {}                       -- Hired guards
Guard.activeThreats = {}                -- Active assassination attempts
Guard.detectedPlots = {}                -- Discovered plots
Guard.foodTaster = false                -- Has food taster
Guard.escapeRoute = false               -- Has escape route
Guard.securityLevel = 50                -- 0-100
Guard.totalThwarts = 0                  -- Successful defenses
Guard.totalAttacks = 0                  -- Total assassination attempts
Guard.totalInjuries = 0                 -- Ruler injuries
Guard.rulerHealth = 100                 -- Ruler's health
Guard.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Guard.init()
    Guard.guards = {}
    Guard.activeThreats = {}
    Guard.detectedPlots = {}
    Guard.foodTaster = false
    Guard.escapeRoute = false
    Guard.securityLevel = 50
    Guard.totalThwarts = 0
    Guard.totalAttacks = 0
    Guard.totalInjuries = 0
    Guard.rulerHealth = 100
    Guard.dayTimer = 0
    print("[Guard] Royal Guard & Personal Security System initialized (5 guard types, 6 threats)")
end

-- ============================================================
-- HIRING GUARDS
-- ============================================================
function Guard.canHire(guardType)
    local def = GUARD_TYPES[guardType]
    if not def then return false, "Neznan tip stražarja" end
    if not _G.state or (_G.state.gold or 0) < def.hireCost then
        return false, "Premalo zlata"
    end
    return true
end

function Guard.hire(guardType, customName)
    local ok, err = Guard.canHire(guardType)
    if not ok then return false, err end
    local def = GUARD_TYPES[guardType]
    _G.state.gold = _G.state.gold - def.hireCost
    local guard = {
        id = "guard_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = guardType,
        name = customName or (def.name .. " " .. #Guard.guards + 1),
        skill = def.skill + math.random(-5, 10),
        loyalty = def.loyalty,
        detectionBonus = def.detectionBonus,
        leadershipBonus = def.leadershipBonus or 0,
        assignment = "patrol",
        experience = 0,
        hiredDay = os.time(),
    }
    table.insert(Guard.guards, guard)
    Guard.recalculateSecurityLevel()
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            string.format("Stražar najet: %s (%s)", guard.name, def.name), "success")
    end
    return true, guard.id
end

function Guard.findGuard(guardId)
    for _, g in ipairs(Guard.guards) do
        if g.id == guardId then return g end
    end
    return nil
end

function Guard.assignGuard(guardId, assignment)
    local g = Guard.findGuard(guardId)
    if not g then return false, "Stražar ne obstaja" end
    if not ASSIGNMENTS[assignment] then return false, "Neznana naloga" end
    g.assignment = assignment
    return true
end

function Guard.recalculateSecurityLevel()
    local total = 0
    for _, g in ipairs(Guard.guards) do
        local assignment = ASSIGNMENTS[g.assignment] or ASSIGNMENTS.patrol
        total = total + g.skill * assignment.effectiveness
    end
    -- Normalize to 0-100
    Guard.securityLevel = math.min(100, math.floor(total / 10))
end

-- ============================================================
-- SPECIAL PROTECTIONS
-- ============================================================
function Guard.hireFoodTaster()
    if Guard.foodTaster then return false, "Že imaš taksalca" end
    if not _G.state or (_G.state.gold or 0) < 500 then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - 500
    Guard.foodTaster = true
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Taksalec najet — zaščita pred strupom!", "success")
    end
    return true
end

function Guard.establishEscapeRoute()
    if Guard.escapeRoute then return false, "Že imaš pobeg pot" end
    if not _G.state or (_G.state.gold or 0) < 1000 then
        return false, "Premalo zlata"
    end
    _G.state.gold = _G.state.gold - 1000
    Guard.escapeRoute = true
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Pobeg pot vzpostavljena!", "success")
    end
    return true
end

-- ============================================================
-- THREAT GENERATION & DETECTION
-- ============================================================
function Guard.generateThreat()
    -- Pick threat type based on chance
    local roll = math.random()
    local cumulative = 0
    local selected = nil
    for threatId, def in pairs(THREAT_TYPES) do
        cumulative = cumulative + def.baseChance
        if roll <= cumulative then
            selected = threatId
            break
        end
    end
    if not selected then return end
    local def = THREAT_TYPES[selected]
    local threat = {
        id = "threat_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = selected,
        typeName = def.name,
        detectionDifficulty = def.detectionDifficulty,
        damageIfSuccess = def.damageIfSuccess,
        detected = false,
        neutralized = false,
        executed = false,
        createdDay = os.time(),
        daysToExecute = math.random(3, 10),  -- days until attack
    }
    table.insert(Guard.activeThreats, threat)
    Guard.totalAttacks = Guard.totalAttacks + 1
    -- Try to detect immediately
    Guard.attemptDetection(threat)
end

function Guard.attemptDetection(threat)
    -- Calculate detection chance
    local detectionScore = 0
    for _, g in ipairs(Guard.guards) do
        if g.assignment == "investigation" or g.assignment == "escort" then
            detectionScore = detectionScore + g.detectionBonus + (g.skill / 4)
        end
    end
    -- Food taster helps with poison
    if threat.type == "poison" and Guard.foodTaster then
        detectionScore = detectionScore + 50
    end
    local detectionChance = (detectionScore / 100) * (1 - threat.detectionDifficulty)
    detectionChance = math.max(0.05, math.min(0.95, detectionChance))
    if math.random() < detectionChance then
        threat.detected = true
        table.insert(Guard.detectedPlots, threat)
        Guard.totalThwarts = Guard.totalThwarts + 1
        -- Remove from active threats
        for i, t in ipairs(Guard.activeThreats) do
            if t.id == threat.id then
                table.remove(Guard.activeThreats, i)
                break
            end
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Zarota odkrita! %s neutraliziran", threat.typeName), "success")
        end
        if _G.GameEventBus then
            pcall(_G.GameEventBus.publish, "PLOT_DETECTED", { type = threat.type })
        end
    end
end

function Guard.executeThreat(threat)
    if threat.neutralized then return end
    threat.executed = true
    -- Check if guards can stop it
    local guardStrength = 0
    for _, g in ipairs(Guard.guards) do
        if g.assignment == "escort" or g.assignment == "palace" then
            guardStrength = guardStrength + g.skill
        end
    end
    -- Defense chance
    local defenseChance = guardStrength / (guardStrength + 100)
    if math.random() < defenseChance then
        -- Stopped by guards
        threat.neutralized = true
        Guard.totalThwarts = Guard.totalThwarts + 1
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("Napad odbit! %s ustavljen", threat.typeName), "success")
        end
    else
        -- Attack succeeds
        local damage = threat.damageIfSuccess
        -- Escape route reduces damage
        if Guard.escapeRoute and math.random() < 0.5 then
            damage = math.floor(damage * 0.3)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, "Pobeg uspel! Škoda zmanjšana", "info")
            end
        end
        -- Food taster blocks poison
        if threat.type == "poison" and Guard.foodTaster then
            damage = 0
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, "Taksalec preživel strup!", "warning")
            end
        end
        Guard.rulerHealth = math.max(0, Guard.rulerHealth - damage)
        Guard.totalInjuries = Guard.totalInjuries + 1
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify,
                string.format("NAPAD USPEL! %s — vladar poškodovan (-%d HP)", threat.typeName, damage), "danger")
        end
        if _G.GameEventBus then
            pcall(_G.GameEventBus.publish, "RULER_INJURED", {
                type = threat.type, damage = damage, healthRemaining = Guard.rulerHealth,
            })
        end
        -- Check ruler death
        if Guard.rulerHealth <= 0 then
            if _G.Dynasty then
                pcall(_G.Dynasty.rulerDeath)
            end
            Guard.rulerHealth = 100  -- new ruler
        end
    end
    -- Remove from active threats
    for i, t in ipairs(Guard.activeThreats) do
        if t.id == threat.id then
            table.remove(Guard.activeThreats, i)
            break
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Guard.update(dt)
    if not _G.state then return end
    Guard.dayTimer = Guard.dayTimer + dt
    if Guard.dayTimer >= 30 then
        Guard.dayTimer = 0
        -- Generate threats (chance based on happiness and security)
        local happiness = (_G.state and _G.state.happiness) or 50
        local threatModifier = (50 - happiness) / 50  -- lower happiness = more threats
        if math.random() < 0.10 * (1 + threatModifier) then
            Guard.generateThreat()
        end
        -- Process active threats
        for i = #Guard.activeThreats, 1, -1 do
            local t = Guard.activeThreats[i]
            t.daysToExecute = t.daysToExecute - 1
            -- Try detection each day
            if not t.detected then
                Guard.attemptDetection(t)
            end
            -- Check if it's time to execute
            if t.daysToExecute <= 0 and not t.detected then
                Guard.executeThreat(t)
            end
        end
        -- Pay upkeep
        local totalUpkeep = 0
        for _, g in ipairs(Guard.guards) do
            local def = GUARD_TYPES[g.type]
            if def then totalUpkeep = totalUpkeep + def.upkeep end
        end
        if Guard.foodTaster then totalUpkeep = totalUpkeep + 20 end
        if totalUpkeep > 0 and _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - totalUpkeep)
        end
        -- Heal ruler slowly
        if Guard.rulerHealth < 100 then
            Guard.rulerHealth = math.min(100, Guard.rulerHealth + 1)
        end
        -- Train guards
        for _, g in ipairs(Guard.guards) do
            g.experience = g.experience + 1
            if g.experience >= 100 then
                g.skill = math.min(100, g.skill + 1)
                g.experience = 0
            end
        end
        -- Clean up old detected plots
        for i = #Guard.detectedPlots, 1, -1 do
            local p = Guard.detectedPlots[i]
            p.cleanupTimer = (p.cleanupTimer or 30) - 1
            if p.cleanupTimer <= 0 then
                table.remove(Guard.detectedPlots, i)
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Guard.getGuardTypeInfo(typeId) return GUARD_TYPES[typeId] end
function Guard.getThTypeInfo(typeId) return THREAT_TYPES[typeId] end
function Guard.getAssignmentInfo(id) return ASSIGNMENTS[id] end

function Guard.getStats()
    return {
        numGuards = #Guard.guards,
        securityLevel = Guard.securityLevel,
        activeThreats = #Guard.activeThreats,
        detectedPlots = #Guard.detectedPlots,
        foodTaster = Guard.foodTaster,
        escapeRoute = Guard.escapeRoute,
        totalThwarts = Guard.totalThwarts,
        totalAttacks = Guard.totalAttacks,
        totalInjuries = Guard.totalInjuries,
        rulerHealth = Guard.rulerHealth,
    }
end

return Guard
