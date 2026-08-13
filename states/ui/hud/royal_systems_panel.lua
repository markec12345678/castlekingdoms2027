-- states/ui/hud/royal_systems_panel.lua
-- Castle Kingdoms 2027 - Royal Systems Panel (v2: Search + Categories)
--
-- Full-screen overlay panel showing all "Royal X Maker" systems discovered
-- by RoyalSystemsRegistry. Allows the player to:
--   * Browse all systems with SEARCH and CATEGORY filtering
--   * View stats for each system
--   * Hire a maker, build workshop, queue product, sell stock
--
-- Toggle with Ctrl+R. Press / to search. Press Tab to cycle categories.

local Registry = require("objects.Economy.RoyalSystemsRegistry")
local RMI = require("objects.Economy.RoyalMarketIntegration")

local RoyalPanel = {}

local visible = false
local selectedIndex = 1
local page = 1
local pageSize = 20
local totalPages = 1
local actionMessage = ""
local actionMessageTime = 0

-- Search & filter state
local searchQuery = ""
local searchActive = false
local activeCategory = "all"  -- "all", "glass", "foundry", "bookbinding", "blacksmith", "garden", "milling", "other"

-- Cached filtered list (rebuilt on search/category change)
local filteredSystems = {}

-- Category definitions: keyword patterns to match against system name
local CATEGORIES = {
    { id = "all",         label = "Vsi",       color = {0.78, 0.62, 0.28} },
    { id = "glass",       label = "Steklar",   color = {0.3, 0.7, 0.9} },
    { id = "foundry",     label = "Livar",     color = {0.9, 0.5, 0.2} },
    { id = "bookbinding", label = "Knjigovez", color = {0.7, 0.5, 0.8} },
    { id = "blacksmith",  label = "Kovač",     color = {0.8, 0.4, 0.3} },
    { id = "garden",      label = "Vrtnar",    color = {0.4, 0.8, 0.3} },
    { id = "milling",     label = "Mlinar",    color = {0.8, 0.75, 0.3} },
    { id = "other",       label = "Ostalo",    color = {0.6, 0.6, 0.6} },
}

-- Keywords for category detection (checked against system name, case-insensitive)
local CATEGORY_KEYWORDS = {
    glass       = { "Glass", "Stekl" },
    foundry     = { "Mold", "Pouring", "Sand", "Core", "Casting", "Flask", "Crucible", "Ingot", "Slag", "Sprue", "Riser", "Vent", "Muller", "Quench", "Slack", "Bell", "Annealing" },
    bookbinding = { "Book", "Parchment", "Manuscript", "Chronicle", "Codex", "Scroll", "Ink", "Quill", "Pen", "Writing", "Pigment", "Stamp", "Seal", "Folio", "Leaf", "Vellum" },
    blacksmith  = { "Forge", "Anvil", "Hammer", "Tongs", "Smith", "Bellows", "Pickaxe", "Shovel", "Nail", "Chain", "Bolt", "Sword", "Shield", "Armor", "Hardy", "Fuller", "Flatter", "Clinker", "Coal", "Pritchel", "Bick", "Slack" },
    garden      = { "Garden", "Plant", "Hedge", "Lawn", "Trellis", "Compost", "Pruning", "Soil", "Seed", "Frost", "Mulch", "Furrow", "Dibber", "Cloche", "Sieve", "Sprayer", "Border", "Watering", "Wheelbarrow", "Bowl", "Hoe", "Trowel", "Rake", "Fork", "Secateurs", "Shears", "Aerator", "Kneeler", "Tie", "Climb", "Label", "Thermometer", "Irrigation", "Pot", "Root", "Packet", "Spike", "Screen", "Panel", "Transplant", "Dibber" },
    milling     = { "Mill", "Grain", "Flour", "Hopper", "Millstone", "Sail", "Bran", "Auger", "Sack", "Probe" },
}

-- Detect category from system name
local function detectCategory(name)
    for cat, keywords in pairs(CATEGORY_KEYWORDS) do
        for _, kw in ipairs(keywords) do
            if name:find(kw, 1, true) then
                return cat
            end
        end
    end
    return "other"
end

-- Rebuild filteredSystems based on search query and active category
local function rebuildFiltered()
    local allSystems = Registry.getSystems()
    filteredSystems = {}

    local query = searchQuery:lower()
    for _, sys in ipairs(allSystems) do
        -- Category filter
        if activeCategory ~= "all" then
            local cat = detectCategory(sys.name)
            if cat ~= activeCategory then
                goto continue
            end
        end
        -- Search filter
        if query ~= "" then
            if not sys.name:lower():find(query, 1, true) then
                goto continue
            end
        end
        table.insert(filteredSystems, sys)
        ::continue::
    end

    -- Sort alphabetically by name
    table.sort(filteredSystems, function(a, b) return a.name < b.name end)

    -- Reset pagination
    totalPages = math.max(1, math.ceil(#filteredSystems / pageSize))
    if page > totalPages then page = totalPages end
    if selectedIndex > #filteredSystems then selectedIndex = 1 end
    page = math.max(1, math.ceil(selectedIndex / pageSize))
end

-- UI layout
local LAYOUT = {
    panelW = 1000,
    panelH = 680,
    listW = 300,
    detailPad = 16,
}

-- Helper: safely call a system function and show feedback
local function tryAction(fn, ...)
    local ok, err = pcall(fn, ...)
    if ok and err ~= false then
        actionMessage = "OK: " .. tostring(err or "")
        actionMessageTime = 3.0
        return true
    elseif ok then
        actionMessage = "Napaka: " .. tostring(err or "Neznana")
        actionMessageTime = 3.0
        return false, err
    else
        actionMessage = "Izjema: " .. tostring(err or "Neznana")
        actionMessageTime = 3.0
        return false, err
    end
end

function RoyalPanel.toggle()
    visible = not visible
    if visible then
        rebuildFiltered()
    end
end

function RoyalPanel.setVisible(state)
    visible = state
end

function RoyalPanel.isVisible()
    return visible
end

function RoyalPanel.update(dt)
    if actionMessageTime > 0 then
        actionMessageTime = actionMessageTime - dt
        if actionMessageTime <= 0 then
            actionMessage = ""
        end
    end
end

-- Mouse click areas (rebuilt each draw)
local clickAreas = {}

local function registerClick(id, x, y, w, h, action)
    table.insert(clickAreas, { id = id, x = x, y = y, w = w, h = h, action = action })
end

-- Helper: draw a button, returns true if hovered
local function drawButton(id, x, y, w, h, label, enabled, action)
    enabled = enabled ~= false
    local mx, my = love.mouse.getPosition()
    local hover = enabled and mx >= x and mx <= x + w and my >= y and my <= y + h

    if not enabled then
        love.graphics.setColor(0.25, 0.22, 0.18, 0.85)
    elseif hover then
        love.graphics.setColor(0.42, 0.34, 0.22, 0.95)
    else
        love.graphics.setColor(0.32, 0.26, 0.18, 0.92)
    end
    love.graphics.rectangle("fill", x, y, w, h, 4, 4, 4, 4)

    love.graphics.setColor(0.6, 0.5, 0.3, enabled and 1 or 0.4)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, w, h, 4, 4, 4, 4)

    love.graphics.setColor(enabled and 1 or 0.5, enabled and 0.92 or 0.5, enabled and 0.7 or 0.5, 1)
    local font = love.graphics.getFont()
    local tw = font:getWidth(label)
    local th = font:getHeight()
    love.graphics.print(label, x + (w - tw) / 2, y + (h - th) / 2)

    if enabled and action then
        registerClick(id, x, y, w, h, action)
    end

    return hover
end

-- Draw a category tab button
local function drawCategoryTab(id, x, y, w, h, label, catColor, isActive, action)
    local mx, my = love.mouse.getPosition()
    local hover = mx >= x and mx <= x + w and my >= y and my <= y + h

    if isActive then
        love.graphics.setColor(catColor[1] * 0.5, catColor[2] * 0.5, catColor[3] * 0.5, 0.95)
    elseif hover then
        love.graphics.setColor(catColor[1] * 0.3, catColor[2] * 0.3, catColor[3] * 0.3, 0.8)
    else
        love.graphics.setColor(0.15, 0.12, 0.08, 0.7)
    end
    love.graphics.rectangle("fill", x, y, w, h, 3, 3, 3, 3)

    love.graphics.setColor(catColor[1], catColor[2], catColor[3], isActive and 1 or 0.6)
    love.graphics.setLineWidth(isActive and 2 or 1)
    love.graphics.rectangle("line", x, y, w, h, 3, 3, 3, 3)

    love.graphics.setColor(isActive and 1 or 0.7, isActive and 1 or 0.7, isActive and 1 or 0.7, 1)
    local font = love.graphics.getFont()
    local tw = font:getWidth(label)
    love.graphics.print(label, x + (w - tw) / 2, y + 3)

    if action then
        registerClick(id, x, y, w, h, action)
    end
end

function RoyalPanel.draw()
    if not visible then return end

    clickAreas = {}

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = math.min(LAYOUT.panelW, screenW - 40)
    local panelH = math.min(LAYOUT.panelH, screenH - 40)
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    -- Panel
    love.graphics.setColor(0.08, 0.06, 0.04, 0.98)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Border (royal gold)
    love.graphics.setColor(0.78, 0.62, 0.28, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Title
    love.graphics.setColor(1, 0.92, 0.7, 1)
    local font = love.graphics.getFont()
    love.graphics.print("Kraljevi sistemski (Royal Systems)", panelX + 20, panelY + 10)
    love.graphics.setColor(0.7, 0.6, 0.4, 1)
    love.graphics.print("Ctrl+R: Zapri  |  /: Iskanje  |  Tab: Kategorije", panelX + panelW - 310, panelY + 10)

    -- Aggregate stats bar
    local agg = Registry.getAggregate()
    love.graphics.setColor(0.6, 0.5, 0.3, 0.4)
    love.graphics.setLineWidth(1)
    love.graphics.line(panelX + 20, panelY + 34, panelX + panelW - 20, panelY + 34)

    local statsText = string.format(
        "Sistemov: %d  |  Zgradb: %d  |  Mojstrov: %d  |  Produktov: %d  |  V izdelavi: %d  |  Bonus zlato: %d",
        agg.totalSystems or 0, agg.totalBuildings or 0, agg.totalMakers or 0,
        agg.totalProducts or 0, agg.totalActiveMaking or 0, agg.totalGoldEarned or 0
    )
    love.graphics.setColor(0.85, 0.85, 0.85, 1)
    love.graphics.print(statsText, panelX + 20, panelY + 40)

    -- Category tabs row
    local catY = panelY + 60
    local catH = 20
    local catW = 70
    local catGap = 4
    local catStartX = panelX + 16
    for i, cat in ipairs(CATEGORIES) do
        local cx = catStartX + (i - 1) * (catW + catGap)
        drawCategoryTab("cat_" .. cat.id, cx, catY, catW, catH, cat.label, cat.color,
            activeCategory == cat.id,
            function()
                activeCategory = cat.id
                page = 1
                selectedIndex = 1
                rebuildFiltered()
            end)
    end

    -- Search box
    local searchX = panelX + panelW - 220
    local searchY = catY
    local searchW = 200
    local searchH = catH
    love.graphics.setColor(searchActive and 0.3 or 0.15, searchActive and 0.25 or 0.12, 0.08, 0.9)
    love.graphics.rectangle("fill", searchX, searchY, searchW, searchH, 3, 3, 3, 3)
    love.graphics.setColor(searchActive and 0.9 or 0.5, searchActive and 0.8 or 0.4, 0.3, 1)
    love.graphics.setLineWidth(searchActive and 2 or 1)
    love.graphics.rectangle("line", searchX, searchY, searchW, searchH, 3, 3, 3, 3)

    local displayQuery = searchQuery
    if searchActive then displayQuery = displayQuery .. "_" end
    love.graphics.setColor(0.9, 0.9, 0.85, 1)
    love.graphics.print("Iskanje: " .. displayQuery, searchX + 8, searchY + 3)
    registerClick("searchBox", searchX, searchY, searchW, searchH,
        function() searchActive = true end)

    -- Two-column layout
    local listX = panelX + 16
    local listY = catY + catH + 8
    local listW = LAYOUT.listW
    local listH = panelH - (listY - panelY) - 50

    local detailX = listX + listW + 16
    local detailY = listY
    local detailW = panelW - listW - 48
    local detailH = listH

    -- Left column: list of systems (filtered + paginated)
    love.graphics.setColor(0.15, 0.12, 0.08, 0.7)
    love.graphics.rectangle("fill", listX, listY, listW, listH, 4, 4, 4, 4)
    love.graphics.setColor(0.5, 0.4, 0.25, 0.6)
    love.graphics.rectangle("line", listX, listY, listW, listH, 4, 4, 4, 4)

    -- Use filtered systems
    local systems = filteredSystems
    totalPages = math.max(1, math.ceil(#systems / pageSize))

    -- Result count
    love.graphics.setColor(0.7, 0.7, 0.6, 1)
    love.graphics.print(string.format("Rezultati: %d", #systems), listX + 8, listY + 6)

    -- Page navigation buttons
    drawButton("prevPage", listX + listW - 60, listY + 4, 24, 20, "<", page > 1,
        function() page = page - 1; if page < 1 then page = 1 end; selectedIndex = (page - 1) * pageSize + 1 end)
    love.graphics.setColor(0.85, 0.85, 0.85, 1)
    love.graphics.print(string.format("%d/%d", page, totalPages), listX + listW - 34, listY + 7)
    drawButton("nextPage", listX + listW - 12, listY + 4, 24, 20, ">", page < totalPages,
        function() page = page + 1; if page > totalPages then page = totalPages end; selectedIndex = (page - 1) * pageSize + 1 end)

    -- System list
    local itemY = listY + 30
    local itemH = 20
    local startIdx = (page - 1) * pageSize + 1
    local endIdx = math.min(startIdx + pageSize - 1, #systems)

    for i = startIdx, endIdx do
        local sys = systems[i]
        if not sys then break end
        local stats = sys.module.getStats()
        local isSelected = i == selectedIndex
        local hasBuilding = (stats.numBuildings or 0) > 0
        local hasMaker = stats.hasMaker

        local rowY = itemY + (i - startIdx) * itemH
        -- Row background
        if isSelected then
            love.graphics.setColor(0.45, 0.36, 0.2, 0.9)
        elseif hasBuilding and hasMaker then
            love.graphics.setColor(0.2, 0.3, 0.18, 0.5)
        else
            love.graphics.setColor(0.12, 0.1, 0.08, 0.4)
        end
        love.graphics.rectangle("fill", listX + 4, rowY, listW - 8, itemH - 2, 2, 2, 2, 2)

        -- Status indicator dot
        if hasBuilding and hasMaker then
            love.graphics.setColor(0.3, 1, 0.3, 1)
        elseif hasBuilding or hasMaker then
            love.graphics.setColor(1, 0.85, 0.3, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        end
        love.graphics.circle("fill", listX + 12, rowY + (itemH - 2) / 2, 3)

        -- Category color stripe
        local cat = detectCategory(sys.name)
        local catDef = nil
        for _, c in ipairs(CATEGORIES) do
            if c.id == cat then catDef = c break end
        end
        if catDef then
            love.graphics.setColor(catDef.color[1], catDef.color[2], catDef.color[3], 0.7)
            love.graphics.rectangle("fill", listX + 4, rowY, 3, itemH - 2)
        end

        -- Name
        love.graphics.setColor(1, 1, 1, 0.92)
        local displayName = sys.name
        if #displayName > 24 then displayName = displayName:sub(1, 22) .. ".." end
        love.graphics.print(displayName, listX + 20, rowY + 3)

        -- Mini stats
        love.graphics.setColor(0.7, 0.7, 0.7, 0.8)
        local mini = string.format("B%d P%d", stats.numBuildings or 0, stats.totalProducts or 0)
        love.graphics.print(mini, listX + listW - 58, rowY + 3)

        -- Click area
        registerClick("sys_" .. i, listX + 4, rowY, listW - 8, itemH - 2,
            function() selectedIndex = i end)
    end

    -- Right column: details of selected system
    love.graphics.setColor(0.15, 0.12, 0.08, 0.7)
    love.graphics.rectangle("fill", detailX, detailY, detailW, detailH, 4, 4, 4, 4)
    love.graphics.setColor(0.5, 0.4, 0.25, 0.6)
    love.graphics.rectangle("line", detailX, detailY, detailW, detailH, 4, 4, 4, 4)

    local selSys = systems[selectedIndex]
    if not selSys then
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.print("Izberi sistem na levi.", detailX + 16, detailY + 16)
    else
        local stats = selSys.module.getStats()
        local cat = Registry.getCatalogs(selSys.key)
        local products = cat and cat.products or {}
        local buildings = cat and cat.buildings or {}

        -- Header with category badge
        love.graphics.setColor(1, 0.92, 0.7, 1)
        love.graphics.print(selSys.name, detailX + 16, detailY + 10)

        -- Category badge
        local sysCat = detectCategory(selSys.name)
        local badgeCat = nil
        for _, c in ipairs(CATEGORIES) do
            if c.id == sysCat then badgeCat = c break end
        end
        if badgeCat then
            local badgeX = detailX + 16 + font:getWidth(selSys.name) + 10
            local badgeW = font:getWidth(badgeCat.label) + 12
            love.graphics.setColor(badgeCat.color[1] * 0.4, badgeCat.color[2] * 0.4, badgeCat.color[3] * 0.4, 0.9)
            love.graphics.rectangle("fill", badgeX, detailY + 10, badgeW, 16, 3, 3, 3, 3)
            love.graphics.setColor(badgeCat.color[1], badgeCat.color[2], badgeCat.color[3], 1)
            love.graphics.print(badgeCat.label, badgeX + 6, detailY + 12)
        end

        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.print("(key: " .. selSys.key .. ")", detailX + 16, detailY + 30)

        -- Stats block
        local y = detailY + 52
        love.graphics.setColor(0.85, 0.85, 0.85, 1)
        love.graphics.print(string.format("Mojster: %s (spretnost %d)",
            stats.makerName or "—", stats.makerSkill or 0), detailX + 16, y)
        y = y + 20
        love.graphics.print(string.format("Zgradbe: %d  |  Aktivne izdelave: %d  |  Skupaj produktov: %d",
            stats.numBuildings or 0, stats.activeMaking or 0, stats.totalProducts or 0), detailX + 16, y)
        y = y + 20

        -- Stock display (with market sell price)
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.print("Zaloga produktov (cena na trgu):", detailX + 16, y)
        y = y + 18
        local stockShown = 0
        for prodId, qty in pairs(stats.productStock or {}) do
            if stockShown >= 6 then
                love.graphics.print("... (več v zalogi)", detailX + 32, y)
                y = y + 16
                break
            end
            local sellPrice = RMI.getPrice(prodId) or 0
            local totalValue = sellPrice * qty
            love.graphics.setColor(0.8, 0.8, 0.7, 1)
            love.graphics.print(string.format("• %s: %d  →  %d zlata/kos (%d skupno)",
                prodId, qty, sellPrice, totalValue), detailX + 32, y)
            y = y + 16
            stockShown = stockShown + 1
        end
        if stockShown == 0 then
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
            love.graphics.print("(prazna zaloga)", detailX + 32, y)
            y = y + 16
        end

        -- Resources block
        y = y + 8
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.print("Surovine v delavnici:", detailX + 16, y)
        y = y + 18
        local res = {
            { "Železo", stats.ironStock },
            { "Bron", stats.bronzeStock },
            { "Les", stats.woodStock },
            { "Usnje", stats.leatherStock },
            { "Srebro", stats.silverStock },
            { "Zlato", stats.goldStock },
            { "Dragulji", stats.jewelStock },
            { "Biseri", stats.pearlStock },
        }
        for i, r in ipairs(res) do
            if r[2] ~= nil then
                local col = (i - 1) % 4
                local row = math.floor((i - 1) / 4)
                local rx = detailX + 32 + col * 100
                local ry = y + row * 16
                love.graphics.setColor(0.85, 0.85, 0.85, 1)
                love.graphics.print(string.format("%s: %d", r[1], r[2]), rx, ry)
            end
        end
        y = y + 40

        -- Action buttons
        y = y + 8
        love.graphics.setColor(0.95, 0.85, 0.5, 1)
        love.graphics.print("Akcije", detailX + 16, y)
        y = y + 22

        local btnW = 200
        local btnH = 28
        local gap = 8

        -- Hire maker button
        local hireCost = 600 + (stats.makerSkill or 70) * 12
        local canHire = _G.state and (_G.state.gold or 0) >= hireCost
        drawButton("hire", detailX + 16, y, btnW, btnH,
            string.format("Najemi mojstra (%d zlata)", hireCost),
            canHire and not stats.hasMaker,
            function()
                tryAction(function()
                    local ok, err = Registry.hireMaker(selSys.key)
                    return ok, err
                end)
            end)
        if stats.hasMaker then
            love.graphics.setColor(0.5, 0.8, 0.5, 1)
            love.graphics.print("✓ Mojster najet", detailX + 16 + btnW + 12, y + 6)
        end
        y = y + btnH + gap

        -- Build workshop button
        local firstBuildingId, firstBuildingCost = nil, math.huge
        for bid, b in pairs(buildings) do
            local cost = (b.cost and b.cost.gold) or 0
            if cost < firstBuildingCost then
                firstBuildingCost = cost
                firstBuildingId = bid
            end
        end
        if firstBuildingId then
            local canBuild = _G.state and (_G.state.gold or 0) >= firstBuildingCost
            drawButton("build", detailX + 16, y, btnW, btnH,
                string.format("Zgradi delavnico (%d zlata)", firstBuildingCost),
                canBuild and (stats.numBuildings or 0) == 0,
                function()
                    tryAction(function()
                        local ok, err = Registry.build(selSys.key, firstBuildingId)
                        return ok, err
                    end)
                end)
            if (stats.numBuildings or 0) > 0 then
                love.graphics.setColor(0.5, 0.8, 0.5, 1)
                love.graphics.print("✓ Delavnica zgrajena", detailX + 16 + btnW + 12, y + 6)
            end
            y = y + btnH + gap
        end

        -- Make first product button
        local firstProductId, firstProductName = nil, nil
        local firstProductCost = math.huge
        for pid, p in pairs(products) do
            local cost = p.cost or 0
            if cost < firstProductCost then
                firstProductCost = cost
                firstProductId = pid
                firstProductName = p.name
            end
        end
        if firstProductId then
            local canMake = (stats.numBuildings or 0) > 0 and stats.hasMaker
            drawButton("make", detailX + 16, y, btnW, btnH,
                string.format("Izdelaj: %s", firstProductName or firstProductId),
                canMake,
                function()
                    tryAction(function()
                        local ok, err = Registry.make(selSys.key, firstProductId, 1)
                        return ok, err
                    end)
                end)
            if not canMake then
                love.graphics.setColor(0.8, 0.7, 0.4, 1)
                local reason = (stats.numBuildings or 0) == 0 and "Potrebna delavnica" or "Potreben mojster"
                love.graphics.print(reason, detailX + 16 + btnW + 12, y + 6)
            end
            y = y + btnH + gap
        end

        -- Quick build all 4 buildings
        drawButton("buildAll", detailX + 16, y, btnW, btnH,
            "Zgradi vse 4 zgradbe",
            _G.state and (_G.state.gold or 0) >= 30000,
            function()
                tryAction(function()
                    local built = 0
                    for bid, _ in pairs(buildings) do
                        local ok, _ = Registry.build(selSys.key, bid)
                        if ok then built = built + 1 end
                    end
                    return true, string.format("Zgradih %d zgradb", built)
                end)
            end)
        y = y + btnH + gap

        -- Sell all stock button (uses dynamic market prices)
        drawButton("sellAll", detailX + 16, y, btnW, btnH,
            "Prodaj na trgu",
            (stats.totalProducts or 0) > 0,
            function()
                tryAction(function()
                    local gold, units, prods = RMI.sellStock(selSys.key)
                    if gold > 0 then
                        return true, string.format("Prodano %d izdelkov za %d zlata (trg)", units, gold)
                    end
                    return false, "Ni zaloge za prodajo"
                end)
            end)
        y = y + btnH + gap

        -- Auto-sell toggle
        local autoOn = RMI.isAutoSellEnabled()
        drawButton("autoSell", detailX + 16, y, btnW, btnH,
            autoOn and "Avtomatska prodaja: ON" or "Avtomatska prodaja: OFF",
            true,
            function()
                tryAction(function()
                    RMI.setAutoSell(not autoOn)
                    return true, autoOn and "Auto-prodaja izklopljena" or "Auto-prodaja vklopljena"
                end)
            end)
        y = y + btnH + gap

        -- Add resources button (testing)
        drawButton("addRes", detailX + 16, y, btnW, btnH,
            "Dodaj surovine (test)",
            true,
            function()
                tryAction(function()
                    local m = selSys.module
                    if m.ironStock then m.ironStock = m.ironStock + 20 end
                    if m.bronzeStock then m.bronzeStock = m.bronzeStock + 20 end
                    if m.woodStock then m.woodStock = m.woodStock + 20 end
                    if m.leatherStock then m.leatherStock = m.leatherStock + 20 end
                    if m.silverStock then m.silverStock = m.silverStock + 20 end
                    if m.goldStock then m.goldStock = m.goldStock + 20 end
                    if m.jewelStock then m.jewelStock = m.jewelStock + 20 end
                    if m.pearlStock then m.pearlStock = m.pearlStock + 20 end
                    return true, "Dodane surovine"
                end)
            end)
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

function RoyalPanel.keypressed(key, scancode, isrepeat)
    if not visible then return false end

    -- Ctrl+R toggles
    if key == "r" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        RoyalPanel.toggle()
        return true
    end

    -- Escape: close panel or exit search
    if key == "escape" then
        if searchActive then
            searchActive = false
            searchQuery = ""
            rebuildFiltered()
        else
            RoyalPanel.toggle()
        end
        return true
    end

    -- Search mode: handle text input
    if searchActive then
        if key == "backspace" then
            searchQuery = searchQuery:sub(1, -2)
            rebuildFiltered()
            return true
        elseif key == "return" or key == "kpenter" then
            searchActive = false
            return true
        elseif key == "tab" then
            -- Cycle categories while in search
            local curIdx = 1
            for i, c in ipairs(CATEGORIES) do
                if c.id == activeCategory then curIdx = i break end
            end
            curIdx = curIdx % #CATEGORIES + 1
            activeCategory = CATEGORIES[curIdx].id
            page = 1
            selectedIndex = 1
            rebuildFiltered()
            return true
        end
        -- Ignore navigation keys when typing
        return true
    end

    -- / activates search
    if key == "/" then
        searchActive = true
        searchQuery = ""
        return true
    end

    -- Tab cycles categories
    if key == "tab" then
        local curIdx = 1
        for i, c in ipairs(CATEGORIES) do
            if c.id == activeCategory then curIdx = i break end
        end
        curIdx = curIdx % #CATEGORIES + 1
        activeCategory = CATEGORIES[curIdx].id
        page = 1
        selectedIndex = 1
        rebuildFiltered()
        return true
    end

    if key == "left" or key == "a" then
        if page > 1 then
            page = page - 1
            selectedIndex = (page - 1) * pageSize + 1
        end
        return true
    end
    if key == "right" or key == "d" then
        if page < totalPages then
            page = page + 1
            selectedIndex = (page - 1) * pageSize + 1
        end
        return true
    end
    if key == "up" or key == "w" then
        if selectedIndex > 1 then
            selectedIndex = selectedIndex - 1
            local newPage = math.ceil(selectedIndex / pageSize)
            if newPage ~= page then page = newPage end
        end
        return true
    end
    if key == "down" or key == "s" then
        if selectedIndex < #filteredSystems then
            selectedIndex = selectedIndex + 1
            local newPage = math.ceil(selectedIndex / pageSize)
            if newPage ~= page then page = newPage end
        end
        return true
    end

    return false
end

-- Handle text input for search
function RoyalPanel.textinput(text)
    if not visible then return false end
    if searchActive then
        -- Only accept printable characters
        if text:match("[%w _-]") then
            searchQuery = searchQuery .. text
            rebuildFiltered()
        end
        return true
    end
    return false
end

function RoyalPanel.mousepressed(x, y, button)
    if not visible then return false end
    if button ~= 1 then return false end

    -- If clicking outside search box, deactivate search
    local screenW, screenH = love.graphics.getDimensions()
    local panelW = math.min(LAYOUT.panelW, screenW - 40)
    local panelH = math.min(LAYOUT.panelH, screenH - 40)
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    for _, area in ipairs(clickAreas) do
        if x >= area.x and x <= area.x + area.w and y >= area.y and y <= area.y + area.h then
            if area.action then
                area.action()
            end
            return true
        end
    end

    -- Click outside panel closes it
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        RoyalPanel.toggle()
        return true
    end

    -- Click inside panel but not on any control: deactivate search
    if searchActive then
        searchActive = false
    end

    return false
end

return RoyalPanel
