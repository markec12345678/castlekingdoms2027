-- objects/Gameplay/RallyPointSystem.lua
-- Stronghold 2027 - Rally Point System
-- Barracks and military buildings auto-send trained units to a rally point

local RallyPoint = {}

local initialized = false
local rallyPoints = {}  -- {buildingId = {gx, gy, active}}

function RallyPoint.init()
    if initialized then return end
    initialized = true
    print("[RallyPoint] Initialized (right-click barracks to set rally point)")
end

-- Set rally point for a building
function RallyPoint.set(building, gx, gy)
    if not building then return false end
    local id = tostring(building)
    rallyPoints[id] = {
        gx = gx,
        gy = gy,
        active = true,
        building = building,
    }
    print(string.format("[RallyPoint] Set for %s at (%d, %d)", id, gx, gy))

    -- Visual feedback
    if _G.VisualPolish and _G.state then
        local sx = _G.IsoToScreenX(gx, gy) - _G.state.viewXview
        local sy = _G.IsoToScreenY(gx, gy) - _G.state.viewYview
        _G.VisualPolish.spawnEffect(sx, sy, "spark", 8)
    end

    -- Voice notification
    if _G.VoiceOver then
        _G.VoiceOver.notify("rally_point_set", "Zbirno mesto")
    end

    return true
end

-- Clear rally point for a building
function RallyPoint.clear(building)
    if not building then return false end
    local id = tostring(building)
    if rallyPoints[id] then
        rallyPoints[id] = nil
        print("[RallyPoint] Cleared for " .. id)
        return true
    end
    return false
end

-- Get rally point for a building
function RallyPoint.get(building)
    if not building then return nil end
    return rallyPoints[tostring(building)]
end

-- Check if building has a rally point
function RallyPoint.has(building)
    if not building then return false end
    local rp = rallyPoints[tostring(building)]
    return rp ~= nil and rp.active
end

-- Send a newly trained unit to the rally point
function RallyPoint.sendUnit(unit, sourceBuilding)
    if not unit or not sourceBuilding then return false end
    local rp = rallyPoints[tostring(sourceBuilding)]
    if not rp or not rp.active then return false end

    -- Move unit to rally point
    if unit.gotoUserWaypoint then
        unit:gotoUserWaypoint(rp.gx, rp.gy, nil, nil)
    end

    return true
end

-- Draw rally point indicators
function RallyPoint.draw()
    if not initialized then return end
    if not _G.state or not _G.state.viewXview then return end

    for buildingId, rp in pairs(rallyPoints) do
        if rp.active and rp.gx and rp.gy then
            local sx = _G.IsoToScreenX(rp.gx, rp.gy) - _G.state.viewXview
            local sy = _G.IsoToScreenY(rp.gx, rp.gy) - _G.state.viewYview

            -- Draw flag/marker
            love.graphics.setColor(1, 0.8, 0.2, 0.9)
            love.graphics.circle("fill", sx, sy, 6)
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.circle("line", sx, sy, 6)

            -- Draw line from building to rally point
            if rp.building and rp.building.gx and rp.building.gy then
                local bx = _G.IsoToScreenX(rp.building.gx, rp.building.gy) - _G.state.viewXview
                local by = _G.IsoToScreenY(rp.building.gx, rp.building.gy) - _G.state.viewYview
                love.graphics.setColor(1, 0.8, 0.2, 0.3)
                love.graphics.setLineWidth(2)
                love.graphics.line(bx, by, sx, sy)
            end

            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setLineWidth(1)
        end
    end
end

-- Get all rally points
function RallyPoint.getAll()
    return rallyPoints
end

-- Get stats
function RallyPoint.getStats()
    local count = 0
    for _ in pairs(rallyPoints) do count = count + 1 end
    return { activeRallyPoints = count }
end

return RallyPoint
