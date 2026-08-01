-- objects/AI/AIEnhancements.lua
-- Stronghold 2027 - AI Behavior Enhancements
--
-- Improves AI behavior to feel more natural and less "cheaty":
-- 1. Smarter building placement (avoid clustering, spread out)
-- 2. Strategic attack timing (attack when army ready, not random)
-- 3. Defense response (recall units when keep is under attack)
-- 4. Difficulty adaptation (adjust strategy based on player strength)
-- 5. Resource management (don't hoard, spend wisely)

local COMBAT = require("objects.Enums.Combat")

local AIEnhancements = {}

local buildingPositions = {}
local playerStrengthHistory = {}
local lastPlayerStrengthCheck = 0
local defenseState = {}

local config = {
    minBuildingDistance = 5,
    maxBuildAttempts = 30,
    minArmySizeForAttack = 8,
    attackCooldownMin = 120,
    defenseResponseTime = 3.0,
    defenseRecallRange = 30,
    adaptationCheckInterval = 60,
    adaptationThreshold = 0.3,
    goldReserveThreshold = 200,
    woodReserveThreshold = 50,
}

function AIEnhancements.initFaction(faction)
    buildingPositions[faction] = {}
    defenseState[faction] = { underAttack = false, attackTime = 0, recallSent = false }
end

-- 1. SMARTER BUILDING PLACEMENT
function AIEnhancements.findSmartBuildLocation(faction, baseGx, baseGy)
    local positions = buildingPositions[faction] or {}
    local bestLocation = nil
    local bestScore = -math.huge

    for attempt = 1, config.maxBuildAttempts do
        local range = 10 + math.floor(attempt / 5) * 5
        local dx = math.random(-range, range)
        local dy = math.random(-range, range)
        local gx = baseGx + dx
        local gy = baseGy + dy

        if gx > 5 and gy > 5 then
            local minDist = math.huge
            for _, pos in ipairs(positions) do
                local dist = math.sqrt((pos.gx - gx)^2 + (pos.gy - gy)^2)
                if dist < minDist then minDist = dist end
            end
            local baseDist = math.sqrt((baseGx - gx)^2 + (baseGy - gy)^2)
            local score = minDist - (baseDist * 0.3)
            if score > bestScore and minDist >= config.minBuildingDistance then
                bestScore = score
                bestLocation = { gx = gx, gy = gy }
            end
        end
    end
    return bestLocation
end

function AIEnhancements.registerBuilding(faction, gx, gy)
    if not buildingPositions[faction] then buildingPositions[faction] = {} end
    table.insert(buildingPositions[faction], { gx = gx, gy = gy })
end

-- 2. STRATEGIC ATTACK TIMING
function AIEnhancements.shouldAttack(faction, state)
    local timeSinceReg = love.timer.getTime() - (state.registrationTime or 0)
    if timeSinceReg < (state.gracePeriod or 300) then return false, "grace_period" end

    local timeSinceAttack = love.timer.getTime() - (state.lastAttack or 0)
    if timeSinceAttack < config.attackCooldownMin then return false, "cooldown" end

    local armySize = 0
    for _, unit in ipairs(state.units or {}) do
        if unit.type ~= "Peasant" then armySize = armySize + 1 end
    end
    if armySize < (state.personality.attackThreshold or config.minArmySizeForAttack) then
        return false, "army_too_small"
    end

    local gold = state.resources.gold or 0
    if gold < config.goldReserveThreshold then return false, "low_gold" end

    local chance = (state.personality.attackChancePerMin or 0.3) + math.min(0.3, armySize / 100)
    if math.random() > chance then return false, "random_skip" end

    return true, "ready"
end

-- 3. DEFENSE RESPONSE
function AIEnhancements.checkDefenseResponse(faction, state, dt)
    if not defenseState[faction] then AIEnhancements.initFaction(faction) end
    local defense = defenseState[faction]

    local keepGx, keepGy = nil, nil
    if _G.state and _G.state.gameObjectList then
        for _, obj in ipairs(_G.state.gameObjectList) do
            if obj.faction == faction and obj.class and obj.class.name then
                local name = obj.class.name
                if name == "Keep" or name == "WoodenKeep" or name == "SaxonHall" then
                    keepGx, keepGy = obj.gx, obj.gy
                    break
                end
            end
        end
    end
    if not keepGx then return end

    local threatCount = 0
    local threats = {}
    if _G.state and _G.state.gameObjectList then
        for _, unit in ipairs(_G.state.gameObjectList) do
            if unit.faction and unit.faction ~= faction
               and unit.faction ~= COMBAT.FACTION_NEUTRAL
               and unit._combatAttached and not unit.toBeDeleted
               and unit.health and unit.health > 0 and unit.gx and unit.gy then
                local dx = unit.gx - keepGx
                local dy = unit.gy - keepGy
                if dx*dx + dy*dy < config.defenseRecallRange^2 then
                    threatCount = threatCount + 1
                    table.insert(threats, unit)
                end
            end
        end
    end

    if threatCount > 0 then
        if not defense.underAttack then
            defense.underAttack = true
            defense.attackTime = love.timer.getTime()
            defense.recallSent = false
            print(string.format("[AIEnh] Faction %d under attack! %d threats", faction, threatCount))
        end
        if not defense.recallSent and love.timer.getTime() - defense.attackTime > config.defenseResponseTime then
            AIEnhancements.recallUnits(faction, threats)
            defense.recallSent = true
        end
    else
        if defense.underAttack then
            defense.underAttack = false
            defense.recallSent = false
        end
    end
end

function AIEnhancements.recallUnits(faction, threats)
    if not _G.state or not _G.state.gameObjectList then return end
    local recalled = 0
    for _, unit in ipairs(_G.state.gameObjectList) do
        if unit.faction == faction and unit._combatAttached
           and not unit.toBeDeleted and unit.health and unit.health > 0
           and unit.className ~= "Peasant"
           and (unit.combatState == COMBAT.STATE_IDLE or unit.combatState == nil) then
            if #threats > 0 then
                local nearest = threats[1]
                local minDist = math.huge
                for _, t in ipairs(threats) do
                    if t.gx and t.gy and unit.gx and unit.gy then
                        local d = (t.gx-unit.gx)^2 + (t.gy-unit.gy)^2
                        if d < minDist then minDist = d; nearest = t end
                    end
                end
                if nearest then
                    unit.target = nearest
                    unit.combatState = COMBAT.STATE_AGGRO
                    if unit.gotoUserWaypoint then
                        unit:gotoUserWaypoint(nearest.gx, nearest.gy, nil, nil)
                    end
                    recalled = recalled + 1
                end
            end
        end
    end
    if recalled > 0 then
        print(string.format("[AIEnh] Faction %d: recalled %d units", faction, recalled))
    end
end

-- 4. DIFFICULTY ADAPTATION
function AIEnhancements.assessPlayerStrength()
    if not _G.state or not _G.state.gameObjectList then return 0 end
    local units, buildings = 0, 0
    local gold = _G.state.gold or 0
    for _, obj in ipairs(_G.state.gameObjectList) do
        if (not obj.faction or obj.faction == COMBAT.FACTION_PLAYER) then
            if obj._combatAttached and not obj.toBeDeleted then units = units + 1
            elseif obj.class and obj.class.name then buildings = buildings + 1 end
        end
    end
    return units * 10 + buildings * 5 + gold / 100
end

function AIEnhancements.getAdaptationSuggestion(faction)
    local now = love.timer.getTime()
    if now - lastPlayerStrengthCheck < config.adaptationCheckInterval then return nil end
    lastPlayerStrengthCheck = now
    local strength = AIEnhancements.assessPlayerStrength()
    table.insert(playerStrengthHistory, { time = now, strength = strength })
    while #playerStrengthHistory > 5 do table.remove(playerStrengthHistory, 1) end
    if #playerStrengthHistory < 2 then return nil end
    local oldest = playerStrengthHistory[1].strength
    local current = playerStrengthHistory[#playerStrengthHistory].strength
    if oldest == 0 then return nil end
    local growth = (current - oldest) / oldest
    if growth > config.adaptationThreshold then return "player_growing_fast", growth
    elseif growth < -config.adaptationThreshold then return "player_weakening", growth end
    return nil
end

-- 5. RESOURCE MANAGEMENT
function AIEnhancements.suggestBuild(faction, state)
    local gold = state.resources.gold or 0
    local wood = state.resources.wood or 0
    local food = state.resources.food or 0
    if food < 20 then return "WheatFarm", "low_food" end
    if wood < 30 then return "Woodcutter", "low_wood" end
    local armySize = 0
    for _, u in ipairs(state.units or {}) do
        if u.type ~= "Peasant" then armySize = armySize + 1 end
    end
    if armySize < (state.personality.attackThreshold or 8) and gold > 100 then
        local hasBarracks = false
        for _, b in ipairs(state.buildings or {}) do
            if b.building == "Barracks" or b.building == "StoneBarracks" then hasBarracks = true; break end
        end
        if not hasBarracks then return "Barracks", "need_military" end
    end
    if gold > 500 and wood > 100 then return "Market", "expand_economy" end
    if (state.resources.stone or 0) > 50 and armySize > 5 then return "SquareTower", "build_defense" end
    return nil, "no_priority"
end

function AIEnhancements.update(faction, state, dt)
    AIEnhancements.checkDefenseResponse(faction, state, dt)
    AIEnhancements.getAdaptationSuggestion(faction)
end

function AIEnhancements.reset()
    buildingPositions = {}
    defenseState = {}
    playerStrengthHistory = {}
    lastPlayerStrengthCheck = 0
end

function AIEnhancements.getDebugInfo(faction)
    return {
        buildingCount = buildingPositions[faction] and #buildingPositions[faction] or 0,
        underAttack = defenseState[faction] and defenseState[faction].underAttack or false,
        recallSent = defenseState[faction] and defenseState[faction].recallSent or false,
    }
end

return AIEnhancements
