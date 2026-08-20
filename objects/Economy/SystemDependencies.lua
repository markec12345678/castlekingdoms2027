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

    -- v3.11.987: Armor/Weapon+ chain (metalwork + wood + cross-chain → advanced arms & armor)
    -- 5 multi-prereq out of 6; 2 CROSS-CHAIN links (GemMiner→Mining+, RawhideTanner→Leatherwork+)
    CeremonialSwordMaker = {"Metalwork", "GemMiner"},      -- multi! CROSS-CHAIN: ceremonial sword needs jeweled hilt
    HalberdSmith          = {"Metalwork", "WoodLathe"},    -- multi! polearm: metal head + wooden shaft
    LongbowMaker          = {"WoodLathe"},                  -- shaped wooden stave
    RecurveBowMaker       = {"WoodLathe", "RawhideTanner"}, -- multi! CROSS-CHAIN: composite bow uses leather/sinew
    ParadeShieldMaker    = {"Metalwork", "RawhideTanner"}, -- multi! CROSS-CHAIN: shield with leather backing
    PresentationAxeMaker = {"Metalwork", "WoodLathe"},    -- multi! axe: metal head + wooden handle

    -- v3.11.988: Anvil+ chain (forge → advanced anvil accessories & blacksmithing equipment)
    -- 5 multi-prereq out of 6; 2 CROSS-CHAIN links (GlassBench→Steklarstvo+, WoodLathe→Woodworking+)
    AnvilClampMaker        = {"Metalwork", "ForgeTuyere"},   -- multi! workholding clamp: metal body + forge bolts
    AnvilFaceHardenerMaker = {"Metalwork", "ForgeTuyere"},  -- multi! hardening process: metal + heat treatment
    AnvilHardyMaker        = {"Metalwork", "ForgeTuyere"},  -- multi! hardy hole cutting tool: forged steel
    AnvilHornPolisherMaker = {"Metalwork", "GlassBench"},   -- multi! CROSS-CHAIN: polishing uses glass abrasive
    AnvilSaddleBlockMaker  = {"WoodLathe", "ForgeTuyere"},  -- multi! CROSS-CHAIN: wooden saddle block on forge
    AnvilStumpWedgeMaker   = {"WoodLathe"},                  -- shaped wooden wedges for anvil leveling

    -- v3.11.989: Garden+ 2 chain (metalwork + wood + cross-chain → advanced soil/compost instruments)
    -- 5 multi-prereq out of 6; 2 CROSS-CHAIN links (GlassBench→Steklarstvo+, Metalwork→Kovaštvo+)
    GardenSoilAeratorSpikeMaker        = {"Metalwork", "WoodLathe"},  -- multi! metal spikes + wooden handle
    GardenSecateursMaker                = {"Metalwork", "WoodLathe"},  -- multi! shears: metal blades + wooden grips
    GardenSprayerMaker                  = {"GlassBench", "Metalwork"}, -- multi! CROSS-CHAIN: glass reservoir + metal pump
    GardenSoilThermometerMaker          = {"GlassBench", "Metalwork"}, -- multi! CROSS-CHAIN: glass tube + metal probe
    GardenCompostThermometerProbeMaker = {"Metalwork", "GlassBench"}, -- multi! CROSS-CHAIN: probe + glass vial
    GardenToolRackMaker                 = {"WoodLathe"},               -- shaped wooden rack for tools

    -- v3.11.990: Milling+ chain (metalwork + wood + cross-chain → advanced milling machinery)
    -- 5 multi-prereq out of 6; 3 CROSS-CHAIN links (GlassBench→Steklarstvo+, SpinningWheel→Tekstil+, Metalwork→Kovaštvo+)
    MillstoneMaker                 = {"Metalwork", "WoodLathe"},  -- multi! millstone needs iron fittings + wooden frame
    MillstoneSpindleBearingMaker   = {"Metalwork", "WoodLathe"},  -- multi! spindle needs metal bearing + wood housing
    MillHopperShakerMaker          = {"WoodLathe", "SpinningWheel"}, -- multi! CROSS-CHAIN: cloth/strap drive from textile
    GrainHopperMaker               = {"WoodLathe", "Metalwork"},    -- multi! wooden box + iron bands
    MillHopperSightGlassMaker      = {"GlassBench", "WoodLathe"},   -- multi! CROSS-CHAIN: glass window + wooden frame
    MillstoneDresserMaker          = {"Metalwork"},                  -- dressing tools are pure metal

    -- v3.11.991: Glass Engraving+ chain (glass + metalwork + cross-chain → advanced glass etching/engraving)
    -- 5 multi-prereq out of 6; 2 CROSS-CHAIN links (GlassBench→Steklarstvo+, GemMiner→Mining+)
    GlassEngraverMaker                  = {"Metalwork", "WoodLathe"},    -- multi! engraving tool: metal point + wooden handle
    GlassEngravingWheelMaker            = {"WoodLathe", "Metalwork"},    -- multi! wheel: wooden frame + metal axis
    GlassEngravingPointMaker            = {"Metalwork", "GlassBench"},   -- multi! CROSS-CHAIN: glass-abrasive point
    GlassEngravingDiamondPointMaker     = {"Metalwork", "GemMiner"},    -- multi! CROSS-CHAIN: diamond-tipped → Mining+
    GlassEngravingCopperWheelMaker      = {"Metalwork", "WoodLathe"},    -- multi! copper wheel + wooden support
    GlassEngravingWheelDressingStoneMaker = {"GlassBench"},              -- pure glass abrasive stone for dressing wheels

    -- v3.11.992: Glass Annealing+ chain (metalwork + forge + cross-chain → advanced glass annealing equipment)
    -- 5 multi-prereq out of 6; 3 CROSS-CHAIN links (GlassBench→Steklarstvo+ x3, ForgeTuyere→Livarstvo+, Metalwork→Kovaštvo+)
    GlassAnnealingOvenMaker                  = {"Metalwork", "ForgeTuyere"},  -- multi! CROSS-CHAIN: oven shell + forge tuyere → Livarstvo+
    GlassAnnealingOvenThermocoupleMaker      = {"Metalwork", "GlassBench"}, -- multi! CROSS-CHAIN: glass tube + metal probe → Steklarstvo+
    GlassAnnealingOvenInspectionMirrorMaker  = {"GlassBench", "Metalwork"}, -- multi! CROSS-CHAIN: glass mirror + metal frame → Steklarstvo+
    GlassAnnealingRollerMaker                = {"WoodLathe", "Metalwork"},   -- multi! wooden handle + metal axis
    GlassAnnealingCartMaker                  = {"WoodLathe", "Metalwork"},   -- multi! wooden cart + metal wheels
    GlassAnnealingForkMaker                  = {"Metalwork"},                -- metal fork for lifting hot glass

    -- v3.11.993: Glass Colorant+ chain (pigments + stone + cross-chain → advanced glass coloring equipment)
    -- 5 multi-prereq out of 6; 3 CROSS-CHAIN links (PigmentGrinderMaker→Barvila+, MasonStonecutter→Kamnoseštvo+, Metalwork→Kovaštvo+)
    GlassColorantMortarMaker         = {"MasonStonecutter", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: stone mortar + pigments → Barvila+
    GlassColorantMortarPestleMaker   = {"MasonStonecutter", "Metalwork"},          -- multi! CROSS-CHAIN: stone bowl + metal pestle → Kamnoseštvo+
    GlassColorantMullerMaker         = {"Metalwork", "PigmentGrinderMaker"},        -- multi! CROSS-CHAIN: metal muller + pigments → Barvila+
    GlassColorantSieveMaker           = {"WoodLathe", "PigmentGrinderMaker"},       -- multi! CROSS-CHAIN: wooden frame + pigments → Barvila+
    GlassColorantSpatulaMaker         = {"Metalwork", "WoodLathe"},                  -- multi! metal spatula + wooden handle
    GlassColorantDryingTrayMaker      = {"WoodLathe"},                              -- wooden tray for drying colorants

    -- v3.11.994: Glass Kiln+ chain (metalwork + stone + cross-chain → advanced glass kiln equipment)
    -- 5 multi-prereq out of 6; 3 CROSS-CHAIN links (MasonStonecutter→Kamnoseštvo+ x4, GlassBench→Steklarstvo+ x2, Metalwork→Kovaštvo+ x4)
    GlassKilnDoorMaker          = {"Metalwork", "MasonStonecutter"},   -- multi! CROSS-CHAIN: metal fittings + stone frame → Kamnoseštvo+
    GlassKilnBrickSawMaker      = {"Metalwork", "MasonStonecutter"},   -- multi! CROSS-CHAIN: metal saw + stone blade → Kamnoseštvo+
    GlassKilnFlueDamperMaker    = {"Metalwork", "GlassBench"},         -- multi! CROSS-CHAIN: metal damper + glass inspection port → Steklarstvo+
    GlassKilnMuffleMaker        = {"MasonStonecutter", "GlassBench"},  -- multi! CROSS-CHAIN: stone muffle + glass windows → Kamnoseštvo+ & Steklarstvo+
    GlassKilnFurnitureMaker     = {"WoodLathe", "MasonStonecutter"},   -- multi! CROSS-CHAIN: wooden shelves + stone supports → Kamnoseštvo+
    GlassKilnSootScraperMaker   = {"Metalwork"},                       -- metal scraper for kiln soot

    -- v3.11.995: Foundry Accessories+ 2 chain (metalwork + cross-chain → advanced foundry tools)
    -- 5 multi-prereq out of 6; 3 CROSS-CHAIN links (GlassBench→Steklarstvo+ x2, MasonStonecutter→Kamnoseštvo+, Metalwork→Kovaštvo+ x4)
    SandMullerBladeMaker           = {"Metalwork", "WoodLathe"},        -- multi! metal blade + wooden handle for sand muller
    MoldFlaskAlignmentPinMaker     = {"Metalwork", "MasonStonecutter"}, -- multi! CROSS-CHAIN: metal pins + stone mold base → Kamnoseštvo+
    CoreGasEscapeChannelMaker      = {"Metalwork", "GlassBench"},       -- multi! CROSS-CHAIN: metal tube + glass inspection → Steklarstvo+
    CastingLadleSkimmerHookMaker  = {"Metalwork", "WoodLathe"},         -- multi! metal hook + wooden handle
    PouringLadleSpoutLinerMaker   = {"GlassBench", "Metalwork"},        -- multi! CROSS-CHAIN: glass-lined spout → Steklarstvo+
    SandRiddleMaker                = {"WoodLathe"},                     -- wooden frame for sifting sand

    -- v3.11.996: Glass Batch+ chain (metalwork + forge + cross-chain → advanced glass batch/smelting equipment)
    -- 5 multi-prereq out of 6; 3 CROSS-CHAIN links (ForgeTuyere→Livarstvo+ x2, MasonStonecutter→Kamnoseštvo+ x2, Metalwork→Kovaštvo+ x5)
    GlassBatchFurnaceMaker     = {"Metalwork", "ForgeTuyere"},        -- multi! CROSS-CHAIN: metal furnace + forge tuyere → Livarstvo+
    GlassBatchSmelter          = {"Metalwork", "ForgeTuyere"},        -- multi! CROSS-CHAIN: metal smelter pot + forge tuyere → Livarstvo+
    GlassBatchMixerMaker       = {"WoodLathe", "Metalwork"},          -- multi! wooden paddle + metal axis for batch mixer
    GlassBatchFeederMaker      = {"WoodLathe", "MasonStonecutter"},   -- multi! CROSS-CHAIN: wooden bucket + stone hopper → Kamnoseštvo+
    GlassBatchMaker            = {"MasonStonecutter", "Metalwork"},   -- multi! CROSS-CHAIN: stone weighing + metal weights → Kamnoseštvo+
    GlassCulletCrusherMaker    = {"Metalwork"},                       -- metal crusher for recycling cullet glass

    -- v3.11.997: Glass Forming Tools+ chain (metalwork + wood + cross-chain → advanced glass shaping tools)
    -- 5 multi-prereq out of 6; 3 CROSS-CHAIN links (MasonStonecutter→Kamnoseštvo+, Metalwork→Kovaštvo+ x5, WoodLathe→Woodworking+ x4)
    GlassMarverMaker         = {"Metalwork", "MasonStonecutter"},  -- multi! CROSS-CHAIN: metal plate + stone base → Kamnoseštvo+
    GlassPuntyRodMaker       = {"Metalwork", "WoodLathe"},          -- multi! metal pontil + wooden handle
    GlassGatheringIronMaker  = {"Metalwork", "WoodLathe"},          -- multi! metal blowpipe + wooden handle
    GlassShearsMaker         = {"Metalwork", "WoodLathe"},          -- multi! metal blades + wooden handle
    GlassYokeMaker           = {"WoodLathe", "Metalwork"},           -- multi! wooden stand + metal fittings
    GlassLehrBeltMaker       = {"WoodLathe"},                       -- wooden conveyor belt for Lehr oven

    -- v3.11.998: Foundry Accessories+ 3 chain (Sand/Mold/Core+ 2 — advanced sand/mold/core tools)
    -- 5 multi-prereq out of 6; 3 CROSS-CHAIN links (MasonStonecutter→Kamnoseštvo+, GlassBench→Steklarstvo+ x2, PigmentGrinderMaker→Barvila+)
    SandMoldMaker            = {"Metalwork", "MasonStonecutter"},  -- multi! CROSS-CHAIN: metal frame + stone mold base → Kamnoseštvo+
    MoldDryingOvenMaker      = {"Metalwork", "GlassBench"},         -- multi! CROSS-CHAIN: metal oven + glass inspection port → Steklarstvo+
    MoldCoatingBrushMaker    = {"WoodLathe", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: wooden brush + coating pigments → Barvila+
    CoreOvenMaker            = {"Metalwork", "GlassBench"},         -- multi! CROSS-CHAIN: metal oven + glass inspection port → Steklarstvo+
    CorePasteMixerMaker      = {"WoodLathe", "Metalwork"},          -- multi! wooden paddle + metal axis for paste mixer
    MoldClampMaker           = {"Metalwork"},                        -- metal clamp for securing molds

    -- v3.11.999: Foundry Accessories+ 4 chain (Sand/Mold/Core+ 3 — sand treatment & mold handling)
    -- 5 multi-prereq out of 6; 3 CROSS-CHAIN links (GlassBench→Steklarstvo+, MasonStonecutter→Kamnoseštvo+ x2, Metalwork→Kovaštvo+ x5)
    SandConditionerMaker  = {"Metalwork", "WoodLathe"},         -- multi! metal blades + wooden paddle for sand conditioning
    SandCoolerMaker        = {"Metalwork", "GlassBench"},         -- multi! CROSS-CHAIN: metal cooling coils + glass inspection port → Steklarstvo+
    MoldDryingStandMaker   = {"WoodLathe", "Metalwork"},          -- multi! wooden stand + metal fittings
    MoldWashBoothMaker     = {"MasonStonecutter", "Metalwork"},   -- multi! CROSS-CHAIN: stone basin + metal plumbing → Kamnoseštvo+
    CorePrintBoxMaker      = {"MasonStonecutter", "WoodLathe"},   -- multi! CROSS-CHAIN: stone box + wooden lid → Kamnoseštvo+
    MoldFlowTesterMaker    = {"Metalwork"},                        -- metal flow testing instrument for molds

    -- v3.12.000: Foundry Accessories+ 5 chain (Casting/Pouring+ — ladle & crucible handling tools)
    -- 5 multi-prereq out of 6; 3 CROSS-CHAIN links (ForgeTuyere→Livarstvo+, GlassBench→Steklarstvo+, MasonStonecutter→Kamnoseštvo+)
    CastingLadleNozzleMaker          = {"Metalwork", "ForgeTuyere"},  -- multi! CROSS-CHAIN: metal nozzle + forge tuyere → Livarstvo+
    CastingLadlePreheatBurnerMaker   = {"Metalwork", "GlassBench"}, -- multi! CROSS-CHAIN: metal burner + glass inspection port → Steklarstvo+
    PouringLadleMaker                = {"Metalwork", "WoodLathe"},    -- multi! metal ladle + wooden handle
    PouringLadleLiningCementMaker    = {"MasonStonecutter", "Metalwork"}, -- multi! CROSS-CHAIN: stone mortar + metal mixer → Kamnoseštvo+
    PouringCrucibleTongsMaker        = {"Metalwork", "WoodLathe"},    -- multi! metal tongs + wooden handle
    CastingBreakoutChiselMaker       = {"Metalwork"},                 -- metal chisel for removing castings from molds

    -- v3.12.001: Foundry Accessories+ 6 chain (Sand/Mold/Core+ 4 — sand processing & mold handling tools)
    -- 5 multi-prereq out of 6; 3 CROSS-CHAIN links (GlassBench→Steklarstvo+ x2, MasonStonecutter→Kamnoseštvo+, Metalwork→Kovaštvo+ x6)
    SandCasterMaker          = {"Metalwork", "WoodLathe"},      -- multi! metal mechanism + wooden handle for sand casting
    SandReclaimerMaker       = {"Metalwork", "GlassBench"},      -- multi! CROSS-CHAIN: metal reclaimer + glass inspection port → Steklarstvo+
    MoldKilnMaker            = {"MasonStonecutter", "Metalwork"}, -- multi! CROSS-CHAIN: stone chamber + metal door → Kamnoseštvo+
    MoldReleaseAgentMaker    = {"GlassBench", "Metalwork"},      -- multi! CROSS-CHAIN: glass reservoir + metal pump → Steklarstvo+
    CoreDryingRackMaker      = {"WoodLathe", "Metalwork"},       -- multi! wooden rack + metal fittings
    CrucibleTongsMaker       = {"Metalwork"},                    -- metal tongs for handling crucibles

    -- v3.12.002: Foundry Accessories+ 7 chain (Sand/Mold/Core+ 5 — sand dispensers, mold wedges, core vents)
    -- 5 multi-prereq out of 6; 3 CROSS-CHAIN links (MasonStonecutter→Kamnoseštvo+ x2, PigmentGrinderMaker→Barvila+, GlassBench→Steklarstvo+)
    SandBinderDispenserMaker   = {"Metalwork", "MasonStonecutter"},   -- multi! CROSS-CHAIN: metal reservoir + stone weighing base → Kamnoseštvo+
    SandSieveShakerMaker       = {"WoodLathe", "Metalwork"},          -- multi! wooden frame + metal shaking mechanism
    MoldCoatingRollerMaker     = {"WoodLathe", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: wooden roller + coating pigments → Barvila+
    MoldFlaskClampWedgeMaker   = {"Metalwork", "MasonStonecutter"},   -- multi! CROSS-CHAIN: metal pins + stone wedges → Kamnoseštvo+
    CoreGasVentPinMaker        = {"Metalwork", "GlassBench"},         -- multi! CROSS-CHAIN: metal pins + glass indicator → Steklarstvo+
    PouringConeMaker           = {"Metalwork"},                       -- metal funnel cone for pouring molten metal

    -- v3.12.003: Foundry Accessories+ 8 chain (Sand/Mold/Core+ 6 — FINAL Sand/Mold/Core batch, exhausts these 3 groups!)
    -- 5 multi-prereq out of 6; 3 CROSS-CHAIN links (GlassBench→Steklarstvo+, PigmentGrinderMaker→Barvila+ x2, MasonStonecutter→Kamnoseštvo+)
    SandTestCupMaker           = {"Metalwork", "GlassBench"},         -- multi! CROSS-CHAIN: metal cup + glass inspection window → Steklarstvo+
    SanderMaker                = {"WoodLathe", "Metalwork"},          -- multi! wooden stand + metal grinding mechanism
    MoldCoatBrushSpinnerMaker  = {"WoodLathe", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: wooden spindle + coating pigments → Barvila+
    MoldVentWireCleanerMaker   = {"Metalwork", "WoodLathe"},          -- multi! metal brush + wooden handle
    CoreVarnishBrushMaker      = {"WoodLathe", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: wooden brush + varnish pigments → Barvila+
    CoreWashingDipMaker        = {"MasonStonecutter", "Metalwork"},   -- multi! CROSS-CHAIN: stone tub + metal plumbing → Kamnoseštvo+

    -- v3.12.004: Foundry Accessories+ 9 chain (Casting/Pouring+ 2 — ladle handling & crucible drying tools)
    -- 6 multi-prereq out of 6 (2nd time all multi!, after v3.12.003); 3 CROSS-CHAIN links (MasonStonecutter→Kamnoseštvo+, GlassBench→Steklarstvo+ x2, Metalwork→Kovaštvo+ x6)
    CastingLadleLiningTrowelMaker   = {"Metalwork", "MasonStonecutter"}, -- multi! CROSS-CHAIN: metal trowel + stone mortar → Kamnoseštvo+
    CastingLadlePreheatStandMaker   = {"Metalwork", "WoodLathe"},       -- multi! metal stand + wooden base
    CastingLadleSkimmerHandleMaker  = {"WoodLathe", "Metalwork"},        -- multi! wooden handle + metal fitting
    PouringCrucibleDrierMaker       = {"Metalwork", "GlassBench"},      -- multi! CROSS-CHAIN: metal dryer + glass inspection port → Steklarstvo+
    PouringLadleLinerMaker          = {"GlassBench", "Metalwork"},       -- multi! CROSS-CHAIN: glass liner + metal frame → Steklarstvo+
    PouringLadleSkimmerSieveMaker    = {"WoodLathe", "Metalwork"},        -- multi! wooden sieve frame + metal mesh

    -- v3.12.005: Glass Kiln Accessories+ 2 chain (GlassKiln remaining — door chains, brick tongs, seals)
    -- 6 multi-prereq out of 6 (3rd time all multi!); 3 CROSS-CHAIN links (MasonStonecutter→Kamnoseštvo+ x3, GlassBench→Steklarstvo+ x2, Metalwork→Kovaštvo+ x5)
    GlassKilnDoorChainMaker       = {"Metalwork", "MasonStonecutter"},  -- multi! CROSS-CHAIN: metal chain + stone pulley → Kamnoseštvo+
    GlassKilnDoorLifterMaker     = {"Metalwork", "MasonStonecutter"},  -- multi! CROSS-CHAIN: metal lifter + stone counterweight → Kamnoseštvo+
    GlassKilnBrickTongsMaker      = {"Metalwork", "MasonStonecutter"},  -- multi! CROSS-CHAIN: metal tongs + stone base → Kamnoseštvo+
    GlassKilnSealMaker            = {"GlassBench", "MasonStonecutter"}, -- multi! CROSS-CHAIN: glass seal + stone frame → Steklarstvo+ & Kamnoseštvo+
    GlassKilnSightingPortCoverMaker = {"Metalwork", "GlassBench"},      -- multi! CROSS-CHAIN: metal cover + glass sighting port → Steklarstvo+
    GlassKilnSpyMaker             = {"Metalwork", "WoodLathe"},         -- multi! metal spy tube + wooden handle

    -- v3.12.006: Glass Blowing+ 2 chain (benches, blowpipes, molds, cooling racks, shears)
    -- 6 multi-prereq out of 6 (4th time all multi!); 3 CROSS-CHAIN links (MasonStonecutter→Kamnoseštvo+ x3, GlassBench→Steklarstvo+ x2, Metalwork→Kovaštvo+ x4)
    GlassBenchMaker               = {"Metalwork", "MasonStonecutter"},  -- multi! CROSS-CHAIN: metal frame + stone legs → Kamnoseštvo+
    GlassBlowerPipeMaker          = {"Metalwork", "GlassBench"},         -- multi! CROSS-CHAIN: metal tube + glass mouthpiece → Steklarstvo+
    GlassBlowingMoldMaker         = {"WoodLathe", "MasonStonecutter"},  -- multi! CROSS-CHAIN: wooden mold + stone base → Kamnoseštvo+
    GlassBlowpipeCoolingRackMaker  = {"WoodLathe", "Metalwork"},         -- multi! wooden rack + metal supports
    GlassCoolingRackMaker          = {"GlassBench", "MasonStonecutter"}, -- multi! CROSS-CHAIN: glass surface + stone base → Steklarstvo+ & Kamnoseštvo+
    GlassPipeShearsMaker           = {"Metalwork", "WoodLathe"},         -- multi! metal blades + wooden handle

    -- v3.12.007: Glass Annealing+ 2 chain (annealing cradles, glory holes, punty warmers)
    -- 6 multi-prereq out of 6 (5th time all multi!); 3 CROSS-CHAIN links (MasonStonecutter→Kamnoseštvo+ x3, GlassBench→Steklarstvo+ x2, Metalwork→Kovaštvo+ x5)
    GlassAnnealingCradleMaker        = {"Metalwork", "MasonStonecutter"},  -- multi! CROSS-CHAIN: metal cradle + stone base → Kamnoseštvo+
    GlassAnnealingOvenDoorWheelMaker = {"Metalwork", "WoodLathe"},         -- multi! metal wheel + wooden frame
    GlassAnnealingTongJawsMaker      = {"Metalwork", "GlassBench"},         -- multi! CROSS-CHAIN: metal jaws + glass coating → Steklarstvo+
    GlassGloryHoleMaker              = {"MasonStonecutter", "Metalwork"},  -- multi! CROSS-CHAIN: stone chamber + metal burner → Kamnoseštvo+
    GlassGloryHoleDamperMaker        = {"Metalwork", "MasonStonecutter"},   -- multi! CROSS-CHAIN: metal damper + stone frame → Kamnoseštvo+
    GlassPuntyWarmerMaker            = {"GlassBench", "Metalwork"},         -- multi! CROSS-CHAIN: glass warming tube + metal frame → Steklarstvo+

    -- v3.12.008: Glass Engraving+ 2 chain (engraving lathe chucks, wheel bearings, polishing, frit, shears, ribbons)
    -- 6 multi-prereq out of 6 (6th time all multi!); 3 CROSS-CHAIN links (GlassBench→Steklarstvo+ x3, MasonStonecutter→Kamnoseštvo+ x2, Metalwork→Kovaštvo+ x5)
    GlassEngravingLatheChuckMaker   = {"Metalwork", "GlassBench"},      -- multi! CROSS-CHAIN: metal chuck + glass abrasive → Steklarstvo+
    GlassEngravingWheelBearingMaker  = {"Metalwork", "WoodLathe"},      -- multi! metal bearing + wooden housing
    GlassEngravingWheelRestMaker     = {"WoodLathe", "MasonStonecutter"}, -- multi! CROSS-CHAIN: wooden rest + stone base → Kamnoseštvo+
    GlassPolishingPadMaker           = {"GlassBench", "MasonStonecutter"}, -- multi! CROSS-CHAIN: glass abrasive pad + stone backing → Steklarstvo+ & Kamnoseštvo+
    GlassFritMaker                   = {"Metalwork", "GlassBench"},      -- multi! CROSS-CHAIN: metal crusher + glass frit → Steklarstvo+
    GlassShearSpringMaker            = {"Metalwork", "WoodLathe"},       -- multi! metal spring + wooden handle

    -- v3.12.009: Glass Finishing+ chain (cane slicers, colorant sieving, vial shakers, skim ladles, ribbons, seeds)
    -- 6 multi-prereq out of 6 (7th time all multi!); 3 CROSS-CHAIN links (GlassBench→Steklarstvo+ x3, PigmentGrinderMaker→Barvila+, MasonStonecutter→Kamnoseštvo+)
    GlassCaneSlicerMaker              = {"Metalwork", "GlassBench"},      -- multi! CROSS-CHAIN: metal blade + glass guide → Steklarstvo+
    GlassColorantSievingClothMaker    = {"WoodLathe", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: wooden frame + pigment cloth → Barvila+
    GlassColorantVialShakerMaker     = {"Metalwork", "GlassBench"},      -- multi! CROSS-CHAIN: metal shaker + glass vial → Steklarstvo+
    GlassMoltenGlassSkimLadleMaker   = {"Metalwork", "MasonStonecutter"}, -- multi! CROSS-CHAIN: metal ladle + stone base → Kamnoseštvo+
    GlassRibbonMaker                 = {"WoodLathe", "Metalwork"},        -- multi! wooden spindle + metal frame
    GlassSeedMaker                   = {"Metalwork", "GlassBench"},      -- multi! CROSS-CHAIN: metal mold + glass seed → Steklarstvo+

    -- v3.12.010: Smith Quench+ chain (quench buckets, oil dippers, filters, drain valves, gaskets, thermometers)
    -- 6 multi-prereq out of 6 (8th time all multi!); 3 CROSS-CHAIN links (GlassBench→Steklarstvo+ x2, MasonStonecutter→Kamnoseštvo+, Metalwork→Kovaštvo+ x6)
    QuenchBucketMaker           = {"Metalwork", "WoodLathe"},       -- multi! metal bucket + wooden handle
    QuenchOilDipperMaker         = {"Metalwork", "WoodLathe"},       -- multi! metal dipper + wooden handle
    QuenchOilFilterMaker         = {"Metalwork", "GlassBench"},      -- multi! CROSS-CHAIN: metal filter + glass container → Steklarstvo+
    QuenchTankDrainValveMaker    = {"Metalwork", "MasonStonecutter"}, -- multi! CROSS-CHAIN: metal valve + stone tank base → Kamnoseštvo+
    QuenchTankLidGasketMaker     = {"Metalwork", "WoodLathe"},       -- multi! metal gasket + wooden lid
    QuenchTankThermometerMaker   = {"Metalwork", "GlassBench"},      -- multi! CROSS-CHAIN: metal instrument + glass tube → Steklarstvo+

    -- v3.12.011: Forge+ chain (forge ash management, tuyere cooling, chimney, clinker)
    -- 6 multi-prereq out of 6 (9th time all multi!); 3 CROSS-CHAIN links (GlassBench→Steklarstvo+ x2, MasonStonecutter→Kamnoseštvo+ x2, Metalwork→Kovaštvo+ x5)
    ForgeTuyereCoolerMaker    = {"Metalwork", "GlassBench"},      -- multi! CROSS-CHAIN: metal cooler + glass inspection → Steklarstvo+
    ForgeChimneyDamperMaker   = {"Metalwork", "MasonStonecutter"}, -- multi! CROSS-CHAIN: metal damper + stone chimney → Kamnoseštvo+
    ForgeClinkerBreakerMaker  = {"Metalwork", "MasonStonecutter"}, -- multi! CROSS-CHAIN: metal breaker + stone grate → Kamnoseštvo+
    ForgeAshPanMaker          = {"Metalwork", "WoodLathe"},       -- multi! metal pan + wooden handle
    ForgeHoodFlueMaker        = {"Metalwork", "GlassBench"},      -- multi! CROSS-CHAIN: metal flue + glass inspection → Steklarstvo+
    ForgeCokeRakeMaker        = {"Metalwork", "WoodLathe"},       -- multi! metal rake + wooden handle

    -- v3.12.012: Smith+ chain (hammer polishers, wedges, tongs jaw inserts, tongs rings)
    -- 6 multi-prereq out of 6 (10th time all multi!); 3 CROSS-CHAIN links (MasonStonecutter→Kamnoseštvo+ x2, GlassBench→Steklarstvo+, Metalwork→Kovaštvo+ x5)
    SmithHammerFacePolisherMaker = {"Metalwork", "MasonStonecutter"}, -- multi! CROSS-CHAIN: metal polisher + stone wheel → Kamnoseštvo+
    SmithHammerHandleWedgeMaker  = {"WoodLathe", "Metalwork"},     -- multi! wooden wedge + metal fitting
    SmithHammerWedgeMaker         = {"Metalwork", "MasonStonecutter"}, -- multi! CROSS-CHAIN: metal wedge + stone anvil → Kamnoseštvo+
    SmithTongsJawInsertMaker     = {"Metalwork", "GlassBench"},   -- multi! CROSS-CHAIN: metal jaws + glass inspection → Steklarstvo+
    SmithTongsRingMaker           = {"Metalwork", "WoodLathe"},    -- multi! metal ring + wooden grip
    SmithHammerHandleFinisherMaker = {"WoodLathe", "Metalwork"},  -- multi! wooden handle + metal ferrule

    -- v3.12.013: Leather+ chain (leather conditioners, creasers, edge bevelers, skivers, splitters)
    -- 6 multi-prereq out of 6 (11th time all multi!); 3 CROSS-CHAIN links (RawhideTanner→Usnjarstvo+, PigmentGrinderMaker→Barvila+, MasonStonecutter→Kamnoseštvo+)
    LeatherConditionerMaker   = {"RawhideTanner", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: leather conditioner + pigments → Barvila+
    LeatherCreaserMaker        = {"Metalwork", "WoodLathe"},              -- multi! metal creaser + wooden handle
    LeatherEdgeBevelerMaker    = {"Metalwork", "RawhideTanner"},          -- multi! CROSS-CHAIN: metal beveler + leather base → Usnjarstvo+
    LeatherSkiverMaker         = {"Metalwork", "MasonStonecutter"},       -- multi! CROSS-CHAIN: metal skiver + stone sharpening → Kamnoseštvo+
    LeatherSplitterMaker       = {"Metalwork", "WoodLathe"},              -- multi! metal splitter + wooden frame
    Leatherworker              = {"RawhideTanner", "WoodLathe"},          -- multi! CROSS-CHAIN: leather tools + wooden bench → Usnjarstvo+

    -- v3.12.014: Book Cover+ chain (book cover tools, edge gilding, spine creasers)
    -- 6 multi-prereq out of 6 (12th time all multi!); 3 CROSS-CHAIN links (MasonStonecutter→Kamnoseštvo+, PigmentGrinderMaker→Barvila+, RawhideTanner→Usnjarstvo+)
    BookCoverBoardShearsMaker  = {"Metalwork", "WoodLathe"},              -- multi! metal shears + wooden handles
    BookCoverCrimperMaker      = {"Metalwork", "WoodLathe"},              -- multi! metal crimper + wooden frame
    BookCoverDieMaker          = {"Metalwork", "MasonStonecutter"},       -- multi! CROSS-CHAIN: metal die + stone base → Kamnoseštvo+
    BookEdgeGilderMaker        = {"Metalwork", "PigmentGrinderMaker"},    -- multi! CROSS-CHAIN: metal gilding tools + pigments/gold → Barvila+
    BookEdgeBurnisherMaker     = {"Metalwork", "RawhideTanner"},          -- multi! CROSS-CHAIN: metal burnisher + leather pad → Usnjarstvo+
    BookSpineCreaserMaker      = {"Metalwork", "WoodLathe"},              -- multi! metal creaser + wooden spine support

    -- v3.12.015: Book Cover Tools+ 2 chain (miters, trimmers, cutters, stamps, presses)
    -- 6 multi-prereq out of 6 (13th time all multi!); 3 CROSS-CHAIN links (MasonStonecutter→Kamnoseštvo+, PigmentGrinderMaker→Barvila+ x2)
    BookCoverBoardCornerMiterMaker = {"Metalwork", "WoodLathe"},          -- multi! metal miter + wooden guide
    BookCoverBoardEdgeTrimmerMaker = {"Metalwork", "WoodLathe"},          -- multi! metal trimmer + wooden fence
    BookCoverCornerCutterMaker     = {"Metalwork", "MasonStonecutter"},   -- multi! CROSS-CHAIN: metal cutter + stone base → Kamnoseštvo+
    BookCoverStampMaker            = {"Metalwork", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: metal stamp + pigments/foil → Barvila+
    BookCoverStampingFoilMaker     = {"Metalwork", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: foil tools + pigments → Barvila+
    BookCoverLeverPressMaker       = {"Metalwork", "WoodLathe"},          -- multi! metal lever + wooden press frame

    -- v3.12.016: Book Edge+ chain (edge coloring, gilt, polishing, painting)
    -- 6 multi-prereq out of 6 (14th time all multi!); 3 CROSS-CHAIN links (PigmentGrinderMaker→Barvila+ x3, MasonStonecutter→Kamnoseštvo+, RawhideTanner→Usnjarstvo+)
    BookEdgeColoringSpongeMaker      = {"WoodLathe", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: wooden handle + pigments → Barvila+
    BookEdgeGiltBurnisherMaker       = {"Metalwork", "RawhideTanner"},      -- multi! CROSS-CHAIN: metal burnisher + leather → Usnjarstvo+
    BookEdgeGiltSizeApplicatorMaker  = {"Metalwork", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: applicator + size/pigments → Barvila+
    BookEdgeGiltSizeBrushMaker       = {"WoodLathe", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: wooden brush + pigments → Barvila+
    BookEdgePainterMaker             = {"WoodLathe", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: wooden brush + pigments → Barvila+
    BookEdgePolishingStoneMaker      = {"MasonStonecutter", "Metalwork"},   -- multi! CROSS-CHAIN: stone polisher + metal mount → Kamnoseštvo+

    -- v3.12.017: Book Sewing+ chain (sewing bench, cords, needles, frames, reels)
    -- 6 multi-prereq out of 6 (15th time all multi!); 2 CROSS-CHAIN links (Metalwork+WoodLathe dominant; SpinningWheel for thread)
    BookSewingBenchHookMaker    = {"Metalwork", "WoodLathe"},             -- multi! metal hook + wooden bench
    BookSewingNeedleCaseMaker   = {"Metalwork", "WoodLathe"},             -- multi! metal case + wooden lid
    BookSewingCordSpoolMaker    = {"WoodLathe", "SpinningWheel"},         -- multi! CROSS-CHAIN: wooden spool + thread → Tekstil+
    BookSewingFrameToggleMaker  = {"Metalwork", "WoodLathe"},             -- multi! metal toggle + wooden frame
    BookStitchingFrameMaker     = {"WoodLathe", "Metalwork"},             -- multi! wooden frame + metal fittings
    BookThreadReelMaker         = {"WoodLathe", "SpinningWheel"},         -- multi! CROSS-CHAIN: wooden reel + thread → Tekstil+

    -- v3.12.018: Book Spine & Press+ chain (spine tools, glue, presses, bookshelf)
    -- 6 multi-prereq out of 6 (16th time all multi!); 3 CROSS-CHAIN links (MasonStonecutter→Kamnoseštvo+, Metalwork, WoodLathe)
    BookSpineGlueBrushMaker      = {"WoodLathe", "Metalwork"},            -- multi! wooden brush + metal ferrule
    BookSpineGluePotStandMaker   = {"WoodLathe", "Metalwork"},            -- multi! wooden stand + metal pot ring
    BookSpineLiningRollerMaker   = {"WoodLathe", "Metalwork"},            -- multi! wooden roller + metal axle
    BookbindingPressStoneMaker   = {"MasonStonecutter", "WoodLathe"},     -- multi! CROSS-CHAIN: stone weight + wooden press → Kamnoseštvo+
    BookbindingScrewPressMaker   = {"Metalwork", "WoodLathe"},            -- multi! metal screw + wooden press
    BookshelfMaker               = {"WoodLathe", "Metalwork"},            -- multi! wooden shelves + metal brackets

    -- v3.12.019: Book Cover Paste & Inlay+ chain (paste tools, inlay, gauge, cord winder)
    -- 6 multi-prereq out of 6 (17th time all multi!); 3 CROSS-CHAIN links (PigmentGrinderMaker→Barvila+, MasonStonecutter→Kamnoseštvo+, SpinningWheel→Tekstil+)
    BookCoverCordWinderMaker   = {"WoodLathe", "SpinningWheel"},         -- multi! CROSS-CHAIN: wooden winder + cord → Tekstil+
    BookCoverGaugeMaker        = {"Metalwork", "WoodLathe"},             -- multi! metal gauge + wooden handle
    BookCoverInlayMaker        = {"Metalwork", "WoodLathe"},             -- multi! metal inlay tools + wooden support
    BookCoverInlayRouterMaker  = {"Metalwork", "MasonStonecutter"},      -- multi! CROSS-CHAIN: metal router + stone guide → Kamnoseštvo+
    BookCoverPasteBrushMaker   = {"WoodLathe", "PigmentGrinderMaker"},   -- multi! CROSS-CHAIN: wooden brush + paste/pigments → Barvila+
    BookCoverPasteRollerMaker  = {"WoodLathe", "Metalwork"},             -- multi! wooden roller + metal axle

    -- v3.12.020: Book Finishing+ chain (paste spatula, endband, foredge, tassel, press, weight)
    -- 6 multi-prereq out of 6 (18th time all multi!); 3 CROSS-CHAIN links (SpinningWheel→Tekstil+, MasonStonecutter→Kamnoseštvo+, PigmentGrinderMaker→Barvila+)
    BookCoverPasteSpatulaMaker = {"Metalwork", "WoodLathe"},             -- multi! metal spatula + wooden handle
    BookEndbandLoomMaker       = {"WoodLathe", "SpinningWheel"},         -- multi! CROSS-CHAIN: wooden loom + thread → Tekstil+
    BookForedgeFanMaker        = {"WoodLathe", "Metalwork"},             -- multi! wooden fan + metal pivot
    BookMarkTasselMaker        = {"SpinningWheel", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: thread + dye → Tekstil+ & Barvila+
    BookPressMaker             = {"WoodLathe", "Metalwork"},             -- multi! wooden press + metal screw
    BookPressingWeightMaker    = {"MasonStonecutter", "WoodLathe"},      -- multi! CROSS-CHAIN: stone weight + wooden base → Kamnoseštvo+

    -- v3.12.021: Book Spine Remaining+ chain (7 systems — final Book residual: sewing light, spine tools, glue pot, press)
    -- 7 multi-prereq out of 7 (19th consecutive all-multi package!); 3 CROSS-CHAIN links (GlassBench→Steklarstvo+, PigmentGrinderMaker→Barvila+, MasonStonecutter→Kamnoseštvo+)
    BookSewingBenchLightMaker    = {"Metalwork", "GlassBench"},          -- multi! CROSS-CHAIN: metal lamp + glass → Steklarstvo+
    BookSpineGiltSizeGaugeMaker  = {"Metalwork", "PigmentGrinderMaker"}, -- multi! CROSS-CHAIN: metal gauge + gilt size → Barvila+
    BookSpineLabelPrinterMaker   = {"Metalwork", "WoodLathe"},           -- multi! metal type + wooden press
    BookSpineLiningClothMaker    = {"SpinningWheel", "WoodLathe"},       -- multi! CROSS-CHAIN: cloth + wooden stretcher → Tekstil+
    BookSpineRulerMaker          = {"Metalwork", "WoodLathe"},           -- multi! metal rule + wooden stock
    BookbindingGluePotMaker      = {"Metalwork", "WoodLathe"},           -- multi! metal pot + wooden handle
    BookbindingPressMaker        = {"WoodLathe", "MasonStonecutter"},    -- multi! CROSS-CHAIN: wooden press + stone platen → Kamnoseštvo+

    -- v3.12.022: Garden Tools+ chain (basic hand tools: fork, hoe, rake, trowel, mulch fork, furrow)
    -- 6 multi-prereq out of 6 (20th consecutive all-multi!); Metalwork+WoodLathe dominant
    GardenForkMaker      = {"Metalwork", "WoodLathe"},                   -- multi! metal tines + wooden handle
    GardenHoeMaker       = {"Metalwork", "WoodLathe"},                   -- multi! metal blade + wooden handle
    GardenRakeMaker      = {"Metalwork", "WoodLathe"},                   -- multi! metal teeth + wooden handle
    GardenTrowelMaker    = {"Metalwork", "WoodLathe"},                   -- multi! metal blade + wooden handle
    GardenMulchForkMaker = {"Metalwork", "WoodLathe"},                   -- multi! metal tines + wooden handle
    GardenFurrowMaker    = {"Metalwork", "WoodLathe"},                   -- multi! metal ploughlet + wooden beam

    -- v3.12.023: Garden Soil+ chain (sieves, screens, compost, moisture)
    -- 6 multi-prereq out of 6 (21st all-multi!); 2 CROSS-CHAIN (GlassBench→Steklarstvo+, MasonStonecutter→Kamnoseštvo+)
    GardenSieveMaker                 = {"Metalwork", "WoodLathe"},       -- multi! metal mesh + wooden frame
    GardenSieveFrameMaker            = {"WoodLathe", "Metalwork"},       -- multi! wooden frame + metal fittings
    GardenSoilScreenMaker            = {"Metalwork", "MasonStonecutter"}, -- multi! CROSS-CHAIN: metal screen + stone base → Kamnoseštvo+
    GardenCompostSifterDrumMaker     = {"Metalwork", "WoodLathe"},       -- multi! metal drum + wooden axle
    GardenCompostAeratorSpikeMaker   = {"Metalwork", "WoodLathe"},       -- multi! metal spikes + wooden handle
    GardenSoilMoistureMeterMaker     = {"Metalwork", "GlassBench"},      -- multi! CROSS-CHAIN: metal probe + glass tube → Steklarstvo+

    -- v3.12.024: Garden Planting+ chain (dibbers, seed tools)
    -- 6 multi-prereq out of 6 (22nd all-multi!); Metalwork+WoodLathe
    GardenDibberDepthGaugeMaker      = {"Metalwork", "WoodLathe"},       -- multi! metal gauge + wooden dibber
    GardenPlantDibberDepthMarkMaker  = {"Metalwork", "WoodLathe"},       -- multi! metal marks + wooden shaft
    GardenTransplantingDibberMaker   = {"Metalwork", "WoodLathe"},       -- multi! metal tip + wooden handle
    GardenSeedDibberPlateMaker       = {"Metalwork", "WoodLathe"},       -- multi! metal plate + wooden base
    GardenSeedTapeMaker              = {"WoodLathe", "SpinningWheel"},   -- multi! CROSS-CHAIN: wooden spool + tape/thread → Tekstil+
    GardenSeedPacketSealerMaker      = {"Metalwork", "WoodLathe"},       -- multi! metal sealer + wooden press

    -- v3.12.025: Garden Water & Climate+ chain (sprayers, cloche, frost, irrigation)
    -- 6 multi-prereq out of 6 (23rd all-multi!); 3 CROSS-CHAIN (GlassBench→Steklarstvo+ x2, SpinningWheel→Tekstil+)
    GardenBowlSprayerMaker             = {"Metalwork", "GlassBench"},    -- multi! CROSS-CHAIN: metal pump + glass bowl → Steklarstvo+
    GardenClocheMaker                  = {"GlassBench", "Metalwork"},    -- multi! CROSS-CHAIN: glass dome + metal frame → Steklarstvo+
    GardenFrostClothClipMaker          = {"Metalwork", "SpinningWheel"}, -- multi! CROSS-CHAIN: metal clip + cloth → Tekstil+
    GardenIrrigationTimerMaker         = {"Metalwork", "WoodLathe"},     -- multi! metal mechanism + wooden housing
    GardenPlantRootWateringSpikeMaker  = {"Metalwork", "WoodLathe"},     -- multi! metal spike + wooden top
    GardenWateringTrayMaker            = {"Metalwork", "WoodLathe"},     -- multi! metal tray + wooden stand

    -- v3.12.026: Garden Support+ chain (edgers, kneeler, grabber, line, twine, holster)
    -- 6 multi-prereq out of 6 (24th all-multi!); 2 CROSS-CHAIN (SpinningWheel→Tekstil+, RawhideTanner→Usnjarstvo+)
    GardenBorderEdgerMaker     = {"Metalwork", "WoodLathe"},             -- multi! metal edger + wooden handle
    GardenKneelerMaker         = {"WoodLathe", "RawhideTanner"},         -- multi! CROSS-CHAIN: wooden frame + leather pad → Usnjarstvo+
    GardenLeafGrabberMaker     = {"Metalwork", "WoodLathe"},             -- multi! metal claws + wooden handles
    GardenLineMaker            = {"WoodLathe", "SpinningWheel"},         -- multi! CROSS-CHAIN: wooden reels + line → Tekstil+
    GardenTwineDispenserMaker  = {"WoodLathe", "SpinningWheel"},         -- multi! CROSS-CHAIN: wooden dispenser + twine → Tekstil+
    GardenTrowelHolsterMaker   = {"RawhideTanner", "Metalwork"},         -- multi! CROSS-CHAIN: leather holster + metal clip → Usnjarstvo+

    -- v3.12.027: Garden Specialty+ chain (7 systems — labels, ties, brush, pH, sharpener, herb/veg gardeners)
    -- 7 multi-prereq out of 7 (25th all-multi package!); 3 CROSS-CHAIN (GlassBench, MasonStonecutter, PigmentGrinderMaker)
    GardenPlantLabelEmbosserMaker = {"Metalwork", "WoodLathe"},          -- multi! metal embosser + wooden press
    GardenPlantTieCutterMaker     = {"Metalwork", "WoodLathe"},          -- multi! metal cutter + wooden handle
    GardenPotBrushMaker           = {"WoodLathe", "Metalwork"},          -- multi! wooden brush + metal ferrule
    GardenSoilpHTesterMaker       = {"GlassBench", "Metalwork"},         -- multi! CROSS-CHAIN: glass vial + metal probe → Steklarstvo+
    GardenTrowelSharpenerMaker    = {"MasonStonecutter", "Metalwork"},   -- multi! CROSS-CHAIN: stone wheel + metal mount → Kamnoseštvo+
    HerbGardener                  = {"GardenRakeMaker", "WoodLathe"},    -- multi! requires garden tools base + wooden beds
    VegetableGardener             = {"GardenRakeMaker", "Metalwork"},    -- multi! requires garden tools base + metal tools

    -- v3.12.028: Grain Core+ chain (mill, farmer, sieve, spout, auger)
    -- 6 multi-prereq out of 6 (26th consecutive all-multi!)
    GrainMillMaker         = {"Metalwork", "WoodLathe"},                 -- multi! metal millworks + wooden housing
    GrainFarmer            = {"WoodLathe", "Metalwork"},                 -- multi! wooden tools + metal implements
    GrainSieveMaker        = {"Metalwork", "WoodLathe"},                 -- multi! metal mesh + wooden frame
    GrainSpoutMaker        = {"Metalwork", "WoodLathe"},                 -- multi! metal spout + wooden chute
    GrainAugerMaker        = {"Metalwork", "WoodLathe"},                 -- multi! metal screw + wooden trough
    GrainAugerSpiralMaker  = {"Metalwork", "WoodLathe"},                 -- multi! metal spiral + wooden core

    -- v3.12.029: Grain Hopper+ chain (hopper gates, liners, sensors, probes)
    -- 6 multi-prereq out of 6 (27th all-multi!); 2 CROSS-CHAIN (GlassBench→Steklarstvo+)
    GrainHopperAugerMaker        = {"Metalwork", "WoodLathe"},           -- multi! metal auger + wooden hopper
    GrainHopperLevelSensorMaker  = {"Metalwork", "GlassBench"},          -- multi! CROSS-CHAIN: metal sensor + glass → Steklarstvo+
    GrainHopperLinerMaker        = {"Metalwork", "WoodLathe"},           -- multi! metal liner + wooden box
    GrainHopperSlideGateMaker    = {"Metalwork", "WoodLathe"},           -- multi! metal gate + wooden frame
    GrainMoistureMeterMaker      = {"Metalwork", "GlassBench"},          -- multi! CROSS-CHAIN: probe + glass tube → Steklarstvo+
    GrainProbeMaker              = {"Metalwork", "WoodLathe"},           -- multi! metal probe + wooden handle

    -- v3.12.030: Grain Sampling & Mill Drive+ chain
    -- 6 multi-prereq out of 6 (28th all-multi!); 1 CROSS-CHAIN (SpinningWheel→Tekstil+ for belt)
    GrainSamplerProbeMaker       = {"Metalwork", "WoodLathe"},           -- multi! metal probe + wooden shaft
    MillDriveBeltMaker           = {"SpinningWheel", "WoodLathe"},       -- multi! CROSS-CHAIN: belt cloth + wooden pulleys → Tekstil+
    MillHopperAgitatorMaker      = {"Metalwork", "WoodLathe"},           -- multi! metal agitator + wooden shaft
    MillHopperLevelFloatMaker    = {"WoodLathe", "Metalwork"},           -- multi! wooden float + metal pivot
    MillHopperLidMaker           = {"WoodLathe", "Metalwork"},           -- multi! wooden lid + metal hinges
    MillHopperLubricatorMaker    = {"Metalwork", "WoodLathe"},           -- multi! metal oiler + wooden reservoir

    -- v3.12.031: Mill Hopper Mech+ chain (vibrator, springs)
    -- 6 multi-prereq out of 6 (29th all-multi!); sail cloth start
    MillHopperVibratorMaker              = {"Metalwork", "WoodLathe"},   -- multi! metal vibrator + wooden mount
    MillHopperVibratorSpringMaker        = {"Metalwork", "WoodLathe"},   -- multi! metal spring + wooden seat
    MillSailClothMaker                   = {"SpinningWheel", "WoodLathe"}, -- multi! CROSS-CHAIN: woven sail + wooden loft → Tekstil+
    MillSailClothReelMaker               = {"WoodLathe", "SpinningWheel"}, -- multi! CROSS-CHAIN: wooden reel + cloth → Tekstil+
    MillSailClothGrommetMaker            = {"Metalwork", "SpinningWheel"}, -- multi! CROSS-CHAIN: metal grommet + sail → Tekstil+
    MillSailClothGrommetInstallerMaker   = {"Metalwork", "WoodLathe"},   -- multi! metal tool + wooden anvil block

    -- v3.12.032: Mill Sail Cloth+ 2 chain (reinforcement, tension, ties, frame)
    -- 6 multi-prereq out of 6 (30th all-multi!); 3 CROSS-CHAIN Tekstil+
    MillSailClothReinforcementStripMaker = {"SpinningWheel", "WoodLathe"}, -- multi! CROSS-CHAIN: reinforced cloth + wooden form → Tekstil+
    MillSailClothTensionerMaker          = {"Metalwork", "SpinningWheel"}, -- multi! CROSS-CHAIN: metal tensioner + sail → Tekstil+
    MillSailClothTieDownStrapMaker       = {"SpinningWheel", "Metalwork"}, -- multi! CROSS-CHAIN: strap + metal buckle → Tekstil+
    MillSailFrameMaker                   = {"WoodLathe", "Metalwork"},   -- multi! wooden frame + metal fittings
    MillstoneBalanceWeightMaker          = {"Metalwork", "MasonStonecutter"}, -- multi! CROSS-CHAIN: metal weight + stone → Kamnoseštvo+
    MillstoneBushMaker                   = {"Metalwork", "WoodLathe"},   -- multi! metal bush + wooden housing

    -- v3.12.033: Millstone Dressing+ chain (chalk, compass, hammer, pick, gauge, reamer)
    -- 6 multi-prereq out of 6 (31st all-multi!); 2 CROSS-CHAIN (MasonStonecutter→Kamnoseštvo+)
    MillstoneDressingChalkMaker      = {"MasonStonecutter", "WoodLathe"}, -- multi! CROSS-CHAIN: chalk/stone + wooden holder → Kamnoseštvo+
    MillstoneDressingCompassMaker    = {"Metalwork", "WoodLathe"},       -- multi! metal compass + wooden beam
    MillstoneDressingHammerMaker     = {"Metalwork", "WoodLathe"},       -- multi! metal head + wooden handle
    MillstoneDressingPickMaker       = {"Metalwork", "WoodLathe"},       -- multi! metal pick + wooden handle
    MillstoneGrooveDepthGaugeMaker   = {"Metalwork", "MasonStonecutter"}, -- multi! CROSS-CHAIN: metal gauge + stone reference → Kamnoseštvo+
    MillstoneEyeReamerMaker          = {"Metalwork", "WoodLathe"},       -- multi! metal reamer + wooden stock

    -- v3.12.034: Millstone Lift & Tenter+ chain (crane, hooks, winch, tenter, quill, chute)
    -- 6 multi-prereq out of 6 (32nd all-multi!)
    MillstoneCraneHookMaker          = {"Metalwork", "WoodLathe"},       -- multi! metal hook + wooden crane arm
    MillstoneCraneWinchMaker         = {"Metalwork", "WoodLathe"},       -- multi! metal winch + wooden drum
    MillstoneLifterHooksMaker        = {"Metalwork", "WoodLathe"},       -- multi! metal hooks + wooden beam
    MillstoneTenterHookMaker         = {"Metalwork", "WoodLathe"},       -- multi! metal tenter + wooden lever
    MillstoneTenteringScrewMaker     = {"Metalwork", "WoodLathe"},       -- multi! metal screw + wooden nut block
    MillstoneGrainFeedChuteMaker     = {"WoodLathe", "Metalwork"},       -- multi! wooden chute + metal liner

    -- v3.12.035: Mill Specialty+ chain (groove, quill, gunpowder, sawmill, snuff, spice)
    -- 6 multi-prereq out of 6 (33rd all-multi!); MILL COMPLETE
    MillstoneGrooveReframerMaker     = {"Metalwork", "MasonStonecutter"}, -- multi! CROSS-CHAIN: metal reframer + stone → Kamnoseštvo+
    MillstoneQuillMaker              = {"Metalwork", "WoodLathe"},       -- multi! metal quill + wooden sleeve
    GunpowderMill                    = {"Metalwork", "WoodLathe"},       -- multi! metal mill + wooden housing (careful process)
    Sawmill                          = {"Metalwork", "WoodLathe"},       -- multi! metal blade + wooden frame
    SnuffMiller                      = {"Metalwork", "WoodLathe"},       -- multi! metal mill + wooden box
    SpiceMillMaker                   = {"Metalwork", "WoodLathe"},       -- multi! metal grinding + wooden body

    -- v3.12.036: Forge Residual+ chain (ash, bellows, brick, chimney, coal rake, spark)
    -- 6 multi-prereq out of 6 (34th consecutive all-multi!); 2 CROSS-CHAIN (MasonStonecutter→Kamnoseštvo+, GlassBench→Steklarstvo+)
    ForgeAshGateValveMaker   = {"Metalwork", "WoodLathe"},               -- multi! metal valve + wooden handle
    ForgeAshRiddleMaker      = {"Metalwork", "WoodLathe"},               -- multi! metal riddle + wooden frame
    ForgeBellowsValveMaker   = {"Metalwork", "RawhideTanner"},           -- multi! CROSS-CHAIN: metal valve + leather bellows → Usnjarstvo+
    ForgeBrickMaker          = {"MasonStonecutter", "Metalwork"},        -- multi! CROSS-CHAIN: stone/brick + metal mold → Kamnoseštvo+
    ForgeChimneyCowlMaker    = {"Metalwork", "MasonStonecutter"},        -- multi! CROSS-CHAIN: metal cowl + stone chimney → Kamnoseštvo+
    ForgeCoalRakeToothMaker  = {"Metalwork", "WoodLathe"},               -- multi! metal teeth + wooden rake

    -- v3.12.037: Forge Residual+ 2 & Casting+ chain (rake, spark, tuyere, casting skimmer)
    -- 6 multi-prereq out of 6 (35th all-multi!); 2 CROSS-CHAIN
    ForgeRakeMaker               = {"Metalwork", "WoodLathe"},           -- multi! metal rake + wooden handle
    ForgeSparkShieldMaker        = {"Metalwork", "WoodLathe"},           -- multi! metal shield + wooden mount
    ForgeTuyereBlockMaker        = {"Metalwork", "MasonStonecutter"},    -- multi! CROSS-CHAIN: metal tuyere + stone block → Kamnoseštvo+
    ForgeTuyereBrushMaker        = {"Metalwork", "WoodLathe"},           -- multi! metal brush + wooden handle
    IronForgeToolMaker           = {"Metalwork", "WoodLathe"},           -- multi! iron tools + wooden handles
    CastingLadleSkimmerMaker     = {"Metalwork", "WoodLathe"},           -- multi! metal skimmer + wooden handle

    -- v3.12.038: Smith / Apothecary / Metalworker / Astrolabe+ chain (7 systems)
    -- 7 multi-prereq out of 7 (36th all-multi package!); 3 CROSS-CHAIN (GlassBench, PotteryWheel, Metalwork)
    Metalworker              = {"Metalwork", "WoodLathe"},               -- multi! general metalwork + wooden bench
    ApothecaryMortarMaker    = {"MasonStonecutter", "PotteryWheel"},     -- multi! CROSS-CHAIN: stone mortar + pottery → Lončarstvo+
    ApothecaryVialMaker      = {"GlassBench", "PotteryWheel"},           -- multi! CROSS-CHAIN: glass vial + pottery → Steklarstvo+ & Lončarstvo+
    BlacksmithViseMaker      = {"Metalwork", "WoodLathe"},               -- multi! metal vise + wooden bench mount
    ScytheSmith              = {"Metalwork", "WoodLathe"},               -- multi! metal blade + wooden snath
    SickleSmith              = {"Metalwork", "WoodLathe"},               -- multi! metal blade + wooden handle
    AstrolabeMaker           = {"Metalwork", "GlassBench"},              -- multi! CROSS-CHAIN: metal plates + glass/sight → Steklarstvo+

    -- v3.12.039: Hat+ chain (blocks, bands, brim, crown, pins)
    -- 6 multi-prereq out of 6 (37th consecutive all-multi!); 2 CROSS-CHAIN (SpinningWheel→Tekstil+, RawhideTanner→Usnjarstvo+)
    HatBlockMaker        = {"WoodLathe", "Metalwork"},                   -- multi! wooden block + metal fittings
    HatCrownBlockMaker   = {"WoodLathe", "Metalwork"},                   -- multi! wooden crown form + metal bands
    HatBrimCurlerMaker   = {"Metalwork", "WoodLathe"},                   -- multi! metal curler + wooden handle
    HatBandMaker         = {"SpinningWheel", "WoodLathe"},               -- multi! CROSS-CHAIN: woven band + wooden loom → Tekstil+
    HatBandBuckleMaker   = {"Metalwork", "RawhideTanner"},               -- multi! CROSS-CHAIN: metal buckle + leather band → Usnjarstvo+
    HatPinMaker          = {"Metalwork", "WoodLathe"},                   -- multi! metal pin + wooden head

    -- v3.12.040: Hat+ 2 chain (box, feather, lining, maker, stretcher)
    -- 5 multi-prereq out of 5 (38th all-multi package!); 3 CROSS-CHAIN
    HatBoxMaker          = {"WoodLathe", "Metalwork"},                   -- multi! wooden box + metal hinges
    HatFeatherMaker      = {"WoodLathe", "SpinningWheel"},               -- multi! CROSS-CHAIN: wooden mount + thread binding → Tekstil+
    HatLiningMaker       = {"SpinningWheel", "RawhideTanner"},           -- multi! CROSS-CHAIN: cloth lining + leather sweatband → Tekstil+ & Usnjarstvo+
    HatMaker             = {"HatBlockMaker", "SpinningWheel"},           -- multi! requires hat block + textiles
    HatStretcherMaker    = {"WoodLathe", "Metalwork"},                   -- multi! wooden stretcher + metal screws

    -- v3.12.041: Plant Support+ chain (7 systems — nets, labels, pruners, stakes, trellis, ties)
    -- 7 multi-prereq out of 7 (39th all-multi!); 3 CROSS-CHAIN (SpinningWheel→Tekstil+)
    PlantClimbingNetMaker          = {"SpinningWheel", "WoodLathe"},     -- multi! CROSS-CHAIN: net cord + wooden frame → Tekstil+
    PlantLabelMaker                = {"WoodLathe", "Metalwork"},         -- multi! wooden label + metal stake
    PlantRootPrunerMaker           = {"Metalwork", "WoodLathe"},         -- multi! metal pruner + wooden handle
    PlantSupportMaker              = {"WoodLathe", "Metalwork"},         -- multi! wooden support + metal fittings
    PlantSupportStakeMaker         = {"WoodLathe", "Metalwork"},         -- multi! wooden stake + metal tip
    PlantSupportTrellisPanelMaker  = {"WoodLathe", "SpinningWheel"},     -- multi! CROSS-CHAIN: wooden panel + cord → Tekstil+
    PlantTyingTwistMaker           = {"SpinningWheel", "WoodLathe"},     -- multi! CROSS-CHAIN: twist ties + wooden spool → Tekstil+

    -- v3.12.042: Flour & Dough+ chain (flour tools + dough tools — bakery chain)
    -- 7 multi-prereq out of 7 (40th all-multi!); 1 CROSS-CHAIN (SpinningWheel→Tekstil+ for sacks)
    FlourPackerMaker     = {"WoodLathe", "Metalwork"},                   -- multi! wooden packer + metal scoop
    FlourSackMaker       = {"SpinningWheel", "WoodLathe"},               -- multi! CROSS-CHAIN: woven sack + wooden form → Tekstil+
    FlourShovelMaker     = {"Metalwork", "WoodLathe"},                   -- multi! metal blade + wooden handle
    FlourSieveMaker      = {"Metalwork", "WoodLathe"},                   -- multi! metal mesh + wooden frame
    DoughDividerMaker    = {"Metalwork", "WoodLathe"},                   -- multi! metal divider + wooden handle
    DoughHookMaker       = {"Metalwork", "WoodLathe"},                   -- multi! metal hook + wooden handle
    DoughScraperMaker    = {"Metalwork", "WoodLathe"},                   -- multi! metal scraper + wooden handle

    -- v3.12.043: Bell+ & Slack Tub+ chain
    -- 6 multi-prereq out of 6 (41st consecutive all-multi!); 2 CROSS-CHAIN
    BellHammerMaker      = {"Metalwork", "WoodLathe"},                   -- multi! metal hammer + wooden handle
    BellPullMaker        = {"SpinningWheel", "WoodLathe"},               -- multi! CROSS-CHAIN: rope pull + wooden wheel → Tekstil+
    BellWheelMaker       = {"WoodLathe", "Metalwork"},                   -- multi! wooden wheel + metal axle
    SlackTubMaker        = {"Metalwork", "WoodLathe"},                   -- multi! metal tub + wooden stand
    SlackTubLidMaker     = {"WoodLathe", "Metalwork"},                   -- multi! wooden lid + metal hinges
    SlackTubHoodMaker    = {"Metalwork", "WoodLathe"},                   -- multi! metal hood + wooden frame

    -- v3.12.044: Ingot+ & Quill+ chain
    -- 6 multi-prereq out of 6 (42nd all-multi!); 1 CROSS-CHAIN (ForgeTuyere for smelter)
    IngotCasterMaker     = {"Metalwork", "WoodLathe"},                   -- multi! metal caster + wooden mold frame
    IngotMoldMaker       = {"Metalwork", "MasonStonecutter"},            -- multi! CROSS-CHAIN: metal mold + stone form → Kamnoseštvo+
    IngotSmelter         = {"Metalwork", "ForgeTuyere"},                 -- multi! CROSS-CHAIN: metal furnace + forge tuyere → Livarstvo+
    QuillPenMaker        = {"WoodLathe", "Metalwork"},                   -- multi! quill shaft tools + metal knife
    QuillTrimmerMaker    = {"Metalwork", "WoodLathe"},                   -- multi! metal trimmer + wooden handle
    QuillMenderMaker     = {"Metalwork", "WoodLathe"},                   -- multi! metal mender + wooden rest

    -- v3.12.045: Royal Heraldry+ & Trade+ chain
    -- 6 multi-prereq out of 6 (43rd all-multi!); 2 CROSS-CHAIN
    RoyalBannerHerald    = {"SpinningWheel", "WoodLathe"},               -- multi! CROSS-CHAIN: cloth banner + wooden pole → Tekstil+
    RoyalCrestCarver     = {"WoodLathe", "Metalwork"},                   -- multi! wooden crest + metal tools
    RoyalSealStampMaker  = {"Metalwork", "WoodLathe"},                   -- multi! metal seal + wooden handle
    TradeGuild           = {"WoodLathe", "Metalwork"},                   -- multi! guild hall wood + metal fittings
    TradeNeg             = {"WoodLathe", "SpinningWheel"},               -- multi! CROSS-CHAIN: ledger desk + cloth samples → Tekstil+
    TradeRoute           = {"WoodLathe", "Metalwork"},                   -- multi! wooden posts + metal markers

    -- v3.12.046: Annealing+ & Banner+ & Bath+ chain
    -- 6 multi-prereq out of 6 (44th all-multi!); 2 CROSS-CHAIN (GlassBench, ForgeTuyere)
    AnnealingLehrMaker   = {"Metalwork", "GlassBench"},                  -- multi! CROSS-CHAIN: metal lehr + glass → Steklarstvo+
    AnnealingTongsMaker  = {"Metalwork", "WoodLathe"},                   -- multi! metal tongs + wooden grips
    BannerMaker          = {"SpinningWheel", "WoodLathe"},               -- multi! CROSS-CHAIN: cloth banner + wooden frame → Tekstil+
    BannerPoleMaker      = {"WoodLathe", "Metalwork"},                   -- multi! wooden pole + metal finial
    BathBucketMaker      = {"Metalwork", "WoodLathe"},                   -- multi! metal bucket + wooden handle
    BathFixtureMaker     = {"Metalwork", "WoodLathe"},                   -- multi! metal fixtures + wooden mounts

    -- v3.12.047: Bridle+ & Horse+ & Hardy+ chain
    -- 6 multi-prereq out of 6 (45th all-multi!); 2 CROSS-CHAIN (RawhideTanner→Usnjarstvo+)
    BridleMaker          = {"RawhideTanner", "Metalwork"},               -- multi! CROSS-CHAIN: leather bridle + metal bits → Usnjarstvo+
    BridleBuckleMaker    = {"Metalwork", "RawhideTanner"},               -- multi! CROSS-CHAIN: metal buckle + leather → Usnjarstvo+
    HorseBreeder         = {"WoodLathe", "RawhideTanner"},               -- multi! CROSS-CHAIN: wooden stalls + leather tack → Usnjarstvo+
    HorseHarnessMaker    = {"RawhideTanner", "Metalwork"},               -- multi! CROSS-CHAIN: leather harness + metal rings → Usnjarstvo+
    HardyHoleMaker       = {"Metalwork", "WoodLathe"},                   -- multi! metal hardy + wooden anvil block
    HardyShankMaker      = {"Metalwork", "WoodLathe"},                   -- multi! metal shank + wooden handle

    -- v3.12.048: Butter+ & Cheese+ & Compass+ chain (6 multi, 46th all-multi)
    ButterChurnMaker     = {"WoodLathe", "Metalwork"},                   -- multi! wooden churn + metal fittings
    ButterDishMaker      = {"PotteryWheel", "WoodLathe"},                -- multi! CROSS-CHAIN: pottery dish + wooden lid → Lončarstvo+
    CheeseDomeMaker      = {"GlassBench", "WoodLathe"},                  -- multi! CROSS-CHAIN: glass dome + wooden base → Steklarstvo+
    CheeseGraterMaker    = {"Metalwork", "WoodLathe"},                   -- multi! metal grater + wooden handle
    CompassMaker         = {"Metalwork", "WoodLathe"},                   -- multi! metal compass + wooden case
    CompassNeedleMaker   = {"Metalwork", "GlassBench"},                  -- multi! CROSS-CHAIN: metal needle + glass capsule → Steklarstvo+

    -- v3.12.049: Compost+ & Coronation+ & Hopper+ chain (6 multi, 47th)
    CompostAeratorMaker      = {"Metalwork", "WoodLathe"},               -- multi! metal aerator + wooden handle
    CompostSieveMaker        = {"Metalwork", "WoodLathe"},               -- multi! metal mesh + wooden frame
    CoronationCushionMaker   = {"SpinningWheel", "RawhideTanner"},       -- multi! CROSS-CHAIN: cloth cushion + leather → Tekstil+ & Usnjarstvo+
    CoronationMantleMaker    = {"SpinningWheel", "Metalwork"},           -- multi! CROSS-CHAIN: cloth mantle + metal clasps → Tekstil+
    HopperGateMaker          = {"Metalwork", "WoodLathe"},               -- multi! metal gate + wooden hopper
    HopperScaleMaker         = {"Metalwork", "WoodLathe"},               -- multi! metal scale + wooden platform

    -- v3.12.050: Inkwell+ & Iron+ & Loom+ chain (6 multi, 48th)
    InkwellDustCoverMaker    = {"Metalwork", "WoodLathe"},               -- multi! metal cover + wooden inkwell
    InkwellStopperMaker      = {"WoodLathe", "GlassBench"},              -- multi! CROSS-CHAIN: wooden stopper + glass inkwell → Steklarstvo+
    IronBeamMaker            = {"Metalwork", "WoodLathe"},               -- multi! iron beam + wooden forms
    IronGateMaker            = {"Metalwork", "WoodLathe"},               -- multi! iron gate + wooden frame
    LoomFrameMaker           = {"WoodLathe", "Metalwork"},               -- multi! wooden loom frame + metal fittings
    LoomHeddleMaker          = {"Metalwork", "WoodLathe"},               -- multi! metal heddles + wooden shaft

    -- v3.12.051: String+ & Net+ & Oil+ chain (6 multi, 49th)
    StringMaker              = {"SpinningWheel", "WoodLathe"},           -- multi! CROSS-CHAIN: spun string + wooden winder → Tekstil+
    StringWinderMaker        = {"WoodLathe", "Metalwork"},               -- multi! wooden winder + metal axle
    NetMaker                 = {"SpinningWheel", "WoodLathe"},           -- multi! CROSS-CHAIN: net cord + wooden needle → Tekstil+
    NetMendingNeedleMaker    = {"Metalwork", "WoodLathe"},               -- multi! metal needle + wooden handle
    OilLampMaker             = {"Metalwork", "GlassBench"},              -- multi! CROSS-CHAIN: metal lamp + glass chimney → Steklarstvo+
    OilPresser               = {"WoodLathe", "Metalwork"},               -- multi! wooden press + metal screw

    -- v3.12.052: Paper+ & Parchment+ & Rope+ chain (6 multi, 50th)
    PaperMaker               = {"WoodLathe", "Metalwork"},               -- multi! wooden mould + metal deckle
    PaperCuttingMachineMaker = {"Metalwork", "WoodLathe"},               -- multi! metal cutter + wooden table
    ParchmentMaker           = {"RawhideTanner", "WoodLathe"},           -- multi! CROSS-CHAIN: hide parchment + wooden frame → Usnjarstvo+
    ParchmentRackMaker       = {"WoodLathe", "Metalwork"},               -- multi! wooden rack + metal hooks
    RopeMaker                = {"SpinningWheel", "WoodLathe"},           -- multi! CROSS-CHAIN: rope walk + wooden posts → Tekstil+
    RopeSpinner              = {"SpinningWheel", "WoodLathe"},           -- multi! CROSS-CHAIN: spinner + wooden wheel → Tekstil+

    -- v3.12.053: Sack+ & Saddle+ & Salt+ chain (6 multi, 51st)
    SackLoaderMaker          = {"WoodLathe", "Metalwork"},               -- multi! wooden loader + metal hooks
    SackStitcherMaker        = {"Metalwork", "SpinningWheel"},           -- multi! CROSS-CHAIN: metal needle + thread → Tekstil+
    SaddlePolishMaker        = {"RawhideTanner", "WoodLathe"},           -- multi! CROSS-CHAIN: leather polish tools + wooden → Usnjarstvo+
    SaddleSoapMaker          = {"RawhideTanner", "Metalwork"},           -- multi! CROSS-CHAIN: soap for leather + metal pans → Usnjarstvo+
    SaltPanWorker            = {"Metalwork", "WoodLathe"},               -- multi! metal pans + wooden rakes
    SaltRefiner              = {"Metalwork", "WoodLathe"},               -- multi! metal refiner + wooden troughs

    -- v3.12.054: Seed+ & Serving+ & Spice+ chain (6 multi, 52nd)
    SeedDrillMaker           = {"Metalwork", "WoodLathe"},               -- multi! metal drill + wooden hopper
    SeedDrillPlowMaker       = {"Metalwork", "WoodLathe"},               -- multi! metal plow + wooden beam
    ServingPlateMaker        = {"PotteryWheel", "WoodLathe"},            -- multi! CROSS-CHAIN: pottery plate + wooden stand → Lončarstvo+
    ServingTongsMaker        = {"Metalwork", "WoodLathe"},               -- multi! metal tongs + wooden handles
    SpiceMerchant            = {"WoodLathe", "GlassBench"},              -- multi! CROSS-CHAIN: wooden shop + glass jars → Steklarstvo+
    SpiceRackMaker           = {"WoodLathe", "Metalwork"},               -- multi! wooden rack + metal hooks

    -- v3.12.055: Star Chart+ & State+ & Stirrup+ chain (6 multi, 53rd)
    StarChartMaker           = {"WoodLathe", "Metalwork"},               -- multi! wooden chart + metal pins
    StarChartRackMaker       = {"WoodLathe", "Metalwork"},               -- multi! wooden rack + metal fittings
    StateCordonMaker         = {"SpinningWheel", "Metalwork"},           -- multi! CROSS-CHAIN: cordon rope + metal posts → Tekstil+
    StateSpearMaker          = {"Metalwork", "WoodLathe"},               -- multi! metal spearhead + wooden shaft
    StirrupMaker             = {"Metalwork", "WoodLathe"},               -- multi! metal stirrup + wooden forms
    StirrupLeatherMaker      = {"RawhideTanner", "Metalwork"},           -- multi! CROSS-CHAIN: leather straps + metal → Usnjarstvo+

    -- v3.12.056: Sugar+ & Top Fuller+ & Watering+ chain (6 multi, 54th)
    SugarRefiner             = {"Metalwork", "WoodLathe"},               -- multi! metal refinery + wooden troughs
    SugarTongsMaker          = {"Metalwork", "WoodLathe"},               -- multi! metal tongs + wooden handles
    TopMaker                 = {"Metalwork", "WoodLathe"},               -- multi! metal top tools + wooden handle
    TopFullerMaker           = {"Metalwork", "WoodLathe"},               -- multi! metal fuller + wooden haft
    WateringCanMaker         = {"Metalwork", "WoodLathe"},               -- multi! metal can + wooden handle
    WateringSpikeMaker       = {"Metalwork", "WoodLathe"},               -- multi! metal spike + wooden top

    -- v3.12.057: Wine+ & Wood+ & Wooden+ chain (6 multi, 55th)
    WineStrainerMaker        = {"Metalwork", "WoodLathe"},               -- multi! metal strainer + wooden frame
    WineVintner              = {"WoodLathe", "GlassBench"},              -- multi! CROSS-CHAIN: wooden barrels + glass demijohns → Steklarstvo+
    WoodLatheMaker           = {"Metalwork", "WoodLathe"},               -- multi! metal lathe parts + wooden bed
    WoodPanelingMaker        = {"WoodLathe", "Metalwork"},               -- multi! wooden panels + metal fasteners
    WoodenColumnMaker        = {"WoodLathe", "Metalwork"},               -- multi! wooden column + metal bands
    WoodenSpoonCarver        = {"WoodLathe", "Metalwork"},               -- multi! wooden blanks + metal carving tools
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
