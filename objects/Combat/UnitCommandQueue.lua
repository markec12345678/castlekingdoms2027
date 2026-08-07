-- objects/Combat/UnitCommandQueue.lua
-- Castle Kingdoms 2027 - Unit Command Queue
-- Shift+click to queue multiple movement/attack orders

local CommandQueue = {}

local initialized = false

-- Per-unit command queues: {unitId = {commands}}
local queues = {}

-- Command types
local COMMAND = {
    MOVE = "move",
    ATTACK = "attack",
    PATROL = "patrol",
    HOLD = "hold",
    STOP = "stop",
}

CommandQueue.COMMAND = COMMAND

function CommandQueue.init()
    if initialized then return end
    initialized = true
    print("[CommandQueue] Initialized (Shift+click to queue orders)")
end

-- Add a command to a unit's queue
-- @param unit table Unit object
-- @param cmdType string Command type (move, attack, patrol)
-- @param gx number Target grid X
-- @param gy number Target grid Y
-- @param queue boolean If true, add to queue; if false, replace queue
function CommandQueue.addCommand(unit, cmdType, gx, gy, queue)
    if not unit then return false end

    local unitId = tostring(unit)

    -- If not queueing, clear existing commands
    if not queue then
        queues[unitId] = {}
    end

    if not queues[unitId] then
        queues[unitId] = {}
    end

    local cmd = {
        type = cmdType,
        gx = gx,
        gy = gy,
        timestamp = love.timer.getTime(),
    }

    table.insert(queues[unitId], cmd)

    -- If this is the first command, execute immediately
    if #queues[unitId] == 1 then
        CommandQueue._executeNext(unit)
    end

    return true
end

-- Add command to multiple units
function CommandQueue.addCommandToUnits(units, cmdType, gx, gy, queue)
    for _, unit in ipairs(units) do
        CommandQueue.addCommand(unit, cmdType, gx, gy, queue)
    end
end

-- Execute the next command for a unit
function CommandQueue._executeNext(unit)
    if not unit then return end
    local unitId = tostring(unit)
    local queue = queues[unitId]
    if not queue or #queue == 0 then return end

    local cmd = queue[1]

    if cmd.type == COMMAND.MOVE then
        if unit.gotoUserWaypoint then
            unit:gotoUserWaypoint(cmd.gx, cmd.gy, nil, function()
                CommandQueue._onCommandComplete(unit)
            end)
        end
    elseif cmd.type == COMMAND.ATTACK then
        if unit.attackTarget then
            unit:attackTarget(cmd.gx, cmd.gy, function()
                CommandQueue._onCommandComplete(unit)
            end)
        end
    elseif cmd.type == COMMAND.PATROL then
        -- Patrol: move back and forth
        if unit.gotoUserWaypoint then
            unit:gotoUserWaypoint(cmd.gx, cmd.gy, nil, function()
                -- Return to original position
                local origX = cmd.origGx or cmd.gx
                local origY = cmd.origGy or cmd.gy
                CommandQueue.addCommand(unit, COMMAND.MOVE, origX, origY, true)
                CommandQueue.addCommand(unit, COMMAND.PATROL, cmd.gx, cmd.gy, true)
                CommandQueue._onCommandComplete(unit)
            end)
        end
    elseif cmd.type == COMMAND.STOP then
        if unit.stop then unit:stop() end
        CommandQueue.clearQueue(unit)
    end
end

-- Called when a command is completed
function CommandQueue._onCommandComplete(unit)
    if not unit then return end
    local unitId = tostring(unit)
    local queue = queues[unitId]
    if not queue or #queue == 0 then return end

    -- Remove completed command
    table.remove(queue, 1)

    -- Execute next command if any
    if #queue > 0 then
        CommandQueue._executeNext(unit)
    end
end

-- Clear a unit's command queue
function CommandQueue.clearQueue(unit)
    if not unit then return end
    queues[tostring(unit)] = {}
end

-- Clear queues for multiple units
function CommandQueue.clearQueues(units)
    for _, unit in ipairs(units) do
        CommandQueue.clearQueue(unit)
    end
end

-- Get a unit's queue
function CommandQueue.getQueue(unit)
    return queues[tostring(unit)] or {}
end

-- Get queue count for a unit
function CommandQueue.getQueueCount(unit)
    local q = queues[tostring(unit)]
    return q and #q or 0
end

-- Check if shift is held (for queue mode)
function CommandQueue.isQueueMode()
    return love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
end

-- Draw command queue indicators (waypoint lines)
function CommandQueue.draw(unit)
    if not unit then return end
    local queue = queues[tostring(unit)]
    if not queue or #queue == 0 then return end

    -- Draw lines between waypoints
    local prevX, prevY = unit.gx, unit.gy

    for i, cmd in ipairs(queue) do
        if _G.state and _G.state.viewXview then
            local sx1 = _G.IsoToScreenX(prevX, prevY) - _G.state.viewXview
            local sy1 = _G.IsoToScreenY(prevX, prevY) - _G.state.viewYview
            local sx2 = _G.IsoToScreenX(cmd.gx, cmd.gy) - _G.state.viewXview
            local sy2 = _G.IsoToScreenY(cmd.gx, cmd.gy) - _G.state.viewYview

            -- Draw line
            local alpha = 1.0 - (i - 1) * 0.2
            love.graphics.setColor(0.3, 0.8, 1.0, alpha)
            love.graphics.setLineWidth(2)
            love.graphics.line(sx1, sy1, sx2, sy2)

            -- Draw waypoint marker
            love.graphics.circle("fill", sx2, sy2, 4)
            love.graphics.setColor(1, 1, 1, alpha)
            love.graphics.circle("line", sx2, sy2, 4)

            prevX, prevY = cmd.gx, cmd.gy
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

-- Draw queues for all selected units
function CommandQueue.drawSelected(units)
    for _, unit in ipairs(units) do
        CommandQueue.draw(unit)
    end
end

-- Get stats
function CommandQueue.getStats()
    local totalQueued = 0
    local unitsWithQueues = 0
    for _, queue in pairs(queues) do
        if #queue > 0 then
            unitsWithQueues = unitsWithQueues + 1
            totalQueued = totalQueued + #queue
        end
    end
    return {
        unitsWithQueues = unitsWithQueues,
        totalQueued = totalQueued,
    }
end

-- Clean up dead units
function CommandQueue.cleanup(activeUnits)
    local activeIds = {}
    for _, unit in ipairs(activeUnits) do
        activeIds[tostring(unit)] = true
    end

    for unitId, _ in pairs(queues) do
        if not activeIds[unitId] then
            queues[unitId] = nil
        end
    end
end

return CommandQueue
