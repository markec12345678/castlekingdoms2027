-- objects/Combat/CombatTestScenario.lua
-- Stronghold 2027 - Combat Test Scenario
--
-- Spawns enemy units for combat testing.
-- Activated via console command: combat_test()
-- Or via keybind F8 (toggle test scenario)
--
-- Spawns:
-- - 3 friendly knights near player's keep
-- - 5 enemy archers at distance
-- - 3 enemy macemen approaching

local COMBAT = require("objects.Enums.Combat")
local CombatIntegration = require("objects.Combat.CombatIntegration")

local CombatTestScenario = {}

local scenarioActive = false
local spawnedUnits = { friendly = {}, enemy = {} }

-- Activate the test scenario
function CombatTestScenario.activate()
    if scenarioActive then
        CombatTestScenario.deactivate()
        return
    end

    if not _G.state or not _G.state.initialized then
        print("[CombatTest] State not initialized, cannot activate")
        return
    end

    if not CombatIntegration.isInitialized() then
        CombatIntegration.init()
    end

    -- Find player's keep as spawn reference
    local keepX, keepY = CombatTestScenario.findPlayerKeep()
    if not keepX then
        print("[CombatTest] No keep found, using default position")
        keepX, keepY = 50, 50
    end

    print(string.format("[CombatTest] Spawning test scenario at keep (%d, %d)", keepX, keepY))

    -- Spawn friendly units (3 knights)
    spawnedUnits.friendly = {}
    for i = 1, 3 do
        local unit = CombatIntegration.spawnUnit("Knight", keepX + i, keepY + 5, COMBAT.FACTION_PLAYER)
        if unit then
            unit.playerControlled = true
            table.insert(spawnedUnits.friendly, unit)
        end
    end

    -- Spawn enemy archers (5, at distance 20 tiles)
    local enemyX = keepX + 20
    local enemyY = keepY + 20
    spawnedUnits.enemy = {}
    for i = 1, 5 do
        local unit = CombatIntegration.spawnUnit("Archer", enemyX + i, enemyY, COMBAT.FACTION_ENEMY_1)
        if unit then
            table.insert(spawnedUnits.enemy, unit)
        end
    end

    -- Spawn enemy macemen (3, closer)
    for i = 1, 3 do
        local unit = CombatIntegration.spawnUnit("Maceman", enemyX - 5 + i, enemyY + 3, COMBAT.FACTION_ENEMY_2)
        if unit then
            table.insert(spawnedUnits.enemy, unit)
        end
    end

    scenarioActive = true
    print(string.format("[CombatTest] Scenario active: %d friendly, %d enemy units",
        #spawnedUnits.friendly, #spawnedUnits.enemy))
    print("[CombatTest] Select friendly units (left-click drag) and right-click enemy to attack!")
    print("[CombatTest] Press F8 again to deactivate")
end

-- Deactivate test scenario (remove all spawned units)
function CombatTestScenario.deactivate()
    for _, unit in ipairs(spawnedUnits.friendly) do
        if unit and not unit.toBeDeleted then
            unit.toBeDeleted = true
            if unit.die then unit:die() end
        end
    end
    for _, unit in ipairs(spawnedUnits.enemy) do
        if unit and not unit.toBeDeleted then
            unit.toBeDeleted = true
            if unit.die then unit:die() end
        end
    end
    spawnedUnits.friendly = {}
    spawnedUnits.enemy = {}
    scenarioActive = false
    print("[CombatTest] Scenario deactivated")
end

-- Find player's keep location
function CombatTestScenario.findPlayerKeep()
    if not _G.state or not _G.state.gameObjectList then return nil end

    for _, obj in ipairs(_G.state.gameObjectList) do
        if obj.class and obj.class.name then
            local name = obj.class.name
            if name == "Keep" or name == "WoodenKeep" or name == "Fortress"
                or name == "Stronghold" or name == "SaxonHall" then
                if obj.gx and obj.gy then
                    return obj.gx, obj.gy
                end
            end
        end
    end

    return nil
end

-- Check if scenario is active
function CombatTestScenario.isActive()
    return scenarioActive
end

-- Get status info
function CombatTestScenario.getStatus()
    local friendlyAlive = 0
    local enemyAlive = 0

    for _, unit in ipairs(spawnedUnits.friendly) do
        if unit and not unit.toBeDeleted and unit.health and unit.health > 0 then
            friendlyAlive = friendlyAlive + 1
        end
    end
    for _, unit in ipairs(spawnedUnits.enemy) do
        if unit and not unit.toBeDeleted and unit.health and unit.health > 0 then
            enemyAlive = enemyAlive + 1
        end
    end

    return {
        active = scenarioActive,
        friendlyTotal = #spawnedUnits.friendly,
        friendlyAlive = friendlyAlive,
        enemyTotal = #spawnedUnits.enemy,
        enemyAlive = enemyAlive,
        victory = scenarioActive and friendlyAlive > 0 and enemyAlive == 0,
        defeat = scenarioActive and friendlyAlive == 0 and enemyAlive > 0,
    }
end

return CombatTestScenario
