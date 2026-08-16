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
end

function TechTreePanel.isVisible()
    return visible
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
local function drawNode(node, font, smallFont)
    local fillCol, borderCol = nodeColor(node.state)
    love.graphics.setColor(fillCol)
    love.graphics.rectangle("fill", node.x, node.y, node.w, node.h, 4, 4, 4, 4)
    love.graphics.setColor(borderCol)
    love.graphics.setLineWidth(node.isBase and 2 or 1)
    love.graphics.rectangle("line", node.x, node.y, node.w, node.h, 4, 4, 4, 4)
    love.graphics.setLineWidth(1)

    -- Status symbol
    local symbol
    if node.state == "active" then symbol = "✓"
    elseif node.state == "met" then symbol = "⚠"
    else symbol = "✗" end

    -- Label
    love.graphics.setColor(0.97, 0.97, 0.97, 1)
    local label = displayName(node.key)
    -- Truncate if too long
    if smallFont then love.graphics.setFont(smallFont) end
    local maxTextW = node.w - 28
    if love.graphics.getFont():getWidth(label) > maxTextW then
        while #label > 3 and love.graphics.getFont():getWidth(label .. "…") > maxTextW do
            label = label:sub(1, -2)
        end
        label = label .. "…"
    end
    love.graphics.print(label, node.x + 8, node.y + (node.h - love.graphics.getFont():getHeight()) / 2)

    -- Symbol on right
    love.graphics.setFont(font)
    local symX = node.x + node.w - 16
    love.graphics.print(symbol, symX, node.y + (node.h - font:getHeight()) / 2)

    -- Base indicator (small triangle in top-left)
    if node.isBase then
        love.graphics.setColor(0.95, 0.85, 0.5, 1)
        local tri = 5
        love.graphics.polygon("fill",
            node.x, node.y,
            node.x + tri, node.y,
            node.x, node.y + tri)
    end

    -- Hover highlight
    if hoveredNode and hoveredNode.key == node.key then
        love.graphics.setColor(1, 1, 1, 0.95)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", node.x - 1, node.y - 1, node.w + 2, node.h + 2, 5, 5, 5, 5)
        love.graphics.setLineWidth(1)
    end
end

-- Draw a bezier connection between two points
local function drawConnection(conn)
    local ctrlOffset = math.abs(conn.toX - conn.fromX) * 0.5
    -- Color: bright if both ends active, dim if base active but dep not, very dim if base inactive
    if conn.active then
        love.graphics.setColor(0.4, 0.95, 0.45, 0.85)
        love.graphics.setLineWidth(2)
    elseif conn.met then
        love.graphics.setColor(0.85, 0.75, 0.3, 0.6)
        love.graphics.setLineWidth(1.5)
    else
        love.graphics.setColor(0.5, 0.3, 0.25, 0.45)
        love.graphics.setLineWidth(1)
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

    -- Pass 1: draw all connections (behind nodes)
    for _, chain in ipairs(chains) do
        for _, conn in ipairs(chain.connections) do
            drawConnection(conn)
        end
    end

    -- Pass 2: draw chain headers
    for _, chain in ipairs(chains) do
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.6, 0.5, 0.3, 1)
        love.graphics.print("═══ " .. chain.label .. " ═══", panelX + 20, chain.chainY - scrollOffset)
    end

    -- Pass 3: draw all nodes
    for _, chain in ipairs(chains) do
        for _, node in ipairs(chain.baseNodes) do
            drawNode(node, font, smallFont)
        end
        for _, node in ipairs(chain.depNodes) do
            drawNode(node, font, smallFont)
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
        and "Ctrl+Shift+G: zapri  |  G: preklopi na tekst  |  ↑↓/wheel: scroll  |  hover: podrobnosti"
        or  "Ctrl+Shift+G: zapri  |  G: preklopi na graf  |  ↑↓/wheel: scroll  |  zelena=met  oranžna=ne met"
    love.graphics.print(hintStr, panelX + 16, panelY + 36)
    love.graphics.setFont(font)

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
    love.graphics.print(string.format("65 deps · 25 verig · 8 multi-prereq · mode: %s", viewMode),
        panelX + 16, panelY + panelH - 22)
    love.graphics.setFont(font)

    love.graphics.setColor(1, 1, 1, 1)
end

-- ============================================================
-- INPUT HANDLERS
-- ============================================================

function TechTreePanel.keypressed(key)
    if not visible then return false end
    if key == "escape" then
        TechTreePanel.toggle()
        return true
    end
    if key == "g" then
        viewMode = viewMode == "graph" and "text" or "graph"
        scrollOffset = 0
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
