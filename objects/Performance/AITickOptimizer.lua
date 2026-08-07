-- objects/Performance/AITickOptimizer.lua
-- Castle Kingdoms 2027 - AI Tick Frequency Optimizer
--
-- Instead of all AI thinking every frame, AI is split into tick frequencies:
--
--   Combat reaction:   0.25s  (4 Hz)   - immediate threat response
--   Tactical decision: 1.0s   (1 Hz)   - unit movement, target selection
--   Economy:           5.0s   (0.2 Hz) - resource management
--   Strategic:         15.0s  (0.07 Hz) - build queue, army composition
--   Personality:       60.0s  (0.02 Hz) - long-term strategy adjustments
--
-- This reduces AI CPU usage by ~80% with minimal gameplay impact.

local AITickOptimizer = {}

-- Tick categories
local TICK_CATEGORIES = {
    combat = {
        interval = 0.25,    -- 4 Hz
        description = "Combat reaction (immediate threat response)",
        maxPerTick = 50,    -- max units to process per tick
    },
    tactical = {
        interval = 1.0,     -- 1 Hz
        description = "Tactical (unit movement, target selection)",
        maxPerTick = 30,
    },
    economy = {
        interval = 5.0,     -- 0.2 Hz
        description = "Economy (resource management, trade)",
        maxPerTick = 10,
    },
    strategic = {
        interval = 15.0,    -- 0.067 Hz
        description = "Strategic (build queue, army composition)",
        maxPerTick = 5,
    },
    personality = {
        interval = 60.0,    -- 0.017 Hz
        description = "Personality (long-term strategy)",
        maxPerTick = 1,
    },
}

-- State
local initialized = false
local enabled = true

-- Timers per category
local timers = {
    combat = 0,
    tactical = 0,
    economy = 0,
    strategic = 0,
    personality = 0,
}

-- Stats
local stats = {
    ticksThisFrame = 0,
    skippedTicks = 0,
    totalTicksRun = 0,
    perCategory = {
        combat = { runs = 0, totalTime = 0, maxTime = 0 },
        tactical = { runs = 0, totalTime = 0, maxTime = 0 },
        economy = { runs = 0, totalTime = 0, maxTime = 0 },
        strategic = { runs = 0, totalTime = 0, maxTime = 0 },
        personality = { runs = 0, totalTime = 0, maxTime = 0 },
    },
}

-- Initialize
function AITickOptimizer.init()
    if initialized then return end
    initialized = true
    print("[AITickOptimizer] Initialized - combat(4Hz), tactical(1Hz), economy(0.2Hz), strategic(0.07Hz), personality(0.02Hz)")
end

function AITickOptimizer.setEnabled(state)
    enabled = state
end

-- Check if a category should tick this frame
-- @param category string "combat", "tactical", "economy", "strategic", "personality"
-- @return boolean should tick
function AITickOptimizer.shouldTick(category)
    if not enabled or not initialized then return true end  -- fallback: always tick if disabled
    if not TICK_CATEGORIES[category] then return true end

    -- We don't update timer here; caller must call tickComplete after
    return timers[category] >= TICK_CATEGORIES[category].interval
end

-- Mark a tick as complete (resets timer for that category)
function AITickOptimizer.tickComplete(category, durationMs)
    if not TICK_CATEGORIES[category] then return end
    timers[category] = 0
    stats.totalTicksRun = stats.totalTicksRun + 1
    stats.ticksThisFrame = stats.ticksThisFrame + 1

    local catStats = stats.perCategory[category]
    catStats.runs = catStats.runs + 1
    catStats.totalTime = catStats.totalTime + (durationMs or 0)
    if (durationMs or 0) > catStats.maxTime then
        catStats.maxTime = durationMs or 0
    end
end

-- Update timers (called every frame)
function AITickOptimizer.update(dt)
    if not enabled or not initialized then return end

    for category, _ in pairs(TICK_CATEGORIES) do
        timers[category] = timers[category] + dt
    end

    stats.ticksThisFrame = 0
end

-- Convenience: run a function if category should tick
-- @param category string
-- @param fn function The AI logic to run
-- @return boolean true if ran, false if skipped
function AITickOptimizer.runIfTick(category, fn)
    if not AITickOptimizer.shouldTick(category) then
        stats.skippedTicks = stats.skippedTicks + 1
        return false
    end

    local startTime = love.timer.getTime() * 1000
    fn()
    local duration = (love.timer.getTime() * 1000) - startTime

    AITickOptimizer.tickComplete(category, duration)
    return true
end

-- Get stats
function AITickOptimizer.getStats()
    local result = {
        ticksThisFrame = stats.ticksThisFrame,
        skippedTicks = stats.skippedTicks,
        totalTicksRun = stats.totalTicksRun,
        categories = {},
    }

    for category, catStats in pairs(stats.perCategory) do
        result.categories[category] = {
            runs = catStats.runs,
            avgTime = catStats.runs > 0 and catStats.totalTime / catStats.runs or 0,
            maxTime = catStats.maxTime,
            interval = TICK_CATEGORIES[category].interval,
            actualHz = catStats.runs > 0 and 1 / TICK_CATEGORIES[category].interval or 0,
        }
    end

    return result
end

-- Get interval for a category
function AITickOptimizer.getInterval(category)
    if not TICK_CATEGORIES[category] then return 0 end
    return TICK_CATEGORIES[category].interval
end

-- Set custom interval (for testing)
function AITickOptimizer.setInterval(category, interval)
    if TICK_CATEGORIES[category] then
        TICK_CATEGORIES[category].interval = interval
        print(string.format("[AITickOptimizer] %s interval set to %.2fs", category, interval))
    end
end

-- Get all categories info
function AITickOptimizer.getCategories()
    local list = {}
    for name, info in pairs(TICK_CATEGORIES) do
        table.insert(list, {
            name = name,
            interval = info.interval,
            frequency = 1 / info.interval,
            description = info.description,
            maxPerTick = info.maxPerTick,
        })
    end
    table.sort(list, function(a, b) return a.interval < b.interval end)
    return list
end

-- Reset
function AITickOptimizer.reset()
    timers = { combat = 0, tactical = 0, economy = 0, strategic = 0, personality = 0 }
    stats.totalTicksRun = 0
    stats.skippedTicks = 0
    for _, catStats in pairs(stats.perCategory) do
        catStats.runs = 0
        catStats.totalTime = 0
        catStats.maxTime = 0
    end
    print("[AITickOptimizer] Reset")
end

return AITickOptimizer
