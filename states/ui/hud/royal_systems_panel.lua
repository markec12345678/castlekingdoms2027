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
local PanelAnim = require("states.ui.hud.PanelAnimations")
local UISound = require("objects.Audio.UISoundHelper")
local RoyalIcon = require("states.ui.hud.royal_icon_generator")  -- v3.12.152: procedural icons

local RoyalPanel = {}

local visible = false
local selectedIndex = 1
local page = 1
local pageSize = 20
local totalPages = 1
local actionMessage = ""
local actionMessageTime = 0

-- v3.12.126: Panel animation state (fade-in/out + slide-left)
local animState = PanelAnim.createState({
    duration = 0.20,
    slideDir = "left",
    slideDist = 22,
    easing = "easeOut",
})

-- v3.11.968: Hovered system for tooltip
local hoveredSystem = nil  -- {sysIndex, mouseX, mouseY}
-- v3.11.968: System row click areas (populated during draw)
local systemRowAreas = {}

-- Search & filter state
local searchQuery = ""
local searchActive = false
local activeCategory = "all"  -- "all", "glass", "foundry", "bookbinding", "blacksmith", "garden", "milling", "other"
local sortMode = "alpha"  -- "alpha", "buildings", "products", "gold", "active"
local SORT_MODES = {
    alpha      = "Abecedno",
    buildings  = "Po zgradbah",
    products   = "Po produktih",
    gold       = "Po zaslužku",
    active     = "Po aktivnosti",
}

local SEARCH_FILE = "royal_systems_search.txt"

-- Load persisted search query on init
local function loadSearchQuery()
    local ok, content = pcall(love.filesystem.read, SEARCH_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")  -- trim trailing whitespace
        if content ~= "" then
            searchQuery = content
        end
    end
end

-- Save search query to file
local function saveSearchQuery()
    pcall(love.filesystem.write, SEARCH_FILE, searchQuery .. "\n")
end

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

    -- Sort by current sort mode
    if sortMode == "alpha" then
        table.sort(filteredSystems, function(a, b) return a.name < b.name end)
    elseif sortMode == "buildings" then
        table.sort(filteredSystems, function(a, b)
            local sa = a.module.getStats and a.module.getStats() or {}
            local sb = b.module.getStats and b.module.getStats() or {}
            return (sa.numBuildings or 0) > (sb.numBuildings or 0)
        end)
    elseif sortMode == "products" then
        table.sort(filteredSystems, function(a, b)
            local sa = a.module.getStats and a.module.getStats() or {}
            local sb = b.module.getStats and b.module.getStats() or {}
            return (sa.totalProducts or 0) > (sb.totalProducts or 0)
        end)
    elseif sortMode == "gold" then
        local RMI = require("objects.Economy.RoyalMarketIntegration")
        local rev = RMI.getPerSystemRevenue()
        table.sort(filteredSystems, function(a, b)
            return (rev[a.key] or 0) > (rev[b.key] or 0)
        end)
    elseif sortMode == "active" then
        table.sort(filteredSystems, function(a, b)
            local sa = a.module.getStats and a.module.getStats() or {}
            local sb = b.module.getStats and b.module.getStats() or {}
            return (sa.activeMaking or 0) > (sb.activeMaking or 0)
        end)
    end

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
        -- v3.12.127: Show toast notification for successful action
        if _G.NotificationCenter then
            pcall(function() _G.NotificationCenter.economy(actionMessage) end)
        end
        return true
    elseif ok then
        actionMessage = "Napaka: " .. tostring(err or "Neznana")
        actionMessageTime = 3.0
        -- v3.12.127: Show toast for error
        if _G.NotificationCenter then
            pcall(function() _G.NotificationCenter.system(actionMessage) end)
        end
        return false, err
    else
        actionMessage = "Izjema: " .. tostring(err or "Neznana")
        actionMessageTime = 3.0
        -- v3.12.127: Show toast for exception
        if _G.NotificationCenter then
            pcall(function() _G.NotificationCenter.combat(actionMessage) end)
        end
        return false, err
    end
end

local SETTINGS_FILE = "royal_systems_sort.txt"
local CATEGORY_FILE = "royal_systems_category.txt"

-- Load persisted sort mode on init
local function loadSortMode()
    local ok, content = pcall(love.filesystem.read, SETTINGS_FILE)
    if ok and content then
        content = content:gsub("%s", "")  -- trim whitespace
        if SORT_MODES[content] then
            sortMode = content
        end
    end
end

-- Save sort mode to file
local function saveSortMode()
    pcall(love.filesystem.write, SETTINGS_FILE, sortMode .. "\n")
end

-- Load persisted category on init
local function loadCategory()
    local ok, content = pcall(love.filesystem.read, CATEGORY_FILE)
    if ok and content then
        content = content:gsub("%s", "")
        -- Validate category ID exists
        for _, cat in ipairs(CATEGORIES) do
            if cat.id == content then
                activeCategory = content
                break
            end
        end
    end
end

-- Save category to file
local function saveCategory()
    pcall(love.filesystem.write, CATEGORY_FILE, activeCategory .. "\n")
end

-- Load on init
loadSortMode()
loadCategory()
loadSearchQuery()

function RoyalPanel.toggle()
    if not visible then
        visible = true
        PanelAnim.open(animState)
        UISound.playPanelOpen()
        rebuildFiltered()
    else
        PanelAnim.close(animState)
        UISound.playPanelClose()
    end
end

function RoyalPanel.setVisible(state)
    if state and not visible then
        visible = true
        PanelAnim.open(animState)
    elseif not state and visible then
        PanelAnim.close(animState)
    end
end

function RoyalPanel.isVisible()
    return visible or PanelAnim.isAnimating(animState)
end

-- v3.11.948: Jump to a specific system by key.
-- Clears search/category filters, finds the system, sets selectedIndex and page.
-- Called from TechTreePanel double-click.
-- @param key string System key (e.g. "BellMaker", "Metalwork")
-- @return boolean True if system was found and selected
function RoyalPanel.jumpToSystem(key)
    if not key then return false end
    -- Clear filters to ensure the system is visible
    searchQuery = ""
    searchActive = false
    activeCategory = "all"
    rebuildFiltered()
    -- Find the system by key
    local foundIdx = nil
    for i, sys in ipairs(filteredSystems) do
        if sys.key == key then
            foundIdx = i
            break
        end
    end
    if not foundIdx then return false end
    selectedIndex = foundIdx
    page = math.max(1, math.ceil(selectedIndex / pageSize))
    actionMessage = "📍 Skok na: " .. (filteredSystems[foundIdx].name or key)
    actionMessageTime = 3.0
    return true
end

function RoyalPanel.update(dt)
    if not visible and not PanelAnim.isAnimating(animState) then return end
    PanelAnim.update(animState, dt)
    if animState.phase == "closed" then
        visible = false
    end
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
    if not visible and not PanelAnim.isAnimating(animState) then return end

    clickAreas = {}

    -- v3.12.126: Apply panel animation (alpha + slide offset)
    local alpha = PanelAnim.getProgress(animState)
    local offsetX, offsetY = PanelAnim.getOffset(animState)

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = math.min(LAYOUT.panelW, screenW - 40)
    local panelH = math.min(LAYOUT.panelH, screenH - 40)
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    -- Dim background (fades in/out)
    love.graphics.setColor(0, 0, 0, 0.7 * alpha)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    -- Panel (with slide offset)
    love.graphics.push("all")
    love.graphics.translate(offsetX, offsetY)

    love.graphics.setColor(0.08, 0.06, 0.04, 0.98 * alpha)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Border (royal gold)
    love.graphics.setColor(0.78, 0.62, 0.28, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)

    -- Title
    love.graphics.setColor(1, 0.92, 0.7, 1)
    local font = love.graphics.getFont()
    love.graphics.print("Kraljevi sistemski (Royal Systems)", panelX + 20, panelY + 10)
    love.graphics.setColor(0.7, 0.6, 0.4, 1)
    love.graphics.print("Ctrl+R: Zapri  |  /: Iskanje  |  Tab: Kategorije  |  F: Sortiranje", panelX + panelW - 420, panelY + 10)

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
                saveCategory()
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

    -- Sort mode indicator (next to search box, left side)
    local sortLabelX = searchX - 140
    love.graphics.setColor(0.15, 0.12, 0.08, 0.9)
    love.graphics.rectangle("fill", sortLabelX, searchY, 130, searchH, 3, 3, 3, 3)
    love.graphics.setColor(0.5, 0.6, 0.4, 0.8)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", sortLabelX, searchY, 130, searchH, 3, 3, 3, 3)
    love.graphics.setColor(0.7, 0.85, 0.6, 1)
    love.graphics.print("F: " .. (SORT_MODES[sortMode] or "?"), sortLabelX + 8, searchY + 3)

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
    -- v3.11.968: Clear system row click areas for this frame
    systemRowAreas = {}

    for i = startIdx, endIdx do
        local sys = systems[i]
        if not sys then break end
        local stats = sys.module.getStats()
        local isSelected = i == selectedIndex
        local hasBuilding = (stats.numBuildings or 0) > 0
        local hasMaker = stats.hasMaker

        local rowY = itemY + (i - startIdx) * itemH
        -- v3.11.968: Store click area for hover detection
        systemRowAreas[#systemRowAreas + 1] = {
            x = listX + 4, y = rowY, w = listW - 8, h = itemH - 2,
            sysIndex = i,
        }
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

        -- v3.12.152: Procedural icon (16x16) to the left of name
        RoyalIcon.draw(sys.name or sys.key, listX + 10, rowY + (itemH - 16) / 2 - 1, 16)

        -- Name
        love.graphics.setColor(1, 1, 1, 0.92)
        local displayName = sys.name
        if #displayName > 24 then displayName = displayName:sub(1, 22) .. ".." end
        love.graphics.print(displayName, listX + 32, rowY + 3)

        -- Mini stats
        love.graphics.setColor(0.7, 0.7, 0.7, 0.8)
        local mini = string.format("B%d P%d", stats.numBuildings or 0, stats.totalProducts or 0)
        love.graphics.print(mini, listX + listW - 58, rowY + 3)

        -- Click area
        registerClick("sys_" .. i, listX + 4, rowY, listW - 16, itemH - 2,
            function() selectedIndex = i end)
    end

    -- Visual scrollbar for system list (right side of list area)
    if totalPages > 1 then
        local sbX = listX + listW - 10
        local sbY = listY + 30
        local sbW = 6
        local sbH = listH - 36
        -- Track
        love.graphics.setColor(0.1, 0.08, 0.04, 1)
        love.graphics.rectangle("fill", sbX, sbY, sbW, sbH, 2, 2, 2, 2)
        -- Thumb (proportional to page/totalPages)
        local thumbH = math.max(20, sbH / totalPages)
        local thumbY = sbY + ((page - 1) / math.max(1, totalPages - 1)) * (sbH - thumbH)
        love.graphics.setColor(0.55, 0.45, 0.25, 0.9)
        love.graphics.rectangle("fill", sbX + 1, thumbY, sbW - 2, thumbH, 2, 2, 2, 2)
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
        -- v3.12.152: Larger procedural icon (48x48) next to system name
        RoyalIcon.draw(selSys.name or selSys.key, detailX + 16, detailY + 8, 48)

        love.graphics.setColor(1, 0.92, 0.7, 1)
        love.graphics.print(selSys.name, detailX + 76, detailY + 10)

        -- Category badge
        local sysCat = detectCategory(selSys.name)
        local badgeCat = nil
        for _, c in ipairs(CATEGORIES) do
            if c.id == sysCat then badgeCat = c break end
        end
        if badgeCat then
            local badgeX = detailX + 76 + font:getWidth(selSys.name) + 10
            local badgeW = font:getWidth(badgeCat.label) + 12
            love.graphics.setColor(badgeCat.color[1] * 0.4, badgeCat.color[2] * 0.4, badgeCat.color[3] * 0.4, 0.9)
            love.graphics.rectangle("fill", badgeX, detailY + 10, badgeW, 16, 3, 3, 3, 3)
            love.graphics.setColor(badgeCat.color[1], badgeCat.color[2], badgeCat.color[3], 1)
            love.graphics.print(badgeCat.label, badgeX + 6, detailY + 12)
        end

        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.print("(key: " .. selSys.key .. ")", detailX + 76, detailY + 30)

        -- Castle Kingdoms 2027 v3.11.934: System dependencies (tech tree) display
        local Deps = require("objects.Economy.SystemDependencies")
        if Deps.hasDependencies(selSys.key) then
            local depDesc = Deps.getDependencyDescription(selSys.key)
            local met, unmet = Deps.checkDependencies(selSys.key)
            if met then
                love.graphics.setColor(0.4, 0.85, 0.4, 1)
            else
                love.graphics.setColor(0.95, 0.5, 0.3, 1)
            end
            love.graphics.setFont(smallFont)
            love.graphics.print("🔗 " .. depDesc, detailX + 16, detailY + 44)
            love.graphics.setFont(font)
        end

        -- Stats block
        local y = detailY + 60
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

        -- Production history mini-chart (last 60s)
        love.graphics.setColor(0.95, 0.85, 0.5, 1)
        love.graphics.print("Proizvodnja (zadnja minuta):", detailX + 16, y)
        y = y + 18

        local prodStats = Registry.getProductionStats(selSys.key, 60)
        local prodHist = Registry.getProductionHistory(selSys.key, 60)

        -- Chart area: spans full detail width, ~60px tall
        local chartX = detailX + 16
        local chartY = y
        local chartW = detailW - 32
        local chartH = 60

        love.graphics.setColor(0.08, 0.06, 0.04, 1)
        love.graphics.rectangle("fill", chartX, chartY, chartW, chartH, 3, 3, 3, 3)
        love.graphics.setColor(0.35, 0.28, 0.18, 0.8)
        love.graphics.rectangle("line", chartX, chartY, chartW, chartH, 3, 3, 3, 3)

        if prodStats and #prodHist >= 2 then
            -- Build per-second bucket counts (60 buckets, 1s each)
            local now = (love.timer and love.timer.getTime()) or 0
            local buckets = {}
            for i = 1, 60 do buckets[i] = 0 end
            for _, e in ipairs(prodHist) do
                local age = now - e.t
                if age >= 0 and age < 60 then
                    local bucketIdx = math.floor(age) + 1
                    if bucketIdx >= 1 and bucketIdx <= 60 then
                        buckets[bucketIdx] = buckets[bucketIdx] + (e.qty or 1)
                    end
                end
            end
            -- Find max for scaling
            local maxBucket = 1
            for _, v in ipairs(buckets) do
                if v > maxBucket then maxBucket = v end
            end

            -- Draw bar chart (each bucket = 1 second wide)
            local padTop, padBottom = 4, 4
            local plotH = chartH - padTop - padBottom
            local barW = chartW / 60
            for i = 1, 60 do
                local v = buckets[i]
                if v > 0 then
                    local h = (v / maxBucket) * plotH
                    local bx = chartX + (i - 1) * barW
                    local by = chartY + chartH - padBottom - h
                    -- Color: brighter for more recent (right side)
                    local recency = (60 - (i - 1)) / 60  -- 1.0 most recent, ~0 oldest
                    love.graphics.setColor(0.4 + recency * 0.4, 0.85, 0.4, 0.9)
                    love.graphics.rectangle("fill", bx + 0.5, by, barW - 1, h)
                end
            end

            -- Stats line below chart
            love.graphics.setColor(0.7, 0.85, 0.7, 1)
            local statusStr
            if prodStats.ratePerMin > 5 then
                statusStr = "🔥 zelo aktivna"
            elseif prodStats.ratePerMin > 1 then
                statusStr = "✓ aktivna"
            else
                statusStr = "○ nizka"
            end
            love.graphics.print(string.format(
                "Skupaj: %d izdelkov  |  Količina: %d  |  Hitrost: %.1f/min  |  Povp. prestiž: %.1f  |  %s",
                prodStats.totalCount, prodStats.totalQty, prodStats.ratePerMin,
                prodStats.avgPrestige, statusStr
            ), chartX + 4, chartY + chartH + 4)
        else
            love.graphics.setColor(0.5, 0.5, 0.55, 1)
            love.graphics.print("(ni podatkov o proizvodnji — začni izdelovati)", chartX + 8, chartY + chartH / 2 - 4)
        end
        y = y + chartH + 22

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

    -- v3.11.968: System hover tooltip
    if hoveredSystem and hoveredSystem.sysIndex then
        local sys = filteredSystems[hoveredSystem.sysIndex]
        if sys then
            local stats = sys.module.getStats()
            local lines = {}
            table.insert(lines, "📦 " .. sys.name)
            -- Status
            local hasBuilding = (stats.numBuildings or 0) > 0
            local hasMaker = stats.hasMaker
            if hasBuilding and hasMaker then
                table.insert(lines, "Status: ✓ aktiven (zgradba + mojster)")
            elseif hasBuilding then
                table.insert(lines, "Status: ⚠ delno (zgradba, brez mojstra)")
            elseif hasMaker then
                table.insert(lines, "Status: ⚠ delno (mojster, brez zgradbe)")
            else
                table.insert(lines, "Status: ✗ neaktiven")
            end
            -- Stats
            table.insert(lines, string.format("Zgradbe: %d", stats.numBuildings or 0))
            table.insert(lines, string.format("Mojster: %s (spretnost %d)",
                stats.makerName or "—", stats.makerSkill or 0))
            table.insert(lines, string.format("Aktivne izdelave: %d", stats.activeMaking or 0))
            table.insert(lines, string.format("Skupno produktov: %d", stats.totalProducts or 0))
            -- Surovine summary
            local resStr = string.format("Surovine: Fe%d Br%d Wo%d Le%d",
                stats.ironStock or 0, stats.bronzeStock or 0,
                stats.woodStock or 0, stats.leatherStock or 0)
            table.insert(lines, resStr)
            table.insert(lines, string.format("          Ag%d Au%d Jew%d Pearl%d",
                stats.silverStock or 0, stats.goldStock or 0,
                stats.jewelStock or 0, stats.pearlStock or 0))

            -- Draw tooltip box
            local sfont = love.graphics.newFont(11)
            love.graphics.setFont(sfont)
            local tipW = 0
            for _, l in ipairs(lines) do
                local lw = sfont:getWidth(l)
                if lw > tipW then tipW = lw end
            end
            tipW = tipW + 16
            local tipH = #lines * (sfont:getHeight() + 2) + 10
            local tipX = hoveredSystem.mouseX + 16
            local tipY = hoveredSystem.mouseY + 16
            -- Keep on screen
            local W = love.graphics.getWidth()
            local H = love.graphics.getHeight()
            if tipX + tipW > W - 8 then tipX = hoveredSystem.mouseX - tipW - 16 end
            if tipY + tipH > H - 8 then tipY = hoveredSystem.mouseY - tipH - 16 end

            love.graphics.setColor(0.05, 0.06, 0.08, 0.97)
            love.graphics.rectangle("fill", tipX, tipY, tipW, tipH, 4, 4, 4, 4)
            love.graphics.setColor(0.5, 0.7, 0.9, 0.9)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", tipX, tipY, tipW, tipH, 4, 4, 4, 4)
            for i, l in ipairs(lines) do
                if i == 1 then
                    love.graphics.setColor(0.95, 0.85, 0.5, 1)
                elseif l:find("✓") then
                    love.graphics.setColor(0.4, 0.95, 0.4, 1)
                elseif l:find("⚠") then
                    love.graphics.setColor(0.95, 0.85, 0.3, 1)
                elseif l:find("✗") then
                    love.graphics.setColor(0.95, 0.4, 0.4, 1)
                else
                    love.graphics.setColor(0.85, 0.88, 0.9, 1)
                end
                love.graphics.print(l, tipX + 8, tipY + 6 + (i - 1) * (sfont:getHeight() + 2))
            end
            love.graphics.setFont(font)
        end
    end

    -- v3.12.126: Close the slide-offset transform
    love.graphics.pop()

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
            saveSearchQuery()
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
            saveSearchQuery()
            rebuildFiltered()
            return true
        elseif key == "return" or key == "kpenter" then
            searchActive = false
            saveSearchQuery()
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
        saveSearchQuery()
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
        saveCategory()
        page = 1
        selectedIndex = 1
        rebuildFiltered()
        return true
    end

    -- F cycles sort modes
    if key == "f" then
        local modes = {"alpha", "buildings", "products", "gold", "active"}
        for i, m in ipairs(modes) do
            if m == sortMode then
                sortMode = modes[(i % #modes) + 1]
                break
            end
        end
        saveSortMode()
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

    -- Castle Kingdoms 2027 v3.11.921: Additional keyboard shortcuts
    -- Home: jump to first page
    if key == "home" then
        page = 1
        selectedIndex = 1
        return true
    end
    -- End: jump to last page
    if key == "end" then
        page = totalPages
        selectedIndex = (page - 1) * pageSize + 1
        return true
    end
    -- PageUp: previous page (same as left arrow but more intuitive)
    if key == "pageup" then
        if page > 1 then
            page = page - 1
            selectedIndex = (page - 1) * pageSize + 1
        end
        return true
    end
    -- PageDown: next page
    if key == "pagedown" then
        if page < totalPages then
            page = page + 1
            selectedIndex = (page - 1) * pageSize + 1
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
            saveSearchQuery()
            rebuildFiltered()
        end
        return true
    end
    return false
end

-- Mouse wheel handler for fast page navigation through 987 systems
function RoyalPanel.wheelmoved(x, y)
    if not visible then return false end
    if searchActive then return false end  -- don't interfere with search
    -- y > 0: scroll up (previous page), y < 0: scroll down (next page)
    if y > 0 then
        if page > 1 then
            page = page - 1
            selectedIndex = (page - 1) * pageSize + 1
            return true
        end
    elseif y < 0 then
        if page < totalPages then
            page = page + 1
            selectedIndex = (page - 1) * pageSize + 1
            return true
        end
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

-- Castle Kingdoms 2027 v3.11.938: Mouse moved/released stubs for consistency
-- v3.11.968: mousemoved now detects hovered system for tooltip
function RoyalPanel.mousemoved(x, y, dx, dy)
    if not visible then return false end
    -- v3.11.968: Check if mouse is over a system row
    hoveredSystem = nil
    for _, area in ipairs(systemRowAreas) do
        if x >= area.x and x <= area.x + area.w
           and y >= area.y and y <= area.y + area.h then
            hoveredSystem = {
                sysIndex = area.sysIndex,
                mouseX = x,
                mouseY = y,
            }
            return true
        end
    end
    return false
end

function RoyalPanel.mousereleased(x, y, button)
    return false
end

return RoyalPanel
