-- objects/Config/BalanceConfig.lua
-- Stronghold 2027 - Balance Configuration
--
-- Centralized balance values for easy tuning.
-- All gameplay numbers should reference this file.

local BalanceConfig = {}

-- === ECONOMY BALANCE ===
BalanceConfig.economy = {
    startingGold = 500,
    startingWood = 30,
    startingStone = 10,
    startingFood = 20,

    gatheringRates = {
        woodcutter = 12, quarry = 8, ironMine = 5, pitchRig = 4,
        wheatFarm = 10, orchard = 8, dairyFarm = 6, hopsFarm = 8, hunterHut = 5,
    },

    productionEfficiency = {
        windmill = 0.80, bakery = 0.75, brewery = 0.625,
        fletcher = 0.50, poleturner = 0.50, blacksmith = 0.50, armorer = 0.33,
    },

    marketSpread = 0.70,
    caravanBonusMultiplier = 1.30,

    inflation = {
        baseline = 0.0001,
        goldCirculationDivisor = 100000,
        maxInflation = 0.30,
    },
}

-- === COMBAT BALANCE ===
BalanceConfig.combat = {
    units = {
        Archer       = { health = 50,  damage = 12, armor = 0.05, range = 8,  cooldown = 0.8, cost = { gold = 50,  wood = 5  } },
        Crossbowman  = { health = 60,  damage = 25, armor = 0.10, range = 12, cooldown = 1.2, cost = { gold = 80,  wood = 10 } },
        Spearman     = { health = 70,  damage = 15, armor = 0.15, range = 1.5, cooldown = 1.5, cost = { gold = 30,  wood = 5  } },
        Pikeman      = { health = 90,  damage = 20, armor = 0.25, range = 1.5, cooldown = 1.5, cost = { gold = 60,  wood = 10 } },
        Maceman      = { health = 100, damage = 18, armor = 0.20, range = 1.5, cooldown = 1.3, cost = { gold = 50,  iron = 5  } },
        Swordsman    = { health = 120, damage = 22, armor = 0.30, range = 1.5, cooldown = 1.4, cost = { gold = 80,  iron = 10 } },
        Knight       = { health = 180, damage = 30, armor = 0.45, range = 1.5, cooldown = 1.6, cost = { gold = 150, iron = 20 } },
        Lord         = { health = 500, damage = 50, armor = 0.60, range = 1.5, cooldown = 1.5, cost = { gold = 0                } },
        Peasant      = { health = 30,  damage = 5,  armor = 0.00, range = 1.5, cooldown = 2.0, cost = { gold = 0,   food = 1  } },
        -- Stronghold 2027 v2.5.4: 4 new Norman-era units
        Huscarl      = { health = 150, damage = 28, armor = 0.40, range = 1.5, cooldown = 1.4, cost = { gold = 120, iron = 15 } },
        Longbowman   = { health = 55,  damage = 18, armor = 0.05, range = 11,  cooldown = 0.9, cost = { gold = 70,  wood = 8  } },
        NormanKnight = { health = 220, damage = 35, armor = 0.55, range = 1.5, cooldown = 1.7, cost = { gold = 200, iron = 25 } },
        Javelinman   = { health = 65,  damage = 16, armor = 0.10, range = 6,   cooldown = 1.1, cost = { gold = 40,  wood = 5  } },
    },

    damageVariance = { min = 0.9, max = 1.1 },
    retreatThreshold = 0.20,
    aggroRange = 12,

    cooldowns = { melee = 1.5, ranged = 0.8, siege = 3.0 },
    ranges = { melee = 1.5, short = 5, medium = 8, long = 12, siege = 20 },
}

-- === AI BALANCE ===
BalanceConfig.ai = {
    personalities = {
        aggressive = {
            economyFocus = 0.3, militaryFocus = 0.7,
            attackThreshold = 5, attackChancePerMin = 0.5,
            defensePriority = 0.5, retreatThreshold = 0.10, aggroRange = 15,
        },
        balanced = {
            economyFocus = 0.5, militaryFocus = 0.5,
            attackThreshold = 10, attackChancePerMin = 0.3,
            defensePriority = 0.7, retreatThreshold = 0.25, aggroRange = 12,
        },
        defensive = {
            economyFocus = 0.7, militaryFocus = 0.3,
            attackThreshold = 20, attackChancePerMin = 0.1,
            defensePriority = 0.9, retreatThreshold = 0.40, aggroRange = 8,
        },
        economic = {
            economyFocus = 0.85, militaryFocus = 0.15,
            attackThreshold = 30, attackChancePerMin = 0.05,
            defensePriority = 0.6, retreatThreshold = 0.25, aggroRange = 12,
        },
    },

    -- Reduced cheat bonuses after playtesting feedback
    difficulties = {
        easy = { decisionInterval = 5.0, resourceEfficiency = 0.6, cheatBonus = 0, maxArmySize = 15, defenseResponseTime = 10 },
        medium = { decisionInterval = 3.0, resourceEfficiency = 0.8, cheatBonus = 0, maxArmySize = 25, defenseResponseTime = 5 },
        hard = { decisionInterval = 1.5, resourceEfficiency = 0.95, cheatBonus = 0.15, maxArmySize = 40, defenseResponseTime = 2 },
        brutal = { decisionInterval = 0.8, resourceEfficiency = 1.0, cheatBonus = 0.30, maxArmySize = 60, defenseResponseTime = 1 },
    },

    behavior = {
        attackGracePeriod = 300,  -- 5 min no-attack grace
        retreatWhenOutnumbered = true,
        outnumberedRatio = 0.5,
        defenseRallyRange = 20,
        rebuildLostBuildings = true,
        rebuildDelay = 60,
    },
}

-- === BUILDING COSTS ===
BalanceConfig.buildings = {
    Stockpile       = { wood = 10,  stone = 0,   gold = 0,   buildTime = 5  },
    Granary         = { wood = 30,  stone = 5,   gold = 0,   buildTime = 15 },
    Woodcutter      = { wood = 5,   stone = 0,   gold = 0,   buildTime = 5  },
    Quarry          = { wood = 15,  stone = 0,   gold = 0,   buildTime = 10 },
    IronMine        = { wood = 20,  stone = 5,   gold = 0,   buildTime = 15 },
    PitchRig        = { wood = 25,  stone = 0,   gold = 0,   buildTime = 15 },
    WheatFarm       = { wood = 15,  stone = 0,   gold = 0,   buildTime = 10 },
    Orchard         = { wood = 20,  stone = 0,   gold = 0,   buildTime = 10 },
    DairyFarm       = { wood = 20,  stone = 5,   gold = 0,   buildTime = 12 },
    HopsFarm        = { wood = 20,  stone = 5,   gold = 0,   buildTime = 12 },
    HunterHut       = { wood = 10,  stone = 0,   gold = 0,   buildTime = 8  },
    Windmill        = { wood = 30,  stone = 10,  gold = 0,   buildTime = 20 },
    Bakery          = { wood = 25,  stone = 10,  gold = 0,   buildTime = 20 },
    Brewery         = { wood = 30,  stone = 10,  gold = 0,   buildTime = 25 },
    Inn             = { wood = 40,  stone = 20,  gold = 0,   buildTime = 30 },
    Market          = { wood = 30,  stone = 15,  gold = 50,  buildTime = 30 },
    Barracks        = { wood = 25,  stone = 15,  gold = 0,   buildTime = 20 },
    StoneBarracks   = { wood = 0,   stone = 30,  gold = 0,   buildTime = 25 },
    EngineersGuild  = { wood = 30,  stone = 20,  gold = 0,   buildTime = 25 },
    TunnelersGuild  = { wood = 30,  stone = 20,  gold = 0,   buildTime = 25 },
    Armoury         = { wood = 25,  stone = 15,  gold = 0,   buildTime = 20 },
    Fletcher        = { wood = 20,  stone = 5,   gold = 0,   buildTime = 15 },
    Poleturner      = { wood = 20,  stone = 5,   gold = 0,   buildTime = 15 },
    Blacksmith      = { wood = 25,  stone = 10,  gold = 0,   buildTime = 20 },
    Armorer         = { wood = 25,  stone = 15,  gold = 0,   buildTime = 25 },
    Chapel          = { wood = 20,  stone = 30,  gold = 0,   buildTime = 30 },
    Church          = { wood = 30,  stone = 50,  gold = 0,   buildTime = 40 },
    Cathedral       = { wood = 50,  stone = 500, gold = 200, buildTime = 120 },
    WoodenWall      = { wood = 5,   stone = 0,   gold = 0,   buildTime = 3  },
    WoodenTower     = { wood = 20,  stone = 0,   gold = 0,   buildTime = 15 },
    SquareTower     = { wood = 0,   stone = 25,  gold = 0,   buildTime = 30 },
    RoundTower      = { wood = 0,   stone = 40,  gold = 0,   buildTime = 40 },
    StoneGateSouth  = { wood = 0,   stone = 20,  gold = 0,   buildTime = 25 },
    StoneGateEast   = { wood = 0,   stone = 20,  gold = 0,   buildTime = 25 },
    Hovel           = { wood = 5,   stone = 0,   gold = 0,   buildTime = 5,  capacity = 4  },
    Flat            = { wood = 20,  stone = 0,   gold = 0,   buildTime = 10, capacity = 8  },
    Residence      = { wood = 40,  stone = 10,  gold = 0,   buildTime = 20, capacity = 12 },
    BigResidence    = { wood = 60,  stone = 30,  gold = 0,   buildTime = 30, capacity = 16 },
    Catapult        = { wood = 50,  stone = 20,  gold = 100, buildTime = 60 },
    Trebuchet       = { wood = 80,  stone = 40,  gold = 200, buildTime = 90 },
    -- Stronghold 2027 v2.5.4: 3 new Norman-era buildings
    TournamentArena = { wood = 40,  stone = 30,  gold = 100, buildTime = 40 },  -- Boosts unit veterancy
    Shrine          = { wood = 20,  stone = 40,  gold = 50,  buildTime = 35 },  -- Boosts popularity
    WatchTower      = { wood = 10,  stone = 30,  gold = 0,   buildTime = 20 },  -- Extended vision range
}

-- === MISSION DIFFICULTY SCALING ===
BalanceConfig.missions = {
    recommendedArmySize = {
        mission1 = 0, mission2 = 5, mission3 = 5, mission4 = 10, mission5 = 25,
        mission6 = 20, mission7 = 25, mission8 = 15, mission9 = 20, mission10 = 40,
    },
    timeLimits = {
        mission1 = 0, mission2 = 0, mission3 = 0, mission4 = 0, mission5 = 0,
        mission6 = 0, mission7 = 0, mission8 = 0, mission9 = 0, mission10 = 0,
    },
}

-- === PERFORMANCE ===
BalanceConfig.performance = {
    maxEntitiesForFullUpdate = 100,
    maxEntitiesForFullDraw = 50,
    maxWeatherParticles = 800,
    maxDamageNumbers = 50,
    aiDecisionInterval = 3.0,
    economicEventCheckInterval = 30,
    marketPriceHistoryInterval = 5,
    lightSourceDetectInterval = 2,
    unitUpdateCullingRange = 50,
    unitDrawCullingRange = 60,
}

return BalanceConfig
