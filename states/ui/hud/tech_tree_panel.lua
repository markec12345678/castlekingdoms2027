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
local PanelAnim = require("states.ui.hud.PanelAnimations")
local UISound = require("objects.Audio.UISoundHelper")

local TechTreePanel = {}

local visible = false
local scrollOffset = 0
local viewMode = "graph"  -- "graph" or "text"

-- v3.12.126: Panel animation state (fade-in/out + slide-up + zoom effect)
local animState = PanelAnim.createState({
    duration = 0.22,
    slideDir = "up",
    slideDist = 26,
    easing = "easeOut",
})

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

local SEARCH_FILE = "tech_tree_search.txt"
local CONFIG_FILE = "tech_tree_config.txt"

-- Load persisted search query on init
local function loadSearchQuery()
    local ok, content = pcall(love.filesystem.read, SEARCH_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")
        if content ~= "" then
            searchQuery = content
        end
    end
end

-- Save search query to file
local function saveSearchQuery()
    pcall(love.filesystem.write, SEARCH_FILE, searchQuery .. "\n")
end

-- Load persisted config (viewMode, pathMode, depthVisible, arrowsVisible, minimapVisible, sortMode, stateFilter) on init
local function loadConfig()
    local ok, content = pcall(love.filesystem.read, CONFIG_FILE)
    if ok and content then
        -- Format: viewMode|pathMode|sortMode|stateFilter|minimapVisible|depthVisible|arrowsVisible
        local fields = {}
        for f in content:gmatch("[^|\n]+") do
            fields[#fields + 1] = f:gsub("%s+$", "")
        end
        if #fields >= 7 then
            if fields[1] == "graph" or fields[1] == "text" then viewMode = fields[1] end
            if fields[2] == "direct" or fields[2] == "transitive" then pathMode = fields[2] end
            if fields[3] == "alphabetical" or fields[3] == "depth" then sortMode = fields[3] end
            if fields[4] == "all" or fields[4] == "active" or fields[4] == "available" or fields[4] == "locked" or fields[4] == "bookmarked" then stateFilter = fields[4] end
            minimapVisible = fields[5] == "true"
            depthVisible = fields[6] == "true"
            arrowsVisible = fields[7] == "true"
        end
    end
end

-- Save config to file
local function saveConfig()
    local data = string.format("%s|%s|%s|%s|%s|%s|%s\n",
        viewMode, pathMode, sortMode, stateFilter,
        tostring(minimapVisible), tostring(depthVisible), tostring(arrowsVisible))
    pcall(love.filesystem.write, CONFIG_FILE, data)
end

-- Load on init
loadSearchQuery()
loadConfig()

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

-- Minimap state (v3.11.949)
-- Compact overview of all 25 chains in the bottom-right corner.
-- Shows current viewport position and allows click-to-scroll.
-- v3.11.957: Also supports drag for continuous scrolling.
local minimapVisible = true  -- toggle with M
local minimapArea = nil  -- {x, y, w, h} set during draw, used by mousepressed
local minimapDragging = false  -- true while mouse is held down on minimap

-- Depth indicator state (v3.11.951)
-- Shows the tech-tree depth of each node (layer 0 = root/base, 1, 2, ...)
-- Computed once via BFS from all root nodes (systems with no dependencies).
local depthVisible = true  -- toggle with D
local depthCache = nil  -- map: key -> depth, built lazily

-- Path direction arrows state (v3.11.952)
-- Draws arrowheads at the dependent end of each bezier curve to indicate
-- the direction of dependency (base → dependent).
local arrowsVisible = true  -- toggle with A

-- Sort mode state (v3.11.953)
-- "alphabetical" = chains ordered as defined in CHAINS (default)
-- "depth" = chains ordered by max depth (shallow → deep), shows tech progression
local sortMode = "alphabetical"  -- toggle with S

-- State filter (v3.11.954)
-- Cycles: "all" → "active" → "met" → "locked" → "all"
-- When not "all", nodes not matching the filter get dimmed (like focus/search).
local stateFilter = "all"  -- cycle with L

-- Keyboard navigation state (v3.11.958)
-- Tab/Shift+Tab cycles through all nodes in display order.
-- keyboardNavIndex is nil when keyboard nav is not active.
-- When set, the node at that index in the flat list gets a distinct highlight.
local keyboardNavIndex = nil  -- nil = inactive, number = index in flat node list
local keyboardNavList = nil  -- flat list of {key, isBase} in display order, rebuilt lazily

-- Bookmark/favorites state (v3.11.959)
-- bookmarks is a set: bookmarks[key] = true if bookmarked.
-- Persisted to tech_tree_bookmarks.txt via love.filesystem.
-- bookmarksOnly, when true, dims non-bookmarked nodes (like focus/search filter).
local bookmarks = {}
local bookmarksOnly = false
local bookmarksLoaded = false  -- lazy load on first use

-- Multi-select state (v3.11.961)
-- Shift+click adds/removes nodes from multiSelect set.
-- When non-empty, the related set is the UNION of all selected keys' related sets.
-- This lets the player compare multiple systems' tech lineages at once.
-- v3.11.964: Persisted to tech_tree_multiselect.txt via love.filesystem.
local multiSelect = {}  -- map: key -> true
local multiSelectLoaded = false  -- lazy load on first use

-- Feedback message state (v3.11.962)
local feedbackMessage = ""
local feedbackMessageTime = 0

-- v3.11.962: Show feedback message (for export/import operations)
local function showFeedback(msg)
    feedbackMessage = msg
    feedbackMessageTime = 3.0
end

-- Config presets state (v3.11.963)
-- 'P' cycles through predefined view configurations for quick switching.
-- v3.11.965: Custom presets (saved by player via Shift+P) are appended after built-in ones.
local PRESETS = {
    {
        name = "Vsi (default)",
        sortMode = "alphabetical",
        stateFilter = "all",
        bookmarksOnly = false,
        depthVisible = true,
        arrowsVisible = true,
        minimapVisible = true,
    },
    {
        name = "Aktivni sistemi",
        sortMode = "depth",
        stateFilter = "active",
        bookmarksOnly = false,
        depthVisible = true,
        arrowsVisible = true,
        minimapVisible = true,
    },
    {
        name = "Razpoložljivi",
        sortMode = "depth",
        stateFilter = "met",
        bookmarksOnly = false,
        depthVisible = true,
        arrowsVisible = true,
        minimapVisible = true,
    },
    {
        name = "Zaklenjeni",
        sortMode = "depth",
        stateFilter = "locked",
        bookmarksOnly = false,
        depthVisible = true,
        arrowsVisible = true,
        minimapVisible = true,
    },
    {
        name = "Zaznamovani",
        sortMode = "alphabetical",
        stateFilter = "all",
        bookmarksOnly = true,
        depthVisible = true,
        arrowsVisible = true,
        minimapVisible = true,
    },
}
local currentPresetIdx = 1  -- 1-indexed

-- v3.11.965: Custom presets (user-defined, persisted)
local customPresets = {}
local customPresetsLoaded = false

-- v3.11.965: Load custom presets from file
local function loadCustomPresets()
    if customPresetsLoaded then return end
    customPresetsLoaded = true
    local path = "tech_tree_custom_presets.txt"
    if love.filesystem.exists(path) then
        local data = love.filesystem.read(path)
        if data then
            -- Format: one preset per line, fields separated by |
            -- name|sortMode|stateFilter|bookmarksOnly|depthVisible|arrowsVisible|minimapVisible
            for line in data:gmatch("[^\n]+") do
                local fields = {}
                for f in line:gmatch("[^|]+") do
                    table.insert(fields, f)
                end
                if #fields >= 7 then
                    table.insert(customPresets, {
                        name = fields[1],
                        sortMode = fields[2],
                        stateFilter = fields[3],
                        bookmarksOnly = fields[4] == "true",
                        depthVisible = fields[5] == "true",
                        arrowsVisible = fields[6] == "true",
                        minimapVisible = fields[7] == "true",
                    })
                end
            end
        end
    end
end

-- v3.11.965: Save custom presets to file
local function saveCustomPresets()
    local lines = {}
    for _, p in ipairs(customPresets) do
        table.insert(lines, string.format("%s|%s|%s|%s|%s|%s|%s",
            p.name, p.sortMode, p.stateFilter,
            tostring(p.bookmarksOnly), tostring(p.depthVisible),
            tostring(p.arrowsVisible), tostring(p.minimapVisible)))
    end
    local data = table.concat(lines, "\n")
    love.filesystem.write("tech_tree_custom_presets.txt", data)
end

-- v3.11.965: Get all presets (built-in + custom)
local function getAllPresets()
    loadCustomPresets()
    local all = {}
    for _, p in ipairs(PRESETS) do
        table.insert(all, p)
    end
    for _, p in ipairs(customPresets) do
        table.insert(all, p)
    end
    return all
end

-- v3.11.963: Apply a preset configuration (v3.11.965: uses getAllPresets)
local function applyPreset(idx)
    local all = getAllPresets()
    if idx < 1 or idx > #all then return end
    local p = all[idx]
    sortMode = p.sortMode
    stateFilter = p.stateFilter
    bookmarksOnly = p.bookmarksOnly
    depthVisible = p.depthVisible
    arrowsVisible = p.arrowsVisible
    minimapVisible = p.minimapVisible
    -- Invalidate nav list since sort mode might have changed
    keyboardNavList = nil
    keyboardNavIndex = nil
    currentPresetIdx = idx
    showFeedback("📋 Preset: " .. p.name)
end

-- v3.11.965: Save current config as a custom preset
local function saveCurrentAsPreset()
    loadCustomPresets()
    local idx = #customPresets + 1
    local preset = {
        name = "Custom " .. idx,
        sortMode = sortMode,
        stateFilter = stateFilter,
        bookmarksOnly = bookmarksOnly,
        depthVisible = depthVisible,
        arrowsVisible = arrowsVisible,
        minimapVisible = minimapVisible,
    }
    table.insert(customPresets, preset)
    saveCustomPresets()
    showFeedback("💾 Preset shranjen: " .. preset.name .. " (skupaj " .. #customPresets .. " custom)")
end

-- v3.11.966: Delete the currently selected custom preset (if it's a custom one)
-- Built-in presets (index 1..#PRESETS) cannot be deleted.
local function deleteCurrentCustomPreset()
    loadCustomPresets()
    if #customPresets == 0 then
        showFeedback("✗ Ni custom presetov za brisanje")
        return
    end
    -- Check if currentPresetIdx points to a custom preset
    if currentPresetIdx <= #PRESETS then
        showFeedback("✗ Built-in presetov ni mogoče brisati")
        return
    end
    -- Calculate the custom preset index (0-indexed within customPresets)
    local customIdx = currentPresetIdx - #PRESETS
    if customIdx < 1 or customIdx > #customPresets then
        showFeedback("✗ Ni custom presetov za brisanje")
        return
    end
    local name = customPresets[customIdx].name
    table.remove(customPresets, customIdx)
    saveCustomPresets()
    -- Adjust currentPresetIdx: go to the previous preset (or last if we deleted the last)
    local totalPresets = #PRESETS + #customPresets
    if totalPresets > 0 then
        if currentPresetIdx > totalPresets then
            currentPresetIdx = totalPresets
        end
    else
        currentPresetIdx = 1
    end
    showFeedback("🗑 Preset izbrisan: " .. name .. " (ostalo " .. #customPresets .. " custom)")
end

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
    -- v3.11.970: New sub-chains
    { label = "VRTNARSTVO+", base = "Metalwork+MasonStonecutter+WoodLathe+GardenRake", systems = {"PruningShearsMaker", "PruningSawMaker", "HedgeShearsMaker", "BonsaiCultivator", "FountainMaker", "TrellisMaker", "VineyardPlanter"}, multiBase = true, bases = {"Metalwork", "MasonStonecutter", "WoodLathe", "GardenRake"} },
    { label = "ČEBELARSTVO+", base = "WaxTablet+GlassBench+HoneyDipperMaker", systems = {"WaxSealPresser", "LostWaxMolderMaker", "ApiaryKeeper"}, multiBase = true, bases = {"WaxTablet", "GlassBench", "HoneyDipperMaker"} },
    { label = "KOVANJE DENARJA+", base = "Metalwork+CoinDieMaker+CoinPressMaker", systems = {"CoinBlankMaker", "CoinScaleMaker", "CoinSorterMaker"}, multiBase = true, bases = {"Metalwork", "CoinDieMaker", "CoinPressMaker"} },
    -- v3.11.971: Surgical+ chain
    { label = "KIRURGIJA+", base = "Metalwork+SurgicalLancetMaker+ApothecaryMortar", systems = {"BoneSawMaker", "SutureMaker", "ForcepsMaker"}, multiBase = true, bases = {"Metalwork", "SurgicalLancetMaker", "ApothecaryMortar"} },
    -- v3.11.972: Astronomy+ chain
    { label = "ASTRONOMIJA+", base = "Metalwork+AstrolabeRingMaker+QuadrantMaker+GlassBench", systems = {"ArmillarySphereMaker", "SextantMaker", "TelescopeMaker"}, multiBase = true, bases = {"Metalwork", "AstrolabeRingMaker", "QuadrantMaker", "GlassBench"} },
    -- v3.11.973: Glassmaking+ chain
    { label = "STKLARSTVO+", base = "GlassBench+GlassBeadMaker+GlassColorantMaker+Metalwork", systems = {"CrystalGobletMaker", "StainedGlassMaker", "HourglassMaker", "GlassFurnaceMaker", "GlassCutterMaker", "GlassPolishingWheelMaker"}, multiBase = true, bases = {"GlassBench", "GlassBeadMaker", "GlassColorantMaker", "Metalwork"} },
    -- v3.11.974: Foundry+ chain
    { label = "LIVARSTVO+", base = "ForgeTuyere+Metalwork", systems = {"CrucibleMaker", "CrucibleFurnaceMaker", "CastingLadleMaker", "CoreBoxMaker", "SandMullerMaker", "IngotMolderMaker"}, multiBase = true, bases = {"ForgeTuyere", "Metalwork"} },
    -- v3.11.975: Bookbinding+ chain
    { label = "KNJIGOVEZSTVO+", base = "WoodLathe+Metalwork+BookPress+ParchmentMaker+BookbindingPress+InkMaker", systems = {"BookClaspMaker", "CodexBinder", "ChronicleBinder", "BookbindingAwlMaker", "BookShelfMaker", "QuillCutterMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "BookPress", "ParchmentMaker", "BookbindingPress", "InkMaker"} },
    -- v3.11.976: Textile+ chain
    { label = "TEKSTIL+", base = "SpinningWheel+LoomHeddle+TapestryLoom+DyeStuff+RawhideTanner+Metalwork", systems = {"CanvasWeaver", "CarpetLoom", "DyeVatMaker", "BobbinMaker", "ClothPresserMaker", "LeatherBurnisherMaker"}, multiBase = true, bases = {"SpinningWheel", "LoomHeddle", "TapestryLoom", "DyeStuff", "RawhideTanner", "Metalwork"} },
    -- v3.11.977: Pottery+ chain
    { label = "LONČARSTVO+", base = "PotteryWheel+MasonStonecutter+BrickMaker", systems = {"ClayDigger", "ClayPipeMaker", "GlazeSieveMaker", "MosaicTileMaker", "KilnFurnitureMaker", "PotteryKiln"}, multiBase = true, bases = {"PotteryWheel", "MasonStonecutter", "BrickMaker"} },
    -- v3.11.978: Musical Instruments+ chain
    { label = "INSTRUMENTI+", base = "Metalwork+WoodLathe+SpinningWheel+RawhideTanner+BellMaker", systems = {"HarpMaker", "LuteMaker", "OrganPipeMaker", "BagpipeMaker", "CymbalMaker", "ShawmMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel", "RawhideTanner", "BellMaker"} },
    -- v3.11.979: Candle/Wax+ chain
    { label = "SVEČE IN VOSAK+", base = "Metalwork+WaxTablet+CandlestickBaseMaker+CandlestickMaker+GlassBench", systems = {"CandelabraMaker", "ChandelierMaker", "CandlestickMaker", "CandleMoldMaker", "WaxDipperMaker", "LanternStreetLight"}, multiBase = true, bases = {"Metalwork", "WaxTablet", "CandlestickBaseMaker", "CandlestickMaker", "GlassBench"} },
    -- v3.11.980: Fishing+ chain
    { label = "RIBOLOV+", base = "NetMaker+Metalwork+WoodLathe+ForgeTuyere", systems = {"FishHookMaker", "BaitBoxMaker", "FishingLineSpoolMaker", "FishingRodMaker", "FishSmoker", "FishingBoatMaker"}, multiBase = true, bases = {"NetMaker", "Metalwork", "WoodLathe", "ForgeTuyere"} },
    -- v3.11.981: Brewing/Baking+ chain
    { label = "PIVOVARSTVO/PEKSTVO+", base = "BranSeparator+FlourSieve+Metalwork+GlassBench+AleBrewer+BreadBaker+PotteryWheel", systems = {"AlambicStillMaker", "DistillationApparatusMaker", "BrewerAdvancedDistillery", "BreadMoldMaker", "BakerConfectioner", "FlourSifterMaker"}, multiBase = true, bases = {"BranSeparator", "FlourSieve", "Metalwork", "GlassBench", "AleBrewer", "BreadBaker", "PotteryWheel"} },
    -- v3.11.982: Masonry+ chain
    { label = "KAMNOSEŠTVO+", base = "MasonStonecutter+Metalwork+BrickMaker+ChiselBladeMaker", systems = {"MarbleStatueMaker", "CrestCarver", "LimeBurner", "StoneLintelMaker", "ChiselBladeMaker", "MortarPestleMaker"}, multiBase = true, bases = {"MasonStonecutter", "Metalwork", "BrickMaker", "ChiselBladeMaker"} },
    -- v3.11.983: Dye/Pigment+ chain
    { label = "BARVILA+", base = "DyeStuff+PigmentGrinderMaker+GlassBench+InkMaker+Metalwork+WoodLathe", systems = {"PigmentGrinderMaker", "PaintMaker", "PaintbrushMaker", "InkwellMaker", "GildingBrushMaker", "WashstandMaker"}, multiBase = true, bases = {"DyeStuff", "PigmentGrinderMaker", "GlassBench", "InkMaker", "Metalwork", "WoodLathe"} },
    -- v3.11.984: Kitchen+ chain
    { label = "KUHINJA+", base = "BreadBaker+FlourSieve+ApothecaryMortar+Metalwork+WoodLathe+CutlerySmith+BrickMaker", systems = {"SpiceGrinderMaker", "CoffeeRoaster", "ButterChurner", "CheeseMaker", "KitchenKnifeMaker", "ConfectionOvenMaker"}, multiBase = true, bases = {"BreadBaker", "FlourSieve", "ApothecaryMortar", "Metalwork", "WoodLathe", "CutlerySmith", "BrickMaker"} },
    -- v3.11.985: Clockmaking+ chain
    { label = "URARSTVO+", base = "MasonStonecutter+Metalwork+GlassBench+BellMaker+WoodLathe+PigmentGrinderMaker", systems = {"SundialMaker", "PocketWatchMaker", "MainspringWinderMaker", "EscapementLeverMaker", "PendulumRodMaker", "ClockFacePainter"}, multiBase = true, bases = {"MasonStonecutter", "Metalwork", "GlassBench", "BellMaker", "WoodLathe", "PigmentGrinderMaker"} },
    -- v3.11.986: Mining+ chain
    { label = "RUDARSTVO+", base = "Metalwork+WoodLathe+PickaxeMaker+ForgeTuyere", systems = {"AugerMaker", "DrillPressMaker", "GemMiner", "PickaxeMaker", "AshShovelMaker", "CharcoalBurner"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "PickaxeMaker", "ForgeTuyere"} },
    -- v3.11.987: Armor/Weapon+ chain (5 multi-prereq, 2 CROSS-CHAIN links)
    { label = "OKLEP IN OROŽJE+", base = "Metalwork+WoodLathe+GemMiner+RawhideTanner", systems = {"CeremonialSwordMaker", "HalberdSmith", "LongbowMaker", "RecurveBowMaker", "ParadeShieldMaker", "PresentationAxeMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GemMiner", "RawhideTanner"} },
    -- v3.11.988: Anvil+ chain (5 multi-prereq, 2 CROSS-CHAIN links)
    { label = "NAKOVALO+", base = "Metalwork+ForgeTuyere+GlassBench+WoodLathe", systems = {"AnvilClampMaker", "AnvilFaceHardenerMaker", "AnvilHardyMaker", "AnvilHornPolisherMaker", "AnvilSaddleBlockMaker", "AnvilStumpWedgeMaker"}, multiBase = true, bases = {"Metalwork", "ForgeTuyere", "GlassBench", "WoodLathe"} },
    -- v3.11.989: Garden+ 2 chain (5 multi-prereq, 2 CROSS-CHAIN links)
    { label = "VRTNARSTVO+ 2", base = "Metalwork+WoodLathe+GlassBench", systems = {"GardenSoilAeratorSpikeMaker", "GardenSecateursMaker", "GardenSprayerMaker", "GardenSoilThermometerMaker", "GardenCompostThermometerProbeMaker", "GardenToolRackMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench"} },
    -- v3.11.990: Milling+ chain (5 multi-prereq, 3 CROSS-CHAIN links)
    { label = "MLINARSTVO+", base = "Metalwork+WoodLathe+GlassBench+SpinningWheel", systems = {"MillstoneMaker", "MillstoneSpindleBearingMaker", "MillHopperShakerMaker", "GrainHopperMaker", "MillHopperSightGlassMaker", "MillstoneDresserMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench", "SpinningWheel"} },
    -- v3.11.991: Glass Engraving+ chain (5 multi-prereq, 2 CROSS-CHAIN links)
    { label = "STEKLO REZBARSTVO+", base = "Metalwork+WoodLathe+GlassBench+GemMiner", systems = {"GlassEngraverMaker", "GlassEngravingWheelMaker", "GlassEngravingPointMaker", "GlassEngravingDiamondPointMaker", "GlassEngravingCopperWheelMaker", "GlassEngravingWheelDressingStoneMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench", "GemMiner"} },
    -- v3.11.992: Glass Annealing+ chain (5 multi-prereq, 3 CROSS-CHAIN links)
    { label = "STEKLO ŽARENJE+", base = "Metalwork+ForgeTuyere+GlassBench+WoodLathe", systems = {"GlassAnnealingOvenMaker", "GlassAnnealingOvenThermocoupleMaker", "GlassAnnealingOvenInspectionMirrorMaker", "GlassAnnealingRollerMaker", "GlassAnnealingCartMaker", "GlassAnnealingForkMaker"}, multiBase = true, bases = {"Metalwork", "ForgeTuyere", "GlassBench", "WoodLathe"} },
    -- v3.11.993: Glass Colorant+ chain (5 multi-prereq, 3 CROSS-CHAIN links)
    { label = "STEKLO BARVILA+", base = "PigmentGrinderMaker+MasonStonecutter+Metalwork+WoodLathe", systems = {"GlassColorantMortarMaker", "GlassColorantMortarPestleMaker", "GlassColorantMullerMaker", "GlassColorantSieveMaker", "GlassColorantSpatulaMaker", "GlassColorantDryingTrayMaker"}, multiBase = true, bases = {"PigmentGrinderMaker", "MasonStonecutter", "Metalwork", "WoodLathe"} },
    -- v3.11.994: Glass Kiln+ chain (5 multi-prereq, 3 CROSS-CHAIN links — MasonStonecutter x4!)
    { label = "STEKLO PEČ+", base = "Metalwork+MasonStonecutter+GlassBench+WoodLathe", systems = {"GlassKilnDoorMaker", "GlassKilnBrickSawMaker", "GlassKilnFlueDamperMaker", "GlassKilnMuffleMaker", "GlassKilnFurnitureMaker", "GlassKilnSootScraperMaker"}, multiBase = true, bases = {"Metalwork", "MasonStonecutter", "GlassBench", "WoodLathe"} },
    -- v3.11.995: Foundry Accessories+ 2 chain (5 multi-prereq, 3 CROSS-CHAIN links)
    { label = "LIVARSKI PRIBOR+ 2", base = "Metalwork+WoodLathe+MasonStonecutter+GlassBench", systems = {"SandMullerBladeMaker", "MoldFlaskAlignmentPinMaker", "CoreGasEscapeChannelMaker", "CastingLadleSkimmerHookMaker", "PouringLadleSpoutLinerMaker", "SandRiddleMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "MasonStonecutter", "GlassBench"} },
    -- v3.11.996: Glass Batch+ chain (5 multi-prereq, 3 CROSS-CHAIN links)
    { label = "STEKLO MEŠANICA+", base = "Metalwork+ForgeTuyere+WoodLathe+MasonStonecutter", systems = {"GlassBatchFurnaceMaker", "GlassBatchSmelter", "GlassBatchMixerMaker", "GlassBatchFeederMaker", "GlassBatchMaker", "GlassCulletCrusherMaker"}, multiBase = true, bases = {"Metalwork", "ForgeTuyere", "WoodLathe", "MasonStonecutter"} },
    -- v3.11.997: Glass Forming Tools+ chain (5 multi-prereq, 3 CROSS-CHAIN links)
    { label = "STEKLO OBLIKOVANJE+", base = "Metalwork+MasonStonecutter+WoodLathe", systems = {"GlassMarverMaker", "GlassPuntyRodMaker", "GlassGatheringIronMaker", "GlassShearsMaker", "GlassYokeMaker", "GlassLehrBeltMaker"}, multiBase = true, bases = {"Metalwork", "MasonStonecutter", "WoodLathe"} },
    -- v3.11.998: Foundry Accessories+ 3 chain (Sand/Mold/Core+ 2 — 5 multi-prereq, 3 CROSS-CHAIN links)
    { label = "LIVARSKI PRIBOR+ 3", base = "Metalwork+MasonStonecutter+GlassBench+WoodLathe+PigmentGrinderMaker", systems = {"SandMoldMaker", "MoldDryingOvenMaker", "MoldCoatingBrushMaker", "CoreOvenMaker", "CorePasteMixerMaker", "MoldClampMaker"}, multiBase = true, bases = {"Metalwork", "MasonStonecutter", "GlassBench", "WoodLathe", "PigmentGrinderMaker"} },
    -- v3.11.999: Foundry Accessories+ 4 chain (Sand/Mold/Core+ 3 — 5 multi-prereq, 3 CROSS-CHAIN links)
    { label = "LIVARSKI PRIBOR+ 4", base = "Metalwork+WoodLathe+GlassBench+MasonStonecutter", systems = {"SandConditionerMaker", "SandCoolerMaker", "MoldDryingStandMaker", "MoldWashBoothMaker", "CorePrintBoxMaker", "MoldFlowTesterMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench", "MasonStonecutter"} },
    -- v3.12.000: Foundry Accessories+ 5 chain (Casting/Pouring+ — 5 multi-prereq, 3 CROSS-CHAIN links)
    { label = "LIVARSKI PRIBOR+ 5", base = "Metalwork+ForgeTuyere+GlassBench+MasonStonecutter+WoodLathe", systems = {"CastingLadleNozzleMaker", "CastingLadlePreheatBurnerMaker", "PouringLadleMaker", "PouringLadleLiningCementMaker", "PouringCrucibleTongsMaker", "CastingBreakoutChiselMaker"}, multiBase = true, bases = {"Metalwork", "ForgeTuyere", "GlassBench", "MasonStonecutter", "WoodLathe"} },
    -- v3.12.001: Foundry Accessories+ 6 chain (Sand/Mold/Core+ 4 — 5 multi-prereq, 3 CROSS-CHAIN links)
    { label = "LIVARSKI PRIBOR+ 6", base = "Metalwork+WoodLathe+GlassBench+MasonStonecutter", systems = {"SandCasterMaker", "SandReclaimerMaker", "MoldKilnMaker", "MoldReleaseAgentMaker", "CoreDryingRackMaker", "CrucibleTongsMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench", "MasonStonecutter"} },
    -- v3.12.002: Foundry Accessories+ 7 chain (Sand/Mold/Core+ 5 — 5 multi-prereq, 3 CROSS-CHAIN links)
    { label = "LIVARSKI PRIBOR+ 7", base = "Metalwork+MasonStonecutter+WoodLathe+PigmentGrinderMaker+GlassBench", systems = {"SandBinderDispenserMaker", "SandSieveShakerMaker", "MoldCoatingRollerMaker", "MoldFlaskClampWedgeMaker", "CoreGasVentPinMaker", "PouringConeMaker"}, multiBase = true, bases = {"Metalwork", "MasonStonecutter", "WoodLathe", "PigmentGrinderMaker", "GlassBench"} },
    -- v3.12.003: Foundry Accessories+ 8 chain (Sand/Mold/Core+ 6 — FINAL, exhausts Sand/Mold/Core groups!)
    { label = "LIVARSKI PRIBOR+ 8", base = "Metalwork+GlassBench+WoodLathe+PigmentGrinderMaker+MasonStonecutter", systems = {"SandTestCupMaker", "SanderMaker", "MoldCoatBrushSpinnerMaker", "MoldVentWireCleanerMaker", "CoreVarnishBrushMaker", "CoreWashingDipMaker"}, multiBase = true, bases = {"Metalwork", "GlassBench", "WoodLathe", "PigmentGrinderMaker", "MasonStonecutter"} },
    -- v3.12.004: Foundry Accessories+ 9 chain (Casting/Pouring+ 2 — 6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "LIVARSKI PRIBOR+ 9", base = "Metalwork+MasonStonecutter+WoodLathe+GlassBench", systems = {"CastingLadleLiningTrowelMaker", "CastingLadlePreheatStandMaker", "CastingLadleSkimmerHandleMaker", "PouringCrucibleDrierMaker", "PouringLadleLinerMaker", "PouringLadleSkimmerSieveMaker"}, multiBase = true, bases = {"Metalwork", "MasonStonecutter", "WoodLathe", "GlassBench"} },
    -- v3.12.005: Glass Kiln Accessories+ 2 chain (6 multi-prereq, 3 CROSS-CHAIN links — MasonStonecutter x4!)
    { label = "STEKLO KILN PRIBOR+", base = "Metalwork+MasonStonecutter+GlassBench+WoodLathe", systems = {"GlassKilnDoorChainMaker", "GlassKilnDoorLifterMaker", "GlassKilnBrickTongsMaker", "GlassKilnSealMaker", "GlassKilnSightingPortCoverMaker", "GlassKilnSpyMaker"}, multiBase = true, bases = {"Metalwork", "MasonStonecutter", "GlassBench", "WoodLathe"} },
    -- v3.12.006: Glass Blowing+ 2 chain (6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "STEKLO PIHALSKO+ 2", base = "Metalwork+MasonStonecutter+GlassBench+WoodLathe", systems = {"GlassBenchMaker", "GlassBlowerPipeMaker", "GlassBlowingMoldMaker", "GlassBlowpipeCoolingRackMaker", "GlassCoolingRackMaker", "GlassPipeShearsMaker"}, multiBase = true, bases = {"Metalwork", "MasonStonecutter", "GlassBench", "WoodLathe"} },
    -- v3.12.007: Glass Annealing+ 2 chain (6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "STEKLO ŽARENJE+ 2", base = "Metalwork+MasonStonecutter+GlassBench+WoodLathe", systems = {"GlassAnnealingCradleMaker", "GlassAnnealingOvenDoorWheelMaker", "GlassAnnealingTongJawsMaker", "GlassGloryHoleMaker", "GlassGloryHoleDamperMaker", "GlassPuntyWarmerMaker"}, multiBase = true, bases = {"Metalwork", "MasonStonecutter", "GlassBench", "WoodLathe"} },
    -- v3.12.008: Glass Engraving+ 2 chain (6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "STEKLO REZBARSTVO+ 2", base = "Metalwork+GlassBench+WoodLathe+MasonStonecutter", systems = {"GlassEngravingLatheChuckMaker", "GlassEngravingWheelBearingMaker", "GlassEngravingWheelRestMaker", "GlassPolishingPadMaker", "GlassFritMaker", "GlassShearSpringMaker"}, multiBase = true, bases = {"Metalwork", "GlassBench", "WoodLathe", "MasonStonecutter"} },
    -- v3.12.009: Glass Finishing+ chain (6 multi-prereq, 3 CROSS-CHAIN links — zadnji Glass* paket!)
    { label = "STEKLO DOKONČANJE+", base = "Metalwork+GlassBench+WoodLathe+PigmentGrinderMaker+MasonStonecutter", systems = {"GlassCaneSlicerMaker", "GlassColorantSievingClothMaker", "GlassColorantVialShakerMaker", "GlassMoltenGlassSkimLadleMaker", "GlassRibbonMaker", "GlassSeedMaker"}, multiBase = true, bases = {"Metalwork", "GlassBench", "WoodLathe", "PigmentGrinderMaker", "MasonStonecutter"} },
    -- v3.12.010: Smith Quench+ chain (6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "KOVAŠKI KVAČ+", base = "Metalwork+WoodLathe+GlassBench+MasonStonecutter", systems = {"QuenchBucketMaker", "QuenchOilDipperMaker", "QuenchOilFilterMaker", "QuenchTankDrainValveMaker", "QuenchTankLidGasketMaker", "QuenchTankThermometerMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench", "MasonStonecutter"} },
    -- v3.12.011: Forge+ chain (6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "KOVAŠKA PEČ+", base = "Metalwork+GlassBench+MasonStonecutter+WoodLathe", systems = {"ForgeTuyereCoolerMaker", "ForgeChimneyDamperMaker", "ForgeClinkerBreakerMaker", "ForgeAshPanMaker", "ForgeHoodFlueMaker", "ForgeCokeRakeMaker"}, multiBase = true, bases = {"Metalwork", "GlassBench", "MasonStonecutter", "WoodLathe"} },
    -- v3.12.012: Smith+ chain (6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "KOVAŠKO ORODJE+", base = "Metalwork+MasonStonecutter+GlassBench+WoodLathe", systems = {"SmithHammerFacePolisherMaker", "SmithHammerHandleWedgeMaker", "SmithHammerWedgeMaker", "SmithTongsJawInsertMaker", "SmithTongsRingMaker", "SmithHammerHandleFinisherMaker"}, multiBase = true, bases = {"Metalwork", "MasonStonecutter", "GlassBench", "WoodLathe"} },
    -- v3.12.013: Leather+ chain (6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "USNJE+ 2", base = "RawhideTanner+PigmentGrinderMaker+Metalwork+WoodLathe+MasonStonecutter", systems = {"LeatherConditionerMaker", "LeatherCreaserMaker", "LeatherEdgeBevelerMaker", "LeatherSkiverMaker", "LeatherSplitterMaker", "Leatherworker"}, multiBase = true, bases = {"RawhideTanner", "PigmentGrinderMaker", "Metalwork", "WoodLathe", "MasonStonecutter"} },
    -- v3.12.014: Book Cover+ chain (6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "KNJIGOVEŠTVO+", base = "Metalwork+WoodLathe+MasonStonecutter+PigmentGrinderMaker+RawhideTanner", systems = {"BookCoverBoardShearsMaker", "BookCoverCrimperMaker", "BookCoverDieMaker", "BookEdgeGilderMaker", "BookEdgeBurnisherMaker", "BookSpineCreaserMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "MasonStonecutter", "PigmentGrinderMaker", "RawhideTanner"} },
    -- v3.12.015: Book Cover Tools+ 2 chain (6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "KNJIGOVEŠTVO+ 2", base = "Metalwork+WoodLathe+MasonStonecutter+PigmentGrinderMaker", systems = {"BookCoverBoardCornerMiterMaker", "BookCoverBoardEdgeTrimmerMaker", "BookCoverCornerCutterMaker", "BookCoverStampMaker", "BookCoverStampingFoilMaker", "BookCoverLeverPressMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "MasonStonecutter", "PigmentGrinderMaker"} },
    -- v3.12.016: Book Edge+ chain (6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "KNJIŽNI ROB+", base = "WoodLathe+PigmentGrinderMaker+Metalwork+RawhideTanner+MasonStonecutter", systems = {"BookEdgeColoringSpongeMaker", "BookEdgeGiltBurnisherMaker", "BookEdgeGiltSizeApplicatorMaker", "BookEdgeGiltSizeBrushMaker", "BookEdgePainterMaker", "BookEdgePolishingStoneMaker"}, multiBase = true, bases = {"WoodLathe", "PigmentGrinderMaker", "Metalwork", "RawhideTanner", "MasonStonecutter"} },
    -- v3.12.017: Book Sewing+ chain (6 multi-prereq, 2 CROSS-CHAIN links)
    { label = "KNJIŽNO ŠIVANJE+", base = "Metalwork+WoodLathe+SpinningWheel", systems = {"BookSewingBenchHookMaker", "BookSewingNeedleCaseMaker", "BookSewingCordSpoolMaker", "BookSewingFrameToggleMaker", "BookStitchingFrameMaker", "BookThreadReelMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel"} },
    -- v3.12.018: Book Spine & Press+ chain (6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "KNJIŽNI HRBET+", base = "WoodLathe+Metalwork+MasonStonecutter", systems = {"BookSpineGlueBrushMaker", "BookSpineGluePotStandMaker", "BookSpineLiningRollerMaker", "BookbindingPressStoneMaker", "BookbindingScrewPressMaker", "BookshelfMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "MasonStonecutter"} },
    -- v3.12.019: Book Cover Paste & Inlay+ chain (6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "KNJIGOVEŠTVO+ 3", base = "WoodLathe+SpinningWheel+Metalwork+MasonStonecutter+PigmentGrinderMaker", systems = {"BookCoverCordWinderMaker", "BookCoverGaugeMaker", "BookCoverInlayMaker", "BookCoverInlayRouterMaker", "BookCoverPasteBrushMaker", "BookCoverPasteRollerMaker"}, multiBase = true, bases = {"WoodLathe", "SpinningWheel", "Metalwork", "MasonStonecutter", "PigmentGrinderMaker"} },
    -- v3.12.020: Book Finishing+ chain (6 multi-prereq, 3 CROSS-CHAIN links)
    { label = "KNJIŽNI FINISH+", base = "Metalwork+WoodLathe+SpinningWheel+PigmentGrinderMaker+MasonStonecutter", systems = {"BookCoverPasteSpatulaMaker", "BookEndbandLoomMaker", "BookForedgeFanMaker", "BookMarkTasselMaker", "BookPressMaker", "BookPressingWeightMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel", "PigmentGrinderMaker", "MasonStonecutter"} },
    -- v3.12.021: Book Spine Remaining+ chain (7 multi-prereq, 3 CROSS-CHAIN links)
    { label = "KNJIŽNI HRBET+ 2", base = "Metalwork+GlassBench+PigmentGrinderMaker+WoodLathe+SpinningWheel+MasonStonecutter", systems = {"BookSewingBenchLightMaker", "BookSpineGiltSizeGaugeMaker", "BookSpineLabelPrinterMaker", "BookSpineLiningClothMaker", "BookSpineRulerMaker", "BookbindingGluePotMaker", "BookbindingPressMaker"}, multiBase = true, bases = {"Metalwork", "GlassBench", "PigmentGrinderMaker", "WoodLathe", "SpinningWheel", "MasonStonecutter"} },
    -- v3.12.022: Garden Tools+ chain (6 multi-prereq)
    { label = "VRTNO ORODJE+", base = "Metalwork+WoodLathe", systems = {"GardenForkMaker", "GardenHoeMaker", "GardenRakeMaker", "GardenTrowelMaker", "GardenMulchForkMaker", "GardenFurrowMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe"} },
    -- v3.12.023: Garden Soil+ chain (6 multi-prereq, 2 CROSS-CHAIN)
    { label = "VRTNA ZEMLJA+", base = "Metalwork+WoodLathe+MasonStonecutter+GlassBench", systems = {"GardenSieveMaker", "GardenSieveFrameMaker", "GardenSoilScreenMaker", "GardenCompostSifterDrumMaker", "GardenCompostAeratorSpikeMaker", "GardenSoilMoistureMeterMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "MasonStonecutter", "GlassBench"} },
    -- v3.12.024: Garden Planting+ chain (6 multi-prereq, 1 CROSS-CHAIN)
    { label = "VRTNO SAJENJE+", base = "Metalwork+WoodLathe+SpinningWheel", systems = {"GardenDibberDepthGaugeMaker", "GardenPlantDibberDepthMarkMaker", "GardenTransplantingDibberMaker", "GardenSeedDibberPlateMaker", "GardenSeedTapeMaker", "GardenSeedPacketSealerMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel"} },
    -- v3.12.025: Garden Water & Climate+ chain (6 multi-prereq, 3 CROSS-CHAIN)
    { label = "VRTNA VODA+", base = "Metalwork+GlassBench+SpinningWheel+WoodLathe", systems = {"GardenBowlSprayerMaker", "GardenClocheMaker", "GardenFrostClothClipMaker", "GardenIrrigationTimerMaker", "GardenPlantRootWateringSpikeMaker", "GardenWateringTrayMaker"}, multiBase = true, bases = {"Metalwork", "GlassBench", "SpinningWheel", "WoodLathe"} },
    -- v3.12.026: Garden Support+ chain (6 multi-prereq, 2 CROSS-CHAIN)
    { label = "VRTNA PODPORA+", base = "Metalwork+WoodLathe+RawhideTanner+SpinningWheel", systems = {"GardenBorderEdgerMaker", "GardenKneelerMaker", "GardenLeafGrabberMaker", "GardenLineMaker", "GardenTwineDispenserMaker", "GardenTrowelHolsterMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "RawhideTanner", "SpinningWheel"} },
    -- v3.12.027: Garden Specialty+ chain (7 multi-prereq, 3 CROSS-CHAIN)
    { label = "VRTNA SPECIAL+", base = "Metalwork+WoodLathe+GlassBench+MasonStonecutter+GardenRakeMaker", systems = {"GardenPlantLabelEmbosserMaker", "GardenPlantTieCutterMaker", "GardenPotBrushMaker", "GardenSoilpHTesterMaker", "GardenTrowelSharpenerMaker", "HerbGardener", "VegetableGardener"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench", "MasonStonecutter", "GardenRakeMaker"} },
    -- v3.12.028: Grain Core+ chain (6 multi-prereq)
    { label = "ŽITO JEDRO+", base = "Metalwork+WoodLathe", systems = {"GrainMillMaker", "GrainFarmer", "GrainSieveMaker", "GrainSpoutMaker", "GrainAugerMaker", "GrainAugerSpiralMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe"} },
    -- v3.12.029: Grain Hopper+ chain (6 multi-prereq, 2 CROSS-CHAIN)
    { label = "ŽITO LIJAK+", base = "Metalwork+WoodLathe+GlassBench", systems = {"GrainHopperAugerMaker", "GrainHopperLevelSensorMaker", "GrainHopperLinerMaker", "GrainHopperSlideGateMaker", "GrainMoistureMeterMaker", "GrainProbeMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench"} },
    -- v3.12.030: Grain Sampling & Mill Drive+ chain (6 multi-prereq, 1 CROSS-CHAIN)
    { label = "MLIN POGON+", base = "Metalwork+WoodLathe+SpinningWheel", systems = {"GrainSamplerProbeMaker", "MillDriveBeltMaker", "MillHopperAgitatorMaker", "MillHopperLevelFloatMaker", "MillHopperLidMaker", "MillHopperLubricatorMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel"} },
    -- v3.12.031: Mill Hopper Mech+ & Sail Cloth+ chain (6 multi-prereq, 3 CROSS-CHAIN)
    { label = "MLIN JADRO+", base = "Metalwork+WoodLathe+SpinningWheel", systems = {"MillHopperVibratorMaker", "MillHopperVibratorSpringMaker", "MillSailClothMaker", "MillSailClothReelMaker", "MillSailClothGrommetMaker", "MillSailClothGrommetInstallerMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel"} },
    -- v3.12.032: Mill Sail Cloth+ 2 chain (6 multi-prereq, 3 CROSS-CHAIN)
    { label = "MLIN JADRO+ 2", base = "SpinningWheel+WoodLathe+Metalwork+MasonStonecutter", systems = {"MillSailClothReinforcementStripMaker", "MillSailClothTensionerMaker", "MillSailClothTieDownStrapMaker", "MillSailFrameMaker", "MillstoneBalanceWeightMaker", "MillstoneBushMaker"}, multiBase = true, bases = {"SpinningWheel", "WoodLathe", "Metalwork", "MasonStonecutter"} },
    -- v3.12.033: Millstone Dressing+ chain (6 multi-prereq, 2 CROSS-CHAIN)
    { label = "MLINSKI KAMEN+", base = "Metalwork+WoodLathe+MasonStonecutter", systems = {"MillstoneDressingChalkMaker", "MillstoneDressingCompassMaker", "MillstoneDressingHammerMaker", "MillstoneDressingPickMaker", "MillstoneGrooveDepthGaugeMaker", "MillstoneEyeReamerMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "MasonStonecutter"} },
    -- v3.12.034: Millstone Lift & Tenter+ chain (6 multi-prereq)
    { label = "MLINSKI DVIG+", base = "Metalwork+WoodLathe", systems = {"MillstoneCraneHookMaker", "MillstoneCraneWinchMaker", "MillstoneLifterHooksMaker", "MillstoneTenterHookMaker", "MillstoneTenteringScrewMaker", "MillstoneGrainFeedChuteMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe"} },
    -- v3.12.035: Mill Specialty+ chain (6 multi-prereq) — MILL COMPLETE
    { label = "MLIN SPECIAL+", base = "Metalwork+WoodLathe+MasonStonecutter", systems = {"MillstoneGrooveReframerMaker", "MillstoneQuillMaker", "GunpowderMill", "Sawmill", "SnuffMiller", "SpiceMillMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "MasonStonecutter"} },
    -- v3.12.036: Forge Residual+ chain (6 multi-prereq, 2 CROSS-CHAIN)
    { label = "KOVAŠKI OSTANEK+", base = "Metalwork+WoodLathe+RawhideTanner+MasonStonecutter", systems = {"ForgeAshGateValveMaker", "ForgeAshRiddleMaker", "ForgeBellowsValveMaker", "ForgeBrickMaker", "ForgeChimneyCowlMaker", "ForgeCoalRakeToothMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "RawhideTanner", "MasonStonecutter"} },
    -- v3.12.037: Forge Residual+ 2 & Casting+ chain (6 multi-prereq, 1 CROSS-CHAIN)
    { label = "KOVAŠKI OSTANEK+ 2", base = "Metalwork+WoodLathe+MasonStonecutter", systems = {"ForgeRakeMaker", "ForgeSparkShieldMaker", "ForgeTuyereBlockMaker", "ForgeTuyereBrushMaker", "IronForgeToolMaker", "CastingLadleSkimmerMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "MasonStonecutter"} },
    -- v3.12.038: Smith / Apothecary / Metalworker / Astrolabe+ chain (7 multi-prereq, 3 CROSS-CHAIN)
    { label = "KOVAČ/APOTEKA+", base = "Metalwork+WoodLathe+MasonStonecutter+PotteryWheel+GlassBench", systems = {"Metalworker", "ApothecaryMortarMaker", "ApothecaryVialMaker", "BlacksmithViseMaker", "ScytheSmith", "SickleSmith", "AstrolabeMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "MasonStonecutter", "PotteryWheel", "GlassBench"} },
    -- v3.12.039: Hat+ chain (6 multi-prereq, 2 CROSS-CHAIN)
    { label = "KLOBUK+", base = "WoodLathe+Metalwork+SpinningWheel+RawhideTanner", systems = {"HatBlockMaker", "HatCrownBlockMaker", "HatBrimCurlerMaker", "HatBandMaker", "HatBandBuckleMaker", "HatPinMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "SpinningWheel", "RawhideTanner"} },
    -- v3.12.040: Hat+ 2 chain (5 multi-prereq, 3 CROSS-CHAIN)
    { label = "KLOBUK+ 2", base = "WoodLathe+Metalwork+SpinningWheel+RawhideTanner+HatBlockMaker", systems = {"HatBoxMaker", "HatFeatherMaker", "HatLiningMaker", "HatMaker", "HatStretcherMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "SpinningWheel", "RawhideTanner", "HatBlockMaker"} },
    -- v3.12.041: Plant Support+ chain (7 multi-prereq, 3 CROSS-CHAIN)
    { label = "RASTLINE+", base = "SpinningWheel+WoodLathe+Metalwork", systems = {"PlantClimbingNetMaker", "PlantLabelMaker", "PlantRootPrunerMaker", "PlantSupportMaker", "PlantSupportStakeMaker", "PlantSupportTrellisPanelMaker", "PlantTyingTwistMaker"}, multiBase = true, bases = {"SpinningWheel", "WoodLathe", "Metalwork"} },
    -- v3.12.042: Flour & Dough+ chain (7 multi-prereq, 1 CROSS-CHAIN)
    { label = "MUKA/TESTO+", base = "WoodLathe+Metalwork+SpinningWheel", systems = {"FlourPackerMaker", "FlourSackMaker", "FlourShovelMaker", "FlourSieveMaker", "DoughDividerMaker", "DoughHookMaker", "DoughScraperMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "SpinningWheel"} },
    -- v3.12.043: Bell+ & Slack Tub+ chain (6 multi-prereq, 2 CROSS-CHAIN)
    { label = "ZVON/KAD+", base = "Metalwork+WoodLathe+SpinningWheel", systems = {"BellHammerMaker", "BellPullMaker", "BellWheelMaker", "SlackTubMaker", "SlackTubLidMaker", "SlackTubHoodMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel"} },
    -- v3.12.044: Ingot+ & Quill+ chain (6 multi-prereq, 2 CROSS-CHAIN)
    { label = "INGOT/PERO+", base = "Metalwork+WoodLathe+MasonStonecutter+ForgeTuyere", systems = {"IngotCasterMaker", "IngotMoldMaker", "IngotSmelter", "QuillPenMaker", "QuillTrimmerMaker", "QuillMenderMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "MasonStonecutter", "ForgeTuyere"} },
    -- v3.12.045: Royal Heraldry+ & Trade+ chain (6 multi-prereq, 2 CROSS-CHAIN)
    { label = "HERALDIKA/TRGOVINA+", base = "SpinningWheel+WoodLathe+Metalwork", systems = {"RoyalBannerHerald", "RoyalCrestCarver", "RoyalSealStampMaker", "TradeGuild", "TradeNeg", "TradeRoute"}, multiBase = true, bases = {"SpinningWheel", "WoodLathe", "Metalwork"} },
    -- v3.12.046: Annealing+ & Banner+ & Bath+ chain (6 multi-prereq, 2 CROSS-CHAIN)
    { label = "ŽARENJE/ZASTAVA/KOPALNA+", base = "Metalwork+GlassBench+WoodLathe+SpinningWheel", systems = {"AnnealingLehrMaker", "AnnealingTongsMaker", "BannerMaker", "BannerPoleMaker", "BathBucketMaker", "BathFixtureMaker"}, multiBase = true, bases = {"Metalwork", "GlassBench", "WoodLathe", "SpinningWheel"} },
    -- v3.12.047: Bridle+ & Horse+ & Hardy+ chain (6 multi-prereq, 2 CROSS-CHAIN)
    { label = "UZDA/KONJ/KOVAČNICA+", base = "RawhideTanner+Metalwork+WoodLathe", systems = {"BridleMaker", "BridleBuckleMaker", "HorseBreeder", "HorseHarnessMaker", "HardyHoleMaker", "HardyShankMaker"}, multiBase = true, bases = {"RawhideTanner", "Metalwork", "WoodLathe"} },
    -- v3.12.048–057: pair groups (10 chains × 6 multi)
    { label = "MASLO/SIR/KOMPAS+", base = "WoodLathe+Metalwork+PotteryWheel+GlassBench", systems = {"ButterChurnMaker", "ButterDishMaker", "CheeseDomeMaker", "CheeseGraterMaker", "CompassMaker", "CompassNeedleMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "PotteryWheel", "GlassBench"} },
    { label = "KOMPOST/KRONANJE/LIJAK+", base = "Metalwork+WoodLathe+SpinningWheel+RawhideTanner", systems = {"CompostAeratorMaker", "CompostSieveMaker", "CoronationCushionMaker", "CoronationMantleMaker", "HopperGateMaker", "HopperScaleMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel", "RawhideTanner"} },
    { label = "ČRNILNIK/ŽELEZO/STATVE+", base = "Metalwork+WoodLathe+GlassBench", systems = {"InkwellDustCoverMaker", "InkwellStopperMaker", "IronBeamMaker", "IronGateMaker", "LoomFrameMaker", "LoomHeddleMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench"} },
    { label = "VRVICA/MREŽA/OLJE+", base = "SpinningWheel+WoodLathe+Metalwork+GlassBench", systems = {"StringMaker", "StringWinderMaker", "NetMaker", "NetMendingNeedleMaker", "OilLampMaker", "OilPresser"}, multiBase = true, bases = {"SpinningWheel", "WoodLathe", "Metalwork", "GlassBench"} },
    { label = "PAPIR/PERGAMENT/VRV+", base = "WoodLathe+Metalwork+RawhideTanner+SpinningWheel", systems = {"PaperMaker", "PaperCuttingMachineMaker", "ParchmentMaker", "ParchmentRackMaker", "RopeMaker", "RopeSpinner"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "RawhideTanner", "SpinningWheel"} },
    { label = "VREČA/SEDLO/SOL+", base = "WoodLathe+Metalwork+SpinningWheel+RawhideTanner", systems = {"SackLoaderMaker", "SackStitcherMaker", "SaddlePolishMaker", "SaddleSoapMaker", "SaltPanWorker", "SaltRefiner"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "SpinningWheel", "RawhideTanner"} },
    { label = "SEME/POSTREŽBA/ZAČIMBE+", base = "Metalwork+WoodLathe+PotteryWheel+GlassBench", systems = {"SeedDrillMaker", "SeedDrillPlowMaker", "ServingPlateMaker", "ServingTongsMaker", "SpiceMerchant", "SpiceRackMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "PotteryWheel", "GlassBench"} },
    { label = "ZVEZDE/DRŽAVA/STREMENA+", base = "WoodLathe+Metalwork+SpinningWheel+RawhideTanner", systems = {"StarChartMaker", "StarChartRackMaker", "StateCordonMaker", "StateSpearMaker", "StirrupMaker", "StirrupLeatherMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "SpinningWheel", "RawhideTanner"} },
    { label = "SLADKOR/FULLER/ZALIVANJE+", base = "Metalwork+WoodLathe", systems = {"SugarRefiner", "SugarTongsMaker", "TopMaker", "TopFullerMaker", "WateringCanMaker", "WateringSpikeMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe"} },
    { label = "VINO/LES+", base = "Metalwork+WoodLathe+GlassBench", systems = {"WineStrainerMaker", "WineVintner", "WoodLatheMaker", "WoodPanelingMaker", "WoodenColumnMaker", "WoodenSpoonCarver"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench"} },
    -- v3.12.058–066: singles batches (9 × 6 multi)
    { label = "ABAKUS–AKVEDUKT+", base = "WoodLathe+Metalwork+PotteryWheel+GlassBench+MasonStonecutter", systems = {"AbacusMaker", "AloeCultivator", "AngelusBellMaker", "AnvilStumpMaker", "AquariumKeeper", "AqueductMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "PotteryWheel", "GlassBench", "MasonStonecutter"} },
    { label = "ARBALET–PEKA+", base = "Metalwork+WoodLathe+SpinningWheel", systems = {"ArbalestMaker", "AugerBitMaker", "AviaryKeeper", "BackgammonMaker", "Baker", "BakingSheetMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel"} },
    { label = "TEHTNICA–ČAŠA+", base = "Metalwork+WoodLathe+GlassBench+SpinningWheel+MasonStonecutter", systems = {"BalanceScaleMaker", "BarometerMaker", "BasketWeaver", "BattlementMaker", "BeaconLightMaker", "BeakerBlower"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench", "SpinningWheel", "MasonStonecutter"} },
    { label = "ČEŠELJ–BILIARD+", base = "WoodLathe+Metalwork+SpinningWheel+RawhideTanner", systems = {"BeardCombMaker", "BedMaker", "Beekeeper", "BellowsMaker", "BickHornAnvilMaker", "BilliardMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "SpinningWheel", "RawhideTanner"} },
    { label = "VEZALNA–OTROBI+", base = "SpinningWheel+WoodLathe+Metalwork+PotteryWheel", systems = {"BindingCordMaker", "BisqueStandMaker", "BobbinWinderMaker", "BoltLatchMaker", "BottomFullerMaker", "BranSeparatorMaker"}, multiBase = true, bases = {"SpinningWheel", "WoodLathe", "Metalwork", "PotteryWheel"} },
    { label = "KRUH–METULJ+", base = "Metalwork+WoodLathe+GlassBench", systems = {"BreadLameMaker", "Distiller", "BridgeMaker", "BroochMaker", "BulbPlanterMaker", "ButterflyBreeder"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench"} },
    { label = "GUMB–KARTE+", base = "Metalwork+WoodLathe+SpinningWheel", systems = {"ButtonMaker", "CabinetMaker", "CalendarMaker", "CandlestickBaseMaker", "CanvasStretcherMaker", "CardDeckMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel"} },
    { label = "CARILLON–VERIGA+", base = "Metalwork+WoodLathe+RawhideTanner+SpinningWheel", systems = {"CarillonMaker", "CattleRancher", "CelestialGlobeMaker", "CentrifugalCasterMaker", "CeremonialSashMaker", "ChainMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "RawhideTanner", "SpinningWheel"} },
    { label = "STOL–CIDER+", base = "WoodLathe+Metalwork", systems = {"ChairMaker", "Chandlery", "ChestMaker", "ChimeHammerMaker", "ChocolateConfectioner", "CiderPress"}, multiBase = true, bases = {"WoodLathe", "Metalwork"} },
    -- v3.12.067–074: singles Cistern→Fuller (8 × 6)
    { label = "CISTERNA–HLADNI OKVIR+", base = "MasonStonecutter+Metalwork+WoodLathe+GlassBench", systems = {"CisternMaker", "ClampMaker", "ClayExtruderMaker", "ClockDialEngraverMaker", "CofferMaker", "ColdFrameMaker"}, multiBase = true, bases = {"MasonStonecutter", "Metalwork", "WoodLathe", "GlassBench"} },
    { label = "OVRATNIK–POSODA+", base = "Metalwork+SpinningWheel+WoodLathe", systems = {"CollarOfEstate", "CombMaker", "CommemorativeTokenMaker", "CommendationScroll", "Confectioner", "CookwareFounder"}, multiBase = true, bases = {"Metalwork", "SpinningWheel", "WoodLathe"} },
    { label = "SODOVEC–VEJALNIK+", base = "WoodLathe+Metalwork+SpinningWheel", systems = {"Cooper", "CopperSheetMaker", "CordageMaker", "CostumeTailor", "CottonGin", "CourtFanMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "SpinningWheel"} },
    { label = "ŽERJAV–KRISTAL+", base = "Metalwork+WoodLathe+SpinningWheel+GlassBench", systems = {"CraneMaker", "Crocheter", "CrumbTrayMaker", "CrumhornMaker", "CrustScorerMaker", "CrystallizationDishMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel", "GlassBench"} },
    { label = "KUPOLA–RAZPLINJEVANJE+", base = "Metalwork+MasonStonecutter+SpinningWheel+RawhideTanner+WoodLathe", systems = {"CupolaTuyereMaker", "CurtainMaker", "CushionMaker", "CutterHardyMaker", "CuttingBoardMaker", "DegassingLanceMaker"}, multiBase = true, bases = {"Metalwork", "MasonStonecutter", "SpinningWheel", "RawhideTanner", "WoodLathe"} },
    { label = "DIBBER–BARVILO+", base = "WoodLathe+Metalwork+RawhideTanner+PigmentGrinderMaker", systems = {"DibberMaker", "DollHouseMaker", "DominoMaker", "DrawbridgeMaker", "DrummerMaker", "DyeStuffMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "RawhideTanner", "PigmentGrinderMaker"} },
    { label = "BARVAR–FILTRACIJA+", base = "PigmentGrinderMaker+SpinningWheel+PotteryWheel+Metalwork+WoodLathe+GlassBench", systems = {"Dyer", "EggCupMaker", "EngravingMachineMaker", "EvaporatingBasinMaker", "FiddleMaker", "FiltrationApparatusMaker"}, multiBase = true, bases = {"PigmentGrinderMaker", "SpinningWheel", "PotteryWheel", "Metalwork", "WoodLathe", "GlassBench"} },
    { label = "RIBA–FULLER+", base = "Metalwork+WoodLathe+SpinningWheel+GlassBench", systems = {"FishScalerMaker", "Fisherman", "FishingNetMaker", "FlaskMaker", "FlatterMaker", "FullerMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel", "GlassBench"} },
    -- v3.12.075–082: singles Funnel→Mat (8 × 6)
    { label = "LIJAK–NAGOJNIK+", base = "Metalwork+WoodLathe+RawhideTanner+GlassBench", systems = {"FunnelMaker", "Furrier", "GildingPressMaker", "Glassmaker", "GlockenspielMaker", "GreaveArmorer"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "RawhideTanner", "GlassBench"} },
    { label = "KRTAČA–HARPOON+", base = "WoodLathe+Metalwork", systems = {"HairbrushMaker", "HairpinMaker", "HammerMaker", "HandTrowelMaker", "HandbellMaker", "HarpoonMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork"} },
    { label = "BRANA–TEČAJ+", base = "Metalwork+WoodLathe+SpinningWheel", systems = {"HarrowMaker", "HeadbandLoomMaker", "HedgeHookMaker", "HelmetCrestMaker", "HempRetter", "HingeMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel"} },
    { label = "KLJUKA–HIDROMETER+", base = "Metalwork+WoodLathe+SpinningWheel+GlassBench", systems = {"HookMaker", "HopsGrower", "HotCutHardyMaker", "HuntingTrapMaker", "HurdyGurdyMaker", "HydrometerMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel", "GlassBench"} },
    { label = "LED–SESTAVLJANKA+", base = "Metalwork+WoodLathe+PigmentGrinderMaker+GlassBench", systems = {"IceCutter", "IncenseMolderMaker", "InkMaker", "InoculationLadleMaker", "Jeweler", "JigsawPuzzleMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "PigmentGrinderMaker", "GlassBench"} },
    { label = "KLJUČ–ČIPKA+", base = "Metalwork+WoodLathe+SpinningWheel", systems = {"KeyMaker", "KitchenScaleMaker", "KiteMaker", "Knitter", "KnotBoardMaker", "LaceMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel"} },
    { label = "ŽLICA–GLAVNIK+", base = "Metalwork+WoodLathe+GlassBench+MasonStonecutter", systems = {"LadlePreheaterMaker", "LanternMaker", "LatrineBuilder", "LensGrinder", "LibraryCatalogMaker", "LiceCombMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench", "MasonStonecutter"} },
    { label = "LAN–PREPROGA+", base = "WoodLathe+SpinningWheel+Metalwork", systems = {"LinenRetter", "LoafPanMaker", "LocketMaker", "LyreMaker", "MandolinMaker", "MatMaker"}, multiBase = true, bases = {"WoodLathe", "SpinningWheel", "Metalwork"} },
    -- v3.12.083–090: singles MatchCord→Quarry (8 × 6)
    { label = "VŽIGALNA–DLETO+", base = "SpinningWheel+Metalwork+WoodLathe+GlassBench", systems = {"MatchCordMaker", "MeadMaker", "MedalMinter", "MetalMeshMaker", "MicroscopeMaker", "MiningChiselMaker"}, multiBase = true, bases = {"SpinningWheel", "Metalwork", "WoodLathe", "GlassBench"} },
    { label = "KOVNICA–IGLA+", base = "Metalwork+WoodLathe+MasonStonecutter", systems = {"Mint", "MortarPestleStandMaker", "MushroomForager", "NailMaker", "NeedleMaker", "OlivePressMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "MasonStonecutter"} },
    { label = "SADOVNJAK–PIŠČAL+", base = "WoodLathe+Metalwork+SpinningWheel", systems = {"Orchardist", "OrderInsignia", "OvenPeelMaker", "OysterFarmer", "PaletteMaker", "PanFluteMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "SpinningWheel"} },
    { label = "BULA–PARFUM+", base = "Metalwork+WoodLathe+GlassBench+PigmentGrinderMaker", systems = {"ParadeMaceMaker", "ParquetFloorMaker", "PenRestMaker", "PendantMaker", "PerfumeBottleMaker", "Perfumer"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench", "PigmentGrinderMaker"} },
    { label = "ZDRAVILO–SKOBELJ+", base = "GlassBench+PigmentGrinderMaker+WoodLathe+PotteryWheel+Metalwork", systems = {"PhysicPotionMaker", "PickleCurer", "PigFarmer", "PipeTaborMaker", "PitchforkMaker", "PlaneIronMaker"}, multiBase = true, bases = {"GlassBench", "PigmentGrinderMaker", "WoodLathe", "PotteryWheel", "Metalwork"} },
    { label = "SKOBELJNIK–DVIGALO+", base = "Metalwork+WoodLathe+SpinningWheel", systems = {"PlanerMaker", "PlanetariumMaker", "PlayingCardMaker", "PlowMaker", "PolisherMaker", "PortcullisMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel"} },
    { label = "DIŠAVE–PRITCHEL+", base = "PotteryWheel+WoodLathe+Metalwork", systems = {"PotpourriBowlMaker", "Potter", "PotteryWheelMaker", "PoultryKeeper", "PrintingPressMaker", "PritchelHoleMaker"}, multiBase = true, bases = {"PotteryWheel", "WoodLathe", "Metalwork"} },
    { label = "PROCESIJA–KAMNOLOM+", base = "SpinningWheel+WoodLathe+Metalwork+MasonStonecutter", systems = {"ProcessionalCanopyMaker", "ProofingBasketMaker", "ProspectingPanMaker", "PsalteryMaker", "PulleyMaker", "QuarryMiner"}, multiBase = true, bases = {"SpinningWheel", "WoodLathe", "Metalwork", "MasonStonecutter"} },
    -- v3.12.091–107: final singles Quench→Yogurt/Mason (MAKERS COMPLETE)
    { label = "KALJENJE–RETORTA+", base = "Metalwork+WoodLathe+RawhideTanner+GlassBench", systems = {"QuenchTankStirrerMaker", "QuiverMaker", "ReadingDeskMaker", "ReaperMaker", "RecorderMaker", "RetortMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "RawhideTanner", "GlassBench"} },
    { label = "TRAK–VRV+", base = "SpinningWheel+WoodLathe+Metalwork", systems = {"RibbonWeaver", "RiserBreakerMaker", "RitualDaggerMaker", "RivetMaker", "RollingPinMaker", "Ropemaker"}, multiBase = true, bases = {"SpinningWheel", "WoodLathe", "Metalwork"} },
    { label = "RULETA–ŽAFRAN+", base = "WoodLathe+Metalwork+SpinningWheel+RawhideTanner+PotteryWheel", systems = {"RouletteMaker", "SachetMaker", "SackbutMaker", "SaddlebagMaker", "Saddler", "SaffronGrower"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "SpinningWheel", "RawhideTanner", "PotteryWheel"} },
    { label = "SALPETRA–NOŽNICA+", base = "Metalwork+WoodLathe+PotteryWheel+GlassBench+SpinningWheel+RawhideTanner", systems = {"SaltpeterRefinery", "SalveJarMaker", "SamplerStitcher", "SausageMaker", "SawSetMaker", "ScabbardChapeMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "PotteryWheel", "GlassBench", "SpinningWheel", "RawhideTanner"} },
    { label = "ODR–OVCE+", base = "WoodLathe+Metalwork+SpinningWheel", systems = {"ScaffoldMaker", "ScentConeMaker", "SconceMaker", "ScrollCaseMaker", "SetHammerMaker", "SheepShepherd"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "SpinningWheel"} },
    { label = "ŠČIT–DIMLJENO+", base = "Metalwork+WoodLathe+SpinningWheel", systems = {"ShieldBossMaker", "ShovelMaker", "ShuttleMaker", "SilkReeler", "SlurryMixerMaker", "SmokedMeatCurer"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel"} },
    { label = "MILO–SPRUE+", base = "PotteryWheel+WoodLathe+Metalwork", systems = {"SoapDishMaker", "SortingMachineMaker", "SoundpostMaker", "SpinningWheelMaker", "SpongeHolderMaker", "SprueCutterMaker"}, multiBase = true, bases = {"PotteryWheel", "WoodLathe", "Metalwork"} },
    { label = "ODER–SONČNA+", base = "WoodLathe+SpinningWheel+Metalwork+MasonStonecutter+GlassBench", systems = {"StagePropMaker", "StitchingAwlMaker", "StuccoReliefMaker", "SublimationApparatusMaker", "SulfurCollector", "SundialGnomonMaker"}, multiBase = true, bases = {"WoodLathe", "SpinningWheel", "Metalwork", "MasonStonecutter", "GlassBench"} },
    { label = "SWAGE–ČOP+", base = "Metalwork+WoodLathe+SpinningWheel", systems = {"SwageBlockMaker", "TableMaker", "TailpieceMaker", "TaperRollerMaker", "TarotCardMaker", "TasselMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel"} },
    { label = "GOSTILNA–TERMO+", base = "WoodLathe+Metalwork+MasonStonecutter+GlassBench", systems = {"TavernGameMaker", "TaxCollector", "TeaBlender", "TemperingFurnaceMaker", "TerrariumKeeper", "ThermocoupleSheathMaker"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "MasonStonecutter", "GlassBench"} },
    { label = "TERMOMETER–TOBAK+", base = "GlassBench+Metalwork+WoodLathe+SpinningWheel+PotteryWheel+MasonStonecutter", systems = {"ThermometerMaker", "ThreadReelMaker", "ThresherMaker", "TileMaker", "TimberFeller", "TobaccoCurer"}, multiBase = true, bases = {"GlassBench", "Metalwork", "WoodLathe", "SpinningWheel", "PotteryWheel", "MasonStonecutter"} },
    { label = "KLEŠČE–TROFEJA+", base = "Metalwork+WoodLathe", systems = {"TongMaker", "TongsRestMaker", "TowelRackMaker", "TreadleHammerMaker", "Treasury", "TrophyMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe"} },
    { label = "ZVONCI–DEŽNIK+", base = "Metalwork+WoodLathe+SpinningWheel+GlassBench", systems = {"TubularBellsMaker", "TuningPinMaker", "TwineMaker", "TypesettingMachineMaker", "UmbrellaMaker", "VacuumCasterMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "SpinningWheel", "GlassBench"} },
    { label = "VENTIL–OSNOVA+", base = "Metalwork+WoodLathe+GlassBench+PigmentGrinderMaker", systems = {"VentWireMaker", "VestibuleLightMaker", "Vineyard", "WalkingStickMaker", "WallpaperPrinter", "WarpBeamMaker"}, multiBase = true, bases = {"Metalwork", "WoodLathe", "GlassBench", "PigmentGrinderMaker"} },
    { label = "STRAŽA–SAMOKOLNICA+", base = "WoodLathe+MasonStonecutter+Metalwork+SpinningWheel", systems = {"WatchtowerMaker", "WaxTabletMaker", "Weaver", "WellBuilder", "WhalingCaptain", "WheelbarrowMaker"}, multiBase = true, bases = {"WoodLathe", "MasonStonecutter", "Metalwork", "SpinningWheel"} },
    { label = "STENJ–ŽICA+", base = "SpinningWheel+WoodLathe+Metalwork+GlassBench", systems = {"WickSpinnerMaker", "WigMaker", "WinchMaker", "WindowFrameMaker", "WinnowingMachineMaker", "WireDrawerMaker"}, multiBase = true, bases = {"SpinningWheel", "WoodLathe", "Metalwork", "GlassBench"} },
    { label = "MIZAR–JOGURT+", base = "WoodLathe+Metalwork+SpinningWheel+PotteryWheel+MasonStonecutter", systems = {"Woodworker", "WoolStapler", "WritingStandMaker", "YogurtFermenter", "Mason"}, multiBase = true, bases = {"WoodLathe", "Metalwork", "SpinningWheel", "PotteryWheel", "MasonStonecutter"} },
}

-- Node dimensions for graph view
local NODE_W = 132
local NODE_H = 30
local NODE_GAP_X = 24
local NODE_GAP_Y = 14
local CHAIN_HEADER_H = 22
local CHAIN_GAP = 18

function TechTreePanel.toggle()
    if not visible then
        visible = true
        PanelAnim.open(animState)
        UISound.playPanelOpen()
    else
        PanelAnim.close(animState)
        UISound.playPanelClose()
    end
    scrollOffset = 0
    hoveredNode = nil
    selectedKey = nil
    searchActive = false
    searchQuery = ""
    pathMode = "transitive"
    minimapVisible = true
    minimapDragging = false
    depthVisible = true
    arrowsVisible = true
    sortMode = "alphabetical"
    stateFilter = "all"
    keyboardNavIndex = nil
    keyboardNavList = nil
    multiSelect = {}
end

function TechTreePanel.isVisible()
    return visible or PanelAnim.isAnimating(animState)
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

-- v3.11.954: Check if a node matches the current state filter.
-- "all" = no filtering (all nodes pass)
-- "active" = only nodes with state == "active" (≥1 building built)
-- "met" = only nodes with state == "met" (deps satisfied, no building)
-- "locked" = only nodes with state == "locked" (deps not met)
-- Returns true if filter is "all" OR if the node's state matches.
local function isStateFilterMatch(key, isBase)
    if stateFilter == "all" then return true end
    local state = getNodeState(key, isBase)
    return state == stateFilter
end

-- v3.11.954: Check if a connection should be shown based on state filter.
-- A connection is state-related if EITHER endpoint matches the filter.
local function isConnectionStateRelated(fromKey, toKey)
    if stateFilter == "all" then return true end
    -- For connection check, we don't know isBase here, but getNodeState handles it
    -- by checking if the key has dependencies. Bases typically have no deps.
    local fromMatch = isStateFilterMatch(fromKey, false)
    local toMatch = isStateFilterMatch(toKey, false)
    return fromMatch or toMatch
end

-- v3.11.951: Compute tech-tree depth for all nodes.
-- Depth = BFS distance from nearest root (a root = system with no dependencies).
-- Roots get depth 0. Systems depending on roots get depth 1. Etc.
-- Multi-prereq systems take the MAX depth of their prereqs + 1 (longest path).
-- Result is cached in depthCache and reused until invalidated.
local function computeDepths()
    if depthCache then return depthCache end
    depthCache = {}

    -- Collect all keys from CHAINS (bases + dependents)
    local allKeys = {}
    local keySet = {}
    for _, chain in ipairs(CHAINS) do
        local bases = chain.multiBase and chain.bases or {chain.base}
        for _, bk in ipairs(bases) do
            if not keySet[bk] then
                keySet[bk] = true
                table.insert(allKeys, bk)
            end
        end
        for _, sk in ipairs(chain.systems) do
            if not keySet[sk] then
                keySet[sk] = true
                table.insert(allKeys, sk)
            end
        end
    end

    -- Build reverse deps map (prereq -> [dependents])
    local reverseDeps = {}
    for _, k in ipairs(allKeys) do
        local prereqs = Deps.getDependencies(k)
        for _, p in ipairs(prereqs) do
            if not reverseDeps[p] then reverseDeps[p] = {} end
            table.insert(reverseDeps[p], k)
        end
    end

    -- Find roots: keys with no dependencies
    local queue = {}
    for _, k in ipairs(allKeys) do
        local prereqs = Deps.getDependencies(k)
        if #prereqs == 0 then
            depthCache[k] = 0
            table.insert(queue, k)
        else
            depthCache[k] = -1  -- unvisited
        end
    end

    -- BFS: process queue, assign depth = max(parent depths) + 1
    -- But we need to ensure all prereqs are processed first.
    -- Use iterative relaxation: keep looping until no changes.
    local changed = true
    local iterations = 0
    while changed and iterations < 100 do  -- safety limit
        changed = false
        for _, k in ipairs(allKeys) do
            if depthCache[k] == -1 then
                local prereqs = Deps.getDependencies(k)
                local maxPrereqDepth = -1
                local allPrereqsResolved = true
                for _, p in ipairs(prereqs) do
                    if depthCache[p] == -1 or depthCache[p] == nil then
                        allPrereqsResolved = false
                        break
                    end
                    if depthCache[p] > maxPrereqDepth then
                        maxPrereqDepth = depthCache[p]
                    end
                end
                if allPrereqsResolved then
                    depthCache[k] = maxPrereqDepth + 1
                    changed = true
                end
            end
        end
        iterations = iterations + 1
    end

    -- Any remaining -1 means a cycle (shouldn't happen, but safety)
    for _, k in ipairs(allKeys) do
        if depthCache[k] == -1 then
            depthCache[k] = 0  -- treat as root
        end
    end

    return depthCache
end

-- v3.11.951: Get depth for a single key (uses cache)
local function getDepth(key)
    local depths = computeDepths()
    return depths[key] or 0
end

-- v3.11.957: Scroll the main graph to center on a given minimap Y coordinate.
-- Shared by mousepressed (click) and mousemoved (drag) for minimap.
-- @param my number Mouse Y position (screen coordinates)
local function scrollToMinimapY(my)
    if not minimapArea then return end
    local W = love.graphics.getWidth()
    local H = love.graphics.getHeight()
    local panelW = math.min(960, W - 40)
    local panelH = math.min(680, H - 60)
    local panelX = (W - panelW) / 2
    local panelY = (H - panelH) / 2
    local contentTop = panelY + 56
    local contentBottom = panelY + panelH - 46  -- v3.11.955: adjusted for stats line
    local contentAreaH = contentBottom - contentTop
    -- Compute totalH (same as drawMinimap)
    local chains = computeGraphLayout(panelX, contentTop - scrollOffset)
    local totalH = contentAreaH
    if #chains > 0 then
        local last = chains[#chains]
        totalH = (last.chainY - (contentTop - scrollOffset)) + CHAIN_HEADER_H + NODE_H + CHAIN_GAP
    end
    local maxScroll = math.max(0, totalH - contentAreaH)
    if maxScroll <= 0 then return end
    -- Map click Y (relative to minimap content area) to scroll offset
    local mmContentTop = minimapArea.y + 20
    local mmContentH = minimapArea.h - 24
    local scale = mmContentH / totalH
    local clickYRel = my - mmContentTop
    -- Center viewport on click position
    local viewportH = contentAreaH * scale
    local targetTopRel = clickYRel - viewportH / 2
    -- Clamp
    if targetTopRel < 0 then targetTopRel = 0 end
    if targetTopRel > mmContentH - viewportH then targetTopRel = mmContentH - viewportH end
    -- Convert back to scroll offset
    scrollOffset = targetTopRel / scale
    if scrollOffset > maxScroll then scrollOffset = maxScroll end
    if scrollOffset < 0 then scrollOffset = 0 end
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

-- v3.11.953: Get chains in the desired order based on sortMode.
-- "alphabetical" = as defined in CHAINS (default)
-- "depth" = sorted by max depth of any node in the chain (shallow → deep)
local function getOrderedChains()
    if sortMode ~= "depth" then
        return CHAINS
    end
    -- Compute max depth for each chain
    local depths = computeDepths()
    local chainDepths = {}
    for i, chain in ipairs(CHAINS) do
        local maxD = 0
        local bases = chain.multiBase and chain.bases or {chain.base}
        for _, bk in ipairs(bases) do
            local d = depths[bk] or 0
            if d > maxD then maxD = d end
        end
        for _, sk in ipairs(chain.systems) do
            local d = depths[sk] or 0
            if d > maxD then maxD = d end
        end
        chainDepths[i] = { chain = chain, maxDepth = maxD, origIdx = i }
    end
    -- Sort by maxDepth (ascending: shallow first), tie-break by original index
    table.sort(chainDepths, function(a, b)
        if a.maxDepth ~= b.maxDepth then
            return a.maxDepth < b.maxDepth
        end
        return a.origIdx < b.origIdx
    end)
    -- Build ordered list
    local ordered = {}
    for _, cd in ipairs(chainDepths) do
        table.insert(ordered, cd.chain)
    end
    return ordered
end

-- v3.11.958: Build a flat list of all nodes in display order for keyboard navigation.
-- Each entry: {key, isBase}
-- Ordered by: chain order (respecting sortMode), then bases first, then dependents.
local function buildKeyboardNavList()
    local list = {}
    for _, chain in ipairs(getOrderedChains()) do
        local bases = chain.multiBase and chain.bases or {chain.base}
        for _, bk in ipairs(bases) do
            table.insert(list, {key = bk, isBase = true})
        end
        for _, sk in ipairs(chain.systems) do
            table.insert(list, {key = sk, isBase = false})
        end
    end
    return list
end

-- v3.11.958: Get or rebuild the keyboard nav list (lazy)
local function getKeyboardNavList()
    if not keyboardNavList then
        keyboardNavList = buildKeyboardNavList()
    end
    return keyboardNavList
end

-- v3.11.959: Load bookmarks from file (one key per line)
local function loadBookmarks()
    if bookmarksLoaded then return end
    bookmarksLoaded = true
    local path = "tech_tree_bookmarks.txt"
    if love.filesystem.exists(path) then
        local data = love.filesystem.read(path)
        if data then
            for line in data:gmatch("[^\n]+") do
                local key = line:match("^%s*(.-)%s*$")  -- trim whitespace
                if key ~= "" then
                    bookmarks[key] = true
                end
            end
        end
    end
end

-- v3.11.959: Save bookmarks to file
local function saveBookmarks()
    local lines = {}
    for key, _ in pairs(bookmarks) do
        table.insert(lines, key)
    end
    local data = table.concat(lines, "\n")
    love.filesystem.write("tech_tree_bookmarks.txt", data)
end

-- v3.11.959: Toggle bookmark on a key
local function toggleBookmark(key)
    if not key then return end
    if bookmarks[key] then
        bookmarks[key] = nil
    else
        bookmarks[key] = true
    end
    saveBookmarks()
end

-- v3.11.959: Check if a key is bookmarked
local function isBookmarked(key)
    return bookmarks[key] == true
end

-- v3.11.964: Load multi-select from file (one key per line)
local function loadMultiSelect()
    if multiSelectLoaded then return end
    multiSelectLoaded = true
    local path = "tech_tree_multiselect.txt"
    if love.filesystem.exists(path) then
        local data = love.filesystem.read(path)
        if data then
            for line in data:gmatch("[^\n]+") do
                local key = line:match("^%s*(.-)%s*$")  -- trim whitespace
                if key ~= "" then
                    multiSelect[key] = true
                end
            end
        end
    end
end

-- v3.11.964: Save multi-select to file
local function saveMultiSelect()
    local lines = {}
    for key, _ in pairs(multiSelect) do
        table.insert(lines, key)
    end
    local data = table.concat(lines, "\n")
    love.filesystem.write("tech_tree_multiselect.txt", data)
end

-- v3.11.962: Export current tech tree configuration as a shareable string.
-- Format: "TT|<viewMode>|<pathMode>|<sortMode>|<stateFilter>|<minimapVisible>|<depthVisible>|<arrowsVisible>|<bookmarksOnly>|<selectedKey>|<multiKeys>|<bookmarkKeys>"
local function exportConfig()
    loadBookmarks()
    loadMultiSelect()  -- v3.11.964
    local parts = {"TT", viewMode, pathMode, sortMode, stateFilter,
        tostring(minimapVisible), tostring(depthVisible), tostring(arrowsVisible), tostring(bookmarksOnly),
        selectedKey or ""}
    -- Multi-select keys (comma-separated)
    local multiKeys = {}
    for k, _ in pairs(multiSelect) do
        table.insert(multiKeys, k)
    end
    table.insert(parts, table.concat(multiKeys, ","))
    -- Bookmark keys (comma-separated)
    local bmKeys = {}
    for k, _ in pairs(bookmarks) do
        table.insert(bmKeys, k)
    end
    table.insert(parts, table.concat(bmKeys, ","))
    return table.concat(parts, "|")
end

-- v3.11.962: Import tech tree configuration from a string.
-- Returns true on success, false on parse error.
local function importConfig(str)
    if not str or str == "" then return false end
    local parts = {}
    for p in str:gmatch("[^|]+") do
        table.insert(parts, p)
    end
    if #parts < 12 or parts[1] ~= "TT" then return false end
    -- Parse fields
    viewMode = parts[2] == "text" and "text" or "graph"
    pathMode = parts[3] == "direct" and "direct" or "transitive"
    sortMode = parts[4] == "depth" and "depth" or "alphabetical"
    stateFilter = parts[5]
    if stateFilter ~= "active" and stateFilter ~= "met" and stateFilter ~= "locked" then
        stateFilter = "all"
    end
    minimapVisible = (parts[6] == "true")
    depthVisible = (parts[7] == "true")
    arrowsVisible = (parts[8] == "true")
    bookmarksOnly = (parts[9] == "true")
    selectedKey = (parts[10] ~= "" and parts[10]) or nil
    -- Multi-select keys
    multiSelect = {}
    if parts[11] ~= "" then
        for k in parts[11]:gmatch("[^,]+") do
            multiSelect[k] = true
        end
    end
    -- Bookmarks (overwrite existing bookmarks)
    bookmarks = {}
    bookmarksLoaded = true  -- mark as loaded so we don't overwrite with file
    if parts[12] ~= "" then
        for k in parts[12]:gmatch("[^,]+") do
            bookmarks[k] = true
        end
    end
    saveBookmarks()
    -- v3.11.964: Mark multi-select as loaded and save imported multi-select
    multiSelectLoaded = true
    saveMultiSelect()
    -- Invalidate nav list since sort mode might have changed
    keyboardNavList = nil
    keyboardNavIndex = nil
    return true
end

-- Compute layout: returns list of { chainLabel, chainY, baseNodes=[], depNodes=[], connections={} }
-- Each node: { key, x, y, w, h, state, isBase }
-- Each connection: { fromX, fromY, toX, toY, active }
local function computeGraphLayout(panelX, contentTop)
    local chains = {}
    local y = contentTop

    for _, chain in ipairs(getOrderedChains()) do
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
-- v3.11.954: added isStateMatched param for state filter dimming
-- v3.11.959: bookmark filter dimming + star indicator
local function drawNode(node, font, smallFont, isRelated, isSelected, isMatched, isStateMatched)
    -- v3.11.959: Load bookmarks lazily
    loadBookmarks()
    -- v3.11.964: Load multi-select lazily
    loadMultiSelect()
    local bm = isBookmarked(node.key)
    -- Apply dimming if focus is active and this node is not related
    -- OR if search is active and this node doesn't match
    -- OR if state filter is active and this node doesn't match
    -- OR if bookmarksOnly is active and this node is not bookmarked
    -- v3.11.961: focusDim also considers multiSelect (if any multi-select is active)
    local focusActive = selectedKey ~= nil
    local multiActive = false
    for _ in pairs(multiSelect) do multiActive = true; break end
    local focusDim = (focusActive or multiActive) and (not isRelated) and (not isSelected)
    local searchDim = (searchActive and searchQuery ~= "") and (not isMatched)
    local stateDim = (stateFilter ~= "all") and (not isStateMatched)
    local bookmarkDim = bookmarksOnly and (not bm)
    local dim = focusDim or searchDim or stateDim or bookmarkDim
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
    -- v3.11.951: If depth visible, reserve space for depth badge on the left
    local depthBadgeW = depthVisible and 18 or 0
    love.graphics.setColor(0.97, 0.97, 0.97, alphaMul)
    local label = displayName(node.key)
    -- Truncate if too long
    if smallFont then love.graphics.setFont(smallFont) end
    local maxTextW = node.w - 28 - depthBadgeW
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
            local curX = node.x + 8 + depthBadgeW
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
            love.graphics.print(label, node.x + 8 + depthBadgeW, node.y + (node.h - love.graphics.getFont():getHeight()) / 2)
        end
    else
        love.graphics.print(label, node.x + 8 + depthBadgeW, node.y + (node.h - love.graphics.getFont():getHeight()) / 2)
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

    -- v3.11.951: Depth indicator badge (small circle with depth number)
    if depthVisible then
        local d = getDepth(node.key)
        -- Badge background: color shifts from green (shallow) to red (deep)
        local depthColors = {
            [0] = {0.3, 0.7, 0.3},   -- green (root)
            [1] = {0.5, 0.75, 0.3},  -- yellow-green
            [2] = {0.75, 0.7, 0.3},  -- yellow
            [3] = {0.85, 0.55, 0.3}, -- orange
            [4] = {0.9, 0.4, 0.3},   -- red-orange
        }
        local dc = depthColors[d] or {0.95, 0.3, 0.3}  -- deep red for 5+
        local badgeR = 7
        local badgeCX = node.x + 10
        local badgeCY = node.y + node.h / 2
        -- Circle background
        love.graphics.setColor(dc[1], dc[2], dc[3], alphaMul * 0.95)
        love.graphics.circle("fill", badgeCX, badgeCY, badgeR)
        love.graphics.setColor(0.15, 0.15, 0.2, alphaMul)
        love.graphics.setLineWidth(1)
        love.graphics.circle("line", badgeCX, badgeCY, badgeR)
        -- Depth number
        if smallFont then love.graphics.setFont(smallFont) end
        love.graphics.setColor(1, 1, 1, alphaMul)
        local numStr = tostring(d)
        local numW = love.graphics.getFont():getWidth(numStr)
        local numH = love.graphics.getFont():getHeight()
        love.graphics.print(numStr, badgeCX - numW / 2, badgeCY - numH / 2)
    end

    -- v3.11.959: Bookmark star indicator (top-right corner of node)
    if bm then
        if smallFont then love.graphics.setFont(smallFont) end
        love.graphics.setColor(1, 0.85, 0.2, alphaMul)
        local starX = node.x + node.w - 28
        local starY = node.y + 2
        love.graphics.print("★", starX, starY)
    end
end

-- Draw a bezier connection between two points
-- v3.11.945: added isRelated param for dimming unrelated connections (focus mode)
-- v3.11.946: added isSearchRelated param for dimming non-matching connections (search mode)
-- v3.11.954: added isStateRelated param for dimming non-matching connections (state filter)
local function drawConnection(conn, isRelated, isSearchRelated, isStateRelated)
    local focusDim = (selectedKey ~= nil) and (not isRelated)
    local searchDim = (searchActive and searchQuery ~= "") and (not isSearchRelated)
    local stateDim = (stateFilter ~= "all") and (not isStateRelated)
    -- v3.11.959: Bookmark filter dimming for connections
    loadBookmarks()
    local bookmarkDim = bookmarksOnly and (not isBookmarked(conn.fromKey)) and (not isBookmarked(conn.toKey))
    local dim = focusDim or searchDim or stateDim or bookmarkDim
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

    -- v3.11.952: Arrowhead at the dependent end (toX, toY)
    -- Indicates direction: base → dependent
    if arrowsVisible then
        -- Tangent at endpoint: from (toX - ctrlOffset, toY) to (toX, toY)
        local tangentDx = conn.toX - (conn.toX - ctrlOffset)
        local tangentDy = conn.toY - (conn.toY)  -- always 0 since last control point has same Y as endpoint
        -- Actually the last control point is (toX - ctrlOffset, toY), so tangent = (ctrlOffset, 0)
        -- But the curve approaches (toX, toY) from (toX - ctrlOffset, toY), so direction is (1, 0)
        -- However, if toY != fromY, the curve has a vertical component near the end.
        -- For a cubic bezier with P0=(fromX,fromY), P1=(fromX+ctrl,fromY), P2=(toX-ctrl,toY), P3=(toX,toY):
        -- Tangent at t=1 is P3 - P2 = (toX - (toX-ctrl), toY - toY) = (ctrl, 0)
        -- So the arrow points in +X direction (towards the dependent node).
        -- But we want it to point AT the node, so we offset slightly back.
        local arrowLen = 7
        local arrowW = 4
        -- Arrow tip is at (toX - 2, toY) (slightly inside the node)
        local tipX = conn.toX - 2
        local tipY = conn.toY
        -- Arrow base is arrowLen pixels back in -X direction
        local baseX = tipX - arrowLen
        -- Triangle points: tip, base-top, base-bottom
        love.graphics.setColor(love.graphics.getColor())
        love.graphics.polygon("fill",
            tipX, tipY,
            baseX, tipY - arrowW,
            baseX, tipY + arrowW
        )
    end
end

function TechTreePanel.drawGraph(panelX, contentTop, contentAreaH, panelW, smallFont, font)
    -- Scissor
    love.graphics.setScissor(panelX + 4, contentTop, panelW - 8, contentAreaH)

    local chains = computeGraphLayout(panelX, contentTop - scrollOffset)

    -- v3.11.945: compute related set if a node is focused
    -- v3.11.961: If multi-select is active, compute UNION of all selected keys' related sets
    local relatedSet = nil
    if selectedKey then
        relatedSet = computeRelatedKeys(selectedKey)
    end
    -- v3.11.961: Merge multi-select related sets
    local hasMulti = false
    for _ in pairs(multiSelect) do hasMulti = true; break end
    if hasMulti then
        if not relatedSet then relatedSet = {} end
        for mk, _ in pairs(multiSelect) do
            local mkRelated = computeRelatedKeys(mk)
            for k, _ in pairs(mkRelated) do
                relatedSet[k] = true
            end
        end
    end

    -- Pass 1: draw all connections (behind nodes)
    for _, chain in ipairs(chains) do
        for _, conn in ipairs(chain.connections) do
            local isRelated = true
            if selectedKey then
                isRelated = isConnectionRelated(conn, conn.fromKey, conn.toKey, relatedSet)
            end
            local isSearchRelated = isConnectionSearchRelated(conn.fromKey, conn.toKey)
            local isStateRelated = isConnectionStateRelated(conn.fromKey, conn.toKey)
            drawConnection(conn, isRelated, isSearchRelated, isStateRelated)
        end
    end

    -- Pass 2: draw chain headers (dim if focus, search, or state filter active)
    local headerAlpha = 1.0
    if selectedKey then headerAlpha = 0.4 end
    if searchActive and searchQuery ~= "" then headerAlpha = math.min(headerAlpha, 0.4) end
    if stateFilter ~= "all" then headerAlpha = math.min(headerAlpha, 0.4) end
    -- v3.11.961: Also dim headers when multi-select is active
    if hasMulti then headerAlpha = 0.4 end
    for _, chain in ipairs(chains) do
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.6, 0.5, 0.3, headerAlpha)
        love.graphics.print("═══ " .. chain.label .. " ═══", panelX + 20, chain.chainY - scrollOffset)
    end

    -- Pass 3: draw all nodes
    -- v3.11.961: isRelated considers both selectedKey and multiSelect
    for _, chain in ipairs(chains) do
        for _, node in ipairs(chain.baseNodes) do
            local focusActive = selectedKey ~= nil or hasMulti
            local isRelated = (not focusActive) or (relatedSet and relatedSet[node.key] ~= nil)
            local isSelected = (selectedKey == node.key) or multiSelect[node.key] ~= nil
            local isMatched = isSearchMatch(node.key)
            local isStateMatched = isStateFilterMatch(node.key, node.isBase)
            drawNode(node, font, smallFont, isRelated, isSelected, isMatched, isStateMatched)
        end
        for _, node in ipairs(chain.depNodes) do
            local focusActive = selectedKey ~= nil or hasMulti
            local isRelated = (not focusActive) or (relatedSet and relatedSet[node.key] ~= nil)
            local isSelected = (selectedKey == node.key) or multiSelect[node.key] ~= nil
            local isMatched = isSearchMatch(node.key)
            local isStateMatched = isStateFilterMatch(node.key, node.isBase)
            drawNode(node, font, smallFont, isRelated, isSelected, isMatched, isStateMatched)
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
        -- v3.11.951: Show tech-tree depth
        local nodeDepth = getDepth(hoveredNode.key)
        local depthLabel
        if nodeDepth == 0 then depthLabel = "0 (koren/root)"
        elseif nodeDepth == 1 then depthLabel = "1 (plitev)"
        elseif nodeDepth == 2 then depthLabel = "2 (srednji)"
        elseif nodeDepth == 3 then depthLabel = "3 (globok)"
        else depthLabel = tostring(nodeDepth) .. " (zelo globok)" end
        table.insert(lines, "Globina: " .. depthLabel)
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
        -- v3.12.125: Use the new Deps.getDependents() helper instead of inline scan
        local dependents = Deps.getDependents(hoveredNode.key)
        local dependentCount = #dependents
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
        -- v3.11.959: Bookmark info
        loadBookmarks()
        if isBookmarked(hoveredNode.key) then
            table.insert(lines, "★ zaznamek: DA (B: odstrani)")
        else
            table.insert(lines, "★ zaznamek: ne (B: dodaj)")
        end
        table.insert(lines, "🚀 2x click: odpri v Royal Systems Panel")

        -- v3.12.125: Build preview-graph node list (max 6 prereqs + 6 dependents)
        local MAX_PREVIEW_PER_ROW = 6
        local previewPrereqs = {}
        for i = 1, math.min(#deps, MAX_PREVIEW_PER_ROW) do
            table.insert(previewPrereqs, deps[i])
        end
        local previewDeps = {}
        for i = 1, math.min(#dependents, MAX_PREVIEW_PER_ROW) do
            table.insert(previewDeps, dependents[i])
        end
        local hasPreview = #previewPrereqs > 0 or #previewDeps > 0

        -- Draw tooltip box
        love.graphics.setFont(smallFont)
        local tipW = 0
        for _, l in ipairs(lines) do
            local lw = smallFont:getWidth(l)
            if lw > tipW then tipW = lw end
        end
        tipW = tipW + 16
        -- v3.12.125: Compute preview graph height (always 100px if hasPreview)
        local PREVIEW_H = hasPreview and 110 or 0
        local tipH = #lines * (smallFont:getHeight() + 2) + 10 + PREVIEW_H
        local tipX = mouseX + 16
        local tipY = mouseY + 16
        -- Keep on screen
        local W = love.graphics.getWidth()
        local H = love.graphics.getHeight()
        if tipX + tipW > W - 8 then tipX = mouseX - tipW - 16 end
        if tipY + tipH > H - 8 then tipY = mouseY - tipH - 16 end
        if tipY < 8 then tipY = 8 end

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
            elseif l:find("★") then
                love.graphics.setColor(1, 0.85, 0.2, 1)
            elseif l:find("🚀") then
                love.graphics.setColor(0.5, 0.85, 1, 1)
            else
                love.graphics.setColor(0.85, 0.88, 0.9, 1)
            end
            love.graphics.print(l, tipX + 8, tipY + 6 + (i - 1) * (smallFont:getHeight() + 2))
        end

        -- v3.12.125: Draw mini preview graph below the text lines
        if hasPreview then
            local textBlockH = #lines * (smallFont:getHeight() + 2) + 10
            local pvX = tipX + 8
            local pvY = tipY + textBlockH
            local pvW = tipW - 16
            local pvH = PREVIEW_H - 4

            -- Separator line
            love.graphics.setColor(0.4, 0.5, 0.65, 0.5)
            love.graphics.setLineWidth(1)
            love.graphics.line(pvX, pvY, pvX + pvW, pvY)

            -- Mini header
            love.graphics.setColor(0.6, 0.75, 0.95, 0.9)
            love.graphics.print("🔗 PREDZADNJI GRAF (1-hop)", pvX + 2, pvY + 4)

            -- Layout: 3 rows
            --   row 1 (top):    prereqs  (y = pvY + 22)
            --   row 2 (middle): hovered node (y = pvY + 50)
            --   row 3 (bottom): dependents (y = pvY + 80)
            local row1Y = pvY + 24
            local row2Y = pvY + 50
            local row3Y = pvY + 82
            local centerX = pvX + pvW / 2

            -- Helper: draw a mini node box, returns x center
            local function drawMiniNode(key, cx, cy, isCenter)
                local label = displayName(key)
                if label:len() > 16 then label = label:sub(1, 15) .. "…" end
                local w = isCenter and 96 or 64
                local h = isCenter and 22 or 16
                local bx = cx - w / 2
                local by = cy - h / 2
                -- Determine node state for color
                local active = isSystemActive(key)
                local met = Deps.checkDependencies(key)
                local bgColor, borderColor
                if isCenter then
                    bgColor = {0.85, 0.7, 0.25, 0.95}
                    borderColor = {1, 0.95, 0.45, 1}
                elseif active then
                    bgColor = {0.2, 0.55, 0.3, 0.9}
                    borderColor = {0.45, 0.9, 0.55, 1}
                elseif met then
                    bgColor = {0.6, 0.55, 0.2, 0.9}
                    borderColor = {0.9, 0.85, 0.4, 1}
                else
                    bgColor = {0.35, 0.18, 0.15, 0.9}
                    borderColor = {0.7, 0.4, 0.3, 1}
                end
                love.graphics.setColor(unpack(bgColor))
                love.graphics.rectangle("fill", bx, by, w, h, 3, 3, 3, 3)
                love.graphics.setColor(unpack(borderColor))
                love.graphics.setLineWidth(isCenter and 2 or 1)
                love.graphics.rectangle("line", bx, by, w, h, 3, 3, 3, 3)
                love.graphics.setLineWidth(1)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.print(label, bx + 4, by + (h - smallFont:getHeight()) / 2 + 1)
                return cx
            end

            -- Helper: draw a connecting line between two y positions
            local function drawConnect(fromX, fromY, toX, toY, isMet)
                love.graphics.setColor(isMet and {0.45, 0.85, 0.5, 0.85} or {0.7, 0.4, 0.3, 0.7})
                love.graphics.setLineWidth(1)
                love.graphics.line(fromX, fromY, toX, toY)
            end

            -- Compute prereq positions (horizontally distributed)
            local nPre = #previewPrereqs
            local preSpacing = math.min(70, (pvW - 16) / math.max(nPre, 1))
            local preTotalW = (nPre - 1) * preSpacing
            local preStartX = centerX - preTotalW / 2
            local preCenters = {}
            for i, k in ipairs(previewPrereqs) do
                local cx = preStartX + (i - 1) * preSpacing
                preCenters[i] = cx
            end

            -- Compute dependents positions (horizontally distributed)
            local nDep = #previewDeps
            local depSpacing = math.min(70, (pvW - 16) / math.max(nDep, 1))
            local depTotalW = (nDep - 1) * depSpacing
            local depStartX = centerX - depTotalW / 2
            local depCenters = {}
            for i, k in ipairs(previewDeps) do
                local cx = depStartX + (i - 1) * depSpacing
                depCenters[i] = cx
            end

            -- Draw connecting lines first (behind boxes)
            -- prereqs (top row) → hovered node (center)
            for i, k in ipairs(previewPrereqs) do
                local met = isSystemActive(k)
                drawConnect(preCenters[i], row1Y + 8, centerX, row2Y - 11, met)
            end
            -- hovered node (center) → dependents (bottom row)
            for i, k in ipairs(previewDeps) do
                local met = isSystemActive(hoveredNode.key)
                drawConnect(centerX, row2Y + 11, depCenters[i], row3Y - 8, met)
            end

            -- Draw prereq boxes
            for i, k in ipairs(previewPrereqs) do
                drawMiniNode(k, preCenters[i], row1Y + 8, false)
            end
            -- Draw hovered node in center (larger, gold)
            drawMiniNode(hoveredNode.key, centerX, row2Y, true)
            -- Draw dependent boxes
            for i, k in ipairs(previewDeps) do
                drawMiniNode(k, depCenters[i], row3Y + 8, false)
            end

            -- Overflow indicator if more than MAX_PREVIEW_PER_ROW
            if #deps > MAX_PREVIEW_PER_ROW or #dependents > MAX_PREVIEW_PER_ROW then
                love.graphics.setColor(0.7, 0.7, 0.7, 0.8)
                local moreText = string.format("+%d več", math.max(0, #deps - MAX_PREVIEW_PER_ROW) + math.max(0, #dependents - MAX_PREVIEW_PER_ROW))
                love.graphics.print(moreText, pvX + 2, pvY + pvH - 14)
            end
        end

        love.graphics.setFont(font)
    end
end

-- ============================================================
-- MINIMAP (v3.11.949)
-- Compact overview of all 25 chains in the bottom-right corner.
-- Shows current viewport position and allows click-to-scroll.
-- ============================================================

function TechTreePanel.drawMinimap(panelX, contentTop, contentAreaH, panelW, panelH, panelY, smallFont, font)
    if not minimapVisible then
        minimapArea = nil
        return
    end

    -- Minimap dimensions: compact, bottom-right of panel
    local mmW = 140
    local mmH = 180
    local mmX = panelX + panelW - mmW - 12
    local mmY = panelY + panelH - mmH - 30  -- above footer

    -- Store for mousepressed click detection
    minimapArea = { x = mmX, y = mmY, w = mmW, h = mmH }

    -- Compute total content height (same logic as drawGraph scrollbar)
    -- We need to recompute chains layout to get totalH
    local chains = computeGraphLayout(panelX, contentTop - scrollOffset)
    local totalH = contentAreaH  -- default if no chains
    if #chains > 0 then
        local last = chains[#chains]
        totalH = (last.chainY - (contentTop - scrollOffset)) + CHAIN_HEADER_H + NODE_H + CHAIN_GAP
    end
    local maxScroll = math.max(0, totalH - contentAreaH)

    -- Compute related set for focus highlight on minimap
    local relatedSet = nil
    if selectedKey then
        relatedSet = computeRelatedKeys(selectedKey)
    end

    -- Background
    love.graphics.setColor(0.03, 0.04, 0.06, 0.92)
    love.graphics.rectangle("fill", mmX, mmY, mmW, mmH, 4, 4, 4, 4)
    -- v3.11.957: Highlight border when dragging (cyan + thicker)
    if minimapDragging then
        love.graphics.setColor(0.4, 0.85, 1, 1)
        love.graphics.setLineWidth(2)
    else
        love.graphics.setColor(0.4, 0.5, 0.65, 0.8)
        love.graphics.setLineWidth(1)
    end
    love.graphics.rectangle("line", mmX, mmY, mmW, mmH, 4, 4, 4, 4)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.7, 0.78, 0.85, 1)
    love.graphics.print("🗺 MINIMAP", mmX + 6, mmY + 4)

    -- Content area inside minimap (below title)
    local mmContentTop = mmY + 20
    local mmContentH = mmH - 24
    local mmContentW = mmW - 8

    -- Scale: map totalH to mmContentH
    local scale = totalH > 0 and mmContentH / totalH or 1
    if scale > 1 then scale = 1 end  -- don't upscale if content fits

    -- Set scissor to minimap content area
    love.graphics.setScissor(mmX + 2, mmContentTop, mmContentW, mmContentH)

    -- Draw each chain as a compact horizontal bar
    -- Position based on chain's Y in the full layout (without scroll offset)
    local mmChainY = mmContentTop
    for i, chain in ipairs(chains) do
        -- Compute this chain's Y position in unscaled coordinates
        local chainYUnscrolled = chain.chainY - (contentTop - scrollOffset)
        -- Map to minimap
        local mmY2 = mmContentTop + chainYUnscrolled * scale

        -- Chain header bar (tiny)
        love.graphics.setColor(0.4, 0.35, 0.25, 0.8)
        love.graphics.rectangle("fill", mmX + 4, mmY2, mmContentW - 4, math.max(2, CHAIN_HEADER_H * scale), 1, 1, 1, 1)

        -- Nodes: base + deps as tiny dots
        local dotSize = math.max(3, math.floor(NODE_H * scale))
        for _, node in ipairs(chain.baseNodes) do
            -- Determine color based on state + focus/search
            local fillCol, _ = nodeColor(node.state)
            local isRelated = (not selectedKey) or (relatedSet and relatedSet[node.key] ~= nil)
            local isMatched = isSearchMatch(node.key)
            local alpha = 1.0
            if selectedKey and not isRelated then alpha = 0.25 end
            if searchActive and searchQuery ~= "" and not isMatched then alpha = math.min(alpha, 0.25) end
            love.graphics.setColor(fillCol[1], fillCol[2], fillCol[3], alpha)
            -- Base node: left side
            local dotX = mmX + 6
            local dotY = mmY2 + CHAIN_HEADER_H * scale + 2
            love.graphics.rectangle("fill", dotX, dotY, dotSize, dotSize, 1, 1, 1, 1)
            -- Selected node: golden outline
            if selectedKey == node.key then
                love.graphics.setColor(1, 0.85, 0.3, 1)
                love.graphics.setLineWidth(1.5)
                love.graphics.rectangle("line", dotX - 1, dotY - 1, dotSize + 2, dotSize + 2, 1, 1, 1, 1)
                love.graphics.setLineWidth(1)
            end
        end
        for j, node in ipairs(chain.depNodes) do
            local fillCol, _ = nodeColor(node.state)
            local isRelated = (not selectedKey) or (relatedSet and relatedSet[node.key] ~= nil)
            local isMatched = isSearchMatch(node.key)
            local alpha = 1.0
            if selectedKey and not isRelated then alpha = 0.25 end
            if searchActive and searchQuery ~= "" and not isMatched then alpha = math.min(alpha, 0.25) end
            love.graphics.setColor(fillCol[1], fillCol[2], fillCol[3], alpha)
            -- Dep nodes: spread horizontally right of base
            local dotX = mmX + 6 + 8 + (j - 1) * (dotSize + 1)
            local dotY = mmY2 + CHAIN_HEADER_H * scale + 2
            -- Wrap to next row if exceeds minimap width
            if dotX + dotSize > mmX + mmContentW then
                dotX = mmX + 6 + 8
                dotY = dotY + dotSize + 1
            end
            love.graphics.rectangle("fill", dotX, dotY, dotSize, dotSize, 1, 1, 1, 1)
            if selectedKey == node.key then
                love.graphics.setColor(1, 0.85, 0.3, 1)
                love.graphics.setLineWidth(1.5)
                love.graphics.rectangle("line", dotX - 1, dotY - 1, dotSize + 2, dotSize + 2, 1, 1, 1, 1)
                love.graphics.setLineWidth(1)
            end
        end
    end

    -- Viewport indicator: shows current scroll position
    if maxScroll > 0 then
        local vpY = mmContentTop + scrollOffset * scale
        local vpH = contentAreaH * scale
        love.graphics.setColor(0.6, 0.85, 1, 0.4)
        love.graphics.setLineWidth(1.5)
        love.graphics.rectangle("line", mmX + 2, vpY, mmContentW, vpH, 2, 2, 2, 2)
        love.graphics.setLineWidth(1)
    end

    love.graphics.setScissor()

    -- Footer hint
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.45, 0.5, 0.55, 0.9)
    love.graphics.print("M: skrij  |  click: skok", mmX + 6, mmY + mmH - 14)
    love.graphics.setFont(font)
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
    if not visible and not PanelAnim.isAnimating(animState) then return end

    -- v3.12.126: Apply panel animation (alpha + slide offset)
    local animAlpha = PanelAnim.getProgress(animState)
    local offsetX, offsetY = PanelAnim.getOffset(animState)

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

    -- Dim background (fades in/out)
    love.graphics.setColor(0, 0, 0, 0.75 * animAlpha)
    love.graphics.rectangle("fill", 0, 0, W, H)

    -- Panel (with slide offset)
    love.graphics.push("all")
    love.graphics.translate(offsetX, offsetY)

    love.graphics.setColor(0.08, 0.09, 0.12, 0.98 * animAlpha)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setColor(0.5, 0.65, 0.85, animAlpha)
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
        and "Ctrl+Shift+G: zapri  |  G: tekst  |  /: iskanje  |  Tab: naslednji  |  click: fokus  |  P: preset  |  E: izvoz  |  B: ★  |  T: pot  |  M: minimap  |  D: globina  |  A: puščice  |  S: sort  |  L: filter  |  F/ESC: počisti"
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
    -- v3.11.955: Adjust contentBottom to leave room for stats summary line
    local contentBottom = panelY + panelH - 46  -- was -30, now -46 for stats line
    local contentAreaH = contentBottom - contentTop

    if viewMode == "graph" then
        TechTreePanel.drawGraph(panelX, contentTop, contentAreaH, panelW, smallFont, font)
        -- v3.11.949: Draw minimap overlay (only in graph view)
        TechTreePanel.drawMinimap(panelX, contentTop, contentAreaH, panelW, panelH, panelY, smallFont, font)
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
    -- v3.11.953: Show sort mode
    local sortLabel = sortMode == "depth" and "po globini" or "abecedno"
    local sortStr = string.format("  |  📊 sort: %s", sortLabel)
    -- v3.11.954: Show state filter
    local filterLabel
    if stateFilter == "active" then filterLabel = "aktivni"
    elseif stateFilter == "met" then filterLabel = "razpoložljivi"
    elseif stateFilter == "locked" then filterLabel = "zaklenjeni"
    else filterLabel = "vsi" end
    local filterStr = string.format("  |  🔻 filter: %s", filterLabel)

    -- v3.11.959: Bookmark count
    loadBookmarks()
    local bookmarkCount = 0
    for _ in pairs(bookmarks) do bookmarkCount = bookmarkCount + 1 end
    local bookmarkStr = string.format("  |  ★ %d%s", bookmarkCount, bookmarksOnly and " (filter)" or "")

    -- v3.11.961: Multi-select count
    local multiCount = 0
    for _ in pairs(multiSelect) do multiCount = multiCount + 1 end
    local multiStr = multiCount > 0 and string.format("  |  🔗 multi: %d", multiCount) or ""

    -- v3.11.963/965: Preset indicator (uses getAllPresets for built-in + custom)
    local allPresets = getAllPresets()
    local presetName = allPresets[currentPresetIdx] and allPresets[currentPresetIdx].name or "?"
    local presetStr = string.format("  |  📋 preset: %s (%d/%d)", presetName, currentPresetIdx, #allPresets)

    -- v3.11.955: Stats summary — count active/met/locked nodes across all chains
    local activeCount, metCount, lockedCount, totalCount = 0, 0, 0, 0
    for _, chain in ipairs(CHAINS) do
        local bases = chain.multiBase and chain.bases or {chain.base}
        for _, bk in ipairs(bases) do
            local state = getNodeState(bk, true)
            totalCount = totalCount + 1
            if state == "active" then activeCount = activeCount + 1
            elseif state == "met" then metCount = metCount + 1
            else lockedCount = lockedCount + 1 end
        end
        for _, sk in ipairs(chain.systems) do
            local state = getNodeState(sk, false)
            totalCount = totalCount + 1
            if state == "active" then activeCount = activeCount + 1
            elseif state == "met" then metCount = metCount + 1
            else lockedCount = lockedCount + 1 end
        end
    end
    -- Draw stats summary on a second line (above the main footer)
    love.graphics.setColor(0.5, 0.7, 0.5, 0.9)
    love.graphics.print(string.format("✓ %d aktivnih  |  ⚠ %d razpoložljivih  |  ✗ %d zaklenjenih  (skupaj %d)",
        activeCount, metCount, lockedCount, totalCount),
        panelX + 16, panelY + panelH - 38)

    -- v3.11.956: Progress bar — visual representation of % active systems
    -- Drawn on the right side of the stats line
    local progressPct = totalCount > 0 and (activeCount / totalCount) or 0
    local pbW = 120
    local pbH = 10
    local pbX = panelX + panelW - pbW - 16
    local pbY = panelY + panelH - 36
    -- Background
    love.graphics.setColor(0.1, 0.12, 0.16, 1)
    love.graphics.rectangle("fill", pbX, pbY, pbW, pbH, 3, 3, 3, 3)
    -- Fill with color gradient based on progress:
    -- 0% = red, 50% = yellow, 100% = green
    local r, g
    if progressPct < 0.5 then
        -- red to yellow
        r = 0.9
        g = progressPct * 2 * 0.85
    else
        -- yellow to green
        r = (1 - progressPct) * 2 * 0.9
        g = 0.85
    end
    love.graphics.setColor(r, g, 0.3, 0.95)
    love.graphics.rectangle("fill", pbX + 1, pbY + 1, (pbW - 2) * progressPct, pbH - 2, 2, 2, 2, 2)
    -- Border
    love.graphics.setColor(0.4, 0.45, 0.55, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", pbX, pbY, pbW, pbH, 3, 3, 3, 3)
    -- Percentage text above bar
    love.graphics.setColor(0.7, 0.78, 0.85, 1)
    local pctStr = string.format("%.0f%% aktivnih", progressPct * 100)
    local pctW = smallFont:getWidth(pctStr)
    love.graphics.print(pctStr, pbX + (pbW - pctW) / 2, pbY - 12)

    love.graphics.setColor(0.4, 0.45, 0.5, 1)
    love.graphics.print(string.format("891 deps · 165 verig · 786 multi-prereq · mode: %s%s%s%s%s%s%s%s%s",
        viewMode, focusStr, pathStr, searchStr, sortStr, filterStr, bookmarkStr, multiStr, presetStr),
        panelX + 16, panelY + panelH - 22)
    love.graphics.setFont(font)

    -- v3.11.962: Feedback message (export/import)
    if feedbackMessage ~= "" then
        love.graphics.setFont(font)
        local msgW = font:getWidth(feedbackMessage)
        local msgX = panelX + (panelW - msgW) / 2
        local msgY = panelY + 60
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", msgX - 8, msgY - 4, msgW + 16, font:getHeight() + 8, 4, 4, 4, 4)
        local alpha = math.min(1, feedbackMessageTime)  -- fade out
        if feedbackMessage:find("✓") then
            love.graphics.setColor(0.4, 0.95, 0.4, alpha)
        else
            love.graphics.setColor(0.95, 0.5, 0.4, alpha)
        end
        love.graphics.print(feedbackMessage, msgX, msgY)
    end

    -- v3.12.126: Close the slide-offset transform
    love.graphics.pop()

    love.graphics.setColor(1, 1, 1, 1)
end

-- ============================================================
-- INPUT HANDLERS
-- ============================================================

-- v3.11.946: Update cursor blink animation
function TechTreePanel.update(dt)
    if not visible and not PanelAnim.isAnimating(animState) then return end
    PanelAnim.update(animState, dt)
    if animState.phase == "closed" then
        visible = false
    end
    if searchActive then
        cursorBlink = cursorBlink + dt
    end
    -- v3.11.962: Update feedback message timer
    if feedbackMessageTime > 0 then
        feedbackMessageTime = feedbackMessageTime - dt
        if feedbackMessageTime <= 0 then feedbackMessage = "" end
    end
end

-- v3.11.946: Receive text input for the search box
function TechTreePanel.textinput(text)
    if not visible then return false end
    if not searchActive then return false end
    -- Only accept printable ASCII characters (avoid control chars)
    if #searchQuery < 30 then
        searchQuery = searchQuery .. text
        saveSearchQuery()
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
            saveSearchQuery()
            return true
        end
        if key == "return" or key == "kpenter" then
            searchActive = false
            saveSearchQuery()
            return true
        end
        if key == "backspace" then
            if #searchQuery > 0 then
                searchQuery = searchQuery:sub(1, -2)
                saveSearchQuery()
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

    -- v3.11.958: Tab/Shift+Tab for keyboard navigation between nodes
    if key == "tab" then
        local navList = getKeyboardNavList()
        if #navList == 0 then return true end
        local shiftDown = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
        if keyboardNavIndex == nil then
            -- First activation: start at first (or last if Shift+Tab)
            keyboardNavIndex = shiftDown and #navList or 1
        else
            if shiftDown then
                keyboardNavIndex = keyboardNavIndex - 1
                if keyboardNavIndex < 1 then keyboardNavIndex = #navList end
            else
                keyboardNavIndex = keyboardNavIndex + 1
                if keyboardNavIndex > #navList then keyboardNavIndex = 1 end
            end
        end
        -- Set focus to the selected node
        local entry = navList[keyboardNavIndex]
        selectedKey = entry.key
        -- Auto-scroll to make the node visible: compute its Y and adjust scrollOffset
        -- We need the layout to find the node's Y position
        local W = love.graphics.getWidth()
        local H = love.graphics.getHeight()
        local panelW = math.min(960, W - 40)
        local panelH = math.min(680, H - 60)
        local panelX = (W - panelW) / 2
        local panelY = (H - panelH) / 2
        local contentTop = panelY + 56
        local contentBottom = panelY + panelH - 46
        local contentAreaH = contentBottom - contentTop
        local chains = computeGraphLayout(panelX, contentTop - scrollOffset)
        for _, chain in ipairs(chains) do
            for _, node in ipairs(chain.baseNodes) do
                if node.key == entry.key then
                    -- Node Y is node.y; check if it's visible
                    if node.y < contentTop then
                        scrollOffset = scrollOffset - (contentTop - node.y) - 10
                    elseif node.y + node.h > contentBottom then
                        scrollOffset = scrollOffset + (node.y + node.h - contentBottom) + 10
                    end
                    if scrollOffset < 0 then scrollOffset = 0 end
                    return true
                end
            end
            for _, node in ipairs(chain.depNodes) do
                if node.key == entry.key then
                    if node.y < contentTop then
                        scrollOffset = scrollOffset - (contentTop - node.y) - 10
                    elseif node.y + node.h > contentBottom then
                        scrollOffset = scrollOffset + (node.y + node.h - contentBottom) + 10
                    end
                    if scrollOffset < 0 then scrollOffset = 0 end
                    return true
                end
            end
        end
        return true
    end

    -- v3.11.959: B toggles bookmark, Shift+B toggles bookmarks-only filter
    if key == "b" then
        loadBookmarks()
        local shiftDown = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
        if shiftDown then
            bookmarksOnly = not bookmarksOnly
        else
            -- Toggle bookmark on hovered node, or selected node if no hover
            local targetKey = (hoveredNode and hoveredNode.key) or selectedKey
            if targetKey then
                toggleBookmark(targetKey)
            end
        end
        return true
    end

    -- v3.11.961: C clears multi-select (and single focus)
    if key == "c" then
        local hasMulti = false
        for _ in pairs(multiSelect) do hasMulti = true; break end
        if selectedKey or hasMulti then
            selectedKey = nil
            multiSelect = {}
            saveMultiSelect()  -- v3.11.964
            return true
        end
        return true
    end

    -- v3.11.962: E exports config to clipboard, Shift+E imports from clipboard
    if key == "e" then
        local shiftDown = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
        if shiftDown then
            -- Import from clipboard
            local clip = love.system.getClipboardText()
            if clip and clip ~= "" then
                local ok = importConfig(clip)
                if ok then
                    showFeedback("✓ Konfiguracija uvožena iz odložišča")
                else
                    showFeedback("✗ Napaka: neveljaven format")
                end
            else
                showFeedback("✗ Odložišče je prazno")
            end
        else
            -- Export to clipboard
            local config = exportConfig()
            love.system.setClipboardText(config)
            showFeedback("✓ Konfiguracija izvožena v odložišče (" .. #config .. " znakov)")
        end
        return true
    end

    -- v3.11.963: P cycles through config presets
    -- v3.11.965: Shift+P saves current config as a custom preset
    if key == "p" then
        local shiftDown = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
        if shiftDown then
            -- Shift+P: save current config as custom preset
            saveCurrentAsPreset()
        else
            -- P: cycle through all presets (built-in + custom)
            local all = getAllPresets()
            local newIdx = currentPresetIdx + 1
            if newIdx > #all then newIdx = 1 end
            applyPreset(newIdx)
        end
        return true
    end

    -- v3.11.966: Shift+X deletes current custom preset (only if it's custom, not built-in)
    if key == "x" then
        local shiftDown = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
        if shiftDown then
            deleteCurrentCustomPreset()
            return true
        end
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
        saveConfig()
        return true
    end
    -- v3.11.949: M toggles minimap visibility
    if key == "m" then
        minimapVisible = not minimapVisible
        saveConfig()
        return true
    end
    -- v3.11.951: D toggles depth indicator visibility
    if key == "d" then
        depthVisible = not depthVisible
        saveConfig()
        return true
    end
    -- v3.11.952: A toggles path direction arrows visibility
    if key == "a" then
        arrowsVisible = not arrowsVisible
        saveConfig()
        return true
    end
    -- v3.11.953: S toggles sort mode (alphabetical vs depth)
    if key == "s" then
        sortMode = sortMode == "alphabetical" and "depth" or "alphabetical"
        saveConfig()
        scrollOffset = 0  -- reset scroll since layout changes
        keyboardNavList = nil  -- v3.11.958: invalidate nav list since order changed
        keyboardNavIndex = nil
        return true
    end
    -- v3.11.954: L cycles state filter (all → active → met → locked → all)
    if key == "l" then
        if stateFilter == "all" then stateFilter = "active"
        elseif stateFilter == "active" then stateFilter = "met"
        elseif stateFilter == "met" then stateFilter = "locked"
        else stateFilter = "all" end
        saveConfig()
        return true
    end
    if key == "g" then
        viewMode = viewMode == "graph" and "text" or "graph"
        saveConfig()
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

    -- v3.11.949: Check minimap click first (if visible and click is within minimap area)
    -- v3.11.957: Start drag mode for continuous scrolling
    if viewMode == "graph" and minimapVisible and minimapArea then
        if x >= minimapArea.x and x <= minimapArea.x + minimapArea.w
           and y >= minimapArea.y and y <= minimapArea.y + minimapArea.h then
            -- Click on minimap: jump scroll to that position and start drag mode
            scrollToMinimapY(y)
            minimapDragging = true
            return true
        end
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
            -- v3.11.961: Shift+click adds/removes from multi-select instead of single focus
            lastClickTime = now
            lastClickKey = clickedKey
            local shiftDown = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
            if shiftDown then
                -- Shift+click: toggle in multi-select
                loadMultiSelect()  -- v3.11.964
                if multiSelect[clickedKey] then
                    multiSelect[clickedKey] = nil
                else
                    multiSelect[clickedKey] = true
                end
                saveMultiSelect()  -- v3.11.964
                -- Clear single selection when using multi-select
                selectedKey = nil
            else
                -- Regular click: clear multi-select, set single focus
                multiSelect = {}
                saveMultiSelect()  -- v3.11.964
                if selectedKey == clickedKey then
                    selectedKey = nil
                else
                    selectedKey = clickedKey
                end
            end
            return true
        end

        -- Click on empty space inside panel: clear focus and multi-select
        local hasMulti = false
        for _ in pairs(multiSelect) do hasMulti = true; break end
        if selectedKey or hasMulti then
            selectedKey = nil
            multiSelect = {}
            saveMultiSelect()  -- v3.11.964
            return true
        end
    end
    return false
end

-- Mouse moved: detect hovered node in graph view
function TechTreePanel.mousemoved(x, y, dx, dy)
    if not visible then return false end
    if viewMode ~= "graph" then return false end

    -- v3.11.957: If dragging on minimap, update scroll continuously
    if minimapDragging then
        scrollToMinimapY(y)
        return true
    end

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

-- v3.11.957: mousereleased — end minimap drag
function TechTreePanel.mousereleased(x, y, button)
    if not visible then return false end
    if minimapDragging then
        minimapDragging = false
        return true
    end
    return false
end

return TechTreePanel
