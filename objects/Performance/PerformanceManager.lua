-- objects/Performance/PerformanceManager.lua
-- Stronghold 2027 - Central Performance Profiling System
--
-- Provides frame-accurate timing for all subsystems:
-- - Game loop (update, render)
-- - AI update (per-faction)
-- - Pathfinding (requests, time, spikes)
-- - Economy tick (market, caravans, events)
-- - Entity update (units, buildings)
-- - Garbage collection
--
-- Usage:
--   local Perf = require("objects.Performance.PerformanceManager")
--   Perf.init()
--   Perf.beginSection("ai_update")
--   -- ... AI work ...
--   Perf.endSection("ai_update")
--   Perf.update(dt)
--   Perf.draw()
--
-- All measurements in milliseconds. Target: 16.7ms per frame (60 FPS).

local PerformanceManager = {}

-- Sections tracked
local SECTIONS = {
    -- Game loop
    update_total    = { color = {0.7, 0.7, 0.7}, category = "Game Loop" },
    render_total    = { color = {0.5, 0.7, 1.0}, category = "Game Loop" },

    -- Subsystems
    ai_update       = { color = {1.0, 0.5, 0.3}, category = "AI" },
    ai_combat       = { color = {1.0, 0.4, 0.2}, category = "AI" },
    ai_economy      = { color = {1.0, 0.6, 0.4}, category = "AI" },
    ai_military     = { color = {1.0, 0.5, 0.3}, category = "AI" },
    ai_commander    = { color = {1.0, 0.5, 0.3}, category = "AI" },

    pathfinding     = { color = {0.9, 0.9, 0.3}, category = "Pathfinding" },
    pathfinding_req = { color = {1.0, 1.0, 0.4}, category = "Pathfinding" },

    economy         = { color = {0.3, 1.0, 0.3}, category = "Economy" },
    market          = { color = {0.4, 0.9, 0.4}, category = "Economy" },
    caravans        = { color = {0.5, 0.8, 0.5}, category = "Economy" },
    events          = { color = {0.6, 0.7, 0.6}, category = "Economy" },
    seasons         = { color = {0.5, 0.8, 0.7}, category = "Economy" },

    combat          = { color = {1.0, 0.3, 0.3}, category = "Combat" },
    projectiles     = { color = {1.0, 0.4, 0.4}, category = "Combat" },
    health_bars     = { color = {1.0, 0.5, 0.5}, category = "Combat" },

    entities        = { color = {0.7, 0.5, 1.0}, category = "Entities" },
    animation       = { color = {0.8, 0.6, 1.0}, category = "Entities" },

    weather         = { color = {0.5, 0.7, 1.0}, category = "Render" },
    lighting        = { color = {0.6, 0.8, 1.0}, category = "Render" },
    ui              = { color = {0.8, 0.8, 0.8}, category = "Render" },
    mission         = { color = {0.9, 0.7, 0.5}, category = "Game Loop" },

    gc              = { color = {0.5, 0.5, 0.5}, category = "Memory" },
    other           = { color = {0.4, 0.4, 0.4}, category = "Other" },
}

-- State
local initialized = false
local enabled = false
local detailed = false

-- Per-frame measurements
local frameSections = {}  -- section -> { count, totalTime, maxTime, startTime }
local frameHistory = {}   -- last N frames for trend
local maxHistory = 120    -- 2 seconds at 60 FPS

-- Pathfinding specific tracking
local pathfindingStats = {
    requestsThisFrame = 0,
    requestsTotal = 0,
    totalTimeThisFrame = 0,
    maxSpike = 0,
    recentSpikes = {},  -- spikes > 5ms
}

-- Memory tracking
local memoryStats = {
    lastGCCount = 0,
    gcDelta = 0,
    gcCycles = 0,
    lastGCTime = 0,
    entityCount = 0,
    maxEntityCount = 0,
}

-- Frame stats
local frameStats = {
    fps = 60,
    frameTime = 16.7,
    targetFrameTime = 16.7,  -- 60 FPS
    frames = 0,
    lastFPSUpdate = 0,
    fpsHistory = {},
}

-- Initialize
function PerformanceManager.init()
    if initialized then return end
    initialized = true

    -- Initialize all sections
    for name, _ in pairs(SECTIONS) do
        frameSections[name] = {
            count = 0,
            totalTime = 0,
            maxTime = 0,
            startTime = 0,
            active = false,
        }
    end

    print("[PerformanceManager] Initialized with " .. #SECTIONS .. " sections")
end

-- Enable/disable profiling
function PerformanceManager.setEnabled(state)
    enabled = state
    if state and not initialized then
        PerformanceManager.init()
    end
end

function PerformanceManager.isEnabled()
    return enabled
end

function PerformanceManager.setDetailed(state)
    detailed = state
end

function PerformanceManager.isDetailed()
    return detailed
end

-- Begin a section
function PerformanceManager.beginSection(name)
    if not enabled then return end
    if not frameSections[name] then
        -- Auto-create unknown sections
        frameSections[name] = {
            count = 0, totalTime = 0, maxTime = 0, startTime = 0, active = false
        }
    end
    frameSections[name].startTime = love.timer.getTime() * 1000  -- ms
    frameSections[name].active = true
end

-- End a section
function PerformanceManager.endSection(name)
    if not enabled then return end
    local section = frameSections[name]
    if not section or not section.active then return end

    local elapsed = (love.timer.getTime() * 1000) - section.startTime
    section.totalTime = section.totalTime + elapsed
    section.count = section.count + 1
    if elapsed > section.maxTime then
        section.maxTime = elapsed
    end
    section.active = false

    -- Track pathfinding specifically
    if name == "pathfinding" or name == "pathfinding_req" then
        pathfindingStats.requestsThisFrame = pathfindingStats.requestsThisFrame + 1
        pathfindingStats.requestsTotal = pathfindingStats.requestsTotal + 1
        pathfindingStats.totalTimeThisFrame = pathfindingStats.totalTimeThisFrame + elapsed
        if elapsed > pathfindingStats.maxSpike then
            pathfindingStats.maxSpike = elapsed
        end
        if elapsed > 5 then  -- spike threshold
            table.insert(pathfindingStats.recentSpikes, {
                time = love.timer.getTime(),
                duration = elapsed,
            })
            -- Keep only last 20 spikes
            while #pathfindingStats.recentSpikes > 20 do
                table.remove(pathfindingStats.recentSpikes, 1)
            end
        end
    end
end

-- Record pathfinding request (manual)
function PerformanceManager.recordPathfindingRequest(durationMs)
    if not enabled then return end
    pathfindingStats.requestsThisFrame = pathfindingStats.requestsThisFrame + 1
    pathfindingStats.requestsTotal = pathfindingStats.requestsTotal + 1
    pathfindingStats.totalTimeThisFrame = pathfindingStats.totalTimeThisFrame + durationMs
    if durationMs > pathfindingStats.maxSpike then
        pathfindingStats.maxSpike = durationMs
    end
end

-- Update performance manager (called once per frame)
function PerformanceManager.update(dt)
    if not enabled then return end

    -- Update FPS
    frameStats.frames = frameStats.frames + 1
    frameStats.frameTime = dt * 1000
    local now = love.timer.getTime()
    if now - frameStats.lastFPSUpdate >= 0.5 then
        frameStats.fps = frameStats.frames / (now - frameStats.lastFPSUpdate)
        frameStats.frames = 0
        frameStats.lastFPSUpdate = now
        table.insert(frameStats.fpsHistory, frameStats.fps)
        while #frameStats.fpsHistory > maxHistory do
            table.remove(frameStats.fpsHistory, 1)
        end
    end

    -- Snapshot frame into history
    local snapshot = {}
    for name, section in pairs(frameSections) do
        snapshot[name] = {
            totalTime = section.totalTime,
            count = section.count,
            maxTime = section.maxTime,
        }
    end
    table.insert(frameHistory, snapshot)
    while #frameHistory > maxHistory do
        table.remove(frameHistory, 1)
    end

    -- Reset per-frame counters
    for _, section in pairs(frameSections) do
        section.totalTime = 0
        section.count = 0
        section.maxTime = 0
    end

    -- Reset pathfinding per-frame counter
    pathfindingStats.requestsThisFrame = 0
    pathfindingStats.totalTimeThisFrame = 0

    -- Track GC
    local currentGC = collectgarbage("count")
    memoryStats.gcDelta = currentGC - memoryStats.lastGCCount
    memoryStats.lastGCCount = currentGC

    -- Track entity count
    if _G.state and _G.state.gameObjectList then
        memoryStats.entityCount = #_G.state.gameObjectList
        if memoryStats.entityCount > memoryStats.maxEntityCount then
            memoryStats.maxEntityCount = memoryStats.entityCount
        end
    end
end

-- Get average for a section over recent history
function PerformanceManager.getAverageTime(name)
    if #frameHistory == 0 then return 0 end
    local sum = 0
    local count = 0
    for _, snapshot in ipairs(frameHistory) do
        if snapshot[name] and snapshot[name].count > 0 then
            sum = sum + snapshot[name].totalTime
            count = count + 1
        end
    end
    if count == 0 then return 0 end
    return sum / count
end

-- Get max for a section over recent history
function PerformanceManager.getMaxTime(name)
    if #frameHistory == 0 then return 0 end
    local maxTime = 0
    for _, snapshot in ipairs(frameHistory) do
        if snapshot[name] and snapshot[name].maxTime > maxTime then
            maxTime = snapshot[name].maxTime
        end
    end
    return maxTime
end

-- Get all section data for current frame
function PerformanceManager.getSectionData()
    local data = {}
    for name, info in pairs(SECTIONS) do
        local avg = PerformanceManager.getAverageTime(name)
        local max = PerformanceManager.getMaxTime(name)
        if avg > 0.01 or max > 0.01 then  -- only include active sections
            table.insert(data, {
                name = name,
                category = info.category,
                color = info.color,
                avgTime = avg,
                maxTime = max,
                percent = (avg / frameStats.targetFrameTime) * 100,
            })
        end
    end
    -- Sort by average time descending
    table.sort(data, function(a, b) return a.avgTime > b.avgTime end)
    return data
end

-- Get frame stats
function PerformanceManager.getFrameStats()
    return {
        fps = frameStats.fps,
        frameTime = frameStats.frameTime,
        targetFrameTime = frameStats.targetFrameTime,
        frameBudgetUsed = (frameStats.frameTime / frameStats.targetFrameTime) * 100,
    }
end

-- Get pathfinding stats
function PerformanceManager.getPathfindingStats()
    return {
        requestsPerFrame = pathfindingStats.requestsThisFrame,
        requestsTotal = pathfindingStats.requestsTotal,
        avgTimePerRequest = pathfindingStats.requestsThisFrame > 0
            and pathfindingStats.totalTimeThisFrame / pathfindingStats.requestsThisFrame
            or 0,
        maxSpike = pathfindingStats.maxSpike,
        recentSpikeCount = #pathfindingStats.recentSpikes,
        recentSpikes = pathfindingStats.recentSpikes,
    }
end

-- Get memory stats
function PerformanceManager.getMemoryStats()
    return {
        memoryKB = memoryStats.lastGCCount,
        memoryMB = memoryStats.lastGCCount / 1024,
        gcDelta = memoryStats.gcDelta,
        entityCount = memoryStats.entityCount,
        maxEntityCount = memoryStats.maxEntityCount,
    }
end

-- Get full report (for console)
function PerformanceManager.getReport()
    local report = {}
    table.insert(report, "=== Performance Report ===")
    table.insert(report, string.format("FPS: %.1f (frame time: %.2fms / %.2fms budget)",
        frameStats.fps, frameStats.frameTime, frameStats.targetFrameTime))
    table.insert(report, "")

    table.insert(report, "Section breakdown (avg / max ms):")
    local data = PerformanceManager.getSectionData()
    for _, section in ipairs(data) do
        table.insert(report, string.format("  %-20s %6.2f / %6.2f ms  (%.1f%%)  %s",
            section.name, section.avgTime, section.maxTime, section.percent, section.category))
    end

    table.insert(report, "")
    table.insert(report, "Pathfinding:")
    local pf = PerformanceManager.getPathfindingStats()
    table.insert(report, string.format("  Requests this frame: %d", pf.requestsPerFrame))
    table.insert(report, string.format("  Total requests: %d", pf.requestsTotal))
    table.insert(report, string.format("  Avg time/request: %.2fms", pf.avgTimePerRequest))
    table.insert(report, string.format("  Max spike: %.2fms", pf.maxSpike))
    table.insert(report, string.format("  Recent spikes (>5ms): %d", pf.recentSpikeCount))

    table.insert(report, "")
    table.insert(report, "Memory:")
    local mem = PerformanceManager.getMemoryStats()
    table.insert(report, string.format("  Memory: %.2f MB", mem.memoryMB))
    table.insert(report, string.format("  GC delta: %.2f KB/frame", mem.gcDelta))
    table.insert(report, string.format("  Entities: %d (max: %d)", mem.entityCount, mem.maxEntityCount))

    return table.concat(report, "\n")
end

-- Reset all stats (for benchmark runs)
function PerformanceManager.reset()
    for _, section in pairs(frameSections) do
        section.totalTime = 0
        section.count = 0
        section.maxTime = 0
    end
    frameHistory = {}
    pathfindingStats.requestsThisFrame = 0
    pathfindingStats.requestsTotal = 0
    pathfindingStats.totalTimeThisFrame = 0
    pathfindingStats.maxSpike = 0
    pathfindingStats.recentSpikes = {}
    memoryStats.maxEntityCount = 0
    print("[PerformanceManager] Stats reset")
end

return PerformanceManager
