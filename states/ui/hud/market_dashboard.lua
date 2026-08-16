-- states/ui/hud/market_dashboard.lua
-- Castle Kingdoms 2027 - Royal Market Dashboard
--
-- Full-screen overlay panel showing all Royal products registered on the
-- DynamicMarket. Allows the player to:
--   * Browse all products with search + sort
--   * View base price, current sell/buy prices, modifier %, total sold, revenue
--   * See aggregate market stats (inflation, total revenue, most volatile)
--   * Trigger market events (for testing): price crash, price surge
--
-- Toggle with Ctrl+K. Press / to search. Press S to cycle sort mode.
-- Press E to trigger a random market event on the selected product.

local DynamicMarket = require("objects.Economy.DynamicMarketSystem")
local RMI = require("objects.Economy.RoyalMarketIntegration")
local Registry = require("objects.Economy.RoyalSystemsRegistry")

local MarketDashboard = {}

-- Fonts (lazily created on first draw, cached for subsequent draws)
local titleFont, smallFont

local visible = false
local selectedIndex = 1
local page = 1
local pageSize = 6
local totalPages = 1

-- v3.11.960: Product row click areas (populated during draw, used by mousepressed)
-- Each entry: {x, y, w, h, productType, source, index}
local productRowAreas = {}

-- v3.11.960: Double-click detection state
local lastClickTime = 0
local lastClickProductType = nil
local DOUBLE_CLICK_THRESHOLD = 0.4  -- seconds

-- Search & sort state
local searchQuery = ""
local searchActive = false
local sortMode = "alpha"  -- "alpha", "sold", "revenue", "volatile", "price"
local sortModes = {
    alpha = "Abecedno",
    sold = "Po prodaji",
    revenue = "Po prihodku",
    volatile = "Po nestanovitnosti",
    price = "Po ceni",
}

-- Leaderboard mode: "qty" (top producers by quantity) or "profit" (top by gold earned)
local leaderboardMode = "qty"

-- Event log expanded panel state
local eventLogExpanded = false
local eventLogFilter = "all"  -- "all", "surge", "crash", "seasonal", "manual"
local eventLogScrollOffset = 0  -- scroll position in event list (0 = top)

-- Comparison mode: multi-product price comparison chart
-- comparisonList: set of productTypes selected for comparison
-- comparisonMode: when true, show comparison chart instead of single-product detail panel
local comparisonList = {}  -- ordered list of productType strings
local comparisonSet = {}   -- set for fast lookup (productType -> true)
local comparisonMode = false
local comparisonMaxItems = 6  -- limit to keep chart readable

-- Color palette for comparison lines (cycled by index)
local COMPARISON_COLORS = {
    {0.4, 0.95, 0.4},   -- green
    {0.4, 0.6, 0.95},   -- blue
    {0.95, 0.7, 0.4},   -- orange
    {0.95, 0.4, 0.6},   -- pink
    {0.95, 0.95, 0.4},  -- yellow
    {0.7, 0.4, 0.95},   -- purple
}

local actionMessage = ""
local actionMessageTime = 0

-- Cached product list (rebuilt on demand)
local cachedProducts = {}
local cacheTimer = 0
local CACHE_REFRESH = 0.5  -- refresh every 500ms when visible

-- Category colors for sort mode chips
local SORT_COLORS = {
    alpha = {0.6, 0.7, 0.9},
    sold = {0.4, 0.9, 0.5},
    revenue = {0.9, 0.8, 0.4},
    volatile = {0.9, 0.5, 0.5},
    price = {0.8, 0.6, 0.9},
}

function MarketDashboard.toggle()
    visible = not visible
    if visible then
        MarketDashboard.refresh()
        love.keyboard.setTextInput(false)  -- ensure text input is off when first opened
    end
end

function MarketDashboard.isVisible()
    return visible
end

-- Rebuild the cached product list (sorted, filtered)
function MarketDashboard.refresh()
    local products = DynamicMarket.listRoyalProducts()
    -- Apply search filter
    local query = searchQuery:lower()
    local filtered = {}
    for _, p in ipairs(products) do
        if query == "" or p.productType:lower():find(query, 1, true) then
            filtered[#filtered + 1] = p
        end
    end

    -- Apply sort
    if sortMode == "alpha" then
        table.sort(filtered, function(a, b) return a.productType < b.productType end)
    elseif sortMode == "sold" then
        table.sort(filtered, function(a, b) return (a.totalSold or 0) > (b.totalSold or 0) end)
    elseif sortMode == "revenue" then
        table.sort(filtered, function(a, b) return (a.totalRevenue or 0) > (b.totalRevenue or 0) end)
    elseif sortMode == "volatile" then
        -- Volatility = abs(current sell - base sell) / base sell
        local function vol(p)
            local baseSell = math.floor(p.basePrice * 0.7 + 0.5)
            if baseSell == 0 then return 0 end
            return math.abs(p.currentSell - baseSell) / baseSell
        end
        table.sort(filtered, function(a, b) return vol(a) > vol(b) end)
    elseif sortMode == "price" then
        table.sort(filtered, function(a, b) return (a.currentSell or 0) > (b.currentSell or 0) end)
    end

    cachedProducts = filtered
    totalPages = math.max(1, math.ceil(#filtered / pageSize))
    if page > totalPages then page = totalPages end
    if page < 1 then page = 1 end
end

function MarketDashboard.update(dt)
    if not visible then return end

    -- Refresh cache periodically
    cacheTimer = cacheTimer + dt
    if cacheTimer >= CACHE_REFRESH then
        cacheTimer = 0
        MarketDashboard.refresh()
    end

    -- Action message fade
    if actionMessage ~= "" then
        actionMessageTime = actionMessageTime - dt
        if actionMessageTime <= 0 then actionMessage = "" end
    end
end

local function showMessage(msg)
    actionMessage = msg
    actionMessageTime = 3.0
end

function MarketDashboard.draw()
    if not visible then return end

    local W = love.graphics.getWidth()
    local H = love.graphics.getHeight()

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, W, H)

    -- Panel
    local panelW = math.min(1100, W - 80)
    local panelH = math.min(720, H - 80)
    local panelX = (W - panelW) / 2
    local panelY = (H - panelH) / 2

    love.graphics.setColor(0.12, 0.13, 0.18, 1)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setColor(0.4, 0.5, 0.7, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setLineWidth(1)

    local font = love.graphics.getFont()
    if not titleFont then titleFont = love.graphics.newFont(16) end
    if not smallFont then smallFont = love.graphics.newFont(11) end

    -- Title bar
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.9, 0.85, 0.5, 1)
    love.graphics.print("🏰 KRALJEVI TRG — Nadzorna plošča trga", panelX + 16, panelY + 12)
    love.graphics.setFont(font)
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print("Ctrl+K: zapri  |  /: iskanje  |  S: sort  |  E: dogodek  |  Q: leaderboard  |  V: zgodovina dogodkov  |  SPACE: primerjava  |  C: primerjava  |  ←→: stran  |  2x click: odpri sistem",
        panelX + 16, panelY + 36)

    -- Aggregate stats bar
    local rmiStats = RMI.getStats()
    local mStats = rmiStats.marketStats or {}
    local y = panelY + 60
    love.graphics.setColor(0.2, 0.25, 0.35, 1)
    love.graphics.rectangle("fill", panelX + 16, y, panelW - 32, 28, 4, 4, 4, 4)
    love.graphics.setColor(0.8, 0.85, 0.95, 1)
    love.graphics.print(string.format(
        "Produktov: %d  |  Prihodek: %d zlata  |  Prodano: %d kosov  |  Inflacija: %.2f  |  Najbolj nestabilno: %s  |  Auto-sell: %s",
        rmiStats.registeredProducts or 0,
        rmiStats.aggregateRevenue or 0,
        rmiStats.totalSold or 0,
        mStats.inflation or 1.0,
        mStats.mostVolatile or "—",
        rmiStats.autoSellEnabled and "ON" or "OFF"
    ), panelX + 24, y + 7)

    -- Aggregate production chart + Top-10 leaderboard (kingdom-wide, last 60s)
    y = y + 32
    local aggChartH = 130
    local aggChartY = y
    love.graphics.setColor(0.2, 0.22, 0.28, 1)
    love.graphics.rectangle("fill", panelX + 16, aggChartY, panelW - 32, aggChartH, 4, 4, 4, 4)
    love.graphics.setColor(0.4, 0.5, 0.7, 0.5)
    love.graphics.rectangle("line", panelX + 16, aggChartY, panelW - 32, aggChartH, 4, 4, 4, 4)

    -- Layout: chart on left (~70%), leaderboard on right (~30%)
    local lbW = 340
    local chartAreaW = panelW - 32 - lbW - 16
    local chartAreaX = panelX + 16
    local lbX = chartAreaX + chartAreaW + 16

    -- Chart title
    love.graphics.setColor(0.7, 0.85, 0.95, 1)
    if smallFont then love.graphics.setFont(smallFont) end
    love.graphics.print("🏭 SKUPNA PROIZVODNJA VSEH 987 SISTEMOV (zadnjih 60s)", chartAreaX + 8, aggChartY + 4)

    local aggHist = Registry.getAggregateProductionHistory(60)
    local aggStats = Registry.getAggregateProduction(60)
    if aggHist and aggHist.maxQty > 1 and aggStats then
        -- Plot area
        local padLeft, padRight, padTop, padBottom = 32, 12, 22, 14
        local plotX = chartAreaX + padLeft
        local plotY = aggChartY + padTop
        local plotW = chartAreaW - padLeft - padRight
        local plotH = aggChartH - padTop - padBottom

        -- Y-axis labels (max and 0)
        love.graphics.setColor(0.5, 0.55, 0.65, 1)
        love.graphics.print(tostring(aggHist.maxQty), chartAreaX + 8, plotY - 4)
        love.graphics.print("0", chartAreaX + 8, plotY + plotH - 8)

        -- Draw bar chart for qty
        love.graphics.setLineWidth(2)
        local barW = plotW / 60
        for i = 1, 60 do
            local b = aggHist.buckets[i]
            if b and b.qty > 0 then
                local h = (b.qty / aggHist.maxQty) * plotH
                local bx = plotX + (i - 1) * barW
                local by = plotY + plotH - h
                local recency = (60 - (i - 1)) / 60
                love.graphics.setColor(0.3 + recency * 0.4, 0.85, 0.4, 0.85)
                love.graphics.rectangle("fill", bx + 0.5, by, math.max(1, barW - 1), h)
            end
        end
        love.graphics.setLineWidth(1)

        -- X-axis time labels
        love.graphics.setColor(0.5, 0.55, 0.65, 1)
        love.graphics.print("-60s", plotX, plotY + plotH + 2)
        love.graphics.print("-30s", plotX + plotW / 2 - 12, plotY + plotH + 2)
        love.graphics.print("now", plotX + plotW - 20, plotY + plotH + 2)
    else
        love.graphics.setColor(0.5, 0.55, 0.6, 1)
        love.graphics.print("(čakam na proizvodnjo — začni izdelovati v Royal sistemih)",
            chartAreaX + 16, aggChartY + aggChartH / 2 - 4)
    end

    -- Top-10 producers leaderboard (right column) - toggleable: by qty or by profit
    love.graphics.setColor(0.7, 0.85, 0.7, 1)
    if smallFont then love.graphics.setFont(smallFont) end
    local lbTitle
    if leaderboardMode == "profit" then
        lbTitle = "💰 TOP-10 PO PRIHODKU (zadnja minuta)  [Q: preklop]"
    else
        lbTitle = "🏆 TOP-10 PRODUCENTOV (zadnja minuta)  [Q: preklop]"
    end
    love.graphics.print(lbTitle, lbX + 4, aggChartY + 4)

    -- Fetch data based on mode
    local topList, maxVal
    if leaderboardMode == "profit" then
        topList = RMI.getTopProfitProducers(10, 60)
        maxVal = 1
        for _, p in ipairs(topList) do
            if p.totalGold > maxVal then maxVal = p.totalGold end
        end
    else
        topList = Registry.getTopProducers(10, 60)
        maxVal = 1
        for _, p in ipairs(topList) do
            if p.totalQty > maxVal then maxVal = p.totalQty end
        end
    end

    if #topList > 0 then
        -- Column headers (mode-specific)
        love.graphics.setColor(0.45, 0.55, 0.65, 1)
        love.graphics.print("#", lbX + 4, aggChartY + 22)
        love.graphics.print("Sistem", lbX + 22, aggChartY + 22)
        if leaderboardMode == "profit" then
            love.graphics.print("Zlata", lbX + 200, aggChartY + 22)
            love.graphics.print("/min", lbX + 250, aggChartY + 22)
            love.graphics.print("Cena/kos", lbX + 290, aggChartY + 22)
        else
            love.graphics.print("Kosov", lbX + 200, aggChartY + 22)
            love.graphics.print("/min", lbX + 250, aggChartY + 22)
            love.graphics.print("Prest.", lbX + 295, aggChartY + 22)
        end

        for i, p in ipairs(topList) do
            local rowY = aggChartY + 36 + (i - 1) * 11
            -- Rank
            local rankColor
            if i == 1 then rankColor = {0.95, 0.85, 0.3, 1}        -- gold
            elseif i == 2 then rankColor = {0.8, 0.8, 0.8, 1}       -- silver
            elseif i == 3 then rankColor = {0.8, 0.55, 0.35, 1}     -- bronze
            else rankColor = {0.6, 0.65, 0.7, 1} end
            love.graphics.setColor(rankColor)
            love.graphics.print(tostring(i), lbX + 4, rowY)

            -- Bar background (proportional to value)
            local val = leaderboardMode == "profit" and p.totalGold or p.totalQty
            local barFrac = val / maxVal
            -- Bar color tint differs by mode
            if leaderboardMode == "profit" then
                love.graphics.setColor(0.35, 0.25, 0.2, 0.5)
            else
                love.graphics.setColor(0.2, 0.35, 0.25, 0.5)
            end
            love.graphics.rectangle("fill", lbX + 18, rowY + 1, 180, 9)

            -- Bar fill
            local rankColorDim = {rankColor[1] * 0.5, rankColor[2] * 0.5, rankColor[3] * 0.5, 0.7}
            love.graphics.setColor(rankColorDim[1], rankColorDim[2], rankColorDim[3], 0.7)
            love.graphics.rectangle("fill", lbX + 18, rowY + 1, 180 * barFrac, 9)

            -- Name
            love.graphics.setColor(0.85, 0.88, 0.9, 1)
            local displayName = p.name or p.key
            if #displayName > 22 then displayName = displayName:sub(1, 21) .. "…" end
            love.graphics.print(displayName, lbX + 22, rowY)

            -- Numbers (mode-specific)
            if leaderboardMode == "profit" then
                love.graphics.setColor(0.95, 0.85, 0.4, 1)  -- gold-ish for revenue
                love.graphics.print(tostring(p.totalGold), lbX + 200, rowY)
                love.graphics.setColor(0.7, 0.85, 0.7, 1)
                love.graphics.print(string.format("%.0f", p.goldPerMin), lbX + 250, rowY)
                love.graphics.setColor(0.85, 0.75, 0.5, 1)
                love.graphics.print(string.format("%.0f", p.avgUnitPrice or 0), lbX + 290, rowY)
            else
                love.graphics.setColor(0.7, 0.85, 0.7, 1)
                love.graphics.print(tostring(p.totalQty), lbX + 200, rowY)
                love.graphics.print(string.format("%.1f", p.ratePerMin), lbX + 250, rowY)
                love.graphics.setColor(0.85, 0.75, 0.5, 1)
                love.graphics.print(string.format("%.1f", p.avgPrestige), lbX + 295, rowY)
            end
        end
    else
        love.graphics.setColor(0.5, 0.55, 0.6, 1)
        if leaderboardMode == "profit" then
            love.graphics.print("(ni prodaje v zadnji minuti)", lbX + 8, aggChartY + 30)
            love.graphics.print("Prodaj s 'Prodaj na trgu'", lbX + 8, aggChartY + 44)
            love.graphics.print("ali vklopi auto-sell.", lbX + 8, aggChartY + 58)
        else
            love.graphics.print("(ni aktivnih sistemov)", lbX + 8, aggChartY + 30)
            love.graphics.print("Začni izdelovati v Royal", lbX + 8, aggChartY + 44)
            love.graphics.print("sistemih (Ctrl+R).", lbX + 8, aggChartY + 58)
        end
    end

    if font then love.graphics.setFont(font) end

    -- Search bar
    y = y + aggChartH + 8
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print("Iskanje:", panelX + 16, y + 4)
    love.graphics.setColor(0.15, 0.15, 0.2, 1)
    love.graphics.rectangle("fill", panelX + 80, y, 300, 22, 3, 3, 3, 3)
    if searchActive then
        love.graphics.setColor(0.9, 0.8, 0.4, 1)
        love.graphics.rectangle("line", panelX + 80, y, 300, 22, 3, 3, 3, 3)
    end
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    local searchDisplay = searchQuery
    if searchActive then searchDisplay = searchDisplay .. "_" end
    love.graphics.print(searchDisplay, panelX + 86, y + 4)

    -- Sort mode chips
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print("Sortiranje:", panelX + 400, y + 4)
    local chipX = panelX + 480
    for _, mode in ipairs({"alpha", "sold", "revenue", "volatile", "price"}) do
        local label = sortModes[mode]
        local chipW = 90
        if mode == sortMode then
            love.graphics.setColor(SORT_COLORS[mode][1], SORT_COLORS[mode][2], SORT_COLORS[mode][3], 1)
        else
            love.graphics.setColor(0.2, 0.2, 0.25, 1)
        end
        love.graphics.rectangle("fill", chipX, y, chipW, 22, 3, 3, 3, 3)
        love.graphics.setColor(0.9, 0.9, 0.9, 1)
        love.graphics.setFont(smallFont)
        love.graphics.print(label, chipX + 6, y + 5)
        love.graphics.setFont(font)
        chipX = chipX + chipW + 6
    end

    -- Results count + event log summary
    y = y + 28
    love.graphics.setColor(0.6, 0.7, 0.5, 1)
    love.graphics.print(string.format("Rezultati: %d produktov  |  Stran %d/%d",
        #cachedProducts, page, totalPages), panelX + 16, y)

    -- Event log (right side of same row) - compact recent events
    local eventLog = DynamicMarket.getEventLog(5)
    local eventStats = DynamicMarket.getEventStats(300)  -- last 5 min
    local evX = panelX + 350
    local evW = panelW - 32 - (350 - 16)
    love.graphics.setColor(0.2, 0.22, 0.28, 1)
    love.graphics.rectangle("fill", evX, y - 2, evW, 22, 3, 3, 3, 3)
    love.graphics.setColor(0.4, 0.5, 0.7, 0.5)
    love.graphics.rectangle("line", evX, y - 2, evW, 22, 3, 3, 3, 3)
    if smallFont then love.graphics.setFont(smallFont) end
    -- Stats summary
    love.graphics.setColor(0.7, 0.85, 0.95, 1)
    local statsStr = string.format("Dogodki (5min): %d  |  📈surge: %d  📉crash: %d  ❄sezon: %d  [V: razširi]",
        eventStats.total, eventStats.surge, eventStats.crash, eventStats.seasonal)
    love.graphics.print(statsStr, evX + 8, y + 3)
    -- Most recent event (if any)
    if #eventLog > 0 then
        local e = eventLog[1]
        local ageStr = ""
        local age = ((love.timer and love.timer.getTime()) or 0) - e.t
        if age < 60 then ageStr = string.format("%ds nazaj", math.floor(age))
        else ageStr = string.format("%dm nazaj", math.floor(age / 60)) end
        local typeIcon = e.type == "surge" and "📈" or (e.type == "crash" and "📉" or "•")
        local typeColor
        if e.type == "surge" then typeColor = {0.4, 0.95, 0.4, 1}
        elseif e.type == "crash" then typeColor = {0.95, 0.4, 0.4, 1}
        elseif e.type == "seasonal" then typeColor = {0.5, 0.7, 0.95, 1}
        else typeColor = {0.7, 0.7, 0.7, 1} end
        love.graphics.setColor(typeColor)
        local lastStr = string.format("  |  Zadnji: %s %s x%.2f (%s)",
            typeIcon, e.productType, e.multiplier, ageStr)
        love.graphics.print(lastStr, evX + 8 + smallFont:getWidth(statsStr), y + 3)
    end
    if font then love.graphics.setFont(font) end

    -- Expanded event log panel (overlay when V is pressed)
    if eventLogExpanded then
        local overlayW = math.min(800, panelW - 80)
        local overlayH = 400
        local overlayX = panelX + (panelW - overlayW) / 2
        local overlayY = panelY + (panelH - overlayH) / 2

        -- Dim background
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", panelX, panelY, panelW, panelH)

        -- Panel
        love.graphics.setColor(0.12, 0.14, 0.18, 1)
        love.graphics.rectangle("fill", overlayX, overlayY, overlayW, overlayH, 6, 6, 6, 6)
        love.graphics.setColor(0.5, 0.7, 0.9, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", overlayX, overlayY, overlayW, overlayH, 6, 6, 6, 6)
        love.graphics.setLineWidth(1)

        -- Title
        love.graphics.setColor(0.9, 0.85, 0.5, 1)
        if titleFont then love.graphics.setFont(titleFont) end
        love.graphics.print("📜 ZGODOVINA TRŽNIH DOGODKOV", overlayX + 16, overlayY + 12)
        love.graphics.setFont(font)
        love.graphics.setColor(0.5, 0.6, 0.7, 1)
        if smallFont then love.graphics.setFont(smallFont) end
        love.graphics.print("V: zapri  |  1-5: filter  |  ↑↓/PgUp/PgDn/wheel: scroll  |  Home: top  |  click zunaj: zapri", overlayX + 16, overlayY + 34)
        love.graphics.setFont(font)

        -- Filter chips
        local filters = {
            {id = "all",      label = "Vsi",      icon = "•"},
            {id = "surge",    label = "Surge",    icon = "📈"},
            {id = "crash",    label = "Crash",    icon = "📉"},
            {id = "seasonal", label = "Sezon",    icon = "❄"},
            {id = "manual",   label = "Manual",   icon = "✋"},
        }
        local chipX = overlayX + 16
        local chipY = overlayY + 56
        for i, f in ipairs(filters) do
            local chipW = 80
            local isActive = (eventLogFilter == f.id)
            if isActive then
                local fc
                if f.id == "surge" then fc = {0.3, 0.6, 0.3}
                elseif f.id == "crash" then fc = {0.6, 0.3, 0.3}
                elseif f.id == "seasonal" then fc = {0.3, 0.4, 0.6}
                elseif f.id == "manual" then fc = {0.5, 0.5, 0.3}
                else fc = {0.4, 0.5, 0.7} end
                love.graphics.setColor(fc[1], fc[2], fc[3], 1)
            else
                love.graphics.setColor(0.2, 0.22, 0.26, 1)
            end
            love.graphics.rectangle("fill", chipX, chipY, chipW, 22, 3, 3, 3, 3)
            love.graphics.setColor(0.85, 0.88, 0.9, 1)
            if smallFont then love.graphics.setFont(smallFont) end
            love.graphics.print(string.format("%d: %s %s", i, f.icon, f.label), chipX + 6, chipY + 4)
            love.graphics.setFont(font)
            chipX = chipX + chipW + 6
        end

        -- Event list (filtered)
        local allEvents = DynamicMarket.getEventLog(50)
        local filteredEvents = {}
        for _, e in ipairs(allEvents) do
            if eventLogFilter == "all" or e.type == eventLogFilter then
                filteredEvents[#filteredEvents + 1] = e
            end
        end

        -- Column headers
        local listY = overlayY + 90
        local cols = {
            time = overlayX + 16,
            type = overlayX + 100,
            product = overlayX + 200,
            mult = overlayX + 440,
            source = overlayX + 540,
            desc = overlayX + 640,
        }
        love.graphics.setColor(0.3, 0.35, 0.45, 1)
        love.graphics.rectangle("fill", overlayX + 16, listY, overlayW - 32, 20, 3, 3, 3, 3)
        love.graphics.setColor(0.9, 0.9, 0.85, 1)
        if smallFont then love.graphics.setFont(smallFont) end
        love.graphics.print("STAROST", cols.time, listY + 4)
        love.graphics.print("TIP", cols.type, listY + 4)
        love.graphics.print("PRODUKT", cols.product, listY + 4)
        love.graphics.print("MULTIPL.", cols.mult, listY + 4)
        love.graphics.print("VIR", cols.source, listY + 4)
        love.graphics.print("OPIS", cols.desc, listY + 4)

        -- Event rows with scroll support
        local rowY = listY + 24
        local rowH = 14
        local listAreaH = overlayH - (rowY - overlayY) - 16
        local maxRows = math.floor(listAreaH / rowH)
        -- Clamp scroll offset to valid range
        local totalFiltered = #filteredEvents
        local maxScrollOffset = math.max(0, totalFiltered - maxRows)
        if eventLogScrollOffset > maxScrollOffset then
            eventLogScrollOffset = maxScrollOffset
        end
        if eventLogScrollOffset < 0 then
            eventLogScrollOffset = 0
        end
        local visibleCount = math.min(totalFiltered, maxRows)

        -- Clip rendering to list area (prevent overflow)
        local clipX, clipY, clipW, clipH = overlayX + 16, rowY, overlayW - 32, listAreaH
        love.graphics.setScissor(clipX, clipY, clipW, clipH)

        for i = 1, visibleCount do
            local eventIdx = i + eventLogScrollOffset
            local e = filteredEvents[eventIdx]
            if not e then break end
            local ry = rowY + (i - 1) * rowH
            -- Row background (alternating by absolute index)
            if eventIdx % 2 == 0 then
                love.graphics.setColor(0.15, 0.17, 0.22, 0.5)
                love.graphics.rectangle("fill", overlayX + 16, ry, overlayW - 32 - 14, rowH, 2, 2, 2, 2)
            end
            -- Age
            local age = ((love.timer and love.timer.getTime()) or 0) - e.t
            local ageStr
            if age < 60 then ageStr = string.format("%ds", math.floor(age))
            elseif age < 3600 then ageStr = string.format("%dm", math.floor(age / 60))
            else ageStr = string.format("%dh", math.floor(age / 3600)) end
            love.graphics.setColor(0.6, 0.65, 0.7, 1)
            love.graphics.print(ageStr, cols.time, ry + 1)

            -- Type with color
            local typeColor, typeIcon
            if e.type == "surge" then typeColor = {0.4, 0.95, 0.4, 1}; typeIcon = "📈"
            elseif e.type == "crash" then typeColor = {0.95, 0.4, 0.4, 1}; typeIcon = "📉"
            elseif e.type == "seasonal" then typeColor = {0.5, 0.7, 0.95, 1}; typeIcon = "❄"
            else typeColor = {0.85, 0.75, 0.5, 1}; typeIcon = "✋" end
            love.graphics.setColor(typeColor)
            love.graphics.print(string.format("%s %s", typeIcon, e.type), cols.type, ry + 1)

            -- Product
            love.graphics.setColor(0.85, 0.88, 0.9, 1)
            local ptName = e.productType or "?"
            if #ptName > 28 then ptName = ptName:sub(1, 27) .. "…" end
            love.graphics.print(ptName, cols.product, ry + 1)

            -- Multiplier
            love.graphics.setColor(typeColor)
            love.graphics.print(string.format("x%.2f", e.multiplier), cols.mult, ry + 1)

            -- Source
            love.graphics.setColor(0.6, 0.7, 0.8, 1)
            love.graphics.print(e.source or "?", cols.source, ry + 1)

            -- Description
            love.graphics.setColor(0.7, 0.72, 0.75, 1)
            local desc = e.description or ""
            if #desc > 30 then desc = desc:sub(1, 29) .. "…" end
            love.graphics.print(desc, cols.desc, ry + 1)
        end

        -- Reset scissor
        love.graphics.setScissor()

        -- Scrollbar (right side of list area)
        if totalFiltered > maxRows then
            local sbX = overlayX + overlayW - 28
            local sbY = rowY
            local sbW = 10
            local sbH = listAreaH
            -- Track
            love.graphics.setColor(0.1, 0.12, 0.16, 1)
            love.graphics.rectangle("fill", sbX, sbY, sbW, sbH, 3, 3, 3, 3)
            love.graphics.setColor(0.3, 0.35, 0.4, 1)
            love.graphics.rectangle("line", sbX, sbY, sbW, sbH, 3, 3, 3, 3)
            -- Thumb
            local thumbH = math.max(20, (maxRows / totalFiltered) * sbH)
            local thumbY = sbY + (eventLogScrollOffset / maxScrollOffset) * (sbH - thumbH)
            love.graphics.setColor(0.5, 0.6, 0.75, 0.9)
            love.graphics.rectangle("fill", sbX + 1, thumbY, sbW - 2, thumbH, 2, 2, 2, 2)
        end

        -- Footer: count info with scroll position
        love.graphics.setColor(0.5, 0.55, 0.6, 1)
        if smallFont then love.graphics.setFont(smallFont) end
        local footerStr
        if totalFiltered > maxRows then
            footerStr = string.format("Prikazano: %d-%d/%d dogodkov (filter: %s)  |  ↑↓/wheel: scroll  |  Home: top",
                eventLogScrollOffset + 1,
                math.min(eventLogScrollOffset + maxRows, totalFiltered),
                totalFiltered, eventLogFilter)
        else
            footerStr = string.format("Prikazano: %d/%d dogodkov (filter: %s)",
                visibleCount, totalFiltered, eventLogFilter)
        end
        love.graphics.print(footerStr, overlayX + 16, overlayY + overlayH - 20)
        love.graphics.setFont(font)
    end

    -- Table header
    y = y + 22
    local colXs = {
        productName = panelX + 24,
        base        = panelX + 380,
        sell        = panelX + 460,
        buy         = panelX + 540,
        modifier    = panelX + 620,
        sold        = panelX + 720,
        revenue     = panelX + 820,
        source      = panelX + 940,
    }
    love.graphics.setColor(0.3, 0.35, 0.45, 1)
    love.graphics.rectangle("fill", panelX + 16, y, panelW - 32, 22, 3, 3, 3, 3)
    love.graphics.setColor(0.9, 0.9, 0.85, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print("PRODUKT", colXs.productName, y + 5)
    love.graphics.print("OSNOVNA", colXs.base, y + 5)
    love.graphics.print("PRODAJA", colXs.sell, y + 5)
    love.graphics.print("KUPNJA", colXs.buy, y + 5)
    love.graphics.print("MODIFIC.", colXs.modifier, y + 5)
    love.graphics.print("PRODANO", colXs.sold, y + 5)
    love.graphics.print("PRIHODEK", colXs.revenue, y + 5)
    love.graphics.print("VIR", colXs.source, y + 5)
    love.graphics.setFont(font)

    -- Product rows
    y = y + 26
    local rowH = 20
    local startIdx = (page - 1) * pageSize + 1
    local endIdx = math.min(#cachedProducts, startIdx + pageSize - 1)
    -- v3.11.960: Clear and rebuild product row click areas for this frame
    productRowAreas = {}
    for i = startIdx, endIdx do
        local p = cachedProducts[i]
        local rowY = y + (i - startIdx) * rowH
        local isSelected = (i == selectedIndex)
        -- v3.11.960: Store click area for mousepressed
        productRowAreas[#productRowAreas + 1] = {
            x = panelX + 16, y = rowY, w = panelW - 32, h = rowH,
            productType = p.productType, source = p.source, index = i,
        }

        -- Row background
        if isSelected then
            love.graphics.setColor(0.3, 0.4, 0.55, 0.8)
            love.graphics.rectangle("fill", panelX + 16, rowY, panelW - 32, rowH, 2, 2, 2, 2)
        elseif (i - startIdx) % 2 == 0 then
            love.graphics.setColor(0.15, 0.17, 0.22, 0.5)
            love.graphics.rectangle("fill", panelX + 16, rowY, panelW - 32, rowH, 2, 2, 2, 2)
        end

        -- Determine price color (green = above base, red = below)
        local baseSell = math.floor(p.basePrice * 0.7 + 0.5)
        local priceColor = {0.85, 0.85, 0.85, 1}
        if p.currentSell > baseSell then
            priceColor = {0.4, 0.95, 0.4, 1}
        elseif p.currentSell < baseSell then
            priceColor = {0.95, 0.4, 0.4, 1}
        end

        love.graphics.setColor(0.85, 0.85, 0.85, 1)
        love.graphics.print(p.productType, colXs.productName, rowY + 3)
        -- Indicator if product is in comparison list
        if comparisonSet[p.productType] then
            -- Find index for color
            local compIdx = 1
            for ci, pt in ipairs(comparisonList) do
                if pt == p.productType then compIdx = ci; break end
            end
            local cc = COMPARISON_COLORS[((compIdx - 1) % #COMPARISON_COLORS) + 1]
            love.graphics.setColor(cc[1], cc[2], cc[3], 1)
            love.graphics.circle("fill", colXs.productName - 8, rowY + 9, 4)
        end
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.print(tostring(p.basePrice), colXs.base, rowY + 3)
        love.graphics.setColor(priceColor)
        love.graphics.print(tostring(p.currentSell), colXs.sell, rowY + 3)
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.print(tostring(p.currentBuy), colXs.buy, rowY + 3)

        -- Modifier % (deviation from base sell price)
        local modifierPct = 0
        local baseSell = math.floor(p.basePrice * 0.7 + 0.5)
        if baseSell > 0 then
            modifierPct = ((p.currentSell / baseSell) - 1) * 100
        end
        local modStr = string.format("%+d%%", math.floor(modifierPct + 0.5))
        if modifierPct > 5 then
            love.graphics.setColor(0.4, 0.95, 0.4, 1)
        elseif modifierPct < -5 then
            love.graphics.setColor(0.95, 0.4, 0.4, 1)
        else
            love.graphics.setColor(0.7, 0.7, 0.7, 1)
        end
        love.graphics.print(modStr, colXs.modifier, rowY + 3)

        love.graphics.setColor(0.85, 0.85, 0.85, 1)
        love.graphics.print(tostring(p.totalSold or 0), colXs.sold, rowY + 3)
        love.graphics.print(tostring(p.totalRevenue or 0), colXs.revenue, rowY + 3)
        love.graphics.setColor(0.55, 0.65, 0.75, 1)
        love.graphics.setFont(smallFont)
        love.graphics.print(tostring(p.source or "?"), colXs.source, rowY + 4)
        love.graphics.setFont(font)
    end

    -- Detail panel: comparison mode (multi-product) or single-product mode
    if comparisonMode and #comparisonList >= 2 then
        -- COMPARISON MODE: multi-line chart with normalized prices
        local detailH = 280
        local detailY = panelY + panelH - detailH - 20
        love.graphics.setColor(0.2, 0.25, 0.35, 1)
        love.graphics.rectangle("fill", panelX + 16, detailY, panelW - 32, detailH, 4, 4, 4, 4)
        love.graphics.setColor(0.9, 0.85, 0.5, 1)
        love.graphics.setFont(titleFont)
        love.graphics.print(string.format("📊 PRIMERJAVA CEN (%d produktov, normalizirano na base=100%%)",
            #comparisonList), panelX + 24, detailY + 8)
        love.graphics.setFont(font)

        -- Plot area (full width)
        local plotX = panelX + 56
        local plotY = detailY + 40
        local plotW = panelW - 32 - 80
        local plotH = detailH - 70

        -- Background
        love.graphics.setColor(0.1, 0.12, 0.16, 1)
        love.graphics.rectangle("fill", plotX, plotY, plotW, plotH, 3, 3, 3, 3)
        love.graphics.setColor(0.3, 0.35, 0.45, 1)
        love.graphics.rectangle("line", plotX, plotY, plotW, plotH, 3, 3, 3, 3)

        -- Y-axis: 0% to 200% (base = 100%)
        -- Reference line at 100% (base price)
        local baseY = plotY + plotH * 0.5  -- 100% at middle
        love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        for x = plotX, plotX + plotW, 6 do
            love.graphics.line(x, baseY, x + 3, baseY)
        end
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        if smallFont then love.graphics.setFont(smallFont) end
        love.graphics.print("100% (base)", panelX + 20, baseY - 6)
        love.graphics.print("200%", panelX + 20, plotY - 4)
        love.graphics.print("0%", panelX + 20, plotY + plotH - 8)

        -- X-axis time labels
        love.graphics.print("-60s", plotX, plotY + plotH + 4)
        love.graphics.print("-30s", plotX + plotW / 2 - 12, plotY + plotH + 4)
        love.graphics.print("now", plotX + plotW - 20, plotY + plotH + 4)

        -- Draw line for each product in comparison list
        -- Normalize: sellPrice / baseSellPrice * 100, range 0-200
        for idx, productType in ipairs(comparisonList) do
            local color = COMPARISON_COLORS[((idx - 1) % #COMPARISON_COLORS) + 1]
            local hist = DynamicMarket.getProductHistory(productType, 60)
            local baseSell = math.floor((DynamicMarket.getRoyalBasePrice(productType) or 1) * 0.7 + 0.5)
            if baseSell <= 0 then baseSell = 1 end

            if #hist >= 2 then
                love.graphics.setColor(color[1], color[2], color[3], 1)
                love.graphics.setLineWidth(2)
                local firstT = hist[1].t
                local lastT = hist[#hist].t
                local tRange = math.max(1, lastT - firstT)
                for i = 2, #hist do
                    local x1 = plotX + ((hist[i - 1].t - firstT) / tRange) * plotW
                    local pct1 = (hist[i - 1].sell / baseSell) * 100
                    local y1 = plotY + plotH - (pct1 / 200) * plotH
                    local x2 = plotX + ((hist[i].t - firstT) / tRange) * plotW
                    local pct2 = (hist[i].sell / baseSell) * 100
                    local y2 = plotY + plotH - (pct2 / 200) * plotH
                    love.graphics.line(x1, y1, x2, y2)
                end
                love.graphics.setLineWidth(1)
                -- End-point dot with current price label
                local last = hist[#hist]
                local pct = (last.sell / baseSell) * 100
                local ex = plotX + plotW
                local ey = plotY + plotH - (pct / 200) * plotH
                love.graphics.circle("fill", ex, ey, 3)
                love.graphics.print(string.format("%d%%", math.floor(pct + 0.5)), ex + 6, ey - 6)
            end
        end

        -- Legend (top-right)
        local legendX = plotX + plotW - 200
        local legendY = plotY + 6
        for idx, productType in ipairs(comparisonList) do
            local color = COMPARISON_COLORS[((idx - 1) % #COMPARISON_COLORS) + 1]
            local rowY = legendY + (idx - 1) * 12
            -- Color square
            love.graphics.setColor(color[1], color[2], color[3], 1)
            love.graphics.rectangle("fill", legendX, rowY + 2, 10, 10)
            -- Product name
            love.graphics.setColor(0.85, 0.88, 0.9, 1)
            local displayName = productType
            if #displayName > 18 then displayName = displayName:sub(1, 17) .. "…" end
            love.graphics.print(displayName, legendX + 14, rowY + 2)
        end

        if font then love.graphics.setFont(font) end
    elseif cachedProducts[selectedIndex] then
        -- SINGLE-PRODUCT MODE (existing detail panel with price + revenue charts)
        local p = cachedProducts[selectedIndex]
        local detailH = 280
        local detailY = panelY + panelH - detailH - 20
        love.graphics.setColor(0.2, 0.25, 0.35, 1)
        love.graphics.rectangle("fill", panelX + 16, detailY, panelW - 32, detailH, 4, 4, 4, 4)
        love.graphics.setColor(0.9, 0.85, 0.5, 1)
        love.graphics.setFont(titleFont)
        love.graphics.print("📦 " .. p.productType, panelX + 24, detailY + 8)
        love.graphics.setFont(font)

        -- Left column: text info
        local leftX = panelX + 24
        local leftW = 380
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        local baseSell = math.floor(p.basePrice * 0.7 + 0.5)
        local profit = p.currentSell - baseSell
        local stats = DynamicMarket.getProductHistoryStats(p.productType, 60)
        local lines = {
            string.format("Vir sistema: %s", p.source or "?"),
            string.format("Osnovna cena: %d zlata  |  Base sell: %d", p.basePrice, baseSell),
            string.format("Trenutna prodaja: %d  |  Kupnja: %d  |  Razlika: %+d",
                p.currentSell, p.currentBuy, profit),
            string.format("Skupaj prodano: %d kosov  |  Prihodek: %d zlata",
                p.totalSold or 0, p.totalRevenue or 0),
        }
        if stats then
            lines[#lines + 1] = string.format("Zadnja minuta: min %d  |  max %d  |  povp %d  |  trend %+d",
                stats.min, stats.max, math.floor(stats.avg + 0.5), stats.trend)
            lines[#lines + 1] = string.format("Vzorcev: %d  |  Stanje: %s",
                stats.sampleCount,
                stats.trend > 2 and "📈 raste" or (stats.trend < -2 and "📉 pada" or "➡ stabilno"))
        else
            lines[#lines + 1] = "(zbiranje zgodovine cen — počakaj 1-2 sekundi)"
        end
        lines[#lines + 1] = "Pritiski E za sprožitev naključnega tržnega dogodka (test)."
        for i, line in ipairs(lines) do
            love.graphics.print(line, leftX, detailY + 30 + (i - 1) * 14)
        end

        -- Right column: price history line chart
        local chartX = panelX + 16 + leftW + 20
        local chartY = detailY + 30
        local chartW = panelW - 32 - leftW - 40
        local chartH = detailH - 40

        -- Chart background
        love.graphics.setColor(0.1, 0.12, 0.16, 1)
        love.graphics.rectangle("fill", chartX, chartY, chartW, chartH, 3, 3, 3, 3)
        love.graphics.setColor(0.3, 0.35, 0.45, 1)
        love.graphics.rectangle("line", chartX, chartY, chartW, chartH, 3, 3, 3, 3)

        -- Chart title
        love.graphics.setColor(0.7, 0.8, 0.95, 1)
        love.graphics.setFont(smallFont)
        love.graphics.print("Zgodovina cene (zadnjih 60s)", chartX + 8, chartY + 6)

        -- Get price history
        local hist = DynamicMarket.getProductHistory(p.productType, 60)
        if #hist >= 2 then
            -- Compute scaling
            local minPrice, maxPrice = nil, nil
            for _, e in ipairs(hist) do
                if minPrice == nil or e.sell < minPrice then minPrice = e.sell end
                if maxPrice == nil or e.sell > maxPrice then maxPrice = e.sell end
            end
            -- Include base sell in range for reference
            if baseSell then
                if minPrice == nil or baseSell < minPrice then minPrice = baseSell end
                if maxPrice == nil or baseSell > maxPrice then maxPrice = baseSell end
            end
            -- Add 10% padding
            local range = maxPrice - minPrice
            if range < 1 then range = 1 end
            minPrice = minPrice - range * 0.1
            maxPrice = maxPrice + range * 0.1
            local drawRange = maxPrice - minPrice

            -- Plot area (inset)
            local padX, padTop, padBottom = 32, 22, 14
            local plotX = chartX + padX
            local plotY = chartY + padTop
            local plotW = chartW - padX - 8
            local plotH = chartH - padTop - padBottom

            -- Y-axis labels (min, max)
            love.graphics.setColor(0.5, 0.55, 0.6, 1)
            love.graphics.setFont(smallFont)
            love.graphics.print(tostring(math.floor(maxPrice)), chartX + 4, plotY - 4)
            love.graphics.print(tostring(math.floor(minPrice)), chartX + 4, plotY + plotH - 8)

            -- Base price reference line (dashed)
            if baseSell >= minPrice and baseSell <= maxPrice then
                local baseY = plotY + plotH - ((baseSell - minPrice) / drawRange) * plotH
                love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
                for x = plotX, plotX + plotW, 6 do
                    love.graphics.line(x, baseY, x + 3, baseY)
                end
                love.graphics.setColor(0.6, 0.6, 0.6, 1)
                love.graphics.print("base", chartX + 4, baseY - 6)
            end

            -- Plot sell price line
            love.graphics.setColor(0.4, 0.95, 0.4, 1)
            love.graphics.setLineWidth(2)
            local now = love.timer.getTime()
            local firstT = hist[1].t
            local lastT = hist[#hist].t
            local tRange = math.max(1, lastT - firstT)
            for i = 2, #hist do
                local x1 = plotX + ((hist[i - 1].t - firstT) / tRange) * plotW
                local y1 = plotY + plotH - ((hist[i - 1].sell - minPrice) / drawRange) * plotH
                local x2 = plotX + ((hist[i].t - firstT) / tRange) * plotW
                local y2 = plotY + plotH - ((hist[i].sell - minPrice) / drawRange) * plotH
                love.graphics.line(x1, y1, x2, y2)
            end
            love.graphics.setLineWidth(1)

            -- Also draw buy price line (dimmer)
            love.graphics.setColor(0.5, 0.6, 0.95, 0.6)
            love.graphics.setLineWidth(1)
            for i = 2, #hist do
                local x1 = plotX + ((hist[i - 1].t - firstT) / tRange) * plotW
                local y1 = plotY + plotH - ((hist[i - 1].buy - minPrice) / drawRange) * plotH
                local x2 = plotX + ((hist[i].t - firstT) / tRange) * plotW
                local y2 = plotY + plotH - ((hist[i].buy - minPrice) / drawRange) * plotH
                love.graphics.line(x1, y1, x2, y2)
            end

            -- Legend
            love.graphics.setFont(smallFont)
            love.graphics.setColor(0.4, 0.95, 0.4, 1)
            love.graphics.print("● sell", chartX + chartW - 80, chartY + 6)
            love.graphics.setColor(0.5, 0.6, 0.95, 1)
            love.graphics.print("● buy", chartX + chartW - 40, chartY + 6)
            love.graphics.setFont(font)
        else
            love.graphics.setColor(0.5, 0.5, 0.55, 1)
            love.graphics.setFont(smallFont)
            love.graphics.print("Čakam na vzorce...", chartX + 10, chartY + chartH / 2)
            love.graphics.setFont(font)
        end

        -- Revenue chart (below price chart, on the right column)
        -- Shows per-second gold earned for this product over the last 60s
        local revChartY = chartY + chartH + 10
        local revChartH = 80
        -- Background
        love.graphics.setColor(0.1, 0.12, 0.16, 1)
        love.graphics.rectangle("fill", chartX, revChartY, chartW, revChartH, 3, 3, 3, 3)
        love.graphics.setColor(0.3, 0.35, 0.45, 1)
        love.graphics.rectangle("line", chartX, revChartY, chartW, revChartH, 3, 3, 3, 3)
        -- Title
        love.graphics.setColor(0.95, 0.85, 0.4, 1)
        if smallFont then love.graphics.setFont(smallFont) end
        love.graphics.print("💰 Prihodek od prodaje (zadnjih 60s)", chartX + 8, revChartY + 6)

        local revBuckets = RMI.getProductSalesBuckets(p.productType, 60)
        if revBuckets and revBuckets.maxGold > 0 and revBuckets.totalGold > 0 then
            -- Plot area
            local rpadX, rpadTop, rpadBottom = 36, 22, 14
            local rplotX = chartX + rpadX
            local rplotY = revChartY + rpadTop
            local rplotW = chartW - rpadX - 8
            local rplotH = revChartH - rpadTop - rpadBottom

            -- Y-axis labels (max gold and 0)
            love.graphics.setColor(0.5, 0.55, 0.6, 1)
            love.graphics.print(tostring(revBuckets.maxGold), chartX + 4, rplotY - 4)
            love.graphics.print("0", chartX + 4, rplotY + rplotH - 8)

            -- Bar chart of gold per second
            local rbarW = rplotW / 60
            for i = 1, 60 do
                local b = revBuckets.buckets[i]
                if b and b.gold > 0 then
                    local h = (b.gold / revBuckets.maxGold) * rplotH
                    local bx = rplotX + (i - 1) * rbarW
                    local by = rplotY + rplotH - h
                    -- Gold-yellow bars; brighter for more recent
                    local recency = (60 - (i - 1)) / 60
                    love.graphics.setColor(0.85, 0.7 + recency * 0.25, 0.2 + recency * 0.2, 0.85)
                    love.graphics.rectangle("fill", bx + 0.5, by, math.max(1, rbarW - 1), h)
                end
            end

            -- X-axis time labels
            love.graphics.setColor(0.5, 0.55, 0.6, 1)
            love.graphics.print("-60s", rplotX, rplotY + rplotH + 2)
            love.graphics.print("-30s", rplotX + rplotW / 2 - 12, rplotY + rplotH + 2)
            love.graphics.print("now", rplotX + rplotW - 20, rplotY + rplotH + 2)

            -- Stats line above chart (right-aligned)
            local revStatsStr = string.format(
                "Skupaj: %d zlata  |  %d kosov  |  Povp. cena/kos: %.0f",
                revBuckets.totalGold, revBuckets.totalQty, revBuckets.avgUnitPrice
            )
            love.graphics.setColor(0.85, 0.8, 0.5, 1)
            local revStatsW = smallFont:getWidth(revStatsStr)
            love.graphics.print(revStatsStr, chartX + chartW - 8 - revStatsW, revChartY + 6)
        else
            love.graphics.setColor(0.5, 0.5, 0.55, 1)
            love.graphics.print("(ni prodaje — uporabi 'Prodaj na trgu' v Royal panelu)",
                chartX + 10, revChartY + revChartH / 2 - 4)
        end
        if font then love.graphics.setFont(font) end
    end

    -- Action feedback message
    if actionMessage ~= "" then
        love.graphics.setColor(0, 0, 0, 0.7)
        local msgW = font:getWidth(actionMessage) + 20
        love.graphics.rectangle("fill", panelX + (panelW - msgW) / 2, panelY + panelH - 36, msgW, 24, 4, 4, 4, 4)
        love.graphics.setColor(1, 0.95, 0.7, 1)
        love.graphics.print(actionMessage, panelX + (panelW - font:getWidth(actionMessage)) / 2, panelY + panelH - 30)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function MarketDashboard.keypressed(key, scancode, isrepeat)
    if not visible then return false end

    -- Ctrl+K toggles off
    if key == "k" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        MarketDashboard.toggle()
        return true
    end

    -- Escape: close panel or exit search
    if key == "escape" then
        if searchActive then
            searchActive = false
            searchQuery = ""
            MarketDashboard.refresh()
        else
            MarketDashboard.toggle()
        end
        return true
    end

    -- Search activation
    if key == "/" and not searchActive then
        searchActive = true
        searchQuery = ""
        return true
    end

    -- Enter confirms search (exits search mode but keeps query)
    if key == "return" and searchActive then
        searchActive = false
        return true
    end

    -- Backspace in search mode
    if searchActive and key == "backspace" then
        searchQuery = searchQuery:sub(1, -2)
        page = 1
        selectedIndex = 1
        MarketDashboard.refresh()
        return true
    end

    -- Cycle sort mode with S
    if key == "s" and not searchActive then
        local modes = {"alpha", "sold", "revenue", "volatile", "price"}
        for i, m in ipairs(modes) do
            if m == sortMode then
                sortMode = modes[(i % #modes) + 1]
                break
            end
        end
        page = 1
        selectedIndex = 1
        MarketDashboard.refresh()
        showMessage("Sortiranje: " .. sortModes[sortMode])
        return true
    end

    -- Trigger random event on selected product
    if key == "e" and not searchActive then
        local p = cachedProducts[selectedIndex]
        if p then
            -- Random: either crash (-30%) or surge (+40%) for 60s
            local multiplier = math.random() < 0.5 and 0.7 or 1.4
            DynamicMarket.triggerEvent(p.productType, multiplier, 60)
            showMessage(string.format("Dogodek na %s: cena x%.2f za 60s", p.productType, multiplier))
        end
        return true
    end

    -- Toggle leaderboard mode: qty <-> profit
    if key == "q" and not searchActive then
        if leaderboardMode == "qty" then
            leaderboardMode = "profit"
            showMessage("Leaderboard: TOP-10 PO PRIHODKU (gold)")
        else
            leaderboardMode = "qty"
            showMessage("Leaderboard: TOP-10 PRODUCENTOV (količina)")
        end
        return true
    end

    -- SPACE: toggle current product in comparison list
    if key == "space" and not searchActive then
        local p = cachedProducts[selectedIndex]
        if p then
            if comparisonSet[p.productType] then
                -- Remove from comparison
                comparisonSet[p.productType] = nil
                for i, pt in ipairs(comparisonList) do
                    if pt == p.productType then
                        table.remove(comparisonList, i)
                        break
                    end
                end
                showMessage(string.format("Odstranjeno iz primerjave: %s (%d ostaja)",
                    p.productType, #comparisonList))
            else
                -- Add to comparison (respect max limit)
                if #comparisonList >= comparisonMaxItems then
                    showMessage(string.format("Primerjava polna (max %d) — odstrani drug produkt", comparisonMaxItems))
                else
                    comparisonSet[p.productType] = true
                    comparisonList[#comparisonList + 1] = p.productType
                    showMessage(string.format("Dodano v primerjavo: %s (%d skupaj)",
                        p.productType, #comparisonList))
                end
            end
        end
        return true
    end

    -- C: toggle comparison mode (show comparison chart instead of single-product detail)
    if key == "c" and not searchActive then
        if #comparisonList < 2 then
            showMessage("Dodaj vsaj 2 produkta v primerjavo (SPACE) preden vklopiš način primerjave")
        else
            comparisonMode = not comparisonMode
            showMessage(comparisonMode and
                string.format("Način primerjave: ON (%d produktov)", #comparisonList) or
                "Način primerjave: OFF")
        end
        return true
    end

    -- X: clear comparison list
    if key == "x" and not searchActive and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        comparisonList = {}
        comparisonSet = {}
        comparisonMode = false
        showMessage("Primerjava počiščena")
        return true
    end

    -- V: toggle event log expanded panel
    if key == "v" and not searchActive then
        eventLogExpanded = not eventLogExpanded
        eventLogScrollOffset = 0  -- reset scroll on open
        showMessage(eventLogExpanded and "Zgodovina dogodkov: ON" or "Zgodovina dogodkov: OFF")
        return true
    end

    -- 1-5: set event log filter (only when expanded)
    if eventLogExpanded and not searchActive then
        local filters = {"all", "surge", "crash", "seasonal", "manual"}
        local filterLabels = {"Vsi", "Surge", "Crash", "Sezon", "Manual"}
        for i, f in ipairs(filters) do
            if key == tostring(i) then
                eventLogFilter = f
                eventLogScrollOffset = 0  -- reset scroll on filter change
                showMessage("Filter: " .. filterLabels[i])
                return true
            end
        end
        -- Up/Down/PageUp/PageDown for scrolling
        if key == "up" then
            eventLogScrollOffset = math.max(0, eventLogScrollOffset - 1)
            return true
        end
        if key == "down" then
            eventLogScrollOffset = eventLogScrollOffset + 1  -- clamped in draw
            return true
        end
        if key == "pageup" then
            eventLogScrollOffset = math.max(0, eventLogScrollOffset - 10)
            return true
        end
        if key == "pagedown" then
            eventLogScrollOffset = eventLogScrollOffset + 10  -- clamped in draw
            return true
        end
        if key == "home" then
            eventLogScrollOffset = 0
            return true
        end
    end

    -- Pagination
    if key == "left" or key == "a" then
        if not searchActive then
            page = math.max(1, page - 1)
            selectedIndex = (page - 1) * pageSize + 1
            MarketDashboard.refresh()
            return true
        end
    end
    if key == "right" or key == "d" then
        if not searchActive then
            page = math.min(totalPages, page + 1)
            selectedIndex = (page - 1) * pageSize + 1
            MarketDashboard.refresh()
            return true
        end
    end

    -- Up/Down navigation
    if key == "up" and not searchActive then
        if selectedIndex > 1 then
            selectedIndex = selectedIndex - 1
            -- If we go above page start, go to previous page
            local startIdx = (page - 1) * pageSize + 1
            if selectedIndex < startIdx then
                page = math.max(1, page - 1)
                MarketDashboard.refresh()
            end
        end
        return true
    end
    if key == "down" and not searchActive then
        if selectedIndex < #cachedProducts then
            selectedIndex = selectedIndex + 1
            local endIdx = math.min(#cachedProducts, page * pageSize)
            if selectedIndex > endIdx then
                page = math.min(totalPages, page + 1)
                MarketDashboard.refresh()
            end
        end
        return true
    end

    return false
end

function MarketDashboard.textinput(text)
    if not visible then return false end
    if searchActive then
        -- Only accept printable characters
        if text:match("^[%w _-]$") then
            searchQuery = searchQuery .. text
            page = 1
            selectedIndex = 1
            MarketDashboard.refresh()
        end
        return true
    end
    return false
end

-- Mouse wheel handler for event log scrolling
function MarketDashboard.wheelmoved(x, y)
    if not visible then return false end
    if not eventLogExpanded then return false end
    -- y > 0: scroll up, y < 0: scroll down
    if y > 0 then
        eventLogScrollOffset = math.max(0, eventLogScrollOffset - 3)
        return true
    elseif y < 0 then
        eventLogScrollOffset = eventLogScrollOffset + 3  -- clamped in draw
        return true
    end
    return false
end

function MarketDashboard.mousepressed(x, y, button, istouch, presses)
    if not visible then return false end
    -- Click outside panel closes
    local W = love.graphics.getWidth()
    local H = love.graphics.getHeight()
    local panelW = math.min(1100, W - 80)
    local panelH = math.min(720, H - 80)
    local panelX = (W - panelW) / 2
    local panelY = (H - panelH) / 2
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        MarketDashboard.toggle()
        return true
    end
    -- v3.11.960: Check product row clicks for selection + double-click jump
    if button == 1 then
        for _, area in ipairs(productRowAreas) do
            if x >= area.x and x <= area.x + area.w
               and y >= area.y and y <= area.y + area.h then
                -- Set selectedIndex to clicked row
                selectedIndex = area.index
                -- Check for double-click
                local now = love.timer.getTime()
                if lastClickProductType == area.productType
                   and (now - lastClickTime) < DOUBLE_CLICK_THRESHOLD then
                    -- Double-click: jump to Royal Systems Panel on the source system
                    local RoyalPanel = require("states.ui.hud.royal_systems_panel")
                    if not RoyalPanel.isVisible() then
                        RoyalPanel.toggle()
                    end
                    RoyalPanel.jumpToSystem(area.source)
                    -- Close Market Dashboard to show Royal Systems Panel
                    MarketDashboard.toggle()
                    lastClickTime = 0
                    lastClickProductType = nil
                else
                    -- Single click: record for double-click detection
                    lastClickTime = now
                    lastClickProductType = area.productType
                end
                return true
            end
        end
    end
    return false
end

-- ============================================================================
-- SAVE / LOAD PERSISTENCE
-- ============================================================================

-- Serialize current comparison list state for saving.
-- Returns a table that can be stored in save file via bitser.
function MarketDashboard.serialize()
    return {
        comparisonList = comparisonList,
        comparisonMode = comparisonMode,
        leaderboardMode = leaderboardMode,
        sortMode = sortMode,
    }
end

-- Deserialize comparison list state from a saved table.
-- Called after Market Dashboard has been loaded; restores player's selection.
function MarketDashboard.deserialize(data)
    if not data then return end
    -- Restore comparison list (validate types to prevent save corruption)
    if type(data.comparisonList) == "table" then
        comparisonList = {}
        comparisonSet = {}
        for _, pt in ipairs(data.comparisonList) do
            if type(pt) == "string" and #pt > 0 and #comparisonList < comparisonMaxItems then
                comparisonList[#comparisonList + 1] = pt
                comparisonSet[pt] = true
            end
        end
    end
    if type(data.comparisonMode) == "boolean" then
        comparisonMode = data.comparisonMode
        -- Sanity: if comparisonMode is true but list has < 2 items, disable
        if comparisonMode and #comparisonList < 2 then
            comparisonMode = false
        end
    end
    if type(data.leaderboardMode) == "string" and
       (data.leaderboardMode == "qty" or data.leaderboardMode == "profit") then
        leaderboardMode = data.leaderboardMode
    end
    if type(data.sortMode) == "string" and sortModes[data.sortMode] then
        sortMode = data.sortMode
    end
    print(string.format("[MarketDashboard] Deserialized: %d comparison items, mode=%s, lbMode=%s, sort=%s",
        #comparisonList, tostring(comparisonMode), leaderboardMode, sortMode))
end

-- Castle Kingdoms 2027 v3.11.937: Mouse moved/released stubs for consistency
-- Currently Market Dashboard is click-only (no drag interactions),
-- but these stubs allow game.lua to forward events without nil checks.
function MarketDashboard.mousemoved(x, y, dx, dy)
    return false
end

function MarketDashboard.mousereleased(x, y, button)
    return false
end

return MarketDashboard
