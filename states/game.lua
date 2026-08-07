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
