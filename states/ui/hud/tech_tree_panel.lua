-- states/ui/hud/tech_tree_panel.lua
-- Castle Kingdoms 2027 - Tech Tree Visualization Panel
--
-- Two view modes (toggle with G):
--   * GRAPH (default): node-based graph with rounded rectangles and bezier
--     curves connecting dependencies. Each chain is a horizontal row.
--   * TEXT (legacy): hierarchical text tree with └─ characters.
--
-- Color coding (both modes):
--   * Green  = active (≥1 building built)
--   * Yellow = met (deps satisfied, but no building yet)
--   * Red    = locked (deps not met)
--
-- Hover over a node in graph mode to see full dependency details.
-- Click a node to "focus" it: related connections highlight, others dim.
-- Press F or click again to clear focus.
-- Toggle with Ctrl+Shift+G (G for "Graph").

local Deps = require("objects.Economy.SystemDependencies")
local Registry = require("objects.Economy.RoyalSystemsRegistry")

local TechTreePanel = {}

local visible = false
local scrollOffset = 0
local viewMode = "graph"  -- "graph" or "text"

-- Hover state for tooltip
local hoveredNode = nil  -- { key, x, y, w, h, chainLabel }
local mouseX, mouseY = 0, 0

-- Click-to-focus state (v3.11.945)
-- When selectedKey is set, related nodes/connections are highlighted and others dimmed.
-- Related = the selected node + its direct prereqs + its direct dependents.
local selectedKey = nil

-- Search/filter state (v3.11.946)
-- When searchActive is true, user is typing in the search box.
-- searchQuery is the current text (case-insensitive substring match).
-- Matching nodes stay bright; non-matching get dimmed (similar to focus mode).
local searchActive = false
local searchQuery = ""
local cursorBlink = 0  -- accumulated time for cursor blink animation

-- Path highlight mode (v3.11.947)
-- "direct" = only direct prereqs + dependents (v3.11.945 behavior)
-- "transitive" = full ancestor chain + full descendant chain (tech lineage)
local pathMode = "transitive"  -- default to full path for richer visualization

-- Double-click detection (v3.11.948)
-- Tracks last click time + key for double-click detection.
-- Double-click on a node opens Royal Systems Panel and jumps to that system.
local lastClickTime = 0
local lastClickKey = nil
local DOUBLE_CLICK_THRESHOLD = 0.4  -- seconds

-- Define chain display order and labels
local CHAINS = {
    { label = "KOVANJE METALOV", base = "Metalwork", systems = {"BellMaker", "ChainmailForger", "SwordPommelMaker", "GauntletMaker", "CoinDieMaker", "CoinPressMaker"} },
    { label = "STEKLARSTVO", base = "GlassBench", systems = {"MirrorMaker", "GlassBeadMaker", "VitrailFoilMaker", "GlassBlowpipeCoolingRack", "GlassMoldMaker"} },
    { label = "LONČARSTVO", base = "PotteryWheel", systems = {"ApothecaryMortar", "ApothecaryVial", "CrystallizationDish"} },
    { label = "DRVESNI OBRT", base = "WoodLathe", systems = {"BookPress", "BookbindingPress", "EaselMaker", "BoardGameMaker"} },
    { label = "TEKSTIL", base = "SpinningWheel", systems = {"LoomHeddle", "TapestryLoom", "CarpetLoom"} },
    { label = "USNJARSTVO", base = "RawhideTanner", systems = {"SaddleMaker", "LeatherCoverMaker", "GloveMaker"} },
    { label = "BARVILA", base = "DyeStuff", systems = {"DyerColor"} },
    { label = "VISOKA PEČ", base = "ForgeTuyere", systems = {"AnvilMaker", "ForgeTongsMaker", "CutlerySmith", "PlateCuirassSmith"} },
    { label = "INSTRUMENTI", base = "Metalwork+WoodLathe", systems = {"TrumpetMaker", "FluteMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe"} },
    { label = "KARTOGRAFIJA", base = "ParchmentMaker+InkMaker", systems = {"MapMaker", "ManuscriptIlluminator"}, multiBase = true, bases = {"ParchmentMaker", "InkMaker"} },
    -- v3.11.940: New chains
    { label = "PIVOVARSTVO", base = "BranSeparator", systems = {"AleBrewer", "BrandyDistiller"} },
    { label = "PEKSTVO", base = "FlourSieve", systems = {"BreadBaker", "PastryChef"} },
    { label = "RIBOLV", base = "NetMaker", systems = {"FishingRodMaker", "FishingTrapMaker"} },
    { label = "SVEČE IN VOSAK", base = "WaxTablet", systems = {"CandlestickBase", "TorchHolderMaker"} },
    { label = "KAMNOSEŠTVO", base = "MasonStonecutter", systems = {"BrickMaker", "RoofTileMaker"} },
    { label = "PREDSTAVE", base = "WoodLathe+PigmentGrinder", systems = {"TheaterMaskMaker"}, multiBase = true, bases = {"WoodLathe", "PigmentGrinder"} },
    -- v3.11.943: New chains
    { label = "VRTNARSTVO", base = "GardenRake", systems = {"TopiaryFrameMaker", "LawnAeratorMaker", "GardenWheelbarrowMaker"} },
    { label = "ČEBELARSTVO", base = "HoneyDipperMaker", systems = {"HoneyCollector"} },
    { label = "BARVNO STEKLO", base = "GlassBench", systems = {"GlassColorantMaker"} },
    { label = "BARVNO STEKLO+", base = "GlassBench+PigmentGrinder", systems = {"GlassColorantMuller"}, multiBase = true, bases = {"GlassBench", "PigmentGrinder"} },
    { label = "MLINSKI PRIBOR", base = "MillstoneSpindleBearing", systems = {"MillstoneBalancerMaker", "MillstoneCraneMaker"} },
    { label = "SODARSTVO", base = "WoodLathe", systems = {"CooperBarrelMaker"} },
    { label = "KIRURGIJA", base = "Metalwork+ApothecaryMortar", systems = {"SurgicalLancetMaker"}, multiBase = true, bases = {"Metalwork", "ApothecaryMortar"} },
    { label = "KOVANJE DENARJA", base = "CoinDieMaker+CoinPressMaker", systems = {"MintCurrency"}, multiBase = true, bases = {"CoinDieMaker", "CoinPressMaker"} },
    { label = "ASTRONOMIJA", base = "Metalwork", systems = {"AstrolabeRingMaker", "NocturnalMaker", "QuadrantMaker"} },
}

-- Node dimensions for graph view
local NODE_W = 132
local NODE_H = 30
local NODE_GAP_X = 24
local NODE_GAP_Y = 14
local CHAIN_HEADER_H = 22
local CHAIN_GAP = 18

function TechTreePanel.toggle()
    visible = not visible
    scrollOffset = 0
    hoveredNode = nil
    selectedKey = nil
    searchActive = false
    searchQuery = ""
    pathMode = "transitive"
end

function TechTreePanel.isVisible()
    return visible
end

-- Compute the set of keys "related" to a selected key (v3.11.945)
-- Related = selectedKey + direct prerequisites + direct dependents
-- Direct dependents = systems whose dependencyGraph entry contains selectedKey
-- v3.11.947: If pathMode == "transitive", extends to full ancestor + descendant chains
local function computeRelatedKeys(key)
    local related = {}
    related[key] = true

    if pathMode == "direct" then
        -- v3.11.945 behavior: direct prereqs + direct dependents only
        local prereqs = Deps.getDependencies(key)
        for _, p in ipairs(prereqs) do
            related[p] = true
        end

        for _, chain in ipairs(CHAINS) do
            local bases = chain.multiBase and chain.bases or {chain.base}
            for _, baseKey in ipairs(bases) do
                if baseKey ~= key then
                    local basePrereqs = Deps.getDependencies(baseKey)
                    for _, p in ipairs(basePrereqs) do
                        if p == key then related[baseKey] = true end
                    end
                end
            end
            for _, sysKey in ipairs(chain.systems) do
                if sysKey ~= key then
                    local sysPrereqs = Deps.getDependencies(sysKey)
                    for _, p in ipairs(sysPrereqs) do
                        if p == key then related[sysKey] = true end
                    end
                end
            end
        end
    else
        -- v3.11.947: transitive mode — full ancestor chain + full descendant chain
        -- BFS up the prereq chain
        local toVisit = {key}
        local visited = {[key] = true}
        while #toVisit > 0 do
            local current = table.remove(toVisit, 1)
            local prereqs = Deps.getDependencies(current)
            for _, p in ipairs(prereqs) do
                if not visited[p] then
                    visited[p] = true
                    related[p] = true
                    table.insert(toVisit, p)
                end
            end
        end

        -- BFS down the dependent chain
        -- Build a reverse dependency map first (prereq -> list of dependents)
        -- by scanning all CHAINS
        local reverseDeps = {}  -- prereqKey -> {dependentKey1, dependentKey2, ...}
        for _, chain in ipairs(CHAINS) do
            local bases = chain.multiBase and chain.bases or {chain.base}
            for _, baseKey in ipairs(bases) do
                local basePrereqs = Deps.getDependencies(baseKey)
                for _, p in ipairs(basePrereqs) do
                    if not reverseDeps[p] then reverseDeps[p] = {} end
                    table.insert(reverseDeps[p], baseKey)
                end
            end
            for _, sysKey in ipairs(chain.systems) do
                local sysPrereqs = Deps.getDependencies(sysKey)
                for _, p in ipairs(sysPrereqs) do
                    if not reverseDeps[p] then reverseDeps[p] = {} end
                    table.insert(reverseDeps[p], sysKey)
                end
            end
        end

        -- BFS down from key using reverseDeps
        toVisit = {key}
        local visitedDown = {[key] = true}
        while #toVisit > 0 do
            local current = table.remove(toVisit, 1)
            local dependents = reverseDeps[current]
            if dependents then
                for _, d in ipairs(dependents) do
                    if not visitedDown[d] then
                        visitedDown[d] = true
                        related[d] = true
                        table.insert(toVisit, d)
                    end
                end
            end
        end
    end

    return related
end

-- Check if a connection is "related" to the selectedKey
-- A connection is related if either endpoint is the selectedKey, or both
-- endpoints are in the related set.
local function isConnectionRelated(conn, fromKey, toKey, relatedSet)
    if not selectedKey then return true end
    -- Direct connection to/from selected
    if fromKey == selectedKey or toKey == selectedKey then return true end
    -- Both endpoints in related set (e.g., selected's prereq → selected's dependent)
    if relatedSet[fromKey] and relatedSet[toKey] then return true end
    return false
end

-- v3.11.946: Check if a node key matches the current search query.
-- Match is case-insensitive substring on the display name.
-- Returns true if search is not active OR if the name matches.
local function isSearchMatch(key)
    if not searchActive or searchQuery == "" then return true end
    local name = displayName(key):lower()
    return name:find(searchQuery:lower(), 1, true) ~= nil
end

-- v3.11.946: Check if a connection should be shown based on search.
-- A connection is search-related if EITHER endpoint matches the search.
-- (When searching, we want to see all connections touching matching nodes.)
local function isConnectionSearchRelated(fromKey, toKey)
    if not searchActive or searchQuery == "" then return true end
    return isSearchMatch(fromKey) or isSearchMatch(toKey)
end

-- Check if a system key is "active" (has ≥1 building)
local function isSystemActive(key)
    local systems = Registry.getSystems()
    for _, sys in ipairs(systems) do
        if sys.key == key then
            local stats = sys.module.getStats()
            return stats and (stats.numBuildings or 0) > 0
        end
    end
    return false
end

-- Get display name from key
local function displayName(key)
    return key:gsub("Maker$", ""):gsub("([a-z])([A-Z])", "%1 %2")
end

-- Get node state: "active" | "met" | "locked" | "base"
local function getNodeState(key, isBase)
    if isBase then
        return isSystemActive(key) and "active" or "locked"
    end
    local met = Deps.checkDependencies(key)
    local active = isSystemActive(key)
    if active then return "active" end
    if met then return "met" end
    return "locked"
end

-- Node color by state
local function nodeColor(state)
    if state == "active" then
        return {0.25, 0.65, 0.35, 0.95}, {0.5, 0.95, 0.55, 1}
    elseif state == "met" then
        return {0.75, 0.7, 0.25, 0.95}, {0.95, 0.9, 0.45, 1}
    else
        return {0.45, 0.22, 0.18, 0.95}, {0.75, 0.45, 0.35, 1}
    end
end

-- ============================================================
-- GRAPH VIEW
-- ============================================================

-- Compute layout: returns list of { chainLabel, chainY, baseNodes=[], depNodes=[], connections={} }
-- Each node: { key, x, y, w, h, state, isBase }
-- Each connection: { fromX, fromY, toX, toY, active }
local function computeGraphLayout(panelX, contentTop)
    local chains = {}
    local y = contentTop

    for _, chain in ipairs(CHAINS) do
        local chainEntry = {
            label = chain.label,
            chainY = y,
            baseNodes = {},
            depNodes = {},
            connections = {},
        }

        -- Header
        y = y + CHAIN_HEADER_H

        -- Base nodes (1 or more)
        local bases = chain.multiBase and chain.bases or {chain.base}
        local baseNodeY = y
        local baseX = panelX + 24
        for i, baseKey in ipairs(bases) do
            local nodeY = baseNodeY + (i - 1) * (NODE_H + 6)
            local state = getNodeState(baseKey, true)
            table.insert(chainEntry.baseNodes, {
                key = baseKey,
                x = baseX,
                y = nodeY,
                w = NODE_W,
                h = NODE_H,
                state = state,
                isBase = true,
            })
        end

        -- Determine base block height (for vertical centering)
        local baseBlockH = #bases * NODE_H + (#bases - 1) * 6
        local depStartX = baseX + NODE_W + NODE_GAP_X + 30  -- extra gap for connection curves

        -- Dependent nodes: spread horizontally, vertically centered to base block
        local numDeps = #chain.systems
        local depY = baseNodeY + (baseBlockH - NODE_H) / 2
        -- If many deps, stack in 2 rows
        local maxPerRow = 4
        for i, sysKey in ipairs(chain.systems) do
            local row = math.floor((i - 1) / maxPerRow)
            local col = (i - 1) % maxPerRow
            local nodeX = depStartX + col * (NODE_W + NODE_GAP_X)
            local nodeY = depY + row * (NODE_H + 8)
            local state = getNodeState(sysKey, false)
            table.insert(chainEntry.depNodes, {
                key = sysKey,
                x = nodeX,
                y = nodeY,
                w = NODE_W,
                h = NODE_H,
                state = state,
                isBase = false,
            })
        end

        -- Compute chain height (tallest of base block and dep rows)
        local depRows = math.ceil(numDeps / maxPerRow)
        local depBlockH = math.max(NODE_H, depRows * NODE_H + (depRows - 1) * 8)
        local chainH = math.max(baseBlockH, depBlockH)

        -- Build connections: each dep node connects to each base node
        for _, depNode in ipairs(chainEntry.depNodes) do
            local depMet = (depNode.state ~= "locked")
            local depActive = (depNode.state == "active")
            for _, baseNode in ipairs(chainEntry.baseNodes) do
                local baseActive = (baseNode.state == "active")
                -- Connection from base right edge to dep left edge
                local fromX = baseNode.x + baseNode.w
                local fromY = baseNode.y + baseNode.h / 2
                local toX = depNode.x
                local toY = depNode.y + depNode.h / 2
                table.insert(chainEntry.connections, {
                    fromX = fromX, fromY = fromY,
                    toX = toX, toY = toY,
                    fromKey = baseNode.key,
                    toKey = depNode.key,
                    active = baseActive and depActive,
                    met = baseActive and depMet,
                })
            end
        end

        y = y + chainH + CHAIN_GAP
        chains[#chains + 1] = chainEntry
    end

    return chains
end

-- Draw a single node (rounded rectangle with text)
-- v3.11.945: added isRelated and isSelected params for click-to-focus dimming
-- v3.11.946: added isMatched param for search dimming
local function drawNode(node, font, smallFont, isRelated, isSelected, isMatched)
    -- Apply dimming if focus is active and this node is not related
    -- OR if search is active and this node doesn't match
    local focusDim = (selectedKey ~= nil) and (not isRelated) and (not isSelected)
    local searchDim = (searchActive and searchQuery ~= "") and (not isMatched)
    local dim = focusDim or searchDim
    local alphaMul = dim and 0.2 or 1.0

    local fillCol, borderCol = nodeColor(node.state)
    love.graphics.setColor(fillCol[1], fillCol[2], fillCol[3], fillCol[4] * alphaMul)
    love.graphics.rectangle("fill", node.x, node.y, node.w, node.h, 4, 4, 4, 4)
    love.graphics.setColor(borderCol[1], borderCol[2], borderCol[3], borderCol[4] * alphaMul)
    love.graphics.setLineWidth(node.isBase and 2 or 1)
    love.graphics.rectangle("line", node.x, node.y, node.w, node.h, 4, 4, 4, 4)
    love.graphics.setLineWidth(1)

    -- Status symbol
    local symbol
    if node.state == "active" then symbol = "✓"
    elseif node.state == "met" then symbol = "⚠"
    else symbol = "✗" end

    -- Label (v3.11.946: highlight matched substring)
    love.graphics.setColor(0.97, 0.97, 0.97, alphaMul)
    local label = displayName(node.key)
    -- Truncate if too long
    if smallFont then love.graphics.setFont(smallFont) end
    local maxTextW = node.w - 28
    local truncated = false
    if love.graphics.getFont():getWidth(label) > maxTextW then
        while #label > 3 and love.graphics.getFont():getWidth(label .. "…") > maxTextW do
            label = label:sub(1, -2)
        end
        label = label .. "…"
        truncated = true
    end
    -- v3.11.946: If search is active and this node matches, highlight the matched part
    if searchActive and searchQuery ~= "" and isMatched and not truncated then
        local lowerLabel = label:lower()
        local lowerQuery = searchQuery:lower()
        local startIdx, endIdx = lowerLabel:find(lowerQuery, 1, true)
        if startIdx then
            -- Draw parts: before, match (highlighted), after
            local before = label:sub(1, startIdx - 1)
            local matchPart = label:sub(startIdx, endIdx)
            local after = label:sub(endIdx + 1)
            local labelY = node.y + (node.h - love.graphics.getFont():getHeight()) / 2
            local curX = node.x + 8
            if before ~= "" then
                love.graphics.setColor(0.97, 0.97, 0.97, alphaMul)
                love.graphics.print(before, curX, labelY)
                curX = curX + love.graphics.getFont():getWidth(before)
            end
            -- Highlight matched part with yellow background
            local matchW = love.graphics.getFont():getWidth(matchPart)
            love.graphics.setColor(1, 0.85, 0.3, 0.35 * alphaMul)
            love.graphics.rectangle("fill", curX, labelY, matchW, love.graphics.getFont():getHeight(), 2, 2, 2, 2)
            love.graphics.setColor(1, 0.95, 0.5, alphaMul)
            love.graphics.print(matchPart, curX, labelY)
            curX = curX + matchW
            if after ~= "" then
                love.graphics.setColor(0.97, 0.97, 0.97, alphaMul)
                love.graphics.print(after, curX, labelY)
            end
        else
            love.graphics.print(label, node.x + 8, node.y + (node.h - love.graphics.getFont():getHeight()) / 2)
        end
    else
        love.graphics.print(label, node.x + 8, node.y + (node.h - love.graphics.getFont():getHeight()) / 2)
    end

    -- Symbol on right
    love.graphics.setFont(font)
    local symX = node.x + node.w - 16
    love.graphics.print(symbol, symX, node.y + (node.h - font:getHeight()) / 2)

    -- Base indicator (small triangle in top-left)
    if node.isBase then
        love.graphics.setColor(0.95, 0.85, 0.5, alphaMul)
        local tri = 5
        love.graphics.polygon("fill",
            node.x, node.y,
            node.x + tri, node.y,
            node.x, node.y + tri)
    end

    -- Selected node: pulsing golden border (v3.11.945)
    if isSelected then
        local t = love.timer.getTime() * 3
        local pulse = 0.6 + 0.4 * (0.5 + 0.5 * math.sin(t))
        love.graphics.setColor(1, 0.85, 0.3, pulse)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", node.x - 2, node.y - 2, node.w + 4, node.h + 4, 6, 6, 6, 6)
        love.graphics.setLineWidth(1)
    -- v3.11.946: Search match highlight (cyan outline) — only if not selected and matches search
    elseif searchActive and searchQuery ~= "" and isMatched and not dim then
        love.graphics.setColor(0.4, 0.85, 1, 0.7)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", node.x - 1, node.y - 1, node.w + 2, node.h + 2, 5, 5, 5, 5)
        love.graphics.setLineWidth(1)
    -- Hover highlight (only when not dimmed)
    elseif hoveredNode and hoveredNode.key == node.key and not dim then
        love.graphics.setColor(1, 1, 1, 0.95)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", node.x - 1, node.y - 1, node.w + 2, node.h + 2, 5, 5, 5, 5)
        love.graphics.setLineWidth(1)
    end
end

-- Draw a bezier connection between two points
-- v3.11.945: added isRelated param for dimming unrelated connections (focus mode)
-- v3.11.946: added isSearchRelated param for dimming non-matching connections (search mode)
local function drawConnection(conn, isRelated, isSearchRelated)
    local focusDim = (selectedKey ~= nil) and (not isRelated)
    local searchDim = (searchActive and searchQuery ~= "") and (not isSearchRelated)
    local dim = focusDim or searchDim
    local alphaMul = dim and 0.1 or 1.0
    local ctrlOffset = math.abs(conn.toX - conn.fromX) * 0.5
    -- Color: bright if both ends active, dim if base active but dep not, very dim if base inactive
    if conn.active then
        love.graphics.setColor(0.4, 0.95, 0.45, 0.85 * alphaMul)
        love.graphics.setLineWidth(2)
    elseif conn.met then
        love.graphics.setColor(0.85, 0.75, 0.3, 0.6 * alphaMul)
        love.graphics.setLineWidth(1.5)
    else
        love.graphics.setColor(0.5, 0.3, 0.25, 0.45 * alphaMul)
        love.graphics.setLineWidth(1)
    end
    -- If this connection is directly connected to the selected node, boost it
    if selectedKey and isRelated and (conn.fromKey == selectedKey or conn.toKey == selectedKey) then
        love.graphics.setColor(1, 0.85, 0.3, 1)
        love.graphics.setLineWidth(3)
    -- v3.11.946: If search is active and at least one endpoint matches, boost with cyan
    elseif searchActive and searchQuery ~= "" and isSearchRelated and not dim then
        love.graphics.setColor(0.4, 0.85, 1, 0.9)
        love.graphics.setLineWidth(2)
    end
    -- Bezier curve
    love.graphics.setLineJoin("round")
    love.graphics.line(
        conn.fromX, conn.fromY,
        conn.fromX + ctrlOffset, conn.fromY,
        conn.toX - ctrlOffset, conn.toY,
        conn.toX, conn.toY
    )
    love.graphics.setLineWidth(1)
end

function TechTreePanel.drawGraph(panelX, contentTop, contentAreaH, panelW, smallFont, font)
    -- Scissor
    love.graphics.setScissor(panelX + 4, contentTop, panelW - 8, contentAreaH)

    local chains = computeGraphLayout(panelX, contentTop - scrollOffset)

    -- v3.11.945: compute related set if a node is focused
    local relatedSet = nil
    if selectedKey then
        relatedSet = computeRelatedKeys(selectedKey)
    end

    -- Pass 1: draw all connections (behind nodes)
    for _, chain in ipairs(chains) do
        for _, conn in ipairs(chain.connections) do
            local isRelated = true
            if selectedKey then
                isRelated = isConnectionRelated(conn, conn.fromKey, conn.toKey, relatedSet)
            end
            local isSearchRelated = isConnectionSearchRelated(conn.fromKey, conn.toKey)
            drawConnection(conn, isRelated, isSearchRelated)
        end
    end

    -- Pass 2: draw chain headers (dim if focus or search active)
    local headerAlpha = 1.0
    if selectedKey then headerAlpha = 0.4 end
    if searchActive and searchQuery ~= "" then headerAlpha = math.min(headerAlpha, 0.4) end
    for _, chain in ipairs(chains) do
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.6, 0.5, 0.3, headerAlpha)
        love.graphics.print("═══ " .. chain.label .. " ═══", panelX + 20, chain.chainY - scrollOffset)
    end

    -- Pass 3: draw all nodes
    for _, chain in ipairs(chains) do
        for _, node in ipairs(chain.baseNodes) do
            local isRelated = (not selectedKey) or (relatedSet[node.key] ~= nil)
            local isSelected = (selectedKey == node.key)
            local isMatched = isSearchMatch(node.key)
            drawNode(node, font, smallFont, isRelated, isSelected, isMatched)
        end
        for _, node in ipairs(chain.depNodes) do
            local isRelated = (not selectedKey) or (relatedSet[node.key] ~= nil)
            local isSelected = (selectedKey == node.key)
            local isMatched = isSearchMatch(node.key)
            drawNode(node, font, smallFont, isRelated, isSelected, isMatched)
        end
    end

    love.graphics.setScissor()

    -- Compute total content height for scrollbar
    if #chains > 0 then
        local last = chains[#chains]
        local totalH = (last.chainY - (contentTop - scrollOffset)) + CHAIN_HEADER_H + NODE_H + CHAIN_GAP
        if totalH > contentAreaH then
            local sbX = panelX + panelW - 14
            local sbW = 6
            local sbH = contentAreaH
            local maxScroll = totalH - contentAreaH
            if scrollOffset > maxScroll then scrollOffset = maxScroll end
            love.graphics.setColor(0.05, 0.06, 0.08, 1)
            love.graphics.rectangle("fill", sbX, contentTop, sbW, sbH, 2, 2, 2, 2)
            local thumbH = math.max(20, (contentAreaH / totalH) * sbH)
            local thumbY = contentTop + (scrollOffset / maxScroll) * (sbH - thumbH)
            love.graphics.setColor(0.5, 0.55, 0.7, 0.9)
            love.graphics.rectangle("fill", sbX + 1, thumbY, sbW - 2, thumbH, 2, 2, 2, 2)
        end
    end

    -- Tooltip on hovered node
    if hoveredNode then
        local deps = Deps.getDependencies(hoveredNode.key)
        local lines = {}
        table.insert(lines, "📦 " .. displayName(hoveredNode.key))
        if hoveredNode.isBase then
            table.insert(lines, "Status: BASE sistem (" .. (hoveredNode.state == "active" and "✓ aktiven" or "✗ neaktiven") .. ")")
        else
            if hoveredNode.state == "active" then
                table.insert(lines, "Status: ✓ AKTIVNA (zgradba prisotna)")
            elseif hoveredNode.state == "met" then
                table.insert(lines, "Status: ⚠ razpoložljiv (odvisnosti met)")
            else
                table.insert(lines, "Status: ✗ zaklenjen (odvisnosti niso met)")
            end
        end
        if #deps > 0 then
            local parts = {}
            for _, d in ipairs(deps) do
                local active = isSystemActive(d)
                table.insert(parts, displayName(d) .. (active and " ✓" or " ✗"))
            end
            table.insert(lines, "Zahteva: " .. table.concat(parts, ", "))
        else
            table.insert(lines, "Zahteva: (brez odvisnosti)")
        end

        -- v3.11.945: Show dependent count (systems that depend on this one)
        local dependentCount = 0
        for _, chain in ipairs(CHAINS) do
            for _, sysKey in ipairs(chain.systems) do
                local sysPrereqs = Deps.getDependencies(sysKey)
                for _, p in ipairs(sysPrereqs) do
                    if p == hoveredNode.key then
                        dependentCount = dependentCount + 1
                        break
                    end
                end
            end
        end
        if dependentCount > 0 then
            table.insert(lines, string.format("Odvisniki: %d sistemov → tega", dependentCount))
        end

        -- v3.11.945: Show focus hint
        -- v3.11.947: Show path mode info
        -- v3.11.948: Show double-click hint
        if selectedKey == hoveredNode.key then
            local modeLabel = pathMode == "transitive" and "celotna pot" or "direktno"
            table.insert(lines, string.format("🎯 FOKUSIRANO [%s] (click/F: počisti, T: preklopi)", modeLabel))
        else
            table.insert(lines, "💡 click: fokusiraj sorodne")
        end
        table.insert(lines, "🚀 2x click: odpri v Royal Systems Panel")

        -- Draw tooltip box
        love.graphics.setFont(smallFont)
        local tipW = 0
        for _, l in ipairs(lines) do
            local lw = smallFont:getWidth(l)
            if lw > tipW then tipW = lw end
        end
        tipW = tipW + 16
        local tipH = #lines * (smallFont:getHeight() + 2) + 10
        local tipX = mouseX + 16
        local tipY = mouseY + 16
        -- Keep on screen
        local W = love.graphics.getWidth()
        local H = love.graphics.getHeight()
        if tipX + tipW > W - 8 then tipX = mouseX - tipW - 16 end
        if tipY + tipH > H - 8 then tipY = mouseY - tipH - 16 end

        love.graphics.setColor(0.05, 0.06, 0.08, 0.97)
        love.graphics.rectangle("fill", tipX, tipY, tipW, tipH, 4, 4, 4, 4)
        love.graphics.setColor(0.6, 0.75, 0.95, 0.9)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", tipX, tipY, tipW, tipH, 4, 4, 4, 4)
        for i, l in ipairs(lines) do
            if i == 1 then
                love.graphics.setColor(0.95, 0.85, 0.5, 1)
            elseif l:find("🎯") then
                love.graphics.setColor(1, 0.85, 0.3, 1)
            elseif l:find("💡") then
                love.graphics.setColor(0.7, 0.85, 0.7, 1)
            elseif l:find("🚀") then
                love.graphics.setColor(0.5, 0.85, 1, 1)
            else
                love.graphics.setColor(0.85, 0.88, 0.9, 1)
            end
            love.graphics.print(l, tipX + 8, tipY + 6 + (i - 1) * (smallFont:getHeight() + 2))
        end
        love.graphics.setFont(font)
    end
end

-- ============================================================
-- TEXT VIEW (legacy)
-- ============================================================

function TechTreePanel.drawText(panelX, contentTop, contentAreaH, panelW, smallFont, font)
    love.graphics.setScissor(panelX + 4, contentTop, panelW - 8, contentAreaH)

    local y = contentTop - scrollOffset
    local x = panelX + 20

    for _, chain in ipairs(CHAINS) do
        -- Chain header
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.6, 0.5, 0.3, 1)
        love.graphics.print("═══ " .. chain.label .. " ═══", x, y)
        y = y + 18

        -- Base system(s)
        if chain.multiBase then
            for _, baseKey in ipairs(chain.bases) do
                local active = isSystemActive(baseKey)
                local symbol = active and "✓" or "✗"
                local color = active and {0.4, 0.85, 0.4, 1} or {0.95, 0.5, 0.3, 1}
                love.graphics.setColor(color)
                love.graphics.print(string.format("  📦 %s (%s)", displayName(baseKey), symbol), x + 8, y)
                y = y + 14
            end
        else
            local active = isSystemActive(chain.base)
            local symbol = active and "✓" or "✗"
            local color = active and {0.4, 0.85, 0.4, 1} or {0.95, 0.5, 0.3, 1}
            love.graphics.setColor(color)
            love.graphics.print(string.format("  📦 %s (%s)", displayName(chain.base), symbol), x + 8, y)
            y = y + 14
        end

        -- Dependent systems
        for _, sysKey in ipairs(chain.systems) do
            local met, unmet = Deps.checkDependencies(sysKey)
            local active = isSystemActive(sysKey)
            local symbol
            local color
            if active then
                symbol = "✓ aktivna"
                color = {0.4, 0.85, 0.4, 1}
            elseif met then
                symbol = "⚠ razpoložljiv"
                color = {0.85, 0.85, 0.3, 1}
            else
                symbol = "✗ zaklenjen"
                color = {0.6, 0.4, 0.3, 1}
            end
            love.graphics.setColor(color)
            love.graphics.print(string.format("    └─ %s [%s]", displayName(sysKey), symbol), x + 8, y)
            y = y + 14
        end

        y = y + 8
    end

    love.graphics.setScissor()

    -- Scrollbar
    local totalContentH = y - (contentTop - scrollOffset)
    if totalContentH > contentAreaH then
        local sbX = panelX + panelW - 14
        local sbW = 6
        local sbH = contentAreaH
        local maxScroll = totalContentH - contentAreaH
        if scrollOffset > maxScroll then scrollOffset = maxScroll end
        love.graphics.setColor(0.05, 0.06, 0.08, 1)
        love.graphics.rectangle("fill", sbX, contentTop, sbW, sbH, 2, 2, 2, 2)
        local thumbH = math.max(20, (contentAreaH / totalContentH) * sbH)
        local thumbY = contentTop + (scrollOffset / maxScroll) * (sbH - thumbH)
        love.graphics.setColor(0.5, 0.55, 0.7, 0.9)
        love.graphics.rectangle("fill", sbX + 1, thumbY, sbW - 2, thumbH, 2, 2, 2, 2)
    end
end

-- ============================================================
-- MAIN DRAW
-- ============================================================

function TechTreePanel.draw()
    if not visible then return end

    -- Track mouse for hover
    mouseX, mouseY = love.mouse.getPosition()
    hoveredNode = nil  -- reset each frame; mousemoved will set it

    local W = love.graphics.getWidth()
    local H = love.graphics.getHeight()
    -- Wider panel for graph view (need horizontal space for nodes)
    local panelW = viewMode == "graph" and math.min(960, W - 40) or math.min(620, W - 80)
    local panelH = math.min(680, H - 60)
    local panelX = (W - panelW) / 2
    local panelY = (H - panelH) / 2

    local font = love.graphics.getFont()
    local titleFont = love.graphics.newFont(16)
    local smallFont = love.graphics.newFont(11)

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, W, H)

    -- Panel
    love.graphics.setColor(0.08, 0.09, 0.12, 0.98)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setColor(0.5, 0.65, 0.85, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.9, 0.85, 0.5, 1)
    local titleStr = viewMode == "graph" and "🌳 TECH TREE — Odvisnosti sistemov (GRAF)" or "🌳 TECH TREE — Odvisnosti sistemov (TEKST)"
    love.graphics.print(titleStr, panelX + 16, panelY + 12)
    love.graphics.setFont(font)
    love.graphics.setColor(0.5, 0.6, 0.7, 1)
    if smallFont then love.graphics.setFont(smallFont) end
    local hintStr = viewMode == "graph"
        and "Ctrl+Shift+G: zapri  |  G: tekst  |  /: iskanje  |  click: fokus  |  2x click: odpri sistem  |  T: pot  |  F/ESC: počisti"
        or  "Ctrl+Shift+G: zapri  |  G: graf  |  /: iskanje  |  ↑↓/wheel: scroll  |  zelena=met  oranžna=ne met"
    love.graphics.print(hintStr, panelX + 16, panelY + 36)
    love.graphics.setFont(font)

    -- v3.11.946: Search input box (top-right of panel, in graph view)
    local searchBoxW = 220
    local searchBoxH = 22
    local searchBoxX = panelX + panelW - searchBoxW - 16
    local searchBoxY = panelY + 14
    if viewMode == "graph" then
        -- Box background
        love.graphics.setColor(0.05, 0.06, 0.08, 1)
        love.graphics.rectangle("fill", searchBoxX, searchBoxY, searchBoxW, searchBoxH, 4, 4, 4, 4)
        -- Border (cyan if active, gray if not)
        if searchActive then
            love.graphics.setColor(0.4, 0.85, 1, 1)
        else
            love.graphics.setColor(0.4, 0.45, 0.55, 1)
        end
        love.graphics.setLineWidth(searchActive and 2 or 1)
        love.graphics.rectangle("line", searchBoxX, searchBoxY, searchBoxW, searchBoxH, 4, 4, 4, 4)
        love.graphics.setLineWidth(1)
        -- Search icon
        love.graphics.setColor(0.6, 0.7, 0.8, 1)
        if smallFont then love.graphics.setFont(smallFont) end
        love.graphics.print("🔍", searchBoxX + 6, searchBoxY + (searchBoxH - (smallFont and smallFont:getHeight() or 12)) / 2)
        -- Query text or placeholder
        if searchQuery == "" then
            love.graphics.setColor(0.4, 0.45, 0.5, 1)
            love.graphics.print(searchActive and "tipkaj za iskanje..." or "/ za iskanje",
                searchBoxX + 24, searchBoxY + (searchBoxH - (smallFont and smallFont:getHeight() or 12)) / 2)
        else
            love.graphics.setColor(0.95, 0.95, 0.95, 1)
            love.graphics.print(searchQuery, searchBoxX + 24,
                searchBoxY + (searchBoxH - (smallFont and smallFont:getHeight() or 12)) / 2)
        end
        -- Blinking cursor when active
        if searchActive then
            local cursorVisible = math.floor(cursorBlink * 2) % 2 == 0
            if cursorVisible then
                local cursorTextX = searchBoxX + 24
                if searchQuery ~= "" and smallFont then
                    cursorTextX = cursorTextX + smallFont:getWidth(searchQuery)
                end
                love.graphics.setColor(0.4, 0.85, 1, 1)
                love.graphics.rectangle("fill", cursorTextX + 1, searchBoxY + 4, 2, searchBoxH - 8)
            end
        end
        love.graphics.setFont(font)
    end

    -- Content area
    local contentTop = panelY + 56
    local contentBottom = panelY + panelH - 30
    local contentAreaH = contentBottom - contentTop

    if viewMode == "graph" then
        TechTreePanel.drawGraph(panelX, contentTop, contentAreaH, panelW, smallFont, font)
    else
        TechTreePanel.drawText(panelX, contentTop, contentAreaH, panelW, smallFont, font)
    end

    -- Footer
    love.graphics.setColor(0.4, 0.45, 0.5, 1)
    if smallFont then love.graphics.setFont(smallFont) end
    local focusStr = selectedKey and string.format("  |  🎯 fokus: %s", displayName(selectedKey)) or ""
    -- v3.11.947: Show path mode + related count when focused
    local pathStr = ""
    if selectedKey then
        local relatedSet = computeRelatedKeys(selectedKey)
        local count = 0
        for _ in pairs(relatedSet) do count = count + 1 end
        local modeLabel = pathMode == "transitive" and "celotna pot" or "direktno"
        pathStr = string.format("  |  🔗 %s (%d sorodnih)", modeLabel, count)
    end
    -- v3.11.946: Count search matches
    local searchStr = ""
    if searchActive and searchQuery ~= "" then
        local matchCount = 0
        for _, chain in ipairs(CHAINS) do
            local bases = chain.multiBase and chain.bases or {chain.base}
            for _, bk in ipairs(bases) do
                if isSearchMatch(bk) then matchCount = matchCount + 1 end
            end
            for _, sk in ipairs(chain.systems) do
                if isSearchMatch(sk) then matchCount = matchCount + 1 end
            end
        end
        searchStr = string.format("  |  🔍 \"%s\": %d zadetkov", searchQuery, matchCount)
    end
    love.graphics.print(string.format("65 deps · 25 verig · 8 multi-prereq · mode: %s%s%s%s",
        viewMode, focusStr, pathStr, searchStr),
        panelX + 16, panelY + panelH - 22)
    love.graphics.setFont(font)

    love.graphics.setColor(1, 1, 1, 1)
end

-- ============================================================
-- INPUT HANDLERS
-- ============================================================

-- v3.11.946: Update cursor blink animation
function TechTreePanel.update(dt)
    if not visible then return end
    if searchActive then
        cursorBlink = cursorBlink + dt
    end
end

-- v3.11.946: Receive text input for the search box
function TechTreePanel.textinput(text)
    if not visible then return false end
    if not searchActive then return false end
    -- Only accept printable ASCII characters (avoid control chars)
    if #searchQuery < 30 then
        searchQuery = searchQuery .. text
        cursorBlink = 0  -- reset cursor to visible
    end
    return true
end

function TechTreePanel.keypressed(key)
    if not visible then return false end

    -- v3.11.946: If search is active, intercept most keys for search input
    if searchActive then
        if key == "escape" then
            -- Close search (clears query and exits search mode)
            searchActive = false
            searchQuery = ""
            return true
        end
        if key == "return" or key == "kpenter" then
            -- Keep filter active but exit input mode (so user can scroll/click)
            -- Actually: keep search active so they can keep typing
            -- Just exit input mode by setting searchActive false but keep query as filter
            -- Hmm, simpler: Enter confirms and exits input mode, query stays as filter
            searchActive = false
            -- query stays, so dimming remains until ESC or new search
            return true
        end
        if key == "backspace" then
            if #searchQuery > 0 then
                searchQuery = searchQuery:sub(1, -2)
                cursorBlink = 0
            end
            return true
        end
        -- Allow scroll keys during search
        if key == "up" then
            scrollOffset = math.max(0, scrollOffset - 30)
            return true
        end
        if key == "down" then
            scrollOffset = scrollOffset + 30
            return true
        end
        if key == "pageup" then
            scrollOffset = math.max(0, scrollOffset - 150)
            return true
        end
        if key == "pagedown" then
            scrollOffset = scrollOffset + 150
            return true
        end
        if key == "home" then
            scrollOffset = 0
            return true
        end
        -- Swallow other keys while searching
        return true
    end

    -- v3.11.946: '/' opens search
    if key == "/" then
        searchActive = true
        searchQuery = ""
        cursorBlink = 0
        return true
    end

    -- v3.11.945: ESC clears focus first if set, otherwise closes panel
    -- v3.11.946: Also clears search query if set (but not active)
    if key == "escape" then
        if searchQuery ~= "" and not searchActive then
            searchQuery = ""
            return true
        end
        if selectedKey then
            selectedKey = nil
            return true
        end
        TechTreePanel.toggle()
        return true
    end
    -- v3.11.945: F toggles/clears focus
    if key == "f" then
        if selectedKey then
            selectedKey = nil
        end
        return true
    end
    -- v3.11.947: T toggles path mode (direct vs transitive)
    if key == "t" then
        pathMode = pathMode == "direct" and "transitive" or "direct"
        return true
    end
    if key == "g" then
        viewMode = viewMode == "graph" and "text" or "graph"
        scrollOffset = 0
        selectedKey = nil
        searchActive = false
        searchQuery = ""
        pathMode = "transitive"
        return true
    end
    if key == "up" then
        scrollOffset = math.max(0, scrollOffset - 30)
        return true
    end
    if key == "down" then
        scrollOffset = scrollOffset + 30
        return true
    end
    if key == "pageup" then
        scrollOffset = math.max(0, scrollOffset - 150)
        return true
    end
    if key == "pagedown" then
        scrollOffset = scrollOffset + 150
        return true
    end
    if key == "home" then
        scrollOffset = 0
        return true
    end
    return false
end

function TechTreePanel.wheelmoved(x, y)
    if not visible then return false end
    if y > 0 then
        scrollOffset = math.max(0, scrollOffset - 40)
        return true
    elseif y < 0 then
        scrollOffset = scrollOffset + 40
        return true
    end
    return false
end

function TechTreePanel.mousepressed(x, y, button)
    if not visible then return false end
    if button ~= 1 then return false end
    -- Click outside closes
    local W = love.graphics.getWidth()
    local H = love.graphics.getHeight()
    local panelW = viewMode == "graph" and math.min(960, W - 40) or math.min(620, W - 80)
    local panelH = math.min(680, H - 60)
    local panelX = (W - panelW) / 2
    local panelY = (H - panelH) / 2
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        TechTreePanel.toggle()
        return true
    end

    -- v3.11.945: In graph view, click on a node toggles focus; click on empty space clears focus
    -- v3.11.948: Double-click on a node opens Royal Systems Panel and jumps to that system
    if viewMode == "graph" then
        local contentTop = panelY + 56
        local chains = computeGraphLayout(panelX, contentTop - scrollOffset)
        local clickedKey = nil
        for _, chain in ipairs(chains) do
            for _, node in ipairs(chain.baseNodes) do
                if x >= node.x and x <= node.x + node.w
                   and y >= node.y and y <= node.y + node.h then
                    clickedKey = node.key
                    break
                end
            end
            if clickedKey then break end
            for _, node in ipairs(chain.depNodes) do
                if x >= node.x and x <= node.x + node.w
                   and y >= node.y and y <= node.y + node.h then
                    clickedKey = node.key
                    break
                end
            end
            if clickedKey then break end
        end

        if clickedKey then
            -- v3.11.948: Check for double-click
            local now = love.timer.getTime()
            if lastClickKey == clickedKey and (now - lastClickTime) < DOUBLE_CLICK_THRESHOLD then
                -- Double-click: jump to Royal Systems Panel
                local RoyalPanel = require("states.ui.hud.royal_systems_panel")
                if not RoyalPanel.isVisible() then
                    RoyalPanel.toggle()
                end
                RoyalPanel.jumpToSystem(clickedKey)
                -- Close tech tree panel to show Royal Systems Panel
                TechTreePanel.toggle()
                lastClickTime = 0
                lastClickKey = nil
                return true
            end
            -- Single click: record for double-click detection, toggle focus
            lastClickTime = now
            lastClickKey = clickedKey
            if selectedKey == clickedKey then
                selectedKey = nil
            else
                selectedKey = clickedKey
            end
            return true
        end

        -- Click on empty space inside panel: clear focus
        if selectedKey then
            selectedKey = nil
            return true
        end
    end
    return false
end

-- Mouse moved: detect hovered node in graph view
function TechTreePanel.mousemoved(x, y, dx, dy)
    if not visible then return false end
    if viewMode ~= "graph" then return false end

    local W = love.graphics.getWidth()
    local H = love.graphics.getHeight()
    local panelW = math.min(960, W - 40)
    local panelH = math.min(680, H - 60)
    local panelX = (W - panelW) / 2
    local panelY = (H - panelH) / 2
    local contentTop = panelY + 56

    -- Recompute layout to find node under cursor
    local chains = computeGraphLayout(panelX, contentTop - scrollOffset)
    hoveredNode = nil
    for _, chain in ipairs(chains) do
        for _, node in ipairs(chain.baseNodes) do
            if x >= node.x and x <= node.x + node.w
               and y >= node.y and y <= node.y + node.h then
                hoveredNode = { key = node.key, x = node.x, y = node.y, w = node.w, h = node.h,
                                isBase = node.isBase, state = node.state, chainLabel = chain.label }
                return true
            end
        end
        for _, node in ipairs(chain.depNodes) do
            if x >= node.x and x <= node.x + node.w
               and y >= node.y and y <= node.y + node.h then
                hoveredNode = { key = node.key, x = node.x, y = node.y, w = node.w, h = node.h,
                                isBase = node.isBase, state = node.state, chainLabel = chain.label }
                return true
            end
        end
    end
    return false
end

function TechTreePanel.mousereleased(x, y, button)
    return false
end

return TechTreePanel
