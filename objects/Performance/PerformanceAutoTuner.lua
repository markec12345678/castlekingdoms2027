-- objects/Performance/PerformanceAutoTuner.lua
-- Castle Kingdoms 2027 v2.9.9 - Performance Auto-Tuner
--
-- Proactively monitors and adjusts graphics settings to maintain target FPS.
-- Different from PerformanceWatchdog — this is granular and predictive.
--
-- Features:
-- - Real-time FPS monitoring (1s, 5s, 30s averages)
-- - 8 tunable graphics parameters
-- - Predictive adjustment (lowers quality before FPS drops)
-- - Gradual quality degradation (not all at once)
-- - Quality recovery (raises quality when FPS is stable)
-- - Player-configurable target FPS (30, 45, 60, 120)
-- - Adjustment history and statistics
-- - Override mode (player locks settings)

local AutoTuner = {}

-- Tunable parameters with priority (lower = adjusted first)
local PARAMS = {
    particleDensity = { current = 1.0, min = 0.1, max = 1.0, step = 0.1, priority = 1, label = "Gostota delcev" },
    shadowQuality = { current = 1.0, min = 0.0, max = 1.0, step = 0.25, priority = 2, label = "Kvaliteta senc" },
    bloomIntensity = { current = 1.0, min = 0.0, max = 1.0, step = 0.2, priority = 3, label = "Bloom intenzivnost" },
    ssaoEnabled = { current = 1.0, min = 0.0, max = 1.0, step = 1.0, priority = 4, label = "SSAO" },
    renderDistance = { current = 1.0, min = 0.5, max = 1.5, step = 0.1, priority = 5, label = "Domet renderiranja" },
    animationDetail = { current = 1.0, min = 0.3, max = 1.0, step = 0.1, priority = 6, label = "Detail animacij" },
    weatherEffects = { current = 1.0, min = 0.0, max = 1.0, step = 0.2, priority = 7, label = "Vremenski efekti" },
    unitCapModifier = { current = 1.0, min = 0.5, max = 1.0, step = 0.1, priority = 8, label = "Omejitev enot" },
}

AutoTuner.PARAMS = PARAMS

local initialized = false
local enabled = true
local overrideMode = false  -- player locks settings
local targetFPS = 60
local fpsHistory1s = {}   -- last 1 second (60 samples at 60fps)
local fpsHistory5s = {}   -- last 5 seconds
local fpsHistory30s = {}  -- last 30 seconds
local maxHistory1s = 60
local maxHistory5s = 300
local maxHistory30s = 1800
local adjustmentTimer = 0
local adjustmentInterval = 3.0  -- check every 3 seconds
local recoveryTimer = 0
local recoveryDelay = 10.0  -- wait 10s of stable FPS before recovering
local adjustmentHistory = {}
local maxHistory = 50

-- Stats
local totalAdjustments = 0
local totalRecoveries = 0
local lowestFPS = 999
local highestFPS = 0

function AutoTuner.init()
    if initialized then return end
    initialized = true
    print("[AutoTuner] Initialized — target: " .. targetFPS .. " FPS")
end

-- Record FPS sample
function AutoTuner.recordFPS(fps)
    table.insert(fpsHistory1s, fps)
    if #fpsHistory1s > maxHistory1s then table.remove(fpsHistory1s, 1) end
    table.insert(fpsHistory5s, fps)
    if #fpsHistory5s > maxHistory5s then table.remove(fpsHistory5s, 1) end
    table.insert(fpsHistory30s, fps)
    if #fpsHistory30s > maxHistory30s then table.remove(fpsHistory30s, 1) end
    if fps < lowestFPS then lowestFPS = fps end
    if fps > highestFPS then highestFPS = fps end
end

-- Calculate average FPS from history
function AutoTuner._average(history)
    if #history == 0 then return targetFPS end
    local sum = 0
    for _, fps in ipairs(history) do sum = sum + fps end
    return sum / #history
end

-- Get current FPS averages
function AutoTuner.getAverages()
    return {
        avg1s = AutoTuner._average(fpsHistory1s),
        avg5s = AutoTuner._average(fpsHistory5s),
        avg30s = AutoTuner._average(fpsHistory30s),
    }
end

-- Check if adjustment is needed
function AutoTuner._checkAdjustment()
    if not enabled or overrideMode then return end

    local avg = AutoTuner.getAverages()
    local currentFPS = avg.avg5s

    -- If FPS is below target, degrade quality
    if currentFPS < targetFPS * 0.85 then
        -- Below 85% of target — degrade
        AutoTuner._degradeQuality(currentFPS)
        recoveryTimer = 0
    elseif currentFPS < targetFPS * 0.95 then
        -- Below 95% — prepare for degradation but don't act yet
        recoveryTimer = 0
    else
        -- FPS is good — check for recovery
        recoveryTimer = recoveryTimer + adjustmentInterval
        if recoveryTimer >= recoveryDelay then
            AutoTuner._recoverQuality()
            recoveryTimer = 0
        end
    end
end

-- Degrade quality (lower one parameter by priority)
function AutoTuner._degradeQuality(currentFPS)
    -- Find highest priority parameter that can be lowered
    local sortedParams = {}
    for name, param in pairs(PARAMS) do
        table.insert(sortedParams, { name = name, param = param })
    end
    table.sort(sortedParams, function(a, b) return a.param.priority < b.param.priority end)

    for _, entry in ipairs(sortedParams) do
        local param = entry.param
        if param.current > param.min then
            local oldValue = param.current
            param.current = math.max(param.min, param.current - param.step)
            AutoTuner._applyParam(entry.name, param.current)
            totalAdjustments = totalAdjustments + 1
            table.insert(adjustmentHistory, {
                action = "degrade",
                param = entry.name,
                oldValue = oldValue,
                newValue = param.current,
                fps = currentFPS,
                timestamp = os.time(),
            })
            while #adjustmentHistory > maxHistory do table.remove(adjustmentHistory, 1) end
            print(string.format("[AutoTuner] Degrade: %s %.2f → %.2f (FPS: %.0f)", entry.name, oldValue, param.current, currentFPS))
            return true
        end
    end
    -- All params at minimum — can't degrade further
    return false
end

-- Recover quality (raise one parameter by reverse priority)
function AutoTuner._recoverQuality()
    local sortedParams = {}
    for name, param in pairs(PARAMS) do
        table.insert(sortedParams, { name = name, param = param })
    end
    table.sort(sortedParams, function(a, b) return a.param.priority > b.param.priority end)

    for _, entry in ipairs(sortedParams) do
        local param = entry.param
        if param.current < param.max then
            local oldValue = param.current
            param.current = math.min(param.max, param.current + param.step)
            AutoTuner._applyParam(entry.name, param.current)
            totalRecoveries = totalRecoveries + 1
            table.insert(adjustmentHistory, {
                action = "recover",
                param = entry.name,
                oldValue = oldValue,
                newValue = param.current,
                fps = AutoTuner._average(fpsHistory5s),
                timestamp = os.time(),
            })
            while #adjustmentHistory > maxHistory do table.remove(adjustmentHistory, 1) end
            print(string.format("[AutoTuner] Recover: %s %.2f → %.2f", entry.name, oldValue, param.current))
            return true
        end
    end
    return false
end

-- Apply parameter change to actual game systems
function AutoTuner._applyParam(paramName, value)
    if paramName == "particleDensity" then
        if _G.VisualPolish and _G.VisualPolish.setParticleDensity then
            pcall(function() _G.VisualPolish.setParticleDensity(value) end)
        end
    elseif paramName == "shadowQuality" then
        local HDShaders = _G.HDShaders or (require("shaders.HD_SHADERS"))
        if HDShaders and HDShaders.enable then
            pcall(function() HDShaders.enable("dynamic_lighting", value > 0.5) end)
        end
    elseif paramName == "bloomIntensity" then
        local HDShaders = _G.HDShaders or (require("shaders.HD_SHADERS"))
        if HDShaders and HDShaders.enable then
            pcall(function() HDShaders.enable("bloom", value > 0.2) end)
        end
    elseif paramName == "ssaoEnabled" then
        local HDShaders = _G.HDShaders or (require("shaders.HD_SHADERS"))
        if HDShaders and HDShaders.enable then
            pcall(function() HDShaders.enable("ssao", value > 0.5) end)
        end
    elseif paramName == "renderDistance" then
        if _G.RenderOptimizer and _G.RenderOptimizer.setRenderDistance then
            pcall(function() _G.RenderOptimizer.setRenderDistance(value) end)
        end
    elseif paramName == "animationDetail" then
        if _G.AnimationSystem and _G.AnimationSystem.setDetailLevel then
            pcall(function() _G.AnimationSystem.setDetailLevel(value) end)
        end
    elseif paramName == "weatherEffects" then
        if _G.WeatherSystem and _G.WeatherSystem.setEffectIntensity then
            pcall(function() _G.WeatherSystem.setEffectIntensity(value) end)
        end
    elseif paramName == "unitCapModifier" then
        if _G.DynamicUnitCap and _G.DynamicUnitCap.setModifier then
            pcall(function() _G.DynamicUnitCap.setModifier(value) end)
        end
    end
end

-- Update
function AutoTuner.update(dt)
    if not initialized then return end

    -- Record current FPS
    local fps = love.timer.getFPS()
    AutoTuner.recordFPS(fps)

    -- Periodic check
    adjustmentTimer = adjustmentTimer + dt
    if adjustmentTimer >= adjustmentInterval then
        adjustmentTimer = 0
        AutoTuner._checkAdjustment()
    end
end

-- Set target FPS
function AutoTuner.setTargetFPS(fps)
    targetFPS = math.max(15, math.min(144, fps))
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Target FPS: " .. targetFPS)
    end
    return targetFPS
end

-- Toggle auto-tuning
function AutoTuner.toggle()
    enabled = not enabled
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Auto-Tuner: " .. (enabled and "ON" or "OFF"))
    end
    return enabled
end

-- Toggle override mode (lock current settings)
function AutoTuner.toggleOverride()
    overrideMode = not overrideMode
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Override mode: " .. (overrideMode and "ON (locked)" or "OFF (auto)"))
    end
    return overrideMode
end

-- Get parameter value
function AutoTuner.getParam(name)
    if not PARAMS[name] then return 1.0 end
    return PARAMS[name].current
end

-- Set parameter manually (overrides auto-tuning for this param)
function AutoTuner.setParam(name, value)
    if not PARAMS[name] then return false end
    PARAMS[name].current = math.max(PARAMS[name].min, math.min(PARAMS[name].max, value))
    AutoTuner._applyParam(name, PARAMS[name].current)
    return true
end

-- Reset all params to max
function AutoTuner.resetToMax()
    for name, param in pairs(PARAMS) do
        param.current = param.max
        AutoTuner._applyParam(name, param.current)
    end
    if _G.ModernUI then
        _G.ModernUI.notifySuccess("Vsi parametri nastavljeni na maksimum")
    end
end

-- Get all params with info
function AutoTuner.getAllParams()
    local result = {}
    for name, param in pairs(PARAMS) do
        table.insert(result, {
            name = name,
            label = param.label,
            current = param.current,
            min = param.min,
            max = param.max,
            priority = param.priority,
            atMin = param.current <= param.min,
            atMax = param.current >= param.max,
        })
    end
    table.sort(result, function(a, b) return a.priority < b.priority end)
    return result
end

-- Get stats
function AutoTuner.getStats()
    local avg = AutoTuner.getAverages()
    local atMinCount = 0
    local atMaxCount = 0
    for _, param in pairs(PARAMS) do
        if param.current <= param.min then atMinCount = atMinCount + 1 end
        if param.current >= param.max then atMaxCount = atMaxCount + 1 end
    end
    return {
        enabled = enabled,
        overrideMode = overrideMode,
        targetFPS = targetFPS,
        currentFPS1s = avg.avg1s,
        currentFPS5s = avg.avg5s,
        currentFPS30s = avg.avg30s,
        lowestFPS = lowestFPS,
        highestFPS = highestFPS,
        totalAdjustments = totalAdjustments,
        totalRecoveries = totalRecoveries,
        paramsAtMin = atMinCount,
        paramsAtMax = atMaxCount,
        totalParams = 8,
        recoveryTimer = recoveryTimer,
        nextCheckIn = math.ceil(adjustmentInterval - adjustmentTimer),
    }
end

-- Get adjustment history
function AutoTuner.getHistory(limit)
    local result = {}
    limit = limit or 10
    for i = math.max(1, #adjustmentHistory - limit + 1), #adjustmentHistory do
        table.insert(result, adjustmentHistory[i])
    end
    return result
end

return AutoTuner
