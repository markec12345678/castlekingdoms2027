-- objects/Economy/SystemDependencies.lua
-- Castle Kingdoms 2027 - Royal System Dependencies (Tech Tree)
--
-- Defines which Royal systems require other systems to be active first.
-- A system is "active" when it has at least one building built.
--
-- Dependencies are checked before:
--   * Hiring a maker (can't hire if dependencies not met)
--   * Building a workshop (can't build if dependencies not met)
--
-- The dependency graph is intentionally lightweight: most systems have no
-- dependencies (they're standalone). Only key "advanced" systems require
-- prerequisite systems, creating a natural progression:
--
--   Metalwork → BellMaker (needs metal bells)
--   Metalwork → ChainmailForger (needs metal rings)
--   Glassmaking → MirrorMaker (needs glass)
--   Pottery → Apothecary (needs ceramic vials)
--   Woodworking → Bookbinder (needs book covers)
--   etc.
--
-- Usage:
--   local Deps = require("objects.Economy.SystemDependencies")
--   local met, missing = Deps.checkDependencies(systemKey)
--   local deps = Deps.getDependencies(systemKey)
--   Deps.registerDependency("BellMaker", {"Metalwork"})

local SystemDependencies = {}

-- Dependency graph: systemKey -> list of prerequisite systemKeys
-- A prerequisite is "met" when that system has at least 1 building.
local dependencyGraph = {
    -- Metalworking chain (basic → advanced metal goods)
    BellMaker        = {"Metalwork"},
    ChainmailForger  = {"Metalwork"},
    SwordPommelMaker = {"Metalwork"},
    GauntletMaker    = {"Metalwork"},
    CoinDieMaker     = {"Metalwork"},
    CoinPressMaker   = {"Metalwork", "BellMaker"},

    -- Glass chain (basic glass → advanced glass products)
    MirrorMaker      = {"GlassBench"},
    GlassBeadMaker   = {"GlassBench"},
    VitrailFoilMaker = {"GlassBench"},

    -- Pottery chain (basic ceramics → apothecary/laboratory)
    ApothecaryMortar = {"PotteryWheel"},
    ApothecaryVial   = {"PotteryWheel"},
    CrystallizationDish = {"PotteryWheel"},

    -- Woodworking chain (basic wood → bookbinding/furniture)
    BookPress        = {"WoodLathe"},
    BookbindingPress = {"WoodLathe"},
    EaselMaker       = {"WoodLathe"},

    -- Textile chain (basic spinning → advanced weaving)
    LoomHeddle       = {"SpinningWheel"},
    TapestryLoom     = {"SpinningWheel"},
    CarpetLoom       = {"SpinningWheel"},

    -- Leatherwork chain (v3.11.935: new chain — tanning → leather goods)
    SaddleMaker      = {"RawhideTanner"},
    LeatherCoverMaker = {"RawhideTanner"},
    GloveMaker       = {"RawhideTanner"},

    -- Dye/pigment chain (v3.11.935: dye stuff → colored textiles)
    DyerColor        = {"DyeStuff"},

    -- Forge chain (v3.11.935: advanced forging requires both metalwork AND forge)
    AnvilMaker       = {"ForgeTuyere"},
    ForgeTongsMaker  = {"ForgeTuyere"},

    -- Instrument chain (v3.11.935: instruments require both woodworking AND metalwork)
    TrumpetMaker     = {"Metalwork", "WoodLathe"},
    FluteMaker       = {"WoodLathe"},

    -- Cartography chain (v3.11.935: maps require parchment + ink)
    MapMaker         = {"ParchmentMaker", "InkMaker"},

    -- Brewing chain (v3.11.940: grain → ale/brandy distillation)
    AleBrewer        = {"BranSeparator"},
    BrandyDistiller  = {"BranSeparator"},

    -- Baking chain (v3.11.940: flour → bread/pastry)
    BreadBaker       = {"FlourSieve"},
    PastryChef       = {"FlourSieve"},

    -- Fishing chain (v3.11.940: fishing equipment → advanced fishing)
    FishingRodMaker  = {"NetMaker"},
    FishingTrapMaker = {"NetMaker"},

    -- Candle/wax chain (v3.11.940: wax → candles)
    CandlestickBase  = {"WaxTablet"},
    TorchHolderMaker = {"WaxTablet"},

    -- Glass accessories chain (v3.11.940: glass bench → glass tools)
    GlassBlowpipeCoolingRack = {"GlassBench"},
    GlassMoldMaker   = {"GlassBench"},

    -- Cutlery/smith chain (v3.11.940: forge → cutlery)
    CutlerySmith     = {"ForgeTuyere"},
    PlateCuirassSmith = {"ForgeTuyere"},

    -- Book illumination chain (v3.11.940: ink → manuscript illumination)
    ManuscriptIlluminator = {"InkMaker", "ParchmentMaker"},

    -- Masonry chain (v3.11.940: stone → brick/roof)
    BrickMaker       = {"MasonStonecutter"},
    RoofTileMaker    = {"MasonStonecutter"},

    -- Music/performance chain (v3.11.940: instruments → performance)
    BoardGameMaker   = {"WoodLathe"},
    TheaterMaskMaker = {"WoodLathe", "PigmentGrinder"},

    -- Horticulture chain (v3.11.943: garden tools → advanced gardening)
    TopiaryFrameMaker  = {"GardenRake"},
    LawnAeratorMaker   = {"GardenRake"},
    GardenWheelbarrowMaker = {"GardenRake"},

    -- Apiary chain (v3.11.943: beekeeping → honey products)
    HoneyCollector    = {"HoneyDipperMaker"},
    HoneyDipperMaker  = {"WoodLathe"},

    -- Glass colorant chain (v3.11.943: glass → colored glass)
    GlassColorantMaker = {"GlassBench"},
    GlassColorantMuller = {"GlassBench", "PigmentGrinder"},

    -- Mill accessories chain (v3.11.943: millstone → mill tools)
    MillstoneBalancerMaker = {"MillstoneSpindleBearing"},
    MillstoneCraneMaker = {"MillstoneSpindleBearing"},

    -- Cooperage chain (v3.11.943: woodworking → barrel making)
    CooperBarrelMaker = {"WoodLathe"},

    -- Surgical/medical chain (v3.11.943: metalwork → surgical tools)
    SurgicalLancetMaker = {"Metalwork", "ApothecaryMortar"},

    -- Coinage chain (v3.11.943: coin die → mint)
    MintCurrency     = {"CoinDieMaker", "CoinPressMaker"},

    -- Astronomy chain (v3.11.943: brass → instruments)
    AstrolabeRingMaker = {"Metalwork"},
    NocturnalMaker     = {"Metalwork"},
    QuadrantMaker      = {"Metalwork"},

    -- v3.11.970: Horticulture+ chain (garden tools → advanced gardening)
    PruningShearsMaker = {"Metalwork"},
    PruningSawMaker    = {"Metalwork"},
    HedgeShearsMaker   = {"Metalwork"},
    BonsaiCultivator   = {"TopiaryFrameMaker"},
    FountainMaker      = {"MasonStonecutter"},
    TrellisMaker       = {"WoodLathe"},
    VineyardPlanter    = {"GardenRake"},

    -- v3.11.970: Apiary+ chain (beekeeping → advanced products)
    WaxSealPresser     = {"WaxTablet"},
    LostWaxMolderMaker = {"WaxTablet", "GlassBench"},  -- multi-prereq!
    ApiaryKeeper        = {"HoneyDipperMaker"},

    -- v3.11.970: Coinage+ chain (coin production → coin tools)
    CoinBlankMaker  = {"Metalwork"},
    CoinScaleMaker  = {"CoinDieMaker"},
    CoinSorterMaker = {"CoinPressMaker"},

    -- v3.11.971: Surgical+ chain (surgical lancet → advanced surgical tools)
    BoneSawMaker   = {"Metalwork", "SurgicalLancetMaker"},
    SutureMaker    = {"SurgicalLancetMaker", "ApothecaryMortar"},
    ForcepsMaker   = {"Metalwork", "SurgicalLancetMaker"},

    -- v3.11.972: Astronomy+ chain (astronomy instruments → advanced astronomy)
    ArmillarySphereMaker = {"Metalwork", "AstrolabeRingMaker"},
    SextantMaker         = {"Metalwork", "QuadrantMaker"},
    TelescopeMaker       = {"Metalwork", "GlassBench"},

    -- v3.11.973: Glassmaking+ chain (glass bench → advanced glass products)
    CrystalGobletMaker   = {"GlassBench", "GlassBeadMaker"},
    StainedGlassMaker    = {"GlassBench", "GlassColorantMaker"},
    HourglassMaker       = {"GlassBench", "GlassBeadMaker"},
    GlassFurnaceMaker    = {"GlassBench", "Metalwork"},
    GlassCutterMaker     = {"GlassBench"},
    GlassPolishingWheelMaker = {"GlassBench"},

    -- v3.11.974: Foundry+ chain (forge → advanced casting/foundry tools)
    CrucibleMaker        = {"ForgeTuyere", "Metalwork"},
    CrucibleFurnaceMaker = {"ForgeTuyere", "CrucibleMaker"},
    CastingLadleMaker    = {"ForgeTuyere", "Metalwork"},
    CoreBoxMaker         = {"ForgeTuyere"},
    SandMullerMaker      = {"ForgeTuyere"},
    IngotMolderMaker     = {"ForgeTuyere", "Metalwork"},

    -- v3.11.975: Bookbinding+ chain (woodworking → advanced bookmaking)
    BookClaspMaker      = {"WoodLathe", "Metalwork"},
    CodexBinder         = {"BookPress", "ParchmentMaker"},
    ChronicleBinder     = {"BookbindingPress", "InkMaker"},
    BookbindingAwlMaker = {"Metalwork"},
    BookShelfMaker      = {"WoodLathe"},
    QuillCutterMaker    = {"Metalwork"},

    -- v3.11.976: Textile+ chain (spinning → advanced weaving/dyeing)
    CanvasWeaver      = {"SpinningWheel", "LoomHeddle"},
    CarpetLoom        = {"SpinningWheel", "TapestryLoom"},
    DyeVatMaker       = {"DyeStuff", "Metalwork"},
    BobbinMaker       = {"SpinningWheel"},
    ClothPresserMaker = {"SpinningWheel"},
    LeatherBurnisherMaker = {"RawhideTanner", "Metalwork"},

    -- v3.11.977: Pottery+ chain (pottery wheel → advanced ceramics)
    ClayDigger         = {"PotteryWheel"},
    ClayPipeMaker      = {"PotteryWheel", "MasonStonecutter"},
    GlazeSieveMaker    = {"PotteryWheel"},
    MosaicTileMaker    = {"MasonStonecutter", "BrickMaker"},
    KilnFurnitureMaker = {"PotteryWheel", "MasonStonecutter"},
    PotteryKiln        = {"PotteryWheel"},

    -- v3.11.978: Musical Instruments+ chain (instruments → advanced instruments)
    HarpMaker       = {"WoodLathe", "SpinningWheel"},
    LuteMaker       = {"WoodLathe", "Metalwork"},
    OrganPipeMaker  = {"Metalwork", "WoodLathe"},
    BagpipeMaker    = {"WoodLathe", "RawhideTanner"},
    CymbalMaker     = {"Metalwork", "BellMaker"},
    ShawmMaker      = {"WoodLathe", "Metalwork"},

    -- v3.11.979: Candle/Wax+ chain (wax tablet → advanced candle/lighting)
    CandelabraMaker   = {"Metalwork", "CandlestickBaseMaker"},
    ChandelierMaker   = {"Metalwork", "CandlestickMaker"},
    CandlestickMaker  = {"Metalwork", "WaxTablet"},
    CandleMoldMaker   = {"WaxTablet"},
    WaxDipperMaker    = {"WaxTablet"},
    LanternStreetLight = {"Metalwork", "GlassBench"},

    -- v3.11.980: Fishing+ chain (net making → advanced fishing)
    FishHookMaker      = {"Metalwork"},
    BaitBoxMaker       = {"NetMaker", "WoodLathe"},
    FishingLineSpoolMaker = {"NetMaker"},
    FishingRodMaker    = {"NetMaker", "WoodLathe"},
    FishSmoker         = {"NetMaker", "ForgeTuyere"},
    FishingBoatMaker   = {"NetMaker", "WoodLathe"},

    -- v3.11.981: Brewing/Baking+ chain (bran separator → advanced brewing/baking)
    AlambicStillMaker         = {"BranSeparator", "Metalwork"},
    DistillationApparatusMaker = {"BranSeparator", "GlassBench"},
    BrewerAdvancedDistillery  = {"BranSeparator", "AleBrewer"},
    BreadMoldMaker            = {"FlourSieve", "PotteryWheel"},
    BakerConfectioner         = {"FlourSieve", "BreadBaker"},
    FlourSifterMaker          = {"FlourSieve"},

    -- v3.11.982: Masonry+ chain (stonecutter → advanced stonework)
    MarbleStatueMaker  = {"MasonStonecutter", "ChiselBladeMaker"},
    CrestCarver        = {"MasonStonecutter", "Metalwork"},
    LimeBurner         = {"MasonStonecutter"},
    StoneLintelMaker   = {"MasonStonecutter", "BrickMaker"},
    ChiselBladeMaker   = {"Metalwork"},
    MortarPestleMaker  = {"MasonStonecutter"},

    -- v3.11.983: Dye/Pigment+ chain (dye stuff → advanced coloring)
    PigmentGrinderMaker = {"DyeStuff"},
    PaintMaker          = {"PigmentGrinderMaker", "GlassBench"},
    PaintbrushMaker     = {"WoodLathe"},
    InkwellMaker        = {"InkMaker", "GlassBench"},
    GildingBrushMaker   = {"PigmentGrinderMaker", "Metalwork"},
    WashstandMaker      = {"WoodLathe"},

    -- v3.11.984: Kitchen+ chain (bread baker → advanced kitchen tools)
    SpiceGrinderMaker   = {"FlourSieve", "ApothecaryMortar"},
    CoffeeRoaster       = {"BreadBaker", "Metalwork"},
    ButterChurner       = {"BreadBaker", "WoodLathe"},
    CheeseMaker         = {"BreadBaker", "ApothecaryMortar"},
    KitchenKnifeMaker   = {"Metalwork", "CutlerySmith"},
    ConfectionOvenMaker = {"BreadBaker", "BrickMaker"},

    -- v3.11.985: Clockmaking+ chain (metalwork → advanced timekeeping)
    SundialMaker           = {"MasonStonecutter"},
    PocketWatchMaker       = {"Metalwork", "GlassBench"},
    MainspringWinderMaker  = {"Metalwork", "BellMaker"},
    EscapementLeverMaker   = {"Metalwork", "WoodLathe"},
    PendulumRodMaker       = {"Metalwork", "WoodLathe"},
    ClockFacePainter       = {"PigmentGrinderMaker", "GlassBench"},

    -- v3.11.986: Mining+ chain (metalwork → advanced mining tools)
    AugerMaker       = {"Metalwork", "WoodLathe"},
    DrillPressMaker  = {"Metalwork", "WoodLathe"},
    GemMiner         = {"Metalwork", "PickaxeMaker"},
    PickaxeMaker     = {"Metalwork"},
    AshShovelMaker   = {"WoodLathe"},
    CharcoalBurner   = {"Metalwork", "ForgeTuyere"},
}

-- Register a dependency at runtime (for modding/extensibility)
-- @param systemKey string The system that has a dependency
-- @param prerequisites table List of systemKeys that must be active
function SystemDependencies.registerDependency(systemKey, prerequisites)
    if not systemKey or not prerequisites then return end
    dependencyGraph[systemKey] = prerequisites
end

-- Get the list of prerequisites for a system
-- @param systemKey string
-- @return table List of prerequisite systemKeys (empty if none)
function SystemDependencies.getDependencies(systemKey)
    return dependencyGraph[systemKey] or {}
end

-- Check if all dependencies for a system are met
-- @param systemKey string
-- @return boolean True if all dependencies are met (or system has no deps)
-- @return table List of unmet dependency keys (empty if all met)
function SystemDependencies.checkDependencies(systemKey)
    local deps = dependencyGraph[systemKey]
    if not deps or #deps == 0 then
        return true, {}
    end

    -- Need access to RoyalSystemsRegistry to check if prerequisite systems
    -- have buildings. Lazy require to avoid circular dependency.
    local Registry = require("objects.Economy.RoyalSystemsRegistry")
    local systems = Registry.getSystems()

    -- Build a lookup: key -> system entry
    local systemMap = {}
    for _, sys in ipairs(systems) do
        systemMap[sys.key] = sys
    end

    local unmet = {}
    for _, prereqKey in ipairs(deps) do
        local prereqSys = systemMap[prereqKey]
        if not prereqSys then
            -- Prerequisite system doesn't exist at all
            table.insert(unmet, prereqKey)
        else
            local stats = prereqSys.module.getStats()
            if not stats or (stats.numBuildings or 0) == 0 then
                table.insert(unmet, prereqKey)
            end
        end
    end

    return #unmet == 0, unmet
end

-- Get a human-readable description of dependencies for UI display
-- @param systemKey string
-- @return string Description (e.g., "Zahteva: Metalwork (✓), GlassBench (✗)")
function SystemDependencies.getDependencyDescription(systemKey)
    local deps = dependencyGraph[systemKey]
    if not deps or #deps == 0 then
        return ""
    end

    local Registry = require("objects.Economy.RoyalSystemsRegistry")
    local systems = Registry.getSystems()
    local systemMap = {}
    for _, sys in ipairs(systems) do
        systemMap[sys.key] = sys
    end

    local parts = {}
    for _, prereqKey in ipairs(deps) do
        local prereqSys = systemMap[prereqKey]
        local met = false
        if prereqSys then
            local stats = prereqSys.module.getStats()
            met = stats and (stats.numBuildings or 0) > 0
        end
        local symbol = met and "✓" or "✗"
        local display = prereqKey:gsub("Maker$", ""):gsub("([a-z])([A-Z])", "%1 %2")
        table.insert(parts, string.format("%s (%s)", display, symbol))
    end

    return "Zahteva: " .. table.concat(parts, ", ")
end

-- Check if a system HAS dependencies (used for UI badge/display)
-- @param systemKey string
-- @return boolean True if system has any dependencies
function SystemDependencies.hasDependencies(systemKey)
    local deps = dependencyGraph[systemKey]
    return deps ~= nil and #deps > 0
end

return SystemDependencies
