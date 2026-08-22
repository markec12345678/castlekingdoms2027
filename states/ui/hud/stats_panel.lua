-- states/ui/hud/stats_panel.lua
-- Castle Kingdoms 2027 v3.12.129 - Statistics Panel
--
-- Comprehensive statistics dashboard showing real-time game metrics:
--   * Royal Systems: total systems, active, total buildings, makers, products
--   * Market: revenue, gold, inflation, events, most volatile resource
--   * Production History: time-series chart of products made (60s window)
--   * Top Producers: leaderboard of most active systems
--   * Top Earners: leaderboard of highest revenue systems
--   * Activity Log: recent milestone achievements
--
-- Toggle with Ctrl+Shift+I (I for "Insights").
-- Tab to cycle between Overview / Production / Market / Leaderboards tabs.
-- Press / to search by system name.

local PanelAnim = require("states.ui.hud.PanelAnimations")
local Registry = require("objects.Economy.RoyalSystemsRegistry")
local RMI = require("objects.Economy.RoyalMarketIntegration")
local DynamicMarket = require("objects.Economy.DynamicMarketSystem")
local Deps = require("objects.Economy.SystemDependencies")

local StatsPanel = {}

local visible = false
local activeTab = "overview"  -- "overview" | "production" | "market" | "leaderboards"
local scrollOffset = 0
local searchActive = false
local searchQuery = ""
local historySamples = {}  -- list of {t, goldEarned, totalProducts, totalActive} sampled each second
local lastSampleTime = 0
local SAMPLE_INTERVAL = 1.0  -- seconds between samples
local MAX_SAMPLES = 60  -- keep 60 seconds of history

-- Anim state (slide-left + fade)
local animState = PanelAnim.createState({
    duration = 0.22,
    slideDir = "left",
    slideDist = 24,
    easing = "easeOut",
})

-- Tab metadata
local TABS = {
    overview     = { label = "PREGLED",       color = {0.6, 0.85, 0.6} },
    production   = { label = "PROIZVODNJA",   color = {0.9, 0.75, 0.3} },
    market       = { label = "TRG",            color = {0.4, 0.65, 0.95} },
    leaderboards = { label = "LESTVICE",      color = {0.85, 0.45, 0.85} },
}
local TAB_ORDER = {"overview", "production", "market", "leaderboards"}

function StatsPanel.toggle()
    if not visible then
        visible = true
        PanelAnim.open(animState)
        scrollOffset = 0
    else
        PanelAnim.close(animState)
    end
end

function StatsPanel.setVisible(state)
    if state and not visible then
        visible = true
        PanelAnim.open(animState)
        scrollOffset = 0
    elseif not state and visible then
        PanelAnim.close(animState)
    end
end

function StatsPanel.isVisible()
    return visible or PanelAnim.isAnimating(animState)
end

function StatsPanel.update(dt)
    if not visible and not PanelAnim.isAnimating(animState) then
        -- Still sample history for chart even when hidden
        lastSampleTime = lastSampleTime + dt
        if lastSampleTime >= SAMPLE_INTERVAL then
            lastSampleTime = 0
            sampleHistory()
        end
        return
    end
    PanelAnim.update(animState, dt)
    if animState.phase == "closed" then
        visible = false
    end
    -- Sample history periodically
    lastSampleTime = lastSampleTime + dt
    if lastSampleTime >= SAMPLE_INTERVAL then
        lastSampleTime = 0
        sampleHistory()
    end
end

-- Sample current stats into history
local function sampleHistory()
    local agg = Registry.getAggregate()
    local sample = {
        t = love.timer and love.timer.getTime() or 0,
        goldEarned = agg.totalGoldEarned or 0,
        totalProducts = agg.totalProducts or 0,
        totalActive = agg.totalActiveMaking or 0,
        totalBuildings = agg.totalBuildings or 0,
    }
    historySamples[#historySamples + 1] = sample
    if #historySamples > MAX_SAMPLES then
        table.remove(historySamples, 1)
    end
end

-- Helper: draw a simple bar chart
local function drawBarChart(x, y, w, h, values, maxVal, color, label, valueLabels)
    -- Background
    love.graphics.setColor(0.08, 0.08, 0.1, 0.6)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4, 4, 4)
    -- Border
    love.graphics.setColor(0.4, 0.45, 0.5, 0.6)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, w, h, 4, 4, 4, 4)
    -- Bars
    local n = #values
    if n == 0 then return end
    local barW = (w - 4) / n
    for i, v in ipairs(values) do
        local bh = maxVal > 0 and (v / maxVal) * (h - 8) or 0
        local bx = x + 2 + (i - 1) * barW
        local by = y + h - 4 - bh
        love.graphics.setColor(color[1], color[2], color[3], 0.85)
        love.graphics.rectangle("fill", bx, by, barW - 1, bh, 1, 1, 1, 1)
    end
    -- Label
    if label then
        love.graphics.setColor(0.7, 0.75, 0.8, 1)
        love.graphics.print(label, x + 4, y - 14)
    end
    -- Value labels (if provided)
    if valueLabels then
        local smallFont = love.graphics.newFont(9)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.6, 0.65, 0.7, 0.8)
        for i, lbl in ipairs(valueLabels) do
            if i <= n then
                local bx = x + 2 + (i - 1) * barW
                love.graphics.print(lbl, bx + 2, y + h + 2)
            end
        end
    end
end

-- Helper: draw a line chart (for time series)
local function drawLineChart(x, y, w, h, samples, key, color, label)
    -- Background
    love.graphics.setColor(0.08, 0.08, 0.1, 0.6)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4, 4, 4)
    love.graphics.setColor(0.4, 0.45, 0.5, 0.6)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, w, h, 4, 4, 4, 4)
    -- Compute min/max
    local n = #samples
    if n < 2 then
        love.graphics.setColor(0.5, 0.55, 0.6, 1)
        love.graphics.print("(zbiranje podatkov...)", x + 8, y + h / 2 - 6)
        return
    end
    local minV, maxV = math.huge, -math.huge
    for _, s in ipairs(samples) do
        local v = s[key] or 0
        if v < minV then minV = v end
        if v > maxV then maxV = v end
    end
    if maxV == minV then maxV = minV + 1 end
    -- Draw line
    love.graphics.setColor(color[1], color[2], color[3], 0.95)
    love.graphics.setLineWidth(2)
    local points = {}
    for i, s in ipairs(samples) do
        local px = x + 2 + (i - 1) * ((w - 4) / (n - 1))
        local py = y + h - 4 - ((s[key] - minV) / (maxV - minV)) * (h - 8)
        points[#points + 1] = px
        points[#points + 1] = py
    end
    if #points >= 4 then
        love.graphics.line(points)
    end
    -- Min/max labels
    local smallFont = love.graphics.newFont(9)
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.7, 0.75, 0.8, 0.9)
    love.graphics.print("max: " .. tostring(maxV), x + w - 80, y + 4)
    love.graphics.print("min: " .. tostring(minV), x + w - 80, y + h - 14)
    -- Label
    if label then
        love.graphics.setColor(0.8, 0.85, 0.9, 1)
        local font = love.graphics.newFont(11)
        love.graphics.setFont(font)
        love.graphics.print(label, x + 4, y - 14)
    end
end

function StatsPanel.draw()
    if not visible and not PanelAnim.isAnimating(animState) then return end

    local alpha = PanelAnim.getProgress(animState)
    local offsetX, offsetY = PanelAnim.getOffset(animState)

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = math.min(1020, screenW - 60)
    local panelH = math.min(700, screenH - 60)
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    local font = love.graphics.getFont()
    local titleFont = love.graphics.newFont(16)
    local smallFont = love.graphics.newFont(11)

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.7 * alpha)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    love.graphics.push("all")
    love.graphics.translate(offsetX, offsetY)

    -- Panel background
    love.graphics.setColor(0.06, 0.07, 0.09, 0.98 * alpha)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setColor(0.45, 0.65, 0.75, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.7, 0.85, 0.95, alpha)
    love.graphics.print("📊 STATISTIKA — Castle Kingdoms 2027", panelX + 16, panelY + 12)

    -- Hint
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.55, 0.6, 0.65, alpha)
    local hintText = "Ctrl+Shift+I: zapri  |  Tab: zavihek  |  ↑↓/wheel: scroll"
    if searchActive then hintText = "Iskanje: " .. searchQuery .. "_  |  ENTER: potrdi  |  ESC: prekliči" end
    love.graphics.print(hintText, panelX + 16, panelY + 36)

    -- Tab buttons
    local tabButtonX = panelX + 16
    local tabButtonY = panelY + 56
    local tabButtonW = 130
    local tabButtonH = 24
    local tabButtonGap = 4
    for i, tabKey in ipairs(TAB_ORDER) do
        local tabInfo = TABS[tabKey]
        local bx = tabButtonX + (i - 1) * (tabButtonW + tabButtonGap)
        local isActive = activeTab == tabKey
        if isActive then
            love.graphics.setColor(tabInfo.color[1], tabInfo.color[2], tabInfo.color[3], alpha * 0.7)
        else
            love.graphics.setColor(0.12, 0.14, 0.18, alpha * 0.6)
        end
        love.graphics.rectangle("fill", bx, tabButtonY, tabButtonW, tabButtonH, 3, 3, 3, 3)
        love.graphics.setColor(tabInfo.color[1], tabInfo.color[2], tabInfo.color[3], alpha)
        love.graphics.rectangle("line", bx, tabButtonY, tabButtonW, tabButtonH, 3, 3, 3, 3)
        love.graphics.setColor(isActive and 1 or 0.8, isActive and 1 or 0.8, isActive and 1 or 0.85, alpha)
        love.graphics.print(tabInfo.label, bx + 8, tabButtonY + 6)
    end

    -- Content area
    local contentTop = panelY + 90
    local contentH = panelH - 110
    local contentW = panelW - 32
    local contentLeft = panelX + 16

    love.graphics.setScissor(panelX + 8, contentTop, panelW - 16, contentH)

    if activeTab == "overview" then
        drawOverview(contentLeft, contentTop, contentW, contentH, alpha, smallFont, font)
    elseif activeTab == "production" then
        drawProduction(contentLeft, contentTop, contentW, contentH, alpha, smallFont, font)
    elseif activeTab == "market" then
        drawMarket(contentLeft, contentTop, contentW, contentH, alpha, smallFont, font)
    elseif activeTab == "leaderboards" then
        drawLeaderboards(contentLeft, contentTop, contentW, contentH, alpha, smallFont, font)
    end

    love.graphics.setScissor()

    -- Scrollbar (only for leaderboards/market which can have long content)
    if activeTab == "leaderboards" or activeTab == "market" then
        local sbX = panelX + panelW - 12
        local sbY = contentTop
        local sbH = contentH
        love.graphics.setColor(0.2, 0.2, 0.25, alpha * 0.5)
        love.graphics.rectangle("fill", sbX, sbY, 4, sbH, 2, 2, 2, 2)
        -- Thumb position depends on scroll (rough estimate)
        local thumbH = 40
        local thumbY = sbY + math.min(sbH - thumbH, scrollOffset)
        love.graphics.setColor(0.4, 0.45, 0.55, alpha)
        love.graphics.rectangle("fill", sbX + 1, thumbY, 2, thumbH, 1, 1, 1, 1)
    end

    -- Footer
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.5, 0.55, 0.6, alpha)
    love.graphics.print("Vzorčenje: 1/s · Zadnjih 60s v pomnilniku", panelX + 16, panelY + panelH - 20)

    love.graphics.setFont(font)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

-- ============================================================
-- TAB: OVERVIEW
-- ============================================================
function drawOverview(x, y, w, h, alpha, smallFont, font)
    love.graphics.setFont(font)
    love.graphics.setColor(0.85, 0.88, 0.92, alpha)
    love.graphics.print("PREGLED — skupne metrike igre", x, y)

    -- Get all stats
    local agg = Registry.getAggregate()
    local mktStats = DynamicMarket.getStats()
    local revenue = RMI.getRevenue()
    local perSystem = RMI.getPerSystemRevenue()
    local trackerStats = _G.AchievementTracker and _G.AchievementTracker.getStats() or { historyCount = 0 }

    -- Compute total revenue
    local totalRevenue = 0
    for _, v in pairs(perSystem) do totalRevenue = totalRevenue + (v or 0) end

    -- Compute active systems count
    local systems = Registry.getSystems()
    local activeCount = 0
    for _, s in ipairs(systems) do
        local stats = s.module.getStats()
        if stats and (stats.numBuildings or 0) > 0 then
            activeCount = activeCount + 1
        end
    end

    -- Compute total achievements unlocked
    local achUnlocked = 0
    local achTotal = 0
    if _G.AchievementTracker then
        local all = _G.AchievementTracker.getAll()
        for _, a in ipairs(all) do
            achTotal = achTotal + 1
            if a.unlocked then achUnlocked = achUnlocked + 1 end
        end
    end

    -- Compute tech tree stats
    local totalDeps = 0
    local metDeps = 0
    for _, s in ipairs(systems) do
        local d = Deps.getDependencies(s.key)
        if #d > 0 then
            totalDeps = totalDeps + 1
            local ok = Deps.checkDependencies(s.key)
            if ok then metDeps = metDeps + 1 end
        end
    end

    -- Big metric cards (3x2 grid)
    local cardW = (w - 32) / 3
    local cardH = 70
    local cardY = y + 30
    local cards = {
        { label = "SISTEMI", value = activeCount .. "/" .. #systems, sub = "aktivnih/skupaj", color = {0.5, 0.85, 0.6} },
        { label = "ZGRADBE", value = tostring(agg.totalBuildings or 0), sub = "skupaj zgrajenih", color = {0.85, 0.75, 0.4} },
        { label = "MOJSTRI", value = tostring(agg.totalMakers or 0), sub = "najetih", color = {0.7, 0.55, 0.85} },
        { label = "IZDELKI", value = tostring(agg.totalProducts or 0), sub = "v zaloga", color = {0.4, 0.7, 0.95} },
        { label = "AKTIVNA IZDELAVA", value = tostring(agg.totalActiveMaking or 0), sub = "v teku", color = {0.9, 0.6, 0.3} },
        { label = "BONUS ZLATO", value = tostring(agg.totalGoldEarned or 0), sub = "prisluženo", color = {0.95, 0.85, 0.3} },
    }
    for i, card in ipairs(cards) do
        local col = (i - 1) % 3
        local row = math.floor((i - 1) / 3)
        local cx = x + col * (cardW + 16)
        local cy = cardY + row * (cardH + 12)
        -- Card background
        love.graphics.setColor(0.1, 0.12, 0.15, alpha * 0.8)
        love.graphics.rectangle("fill", cx, cy, cardW, cardH, 4, 4, 4, 4)
        love.graphics.setColor(card.color[1], card.color[2], card.color[3], alpha)
        love.graphics.rectangle("fill", cx, cy, 4, cardH, 4, 0, 0, 4)
        -- Label
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.6, 0.65, 0.7, alpha)
        love.graphics.print(card.label, cx + 12, cy + 8)
        -- Value
        love.graphics.setFont(font)
        love.graphics.setColor(card.color[1], card.color[2], card.color[3], alpha)
        love.graphics.print(card.value, cx + 12, cy + 22)
        -- Sub
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.55, 0.6, 0.65, alpha)
        love.graphics.print(card.sub, cx + 12, cy + 48)
    end

    -- Stats row (smaller)
    local statsY = cardY + 2 * (cardH + 12) + 16
    love.graphics.setFont(font)
    love.graphics.setColor(0.8, 0.85, 0.9, alpha)
    love.graphics.print("PODROBNOSTI", x, statsY)

    local detailY = statsY + 22
    local details = {
        { label = "Tržni prihodek", value = tostring(totalRevenue), color = {0.4, 0.85, 0.4} },
        { label = "Inflacija", value = string.format("%.2f%%", (mktStats.inflation - 1) * 100), color = {0.9, 0.7, 0.3} },
        { label = "Tržni dogodki", value = tostring(mktStats.activeEvents or 0), color = {0.8, 0.5, 0.4} },
        { label = "Nestanovitna surovina", value = tostring(mktStats.mostVolatile or "—"), color = {0.9, 0.5, 0.6} },
        { label = "Tech tree met", value = metDeps .. "/" .. totalDeps, color = {0.5, 0.75, 0.95} },
        { label = "Dosežki odklenjeni", value = achUnlocked .. "/" .. achTotal, color = {0.85, 0.6, 0.95} },
    }
    for i, d in ipairs(details) do
        local col = (i - 1) % 3
        local row = math.floor((i - 1) / 3)
        local dx = x + col * (cardW + 16)
        local dy = detailY + row * 26
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.55, 0.6, 0.65, alpha)
        love.graphics.print(d.label .. ":", dx, dy + 4)
        love.graphics.setColor(d.color[1], d.color[2], d.color[3], alpha)
        love.graphics.print(d.value, dx + 160, dy + 4)
    end

    -- Gold earned history chart
    local chartY = detailY + 2 * 26 + 30
    local chartH = 100
    love.graphics.setFont(font)
    love.graphics.setColor(0.8, 0.85, 0.9, alpha)
    love.graphics.print("📊 ZGODOVINA BONUS ZLATA (60s)", x, chartY - 18)
    drawLineChart(x, chartY, w, chartH, historySamples, "goldEarned", {0.95, 0.85, 0.3}, nil)
end

-- ============================================================
-- TAB: PRODUCTION
-- ============================================================
function drawProduction(x, y, w, h, alpha, smallFont, font)
    love.graphics.setFont(font)
    love.graphics.setColor(0.85, 0.88, 0.92, alpha)
    love.graphics.print("PROIZVODNJA — časovni nizi in statistika", x, y)

    -- Get history data
    local agg = Registry.getAggregate()
    local systems = Registry.getSystems()

    -- Charts
    local chart1Y = y + 30
    local chartH = 100
    love.graphics.setColor(0.8, 0.85, 0.9, alpha)
    love.graphics.print("📦 SKUPNA ZALOGA IZDELKOV (60s)", x, chart1Y - 18)
    drawLineChart(x, chart1Y, w, chartH, historySamples, "totalProducts", {0.4, 0.7, 0.95}, nil)

    local chart2Y = chart1Y + chartH + 36
    love.graphics.print("🔧 AKTIVNA IZDELAVA (60s)", x, chart2Y - 18)
    drawLineChart(x, chart2Y, w, chartH, historySamples, "totalActive", {0.9, 0.6, 0.3}, nil)

    -- Top producing systems (top 10 by totalProducts)
    local chart3Y = chart2Y + chartH + 36
    love.graphics.print("🏆 TOP 10 PROIZVAJALCEV (po zalogi)", x, chart3Y - 18)
    local topProducers = {}
    for _, s in ipairs(systems) do
        local stats = s.module.getStats()
        if stats and (stats.totalProducts or 0) > 0 then
            topProducers[#topProducers + 1] = {
                name = s.name or s.key,
                value = stats.totalProducts or 0,
            }
        end
    end
    table.sort(topProducers, function(a, b) return a.value > b.value end)
    local topN = math.min(10, #topProducers)
    local values = {}
    local labels = {}
    local maxVal = 0
    for i = 1, topN do
        values[i] = topProducers[i].value
        labels[i] = topProducers[i].name:sub(1, 12)
        if topProducers[i].value > maxVal then maxVal = topProducers[i].value end
    end
    drawBarChart(x, chart3Y, w, 80, values, maxVal, {0.4, 0.7, 0.5}, nil, labels)
end

-- ============================================================
-- TAB: MARKET
-- ============================================================
function drawMarket(x, y, w, h, alpha, smallFont, font)
    love.graphics.setFont(font)
    love.graphics.setColor(0.85, 0.88, 0.92, alpha)
    love.graphics.print("TRG — tržne metrike in dinamika", x, y)

    local mktStats = DynamicMarket.getStats()
    local products = DynamicMarket.listRoyalProducts()
    local perSystem = RMI.getPerSystemRevenue()
    local totalRevenue = 0
    for _, v in pairs(perSystem) do totalRevenue = totalRevenue + (v or 0) end

    -- Top row: 3 metric cards
    local cardW = (w - 32) / 3
    local cardH = 60
    local cardY = y + 30
    local cards = {
        { label = "TRŽNI PRIHODEK", value = tostring(totalRevenue), sub = "skupaj", color = {0.4, 0.85, 0.4} },
        { label = "INFLACIJA", value = string.format("%.2f%%", (mktStats.inflation - 1) * 100), sub = "od baze", color = {0.9, 0.7, 0.3} },
        { label = "AKTIVNI DOGODKI", value = tostring(mktStats.activeEvents or 0), sub = "v teku", color = {0.8, 0.5, 0.4} },
    }
    for i, card in ipairs(cards) do
        local cx = x + (i - 1) * (cardW + 16)
        love.graphics.setColor(0.1, 0.12, 0.15, alpha * 0.8)
        love.graphics.rectangle("fill", cx, cardY, cardW, cardH, 4, 4, 4, 4)
        love.graphics.setColor(card.color[1], card.color[2], card.color[3], alpha)
        love.graphics.rectangle("fill", cx, cardY, 4, cardH, 4, 0, 0, 4)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.6, 0.65, 0.7, alpha)
        love.graphics.print(card.label, cx + 12, cardY + 8)
        love.graphics.setFont(font)
        love.graphics.setColor(card.color[1], card.color[2], card.color[3], alpha)
        love.graphics.print(card.value, cx + 12, cardY + 22)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.55, 0.6, 0.65, alpha)
        love.graphics.print(card.sub, cx + 12, cardY + 44)
    end

    -- Top 10 most sold products
    local topSoldY = cardY + cardH + 30
    love.graphics.setFont(font)
    love.graphics.setColor(0.8, 0.85, 0.9, alpha)
    love.graphics.print("🏆 TOP 10 PRODANIH IZDELKOV", x, topSoldY - 18)

    -- Filter products with totalSold > 0, sort by sold
    local soldList = {}
    for _, p in ipairs(products) do
        if (p.totalSold or 0) > 0 then
            soldList[#soldList + 1] = {
                name = p.productType,
                value = p.totalSold,
                revenue = p.totalRevenue or 0,
            }
        end
    end
    table.sort(soldList, function(a, b) return a.value > b.value end)
    local topN = math.min(10, #soldList)

    -- Header row
    local listY = topSoldY + 6
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.55, 0.6, 0.65, alpha)
    love.graphics.print("#", x + 4, listY)
    love.graphics.print("IZDELEK", x + 32, listY)
    love.graphics.print("PRODANO", x + 280, listY)
    love.graphics.print("PRIHODEK", x + 380, listY)
    love.graphics.print("DELEŽ", x + 480, listY)

    local maxVal = 0
    for i = 1, topN do
        if soldList[i].value > maxVal then maxVal = soldList[i].value end
    end

    for i = 1, topN do
        local ry = listY + 16 + (i - 1) * 22
        local item = soldList[i]
        love.graphics.setColor(0.85, 0.88, 0.92, alpha)
        love.graphics.print(tostring(i), x + 4, ry)
        love.graphics.print(item.name:sub(1, 30), x + 32, ry)
        love.graphics.setColor(0.4, 0.85, 0.4, alpha)
        love.graphics.print(tostring(item.value), x + 280, ry)
        love.graphics.setColor(0.95, 0.85, 0.3, alpha)
        love.graphics.print(tostring(item.revenue), x + 380, ry)
        -- Bar
        local barW = 80
        local barH = 8
        local barFill = maxVal > 0 and (item.value / maxVal) * barW or 0
        love.graphics.setColor(0.15, 0.15, 0.18, alpha)
        love.graphics.rectangle("fill", x + 480, ry + 4, barW, barH, 2, 2, 2, 2)
        love.graphics.setColor(0.4, 0.7, 0.5, alpha)
        love.graphics.rectangle("fill", x + 481, ry + 5, math.max(0, barFill - 2), barH - 2, 1, 1, 1, 1)
    end

    if topN == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6, alpha)
        love.graphics.print("(ni prodanih izdelkov)", x + 4, listY + 16)
    end
end

-- ============================================================
-- TAB: LEADERBOARDS
-- ============================================================
function drawLeaderboards(x, y, w, h, alpha, smallFont, font)
    love.graphics.setFont(font)
    love.graphics.setColor(0.85, 0.88, 0.92, alpha)
    love.graphics.print("LESTVICE — top sistemi po različnih kriterijih", x, y)

    local systems = Registry.getSystems()
    local perSystem = RMI.getPerSystemRevenue()
    local listY = y + 30 - scrollOffset

    -- Top 15 by revenue
    love.graphics.setFont(font)
    love.graphics.setColor(0.8, 0.85, 0.9, alpha)
    love.graphics.print("💰 TOP 15 PO PRIHODKU (gold)", x, listY)
    local revenueList = {}
    for _, s in ipairs(systems) do
        local rev = perSystem[s.key] or 0
        if rev > 0 then
            revenueList[#revenueList + 1] = {
                name = s.name or s.key,
                value = rev,
            }
        end
    end
    table.sort(revenueList, function(a, b) return a.value > b.value end)

    local list1Y = listY + 22
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.55, 0.6, 0.65, alpha)
    love.graphics.print("#", x + 4, list1Y)
    love.graphics.print("SISTEM", x + 32, list1Y)
    love.graphics.print("PRIHODEK", x + 220, list1Y)

    local maxVal = 0
    for i = 1, math.min(15, #revenueList) do
        if revenueList[i].value > maxVal then maxVal = revenueList[i].value end
    end
    for i = 1, math.min(15, #revenueList) do
        local ry = list1Y + 16 + (i - 1) * 20
        local item = revenueList[i]
        love.graphics.setColor(0.85, 0.88, 0.92, alpha)
        love.graphics.print(tostring(i), x + 4, ry)
        love.graphics.print(item.name:sub(1, 30), x + 32, ry)
        love.graphics.setColor(0.95, 0.85, 0.3, alpha)
        love.graphics.print(tostring(item.value), x + 220, ry)
        -- Bar
        local barW = 200
        local barH = 6
        local barFill = maxVal > 0 and (item.value / maxVal) * barW or 0
        love.graphics.setColor(0.15, 0.15, 0.18, alpha)
        love.graphics.rectangle("fill", x + 320, ry + 4, barW, barH, 2, 2, 2, 2)
        love.graphics.setColor(0.85, 0.65, 0.2, alpha)
        love.graphics.rectangle("fill", x + 321, ry + 5, math.max(0, barFill - 2), barH - 2, 1, 1, 1, 1)
    end
    if #revenueList == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6, alpha)
        love.graphics.print("(ni sistemov s prihodkom)", x + 4, list1Y + 16)
    end

    -- Top 15 by buildings
    local list2StartY = list1Y + 16 + math.min(15, #revenueList) * 20 + 30
    love.graphics.setFont(font)
    love.graphics.setColor(0.8, 0.85, 0.9, alpha)
    love.graphics.print("🏗 TOP 15 PO ŠTEVILU ZGRADB", x, list2StartY)

    local buildingList = {}
    for _, s in ipairs(systems) do
        local stats = s.module.getStats()
        if stats and (stats.numBuildings or 0) > 0 then
            buildingList[#buildingList + 1] = {
                name = s.name or s.key,
                value = stats.numBuildings or 0,
            }
        end
    end
    table.sort(buildingList, function(a, b) return a.value > b.value end)

    local list2Y = list2StartY + 22
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.55, 0.6, 0.65, alpha)
    love.graphics.print("#", x + 4, list2Y)
    love.graphics.print("SISTEM", x + 32, list2Y)
    love.graphics.print("ZGRADBE", x + 220, list2Y)

    local maxVal2 = 0
    for i = 1, math.min(15, #buildingList) do
        if buildingList[i].value > maxVal2 then maxVal2 = buildingList[i].value end
    end
    for i = 1, math.min(15, #buildingList) do
        local ry = list2Y + 16 + (i - 1) * 20
        local item = buildingList[i]
        love.graphics.setColor(0.85, 0.88, 0.92, alpha)
        love.graphics.print(tostring(i), x + 4, ry)
        love.graphics.print(item.name:sub(1, 30), x + 32, ry)
        love.graphics.setColor(0.75, 0.55, 0.85, alpha)
        love.graphics.print(tostring(item.value), x + 220, ry)
        -- Bar
        local barW = 200
        local barH = 6
        local barFill = maxVal2 > 0 and (item.value / maxVal2) * barW or 0
        love.graphics.setColor(0.15, 0.15, 0.18, alpha)
        love.graphics.rectangle("fill", x + 320, ry + 4, barW, barH, 2, 2, 2, 2)
        love.graphics.setColor(0.65, 0.45, 0.8, alpha)
        love.graphics.rectangle("fill", x + 321, ry + 5, math.max(0, barFill - 2), barH - 2, 1, 1, 1, 1)
    end
    if #buildingList == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6, alpha)
        love.graphics.print("(ni sistemov z zgradbami)", x + 4, list2Y + 16)
    end
end

function StatsPanel.wheelmoved(x, y)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    if y > 0 then
        scrollOffset = math.max(0, scrollOffset - 40)
        return true
    elseif y < 0 then
        scrollOffset = scrollOffset + 40
        return true
    end
    return false
end

function StatsPanel.keypressed(key, scancode, isrepeat)
    if not visible and not PanelAnim.isAnimating(animState) then return false end

    if searchActive then
        if key == "escape" then
            searchActive = false
            searchQuery = ""
            return true
        end
        if key == "return" then
            searchActive = false
            return true
        end
        if key == "backspace" then
            searchQuery = searchQuery:sub(1, -2)
            return true
        end
        return false
    end

    if key == "escape" then
        StatsPanel.toggle()
        return true
    end
    if key == "/" then
        searchActive = true
        return true
    end
    if key == "tab" then
        for i, t in ipairs(TAB_ORDER) do
            if t == activeTab then
                activeTab = TAB_ORDER[(i % #TAB_ORDER) + 1]
                break
            end
        end
        scrollOffset = 0
        return true
    end
    if key == "up" then
        scrollOffset = math.max(0, scrollOffset - 40)
        return true
    end
    if key == "down" then
        scrollOffset = scrollOffset + 40
        return true
    end
    if key == "pageup" then
        scrollOffset = math.max(0, scrollOffset - 200)
        return true
    end
    if key == "pagedown" then
        scrollOffset = scrollOffset + 200
        return true
    end
    if key == "home" then
        scrollOffset = 0
        return true
    end
    return false
end

function StatsPanel.textinput(text)
    if not visible or not searchActive then return false end
    if #searchQuery < 30 and text:match("^[%w%s%-_]+$") then
        searchQuery = searchQuery .. text
    end
    return true
end

function StatsPanel.mousepressed(x, y, button)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    if button ~= 1 then return false end
    -- Click on tab buttons
    local screenW = love.graphics.getWidth()
    local panelW = math.min(1020, screenW - 60)
    local panelX = (screenW - panelW) / 2
    local screenH = love.graphics.getHeight()
    local panelH = math.min(700, screenH - 60)
    local panelY = (screenH - panelH) / 2
    local tabButtonX = panelX + 16
    local tabButtonY = panelY + 56
    local tabButtonW = 130
    local tabButtonH = 24
    local tabButtonGap = 4
    for i, tabKey in ipairs(TAB_ORDER) do
        local bx = tabButtonX + (i - 1) * (tabButtonW + tabButtonGap)
        if x >= bx and x <= bx + tabButtonW and y >= tabButtonY and y <= tabButtonY + tabButtonH then
            activeTab = tabKey
            scrollOffset = 0
            return true
        end
    end
    -- Click outside panel closes
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        StatsPanel.toggle()
        return true
    end
    return false
end

function StatsPanel.mousemoved(x, y, dx, dy)
    return false
end

function StatsPanel.mousereleased(x, y, button)
    return false
end

return StatsPanel
