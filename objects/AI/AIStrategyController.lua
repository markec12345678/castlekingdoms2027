-- objects/AI/AIStrategyController.lua
-- Stronghold 2027 - High-level AI Strategy
--
-- Controls overall strategy for AI opponents:
-- - Decides when to gather, build, expand, attack, defend
-- - Manages resource allocation
-- - Coordinates EconomyAI and MilitaryAI
-- - Adapts strategy based on game state
--
-- AI Personalities:
-- - Aggressive: prioritizes military, attacks early
-- - Balanced: mixed economy and military
-- - Defensive: focuses on economy, defends
-- - Economic: maximizes gold/resources, late game army
--
-- Difficulty levels affect:
-- - Decision frequency (faster = harder)
-- - Resource efficiency (less waste = harder)
-- - Strategic depth (more complex plans = harder)
-- - Cheat bonus (extra resources = harder)

local COMBAT = require("objects.Enums.Combat")

local AIStrategyController = _G.class("AIStrategyController")

-- AI Personalities
local PERSONALITIES = {
    aggressive = {
        name = "Aggressive",
        economyFocus = 0.3,      -- 30% of resources to economy
        militaryFocus = 0.7,     -- 70% to military
        expansionFocus = 0.4,
        attackThreshold = 5,     -- attacks with 5+ units
        attackChancePerMin = 0.5,-- 50% chance per minute to attack
        defensePriority = 0.5,
        preferredUnits = {"Maceman", "Archer", "Knight"},
        preferredBuildings = {"Barracks", "StoneBarracks", "EngineersGuild"},
        resourceStockpileTarget = 200,  -- attacks when has this much gold
    },
    balanced = {
        name = "Balanced",
        economyFocus = 0.5,
        militaryFocus = 0.5,
        expansionFocus = 0.5,
        attackThreshold = 10,
        attackChancePerMin = 0.3,
        defensePriority = 0.7,
        preferredUnits = {"Spearman", "Archer", "Swordsman", "Knight"},
        preferredBuildings = {"Barracks", "Stockpile", "Granary", "Market"},
        resourceStockpileTarget = 500,
    },
    defensive = {
        name = "Defensive",
        economyFocus = 0.7,
        militaryFocus = 0.3,
        expansionFocus = 0.3,
        attackThreshold = 20,    -- only attacks with overwhelming force
        attackChancePerMin = 0.1,-- rarely attacks
        defensePriority = 0.9,
        preferredUnits = {"Pikeman", "Crossbowman", "Archer"},
        preferredBuildings = {"SquareTower", "RoundTower", "StoneGateSouth", "WoodenWall"},
        resourceStockpileTarget = 1000,
    },
    economic = {
        name = "Economic",
        economyFocus = 0.85,
        militaryFocus = 0.15,
        expansionFocus = 0.6,
        attackThreshold = 30,
        attackChancePerMin = 0.05,
        defensePriority = 0.6,
        preferredUnits = {"Mercenary", "Crossbowman", "Knight"},
        preferredBuildings = {"Market", "Stockpile", "Granary", "Bakery", "Brewery"},
        resourceStockpileTarget = 2000,
    },
    -- Stronghold 2027 v2.5.2: 4 new specialized personalities
    siege_master = {
        name = "Siege Master",
        economyFocus = 0.4,
        militaryFocus = 0.6,
        expansionFocus = 0.3,
        attackThreshold = 8,
        attackChancePerMin = 0.4,
        defensePriority = 0.6,
        preferredUnits = {"Engineer", "Knight", "Crossbowman"},
        preferredBuildings = {"EngineersGuild", "StoneBarracks", "SquareTower"},
        resourceStockpileTarget = 800,
        specialization = "siege",  -- builds siege weapons preferentially
    },
    fortress_keeper = {
        name = "Fortress Keeper",
        economyFocus = 0.5,
        militaryFocus = 0.4,
        expansionFocus = 0.2,
        attackThreshold = 25,
        attackChancePerMin = 0.08,
        defensePriority = 0.95,
        preferredUnits = {"Pikeman", "Crossbowman", "Maceman"},
        preferredBuildings = {"SquareTower", "RoundTower", "StoneGateSouth", "WoodenWall", "StoneBarracks"},
        resourceStockpileTarget = 1500,
        specialization = "fortification",  -- max defenses
    },
    raider = {
        name = "Raider",
        economyFocus = 0.2,
        militaryFocus = 0.8,
        expansionFocus = 0.5,
        attackThreshold = 3,
        attackChancePerMin = 0.7,
        defensePriority = 0.3,
        preferredUnits = {"Maceman", "Archer", "Knight"},
        preferredBuildings = {"Barracks", "Barracks", "Barracks"},  -- spam barracks
        resourceStockpileTarget = 100,
        specialization = "raid",  -- fast raids, hit and run
    },
    diplomat = {
        name = "Diplomat",
        economyFocus = 0.6,
        militaryFocus = 0.3,
        expansionFocus = 0.4,
        attackThreshold = 15,
        attackChancePerMin = 0.15,
        defensePriority = 0.7,
        preferredUnits = {"Knight", "Crossbowman", "Spearman"},
        preferredBuildings = {"Market", "Barracks", "SquareTower", "Inn"},
        resourceStockpileTarget = 1200,
        specialization = "diplomacy",  -- forms alliances, trades aggressively
    },
}

-- Difficulty levels
local DIFFICULTIES = {
    -- Stronghold 2027 v2.5.2: Added story and legendary difficulties
    story = {
        decisionInterval = 6.0,    -- very slow thinking
        resourceEfficiency = 0.4,  -- wastes 60% of resources
        cheatBonus = 0,
        maxArmySize = 10,
        defenseResponseTime = 15,  -- very slow to defend
    },
    easy = {
        decisionInterval = 5.0,    -- thinks every 5 seconds
        resourceEfficiency = 0.6,  -- wastes 40% of resources
        cheatBonus = 0,            -- no cheats
        maxArmySize = 15,
        defenseResponseTime = 10,  -- slow to defend
    },
    medium = {
        decisionInterval = 3.0,
        resourceEfficiency = 0.8,
        cheatBonus = 0,
        maxArmySize = 25,
        defenseResponseTime = 5,
    },
    hard = {
        decisionInterval = 1.5,
        resourceEfficiency = 0.95,
        cheatBonus = 0.15,          -- 15% extra resources (reduced from 20%)
        maxArmySize = 40,
        defenseResponseTime = 2,
    },
    brutal = {
        decisionInterval = 0.8,
        resourceEfficiency = 1.0,
        cheatBonus = 0.30,          -- 30% extra resources (reduced from 50%, less unfair feel)
        maxArmySize = 60,
        defenseResponseTime = 1,
    },
    legendary = {
        decisionInterval = 0.5,    -- thinks every 0.5s (super fast)
        resourceEfficiency = 1.0,
        cheatBonus = 0.50,          -- 50% extra resources
        maxArmySize = 80,
        defenseResponseTime = 0.5,  -- instant defense
    },
}

-- Strategic states
local STRATEGY_STATES = {
    INITIALIZING = "initializing",   -- just spawned, building initial economy
    ECONOMY_BUILDUP = "economy",     -- focusing on economy
    MILITARY_BUILDUP = "military",   -- building army
    EXPANDING = "expanding",         -- claiming new territory
    ATTACKING = "attacking",         -- launched attack
    DEFENDING = "defending",         -- under attack
    RETREATING = "retreating",       -- regrouping
    ENDGAME = "endgame",             -- going for final push
}

function AIStrategyController:initialize()
    self.factions = {}  -- per-faction state
    print("[AIStrategyController] Initialized")
end

-- Register a new AI faction
-- @param faction number Faction ID (COMBAT.FACTION_ENEMY_1, etc.)
-- @param personality string "aggressive", "balanced", "defensive", "economic"
-- @param difficulty string "easy", "medium", "hard", "brutal"
function AIStrategyController:registerFaction(faction, personality, difficulty)
    if self.factions[faction] then
        print("[AIStrategyController] Faction " .. faction .. " already registered")
        return false
    end

    self.factions[faction] = {
        faction = faction,
        personality = PERSONALITIES[personality] or PERSONALITIES.balanced,
        personalityName = personality or "balanced",
        difficulty = DIFFICULTIES[difficulty] or DIFFICULTIES.medium,
        difficultyName = difficulty or "medium",
        state = STRATEGY_STATES.INITIALIZING,
        lastDecision = 0,
        lastAttack = 0,
        -- Grace period: AI won't attack player for first 5 minutes
        -- (gives player time to set up)
        registrationTime = love.timer.getTime(),
        gracePeriod = 300,  -- 5 minutes
        buildQueue = {},
        attackQueue = {},
        resources = { gold = 1000, wood = 100, stone = 50, food = 50 },
        buildings = {},
        units = {},
        enemyThreats = {},  -- known enemy positions
        expansionTargets = {},  -- potential expansion spots
    }

    print(string.format("[AIStrategyController] Registered faction %d (%s/%s) - grace period: %ds",
        faction, personality or "balanced", difficulty or "medium", 300))
    return true
end

-- Update all AI factions
function AIStrategyController:update(dt)
    for faction, state in pairs(self.factions) do
        self:updateFaction(faction, state, dt)
    end
end

-- Update a single faction
function AIStrategyController:updateFaction(faction, state, dt)
    local now = love.timer.getTime()
    if now - state.lastDecision < state.difficulty.decisionInterval then
        return  -- not time to think yet
    end
    state.lastDecision = now

    -- Apply cheat bonus (resource generation)
    if state.difficulty.cheatBonus > 0 then
        local bonus = state.difficulty.cheatBonus
        -- Stronghold 2027 v2.3.4: Apply seasonal modifiers to cheat bonus too
        local SeasonalSystem = _G.SeasonalSystem
        local woodMod = (SeasonalSystem and SeasonalSystem.getProductionModifier("wood")) or 1.0
        local stoneMod = (SeasonalSystem and SeasonalSystem.getProductionModifier("stone")) or 1.0
        state.resources.gold = state.resources.gold + math.floor(10 * bonus)
        state.resources.wood = state.resources.wood + math.floor(5 * bonus * woodMod)
        state.resources.stone = state.resources.stone + math.floor(2 * bonus * stoneMod)
    end

    -- Update state based on game conditions
    self:evaluateStrategicState(faction, state)

    -- Execute state-specific logic
    local stateHandler = {
        [STRATEGY_STATES.INITIALIZING] = self.stateInitializing,
        [STRATEGY_STATES.ECONOMY_BUILDUP] = self.stateEconomyBuildup,
        [STRATEGY_STATES.MILITARY_BUILDUP] = self.stateMilitaryBuildup,
        [STRATEGY_STATES.EXPANDING] = self.stateExpanding,
        [STRATEGY_STATES.ATTACKING] = self.stateAttacking,
        [STRATEGY_STATES.DEFENDING] = self.stateDefending,
        [STRATEGY_STATES.RETREATING] = self.stateRetreating,
        [STRATEGY_STATES.ENDGAME] = self.stateEndgame,
    }

    local handler = stateHandler[state.state]
    if handler then
        handler(self, faction, state, dt)
    end
end

-- Evaluate and possibly change strategic state
function AIStrategyController:evaluateStrategicState(faction, state)
    local enemyThreats = self:countEnemyThreats(faction, state)
    local armySize = self:countArmyUnits(faction, state)
    -- Nil-safe resource access (default to 0 if missing)
    local resourceLevel = (state.resources.gold or 0) + (state.resources.wood or 0) + (state.resources.stone or 0)

    -- Check grace period (AI won't attack player for first 5 minutes)
    local timeSinceRegistration = love.timer.getTime() - state.registrationTime
    local inGracePeriod = timeSinceRegistration < state.gracePeriod

    -- Under attack? (always allowed to defend, even during grace period)
    if enemyThreats > 0 then
        state.state = STRATEGY_STATES.DEFENDING
        return
    end

    -- Current state handling
    if state.state == STRATEGY_STATES.INITIALIZING then
        if resourceLevel > 500 then
            state.state = STRATEGY_STATES.ECONOMY_BUILDUP
        end
    elseif state.state == STRATEGY_STATES.ECONOMY_BUILDUP then
        if armySize >= state.personality.attackThreshold then
            state.state = STRATEGY_STATES.MILITARY_BUILDUP
        end
    elseif state.state == STRATEGY_STATES.MILITARY_BUILDUP then
        if armySize >= state.personality.attackThreshold and
           (state.resources.gold or 0) >= state.personality.resourceStockpileTarget then

            -- Don't attack during grace period
            if inGracePeriod then
                return  -- stay in MILITARY_BUILDUP, build up more
            end

            -- Chance to attack
            local timeSinceLastAttack = love.timer.getTime() - state.lastAttack
            if timeSinceLastAttack > 60 then  -- at least 1 min between attacks
                if math.random() < state.personality.attackChancePerMin then
                    state.state = STRATEGY_STATES.ATTACKING
                    state.lastAttack = love.timer.getTime()
                    -- Stronghold 2027: Trigger AI dialogue on attack
                    if _G.AIDialogue then
                        _G.AIDialogue.trigger(state.playerId or 2, state.personalityName or "balanced", "attacking")
                    end
                end
            end
        end
    elseif state.state == STRATEGY_STATES.ATTACKING then
        -- Retreat if outnumbered (less suicidal AI)
        if armySize < 3 then
            state.state = STRATEGY_STATES.RETREATING
        end
    elseif state.state == STRATEGY_STATES.RETREATING then
        if armySize >= state.personality.attackThreshold / 2 then
            state.state = STRATEGY_STATES.MILITARY_BUILDUP
        end
    elseif state.state == STRATEGY_STATES.DEFENDING then
        if enemyThreats == 0 then
            state.state = STRATEGY_STATES.ECONOMY_BUILDUP
        end
    end
end

-- State: INITIALIZING - build initial economy
function AIStrategyController:stateInitializing(faction, state, dt)
    -- Build essential starting buildings
    if #state.buildings < 3 then
        self:queueBuild(faction, state, "Stockpile")
        self:queueBuild(faction, state, "Granary")
        self:queueBuild(faction, state, "Woodcutter")
    end

    -- Gather initial resources
    self:gatherResources(faction, state)
end

-- State: ECONOMY_BUILDUP
function AIStrategyController:stateEconomyBuildup(faction, state, dt)
    -- Build economic buildings based on personality
    local buildings = state.personality.preferredBuildings

    -- Build a few economy buildings
    if #state.buildings < 8 then
        local economyBuildings = {"Woodcutter", "Quarry", "IronMine", "WheatFarm", "Bakery"}
        local building = economyBuildings[math.random(#economyBuildings)]
        self:queueBuild(faction, state, building)
    end

    -- Always train a few workers
    self:trainWorkers(faction, state)

    -- Maybe build market for trade (nil-safe)
    if (state.resources.gold or 0) > 300 and not self:hasBuilding(state, "Market") then
        self:queueBuild(faction, state, "Market")
    end

    self:gatherResources(faction, state)
end

-- State: MILITARY_BUILDUP
function AIStrategyController:stateMilitaryBuildup(faction, state, dt)
    -- Train military units
    if #state.units < state.difficulty.maxArmySize then
        local unitType = state.personality.preferredUnits[
            math.random(#state.personality.preferredUnits)
        ]
        self:trainUnit(faction, state, unitType)
    end

    -- Build military buildings if needed
    if not self:hasBuilding(state, "Barracks") then
        self:queueBuild(faction, state, "Barracks")
    end

    -- Build defenses
    if state.personality.defensePriority > 0.6 and #state.buildings < 15 then
        local defenses = {"SquareTower", "StoneGateSouth", "WoodenWall"}
        self:queueBuild(faction, state, defenses[math.random(#defenses)])
    end
end

-- State: EXPANDING
function AIStrategyController:stateExpanding(faction, state, dt)
    -- Find expansion spot
    local spot = self:findExpansionSpot(faction, state)
    if spot then
        -- Send worker to build new stockpile
        self:queueBuild(faction, state, "Stockpile", spot.gx, spot.gy)
    end
    state.state = STRATEGY_STATES.ECONOMY_BUILDUP
end

-- State: ATTACKING
function AIStrategyController:stateAttacking(faction, state, dt)
    -- Find player's keep
    local targetGx, targetGy = self:findPlayerKeep(faction, state)
    if not targetGx then
        state.state = STRATEGY_STATES.MILITARY_BUILDUP
        return
    end

    -- Send all military units to attack
    self:orderAttack(faction, state, targetGx, targetGy)
end

-- State: DEFENDING
function AIStrategyController:stateDefending(faction, state, dt)
    -- Find enemy units threatening
    local threats = self:findEnemyThreats(faction, state)

    -- Send military units to defend
    for _, threat in ipairs(threats) do
        self:orderDefend(faction, state, threat.gx, threat.gy)
    end

    -- Train more units if needed
    if #state.units < 5 then
        self:trainUnit(faction, state, "Spearman")  -- cheap defender
    end
end

-- State: RETREATING
function AIStrategyController:stateRetreating(faction, state, dt)
    -- Send units back to base
    local baseGx, baseGy = self:findOwnKeep(faction, state)
    if baseGx then
        self:orderRetreat(faction, state, baseGx, baseGy)
    end
end

-- State: ENDGAME
function AIStrategyController:stateEndgame(faction, state, dt)
    -- Massive final assault with all units
    local targetGx, targetGy = self:findPlayerKeep(faction, state)
    if targetGx then
        self:orderAttack(faction, state, targetGx, targetGy)

        -- Also build siege weapons (nil-safe)
        if (state.resources.gold or 0) > 500 then
            self:trainUnit(faction, state, "Engineer")  -- for siege
        end
    end
end

-- === Helper methods ===

function AIStrategyController:queueBuild(faction, state, buildingName, gx, gy)
    -- Check if can afford
    local cost = self:getBuildingCost(buildingName)
    if not self:canAfford(state, cost) then return false end

    -- Deduct resources
    self:spendResources(state, cost)

    table.insert(state.buildQueue, {
        building = buildingName,
        gx = gx,
        gy = gy,
        time = love.timer.getTime(),
    })

    print(string.format("[AI %d] Queued build: %s", faction, buildingName))
    return true
end

function AIStrategyController:trainUnit(faction, state, unitType)
    local cost = self:getUnitCost(unitType)
    if not self:canAfford(state, cost) then return false end

    self:spendResources(state, cost)
    table.insert(state.units, {
        type = unitType,
        time = love.timer.getTime(),
    })

    print(string.format("[AI %d] Trained unit: %s (army: %d)", faction, unitType, #state.units))
    return true
end

function AIStrategyController:trainWorkers(faction, state)
    if #state.units < 10 then  -- need workers
        self:trainUnit(faction, state, "Peasant")
    end
end

function AIStrategyController:gatherResources(faction, state)
    -- Simulate resource gathering (in real game, workers would do this)
    local efficiency = state.difficulty.resourceEfficiency
    -- Stronghold 2027 v2.3.4: Apply seasonal production modifiers
    local SeasonalSystem = _G.SeasonalSystem
    local woodMod = (SeasonalSystem and SeasonalSystem.getProductionModifier("wood")) or 1.0
    local stoneMod = (SeasonalSystem and SeasonalSystem.getProductionModifier("stone")) or 1.0
    local foodMod = (SeasonalSystem and SeasonalSystem.getProductionModifier("food")) or 1.0
    -- Stronghold 2027 v2.3.5: Apply economic event modifiers (blight, bumper harvest, etc.)
    local EconomicEvents = _G.EconomicEvents
    if EconomicEvents then
        woodMod = woodMod * ((EconomicEvents.getProductionModifier and EconomicEvents.getProductionModifier("wood")) or 1.0)
        stoneMod = stoneMod * ((EconomicEvents.getProductionModifier and EconomicEvents.getProductionModifier("stone")) or 1.0)
        foodMod = foodMod * ((EconomicEvents.getProductionModifier and EconomicEvents.getProductionModifier("food")) or 1.0)
    end
    -- Stronghold 2027 v2.3.7: Apply weather farm multiplier to food
    local WeatherGameplay = _G.WeatherGameplay
    if WeatherGameplay and WeatherGameplay.getFarmMultiplier then
        foodMod = foodMod * (WeatherGameplay.getFarmMultiplier() or 1.0)
    end
    state.resources.wood = state.resources.wood + math.floor(20 * efficiency * woodMod)
    state.resources.stone = state.resources.stone + math.floor(10 * efficiency * stoneMod)
    state.resources.food = state.resources.food + math.floor(15 * efficiency * foodMod)
end

function AIStrategyController:hasBuilding(state, buildingName)
    for _, b in ipairs(state.buildings) do
        if b.building == buildingName then return true end
    end
    return false
end

function AIStrategyController:countArmyUnits(faction, state)
    local count = 0
    for _, u in ipairs(state.units) do
        if u.type ~= "Peasant" then
            count = count + 1
        end
    end
    return count
end

function AIStrategyController:countEnemyThreats(faction, state)
    -- Check for enemy units near AI territory
    return #state.enemyThreats
end

function AIStrategyController:findPlayerKeep(faction, state)
    -- Find player's keep location
    if not _G.state or not _G.state.gameObjectList then return nil end

    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.class and obj.class.name then
            local name = obj.class.name
            if (name == "Keep" or name == "WoodenKeep" or name == "SaxonHall")
                and obj.faction == COMBAT.FACTION_PLAYER then
                return obj.gx, obj.gy
            end
        end
    end
    return nil
end

function AIStrategyController:findOwnKeep(faction, state)
    -- Find AI's own keep
    if not _G.state or not _G.state.gameObjectList then return nil end

    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.class and obj.class.name and obj.faction == faction then
            local name = obj.class.name
            if name == "Keep" or name == "WoodenKeep" or name == "SaxonHall" then
                return obj.gx, obj.gy
            end
        end
    end
    return nil
end

function AIStrategyController:findExpansionSpot(faction, state)
    -- Find empty area near current base
    local baseGx, baseGy = self:findOwnKeep(faction, state)
    if not baseGx then return nil end

    -- Try random spots near base
    for _ = 1, 10 do
        local dx = math.random(-20, 20)
        local dy = math.random(-20, 20)
        local gx = baseGx + dx
        local gy = baseGy + dy
        if gx > 0 and gy > 0 then
            return { gx = gx, gy = gy }
        end
    end
    return nil
end

function AIStrategyController:findEnemyThreats(faction, state)
    -- Find enemy units near AI territory
    local threats = {}
    if not _G.state or not _G.state.gameObjectList then return threats end

    local baseGx, baseGy = self:findOwnKeep(faction, state)
    if not baseGx then return threats end

    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit.faction and unit.faction ~= faction
            and unit.faction ~= 5  -- COMBAT.FACTION_NEUTRAL
            and unit.gx and unit.gy then
            local dx = unit.gx - baseGx
            local dy = unit.gy - baseGy
            local distSq = dx * dx + dy * dy
            if distSq < 400 then  -- within 20 tiles
                table.insert(threats, { gx = unit.gx, gy = unit.gy, distSq = distSq })
            end
        end
    end

    return threats
end

function AIStrategyController:orderAttack(faction, state, targetGx, targetGy)
    -- Stronghold 2027 v2.3.6: Actually issue attack orders to military units
    if not _G.state or not _G.state.gameObjectList then return end
    local ordered = 0
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit.faction == faction and unit._combatAttached
            and unit.health and unit.health > 0
            and unit.combatState ~= COMBAT.STATE_RETREATING then
            -- Set attack target
            unit.target = { gx = targetGx, gy = targetGy, faction = COMBAT.FACTION_PLAYER }
            unit.combatState = COMBAT.STATE_AGGRO
            -- Move toward target if unit supports waypoint movement
            if unit.gotoUserWaypoint then
                pcall(function() unit:gotoUserWaypoint(targetGx, targetGy, nil, nil) end)
            end
            ordered = ordered + 1
        end
    end
    print(string.format("[AI %d] Attack ordered: %d units -> (%d, %d)",
        faction, ordered, targetGx, targetGy))
end

function AIStrategyController:orderDefend(faction, state, threatGx, threatGy)
    -- Stronghold 2027 v2.3.6: Send nearby military units to defend
    if not _G.state or not _G.state.gameObjectList then return end
    local ordered = 0
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit.faction == faction and unit._combatAttached
            and unit.health and unit.health > 0
            and unit.combatState == COMBAT.STATE_IDLE then
            -- Move to defend position
            if unit.gotoUserWaypoint then
                pcall(function() unit:gotoUserWaypoint(threatGx, threatGy, nil, nil) end)
            end
            ordered = ordered + 1
        end
    end
    print(string.format("[AI %d] Defense ordered: %d units to (%d, %d)",
        faction, ordered, threatGx, threatGy))
end

function AIStrategyController:orderRetreat(faction, state, baseGx, baseGy)
    -- Stronghold 2027 v2.3.6: Order all military units to retreat to base
    if not _G.state or not _G.state.gameObjectList then return end
    local ordered = 0
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit.faction == faction and unit._combatAttached
            and unit.health and unit.health > 0 then
            unit.combatState = COMBAT.STATE_RETREATING
            unit.target = nil  -- clear attack target
            -- Move back to base
            if unit.gotoUserWaypoint then
                pcall(function() unit:gotoUserWaypoint(baseGx, baseGy, nil, nil) end)
            end
            ordered = ordered + 1
        end
    end
    print(string.format("[AI %d] Retreat ordered: %d units to base (%d, %d)",
        faction, ordered, baseGx, baseGy))
end

function AIStrategyController:canAfford(state, cost)
    if not cost then return true end
    -- Nil-safe: use (state.resources.X or 0) to prevent crash if resource is nil
    if cost.gold and (state.resources.gold or 0) < cost.gold then return false end
    if cost.wood and (state.resources.wood or 0) < cost.wood then return false end
    if cost.stone and (state.resources.stone or 0) < cost.stone then return false end
    if cost.food and (state.resources.food or 0) < cost.food then return false end
    return true
end

function AIStrategyController:spendResources(state, cost)
    if not cost then return end
    -- Nil-safe: initialize to 0 if nil before subtracting
    if cost.gold then state.resources.gold = (state.resources.gold or 0) - cost.gold end
    if cost.wood then state.resources.wood = (state.resources.wood or 0) - cost.wood end
    if cost.stone then state.resources.stone = (state.resources.stone or 0) - cost.stone end
    if cost.food then state.resources.food = (state.resources.food or 0) - cost.food end
end

-- Building costs (simplified - real values from game data)
function AIStrategyController:getBuildingCost(buildingName)
    local costs = {
        Stockpile = { wood = 10 },
        Granary = { wood = 30 },
        Woodcutter = { wood = 5 },
        Quarry = { wood = 15 },
        IronMine = { wood = 20 },
        WheatFarm = { wood = 15 },
        Bakery = { wood = 20, stone = 5 },
        Brewery = { wood = 25, stone = 5 },
        Market = { wood = 30, stone = 10 },
        Barracks = { wood = 25, stone = 15 },
        StoneBarracks = { stone = 30 },
        EngineersGuild = { wood = 30, stone = 20 },
        SquareTower = { stone = 25 },
        RoundTower = { stone = 40 },
        StoneGateSouth = { stone = 20 },
        WoodenWall = { wood = 5 },
    }
    return costs[buildingName] or { wood = 10 }
end

-- Unit costs (simplified)
function AIStrategyController:getUnitCost(unitType)
    local costs = {
        Peasant = { gold = 0, food = 1 },
        Archer = { gold = 50, wood = 5 },
        Crossbowman = { gold = 80, wood = 10 },
        Spearman = { gold = 30, wood = 5 },
        Pikeman = { gold = 60, wood = 10 },
        Maceman = { gold = 50, iron = 5 },
        Swordsman = { gold = 80, iron = 10 },
        Knight = { gold = 150, iron = 20 },
        Engineer = { gold = 100, wood = 20 },
        Mercenary = { gold = 200 },
    }
    return costs[unitType] or { gold = 50 }
end

-- Get info for debug
function AIStrategyController:getFactionInfo(faction)
    local state = self.factions[faction]
    if not state then return nil end
    return {
        faction = faction,
        personality = state.personalityName,
        difficulty = state.difficultyName,
        state = state.state,
        resources = state.resources,
        buildingCount = #state.buildings,
        unitCount = #state.units,
        armySize = self:countArmyUnits(faction, state),
    }
end

-- Get all factions info
function AIStrategyController:getAllFactionsInfo()
    local list = {}
    for faction, _ in pairs(self.factions) do
        table.insert(list, self:getFactionInfo(faction))
    end
    return list
end

return AIStrategyController:new()
