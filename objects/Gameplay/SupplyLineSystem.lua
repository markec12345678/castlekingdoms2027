-- objects/Gameplay/SupplyLineSystem.lua
-- Castle Kingdoms 2027 v2.7.5 - Supply Line Manager
--
-- Manages supply lines between buildings and military units.
-- Units far from supply sources suffer penalties; cutting supply lines is a valid strategy.
--
-- Supply features:
-- - Track supply coverage for all player units
-- - Supply buildings: Stockpile, Granary, Armoury, Market
-- - Units out of supply: -20% damage, -10% speed, no healing
-- - Supply line visualization
-- - Raidable supply lines

local SupplyLine = {}

local initialized = false
local supplyBuildings = {}  -- cached list of supply buildings
local cacheTimer = 0
local cacheInterval = 3.0  -- refresh every 3 seconds
local supplyRange = 30  -- tiles
local outOfSupplyUnits = {}  -- units currently out of supply

-- Supply building types
local SUPPLY_BUILDING_TYPES = {
    Stockpile = { supplies = {"wood", "stone", "iron", "pitch"} },
    Granary = { supplies = {"food", "wheat", "flour"} },
    Armoury = { supplies = {"weapons", "armor"} },
    Market = { supplies = {"gold", "trade"} },
    Inn = { supplies = {"ale", "mercenaries"} },
}

SupplyLine.SUPPLY_BUILDING_TYPES = SUPPLY_BUILDING_TYPES
SupplyLine.SUPPLY_RANGE = supplyRange

function SupplyLine.init()
    if initialized then return end
    initialized = true
    print("[SupplyLine] Initialized (range: " .. supplyRange .. " tiles)")
end

-- Refresh supply building cache
function SupplyLine._refreshCache()
    supplyBuildings = {}
    if not _G.state or not _G.state.gameObjectList then return end
    for _, obj in ipairs(_G.state.gameObjectList) do
        if (not obj.faction or obj.faction == 1) and obj.class and obj.class.name then
            if SUPPLY_BUILDING_TYPES[obj.class.name] then
                table.insert(supplyBuildings, {
                    object = obj,
                    name = obj.class.name,
                    gx = obj.gx,
                    gy = obj.gy,
                    supplies = SUPPLY_BUILDING_TYPES[obj.class.name].supplies,
                })
            end
        end
    end
end

-- Update (refresh cache and check units)
function SupplyLine.update(dt)
    if not initialized then return end
    cacheTimer = cacheTimer + dt
    if cacheTimer >= cacheInterval then
        cacheTimer = 0
        SupplyLine._refreshCache()
        SupplyLine._checkAllUnits()
    end
end

-- Check supply status for all player units
function SupplyLine._checkAllUnits()
    outOfSupplyUnits = {}
    if not _G.state or not _G.state.gameObjectList then return end

    for _, unit in ipairs(_G.state.gameObjectList) do
        if (not unit.faction or unit.faction == 1) and unit._combatAttached
            and unit.health and unit.health > 0 and not unit.toBeDeleted then
            if not SupplyLine._isInSupplyRange(unit.gx, unit.gy) then
                table.insert(outOfSupplyUnits, unit)
                -- Apply supply penalty
                SupplyLine._applyPenalty(unit)
            else
                -- Remove penalty
                SupplyLine._removePenalty(unit)
            end
        end
    end
end

-- Check if position is in supply range
function SupplyLine._isInSupplyRange(gx, gy)
    if not gx or not gy then return true end  -- can't check, assume supplied
    if #supplyBuildings == 0 then return true end  -- no supply buildings yet

    local rangeSq = supplyRange * supplyRange
    for _, building in ipairs(supplyBuildings) do
        if building.gx and building.gy then
            local dx = building.gx - gx
            local dy = building.gy - gy
            if dx * dx + dy * dy <= rangeSq then
                return true
            end
        end
    end
    return false
end

-- Apply supply penalty to a unit
function SupplyLine._applyPenalty(unit)
    if unit._supplyPenaltyApplied then return end
    unit._supplyPenaltyApplied = true
    unit._originalDamage = unit._originalDamage or unit.damage or 10
    unit._originalSpeed = unit._originalSpeed or unit.speed or 1.0
    -- Apply -20% damage, -10% speed
    if unit.damage then
        unit.damage = unit._originalDamage * 0.80
    end
    if unit.speed then
        unit.speed = unit._originalSpeed * 0.90
    end
    -- Disable healing
    unit._canHeal = false
end

-- Remove supply penalty from a unit
function SupplyLine._removePenalty(unit)
    if not unit._supplyPenaltyApplied then return end
    unit._supplyPenaltyApplied = false
    -- Restore original stats
    if unit._originalDamage then
        unit.damage = unit._originalDamage
    end
    if unit._originalSpeed then
        unit.speed = unit._originalSpeed
    end
    unit._canHeal = true
end

-- Get all supply buildings
function SupplyLine.getSupplyBuildings()
    return supplyBuildings
end

-- Get units out of supply
function SupplyLine.getOutOfSupplyUnits()
    return outOfSupplyUnits
end

-- Check if a specific unit is in supply
function SupplyLine.isUnitSupplied(unit)
    if not unit or not unit.gx or not unit.gy then return true end
    return SupplyLine._isInSupplyRange(unit.gx, unit.gy)
end

-- Get supply coverage percentage
function SupplyLine.getCoveragePercent()
    if not _G.state or not _G.state.gameObjectList then return 100 end
    local total = 0
    local supplied = 0
    for _, unit in ipairs(_G.state.gameObjectList) do
        if (not unit.faction or unit.faction == 1) and unit._combatAttached
            and unit.health and unit.health > 0 then
            total = total + 1
            if SupplyLine._isInSupplyRange(unit.gx, unit.gy) then
                supplied = supplied + 1
            end
        end
    end
    if total == 0 then return 100 end
    return (supplied / total) * 100
end

-- Get stats
function SupplyLine.getStats()
    return {
        supplyBuildings = #supplyBuildings,
        outOfSupply = #outOfSupplyUnits,
        coverage = SupplyLine.getCoveragePercent(),
        range = supplyRange,
    }
end

-- Set supply range (for upgrades/tech)
function SupplyLine.setRange(newRange)
    supplyRange = math.max(10, math.min(100, newRange))
    SupplyLine.SUPPLY_RANGE = supplyRange
    print("[SupplyLine] Range set to " .. supplyRange)
end

-- Draw supply coverage (debug visualization)
function SupplyLine.drawDebug()
    if not initialized then return end
    if not _G.state or not _G.state.viewXview then return end

    -- Draw supply range circles
    love.graphics.setColor(0.2, 0.8, 0.2, 0.15)
    for _, building in ipairs(supplyBuildings) do
        if building.gx and building.gy then
            local sx = _G.IsoToScreenX(building.gx, building.gy) - _G.state.viewXview
            local sy = _G.IsoToScreenY(building.gx, building.gy) - _G.state.viewYview
            love.graphics.circle("fill", sx, sy, supplyRange * 4)  -- approximate tile to pixel
        end
    end

    -- Mark out-of-supply units with red indicator
    love.graphics.setColor(1, 0.2, 0.2, 0.8)
    for _, unit in ipairs(outOfSupplyUnits) do
        if unit.gx and unit.gy then
            local sx = _G.IsoToScreenX(unit.gx, unit.gy) - _G.state.viewXview
            local sy = _G.IsoToScreenY(unit.gx, unit.gy) - _G.state.viewYview
            love.graphics.circle("line", sx, sy - 30, 5)
            love.graphics.print("!", sx - 2, sy - 35)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return SupplyLine
