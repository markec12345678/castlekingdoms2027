-- objects/Combat/ArmyCommandSystem.lua
-- Stronghold 2027 v2.6.9 - Army Command System
--
-- Manages army groups, their composition, and strategic orders.
-- Allows players to organize units into named armies with persistent orders.
--
-- Army features:
-- - Create named armies (e.g., "Vanguard", "Reserve", "Scouts")
-- - Assign units to armies
-- - Set standing orders (defend, patrol, attack, retreat)
-- - Track army strength and composition
-- - Coordinate multi-army operations

local ArmyCommand = {}

local initialized = false
local armies = {}  -- [armyId] = { name, units, orders, target, strength }
local nextArmyId = 1

-- Order types
local ORDERS = {
    hold = { name = "Drži položaj", nameEn = "Hold", desc = "Ostani na mestu, napadaj bližnje sovražnike" },
    advance = { name = "Napreduj", nameEn = "Advance", desc = "Premakni se k cilju" },
    charge = { name = "Juriš", nameEn = "Charge", desc = "Polni napad na sovražnika" },
    retreat = { name = "Umik", nameEn = "Retreat", desc = "Umik v bazo" },
    patrol = { name = "Patrulja", nameEn = "Patrol", desc = "Patruliraj med točkami" },
    siege = { name = "Obleganje", nameEn = "Siege", desc = "Oblegaj sovražnikov grad" },
    flank = { name = "Obhod", nameEn = "Flank", desc = "Napadi sovražnika z boka" },
}

ArmyCommand.ORDERS = ORDERS

function ArmyCommand.init()
    if initialized then return end
    initialized = true
    print("[ArmyCommand] Initialized with " .. ArmyCommand._getOrderCount() .. " order types")
end

function ArmyCommand._getOrderCount()
    local count = 0
    for _ in pairs(ORDERS) do count = count + 1 end
    return count
end

-- Create a new army
function ArmyCommand.createArmy(name)
    local armyId = nextArmyId
    nextArmyId = nextArmyId + 1
    armies[armyId] = {
        id = armyId,
        name = name or ("Armada " .. armyId),
        units = {},  -- list of unit objects
        orders = "hold",
        target = nil,  -- { gx, gy }
        patrolPoints = {},  -- for patrol orders
        strength = 0,
        created = os.time(),
    }
    print("[ArmyCommand] Created army: " .. armies[armyId].name .. " (ID: " .. armyId .. ")")
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Armada ustvarjena: " .. armies[armyId].name)
    end
    return armyId
end

-- Disband an army (units return to player control)
function ArmyCommand.disbandArmy(armyId)
    local army = armies[armyId]
    if not army then return false end
    -- Clear orders on all units
    for _, unit in ipairs(army.units) do
        if unit.combatState then
            unit.combatState = "idle"
        end
        unit.armyId = nil
    end
    print("[ArmyCommand] Disbanded army: " .. army.name)
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Armada razpuščena: " .. army.name)
    end
    armies[armyId] = nil
    return true
end

-- Add a unit to an army
function ArmyCommand.addUnit(armyId, unit)
    local army = armies[armyId]
    if not army then return false end
    if not unit then return false end
    -- Remove from previous army if any
    if unit.armyId and armies[unit.armyId] then
        ArmyCommand.removeUnit(unit.armyId, unit)
    end
    table.insert(army.units, unit)
    unit.armyId = armyId
    ArmyCommand._recalculateStrength(armyId)
    return true
end

-- Remove a unit from an army
function ArmyCommand.removeUnit(armyId, unit)
    local army = armies[armyId]
    if not army then return false end
    for i, u in ipairs(army.units) do
        if u == unit then
            table.remove(army.units, i)
            unit.armyId = nil
            ArmyCommand._recalculateStrength(armyId)
            return true
        end
    end
    return false
end

-- Recalculate army strength
function ArmyCommand._recalculateStrength(armyId)
    local army = armies[armyId]
    if not army then return end
    local strength = 0
    local aliveUnits = {}
    for _, unit in ipairs(army.units) do
        if not unit.toBeDeleted and unit.health and unit.health > 0 then
            table.insert(aliveUnits, unit)
            -- Strength = sum of (health + damage)
            local hp = unit.health or 50
            local dmg = unit.damage or 10
            strength = strength + hp + dmg
        end
    end
    army.units = aliveUnits
    army.strength = strength
end

-- Set orders for an army
function ArmyCommand.setOrders(armyId, orderType, target)
    local army = armies[armyId]
    if not army then return false end
    if not ORDERS[orderType] then return false end
    army.orders = orderType
    if target then
        army.target = target
    end
    -- Apply orders to units
    ArmyCommand._applyOrders(armyId)
    print("[ArmyCommand] " .. army.name .. " orders: " .. ORDERS[orderType].name)
    return true
end

-- Apply orders to all units in army
function ArmyCommand._applyOrders(armyId)
    local army = armies[armyId]
    if not army then return end
    local COMBAT = require("objects.Enums.Combat")
    for _, unit in ipairs(army.units) do
        if army.orders == "hold" then
            unit.combatState = COMBAT.STATE_IDLE
            unit.target = nil
        elseif army.orders == "advance" then
            unit.combatState = COMBAT.STATE_SEEKING
            if army.target and unit.gotoUserWaypoint then
                pcall(function() unit:gotoUserWaypoint(army.target.gx, army.target.gy, nil, nil) end)
            end
        elseif army.orders == "charge" then
            unit.combatState = COMBAT.STATE_AGGRO
            if army.target and unit.gotoUserWaypoint then
                pcall(function() unit:gotoUserWaypoint(army.target.gx, army.target.gy, nil, nil) end)
            end
        elseif army.orders == "retreat" then
            unit.combatState = COMBAT.STATE_RETREATING
            unit.target = nil
        elseif army.orders == "siege" then
            unit.combatState = COMBAT.STATE_AGGRO
            if army.target and unit.gotoUserWaypoint then
                pcall(function() unit:gotoUserWaypoint(army.target.gx, army.target.gy, nil, nil) end)
            end
        end
    end
end

-- Get army info
function ArmyCommand.getArmy(armyId)
    local army = armies[armyId]
    if not army then return nil end
    ArmyCommand._recalculateStrength(armyId)
    return {
        id = army.id,
        name = army.name,
        unitCount = #army.units,
        strength = army.strength,
        orders = army.orders,
        ordersName = ORDERS[army.orders] and ORDERS[army.orders].name or "Unknown",
        target = army.target,
        created = army.created,
    }
end

-- Get all armies
function ArmyCommand.getAllArmies()
    local result = {}
    for armyId, _ in pairs(armies) do
        table.insert(result, ArmyCommand.getArmy(armyId))
    end
    return result
end

-- Get total military strength
function ArmyCommand.getTotalStrength()
    local total = 0
    for armyId, _ in pairs(armies) do
        ArmyCommand._recalculateStrength(armyId)
        total = total + armies[armyId].strength
    end
    return total
end

-- Update (clean dead units, check orders)
function ArmyCommand.update(dt)
    if not initialized then return end
    -- Clean dead units from all armies
    for armyId, army in pairs(armies) do
        ArmyCommand._recalculateStrength(armyId)
        -- If army is empty, auto-disband
        if #army.units == 0 then
            print("[ArmyCommand] Auto-disbanding empty army: " .. army.name)
            armies[armyId] = nil
        end
    end
end

-- Get stats
function ArmyCommand.getStats()
    local count = 0
    local totalUnits = 0
    local totalStrength = 0
    for _, army in pairs(armies) do
        count = count + 1
        totalUnits = totalUnits + #army.units
        totalStrength = totalStrength + army.strength
    end
    return {
        armyCount = count,
        totalUnits = totalUnits,
        totalStrength = totalStrength,
    }
end

return ArmyCommand
