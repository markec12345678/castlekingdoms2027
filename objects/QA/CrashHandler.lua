-- objects/QA/CrashHandler.lua
-- Stronghold 2027 - Crash Handler & Error Recovery
--
-- Catches runtime errors, logs them, and attempts recovery:
-- - Wrap critical game loops in pcall
-- - Log errors with stack trace to crash.log
-- - Auto-save on crash
-- - Graceful degradation (disable failing system)
--
-- Usage:
--   local CrashHandler = require("objects.QA.CrashHandler")
--   CrashHandler.init()
--   CrashHandler.safeCall("combat_update", function() CombatIntegration.update(dt) end)

local CrashHandler = {}

local errorLog = {}
local systemFailureCount = {}  -- Track which systems are failing
local maxFailuresBeforeDisable = 3
local disabledSystems = {}

-- Initialize
function CrashHandler.init()
    print("[CrashHandler] Initialized")
end

-- Safely call a function, catching errors
-- @param systemName string Name of the system (for tracking)
-- @param func function Function to call
-- @param ... Arguments to pass
-- @return boolean success, any result
function CrashHandler.safeCall(systemName, func, ...)
    if disabledSystems[systemName] then
        return false
    end

    local ok, result = pcall(func, ...)

    if not ok then
        CrashHandler._logError(systemName, tostring(result))

        -- Track failures
        systemFailureCount[systemName] = (systemFailureCount[systemName] or 0) + 1

        if systemFailureCount[systemName] >= maxFailuresBeforeDisable then
            CrashHandler._disableSystem(systemName)
        end

        return false, result
    end

    -- Reset failure count on success
    systemFailureCount[systemName] = 0
    return true, result
end

-- Log an error
function CrashHandler._logError(systemName, errorMessage)
    local entry = {
        system = systemName,
        error = errorMessage,
        timestamp = os.time(),
        timeStr = os.date("%Y-%m-%d %H:%M:%S"),
        stack = debug.traceback("", 2),
    }

    table.insert(errorLog, entry)

    -- Keep only last 100 errors
    if #errorLog > 100 then
        table.remove(errorLog, 1)
    end

    -- Print to console
    print(string.format("[CrashHandler] ERROR in %s: %s", systemName, errorMessage))
end

-- Disable a failing system
function CrashHandler._disableSystem(systemName)
    if disabledSystems[systemName] then return end
    disabledSystems[systemName] = true
    print(string.format("[CrashHandler] DISABLED system '%s' after %d failures",
        systemName, systemFailureCount[systemName] or 0))
end

-- Re-enable a disabled system
function CrashHandler.enableSystem(systemName)
    disabledSystems[systemName] = nil
    systemFailureCount[systemName] = 0
    print(string.format("[CrashHandler] Re-enabled system '%s'", systemName))
end

-- Check if a system is disabled
function CrashHandler.isSystemDisabled(systemName)
    return disabledSystems[systemName] == true
end

-- Get error log
function CrashHandler.getErrorLog()
    return errorLog
end

-- Get disabled systems
function CrashHandler.getDisabledSystems()
    local list = {}
    for name, _ in pairs(disabledSystems) do
        table.insert(list, name)
    end
    return list
end

-- Write crash log to file
function CrashHandler.writeLog()
    if #errorLog == 0 then return end

    local logText = "Stronghold 2027 - Crash Log\n"
    logText = logText .. "Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    logText = logText .. "Total errors: " .. #errorLog .. "\n"
    logText = logText .. string.rep("=", 60) .. "\n\n"

    for i, entry in ipairs(errorLog) do
        logText = logText .. string.format("[%d] %s\n", i, entry.timeStr)
        logText = logText .. string.format("    System: %s\n", entry.system)
        logText = logText .. string.format("    Error: %s\n", entry.error)
        logText = logText .. "    Stack:\n" .. entry.stack .. "\n\n"
    end

    -- Write to save directory
    local filename = "crash_log_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    local file = love.filesystem.newFile(filename)
    if file:open("w") then
        file:write(logText)
        file:close()
        print("[CrashHandler] Crash log written to: " .. filename)
    end
end

-- Trigger auto-save on crash
function CrashHandler.triggerAutoSave()
    if not _G.AutoSaveSystem then return end
    pcall(function()
        _G.AutoSaveSystem.saveNow()
        print("[CrashHandler] Auto-save triggered")
    end)
end

-- Get summary for debug overlay
function CrashHandler.getSummary()
    local disabledList = CrashHandler.getDisabledSystems()
    return {
        totalErrors = #errorLog,
        disabledSystems = #disabledList,
        disabledList = disabledList,
        recentErrors = #errorLog > 0 and {
            errorLog[#errorLog].system,
            errorLog[#errorLog].error,
        } or nil,
    }
end

return CrashHandler
