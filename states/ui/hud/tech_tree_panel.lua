-- states/ui/hud/tech_tree_panel.lua
-- Castle Kingdoms 2027 - Tech Tree Visualization Panel
--
-- Shows all system dependency chains in a hierarchical view:
--   * Each chain displayed as a tree: base system → advanced systems
--   * Color-coded: green (met), orange (not met), gray (no deps)
--   * Scrollable if content exceeds panel
--
-- Toggle with Ctrl+Shift+G (G for "Graph").

local Deps = require("objects.Economy.SystemDependencies")
local Registry = require("objects.Economy.RoyalSystemsRegistry")

local TechTreePanel = {}

local visible = false
local scrollOffset = 0

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

function TechTreePanel.toggle()
    visible = not visible
    scrollOffset = 0
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

function TechTreePanel.draw()
    if not visible then return end

    local W = love.graphics.getWidth()
    local H = love.graphics.getHeight()
    local panelW = math.min(620, W - 80)
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
    love.graphics.print("🌳 TECH TREE — Odvisnosti sistemov", panelX + 16, panelY + 12)
    love.graphics.setFont(font)
    love.graphics.setColor(0.5, 0.6, 0.7, 1)
    if smallFont then love.graphics.setFont(smallFont) end
    love.graphics.print("Ctrl+Shift+G: zapri  |  ↑↓/wheel: scroll  |  zelena=met  oranžna=ne met", panelX + 16, panelY + 36)
    love.graphics.setFont(font)

    -- Content area
    local contentTop = panelY + 56
    local contentBottom = panelY + panelH - 30
    local contentAreaH = contentBottom - contentTop

    -- Scissor
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

    -- Footer
    love.graphics.setColor(0.4, 0.45, 0.5, 1)
    if smallFont then love.graphics.setFont(smallFont) end
    love.graphics.print("65 dependencies · 25 verig · 8 multi-prereq sistemi", panelX + 16, panelY + panelH - 22)
    love.graphics.setFont(font)

    love.graphics.setColor(1, 1, 1, 1)
end

function TechTreePanel.keypressed(key)
    if not visible then return false end
    if key == "escape" then
        TechTreePanel.toggle()
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
    local panelW = math.min(620, W - 80)
    local panelH = math.min(680, H - 60)
    local panelX = (W - panelW) / 2
    local panelY = (H - panelH) / 2
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        TechTreePanel.toggle()
        return true
    end
    return false
end

-- Castle Kingdoms 2027 v3.11.939: Mouse moved/released stubs for consistency
function TechTreePanel.mousemoved(x, y, dx, dy)
    return false
end

function TechTreePanel.mousereleased(x, y, button)
    return false
end

return TechTreePanel
