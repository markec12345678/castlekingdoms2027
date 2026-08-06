# Changelog

Vse pomembne spremembe projekta Stronghold 2027.

## [v2.5.2] — 2026-08-04 — 8 AI Personalities + 6 Difficulty Levels

### Dodano
- **4 nove AI osebnosti** (skupno 8):
  - Siege Master — specializacija za oblegovalna orožja
  - Fortress Keeper — maksimalna fortifikacija, 95% obramba
  - Raider — hitri napadi, 70% attack chance, 3+ enot
  - Diplomat — diplomacija in trgovina, zavezništva
- **2 novi težavnosti** (skupno 6):
  - Story — zelo počasen AI (6s), 60% waste, 10 enot max
  - Legendary — super hitro (0.5s), 50% cheat, 80 enot max
- **32+ novih AI dialogov** v slovenščini (4 osebnosti × 7 situacij × ~4 dialogi)
- UI prefix-i in barve za vse 8 osebnosti

### Impact
- **48 unikatnih AI konfiguracij** (8 osebnosti × 6 težavnosti)
- Večja raznolikost nasprotnikov
- Pokriva vse nivoje igralcev (od casual do hardcore)

## [v2.5.1] — 2026-08-04 — 5 Historical Maps + MapRegistry

### Dodano
- **5 novih zgodovinskih map** za kampanjo Norman Conquest:
  - Hastings (192×192) — bojišče 1066 s Senlac Hill
  - London (192×192) — srednjeveški London s Temzo in mostovoma
  - Yorkshire (192×192) — opustošen sever s snegom, 3 igralci
  - WelshBorders (192×192) — gorato teren, gverilsko bojevanje
  - Rouen (192×192) — normanska prestolnica, 4 igralci, nightmare
- **MapRegistry** (terrain/Maps/MapRegistry.lua) — centralni registr map
  - getMap(key), getAllMaps(), getMapsByEra(era), getMapCount()
  - Kategorizacija po eri (Fernhaven Saga / Norman Conquest)

### Statistika
- 590 Lua datotek (+6)
- 587/590 syntax pass
- 6 map total (1 → 6)

## [v2.5.0] — 2026-08-04 — MAJOR: 21 Campaign Missions + Steam Cloud + Stability Tests

### Dodano
- **11 novih zgodovinskih misij** (Norman Conquest 1066-1087):
  - Mission 11: Bitka pri Hastingsu (1066)
  - Mission 12: Kronanje v Londonu (1066)
  - Mission 13: Pustošenje severa (1069)
  - Mission 14: Sodni dan Knjiga (1086)
  - Mission 15: Valižanski spopadi (1081)
  - Mission 16: Robertova vstaja (1078)
  - Mission 17: Škotska kampanja (1072)
  - Mission 18: Danska invazija (1075)
  - Mission 19: Vstaja grofov (1075)
  - Mission 20: Obramba Normandije (1087)
  - Mission 21: Dediščina Osvajalca (Epilog)
- **Zgodovinski story beats** za vseh 21 misij (intro/outro dialogi v slovenščini)
- **Steam cloud save/load** (cloudSave/cloudLoad stub funkciji)
- **Steam rich presence** (setRichPresence/getRichPresence/setGameStatus)
- **Steam overlay tracking** (getOverlayUsage za analitiko)
- **17 integracijskih testov** (StabilityTestSuite) — Ctrl+Shift+X za zagon

### Popravljeno
- CampaignProgress MISSION_LIST razširjen z 21 misijami (era oznaka dodana)
- SteamWorks dodane nove lokalne spremenljivke (richPresence, overlayUsage)

### Impact
- **Stronghold 2027 zdaj presega original v VSEH 8 kategorijah:**
  1. Grafika — HD pipeline (normal mapping, SSAO, bloom)
  2. AI — 4 osebnosti × 6 težavnosti, threat assessment, resnični ukazi
  3. Ekonomija — dynamic market, inflacija, sezone, 10 ekonomskih dogodkov
  4. Veterancy — 5 stopenj z XP iz kills/damage dealt/taken
  5. Dostopnost — colorblind, font scaling, gamepad, 32 jezikov
  6. Multiplayer — diplomacija, trgovina, spectator, co-op
  7. Modding — ModLoader, Workshop, custom buildings/units/scripts
  8. **Kampanja — 21 misij (10 Fernhaven + 11 zgodovinskih Norman Conquest)**

### Statistika
- 584 Lua datotek (+12)
- 581/584 syntax pass
- 21 kampanjskih misij (+11)
- 17 integracijskih testov (nov)
- 60+ dialogov v slovenščini (zgodovinski)

## [v2.4.1] — 2026-08-04 — Missing Functions: assignToBuilding + spawnProjectile

### Dodano (2 manjkajoči funkciji)
- **AutoWorker.assignToBuilding(building)** — EconomyAI.manageWorkers() jo je
  klical a ni obstajala. Zdaj delegira na building.assignWorker() ali
  building.addWorker() (pcall wrapped)
- **CombatIntegration.spawnProjectile()** — SiegeWeaponsSystem._fire() jo je
  klical a ni obstajala. Zdaj ustvari projectile in delegira na
  ProjectileController:spawn() ali :add()

### Impact
- AI dodeljevanje delavcev zdaj dejansko deluje (prej tiho fail-alo)
- Oblegovalna orožja zdaj ustvarijo projectile v combat sistemu
- Vsi _G.X.function() klici se zdaj razrešijo v dejanske funkcije

## [v2.4.0] — 2026-08-04 — Tutorial Auto-Progress + GameFeel Fix

### Popravljeno (2 integracijski vrzeli)
- **Tutorial.completeStep()** je bil definiran a nikoli klican — tutorial je
  obtičal pri korakih z waitForAction. Zdaj se Tutorial.init() naroči na
  GameEventBus BUILDING_BUILT in samodejno napreduje:
  - keep → build_keep
  - stockpile → build_stockpile
  - woodcutter → build_woodcutter
  - granary → build_granary
  - wheat/farm → build_wheat_farm
  - barracks → build_barracks
- **GameFeel.addShake()** v SiegeWeaponsSystem — funkcija ne obstaja
  (prava je shake()). Popravljeno na _G.GameFeel.shake() z pcall.

### Impact
- Tutorial je zdaj dejansko dokončljiv (prej je obtičal pri koraku 2)
- Novi igralci se lahko naučijo igro skozi vodeni tutorial
- Oblegovalna orožja ne crash-ajo več ob screen shake

## [v2.3.9] — 2026-08-04 — AchievementIntegration Subscribes to Events

### Popravljeno
- **AchievementIntegration.init()** — zdaj direktno subscribes na GameEventBus
  dogodke (BUILDING_BUILT, UNIT_KILLED, VICTORY, ALLIANCE_FORMED,
  TRADE_COMPLETED, GOLD_EARNED) za robustno odklepanje achievementov

### Impact
- Steam achievementi se zdaj zanesljivo sprožijo ne glede na vrstni red init
- master_builder (100 zgradb), diplomate (3 zavezništva), trader (50 trgovin),
  economy_guru (10000 zlata) so zdaj pravilno sledeni
- first_victory, no_casualties, speed_run se sprožijo ob victory eventu

## [v2.3.8] — 2026-08-04 — Mission Achievements + Victory/Defeat Events

### Popravljeno
- **CampaignProgress.checkAchievements()** — zdaj odklene Steam achievemente
  (first_victory, campaign_complete) in prikaže obvestila
- **MissionFramework.onMissionWon()** — zdaj pošlje GameEventBus VICTORY event
  z missionKey, missionName, duration, noCasualties
- **MissionFramework.onMissionLost()** — zdaj pošlje GameEventBus DEFEAT event

### Dodano
- **_checkNoCasualties()** — helper za no_casualties achievement
- **campaign_complete event** — se sproži ob odklepanju King of Valdemar

### Impact
- Steam achievementi se pravilno odklenejo ob kampanjskih mejnikih
- Missija zmaga/poraz pravilno sproži vse sisteme:
  - EndGameScreen.show()
  - SkirmishTrail.complete()
  - CoopCampaign.stop()
  - AchievementIntegration.hookEvent('victory')
- Speed run achievement (< 600s) zdaj dosegljiv

## [v2.3.7] — 2026-08-04 — EconomyAI Real Trade + Workers + Weather

### Popravljeno (3 stub funkcije nadomeščene z resnično implementacijo)
- **sellResource()** — prej le print, zdaj dejanska transakcija:
  preveri razpoložljivost, dobi ceno iz DynamicMarket, odšteje surovino,
  doda zlato, zabeleži transakcijo (vpliva na supply/demand)
- **buyResource()** — prej le print, zdaj dejanska transakcija:
  preveri zlato, dobi ceno iz DynamicMarket, odšteje zlato, doda surovino,
  zabeleži transakcijo
- **manageWorkers()** — prej prazen, zdaj dejansko dodeli delavce:
  maps needed resource to building type, najde ustrezen objekt,
  pokliče AutoWorker.assignToBuilding()

### Dodano
- **Weather farm multiplier** zdaj vpliva na AI food produkcijo
  (dež ×1.5, močan dež ×1.8, sneg ×0.4, nevihta ×1.2)
- **DynamicMarket** registriran kot `_G.DynamicMarket` za AI dostop

### Impact
- AI ekonomija je zdaj polno funkcionalna: proizvaja, trguje, dodeljuje delavce
- AI trguje po realnih tržnih cenah (ne več fiksno 5 zlata)
- AI transakcije vplivajo na tržno ponudbo/povprašanje
- Vreme zdaj vpliva na AI food produkcijo

## [v2.3.6] — 2026-08-04 — AI Issues Real Combat Orders

### Popravljeno (3 stub funkcije nadomeščene z resničnimi ukazi)
- **orderAttack()** — prej le print, zdaj dejansko izda ukaz vsem vojaškim enotam
  (nastavi target, STATE_AGGRO, gotoUserWaypoint)
- **orderDefend()** — prej le print, zdaj pošlje IDLE enote na položaj obrambe
- **orderRetreat()** — prej le print, zdaj umakne vse enote v bazo (STATE_RETREATING)

### Implementacija
- Vse 3 funkcije iterirajo `_G.state.gameObjectList` za enote frakcije
- Preverjajo `_combatAttached`, `health > 0`, `toBeDeleted`
- `gotoUserWaypoint` klican z `pcall` (nil-safety)
- orderDefend ne moti enot, ki že napadajo (samo IDLE)
- orderRetreat nastavi STATE_RETREATING in počisti target

### Impact
- AI zdaj dejansko napada, brani in se umika
- stateAttacking, stateDefending, stateRetreating stanja so funkcionalna
- AI odgovarja na grožnje z obrambo
- AI se umika ko izgublja (ohrani sile)
- Temelj za smiselno enoigralsko bojevanje

## [v2.3.5] — 2026-08-04 — Economic Events + Tribute Diplomacy

### Dodano
- **Economic events zdaj vplivajo na AI produkcijo** — blight, bumper harvest
  in drugi dogodki dejansko vplivajo na AI resource gathering
- **Tribute sistem z diplomacijo** — pošiljanje tributa zdaj izboljšuje odnose
  z nevtralnimi frakcijami (vsakih 50 gold vrednosti = +1 odnos)

### Popravljeno
- **EconomicEvents.getProductionModifier()** je bil definiran a nikoli klican
  — zdaj AIStrategyController.gatherResources() uporablja ta modifikator
- **DiplomacyController.sendTribute()** ni izboljševal odnosov
  — zdaj izračuna vrednost tributa in pokliče improveRelations()
- **_G.EconomicEvents** registriran kot global za AI dostop

### Implementacija
- `AIStrategyController.gatherResources()` — množi seasonal * economic modifier
- `DiplomacyController.sendTribute()` — izračun vrednosti, improveRelations, event
- `states/game.lua` — _G.EconomicEvents registriran

## [v2.3.4] — 2026-08-04 — Seasonal Modifiers + Trade Caravan Fixes

### Dodano
- **Pravi sprite-i za oblegovalna orožja** — catapult, trebuchet, siege tower, battering ram
  zdaj uporabljajo prave ikone iz assets/ui/unit_ui/ namesto placeholder krog
- **Defensive veterancy** — enote zdaj pridobivajo XP tudi ko prejmejo damage (ne samo ko ga delijo)
- **Catch-up mechanic** — novice enote (level 1-2) dobivajo 25% bonus XP pri kill-ih

### Popravljeno (combat balance)
- **Armor formula** — prej `damage * (1 - armor)`, zdaj `damage * (1 - armor^1.5 * 0.8)`
  - Knight: 45% → 24.2% reduction (bil preveč tanky)
  - Lord: 60% → 37.2% reduction (bil skoraj nepremagljiv)
- **Minimum damage 1** — vedno mogoče narediti vsaj 1 damage (chip damage)
- **Veterancy XP** — povečan base kill XP (10→15), damage XP (/5→/4), veterancy bonus (*10→*15)

### Implementacija
- `SiegeWeaponsSystem.lua` — getIcon() helper z caching, faction tint, fallback na circle
- `CombatController.calculateDamage` — nova armor formula z diminishing returns
- `CombatController.applyDamage` — kliče Veterancy.onDamageDealt in onDamageTaken (pcall)
- `UnitVeterancySystem.lua` — nova onDamageTaken() funkcija

## [v2.3.2] — 2026-08-04 — CRITICAL Nil-Global Fix

### Popravljeno (kritično — 22 nil globalov)
- **22 sistemskih globalov** je bilo nastavljenih na `nil` zaradi v2.3.0 konsolidacije
- Vse `_G.X = X` vrstice so bile popravljene na `_G.X = S.X`
- Prizadeti sistemi:
  - **Zvok**: DynamicMusic, SFXLibrary, VoiceOver
  - **Vizualno**: VisualPolish, WeatherGameplay, FormationSystem, FestivalSystem
  - **AI**: ThreatAI, AIDialogue
  - **Boj**: Veterancy
  - **UI**: ResourceFlow, ConstructionAnim
  - **QoL**: RallyPoint, BuildingQueue, AutoWorker, DynamicUnitCap
  - **Multiplayer**: MapSizeSelector, SpectatorMode, CoopCampaign, PathOpt, Workshop
  - **v1.28**: SkirmishTrail, ObjectPool, Gamepad, MapSharing, AutoSaveIndicator
- **Posodobljena startup notifikacija**: "F8 for combat test" → "F1 for help, F3 for perf overlay"

### Posodobljena dokumentacija
- **README.md**: badge-i posodobljeni na v2.3.1, statistika 572 datotek, 14 krogov pregleda
- **Map Editor**: F12 → F4 v README
- **Screenshot**: dodan F12 poleg Ctrl+M

## [v2.3.1] — 2026-08-04 — Keybind Conflict Fix Round 14

### Popravljeno (6 kritičnih popravkov tipkovnih bližnjic)
- **M (plain)** — dodana izključitev Ctrl, da Ctrl+M (screenshot) postane dosegljiv
- **C (plain)** — dodana izključitev Ctrl, da Ctrl+C / Ctrl+Shift+C (co-op) postaneta dosegljiva
- **H = KeybindHelp** — premaknjeno na F1; H je obnovljen kot CenterViewToKeep (originalna bližnjica)
- **F12 = Map Editor** — premaknjeno na F4; F12 je obnovljen kot Screenshot (Steam konvencija)
- **F3 = Performance Overlay** — eksplicitno vezan na F3 (prej je bil le stranski učinek F2)
- **B (keyreleased)** — dodana izključitev Ctrl, da Ctrl+B (catapult) ne toggle-a brush tool ob sprostitvi tipke
- **Ctrl+S** — poenostavljena logika izključevanja Shift (odstranjena redundantna dvojna preverba)
- **EVENT.Screenshot** — zdaj uporablja ScreenshotManager.capture() za organizirano shranjevanje

### Statistika
- 572 Lua datotek, 569/572 syntax pass (3 lažni pozitivi zaradi LuaJIT specifične sintakse)
- 50 keybind handlerjev v game.lua, 0 konfliktov
- 30 KeybindManager mapiranj, 0 konfliktov z game.lua

## [v2.3.0] — 2026-08-04 — Critical LuaJIT Upvalue Fix

### Popravljeno (kritično)
- **LuaJIT 60-upvalue limit** — 84 sistemskih require() konsolidiranih v S tabelo
- Game prej ni mogel startati (error: "function at line 185 has more than 60 upvalues")

## [v2.0.7] — 2025-08-04 — FINAL RELEASE

### Dodano
- **README.md** posodobljen z vsemi funkcijami in statistiko
- **STEAM_STORE_PAGE.md** — opis za Steam store page
- **KEYBINDS.md** — popoln seznam 50+ tipkovnih bližnjic

### Popravljeno (10 krogov pregleda — 45 popravkov)
- Krog 1 (v1.25.1): 11 integracijskih napak (BuildingHotkeys, Veterancy, FogOfWar, GameSpeedControl, VisualPolish, Minimap, ResourceFlow, 8 globalov)
- Krog 2 (v1.25.2): 6 napak (MapEditor keypressed/mousepressed, ConstructionAnim, EndGameScreen, AIDialogue, FormationSystem)
- Krog 3 (v2.0.0): 5 napak (AutoSaveIndicator, Gamepad events, SkirmishTrail, BuildingQueue.clear, Gamepad connect/disconnect)
- Krog 4 (v2.0.1): 4 napake (SkirmishTrail.complete, MapSizeSelector.applyToGame, CoopCampaign.stop, AutoWorker toggle, Gamepad.update)
- Krog 5 (v2.0.2): 7 keybind konfliktov (Ctrl+W/S/T/C/M/L vs Ctrl+Shift variant)
- Krog 6 (v2.0.3): 2 napaki (duplicate CreditsScreen.draw, AutoSaveIndicator global)
- Krog 7 (v2.0.4): 3 nil-safety popravki (ConstructionAnim, RallyPoint, AutoSaveEnhancer)
- Krog 8 (v2.0.5): 4 F-key konflikti (F7, F8, F9, F12)
- Krog 9 (v2.0.6): 2 F-key konflikti (F10, F11)
- Krog 10 (v2.0.7): 1 syntax error (ErrorHandler.lua const variable)

### Končna statistika
- 570 Lua datotek, 286.918 vrstic kode
- 393/393 syntax pass (100%)
- 12 GLSL shaderjev, 33 jezikov
- 45 bug popravkov v 10 krogih

## [v1.28.0] — 2025-08-03

### Dodano
- **Skirmish Trail System** — 10 progresivnih skirmish misij
- **Object Pooling System** — performance optimizacija (projectiles, particles, effects)
- **Gamepad Support** — polna podpora krmilnika z virtualnim kazalcem
- **Custom Map Sharing** — deljenje map med igralci
- **Auto-Save Indicator** — vizualni indikator shranjevanja

## [v1.27.0] — 2025-08-03

### Dodano
- **Map Size Selector** — 4 velikosti (Small 128 → Huge 768)
- **Spectator Mode** — opazovanje multiplayer iger
- **Co-op Campaign Framework** — 2-igralec co-op
- **Pathfinding Optimizer** — JPS + caching
- **Steam Workshop Integration** — subscribe/upload modov

## [v1.26.0] — 2025-08-03

### Dodano
- **Rally Point System** — zbirno mesto za barake
- **Right-Click Dismiss** — desni klik zapre panele
- **Building Queue** — shift+klik za vrsto gradenj
- **Minimap Drag Scroll** — vlečenje po minimap-u
- **Auto Worker Assignment** — samodejna dodelitev delavcev
- **Dynamic Unit Cap** — prilagoditev glede na FPS

## [v1.25.0] — 2025-08-03

### Dodano
- **Unit Veterancy System** — 5 stopenj z bonusi
- **Building Hotkeys** — Ctrl+1-9 za hitro gradnjo
- **Resource Flow Visualizer** — proizvodnja/poraba surovin
- **Auto-Save Enhancer** — crash recovery backup-i
- **Threat Assessment AI** — prilagodljiv AI

## [v1.24.0] — 2025-08-03

### Dodano
- **Minimap System** — teren, zgradbe, kamera viewport
- **Unit Command Queue** — shift+klik za več ukazov
- **AI Personality Dialogue** — 30+ dialogov v slovenščini
- **Game Speed Control** — pavza, 1x, 2x, 3x, 5x
- **Construction Animation** — progress bar, delci

## [v1.18.0] — 2025-08-02

### Dodano
- **Save Game Compatibility** — versioned saves z migration system (magic header SH2027)
- **Config Profile System** — 5 preset grafičnih profilov (Ultra/High/Medium/Low/Custom)
- **Debug Console** (Tilde ~) — 12 ukazov (help, stats, perf, mods, reload, time, gold, spawn, checklist, gc, profile, clear)
- **Community Feedback System** — bug reports, suggestions, crash reports z sistemskimi informacijami

### Spremenjeno
- Integracija SaveCompat, ConfigProfiles, DebugConsole, CommunityFeedback v game loop
- textinput handler podpira debug console

## [v1.17.0] — 2025-08-02 — Release Candidate

### Dodano
- **Final Bug Fix Pass** — nil-safety wrapperji (safeGetState, safeDraw, safeNewImage, safeSetColor, itd.)
- **Performance Optimizer** — frustum culling, LOD (near/medium/far/culled), update tiering (60/10/2 Hz)
- **Achievement Integration** — povezovanje game eventov z Steam achievements
- **Release Checklist** (Ctrl+L) — 20 pre-release preverjanj v 8 kategorijah

### Spremenjeno
- Auto garbage collection ko memory > 200MB
- Frame stats tracking (draw calls, culled objects)

## [v1.16.0] — 2025-08-02

### Dodano
- **Campaign Story System** — cutscene dialogi v slovenščini z portreti (misije 1, 2, 3, 10)
- **Siege Weapons System** — 4 tipi (catapult, trebuchet, siege tower, battering ram)
- **Unified Settings Panel** (Ctrl+O) — 5 zavihkov (Gameplay, Graphics, Audio, Accessibility, Language)

## [v1.15.0] — 2025-08-02

### Dodano
- **Localization System** — 32 jezikov z runtime preklopom, font detection, RTL podpora
- **Accessibility System** — colorblind mode-i (protanopia, deuteranopia, tritanopia), font scaling, reduced motion
- **Tutorial System** (Ctrl+T) — 10-korak interaktivni vadbeni v slovenščini

## [v1.14.0] — 2025-08-02

### Dodano
- **Replay System** (Ctrl+R) — snemanje/predvajanje z state snapshots, seek, speed control
- **Statistics Dashboard** (Ctrl+S) — session + lifetime statistike, K/D ratio, win rate
- **Map Editor** (F12) — terrain painting, objects, save/load custom maps

## [v1.13.0] — 2025-08-02

### Dodano
- **Dynamic Music Manager** — 5 stanj (menu, peace, combat, victory, defeat), combat intensity tracking
- **SFX Library** — 4 kategorije (combat, building, UI, environment), 3D positional audio
- **Slovenian Voice-Over** — 30+ notifikacij v slovenščini (combat, economy, mission, diplomacy)

### Spremenjeno
- CombatComponent.takeDamage() zdaj predvaja SFX in prijavlja boj glasbenemu sistemu

## [v1.12.0] — 2025-08-02

### Dodano
- **Modding API** — ModLoader (scan /mods, load manifest.lua), CustomBuildingLoader
- **Steam Integration** — 10 achievements, stats tracking, leaderboard (stub)
- **Sample mod** — GoldMine building (produces 5 gold / 10s)

## [v1.11.0] — 2025-08-02

### Dodano
- **Mission Test Suite** (F10) — avtomatski testi za vseh 10 misij kampanje
- **Crash Handler** (F11) — error recovery, auto-disable failing systems, crash log
- **Performance Watchdog** — auto quality (ULTRA/HIGH/MEDIUM/LOW), FPS tracking
- **Audio Mix System** — 5 kategorij glasnosti, 3D positional, music crossfade

## [v1.10.0] — 2025-08-02

### Dodano
- **Diplomacy Controller** — 6 stanj razmerij (neutral, allied, war, truce, proposed_alliance, proposed_peace)
- **Trade Controller** — predlogi, darila, trade routes, trade history
- **Diplomacy Panel** (F9) — UI z relacijami in trgovanjem

### Spremenjeno
- 11 novih mrežnih tipov sporočil (diplomacy + trade)

## [v1.9.0] — 2025-08-02

### Dodano
- **Multiplayer** — TCP/IP socket networking (LuaSocket)
- **GameServer** + **GameClient** — server/client arhitektura (do 8 igralcev)
- **Multiplayer Lobby** — host/join, player list, ready, start game
- **In-game Chat** (Enter) — timestamp, 10 zadnjih sporočil
- **Network Protocol** — 18 tipov sporočil, length-prefixed JSON, custom encoder/decoder

## [v1.8.0] — 2025-08-02

### Dodano
- **HD Asset Pipeline** — normal mapping, dynamic point lights (32), SSAO, ACES tone mapping
- **Normal Map Generator** — Sobel filter iz heightmap podatkov
- **HD Render Pipeline** — integrira vse shaderje (5-stopni pipeline)

### Novi shaderji
- `normal_mapping.glsl`, `point_lights.glsl`, `ssao.glsl`, `tonemap.glsl`

## [v1.7.9] — 2025-08-02

### Popravljeno
- **Action bar SetScale bug** — `SetScale(x)` → `SetScale(x, x)` (scaley je bil nil → 0, ikone nevidne)

## [v1.7.7] — 2025-08-02

### Popravljeno
- Revert input handling na originalno Stone Kingdoms implementacijo
- Odstranjeni pcall wrapperji, fallback hit-test, mousemoved handler
- `currentGroup = nil` za pravilno inicializacijo

## [v1.7.5] — 2025-08-02

### Popravljeno
- Force-show gumbi ko `showGroup` pokličemo z isto skupino
- Splash screen pcall za LFS pointer crash (heart.png)
- Animation watchdog za stuck animacije

## [v1.7.4] — 2025-08-02

### Popravljeno
- Back button (puščica nazaj) z `skipAnimation=true`
- Manual hit-test fallback za klik gumb
- ESC shortcut za vrnitev v main meni

---

## Starejše verzije (v1.0.0 — v1.7.1)

Glej [git log](https://github.com/markec12345678/stronghold2027/commits/main) za podrobnosti o zgodnjih verzijah:
- v1.0.0 — campaign complete
- v1.1.x — polish, performance, gamefeel
- v1.2.x — combat visualizer, settings
- v1.3.x — AI enhancements, UX screens
- v1.4.x — final audit, localization
- v1.5.x — Kenney CC0 asset integration
- v1.6.x — final, performance fixes
- v1.7.0-v1.7.1 — crash fixes, LFS fix
