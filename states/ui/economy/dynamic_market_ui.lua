-- states/ui/economy/dynamic_market_ui.lua
-- Stronghold 2027 - Dynamic Market UI
--
-- Displays all 20 resources with:
-- - Current buy/sell prices
-- - Price trends (up/down/stable)
-- - Seasonal/event modifiers
-- - Inflation indicator
--
-- Toggle with F-KEY or via Market building click
--
-- Usage:
--   local DynamicMarketUI = require("states.ui.economy.dynamic_market_ui")
--   DynamicMarketUI.toggle()
--   DynamicMarketUI.update(dt)
--   DynamicMarketUI.draw()

local loveframes = require("libraries.loveframes")
local DynamicMarket = require("objects.Economy.DynamicMarketSystem")
local SeasonalSystem = require("objects.Economy.SeasonalSystem")

local DynamicMarketUI = {}

-- State
local visible = false
local selectedCategory = "all"  -- all, materials, food, weapons
local priceHistory = {}  -- for trend arrows
local lastHistoryUpdate = 0
local historyUpdateInterval = 5  -- update history every 5 seconds

-- Resource categories
local CATEGORIES = {
    materials = {"wood", "stone", "iron", "tar", "wheat", "flour", "hop", "ale"},
    food = {"meat", "cheese", "apples", "bread"},
    weapons = {"spear", "bow", "mace", "crossbow", "sword", "pike", "leatherArmor", "shield"},
}

-- Resource display names (Slovenian)
local RESOURCE_NAMES_SLV = {
    wood = "Les",
    stone = "Kamen",
    iron = "Železo",
    tar = "Smola",
    wheat = "Pšenica",
    flour = "Moka",
    hop = "Hmelj",
    ale = "Ale",
    meat = "Meso",
    cheese = "Sir",
    apples = "Jabolka",
    bread = "Kruh",
    spear = "Koplje",
    bow = "Lok",
    mace = "Buzdovan",
    crossbow = "Samostrel",
    sword = "Meč",
    pike = "Sulica",
    leatherArmor = "Usnjeni oklep",
    shield = "Ščit",
}

-- Initialize price history
function DynamicMarketUI.init()
    for resource, _ in pairs(RESOURCE_NAMES_SLV) do
        priceHistory[resource] = {
            previous = DynamicMarket.getPrice(resource, "buy"),
            current = DynamicMarket.getPrice(resource, "buy"),
            trend = "stable",  -- up, down, stable
        }
    end
end

-- Toggle visibility
function DynamicMarketUI.toggle()
    visible = not visible
    if visible and not priceHistory.wood then
        DynamicMarketUI.init()
    end
end

-- Set visibility
function DynamicMarketUI.setVisible(state)
    visible = state
end

-- Is visible
function DynamicMarketUI.isVisible()
    return visible
end

-- Update price history (called periodically)
function DynamicMarketUI.updatePriceHistory()
    for resource, _ in pairs(RESOURCE_NAMES_SLV) do
        local currentPrice = DynamicMarket.getPrice(resource, "buy")
        local history = priceHistory[resource]
        if history then
            history.previous = history.current
            history.current = currentPrice

            -- Calculate trend (5% threshold)
            local diff = currentPrice - history.previous
            if math.abs(diff) > history.previous * 0.05 then
                history.trend = diff > 0 and "up" or "down"
            else
                history.trend = "stable"
            end
        end
    end
end

-- Update UI
function DynamicMarketUI.update(dt)
    if not visible then return end

    -- Update price history periodically
    lastHistoryUpdate = lastHistoryUpdate + dt
    if lastHistoryUpdate >= historyUpdateInterval then
        lastHistoryUpdate = 0
        DynamicMarketUI.updatePriceHistory()
    end
end

-- Get resources for current category
function DynamicMarketUI.getResourcesForCategory()
    if selectedCategory == "all" then
        local all = {}
        for cat, resources in pairs(CATEGORIES) do
            for _, r in ipairs(resources) do
                table.insert(all, r)
            end
        end
        return all
    else
        return CATEGORIES[selectedCategory] or {}
    end
end

-- Draw the market UI
function DynamicMarketUI.draw()
    if not visible then return end

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = 600
    local panelH = 500
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    -- Background overlay (dim the game)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    -- Main panel
    love.graphics.setColor(0.15, 0.12, 0.1, 0.95)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Border
    love.graphics.setColor(0.6, 0.5, 0.3, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Title
    love.graphics.setColor(1, 0.9, 0.7, 1)
    love.graphics.print("Tržnica - Dinamične cene", panelX + 20, panelY + 15)

    -- Market stats (top right)
    local stats = DynamicMarket.getStats()
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print(string.format("Inflacija: %.1f%%", (stats.inflation - 1) * 100),
        panelX + panelW - 200, panelY + 15)
    love.graphics.print(string.format("Zlato v obtoku: %d", stats.totalGold),
        panelX + panelW - 200, panelY + 35)

    -- Season info
    local seasonInfo = SeasonalSystem.getSeasonInfo()
    love.graphics.setColor(0.7, 0.9, 1, 1)
    love.graphics.print(string.format("Letni čas: %s (leto %d)", seasonInfo.nameSlv, seasonInfo.year),
        panelX + 20, panelY + 40)
    love.graphics.print(string.format("Naslednji: %s (%.0fs)",
        SeasonalSystem.getNextSeason(), seasonInfo.timeRemaining),
        panelX + 20, panelY + 58)

    -- Category tabs
    local tabY = panelY + 85
    local tabX = panelX + 20
    local tabs = {"all", "materials", "food", "weapons"}
    local tabLabels = {all = "Vse", materials = "Materiali", food = "Hrana", weapons = "Orožje"}

    for _, tab in ipairs(tabs) do
        local label = tabLabels[tab]
        local tabW = 100
        local isActive = selectedCategory == tab

        if isActive then
            love.graphics.setColor(0.4, 0.35, 0.25, 1)
        else
            love.graphics.setColor(0.2, 0.18, 0.15, 1)
        end
        love.graphics.rectangle("fill", tabX, tabY, tabW, 25, 4, 4, 4, 4)

        love.graphics.setColor(0.6, 0.5, 0.3, 1)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", tabX, tabY, tabW, 25, 4, 4, 4, 4)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(label, tabX + 15, tabY + 5)

        tabX = tabX + tabW + 5
    end

    -- Resource list
    local listY = tabY + 40
    local listX = panelX + 20
    local rowH = 30
    local resources = DynamicMarketUI.getResourcesForCategory()

    -- Header
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.print("Surovina", listX, listY)
    love.graphics.print("Nakup", listX + 200, listY)
    love.graphics.print("Prodaja", listX + 280, listY)
    love.graphics.print("Trend", listX + 380, listY)
    love.graphics.print("Sprememba", listX + 450, listY)

    -- Underline
    love.graphics.setColor(0.6, 0.5, 0.3, 1)
    love.graphics.setLineWidth(1)
    love.graphics.line(listX, listY + 18, listX + panelW - 40, listY + 18)

    -- Rows
    for i, resource in ipairs(resources) do
        local y = listY + 25 + (i - 1) * rowH

        -- Alternating row background
        if i % 2 == 0 then
            love.graphics.setColor(0.2, 0.18, 0.15, 0.5)
            love.graphics.rectangle("fill", listX - 5, y - 3, panelW - 30, rowH - 2)
        end

        -- Resource name
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(RESOURCE_NAMES_SLV[resource] or resource, listX, y)

        -- Prices
        local buyPrice = DynamicMarket.getPrice(resource, "buy")
        local sellPrice = DynamicMarket.getPrice(resource, "sell")
        love.graphics.setColor(1, 0.9, 0.5, 1)
        love.graphics.print(tostring(buyPrice) .. " g", listX + 200, y)
        love.graphics.setColor(0.5, 1, 0.5, 1)
        love.graphics.print(tostring(sellPrice) .. " g", listX + 280, y)

        -- Trend
        local history = priceHistory[resource]
        if history then
            local trendIcon, trendColor
            if history.trend == "up" then
                trendIcon = "↑"
                trendColor = {1, 0.3, 0.3}  -- red (price going up = bad for buyer)
            elseif history.trend == "down" then
                trendIcon = "↓"
                trendColor = {0.3, 1, 0.3}  -- green
            else
                trendIcon = "→"
                trendColor = {0.7, 0.7, 0.7}
            end

            love.graphics.setColor(trendColor[1], trendColor[2], trendColor[3], 1)
            love.graphics.print(trendIcon, listX + 390, y)

            -- Change percentage
            if history.previous > 0 then
                local changePct = ((history.current - history.previous) / history.previous) * 100
                local changeStr = string.format("%+.1f%%", changePct)
                love.graphics.print(changeStr, listX + 450, y)
            else
                love.graphics.print("-", listX + 450, y)
            end
        end
    end

    -- Footer with active events
    local eventStats = require("objects.Economy.EconomicEventsSystem").getStats()
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print(string.format("Aktivni dogodki: %d", eventStats.activeCount),
        panelX + 20, panelY + panelH - 30)

    -- Close hint
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print("[M] Zapri", panelX + panelW - 80, panelY + panelH - 30)

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Handle mouse click on category tabs
function DynamicMarketUI.mousepressed(x, y, button)
    if not visible or button ~= 1 then return false end

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = 600
    local panelH = 500
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    -- Check if click is on category tabs
    local tabY = panelY + 85
    local tabX = panelX + 20
    local tabs = {"all", "materials", "food", "weapons"}
    local tabW = 100

    for _, tab in ipairs(tabs) do
        if x >= tabX and x <= tabX + tabW and y >= tabY and y <= tabY + 25 then
            selectedCategory = tab
            return true
        end
        tabX = tabX + tabW + 5
    end

    return false
end

-- Handle keypress
function DynamicMarketUI.keypressed(key)
    if key == "m" or key == "escape" then
        DynamicMarketUI.toggle()
        return true
    end
    return false
end

-- Get info for debug
function DynamicMarketUI.getInfo()
    return {
        visible = visible,
        category = selectedCategory,
        resourceCount = #DynamicMarketUI.getResourcesForCategory(),
    }
end

return DynamicMarketUI
