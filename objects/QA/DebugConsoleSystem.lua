-- objects/QA/DebugConsoleSystem.lua
-- Stronghold 2027 - Debug Console
-- In-game console for development commands

local DebugConsole = {}

local initialized = false
local isVisible = false
local inputBuffer = ""
local history = {}
local historyIndex = 0
local outputLines = {}
local maxOutputLines = 50

-- Registered commands
local commands = {}

function DebugConsole.init()
    if initialized then return end
    initialized = true

    -- Register built-in commands
    DebugConsole.register("help", "Show available commands", function()
        DebugConsole.print("Available commands:")
        for name, cmd in pairs(commands) do
            DebugConsole.print("  " .. name .. " - " .. cmd.description)
        end
    end)

    DebugConsole.register("clear", "Clear console output", function()
        outputLines = {}
    end)

    DebugConsole.register("stats", "Show game statistics", function()
        local Stats = require("objects.QA.StatisticsDashboard")
        Stats.printSummary()
    end)

    DebugConsole.register("perf", "Show performance info", function()
        local PerfWatchdog = require("objects.QA.PerformanceWatchdog")
        local stats = PerfWatchdog.getStats()
        DebugConsole.print(string.format("FPS: %d | Quality: %s | Memory: %d MB",
            stats.fps, stats.quality, stats.memoryMB))
    end)

    DebugConsole.register("mods", "List loaded mods", function()
        local ModLoader = require("objects.Modding.ModLoader")
        local stats = ModLoader.getStats()
        DebugConsole.print(string.format("Mods: %d loaded / %d total", stats.loaded, stats.total))
        for id, mod in pairs(ModLoader.getMods()) do
            DebugConsole.print("  " .. id .. " v" .. mod.manifest.version .. " - " ..
                (mod.enabled and "enabled" or "disabled"))
        end
    end)

    DebugConsole.register("reload", "Reload a mod (usage: reload mod_id)", function(args)
        if not args[1] then
            DebugConsole.print("Usage: reload <mod_id>")
            return
        end
        local ModLoader = require("objects.Modding.ModLoader")
        if ModLoader.reloadMod(args[1]) then
            DebugConsole.print("Mod reloaded: " .. args[1])
        else
            DebugConsole.print("Failed to reload: " .. args[1])
        end
    end)

    DebugConsole.register("time", "Set time of day (0-1)", function(args)
        local time = tonumber(args[1])
        if time then
            local LightingSystem = require("objects.Environment.LightingSystem")
            LightingSystem.setTimeOfDay(time)
            DebugConsole.print("Time set to: " .. time .. " (" .. LightingSystem.getTimeString() .. ")")
        else
            DebugConsole.print("Usage: time <0-1>")
        end
    end)

    DebugConsole.register("gold", "Add gold (usage: gold 1000)", function(args)
        local amount = tonumber(args[1]) or 1000
        if _G.state then
            _G.state.gold = (_G.state.gold or 0) + amount
            DebugConsole.print("Added " .. amount .. " gold (total: " .. _G.state.gold .. ")")
        end
    end)

    DebugConsole.register("spawn", "Spawn siege weapon (usage: spawn catapult)", function(args)
        local weaponType = args[1] or "catapult"
        if _G.state and _G.state.keepX then
            local SiegeWeapons = require("objects.Combat.SiegeWeaponsSystem")
            SiegeWeapons.create(weaponType, _G.state.keepX + 5, _G.state.keepY + 5, 1)
            DebugConsole.print("Spawned " .. weaponType)
        end
    end)

    DebugConsole.register("checklist", "Run release checklist", function()
        local ReleaseChecklist = require("objects.QA.ReleaseChecklist")
        ReleaseChecklist.printResults()
    end)

    DebugConsole.register("gc", "Force garbage collection", function()
        local before = collectgarbage("count")
        collectgarbage("collect")
        local after = collectgarbage("count")
        DebugConsole.print(string.format("GC: %.1f MB -> %.1f MB (freed %.1f MB)",
            before / 1024, after / 1024, (before - after) / 1024))
    end)

    DebugConsole.register("profile", "Apply graphics profile (usage: profile ultra)", function(args)
        local profileName = args[1] or "high"
        local ConfigProfiles = require("objects.Config.ConfigProfileSystem")
        if ConfigProfiles.apply(profileName) then
            DebugConsole.print("Profile applied: " .. profileName)
        else
            DebugConsole.print("Unknown profile: " .. profileName)
        end
    end)

    print("[DebugConsole] Initialized with " .. DebugConsole._getCommandCount() .. " commands")
end

function DebugConsole._getCommandCount()
    local count = 0
    for _ in pairs(commands) do count = count + 1 end
    return count
end

-- Register a custom command
function DebugConsole.register(name, description, func)
    commands[name] = {
        description = description or "",
        func = func or function() end,
    }
end

-- Execute a command
function DebugConsole.execute(input)
    if not input or #input == 0 then return end

    -- Add to history
    table.insert(history, input)
    historyIndex = #history + 1

    -- Show input in output
    DebugConsole.print("> " .. input)

    -- Parse command and args
    local args = {}
    for word in input:gmatch("%S+") do
        table.insert(args, word)
    end

    local cmdName = table.remove(args, 1)
    if not cmdName then return end

    local cmd = commands[cmdName]
    if not cmd then
        DebugConsole.print("Unknown command: " .. cmdName .. " (type 'help' for list)")
        return
    end

    -- Execute
    local ok, err = pcall(cmd.func, args)
    if not ok then
        DebugConsole.print("Error: " .. tostring(err))
    end
end

-- Print to console output
function DebugConsole.print(text)
    table.insert(outputLines, text)
    while #outputLines > maxOutputLines do
        table.remove(outputLines, 1)
    end
    print("[Console] " .. text)  -- Also print to system console
end

-- Toggle console visibility
function DebugConsole.toggle()
    if not initialized then DebugConsole.init() end
    isVisible = not isVisible
end

function DebugConsole.isVisible()
    return isVisible
end

-- Handle text input
function DebugConsole.textinput(text)
    if not isVisible then return false end
    inputBuffer = inputBuffer .. text
    return true
end

-- Handle key press
function DebugConsole.keypressed(key)
    if not isVisible then return false end

    if key == "return" or key == "kpenter" then
        DebugConsole.execute(inputBuffer)
        inputBuffer = ""
        return true
    elseif key == "backspace" then
        inputBuffer = inputBuffer:sub(1, -2)
        return true
    elseif key == "up" then
        if historyIndex > 1 then
            historyIndex = historyIndex - 1
            inputBuffer = history[historyIndex] or ""
        end
        return true
    elseif key == "down" then
        if historyIndex < #history then
            historyIndex = historyIndex + 1
            inputBuffer = history[historyIndex] or ""
        else
            historyIndex = #history + 1
            inputBuffer = ""
        end
        return true
    end

    return false
end

-- Draw console
function DebugConsole.draw()
    if not isVisible then return end

    local w, h = love.graphics.getDimensions()
    local consoleH = 300

    -- Background
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 0, 0, w, consoleH)

    -- Border
    love.graphics.setColor(0.3, 0.5, 0.8, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 0, 0, w, consoleH)

    -- Output text
    love.graphics.setColor(0.8, 0.9, 1, 1)
    local y = 10
    for i = math.max(1, #outputLines - 20), #outputLines do
        if outputLines[i] then
            love.graphics.print(outputLines[i], 10, y)
            y = y + 15
        end
    end

    -- Input line
    love.graphics.setColor(1, 1, 0.3, 1)
    love.graphics.print("> " .. inputBuffer .. "_", 10, consoleH - 25)

    -- Reset
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

return DebugConsole
