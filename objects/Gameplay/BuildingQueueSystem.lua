-- objects/Gameplay/BuildingQueueSystem.lua
-- Castle Kingdoms 2027 - Building Queue System
-- Shift+click to queue multiple buildings for construction

local BuildingQueue = {}

local initialized = false
local buildQueue = {}  -- { {buildingType, gx, gy, callback}, ... }
local maxQueueSize = 10
local isProcessing = false

function BuildingQueue.init()
    if initialized then return end
    initialized = true
    print("[BuildingQueue] Initialized (shift+click to queue buildings)")
end

-- Add a building to the queue
function BuildingQueue.add(buildingType, gx, gy, callback)
    if not initialized then return false end
    if #buildQueue >= maxQueueSize then
        if _G.ModernUI then
            _G.ModernUI.notifyError("Vrsta gradnje je polna (max " .. maxQueueSize .. ")")
        end
        return false
    end

    table.insert(buildQueue, {
        buildingType = buildingType,
        gx = gx,
        gy = gy,
        callback = callback,
    })

    -- Visual feedback
    if _G.VisualPolish and _G.state then
        local sx = _G.IsoToScreenX(gx, gy) - _G.state.viewXview
        local sy = _G.IsoToScreenY(gx, gy) - _G.state.viewYview
        _G.VisualPolish.spawnEffect(sx, sy, "dust", 5)
    end

    if _G.VoiceOver then
        _G.VoiceOver.notify("building_queued", "Gradnja v vrsti (" .. #buildQueue .. ")")
    end

    print(string.format("[BuildingQueue] Queued: %s at (%d,%d) — queue: %d/%d",
        buildingType, gx, gy, #buildQueue, maxQueueSize))

    -- Start processing if not already
    if not isProcessing then
        BuildingQueue._processNext()
    end

    return true
end

-- Process the next building in queue
function BuildingQueue._processNext()
    if #buildQueue == 0 then
        isProcessing = false
        return
    end

    isProcessing = true
    local entry = buildQueue[1]

    -- Start building
    pcall(function()
        if _G.BuildController and _G.BuildController.set then
            _G.BuildController:set(entry.buildingType, function()
                -- Building placed, remove from queue
                table.remove(buildQueue, 1)

                -- Call callback
                if entry.callback then
                    pcall(entry.callback)
                end

                -- Emit event
                if _G.GameEventBus then
                    _G.GameEventBus.emit("building_built", {
                        buildingType = entry.buildingType,
                        gx = entry.gx,
                        gy = entry.gy,
                        fromQueue = true,
                    })
                end

                -- Process next
                BuildingQueue._processNext()
            end)
        end
    end)
end

-- Clear the queue
function BuildingQueue.clear()
    local count = #buildQueue
    buildQueue = {}
    isProcessing = false
    if count > 0 then
        print("[BuildingQueue] Cleared (" .. count .. " buildings removed)")
    end
end

-- Get the queue
function BuildingQueue.getQueue()
    return buildQueue
end

-- Get queue count
function BuildingQueue.getCount()
    return #buildQueue
end

-- Check if shift is held (queue mode)
function BuildingQueue.isQueueMode()
    return love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
end

-- Draw queue indicators
function BuildingQueue.draw()
    if not initialized or #buildQueue == 0 then return end
    if not _G.state or not _G.state.viewXview then return end

    for i, entry in ipairs(buildQueue) do
        local sx = _G.IsoToScreenX(entry.gx, entry.gy) - _G.state.viewXview
        local sy = _G.IsoToScreenY(entry.gx, entry.gy) - _G.state.viewYview

        -- Draw ghost building marker
        local alpha = 0.8 - (i - 1) * 0.1  -- Fade for later items
        alpha = math.max(0.2, alpha)

        love.graphics.setColor(0.3, 0.6, 1.0, alpha)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", sx - 15, sy - 15, 30, 30)

        -- Queue position number
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print(tostring(i), sx - 4, sy - 25)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

-- Get stats
function BuildingQueue.getStats()
    return {
        queueSize = #buildQueue,
        maxSize = maxQueueSize,
        isProcessing = isProcessing,
    }
end

-- Set max queue size
function BuildingQueue.setMaxSize(size)
    maxQueueSize = math.max(1, math.min(50, size))
end

return BuildingQueue
