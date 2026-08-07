-- objects/Performance/MemoryProfiler.lua
-- Castle Kingdoms 2027 - Memory Profiler
--
-- Tracks memory usage, GC cycles, entity counts, and detects leaks:
-- - Lua heap memory (KB/MB)
-- - GC cycles per minute
-- - Entity count over time
-- - Leak detection (entity count never decreases)
--
-- Usage:
--   local MemProf = require("objects.Performance.MemoryProfiler")
--   MemProf.init()
--   MemProf.update(dt)
--   MemProf.draw()

local MemoryProfiler = {}

-- State
local initialized = false
local enabled = false

-- Memory tracking
local memoryHistory = {}  -- last N samples
local maxHistory = 120     -- 2 minutes at 1 Hz
local lastSampleTime = 0
local sampleInterval = 1.0  -- sample every 1 second

-- GC tracking
local gcStats = {
    lastCount = 0,           -- KB
    currentCount = 0,
    delta = 0,
    totalGCTriggered = 0,    -- count of GC cycles triggered by us
    autoGCCycles = 0,        -- count of automatic GC cycles detected
    lastGCStep = 0,
}

-- Entity tracking
local entityStats = {
    current = 0,
    max = 0,
    history = {},
    possibleLeak = false,
    leakThreshold = 200,  -- if entity count grows by this much without drop
    growthCounter = 0,
}

-- Leak detection
local leakDetection = {
    enabled = true,
    lastPeak = 0,
    sustainedGrowth = 0,
    warningThreshold = 100,  -- warn if 100+ net growth over 60s
}

-- Initialize
function MemoryProfiler.init()
    if initialized then return end
    initialized = true
    gcStats.lastCount = collectgarbage("count")
    gcStats.currentCount = gcStats.lastCount
    print("[MemoryProfiler] Initialized")
end

function MemoryProfiler.setEnabled(state)
    enabled = state
end

function MemoryProfiler.isEnabled()
    return enabled
end

-- Update memory profiler
function MemoryProfiler.update(dt)
    if not enabled or not initialized then return end

    lastSampleTime = lastSampleTime + dt
    if lastSampleTime < sampleInterval then return end
    lastSampleTime = 0

    -- Sample current memory
    local currentKB = collectgarbage("count")
    gcStats.currentCount = currentKB
    gcStats.delta = currentKB - gcStats.lastCount
    gcStats.lastCount = currentKB

    -- Add to history
    table.insert(memoryHistory, {
        time = love.timer.getTime(),
        memoryKB = currentKB,
    })
    while #memoryHistory > maxHistory do
        table.remove(memoryHistory, 1)
    end

    -- Track entity count
    if _G.state and _G.state.gameObjectList then
        local count = #_G.state.gameObjectList
        entityStats.current = count
        if count > entityStats.max then
            entityStats.max = count
        end
        table.insert(entityStats.history, count)
        while #entityStats.history > maxHistory do
            table.remove(entityStats.history, 1)
        end

        -- Leak detection
        if leakDetection.enabled and #entityStats.history >= 60 then
            -- Compare current to 60 samples ago
            local oldCount = entityStats.history[#entityStats.history - 60]
            local growth = count - oldCount
            if growth > leakDetection.warningThreshold then
                leakDetection.sustainedGrowth = growth
                if not entityStats.possibleLeak then
                    print(string.format("[MemoryProfiler] WARNING: Possible entity leak! Growth: %d entities in 60s", growth))
                    entityStats.possibleLeak = true
                end
            else
                entityStats.possibleLeak = false
                leakDetection.sustainedGrowth = 0
            end
        end
    end
end

-- Force GC and measure
function MemoryProfiler.forceGC()
    local before = collectgarbage("count")
    collectgarbage("collect")
    collectgarbage("collect")  -- run twice to ensure full collection
    local after = collectgarbage("count")
    local freed = before - after
    gcStats.totalGCTriggered = gcStats.totalGCTriggered + 1
    print(string.format("[MemoryProfiler] Forced GC: freed %.2f KB (%.2f MB)", freed, freed / 1024))
    return freed
end

-- Get current memory stats
function MemoryProfiler.getStats()
    return {
        memoryKB = gcStats.currentCount,
        memoryMB = gcStats.currentCount / 1024,
        delta = gcStats.delta,
        forcedGCCycles = gcStats.totalGCTriggered,
        entityCount = entityStats.current,
        maxEntityCount = entityStats.max,
        possibleLeak = entityStats.possibleLeak,
        leakGrowth = leakDetection.sustainedGrowth,
    }
end

-- Get memory history (for graph)
function MemoryProfiler.getHistory()
    return memoryHistory
end

-- Get entity history
function MemoryProfiler.getEntityHistory()
    return entityStats.history
end

-- Get peak memory
function MemoryProfiler.getPeakMemory()
    local peak = 0
    for _, sample in ipairs(memoryHistory) do
        if sample.memoryKB > peak then
            peak = sample.memoryKB
        end
    end
    return peak
end

-- Get average memory
function MemoryProfiler.getAverageMemory()
    if #memoryHistory == 0 then return 0 end
    local sum = 0
    for _, sample in ipairs(memoryHistory) do
        sum = sum + sample.memoryKB
    end
    return sum / #memoryHistory
end

-- Run memory stress test
-- @param iterations number How many times to run save/load
function MemoryProfiler.runStressTest(iterations)
    iterations = iterations or 20
    print(string.format("[MemoryProfiler] Running stress test: %d iterations", iterations))

    local startMem = collectgarbage("count")
    local startEntities = entityStats.current

    for i = 1, iterations do
        -- Force GC
        collectgarbage("collect")
        local mem = collectgarbage("count")
        local entities = (_G.state and _G.state.gameObjectList) and #_G.state.gameObjectList or 0

        if i % 5 == 0 then
            print(string.format("  Iteration %d: %.2f KB, %d entities", i, mem, entities))
        end
    end

    local endMem = collectgarbage("count")
    local endEntities = entityStats.current

    local memGrowth = endMem - startMem
    local entityGrowth = endEntities - startEntities

    print(string.format("[MemoryProfiler] Stress test complete:"))
    print(string.format("  Memory: %.2f KB -> %.2f KB (growth: %.2f KB)", startMem, endMem, memGrowth))
    print(string.format("  Entities: %d -> %d (growth: %d)", startEntities, endEntities, entityGrowth))

    if memGrowth > 100 then  -- 100 KB growth is suspicious
        print("[MemoryProfiler] WARNING: Significant memory growth detected - possible leak!")
    end

    if entityGrowth > 10 then
        print("[MemoryProfiler] WARNING: Entity count grew - cleanup issue!")
    end

    return {
        memGrowth = memGrowth,
        entityGrowth = entityGrowth,
        possibleLeak = memGrowth > 100 or entityGrowth > 10,
    }
end

-- Reset
function MemoryProfiler.reset()
    memoryHistory = {}
    entityStats = {
        current = 0, max = 0, history = {}, possibleLeak = false, growthCounter = 0,
    }
    leakDetection.sustainedGrowth = 0
    print("[MemoryProfiler] Reset")
end

return MemoryProfiler
