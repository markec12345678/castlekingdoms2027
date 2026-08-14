local game = {}
local loveframes = require("libraries.loveframes")
local ActionBar = require("states.ui.ActionBar")
local states = require("states.ui.states")
local core = require("misc")
local thread, thread2, objects
---@type Terrain
local Terrain
require("shaders.postshader")
local renderLoadingScreen = require("states.ui.loading_screen")
local renderLoadingBar = require("states.ui.loading_bar")
local loadState, progress = 1, 15
local SaveManager = require("objects.Controllers.SaveManager")
local keybindManager = require("objects.Controllers.KeybindManager")
local EVENT = require("objects.Enums.KeyEvents")
-- Castle Kingdoms 2027 - All systems consolidated into S table to avoid LuaJIT 60-upvalue limit
local S = {}
S.CombatIntegration = require("objects.Combat.CombatIntegration")
S.CombatTestScenario = require("objects.Combat.CombatTestScenario")
S.AnimationSystem = require("objects.Animation.AnimationSystem")
S.SoundSystem = require("objects.Audio.SoundSystem")
S.WeatherSystem = require("objects.Weather.WeatherSystem")
S.ModernUI = require("objects.UI.ModernUISystem")
S.LightingSystem = require("objects.Environment.LightingSystem")
S.HDRenderPipeline = require("objects.Environment.HDRenderPipeline")
S.GameServer = require("objects.Network.GameServer")
S.GameClient = require("objects.Network.GameClient")
S.Chat = require("states.ui.multiplayer.chat")
S.DiplomacyController = require("objects.Network.DiplomacyController")
S.TradeController = require("objects.Network.TradeController")
S.DiplomacyPanel = require("states.ui.multiplayer.diplomacy_panel")
S.MissionTestSuite = require("objects.QA.MissionTestSuite")
S.CrashHandler = require("objects.QA.CrashHandler")
S.PerfWatchdog = require("objects.QA.PerformanceWatchdog")
S.ReplaySystem = require("objects.QA.ReplaySystem")
S.StatisticsDashboard = require("objects.QA.StatisticsDashboard")
S.MapEditor = require("objects.QA.MapEditor")
S.AudioMix = require("objects.Audio.AudioMixSystem")
S.DynamicMusic = require("objects.Audio.DynamicMusicManager")
S.SFXLibrary = require("objects.Audio.SFXLibrary")
S.VoiceOver = require("objects.Audio.SlovenianVoiceOver")
S.ModLoader = require("objects.Modding.ModLoader")
S.CustomBuildingLoader = require("objects.Modding.CustomBuildingLoader")
S.SteamWorks = require("objects.Steam.SteamWorks")
S.LocalizationSystem = require("objects.Config.LocalizationSystem")
S.AccessibilitySystem = require("objects.Config.AccessibilitySystem")
S.TutorialSystem = require("objects.Tutorial.TutorialSystem")
S.CampaignStory = require("objects.Mission.CampaignStorySystem")
S.SiegeWeapons = require("objects.Combat.SiegeWeaponsSystem")
S.UnifiedSettings = require("states.ui.settings.unified_settings")
S.FinalBugFix = require("objects.QA.FinalBugFixPass")
S.PerfOpt = require("objects.Performance.PerformanceOptimizer")
S.AchievementIntegration = require("objects.Steam.AchievementIntegration")
S.ReleaseChecklist = require("objects.QA.ReleaseChecklist")
S.SaveCompat = require("objects.QA.SaveGameCompatibility")
S.ConfigProfiles = require("objects.Config.ConfigProfileSystem")
S.DebugConsole = require("objects.QA.DebugConsoleSystem")
S.CommunityFeedback = require("objects.QA.CommunityFeedbackSystem")
S.GameEventBus = require("objects.Core.GameEventBus")
S.IntegrationTestSuite = require("objects.QA.IntegrationTestSuite")
S.StabilityTests = require("objects.QA.StabilityTestSuite")
S.GameBalancePass = require("objects.Config.GameBalancePass")
S.VisualPolish = require("objects.Feedback.VisualPolishSystem")
S.PerfBenchmark = require("objects.QA.PerformanceBenchmark")
S.ReleaseNotesGen = require("objects.QA.ReleaseNotesGenerator")
S.WeatherGameplay = require("objects.Weather.WeatherGameplayIntegration")
S.FogOfWar = require("objects.Gameplay.FogOfWarSystem")
S.FestivalSystem = require("objects.Gameplay.FestivalSystem")
S.AchievementGallery = require("states.ui.hud.achievement_gallery")
S.FormationSystem = require("objects.Combat.UnitFormationSystem")
S.UpgradeTree = require("objects.Config.BuildingUpgradeTree")
S.LoadingTips = require("objects.UI.LoadingTipsSystem")
S.CreditsScreen = require("states.ui.hud.credits_screen")
S.EndGameScreen = require("states.ui.hud.end_game_screen")
S.ScreenshotManager = require("objects.QA.ScreenshotManager")
S.DifficultyPresets = require("objects.Config.DifficultyPresets")
S.FinalReleasePrep = require("objects.QA.FinalReleasePrep")
S.Minimap = require("objects.UI.MinimapSystem")
S.CommandQueue = require("objects.Combat.UnitCommandQueue")
S.AIDialogue = require("objects.AI.AIPersonalityDialogue")
S.GameSpeedControl = require("objects.UI.GameSpeedControl")
S.ConstructionAnim = require("objects.Feedback.ConstructionAnimation")
S.Veterancy = require("objects.Combat.UnitVeterancySystem")
S.BuildingHotkeys = require("objects.UI.BuildingHotkeys")
S.ResourceFlow = require("objects.UI.ResourceFlowVisualizer")
S.AutoSaveEnhancer = require("objects.QA.AutoSaveEnhancer")
S.ThreatAI = require("objects.AI.ThreatAssessmentAI")
S.RallyPoint = require("objects.Gameplay.RallyPointSystem")
S.RightClickDismiss = require("objects.UI.RightClickDismiss")
S.BuildingQueue = require("objects.Gameplay.BuildingQueueSystem")
S.MinimapDrag = require("objects.UI.MinimapDragScroll")
S.AutoWorker = require("objects.Gameplay.AutoWorkerAssign")
S.DynamicUnitCap = require("objects.Gameplay.DynamicUnitCap")
S.MapSizeSelector = require("objects.Gameplay.MapSizeSelector")
S.SpectatorMode = require("objects.Network.SpectatorMode")
S.CoopCampaign = require("objects.Network.CoopCampaignFramework")
S.PathOpt = require("objects.AI.PathfindingOptimizer")
S.Workshop = require("objects.Steam.SteamWorkshopIntegration")
S.SkirmishTrail = require("objects.Mission.SkirmishTrailSystem")
S.ObjectPool = require("objects.Performance.ObjectPoolingSystem")
S.Gamepad = require("objects.UI.GamepadSupport")
S.MapSharing = require("objects.Gameplay.CustomMapSharing")
S.AutoSaveIndicator = require("objects.UI.AutoSaveIndicator")
S.CommunityToolkit = require("objects.QA.CommunityToolkit")
S.AutoUpdater = require("objects.QA.AutoUpdater")
S.DailyChallenge = require("objects.Mission.DailyChallengeSystem")
S.TechnologyTree = require("objects.Config.TechnologyTree")
S.PopulationSystem = require("objects.Config.PopulationSystem")
S.ProductionChain = require("objects.Economy.ProductionChainSystem")
S.Espionage = require("objects.Gameplay.EspionageSystem")
S.DiplomaticRelations = require("objects.Network.DiplomaticRelationsSystem")
S.ArmyCommand = require("objects.Combat.ArmyCommandSystem")
S.TradeRoute = require("objects.Economy.TradeRouteSystem")
S.RandomEvent = require("objects.Gameplay.RandomEventSystem")
S.NotificationCenter = require("objects.UI.NotificationCenter")
S.BuildingManager = require("objects.Controllers.BuildingManagerSystem")
S.AchievementTracker = require("objects.Steam.AchievementTracker")
S.SupplyLine = require("objects.Gameplay.SupplyLineSystem")
S.QuestSystem = require("objects.Mission.QuestSystem")
S.Analytics = require("objects.QA.GameAnalyticsDashboard")
S.TacticalOverlay = require("objects.UI.TacticalMapOverlay")
S.Prestige = require("objects.Config.PrestigeSystem")
S.Tournament = require("objects.Gameplay.TournamentSystem")
S.Scenario = require("objects.Mission.CustomScenarioSystem")
S.Leaderboard = require("objects.Steam.LeaderboardSystem")
S.ReplayEnhanced = require("objects.QA.ReplayEnhancementSystem")
S.ModAPI = require("objects.Modding.ModdingAPI")
S.WeatherWarfare = require("objects.Gameplay.WeatherWarfareSystem")
S.HeroSystem = require("objects.Combat.HeroUnitSystem")
S.TimeManager = require("objects.Controllers.TimeManagerSystem")
S.CameraEnhanced = require("objects.UI.CameraEnhancementSystem")
S.MapGen = require("objects.Gameplay.ProceduralMapGenerator")
S.SummaryGen = require("objects.QA.GameSummaryGenerator")
S.SoundtrackMgr = require("objects.Audio.SoundtrackManager")
S.ChatCmd = require("objects.Network.ChatCommandSystem")
S.SaveState = require("objects.QA.SaveStateManager")
S.TooltipSystem = require("objects.Feedback.TooltipSystem")
S.AchievementAnim = require("objects.UI.AchievementUnlockAnimation")
S.MapEditorEnhanced = require("objects.QA.MapEditorEnhanced")
S.DDA = require("objects.Config.DynamicDifficultyAdjuster")
S.AutoTuner = require("objects.Performance.PerformanceAutoTuner")
S.Forecast = require("objects.Economy.ResourceForecastSystem")
S.Matchmaking = require("objects.Network.MatchmakingSystem")
S.StatsWidget = require("objects.UI.StatsDashboardWidget")
S.CastleSiege = require("objects.Gameplay.CastleSiegeSystem")
S.TradeNeg = require("objects.Economy.TradeNegotiationSystem")
S.Governor = require("objects.Config.GovernorSystem")
S.Court = require("objects.Config.CourtNobilitySystem")
S.Disease = require("objects.Gameplay.DiseaseHealthSystem")
S.Religion = require("objects.Gameplay.ReligionFaithSystem")
S.TradeGuild = require("objects.Economy.TradeGuildSystem")
S.Mercenary = require("objects.Combat.MercenaryContractSystem")
S.Prisoner = require("objects.Gameplay.PrisonerRansomSystem")
S.Famine = require("objects.Gameplay.FamineScarcitySystem")
S.Rebellion = require("objects.Gameplay.TreasonRebellionSystem")
S.BlackMarket = require("objects.Economy.BlackMarketSmugglingSystem")
S.Decrees = require("objects.Config.RoyalDecreesSystem")
S.Culture = require("objects.Config.CulturalEducationSystem")
S.Dynasty = require("objects.Config.RoyalMarriageDynastySystem")
S.Naval = require("objects.Combat.NavalCombatTradeSystem")
S.Winter = require("objects.Gameplay.WinterQuartersSystem")
S.Treasury = require("objects.Economy.RoyalTreasuryTaxationSystem")
S.Chronicle = require("objects.QA.ChronicleHistorySystem")
S.Heraldry = require("objects.Config.HeraldryCoatOfArmsSystem")
S.Mint = require("objects.Economy.RoyalMintCurrencySystem")
S.Tournament = require("objects.Gameplay.TournamentJoustingSystem")
S.Intrigue = require("objects.Gameplay.CourtIntrigueSpyNetworkSystem")
S.Entertainment = require("objects.Gameplay.RoyalCourtEntertainmentSystem")
S.Archive = require("objects.QA.RoyalArchiveRecordsSystem")
S.Progress = require("objects.Gameplay.RoyalProgressTourSystem")
S.Justice = require("objects.Config.MedievalLawJusticeSystem")
S.Guard = require("objects.Combat.RoyalGuardSecuritySystem")
S.Feast = require("objects.Gameplay.RoyalFeastBanquetSystem")
S.Menagerie = require("objects.Gameplay.RoyalPetMenagerieSystem")
S.Astrology = require("objects.Config.RoyalAstrologerOmensSystem")
S.Apothecary = require("objects.Gameplay.RoyalApothecaryMedicineSystem")
S.Cartographer = require("objects.QA.RoyalCartographerMapsSystem")
S.Stables = require("objects.Combat.RoyalMasterOfHorseStablesSystem")
S.Beekeeper = require("objects.Economy.RoyalBeekeeperHoneySystem")
S.Vineyard = require("objects.Economy.RoyalVineyardWineSystem")
S.Falconer = require("objects.Gameplay.RoyalFalconerHawkingSystem")
S.Gardens = require("objects.Gameplay.RoyalGardenerOrnamentalGardensSystem")
S.Alchemist = require("objects.Config.RoyalAlchemistTransmutationSystem")
S.Hunt = require("objects.Gameplay.RoyalMasterOfHuntGameSystem")
S.Forester = require("objects.Gameplay.RoyalForesterWoodlandSystem")
S.Genetics = require("objects.Gameplay.RoyalFalconryBreedingGeneticsSystem")
S.Music = require("objects.Gameplay.RoyalComposerMusicSystem")
S.Philosophy = require("objects.Config.RoyalPhilosopherWisdomSystem")
S.Physician = require("objects.Gameplay.RoyalPhysicianHealthSystem")
S.AstrologyAdv = require("objects.Config.RoyalAstrologerAdvancedSystem")
S.Engineer = require("objects.Combat.RoyalEngineerSiegeWorksSystem")
S.Diplomat = require("objects.Network.RoyalDiplomatEnvoySystem")
S.Historian = require("objects.QA.RoyalHistorianChronicleAdvancedSystem")
S.Ceremonies = require("objects.Gameplay.RoyalMasterOfCeremoniesProtocolSystem")
S.Confessor = require("objects.Config.RoyalConfessorSpiritualGuidanceSystem")
S.Minstrel = require("objects.Gameplay.RoyalMinstrelTroubadourSystem")
S.Comedy = require("objects.Gameplay.RoyalJesterAdvancedCourtComedySystem")
S.Cupbearer = require("objects.Gameplay.RoyalCupbearerTasterSystem")
S.Chandlery = require("objects.Economy.RoyalChandleryWaxWorksSystem")
S.Potter = require("objects.Economy.RoyalPotterCeramicsSystem")
S.Weaver = require("objects.Economy.RoyalWeaverTextileSystem")
S.Glassmaker = require("objects.Economy.RoyalGlassmakerStainedGlassSystem")
S.Clockmaker = require("objects.Config.RoyalClockmakerTimekeepingSystem")
S.Jeweler = require("objects.Economy.RoyalJewelerGemstoneSystem")
S.Calligraphy = require("objects.Config.RoyalCalligrapherIlluminationSystem")
S.Funerary = require("objects.Gameplay.RoyalEmbalmerFunerarySystem")
S.Perfumer = require("objects.Economy.RoyalPerfumerFragranceSystem")
S.Dyer = require("objects.Economy.RoyalDyerColorSystem")
S.Bookbinder = require("objects.Config.RoyalBookbinderLibrarySystem")
S.Sculptor = require("objects.Gameplay.RoyalSculptorStoneCarvingSystem")
S.Painter = require("objects.Gameplay.RoyalPainterFrescoSystem")
S.Metalworker = require("objects.Economy.RoyalMetalworkerBronzeCastingSystem")
S.Leatherworker = require("objects.Economy.RoyalLeatherworkerTannerySystem")
S.Surveyor = require("objects.QA.RoyalSurveyorLandMeasurementSystem")
S.TaxCollector = require("objects.Economy.RoyalTaxCollectorRevenueSystem")
S.Postal = require("objects.Network.RoyalMessengerPostalSystem")
S.Distiller = require("objects.Economy.RoyalBrewerAdvancedDistillerySystem")
S.Forge = require("objects.Combat.RoyalSmithAdvancedWeaponForgeSystem")
S.Woodworker = require("objects.Economy.RoyalWoodworkerCarpenterSystem")
S.Mason = require("objects.Economy.RoyalMasonStonecutterSystem")
S.Armorer = require("objects.Combat.RoyalArmorerShieldSystem")
S.Scribe = require("objects.Config.RoyalScribeNotarySystem")
S.Barber = require("objects.Gameplay.RoyalBarberSurgeonSystem")
S.Baker = require("objects.Economy.RoyalBakerConfectionerSystem")
S.Cooper = require("objects.Economy.RoyalCooperBarrelMakerSystem")
S.Ropemaker = require("objects.Economy.RoyalRopemakerCordageSystem")
S.Locksmith = require("objects.Config.RoyalLocksmithSecuritySystem")
S.Chandler = require("objects.Gameplay.RoyalChandlerLampMakerSystem")
S.Fletcher = require("objects.Combat.RoyalFletcherArrowMakerSystem")
S.Saddler = require("objects.Economy.RoyalSaddlerTackMakerSystem")
S.NailMaker = require("objects.Economy.RoyalNailMakerHardwareSystem")
S.SoapMaker = require("objects.Gameplay.RoyalSoapMakerCleansingSystem")
S.InkMaker = require("objects.Config.RoyalInkMakerWritingMaterialsSystem")
S.Thatcher = require("objects.Gameplay.RoyalThatcherRoofingSystem")
S.Plasterer = require("objects.Gameplay.RoyalPlastererDecoratorSystem")
S.Glazier = require("objects.Gameplay.RoyalGlazierWindowMakerSystem")
S.BellFounder = require("objects.Gameplay.RoyalBellFounderCampanologySystem")
S.OrganBuilder = require("objects.Gameplay.RoyalOrganBuilderInstrumentMakerSystem")
S.Compass = require("objects.Config.RoyalCompassNavigationMakerSystem")
S.LensGrinder = require("objects.Config.RoyalLensGrinderOpticianSystem")
S.DiceMaker = require("objects.Gameplay.RoyalDiceGameMakerSystem")
S.Embroiderer = require("objects.Gameplay.RoyalEmbroidererNeedleworkSystem")
S.Gilder = require("objects.Config.RoyalBookIlluminatorGilderSystem")
S.CombMaker = require("objects.Economy.RoyalCombHairAccessoryMakerSystem")
S.SealEngraver = require("objects.Config.RoyalSealEngraverSignetMakerSystem")
S.FanMaker = require("objects.Gameplay.RoyalFanMakerFanPainterSystem")
S.PuppetMaker = require("objects.Gameplay.RoyalPuppetMarionetteMakerSystem")
S.ButtonMaker = require("objects.Economy.RoyalButtonBuckleMakerSystem")
S.BasketWeaver = require("objects.Economy.RoyalBasketWeaverWickerworkSystem")
S.MatMaker = require("objects.Economy.RoyalMatMakerFloorCoveringSystem")
S.TokenMaker = require("objects.Config.RoyalTokenMedalMakerSystem")
S.Engraver = require("objects.Config.RoyalEngraverEtcherSystem")
S.Horologist = require("objects.Config.RoyalHorologistWatchmakerSystem")
S.ChessCarver = require("objects.Gameplay.RoyalChessPieceBoardGameCarverSystem")
S.SundialMaker = require("objects.Config.RoyalSundialGnomonMakerSystem")
S.StringMaker = require("objects.Economy.RoyalMusicalStringMakerSystem")
S.NeedleMaker = require("objects.Economy.RoyalNeedlePinMakerSystem")
S.WaxModeler = require("objects.Config.RoyalWaxModelerSealPressSystem")
-- Castle Kingdoms 2027 v3.11.7-v3.11.11: 5 new craft systems
S.TileMaker = require("objects.Economy.RoyalTileMakerFloorSystem")
S.ClayPipeMaker = require("objects.Economy.RoyalClayPipeMakerSystem")
S.SconceMaker = require("objects.Economy.RoyalSconceWallLightSystem")
S.SignBoardMaker = require("objects.Gameplay.RoyalSignBoardInnSignSystem")
S.LanternMaker = require("objects.Economy.RoyalLanternStreetLightSystem")
-- Castle Kingdoms 2027 v3.11.12-v3.11.16: 5 new craft systems
S.FunnelMaker = require("objects.Economy.RoyalFunnelMakerSystem")
S.CofferMaker = require("objects.Economy.RoyalCofferLockboxSystem")
S.BellPullMaker = require("objects.Economy.RoyalBellPullSystem")
S.KeyMaker = require("objects.Economy.RoyalKeyMakerSystem")
S.ChainMaker = require("objects.Economy.RoyalChainMakerSystem")
-- Castle Kingdoms 2027 v3.11.17-v3.11.21: 5 new craft systems
S.HingeMaker = require("objects.Economy.RoyalHingeMakerSystem")
S.BoltLatchMaker = require("objects.Economy.RoyalBoltLatchMakerSystem")
S.RivetMaker = require("objects.Economy.RoyalRivetMakerSystem")
S.CrownMaker = require("objects.Gameplay.RoyalCrownMakerSystem")
S.ScepterMaker = require("objects.Gameplay.RoyalScepterMakerSystem")
-- Castle Kingdoms 2027 v3.11.22-v3.11.26: 5 new craft systems
S.ThroneMaker = require("objects.Gameplay.RoyalThroneMakerSystem")
S.OrbMaker = require("objects.Gameplay.RoyalOrbMakerSystem")
S.SealRingMaker = require("objects.Gameplay.RoyalSealRingMakerSystem")
S.MedalMaker = require("objects.Gameplay.RoyalMedalMakerSystem")
S.TapestryLoom = require("objects.Economy.RoyalTapestryLoomSystem")
-- Castle Kingdoms 2027 v3.11.27-v3.11.31: 5 new craft systems
S.StainedGlassMaker = require("objects.Economy.RoyalStainedGlassMakerSystem")
S.CarpetLoom = require("objects.Economy.RoyalCarpetLoomSystem")
S.CushionMaker = require("objects.Economy.RoyalCushionMakerSystem")
S.BannerMaker = require("objects.Economy.RoyalBannerMakerSystem")
S.HeraldicFlagMaker = require("objects.Gameplay.RoyalHeraldicFlagMakerSystem")
-- Castle Kingdoms 2027 v3.11.32-v3.11.36: 5 new liturgical craft systems
S.CopeVestmentMaker = require("objects.Gameplay.RoyalCopeVestmentMakerSystem")
S.AltarFrontalMaker = require("objects.Gameplay.RoyalAltarFrontalMakerSystem")
S.ReliquaryMaker = require("objects.Gameplay.RoyalReliquaryMakerSystem")
S.ChrismatoryMaker = require("objects.Gameplay.RoyalChrismatoryMakerSystem")
S.ProcessionalCrossMaker = require("objects.Gameplay.RoyalProcessionalCrossMakerSystem")
-- Castle Kingdoms 2027 v3.11.37-v3.11.41: 5 new liturgical vessel systems
S.MonstranceMaker = require("objects.Gameplay.RoyalMonstranceMakerSystem")
S.CiboriumMaker = require("objects.Gameplay.RoyalCiboriumMakerSystem")
S.ChaliceMaker = require("objects.Gameplay.RoyalChaliceMakerSystem")
S.PatenMaker = require("objects.Gameplay.RoyalPatenMakerSystem")
S.ThuribleMaker = require("objects.Gameplay.RoyalThuribleCenserMakerSystem")
-- Castle Kingdoms 2027 v3.11.42-v3.11.46: 5 new musical instrument systems
S.OrganPipeMaker = require("objects.Economy.RoyalOrganPipeMakerSystem")
S.BellWheelMaker = require("objects.Economy.RoyalBellWheelMakerSystem")
S.CymbalMaker = require("objects.Economy.RoyalCymbalMakerSystem")
S.HarpMaker = require("objects.Economy.RoyalHarpMakerSystem")
S.DrummerMaker = require("objects.Economy.RoyalDrummerMakerSystem")
-- Castle Kingdoms 2027 v3.11.47-v3.11.51: 5 new musical instrument systems (string/wind)
S.LuteMaker = require("objects.Economy.RoyalLuteMakerSystem")
S.FiddleMaker = require("objects.Economy.RoyalFiddleMakerSystem")
S.PsalteryMaker = require("objects.Economy.RoyalPsalteryMakerSystem")
S.HurdyGurdyMaker = require("objects.Economy.RoyalHurdyGurdyMakerSystem")
S.RecorderMaker = require("objects.Economy.RoyalRecorderMakerSystem")
-- Castle Kingdoms 2027 v3.11.52-v3.11.56: 5 new wind instrument systems
S.ShawmMaker = require("objects.Economy.RoyalShawmMakerSystem")
S.CrumhornMaker = require("objects.Economy.RoyalCrumhornMakerSystem")
S.SackbutMaker = require("objects.Economy.RoyalSackbutMakerSystem")
S.BagpipeMaker = require("objects.Economy.RoyalBagpipeMakerSystem")
S.PipeTaborMaker = require("objects.Economy.RoyalPipeTaborMakerSystem")
-- Castle Kingdoms 2027 v3.11.57-v3.11.61: 5 new weapons & armor systems
S.SwordsmithMaker = require("objects.Gameplay.RoyalSwordsmithMakerSystem")
S.DaggerMaker = require("objects.Gameplay.RoyalDaggerMakerSystem")
S.HelmetMaker = require("objects.Gameplay.RoyalHelmetMakerSystem")
S.ShieldMaker = require("objects.Gameplay.RoyalShieldMakerSystem")
S.ArmorMaker = require("objects.Gameplay.RoyalArmorMakerSystem")
-- Castle Kingdoms 2027 v3.11.62-v3.11.66: 5 new ranged/polearm/blunt weapon systems
S.Bowyer = require("objects.Gameplay.RoyalBowyerSystem")
S.Fletcher = require("objects.Gameplay.RoyalFletcherSystem")
S.CrossbowMaker = require("objects.Gameplay.RoyalCrossbowMakerSystem")
S.PolearmMaker = require("objects.Gameplay.RoyalPolearmMakerSystem")
S.MaceAxeMaker = require("objects.Gameplay.RoyalMaceAxeMakerSystem")
-- Castle Kingdoms 2027 v3.11.67-v3.11.71: 5 new cavalry equipment systems
S.SaddleMaker = require("objects.Gameplay.RoyalSaddleMakerSystem")
S.SpurMaker = require("objects.Gameplay.RoyalSpurMakerSystem")
S.HorseArmorMaker = require("objects.Gameplay.RoyalHorseArmorMakerSystem")
S.LanceMaker = require("objects.Gameplay.RoyalLanceMakerSystem")
S.CavalryBannerMaker = require("objects.Gameplay.RoyalCavalryBannerMakerSystem")
-- Castle Kingdoms 2027 v3.11.72-v3.11.76: 5 new siege engine systems
S.CatapultMaker = require("objects.Gameplay.RoyalCatapultMakerSystem")
S.TrebuchetMaker = require("objects.Gameplay.RoyalTrebuchetMakerSystem")
S.BallistaMaker = require("objects.Gameplay.RoyalBallistaMakerSystem")
S.SiegeTowerMaker = require("objects.Gameplay.RoyalSiegeTowerMakerSystem")
S.BatteringRamMaker = require("objects.Gameplay.RoyalBatteringRamMakerSystem")
-- Castle Kingdoms 2027 v3.11.77-v3.11.81: 5 new gunpowder weapon systems
S.CannonMaker = require("objects.Gameplay.RoyalCannonMakerSystem")
S.MortarMaker = require("objects.Gameplay.RoyalMortarMakerSystem")
S.BombardMaker = require("objects.Gameplay.RoyalBombardMakerSystem")
S.HandCannonMaker = require("objects.Gameplay.RoyalHandCannonMakerSystem")
S.GrenadeMaker = require("objects.Gameplay.RoyalGrenadeMakerSystem")
-- Castle Kingdoms 2027 v3.11.82-v3.11.86: 5 new gunpowder resource systems
S.GunpowderMill = require("objects.Economy.RoyalGunpowderMillSystem")
S.SaltpeterRefinery = require("objects.Economy.RoyalSaltpeterRefinerySystem")
S.SulfurCollector = require("objects.Economy.RoyalSulfurCollectorSystem")
S.CharcoalBurner = require("objects.Economy.RoyalCharcoalBurnerSystem")
S.MatchCordMaker = require("objects.Economy.RoyalMatchCordMakerSystem")
-- Castle Kingdoms 2027 v3.11.87-v3.11.91: 5 new beverage systems
S.AleBrewer = require("objects.Economy.RoyalAleBrewerSystem")
S.MeadMaker = require("objects.Economy.RoyalMeadMakerSystem")
S.WineVintner = require("objects.Economy.RoyalWineVintnerSystem")
S.CiderPress = require("objects.Economy.RoyalCiderPressSystem")
S.BrandyDistiller = require("objects.Economy.RoyalBrandyDistillerSystem")
-- Castle Kingdoms 2027 v3.11.92-v3.11.96: 5 new food resource systems
S.SpiceMerchant = require("objects.Economy.RoyalSpiceMerchantSystem")
S.SaltRefiner = require("objects.Economy.RoyalSaltRefinerSystem")
S.SugarRefiner = require("objects.Economy.RoyalSugarRefinerSystem")
S.HoneyCollector = require("objects.Economy.RoyalHoneyCollectorSystem")
S.OilPresser = require("objects.Economy.RoyalOilPresserSystem")
-- Castle Kingdoms 2027 v3.11.97-v3.11.101: 5 new dairy & bakery systems
S.CheeseMaker = require("objects.Economy.RoyalCheeseMakerSystem")
S.ButterChurner = require("objects.Economy.RoyalButterChurnerSystem")
S.YogurtFermenter = require("objects.Economy.RoyalYogurtFermenterSystem")
S.BreadBaker = require("objects.Economy.RoyalBreadBakerSystem")
S.PastryChef = require("objects.Economy.RoyalPastryChefSystem")
-- Castle Kingdoms 2027 v3.11.102-v3.11.106: 5 new meat & preservation systems
S.SausageMaker = require("objects.Economy.RoyalSausageMakerSystem")
S.SmokedMeatCurer = require("objects.Economy.RoyalSmokedMeatCurerSystem")
S.FishSmoker = require("objects.Economy.RoyalFishSmokerSystem")
S.PickleCurer = require("objects.Economy.RoyalPickleCurerSystem")
S.Confectioner = require("objects.Economy.RoyalConfectionerSystem")
-- Castle Kingdoms 2027 v3.11.107-v3.11.111: 5 new textile raw material systems
S.DyeStuffMaker = require("objects.Economy.RoyalDyeStuffMakerSystem")
S.RawhideTanner = require("objects.Economy.RoyalRawhideTannerSystem")
S.Furrier = require("objects.Economy.RoyalFurrierSystem")
S.WoolStapler = require("objects.Economy.RoyalWoolStaplerSystem")
S.SilkReeler = require("objects.Economy.RoyalSilkReelerSystem")
-- Castle Kingdoms 2027 v3.11.112-v3.11.116: 5 new fiber raw material systems
S.LinenRetter = require("objects.Economy.RoyalLinenRetterSystem")
S.HempRetter = require("objects.Economy.RoyalHempRetterSystem")
S.CottonGin = require("objects.Economy.RoyalCottonGinSystem")
S.CanvasWeaver = require("objects.Economy.RoyalCanvasWeaverSystem")
S.RopeSpinner = require("objects.Economy.RoyalRopeSpinnerSystem")
-- Castle Kingdoms 2027 v3.11.117-v3.11.121: 5 new construction material systems
S.GlassBatchSmelter = require("objects.Economy.RoyalGlassBatchSmelterSystem")
S.IngotSmelter = require("objects.Economy.RoyalIngotSmelterSystem")
S.LimeBurner = require("objects.Economy.RoyalLimeBurnerSystem")
S.BrickMaker = require("objects.Economy.RoyalBrickMakerSystem")
S.PotteryKiln = require("objects.Economy.RoyalPotteryKilnSystem")
-- Castle Kingdoms 2027 v3.11.122-v3.11.126: 5 new wood & stone raw material systems
S.TimberFeller = require("objects.Economy.RoyalTimberFellerSystem")
S.Sawmill = require("objects.Economy.RoyalSawmillSystem")
S.QuarryMiner = require("objects.Economy.RoyalQuarryMinerSystem")
S.ClayDigger = require("objects.Economy.RoyalClayDiggerSystem")
S.GemMiner = require("objects.Economy.RoyalGemMinerSystem")
-- Castle Kingdoms 2027 v3.11.127-v3.11.131: 5 new agricultural systems
S.GrainFarmer = require("objects.Economy.RoyalGrainFarmerSystem")
S.Orchardist = require("objects.Economy.RoyalOrchardistSystem")
S.VineyardPlanter = require("objects.Economy.RoyalVineyardPlanterSystem")
S.HerbGardener = require("objects.Economy.RoyalHerbGardenerSystem")
S.ApiaryKeeper = require("objects.Economy.RoyalApiaryKeeperSystem")
-- Castle Kingdoms 2027 v3.11.132-v3.11.136: 5 new livestock farming systems
S.CattleRancher = require("objects.Economy.RoyalCattleRancherSystem")
S.SheepShepherd = require("objects.Economy.RoyalSheepShepherdSystem")
S.PigFarmer = require("objects.Economy.RoyalPigFarmerSystem")
S.PoultryKeeper = require("objects.Economy.RoyalPoultryKeeperSystem")
S.HorseBreeder = require("objects.Economy.RoyalHorseBreederSystem")
-- Castle Kingdoms 2027 v3.11.137-v3.11.141: 5 new water/economic systems
S.Fisherman = require("objects.Economy.RoyalFishermanSystem")
S.OysterFarmer = require("objects.Economy.RoyalOysterFarmerSystem")
S.WhalingCaptain = require("objects.Economy.RoyalWhalingCaptainSystem")
S.SaltPanWorker = require("objects.Economy.RoyalSaltPanWorkerSystem")
S.IceCutter = require("objects.Economy.RoyalIceCutterSystem")
-- Castle Kingdoms 2027 v3.11.142-v3.11.146: 5 new animal breeding systems
S.FalconBreeder = require("objects.Gameplay.RoyalFalconBreederSystem")
S.PigeonCourier = require("objects.Gameplay.RoyalPigeonCourierSystem")
S.HoundBreeder = require("objects.Gameplay.RoyalHoundBreederSystem")
S.HuntingFalconer = require("objects.Gameplay.RoyalHuntingFalconerSystem")
S.WarDogTrainer = require("objects.Gameplay.RoyalWarDogTrainerSystem")
-- Castle Kingdoms 2027 v3.11.147-v3.11.151: 5 new scientific/cartographic systems
S.MapMaker = require("objects.Economy.RoyalMapMakerSystem")
S.StarChartMaker = require("objects.Economy.RoyalStarChartMakerSystem")
S.PaperMaker = require("objects.Economy.RoyalPaperMakerSystem")
S.ParchmentMaker = require("objects.Economy.RoyalParchmentMakerSystem")
S.QuillPenMaker = require("objects.Economy.RoyalQuillPenMakerSystem")
-- Castle Kingdoms 2027 v3.11.152-v3.11.156: 5 new scientific instrument systems
S.AstrolabeMaker = require("objects.Economy.RoyalAstrolabeMakerSystem")
S.AbacusMaker = require("objects.Economy.RoyalAbacusMakerSystem")
S.BalanceScaleMaker = require("objects.Economy.RoyalBalanceScaleMakerSystem")
S.SextantMaker = require("objects.Economy.RoyalSextantMakerSystem")
S.ArmillarySphereMaker = require("objects.Economy.RoyalArmillarySphereMakerSystem")
-- Castle Kingdoms 2027 v3.11.157-v3.11.161: 5 new optical/measurement instrument systems
S.TelescopeMaker = require("objects.Economy.RoyalTelescopeMakerSystem")
S.HourglassMaker = require("objects.Economy.RoyalHourglassMakerSystem")
S.MicroscopeMaker = require("objects.Economy.RoyalMicroscopeMakerSystem")
S.BarometerMaker = require("objects.Economy.RoyalBarometerMakerSystem")
S.ThermometerMaker = require("objects.Economy.RoyalThermometerMakerSystem")
-- Castle Kingdoms 2027 v3.11.162-v3.11.166: 5 new medical & alchemical systems
S.SurgicalToolMaker = require("objects.Gameplay.RoyalSurgicalToolMakerSystem")
S.LeechCollector = require("objects.Gameplay.RoyalLeechCollectorSystem")
S.PlagueDoctorMaskMaker = require("objects.Gameplay.RoyalPlagueDoctorMaskMakerSystem")
S.PotionBrewer = require("objects.Gameplay.RoyalPotionBrewerSystem")
S.AlchemicalElixirMaker = require("objects.Gameplay.RoyalAlchemicalElixirMakerSystem")
-- Castle Kingdoms 2027 v3.11.167-v3.11.171: 5 new personal & entertainment systems
S.MirrorMaker = require("objects.Economy.RoyalMirrorMakerSystem")
S.WigMaker = require("objects.Economy.RoyalWigMakerSystem")
S.FortuneTeller = require("objects.Gameplay.RoyalFortuneTellerSystem")
S.TattooArtist = require("objects.Gameplay.RoyalTattooArtistSystem")
S.JesterPropsMaker = require("objects.Gameplay.RoyalJesterPropsMakerSystem")
-- Castle Kingdoms 2027 v3.11.172-v3.11.176: 5 new toy & game systems
S.BoardGameMaker = require("objects.Economy.RoyalBoardGameMakerSystem")
S.CardDeckMaker = require("objects.Economy.RoyalCardDeckMakerSystem")
S.DominoMaker = require("objects.Economy.RoyalDominoMakerSystem")
S.PlayingCardMaker = require("objects.Economy.RoyalPlayingCardMakerSystem")
S.JigsawPuzzleMaker = require("objects.Economy.RoyalJigsawPuzzleMakerSystem")
-- Castle Kingdoms 2027 v3.11.177-v3.11.181: 5 new toy & decorative systems
S.KiteMaker = require("objects.Economy.RoyalKiteMakerSystem")
S.TopMaker = require("objects.Economy.RoyalTopMakerSystem")
S.DollHouseMaker = require("objects.Economy.RoyalDollHouseMakerSystem")
S.MarbleStatueMaker = require("objects.Economy.RoyalMarbleStatueMakerSystem")
S.PerfumeBottleMaker = require("objects.Economy.RoyalPerfumeBottleMakerSystem")
-- Castle Kingdoms 2027 v3.11.182-v3.11.186: 5 new decorative furnishing systems
S.ClockFacePainter = require("objects.Economy.RoyalClockFacePainterSystem")
S.CurtainMaker = require("objects.Economy.RoyalCurtainMakerSystem")
S.ChandelierMaker = require("objects.Economy.RoyalChandelierMakerSystem")
S.CandelabraMaker = require("objects.Economy.RoyalCandelabraMakerSystem")
S.FountainMaker = require("objects.Economy.RoyalFountainMakerSystem")
S.AquariumKeeper = require("objects.Economy.RoyalAquariumKeeperSystem")
S.AviaryKeeper = require("objects.Economy.RoyalAviaryKeeperSystem")
S.TerrariumKeeper = require("objects.Economy.RoyalTerrariumKeeperSystem")
S.ButterflyBreeder = require("objects.Economy.RoyalButterflyBreederSystem")
S.BonsaiCultivator = require("objects.Economy.RoyalBonsaiCultivatorSystem")
S.VegetableGardener = require("objects.Economy.RoyalVegetableGardenerSystem")
S.MushroomForager = require("objects.Economy.RoyalMushroomForagerSystem")
S.AloeCultivator = require("objects.Economy.RoyalAloeCultivatorSystem")
S.SaffronGrower = require("objects.Economy.RoyalSaffronGrowerSystem")
S.HopsGrower = require("objects.Economy.RoyalHopsGrowerSystem")
S.InkMaker = require("objects.Economy.RoyalInkMakerSystem")
S.WaxSealPresser = require("objects.Economy.RoyalWaxSealPresserSystem")
S.CalendarMaker = require("objects.Economy.RoyalCalendarMakerSystem")
S.CodexBinder = require("objects.Economy.RoyalCodexBinderSystem")
S.ManuscriptIlluminator = require("objects.Economy.RoyalManuscriptIlluminatorSystem")
S.TasselMaker = require("objects.Economy.RoyalTasselMakerSystem")
S.Knitter = require("objects.Economy.RoyalKnitterSystem")
S.Crocheter = require("objects.Economy.RoyalCrocheterSystem")
S.LaceMaker = require("objects.Economy.RoyalLaceMakerSystem")
S.SamplerStitcher = require("objects.Economy.RoyalSamplerStitcherSystem")
S.LyreMaker = require("objects.Economy.RoyalLyreMakerSystem")
S.TrumpetMaker = require("objects.Economy.RoyalTrumpetMakerSystem")
S.FluteMaker = require("objects.Economy.RoyalFluteMakerSystem")
S.MandolinMaker = require("objects.Economy.RoyalMandolinMakerSystem")
S.PanFluteMaker = require("objects.Economy.RoyalPanFluteMakerSystem")
S.PlanetariumMaker = require("objects.Economy.RoyalPlanetariumMakerSystem")
S.SundialMaker = require("objects.Economy.RoyalSundialMakerSystem")
S.CompassMaker = require("objects.Economy.RoyalCompassMakerSystem")
S.QuadrantMaker = require("objects.Economy.RoyalQuadrantMakerSystem")
S.NocturnalMaker = require("objects.Economy.RoyalNocturnalMakerSystem")
S.CoffeeRoaster = require("objects.Economy.RoyalCoffeeRoasterSystem")
S.TeaBlender = require("objects.Economy.RoyalTeaBlenderSystem")
S.ChocolateConfectioner = require("objects.Economy.RoyalChocolateConfectionerSystem")
S.TobaccoCurer = require("objects.Economy.RoyalTobaccoCurerSystem")
S.SnuffMiller = require("objects.Economy.RoyalSnuffMillerSystem")
S.StagePropMaker = require("objects.Economy.RoyalStagePropMakerSystem")
S.CostumeTailor = require("objects.Economy.RoyalCostumeTailorSystem")
S.TheaterMaskMaker = require("objects.Economy.RoyalTheaterMaskMakerSystem")
S.EaselMaker = require("objects.Economy.RoyalEaselMakerSystem")
S.PaintMaker = require("objects.Economy.RoyalPaintMakerSystem")
S.CoronationMantleMaker = require("objects.Economy.RoyalCoronationMantleMakerSystem")
S.RoyalCrestCarver = require("objects.Economy.RoyalCrestCarverSystem")
S.RoyalSealStampMaker = require("objects.Economy.RoyalSealStampMakerSystem")
S.RoyalBannerHerald = require("objects.Economy.RoyalBannerHeraldSystem")
S.CoronationCushionMaker = require("objects.Economy.RoyalCoronationCushionMakerSystem")
S.CrucibleMaker = require("objects.Economy.RoyalCrucibleMakerSystem")
S.RetortMaker = require("objects.Economy.RoyalRetortMakerSystem")
S.HydrometerMaker = require("objects.Economy.RoyalHydrometerMakerSystem")
S.AlambicStillMaker = require("objects.Economy.RoyalAlambicStillMakerSystem")
S.ApothecaryMortarMaker = require("objects.Economy.RoyalApothecaryMortarMakerSystem")
S.KitchenKnifeMaker = require("objects.Economy.RoyalKitchenKnifeMakerSystem")
S.CutlerySmith = require("objects.Economy.RoyalCutlerySmithSystem")
S.CookwareFounder = require("objects.Economy.RoyalCookwareFounderSystem")
S.ServingPlateMaker = require("objects.Economy.RoyalServingPlateMakerSystem")
S.WoodenSpoonCarver = require("objects.Economy.RoyalWoodenSpoonCarverSystem")
S.CrystalGobletMaker = require("objects.Economy.RoyalCrystalGobletMakerSystem")
S.GlassBeadMaker = require("objects.Economy.RoyalGlassBeadMakerSystem")
S.LensGrinder = require("objects.Economy.RoyalLensGrinderSystem")
S.BeakerBlower = require("objects.Economy.RoyalBeakerBlowerSystem")
S.VitrailFoilMaker = require("objects.Economy.RoyalVitrailFoilMakerSystem")
S.ChainmailForger = require("objects.Economy.RoyalChainmailForgerSystem")
S.PlateCuirassSmith = require("objects.Economy.RoyalPlateCuirassSmithSystem")
S.GreaveArmorer = require("objects.Economy.RoyalGreaveArmorerSystem")
S.GauntletMaker = require("objects.Economy.RoyalGauntletMakerSystem")
S.HalberdSmith = require("objects.Economy.RoyalHalberdSmithSystem")
S.ParquetFloorMaker = require("objects.Economy.RoyalParquetFloorMakerSystem")
S.MosaicTileMaker = require("objects.Economy.RoyalMosaicTileMakerSystem")
S.WallpaperPrinter = require("objects.Economy.RoyalWallpaperPrinterSystem")
S.WoodPanelingMaker = require("objects.Economy.RoyalWoodPanelingMakerSystem")
S.StuccoReliefMaker = require("objects.Economy.RoyalStuccoReliefMakerSystem")
S.LongbowMaker = require("objects.Economy.RoyalLongbowMakerSystem")
S.RecurveBowMaker = require("objects.Economy.RoyalRecurveBowMakerSystem")
S.ArbalestMaker = require("objects.Economy.RoyalArbalestMakerSystem")
S.QuiverMaker = require("objects.Economy.RoyalQuiverMakerSystem")
S.HuntingTrapMaker = require("objects.Economy.RoyalHuntingTrapMakerSystem")
S.ChairMaker = require("objects.Economy.RoyalChairMakerSystem")
S.TableMaker = require("objects.Economy.RoyalTableMakerSystem")
S.CabinetMaker = require("objects.Economy.RoyalCabinetMakerSystem")
S.BedMaker = require("objects.Economy.RoyalBedMakerSystem")
S.ChestMaker = require("objects.Economy.RoyalChestMakerSystem")
S.TrophyMaker = require("objects.Economy.RoyalTrophyMakerSystem")
S.CommemorativeTokenMaker = require("objects.Economy.RoyalCommemorativeTokenMakerSystem")
S.PendantMaker = require("objects.Economy.RoyalPendantMakerSystem")
S.BroochMaker = require("objects.Economy.RoyalBroochMakerSystem")
S.LocketMaker = require("objects.Economy.RoyalLocketMakerSystem")
S.UmbrellaMaker = require("objects.Economy.RoyalUmbrellaMakerSystem")
S.PocketWatchMaker = require("objects.Economy.RoyalPocketWatchMakerSystem")
S.WalkingStickMaker = require("objects.Economy.RoyalWalkingStickMakerSystem")
S.GloveMaker = require("objects.Economy.RoyalGloveMakerSystem")
S.HatMaker = require("objects.Economy.RoyalHatMakerSystem")
S.RouletteMaker = require("objects.Economy.RoyalRouletteMakerSystem")
S.BackgammonMaker = require("objects.Economy.RoyalBackgammonMakerSystem")
S.BilliardMaker = require("objects.Economy.RoyalBilliardMakerSystem")
S.TarotCardMaker = require("objects.Economy.RoyalTarotCardMakerSystem")
S.TavernGameMaker = require("objects.Economy.RoyalTavernGameMakerSystem")
S.RoofTileMaker = require("objects.Economy.RoyalRoofTileMakerSystem")
S.IronBeamMaker = require("objects.Economy.RoyalIronBeamMakerSystem")
S.WoodenColumnMaker = require("objects.Economy.RoyalWoodenColumnMakerSystem")
S.StoneLintelMaker = require("objects.Economy.RoyalStoneLintelMakerSystem")
S.WindowFrameMaker = require("objects.Economy.RoyalWindowFrameMakerSystem")
S.BookshelfMaker = require("objects.Economy.RoyalBookshelfMakerSystem")
S.LibraryCatalogMaker = require("objects.Economy.RoyalLibraryCatalogMakerSystem")
S.ReadingDeskMaker = require("objects.Economy.RoyalReadingDeskMakerSystem")
S.ScrollCaseMaker = require("objects.Economy.RoyalScrollCaseMakerSystem")
S.ChronicleBinder = require("objects.Economy.RoyalChronicleBinderSystem")
S.IronGateMaker = require("objects.Economy.RoyalIronGateMakerSystem")
S.DrawbridgeMaker = require("objects.Economy.RoyalDrawbridgeMakerSystem")
S.PortcullisMaker = require("objects.Economy.RoyalPortcullisMakerSystem")
S.BattlementMaker = require("objects.Economy.RoyalBattlementMakerSystem")
S.WatchtowerMaker = require("objects.Economy.RoyalWatchtowerMakerSystem")
S.CeremonialSwordMaker = require("objects.Economy.RoyalCeremonialSwordMakerSystem")
S.ParadeMaceMaker = require("objects.Economy.RoyalParadeMaceMakerSystem")
S.RitualDaggerMaker = require("objects.Economy.RoyalRitualDaggerMakerSystem")
S.StateSpearMaker = require("objects.Economy.RoyalStateSpearMakerSystem")
S.PresentationAxeMaker = require("objects.Economy.RoyalPresentationAxeMakerSystem")
S.CraneMaker = require("objects.Economy.RoyalCraneMakerSystem")
S.ScaffoldMaker = require("objects.Economy.RoyalScaffoldMakerSystem")
S.PulleyMaker = require("objects.Economy.RoyalPulleyMakerSystem")
S.WinchMaker = require("objects.Economy.RoyalWinchMakerSystem")
S.WheelbarrowMaker = require("objects.Economy.RoyalWheelbarrowMakerSystem")
S.WoodLatheMaker = require("objects.Economy.RoyalWoodLatheMakerSystem")
S.DrillPressMaker = require("objects.Economy.RoyalDrillPressMakerSystem")
S.PlanerMaker = require("objects.Economy.RoyalPlanerMakerSystem")
S.SanderMaker = require("objects.Economy.RoyalSanderMakerSystem")
S.PolisherMaker = require("objects.Economy.RoyalPolisherMakerSystem")
S.GrainMillMaker = require("objects.Economy.RoyalGrainMillMakerSystem")
S.SpiceMillMaker = require("objects.Economy.RoyalSpiceMillMakerSystem")
S.ConfectionOvenMaker = require("objects.Economy.RoyalConfectionOvenMakerSystem")
S.KitchenScaleMaker = require("objects.Economy.RoyalKitchenScaleMakerSystem")
S.BakingSheetMaker = require("objects.Economy.RoyalBakingSheetMakerSystem")
S.WireDrawerMaker = require("objects.Economy.RoyalWireDrawerMakerSystem")
S.HookMaker = require("objects.Economy.RoyalHookMakerSystem")
S.MetalMeshMaker = require("objects.Economy.RoyalMetalMeshMakerSystem")
S.IronForgeToolMaker = require("objects.Economy.RoyalIronForgeToolMakerSystem")
S.CopperSheetMaker = require("objects.Economy.RoyalCopperSheetMakerSystem")
S.OilLampMaker = require("objects.Economy.RoyalOilLampMakerSystem")
S.TorchHolderMaker = require("objects.Economy.RoyalTorchHolderMakerSystem")
S.CandlestickMaker = require("objects.Economy.RoyalCandlestickMakerSystem")
S.BeaconLightMaker = require("objects.Economy.RoyalBeaconLightMakerSystem")
S.VestibuleLightMaker = require("objects.Economy.RoyalVestibuleLightMakerSystem")
S.WellBuilder = require("objects.Economy.RoyalWellBuilderSystem")
S.AqueductMaker = require("objects.Economy.RoyalAqueductMakerSystem")
S.BathFixtureMaker = require("objects.Economy.RoyalBathFixtureMakerSystem")
S.CisternMaker = require("objects.Economy.RoyalCisternMakerSystem")
S.LatrineBuilder = require("objects.Economy.RoyalLatrineBuilderSystem")
S.PlowMaker = require("objects.Economy.RoyalPlowMakerSystem")
S.HarrowMaker = require("objects.Economy.RoyalHarrowMakerSystem")
S.SickleSmith = require("objects.Economy.RoyalSickleSmithSystem")
S.ScytheSmith = require("objects.Economy.RoyalScytheSmithSystem")
S.PitchforkMaker = require("objects.Economy.RoyalPitchforkMakerSystem")
S.SpinningWheelMaker = require("objects.Economy.RoyalSpinningWheelMakerSystem")
S.LoomFrameMaker = require("objects.Economy.RoyalLoomFrameMakerSystem")
S.BobbinMaker = require("objects.Economy.RoyalBobbinMakerSystem")
S.ThreadReelMaker = require("objects.Economy.RoyalThreadReelMakerSystem")
S.DyeVatMaker = require("objects.Economy.RoyalDyeVatMakerSystem")
S.GlassFurnaceMaker = require("objects.Economy.RoyalGlassFurnaceMakerSystem")
S.AnnealingLehrMaker = require("objects.Economy.RoyalAnnealingLehrMakerSystem")
S.CrucibleFurnaceMaker = require("objects.Economy.RoyalCrucibleFurnaceMakerSystem")
S.MoldKilnMaker = require("objects.Economy.RoyalMoldKilnMakerSystem")
S.TemperingFurnaceMaker = require("objects.Economy.RoyalTemperingFurnaceMakerSystem")
S.StateCordonMaker = require("objects.Economy.RoyalStateCordonMakerSystem")
S.CeremonialSashMaker = require("objects.Economy.RoyalCeremonialSashMakerSystem")
S.ParadeShieldMaker = require("objects.Economy.RoyalParadeShieldMakerSystem")
S.CourtFanMaker = require("objects.Economy.RoyalCourtFanMakerSystem")
S.ProcessionalCanopyMaker = require("objects.Economy.RoyalProcessionalCanopyMakerSystem")
S.DistillationApparatusMaker = require("objects.Economy.RoyalDistillationApparatusMakerSystem")
S.FiltrationApparatusMaker = require("objects.Economy.RoyalFiltrationApparatusMakerSystem")
S.SublimationApparatusMaker = require("objects.Economy.RoyalSublimationApparatusMakerSystem")
S.CrystallizationDishMaker = require("objects.Economy.RoyalCrystallizationDishMakerSystem")
S.EvaporatingBasinMaker = require("objects.Economy.RoyalEvaporatingBasinMakerSystem")
S.SeedDrillMaker = require("objects.Economy.RoyalSeedDrillMakerSystem")
S.ReaperMaker = require("objects.Economy.RoyalReaperMakerSystem")
S.ThresherMaker = require("objects.Economy.RoyalThresherMakerSystem")
S.WinnowingMachineMaker = require("objects.Economy.RoyalWinnowingMachineMakerSystem")
S.SortingMachineMaker = require("objects.Economy.RoyalSortingMachineMakerSystem")
S.FishingNetMaker = require("objects.Economy.RoyalFishingNetMakerSystem")
S.FishingTrapMaker = require("objects.Economy.RoyalFishingTrapMakerSystem")
S.FishingRodMaker = require("objects.Economy.RoyalFishingRodMakerSystem")
S.HarpoonMaker = require("objects.Economy.RoyalHarpoonMakerSystem")
S.FishingBoatMaker = require("objects.Economy.RoyalFishingBoatMakerSystem")
S.PrintingPressMaker = require("objects.Economy.RoyalPrintingPressMakerSystem")
S.EngravingMachineMaker = require("objects.Economy.RoyalEngravingMachineMakerSystem")
S.TypesettingMachineMaker = require("objects.Economy.RoyalTypesettingMachineMakerSystem")
S.BookbindingPressMaker = require("objects.Economy.RoyalBookbindingPressMakerSystem")
S.PaperCuttingMachineMaker = require("objects.Economy.RoyalPaperCuttingMachineMakerSystem")
S.MedalMinter = require("objects.Economy.RoyalMedalMinterSystem")
S.RibbonWeaver = require("objects.Economy.RoyalRibbonWeaverSystem")
S.OrderInsignia = require("objects.Economy.RoyalOrderInsigniaSystem")
S.CommendationScroll = require("objects.Economy.RoyalCommendationScrollSystem")
S.CollarOfEstate = require("objects.Economy.RoyalCollarOfEstateSystem")
S.CarillonMaker = require("objects.Economy.RoyalCarillonMakerSystem")
S.GlockenspielMaker = require("objects.Economy.RoyalGlockenspielMakerSystem")
S.HandbellMaker = require("objects.Economy.RoyalHandbellMakerSystem")
S.TubularBellsMaker = require("objects.Economy.RoyalTubularBellsMakerSystem")
S.AngelusBellMaker = require("objects.Economy.RoyalAngelusBellMakerSystem")
-- Castle Kingdoms 2027 v3.11.382-v3.11.386: Mining tools batch (5 new Royal systems)
S.PickaxeMaker = require("objects.Economy.RoyalPickaxeMakerSystem")
S.ShovelMaker = require("objects.Economy.RoyalShovelMakerSystem")
S.AugerMaker = require("objects.Economy.RoyalAugerMakerSystem")
S.MiningChiselMaker = require("objects.Economy.RoyalMiningChiselMakerSystem")
S.ProspectingPanMaker = require("objects.Economy.RoyalProspectingPanMakerSystem")
-- Castle Kingdoms 2027 v3.11.387-v3.11.391: Apothecary containers batch (5 new Royal systems)
S.MortarPestleMaker = require("objects.Economy.RoyalMortarPestleMakerSystem")
S.ApothecaryVialMaker = require("objects.Economy.RoyalApothecaryVialMakerSystem")
S.SalveJarMaker = require("objects.Economy.RoyalSalveJarMakerSystem")
S.SurgicalLancetMaker = require("objects.Economy.RoyalSurgicalLancetMakerSystem")
S.PhysicPotionMaker = require("objects.Economy.RoyalPhysicPotionMakerSystem")
-- Castle Kingdoms 2027 v3.11.392-v3.11.396: Gardening equipment batch (5 new Royal systems)
S.PruningShearsMaker = require("objects.Economy.RoyalPruningShearsMakerSystem")
S.TopiaryFrameMaker = require("objects.Economy.RoyalTopiaryFrameMakerSystem")
S.GardenTrowelMaker = require("objects.Economy.RoyalGardenTrowelMakerSystem")
S.HedgeHookMaker = require("objects.Economy.RoyalHedgeHookMakerSystem")
S.WateringCanMaker = require("objects.Economy.RoyalWateringCanMakerSystem")
-- Castle Kingdoms 2027 v3.11.397-v3.11.401: Equestrian equipment batch (5 new Royal systems)
S.SaddleMaker = require("objects.Economy.RoyalSaddleMakerSystem")
S.BridleMaker = require("objects.Economy.RoyalBridleMakerSystem")
S.StirrupMaker = require("objects.Economy.RoyalStirrupMakerSystem")
S.HorseHarnessMaker = require("objects.Economy.RoyalHorseHarnessMakerSystem")
S.SaddlebagMaker = require("objects.Economy.RoyalSaddlebagMakerSystem")
-- Castle Kingdoms 2027 v3.11.402-v3.11.406: Painting equipment batch (5 new Royal systems)
S.EaselMaker = require("objects.Economy.RoyalEaselMakerSystem")
S.PaintbrushMaker = require("objects.Economy.RoyalPaintbrushMakerSystem")
S.PaletteMaker = require("objects.Economy.RoyalPaletteMakerSystem")
S.PigmentGrinderMaker = require("objects.Economy.RoyalPigmentGrinderMakerSystem")
S.CanvasStretcherMaker = require("objects.Economy.RoyalCanvasStretcherMakerSystem")
-- Castle Kingdoms 2027 v3.11.407-v3.11.411: Kitchen equipment batch (5 new Royal systems)
S.RollingPinMaker = require("objects.Economy.RoyalRollingPinMakerSystem")
S.CheeseGraterMaker = require("objects.Economy.RoyalCheeseGraterMakerSystem")
S.ButterChurnMaker = require("objects.Economy.RoyalButterChurnMakerSystem")
S.SpiceRackMaker = require("objects.Economy.RoyalSpiceRackMakerSystem")
S.CuttingBoardMaker = require("objects.Economy.RoyalCuttingBoardMakerSystem")
-- Castle Kingdoms 2027 v3.11.412-v3.11.416: Glassmaking equipment batch (5 new Royal systems)
S.GlassBlowerPipeMaker = require("objects.Economy.RoyalGlassBlowerPipeMakerSystem")
S.GlassCutterMaker = require("objects.Economy.RoyalGlassCutterMakerSystem")
S.GlassMoldMaker = require("objects.Economy.RoyalGlassMoldMakerSystem")
S.AnnealingTongsMaker = require("objects.Economy.RoyalAnnealingTongsMakerSystem")
S.GlassEngraverMaker = require("objects.Economy.RoyalGlassEngraverMakerSystem")
-- Castle Kingdoms 2027 v3.11.417-v3.11.421: Milling equipment batch (5 new Royal systems)
S.MillstoneMaker = require("objects.Economy.RoyalMillstoneMakerSystem")
S.FlourSifterMaker = require("objects.Economy.RoyalFlourSifterMakerSystem")
S.DoughHookMaker = require("objects.Economy.RoyalDoughHookMakerSystem")
S.GrainHopperMaker = require("objects.Economy.RoyalGrainHopperMakerSystem")
S.SackLoaderMaker = require("objects.Economy.RoyalSackLoaderMakerSystem")
-- Castle Kingdoms 2027 v3.11.422-v3.11.426: Hatmaking equipment batch (5 new Royal systems)
S.HatBlockMaker = require("objects.Economy.RoyalHatBlockMakerSystem")
S.HatBandMaker = require("objects.Economy.RoyalHatBandMakerSystem")
S.HatPinMaker = require("objects.Economy.RoyalHatPinMakerSystem")
S.HatFeatherMaker = require("objects.Economy.RoyalHatFeatherMakerSystem")
S.HatBoxMaker = require("objects.Economy.RoyalHatBoxMakerSystem")
-- Castle Kingdoms 2027 v3.11.427-v3.11.431: Ropemaking equipment batch (5 new Royal systems)
S.RopeMaker = require("objects.Economy.RoyalRopeMakerSystem")
S.TwineMaker = require("objects.Economy.RoyalTwineMakerSystem")
S.NetMaker = require("objects.Economy.RoyalNetMakerSystem")
S.CordageMaker = require("objects.Economy.RoyalCordageMakerSystem")
S.KnotBoardMaker = require("objects.Economy.RoyalKnotBoardMakerSystem")
-- Castle Kingdoms 2027 v3.11.432-v3.11.436: Comb-making equipment batch (5 new Royal systems)
S.CombMaker = require("objects.Economy.RoyalCombMakerSystem")
S.HairbrushMaker = require("objects.Economy.RoyalHairbrushMakerSystem")
S.HairpinMaker = require("objects.Economy.RoyalHairpinMakerSystem")
S.BeardCombMaker = require("objects.Economy.RoyalBeardCombMakerSystem")
S.LiceCombMaker = require("objects.Economy.RoyalLiceCombMakerSystem")
-- Castle Kingdoms 2027 v3.11.437-v3.11.441: Saddler's accessories batch (5 new Royal systems)
S.SaddleSoapMaker = require("objects.Economy.RoyalSaddleSoapMakerSystem")
S.SaddlePolishMaker = require("objects.Economy.RoyalSaddlePolishMakerSystem")
S.LeatherConditionerMaker = require("objects.Economy.RoyalLeatherConditionerMakerSystem")
S.StirrupLeatherMaker = require("objects.Economy.RoyalStirrupLeatherMakerSystem")
S.BridleBuckleMaker = require("objects.Economy.RoyalBridleBuckleMakerSystem")
-- Castle Kingdoms 2027 v3.11.442-v3.11.446: Wax equipment batch (5 new Royal systems)
S.CandleMoldMaker = require("objects.Economy.RoyalCandleMoldMakerSystem")
S.WickSpinnerMaker = require("objects.Economy.RoyalWickSpinnerMakerSystem")
S.WaxDipperMaker = require("objects.Economy.RoyalWaxDipperMakerSystem")
S.CandlestickBaseMaker = require("objects.Economy.RoyalCandlestickBaseMakerSystem")
S.TaperRollerMaker = require("objects.Economy.RoyalTaperRollerMakerSystem")
-- Castle Kingdoms 2027 v3.11.447-v3.11.451: Foundry/casting equipment batch (5 new Royal systems)
S.CrucibleMaker = require("objects.Economy.RoyalCrucibleMakerSystem")
S.SandMoldMaker = require("objects.Economy.RoyalSandMoldMakerSystem")
S.IngotMoldMaker = require("objects.Economy.RoyalIngotMoldMakerSystem")
S.FlaskMaker = require("objects.Economy.RoyalFlaskMakerSystem")
S.CastingLadleMaker = require("objects.Economy.RoyalCastingLadleMakerSystem")
-- Castle Kingdoms 2027 v3.11.452-v3.11.456: Blacksmith tools batch (5 new Royal systems)
S.TongMaker = require("objects.Economy.RoyalTongMakerSystem")
S.HammerMaker = require("objects.Economy.RoyalHammerMakerSystem")
S.AnvilMaker = require("objects.Economy.RoyalAnvilMakerSystem")
S.BellowsMaker = require("objects.Economy.RoyalBellowsMakerSystem")
S.ForgeTongsMaker = require("objects.Economy.RoyalForgeTongsMakerSystem")
-- Castle Kingdoms 2027 v3.11.457-v3.11.461: Woodworking tools batch (5 new Royal systems)
S.PlaneIronMaker = require("objects.Economy.RoyalPlaneIronMakerSystem")
S.ChiselBladeMaker = require("objects.Economy.RoyalChiselBladeMakerSystem")
S.SawSetMaker = require("objects.Economy.RoyalSawSetMakerSystem")
S.AugerBitMaker = require("objects.Economy.RoyalAugerBitMakerSystem")
S.ClampMaker = require("objects.Economy.RoyalClampMakerSystem")
-- Castle Kingdoms 2027 v3.11.462-v3.11.466: Ceramic equipment batch (5 new Royal systems)
S.PotteryWheelMaker = require("objects.Economy.RoyalPotteryWheelMakerSystem")
S.KilnFurnitureMaker = require("objects.Economy.RoyalKilnFurnitureMakerSystem")
S.ClayExtruderMaker = require("objects.Economy.RoyalClayExtruderMakerSystem")
S.GlazeSieveMaker = require("objects.Economy.RoyalGlazeSieveMakerSystem")
S.BisqueStandMaker = require("objects.Economy.RoyalBisqueStandMakerSystem")
-- Castle Kingdoms 2027 v3.11.467-v3.11.471: Glassmaking accessories batch (5 new Royal systems)
S.GlassBatchMaker = require("objects.Economy.RoyalGlassBatchMakerSystem")
S.GlassColorantMaker = require("objects.Economy.RoyalGlassColorantMakerSystem")
S.GlassSeedMaker = require("objects.Economy.RoyalGlassSeedMakerSystem")
S.GlassRibbonMaker = require("objects.Economy.RoyalGlassRibbonMakerSystem")
S.GlassFritMaker = require("objects.Economy.RoyalGlassFritMakerSystem")
-- Castle Kingdoms 2027 v3.11.472-v3.11.476: Weaving equipment batch (5 new Royal systems)
S.LoomHeddleMaker = require("objects.Economy.RoyalLoomHeddleMakerSystem")
S.ShuttleMaker = require("objects.Economy.RoyalShuttleMakerSystem")
S.BobbinWinderMaker = require("objects.Economy.RoyalBobbinWinderMakerSystem")
S.WarpBeamMaker = require("objects.Economy.RoyalWarpBeamMakerSystem")
S.ClothPresserMaker = require("objects.Economy.RoyalClothPresserMakerSystem")
-- Castle Kingdoms 2027 v3.11.477-v3.11.481: Bookbinding equipment batch (5 new Royal systems)
S.BookPressMaker = require("objects.Economy.RoyalBookPressMakerSystem")
S.StitchingAwlMaker = require("objects.Economy.RoyalStitchingAwlMakerSystem")
S.BindingCordMaker = require("objects.Economy.RoyalBindingCordMakerSystem")
S.LeatherCoverMaker = require("objects.Economy.RoyalLeatherCoverMakerSystem")
S.GildingPressMaker = require("objects.Economy.RoyalGildingPressMakerSystem")
-- Castle Kingdoms 2027 v3.11.482-v3.11.486: Quill/writing equipment batch (5 new Royal systems)
S.QuillCutterMaker = require("objects.Economy.RoyalQuillCutterMakerSystem")
S.InkwellMaker = require("objects.Economy.RoyalInkwellMakerSystem")
S.ParchmentRackMaker = require("objects.Economy.RoyalParchmentRackMakerSystem")
S.WaxTabletMaker = require("objects.Economy.RoyalWaxTabletMakerSystem")
S.WritingStandMaker = require("objects.Economy.RoyalWritingStandMakerSystem")
-- Castle Kingdoms 2027 v3.11.487-v3.11.491: Coin minting equipment batch (5 new Royal systems)
S.CoinPressMaker = require("objects.Economy.RoyalCoinPressMakerSystem")
S.CoinDieMaker = require("objects.Economy.RoyalCoinDieMakerSystem")
S.CoinBlankMaker = require("objects.Economy.RoyalCoinBlankMakerSystem")
S.CoinSorterMaker = require("objects.Economy.RoyalCoinSorterMakerSystem")
S.CoinScaleMaker = require("objects.Economy.RoyalCoinScaleMakerSystem")
-- Castle Kingdoms 2027 v3.11.492-v3.11.496: Musical instrument parts batch (5 new Royal systems)
S.StringWinderMaker = require("objects.Economy.RoyalStringWinderMakerSystem")
S.TuningPinMaker = require("objects.Economy.RoyalTuningPinMakerSystem")
S.BridgeMaker = require("objects.Economy.RoyalBridgeMakerSystem")
S.SoundpostMaker = require("objects.Economy.RoyalSoundpostMakerSystem")
S.TailpieceMaker = require("objects.Economy.RoyalTailpieceMakerSystem")
-- Castle Kingdoms 2027 v3.11.497-v3.11.501: Aromatic equipment batch (5 new Royal systems)
S.IncenseMolderMaker = require("objects.Economy.RoyalIncenseMolderMakerSystem")
S.PerfumeBottleMaker = require("objects.Economy.RoyalPerfumeBottleMakerSystem")
S.SachetMaker = require("objects.Economy.RoyalSachetMakerSystem")
S.PotpourriBowlMaker = require("objects.Economy.RoyalPotpourriBowlMakerSystem")
S.ScentConeMaker = require("objects.Economy.RoyalScentConeMakerSystem")
-- Castle Kingdoms 2027 v3.11.502-v3.11.506: Military equipment batch (5 new Royal systems)
S.ShieldBossMaker = require("objects.Economy.RoyalShieldBossMakerSystem")
S.SwordPommelMaker = require("objects.Economy.RoyalSwordPommelMakerSystem")
S.ScabbardChapeMaker = require("objects.Economy.RoyalScabbardChapeMakerSystem")
S.HelmetCrestMaker = require("objects.Economy.RoyalHelmetCrestMakerSystem")
S.BannerPoleMaker = require("objects.Economy.RoyalBannerPoleMakerSystem")
-- Castle Kingdoms 2027 v3.11.507-v3.11.511: Astrological equipment batch (5 new Royal systems)
S.AstrolabeRingMaker = require("objects.Economy.RoyalAstrolabeRingMakerSystem")
S.StarChartRackMaker = require("objects.Economy.RoyalStarChartRackMakerSystem")
S.CelestialGlobeMaker = require("objects.Economy.RoyalCelestialGlobeMakerSystem")
S.SundialGnomonMaker = require("objects.Economy.RoyalSundialGnomonMakerSystem")
S.CompassNeedleMaker = require("objects.Economy.RoyalCompassNeedleMakerSystem")
-- Castle Kingdoms 2027 v3.11.512-v3.11.516: Clockwork accessories batch (5 new Royal systems)
S.PendulumRodMaker = require("objects.Economy.RoyalPendulumRodMakerSystem")
S.EscapementLeverMaker = require("objects.Economy.RoyalEscapementLeverMakerSystem")
S.MainspringWinderMaker = require("objects.Economy.RoyalMainspringWinderMakerSystem")
S.ClockDialEngraverMaker = require("objects.Economy.RoyalClockDialEngraverMakerSystem")
S.ChimeHammerMaker = require("objects.Economy.RoyalChimeHammerMakerSystem")
-- Castle Kingdoms 2027 v3.11.517-v3.11.521: Bathroom equipment batch (5 new Royal systems)
S.TowelRackMaker = require("objects.Economy.RoyalTowelRackMakerSystem")
S.SoapDishMaker = require("objects.Economy.RoyalSoapDishMakerSystem")
S.BathBucketMaker = require("objects.Economy.RoyalBathBucketMakerSystem")
S.SpongeHolderMaker = require("objects.Economy.RoyalSpongeHolderMakerSystem")
S.WashstandMaker = require("objects.Economy.RoyalWashstandMakerSystem")
-- Castle Kingdoms 2027 v3.11.522-v3.11.526: Kitchen accessories batch (5 new Royal systems)
S.MortarPestleStandMaker = require("objects.Economy.RoyalMortarPestleStandMakerSystem")
S.SpiceGrinderMaker = require("objects.Economy.RoyalSpiceGrinderMakerSystem")
S.OlivePressMaker = require("objects.Economy.RoyalOlivePressMakerSystem")
S.WineStrainerMaker = require("objects.Economy.RoyalWineStrainerMakerSystem")
S.HoneyDipperMaker = require("objects.Economy.RoyalHoneyDipperMakerSystem")
-- Castle Kingdoms 2027 v3.11.527-v3.11.531: Garden accessories batch (5 new Royal systems)
S.GardenSieveMaker = require("objects.Economy.RoyalGardenSieveMakerSystem")
S.PlantSupportMaker = require("objects.Economy.RoyalPlantSupportMakerSystem")
S.WateringSpikeMaker = require("objects.Economy.RoyalWateringSpikeMakerSystem")
S.CompostAeratorMaker = require("objects.Economy.RoyalCompostAeratorMakerSystem")
S.SeedDrillPlowMaker = require("objects.Economy.RoyalSeedDrillPlowMakerSystem")
-- Castle Kingdoms 2027 v3.11.532-v3.11.536: Bakery accessories batch (5 new Royal systems)
S.DoughScraperMaker = require("objects.Economy.RoyalDoughScraperMakerSystem")
S.ProofingBasketMaker = require("objects.Economy.RoyalProofingBasketMakerSystem")
S.BreadLameMaker = require("objects.Economy.RoyalBreadLameMakerSystem")
S.OvenPeelMaker = require("objects.Economy.RoyalOvenPeelMakerSystem")
S.FlourShovelMaker = require("objects.Economy.RoyalFlourShovelMakerSystem")
-- Castle Kingdoms 2027 v3.11.537-v3.11.541: Fishing accessories batch (5 new Royal systems)
S.FishHookMaker = require("objects.Economy.RoyalFishHookMakerSystem")
S.FishingLineSpoolMaker = require("objects.Economy.RoyalFishingLineSpoolMakerSystem")
S.BaitBoxMaker = require("objects.Economy.RoyalBaitBoxMakerSystem")
S.FishScalerMaker = require("objects.Economy.RoyalFishScalerMakerSystem")
S.NetMendingNeedleMaker = require("objects.Economy.RoyalNetMendingNeedleMakerSystem")
-- Create local aliases for most-used systems (keeps upvalue count low)
local CombatIntegration = S.CombatIntegration
local ModernUI = S.ModernUI
local GameEventBus = S.GameEventBus
local ActionBar = require("states.ui.ActionBar")
-- Castle Kingdoms 2027 - AI system
local AIIntegration = require("objects.AI.AIIntegration")
-- Castle Kingdoms 2027 - Economy systems
local DynamicMarket = require("objects.Economy.DynamicMarketSystem")
local SeasonalSystem = require("objects.Economy.SeasonalSystem")
local EconomicEvents = require("objects.Economy.EconomicEventsSystem")
local TradeCaravans = require("objects.Economy.TradeCaravanSystem")
-- Castle Kingdoms 2027 - Mission framework
local MissionFramework = require("objects.Mission.MissionFramework")
-- Castle Kingdoms 2027 - Economy UI
local DynamicMarketUI = require("states.ui.economy.dynamic_market_ui")
local CaravanUI = require("states.ui.economy.caravan_ui")
-- Castle Kingdoms 2027 - HUD widgets
local SeasonWidget = require("states.ui.hud.season_info_widget")
local EventLog = require("states.ui.hud.economic_event_log")
-- Castle Kingdoms 2027 - Royal Systems Registry + UI panel (Ctrl+R)
local RoyalSystemsRegistry = require("objects.Economy.RoyalSystemsRegistry")
local RoyalMarketIntegration = require("objects.Economy.RoyalMarketIntegration")
local RoyalSystemsPanel = require("states.ui.hud.royal_systems_panel")
local MarketDashboard = require("states.ui.hud.market_dashboard")
local AutoSavePanel = require("states.ui.hud.autosave_panel")
-- Castle Kingdoms 2027 - Performance profiling
local PerformanceManager = require("objects.Performance.PerformanceManager")
local PriorityUpdate = require("objects.Performance.PriorityUpdateSystem")
local AITickOptimizer = require("objects.Performance.AITickOptimizer")
local MemoryProfiler = require("objects.Performance.MemoryProfiler")
local PerformanceOverlay = require("states.ui.hud.performance_overlay")
local RenderOptimizer = require("objects.Performance.RenderOptimizer")
-- Castle Kingdoms 2027 - Game feel feedback
local GameFeel = require("objects.Feedback.GameFeelSystem")
local BuildPreview = require("objects.Feedback.BuildPreviewSystem")
local SelectionFeedback = require("objects.Feedback.SelectionFeedbackSystem")
local CombatOrderViz = require("objects.Feedback.CombatOrderVisualizer")
-- Castle Kingdoms 2027 - Settings
local GameFeelSettings = require("states.ui.settings.gamefeel_settings")
local SettingsPersistence = require("objects.Config.SettingsPersistence")
-- Castle Kingdoms 2027 - UX screens
local MissionEndScreen = require("states.ui.hud.mission_end_screen")
local TutorialHints = require("objects.Feedback.TutorialHints")
local KeybindHelp = require("states.ui.hud.keybind_help")
-- Castle Kingdoms 2027 - Campaign progress & auto-save
local CampaignProgress = require("objects.Mission.CampaignProgress")
local AutoSaveSystem = require("objects.AutoSaveSystem")
-- Castle Kingdoms 2027 - Kenney CC0 asset loader
local KenneyAssetLoader = require("objects.Config.KenneyAssetLoader")
local KenneySpriteRenderer = require("objects.Config.KenneySpriteRenderer")
local KenneySpriteOverlay = require("states.ui.hud.kenney_sprite_overlay")
local savegame
local playlist = require("sounds.music_playlist")
local RationController
local groupTypeMarket = require("states.ui.market.market_trade_main")
local ArmouryUI = require("states.ui.armoury.armoury_ui")
local _, MarketUI = unpack(require("states.ui.market.market_trade"))
local BarracksUI = require("states.ui.barracks.units_recruitment")
local GuildsUI = require("states.ui.guilds.guild_ui")
local WorkshopsUI = require("states.ui.workshops.workshops_ui")
local UnitsUI = require("states.ui.units.units_control")
local UnitDetails = require("states.ui.unit_details.unit_details")
local console = require "libraries.console"

local function updateProgress(prgs, lState)
    progress = prgs or progress
    loadState = lState or loadState
    game:draw()
    love.graphics.present()
end

local function delayedInit()
    updateProgress(20)
    objects = love.filesystem.load("objects/objects.lua")(objectAtlas)
    package.loaded["objects.objects"] = objects
    updateProgress(30)
    _G.BrushController = require("objects.Controllers.BrushController")
    _G.DestructionController = require("objects.Controllers.DestructionController"):new()
    _G.SleepController = require("objects.Controllers.SleepController"):new()
    RationController = require("objects.Controllers.RationController")
    _G.AleController = require("objects.Controllers.AleController")
    _G.ReligionController = require("objects.Controllers.ReligionController")
    _G.HerdController = require("objects.Controllers.HerdController")
    _G.TaxController = require("objects.Controllers.TaxController")
    _G.TimeController = require("objects.Controllers.TimeController")
    _G.MissionController = require("objects.Controllers.MissionController")
    _G.PopularityController = require("objects.Controllers.PopularityController")
    _G.ScribeController = require("objects.Controllers.ScribeController")
    _G.BuildController = love.filesystem.load("objects/Controllers/BuildController.lua")(
        package.loaded["objects.objects"].object, objectAtlas)
    _G.JobController = require("objects.Controllers.JobController")
    _G.BuildingManager = require("objects.Controllers.BuildingManager")
    _G.Commander = require("objects.Controllers.Commander")
    _G.ArrowController = require("objects.Controllers.ArrowController")
    _G.DebugView = require("objects.Controllers.DebugView")
    updateProgress(35)
    ----Pathfinding setup
    updateProgress(40)
    _G.finder = require("objects.Controllers.PathController")
    _G.state.newGame = savegame == "map_Fernhaven" or savegame == "map_Grasslands"
    if _G.state.newGame then
        if savegame == "map_Grasslands" then
            _G.state.viewYview = -50
            _G.state:allocateMeshes()
            for i = 0, _G.chunksWide - 1 do
                for o = 0, _G.chunksHigh - 1 do -- usually both are 32 (jumper is set like that with magic numbers)
                    _G.state.Terrain:genTerrain(i, o)
                end
            end
            _G.channel.mapUpdate:push("final")
            _G.channel2.mapUpdate:push("final")
        else
            SaveManager:load(savegame)
        end
        updateProgress(70)
    else
        updateProgress(70, 3)
        SaveManager:load(savegame)
    end
    core.update()
    updateProgress(80, 4)
    objects.update(_G.dt)
    updateProgress(90, 5)
    _G.state.Terrain:update()
    updateProgress(95)
    _G.BuildController:update()
    loveframes.update()
    _G.finder:update()
    updateProgress(97)
    _G.state.map:forceRefresh()
    _G.state.Terrain:update()
    updateProgress(100)
    love.timer.sleep(0.4)
    if _G.state.missionNr then
        _G.MissionController:setMissionState(_G.state.missionNr)
    end
    loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
    ActionBar:updateGoldCount()
    ActionBar:updatePopularityCount()
    _G.state:shadeBuildings()
    _G.loaded = true
    _G.speedModifier = 1
    -- Castle Kingdoms 2027: Initialize combat system
    CombatIntegration.init()
    -- Castle Kingdoms 2027: Initialize immersion systems
    S.SoundSystem.init()
    S.WeatherSystem.init()
    ModernUI.init()
    S.LightingSystem.init()
    -- Castle Kingdoms 2027: Initialize HD render pipeline
    S.HDRenderPipeline.init()
    -- Castle Kingdoms 2027: Initialize multiplayer chat
    S.Chat.init()
    -- Castle Kingdoms 2027: Initialize diplomacy & trade
    S.DiplomacyController.init()
    S.TradeController.init()
    -- Castle Kingdoms 2027: Initialize QA & polish systems
    S.CrashHandler.init()
    S.PerfWatchdog.init()
    S.ReplaySystem.init()
    S.StatisticsDashboard.init()
    S.MapEditor.init()
    S.AudioMix.init()
    -- Castle Kingdoms 2027: Initialize sound design
    S.DynamicMusic.init()
    S.SFXLibrary.init()
    S.VoiceOver.init()
    S.DynamicMusic.playPeaceMusic()
    -- Register sound globals for combat system access
    _G.DynamicMusic = S.DynamicMusic
    _G.SFXLibrary = S.SFXLibrary
    _G.VoiceOver = S.VoiceOver
    -- Castle Kingdoms 2027: Register other globals for cross-system access
    _G.VisualPolish = S.VisualPolish
    _G.WeatherGameplay = S.WeatherGameplay
    _G.FormationSystem = S.FormationSystem
    _G.FestivalSystem = S.FestivalSystem
    _G.ThreatAI = S.ThreatAI
    _G.Veterancy = S.Veterancy
    _G.ResourceFlow = S.ResourceFlow
    _G.ConstructionAnim = S.ConstructionAnim
    _G.AIDialogue = S.AIDialogue
    -- Castle Kingdoms 2027: Initialize modding & Steam
    S.ModLoader.init()
    S.CustomBuildingLoader.init()
    S.SteamWorks.init()
    -- Register callback for custom buildings
    S.ModLoader.onBuildingRegistered = function(def)
        S.CustomBuildingLoader.register(def)
    end
    -- Load all mods
    S.ModLoader.loadAll()
    -- Castle Kingdoms 2027: Initialize localization, accessibility, tutorial
    S.LocalizationSystem.init()
    S.AccessibilitySystem.init()
    S.TutorialSystem.init()
    -- Castle Kingdoms 2027: Initialize story & siege
    S.CampaignStory.init()
    S.SiegeWeapons.init()
    -- Castle Kingdoms 2027: Final polish
    S.FinalBugFix.init()
    S.PerfOpt.init()
    S.AchievementIntegration.init()
    -- Castle Kingdoms 2027: Initialize save, profiles, console, feedback
    S.SaveCompat.init()
    S.ConfigProfiles.init()
    S.DebugConsole.init()
    S.CommunityFeedback.init()
    -- Castle Kingdoms 2027: Initialize GameEventBus and integrate all systems
    GameEventBus.integrateAll()
    _G.GameEventBus = GameEventBus
    -- Castle Kingdoms 2027: Connect victory/defeat to EndGameScreen + SkirmishTrail + CoopCampaign
    GameEventBus.on(GameEventBus.EVENTS.VICTORY, function(data)
        local Stats = require("objects.QA.StatisticsDashboard")
        S.EndGameScreen.show("victory", Stats.getSessionStats())
        -- Complete skirmish trail mission if active
        if S.SkirmishTrail.getCurrentMission() > 0 then
            S.SkirmishTrail.complete(S.SkirmishTrail.getCurrentMission())
        end
    end)
    GameEventBus.on(GameEventBus.EVENTS.DEFEAT, function(data)
        local Stats = require("objects.QA.StatisticsDashboard")
        S.EndGameScreen.show("defeat", Stats.getSessionStats())
        -- Stop co-op campaign on defeat
        if S.CoopCampaign.isActive() then
            S.CoopCampaign.stop()
        end
    end)
    -- Castle Kingdoms 2027: Final polish systems
    S.GameBalancePass.init()
    S.GameBalancePass.applyAll()
    S.VisualPolish.init()
    S.PerfBenchmark.init()
    -- Castle Kingdoms 2027: Initialize gameplay systems
    S.WeatherGameplay.init()
    S.FogOfWar.init()
    S.FestivalSystem.init()
    -- Castle Kingdoms 2027: Initialize formations, upgrades, tips
    S.FormationSystem.init()
    S.UpgradeTree.init()
    S.LoadingTips.init()
    -- Castle Kingdoms 2027: Initialize final systems
    S.ScreenshotManager.init()
    S.DifficultyPresets.init()
    -- Castle Kingdoms 2027: Initialize improvements
    S.Minimap.init()
    S.CommandQueue.init()
    S.AIDialogue.init()
    S.GameSpeedControl.init()
    S.ConstructionAnim.init()
    -- Castle Kingdoms 2027: Initialize v1.25 improvements
    S.Veterancy.init()
    S.BuildingHotkeys.init()
    S.ResourceFlow.init()
    S.AutoSaveEnhancer.init()
    S.ThreatAI.init()
    -- Castle Kingdoms 2027: Initialize v1.26 QoL systems
    S.RallyPoint.init()
    S.RightClickDismiss.init()
    S.RightClickDismiss.autoRegister()
    S.BuildingQueue.init()
    S.MinimapDrag.init()
    S.AutoWorker.init()
    S.DynamicUnitCap.init()
    -- Register globals
    _G.RallyPoint = S.RallyPoint
    _G.BuildingQueue = S.BuildingQueue
    _G.AutoWorker = S.AutoWorker
    _G.DynamicUnitCap = S.DynamicUnitCap
    -- Castle Kingdoms 2027: Initialize v1.27 systems
    S.MapSizeSelector.init()
    S.SpectatorMode.init()
    S.CoopCampaign.init()
    S.PathOpt.init()
    S.Workshop.init()
    -- Register globals
    _G.MapSizeSelector = S.MapSizeSelector
    _G.SpectatorMode = S.SpectatorMode
    _G.CoopCampaign = S.CoopCampaign
    _G.PathOpt = S.PathOpt
    _G.Workshop = S.Workshop
    -- Castle Kingdoms 2027: Initialize v1.28 systems
    S.SkirmishTrail.init()
    S.ObjectPool.init()
    S.Gamepad.init()
    S.MapSharing.init()
    S.AutoSaveIndicator.init()
    -- Register globals
    _G.SkirmishTrail = S.SkirmishTrail
    _G.ObjectPool = S.ObjectPool
    _G.Gamepad = S.Gamepad
    _G.MapSharing = S.MapSharing
    _G.AutoSaveIndicator = S.AutoSaveIndicator
    -- Castle Kingdoms 2027: Initialize v2.2 systems
    S.CommunityToolkit.init()
    S.AutoUpdater.init()
    S.AutoUpdater.checkForUpdates()
    -- Castle Kingdoms 2027 v2.6.3: Initialize Daily Challenges
    S.DailyChallenge.init()
    -- Castle Kingdoms 2027 v2.6.4: Initialize Technology Tree
    S.TechnologyTree.init()
    -- Castle Kingdoms 2027 v2.6.5: Initialize Population System
    S.PopulationSystem.init()
    -- Castle Kingdoms 2027 v2.6.6: Initialize Production Chain System
    S.ProductionChain.init()
    -- Castle Kingdoms 2027 v2.6.7: Initialize Espionage System
    S.Espionage.init()
    -- Castle Kingdoms 2027 v2.6.8: Initialize Diplomatic Relations System
    S.DiplomaticRelations.init()
    -- Castle Kingdoms 2027 v2.6.9: Initialize Army Command System
    S.ArmyCommand.init()
    -- Castle Kingdoms 2027 v2.7.0: Initialize Trade Route System
    S.TradeRoute.init()
    -- Castle Kingdoms 2027 v2.7.1: Initialize Random Event System
    S.RandomEvent.init()
    -- Castle Kingdoms 2027 v2.7.2: Initialize Notification Center
    S.NotificationCenter.init()
    _G.NotificationCenter = S.NotificationCenter
    -- Castle Kingdoms 2027 v2.7.3: Initialize Building Manager
    S.BuildingManager.init()
    _G.BuildingManager = S.BuildingManager
    -- Castle Kingdoms 2027 v2.7.4: Initialize Achievement Tracker
    S.AchievementTracker.init()
    _G.AchievementTracker = S.AchievementTracker
    -- Castle Kingdoms 2027 v2.7.5: Initialize Supply Line System
    S.SupplyLine.init()
    _G.SupplyLine = S.SupplyLine
    -- Castle Kingdoms 2027 v2.7.6: Initialize Quest System
    S.QuestSystem.init()
    _G.QuestSystem = S.QuestSystem
    -- Castle Kingdoms 2027 v2.7.7: Initialize Game Analytics Dashboard
    S.Analytics.init()
    _G.Analytics = S.Analytics
    -- Castle Kingdoms 2027 v2.7.8: Initialize Tactical Map Overlay
    S.TacticalOverlay.init()
    _G.TacticalOverlay = S.TacticalOverlay
    -- Castle Kingdoms 2027 v2.7.9: Initialize Prestige System
    S.Prestige.init()
    _G.Prestige = S.Prestige
    -- Castle Kingdoms 2027 v2.8.0: Initialize Tournament System
    S.Tournament.init()
    _G.Tournament = S.Tournament
    -- Castle Kingdoms 2027 v2.8.1: Initialize Custom Scenario Editor
    S.Scenario.init()
    _G.Scenario = S.Scenario
    -- Castle Kingdoms 2027 v2.8.2: Initialize Leaderboard System
    S.Leaderboard.init()
    _G.Leaderboard = S.Leaderboard
    -- Castle Kingdoms 2027 v2.8.4: Initialize Replay Enhancement
    S.ReplayEnhanced.init()
    _G.ReplayEnhanced = S.ReplayEnhanced
    -- Castle Kingdoms 2027 v2.8.5: Initialize Modding API
    S.ModAPI.init()
    _G.ModAPI = S.ModAPI
    -- Castle Kingdoms 2027 v2.8.6: Initialize Weather Warfare
    S.WeatherWarfare.init()
    _G.WeatherWarfare = S.WeatherWarfare
    -- Castle Kingdoms 2027 v2.8.7: Initialize Hero Unit System
    S.HeroSystem.init()
    _G.HeroSystem = S.HeroSystem
    -- Castle Kingdoms 2027 v2.8.8: Initialize Time Manager
    S.TimeManager.init()
    _G.TimeManager = S.TimeManager
    -- Castle Kingdoms 2027 v2.8.9: Initialize Camera Enhancement
    S.CameraEnhanced.init()
    _G.CameraEnhanced = S.CameraEnhanced
    -- Castle Kingdoms 2027 v2.9.0: Initialize Procedural Map Generator
    S.MapGen.init()
    _G.MapGen = S.MapGen
    -- Castle Kingdoms 2027 v2.9.1: Initialize Game Summary Generator
    S.SummaryGen.init()
    _G.SummaryGen = S.SummaryGen
    -- Castle Kingdoms 2027 v2.9.2: Initialize Soundtrack Manager
    S.SoundtrackMgr.init()
    _G.SoundtrackMgr = S.SoundtrackMgr
    -- Castle Kingdoms 2027 v2.9.3: Initialize Chat Command System
    S.ChatCmd.init()
    _G.ChatCmd = S.ChatCmd
    -- Castle Kingdoms 2027 v2.9.4: Initialize Save State Manager
    S.SaveState.init()
    _G.SaveState = S.SaveState
    -- Castle Kingdoms 2027 v2.9.5: Initialize Tooltip System
    S.TooltipSystem.init()
    _G.TooltipSystem = S.TooltipSystem
    -- Castle Kingdoms 2027 v2.9.6: Initialize Achievement Unlock Animation
    S.AchievementAnim.init()
    _G.AchievementAnim = S.AchievementAnim
    -- Castle Kingdoms 2027 v2.9.7: Initialize Enhanced Map Editor
    S.MapEditorEnhanced.init()
    _G.MapEditorEnhanced = S.MapEditorEnhanced
    -- Castle Kingdoms 2027 v2.9.8: Initialize Dynamic Difficulty Adjuster
    S.DDA.init()
    _G.DDA = S.DDA
    -- Castle Kingdoms 2027 v2.9.9: Initialize Performance Auto-Tuner
    S.AutoTuner.init()
    _G.AutoTuner = S.AutoTuner
    -- Castle Kingdoms 2027 v3.0.0: Initialize Resource Forecast System
    S.Forecast.init()
    _G.Forecast = S.Forecast
    -- Castle Kingdoms 2027 v3.0.1: Initialize Matchmaking System
    S.Matchmaking.init()
    _G.Matchmaking = S.Matchmaking
    -- Castle Kingdoms 2027 v3.0.2: Initialize Stats Dashboard Widget
    S.StatsWidget.init()
    _G.StatsWidget = S.StatsWidget
    -- Castle Kingdoms 2027 v3.0.3: Initialize Castle Siege System
    S.CastleSiege.init()
    _G.CastleSiege = S.CastleSiege
    -- Castle Kingdoms 2027 v3.0.4: Initialize Trade Negotiation System
    S.TradeNeg.init()
    _G.TradeNeg = S.TradeNeg
    -- Castle Kingdoms 2027 v3.0.5: Initialize Governor System
    S.Governor.init()
    _G.Governor = S.Governor
    -- Castle Kingdoms 2027 v3.0.6: Initialize Court & Nobility System
    S.Court.init()
    _G.Court = S.Court
    -- Castle Kingdoms 2027 v3.0.7: Initialize Disease & Health System
    S.Disease.init()
    _G.Disease = S.Disease
    -- Castle Kingdoms 2027 v3.0.8: Initialize Religion & Faith System
    S.Religion.init()
    _G.Religion = S.Religion
    -- Castle Kingdoms 2027 v3.0.9: Initialize Trade Guild System
    S.TradeGuild.init()
    _G.TradeGuild = S.TradeGuild
    -- Castle Kingdoms 2027 v3.1.0: Initialize Mercenary Contract System
    S.Mercenary.init()
    _G.Mercenary = S.Mercenary
    -- Castle Kingdoms 2027 v3.1.1: Initialize Prisoner & Ransom System
    S.Prisoner.init()
    _G.Prisoner = S.Prisoner
    -- Castle Kingdoms 2027 v3.1.2: Initialize Famine & Scarcity System
    S.Famine.init()
    _G.Famine = S.Famine
    -- Castle Kingdoms 2027 v3.1.3: Initialize Treason & Rebellion System
    S.Rebellion.init()
    _G.Rebellion = S.Rebellion
    -- Castle Kingdoms 2027 v3.1.4: Initialize Black Market & Smuggling
    S.BlackMarket.init()
    _G.BlackMarket = S.BlackMarket
    -- Castle Kingdoms 2027 v3.1.5: Initialize Royal Decrees System
    S.Decrees.init()
    _G.Decrees = S.Decrees
    -- Castle Kingdoms 2027 v3.1.6: Initialize Cultural & Education System
    S.Culture.init()
    _G.Culture = S.Culture
    -- Castle Kingdoms 2027 v3.1.7: Initialize Royal Marriage & Dynasty System
    S.Dynasty.init()
    _G.Dynasty = S.Dynasty
    -- Castle Kingdoms 2027 v3.1.8: Initialize Naval Combat & Trade System
    S.Naval.init()
    _G.Naval = S.Naval
    -- Castle Kingdoms 2027 v3.1.9: Initialize Winter Quarters System
    S.Winter.init()
    _G.Winter = S.Winter
    -- Castle Kingdoms 2027 v3.2.0: Initialize Royal Treasury & Taxation System
    S.Treasury.init()
    _G.Treasury = S.Treasury
    -- Castle Kingdoms 2027 v3.2.1: Initialize Chronicle & History System
    S.Chronicle.init()
    _G.Chronicle = S.Chronicle
    -- Castle Kingdoms 2027 v3.2.2: Initialize Heraldry & Coat of Arms System
    S.Heraldry.init()
    _G.Heraldry = S.Heraldry
    -- Castle Kingdoms 2027 v3.2.3: Initialize Royal Mint & Currency System
    S.Mint.init()
    _G.Mint = S.Mint
    -- Castle Kingdoms 2027 v3.2.4: Initialize Tournament & Jousting System
    S.Tournament.init()
    _G.Tournament = S.Tournament
    -- Castle Kingdoms 2027 v3.2.5: Initialize Court Intrigue & Spy Network System
    S.Intrigue.init()
    _G.Intrigue = S.Intrigue
    -- Castle Kingdoms 2027 v3.2.6: Initialize Royal Court Entertainment System
    S.Entertainment.init()
    _G.Entertainment = S.Entertainment
    -- Castle Kingdoms 2027 v3.2.7: Initialize Royal Archive & Records System
    S.Archive.init()
    _G.Archive = S.Archive
    -- Castle Kingdoms 2027 v3.2.8: Initialize Royal Progress & Tour System
    S.Progress.init()
    _G.Progress = S.Progress
    -- Castle Kingdoms 2027 v3.2.9: Initialize Medieval Law & Justice System
    S.Justice.init()
    _G.Justice = S.Justice
    -- Castle Kingdoms 2027 v3.3.0: Initialize Royal Guard & Security System
    S.Guard.init()
    _G.Guard = S.Guard
    -- Castle Kingdoms 2027 v3.3.1: Initialize Royal Feast & Banquet System
    S.Feast.init()
    _G.Feast = S.Feast
    -- Castle Kingdoms 2027 v3.3.2: Initialize Royal Pet & Menagerie System
    S.Menagerie.init()
    _G.Menagerie = S.Menagerie
    -- Castle Kingdoms 2027 v3.3.3: Initialize Royal Astrologer & Omens System
    S.Astrology.init()
    _G.Astrology = S.Astrology
    -- Castle Kingdoms 2027 v3.3.4: Initialize Royal Apothecary & Medicine System
    S.Apothecary.init()
    _G.Apothecary = S.Apothecary
    -- Castle Kingdoms 2027 v3.3.5: Initialize Royal Cartographer & Maps System
    S.Cartographer.init()
    _G.Cartographer = S.Cartographer
    -- Castle Kingdoms 2027 v3.3.6: Initialize Royal Master of Horse & Stables System
    S.Stables.init()
    _G.Stables = S.Stables
    -- Castle Kingdoms 2027 v3.3.7: Initialize Royal Beekeeper & Honey System
    S.Beekeeper.init()
    _G.Beekeeper = S.Beekeeper
    -- Castle Kingdoms 2027 v3.3.8: Initialize Royal Vineyard & Wine System
    S.Vineyard.init()
    _G.Vineyard = S.Vineyard
    -- Castle Kingdoms 2027 v3.3.9: Initialize Royal Falconer & Hawking System
    S.Falconer.init()
    _G.Falconer = S.Falconer
    -- Castle Kingdoms 2027 v3.4.0: Initialize Royal Gardener & Ornamental Gardens System
    S.Gardens.init()
    _G.Gardens = S.Gardens
    -- Castle Kingdoms 2027 v3.4.1: Initialize Royal Alchemist & Transmutation System
    S.Alchemist.init()
    _G.Alchemist = S.Alchemist
    -- Castle Kingdoms 2027 v3.4.2: Initialize Royal Master of Hunt & Game System
    S.Hunt.init()
    _G.Hunt = S.Hunt
    -- Castle Kingdoms 2027 v3.4.3: Initialize Royal Forester & Woodland System
    S.Forester.init()
    _G.Forester = S.Forester
    -- Castle Kingdoms 2027 v3.4.4: Initialize Royal Falconry Breeding & Genetics System
    S.Genetics.init()
    _G.Genetics = S.Genetics
    -- Castle Kingdoms 2027 v3.4.5: Initialize Royal Composer & Music System
    S.Music.init()
    _G.Music = S.Music
    -- Castle Kingdoms 2027 v3.4.6: Initialize Royal Philosopher & Wisdom System
    S.Philosophy.init()
    _G.Philosophy = S.Philosophy
    -- Castle Kingdoms 2027 v3.4.7: Initialize Royal Physician & Health System
    S.Physician.init()
    _G.Physician = S.Physician
    -- Castle Kingdoms 2027 v3.4.8: Initialize Royal Astrologer Advanced System
    S.AstrologyAdv.init()
    _G.AstrologyAdv = S.AstrologyAdv
    -- Castle Kingdoms 2027 v3.4.9: Initialize Royal Engineer & Siege Works System
    S.Engineer.init()
    _G.Engineer = S.Engineer
    -- Castle Kingdoms 2027 v3.5.0: Initialize Royal Diplomat & Envoy System
    S.Diplomat.init()
    _G.Diplomat = S.Diplomat
    -- Castle Kingdoms 2027 v3.5.1: Initialize Royal Historian & Chronicle Advanced System
    S.Historian.init()
    _G.Historian = S.Historian
    -- Castle Kingdoms 2027 v3.5.2: Initialize Royal Master of Ceremonies & Protocol System
    S.Ceremonies.init()
    _G.Ceremonies = S.Ceremonies
    -- Castle Kingdoms 2027 v3.5.3: Initialize Royal Confessor & Spiritual Guidance System
    S.Confessor.init()
    _G.Confessor = S.Confessor
    -- Castle Kingdoms 2027 v3.5.4: Initialize Royal Minstrel & Troubadour System
    S.Minstrel.init()
    _G.Minstrel = S.Minstrel
    -- Castle Kingdoms 2027 v3.5.5: Initialize Royal Jester Advanced & Court Comedy System
    S.Comedy.init()
    _G.Comedy = S.Comedy
    -- Castle Kingdoms 2027 v3.5.6: Initialize Royal Cupbearer & Taster System
    S.Cupbearer.init()
    _G.Cupbearer = S.Cupbearer
    -- Castle Kingdoms 2027 v3.5.7: Initialize Royal Chandlery & Wax Works System
    S.Chandlery.init()
    _G.Chandlery = S.Chandlery
    -- Castle Kingdoms 2027 v3.5.8: Initialize Royal Potter & Ceramics System
    S.Potter.init()
    _G.Potter = S.Potter
    -- Castle Kingdoms 2027 v3.5.9: Initialize Royal Weaver & Textile System
    S.Weaver.init()
    _G.Weaver = S.Weaver
    -- Castle Kingdoms 2027 v3.6.0: Initialize Royal Glassmaker & Stained Glass System
    S.Glassmaker.init()
    _G.Glassmaker = S.Glassmaker
    -- Castle Kingdoms 2027 v3.6.1: Initialize Royal Clockmaker & Timekeeping System
    S.Clockmaker.init()
    _G.Clockmaker = S.Clockmaker
    -- Castle Kingdoms 2027 v3.6.2: Initialize Royal Jeweler & Gemstone System
    S.Jeweler.init()
    _G.Jeweler = S.Jeweler
    -- Castle Kingdoms 2027 v3.6.3: Initialize Royal Calligrapher & Illumination System
    S.Calligraphy.init()
    _G.Calligraphy = S.Calligraphy
    -- Castle Kingdoms 2027 v3.6.4: Initialize Royal Embalmer & Funerary System
    S.Funerary.init()
    _G.Funerary = S.Funerary
    -- Castle Kingdoms 2027 v3.6.5: Initialize Royal Perfumer & Fragrance System
    S.Perfumer.init()
    _G.Perfumer = S.Perfumer
    -- Castle Kingdoms 2027 v3.6.6: Initialize Royal Dyer & Color System
    S.Dyer.init()
    _G.Dyer = S.Dyer
    -- Castle Kingdoms 2027 v3.6.7: Initialize Royal Bookbinder & Library System
    S.Bookbinder.init()
    _G.Bookbinder = S.Bookbinder
    -- Castle Kingdoms 2027 v3.6.8: Initialize Royal Sculptor & Stone Carving System
    S.Sculptor.init()
    _G.Sculptor = S.Sculptor
    -- Castle Kingdoms 2027 v3.6.9: Initialize Royal Painter & Fresco System
    S.Painter.init()
    _G.Painter = S.Painter
    -- Castle Kingdoms 2027 v3.7.0: Initialize Royal Metalworker & Bronze Casting System
    S.Metalworker.init()
    _G.Metalworker = S.Metalworker
    -- Castle Kingdoms 2027 v3.7.1: Initialize Royal Leatherworker & Tannery System
    S.Leatherworker.init()
    _G.Leatherworker = S.Leatherworker
    -- Castle Kingdoms 2027 v3.7.2: Initialize Royal Surveyor & Land Measurement System
    S.Surveyor.init()
    _G.Surveyor = S.Surveyor
    -- Castle Kingdoms 2027 v3.7.3: Initialize Royal Tax Collector & Revenue System
    S.TaxCollector.init()
    _G.TaxCollector = S.TaxCollector
    -- Castle Kingdoms 2027 v3.7.4: Initialize Royal Messenger & Postal System
    S.Postal.init()
    _G.Postal = S.Postal
    -- Castle Kingdoms 2027 v3.7.5: Initialize Royal Brewer Advanced & Distillery System
    S.Distiller.init()
    _G.Distiller = S.Distiller
    -- Castle Kingdoms 2027 v3.7.6: Initialize Royal Smith Advanced & Weapon Forge System
    S.Forge.init()
    _G.Forge = S.Forge
    -- Castle Kingdoms 2027 v3.7.7: Initialize Royal Woodworker & Carpenter System
    S.Woodworker.init()
    _G.Woodworker = S.Woodworker
    -- Castle Kingdoms 2027 v3.7.8: Initialize Royal Mason & Stonecutter System
    S.Mason.init()
    _G.Mason = S.Mason
    -- Castle Kingdoms 2027 v3.7.9: Initialize Royal Armorer & Shield System
    S.Armorer.init()
    _G.Armorer = S.Armorer
    -- Castle Kingdoms 2027 v3.8.0: Initialize Royal Scribe & Notary System
    S.Scribe.init()
    _G.Scribe = S.Scribe
    -- Castle Kingdoms 2027 v3.8.1: Initialize Royal Barber & Surgeon System
    S.Barber.init()
    _G.Barber = S.Barber
    -- Castle Kingdoms 2027 v3.8.2-v3.8.6: Initialize 5 new craft systems
    S.Baker.init(); _G.Baker = S.Baker
    S.Cooper.init(); _G.Cooper = S.Cooper
    S.Ropemaker.init(); _G.Ropemaker = S.Ropemaker
    S.Locksmith.init(); _G.Locksmith = S.Locksmith
    S.Chandler.init(); _G.Chandler = S.Chandler
    -- Castle Kingdoms 2027 v3.8.7-v3.9.1: Initialize 5 new craft systems
    S.Fletcher.init(); _G.Fletcher = S.Fletcher
    S.Saddler.init(); _G.Saddler = S.Saddler
    S.NailMaker.init(); _G.NailMaker = S.NailMaker
    S.SoapMaker.init(); _G.SoapMaker = S.SoapMaker
    S.InkMaker.init(); _G.InkMaker = S.InkMaker
    -- Castle Kingdoms 2027 v3.9.2-v3.9.6: Initialize 5 new craft systems
    S.Thatcher.init(); _G.Thatcher = S.Thatcher
    S.Plasterer.init(); _G.Plasterer = S.Plasterer
    S.Glazier.init(); _G.Glazier = S.Glazier
    S.BellFounder.init(); _G.BellFounder = S.BellFounder
    S.OrganBuilder.init(); _G.OrganBuilder = S.OrganBuilder
    -- Castle Kingdoms 2027 v3.9.7-v3.10.1: Initialize 5 new craft systems
    S.Compass.init(); _G.Compass = S.Compass
    S.LensGrinder.init(); _G.LensGrinder = S.LensGrinder
    S.DiceMaker.init(); _G.DiceMaker = S.DiceMaker
    S.Embroiderer.init(); _G.Embroiderer = S.Embroiderer
    S.Gilder.init(); _G.Gilder = S.Gilder
    -- Castle Kingdoms 2027 v3.10.2-v3.10.6: Initialize 5 new craft systems
    S.CombMaker.init(); _G.CombMaker = S.CombMaker
    S.SealEngraver.init(); _G.SealEngraver = S.SealEngraver
    S.FanMaker.init(); _G.FanMaker = S.FanMaker
    S.PuppetMaker.init(); _G.PuppetMaker = S.PuppetMaker
    S.ButtonMaker.init(); _G.ButtonMaker = S.ButtonMaker
    -- Castle Kingdoms 2027 v3.10.7-v3.11.1: Initialize 5 new craft systems
    S.BasketWeaver.init(); _G.BasketWeaver = S.BasketWeaver
    S.MatMaker.init(); _G.MatMaker = S.MatMaker
    S.TokenMaker.init(); _G.TokenMaker = S.TokenMaker
    S.Engraver.init(); _G.Engraver = S.Engraver
    S.Horologist.init(); _G.Horologist = S.Horologist
    -- Castle Kingdoms 2027 v3.11.2-v3.11.6: Initialize 5 new craft systems
    S.ChessCarver.init(); _G.ChessCarver = S.ChessCarver
    S.SundialMaker.init(); _G.SundialMaker = S.SundialMaker
    S.StringMaker.init(); _G.StringMaker = S.StringMaker
    S.NeedleMaker.init(); _G.NeedleMaker = S.NeedleMaker
    S.WaxModeler.init(); _G.WaxModeler = S.WaxModeler
    -- Castle Kingdoms 2027 v3.11.7-v3.11.11: Initialize 5 new craft systems
    S.TileMaker.init(); _G.TileMaker = S.TileMaker
    S.ClayPipeMaker.init(); _G.ClayPipeMaker = S.ClayPipeMaker
    S.SconceMaker.init(); _G.SconceMaker = S.SconceMaker
    S.SignBoardMaker.init(); _G.SignBoardMaker = S.SignBoardMaker
    S.LanternMaker.init(); _G.LanternMaker = S.LanternMaker
    -- Castle Kingdoms 2027 v3.11.12-v3.11.16: Initialize 5 new craft systems
    S.FunnelMaker.init(); _G.FunnelMaker = S.FunnelMaker
    S.CofferMaker.init(); _G.CofferMaker = S.CofferMaker
    S.BellPullMaker.init(); _G.BellPullMaker = S.BellPullMaker
    S.KeyMaker.init(); _G.KeyMaker = S.KeyMaker
    S.ChainMaker.init(); _G.ChainMaker = S.ChainMaker
    -- Castle Kingdoms 2027 v3.11.17-v3.11.21: Initialize 5 new craft systems
    S.HingeMaker.init(); _G.HingeMaker = S.HingeMaker
    S.BoltLatchMaker.init(); _G.BoltLatchMaker = S.BoltLatchMaker
    S.RivetMaker.init(); _G.RivetMaker = S.RivetMaker
    S.CrownMaker.init(); _G.CrownMaker = S.CrownMaker
    S.ScepterMaker.init(); _G.ScepterMaker = S.ScepterMaker
    -- Castle Kingdoms 2027 v3.11.22-v3.11.26: Initialize 5 new craft systems
    S.ThroneMaker.init(); _G.ThroneMaker = S.ThroneMaker
    S.OrbMaker.init(); _G.OrbMaker = S.OrbMaker
    S.SealRingMaker.init(); _G.SealRingMaker = S.SealRingMaker
    S.MedalMaker.init(); _G.MedalMaker = S.MedalMaker
    S.TapestryLoom.init(); _G.TapestryLoom = S.TapestryLoom
    -- Castle Kingdoms 2027 v3.11.27-v3.11.31: Initialize 5 new craft systems
    S.StainedGlassMaker.init(); _G.StainedGlassMaker = S.StainedGlassMaker
    S.CarpetLoom.init(); _G.CarpetLoom = S.CarpetLoom
    S.CushionMaker.init(); _G.CushionMaker = S.CushionMaker
    S.BannerMaker.init(); _G.BannerMaker = S.BannerMaker
    S.HeraldicFlagMaker.init(); _G.HeraldicFlagMaker = S.HeraldicFlagMaker
    -- Castle Kingdoms 2027 v3.11.32-v3.11.36: Initialize 5 new liturgical systems
    S.CopeVestmentMaker.init(); _G.CopeVestmentMaker = S.CopeVestmentMaker
    S.AltarFrontalMaker.init(); _G.AltarFrontalMaker = S.AltarFrontalMaker
    S.ReliquaryMaker.init(); _G.ReliquaryMaker = S.ReliquaryMaker
    S.ChrismatoryMaker.init(); _G.ChrismatoryMaker = S.ChrismatoryMaker
    S.ProcessionalCrossMaker.init(); _G.ProcessionalCrossMaker = S.ProcessionalCrossMaker
    -- Castle Kingdoms 2027 v3.11.37-v3.11.41: Initialize 5 new liturgical vessel systems
    S.MonstranceMaker.init(); _G.MonstranceMaker = S.MonstranceMaker
    S.CiboriumMaker.init(); _G.CiboriumMaker = S.CiboriumMaker
    S.ChaliceMaker.init(); _G.ChaliceMaker = S.ChaliceMaker
    S.PatenMaker.init(); _G.PatenMaker = S.PatenMaker
    S.ThuribleMaker.init(); _G.ThuribleMaker = S.ThuribleMaker
    -- Castle Kingdoms 2027 v3.11.42-v3.11.46: Initialize 5 new musical instrument systems
    S.OrganPipeMaker.init(); _G.OrganPipeMaker = S.OrganPipeMaker
    S.BellWheelMaker.init(); _G.BellWheelMaker = S.BellWheelMaker
    S.CymbalMaker.init(); _G.CymbalMaker = S.CymbalMaker
    S.HarpMaker.init(); _G.HarpMaker = S.HarpMaker
    S.DrummerMaker.init(); _G.DrummerMaker = S.DrummerMaker
    -- Castle Kingdoms 2027 v3.11.47-v3.11.51: Initialize 5 new musical instrument systems
    S.LuteMaker.init(); _G.LuteMaker = S.LuteMaker
    S.FiddleMaker.init(); _G.FiddleMaker = S.FiddleMaker
    S.PsalteryMaker.init(); _G.PsalteryMaker = S.PsalteryMaker
    S.HurdyGurdyMaker.init(); _G.HurdyGurdyMaker = S.HurdyGurdyMaker
    S.RecorderMaker.init(); _G.RecorderMaker = S.RecorderMaker
    -- Castle Kingdoms 2027 v3.11.52-v3.11.56: Initialize 5 new wind instrument systems
    S.ShawmMaker.init(); _G.ShawmMaker = S.ShawmMaker
    S.CrumhornMaker.init(); _G.CrumhornMaker = S.CrumhornMaker
    S.SackbutMaker.init(); _G.SackbutMaker = S.SackbutMaker
    S.BagpipeMaker.init(); _G.BagpipeMaker = S.BagpipeMaker
    S.PipeTaborMaker.init(); _G.PipeTaborMaker = S.PipeTaborMaker
    -- Castle Kingdoms 2027 v3.11.57-v3.11.61: Initialize 5 new weapons & armor systems
    S.SwordsmithMaker.init(); _G.SwordsmithMaker = S.SwordsmithMaker
    S.DaggerMaker.init(); _G.DaggerMaker = S.DaggerMaker
    S.HelmetMaker.init(); _G.HelmetMaker = S.HelmetMaker
    S.ShieldMaker.init(); _G.ShieldMaker = S.ShieldMaker
    S.ArmorMaker.init(); _G.ArmorMaker = S.ArmorMaker
    -- Castle Kingdoms 2027 v3.11.62-v3.11.66: Initialize 5 new weapon systems
    S.Bowyer.init(); _G.Bowyer = S.Bowyer
    S.Fletcher.init(); _G.Fletcher = S.Fletcher
    S.CrossbowMaker.init(); _G.CrossbowMaker = S.CrossbowMaker
    S.PolearmMaker.init(); _G.PolearmMaker = S.PolearmMaker
    S.MaceAxeMaker.init(); _G.MaceAxeMaker = S.MaceAxeMaker
    -- Castle Kingdoms 2027 v3.11.67-v3.11.71: Initialize 5 new cavalry equipment systems
    S.SaddleMaker.init(); _G.SaddleMaker = S.SaddleMaker
    S.SpurMaker.init(); _G.SpurMaker = S.SpurMaker
    S.HorseArmorMaker.init(); _G.HorseArmorMaker = S.HorseArmorMaker
    S.LanceMaker.init(); _G.LanceMaker = S.LanceMaker
    S.CavalryBannerMaker.init(); _G.CavalryBannerMaker = S.CavalryBannerMaker
    -- Castle Kingdoms 2027 v3.11.72-v3.11.76: Initialize 5 new siege engine systems
    S.CatapultMaker.init(); _G.CatapultMaker = S.CatapultMaker
    S.TrebuchetMaker.init(); _G.TrebuchetMaker = S.TrebuchetMaker
    S.BallistaMaker.init(); _G.BallistaMaker = S.BallistaMaker
    S.SiegeTowerMaker.init(); _G.SiegeTowerMaker = S.SiegeTowerMaker
    S.BatteringRamMaker.init(); _G.BatteringRamMaker = S.BatteringRamMaker
    -- Castle Kingdoms 2027 v3.11.77-v3.11.81: Initialize 5 new gunpowder weapon systems
    S.CannonMaker.init(); _G.CannonMaker = S.CannonMaker
    S.MortarMaker.init(); _G.MortarMaker = S.MortarMaker
    S.BombardMaker.init(); _G.BombardMaker = S.BombardMaker
    S.HandCannonMaker.init(); _G.HandCannonMaker = S.HandCannonMaker
    S.GrenadeMaker.init(); _G.GrenadeMaker = S.GrenadeMaker
    -- Castle Kingdoms 2027 v3.11.82-v3.11.86: Initialize 5 new gunpowder resource systems
    S.GunpowderMill.init(); _G.GunpowderMill = S.GunpowderMill
    S.SaltpeterRefinery.init(); _G.SaltpeterRefinery = S.SaltpeterRefinery
    S.SulfurCollector.init(); _G.SulfurCollector = S.SulfurCollector
    S.CharcoalBurner.init(); _G.CharcoalBurner = S.CharcoalBurner
    S.MatchCordMaker.init(); _G.MatchCordMaker = S.MatchCordMaker
    -- Castle Kingdoms 2027 v3.11.87-v3.11.91: Initialize 5 new beverage systems
    S.AleBrewer.init(); _G.AleBrewer = S.AleBrewer
    S.MeadMaker.init(); _G.MeadMaker = S.MeadMaker
    S.WineVintner.init(); _G.WineVintner = S.WineVintner
    S.CiderPress.init(); _G.CiderPress = S.CiderPress
    S.BrandyDistiller.init(); _G.BrandyDistiller = S.BrandyDistiller
    -- Castle Kingdoms 2027 v3.11.92-v3.11.96: Initialize 5 new food resource systems
    S.SpiceMerchant.init(); _G.SpiceMerchant = S.SpiceMerchant
    S.SaltRefiner.init(); _G.SaltRefiner = S.SaltRefiner
    S.SugarRefiner.init(); _G.SugarRefiner = S.SugarRefiner
    S.HoneyCollector.init(); _G.HoneyCollector = S.HoneyCollector
    S.OilPresser.init(); _G.OilPresser = S.OilPresser
    -- Castle Kingdoms 2027 v3.11.97-v3.11.101: Initialize 5 new dairy & bakery systems
    S.CheeseMaker.init(); _G.CheeseMaker = S.CheeseMaker
    S.ButterChurner.init(); _G.ButterChurner = S.ButterChurner
    S.YogurtFermenter.init(); _G.YogurtFermenter = S.YogurtFermenter
    S.BreadBaker.init(); _G.BreadBaker = S.BreadBaker
    S.PastryChef.init(); _G.PastryChef = S.PastryChef
    -- Castle Kingdoms 2027 v3.11.102-v3.11.106: Initialize 5 new meat & preservation systems
    S.SausageMaker.init(); _G.SausageMaker = S.SausageMaker
    S.SmokedMeatCurer.init(); _G.SmokedMeatCurer = S.SmokedMeatCurer
    S.FishSmoker.init(); _G.FishSmoker = S.FishSmoker
    S.PickleCurer.init(); _G.PickleCurer = S.PickleCurer
    S.Confectioner.init(); _G.Confectioner = S.Confectioner
    -- Castle Kingdoms 2027 v3.11.107-v3.11.111: Initialize 5 new textile raw material systems
    S.DyeStuffMaker.init(); _G.DyeStuffMaker = S.DyeStuffMaker
    S.RawhideTanner.init(); _G.RawhideTanner = S.RawhideTanner
    S.Furrier.init(); _G.Furrier = S.Furrier
    S.WoolStapler.init(); _G.WoolStapler = S.WoolStapler
    S.SilkReeler.init(); _G.SilkReeler = S.SilkReeler
    -- Castle Kingdoms 2027 v3.11.112-v3.11.116: Initialize 5 new fiber raw material systems
    S.LinenRetter.init(); _G.LinenRetter = S.LinenRetter
    S.HempRetter.init(); _G.HempRetter = S.HempRetter
    S.CottonGin.init(); _G.CottonGin = S.CottonGin
    S.CanvasWeaver.init(); _G.CanvasWeaver = S.CanvasWeaver
    S.RopeSpinner.init(); _G.RopeSpinner = S.RopeSpinner
    -- Castle Kingdoms 2027 v3.11.117-v3.11.121: Initialize 5 new construction material systems
    S.GlassBatchSmelter.init(); _G.GlassBatchSmelter = S.GlassBatchSmelter
    S.IngotSmelter.init(); _G.IngotSmelter = S.IngotSmelter
    S.LimeBurner.init(); _G.LimeBurner = S.LimeBurner
    S.BrickMaker.init(); _G.BrickMaker = S.BrickMaker
    S.PotteryKiln.init(); _G.PotteryKiln = S.PotteryKiln
    -- Castle Kingdoms 2027 v3.11.122-v3.11.126: Initialize 5 new wood & stone raw material systems
    S.TimberFeller.init(); _G.TimberFeller = S.TimberFeller
    S.Sawmill.init(); _G.Sawmill = S.Sawmill
    S.QuarryMiner.init(); _G.QuarryMiner = S.QuarryMiner
    S.ClayDigger.init(); _G.ClayDigger = S.ClayDigger
    S.GemMiner.init(); _G.GemMiner = S.GemMiner
    -- Castle Kingdoms 2027 v3.11.127-v3.11.131: Initialize 5 new agricultural systems
    S.GrainFarmer.init(); _G.GrainFarmer = S.GrainFarmer
    S.Orchardist.init(); _G.Orchardist = S.Orchardist
    S.VineyardPlanter.init(); _G.VineyardPlanter = S.VineyardPlanter
    S.HerbGardener.init(); _G.HerbGardener = S.HerbGardener
    S.ApiaryKeeper.init(); _G.ApiaryKeeper = S.ApiaryKeeper
    -- Castle Kingdoms 2027 v3.11.132-v3.11.136: Initialize 5 new livestock farming systems
    S.CattleRancher.init(); _G.CattleRancher = S.CattleRancher
    S.SheepShepherd.init(); _G.SheepShepherd = S.SheepShepherd
    S.PigFarmer.init(); _G.PigFarmer = S.PigFarmer
    S.PoultryKeeper.init(); _G.PoultryKeeper = S.PoultryKeeper
    S.HorseBreeder.init(); _G.HorseBreeder = S.HorseBreeder
    -- Castle Kingdoms 2027 v3.11.137-v3.11.141: Initialize 5 new water/economic systems
    S.Fisherman.init(); _G.Fisherman = S.Fisherman
    S.OysterFarmer.init(); _G.OysterFarmer = S.OysterFarmer
    S.WhalingCaptain.init(); _G.WhalingCaptain = S.WhalingCaptain
    S.SaltPanWorker.init(); _G.SaltPanWorker = S.SaltPanWorker
    S.IceCutter.init(); _G.IceCutter = S.IceCutter
    -- Castle Kingdoms 2027 v3.11.142-v3.11.146: Initialize 5 new animal breeding systems
    S.FalconBreeder.init(); _G.FalconBreeder = S.FalconBreeder
    S.PigeonCourier.init(); _G.PigeonCourier = S.PigeonCourier
    S.HoundBreeder.init(); _G.HoundBreeder = S.HoundBreeder
    S.HuntingFalconer.init(); _G.HuntingFalconer = S.HuntingFalconer
    S.WarDogTrainer.init(); _G.WarDogTrainer = S.WarDogTrainer
    -- Castle Kingdoms 2027 v3.11.147-v3.11.151: Initialize 5 new scientific/cartographic systems
    S.MapMaker.init(); _G.MapMaker = S.MapMaker
    S.StarChartMaker.init(); _G.StarChartMaker = S.StarChartMaker
    S.PaperMaker.init(); _G.PaperMaker = S.PaperMaker
    S.ParchmentMaker.init(); _G.ParchmentMaker = S.ParchmentMaker
    S.QuillPenMaker.init(); _G.QuillPenMaker = S.QuillPenMaker
    -- Castle Kingdoms 2027 v3.11.152-v3.11.156: Initialize 5 new scientific instrument systems
    S.AstrolabeMaker.init(); _G.AstrolabeMaker = S.AstrolabeMaker
    S.AbacusMaker.init(); _G.AbacusMaker = S.AbacusMaker
    S.BalanceScaleMaker.init(); _G.BalanceScaleMaker = S.BalanceScaleMaker
    S.SextantMaker.init(); _G.SextantMaker = S.SextantMaker
    S.ArmillarySphereMaker.init(); _G.ArmillarySphereMaker = S.ArmillarySphereMaker
    -- Castle Kingdoms 2027 v3.11.157-v3.11.161: Initialize 5 new optical/measurement systems
    S.TelescopeMaker.init(); _G.TelescopeMaker = S.TelescopeMaker
    S.HourglassMaker.init(); _G.HourglassMaker = S.HourglassMaker
    S.MicroscopeMaker.init(); _G.MicroscopeMaker = S.MicroscopeMaker
    S.BarometerMaker.init(); _G.BarometerMaker = S.BarometerMaker
    S.ThermometerMaker.init(); _G.ThermometerMaker = S.ThermometerMaker
    -- Castle Kingdoms 2027 v3.11.162-v3.11.166: Initialize 5 new medical & alchemical systems
    S.SurgicalToolMaker.init(); _G.SurgicalToolMaker = S.SurgicalToolMaker
    S.LeechCollector.init(); _G.LeechCollector = S.LeechCollector
    S.PlagueDoctorMaskMaker.init(); _G.PlagueDoctorMaskMaker = S.PlagueDoctorMaskMaker
    S.PotionBrewer.init(); _G.PotionBrewer = S.PotionBrewer
    S.AlchemicalElixirMaker.init(); _G.AlchemicalElixirMaker = S.AlchemicalElixirMaker
    -- Castle Kingdoms 2027 v3.11.167-v3.11.171: Initialize 5 new personal & entertainment systems
    S.MirrorMaker.init(); _G.MirrorMaker = S.MirrorMaker
    S.WigMaker.init(); _G.WigMaker = S.WigMaker
    S.FortuneTeller.init(); _G.FortuneTeller = S.FortuneTeller
    S.TattooArtist.init(); _G.TattooArtist = S.TattooArtist
    S.JesterPropsMaker.init(); _G.JesterPropsMaker = S.JesterPropsMaker
    -- Castle Kingdoms 2027 v3.11.172-v3.11.176: Initialize 5 new toy & game systems
    S.BoardGameMaker.init(); _G.BoardGameMaker = S.BoardGameMaker
    S.CardDeckMaker.init(); _G.CardDeckMaker = S.CardDeckMaker
    S.DominoMaker.init(); _G.DominoMaker = S.DominoMaker
    S.PlayingCardMaker.init(); _G.PlayingCardMaker = S.PlayingCardMaker
    S.JigsawPuzzleMaker.init(); _G.JigsawPuzzleMaker = S.JigsawPuzzleMaker
    -- Castle Kingdoms 2027 v3.11.177-v3.11.181: Initialize 5 new toy & decorative systems
    S.KiteMaker.init(); _G.KiteMaker = S.KiteMaker
    S.TopMaker.init(); _G.TopMaker = S.TopMaker
    S.DollHouseMaker.init(); _G.DollHouseMaker = S.DollHouseMaker
    S.MarbleStatueMaker.init(); _G.MarbleStatueMaker = S.MarbleStatueMaker
    S.PerfumeBottleMaker.init(); _G.PerfumeBottleMaker = S.PerfumeBottleMaker
    -- Castle Kingdoms 2027 v3.11.182-v3.11.186: Initialize 5 new decorative furnishing systems
    S.ClockFacePainter.init(); _G.ClockFacePainter = S.ClockFacePainter
    S.CurtainMaker.init(); _G.CurtainMaker = S.CurtainMaker
    S.ChandelierMaker.init(); _G.ChandelierMaker = S.ChandelierMaker
    S.CandelabraMaker.init(); _G.CandelabraMaker = S.CandelabraMaker
    S.FountainMaker.init(); _G.FountainMaker = S.FountainMaker
    S.AquariumKeeper.init(); _G.AquariumKeeper = S.AquariumKeeper
    S.AviaryKeeper.init(); _G.AviaryKeeper = S.AviaryKeeper
    S.TerrariumKeeper.init(); _G.TerrariumKeeper = S.TerrariumKeeper
    S.ButterflyBreeder.init(); _G.ButterflyBreeder = S.ButterflyBreeder
    S.BonsaiCultivator.init(); _G.BonsaiCultivator = S.BonsaiCultivator
    S.VegetableGardener.init(); _G.VegetableGardener = S.VegetableGardener
    S.MushroomForager.init(); _G.MushroomForager = S.MushroomForager
    S.AloeCultivator.init(); _G.AloeCultivator = S.AloeCultivator
    S.SaffronGrower.init(); _G.SaffronGrower = S.SaffronGrower
    S.HopsGrower.init(); _G.HopsGrower = S.HopsGrower
    S.InkMaker.init(); _G.InkMaker = S.InkMaker
    S.WaxSealPresser.init(); _G.WaxSealPresser = S.WaxSealPresser
    S.CalendarMaker.init(); _G.CalendarMaker = S.CalendarMaker
    S.CodexBinder.init(); _G.CodexBinder = S.CodexBinder
    S.ManuscriptIlluminator.init(); _G.ManuscriptIlluminator = S.ManuscriptIlluminator
    S.TasselMaker.init(); _G.TasselMaker = S.TasselMaker
    S.Knitter.init(); _G.Knitter = S.Knitter
    S.Crocheter.init(); _G.Crocheter = S.Crocheter
    S.LaceMaker.init(); _G.LaceMaker = S.LaceMaker
    S.SamplerStitcher.init(); _G.SamplerStitcher = S.SamplerStitcher
    S.LyreMaker.init(); _G.LyreMaker = S.LyreMaker
    S.TrumpetMaker.init(); _G.TrumpetMaker = S.TrumpetMaker
    S.FluteMaker.init(); _G.FluteMaker = S.FluteMaker
    S.MandolinMaker.init(); _G.MandolinMaker = S.MandolinMaker
    S.PanFluteMaker.init(); _G.PanFluteMaker = S.PanFluteMaker
    S.PlanetariumMaker.init(); _G.PlanetariumMaker = S.PlanetariumMaker
    S.SundialMaker.init(); _G.SundialMaker = S.SundialMaker
    S.CompassMaker.init(); _G.CompassMaker = S.CompassMaker
    S.QuadrantMaker.init(); _G.QuadrantMaker = S.QuadrantMaker
    S.NocturnalMaker.init(); _G.NocturnalMaker = S.NocturnalMaker
    S.CoffeeRoaster.init(); _G.CoffeeRoaster = S.CoffeeRoaster
    S.TeaBlender.init(); _G.TeaBlender = S.TeaBlender
    S.ChocolateConfectioner.init(); _G.ChocolateConfectioner = S.ChocolateConfectioner
    S.TobaccoCurer.init(); _G.TobaccoCurer = S.TobaccoCurer
    S.SnuffMiller.init(); _G.SnuffMiller = S.SnuffMiller
    S.StagePropMaker.init(); _G.StagePropMaker = S.StagePropMaker
    S.CostumeTailor.init(); _G.CostumeTailor = S.CostumeTailor
    S.TheaterMaskMaker.init(); _G.TheaterMaskMaker = S.TheaterMaskMaker
    S.EaselMaker.init(); _G.EaselMaker = S.EaselMaker
    S.PaintMaker.init(); _G.PaintMaker = S.PaintMaker
    S.CoronationMantleMaker.init(); _G.CoronationMantleMaker = S.CoronationMantleMaker
    S.RoyalCrestCarver.init(); _G.RoyalCrestCarver = S.RoyalCrestCarver
    S.RoyalSealStampMaker.init(); _G.RoyalSealStampMaker = S.RoyalSealStampMaker
    S.RoyalBannerHerald.init(); _G.RoyalBannerHerald = S.RoyalBannerHerald
    S.CoronationCushionMaker.init(); _G.CoronationCushionMaker = S.CoronationCushionMaker
    S.CrucibleMaker.init(); _G.CrucibleMaker = S.CrucibleMaker
    S.RetortMaker.init(); _G.RetortMaker = S.RetortMaker
    S.HydrometerMaker.init(); _G.HydrometerMaker = S.HydrometerMaker
    S.AlambicStillMaker.init(); _G.AlambicStillMaker = S.AlambicStillMaker
    S.ApothecaryMortarMaker.init(); _G.ApothecaryMortarMaker = S.ApothecaryMortarMaker
    S.KitchenKnifeMaker.init(); _G.KitchenKnifeMaker = S.KitchenKnifeMaker
    S.CutlerySmith.init(); _G.CutlerySmith = S.CutlerySmith
    S.CookwareFounder.init(); _G.CookwareFounder = S.CookwareFounder
    S.ServingPlateMaker.init(); _G.ServingPlateMaker = S.ServingPlateMaker
    S.WoodenSpoonCarver.init(); _G.WoodenSpoonCarver = S.WoodenSpoonCarver
    S.CrystalGobletMaker.init(); _G.CrystalGobletMaker = S.CrystalGobletMaker
    S.GlassBeadMaker.init(); _G.GlassBeadMaker = S.GlassBeadMaker
    S.LensGrinder.init(); _G.LensGrinder = S.LensGrinder
    S.BeakerBlower.init(); _G.BeakerBlower = S.BeakerBlower
    S.VitrailFoilMaker.init(); _G.VitrailFoilMaker = S.VitrailFoilMaker
    S.ChainmailForger.init(); _G.ChainmailForger = S.ChainmailForger
    S.PlateCuirassSmith.init(); _G.PlateCuirassSmith = S.PlateCuirassSmith
    S.GreaveArmorer.init(); _G.GreaveArmorer = S.GreaveArmorer
    S.GauntletMaker.init(); _G.GauntletMaker = S.GauntletMaker
    S.HalberdSmith.init(); _G.HalberdSmith = S.HalberdSmith
    S.ParquetFloorMaker.init(); _G.ParquetFloorMaker = S.ParquetFloorMaker
    S.MosaicTileMaker.init(); _G.MosaicTileMaker = S.MosaicTileMaker
    S.WallpaperPrinter.init(); _G.WallpaperPrinter = S.WallpaperPrinter
    S.WoodPanelingMaker.init(); _G.WoodPanelingMaker = S.WoodPanelingMaker
    S.StuccoReliefMaker.init(); _G.StuccoReliefMaker = S.StuccoReliefMaker
    S.LongbowMaker.init(); _G.LongbowMaker = S.LongbowMaker
    S.RecurveBowMaker.init(); _G.RecurveBowMaker = S.RecurveBowMaker
    S.ArbalestMaker.init(); _G.ArbalestMaker = S.ArbalestMaker
    S.QuiverMaker.init(); _G.QuiverMaker = S.QuiverMaker
    S.HuntingTrapMaker.init(); _G.HuntingTrapMaker = S.HuntingTrapMaker
    S.ChairMaker.init(); _G.ChairMaker = S.ChairMaker
    S.TableMaker.init(); _G.TableMaker = S.TableMaker
    S.CabinetMaker.init(); _G.CabinetMaker = S.CabinetMaker
    S.BedMaker.init(); _G.BedMaker = S.BedMaker
    S.ChestMaker.init(); _G.ChestMaker = S.ChestMaker
    S.TrophyMaker.init(); _G.TrophyMaker = S.TrophyMaker
    S.CommemorativeTokenMaker.init(); _G.CommemorativeTokenMaker = S.CommemorativeTokenMaker
    S.PendantMaker.init(); _G.PendantMaker = S.PendantMaker
    S.BroochMaker.init(); _G.BroochMaker = S.BroochMaker
    S.LocketMaker.init(); _G.LocketMaker = S.LocketMaker
    S.UmbrellaMaker.init(); _G.UmbrellaMaker = S.UmbrellaMaker
    S.PocketWatchMaker.init(); _G.PocketWatchMaker = S.PocketWatchMaker
    S.WalkingStickMaker.init(); _G.WalkingStickMaker = S.WalkingStickMaker
    S.GloveMaker.init(); _G.GloveMaker = S.GloveMaker
    S.HatMaker.init(); _G.HatMaker = S.HatMaker
    S.RouletteMaker.init(); _G.RouletteMaker = S.RouletteMaker
    S.BackgammonMaker.init(); _G.BackgammonMaker = S.BackgammonMaker
    S.BilliardMaker.init(); _G.BilliardMaker = S.BilliardMaker
    S.TarotCardMaker.init(); _G.TarotCardMaker = S.TarotCardMaker
    S.TavernGameMaker.init(); _G.TavernGameMaker = S.TavernGameMaker
    S.RoofTileMaker.init(); _G.RoofTileMaker = S.RoofTileMaker
    S.IronBeamMaker.init(); _G.IronBeamMaker = S.IronBeamMaker
    S.WoodenColumnMaker.init(); _G.WoodenColumnMaker = S.WoodenColumnMaker
    S.StoneLintelMaker.init(); _G.StoneLintelMaker = S.StoneLintelMaker
    S.WindowFrameMaker.init(); _G.WindowFrameMaker = S.WindowFrameMaker
    S.BookshelfMaker.init(); _G.BookshelfMaker = S.BookshelfMaker
    S.LibraryCatalogMaker.init(); _G.LibraryCatalogMaker = S.LibraryCatalogMaker
    S.ReadingDeskMaker.init(); _G.ReadingDeskMaker = S.ReadingDeskMaker
    S.ScrollCaseMaker.init(); _G.ScrollCaseMaker = S.ScrollCaseMaker
    S.ChronicleBinder.init(); _G.ChronicleBinder = S.ChronicleBinder
    S.IronGateMaker.init(); _G.IronGateMaker = S.IronGateMaker
    S.DrawbridgeMaker.init(); _G.DrawbridgeMaker = S.DrawbridgeMaker
    S.PortcullisMaker.init(); _G.PortcullisMaker = S.PortcullisMaker
    S.BattlementMaker.init(); _G.BattlementMaker = S.BattlementMaker
    S.WatchtowerMaker.init(); _G.WatchtowerMaker = S.WatchtowerMaker
    S.CeremonialSwordMaker.init(); _G.CeremonialSwordMaker = S.CeremonialSwordMaker
    S.ParadeMaceMaker.init(); _G.ParadeMaceMaker = S.ParadeMaceMaker
    S.RitualDaggerMaker.init(); _G.RitualDaggerMaker = S.RitualDaggerMaker
    S.StateSpearMaker.init(); _G.StateSpearMaker = S.StateSpearMaker
    S.PresentationAxeMaker.init(); _G.PresentationAxeMaker = S.PresentationAxeMaker
    S.CraneMaker.init(); _G.CraneMaker = S.CraneMaker
    S.ScaffoldMaker.init(); _G.ScaffoldMaker = S.ScaffoldMaker
    S.PulleyMaker.init(); _G.PulleyMaker = S.PulleyMaker
    S.WinchMaker.init(); _G.WinchMaker = S.WinchMaker
    S.WheelbarrowMaker.init(); _G.WheelbarrowMaker = S.WheelbarrowMaker
    S.WoodLatheMaker.init(); _G.WoodLatheMaker = S.WoodLatheMaker
    S.DrillPressMaker.init(); _G.DrillPressMaker = S.DrillPressMaker
    S.PlanerMaker.init(); _G.PlanerMaker = S.PlanerMaker
    S.SanderMaker.init(); _G.SanderMaker = S.SanderMaker
    S.PolisherMaker.init(); _G.PolisherMaker = S.PolisherMaker
    S.GrainMillMaker.init(); _G.GrainMillMaker = S.GrainMillMaker
    S.SpiceMillMaker.init(); _G.SpiceMillMaker = S.SpiceMillMaker
    S.ConfectionOvenMaker.init(); _G.ConfectionOvenMaker = S.ConfectionOvenMaker
    S.KitchenScaleMaker.init(); _G.KitchenScaleMaker = S.KitchenScaleMaker
    S.BakingSheetMaker.init(); _G.BakingSheetMaker = S.BakingSheetMaker
    S.WireDrawerMaker.init(); _G.WireDrawerMaker = S.WireDrawerMaker
    S.HookMaker.init(); _G.HookMaker = S.HookMaker
    S.MetalMeshMaker.init(); _G.MetalMeshMaker = S.MetalMeshMaker
    S.IronForgeToolMaker.init(); _G.IronForgeToolMaker = S.IronForgeToolMaker
    S.CopperSheetMaker.init(); _G.CopperSheetMaker = S.CopperSheetMaker
    S.OilLampMaker.init(); _G.OilLampMaker = S.OilLampMaker
    S.TorchHolderMaker.init(); _G.TorchHolderMaker = S.TorchHolderMaker
    S.CandlestickMaker.init(); _G.CandlestickMaker = S.CandlestickMaker
    S.BeaconLightMaker.init(); _G.BeaconLightMaker = S.BeaconLightMaker
    S.VestibuleLightMaker.init(); _G.VestibuleLightMaker = S.VestibuleLightMaker
    S.WellBuilder.init(); _G.WellBuilder = S.WellBuilder
    S.AqueductMaker.init(); _G.AqueductMaker = S.AqueductMaker
    S.BathFixtureMaker.init(); _G.BathFixtureMaker = S.BathFixtureMaker
    S.CisternMaker.init(); _G.CisternMaker = S.CisternMaker
    S.LatrineBuilder.init(); _G.LatrineBuilder = S.LatrineBuilder
    S.PlowMaker.init(); _G.PlowMaker = S.PlowMaker
    S.HarrowMaker.init(); _G.HarrowMaker = S.HarrowMaker
    S.SickleSmith.init(); _G.SickleSmith = S.SickleSmith
    S.ScytheSmith.init(); _G.ScytheSmith = S.ScytheSmith
    S.PitchforkMaker.init(); _G.PitchforkMaker = S.PitchforkMaker
    S.SpinningWheelMaker.init(); _G.SpinningWheelMaker = S.SpinningWheelMaker
    S.LoomFrameMaker.init(); _G.LoomFrameMaker = S.LoomFrameMaker
    S.BobbinMaker.init(); _G.BobbinMaker = S.BobbinMaker
    S.ThreadReelMaker.init(); _G.ThreadReelMaker = S.ThreadReelMaker
    S.DyeVatMaker.init(); _G.DyeVatMaker = S.DyeVatMaker
    S.GlassFurnaceMaker.init(); _G.GlassFurnaceMaker = S.GlassFurnaceMaker
    S.AnnealingLehrMaker.init(); _G.AnnealingLehrMaker = S.AnnealingLehrMaker
    S.CrucibleFurnaceMaker.init(); _G.CrucibleFurnaceMaker = S.CrucibleFurnaceMaker
    S.MoldKilnMaker.init(); _G.MoldKilnMaker = S.MoldKilnMaker
    S.TemperingFurnaceMaker.init(); _G.TemperingFurnaceMaker = S.TemperingFurnaceMaker
    S.StateCordonMaker.init(); _G.StateCordonMaker = S.StateCordonMaker
    S.CeremonialSashMaker.init(); _G.CeremonialSashMaker = S.CeremonialSashMaker
    S.ParadeShieldMaker.init(); _G.ParadeShieldMaker = S.ParadeShieldMaker
    S.CourtFanMaker.init(); _G.CourtFanMaker = S.CourtFanMaker
    S.ProcessionalCanopyMaker.init(); _G.ProcessionalCanopyMaker = S.ProcessionalCanopyMaker
    S.DistillationApparatusMaker.init(); _G.DistillationApparatusMaker = S.DistillationApparatusMaker
    S.FiltrationApparatusMaker.init(); _G.FiltrationApparatusMaker = S.FiltrationApparatusMaker
    S.SublimationApparatusMaker.init(); _G.SublimationApparatusMaker = S.SublimationApparatusMaker
    S.CrystallizationDishMaker.init(); _G.CrystallizationDishMaker = S.CrystallizationDishMaker
    S.EvaporatingBasinMaker.init(); _G.EvaporatingBasinMaker = S.EvaporatingBasinMaker
    S.SeedDrillMaker.init(); _G.SeedDrillMaker = S.SeedDrillMaker
    S.ReaperMaker.init(); _G.ReaperMaker = S.ReaperMaker
    S.ThresherMaker.init(); _G.ThresherMaker = S.ThresherMaker
    S.WinnowingMachineMaker.init(); _G.WinnowingMachineMaker = S.WinnowingMachineMaker
    S.SortingMachineMaker.init(); _G.SortingMachineMaker = S.SortingMachineMaker
    S.FishingNetMaker.init(); _G.FishingNetMaker = S.FishingNetMaker
    S.FishingTrapMaker.init(); _G.FishingTrapMaker = S.FishingTrapMaker
    S.FishingRodMaker.init(); _G.FishingRodMaker = S.FishingRodMaker
    S.HarpoonMaker.init(); _G.HarpoonMaker = S.HarpoonMaker
    S.FishingBoatMaker.init(); _G.FishingBoatMaker = S.FishingBoatMaker
    S.PrintingPressMaker.init(); _G.PrintingPressMaker = S.PrintingPressMaker
    S.EngravingMachineMaker.init(); _G.EngravingMachineMaker = S.EngravingMachineMaker
    S.TypesettingMachineMaker.init(); _G.TypesettingMachineMaker = S.TypesettingMachineMaker
    S.BookbindingPressMaker.init(); _G.BookbindingPressMaker = S.BookbindingPressMaker
    S.PaperCuttingMachineMaker.init(); _G.PaperCuttingMachineMaker = S.PaperCuttingMachineMaker
    S.MedalMinter.init(); _G.MedalMinter = S.MedalMinter
    S.RibbonWeaver.init(); _G.RibbonWeaver = S.RibbonWeaver
    S.OrderInsignia.init(); _G.OrderInsignia = S.OrderInsignia
    S.CommendationScroll.init(); _G.CommendationScroll = S.CommendationScroll
    S.CollarOfEstate.init(); _G.CollarOfEstate = S.CollarOfEstate
    S.CarillonMaker.init(); _G.CarillonMaker = S.CarillonMaker
    S.GlockenspielMaker.init(); _G.GlockenspielMaker = S.GlockenspielMaker
    S.HandbellMaker.init(); _G.HandbellMaker = S.HandbellMaker
    S.TubularBellsMaker.init(); _G.TubularBellsMaker = S.TubularBellsMaker
    S.AngelusBellMaker.init(); _G.AngelusBellMaker = S.AngelusBellMaker
    -- Castle Kingdoms 2027 v3.11.382-v3.11.386: Mining tools batch init
    S.PickaxeMaker.init(); _G.PickaxeMaker = S.PickaxeMaker
    S.ShovelMaker.init(); _G.ShovelMaker = S.ShovelMaker
    S.AugerMaker.init(); _G.AugerMaker = S.AugerMaker
    S.MiningChiselMaker.init(); _G.MiningChiselMaker = S.MiningChiselMaker
    S.ProspectingPanMaker.init(); _G.ProspectingPanMaker = S.ProspectingPanMaker
    -- Castle Kingdoms 2027 v3.11.387-v3.11.391: Apothecary containers batch init
    S.MortarPestleMaker.init(); _G.MortarPestleMaker = S.MortarPestleMaker
    S.ApothecaryVialMaker.init(); _G.ApothecaryVialMaker = S.ApothecaryVialMaker
    S.SalveJarMaker.init(); _G.SalveJarMaker = S.SalveJarMaker
    S.SurgicalLancetMaker.init(); _G.SurgicalLancetMaker = S.SurgicalLancetMaker
    S.PhysicPotionMaker.init(); _G.PhysicPotionMaker = S.PhysicPotionMaker
    -- Castle Kingdoms 2027 v3.11.392-v3.11.396: Gardening equipment batch init
    S.PruningShearsMaker.init(); _G.PruningShearsMaker = S.PruningShearsMaker
    S.TopiaryFrameMaker.init(); _G.TopiaryFrameMaker = S.TopiaryFrameMaker
    S.GardenTrowelMaker.init(); _G.GardenTrowelMaker = S.GardenTrowelMaker
    S.HedgeHookMaker.init(); _G.HedgeHookMaker = S.HedgeHookMaker
    S.WateringCanMaker.init(); _G.WateringCanMaker = S.WateringCanMaker
    -- Castle Kingdoms 2027 v3.11.397-v3.11.401: Equestrian equipment batch init
    S.SaddleMaker.init(); _G.SaddleMaker = S.SaddleMaker
    S.BridleMaker.init(); _G.BridleMaker = S.BridleMaker
    S.StirrupMaker.init(); _G.StirrupMaker = S.StirrupMaker
    S.HorseHarnessMaker.init(); _G.HorseHarnessMaker = S.HorseHarnessMaker
    S.SaddlebagMaker.init(); _G.SaddlebagMaker = S.SaddlebagMaker
    -- Castle Kingdoms 2027 v3.11.402-v3.11.406: Painting equipment batch init
    S.EaselMaker.init(); _G.EaselMaker = S.EaselMaker
    S.PaintbrushMaker.init(); _G.PaintbrushMaker = S.PaintbrushMaker
    S.PaletteMaker.init(); _G.PaletteMaker = S.PaletteMaker
    S.PigmentGrinderMaker.init(); _G.PigmentGrinderMaker = S.PigmentGrinderMaker
    S.CanvasStretcherMaker.init(); _G.CanvasStretcherMaker = S.CanvasStretcherMaker
    -- Castle Kingdoms 2027 v3.11.407-v3.11.411: Kitchen equipment batch init
    S.RollingPinMaker.init(); _G.RollingPinMaker = S.RollingPinMaker
    S.CheeseGraterMaker.init(); _G.CheeseGraterMaker = S.CheeseGraterMaker
    S.ButterChurnMaker.init(); _G.ButterChurnMaker = S.ButterChurnMaker
    S.SpiceRackMaker.init(); _G.SpiceRackMaker = S.SpiceRackMaker
    S.CuttingBoardMaker.init(); _G.CuttingBoardMaker = S.CuttingBoardMaker
    -- Castle Kingdoms 2027 v3.11.412-v3.11.416: Glassmaking equipment batch init
    S.GlassBlowerPipeMaker.init(); _G.GlassBlowerPipeMaker = S.GlassBlowerPipeMaker
    S.GlassCutterMaker.init(); _G.GlassCutterMaker = S.GlassCutterMaker
    S.GlassMoldMaker.init(); _G.GlassMoldMaker = S.GlassMoldMaker
    S.AnnealingTongsMaker.init(); _G.AnnealingTongsMaker = S.AnnealingTongsMaker
    S.GlassEngraverMaker.init(); _G.GlassEngraverMaker = S.GlassEngraverMaker
    -- Castle Kingdoms 2027 v3.11.417-v3.11.421: Milling equipment batch init
    S.MillstoneMaker.init(); _G.MillstoneMaker = S.MillstoneMaker
    S.FlourSifterMaker.init(); _G.FlourSifterMaker = S.FlourSifterMaker
    S.DoughHookMaker.init(); _G.DoughHookMaker = S.DoughHookMaker
    S.GrainHopperMaker.init(); _G.GrainHopperMaker = S.GrainHopperMaker
    S.SackLoaderMaker.init(); _G.SackLoaderMaker = S.SackLoaderMaker
    -- Castle Kingdoms 2027 v3.11.422-v3.11.426: Hatmaking equipment batch init
    S.HatBlockMaker.init(); _G.HatBlockMaker = S.HatBlockMaker
    S.HatBandMaker.init(); _G.HatBandMaker = S.HatBandMaker
    S.HatPinMaker.init(); _G.HatPinMaker = S.HatPinMaker
    S.HatFeatherMaker.init(); _G.HatFeatherMaker = S.HatFeatherMaker
    S.HatBoxMaker.init(); _G.HatBoxMaker = S.HatBoxMaker
    -- Castle Kingdoms 2027 v3.11.427-v3.11.431: Ropemaking equipment batch init
    S.RopeMaker.init(); _G.RopeMaker = S.RopeMaker
    S.TwineMaker.init(); _G.TwineMaker = S.TwineMaker
    S.NetMaker.init(); _G.NetMaker = S.NetMaker
    S.CordageMaker.init(); _G.CordageMaker = S.CordageMaker
    S.KnotBoardMaker.init(); _G.KnotBoardMaker = S.KnotBoardMaker
    -- Castle Kingdoms 2027 v3.11.432-v3.11.436: Comb-making equipment batch init
    S.CombMaker.init(); _G.CombMaker = S.CombMaker
    S.HairbrushMaker.init(); _G.HairbrushMaker = S.HairbrushMaker
    S.HairpinMaker.init(); _G.HairpinMaker = S.HairpinMaker
    S.BeardCombMaker.init(); _G.BeardCombMaker = S.BeardCombMaker
    S.LiceCombMaker.init(); _G.LiceCombMaker = S.LiceCombMaker
    -- Castle Kingdoms 2027 v3.11.437-v3.11.441: Saddler's accessories batch init
    S.SaddleSoapMaker.init(); _G.SaddleSoapMaker = S.SaddleSoapMaker
    S.SaddlePolishMaker.init(); _G.SaddlePolishMaker = S.SaddlePolishMaker
    S.LeatherConditionerMaker.init(); _G.LeatherConditionerMaker = S.LeatherConditionerMaker
    S.StirrupLeatherMaker.init(); _G.StirrupLeatherMaker = S.StirrupLeatherMaker
    S.BridleBuckleMaker.init(); _G.BridleBuckleMaker = S.BridleBuckleMaker
    -- Castle Kingdoms 2027 v3.11.442-v3.11.446: Wax equipment batch init
    S.CandleMoldMaker.init(); _G.CandleMoldMaker = S.CandleMoldMaker
    S.WickSpinnerMaker.init(); _G.WickSpinnerMaker = S.WickSpinnerMaker
    S.WaxDipperMaker.init(); _G.WaxDipperMaker = S.WaxDipperMaker
    S.CandlestickBaseMaker.init(); _G.CandlestickBaseMaker = S.CandlestickBaseMaker
    S.TaperRollerMaker.init(); _G.TaperRollerMaker = S.TaperRollerMaker
    -- Castle Kingdoms 2027 v3.11.447-v3.11.451: Foundry/casting equipment batch init
    S.CrucibleMaker.init(); _G.CrucibleMaker = S.CrucibleMaker
    S.SandMoldMaker.init(); _G.SandMoldMaker = S.SandMoldMaker
    S.IngotMoldMaker.init(); _G.IngotMoldMaker = S.IngotMoldMaker
    S.FlaskMaker.init(); _G.FlaskMaker = S.FlaskMaker
    S.CastingLadleMaker.init(); _G.CastingLadleMaker = S.CastingLadleMaker
    -- Castle Kingdoms 2027 v3.11.452-v3.11.456: Blacksmith tools batch init
    S.TongMaker.init(); _G.TongMaker = S.TongMaker
    S.HammerMaker.init(); _G.HammerMaker = S.HammerMaker
    S.AnvilMaker.init(); _G.AnvilMaker = S.AnvilMaker
    S.BellowsMaker.init(); _G.BellowsMaker = S.BellowsMaker
    S.ForgeTongsMaker.init(); _G.ForgeTongsMaker = S.ForgeTongsMaker
    -- Castle Kingdoms 2027 v3.11.457-v3.11.461: Woodworking tools batch init
    S.PlaneIronMaker.init(); _G.PlaneIronMaker = S.PlaneIronMaker
    S.ChiselBladeMaker.init(); _G.ChiselBladeMaker = S.ChiselBladeMaker
    S.SawSetMaker.init(); _G.SawSetMaker = S.SawSetMaker
    S.AugerBitMaker.init(); _G.AugerBitMaker = S.AugerBitMaker
    S.ClampMaker.init(); _G.ClampMaker = S.ClampMaker
    -- Castle Kingdoms 2027 v3.11.462-v3.11.466: Ceramic equipment batch init
    S.PotteryWheelMaker.init(); _G.PotteryWheelMaker = S.PotteryWheelMaker
    S.KilnFurnitureMaker.init(); _G.KilnFurnitureMaker = S.KilnFurnitureMaker
    S.ClayExtruderMaker.init(); _G.ClayExtruderMaker = S.ClayExtruderMaker
    S.GlazeSieveMaker.init(); _G.GlazeSieveMaker = S.GlazeSieveMaker
    S.BisqueStandMaker.init(); _G.BisqueStandMaker = S.BisqueStandMaker
    -- Castle Kingdoms 2027 v3.11.467-v3.11.471: Glassmaking accessories batch init
    S.GlassBatchMaker.init(); _G.GlassBatchMaker = S.GlassBatchMaker
    S.GlassColorantMaker.init(); _G.GlassColorantMaker = S.GlassColorantMaker
    S.GlassSeedMaker.init(); _G.GlassSeedMaker = S.GlassSeedMaker
    S.GlassRibbonMaker.init(); _G.GlassRibbonMaker = S.GlassRibbonMaker
    S.GlassFritMaker.init(); _G.GlassFritMaker = S.GlassFritMaker
    -- Castle Kingdoms 2027 v3.11.472-v3.11.476: Weaving equipment batch init
    S.LoomHeddleMaker.init(); _G.LoomHeddleMaker = S.LoomHeddleMaker
    S.ShuttleMaker.init(); _G.ShuttleMaker = S.ShuttleMaker
    S.BobbinWinderMaker.init(); _G.BobbinWinderMaker = S.BobbinWinderMaker
    S.WarpBeamMaker.init(); _G.WarpBeamMaker = S.WarpBeamMaker
    S.ClothPresserMaker.init(); _G.ClothPresserMaker = S.ClothPresserMaker
    -- Castle Kingdoms 2027 v3.11.477-v3.11.481: Bookbinding equipment batch init
    S.BookPressMaker.init(); _G.BookPressMaker = S.BookPressMaker
    S.StitchingAwlMaker.init(); _G.StitchingAwlMaker = S.StitchingAwlMaker
    S.BindingCordMaker.init(); _G.BindingCordMaker = S.BindingCordMaker
    S.LeatherCoverMaker.init(); _G.LeatherCoverMaker = S.LeatherCoverMaker
    S.GildingPressMaker.init(); _G.GildingPressMaker = S.GildingPressMaker
    -- Castle Kingdoms 2027 v3.11.482-v3.11.486: Quill/writing equipment batch init
    S.QuillCutterMaker.init(); _G.QuillCutterMaker = S.QuillCutterMaker
    S.InkwellMaker.init(); _G.InkwellMaker = S.InkwellMaker
    S.ParchmentRackMaker.init(); _G.ParchmentRackMaker = S.ParchmentRackMaker
    S.WaxTabletMaker.init(); _G.WaxTabletMaker = S.WaxTabletMaker
    S.WritingStandMaker.init(); _G.WritingStandMaker = S.WritingStandMaker
    -- Castle Kingdoms 2027 v3.11.487-v3.11.491: Coin minting equipment batch init
    S.CoinPressMaker.init(); _G.CoinPressMaker = S.CoinPressMaker
    S.CoinDieMaker.init(); _G.CoinDieMaker = S.CoinDieMaker
    S.CoinBlankMaker.init(); _G.CoinBlankMaker = S.CoinBlankMaker
    S.CoinSorterMaker.init(); _G.CoinSorterMaker = S.CoinSorterMaker
    S.CoinScaleMaker.init(); _G.CoinScaleMaker = S.CoinScaleMaker
    -- Castle Kingdoms 2027 v3.11.492-v3.11.496: Musical instrument parts batch init
    S.StringWinderMaker.init(); _G.StringWinderMaker = S.StringWinderMaker
    S.TuningPinMaker.init(); _G.TuningPinMaker = S.TuningPinMaker
    S.BridgeMaker.init(); _G.BridgeMaker = S.BridgeMaker
    S.SoundpostMaker.init(); _G.SoundpostMaker = S.SoundpostMaker
    S.TailpieceMaker.init(); _G.TailpieceMaker = S.TailpieceMaker
    -- Castle Kingdoms 2027 v3.11.497-v3.11.501: Aromatic equipment batch init
    S.IncenseMolderMaker.init(); _G.IncenseMolderMaker = S.IncenseMolderMaker
    S.PerfumeBottleMaker.init(); _G.PerfumeBottleMaker = S.PerfumeBottleMaker
    S.SachetMaker.init(); _G.SachetMaker = S.SachetMaker
    S.PotpourriBowlMaker.init(); _G.PotpourriBowlMaker = S.PotpourriBowlMaker
    S.ScentConeMaker.init(); _G.ScentConeMaker = S.ScentConeMaker
    -- Castle Kingdoms 2027 v3.11.502-v3.11.506: Military equipment batch init
    S.ShieldBossMaker.init(); _G.ShieldBossMaker = S.ShieldBossMaker
    S.SwordPommelMaker.init(); _G.SwordPommelMaker = S.SwordPommelMaker
    S.ScabbardChapeMaker.init(); _G.ScabbardChapeMaker = S.ScabbardChapeMaker
    S.HelmetCrestMaker.init(); _G.HelmetCrestMaker = S.HelmetCrestMaker
    S.BannerPoleMaker.init(); _G.BannerPoleMaker = S.BannerPoleMaker
    -- Castle Kingdoms 2027 v3.11.507-v3.11.511: Astrological equipment batch init
    S.AstrolabeRingMaker.init(); _G.AstrolabeRingMaker = S.AstrolabeRingMaker
    S.StarChartRackMaker.init(); _G.StarChartRackMaker = S.StarChartRackMaker
    S.CelestialGlobeMaker.init(); _G.CelestialGlobeMaker = S.CelestialGlobeMaker
    S.SundialGnomonMaker.init(); _G.SundialGnomonMaker = S.SundialGnomonMaker
    S.CompassNeedleMaker.init(); _G.CompassNeedleMaker = S.CompassNeedleMaker
    -- Castle Kingdoms 2027 v3.11.512-v3.11.516: Clockwork accessories batch init
    S.PendulumRodMaker.init(); _G.PendulumRodMaker = S.PendulumRodMaker
    S.EscapementLeverMaker.init(); _G.EscapementLeverMaker = S.EscapementLeverMaker
    S.MainspringWinderMaker.init(); _G.MainspringWinderMaker = S.MainspringWinderMaker
    S.ClockDialEngraverMaker.init(); _G.ClockDialEngraverMaker = S.ClockDialEngraverMaker
    S.ChimeHammerMaker.init(); _G.ChimeHammerMaker = S.ChimeHammerMaker
    -- Castle Kingdoms 2027 v3.11.517-v3.11.521: Bathroom equipment batch init
    S.TowelRackMaker.init(); _G.TowelRackMaker = S.TowelRackMaker
    S.SoapDishMaker.init(); _G.SoapDishMaker = S.SoapDishMaker
    S.BathBucketMaker.init(); _G.BathBucketMaker = S.BathBucketMaker
    S.SpongeHolderMaker.init(); _G.SpongeHolderMaker = S.SpongeHolderMaker
    S.WashstandMaker.init(); _G.WashstandMaker = S.WashstandMaker
    -- Castle Kingdoms 2027 v3.11.522-v3.11.526: Kitchen accessories batch init
    S.MortarPestleStandMaker.init(); _G.MortarPestleStandMaker = S.MortarPestleStandMaker
    S.SpiceGrinderMaker.init(); _G.SpiceGrinderMaker = S.SpiceGrinderMaker
    S.OlivePressMaker.init(); _G.OlivePressMaker = S.OlivePressMaker
    S.WineStrainerMaker.init(); _G.WineStrainerMaker = S.WineStrainerMaker
    S.HoneyDipperMaker.init(); _G.HoneyDipperMaker = S.HoneyDipperMaker
    -- Castle Kingdoms 2027 v3.11.527-v3.11.531: Garden accessories batch init
    S.GardenSieveMaker.init(); _G.GardenSieveMaker = S.GardenSieveMaker
    S.PlantSupportMaker.init(); _G.PlantSupportMaker = S.PlantSupportMaker
    S.WateringSpikeMaker.init(); _G.WateringSpikeMaker = S.WateringSpikeMaker
    S.CompostAeratorMaker.init(); _G.CompostAeratorMaker = S.CompostAeratorMaker
    S.SeedDrillPlowMaker.init(); _G.SeedDrillPlowMaker = S.SeedDrillPlowMaker
    -- Castle Kingdoms 2027 v3.11.532-v3.11.536: Bakery accessories batch init
    S.DoughScraperMaker.init(); _G.DoughScraperMaker = S.DoughScraperMaker
    S.ProofingBasketMaker.init(); _G.ProofingBasketMaker = S.ProofingBasketMaker
    S.BreadLameMaker.init(); _G.BreadLameMaker = S.BreadLameMaker
    S.OvenPeelMaker.init(); _G.OvenPeelMaker = S.OvenPeelMaker
    S.FlourShovelMaker.init(); _G.FlourShovelMaker = S.FlourShovelMaker
    -- Castle Kingdoms 2027 v3.11.537-v3.11.541: Fishing accessories batch init
    S.FishHookMaker.init(); _G.FishHookMaker = S.FishHookMaker
    S.FishingLineSpoolMaker.init(); _G.FishingLineSpoolMaker = S.FishingLineSpoolMaker
    S.BaitBoxMaker.init(); _G.BaitBoxMaker = S.BaitBoxMaker
    S.FishScalerMaker.init(); _G.FishScalerMaker = S.FishScalerMaker
    S.NetMendingNeedleMaker.init(); _G.NetMendingNeedleMaker = S.NetMendingNeedleMaker
    -- Castle Kingdoms 2027 v3.11.382: Initialize Royal Systems Registry (auto-discovers all 347+ systems)
    RoyalSystemsRegistry.init(S)
    _G.RoyalSystemsRegistry = RoyalSystemsRegistry
    -- Castle Kingdoms 2027: Initialize economy systems
    DynamicMarket.init()
    SeasonalSystem.init()
    EconomicEvents.init()
    TradeCaravans.init()
    -- Castle Kingdoms 2027 v2.3.4: Register SeasonalSystem as global for AI access
    _G.SeasonalSystem = SeasonalSystem
    -- Castle Kingdoms 2027 v2.3.5: Register EconomicEvents as global for AI access
    _G.EconomicEvents = EconomicEvents
    -- Castle Kingdoms 2027 v2.3.7: Register DynamicMarket as global for AI trade
    _G.DynamicMarket = DynamicMarket
    -- Castle Kingdoms 2027 v2.6.0: Register MissionFramework as global for combat casualty tracking
    _G.MissionFramework = MissionFramework
    -- Castle Kingdoms 2027: Initialize performance profiling
    PerformanceManager.init()
    PriorityUpdate.init()
    AITickOptimizer.init()
    MemoryProfiler.init()
    RenderOptimizer.init()
    -- Castle Kingdoms 2027: Initialize game feel feedback
    GameFeel.init()
    BuildPreview.init()
    SelectionFeedback.init()
    CombatOrderViz.init()
    -- Castle Kingdoms 2027: Load persisted settings
    SettingsPersistence.init()
    SettingsPersistence.applyAll()
    GameFeelSettings.applySettings()
    -- Register globally for other systems to access
    _G.GameFeel = GameFeel
    _G.BuildPreview = BuildPreview
    _G.SelectionFeedback = SelectionFeedback
    _G.CombatOrderViz = CombatOrderViz
    ModernUI.notifySuccess("Castle Kingdoms 2027 loaded! Press F1 for help, F3 for perf overlay.")
    -- Castle Kingdoms 2027: Show tutorial hints on first game
    TutorialHints.onGameStart()
    -- Castle Kingdoms 2027: Initialize campaign progress & auto-save
    CampaignProgress.init()
    AutoSaveSystem.init()
    AutoSaveSystem.setEnabledFromSettings()
    -- Castle Kingdoms 2027: Initialize Kenney CC0 asset loader
    KenneyAssetLoader.init()
    _G.KenneyAssetLoader = KenneyAssetLoader
    _G.KenneySpriteRenderer = KenneySpriteRenderer
    if _G.state.newGame then
        _G.playSpeech("place_a_keep")
        _G.BuildController.start = true
        ActionBar:showGroup("start")
        local buttons = require("states.ui.construction.level_1_new_game")
        buttons.castleButton:enable()
        buttons.stockpileButton:disable()
        buttons.granaryButton:disable()
    else
        ActionBar:showGroup("main")
    end
    _G.paused = false
    loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
end

function game:init()
end

local scrolledAmountWithinShortPeriod = 0
local scrollCountDown = 0.05
function game:update(dt)
    if (not _G.state or not _G.state.initialized) then
        delayedInit()
        _G.state.initialized = true
    else
        prof.push("core")
        ActionBar:animate()
        core.update()
        if scrollCountDown > 0 then
            scrollCountDown = scrollCountDown - love.timer.getDelta()
        elseif scrollCountDown < 0 then
            scrollCountDown = 0
            core.scale(scrolledAmountWithinShortPeriod)
        end
        prof.pop("core")
        if not _G.paused then
            local HighlightView = require("objects.Controllers.HighlightView")
            prof.push("objects")
            objects.update(dt)
            prof.pop("objects")
            _G.state.Terrain:update()
            prof.push("bcontr")
            HighlightView:update()
            _G.BuildController:update()
            _G.DebugView:update()
            _G.BrushController:update()
            if not _G.BuildController.start then
                _G.TimeController:update()
                RationController:update()
                _G.AleController:update()
                _G.ReligionController:update()
                _G.HerdController:update()
                _G.TaxController:update()
                _G.PopularityController:update()
                _G.ScribeController:update()
                _G.DestructionController:update()
                _G.SleepController:update()
                -- Castle Kingdoms 2027: Update combat system
                CombatIntegration.update(dt)
                -- Castle Kingdoms 2027: Update immersion systems
                S.AnimationSystem.updateAll(dt)
                S.SoundSystem.update(dt)
                S.WeatherSystem.update(dt)
                ModernUI.update(dt)
                S.LightingSystem.update(dt)
                -- Castle Kingdoms 2027: Update HD render pipeline (normal maps, lights)
                S.HDRenderPipeline.update(dt)
                -- Castle Kingdoms 2027: Update multiplayer networking
                S.GameServer.update(dt)
                S.GameClient.update(dt)
                S.Chat.update(dt)
                -- Castle Kingdoms 2027: Update diplomacy & trade
                S.DiplomacyController.update(dt)
                S.TradeController.update(dt)
                if S.DiplomacyPanel.isVisible() then
                    S.DiplomacyPanel.refresh()
                end
                -- Castle Kingdoms 2027: Update QA systems
                S.PerfWatchdog.update(dt)
                S.AudioMix.update(dt)
                S.ReplaySystem.update(dt)
                S.StatisticsDashboard.updateStats()
                S.MapEditor.update(dt)
                -- Castle Kingdoms 2027: Update dynamic music
                S.DynamicMusic.update(dt)
                -- Castle Kingdoms 2027: Update mods
                S.ModLoader.update(dt)
                -- Castle Kingdoms 2027: Update tutorial
                S.TutorialSystem.update(dt)
                -- Castle Kingdoms 2027: Update siege weapons
                S.SiegeWeapons.update(dt)
                S.CampaignStory.update(dt)
                -- Castle Kingdoms 2027: Performance optimization
                S.PerfOpt.checkGC()
                S.PerfOpt.resetFrameStats()
                -- Castle Kingdoms 2027: Update visual polish (particles, animations)
                S.VisualPolish.update(dt)
                -- Castle Kingdoms 2027: Update performance benchmark
                S.PerfBenchmark.update(dt)
                -- Castle Kingdoms 2027: Update gameplay systems
                S.FestivalSystem.update(dt)
                -- Castle Kingdoms 2027: Update loading tips + credits
                S.LoadingTips.update(dt)
                S.CreditsScreen.update(dt)
                -- Castle Kingdoms 2027: Update screenshot manager
                S.ScreenshotManager.update(dt)
                -- Castle Kingdoms 2027: Update improvements
                S.Minimap.update(dt)
                S.AIDialogue.update(dt)
                S.ConstructionAnim.update(dt)
                -- Clean up dead unit command queues
                if _G.state and _G.state.gameObjectList then
                    S.CommandQueue.cleanup(_G.state.gameObjectList)
                end
                -- Castle Kingdoms 2027: Update v1.25 systems
                S.AutoSaveEnhancer.update(dt)
                S.ThreatAI.update(dt)
                S.ResourceFlow.update(dt)
                S.Veterancy.cleanup(_G.state.gameObjectList or {})
                -- Castle Kingdoms 2027: Update v1.26 QoL systems
                S.AutoWorker.update(dt)
                S.DynamicUnitCap.update(dt)
                -- Castle Kingdoms 2027: Update v1.27 systems
                S.SpectatorMode.update(dt)
                S.Workshop.update(dt)
                -- Castle Kingdoms 2027: Update v1.28 systems
                S.AutoSaveIndicator.update(dt)
                S.Gamepad.update(dt)
                -- Castle Kingdoms 2027: Update v2.2 systems
                S.AutoUpdater.update(dt)
                -- Castle Kingdoms 2027 v2.6.4: Update Technology Tree research
                S.TechnologyTree.update(dt)
                -- Castle Kingdoms 2027 v2.6.5: Update Population System
                S.PopulationSystem.update(dt)
                -- Castle Kingdoms 2027 v2.6.6: Update Production Chain System
                S.ProductionChain.update(dt)
                -- Castle Kingdoms 2027 v2.6.7: Update Espionage System
                S.Espionage.update(dt)
                -- Castle Kingdoms 2027 v2.6.8: Update Diplomatic Relations (slow decay)
                S.DiplomaticRelations.update(dt)
                -- Castle Kingdoms 2027 v2.6.9: Update Army Command System
                S.ArmyCommand.update(dt)
                -- Castle Kingdoms 2027 v2.7.0: Update Trade Route System
                S.TradeRoute.update(dt)
                -- Castle Kingdoms 2027 v2.7.1: Update Random Event System
                S.RandomEvent.update(dt)
                -- Castle Kingdoms 2027 v2.7.2: Update Notification Center
                S.NotificationCenter.update(dt)
                -- Castle Kingdoms 2027 v2.7.3: Update Building Manager
                S.BuildingManager.update(dt)
                -- Castle Kingdoms 2027 v2.7.5: Update Supply Line System
                S.SupplyLine.update(dt)
                -- Castle Kingdoms 2027 v2.7.6: Update Quest System
                S.QuestSystem.update(dt)
                -- Castle Kingdoms 2027 v2.7.7: Update Analytics
                S.Analytics.update(dt)
                -- Castle Kingdoms 2027 v2.7.8: Update Tactical Overlay
                S.TacticalOverlay.update(dt)
                -- Castle Kingdoms 2027 v2.8.0: Update Tournament System
                S.Tournament.update(dt)
                -- Castle Kingdoms 2027 v2.8.4: Update Replay Enhancement
                S.ReplayEnhanced.update(dt)
                -- Castle Kingdoms 2027 v2.8.6: Update Weather Warfare
                S.WeatherWarfare.update(dt)
                -- Castle Kingdoms 2027 v2.8.7: Update Hero System
                S.HeroSystem.update(dt)
                -- Castle Kingdoms 2027 v2.8.8: Update Time Manager
                S.TimeManager.update(dt)
                -- Castle Kingdoms 2027 v2.8.9: Update Camera Enhancement
                S.CameraEnhanced.update(dt)
                -- Castle Kingdoms 2027 v2.9.2: Update Soundtrack Manager
                S.SoundtrackMgr.update(dt)
                -- Castle Kingdoms 2027 v2.9.5: Update Tooltip System
                S.TooltipSystem.update(dt)
                -- Castle Kingdoms 2027 v2.9.6: Update Achievement Animation
                S.AchievementAnim.update(dt)
                -- Castle Kingdoms 2027 v2.9.7: Update Map Editor (mouse tracking)
                S.MapEditorEnhanced.mousemoved(love.mouse.getPosition())
                -- Castle Kingdoms 2027 v2.9.8: Update Dynamic Difficulty Adjuster
                S.DDA.update(dt)
                -- Castle Kingdoms 2027 v2.9.9: Update Performance Auto-Tuner
                S.AutoTuner.update(dt)
                -- Castle Kingdoms 2027 v3.0.0: Update Resource Forecast
                S.Forecast.update(dt)
                -- Castle Kingdoms 2027 v3.0.1: Update Matchmaking
                S.Matchmaking.update(dt)
                -- Castle Kingdoms 2027 v3.0.2: Update Stats Widget
                S.StatsWidget.update(dt)
                -- Castle Kingdoms 2027 v3.0.3: Update Castle Siege
                S.CastleSiege.update(dt)
                -- Castle Kingdoms 2027 v3.0.4: Update Trade Negotiations
                S.TradeNeg.update(dt)
                -- Castle Kingdoms 2027 v3.0.5: Update Governor System
                S.Governor.update(dt)
                -- Castle Kingdoms 2027 v3.0.6: Update Court & Nobility
                S.Court.update(dt)
                -- Castle Kingdoms 2027 v3.0.7: Update Disease & Health
                S.Disease.update(dt)
                -- Castle Kingdoms 2027 v3.0.8: Update Religion & Faith
                S.Religion.update(dt)
                -- Castle Kingdoms 2027 v3.0.9: Update Trade Guilds
                S.TradeGuild.update(dt)
                -- Castle Kingdoms 2027 v3.1.0: Update Mercenaries
                S.Mercenary.update(dt)
                -- Castle Kingdoms 2027 v3.1.1: Update Prisoners
                S.Prisoner.update(dt)
                -- Castle Kingdoms 2027 v3.1.2: Update Famine & Scarcity
                S.Famine.update(dt)
                -- Castle Kingdoms 2027 v3.1.3: Update Treason & Rebellion
                S.Rebellion.update(dt)
                -- Castle Kingdoms 2027 v3.1.4: Update Black Market
                S.BlackMarket.update(dt)
                -- Castle Kingdoms 2027 v3.1.5: Update Royal Decrees
                S.Decrees.update(dt)
                -- Castle Kingdoms 2027 v3.1.6: Update Culture & Education
                S.Culture.update(dt)
                -- Castle Kingdoms 2027 v3.1.7: Update Royal Dynasty
                S.Dynasty.update(dt)
                -- Castle Kingdoms 2027 v3.1.8: Update Naval System
                S.Naval.update(dt)
                -- Castle Kingdoms 2027 v3.1.9: Update Winter Quarters
                S.Winter.update(dt)
                -- Castle Kingdoms 2027 v3.2.0: Update Treasury & Taxation
                S.Treasury.update(dt)
                -- Castle Kingdoms 2027 v3.2.3: Update Royal Mint
                S.Mint.update(dt)
                -- Castle Kingdoms 2027 v3.2.4: Update Tournaments
                S.Tournament.update(dt)
                -- Castle Kingdoms 2027 v3.2.5: Update Court Intrigue
                S.Intrigue.update(dt)
                -- Castle Kingdoms 2027 v3.2.6: Update Court Entertainment
                S.Entertainment.update(dt)
                -- Castle Kingdoms 2027 v3.2.7: Update Royal Archive
                S.Archive.update(dt)
                -- Castle Kingdoms 2027 v3.2.8: Update Royal Progress
                S.Progress.update(dt)
                -- Castle Kingdoms 2027 v3.2.9: Update Law & Justice
                S.Justice.update(dt)
                -- Castle Kingdoms 2027 v3.3.0: Update Royal Guard
                S.Guard.update(dt)
                -- Castle Kingdoms 2027 v3.3.1: Update Royal Feast
                S.Feast.update(dt)
                -- Castle Kingdoms 2027 v3.3.2: Update Royal Menagerie
                S.Menagerie.update(dt)
                -- Castle Kingdoms 2027 v3.3.3: Update Royal Astrologer
                S.Astrology.update(dt)
                -- Castle Kingdoms 2027 v3.3.4: Update Royal Apothecary
                S.Apothecary.update(dt)
                -- Castle Kingdoms 2027 v3.3.5: Update Royal Cartographer
                S.Cartographer.update(dt)
                -- Castle Kingdoms 2027 v3.3.6: Update Royal Stables
                S.Stables.update(dt)
                -- Castle Kingdoms 2027 v3.3.7: Update Royal Beekeeper
                S.Beekeeper.update(dt)
                -- Castle Kingdoms 2027 v3.3.8: Update Royal Vineyard
                S.Vineyard.update(dt)
                -- Castle Kingdoms 2027 v3.3.9: Update Royal Falconer
                S.Falconer.update(dt)
                -- Castle Kingdoms 2027 v3.4.0: Update Royal Gardens
                S.Gardens.update(dt)
                -- Castle Kingdoms 2027 v3.4.1: Update Royal Alchemist
                S.Alchemist.update(dt)
                -- Castle Kingdoms 2027 v3.4.2: Update Royal Hunt
                S.Hunt.update(dt)
                -- Castle Kingdoms 2027 v3.4.3: Update Royal Forester
                S.Forester.update(dt)
                -- Castle Kingdoms 2027 v3.4.4: Update Genetics System
                S.Genetics.update(dt)
                -- Castle Kingdoms 2027 v3.4.5: Update Royal Music
                S.Music.update(dt)
                -- Castle Kingdoms 2027 v3.4.6: Update Royal Philosophy
                S.Philosophy.update(dt)
                -- Castle Kingdoms 2027 v3.4.7: Update Royal Physician
                S.Physician.update(dt)
                -- Castle Kingdoms 2027 v3.4.8: Update Advanced Astrology
                S.AstrologyAdv.update(dt)
                -- Castle Kingdoms 2027 v3.4.9: Update Royal Engineer
                S.Engineer.update(dt)
                -- Castle Kingdoms 2027 v3.5.0: Update Royal Diplomat
                S.Diplomat.update(dt)
                -- Castle Kingdoms 2027 v3.5.1: Update Royal Historian
                S.Historian.update(dt)
                -- Castle Kingdoms 2027 v3.5.2: Update Royal Ceremonies
                S.Ceremonies.update(dt)
                -- Castle Kingdoms 2027 v3.5.3: Update Royal Confessor
                S.Confessor.update(dt)
                -- Castle Kingdoms 2027 v3.5.4: Update Royal Minstrel
                S.Minstrel.update(dt)
                -- Castle Kingdoms 2027 v3.5.5: Update Royal Comedy
                S.Comedy.update(dt)
                -- Castle Kingdoms 2027 v3.5.6: Update Royal Cupbearer
                S.Cupbearer.update(dt)
                -- Castle Kingdoms 2027 v3.5.7: Update Royal Chandlery
                S.Chandlery.update(dt)
                -- Castle Kingdoms 2027 v3.5.8: Update Royal Potter
                S.Potter.update(dt)
                -- Castle Kingdoms 2027 v3.5.9: Update Royal Weaver
                S.Weaver.update(dt)
                -- Castle Kingdoms 2027 v3.6.0: Update Royal Glassmaker
                S.Glassmaker.update(dt)
                -- Castle Kingdoms 2027 v3.6.1: Update Royal Clockmaker
                S.Clockmaker.update(dt)
                -- Castle Kingdoms 2027 v3.6.2: Update Royal Jeweler
                S.Jeweler.update(dt)
                -- Castle Kingdoms 2027 v3.6.3: Update Royal Calligraphy
                S.Calligraphy.update(dt)
                -- Castle Kingdoms 2027 v3.6.4: Update Royal Funerary
                S.Funerary.update(dt)
                -- Castle Kingdoms 2027 v3.6.5: Update Royal Perfumer
                S.Perfumer.update(dt)
                -- Castle Kingdoms 2027 v3.6.6: Update Royal Dyer
                S.Dyer.update(dt)
                -- Castle Kingdoms 2027 v3.6.7: Update Royal Bookbinder
                S.Bookbinder.update(dt)
                -- Castle Kingdoms 2027 v3.6.8: Update Royal Sculptor
                S.Sculptor.update(dt)
                -- Castle Kingdoms 2027 v3.6.9: Update Royal Painter
                S.Painter.update(dt)
                -- Castle Kingdoms 2027 v3.7.0: Update Royal Metalworker
                S.Metalworker.update(dt)
                -- Castle Kingdoms 2027 v3.7.1: Update Royal Leatherworker
                S.Leatherworker.update(dt)
                -- Castle Kingdoms 2027 v3.7.2: Update Royal Surveyor
                S.Surveyor.update(dt)
                -- Castle Kingdoms 2027 v3.7.3: Update Royal Tax Collector
                S.TaxCollector.update(dt)
                -- Castle Kingdoms 2027 v3.7.4: Update Royal Postal
                S.Postal.update(dt)
                -- Castle Kingdoms 2027 v3.7.5: Update Royal Distiller
                S.Distiller.update(dt)
                -- Castle Kingdoms 2027 v3.7.6: Update Royal Forge
                S.Forge.update(dt)
                -- Castle Kingdoms 2027 v3.7.7: Update Royal Woodworker
                S.Woodworker.update(dt)
                -- Castle Kingdoms 2027 v3.7.8-v3.8.6: Update 9 new craft systems
                S.Mason.update(dt)
                S.Armorer.update(dt)
                S.Scribe.update(dt)
                S.Barber.update(dt)
                S.Baker.update(dt)
                S.Cooper.update(dt)
                S.Ropemaker.update(dt)
                S.Locksmith.update(dt)
                S.Chandler.update(dt)
                -- Castle Kingdoms 2027 v3.8.7-v3.9.1: Update 5 new craft systems
                S.Fletcher.update(dt)
                S.Saddler.update(dt)
                S.NailMaker.update(dt)
                S.SoapMaker.update(dt)
                S.InkMaker.update(dt)
                -- Castle Kingdoms 2027 v3.9.2-v3.9.6: Update 5 new craft systems
                S.Thatcher.update(dt)
                S.Plasterer.update(dt)
                S.Glazier.update(dt)
                S.BellFounder.update(dt)
                S.OrganBuilder.update(dt)
                -- Castle Kingdoms 2027 v3.9.7-v3.10.1: Update 5 new craft systems
                S.Compass.update(dt)
                S.LensGrinder.update(dt)
                S.DiceMaker.update(dt)
                S.Embroiderer.update(dt)
                S.Gilder.update(dt)
                -- Castle Kingdoms 2027 v3.10.2-v3.10.6: Update 5 new craft systems
                S.CombMaker.update(dt)
                S.SealEngraver.update(dt)
                S.FanMaker.update(dt)
                S.PuppetMaker.update(dt)
                S.ButtonMaker.update(dt)
                -- Castle Kingdoms 2027 v3.10.7-v3.11.1: Update 5 new craft systems
                S.BasketWeaver.update(dt)
                S.MatMaker.update(dt)
                S.TokenMaker.update(dt)
                S.Engraver.update(dt)
                S.Horologist.update(dt)
                -- Castle Kingdoms 2027 v3.11.2-v3.11.6: Update 5 new craft systems
                S.ChessCarver.update(dt)
                S.SundialMaker.update(dt)
                S.StringMaker.update(dt)
                S.NeedleMaker.update(dt)
                S.WaxModeler.update(dt)
                -- Castle Kingdoms 2027 v3.11.7-v3.11.11: Update 5 new craft systems
                S.TileMaker.update(dt)
                S.ClayPipeMaker.update(dt)
                S.SconceMaker.update(dt)
                S.SignBoardMaker.update(dt)
                S.LanternMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.12-v3.11.16: Update 5 new craft systems
                S.FunnelMaker.update(dt)
                S.CofferMaker.update(dt)
                S.BellPullMaker.update(dt)
                S.KeyMaker.update(dt)
                S.ChainMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.17-v3.11.21: Update 5 new craft systems
                S.HingeMaker.update(dt)
                S.BoltLatchMaker.update(dt)
                S.RivetMaker.update(dt)
                S.CrownMaker.update(dt)
                S.ScepterMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.22-v3.11.26: Update 5 new craft systems
                S.ThroneMaker.update(dt)
                S.OrbMaker.update(dt)
                S.SealRingMaker.update(dt)
                S.MedalMaker.update(dt)
                S.TapestryLoom.update(dt)
                -- Castle Kingdoms 2027 v3.11.27-v3.11.31: Update 5 new craft systems
                S.StainedGlassMaker.update(dt)
                S.CarpetLoom.update(dt)
                S.CushionMaker.update(dt)
                S.BannerMaker.update(dt)
                S.HeraldicFlagMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.32-v3.11.36: Update 5 new liturgical systems
                S.CopeVestmentMaker.update(dt)
                S.AltarFrontalMaker.update(dt)
                S.ReliquaryMaker.update(dt)
                S.ChrismatoryMaker.update(dt)
                S.ProcessionalCrossMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.37-v3.11.41: Update 5 new liturgical vessel systems
                S.MonstranceMaker.update(dt)
                S.CiboriumMaker.update(dt)
                S.ChaliceMaker.update(dt)
                S.PatenMaker.update(dt)
                S.ThuribleMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.42-v3.11.46: Update 5 new musical instrument systems
                S.OrganPipeMaker.update(dt)
                S.BellWheelMaker.update(dt)
                S.CymbalMaker.update(dt)
                S.HarpMaker.update(dt)
                S.DrummerMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.47-v3.11.51: Update 5 new musical instrument systems
                S.LuteMaker.update(dt)
                S.FiddleMaker.update(dt)
                S.PsalteryMaker.update(dt)
                S.HurdyGurdyMaker.update(dt)
                S.RecorderMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.52-v3.11.56: Update 5 new wind instrument systems
                S.ShawmMaker.update(dt)
                S.CrumhornMaker.update(dt)
                S.SackbutMaker.update(dt)
                S.BagpipeMaker.update(dt)
                S.PipeTaborMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.57-v3.11.61: Update 5 new weapons & armor systems
                S.SwordsmithMaker.update(dt)
                S.DaggerMaker.update(dt)
                S.HelmetMaker.update(dt)
                S.ShieldMaker.update(dt)
                S.ArmorMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.62-v3.11.66: Update 5 new weapon systems
                S.Bowyer.update(dt)
                S.Fletcher.update(dt)
                S.CrossbowMaker.update(dt)
                S.PolearmMaker.update(dt)
                S.MaceAxeMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.67-v3.11.71: Update 5 new cavalry equipment systems
                S.SaddleMaker.update(dt)
                S.SpurMaker.update(dt)
                S.HorseArmorMaker.update(dt)
                S.LanceMaker.update(dt)
                S.CavalryBannerMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.72-v3.11.76: Update 5 new siege engine systems
                S.CatapultMaker.update(dt)
                S.TrebuchetMaker.update(dt)
                S.BallistaMaker.update(dt)
                S.SiegeTowerMaker.update(dt)
                S.BatteringRamMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.77-v3.11.81: Update 5 new gunpowder weapon systems
                S.CannonMaker.update(dt)
                S.MortarMaker.update(dt)
                S.BombardMaker.update(dt)
                S.HandCannonMaker.update(dt)
                S.GrenadeMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.82-v3.11.86: Update 5 new gunpowder resource systems
                S.GunpowderMill.update(dt)
                S.SaltpeterRefinery.update(dt)
                S.SulfurCollector.update(dt)
                S.CharcoalBurner.update(dt)
                S.MatchCordMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.87-v3.11.91: Update 5 new beverage systems
                S.AleBrewer.update(dt)
                S.MeadMaker.update(dt)
                S.WineVintner.update(dt)
                S.CiderPress.update(dt)
                S.BrandyDistiller.update(dt)
                -- Castle Kingdoms 2027 v3.11.92-v3.11.96: Update 5 new food resource systems
                S.SpiceMerchant.update(dt)
                S.SaltRefiner.update(dt)
                S.SugarRefiner.update(dt)
                S.HoneyCollector.update(dt)
                S.OilPresser.update(dt)
                -- Castle Kingdoms 2027 v3.11.97-v3.11.101: Update 5 new dairy & bakery systems
                S.CheeseMaker.update(dt)
                S.ButterChurner.update(dt)
                S.YogurtFermenter.update(dt)
                S.BreadBaker.update(dt)
                S.PastryChef.update(dt)
                -- Castle Kingdoms 2027 v3.11.102-v3.11.106: Update 5 new meat & preservation systems
                S.SausageMaker.update(dt)
                S.SmokedMeatCurer.update(dt)
                S.FishSmoker.update(dt)
                S.PickleCurer.update(dt)
                S.Confectioner.update(dt)
                -- Castle Kingdoms 2027 v3.11.107-v3.11.111: Update 5 new textile raw material systems
                S.DyeStuffMaker.update(dt)
                S.RawhideTanner.update(dt)
                S.Furrier.update(dt)
                S.WoolStapler.update(dt)
                S.SilkReeler.update(dt)
                -- Castle Kingdoms 2027 v3.11.112-v3.11.116: Update 5 new fiber raw material systems
                S.LinenRetter.update(dt)
                S.HempRetter.update(dt)
                S.CottonGin.update(dt)
                S.CanvasWeaver.update(dt)
                S.RopeSpinner.update(dt)
                -- Castle Kingdoms 2027 v3.11.117-v3.11.121: Update 5 new construction material systems
                S.GlassBatchSmelter.update(dt)
                S.IngotSmelter.update(dt)
                S.LimeBurner.update(dt)
                S.BrickMaker.update(dt)
                S.PotteryKiln.update(dt)
                -- Castle Kingdoms 2027 v3.11.122-v3.11.126: Update 5 new wood & stone raw material systems
                S.TimberFeller.update(dt)
                S.Sawmill.update(dt)
                S.QuarryMiner.update(dt)
                S.ClayDigger.update(dt)
                S.GemMiner.update(dt)
                -- Castle Kingdoms 2027 v3.11.127-v3.11.131: Update 5 new agricultural systems
                S.GrainFarmer.update(dt)
                S.Orchardist.update(dt)
                S.VineyardPlanter.update(dt)
                S.HerbGardener.update(dt)
                S.ApiaryKeeper.update(dt)
                -- Castle Kingdoms 2027 v3.11.132-v3.11.136: Update 5 new livestock farming systems
                S.CattleRancher.update(dt)
                S.SheepShepherd.update(dt)
                S.PigFarmer.update(dt)
                S.PoultryKeeper.update(dt)
                S.HorseBreeder.update(dt)
                -- Castle Kingdoms 2027 v3.11.137-v3.11.141: Update 5 new water/economic systems
                S.Fisherman.update(dt)
                S.OysterFarmer.update(dt)
                S.WhalingCaptain.update(dt)
                S.SaltPanWorker.update(dt)
                S.IceCutter.update(dt)
                -- Castle Kingdoms 2027 v3.11.142-v3.11.146: Update 5 new animal breeding systems
                S.FalconBreeder.update(dt)
                S.PigeonCourier.update(dt)
                S.HoundBreeder.update(dt)
                S.HuntingFalconer.update(dt)
                S.WarDogTrainer.update(dt)
                -- Castle Kingdoms 2027 v3.11.147-v3.11.151: Update 5 new scientific/cartographic systems
                S.MapMaker.update(dt)
                S.StarChartMaker.update(dt)
                S.PaperMaker.update(dt)
                S.ParchmentMaker.update(dt)
                S.QuillPenMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.152-v3.11.156: Update 5 new scientific instrument systems
                S.AstrolabeMaker.update(dt)
                S.AbacusMaker.update(dt)
                S.BalanceScaleMaker.update(dt)
                S.SextantMaker.update(dt)
                S.ArmillarySphereMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.157-v3.11.161: Update 5 new optical/measurement systems
                S.TelescopeMaker.update(dt)
                S.HourglassMaker.update(dt)
                S.MicroscopeMaker.update(dt)
                S.BarometerMaker.update(dt)
                S.ThermometerMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.162-v3.11.166: Update 5 new medical & alchemical systems
                S.SurgicalToolMaker.update(dt)
                S.LeechCollector.update(dt)
                S.PlagueDoctorMaskMaker.update(dt)
                S.PotionBrewer.update(dt)
                S.AlchemicalElixirMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.167-v3.11.171: Update 5 new personal & entertainment systems
                S.MirrorMaker.update(dt)
                S.WigMaker.update(dt)
                S.FortuneTeller.update(dt)
                S.TattooArtist.update(dt)
                S.JesterPropsMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.172-v3.11.176: Update 5 new toy & game systems
                S.BoardGameMaker.update(dt)
                S.CardDeckMaker.update(dt)
                S.DominoMaker.update(dt)
                S.PlayingCardMaker.update(dt)
                S.JigsawPuzzleMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.177-v3.11.181: Update 5 new toy & decorative systems
                S.KiteMaker.update(dt)
                S.TopMaker.update(dt)
                S.DollHouseMaker.update(dt)
                S.MarbleStatueMaker.update(dt)
                S.PerfumeBottleMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.182-v3.11.186: Update 5 new decorative furnishing systems
                S.ClockFacePainter.update(dt)
                S.CurtainMaker.update(dt)
                S.ChandelierMaker.update(dt)
                S.CandelabraMaker.update(dt)
                S.FountainMaker.update(dt)
                S.AquariumKeeper.update(dt)
                S.AviaryKeeper.update(dt)
                S.TerrariumKeeper.update(dt)
                S.ButterflyBreeder.update(dt)
                S.BonsaiCultivator.update(dt)
                S.VegetableGardener.update(dt)
                S.MushroomForager.update(dt)
                S.AloeCultivator.update(dt)
                S.SaffronGrower.update(dt)
                S.HopsGrower.update(dt)
                S.InkMaker.update(dt)
                S.WaxSealPresser.update(dt)
                S.CalendarMaker.update(dt)
                S.CodexBinder.update(dt)
                S.ManuscriptIlluminator.update(dt)
                S.TasselMaker.update(dt)
                S.Knitter.update(dt)
                S.Crocheter.update(dt)
                S.LaceMaker.update(dt)
                S.SamplerStitcher.update(dt)
                S.LyreMaker.update(dt)
                S.TrumpetMaker.update(dt)
                S.FluteMaker.update(dt)
                S.MandolinMaker.update(dt)
                S.PanFluteMaker.update(dt)
                S.PlanetariumMaker.update(dt)
                S.SundialMaker.update(dt)
                S.CompassMaker.update(dt)
                S.QuadrantMaker.update(dt)
                S.NocturnalMaker.update(dt)
                S.CoffeeRoaster.update(dt)
                S.TeaBlender.update(dt)
                S.ChocolateConfectioner.update(dt)
                S.TobaccoCurer.update(dt)
                S.SnuffMiller.update(dt)
                S.StagePropMaker.update(dt)
                S.CostumeTailor.update(dt)
                S.TheaterMaskMaker.update(dt)
                S.EaselMaker.update(dt)
                S.PaintMaker.update(dt)
                S.CoronationMantleMaker.update(dt)
                S.RoyalCrestCarver.update(dt)
                S.RoyalSealStampMaker.update(dt)
                S.RoyalBannerHerald.update(dt)
                S.CoronationCushionMaker.update(dt)
                S.CrucibleMaker.update(dt)
                S.RetortMaker.update(dt)
                S.HydrometerMaker.update(dt)
                S.AlambicStillMaker.update(dt)
                S.ApothecaryMortarMaker.update(dt)
                S.KitchenKnifeMaker.update(dt)
                S.CutlerySmith.update(dt)
                S.CookwareFounder.update(dt)
                S.ServingPlateMaker.update(dt)
                S.WoodenSpoonCarver.update(dt)
                S.CrystalGobletMaker.update(dt)
                S.GlassBeadMaker.update(dt)
                S.LensGrinder.update(dt)
                S.BeakerBlower.update(dt)
                S.VitrailFoilMaker.update(dt)
                S.ChainmailForger.update(dt)
                S.PlateCuirassSmith.update(dt)
                S.GreaveArmorer.update(dt)
                S.GauntletMaker.update(dt)
                S.HalberdSmith.update(dt)
                S.ParquetFloorMaker.update(dt)
                S.MosaicTileMaker.update(dt)
                S.WallpaperPrinter.update(dt)
                S.WoodPanelingMaker.update(dt)
                S.StuccoReliefMaker.update(dt)
                S.LongbowMaker.update(dt)
                S.RecurveBowMaker.update(dt)
                S.ArbalestMaker.update(dt)
                S.QuiverMaker.update(dt)
                S.HuntingTrapMaker.update(dt)
                S.ChairMaker.update(dt)
                S.TableMaker.update(dt)
                S.CabinetMaker.update(dt)
                S.BedMaker.update(dt)
                S.ChestMaker.update(dt)
                S.TrophyMaker.update(dt)
                S.CommemorativeTokenMaker.update(dt)
                S.PendantMaker.update(dt)
                S.BroochMaker.update(dt)
                S.LocketMaker.update(dt)
                S.UmbrellaMaker.update(dt)
                S.PocketWatchMaker.update(dt)
                S.WalkingStickMaker.update(dt)
                S.GloveMaker.update(dt)
                S.HatMaker.update(dt)
                S.RouletteMaker.update(dt)
                S.BackgammonMaker.update(dt)
                S.BilliardMaker.update(dt)
                S.TarotCardMaker.update(dt)
                S.TavernGameMaker.update(dt)
                S.RoofTileMaker.update(dt)
                S.IronBeamMaker.update(dt)
                S.WoodenColumnMaker.update(dt)
                S.StoneLintelMaker.update(dt)
                S.WindowFrameMaker.update(dt)
                S.BookshelfMaker.update(dt)
                S.LibraryCatalogMaker.update(dt)
                S.ReadingDeskMaker.update(dt)
                S.ScrollCaseMaker.update(dt)
                S.ChronicleBinder.update(dt)
                S.IronGateMaker.update(dt)
                S.DrawbridgeMaker.update(dt)
                S.PortcullisMaker.update(dt)
                S.BattlementMaker.update(dt)
                S.WatchtowerMaker.update(dt)
                S.CeremonialSwordMaker.update(dt)
                S.ParadeMaceMaker.update(dt)
                S.RitualDaggerMaker.update(dt)
                S.StateSpearMaker.update(dt)
                S.PresentationAxeMaker.update(dt)
                S.CraneMaker.update(dt)
                S.ScaffoldMaker.update(dt)
                S.PulleyMaker.update(dt)
                S.WinchMaker.update(dt)
                S.WheelbarrowMaker.update(dt)
                S.WoodLatheMaker.update(dt)
                S.DrillPressMaker.update(dt)
                S.PlanerMaker.update(dt)
                S.SanderMaker.update(dt)
                S.PolisherMaker.update(dt)
                S.GrainMillMaker.update(dt)
                S.SpiceMillMaker.update(dt)
                S.ConfectionOvenMaker.update(dt)
                S.KitchenScaleMaker.update(dt)
                S.BakingSheetMaker.update(dt)
                S.WireDrawerMaker.update(dt)
                S.HookMaker.update(dt)
                S.MetalMeshMaker.update(dt)
                S.IronForgeToolMaker.update(dt)
                S.CopperSheetMaker.update(dt)
                S.OilLampMaker.update(dt)
                S.TorchHolderMaker.update(dt)
                S.CandlestickMaker.update(dt)
                S.BeaconLightMaker.update(dt)
                S.VestibuleLightMaker.update(dt)
                S.WellBuilder.update(dt)
                S.AqueductMaker.update(dt)
                S.BathFixtureMaker.update(dt)
                S.CisternMaker.update(dt)
                S.LatrineBuilder.update(dt)
                S.PlowMaker.update(dt)
                S.HarrowMaker.update(dt)
                S.SickleSmith.update(dt)
                S.ScytheSmith.update(dt)
                S.PitchforkMaker.update(dt)
                S.SpinningWheelMaker.update(dt)
                S.LoomFrameMaker.update(dt)
                S.BobbinMaker.update(dt)
                S.ThreadReelMaker.update(dt)
                S.DyeVatMaker.update(dt)
                S.GlassFurnaceMaker.update(dt)
                S.AnnealingLehrMaker.update(dt)
                S.CrucibleFurnaceMaker.update(dt)
                S.MoldKilnMaker.update(dt)
                S.TemperingFurnaceMaker.update(dt)
                S.StateCordonMaker.update(dt)
                S.CeremonialSashMaker.update(dt)
                S.ParadeShieldMaker.update(dt)
                S.CourtFanMaker.update(dt)
                S.ProcessionalCanopyMaker.update(dt)
                S.DistillationApparatusMaker.update(dt)
                S.FiltrationApparatusMaker.update(dt)
                S.SublimationApparatusMaker.update(dt)
                S.CrystallizationDishMaker.update(dt)
                S.EvaporatingBasinMaker.update(dt)
                S.SeedDrillMaker.update(dt)
                S.ReaperMaker.update(dt)
                S.ThresherMaker.update(dt)
                S.WinnowingMachineMaker.update(dt)
                S.SortingMachineMaker.update(dt)
                S.FishingNetMaker.update(dt)
                S.FishingTrapMaker.update(dt)
                S.FishingRodMaker.update(dt)
                S.HarpoonMaker.update(dt)
                S.FishingBoatMaker.update(dt)
                S.PrintingPressMaker.update(dt)
                S.EngravingMachineMaker.update(dt)
                S.TypesettingMachineMaker.update(dt)
                S.BookbindingPressMaker.update(dt)
                S.PaperCuttingMachineMaker.update(dt)
                S.MedalMinter.update(dt)
                S.RibbonWeaver.update(dt)
                S.OrderInsignia.update(dt)
                S.CommendationScroll.update(dt)
                S.CollarOfEstate.update(dt)
                S.CarillonMaker.update(dt)
                S.GlockenspielMaker.update(dt)
                S.HandbellMaker.update(dt)
                S.TubularBellsMaker.update(dt)
                S.AngelusBellMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.382-v3.11.386: Mining tools batch update
                S.PickaxeMaker.update(dt)
                S.ShovelMaker.update(dt)
                S.AugerMaker.update(dt)
                S.MiningChiselMaker.update(dt)
                S.ProspectingPanMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.387-v3.11.391: Apothecary containers batch update
                S.MortarPestleMaker.update(dt)
                S.ApothecaryVialMaker.update(dt)
                S.SalveJarMaker.update(dt)
                S.SurgicalLancetMaker.update(dt)
                S.PhysicPotionMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.392-v3.11.396: Gardening equipment batch update
                S.PruningShearsMaker.update(dt)
                S.TopiaryFrameMaker.update(dt)
                S.GardenTrowelMaker.update(dt)
                S.HedgeHookMaker.update(dt)
                S.WateringCanMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.397-v3.11.401: Equestrian equipment batch update
                S.SaddleMaker.update(dt)
                S.BridleMaker.update(dt)
                S.StirrupMaker.update(dt)
                S.HorseHarnessMaker.update(dt)
                S.SaddlebagMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.402-v3.11.406: Painting equipment batch update
                S.EaselMaker.update(dt)
                S.PaintbrushMaker.update(dt)
                S.PaletteMaker.update(dt)
                S.PigmentGrinderMaker.update(dt)
                S.CanvasStretcherMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.407-v3.11.411: Kitchen equipment batch update
                S.RollingPinMaker.update(dt)
                S.CheeseGraterMaker.update(dt)
                S.ButterChurnMaker.update(dt)
                S.SpiceRackMaker.update(dt)
                S.CuttingBoardMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.412-v3.11.416: Glassmaking equipment batch update
                S.GlassBlowerPipeMaker.update(dt)
                S.GlassCutterMaker.update(dt)
                S.GlassMoldMaker.update(dt)
                S.AnnealingTongsMaker.update(dt)
                S.GlassEngraverMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.417-v3.11.421: Milling equipment batch update
                S.MillstoneMaker.update(dt)
                S.FlourSifterMaker.update(dt)
                S.DoughHookMaker.update(dt)
                S.GrainHopperMaker.update(dt)
                S.SackLoaderMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.422-v3.11.426: Hatmaking equipment batch update
                S.HatBlockMaker.update(dt)
                S.HatBandMaker.update(dt)
                S.HatPinMaker.update(dt)
                S.HatFeatherMaker.update(dt)
                S.HatBoxMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.427-v3.11.431: Ropemaking equipment batch update
                S.RopeMaker.update(dt)
                S.TwineMaker.update(dt)
                S.NetMaker.update(dt)
                S.CordageMaker.update(dt)
                S.KnotBoardMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.432-v3.11.436: Comb-making equipment batch update
                S.CombMaker.update(dt)
                S.HairbrushMaker.update(dt)
                S.HairpinMaker.update(dt)
                S.BeardCombMaker.update(dt)
                S.LiceCombMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.437-v3.11.441: Saddler's accessories batch update
                S.SaddleSoapMaker.update(dt)
                S.SaddlePolishMaker.update(dt)
                S.LeatherConditionerMaker.update(dt)
                S.StirrupLeatherMaker.update(dt)
                S.BridleBuckleMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.442-v3.11.446: Wax equipment batch update
                S.CandleMoldMaker.update(dt)
                S.WickSpinnerMaker.update(dt)
                S.WaxDipperMaker.update(dt)
                S.CandlestickBaseMaker.update(dt)
                S.TaperRollerMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.447-v3.11.451: Foundry/casting equipment batch update
                S.CrucibleMaker.update(dt)
                S.SandMoldMaker.update(dt)
                S.IngotMoldMaker.update(dt)
                S.FlaskMaker.update(dt)
                S.CastingLadleMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.452-v3.11.456: Blacksmith tools batch update
                S.TongMaker.update(dt)
                S.HammerMaker.update(dt)
                S.AnvilMaker.update(dt)
                S.BellowsMaker.update(dt)
                S.ForgeTongsMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.457-v3.11.461: Woodworking tools batch update
                S.PlaneIronMaker.update(dt)
                S.ChiselBladeMaker.update(dt)
                S.SawSetMaker.update(dt)
                S.AugerBitMaker.update(dt)
                S.ClampMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.462-v3.11.466: Ceramic equipment batch update
                S.PotteryWheelMaker.update(dt)
                S.KilnFurnitureMaker.update(dt)
                S.ClayExtruderMaker.update(dt)
                S.GlazeSieveMaker.update(dt)
                S.BisqueStandMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.467-v3.11.471: Glassmaking accessories batch update
                S.GlassBatchMaker.update(dt)
                S.GlassColorantMaker.update(dt)
                S.GlassSeedMaker.update(dt)
                S.GlassRibbonMaker.update(dt)
                S.GlassFritMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.472-v3.11.476: Weaving equipment batch update
                S.LoomHeddleMaker.update(dt)
                S.ShuttleMaker.update(dt)
                S.BobbinWinderMaker.update(dt)
                S.WarpBeamMaker.update(dt)
                S.ClothPresserMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.477-v3.11.481: Bookbinding equipment batch update
                S.BookPressMaker.update(dt)
                S.StitchingAwlMaker.update(dt)
                S.BindingCordMaker.update(dt)
                S.LeatherCoverMaker.update(dt)
                S.GildingPressMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.482-v3.11.486: Quill/writing equipment batch update
                S.QuillCutterMaker.update(dt)
                S.InkwellMaker.update(dt)
                S.ParchmentRackMaker.update(dt)
                S.WaxTabletMaker.update(dt)
                S.WritingStandMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.487-v3.11.491: Coin minting equipment batch update
                S.CoinPressMaker.update(dt)
                S.CoinDieMaker.update(dt)
                S.CoinBlankMaker.update(dt)
                S.CoinSorterMaker.update(dt)
                S.CoinScaleMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.492-v3.11.496: Musical instrument parts batch update
                S.StringWinderMaker.update(dt)
                S.TuningPinMaker.update(dt)
                S.BridgeMaker.update(dt)
                S.SoundpostMaker.update(dt)
                S.TailpieceMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.497-v3.11.501: Aromatic equipment batch update
                S.IncenseMolderMaker.update(dt)
                S.PerfumeBottleMaker.update(dt)
                S.SachetMaker.update(dt)
                S.PotpourriBowlMaker.update(dt)
                S.ScentConeMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.502-v3.11.506: Military equipment batch update
                S.ShieldBossMaker.update(dt)
                S.SwordPommelMaker.update(dt)
                S.ScabbardChapeMaker.update(dt)
                S.HelmetCrestMaker.update(dt)
                S.BannerPoleMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.507-v3.11.511: Astrological equipment batch update
                S.AstrolabeRingMaker.update(dt)
                S.StarChartRackMaker.update(dt)
                S.CelestialGlobeMaker.update(dt)
                S.SundialGnomonMaker.update(dt)
                S.CompassNeedleMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.512-v3.11.516: Clockwork accessories batch update
                S.PendulumRodMaker.update(dt)
                S.EscapementLeverMaker.update(dt)
                S.MainspringWinderMaker.update(dt)
                S.ClockDialEngraverMaker.update(dt)
                S.ChimeHammerMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.517-v3.11.521: Bathroom equipment batch update
                S.TowelRackMaker.update(dt)
                S.SoapDishMaker.update(dt)
                S.BathBucketMaker.update(dt)
                S.SpongeHolderMaker.update(dt)
                S.WashstandMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.522-v3.11.526: Kitchen accessories batch update
                S.MortarPestleStandMaker.update(dt)
                S.SpiceGrinderMaker.update(dt)
                S.OlivePressMaker.update(dt)
                S.WineStrainerMaker.update(dt)
                S.HoneyDipperMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.527-v3.11.531: Garden accessories batch update
                S.GardenSieveMaker.update(dt)
                S.PlantSupportMaker.update(dt)
                S.WateringSpikeMaker.update(dt)
                S.CompostAeratorMaker.update(dt)
                S.SeedDrillPlowMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.532-v3.11.536: Bakery accessories batch update
                S.DoughScraperMaker.update(dt)
                S.ProofingBasketMaker.update(dt)
                S.BreadLameMaker.update(dt)
                S.OvenPeelMaker.update(dt)
                S.FlourShovelMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.537-v3.11.541: Fishing accessories batch update
                S.FishHookMaker.update(dt)
                S.FishingLineSpoolMaker.update(dt)
                S.BaitBoxMaker.update(dt)
                S.FishScalerMaker.update(dt)
                S.NetMendingNeedleMaker.update(dt)
                -- Castle Kingdoms 2027 v3.11.382: Royal Systems Registry aggregates stats + grants bonus gold
                RoyalSystemsRegistry.update(dt)
                RoyalMarketIntegration.update(dt)
                RoyalSystemsPanel.update(dt)
                MarketDashboard.update(dt)
                AutoSavePanel.update(dt)
                -- Castle Kingdoms 2027: Update fog of war periodically
                if not _G._fogTimer then _G._fogTimer = 0 end
                _G._fogTimer = _G._fogTimer + dt
                if _G._fogTimer > 1.0 then
                    _G._fogTimer = 0
                    pcall(function() S.FogOfWar.updateVisibility() end)
                end
                -- Castle Kingdoms 2027: Update AI system (with profiling)
                PerformanceManager.beginSection("ai_update")
                AIIntegration.update(dt)
                PerformanceManager.endSection("ai_update")
                -- Castle Kingdoms 2027: Update economy systems (with profiling)
                PerformanceManager.beginSection("economy")
                DynamicMarket.update(dt)
                DynamicMarket.updateEvents()
                SeasonalSystem.update(dt)
                EconomicEvents.update(dt)
                TradeCaravans.update(dt)
                PerformanceManager.endSection("economy")
                -- Castle Kingdoms 2027: Update mission framework
                MissionFramework.update(dt)
                -- Castle Kingdoms 2027: Update economy UI
                DynamicMarketUI.update(dt)
                CaravanUI.update(dt)
                -- Castle Kingdoms 2027: Update HUD widgets
                SeasonWidget.update(dt)
                EventLog.update(dt)
                -- Castle Kingdoms 2027: Update performance profiling
                PerformanceManager.update(dt)
                MemoryProfiler.update(dt)
                AITickOptimizer.update(dt)
                -- Castle Kingdoms 2027: Update game feel feedback
                GameFeel.update(dt)
                BuildPreview.update(dt)
                SelectionFeedback.update(dt)
                CombatOrderViz.update(dt)
                -- Castle Kingdoms 2027: Update render optimizer (camera bounds)
                RenderOptimizer.updateCameraBounds()
                -- Castle Kingdoms 2027: Auto-detect HD light sources every 2 seconds
                if not _G._hdLightTimer then _G._hdLightTimer = 0 end
                _G._hdLightTimer = _G._hdLightTimer + dt
                if _G._hdLightTimer > 2.0 then
                    _G._hdLightTimer = 0
                    pcall(function() S.HDRenderPipeline.autoDetectLights() end)
                end
                -- Castle Kingdoms 2027: Update UX screens
                MissionEndScreen.update(dt)
                S.CreditsScreen.update(dt)
                TutorialHints.update(dt)
                -- Castle Kingdoms 2027: Update auto-save
                AutoSaveSystem.update(dt)
                -- Update selection box position while dragging
                if _G.Commander and _G.Commander.isDown then
                    local mx, my = love.mouse.getPosition()
                    SelectionFeedback.updateBox(mx, my)
                end
                _G.MissionStart = true
                if (loveframes.GetState() == states.STATE_ARMOURY) then
                    ArmouryUI.DisplayCurrentStock()
                end
                if (loveframes.GetState() == states.STATE_MARKET) then
                    MarketUI(groupTypeMarket.name)
                end
                if (loveframes.GetState() == states.STATE_BARRACKS) then
                    BarracksUI.DisplayCurrentStock()
                end
                if (loveframes.GetState() == states.STATE_GUILDS) then
                    GuildsUI.DisplayButtons()
                end
                if (loveframes.GetState() == states.STATE_INGAME_CONSTRUCTION) then
                    WorkshopsUI.CheckTooltip()
                end
            end
            prof.pop("bcontr")
        end
        prof.push("ui")
        loveframes.update()
        prof.pop("ui")
        prof.push("pathfind")
        _G.finder:update()
        prof.pop("pathfind")
        local error = _G.state.thread:getError()
        assert(not error, error)
        error = _G.state.thread2:getError()
        assert(not error, error)
        -- Stop playing main menu music at game start
        if _G.BuildController.start then
            if _G.CURRENT_MUSIC and _G.CURRENT_MUSIC:isPlaying() then
                love.audio.stop(_G.CURRENT_MUSIC)
                _G.CURRENT_MUSIC = nil
                _G.CURRENT_PLAYLIST_INDEX = 0
            end
        else
            playlist()
        end
    end
end

function game:enter(_, savegameName, w, h)
    love.graphics.setBackgroundColor(26 / 255, 26 / 255, 26 / 255, 1)
    savegame = savegameName
    collectgarbage()
    collectgarbage()
    _G.chunksWide, _G.chunksHigh = w, h
    -- Castle Kingdoms 2027: Apply selected map size if not overridden
    if MapSizeSelector and not w then
        S.MapSizeSelector.applyToGame()
    end
    if _G.loaded then
        _G.paused = false
        loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
    end
end

function game:draw()
    if not _G.testMode then
        if _G.loaded then
            local HighlightView = require("objects.Controllers.HighlightView")
            if _G.state.scaleX >= 2.1 or _G.paused then
                love.postshader.setBuffer("render")
            end
            love.graphics.push()
            love.graphics.translate((love.graphics.getWidth() / 2), (love.graphics.getHeight() / 2))
            objects.draw()
            if not _G.paused then
                HighlightView:draw()
                _G.BuildController:draw()
                _G.DebugView:draw()
                _G.BrushController:draw()
                _G.ArrowController:draw()
            end
            _G.Commander:draw()
            -- Castle Kingdoms 2027: Draw combat system (projectiles, damage numbers, health bars)
            CombatIntegration.draw()
            -- Castle Kingdoms 2027: Draw light sources (torches, fires)
            S.LightingSystem.drawLights()
            -- Castle Kingdoms 2027: Draw weather (rain, snow, fog)
            S.WeatherSystem.draw()
            love.graphics.pop()
            if _G.paused then
                love.postshader.addTiltshift(12)
            elseif _G.state.scaleX >= 2.1 then
                love.postshader.addTiltshift(4)
            end
            core.draw()
            prof.push("ui_draw")
            loveframes.draw()
            ActionBar:draw()
            prof.pop("ui_draw")
            if not _G.paused then
                _G.ScribeController:draw()
            end
            if _G.state.scaleX >= 2.1 or _G.paused then
                love.postshader.draw()
            end
            _G.Commander:drawMouse()
            if not _G.paused then
                local WallController = require("objects.Controllers.WallController")
                WallController:drawMouse()
            end
            console.draw()
            -- Castle Kingdoms 2027: Draw modern UI (tooltips, notifications)
            ModernUI.draw()
            -- Castle Kingdoms 2027: Draw mission UI (objectives, timer)
            MissionFramework.draw()
            -- Castle Kingdoms 2027: Draw economy UI (market, caravans)
            DynamicMarketUI.draw()
            CaravanUI.draw()
            -- Castle Kingdoms 2027: Draw HUD widgets (season, events)
            SeasonWidget.draw()
            EventLog.draw()
            -- Castle Kingdoms 2027: Draw performance overlay (F3/F4)
            PerformanceOverlay.draw()
            -- Castle Kingdoms 2027: Draw game feel feedback (selection rings, build preview, combat orders)
            -- Use scissor to prevent drawing over action bar
            local screenWidth, screenHeight = love.graphics.getDimensions()
            love.graphics.setScissor(0, 0, screenWidth, screenHeight - 150)
            SelectionFeedback.draw()
            BuildPreview.draw()
            CombatOrderViz.draw()
            love.graphics.setScissor()
            -- Castle Kingdoms 2027: Draw settings panel (V key)
            GameFeelSettings.draw()
            -- Castle Kingdoms 2027: Draw mission end screen
            MissionEndScreen.draw()
            -- Castle Kingdoms 2027: Draw keybind help (H key)
            KeybindHelp.draw()
            -- Castle Kingdoms 2027 v3.11.382: Draw Royal Systems panel (Ctrl+R)
            RoyalSystemsPanel.draw()
            -- Castle Kingdoms 2027 v3.11.903: Draw Market Dashboard (Ctrl+K)
            MarketDashboard.draw()
            -- Castle Kingdoms 2027 v3.11.918: Draw Auto-Save Panel (Ctrl+U)
            AutoSavePanel.draw()
            -- Castle Kingdoms 2027: Draw Kenney CC0 overlay (if enabled)
            if _G.KenneySpriteRenderer and _G.KenneySpriteRenderer.isActive() then
                love.graphics.setScissor(0, 0, screenWidth, screenHeight - 150)
                KenneySpriteOverlay.draw()
                love.graphics.setScissor()
            end
            -- Castle Kingdoms 2027: Draw tutorial overlay
            S.TutorialSystem.draw()
            -- Castle Kingdoms 2027: Draw siege weapons
            S.SiegeWeapons.draw()
            -- Castle Kingdoms 2027: Draw campaign story dialogue
            S.CampaignStory.draw()
            -- Castle Kingdoms 2027: Draw debug console
            S.DebugConsole.draw()
            -- Castle Kingdoms 2027: Draw visual polish particles
            S.VisualPolish.draw()
            -- Castle Kingdoms 2027: Draw loading tips (bottom-left, above action bar)
            S.LoadingTips.draw(10, love.graphics.getHeight() - 310, 300)
            S.CreditsScreen.draw()
            -- Castle Kingdoms 2027: Draw improvements
            S.Minimap.draw()
            S.GameSpeedControl.draw()
            S.ConstructionAnim.draw()
            S.AIDialogue.draw()
            -- Draw command queue indicators for selected units
            if _G.Commander and _G.Commander.selectedUnits then
                S.CommandQueue.drawSelected(_G.Commander.selectedUnits)
            end
            -- Castle Kingdoms 2027: Draw v1.25 visuals
            S.ResourceFlow.draw()
            S.Veterancy.drawSelected()
            -- Castle Kingdoms 2027: Draw v1.26 QoL visuals
            S.RallyPoint.draw()
            S.BuildingQueue.draw()
            -- Castle Kingdoms 2027: Draw v1.27 visuals
            S.SpectatorMode.draw()
            -- Castle Kingdoms 2027: Draw v1.28 visuals
            S.AutoSaveIndicator.draw()
            S.Gamepad.draw()
            -- Castle Kingdoms 2027 v2.7.2: Draw Notification Center
            S.NotificationCenter.draw()
            -- Castle Kingdoms 2027 v3.0.2: Draw Stats Dashboard Widget
            S.StatsWidget.draw()
            -- Castle Kingdoms 2027 v3.0.8: Draw Religion & Faith overlay
            S.Religion.draw()
        else
            renderLoadingScreen("")
            renderLoadingBar(loadState, progress)
            loveframes.draw()
        end
    end
end

function game:mousepressed(x, y, button, istouch)
    if not _G.loaded then return end
    if loveframes.mousepressed(x, y, button) then
        return
    end
    -- Castle Kingdoms 2027: Handle economy UI clicks
    if DynamicMarketUI.isVisible() then
        if DynamicMarketUI.mousepressed(x, y, button) then return end
    end
    if CaravanUI.isVisible() then
        if CaravanUI.mousepressed(x, y, button) then return end
    end
    if GameFeelSettings.isVisible() then
        if GameFeelSettings.mousepressed(x, y, button) then return end
    end
    if MissionEndScreen.isVisible() then
        if MissionEndScreen.mousepressed(x, y, button) then return end
    end
    -- Castle Kingdoms 2027 v3.11.382: Royal Systems panel click handling
    if RoyalSystemsPanel.isVisible() then
        if RoyalSystemsPanel.mousepressed(x, y, button) then return end
    end
    -- Castle Kingdoms 2027 v3.11.903: Market Dashboard click handling
    if MarketDashboard.isVisible() then
        if MarketDashboard.mousepressed(x, y, button) then return end
    end
    -- Castle Kingdoms 2027 v3.11.918: Auto-Save Panel click handling
    if AutoSavePanel.isVisible() then
        if AutoSavePanel.mousepressed(x, y, button) then return end
    end
    -- Castle Kingdoms 2027: Minimap + GameSpeed click handling
    if S.Minimap.isVisible() then
        if S.Minimap.mousepressed(x, y, button) then return end
        if S.MinimapDrag.mousepressed(x, y, button) then return end
    end
    if S.GameSpeedControl.mousepressed(x, y, button) then return end
    -- Castle Kingdoms 2027: Right-click dismiss panels
    if S.RightClickDismiss.handleRightClick(x, y, button) then return end
    -- Castle Kingdoms 2027: Map Editor click handling
    if S.MapEditor.isActive() then
        if S.MapEditor.mousepressed(x, y, button) then return end
    end
    if _G.paused then return end
    if objects.mousepressed(x, y, button, istouch) then
        return
    end
    if _G.Commander:mousepressed(x, y, button) then
        return
    end
    if button == 2 then
        if not _G.BuildController.start then
            _G.BuildController:disable()
            local WallController = require("objects.Controllers.WallController")
            WallController.clicked = false
            if _G.BuildController.onBuildCallback then
                _G.BuildController.onBuildCallback()
                _G.BuildController.onBuildCallback = nil
            end
        end
        if not _G.BuildController.start and (loveframes.GetState() ~= states.STATE_INGAME_CONSTRUCTION or not ActionBar.hasSelectedButton) then
            if #_G.Commander.selectedUnits < 1 then
                ActionBar.lastCommand = nil
                ActionBar:switchMode()
            end
        else
            ActionBar:unselectAll()
        end
    end
    _G.BrushController:mousepressed(button)
end

function game:textinput(text)
    if S.DebugConsole.isVisible() then
        if S.DebugConsole.textinput(text) then return end
    end
    if RoyalSystemsPanel.isVisible() then
        if RoyalSystemsPanel.textinput(text) then return end
    end
    if MarketDashboard.isVisible() then
        if MarketDashboard.textinput(text) then return end
    end
    console.textinput(text)
end

function game:keypressed(key, scancode, isRepeat)
    -- Castle Kingdoms 2027: Chat input takes priority
    if S.Chat.isInputActive() then
        if S.Chat.keypressed(key) then return end
    end

    if love.keyboard.isScancodeDown("`") and love.keyboard.isScancodeDown("lshift") then
        console:toggleEnable()
        return
    end
    if console.isEnabled() then
        console.keypressed(key, scancode, isRepeat)
        return
    end

    -- Castle Kingdoms 2027: Enter = toggle chat
    if key == "return" or key == "kpenter" then
        S.Chat.keypressed(key)
        return
    end
    -- Castle Kingdoms 2027: Game speed control (Space, 1-4)
    if S.GameSpeedControl.keypressed(key) then return end
    -- Castle Kingdoms 2027: Building hotkeys (Ctrl+1-9)
    if (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        if S.BuildingHotkeys.handleKey(key, true) then return end
    end
    -- Castle Kingdoms 2027: Toggle resource flow (Ctrl+Y)
    if key == "y" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        S.ResourceFlow.toggle()
        ModernUI.notifyInfo("Tok surovin: " .. (S.ResourceFlow.isVisible() and "ON" or "OFF"))
        return
    end
    -- Castle Kingdoms 2027: Spectator mode (Ctrl+Shift+S)
    if key == "s" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        if S.SpectatorMode.isSpectating() then
            S.SpectatorMode.exit()
            ModernUI.notifyInfo("Opsazevalni nacin izklopljen")
        else
            S.SpectatorMode.enter(1)
        end
        return
    end
    -- Castle Kingdoms 2027: Co-op campaign (Ctrl+Shift+C)
    if key == "c" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        S.CoopCampaign.start("mission1")
        ModernUI.notifySuccess("Kooperativna kampanja zaceta!")
        return
    end
    -- Castle Kingdoms 2027: Cycle map size (Ctrl+Shift+M)
    if key == "m" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        local next = S.MapSizeSelector.cycle()
        local info = S.MapSizeSelector.getInfo()
        ModernUI.notifyInfo("Velikost mape: " .. info.name .. " (" .. info.tiles .. " tiles)")
        return
    end
    -- Castle Kingdoms 2027: Skirmish trail (Ctrl+Shift+T = start next unlocked)
    if key == "t" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        local missions = S.SkirmishTrail.getAllMissions()
        for _, m in ipairs(missions) do
            if m.unlocked and not m.completed then
                S.SkirmishTrail.start(m.id)
                ModernUI.notifySuccess("Skirmish: " .. m.name)
                return
            end
        end
        ModernUI.notifyInfo("Vse skirmish misije končane!")
        return
    end
    -- Castle Kingdoms 2027: Building queue toggle (Ctrl+Shift+Q = clear queue)
    if key == "q" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        S.BuildingQueue.clear()
        ModernUI.notifyInfo("Vrsta gradnje pociscena")
        return
    end
    -- Castle Kingdoms 2027: Toggle auto-worker assignment (Ctrl+Shift+W)
    if key == "w" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        local newState = not S.AutoWorker.isEnabled()
        S.AutoWorker.setEnabled(newState)
        ModernUI.notifyInfo("Samodejna delavci: " .. (newState and "ON" or "OFF"))
        return
    end
    -- Castle Kingdoms 2027: Bug report (Ctrl+Shift+B)
    if key == "b" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        S.CommunityToolkit.submitBugReport()
        return
    end
    -- Castle Kingdoms 2027: Open Discord (Ctrl+Shift+D)
    if key == "d" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        S.CommunityToolkit.openDiscord()
        ModernUI.notifyInfo("Odpiranje Discord...")
        return
    end
    -- Castle Kingdoms 2027: Check for updates (Ctrl+Shift+U)
    if key == "u" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        if S.AutoUpdater.isUpdateAvailable() then
            ModernUI.notifySuccess("Nova verzija: " .. tostring(S.AutoUpdater.getLatestVersion()))
            S.AutoUpdater.openReleasesPage()
        else
            ModernUI.notifyInfo("Posodobljeni ste (v" .. S.AutoUpdater.getCurrentVersion() .. ")")
        end
        return
    end
    -- Handle spectator mode keys
    if S.SpectatorMode.isSpectating() then
        if S.SpectatorMode.keypressed(key) then return end
    end
    ActionBar:keypressed(key, scancode)

    local event = keybindManager:getEventForKeypress(key)

    -- F8 combat test removed (use debug console). F8 = refresh lights (see below)
    -- Ctrl+Shift+F9 = Print combat stats (moved from F9)
    if key == "f9" and love.keyboard.isDown("lshift") then
        if CombatIntegration.isInitialized() then
            local stats = CombatIntegration.getStats()
            print("=== Combat Stats ===")
            print(string.format("Total attacks: %d", stats.totalAttacks))
            print(string.format("Total kills: %d", stats.totalKills))
            print(string.format("Total damage: %d", stats.totalDamage))
            print(string.format("Active projectiles: %d", stats.activeProjectiles))
            print(string.format("Visible health bars: %d", stats.visibleHealthBars))
            if stats.aiStats then
                print(string.format("AI units: %d", stats.aiStats.totalUnits))
            end
        end
        return
    end
    -- Ctrl+Shift+F7 = Spawn AI opponent (moved from F7 to avoid conflict)
    if key == "f7" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        if not _G.state or not _G.state.initialized then
            ModernUI.notifyError("Game not initialized")
            return
        end
        -- Find player's keep as reference
        local playerKeepX, playerKeepY = 50, 50
        if _G.state.gameObjectList then
            for _, obj in ipairs(_G.state.gameObjectList) do
                if obj.class and obj.class.name then
                    local name = obj.class.name
                    if (name == "Keep" or name == "WoodenKeep" or name == "SaxonHall")
                        and (not obj.faction or obj.faction == 1) then
                        playerKeepX, playerKeepY = obj.gx, obj.gy
                        break
                    end
                end
            end
        end
        -- Spawn AI at distance from player
        local personalities = {"aggressive", "balanced", "defensive", "economic"}
        local difficulties = {"easy", "medium", "hard"}
        local personality = personalities[math.random(#personalities)]
        local difficulty = difficulties[math.random(#difficulties)]
        local aiX = playerKeepX + math.random(30, 50)
        local aiY = playerKeepY + math.random(30, 50)
        AIIntegration.spawnAIFaction(personality, difficulty, aiX, aiY)
        ModernUI.notifySuccess(string.format("AI spawned! %s/%s at (%d, %d)",
            personality, difficulty, aiX, aiY))
        return
    end
    -- Ctrl+Shift+F10 = Print AI debug info (moved from F10)
    if key == "f10" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        AIIntegration.printDebugInfo()
        return
    end
    -- Ctrl+Shift+F11 = Print economy debug info (moved from F11)
    if key == "f11" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        print("\n=== Economy Debug Info ===")
        local marketStats = DynamicMarket.getStats()
        print(string.format("Inflation: %.3f", marketStats.inflation))
        print(string.format("Total gold in circulation: %d", marketStats.totalGold))
        print(string.format("Active events: %d", marketStats.activeEvents))
        print(string.format("Most volatile resource: %s (%.0f%%)", marketStats.mostVolatile, marketStats.maxVolatility * 100))

        local seasonInfo = SeasonalSystem.getSeasonInfo()
        print(string.format("\nSeason: %s (Year %d)", seasonInfo.nameSlv, seasonInfo.year))
        print(string.format("Time remaining: %.0fs", seasonInfo.timeRemaining))
        print(string.format("Next season: %s", SeasonalSystem.getNextSeason()))

        local eventStats = EconomicEvents.getStats()
        print(string.format("\nActive events: %d", eventStats.activeCount))
        print(string.format("History: %d events", eventStats.historyCount))

        local caravanStats = TradeCaravans.getStats()
        print(string.format("\nCaravans: %d active, %d completed", caravanStats.activeCount, caravanStats.completedCount))
        print(string.format("Success rate: %.0f%%", caravanStats.successRate * 100))
        print(string.format("Total profit: %d gold", caravanStats.totalProfit))
        print("=========================\n")
        return
    end
    -- Ctrl+Shift+F12 = Load campaign mission 1 (moved from F12 to avoid conflict)
    if key == "f12" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        local success = MissionFramework.loadMission("campaign.mission1_return_to_fernhaven")
        if success then
            MissionFramework.startMission()
            ModernUI.notifySuccess("Campaign mission loaded: Return to Fernhaven")
        else
            ModernUI.notifyError("Could not load mission")
        end
        return
    end
    -- M = Toggle dynamic market UI (Castle Kingdoms 2027)
    -- NOTE: must exclude Ctrl so Ctrl+M (screenshot) is reachable
    if key == "m" and not (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        DynamicMarketUI.toggle()
        return
    end
    -- C = Toggle caravan UI (Castle Kingdoms 2027)
    -- NOTE: must exclude Ctrl so Ctrl+C / Ctrl+Shift+C are reachable
    if key == "c" and not (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        CaravanUI.toggle()
        return
    end
    -- V = Toggle game feel settings (Castle Kingdoms 2027)
    if key == "v" and not (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        GameFeelSettings.toggle()
        return
    end
    -- Ctrl+R = Toggle Royal Systems panel (Castle Kingdoms 2027 v3.11.382)
    -- Lists all 347+ Royal Maker systems, hire makers, build workshops, queue products
    if key == "r" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        RoyalSystemsPanel.toggle()
        return
    end
    -- Ctrl+K = Toggle Market Dashboard (Castle Kingdoms 2027 v3.11.903)
    -- Browse all Royal products on the dynamic market with prices, volumes, trends
    if key == "k" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        MarketDashboard.toggle()
        return
    end
    -- Ctrl+U = Toggle Auto-Save Panel (Castle Kingdoms 2027 v3.11.918)
    -- Show auto-save status, last save stats, interval presets
    if key == "u" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        AutoSavePanel.toggle()
        return
    end
    -- Shift+U = Quick toggle auto-save on/off (Castle Kingdoms 2027 v3.11.923)
    -- No panel opened - just toggles state with notification
    if key == "u" and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift"))
                   and not (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        local AutoSaveSystem = require("objects.AutoSaveSystem")
        local stats = AutoSaveSystem.getStats()
        AutoSaveSystem.setEnabled(not stats.enabled)
        if _G.ModernUI then
            local msg = stats.enabled and "Auto-save: IZKLOPLJEN" or "Auto-save: VKLOPLJEN"
            _G.ModernUI.notifyInfo(msg, 2)
        end
        return
    end
    -- Forward keys to Royal panel if it's visible
    if RoyalSystemsPanel.isVisible() then
        if RoyalSystemsPanel.keypressed(key, scancode, isrepeat) then
            return
        end
    end
    -- Forward keys to Market Dashboard if it's visible
    if MarketDashboard.isVisible() then
        if MarketDashboard.keypressed(key, scancode, isrepeat) then
            return
        end
    end
    -- Forward keys to Auto-Save Panel if it's visible
    if AutoSavePanel.isVisible() then
        if AutoSavePanel.keypressed(key, scancode, isrepeat) then
            return
        end
    end
    -- F1 = Toggle keybind help (Castle Kingdoms 2027)
    -- NOTE: moved from H (H is the original CenterViewToKeep keybind)
    if key == "f1" then
        KeybindHelp.toggle()
        return
    end
    -- F5 = Cycle weather (Castle Kingdoms 2027)
    if key == "f5" then
        -- Castle Kingdoms 2027 v2.6.2: Added blizzard, heatwave, sandstorm
        local weathers = {"clear", "rain", "heavy_rain", "fog", "snow", "storm", "blizzard", "heatwave", "sandstorm"}
        local current = S.WeatherSystem.getCurrentWeather()
        local idx = 1
        for i, w in ipairs(weathers) do
            if w == current then idx = i; break end
        end
        local next = weathers[(idx % #weathers) + 1]
        S.WeatherSystem.setWeather(next)
        ModernUI.notifyInfo("Weather: " .. next)
        return
    end
    -- F6 = Cycle time of day (Castle Kingdoms 2027)
    if key == "f6" then
        local periods = {"dawn", "day", "dusk", "night"}
        local current = S.LightingSystem.getTimePeriod():lower()
        local idx = 1
        for i, p in ipairs(periods) do
            if p == current then idx = i; break end
        end
        local next = periods[(idx % #periods) + 1]
        S.LightingSystem.setTimePeriod(next)
        ModernUI.notifyInfo("Time: " .. next .. " (" .. S.LightingSystem.getTimeString() .. ")")
        return
    end
    -- F7 = Toggle HD render pipeline (Castle Kingdoms 2027)
    if key == "f7" then
        local newState = not S.HDRenderPipeline.isEnabled()
        S.HDRenderPipeline.setEnabled(newState)
        ModernUI.notifyInfo("HD Pipeline: " .. (newState and "ON" or "OFF"))
        return
    end
    -- F8 = Force refresh light sources (Castle Kingdoms 2027)
    if key == "f8" then
        S.HDRenderPipeline.autoDetectLights()
        local info = S.HDRenderPipeline.getInfo()
        ModernUI.notifyInfo("Lights refreshed: " .. info.lightCount .. " active")
        return
    end
    -- F9 = Toggle diplomacy & trade panel (Castle Kingdoms 2027)
    if key == "f9" then
        S.DiplomacyPanel.toggle()
        return
    end
    -- F10 = Run mission test suite (Castle Kingdoms 2027)
    if key == "f10" then
        local results = S.MissionTestSuite.runAll()
        S.MissionTestSuite.printResults(results)
        ModernUI.notifyInfo(string.format("Mission tests: %d/%d passed", results.passed, results.total))
        return
    end
    -- F11 = Write crash log + mod/Steam info (Castle Kingdoms 2027)
    if key == "f11" then
        S.CrashHandler.writeLog()
        local summary = S.CrashHandler.getSummary()
        local modStats = S.ModLoader.getStats()
        local steamInfo = S.SteamWorks.getInfo()
        ModernUI.notifyInfo(string.format("Crash: %d errs | Mods: %d/%d loaded | Achievements: %d/%d",
            summary.totalErrors, modStats.loaded, modStats.total,
            steamInfo.achievementsUnlocked, steamInfo.totalAchievements))
        return
    end
    -- F4 = Toggle Map Editor (Castle Kingdoms 2027)
    -- NOTE: moved from F12 (F12 is the standard screenshot key, now handled via EVENT.Screenshot)
    if key == "f4" then
        S.MapEditor.toggle()
        return
    end
    -- F3 = Toggle performance overlay (Castle Kingdoms 2027)
    if key == "f3" then
        PerformanceOverlay.toggle()
        return
    end
    -- Ctrl+T = Toggle tutorial (Castle Kingdoms 2027)
    if key == "t" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and not love.keyboard.isDown("lshift") and not love.keyboard.isDown("rshift") then
        if S.TutorialSystem.isActive() then
            S.TutorialSystem.stop()
            ModernUI.notifyInfo("Tutorial stopped")
        else
            S.TutorialSystem.start()
            ModernUI.notifyInfo("Tutorial started")
        end
        return
    end
    -- Ctrl+O = Toggle unified settings (Castle Kingdoms 2027)
    if key == "o" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        S.UnifiedSettings.toggle()
        return
    end
    -- Ctrl+B = Spawn catapult for testing (Castle Kingdoms 2027)
    if key == "b" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and not love.keyboard.isDown("lshift") and not love.keyboard.isDown("rshift") then
        if _G.state and _G.state.keepX then
            S.SiegeWeapons.create("catapult", _G.state.keepX + 5, _G.state.keepY + 5, 1)
            ModernUI.notifySuccess("Catapult created near keep")
        end
        return
    end
    -- Ctrl+L = Run release checklist (Castle Kingdoms 2027)
    if key == "l" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and not love.keyboard.isDown("lshift") and not love.keyboard.isDown("rshift") then
        local results = S.ReleaseChecklist.runAll()
        S.ReleaseChecklist.printResults()
        ModernUI.notifyInfo(string.format("Release checklist: %d/%d passed", results.passed, results.total))
        return
    end
    -- Ctrl+I = Run integration test suite (Castle Kingdoms 2027)
    if key == "i" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        local results = S.IntegrationTestSuite.runAll()
        S.IntegrationTestSuite.printResults()
        ModernUI.notifyInfo(string.format("Integration tests: %d/%d passed", results.passed, results.total))
        return
    end
    -- Ctrl+P = Run performance benchmark (Castle Kingdoms 2027)
    if key == "p" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        if S.PerfBenchmark.isRunning() then
            ModernUI.notifyInfo("Benchmark already running...")
        else
            S.PerfBenchmark.start()
            ModernUI.notifyInfo("Benchmark started (30s)")
        end
        return
    end
    -- Ctrl+N = Generate release notes (Castle Kingdoms 2027)
    if key == "n" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        local filename = S.ReleaseNotesGen.save("1.21.0")
        ModernUI.notifyInfo("Release notes saved: " .. tostring(filename))
        return
    end
    -- Ctrl+A = Toggle achievement gallery (Castle Kingdoms 2027)
    if key == "a" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        S.AchievementGallery.toggle()
        return
    end
    -- Ctrl+W = Cycle weather gameplay (Castle Kingdoms 2027)
    if key == "w" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and not love.keyboard.isDown("lshift") and not love.keyboard.isDown("rshift") then
        local newWeather = S.WeatherGameplay.cycleWeather()
        local mods = S.WeatherGameplay.getModifiers()
        ModernUI.notifyInfo("Vreme: " .. mods.name .. " (farm x" .. mods.farmMult .. ", speed x" .. mods.speedMult .. ")")
        return
    end
    -- Ctrl+F = Start tournament festival (Castle Kingdoms 2027)
    if key == "f" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        if S.FestivalSystem.start("tournament") then
            ModernUI.notifySuccess("Turnir zacel! (+10 popularnost)")
        else
            ModernUI.notifyError("Ni dovolj zlata za turnir (200)")
        end
        return
    end
    -- Ctrl+Shift+V = Reveal all fog (debug, Castle Kingdoms 2027)
    if key == "v" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        S.FogOfWar.revealAll()
        ModernUI.notifyInfo("Megla razkrita (debug)")
        return
    end
    -- Ctrl+G = Cycle formation (Castle Kingdoms 2027)
    if key == "g" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        local next = S.FormationSystem.cycleFormation()
        local info = S.FormationSystem.getStats()
        ModernUI.notifyInfo("Formacija: " .. info.name .. " (def x" .. info.defenseBonus .. ", atk x" .. info.attackBonus .. ")")
        return
    end
    -- Ctrl+E = Show credits (Castle Kingdoms 2027)
    if key == "e" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        S.CreditsScreen.show()
        return
    end
    -- Ctrl+D = Cycle difficulty (Castle Kingdoms 2027)
    if key == "d" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and not love.keyboard.isDown("lshift") and not love.keyboard.isDown("rshift") then
        local next = S.DifficultyPresets.cycle()
        local info = S.DifficultyPresets.getCurrentInfo()
        ModernUI.notifyInfo("Tezavnost: " .. info.name .. " - " .. info.description)
        return
    end
    -- Ctrl+M = Capture screenshot (Castle Kingdoms 2027)
    if key == "m" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and not love.keyboard.isDown("lshift") and not love.keyboard.isDown("rshift") then
        local file = S.ScreenshotManager.capture("manual")
        ModernUI.notifySuccess("Screenshot shranjen: " .. tostring(file))
        return
    end
    -- Ctrl+Shift+L = Final release prep (Castle Kingdoms 2027)
    if key == "l" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        S.FinalReleasePrep.printResults()
        local results = S.FinalReleasePrep.runAll()
        ModernUI.notifyInfo(string.format("Release prep: %d/%d passed", results.passed, results.total))
        return
    end
    -- Castle Kingdoms 2027 v2.5.0: Ctrl+Shift+X = Run stability test suite
    if key == "x" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        local results = S.StabilityTests.runAll()
        S.StabilityTests.printResults()
        ModernUI.notifyInfo(string.format("Stability tests: %d/%d passed", results.passed, results.total))
        return
    end
    -- Castle Kingdoms 2027 v2.6.3: Ctrl+Shift+H = Show daily challenges
    if key == "h" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        local challenges = S.DailyChallenge.getChallenges()
        local stats = S.DailyChallenge.getStats()
        ModernUI.notifyInfo(string.format("Dnevni izzivi: %d/%d končani (%s)",
            stats.completed, stats.total, stats.date or "danes"))
        for _, c in ipairs(challenges) do
            local status = c.completed and "[OK]" or string.format("[%d/%d]", c.progress, c.target)
            ModernUI.notifyInfo(status .. " " .. c.description)
        end
        return
    end
    -- Castle Kingdoms 2027 v2.6.4: Ctrl+Shift+Y = Show technology tree
    if key == "y" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        local stats = S.TechnologyTree.getStats()
        local current = S.TechnologyTree.getCurrentResearch()
        ModernUI.notifyInfo(string.format("Tehnologije: %d/%d raziskanih", stats.researched, stats.totalTechs))
        if current then
            ModernUI.notifyInfo(string.format("Raziskujem: %s (%.0f%%)", current.name, current.percent))
        end
        -- Show first 3 available techs
        local techs = S.TechnologyTree.getAllTechs()
        local shown = 0
        for _, t in ipairs(techs) do
            if shown >= 3 then break end
            if not t.researched and t.canResearch then
                ModernUI.notifyInfo(string.format("[Dostopno] %s (%dg)", t.name, t.cost.gold or 0))
                shown = shown + 1
            end
        end
        return
    end
    -- Castle Kingdoms 2027 v2.6.5: Ctrl+Shift+P = Show population & happiness
    if key == "p" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") then
        local stats = S.PopulationSystem.getStats()
        ModernUI.notifyInfo(string.format("Populacija: %d/%d | Sreca: %d/100 | Rast: %.1f",
            stats.population, stats.maxPopulation, stats.happiness, stats.growthRate))
        local breakdown = S.PopulationSystem.getHappinessBreakdown()
        for _, mod in ipairs(breakdown.modifiers) do
            local sign = mod.value >= 0 and "+" or ""
            ModernUI.notifyInfo(string.format("  %s: %s%d (%s)", mod.category, sign, mod.value, mod.description))
        end
        return
    end
    -- Handle credits ESC
    if S.CreditsScreen.isActive() then
        if S.CreditsScreen.keypressed(key) then return end
    end
    -- Tilde (~) = Toggle debug console (Castle Kingdoms 2027)
    if key == "`" or key == "~" then
        S.DebugConsole.toggle()
        return
    end
    -- Handle debug console input
    if S.DebugConsole.isVisible() then
        if S.DebugConsole.keypressed(key) then return end
    end
    -- Handle story dialogue input
    if S.CampaignStory.isActive() then
        if S.CampaignStory.keypressed(key) then return end
    end
    -- Castle Kingdoms 2027: Handle Map Editor input
    if S.MapEditor.isActive() then
        if S.MapEditor.keypressed(key) then return end
    end
    -- Ctrl+R = Toggle replay recording (Castle Kingdoms 2027)
    if key == "r" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        if S.ReplaySystem.isRecording() then
            S.ReplaySystem.stopRecording()
            ModernUI.notifySuccess("Replay saved!")
        else
            S.ReplaySystem.startRecording()
            ModernUI.notifyInfo("Replay recording started")
        end
        return
    end
    -- Ctrl+S = Print statistics (Castle Kingdoms 2027)
    -- NOTE: excludes Shift so Ctrl+Shift+S (spectator mode) is reachable
    if key == "s" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
        and not (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
        -- Don't interfere with map editor save
        if not S.MapEditor.isActive() then
            S.StatisticsDashboard.printSummary()
            S.StatisticsDashboard.save()
            ModernUI.notifyInfo("Statistics saved (check console)")
            return
        end
    end

    if event == EVENT.Screenshot then
        -- Screenshot (F12) — use ScreenshotManager for organized storage
        local filename = S.ScreenshotManager.capture("f12")
        ModernUI.notifySuccess("Screenshot: " .. tostring(filename))
    elseif event == EVENT.IncreaseGameSpeed then
        if _G.speedModifier == 0.5 then
            _G.speedModifier = _G.speedModifier + 0.5
        elseif _G.speedModifier < 10 then
            _G.speedModifier = _G.speedModifier + 1
        end
    elseif event == EVENT.NormalizeGameSpeed then
        _G.speedModifier = 1
    elseif event == EVENT.DecreaseGameSpeed then
        if _G.speedModifier <= 1 then
            _G.speedModifier = _G.speedModifier - 0.5
        else
            _G.speedModifier = _G.speedModifier - 1
        end
        if _G.speedModifier < 0.5 then
            _G.speedModifier = 0.5
        end
    elseif event == EVENT.Escape then
        if _G.BuildController.start then
            if loveframes.GetState() ~= states.STATE_PAUSE_MENU then
                loveframes.SetState(states.STATE_PAUSE_MENU)
                loveframes.TogglePause()
                ActionBar:showGroup("start")
                return
            end
            if loveframes.GetState() == states.STATE_INGAME_CONSTRUCTION then
                loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
                loveframes.TogglePause()
                return
            end
        elseif (loveframes.GetState() == states.STATE_PAUSE_MENU or
                loveframes.GetState() == states.STATE_INGAME_CONSTRUCTION) then
            if _G.BuildController.active and not _G.BuildController.start then
                ActionBar:unselectAll()
                _G.BuildController:disable()
                return
            end
            if _G.DestructionController.active then
                -- unselect the demolish button
                ActionBar:unselectAll()
                _G.DestructionController:disable()
                return
            end
            if ActionBar.currentGroup ~= "main" then
                if not _G.BuildController.start then
                    ActionBar:showGroup("main")
                end
                return
            end
        elseif (loveframes.GetState() == states.STATE_MARKET or
                loveframes.GetState() == states.STATE_STOCKPILE or
                loveframes.GetState() == states.STATE_GRANARY or
                loveframes.GetState() == states.STATE_MARKET_MAIN or
                loveframes.GetState() == states.STATE_KEEP_TAX or
                loveframes.GetState() == states.STATE_ARMOURY or
                loveframes.GetState() == states.STATE_UNIT_DETAILS or
                loveframes.GetState() == states.STATE_UNITS or
                loveframes.GetState() == states.STATE_INN or
                loveframes.GetState() == states.STATE_RELIGION) then
            ActionBar:switchMode()
            return
        end
        loveframes.TogglePause()
    elseif event == EVENT.ToggleDebugView then
        _G.DebugView:toggle()
        -- Castle Kingdoms 2027: Toggle performance overlay with F3
        PerformanceOverlay.toggle()
    elseif event == EVENT.CenterViewToKeep and _G.state.keepX then
        _G.state.viewXview = _G.IsoToScreenX(_G.state.keepX, _G.state.keepY)
        _G.state.viewYview = _G.IsoToScreenY(_G.state.keepX, _G.state.keepY)
    elseif event == EVENT.CenterViewToGranary and _G.state.granaryX then
        _G.state.viewXview = _G.IsoToScreenX(_G.state.granaryX, _G.state.granaryY)
        _G.state.viewYview = _G.IsoToScreenY(_G.state.granaryX, _G.state.granaryY)
    end
end

function game:mousereleased(x, y, button, istouch)
    -- Castle Kingdoms 2027: Handle minimap drag release
    S.MinimapDrag.mousereleased(x, y, button)
    -- TODO: Check if event is consumed
    if _G.Commander:mousereleased(x, y, button) then
        return
    end
    loveframes.mousereleased(x, y, button)
    _G.BrushController:mousereleased(button)
end

function game:mousemoved(x, y, dx, dy, istouch)
    -- Castle Kingdoms 2027: Handle minimap drag scrolling
    S.MinimapDrag.mousemoved(x, y, dx, dy)
end

-- Castle Kingdoms 2027: Gamepad support
function game:gamepadpressed(joystick, button)
    S.Gamepad.handleButton(joystick, button)
end

function game:gamepadaxis(joystick, axis, value)
    S.Gamepad.handleAxis(joystick, axis, value)
end

function game:gamepadconnected(joystick)
    S.Gamepad.setConnected(true)
    if ModernUI then
        ModernUI.notifySuccess("Krmilnik prikljucen: " .. joystick:getName())
    end
end

function game:gamepaddisconnected(joystick)
    S.Gamepad.setConnected(false)
    if ModernUI then
        ModernUI.notifyInfo("Krmilnik odklopljen")
    end
end

-- Castle Kingdoms 2027: Skirmish trail access (Ctrl+Shift+T = start skirmish 1)
function game:wheelmoved(x, y)
    -- Castle Kingdoms 2027 v3.11.919: Forward wheel to Market Dashboard if expanded
    if MarketDashboard.isVisible() then
        if MarketDashboard.wheelmoved(x, y) then return end
    end
    -- Castle Kingdoms 2027 v3.11.920: Forward wheel to Royal Systems Panel for page navigation
    if RoyalSystemsPanel.isVisible() then
        if RoyalSystemsPanel.wheelmoved(x, y) then return end
    end
    if scrollCountDown == 0 then
        scrollCountDown = 0.05
        scrolledAmountWithinShortPeriod = y
    else
        scrolledAmountWithinShortPeriod = scrolledAmountWithinShortPeriod + y
    end
end

function game:keyreleased(key, scancode)
    if console.isEnabled() then
        return
    end
    -- Castle Kingdoms 2027: exclude Ctrl modifiers so Ctrl+B (catapult) doesn't toggle brush on release
    local ctrl_down = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
    -- if not _G.BuildController.start then
    if key == "b" and not ctrl_down then
        _G.BrushController:toggle()
    elseif key == "delete" then
        _G.DestructionController:toggle()
    end

    if _G.BrushController:activated() then
        _G.BrushController:keyReleased(key)
    end
    -- end
end

return game
