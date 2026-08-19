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
