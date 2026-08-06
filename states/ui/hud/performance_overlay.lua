-- states/ui/hud/performance_overlay.lua
-- Stronghold 2027 - Performance Overlay HUD
--
-- Visual breakdown of frame timing:
-- - Bar chart showing time spent in each subsystem
-- - FPS counter with color coding
-- - Memory usage
-- - Pathfinding stats
-- - Entity counts
--
-- Toggle with F3 (basic) or F4 (detailed)

local PerformanceManager = require("objects.Performance.PerformanceManager")
local MemoryProfiler = require("objects.Performance.MemoryProfiler")
local PriorityUpdate = require("objects.Performance.PriorityUpdateSystem")
local AITickOptimizer = require("objects.Performance.AITickOptimizer")

local PerformanceOverlay = {}

local visible = false
local detailed = false

function PerformanceOverlay.setVisible(state)
    visible = state
    PerformanceManager.setEnabled(state)
    MemoryProfiler.setEnabled(state)
end

function PerformanceOverlay.toggle()
    PerformanceOverlay.setVisible(not visible)
end

function PerformanceOverlay.setDetailed(state)
    detailed = state
    PerformanceManager.setDetailed(state)
end

function PerformanceOverlay.toggleDetailed()
    PerformanceOverlay.setDetailed(not detailed)
end

function PerformanceOverlay.isVisible()
    return visible
end

-- Draw the overlay
function PerformanceOverlay.draw()
    if not visible then return end

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = 350
    local panelH = detailed and 500 or 250
    local panelX = screenW - panelW - 10
    local panelY = 90  -- below event log

    -- Background
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 4, 4, 4, 4)

    -- Border
    love.graphics.setColor(0.5, 0.7, 1, 0.8)
    love.graphics.setLineWidth(1.5)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 4, 4, 4, 4)

    local y = panelY + 10
    local x = panelX + 10

    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Performance Monitor", x, y)
    y = y + 20

    -- Frame stats
    local frameStats = PerformanceManager.getFrameStats()
    local fpsColor
    if frameStats.fps >= 55 then fpsColor = {0.3, 1, 0.3}
    elseif frameStats.fps >= 30 then fpsColor = {1, 1, 0.3}
    else fpsColor = {1, 0.3, 0.3} end

    love.graphics.setColor(fpsColor[1], fpsColor[2], fpsColor[3], 1)
    love.graphics.print(string.format("FPS: %.1f", frameStats.fps), x, y)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print(string.format("Frame: %.2fms / %.2fms (%.0f%%)",
        frameStats.frameTime, frameStats.targetFrameTime, frameStats.frameBudgetUsed),
        x + 100, y)
    y = y + 20

    -- Section breakdown (bar chart)
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.print("Subsystems:", x, y)
    y = y + 18

    local sectionData = PerformanceManager.getSectionData()
    local maxBarWidth = panelW - 100

    for i, section in ipairs(sectionData) do
        if i > 10 and not detailed then break end  -- limit in basic mode

        -- Section name
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.print(string.format("%-15s", section.name), x, y)

        -- Bar
        local barWidth = math.min(maxBarWidth, (section.avgTime / frameStats.targetFrameTime) * maxBarWidth)
        love.graphics.setColor(section.color[1], section.color[2], section.color[3], 0.8)
        love.graphics.rectangle("fill", x + 90, y + 2, barWidth, 12)

        -- Time text
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(string.format("%.2fms", section.avgTime), x + 90 + barWidth + 5, y)

        y = y + 16
    end

    if not detailed then
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.print("[F4 for detailed view]", x, y)
        return
    end

    -- === DETAILED VIEW ===
    y = y + 20

    -- Pathfinding
    love.graphics.setColor(0.9, 0.9, 0.3, 1)
    love.graphics.print("Pathfinding:", x, y)
    y = y + 16

    local pfStats = PerformanceManager.getPathfindingStats()
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print(string.format("  Requests/frame: %d", pfStats.requestsPerFrame), x, y); y = y + 14
    love.graphics.print(string.format("  Total requests: %d", pfStats.requestsTotal), x, y); y = y + 14
    love.graphics.print(string.format("  Avg time: %.2fms", pfStats.avgTimePerRequest), x, y); y = y + 14
    love.graphics.print(string.format("  Max spike: %.2fms", pfStats.maxSpike), x, y); y = y + 14

    -- Spike warning
    if pfStats.maxSpike > 20 then
        love.graphics.setColor(1, 0.3, 0.3, 1)
        love.graphics.print(string.format("  ⚠ SPIKE > 20ms!", pfStats.maxSpike), x, y)
        y = y + 14
    end

    y = y + 10

    -- Memory
    love.graphics.setColor(0.7, 0.5, 1, 1)
    love.graphics.print("Memory:", x, y)
    y = y + 16

    local memStats = MemoryProfiler.getStats()
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print(string.format("  Memory: %.2f MB", memStats.memoryMB), x, y); y = y + 14
    love.graphics.print(string.format("  Delta: %.2f KB/sample", memStats.delta), x, y); y = y + 14
    love.graphics.print(string.format("  Entities: %d (max: %d)", memStats.entityCount, memStats.maxEntityCount), x, y); y = y + 14

    if memStats.possibleLeak then
        love.graphics.setColor(1, 0.3, 0.3, 1)
        love.graphics.print(string.format("  ⚠ POSSIBLE LEAK! Growth: %d", memStats.leakGrowth), x, y)
        y = y + 14
    end

    y = y + 10

    -- Priority Update stats
    love.graphics.setColor(0.3, 1, 0.5, 1)
    love.graphics.print("Tiered Updates:", x, y)
    y = y + 16

    local puStats = PriorityUpdate.getStats()
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print(string.format("  High (60Hz): %d entities", puStats.high), x, y); y = y + 14
    love.graphics.print(string.format("  Medium (10Hz): %d entities", puStats.medium), x, y); y = y + 14
    love.graphics.print(string.format("  Low (2Hz): %d entities", puStats.low), x, y); y = y + 14
    love.graphics.print(string.format("  Updated/frame: %d (skipped: %d)", puStats.updatesThisFrame, puStats.skippedThisFrame), x, y); y = y + 14
    love.graphics.print(string.format("  Savings: %.1f%%", puStats.savingsPercent), x, y); y = y + 14

    y = y + 10

    -- AI Tick stats
    love.graphics.setColor(1, 0.5, 0.3, 1)
    love.graphics.print("AI Ticks:", x, y)
    y = y + 16

    local aiStats = AITickOptimizer.getStats()
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print(string.format("  Total ticks run: %d", aiStats.totalTicksRun), x, y); y = y + 14
    for category, catStats in pairs(aiStats.categories) do
        if catStats.runs > 0 then
            love.graphics.print(string.format("  %s: %d runs, avg %.2fms (max %.2fms)",
                category, catStats.runs, catStats.avgTime, catStats.maxTime), x, y)
            y = y + 14
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return PerformanceOverlay
