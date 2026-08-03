-- objects/Gameplay/DynamicUnitCap.lua
-- Stronghold 2027 - Dynamic Unit Cap
-- Adjusts max unit count based on hardware performance

local DynamicUnitCap = {}

local initialized = false
local currentCap = 200
local minCap = 50
local maxCap = 500
local checkTimer = 0
local checkInterval = 10  -- Check every 10 seconds
local fpsHistory = {}
local maxHistory = 6  -- Last 60 seconds (6 × 10s)

function DynamicUnitCap.init()
    if initialized then return end
    initialized = true
    currentCap = 200
    print("[DynamicUnitCap] Initialized (base cap: " .. currentCap .. ")")
end

function DynamicUnitCap.update(dt)
    if not initialized then return end

    checkTimer = checkTimer + dt
    if checkTimer < checkInterval then return end
    checkTimer = 0

    -- Get current FPS
    local PerfWatchdog = require("objects.QA.PerformanceWatchdog")
    local stats = PerfWatchdog.getStats()
    local fps = stats.fps or 60

    table.insert(fpsHistory, fps)
    if #fpsHistory > maxHistory then
        table.remove(fpsHistory, 1)
    end

    -- Calculate average FPS
    local avgFPS = 0
    for _, f in ipairs(fpsHistory) do avgFPS = avgFPS + f end
    avgFPS = avgFPS / #fpsHistory

    -- Adjust cap based on performance
    local oldCap = currentCap

    if avgFPS >= 55 then
        -- Good performance — increase cap
        currentCap = math.min(maxCap, currentCap + 10)
    elseif avgFPS < 25 then
        -- Poor performance — decrease cap
        currentCap = math.max(minCap, currentCap - 20)
    elseif avgFPS < 35 then
        -- Marginal — slight decrease
        currentCap = math.max(minCap, currentCap - 5)
    end

    if currentCap ~= oldCap then
        print(string.format("[DynamicUnitCap] %d -> %d (avg FPS: %.0f)", oldCap, currentCap, avgFPS))
        if _G.ModernUI and math.abs(currentCap - oldCap) >= 20 then
            _G.ModernUI.notifyInfo("Omejitev enot: " .. currentCap)
        end
    end
end

function DynamicUnitCap.getCap()
    return currentCap
end

function DynamicUnitCap.setCap(cap)
    currentCap = math.max(minCap, math.min(maxCap, cap))
    print("[DynamicUnitCap] Manually set to " .. currentCap)
end

function DynamicUnitCap.getStats()
    local avgFPS = 0
    for _, f in ipairs(fpsHistory) do avgFPS = avgFPS + f end
    avgFPS = #fpsHistory > 0 and avgFPS / #fpsHistory or 0

    return {
        currentCap = currentCap,
        minCap = minCap,
        maxCap = maxCap,
        avgFPS = math.floor(avgFPS),
        historySize = #fpsHistory,
    }
end

function DynamicUnitCap.setMinMax(minimum, maximum)
    minCap = math.max(10, minimum)
    maxCap = math.min(2000, maximum)
    currentCap = math.max(minCap, math.min(maxCap, currentCap))
    print(string.format("[DynamicUnitCap] Range: %d-%d", minCap, maxCap))
end

return DynamicUnitCap
