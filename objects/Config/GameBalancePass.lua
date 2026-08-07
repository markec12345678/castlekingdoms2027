-- objects/Config/GameBalancePass.lua
-- Castle Kingdoms 2027 - Game Balance Pass
-- Fine-tunes economy, combat, and AI based on playtesting data

local GameBalancePass = {}

-- ============================================================
-- ECONOMY BALANCE
-- ============================================================

local ECONOMY_ADJUSTMENTS = {
    -- Starting resources (slightly more generous for new players)
    startingGold = 500,
    startingWood = 40,   -- was 30
    startingStone = 15,  -- was 10
    startingFood = 25,   -- was 20

    -- Gathering rates (slightly faster for better pacing)
    gatheringRates = {
        woodcutter = 14,   -- was 12
        quarry = 9,         -- was 8
        ironMine = 6,       -- was 5
        pitchRig = 5,       -- was 4
        wheatFarm = 12,     -- was 10
        orchard = 9,        -- was 8
        dairyFarm = 7,      -- was 6
        hopsFarm = 9,       -- was 8
        hunterHut = 6,      -- was 5
    },

    -- Production efficiency (slightly improved)
    productionEfficiency = {
        windmill = 0.85,    -- was 0.80
        bakery = 0.80,      -- was 0.75
        brewery = 0.67,     -- was 0.625
        fletcher = 0.55,    -- was 0.50
        poleturner = 0.55,  -- was 0.50
        blacksmith = 0.55,  -- was 0.50
        armorer = 0.38,     -- was 0.33
    },

    -- Market (slightly better for player)
    marketSpread = 0.72,   -- was 0.70 (higher = better sell price)
    caravanBonusMultiplier = 1.35,  -- was 1.30

    -- Inflation (less aggressive)
    inflation = {
        baseline = 0.00008,  -- was 0.0001
        goldCirculationDivisor = 120000,  -- was 100000
        maxInflation = 0.25,  -- was 0.30
    },

    -- Population growth (faster early game)
    populationGrowthRate = 1.2,  -- 20% faster
    maxPopulationPerHouse = 4,
}

-- ============================================================
-- COMBAT BALANCE
-- ============================================================

local COMBAT_ADJUSTMENTS = {
    units = {
        -- Slightly more health for survivability
        Archer       = { health = 55,  damage = 14, armor = 0.05, range = 8,  cooldown = 0.7 },
        Crossbowman  = { health = 65,  damage = 28, armor = 0.10, range = 12, cooldown = 1.1 },
        Spearman     = { health = 75,  damage = 16, armor = 0.20, range = 1.5, cooldown = 1.4 },
        Pikeman      = { health = 100, damage = 22, armor = 0.30, range = 1.5, cooldown = 1.4 },
        Maceman      = { health = 110, damage = 20, armor = 0.25, range = 1.5, cooldown = 1.2 },
        Swordsman    = { health = 130, damage = 25, armor = 0.35, range = 1.5, cooldown = 1.3 },
        Knight       = { health = 200, damage = 35, armor = 0.50, range = 1.5, cooldown = 1.5 },
        Lord         = { health = 600, damage = 55, armor = 0.65, range = 1.5, cooldown = 1.4 },
        Peasant      = { health = 35,  damage = 6,  armor = 0.00, range = 1.5, cooldown = 1.8 },
    },

    -- Damage variance (tighter for more predictable combat)
    damageVariance = { min = 0.92, max = 1.08 },  -- was 0.9-1.1

    -- Retreat (slightly later for more committed fights)
    retreatThreshold = 0.15,  -- was 0.20 (retreat at 15% HP instead of 20%)

    -- Aggro range (slightly larger for better responsiveness)
    aggroRange = 14,  -- was 12

    cooldowns = { melee = 1.4, ranged = 0.7, siege = 2.8 },
    ranges = { melee = 1.5, short = 5, medium = 8, long = 12, siege = 20 },
}

-- ============================================================
-- AI BALANCE
-- ============================================================

local AI_ADJUSTMENTS = {
    personalities = {
        aggressive = {
            economyFocus = 0.35, militaryFocus = 0.65,
            attackThreshold = 4, attackChancePerMin = 0.6,
            defensePriority = 0.55, retreatThreshold = 0.08, aggroRange = 16,
        },
        balanced = {
            economyFocus = 0.50, militaryFocus = 0.50,
            attackThreshold = 8, attackChancePerMin = 0.35,
            defensePriority = 0.75, retreatThreshold = 0.20, aggroRange = 13,
        },
        defensive = {
            economyFocus = 0.70, militaryFocus = 0.30,
            attackThreshold = 15, attackChancePerMin = 0.12,
            defensePriority = 0.92, retreatThreshold = 0.35, aggroRange = 9,
        },
        economic = {
            economyFocus = 0.80, militaryFocus = 0.20,
            attackThreshold = 25, attackChancePerMin = 0.06,
            defensePriority = 0.65, retreatThreshold = 0.22, aggroRange = 12,
        },
    },

    -- Reduced cheat bonuses further (more fair)
    difficulties = {
        easy   = { decisionInterval = 5.0, resourceEfficiency = 0.55, cheatBonus = 0,    maxArmySize = 12, defenseResponseTime = 12 },
        medium = { decisionInterval = 3.0, resourceEfficiency = 0.75, cheatBonus = 0,    maxArmySize = 22, defenseResponseTime = 6 },
        hard   = { decisionInterval = 1.5, resourceEfficiency = 0.90, cheatBonus = 0.10, maxArmySize = 35, defenseResponseTime = 3 },
        brutal = { decisionInterval = 0.8, resourceEfficiency = 1.0,  cheatBonus = 0.20, maxArmySize = 50, defenseResponseTime = 1 },
    },

    behavior = {
        attackGracePeriod = 360,  -- 6 min (was 5)
        retreatWhenOutnumbered = true,
        outnumberedRatio = 0.45,  -- was 0.5 (retreat sooner)
        defenseRallyRange = 25,   -- was 20 (larger rally)
        rebuildLostBuildings = true,
        rebuildDelay = 45,        -- was 60 (faster rebuild)
    },
}

-- ============================================================
-- BUILDING COST BALANCE
-- ============================================================

local BUILDING_COST_ADJUSTMENTS = {
    -- Slightly cheaper early-game buildings
    Stockpile       = { wood = 8,   stone = 0,   gold = 0,   buildTime = 4 },
    Granary         = { wood = 25,  stone = 5,   gold = 0,   buildTime = 12 },
    Woodcutter      = { wood = 4,   stone = 0,   gold = 0,   buildTime = 4 },
    Quarry          = { wood = 12,  stone = 0,   gold = 0,   buildTime = 8 },
    IronMine        = { wood = 18,  stone = 5,   gold = 0,   buildTime = 12 },
    WheatFarm       = { wood = 12,  stone = 0,   gold = 0,   buildTime = 8 },
    Orchard         = { wood = 18,  stone = 0,   gold = 0,   buildTime = 8 },
    Barracks        = { wood = 20,  stone = 15,  gold = 0,   buildTime = 18 },
    Market          = { wood = 25,  stone = 12,  gold = 40,  buildTime = 25 },
}

-- ============================================================
-- APPLY FUNCTIONS
-- ============================================================

local initialized = false

function GameBalancePass.init()
    if initialized then return end
    initialized = true
    print("[GameBalancePass] Initialized")
    print("[GameBalancePass] Economy: faster gathering, less inflation")
    print("[GameBalancePass] Combat: more health, tighter damage variance")
    print("[GameBalancePass] AI: reduced cheats, longer grace period")
end

-- Apply all balance adjustments to BalanceConfig
function GameBalancePass.applyAll()
    local BalanceConfig = require("objects.Config.BalanceConfig")

    -- Apply economy
    if BalanceConfig.economy then
        for k, v in pairs(ECONOMY_ADJUSTMENTS) do
            if type(v) == "table" then
                if not BalanceConfig.economy[k] then BalanceConfig.economy[k] = {} end
                for k2, v2 in pairs(v) do
                    BalanceConfig.economy[k][k2] = v2
                end
            else
                BalanceConfig.economy[k] = v
            end
        end
    end

    -- Apply combat
    if BalanceConfig.combat and BalanceConfig.combat.units then
        for unitName, stats in pairs(COMBAT_ADJUSTMENTS.units) do
            if BalanceConfig.combat.units[unitName] then
                for k, v in pairs(stats) do
                    BalanceConfig.combat.units[unitName][k] = v
                end
            else
                BalanceConfig.combat.units[unitName] = stats
            end
        end
        BalanceConfig.combat.damageVariance = COMBAT_ADJUSTMENTS.damageVariance
        BalanceConfig.combat.retreatThreshold = COMBAT_ADJUSTMENTS.retreatThreshold
        BalanceConfig.combat.aggroRange = COMBAT_ADJUSTMENTS.aggroRange
        BalanceConfig.combat.cooldowns = COMBAT_ADJUSTMENTS.cooldowns
        BalanceConfig.combat.ranges = COMBAT_ADJUSTMENTS.ranges
    end

    -- Apply AI
    if BalanceConfig.ai then
        for personality, stats in pairs(AI_ADJUSTMENTS.personalities) do
            if BalanceConfig.ai.personalities[personality] then
                for k, v in pairs(stats) do
                    BalanceConfig.ai.personalities[personality][k] = v
                end
            end
        end
        for difficulty, stats in pairs(AI_ADJUSTMENTS.difficulties) do
            if BalanceConfig.ai.difficulties[difficulty] then
                for k, v in pairs(stats) do
                    BalanceConfig.ai.difficulties[difficulty][k] = v
                end
            end
        end
        for k, v in pairs(AI_ADJUSTMENTS.behavior) do
            BalanceConfig.ai.behavior[k] = v
        end
    end

    -- Apply building costs
    if BalanceConfig.buildings then
        for building, cost in pairs(BUILDING_COST_ADJUSTMENTS) do
            if BalanceConfig.buildings[building] then
                for k, v in pairs(cost) do
                    BalanceConfig.buildings[building][k] = v
                end
            end
        end
    end

    print("[GameBalancePass] All balance adjustments applied to BalanceConfig")
end

-- Get adjustment summary
function GameBalancePass.getSummary()
    return {
        economy = {
            startingWood = "30 → 40 (+33%)",
            gatheringWoodcutter = "12 → 14 (+17%)",
            inflationBaseline = "0.0001 → 0.00008 (-20%)",
        },
        combat = {
            archerHealth = "50 → 55 (+10%)",
            knightHealth = "180 → 200 (+11%)",
            damageVariance = "0.9-1.1 → 0.92-1.08 (tighter)",
            retreatThreshold = "0.20 → 0.15 (later retreat)",
        },
        ai = {
            brutalCheatBonus = "0.30 → 0.20 (-33%)",
            attackGracePeriod = "300s → 360s (+20%)",
            rebuildDelay = "60s → 45s (-25%)",
        },
        buildings = {
            stockpileWood = "10 → 8 (-20%)",
            barracksBuildTime = "20 → 18 (-10%)",
        },
    }
end

-- Print balance report
function GameBalancePass.printReport()
    local summary = GameBalancePass.getSummary()
    print("\n" .. string.rep("=", 50))
    print("GAME BALANCE PASS REPORT")
    print(string.rep("=", 50))

    print("\n[Economy]")
    for k, v in pairs(summary.economy) do
        print("  " .. k .. ": " .. v)
    end

    print("\n[Combat]")
    for k, v in pairs(summary.combat) do
        print("  " .. k .. ": " .. v)
    end

    print("\n[AI]")
    for k, v in pairs(summary.ai) do
        print("  " .. k .. ": " .. v)
    end

    print("\n[Buildings]")
    for k, v in pairs(summary.buildings) do
        print("  " .. k .. ": " .. v)
    end

    print(string.rep("=", 50))
end

return GameBalancePass
