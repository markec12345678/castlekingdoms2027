-- objects/Controllers/ProfilerController.lua
-- Castle Kingdoms 2027 - Performance Profiler
--
-- Tracks performance metrics and provides debug overlay
-- Activated with F3 key (toggle debug overlay)
-- Activated with F4 key (toggle detailed profiling)
--
-- Usage:
--   local Profiler = require("objects.Controllers.ProfilerController")
--   Profiler:start()
--   Profiler:beginSection("pathfinding")
--   -- ... do pathfinding work ...
--   Profiler:endSection("pathfinding")
--   Profiler:draw()  -- in love.draw()

local Profiler = _G.class("ProfilerController")

function Profiler:initialize()
    self.enabled = false
    self.detailed = false
    self.sections = {}
    self.frameStats = {
        fps = 0,
        frameTime = 0,
        frames = 0,
        lastUpdate = 0,
    }
    self.history = {}
    self.maxHistory = 60  -- Keep last 60 frames

    -- Memory tracking
    self.memoryUsage = 0
    self.memoryHistory = {}

    -- Custom counters
    self.counters = {}

    print("ProfilerController initialized (press F3 to toggle)")
end

function Profiler:start()
    self.enabled = true
end

function Profiler:stop()
    self.enabled = false
end

function Profiler:toggle()
    self.enabled = not self.enabled
    print("Profiler " .. (self.enabled and "enabled" or "disabled"))
end

function Profiler:toggleDetailed()
    self.detailed = not self.detailed
    print("Detailed profiling " .. (self.detailed and "enabled" or "disabled"))
end

function Profiler:beginSection(name)
    if not self.enabled then return end
    if not self.sections[name] then
        self.sections[name] = {
            calls = 0,
            totalTime = 0,
            maxTime = 0,
            startTime = 0,
        }
    end
    self.sections[name].startTime = love.timer.getTime()
    self.sections[name].calls = self.sections[name].calls + 1
end

function Profiler:endSection(name)
    if not self.enabled then return end
    local section = self.sections[name]
    if not section then return end

    local elapsed = love.timer.getTime() - section.startTime
    section.totalTime = section.totalTime + elapsed
    if elapsed > section.maxTime then
        section.maxTime = elapsed
    end
end

function Profiler:incrementCounter(name, amount)
    amount = amount or 1
    self.counters[name] = (self.counters[name] or 0) + amount
end

function Profiler:getCounter(name)
    return self.counters[name] or 0
end

function Profiler:resetCounters()
    self.counters = {}
end

function Profiler:update(dt)
    if not self.enabled then return end

    -- Update frame stats
    self.frameStats.frames = self.frameStats.frames + 1
    self.frameStats.frameTime = dt
    self.frameStats.fps = 1 / dt
    self.frameStats.lastUpdate = love.timer.getTime()

    -- Track history
    table.insert(self.history, {
        time = love.timer.getTime(),
        fps = self.frameStats.fps,
        frameTime = dt * 1000,  -- ms
    })

    if #self.history > self.maxHistory then
        table.remove(self.history, 1)
    end

    -- Memory tracking (Lua garbage collection stats)
    self.memoryUsage = collectgarbage("count")  -- KB
    table.insert(self.memoryHistory, self.memoryUsage)
    if #self.memoryHistory > self.maxHistory then
        table.remove(self.memoryHistory, 1)
    end
end

function Profiler:resetSections()
    for _, section in pairs(self.sections) do
        section.calls = 0
        section.totalTime = 0
        section.maxTime = 0
    end
end

function Profiler:draw()
    if not self.enabled then return end

    local font = love.graphics.getFont()
    local lineHeight = font:getHeight() + 2
    local padding = 8
    local x = padding
    local y = padding

    -- Background panel
    love.graphics.setColor(0, 0, 0, 0.7)
    local panelWidth = 280
    local panelHeight = lineHeight * 12 + padding * 2
    love.graphics.rectangle("fill", x - padding/2, y - padding/2, panelWidth, panelHeight)

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)

    -- Header
    love.graphics.setColor(0.5, 1, 0.5, 1)
    love.graphics.print("Castle Kingdoms 2027 - Profiler", x, y)
    y = y + lineHeight

    love.graphics.setColor(1, 1, 1, 1)

    -- FPS
    local fpsColor = self.frameStats.fps > 50 and {0.5, 1, 0.5} or
                     self.frameStats.fps > 30 and {1, 1, 0.5} or
                     {1, 0.5, 0.5}
    love.graphics.setColor(fpsColor[1], fpsColor[2], fpsColor[3], 1)
    love.graphics.print(string.format("FPS: %.1f", self.frameStats.fps), x, y)
    y = y + lineHeight

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(string.format("Frame time: %.2f ms", self.frameStats.frameTime * 1000), x, y)
    y = y + lineHeight

    -- Memory
    love.graphics.print(string.format("Memory: %.1f MB", self.memoryUsage / 1024), x, y)
    y = y + lineHeight

    -- Active entities (if available)
    if _G.state and _G.state.gameObjectList then
        love.graphics.print(string.format("Objects: %d", #_G.state.gameObjectList), x, y)
        y = y + lineHeight
    end

    -- Counters
    love.graphics.setColor(0.7, 0.7, 1, 1)
    love.graphics.print("Counters:", x, y)
    y = y + lineHeight

    love.graphics.setColor(1, 1, 1, 1)
    local counterCount = 0
    for name, value in pairs(self.counters) do
        if counterCount < 5 then  -- Limit displayed counters
            love.graphics.print(string.format("  %s: %d", name, value), x, y)
            y = y + lineHeight
            counterCount = counterCount + 1
        end
    end

    -- Detailed sections (only if detailed mode)
    if self.detailed then
        y = y + lineHeight
        love.graphics.setColor(0.7, 1, 0.7, 1)
        love.graphics.print("Sections:", x, y)
        y = y + lineHeight

        love.graphics.setColor(1, 1, 1, 1)
        local sectionCount = 0
        for name, section in pairs(self.sections) do
            if sectionCount < 10 and section.calls > 0 then
                local avgTime = section.totalTime / section.calls * 1000  -- ms
                love.graphics.print(string.format("  %s: %.3fms avg (%d calls, max %.3fms)",
                    name, avgTime, section.calls, section.maxTime * 1000), x, y)
                y = y + lineHeight
                sectionCount = sectionCount + 1
            end
        end
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function Profiler:getStats()
    return {
        fps = self.frameStats.fps,
        frameTime = self.frameStats.frameTime,
        memory = self.memoryUsage,
        sections = self.sections,
        counters = self.counters,
    }
end

function Profiler:dumpToFile(filename)
    filename = filename or "profiler_dump.txt"
    local f = io.open(filename, "w")
    if not f then return false end

    f:write("=== Castle Kingdoms 2027 Profiler Dump ===\n")
    f:write(string.format("Timestamp: %s\n", os.date()))
    f:write(string.format("FPS: %.2f\n", self.frameStats.fps))
    f:write(string.format("Frame time: %.3f ms\n", self.frameStats.frameTime * 1000))
    f:write(string.format("Memory: %.2f MB\n", self.memoryUsage / 1024))
    f:write("\n")

    f:write("=== Sections ===\n")
    for name, section in pairs(self.sections) do
        if section.calls > 0 then
            local avgTime = section.totalTime / section.calls * 1000
            f:write(string.format("%s: %.3fms avg (%d calls, max %.3fms)\n",
                name, avgTime, section.calls, section.maxTime * 1000))
        end
    end
    f:write("\n")

    f:write("=== Counters ===\n")
    for name, value in pairs(self.counters) do
        f:write(string.format("%s: %d\n", name, value))
    end

    f:close()
    print("Profiler dump saved to: " .. filename)
    return true
end

return Profiler:new()
