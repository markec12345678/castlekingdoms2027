-- objects/QA/PerformanceWatchdog.lua
-- Castle Kingdoms 2027 - Performance Watchdog
--
-- Monitors game performance and auto-adjusts quality settings:
-- - FPS tracking (1s average)
-- - Frame time tracking
-- - Auto-degrade when FPS < 30 for 5s
-- - Auto-upgrade when FPS > 55 for 10s
-- - Memory usage monitoring
--
-- Usage:
--   local PerfWatchdog = require("objects.QA.PerformanceWatchdog")
--   PerfWatchdog.init()
--   PerfWatchdog.update(dt)  -- call every frame
--   PerfWatchdog.getStats()

local PerfWatchdog = {}

local initialized = false
local frameTimes = {}
local maxFrameTimes = 60  -- Track last 60 frames
local fpsHistory = {}
local maxFpsHistory = 10  -- Track last 10 seconds
local lastFpsUpdate = 0
local currentFps = 60
local avgFps = 60
local lowFpsDuration = 0
local highFpsDuration = 0
local autoAdjustEnabled = true

-- Quality levels
local QUALITY = {
    ULTRA = 4,
    HIGH = 3,
    MEDIUM = 2,
    LOW = 1,
}

PerfWatchdog.QUALITY = QUALITY
local currentQuality = QUALITY.HIGH

-- Initialize
function PerfWatchdog.init()
    if initialized then return end
    initialized = true
    print("[PerfWatchdog] Initialized (quality: " .. PerfWatchdog.getQualityName() .. ")")
end

-- Get quality level name
function PerfWatchdog.getQualityName()
    for name, level in pairs(QUALITY) do
        if level == currentQuality then return name end
    end
    return "UNKNOWN"
end

-- Get current quality level
function PerfWatchdog.getQuality()
    return currentQuality
end

-- Set quality level manually
function PerfWatchdog.setQuality(level)
    if level < QUALITY.LOW or level > QUALITY.ULTRA then return end
    if level == currentQuality then return end

    local oldName = PerfWatchdog.getQualityName()
    currentQuality = level
    local newName = PerfWatchdog.getQualityName()

    print(string.format("[PerfWatchdog] Quality changed: %s -> %s", oldName, newName))

    -- Apply quality settings
    PerfWatchdog._applyQualitySettings()

    -- Reset timers
    lowFpsDuration = 0
    highFpsDuration = 0
end

-- Apply quality settings based on current level
function PerfWatchdog._applyQualitySettings()
    local HDRenderPipeline = require("objects.Environment.HDRenderPipeline")
    local LightingSystem = require("objects.Environment.LightingSystem")
    local HDShaders = require("shaders.HD_SHADERS")

    if currentQuality == QUALITY.ULTRA then
        -- Everything on
        HDRenderPipeline.setEnabled(true)
        HDShaders.enable("bloom", true)
        HDShaders.enable("ssao", true)
        HDShaders.enable("color_grading", true)
        HDShaders.enable("vignette", true)
        HDShaders.enable("dynamic_lighting", true)

    elseif currentQuality == QUALITY.HIGH then
        -- Most effects on, SSAO off
        HDRenderPipeline.setEnabled(true)
        HDShaders.enable("bloom", true)
        HDShaders.enable("color_grading", true)
        HDShaders.enable("vignette", true)
        HDShaders.enable("dynamic_lighting", true)

    elseif currentQuality == QUALITY.MEDIUM then
        -- Core effects only
        HDRenderPipeline.setEnabled(true)
        HDShaders.enable("bloom", false)
        HDShaders.enable("color_grading", true)
        HDShaders.enable("vignette", false)
        HDShaders.enable("dynamic_lighting", true)

    elseif currentQuality == QUALITY.LOW then
        -- Everything off for max FPS
        HDRenderPipeline.setEnabled(false)
        HDShaders.enable("bloom", false)
        HDShaders.enable("color_grading", false)
        HDShaders.enable("vignette", false)
        HDShaders.enable("dynamic_lighting", false)
    end
end

-- Update (call every frame)
function PerfWatchdog.update(dt)
    if not initialized then return end

    -- Track frame time
    table.insert(frameTimes, dt)
    if #frameTimes > maxFrameTimes then
        table.remove(frameTimes, 1)
    end

    -- Update FPS every second
    lastFpsUpdate = lastFpsUpdate + dt
    if lastFpsUpdate >= 1.0 then
        lastFpsUpdate = 0

        -- Calculate current FPS
        if #frameTimes > 0 then
            local sum = 0
            for _, ft in ipairs(frameTimes) do
                sum = sum + ft
            end
            currentFps = math.floor(#frameTimes / sum)
        end

        -- Track FPS history
        table.insert(fpsHistory, currentFps)
        if #fpsHistory > maxFpsHistory then
            table.remove(fpsHistory, 1)
        end

        -- Calculate average FPS
        local fpsSum = 0
        for _, fps in ipairs(fpsHistory) do
            fpsSum = fpsSum + fps
        end
        avgFps = math.floor(fpsSum / #fpsHistory)

        -- Auto-adjust
        if autoAdjustEnabled then
            PerfWatchdog._autoAdjust()
        end
    end
end

-- Auto-adjust quality based on FPS
function PerfWatchdog._autoAdjust()
    if currentFps < 30 then
        lowFpsDuration = lowFpsDuration + 1
        highFpsDuration = 0

        -- After 5 seconds of low FPS, degrade
        if lowFpsDuration >= 5 and currentQuality > QUALITY.LOW then
            print("[PerfWatchdog] Low FPS detected (" .. currentFps .. "), degrading quality")
            PerfWatchdog.setQuality(currentQuality - 1)
        end
    elseif currentFps > 55 then
        highFpsDuration = highFpsDuration + 1
        lowFpsDuration = 0

        -- After 10 seconds of high FPS, upgrade
        if highFpsDuration >= 10 and currentQuality < QUALITY.ULTRA then
            print("[PerfWatchdog] High FPS detected (" .. currentFps .. "), upgrading quality")
            PerfWatchdog.setQuality(currentQuality + 1)
        end
    else
        lowFpsDuration = 0
        highFpsDuration = 0
    end
end

-- Enable/disable auto-adjust
function PerfWatchdog.setAutoAdjust(enabled)
    autoAdjustEnabled = enabled
end

-- Get current stats
function PerfWatchdog.getStats()
    local memUsage = collectgarbage("count")  -- KB

    return {
        fps = currentFps,
        avgFps = avgFps,
        quality = PerfWatchdog.getQualityName(),
        qualityLevel = currentQuality,
        memoryKB = math.floor(memUsage),
        memoryMB = math.floor(memUsage / 1024),
        frameTimeMs = #frameTimes > 0 and math.floor((frameTimes[#frameTimes] or 0) * 1000) or 0,
        autoAdjust = autoAdjustEnabled,
    }
end

-- Get FPS history for graphing
function PerfWatchdog.getFpsHistory()
    return fpsHistory
end

return PerfWatchdog
