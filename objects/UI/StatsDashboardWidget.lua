-- objects/UI/StatsDashboardWidget.lua
-- Castle Kingdoms 2027 v3.0.2 - Stats Dashboard Widget
--
-- Real-time HUD overlay showing key game statistics in a clean widget.
-- Compact, configurable, and always visible during gameplay.
--
-- Features:
-- - 6 widget panels (economy, military, population, diplomacy, tech, performance)
-- - Configurable position (4 corners + top/bottom center)
-- - Collapsible panels (click to expand/collapse)
-- - Auto-refresh every 2 seconds
-- - Color-coded values (green=good, red=bad, yellow=warning)
-- - Compact mode (single line per panel)
-- - Transparent background with border

local StatsWidget = {}

local initialized = false
local isVisible = true
local position = "top-right"  -- top-left, top-right, bottom-left, bottom-right, top-center, bottom-center
local compactMode = false
local updateTimer = 0
local updateInterval = 2.0
local collapsedPanels = {}

-- Panel definitions
local PANELS = {
    economy = {
        label = "EKONOMIJA",
        collapsed = false,
        getStats = function()
            if not _G.state then return {} end
            local stats = {}
            stats["Zlato"] = { value = _G.state.gold or 0, unit = "g", good = (_G.state.gold or 0) > 500, bad = (_G.state.gold or 0) < 100 }
            if _G.state.resources then
                stats["Les"] = { value = _G.state.resources.wood or 0, good = (_G.state.resources.wood or 0) > 50 }
                stats["Kamen"] = { value = _G.state.resources.stone or 0, good = (_G.state.resources.stone or 0) > 30 }
                stats["Hrana"] = { value = _G.state.resources.food or 0, good = (_G.state.resources.food or 0) > 50, bad = (_G.state.resources.food or 0) < 20 }
                stats["Železo"] = { value = _G.state.resources.iron or 0 }
            end
            if _G.Forecast then
                local eff = _G.Forecast.getEfficiency()
                stats["Učinkovitost"] = { value = eff.efficiency, unit = "%", good = eff.efficiency > 70, bad = eff.efficiency < 40 }
            end
            return stats
        end,
    },
    military = {
        label = "VOJAŠKO",
        collapsed = false,
        getStats = function()
            local stats = {}
            if _G.ArmyCommand then
                local armyStats = _G.ArmyCommand.getStats()
                stats["Armade"] = { value = armyStats.armyCount }
                stats["Enote"] = { value = armyStats.totalUnits }
                stats["Moč"] = { value = armyStats.totalStrength }
            end
            if _G.HeroSystem then
                local heroStats = _G.HeroSystem.getStats()
                stats["Heroji"] = { value = heroStats.aliveHeroes .. "/" .. heroStats.totalHeroes }
            end
            if _G.Analytics then
                local s = _G.Analytics.getSessionStats()
                stats["K/D"] = { value = string.format("%.1f", s.kdRatio or 0), good = (s.kdRatio or 0) > 1.0 }
                stats["Zmage"] = { value = s.battlesWon or 0, good = true }
                stats["Porazi"] = { value = s.battlesLost or 0, bad = true }
            end
            return stats
        end,
    },
    population = {
        label = "POPULACIJA",
        collapsed = false,
        getStats = function()
            local stats = {}
            if _G.state then
                local pop = _G.state.population or 0
                local maxPop = _G.state.maxPopulation or 0
                stats["Prebivalstvo"] = { value = pop .. "/" .. maxPop, good = pop > maxPop * 0.5, bad = pop < maxPop * 0.3 }
                stats["Sreča"] = { value = _G.state.popularity or 50, good = (_G.state.popularity or 50) > 60, bad = (_G.state.popularity or 50) < 30 }
            end
            if _G.PopulationSystem then
                local popStats = _G.PopulationSystem.getStats()
                stats["Rast"] = { value = string.format("%+.1f", popStats.growthRate), good = popStats.growthRate > 0, bad = popStats.growthRate < -0.5 }
            end
            return stats
        end,
    },
    diplomacy = {
        label = "DIPLOMACIJA",
        collapsed = true,
        getStats = function()
            local stats = {}
            if _G.DiplomaticRelations then
                local dStats = _G.DiplomaticRelations.getStats()
                stats["Zavezništva"] = { value = dStats.allied, good = true }
                stats["Nasprotniki"] = { value = dStats.hostile, bad = true }
            end
            if _G.Analytics then
                local s = _G.Analytics.getSessionStats()
                stats["Trgovine"] = { value = s.tradesCompleted or 0 }
                stats["Tributi"] = { value = (s.tributesSent or 0) .. "/" .. (s.tributesReceived or 0) }
            end
            if _G.TradeRoute then
                local tStats = _G.TradeRoute.getStats()
                stats["Poti"] = { value = tStats.activeRoutes }
                stats["Dohodek"] = { value = tStats.totalIncomeGenerated, unit = "g", good = true }
            end
            return stats
        end,
    },
    technology = {
        label = "TEHNOLOGIJA",
        collapsed = true,
        getStats = function()
            local stats = {}
            if _G.TechnologyTree then
                local tStats = _G.TechnologyTree.getStats()
                stats["Raziskane"] = { value = tStats.researched .. "/" .. tStats.totalTechs }
                local current = _G.TechnologyTree.getCurrentResearch()
                if current then
                    stats["Trenutna"] = { value = current.name .. " (" .. string.format("%.0f%%", current.percent) .. ")" }
                end
            end
            if _G.QuestSystem then
                local qStats = _G.QuestSystem.getStats()
                stats["Questi"] = { value = qStats.completed .. "/" .. qStats.total }
            end
            if _G.Prestige then
                local pStats = _G.Prestige.getStats()
                stats["Prestige"] = { value = pStats.currentPrestige }
                stats["Rank"] = { value = pStats.rank, good = true }
            end
            return stats
        end,
    },
    performance = {
        label = "PERFORMANCE",
        collapsed = true,
        getStats = function()
            local stats = {}
            stats["FPS"] = { value = love.timer.getFPS(), good = love.timer.getFPS() >= 55, bad = love.timer.getFPS() < 30 }
            local mem = collectgarbage("count")
            stats["Spomin"] = { value = string.format("%.1f MB", mem / 1024), good = mem < 100000, bad = mem > 200000 }
            if _G.AutoTuner then
                local aStats = _G.AutoTuner.getStats()
                stats["Target FPS"] = { value = aStats.targetFPS }
                stats["Prilagajanja"] = { value = aStats.totalAdjustments }
            end
            if _G.DDA then
                local dStats = _G.DDA.getStats()
                stats["DDA"] = { value = dStats.adjustmentLevel }
            end
            if _G.Matchmaking then
                local mStats = _G.Matchmaking.getStats()
                if mStats.totalMatches > 0 then
                    stats["Rating"] = { value = mStats.rating, good = true }
                    stats["Rank"] = { value = mStats.rankTier.name, good = true }
                    stats["Win Rate"] = { value = mStats.winRate .. "%", good = mStats.winRate >= 50 }
                end
            end
            return stats
        end,
    },
}

StatsWidget.PANELS = PANELS

function StatsWidget.init()
    if initialized then return end
    initialized = true
    -- Load collapsed state
    for panelId, panel in pairs(PANELS) do
        collapsedPanels[panelId] = panel.collapsed
    end
    print("[StatsWidget] Initialized with " .. StatsWidget._getPanelCount() .. " panels")
end

function StatsWidget._getPanelCount()
    local count = 0
    for _ in pairs(PANELS) do count = count + 1 end
    return count
end

-- Toggle visibility
function StatsWidget.toggle()
    isVisible = not isVisible
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Stats Dashboard: " .. (isVisible and "ON" or "OFF"))
    end
    return isVisible
end

-- Toggle panel collapse
function StatsWidget.togglePanel(panelId)
    if not PANELS[panelId] then return false end
    collapsedPanels[panelId] = not collapsedPanels[panelId]
    return collapsedPanels[panelId]
end

-- Set position
function StatsWidget.setPosition(pos)
    local valid = {"top-left", "top-right", "bottom-left", "bottom-right", "top-center", "bottom-center"}
    for _, v in ipairs(valid) do
        if v == pos then
            position = pos
            return true
        end
    end
    return false
end

-- Cycle position
function StatsWidget.cyclePosition()
    local positions = {"top-right", "top-left", "bottom-right", "bottom-left", "top-center", "bottom-center"}
    local idx = 1
    for i, p in ipairs(positions) do
        if p == position then idx = i break end
    end
    position = positions[(idx % #positions) + 1]
    if _G.ModernUI then
        _G.ModernUI.notifyInfo("Stats position: " .. position)
    end
    return position
end

-- Toggle compact mode
function StatsWidget.toggleCompact()
    compactMode = not compactMode
    return compactMode
end

-- Update
function StatsWidget.update(dt)
    if not initialized or not isVisible then return end
    updateTimer = updateTimer + dt
    -- No need to update more frequently — stats are read on draw
end

-- Draw
function StatsWidget.draw()
    if not initialized or not isVisible then return end

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local panelWidth = 200
    local lineHeight = 16
    local padding = 6

    -- Calculate position
    local x, y
    if position == "top-right" then x = screenWidth - panelWidth - 10; y = 10
    elseif position == "top-left" then x = 10; y = 10
    elseif position == "bottom-right" then x = screenWidth - panelWidth - 10; y = screenHeight - 200
    elseif position == "bottom-left" then x = 10; y = screenHeight - 200
    elseif position == "top-center" then x = (screenWidth - panelWidth) / 2; y = 10
    elseif position == "bottom-center" then x = (screenWidth - panelWidth) / 2; y = screenHeight - 200
    end

    -- Draw each panel
    local currentY = y
    for panelId, panel in pairs(PANELS) do
        local isCollapsed = collapsedPanels[panelId]
        local stats = panel.getStats()

        -- Count lines
        local lineCount = 0
        for _ in pairs(stats) do lineCount = lineCount + 1 end
        local panelHeight = lineHeight + padding * 2
        if not isCollapsed then
            panelHeight = panelHeight + lineCount * lineHeight
        end

        -- Draw background
        love.graphics.setColor(0.05, 0.05, 0.08, 0.85)
        love.graphics.rectangle("fill", x, currentY, panelWidth, panelHeight, 3, 3)

        -- Draw border
        love.graphics.setColor(0.3, 0.4, 0.5, 0.6)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", x, currentY, panelWidth, panelHeight, 3, 3)

        -- Draw label
        love.graphics.setColor(0.6, 0.7, 0.9, 1.0)
        local label = panel.label
        if isCollapsed then label = label .. " [+]" end
        love.graphics.print(label, x + padding, currentY + padding)

        -- Draw stats
        if not isCollapsed then
            local statY = currentY + padding + lineHeight
            for statName, statData in pairs(stats) do
                -- Stat name
                love.graphics.setColor(0.7, 0.7, 0.7, 1.0)
                love.graphics.print(statName, x + padding, statY)

                -- Stat value
                local valueStr = tostring(statData.value) .. (statData.unit or "")
                local valueX = x + panelWidth - padding - 60
                if statData.good then
                    love.graphics.setColor(0.3, 0.9, 0.3, 1.0)
                elseif statData.bad then
                    love.graphics.setColor(0.9, 0.3, 0.3, 1.0)
                else
                    love.graphics.setColor(0.9, 0.9, 0.9, 1.0)
                end
                love.graphics.print(valueStr, valueX, statY)

                statY = statY + lineHeight
            end
        end

        currentY = currentY + panelHeight + 4
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Mouse click handler (for collapsing panels)
function StatsWidget.mousepressed(mx, my, button)
    if not initialized or not isVisible then return false end
    if button ~= 1 then return false end

    -- Check if click is on a panel label
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local panelWidth = 200
    local padding = 6
    local lineHeight = 16

    local x, startY
    if position == "top-right" then x = screenWidth - panelWidth - 10; startY = 10
    elseif position == "top-left" then x = 10; startY = 10
    elseif position == "bottom-right" then x = screenWidth - panelWidth - 10; startY = screenHeight - 200
    elseif position == "bottom-left" then x = 10; startY = screenHeight - 200
    elseif position == "top-center" then x = (screenWidth - panelWidth) / 2; startY = 10
    elseif position == "bottom-center" then x = (screenWidth - panelWidth) / 2; startY = screenHeight - 200
    end

    local currentY = startY
    for panelId, panel in pairs(PANELS) do
        local isCollapsed = collapsedPanels[panelId]
        local labelHeight = lineHeight + padding * 2
        if mx >= x and mx <= x + panelWidth and my >= currentY and my <= currentY + labelHeight then
            StatsWidget.togglePanel(panelId)
            return true
        end
        if not isCollapsed then
            local stats = panel.getStats()
            local lineCount = 0
            for _ in pairs(stats) do lineCount = lineCount + 1 end
            currentY = currentY + labelHeight + lineCount * lineHeight + 4
        else
            currentY = currentY + labelHeight + 4
        end
    end
    return false
end

-- Get stats
function StatsWidget.getStats()
    local visiblePanels = 0
    for panelId, _ in pairs(PANELS) do
        if not collapsedPanels[panelId] then visiblePanels = visiblePanels + 1 end
    end
    return {
        visible = isVisible,
        position = position,
        compactMode = compactMode,
        totalPanels = StatsWidget._getPanelCount(),
        visiblePanels = visiblePanels,
        collapsedPanels = StatsWidget._getPanelCount() - visiblePanels,
    }
end

return StatsWidget
