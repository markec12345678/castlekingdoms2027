-- objects/Performance/PerformanceOptimizer.lua
-- Stronghold 2027 - Final Performance Optimizer
-- Batch rendering, LOD, frustum culling, update tiering

local PerfOpt = {}

local initialized = false
local stats = {
    drawCalls = 0,
    culledObjects = 0,
    batchedDraws = 0,
    updateSkipped = 0,
}

-- LOD distances (in tiles)
local LOD_DISTANCES = {
    near = 30,    -- Full detail
    medium = 60,  -- Reduced detail
    far = 100,    -- Minimal detail
}

-- Update tiers (Hz)
local UPDATE_TIERS = {
    high = { interval = 1/60, description = "Combat, input, camera" },
    medium = { interval = 1/10, description = "AI, economy, diplomacy" },
    low = { interval = 1/2, description = "Statistics, achievements, stats" },
}

local tierTimers = { high = 0, medium = 0, low = 0 }

function PerfOpt.init()
    if initialized then return end
    initialized = true
    print("[PerfOpt] Initialized")
    print(string.format("[PerfOpt] LOD: near=%d, medium=%d, far=%d",
        LOD_DISTANCES.near, LOD_DISTANCES.medium, LOD_DISTANCES.far))
    print(string.format("[PerfOpt] Update tiers: high=%.0fHz, medium=%.1fHz, low=%.1fHz",
        1/UPDATE_TIERS.high.interval, 1/UPDATE_TIERS.medium.interval, 1/UPDATE_TIERS.low.interval))
end

-- Check if an object should be culled (not visible)
function PerfOpt.shouldCull(gx, gy)
    if not _G.state or not _G.state.viewXview then return false end

    -- Convert to screen coordinates
    local sx = _G.IsoToScreenX(gx, gy) - _G.state.viewXview
    local sy = _G.IsoToScreenY(gx, gy) - _G.state.viewYview

    local w, h = love.graphics.getDimensions()
    local margin = 200  -- Extra margin for smooth scrolling

    -- Frustum culling
    if sx < -margin or sx > w + margin then
        stats.culledObjects = stats.culledObjects + 1
        return true
    end
    if sy < -margin or sy > h + margin then
        stats.culledObjects = stats.culledObjects + 1
        return true
    end

    return false
end

-- Get LOD level for an object
function PerfOpt.getLODLevel(gx, gy)
    if not _G.state or not _G.state.keepX then return "near" end

    local dx = gx - _G.state.keepX
    local dy = gy - _G.state.keepY
    local dist = math.sqrt(dx*dx + dy*dy)

    if dist < LOD_DISTANCES.near then return "near"
    elseif dist < LOD_DISTANCES.medium then return "medium"
    elseif dist < LOD_DISTANCES.far then return "far"
    else return "culled" end
end

-- Check if update tier should run this frame
function PerfOpt.shouldUpdate(tier, dt)
    tierTimers[tier] = tierTimers[tier] + dt
    if tierTimers[tier] >= UPDATE_TIERS[tier].interval then
        tierTimers[tier] = 0
        return true
    end
    stats.updateSkipped = stats.updateSkipped + 1
    return false
end

-- Batch draw setup
local batchCanvas = nil
local isBatching = false

function PerfOpt.beginBatch()
    if not initialized then return end
    local w, h = love.graphics.getDimensions()
    if not batchCanvas then
        batchCanvas = love.graphics.newCanvas(w, h)
    end
    love.graphics.setCanvas(batchCanvas)
    love.graphics.clear(0, 0, 0, 0)
    isBatching = true
    stats.drawCalls = 0
end

function PerfOpt.endBatch()
    if not isBatching then return nil end
    love.graphics.setCanvas()
    isBatching = false
    stats.batchedDraws = stats.batchedDraws + 1
    return batchCanvas
end

-- Draw batched result
function PerfOpt.drawBatch()
    if not batchCanvas then return end
    love.graphics.draw(batchCanvas)
end

-- Reset stats (call at start of frame)
function PerfOpt.resetFrameStats()
    stats.drawCalls = 0
    stats.culledObjects = 0
end

-- Increment draw call counter
function PerfOpt.countDrawCall()
    stats.drawCalls = stats.drawCalls + 1
end

-- Get stats
function PerfOpt.getStats()
    return {
        drawCalls = stats.drawCalls,
        culledObjects = stats.culledObjects,
        batchedDraws = stats.batchedDraws,
        updateSkipped = stats.updateSkipped,
        memoryMB = math.floor(collectgarbage("count") / 1024),
    }
end

-- Get LOD distances
function PerfOpt.getLODDistances()
    return LOD_DISTANCES
end

-- Get update tier info
function PerfOpt.getUpdateTiers()
    return UPDATE_TIERS
end

-- Run garbage collection if needed
function PerfOpt.checkGC()
    local memKB = collectgarbage("count")
    if memKB > 200000 then  -- Over 200MB
        collectgarbage("collect")
        print("[PerfOpt] Garbage collection triggered (was " .. math.floor(memKB/1024) .. " MB)")
    end
end

-- Print performance report
function PerfOpt.printReport()
    local s = PerfOpt.getStats()
    print("\n" .. string.rep("=", 50))
    print("PERFORMANCE REPORT")
    print(string.rep("=", 50))
    print(string.format("Draw calls this frame: %d", s.drawCalls))
    print(string.format("Culled objects: %d", s.culledObjects))
    print(string.format("Batched draws: %d", s.batchedDraws))
    print(string.format("Updates skipped: %d", s.updateSkipped))
    print(string.format("Memory: %d MB", s.memoryMB))
    print(string.rep("=", 50))
end

return PerfOpt
