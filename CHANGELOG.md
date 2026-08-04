# Changelog

Vse pomembne spremembe projekta Stronghold 2027.

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
