-- objects/Gameplay/TreasonRebellionSystem.lua
-- Castle Kingdoms 2027 v3.1.3 - Treason & Rebellion System
--
-- Manages internal strife: peasant revolts, noble conspiracies, civil war,
-- and loyalty management. Unrest builds up based on happiness, taxes, and
-- external provocations.
--
-- Features:
-- - 6 rebellion types (peasant revolt, noble coup, religious schism, army mutiny,
--   succession crisis, foreign-sponsored uprising)
-- - Loyalty tracker per region/noble
-- - Unrest build-up mechanics
-- - Conspiracy detection (via espionage)
-- - Civil war (multiple regions break away)
-- - Crackdown options (ruthless vs merciful)
-- - Pacification programs

local Rebellion = {}

-- ============================================================
-- REBELLION TYPES
-- ============================================================
local REBELLION_TYPES = {
    peasant_revolt = {
        name = "Kmečki upor",
        nameEn = "Peasant Revolt",
        cause = "low_happiness",
        threshold = 30,  -- happiness below this
        strength = 50,
        duration = 30,
        spreadChance = 0.20,
        description = "Kmetje se uperjo proti visokim davkom in slabihravnanju.",
        units = { "peasant_rebel", "peasant_rebel", "peasant_archer" },
        demands = { "reduce_taxes", "increase_food" },
    },
    noble_coup = {
        name = "Plemiški udar",
        nameEn = "Noble Coup",
        cause = "low_noble_loyalty",
        threshold = 40,
        strength = 80,
        duration = 60,
        spreadChance = 0.15,
        description = "Nezadovoljni plemiči poskušajo prevzeti oblast.",
        units = { "knight", "knight", "swordsman", "archer" },
        demands = { "more_privileges", "lower_taxes" },
    },
    religious_schism = {
        name = "Verski razkol",
        nameEn = "Religious Schism",
        cause = "heresy_high",
        threshold = 50,
        strength = 65,
        duration = 45,
        spreadChance = 0.30,
        description = "Verniki se ločijo od državne vere.",
        units = { "zealot", "zealot", "fanatic" },
        demands = { "religious_freedom", "stop_inquisition" },
    },
    army_mutiny = {
        name = "Vojaška vstaja",
        nameEn = "Army Mutiny",
        cause = "unpaid_troops",
        threshold = 0,  -- triggered by gold shortage
        strength = 100,
        duration = 20,
        spreadChance = 0.40,
        description = "Neplačani vojaki odkynejo ukaze.",
        units = { "swordsman", "archer", "knight" },
        demands = { "pay_wages", "new_commander" },
    },
    succession_crisis = {
        name = "Kriza nasledstva",
        nameEn = "Succession Crisis",
        cause = "no_heir",
        threshold = 0,
        strength = 90,
        duration = 90,
        spreadChance = 0.10,
        description = "Brez jasnga dediča se začne boj za oblast.",
        units = { "knight", "knight", "knight", "swordsman" },
        demands = { "name_heir", "support_claimant" },
    },
    foreign_uprising = {
        name = "Tujim sponzoriran upor",
        nameEn = "Foreign-Sponsored Uprising",
        cause = "foreign_agent",
        threshold = 0,
        strength = 75,
        duration = 40,
        spreadChance = 0.25,
        description = "Tuje sile podpirajo upornike v tvoji deželi.",
        units = { "mercenary", "mercenary", "swordsman" },
        demands = { "change_alliance", "release_territory" },
    },
}

-- ============================================================
-- PACIFICATION OPTIONS
-- ============================================================
local PACIFICATION_OPTIONS = {
    send_gifts = {
        name = "Pošlji darila",
        cost = { gold = 500 },
        loyaltyGain = 5,
        happinessGain = 3,
        cooldown = 30,
        description = "Razdeli zlato in hrano ljudstvu.",
    },
    reduce_taxes = {
        name = "Zmanjšaj davke",
        cost = {},
        loyaltyGain = 15,
        happinessGain = 10,
        goldProductionPenalty = 0.7,  -- 30% less gold
        cooldown = 90,
        description = "Začasno zmanjšaj davke za 30 dni.",
    },
    hold_festival = {
        name = "Priredi festival",
        cost = { gold = 300, food = 100 },
        loyaltyGain = 10,
        happinessGain = 15,
        cooldown = 60,
        description = "Javni festival za pomiritev ljudstva.",
    },
    execute_leaders = {
        name = "Usmrti vodje",
        cost = {},
        loyaltyGain = -10,  -- makes it worse short-term
        happinessGain = -15,
        rebellionStrengthReduction = 0.50,  -- but weakens rebellion
        cooldown = 120,
        description = "Usmrti vodje upora — kruto a učinkovito.",
    },
    grant_amnesty = {
        name = "Podeli amnestijo",
        cost = {},
        loyaltyGain = 20,
        happinessGain = 8,
        rebellionEndChance = 0.60,
        cooldown = 90,
        description = "Oprosti upornikom in jih sprejmi nazaj.",
    },
    military_crackdown = {
        name = "Vojaško zatiranje",
        cost = { gold = 200 },
        loyaltyGain = -5,
        happinessGain = -20,
        rebellionStrengthReduction = 0.70,
        cooldown = 60,
        description = "Pošlji vojsko, da zatre upor s silo.",
    },
}

-- ============================================================
-- STATE
-- ============================================================
Rebellion.activeRebellions = {}      -- Currently active rebellions
Rebellion.regionLoyalty = {}         -- Loyalty per region (0-100)
Rebellion.nobleLoyalty = {}          -- Loyalty per noble (0-100)
Rebellion.unrestLevel = 0            -- Global unrest (0-100)
Rebellion.conspiracies = {}          -- Detected conspiracies
Rebellion.undetectedConspiracies = {} -- Hidden conspiracies
Rebellion.pacificationCooldowns = {} -- Cooldowns per option
Rebellion.activeCivilWar = nil       -- Civil war state
Rebellion.totalRebellions = 0
Rebellion.totalSuppressed = 0
Rebellion.dayTimer = 0

-- ============================================================
-- INITIALIZATION
-- ============================================================
function Rebellion.init()
    Rebellion.activeRebellions = {}
    Rebellion.regionLoyalty = {}
    Rebellion.nobleLoyalty = {}
    Rebellion.unrestLevel = 0
    Rebellion.conspiracies = {}
    Rebellion.undetectedConspiracies = {}
    Rebellion.pacificationCooldowns = {}
    Rebellion.activeCivilWar = nil
    Rebellion.totalRebellions = 0
    Rebellion.totalSuppressed = 0
    Rebellion.dayTimer = 0
    print("[Rebellion] Treason & Rebellion System initialized (6 types, 6 pacification options)")
end

-- ============================================================
-- LOYALTY MANAGEMENT
-- ============================================================
function Rebellion.setRegionLoyalty(regionId, value)
    Rebellion.regionLoyalty[regionId] = math.max(0, math.min(100, value))
end

function Rebellion.changeRegionLoyalty(regionId, delta)
    local current = Rebellion.regionLoyalty[regionId] or 75
    Rebellion.setRegionLoyalty(regionId, current + delta)
end

function Rebellion.setNobleLoyalty(nobleId, value)
    Rebellion.nobleLoyalty[nobleId] = math.max(0, math.min(100, value))
end

function Rebellion.changeNobleLoyalty(nobleId, delta)
    local current = Rebellion.nobleLoyalty[nobleId] or 75
    Rebellion.setNobleLoyalty(nobleId, current + delta)
end

function Rebellion.updateGlobalUnrest()
    -- Calculate from average happiness, taxes, active rebellions
    local unrest = 0
    if _G.state and _G.state.happiness then
        unrest = unrest + (50 - _G.state.happiness) * 0.5
    end
    -- Tax rate (assume stored in state)
    local taxRate = (_G.state and _G.state.taxRate) or 10
    unrest = unrest + (taxRate - 10) * 1.5
    -- Active rebellions add to unrest
    unrest = unrest + #Rebellion.activeRebellions * 5
    -- Heresy
    if _G.Religion and _G.Religion.heresyLevel then
        unrest = unrest + _G.Religion.heresyLevel * 0.2
    end
    -- Famine
    if _G.Famine and #(_G.Famine.activeEvents or {}) > 0 then
        unrest = unrest + 10
    end
    Rebellion.unrestLevel = math.max(0, math.min(100, unrest))
end

-- ============================================================
-- REBELLION TRIGGERING
-- ============================================================
function Rebellion.checkRebellionTriggers()
    -- Peasant revolt
    if _G.state and _G.state.happiness and _G.state.happiness < 30 then
        if math.random() < 0.05 then
            Rebellion.triggerRebellion("peasant_revolt")
        end
    end
    -- Noble coup
    local lowLoyaltyNobles = 0
    for _, loyalty in pairs(Rebellion.nobleLoyalty) do
        if loyalty < 40 then lowLoyaltyNobles = lowLoyaltyNobles + 1 end
    end
    if lowLoyaltyNobles >= 2 and math.random() < 0.03 then
        Rebellion.triggerRebellion("noble_coup")
    end
    -- Army mutiny (low gold)
    if _G.state and (_G.state.gold or 0) < 50 and math.random() < 0.04 then
        Rebellion.triggerRebellion("army_mutiny")
    end
    -- Religious schism
    if _G.Religion and (_G.Religion.heresyLevel or 0) > 50 and math.random() < 0.03 then
        Rebellion.triggerRebellion("religious_schism")
    end
    -- Random foreign-sponsored (very rare)
    if math.random() < 0.005 then
        Rebellion.triggerRebellion("foreign_uprising")
    end
end

function Rebellion.triggerRebellion(rebellionType, regionId)
    local def = REBELLION_TYPES[rebellionType]
    if not def then return false, "Neznan tip upora" end
    -- Check if already active
    for _, r in ipairs(Rebellion.activeRebellions) do
        if r.type == rebellionType and r.regionId == (regionId or "main") then
            return false, "Upor že aktiven"
        end
    end
    local rebellion = {
        id = "rebellion_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
        type = rebellionType,
        name = def.name,
        regionId = regionId or "main",
        strength = def.strength,
        daysRemaining = def.duration,
        totalDays = def.duration,
        spreadChance = def.spreadChance,
        units = def.units,
        demands = def.demands,
        negotiationAttempts = 0,
        suppressed = false,
    }
    table.insert(Rebellion.activeRebellions, rebellion)
    Rebellion.totalRebellions = Rebellion.totalRebellions + 1
    -- Spawn rebel units
    if _G.CombatIntegration and _G.CombatIntegration.spawnEnemyUnit then
        for _, unitType in ipairs(def.units) do
            for _ = 1, 5 do  -- spawn 5 of each
                pcall(_G.CombatIntegration.spawnEnemyUnit, unitType,
                    500 + math.random(-100, 100), 500 + math.random(-100, 100))
            end
        end
    end
    -- Notification
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "UPOR! " .. def.name .. " izbruhnil!", "danger")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "REBELLION_STARTED", {
            type = rebellionType, regionId = regionId, strength = def.strength,
        })
    end
    -- Check if civil war
    if #Rebellion.activeRebellions >= 3 then
        Rebellion.startCivilWar()
    end
    return true
end

-- ============================================================
-- CIVIL WAR
-- ============================================================
function Rebellion.startCivilWar()
    if Rebellion.activeCivilWar then return end
    Rebellion.activeCivilWar = {
        started = os.time(),
        regionsLost = {},
        battlesFought = 0,
    }
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "DRŽAVLJANSKA VOJNA! Dežela razklana!", "danger")
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "CIVIL_WAR_STARTED", {})
    end
end

function Rebellion.endCivilWar()
    if not Rebellion.activeCivilWar then return end
    Rebellion.activeCivilWar = nil
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Državljanska vojna končana!", "success")
    end
end

-- ============================================================
-- PACIFICATION
-- ============================================================
function Rebellion.canPacify(optionId)
    local def = PACIFICATION_OPTIONS[optionId]
    if not def then return false, "Neznana opcija" end
    -- Check cooldown
    local cd = Rebellion.pacificationCooldowns[optionId] or 0
    if cd > 0 then return false, "Opcija v pripravljenosti" end
    -- Check costs
    if not _G.state then return false, "Brez stanja" end
    if def.cost.gold and (_G.state.gold or 0) < def.cost.gold then
        return false, "Premalo zlata"
    end
    if def.cost.food and _G.state.resources and
       (_G.state.resources.food or 0) < def.cost.food then
        return false, "Premalo hrane"
    end
    return true
end

function Rebellion.pacify(optionId)
    local ok, err = Rebellion.canPacify(optionId)
    if not ok then return false, err end
    local def = PACIFICATION_OPTIONS[optionId]
    -- Pay costs
    if def.cost.gold then _G.state.gold = _G.state.gold - def.cost.gold end
    if def.cost.food and _G.state.resources then
        _G.state.resources.food = (_G.state.resources.food or 0) - def.cost.food
    end
    -- Apply effects
    if def.loyaltyGain then
        for region, _ in pairs(Rebellion.regionLoyalty) do
            Rebellion.changeRegionLoyalty(region, def.loyaltyGain)
        end
        for noble, _ in pairs(Rebellion.nobleLoyalty) do
            Rebellion.changeNobleLoyalty(noble, def.loyaltyGain)
        end
    end
    if def.happinessGain and _G.state.happiness then
        _G.state.happiness = math.max(0, math.min(100,
            _G.state.happiness + def.happinessGain))
    end
    -- Rebellion strength reduction
    if def.rebellionStrengthReduction then
        for _, r in ipairs(Rebellion.activeRebellions) do
            r.strength = r.strength * (1 - def.rebellionStrengthReduction)
            if r.strength < 10 then
                Rebellion.suppressRebellion(r.id, true)
            end
        end
    end
    -- End rebellion chance (amnesty)
    if def.rebellionEndChance then
        for i = #Rebellion.activeRebellions, 1, -1 do
            local r = Rebellion.activeRebellions[i]
            if math.random() < def.rebellionEndChance then
                Rebellion.suppressRebellion(r.id, true)
            end
        end
    end
    -- Gold production penalty (reduce_taxes)
    if def.goldProductionPenalty and _G.state then
        _G.state.taxPenalty = { mult = def.goldProductionPenalty, daysRemaining = 30 }
    end
    -- Set cooldown
    Rebellion.pacificationCooldowns[optionId] = def.cooldown
    -- Notify
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify, "Pacifikacija: " .. def.name, "info")
    end
    return true
end

-- ============================================================
-- CONSPIRACY DETECTION
-- ============================================================
function Rebellion.generateConspiracy()
    local types = { "assassination_plot", "coup_attempt", "foreign_espionage", "tax_evasion_ring" }
    local conspiracy = {
        id = "conspiracy_" .. tostring(os.time()),
        type = types[math.random(#types)],
        detected = false,
        detectionChance = 0.10,  -- per day if no espionage
        progress = 0,
        completionThreshold = 100,
        daysRemaining = math.random(20, 60),
    }
    table.insert(Rebellion.undetectedConspiracies, conspiracy)
    return conspiracy
end

function Rebellion.attemptDetection()
    -- Espionage skill increases detection chance
    local baseChance = 0.10
    if _G.EspionageSystem and _G.EspionageSystem.getDetectionBonus then
        local ok, bonus = pcall(_G.EspionageSystem.getDetectionBonus)
        if ok then baseChance = baseChance + bonus end
    end
    for i = #Rebellion.undetectedConspiracies, 1, -1 do
        local c = Rebellion.undetectedConspiracies[i]
        if math.random() < baseChance then
            c.detected = true
            table.insert(Rebellion.conspiracies, c)
            table.remove(Rebellion.undetectedConspiracies, i)
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, "Zarota odkrita! Tip: " .. c.type, "warning")
            end
            if _G.GameEventBus then
                pcall(_G.GameEventBus.publish, "CONSPIRACY_DETECTED", { type = c.type })
            end
        end
    end
end

function Rebellion.exposeConspiracy(conspiracyId)
    for i, c in ipairs(Rebellion.conspiracies) do
        if c.id == conspiracyId then
            table.remove(Rebellion.conspiracies, i)
            -- Boost loyalty
            for region, _ in pairs(Rebellion.regionLoyalty) do
                Rebellion.changeRegionLoyalty(region, 5)
            end
            if _G.NotificationCenter then
                pcall(_G.NotificationCenter.notify, "Zarota razkrita javnosti!", "success")
            end
            return true
        end
    end
    return false
end

function Rebellion.updateConspiracies()
    -- Progress undetected conspiracies
    for i = #Rebellion.undetectedConspiracies, 1, -1 do
        local c = Rebellion.undetectedConspiracies[i]
        c.progress = c.progress + (100 / c.daysRemaining)
        c.daysRemaining = c.daysRemaining - 1
        if c.daysRemaining <= 0 then
            -- Conspiracy succeeds!
            Rebellion.executeConspiracy(c)
            table.remove(Rebellion.undetectedConspiracies, i)
        end
    end
end

function Rebellion.executeConspiracy(conspiracy)
    if conspiracy.type == "assassination_plot" then
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Atentat! Vladar ubit!", "danger")
        end
        if _G.Court and _G.Court.killRuler then
            pcall(_G.Court.killRuler)
        end
        Rebellion.triggerRebellion("succession_crisis")
    elseif conspiracy.type == "coup_attempt" then
        Rebellion.triggerRebellion("noble_coup")
    elseif conspiracy.type == "foreign_espionage" then
        Rebellion.triggerRebellion("foreign_uprising")
    elseif conspiracy.type == "tax_evasion_ring" then
        if _G.state then
            _G.state.gold = math.max(0, (_G.state.gold or 0) - 1000)
        end
        if _G.NotificationCenter then
            pcall(_G.NotificationCenter.notify, "Davčna goljufija odkrita prepozno! -1000 zlata", "warning")
        end
    end
end

-- ============================================================
-- REBELLION SUPPRESSION
-- ============================================================
function Rebellion.suppressRebellion(rebellionId, peaceful)
    for i, r in ipairs(Rebellion.activeRebellions) do
        if r.id == rebellionId then
            r.suppressed = true
            table.remove(Rebellion.activeRebellions, i)
            Rebellion.totalSuppressed = Rebellion.totalSuppressed + 1
            if peaceful then
                for region, _ in pairs(Rebellion.regionLoyalty) do
                    Rebellion.changeRegionLoyalty(region, 8)
                end
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify, "Upor mirno zatrt: " .. r.name, "success")
                end
            else
                for region, _ in pairs(Rebellion.regionLoyalty) do
                    Rebellion.changeRegionLoyalty(region, -3)
                end
                if _G.NotificationCenter then
                    pcall(_G.NotificationCenter.notify, "Upor zatrt s silo: " .. r.name, "warning")
                end
            end
            if _G.GameEventBus then
                pcall(_G.GameEventBus.publish, "REBELLION_SUPPRESSED", {
                    type = r.type, peaceful = peaceful,
                })
            end
            -- Check if civil war ends
            if Rebellion.activeCivilWar and #Rebellion.activeRebellions == 0 then
                Rebellion.endCivilWar()
            end
            return true
        end
    end
    return false
end

function Rebellion.updateRebellions()
    for i = #Rebellion.activeRebellions, 1, -1 do
        local r = Rebellion.activeRebellions[i]
        r.daysRemaining = r.daysRemaining - 1
        -- Spread chance
        if math.random() < r.spreadChance * 0.1 then
            -- Spread to another region
            local regions = {}
            for region, _ in pairs(Rebellion.regionLoyalty) do
                if region ~= r.regionId then
                    table.insert(regions, region)
                end
            end
            if #regions > 0 then
                local newRegion = regions[math.random(#regions)]
                Rebellion.triggerRebellion(r.type, newRegion)
            end
        end
        -- Auto-suppress if strength too low
        if r.strength < 5 then
            Rebellion.suppressRebellion(r.id, true)
        elseif r.daysRemaining <= 0 then
            -- Time ran out — rebels won
            Rebellion.rebellionVictory(r)
            table.remove(Rebellion.activeRebellions, i)
        end
    end
end

function Rebellion.rebellionVictory(rebellion)
    if _G.NotificationCenter then
        pcall(_G.NotificationCenter.notify,
            "Uporniki zmagali! " .. rebellion.name .. " prevzame oblast.", "danger")
    end
    -- Apply demands
    for _, demand in ipairs(rebellion.demains or {}) do
        if demand == "reduce_taxes" and _G.state then
            _G.state.taxRate = math.max(0, (_G.state.taxRate or 10) - 5)
        elseif demand == "increase_food" and _G.state and _G.state.resources then
            _G.state.resources.food = (_G.state.resources.food or 0) + 500
        end
    end
    if _G.GameEventBus then
        pcall(_G.GameEventBus.publish, "REBELLION_VICTORY", { type = rebellion.type })
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function Rebellion.update(dt)
    if not _G.state then return end
    Rebellion.dayTimer = Rebellion.dayTimer + dt
    if Rebellion.dayTimer >= 30 then
        Rebellion.dayTimer = 0
        Rebellion.updateGlobalUnrest()
        Rebellion.checkRebellionTriggers()
        Rebellion.updateRebellions()
        Rebellion.attemptDetection()
        Rebellion.updateConspiracies()
        -- Generate new conspiracies occasionally
        if math.random() < 0.05 then
            Rebellion.generateConspiracy()
        end
        -- Reduce cooldowns
        for option, cd in pairs(Rebellion.pacificationCooldowns) do
            if cd > 0 then
                Rebellion.pacificationCooldowns[option] = cd - 1
            end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function Rebellion.getRebellionTypeInfo(typeId) return REBELLION_TYPES[typeId] end
function Rebellion.getPacificationInfo(optionId) return PACIFICATION_OPTIONS[optionId] end

function Rebellion.getStats()
    return {
        activeRebellions = #Rebellion.activeRebellions,
        totalRebellions = Rebellion.totalRebellions,
        totalSuppressed = Rebellion.totalSuppressed,
        unrestLevel = Rebellion.unrestLevel,
        civilWar = Rebellion.activeCivilWar ~= nil,
        detectedConspiracies = #Rebellion.conspiracies,
        pendingConspiracies = #Rebellion.undetectedConspiracies,
        averageLoyalty = Rebellion.calculateAverageLoyalty(),
    }
end

function Rebellion.calculateAverageLoyalty()
    local sum, count = 0, 0
    for _, l in pairs(Rebellion.regionLoyalty) do
        sum = sum + l; count = count + 1
    end
    for _, l in pairs(Rebellion.nobleLoyalty) do
        sum = sum + l; count = count + 1
    end
    if count == 0 then return 75 end
    return sum / count
end

return Rebellion
