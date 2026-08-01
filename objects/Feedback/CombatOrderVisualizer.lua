-- objects/Feedback/CombatOrderVisualizer.lua
-- Stronghold 2027 - Combat Order Visualizer
--
-- Draws visual indicators for unit orders:
-- - Attack orders: red line from unit to target
-- - Move orders: yellow arrow to destination
-- - Waypoint paths: dashed yellow line
-- - Patrol routes: blue dashed line
-- - Rally points: green marker
--
-- Only shows for SELECTED units (to avoid screen clutter).
--
-- Usage:
--   local CombatViz = require("objects.Feedback.CombatOrderVisualizer")
--   CombatViz.init()
--   CombatViz.update(dt)
--   CombatViz.draw()

local COMBAT = require("objects.Enums.Combat")

local CombatOrderVisualizer = {}

local initialized = false
local enabled = true

-- Animation state
local animTime = 0
local dashOffset = 0

-- Configuration
local config = {
    -- Colors (RGBA)
    attackColor = { 1.0, 0.2, 0.2, 0.8 },      -- red
    moveColor = { 1.0, 0.9, 0.3, 0.7 },        -- yellow
    waypointColor = { 1.0, 0.9, 0.3, 0.5 },    -- yellow (dashed)
    patrolColor = { 0.3, 0.6, 1.0, 0.6 },      -- blue
    rallyColor = { 0.3, 1.0, 0.3, 0.8 },       -- green

    -- Line settings
    lineWidth = 2,
    dashLength = 8,
    dashGap = 6,
    arrowSize = 10,

    -- Animation
    dashSpeed = 30,       -- pixels per second
    pulseSpeed = 3.0,
    pulseAmount = 0.3,

    -- Display settings
    showOnlySelected = true,  -- only show for selected units
    showTargetCircle = true,  -- draw circle around target
    targetCircleRadius = 15,
}

-- Initialize
function CombatOrderVisualizer.init()
    if initialized then return end
    initialized = true
    print("[CombatOrderVisualizer] Initialized")
end

function CombatOrderVisualizer.setEnabled(state)
    enabled = state
end

function CombatOrderVisualizer.isEnabled()
    return enabled
end

-- Update animation
function CombatOrderVisualizer.update(dt)
    if not enabled then return end
    animTime = animTime + dt
    dashOffset = (dashOffset + config.dashSpeed * dt) % (config.dashLength + config.dashGap)
end

-- Convert world coords to screen (isometric)
local function worldToScreen(gx, gy)
    if not gx or not gy then return nil, nil end
    local screenX = gx * 32 - gy * 32
    local screenY = (gx + gy) * 16

    if _G.state and _G.state.viewXview then
        screenX = screenX - _G.state.viewXview
    end
    if _G.state and _G.state.viewYview then
        screenY = screenY - _G.state.viewYview
    end

    local scale = (_G.state and _G.state.scaleX) or 1
    screenX = screenX * scale
    screenY = screenY * scale

    return screenX, screenY
end

-- Draw a dashed line between two points
local function drawDashedLine(x1, y1, x2, y2, color, dashLen, gapLen, offset)
    dashLen = dashLen or config.dashLength
    gapLen = gapLen or config.dashGap
    offset = offset or 0

    local dx = x2 - x1
    local dy = y2 - y1
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist < 1 then return end

    local nx = dx / dist
    local ny = dy / dist

    love.graphics.setColor(color[1], color[2], color[3], color[4])
    love.graphics.setLineWidth(config.lineWidth)

    local pos = -offset
    while pos < dist do
        local start_x = x1 + nx * math.max(0, pos)
        local start_y = y1 + ny * math.max(0, pos)
        local end_x = x1 + nx * math.min(dist, pos + dashLen)
        local end_y = y1 + ny * math.min(dist, pos + dashLen)

        if pos + dashLen > 0 then
            love.graphics.line(start_x, start_y, end_x, end_y)
        end

        pos = pos + dashLen + gapLen
    end
end

-- Draw an arrow at destination
local function drawArrow(x, y, fromX, fromY, color, size)
    size = size or config.arrowSize
    local dx = x - fromX
    local dy = y - fromY
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist < 1 then return end

    local angle = math.atan2(dy, dx)

    love.graphics.setColor(color[1], color[2], color[3], color[4])
    love.graphics.setLineWidth(config.lineWidth)

    -- Arrow head (triangle)
    local x1 = x - math.cos(angle - 0.4) * size
    local y1 = y - math.sin(angle - 0.4) * size
    local x2 = x - math.cos(angle + 0.4) * size
    local y2 = y - math.sin(angle + 0.4) * size

    love.graphics.polygon("fill", x, y, x1, y1, x2, y2)
end

-- Draw a circle around target
local function drawTargetCircle(x, y, color, radius)
    radius = radius or config.targetCircleRadius
    local pulse = 1 + math.sin(animTime * config.pulseSpeed) * config.pulseAmount

    -- Outer glow
    love.graphics.setColor(color[1], color[2], color[3], color[4] * 0.3)
    love.graphics.setLineWidth(config.lineWidth * 3)
    love.graphics.circle("line", x, y, radius * pulse)

    -- Inner ring
    love.graphics.setColor(color[1], color[2], color[3], color[4])
    love.graphics.setLineWidth(config.lineWidth)
    love.graphics.circle("line", x, y, radius * pulse)
end

-- Draw combat orders for a single unit
local function drawUnitOrders(unit)
    if not unit or unit.toBeDeleted then return end
    if not unit.gx or not unit.gy then return end

    local unitX, unitY = worldToScreen(unit.gx, unit.gy)
    if not unitX then return end

    -- === ATTACK ORDER ===
    -- If unit has a target (combat target, not waypoint)
    if unit.target and not unit.target.toBeDeleted
       and unit.target.gx and unit.target.gy
       and unit.combatState and unit.combatState ~= COMBAT.STATE_IDLE then

        local targetX, targetY = worldToScreen(unit.target.gx, unit.target.gy)
        if targetX then
            -- Draw solid red line to target
            love.graphics.setColor(config.attackColor[1], config.attackColor[2],
                                   config.attackColor[3], config.attackColor[4])
            love.graphics.setLineWidth(config.lineWidth)
            love.graphics.line(unitX, unitY, targetX, targetY)

            -- Draw target circle (pulsing)
            if config.showTargetCircle then
                drawTargetCircle(targetX, targetY, config.attackColor)
            end
        end
    end

    -- === MOVE/WAYPOINT ORDER ===
    -- If unit has a waypoint (moving to destination)
    if unit.waypointX and unit.waypointY
       and unit.moveDir and unit.moveDir ~= "none" then

        local wpX, wpY = worldToScreen(unit.waypointX, unit.waypointY)
        if wpX then
            -- Draw dashed yellow line to waypoint
            drawDashedLine(unitX, unitY, wpX, wpY, config.waypointColor,
                          config.dashLength, config.dashGap, dashOffset)

            -- Draw arrow at destination
            drawArrow(wpX, wpY, unitX, unitY, config.moveColor)
        end
    end

    -- === WAYPOINT FLOAT (from Commander) ===
    -- Check if there are waypoint floats assigned to this unit
    if _G.Commander and _G.Commander.waypointFloats then
        for _, wf in ipairs(_G.Commander.waypointFloats) do
            if wf and wf.gx and wf.gy and wf.active then
                local wfX, wfY = worldToScreen(wf.gx, wf.gy)
                if wfX then
                    -- Draw small marker at waypoint
                    love.graphics.setColor(config.moveColor[1], config.moveColor[2],
                                           config.moveColor[3], config.moveColor[4])
                    love.graphics.setLineWidth(config.lineWidth)
                    love.graphics.circle("line", wfX, wfY, 5)

                    -- Draw line from unit to waypoint
                    drawDashedLine(unitX, unitY, wfX, wfY, config.waypointColor,
                                  config.dashLength, config.dashGap, dashOffset)
                end
            end
        end
    end
end

-- Main draw function
function CombatOrderVisualizer.draw()
    if not enabled then return end
    if not _G.state or not _G.state.gameObjectList then return end

    -- Determine which units to show orders for
    local unitsToShow = {}

    if config.showOnlySelected and _G.Commander and _G.Commander.selectedUnits then
        -- Only show for selected units
        for _, unit in ipairs(_G.Commander.selectedUnits) do
            table.insert(unitsToShow, unit)
        end
    else
        -- Show for all units with orders
        for _, unit in ipairs(_G.state.gameObjectList) do
            if unit and not unit.toBeDeleted then
                if (unit.target and unit.combatState ~= COMBAT.STATE_IDLE)
                   or (unit.waypointX and unit.moveDir ~= "none") then
                    table.insert(unitsToShow, unit)
                end
            end
        end
    end

    -- Draw orders for each unit
    for _, unit in ipairs(unitsToShow) do
        drawUnitOrders(unit)
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Get stats for debug
function CombatOrderVisualizer.getStats()
    local count = 0
    if _G.Commander and _G.Commander.selectedUnits then
        for _, unit in ipairs(_G.Commander.selectedUnits) do
            if unit and not unit.toBeDeleted then
                if (unit.target and unit.combatState ~= COMBAT.STATE_IDLE)
                   or (unit.waypointX and unit.moveDir ~= "none") then
                    count = count + 1
                end
            end
        end
    end
    return {
        enabled = enabled,
        visibleOrders = count,
    }
end

-- Configuration setters
function CombatOrderVisualizer.setShowOnlySelected(state)
    config.showOnlySelected = state
end

function CombatOrderVisualizer.setShowTargetCircle(state)
    config.showTargetCircle = state
end

return CombatOrderVisualizer
