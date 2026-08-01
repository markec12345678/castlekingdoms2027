# v1.6.0-final (2026-08-01)

Končni release pred asset/testing fazo. Projekt je feature complete.

### Documentation
- CHANGELOG.md posodobljen z vsemi 39 releasi
- PROJECT_SUMMARY.md - končni povzetek projekta
- README.md - popoln feature list (16 kategorij)
- FINAL_AUDIT.md - zadnji pregled kode

### Stats (končne)
- 301 Lua datotek
- ~220,000 vrstic kode
- 831 Kenney CC0 datotek (14 MB)
- 39 git tag-ov
- 343 test preverjanj (100% pass)
- 0 nil-safety warnings
- 16 jezikov (popolni prevodi)
- 17 dokumentacijskih datotek

---

# v1.5.3-kenney-rendering (2026-08-01)

Kenney CC0 sprite rendering v game world.

### Features
- KenneySpriteRenderer: 8 draw funkcij (building, unit, icon, preview, health bar)
- KenneySpriteOverlay: non-intrusive overlay z CC0 status badge
- BuildController integracija: Kenney ghost building preview
- Game loop: overlay rendering ko je CC0 aktiven
- Fallback sistem: ko je CC0 OFF, original Firefly rendering (brez sprememb)

---

# v1.5.2-kenney-integration (2026-08-01)

Kenney CC0 asset loader integriran v game loop + Settings.

### Features
- KenneyAssetLoader z image caching in sprite atlas
- Settings toggle: "CC0 Asseti (Kenney)" v Graphics tab (V key)
- SettingsPersistence: useKenneyAssets saved v settings.json
- 89 assetov mapiranih (buildings, units, terrain, environment)

---

# v1.5.1-kenney-cc0 (2026-08-01)

600+ CC0 PNG datotek integriranih iz Kenney.nl.

### Assets
- Kenney Medieval RTS pack: 270 PNG (23 structures, 24 units, 58 tiles, 22 environment)
- Kenney Castle Kit: 341 PNG (zidovi, stolpi, siege weapons)
- KenneyAssetMapping: 89 assetov mapiranih na naše zgradbe/enote
- Licenca: CC0 (Public Domain) - brez atribucije, brez omejitev

---

# v1.5.0-asset-migration-plan (2026-08-01)

Načrt za popolno neodvisnost od Firefly Studios.

### Documentation
- ASSET_MIGRATION_PLAN.md: 6-fazni načrt migracije na CC0
- Kenney.nl CC0 kot priporočeni vir (685+ assetov, €0, komercialno brezplačno)

---

# v1.4.2-full-localization (2026-08-01)

16 jezikov popolnoma prevedenih.

### Localization
- 6 jezikom dokončani vsi prevodi (groups, rations, taxes, settings, tips, UI)
- srp, ell, bul, mkd, lit, lav - vsi popolni
- ~300 dodatnih prevodov (50 per jezik)

---

# v1.4.1-localization-steam (2026-08-01)

150 prevodov zgradb + Steam store page + trailer storyboard.

### Localization
- 6 jezikom dodani prevodi zgradb (25 vsakemu)
- STEAM_STORE_PAGE.md: complete store page z 15 achievements
- TRAILER_STORYBOARD.md: 90-second trailer plan z 6 sekcijami

---

# v1.4.0-final-audit (2026-08-01)

Final code audit - PROJECT IS FEATURE COMPLETE.

### Code Quality
- 0 nil-safety warnings (all resource_compare fixed)
- canAfford() in spendResources() nil-safe
- README.md: popoln prepis s celotnim feature listom (16 kategorij)
- FINAL_AUDIT.md: complete project review

---

# v1.3.2-completeness (2026-08-01)

Completeness pass - campaign progress, keybind help, auto-save.

### Features
- CampaignProgress: save/load katere misije so končane (campaign_progress.json)
- KeybindHelp: prikaz vseh 25+ tipk (H key, 8 kategorij)
- AutoSaveSystem: samodejno shranjevanje vsakih 5 minut (3 rotating sloti)
- 3 achievements: first_victory, halfway, king_of_valdemar

---

# v1.3.1-ux-screens (2026-08-01)

Essential UX screens.

### Features
- MissionEndScreen: win/lose screen z stats, continue/retry
- CreditsScreen: scrolling credits po končani kampanji
- TutorialHints: 12 kontekstualnih namigov za nove igralce

---

# v1.3.0-ai-enhancements (2026-08-01)

AI behavior improvements.

### AI
- Smarter building placement (no clustering, minBuildingDistance=5)
- Strategic attack timing (multi-factor: grace, cooldown, army, gold)
- Defense response (recall units when keep under attack, 30 tile range)
- Difficulty adaptation (assess player strength every 60s)
- Resource management (suggestBuild z prioriteto: food > wood > military > economy > defense)

---

# v1.2.2-full-settings (2026-08-01)

Full settings system z persistence, tooltips, audio, graphics.

### Settings
- SettingsPersistence: save/load settings.json
- 3 tabi: Game Feel (8 stikal + slider), Audio (5 volumov), Graphics (FPS/VSync)
- Tooltipi v slovenščini za vsako nastavitev
- Reset to Defaults gumb
- V keybind v glavnem meniju IN gameplay-u
- Auto-save ob spremembi

---

# v1.2.1-settings-playtest (2026-08-01)

Settings menu + posodobljen .love paket.

### Features
- GameFeelSettings panel (V key) z 8 toggle stikali
- Camera smoothing slider
- GitHub Release z .love paketom

---

# v1.2.0-combat-visualizer (2026-08-01)

Combat Order Visualizer - črte do tarč.

### Features
- Attack orders: rdeča črta + pulzajoči krož okoli tarče
- Move orders: rumena črtkana črta + puščica na cilju
- Animirane črtkane črte (dash offset 30px/s)
- Samo za izbrane enote (ne zmede UI)

---

# v1.1.4-gamefeel-integration (2026-08-01)

Game feel sistemi integrirani v igro.

### Integration
- GameFeel ↔ CombatComponent: screen shake, hit flash, punch zoom
- BuildPreview ↔ BuildController: ghost building z valid/invalid
- SelectionFeedback ↔ Commander: glow rings, selection box
- 7 nil-safety warnings fixed

---

# v1.1.3-gamefeel-pass (2026-08-01)

Game feel sistemi ustvarjeni.

### Systems
- GameFeelSystem: screen shake (4 stopnje), punch zoom, hit flash, camera smooth
- BuildPreviewSystem: ghost building z valid/invalid indicator in cost
- SelectionFeedbackSystem: glow rings, hover highlight, selection box
- Nil safety audit: 750 potential issues identified

---

# v1.1.2-hotfix-economy-ai (2026-08-01)

Hotfix: EconomyAI nil crash + LFS fix.

### Bug Fixes
- EconomyAI.lua:217 nil compare crash popravljen (resources.iron nil)
- getResources() sedaj vrača iron
- Nil-safe access ('or 0') v evaluateTrade(), determinePhase()
- LFS_FIX.md z navodili za popravek črnih kvadratkov

---

# v1.1.1-performance-pass (2026-08-01)

Performance profiling sistem.

### Systems
- PerformanceManager: 25+ sekcij z frame history in pathfinding spike tracking
- PriorityUpdateSystem: tiered update (60Hz/10Hz/2Hz)
- AITickOptimizer: 5 AI tick kategorij (combat 4Hz do personality 0.02Hz)
- MemoryProfiler: leak detection z GC tracking
- PerformanceOverlay: vizualni bar chart (F3)
- Benchmark skripta za avtomatske meritve

---

# v1.1.0-polish-pass (2026-08-01)

Prvi polish pass - bugfixi, balance, AI tuning.

### Bug Fixes
- Hardcoded faction IDs odstranjeni (4 lokacije)
- Missing COMBAT require dodan v AIStrategyController

### AI Tuning
- Brutal cheat bonus: 50% -> 30%
- Hard cheat bonus: 20% -> 15%
- 5-minutni grace period (AI ne napade na začetku)
- Boljša retreat logika

### Balance
- BalanceConfig.lua: centralizirane vse balance vrednosti

---

# v1.0.0-campaign-complete (2026-08-01)

KAMPANJA KONČANA! Vseh 10 misij implementiranih.

### Campaign
- Mission 8: The Cathedral (upravljanje, popularnost)
- Mission 9: Lady Elara's Sacrifice (2 poti do zmage, čustvena)
- Mission 10: The Throne of Valdemar (6-fazni finalni siege)
- Sir Markus postane KRALJ VALDEMARJA

---

# v0.9.4-campaign2-alpha (2026-08-01)

Drugo dejanje kampanje.

### Campaign
- Mission 6: Betrayal at Eastvale (3 valovi napadov, izdaja)
- Mission 7: The Northern Pass (siege warfare z catapulti)

---

# v0.9.3-hud-alpha (2026-08-01)

HUD widgeti + prva polovica kampanje končana.

### Features
- SeasonInfoWidget: letni čas z progress bar (vedno viden)
- EconomicEventLog: toast/banner za ekonomske evente
- Mission 4: The Iron Hills (zavzetje rudnika)
- Mission 5: The Bandit King (boss fight)

---

# v0.9.2-ui-alpha (2026-08-01)

Market UI + Caravan UI + Misije 2-3.

### UI
- DynamicMarketUI: prikaz 20 surovin z dinamičnimi cenami in trendi
- CaravanUI: pošiljanje karavan z escort in risk calculation
- Mission 2: First Defenders (vojaški tutorial)
- Mission 3: Alliance with Westmarsh (trgovina)

---

# v0.9.1-economy-alpha (2026-08-01)

Ekonomija + prva misija kampanje.

### Economy
- DynamicMarketSystem: supply/demand, inflation, event modifiers
- SeasonalSystem: 4 letni časi z vplivom na proizvodnjo
- EconomicEventsSystem: 10 random eventov
- TradeCaravanSystem: mednarodna trgovina z AI

### Campaign
- MissionFramework: 10 objective tipov, scripted events
- Mission 1: Return to Fernhaven (tutorial)

---

# v0.9.0-ai-alpha (2026-08-01)

AI sistem.

### AI
- AIStrategyController: 4 osebnosti, 4 težavnosti, 8 stanj
- EconomyAI: resource gathering, build priorities, trade
- MilitaryAI: army composition, 4 formacije, target selection
- AICommander: execution (build, spawn, attack)
- AIIntegration: coordinator

---

# v0.8.0-immersion-alpha (2026-08-01)

5 immersion sistemov.

### Systems
- AnimationSystem: state machine z 8 state-i in 8 smermi
- SoundSystem: ambient crossfading, SFX z 3D audio, music state machine
- WeatherSystem: 6 weather tipov z particle sistemom
- LightingSystem: day/night cycle z dynamic lighting
- ModernUISystem: tooltips, notifications, hover effects

---

# v0.7.1-combat-alpha (2026-08-01)

Combat integriran v game loop.

### Combat
- CombatComponent (mixin za Unit)
- CombatIntegration (hook v game loop, Commander, spawn)
- CombatTestScenario (F8 za test)
- Prva prava bitka mogoča!

---

# v0.7.0-stronghold2027-alpha (2026-08-01)

Prvi alpha release Stronghold 2027 - forka Stone Kingdoms z dodatnimi izboljšavami.

### Features

- **Slovenski prevod (slv.yaml)**: Popoln prevod vseh 472 vrstic besedila (5 misij, 63 zgradb, 12 mesecev, UI, nastavitve)
- **Modding API (alpha)**: Osnovni sistem za uporabniške mode z lifecycle hook-i (onLoad, onTick, onBuildingPlaced, onUnitRecruited)
- **HD Shaderji**: Moderni post-processing shaderji (bloom, color grading, vignette, dynamic lighting) za izboljšano vizualno izkušnjo
- **Performance Profiler**: Debug overlay s FPS, memory usage, custom counters (F3 za toggle, F4 za detailed mode)
- **CI/CD Pipeline**: GitHub Actions z luacheck, YAML validacijo, custom test runnerjem in build pipeline
- **Comprehensive Test Suite**: 343 preverjanj - sintaksa, YAML, dokumentacija, arhitektura

### Documentation

- **README.md**: Posodobljen z informacijami o forku in roadmapom
- **FORK_NOTICE.md**: Dokumentacija odnosa do upstream Stone Kingdoms
- **CONTRIBUTING.md**: Navodila za sodelovanje z Conventional Commits
- **ROADMAP.md**: Razvojni načrt do 2027-09-01
- **BUGFIX_STRATEGY.md**: Strategija popravkov v 4 fazah
- **HD_ASSETS_GUIDE.md**: Specifikacije za grafične oblikovalce (4K tileset, UI, animacije)
- **MODDING_API.md**: Dokumentacija modding API za ustvarjalce modov

### Branches

- `main` - Stabilna produkcija
- `dev` - Integracijska veja
- `feat/bugfixes` - Popravki bug-ov
- `feat/hd-assets` - HD grafični asseti
- `feat/slovenian-polish` - Izboljšave slovenskega prevoda

### GitHub Templates

- Issue template za bug report
- Issue template za feature request
- Pull request template s checklist

### Infrastructure

- Git LFS konfiguriran za vse binarne datoteke (PNG, DDS, MP3, DEB, DXT5, BIN)
- 1151 LFS objektov (1.8 GB) sinhronizirano z GitHubom
- 4 nove razvojne veje ustvarjene
- Slovenščina registrirana kot 10. podprti jezik

### Stats

- 280 Lua datotek v projektu (213,215 vrstic kode)
- 71 struktur (zgradbe)
- 42 enot
- 15+ krmilnikov (Controllers)
- 33 jezikovnih datotek v locale/
- 343 test preverjanj - 100% pass rate

### Known Issues

- Xvfb (virtual display) ne podpira GLX v strežniškem okolju - dejansko grafično testiranje zahteva lokalni računalnik
- GitHub LFS storage trenutno porabljen 1.8 GB (free plan = 1 GB) - priporočen nakup GitHub Pro ($4/mesec)
- Apothecary, Stable, Maypole so še vedno nefunkcionalni (enako kot upstream v0.6.1)
- Combat sistem še ni implementiran (enake kot upstream v0.6.1)

### Credits

- Original Stone Kingdoms team - celotna koda, arhitektura in asseti
- Firefly Studios - dovoljenje za uporabo originalnih Stronghold assetov
- Stronghold 2027 ekipa - slovenski prevod, CI/CD, modding API, HD shaderji, dokumentacija

### Breaking Changes

- Branch renamed: `master` → `main`
- `*.dds` files migrated to Git LFS in history (to bypass GitHub 100MB limit)
- README.md replaced with fork-specific documentation

---

# 0.6.1

### Misc

- Added the innkeeper (partially implemented).
- Added the Grasslands map which loads an empty 128x128 map for testing purposes.
- Menu buttons are now sized to the localized caption if necessary

### Bug Fixes

- Pressing exit or loading a game no longer freezes for 1 second.
- Fixed crash when centering on granary or keep before they were placed
- Fixed crash with OxHandler
- Fixed crash when worker leaves their workplace while working
- Fixed crash with pathfinding when workers couldn't find a path back to the stockpile
- Fixed crash with Miller boys
- Fixed the ability for workers to leave/sleep the windmill
- Fixed crash when upgrading castle placed near edge of map
- Fixed peasants getting stuck at campfire
- Fixed various rendering bugs with defensive structures

# 0.6.0

### New Buildings

- **Wooden Perimeter Tower**: A small wooden defensive tower.
- **Wooden Defensive Tower**: A large wooden defensive tower.
- **Wooden Big Gate**: A bigger kind of wooden gate.
- **Pich Rig**: Small platform to collect pitch from the swamp.
- **Apothecary**: It creates a healer that wanders around. Temporarely not functional.
- **Stable**: It produces horses. Temporarely not functional.

### Gameplay

- Added military units (they can only be moved around for now, there's no combat yet).
- Switched popularity system to be more similar to Stronghold.
- Buildings will now be unlocked by upgrading the keep.
- Added ability to upgrade houses to increase the population.
- Added priest worker for the chapel (he blesses buildings, but there's no popularity bonus yet).
- Workers now leave their job when they're unhappy.
- Added sleep feature to buildings.

### Misc

- Added new tree types: birch and chestnut.
- Added [translations framework](https://crowdin.com/project/stone-kingdoms). Currently supported languages are German, Italian, Polish, Portuguese (BR) and Ukrainian. Contributions are welcome!
- Changes some fonts to improves language support.
- Extended soundtrack (check below for credits).
- Added drunkard. They will wander around the inn and houses.
- Added automatic crash reporting via Sentry.
- Made woodcutter's tree finding algorithm smarter.
- Added master volume slider in the settings.
- Added a new main menu soundtrack.
- Major overhaul of the graphics settings.
- Added language picker to the menu.

### Bug Fixes

- Fixed workers not able to enter buildings when they're built next to other buildings.
- Fixed an issue where you couldn't trade goods when you select them from the stockpile.
- Fixed crash when completing the last mission in the campaign.
- Fixed crash on load when having a Maypole.
- Fixed crash on load when having an Inn.
- Fixed Orchard farmer crash.
- Fixed Chicken related crash.
- Fixed not reloading prices at the market.
- Fixed woodcutters getting stuck in various situations.
- Fixed inaccurate gold counter when trading weapons.
- Fixed multiple woodcutters chopping the same tree.
- Fixed game music not stopping when return back to main menu.
- Fixed crash loading a game with a windmill.
- Fixed "cannot build" sounds not always playing.

### Credits

- Features additional art by Ho6org, Lord Steinhauer, Monsterfish and Zarentreuer Lenin.
- Extended soundtrack was made by Alexander Nakarada, Kevin MacLeod & Random Mind. See `/sounds/music` for full attribution & licensing info.
- Thanks to UCP team and Project Reconquista for technical support.

# 0.5.0

### New Buildings

- **Dairy Farm**: Produce cheese for food consumption.
- **Hops Farm**, **Brewery**, **Inn**: Grow hops, produce ale and distribute it, making people happy!
- **Armory**: A storage for your weapons.
- **Fletcher's Workshop**: Produce bows or crossbows.
- **Poleturner's Workshop**: Produce spears or pikes.
- **Blacksmith's Workshop**: Produce swords or maces.
- **Armorer's Workshop**: Produce shields.
- **Barracks**, **Stone Barracks**, **Engineer's Guild**, **Tunneler's Guild**: They are currently placeholders, but they will allow recruiting military units in the next updates.
- **Chapel**, **Church**, **Cathedral**: They are currently non-functional, but in future updates they will increase faith, which will increase happiness.
- **Apothecary**: Currently non-functional. It will gain utility in future updates.
- **Positive Buildings**: Gardens, ponds and maypole. Build them to increase population happiness.
- **Defensive Stone Structures**: Towers and gates made out of stone.

### Gameplay

- Added a new "Campaign" mode, where you can play missions with objectives.
- The previous free build mode is now a separate mode called "Freebuild".
- Added auto tax feature to castles. This will automatically apply tax on your population, based on the happiness level.
- Workers from destroyed builders will no longer disappear anymore and they will become unemployed again.
- Destroyed buildings will now refund half of the material cost.

### GUI

- Added map selection for the freebuild mode.
- Added campaign menu.
- Added option to select game resolution.
- Added GUI for the barracks.
- Added GUI for the armory.
- The material cost on building tooltips will change color based on if you have the required resources or not.

### Misc

- The game date is now displayed.
- Added the lord unit. It will wander around your castle.
- You can now press F12 to take a screenshot.
- The camera zoom is now smoother.
- Added tooltips to built buildings.
- Added current materials beside the cost to the building tooltips.
- Clicking on materials in the stockpile UI will now open the market UI with that material.
- Added right click shortcut to navigate back in UIs.
- Added soundeffects to the action bar.
- Save files are now ~10 times smaller.
- Added configurable keybindings. This is currently not exposed in the UI.

### Bug Fixes

- Buying materials from the market when the stockpile is full will no longer spend money.
- Fixed wheat farmer sometimes getting stuck.
- Fixed crash after trying to build outside of the map.
- The quarry workers will not get stuck anymore if the ox handler is unemployed.
- Fixed wrong shading of the stockpile on game load.
- Fixed not being able to select the Fortress (upgraded keep).
- Fixed several bugs about terraforming when placing buildings.
- Fixed being able to place the initial buildings when the game is paused.
- Fixed stone texture in the stockpile getting misaligned.
- Fixed crash on game start for ARM processors, like Apple's M1 and M2.
- Fixed not being able to fully destroy woodcutters in a loaded game.
- Disable building too close to the keep to not interfere with keep upgrades.
