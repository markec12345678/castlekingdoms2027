# Castle Kingdoms 2027 — Systems Reference

Popoln seznam vseh sistemov v igri z njihovimi datotekami in funkcijami.

## 🎮 Core Systems

### Game Loop
| Datoteka | Funkcija |
|----------|----------|
| `states/game.lua` | Glavna igra — update, draw, input |
| `states/start_menu.lua` | Glavni meni |
| `states/splash_screen.lua` | Splash screen |
| `objects/State.lua` | Globalno stanje igre |
| `objects/objects.lua` | Upravljanje objektov |

### Controllers
| Datoteka | Funkcija |
|----------|----------|
| `objects/Controllers/BuildController.lua` | Gradnja zgradb |
| `objects/Controllers/Commander.lua` | Enote, izbira, ukazi |
| `objects/Controllers/CameraController.lua` | Kamera |
| `objects/Controllers/SaveManager.lua` | Save/load |
| `objects/Controllers/KeybindManager.lua` | Tipke |

## 🌐 Multiplayer

| Datoteka | Funkcija |
|----------|----------|
| `objects/Network/NetworkProtocol.lua` | Mrežni protokol (30+ tipov sporočil) |
| `objects/Network/GameServer.lua` | TCP/IP server (do 8 igralcev) |
| `objects/Network/GameClient.lua` | TCP/IP client |
| `objects/Network/DiplomacyController.lua` | Diplomacija (6 stanj) |
| `objects/Network/TradeController.lua` | Trgovina, darila, trade routes |
| `states/ui/multiplayer/lobby.lua` | Multiplayer lobby UI |
| `states/ui/multiplayer/chat.lua` | In-game chat |
| `states/ui/multiplayer/diplomacy_panel.lua` | Diplomacy & trade panel (F9) |

## 🎨 Graphics & Rendering

| Datoteka | Funkcija |
|----------|----------|
| `objects/Environment/HDRenderPipeline.lua` | HD render manager |
| `objects/Environment/LightingSystem.lua` | Day/night cycle, dynamic lighting |
| `objects/Environment/NormalMapGenerator.lua` | Normal maps iz heightmap |
| `shaders/HD_SHADERS.lua` | HD shader manager |
| `shaders/normal_mapping.glsl` | Terrain normal mapping |
| `shaders/point_lights.glsl` | Dynamic point lights (32 max) |
| `shaders/ssao.glsl` | Screen-space ambient occlusion |
| `shaders/tonemap.glsl` | ACES filmic tone mapping |
| `shaders/bloom.glsl` | Bloom effect |
| `shaders/dynamic_lighting.glsl` | Day/night color shift |
| `shaders/vignette.glsl` | Vignette effect |
| `shaders/color_grading.glsl` | Color grading |

## 🔊 Audio

| Datoteka | Funkcija |
|----------|----------|
| `objects/Audio/AudioMixSystem.lua` | 5 kategorij glasnosti, 3D audio |
| `objects/Audio/DynamicMusicManager.lua` | 5 stanj glasbe (menu/peace/combat/victory/defeat) |
| `objects/Audio/SFXLibrary.lua` | 4 kategorije SFX |
| `objects/Audio/SlovenianVoiceOver.lua` | 30+ slovenskih notifikacij |
| `sounds/music_playlist.lua` | Playlist manager |

## 🤖 AI

| Datoteka | Funkcija |
|----------|----------|
| `objects/AI/AIIntegration.lua` | AI integration |
| `objects/AI/AIStrategyController.lua` | 4 osebnosti × 4 težavnosti |
| `objects/AI/AIEnhancements.lua` | Smart building, defense response |
| `objects/AI/AICommander.lua` | AI military commands |
| `objects/AI/EconomyAI.lua` | AI economy |

## ⚔️ Combat

| Datoteka | Funkcija |
|----------|----------|
| `objects/Combat/CombatIntegration.lua` | Combat system init |
| `objects/Combat/CombatComponent.lua` | Health, armor, damage mixin |
| `objects/Combat/SiegeWeaponsSystem.lua` | 4 siege weapon types |
| `objects/Controllers/CombatController.lua` | Combat controller |
| `objects/Controllers/ProjectileController.lua` | Projectiles |

## 📊 Economy

| Datoteka | Funkcija |
|----------|----------|
| `objects/Economy/DynamicMarketSystem.lua` | Supply/demand, inflation |
| `objects/Economy/SeasonalSystem.lua` | Sezonski modifikatorji |
| `objects/Economy/EconomicEventsSystem.lua` | Random events |
| `objects/Economy/TradeCaravanSystem.lua` | AI trade caravans |
| `objects/Controllers/StockpileController.lua` | Surovine |
| `objects/Controllers/TaxController.lua` | Davki |
| `objects/Controllers/FoodController.lua` | Hrana |

## 🌍 Localization & Accessibility

| Datoteka | Funkcija |
|----------|----------|
| `objects/Config/LocalizationSystem.lua` | 32 jezikov, runtime preklop |
| `objects/Config/AccessibilitySystem.lua` | Colorblind, font scaling, reduced motion |
| `locale/*.yaml` | 32 jezikovnih datotek |

## 🛠️ Tools & QA

| Datoteka | Funkcija |
|----------|----------|
| `objects/QA/MissionTestSuite.lua` | Testi za 10 misij (F10) |
| `objects/QA/CrashHandler.lua` | Error recovery (F11) |
| `objects/QA/PerformanceWatchdog.lua` | Auto quality adjustment |
| `objects/QA/ReplaySystem.lua` | Snemanje/predvajanje (Ctrl+R) |
| `objects/QA/StatisticsDashboard.lua` | Statistike (Ctrl+S) |
| `objects/QA/MapEditor.lua` | Map editor (F12) |
| `objects/QA/FinalBugFixPass.lua` | Nil-safety wrapperji |
| `objects/QA/ReleaseChecklist.lua` | 20 pre-release checks (Ctrl+L) |
| `objects/QA/SaveGameCompatibility.lua` | Versioned saves |
| `objects/QA/DebugConsoleSystem.lua` | Debug console (Tilde ~) |
| `objects/QA/CommunityFeedbackSystem.lua` | Bug reports, suggestions |
| `objects/Performance/PerformanceOptimizer.lua` | Frustum culling, LOD |

## 🔌 Modding & Steam

| Datoteka | Funkcija |
|----------|----------|
| `objects/Modding/ModLoader.lua` | Mod loader (scan /mods) |
| `objects/Modding/CustomBuildingLoader.lua` | Custom building registration |
| `objects/Steam/SteamWorks.lua` | 10 achievements, stats |
| `objects/Steam/AchievementIntegration.lua` | Event → achievement hooks |
| `mods/sample_mod/` | Sample mod (GoldMine) |

## 📚 Tutorial & Story

| Datoteka | Funkcija |
|----------|----------|
| `objects/Tutorial/TutorialSystem.lua` | 10-korak tutorial (Ctrl+T) |
| `objects/Mission/MissionFramework.lua` | Mission manager |
| `objects/Mission/CampaignProgress.lua` | Campaign progression |
| `objects/Mission/CampaignStorySystem.lua` | Cutscene dialogi |
| `saves/Missions/campaign/` | 10 misij |

## ⚙️ Config

| Datoteka | Funkcija |
|----------|----------|
| `objects/Config/BalanceConfig.lua` | Centralizirane vrednosti |
| `objects/Config/ConfigProfileSystem.lua` | 5 grafičnih profilov |
| `objects/Config/SettingsPersistence.lua` | Save/load settings |
| `objects/Config/KenneyAssetLoader.lua` | CC0 asset loading |
| `objects/Config/KenneySpriteRenderer.lua` | CC0 sprite rendering |

## 🎨 Feedback & UI

| Datoteka | Funkcija |
|----------|----------|
| `objects/Feedback/GameFeelSystem.lua` | Screen shake, hit flash |
| `objects/Feedback/BuildPreviewSystem.lua` | Ghost building preview |
| `objects/Feedback/SelectionFeedbackSystem.lua` | Selection rings |
| `objects/Feedback/CombatOrderVisualizer.lua` | Combat order lines |
| `objects/UI/ModernUISystem.lua` | Notifications |
| `states/ui/settings/unified_settings.lua` | Unified settings (Ctrl+O) |

## 🌦️ Environment

| Datoteka | Funkcija |
|----------|----------|
| `objects/Weather/WeatherSystem.lua` | Rain, snow, fog |
| `objects/Animation/AnimationSystem.lua` | Animation manager |
| `objects/Environment/BirchTree.lua` | Trees |
| `objects/Environment/Rock_2x2.lua` | Rocks |

---

**Skupno**: 80+ Lua modulov, 6 GLSL shaderjev, 32 jezikov
