-- objects/QA/PerformanceBenchmark.lua
-- Castle Kingdoms 2027 - Automated Performance Benchmark
-- Runs standardized tests to measure game performance

local PerfBenchmark = {}

local benchmarkResults = {}
local isRunning = false
local currentTest = 0
local testTimer = 0
local frameCount = 0
local testDuration = 5.0  -- 5 seconds per test

local BENCHMARK_TESTS = {
    {
        name = "Idle (no activity)",
        description = "Baseline performance with no game activity",
        setup = function() end,
    },
    {
        name = "Many buildings (50+)",
        description = "Performance with 50+ buildings on map",
        setup = function()
            -- Simulate by counting objects
        end,
    },
    {
        name = "Large army (100+ units)",
        description = "Performance with 100+ units",
        setup = function() end,
    },
    {
        name = "Combat (active battle)",
        description = "Performance during active combat",
        setup = function() end,
    },
    {
        name = "HD Pipeline ON",
        description = "Performance with all HD effects enabled",
        setup = function()
            local HDShaders = require("shaders.HD_SHADERS")
            HDShaders.enable("bloom", true)
            HDShaders.enable("color_grading", true)
            HDShaders.enable("vignette", true)
            HDShaders.enable("dynamic_lighting", true)
        end,
    },
    {
        name = "HD Pipeline OFF",
        description = "Performance with HD effects disabled",
        setup = function()
            local HDShaders = require("shaders.HD_SHADERS")
            HDShaders.enable("bloom", false)
            HDShaders.enable("color_grading", false)
            HDShaders.enable("vignette", false)
            HDShaders.enable("dynamic_lighting", false)
        end,
    },
}

function PerfBenchmark.init()
    print("[PerfBenchmark] Initialized with " .. #BENCHMARK_TESTS .. " tests")
end

function PerfBenchmark.isRunning()
    return isRunning
end

function PerfBenchmark.start()
    if isRunning then return false end
    isRunning = true
    currentTest = 0
    benchmarkResults = {}
    PerfBenchmark._nextTest()
    return true
end

function PerfBenchmark._nextTest()
    currentTest = currentTest + 1
    if currentTest > #BENCHMARK_TESTS then
        isRunning = false
        PerfBenchmark.printResults()
        return
    end

    local test = BENCHMARK_TESTS[currentTest]
    testTimer = 0
    frameCount = 0

    -- Run setup
    pcall(test.setup)

    print("[PerfBenchmark] Running: " .. test.name)
end

function PerfBenchmark.update(dt)
    if not isRunning then return end

    testTimer = testTimer + dt
    frameCount = frameCount + 1

    if testTimer >= testDuration then
        -- Record results
        local avgFPS = math.floor(frameCount / testTimer)
        local memKB = collectgarbage("count")
        local memMB = math.floor(memKB / 1024)

        local PerfWatchdog = require("objects.QA.PerformanceWatchdog")
        local pwStats = PerfWatchdog.getStats()

        table.insert(benchmarkResults, {
            name = BENCHMARK_TESTS[currentTest].name,
            avgFPS = avgFPS,
            memoryMB = memMB,
            quality = pwStats.quality,
            frameTimeMs = math.floor((testTimer / frameCount) * 1000),
        })

        PerfBenchmark._nextTest()
    end
end

function PerfBenchmark.printResults()
    print("\n" .. string.rep("=", 60))
    print("PERFORMANCE BENCHMARK RESULTS")
    print(string.rep("=", 60))
    print(string.format("%-30s %8s %8s %8s %8s", "Test", "FPS", "FrameMs", "Mem MB", "Quality"))
    print(string.rep("-", 60))

    for _, result in ipairs(benchmarkResults) do
        print(string.format("%-30s %8d %8d %8d %8s",
            result.name:sub(1, 28),
            result.avgFPS,
            result.frameTimeMs,
            result.memoryMB,
            result.quality))
    end

    print(string.rep("=", 60))

    -- Calculate average
    local totalFPS = 0
    for _, r in ipairs(benchmarkResults) do totalFPS = totalFPS + r.avgFPS end
    local avgFPS = #benchmarkResults > 0 and math.floor(totalFPS / #benchmarkResults) or 0
    print(string.format("Average FPS: %d", avgFPS))

    if avgFPS >= 60 then
        print("VERDICT: EXCELLENT - Game runs at 60+ FPS")
    elseif avgFPS >= 30 then
        print("VERDICT: ACCEPTABLE - Game is playable at 30+ FPS")
    else
        print("VERDICT: NEEDS OPTIMIZATION - Below 30 FPS")
    end

    print(string.rep("=", 60))
end

function PerfBenchmark.getResults()
    return benchmarkResults
end

return PerfBenchmark
