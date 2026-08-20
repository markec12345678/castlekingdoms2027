# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.12.090**
- Skupaj Royal sistemov: **990**
- Skupaj Lua datotek: **1648**
- Sintaktična preverba (avtentična Lua `load()`): **1648/1648 pass (100%)**
- Tech Tree: **790 deps · 148 verig · 685 multi-prereq** (85.625x zažetnih 8!)
- Zadnji paket: **v3.12.083–090 singles MatchCord→Quarry** (48 multi-prereq, 88. zapored all-multi, 685 multi = 85.625x)
- GitHub: pripravljen za push
- Lokalni repo (sandbox): `/home/workdir/castlekingdoms2027`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 769 Royal sisteme z igro:

- **`objects/Economy/RoyalSystemsRegistry.lua`** — auto-discovers vse sisteme, hook-a `completeMaking()`, dodeli bonus zlato (prestige × 10) ob končanem produktu
- **`states/ui/hud/royal_systems_panel.lua`** — full-screen UI panel (toggle s Ctrl+R), ki omogoča brskanje, najem mojstrov, gradnjo delavnic, izdelavo produktov, prodajo zalog
- **`states/ui/hud/keybind_help.lua`** — dodana Ctrl+R bližnjica
- **`scripts/test_registry.lua`** — test skripta (poženi z lupa)

Vsi novi sistemi, dodani po v3.11.382, so samodejno odkriti in prikazani v panelu — ni potrebe po ročni registraciji v Registry. Tudi ni potrebno več ročno registrirati sisteme v states/game.lua (require/init/update bloki) — zadnje pakete (od v3.11.542 naprej) pustimo neregistrirane, ker jih Registry sam odkrije preko S tabele.

## ZNANE NADGRADNJE ZA PRIHODNJE PAKETE (stari seznam — vidi spodaj za posodobljen)

1. ~~**Sprite-i za Royal sisteme** — trenutno so samo podatkovni, brez grafične podobe~~ (odprto)
2. ~~**Sistemske odvisnosti** — nekateri sistemi naj zahtevajo druge (npr. BellMaker zahteva Metalwork)~~ ✅ končano v v3.11.934-v3.11.943
3. ~~**Market Dashboard mousemoved forwarding**~~ ✅ končano
4. ~~**Overlay settings migration**~~ ✅ končano v v3.11.933

## ZAKLJUČENE NADGRADNJE (v3.11.382 - v3.12.013)

- ✅ **v3.11.382**: Royal Systems Registry + UI Panel (Ctrl+R)
- ✅ **v3.11.901**: Save/Load persistenca za Royal sisteme (maker, zgradbe, zaloga, surovine)
- ✅ **v3.11.902**: DynamicMarket integracija — Royal produkti registrirani na trgu, auto-sell toggle, dinamične cene
- ✅ **v3.11.903**: Market Dashboard (Ctrl+K) — pregled vseh 987 produktov, sortiranje, iskanje, test dogodki
- ✅ **v3.11.904**: Price History Chart — line chart 60s zgodovine cene v Market Dashboard, trend detection
- ✅ **v3.11.905**: Production History Chart — bar chart 60s proizvodnje v Royal Systems Panel, rate/min, status
- ✅ **v3.11.906**: Aggregate Production Chart — bar chart skupne proizvodnje vseh 987 sistemov v Market Dashboard
- ✅ **v3.11.907**: Top-10 Producers Leaderboard — seznam 10 najproduktivnejših sistemov z rangi, bar-i, statistiko
- ✅ **v3.11.908**: Profit Leaderboard (Q toggle) — top-10 sistemov po prihodku (gold), Q preklopi med qty in profit
- ✅ **v3.11.909**: Per-Product Revenue Chart — bar chart 60s prihodka za izbran produkt v detail panel
- ✅ **v3.11.910**: Market Event Log — zgodovina tržnih dogodkov (crash/surge/seasonal) z stats in zadnjim dogodkom
- ✅ **v3.11.911**: Multi-Product Comparison Chart — SPACE/C za večproduktovno primerjavo cen (normalizirano na base=100%)
- ✅ **v3.11.912**: Saved Comparison List — persistenca comparisonList, comparisonMode, leaderboardMode, sortMode med sejami
- ✅ **v3.11.913**: Saved Auto-Sell State — persistenca autoSellEnabled, autoSellInterval, aggregateRevenue, perSystemRevenue
- ✅ **v3.11.914**: Saved DynamicMarket State — persistenca priceModifiers, inflationRate, goldInCirculation, eventLog, eventTimers
- ✅ **v3.11.915**: Save Game Versioning — SaveVersioner modul z migracijsko verigo za future-proofing save-ov
- ✅ **v3.11.916**: Expandable Event Log Panel — V/1-5 keybinds za polno zgodovino dogodkov z filtri (surge/crash/seasonal/manual)
- ✅ **v3.11.917**: Auto-Save Integration z Royal Diagnostic Stats — notification prikazuje kaj je bilo shranjeno, getStats() vključuje lastSaveStats
- ✅ **v3.11.918**: Auto-Save UI Panel (Ctrl+U) — status, progress bar, interval presets, force save, Royal diagnostic stats
- ✅ **v3.11.919**: Event Log Scroll/Pagination — miškin wheel + ↑↓/PgUp/PgDn/Home tipke + vizualen scrollbar v expanded panelu
- ✅ **v3.11.920**: Royal Systems Panel Scroll — wheel scroll med stranimi + vizualen scrollbar v seznamu 987 sistemov
- ✅ **v3.11.921**: Royal Systems Panel Keyboard Shortcuts — Home/End/PgUp/PgDn za hitro navigacijo po straneh
- ✅ **v3.11.922**: Keybind Help Overlay Dopolnjen — F1 help z 23 novimi keybind opisi za Ctrl+R/Ctrl+K/Ctrl+U panele
- ✅ **v3.11.923**: Auto-Save Quick Toggle (Shift+U) — hitri vklop/izklop brez odpiranja panela, z notification
- ✅ **v3.11.924**: Auto-Save Status Overlay — always-on HUD z statusom, timer-jem, mini progress bar, click za odprtje panela
- ✅ **v3.11.925**: Auto-Save Overlay Drag-to-Move — drag overlay na poljubno mesto, pozicija persistira med sejami
- ✅ **v3.11.926**: Overlay Position Reset Button — gumb v Auto-Save Panel za reset pozicije overlay-a na default
- ✅ **v3.11.927**: Keybind Help Scroll — scrollbar + wheel + ↑↓/PgUp/PgDn/Home/End za navigacijo po 50+ keybind opisih
- ✅ **v3.11.928**: Overlay Hide/Show Toggle (Ctrl+Shift+U) — skrij/prikaži overlay brez izklopa auto-save
- ✅ **v3.11.929**: Overlay Opacity Control — wheel-over-overlay za prosojnost (0.2–1.0), persistira med sejami
- ✅ **v3.11.930**: Overlay Hidden State Persistence — hidden stanje shranjeno med sejami (3 persisted datoteke: position, opacity, hidden)
- ✅ **v3.11.931**: Overlay Opacity Slider v Panel — vizualni drsnik v Ctrl+U za natančno nastavitev prosojnosti (drag support)
- ✅ **v3.11.932**: Auto-Save Panel Mousemoved/Mousereleased Forwarding — bug fix: slider drag sedaj pravilno deluje
- ✅ **v3.11.933**: Overlay Settings Consolidation — 3 ločene datoteke združene v 1 (autosave_overlay_settings.txt) z avtomatsko migracijo
- ✅ **v3.11.934-v3.11.943**: Tech Tree — SystemDependencies modul (65 deps v 25 verigah, 8 multi-prereq), TechTreePanel (Ctrl+Shift+G) z 100% mouse/wheel forwarding
- ✅ **v3.11.944**: Tech Tree Node Graph Visualization — node-based graph z bezier krivuljami, hover tooltip z odvisnostmi, G toggle med graf/tekst, keybind_help dopolnjen
- ✅ **v3.11.945**: Tech Tree Click-to-Focus — klik na vozlišče poudari sorodne (predpogoji + odvisniki), zatemni nepovezane, pulsing golden border, F/ESC počistita fokus, tooltip prikazuje število odvisnikov
- ✅ **v3.11.946**: Tech Tree Search/Filter — `/` odpre iskanje, case-insensitive substring match z highlightom ujemajočega dela, cyan obrobl za ujemajoča vozlišča, števec zadetkov v footerju, kombinacija s focus mode
- ✅ **v3.11.947**: Tech Tree Path Highlight — `T` preklopi med direktno (1. stopnja) in celotna pot (transitivni predniki+potomci), BFS algoritem, footer prikazuje mode + število sorodnih, tooltip label
- ✅ **v3.11.948**: Tech Tree Click-to-Jump — dvoklik na vozlišče odpre Royal Systems Panel in skoči na izbran sistem (jumpToSystem), poveže tech tree z dejansko igro, lazy require preprečuje circular dependency
- ✅ **v3.11.949**: Tech Tree Minimap — M skrij/pokaži kompakti pregled vseh 25 verig v kotu, click za skok na pozicijo, viewport indikator, focus/search dimming se preslika
- ✅ **v3.11.950**: AutoSavePanel Wheelmoved Functionality — wheel cikla interval preseti (1/5/15/30 min), snap-to-nearest za custom vrednosti, feedback message, zadnja znana vrzel v interaktivnosti panela
- ✅ **v3.11.951**: Tech Tree Depth Indicator — D preklopi barvne krožce z globino sistema (0=zeleno root, 4+=rdeče napredno), iterative relaxation algoritem, cache, tooltip z besednim opisom
- ✅ **v3.11.952**: Tech Tree Path Direction Arrows — A preklopi puščice na krivuljah (base → dependent), trikotni arrowhead na toX,toY z ista barva kot krivulja, cubic bezier tangent kalkulacija
- ✅ **v3.11.953**: Tech Tree Depth-Based Sorting — S preklopi sortiranje verig (abecedno ↔ po globini), getOrderedChains() helper, max depth per chain, stabilen sort z tie-break, footer indikator
- ✅ **v3.11.954**: Tech Tree State Filter — L cikla filter stanja (vsi→aktivni→razpoložljivi→zaklenjeni), dimming neujemajočih, kombinacija s focus in search, footer indikator
- ✅ **v3.11.955**: Tech Tree Stats Summary — povzetek statistike v footerju (X aktivnih, Y razpoložljivih, Z zaklenjenih, skupaj N), contentBottom prilagojen
- ✅ **v3.11.956**: Tech Tree Progress Bar — vizualni progress bar (% aktivnih) z barvnim gradientom (rdeča→rumena→zelena), procentni tekst, desna stran stats line
- ✅ **v3.11.957**: Tech Tree Minimap Drag — drag na minimap za kontinuirano scrollanje (ne samo click), scrollToMinimapY() helper, cyan border med drag
- ✅ **v3.11.958**: Tech Tree Keyboard Navigation — Tab/Shift+Tab za navigacijo med vozlišči, auto-scroll, auto-focus, cache invalidation ob sort spremembi, wrap-around
- ✅ **v3.11.959**: Tech Tree Bookmarks/Favorites — B označi ★ zaznamek, Shift+B filter samo zaznamovani, persisted v tech_tree_bookmarks.txt, lazy load, tooltip + footer info
- ✅ **v3.11.960**: Market Dashboard Quick-Jump — 2x click na produkt odpre Royal Systems Panel na sistemu ki ga proizvaja (jumpToSystem), productRowAreas click detekcija, lazy require
- ✅ **v3.11.961**: Tech Tree Multi-Select — Shift+click za izbiro več vozlišč, union sorodnih setov, C za počistitev, footer multi count
- ✅ **v3.11.962**: Tech Tree Export/Import — E izvozi konfiguracijo v odložišče, Shift+E uvozi, format TT|...|..., feedback message z fade out
- ✅ **v3.11.963**: Tech Tree Config Presets — P cikla 5 presetov (Vsi/Aktivni/Razpoložljivi/Zaklenjeni/Zaznamovani), applyPreset(), footer indikator, feedback message
- ✅ **v3.11.964**: Tech Tree Multi-Select Persistence — shranjevanje multi-izbire v tech_tree_multiselect.txt, lazy load, save on every change
- ✅ **v3.11.965**: Tech Tree Custom Presets — Shift+P shrani trenutno konfiguracijo kot custom preset, persisted v tech_tree_custom_presets.txt, getAllPresets() combined, P cikla skozi built-in + custom
- ✅ **v3.11.966**: Tech Tree Custom Preset Deletion — Shift+X izbriše trenutno izbran custom preset, built-in zaščita, index adjust, feedback message
- ✅ **v3.11.967**: Market Dashboard Product Hover Tooltip — hover na produkt prikaže ceno, trend (↑/↓), nabavno, prodano, prihodek, vir, 2x click hint, barvno kodiranje
- ✅ **v3.11.968**: Royal Systems Panel Hover Tooltip — hover na sistem prikaže status, zgradbe, mojstra, aktivne izdelave, surovine, barvno kodiranje
- ✅ **v3.11.969**: Auto-Save Overlay Hover Tooltip — hover na overlay prikaže status, timer, save count, zadnji save čas, Royal stats, interaction hints; celoten hover tooltip ekosistem končan (4/4 paneli)
- ✅ **v3.11.970**: Tech Tree Expansion IV — 13 novih deps v 3 novih podverigah (Horticulture+, Apiary+, Coinage+), 65→72 deps, 25→28 verig, 8→9 multi-prereq
- ✅ **v3.11.971**: Surgical+ Chain — 3 novi sistemi (BoneSawMaker, SutureMaker, ForcepsMaker), 3 nove deps, KIRURGIJA+ chain, 987→990 sistemov, 72→75 deps, 28→29 verig, 9→12 multi-prereq
- ✅ **v3.11.972**: Astronomy+ Chain — 3 nove deps za obstoječe sisteme (ArmillarySphere, Sextant, Telescope), ASTRONOMIJA+ chain, 75→78 deps, 29→30 verig, 12→15 multi-prereq
- ✅ **v3.11.973**: Glassmaking+ Chain — 6 novih deps za obstoječe steklarske sisteme (CrystalGoblet, StainedGlass, Hourglass, GlassFurnace, GlassCutter, GlassPolishingWheel), STEKLARSTVO+ chain, 78→84 deps, 30→31 verig, 15→19 multi-prereq
- ✅ **v3.11.974**: Foundry+ Chain — 6 novih deps za obstoječe livarske sisteme (Crucible, CrucibleFurnace, CastingLadle, CoreBox, SandMuller, IngotMolder), LIVARSTVO+ chain, 84→90 deps, 31→32 verig, 19→23 multi-prereq
- ✅ **v3.11.975**: Bookbinding+ Chain — 6 novih deps za obstoječe knjigoveške sisteme (BookClasp, CodexBinder, ChronicleBinder, BookbindingAwl, BookShelf, QuillCutter), KNJIGOVEZSTVO+ chain, 90→96 deps, 32→33 verig, 23→26 multi-prereq
- ✅ **v3.11.976**: Textile+ Chain — 6 novih deps za obstoječe tekstilne/usnjarske sisteme (CanvasWeaver, CarpetLoom, DyeVat, Bobbin, ClothPresser, LeatherBurnisher), TEKSTIL+ chain, 96→102 deps, 33→34 verig, 26→30 multi-prereq; MEJNIK 100+ deps in 30+ multi-prereq
- ✅ **v3.11.977**: Pottery+ Chain — 6 novih deps za obstoječe lončarske sisteme (ClayDigger, ClayPipe, GlazeSieve, MosaicTile, KilnFurniture, PotteryKiln), LONČARSTVO+ chain, 102→108 deps, 34→35 verig, 30→33 multi-prereq
- ✅ **v3.11.978**: Musical Instruments+ Chain — 6 novih deps za obstoječe glasbilske sisteme (Harp, Lute, OrganPipe, Bagpipe, Cymbal, Shawm — vsi multi-prereq!), INSTRUMENTI+ chain, 108→114 deps, 35→36 verig, 33→39 multi-prereq; MEJNIK 39 multi-prereq (skoraj 5x začetnih 8)
- ✅ **v3.11.979**: Candle/Wax+ Chain — 6 novih deps za obstoječe voščene/svečne sisteme (Candelabra, Chandelier, Candlestick, CandleMold, WaxDipper, LanternStreetLight), SVEČE IN VOSAK+ chain, 114→120 deps, 36→37 verig, 39→43 multi-prereq; MEJNIK 120 deps in 43 multi-prereq
- ✅ **v3.11.980**: Fishing+ Chain — 6 novih deps za obstoječe ribiške sisteme (FishHook, BaitBox, FishingLineSpool, FishingRod, FishSmoker, FishingBoat), RIBOLOV+ chain, 120→126 deps, 37→38 verig, 43→47 multi-prereq; MEJNIK 126 deps in 47 multi-prereq (skoraj 6x začetnih 8)
- ✅ **v3.11.981**: Brewing/Baking+ Chain — 6 novih deps za obstoječe pivovarske/pekarske sisteme (AlambicStill, DistillationApparatus, BrewerAdvancedDistillery, BreadMold, BakerConfectioner, FlourSifter), PIVOVARSTVO/PEKSTVO+ chain, 126→132 deps, 38→39 verig, 47→52 multi-prereq; MEJNIK 132 deps in 52 multi-prereq (6.5x začetnih 8)
- ✅ **v3.11.982**: Masonry+ Chain — 6 novih deps za obstoječe kamnoseške sisteme (MarbleStatue, CrestCarver, LimeBurner, StoneLintel, ChiselBlade, MortarPestle), KAMNOSEŠTVO+ chain, 132→138 deps, 39→40 verig, 52→55 multi-prereq; MEJNIK 138 deps, 40 verig, 55 multi-prereq
- ✅ **v3.11.983**: Dye/Pigment+ Chain — 6 novih deps za obstoječe barvilne/pigmentne sisteme (PigmentGrinder, Paint, Paintbrush, Inkwell, GildingBrush, Washstand), BARVILA+ chain, 138→144 deps, 40→41 verig, 55→58 multi-prereq; MEJNIK 144 deps, 41 verig, 58 multi-prereq
- ✅ **v3.11.984**: Kitchen+ Chain — 6 novih deps za obstoječe kuhinjske sisteme (SpiceGrinder, CoffeeRoaster, ButterChurner, CheeseMaker, KitchenKnife, ConfectionOven — vsi multi-prereq!), KUHINJA+ chain, 144→150 deps, 41→42 verig, 58→64 multi-prereq; MEJNIK 150 deps, 42 verig, 64 multi-prereq (8x začetnih 8)
- ✅ **v3.11.985**: Clockmaking+ Chain — 6 novih deps za obstoječe urarske sisteme (Sundial, PocketWatch, MainspringWinder, EscapementLever, PendulumRod, ClockFacePainter — 5 multi-prereq!), URARSTVO+ chain, 150→156 deps, 42→43 verig, 64→69 multi-prereq; MEJNIK 156 deps, 43 verig, 69 multi-prereq (skoraj 9x začetnih 8); ClockFacePainter je cross-chain povezava (PigmentGrinderMaker → barvila)
- ✅ **v3.11.986**: Mining+ Chain — 6 novih deps za obstoječe rudarske sisteme (Auger, DrillPress, GemMiner, Pickaxe, AshShovel, CharcoalBurner — 4 multi-prereq!), RUDARSTVO+ chain, 156→162 deps, 43→44 verig, 69→73 multi-prereq; MEJNIK 162 deps, 44 verig, 73 multi-prereq (9x začetnih 8); CharcoalBurner je cross-chain povezava (ForgeTuyere → livarstvo)
- ✅ **v3.11.987**: Armor/Weapon+ Chain — 6 novih deps za obstoječe oklepno/orožne sisteme (CeremonialSword, Halberd, Longbow, RecurveBow, ParadeShield, PresentationAxe — 5 multi-prereq!), OKLEP IN OROŽJE+ chain, 162→168 deps, 44→45 verig, 73→78 multi-prereq; MEJNIK 168 deps, 45 verig, 78 multi-prereq (10x začetnih 8!); 2 CROSS-CHAIN povezave: CeremonialSwordMaker→GemMiner (Mining+), RecurveBowMaker+ParadeShieldMaker→RawhideTanner (Leatherwork+)
- ✅ **v3.11.988**: Anvil+ Chain — 6 novih deps za obstoječe sisteme z Anvil priborom (AnvilClamp, AnvilFaceHardener, AnvilHardy, AnvilHornPolisher, AnvilSaddleBlock, AnvilStumpWedge — 5 multi-prereq!), NAKOVALO+ chain, 168→174 deps, 45→46 verig, 78→83 multi-prereq; MEJNIK 174 deps, 46 verig, 83 multi-prereq (10.4x začetnih 8!); 2 CROSS-CHAIN povezave: AnvilHornPolisherMaker→GlassBench (Steklarstvo+), AnvilSaddleBlockMaker→WoodLathe (Woodworking+)
- ✅ **v3.11.989**: Garden+ 2 Chain — 6 novih deps za obstoječe vrtnarske sisteme (GardenSoilAerator, GardenSecateurs, GardenSprayer, GardenSoilThermometer, GardenCompostThermometerProbe, GardenToolRack — 5 multi-prereq!), VRTNARSTVO+ 2 chain, 174→180 deps, 46→47 verig, 83→88 multi-prereq; MEJNIK 180 deps, 47 verig, 88 multi-prereq (11x začetnih 8!); 3 CROSS-CHAIN povezave (prvič 3 sistemi z isto CROSS-CHAIN bazo!): GardenSprayerMaker+GardenSoilThermometerMaker+GardenCompostThermometerProbeMaker→GlassBench (Steklarstvo+)
- ✅ **v3.11.990**: Milling+ Chain — 6 novih deps za obstoječe mlinarske sisteme (Millstone, MillstoneSpindleBearing, MillHopperShaker, GrainHopper, MillHopperSightGlass, MillstoneDresser — 5 multi-prereq!), MLINARSTVO+ chain, 180→186 deps, 47→48 verig, 88→93 multi-prereq; MEJNIK 186 deps, 48 verig, 93 multi-prereq (11.6x začetnih 8!); 3 CROSS-CHAIN povezave: MillHopperShakerMaker→SpinningWheel (Tekstil+), MillHopperSightGlassMaker→GlassBench (Steklarstvo+), Metalwork povezuje s Kovastvom+
- ✅ **v3.11.991**: Glass Engraving+ Chain — 6 novih deps za obstoječe sisteme z opremo za graviranje stekla (GlassEngraver, GlassEngravingWheel, GlassEngravingPoint, GlassEngravingDiamondPoint, GlassEngravingCopperWheel, GlassEngravingWheelDressingStone — 5 multi-prereq!), STEKLO REZBARSTVO+ chain, 186→192 deps, 48→49 verig, 93→98 multi-prereq; MEJNIK 192 deps, 49 verig, 98 multi-prereq (12.25x začetnih 8!); 2 CROSS-CHAIN povezave: GlassEngravingPointMaker+GlassEngravingWheelDressingStoneMaker→GlassBench (Steklarstvo+), GlassEngravingDiamondPointMaker→GemMiner (Mining+)
- ✅ **v3.11.992**: Glass Annealing+ Chain — 6 novih deps za obstoječe sisteme z žarilno opremo za steklo (GlassAnnealingOven, GlassAnnealingOvenThermocouple, GlassAnnealingOvenInspectionMirror, GlassAnnealingRoller, GlassAnnealingCart, GlassAnnealingFork — 5 multi-prereq!), STEKLO ŽARENJE+ chain, 192→198 deps, 49→50 verig, 98→103 multi-prereq; MEJNIK 198 deps, 50 verig, 103 multi-prereq (12.875x začetnih 8! + MEJNIK 50 verig!); 3 CROSS-CHAIN povezave: GlassAnnealingOvenMaker→ForgeTuyere (Livarstvo+), GlassAnnealingOvenThermocoupleMaker+GlassAnnealingOvenInspectionMirrorMaker→GlassBench (Steklarstvo+)
- ✅ **v3.11.993**: Glass Colorant+ Chain — 6 novih deps za obstoječe sisteme z opremo za barvanje stekla (GlassColorantMortar, GlassColorantMortarPestle, GlassColorantMuller, GlassColorantSieve, GlassColorantSpatula, GlassColorantDryingTray — 5 multi-prereq!), STEKLO BARVILA+ chain, 198→204 deps, 50→51 verig, 103→108 multi-prereq; MEJNIK 204 deps, 51 verig, 108 multi-prereq (13.5x začetnih 8!); 3 CROSS-CHAIN povezave: GlassColorantMortarMaker+GlassColorantMullerMaker+GlassColorantSieveMaker→PigmentGrinderMaker (Barvila+), GlassColorantMortarMaker+GlassColorantMortarPestleMaker→MasonStonecutter (Kamnoseštvo+)
- ✅ **v3.11.994**: Glass Kiln+ Chain — 6 novih deps za obstoječe sisteme z opremo za steklarske peči (GlassKilnDoor, GlassKilnBrickSaw, GlassKilnFlueDamper, GlassKilnMuffle, GlassKilnFurniture, GlassKilnSootScraper — 5 multi-prereq!), STEKLO PEČ+ chain, 204→210 deps, 51→52 verig, 108→113 multi-prereq; MEJNIK 210 deps, 52 verig, 113 multi-prereq (14.125x začetnih 8!); 3 CROSS-CHAIN povezave: GlassKilnDoorMaker+GlassKilnBrickSawMaker+GlassKilnMuffleMaker+GlassKilnFurnitureMaker→MasonStonecutter (Kamnoseštvo+ — NOV REKORD 4 sistemi!), GlassKilnFlueDamperMaker+GlassKilnMuffleMaker→GlassBench (Steklarstvo+), Metalwork skupna povezava s Kovastvom+
- ✅ **v3.11.995**: Foundry Accessories+ 2 Chain — 6 novih deps za obstoječe livarske sisteme z naprednim priborom (SandMullerBlade, MoldFlaskAlignmentPin, CoreGasEscapeChannel, CastingLadleSkimmerHook, PouringLadleSpoutLiner, SandRiddle — 5 multi-prereq!), LIVARSKI PRIBOR+ 2 chain, 210→216 deps, 52→53 verig, 113→118 multi-prereq; MEJNIK 216 deps, 53 verig, 118 multi-prereq (14.75x začetnih 8!); 3 CROSS-CHAIN povezave: MoldFlaskAlignmentPinMaker→MasonStonecutter (Kamnoseštvo+), CoreGasEscapeChannelMaker+PouringLadleSpoutLinerMaker→GlassBench (Steklarstvo+), Metalwork skupna povezava s Kovastvom+
- ✅ **v3.11.996**: Glass Batch+ Chain — 6 novih deps za obstoječe sisteme s pripravo in taljenjem steklarske mešanice (GlassBatchFurnace, GlassBatchSmelter, GlassBatchMixer, GlassBatchFeeder, GlassBatch, GlassCulletCrusher — 5 multi-prereq!), STEKLO MEŠANICA+ chain, 216→222 deps, 53→54 verig, 118→123 multi-prereq; MEJNIK 222 deps, 54 verig, 123 multi-prereq (15.375x začetnih 8!); 3 CROSS-CHAIN povezave: GlassBatchFurnaceMaker+GlassBatchSmelter→ForgeTuyere (Livarstvo+), GlassBatchFeederMaker+GlassBatchMaker→MasonStonecutter (Kamnoseštvo+), Metalwork skupna povezava s Kovastvom+ (5 sistemov — NOV REKORD za eno verigo!)
- ✅ **v3.11.997**: Glass Forming Tools+ Chain — 6 novih deps za obstoječe sisteme z orodji za oblikovanje stekla (GlassMarver, GlassPuntyRod, GlassGatheringIron, GlassShears, GlassYoke, GlassLehrBelt — 5 multi-prereq!), STEKLO OBLIKOVANJE+ chain, 222→228 deps, 54→55 verig, 123→128 multi-prereq; MEJNIK 228 deps, 55 verig, 128 multi-prereq (16x začetnih 8!); 3 CROSS-CHAIN povezave: GlassMarverMaker→MasonStonecutter (Kamnoseštvo+), Metalwork skupna povezava s Kovastvom+ (5 sistemov), WoodLathe skupna povezava z Lesarstvom+ (4 sistemi)
- ✅ **v3.11.998**: Foundry Accessories+ 3 Chain (Sand/Mold/Core+ 2) — 6 novih deps za obstoječe livarske sisteme (SandMold, MoldDryingOven, MoldCoatingBrush, CoreOven, CorePasteMixer, MoldClamp — 5 multi-prereq!), LIVARSKI PRIBOR+ 3 chain, 228→234 deps, 55→56 verig, 128→133 multi-prereq; MEJNIK 234 deps, 56 verig, 133 multi-prereq (16.625x začetnih 8! + MEJNIK 56 verig!); 3 CROSS-CHAIN povezave: SandMoldMaker→MasonStonecutter (Kamnoseštvo+), MoldDryingOvenMaker+CoreOvenMaker→GlassBench (Steklarstvo+), MoldCoatingBrushMaker→PigmentGrinderMaker (Barvila+)
- ✅ **v3.11.999**: Foundry Accessories+ 4 Chain (Sand/Mold/Core+ 3) — 6 novih deps za obstoječe livarske sisteme (SandConditioner, SandCooler, MoldDryingStand, MoldWashBooth, CorePrintBox, MoldFlowTester — 5 multi-prereq!), LIVARSKI PRIBOR+ 4 chain, 234→240 deps, 56→57 verig, 133→138 multi-prereq; MEJNIK 240 deps, 57 verig, 138 multi-prereq (17.25x začetnih 8! + MEJNIK 240 deps!); 3 CROSS-CHAIN povezave: SandCoolerMaker→GlassBench (Steklarstvo+), MoldWashBoothMaker+CorePrintBoxMaker→MasonStonecutter (Kamnoseštvo+), Metalwork skupna povezava s Kovastvom+ (5 sistemov)
- ✅ **v3.12.000**: Foundry Accessories+ 5 Chain (Casting/Pouring+) — 6 novih deps za obstoječe livarske sisteme (CastingLadleNozzle, CastingLadlePreheatBurner, PouringLadle, PouringLadleLiningCement, PouringCrucibleTongs, CastingBreakoutChisel — 5 multi-prereq!), LIVARSKI PRIBOR+ 5 chain, 240→246 deps, 57→58 verig, 138→143 multi-prereq; VELIKI MEJNIK: prva različica v seriji v3.12! + 246 deps, 58 verig, 143 multi-prereq (17.875x začetnih 8!); 3 CROSS-CHAIN povezave: CastingLadleNozzleMaker→ForgeTuyere (Livarstvo+), CastingLadlePreheatBurnerMaker→GlassBench (Steklarstvo+), PouringLadleLiningCementMaker→MasonStonecutter (Kamnoseštvo+)
- ✅ **v3.12.001**: Foundry Accessories+ 6 Chain (Sand/Mold/Core+ 4) — 6 novih deps za obstoječe livarske sisteme (SandCaster, SandReclaimer, MoldKiln, MoldReleaseAgent, CoreDryingRack, CrucibleTongs — 5 multi-prereq!), LIVARSKI PRIBOR+ 6 chain, 246→252 deps, 58→59 verig, 143→148 multi-prereq; MEJNIK 252 deps, 59 verig, 148 multi-prereq (18.5x začetnih 8!); 3 CROSS-CHAIN povezave: SandReclaimerMaker+MoldReleaseAgentMaker→GlassBench (Steklarstvo+), MoldKilnMaker→MasonStonecutter (Kamnoseštvo+), Metalwork skupna povezava s Kovastvom+ (6 sistemov — NOV REKORD, izenačeno z v3.11.996!)
- ✅ **v3.12.002**: Foundry Accessories+ 7 Chain (Sand/Mold/Core+ 5) — 6 novih deps za obstoječe livarske sisteme (SandBinderDispenser, SandSieveShaker, MoldCoatingRoller, MoldFlaskClampWedge, CoreGasVentPin, PouringCone — 5 multi-prereq!), LIVARSKI PRIBOR+ 7 chain, 252→258 deps, 59→60 verig, 148→153 multi-prereq; MEJNIK 258 deps, 60 verig, 153 multi-prereq (19.125x začetnih 8! + MEJNIK 60 verig!); 3 CROSS-CHAIN povezave: SandBinderDispenserMaker+MoldFlaskClampWedgeMaker→MasonStonecutter (Kamnoseštvo+), MoldCoatingRollerMaker→PigmentGrinderMaker (Barvila+), CoreGasVentPinMaker→GlassBench (Steklarstvo+)
- ✅ **v3.12.003**: Foundry Accessories+ 8 Chain (Sand/Mold/Core+ 6 — FINAL) — 6 novih deps za obstoječe livarske sisteme (SandTestCup, Sander, MoldCoatBrushSpinner, MoldVentWireCleaner, CoreVarnishBrush, CoreWashingDip — 6 multi-prereq, prvič vsi multi!), LIVARSKI PRIBOR+ 8 chain, 258→264 deps, 60→61 verig, 153→159 multi-prereq; VELIKI MEJNIK: izčrpane Sand/Mold/Core skupine (36 sistemov v 6 paketih)! + MEJNIK 264 deps, 61 verig, 159 multi-prereq (19.875x začetnih 8!); 4 CROSS-CHAIN povezave (NOV REKORD za število različnih baz v eni verigi!): SandTestCupMaker→GlassBench (Steklarstvo+), MoldCoatBrushSpinnerMaker+CoreVarnishBrushMaker→PigmentGrinderMaker (Barvila+), CoreWashingDipMaker→MasonStonecutter (Kamnoseštvo+), Metalwork+WoodLathe skupna (5 sistemov)
- ✅ **v3.12.004**: Foundry Accessories+ 9 Chain (Casting/Pouring+ 2) — 6 novih deps za obstoječe livarske sisteme (CastingLadleLiningTrowel, CastingLadlePreheatStand, CastingLadleSkimmerHandle, PouringCrucibleDrier, PouringLadleLiner, PouringLadleSkimmerSieve — 6 multi-prereq, drugič zapored vsi multi!), LIVARSKI PRIBOR+ 9 chain, 264→270 deps, 61→62 verig, 159→165 multi-prereq; MEJNIK 270 deps, 62 verig, 165 multi-prereq (20.625x začetnih 8! — presežen mejnik 20x!); 3 CROSS-CHAIN povezave: CastingLadleLiningTrowelMaker→MasonStonecutter (Kamnoseštvo+), PouringCrucibleDrierMaker+PouringLadleLinerMaker→GlassBench (Steklarstvo+), Metalwork skupna povezava s Kovastvom+ (6 sistemov — drugi NOV REKORD, izenačeno z v3.12.001 in v3.11.996)
- ✅ **v3.12.005**: Glass Kiln Accessories+ 2 Chain — 6 novih deps za preostale sisteme z opremo za steklarske peči (GlassKilnDoorChain, GlassKilnDoorLifter, GlassKilnBrickTongs, GlassKilnSeal, GlassKilnSightingPortCover, GlassKilnSpy — 6 multi-prereq, tretjič zapored vsi multi!), STEKLO KILN PRIBOR+ chain, 270→276 deps, 62→63 verig, 165→171 multi-prereq; MEJNIK 276 deps, 63 verig, 171 multi-prereq (21.375x začetnih 8!); 3 CROSS-CHAIN povezave: GlassKilnDoorChainMaker+GlassKilnDoorLifterMaker+GlassKilnBrickTongsMaker+GlassKilnSealMaker→MasonStonecutter (Kamnoseštvo+ x4), GlassKilnSealMaker+GlassKilnSightingPortCoverMaker→GlassBench (Steklarstvo+), Metalwork skupna (Kovaštvo+ x5)
- ✅ **v3.12.006**: Glass Blowing+ 2 Chain — 6 novih deps za sisteme z opremo za pihanje stekla (GlassBench, GlassBlowerPipe, GlassBlowingMold, GlassBlowpipeCoolingRack, GlassCoolingRack, GlassPipeShears — 6 multi-prereq, 4. zapored vsi multi!), STEKLO PIHALSKO+ 2 chain, 276→282 deps, 63→64 verig, 171→177 multi-prereq; MEJNIK 282 deps, 64 verig, 177 multi-prereq (22.125x začetnih 8!); 3 CROSS-CHAIN povezave: GlassBenchMaker+GlassBlowingMoldMaker+GlassCoolingRackMaker→MasonStonecutter (Kamnoseštvo+ x3), GlassBlowerPipeMaker+GlassCoolingRackMaker→GlassBench (Steklarstvo+ x2), Metalwork skupna (Kovaštvo+ x4)
- ✅ **v3.12.007**: Glass Annealing+ 2 Chain — 6 novih deps za sisteme z žarilno opremo (GlassAnnealingCradle, GlassAnnealingOvenDoorWheel, GlassAnnealingTongJaws, GlassGloryHole, GlassGloryHoleDamper, GlassPuntyWarmer — 6 multi-prereq, 5. zapored vsi multi!), STEKLO ŽARENJE+ 2 chain, 282→288 deps, 64→65 verig, 177→183 multi-prereq; MEJNIK 288 deps, 65 verig, 183 multi-prereq (22.875x začetnih 8!); 3 CROSS-CHAIN povezave: GlassAnnealingCradleMaker+GlassGloryHoleMaker+GlassGloryHoleDamperMaker→MasonStonecutter (Kamnoseštvo+ x3), GlassAnnealingTongJawsMaker+GlassPuntyWarmerMaker→GlassBench (Steklarstvo+ x2), Metalwork skupna (Kovaštvo+ x5)
- ✅ **v3.12.008**: Glass Engraving+ 2 Chain — 6 novih deps za sisteme z gravirno/dokončevalno opremo (GlassEngravingLatheChuck, GlassEngravingWheelBearing, GlassEngravingWheelRest, GlassPolishingPad, GlassFrit, GlassShearSpring — 6 multi-prereq, 6. zapored vsi multi!), STEKLO REZBARSTVO+ 2 chain, 288→294 deps, 65→66 verig, 183→189 multi-prereq; MEJNIK 294 deps, 66 verig, 189 multi-prereq (23.625x začetnih 8!); 3 CROSS-CHAIN povezave: GlassEngravingLatheChuckMaker+GlassPolishingPadMaker+GlassFritMaker→GlassBench (Steklarstvo+ x3), GlassEngravingWheelRestMaker+GlassPolishingPadMaker→MasonStonecutter (Kamnoseštvo+ x2), Metalwork skupna (Kovaštvo+ x5)
- ✅ **v3.12.009**: Glass Finishing+ Chain — 6 novih deps za zadnje preostale sisteme z dokončevalno opremo stekla (GlassCaneSlicer, GlassColorantSievingCloth, GlassColorantVialShaker, GlassMoltenGlassSkimLadle, GlassRibbon, GlassSeed — 6 multi-prereq, 7. zapored vsi multi!), STEKLO DOKONČANJE+ chain, 294→300 deps, 66→67 verig, 189→195 multi-prereq; VELIKI MEJNIK: 300 deps (zaokroženo število)! + MEJNIK 300 deps, 67 verig, 195 multi-prereq (24.375x začetnih 8!); 4 CROSS-CHAIN povezave (NOV REKORD za število različnih baz v eni verigi!): GlassCaneSlicerMaker+GlassColorantVialShakerMaker+GlassSeedMaker→GlassBench (Steklarstvo+ x3), GlassColorantSievingClothMaker→PigmentGrinderMaker (Barvila+), GlassMoltenGlassSkimLadleMaker→MasonStonecutter (Kamnoseštvo+), Metalwork skupna (Kovaštvo+ x5)
- ✅ **v3.12.010**: Smith Quench+ Chain — 6 novih deps za sisteme s kalilno opremo (QuenchBucket, QuenchOilDipper, QuenchOilFilter, QuenchTankDrainValve, QuenchTankLidGasket, QuenchTankThermometer — 6 multi-prereq, 8. zapored vsi multi!), KOVAŠKI KVAČ+ chain, 300→306 deps, 67→68 verig, 195→201 multi-prereq; MEJNIK 306 deps, 68 verig, 201 multi-prereq (25.125x začetnih 8! — presežen mejnik 25x!); 3 CROSS-CHAIN povezave: QuenchOilFilterMaker+QuenchTankThermometerMaker→GlassBench (Steklarstvo+ x2), QuenchTankDrainValveMaker→MasonStonecutter (Kamnoseštvo+), Metalwork skupna (Kovaštvo+ x6)
- ✅ **v3.12.011**: Forge+ Chain — 6 novih deps za sisteme s kovaško pečjo (ForgeTuyereCooler, ForgeChimneyDamper, ForgeClinkerBreaker, ForgeAshPan, ForgeHoodFlue, ForgeCokeRake — 6 multi-prereq, 9. zapored vsi multi!), KOVAŠKA PEČ+ chain, 306→312 deps, 68→69 verig, 201→207 multi-prereq; MEJNIK 312 deps, 69 verig, 207 multi-prereq (25.875x začetnih 8!); 3 CROSS-CHAIN povezave: ForgeTuyereCoolerMaker+ForgeHoodFlueMaker→GlassBench (Steklarstvo+ x2), ForgeChimneyDamperMaker+ForgeClinkerBreakerMaker→MasonStonecutter (Kamnoseštvo+ x2), Metalwork skupna (Kovaštvo+ x5)
- ✅ **v3.12.012**: Smith+ Chain — 6 novih deps za sisteme z kovaškim orodjem (SmithHammerFacePolisher, SmithHammerHandleWedge, SmithHammerWedge, SmithTongsJawInsert, SmithTongsRing, SmithHammerHandleFinisher — 6 multi-prereq, 10. zapored vsi multi!), KOVAŠKO ORODJE+ chain, 312→318 deps, 69→70 verig, 207→213 multi-prereq; MEJNIK 318 deps, 70 verig, 213 multi-prereq (26.625x začetnih 8!); 3 CROSS-CHAIN povezave: SmithHammerFacePolisherMaker+SmithHammerWedgeMaker→MasonStonecutter (Kamnoseštvo+ x2), SmithTongsJawInsertMaker→GlassBench (Steklarstvo+), Metalwork skupna (Kovaštvo+ x5)
- ✅ **v3.12.013**: Leather+ Chain — 6 novih deps za sisteme z usnjenimi orodji (LeatherConditioner, LeatherCreaser, LeatherEdgeBeveler, LeatherSkiver, LeatherSplitter, Leatherworker — 6 multi-prereq, 11. zapored vsi multi!), USNJE+ 2 chain, 318→324 deps, 70→71 verig, 213→219 multi-prereq; MEJNIK 324 deps, 71 verig, 219 multi-prereq (27.375x začetnih 8!); 3 CROSS-CHAIN povezave: LeatherConditionerMaker+Leatherworker→RawhideTanner (Usnjarstvo+ x2), LeatherConditionerMaker→PigmentGrinderMaker (Barvila+), LeatherSkiverMaker→MasonStonecutter (Kamnoseštvo+)

## ZNANE NADGRADNJE ZA PRIHODNJE PAKETE

1. **Sprite-i za Royal sisteme** — trenutno so samo podatkovni, brez grafične podobe
2. **Tech tree node hover preview** — hover na vozlišče prikaže preview graf povezanih sistemov v tooltip box
3. **Keybind Help hover tooltip** — hover na keybind v F1 help prikaže dodatne podrobnosti o bližnjici
4. ~~**Armor/Weapon+ chain**~~ ✅ končano v v3.11.987 (5 multi-prereq, 2 CROSS-CHAIN: GemMiner←Mining+, RawhideTanner←Leatherwork+; 162→168 deps, 44→45 verig, 73→78 multi-prereq; MEJNIK 10x multi-prereq!)
5. ~~**Anvil+ chain**~~ ✅ končano v v3.11.988 (5 multi-prereq, 2 CROSS-CHAIN: GlassBench←Steklarstvo+, WoodLathe←Woodworking+; 168→174 deps, 45→46 verig, 78→83 multi-prereq; MEJNIK 10.4x multi-prereq!)
6. ~~**Garden+ 2 chain**~~ ✅ končano v v3.11.989 (5 multi-prereq, 3 CROSS-CHAIN: GlassBench←Steklarstvo+ x3 — prvič 3 sistemi z isto CROSS-CHAIN povezavo!; 174→180 deps, 46→47 verig, 83→88 multi-prereq; MEJNIK 11x multi-prereq!)
7. ~~**Mlinarski+ chain**~~ ✅ končano v v3.11.990 (5 multi-prereq, 3 CROSS-CHAIN: SpinningWheel←Tekstil+, GlassBench←Steklarstvo+, Metalwork←Kovastvo+; 180→186 deps, 47→48 verig, 88→93 multi-prereq; MEJNIK 11.6x multi-prereq!)
8. ~~**Glass Engraving+ chain**~~ ✅ končano v v3.11.991 (5 multi-prereq, 2 CROSS-CHAIN: GlassBench←Steklarstvo+ x2, GemMiner←Mining+; 186→192 deps, 48→49 verig, 93→98 multi-prereq; MEJNIK 12.25x multi-prereq!)
9. ~~**Glass Annealing+ chain**~~ ✅ končano v v3.11.992 (5 multi-prereq, 3 CROSS-CHAIN: ForgeTuyere←Livarstvo+, GlassBench←Steklarstvo+ x2; 192→198 deps, 49→50 verig, 98→103 multi-prereq; MEJNIK 50 verig in 12.875x multi-prereq!)
10. ~~**Glass Colorant+ chain**~~ ✅ končano v v3.11.993 (5 multi-prereq, 3 CROSS-CHAIN: PigmentGrinderMaker←Barvila+ x3, MasonStonecutter←Kamnoseštvo+ x2, Metalwork←Kovastvo+; 198→204 deps, 50→51 verig, 103→108 multi-prereq; MEJNIK 13.5x multi-prereq!)
11. ~~**Glass Kiln+ chain**~~ ✅ končano v v3.11.994 (5 multi-prereq, 3 CROSS-CHAIN: MasonStonecutter←Kamnoseštvo+ x4 NOV REKORD!, GlassBench←Steklarstvo+ x2, Metalwork←Kovastvo+ x4; 204→210 deps, 51→52 verig, 108→113 multi-prereq; MEJNIK 14.125x multi-prereq!)
12. ~~**Livarski pribor+ 2**~~ ✅ končano v v3.11.995 (5 multi-prereq, 3 CROSS-CHAIN: MasonStonecutter←Kamnoseštvo+, GlassBench←Steklarstvo+ x2, Metalwork←Kovastvo+ x4; 210→216 deps, 52→53 verig, 113→118 multi-prereq; MEJNIK 14.75x multi-prereq!)
13. ~~**Glass Batch/Smelter+ chain**~~ ✅ končano v v3.11.996 (5 multi-prereq, 3 CROSS-CHAIN: ForgeTuyere←Livarstvo+ x2, MasonStonecutter←Kamnoseštvo+ x2, Metalwork←Kovastvo+ x5 NOV REKORD!; 216→222 deps, 53→54 verig, 118→123 multi-prereq; MEJNIK 15.375x multi-prereq!)
14. ~~**Glass Forming Tools+ chain**~~ ✅ končano v v3.11.997 (5 multi-prereq, 3 CROSS-CHAIN: MasonStonecutter←Kamnoseštvo+, Metalwork←Kovastvo+ x5, WoodLathe←Woodworking+ x4; 222→228 deps, 54→55 verig, 123→128 multi-prereq; MEJNIK 16x multi-prereq!)
15. ~~**Sand/Mold/Core+ 2 chain**~~ ✅ končano v v3.11.998 (5 multi-prereq, 3 CROSS-CHAIN: MasonStonecutter←Kamnoseštvo+, GlassBench←Steklarstvo+ x2, PigmentGrinderMaker←Barvila+; 228→234 deps, 55→56 verig, 128→133 multi-prereq; MEJNIK 56 verig in 16.625x multi-prereq!)
16. ~~**Sand/Mold/Core+ 3 chain**~~ ✅ končano v v3.11.999 (5 multi-prereq, 3 CROSS-CHAIN: GlassBench←Steklarstvo+, MasonStonecutter←Kamnoseštvo+ x2, Metalwork←Kovastvo+ x5; 234→240 deps, 56→57 verig, 133→138 multi-prereq; MEJNIK 240 deps in 17.25x multi-prereq!)
17. ~~**Casting/Pouring+ chain**~~ ✅ končano v v3.12.000 (5 multi-prereq, 3 CROSS-CHAIN: ForgeTuyere←Livarstvo+, GlassBench←Steklarstvo+, MasonStonecutter←Kamnoseštvo+; 240→246 deps, 57→58 verig, 138→143 multi-prereq; VELIKI MEJNIK: prva različica v seriji v3.12! + 17.875x multi-prereq!)
18. ~~**Sand/Mold/Core+ 4 chain**~~ ✅ končano v v3.12.001 (5 multi-prereq, 3 CROSS-CHAIN: GlassBench←Steklarstvo+ x2, MasonStonecutter←Kamnoseštvo+, Metalwork←Kovastvo+ x6 NOV REKORD!; 246→252 deps, 58→59 verig, 143→148 multi-prereq; MEJNIK 18.5x multi-prereq!)
19. ~~**Sand/Mold/Core+ 5 chain**~~ ✅ končano v v3.12.002 (5 multi-prereq, 3 CROSS-CHAIN: MasonStonecutter←Kamnoseštvo+ x2, PigmentGrinderMaker←Barvila+, GlassBench←Steklarstvo+; 252→258 deps, 59→60 verig, 148→153 multi-prereq; MEJNIK 60 verig in 19.125x multi-prereq!)
20. ~~**Sand/Mold/Core+ 6 chain**~~ ✅ končano v v3.12.003 (6 multi-prereq — prvič vsi multi!, 4 CROSS-CHAIN NOV REKORD!: GlassBench←Steklarstvo+, PigmentGrinderMaker←Barvila+ x2, MasonStonecutter←Kamnoseštvo+, Metalwork+WoodLathe skupna; 258→264 deps, 60→61 verig, 153→159 multi-prereq; VELIKI MEJNIK: izčrpane Sand/Mold/Core skupine (36 sistemov v 6 paketih)! + MEJNIK 19.875x multi-prereq!)
21. ~~**Casting/Pouring+ 2 chain**~~ ✅ končano v v3.12.004 (6 multi-prereq — drugič zapored vsi multi!, 3 CROSS-CHAIN: MasonStonecutter←Kamnoseštvo+, GlassBench←Steklarstvo+ x2, Metalwork←Kovastvo+ x6; 264→270 deps, 61→62 verig, 159→165 multi-prereq; MEJNIK 20.625x multi-prereq — presežen mejnik 20x!)
22. **Kirurgija+ chain 2** — dodatni kirurški deps (ApothecaryMortarMaker, ApothecaryVialMaker, SalveJarMaker so kandidati; npr. ApothecaryVialMaker → GlassBench + PotteryWheel CROSS-CHAIN)
23. **Astrologija+ chain 2** — dodatni astronomski deps (npr. Telescope → GlassBench + Metalwork za tube)
24. **Glass Glory Hole+ chain** — GlassGloryHole* sistemi so brez deps (GlassGloryHole, GlassGloryHoleDamper); 2 kandidata, manjša priložnost
25. **Glass Remaining+ chain** — preostali Glass* sistemi (31 kandidatov) so brez deps; velika priložnost za več zaporednih verig
26. **Casting/Pouring+ 3 chain** — preostali 1 Casting* (CastingLadleSkimmerMaker) sistem je brez deps; majhna priložnost za še eno verigo z drugimi sistemi

## ZADNJE ZAKLJUČENI PAKET (v3.11.892–v3.11.901) — STEKLARSKI DODATKI 13 + LIVARSKI DODATKI 13

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 13 (v3.11.892-v3.11.896)
8. **RoyalGlassMoltenGlassSkimLadleMakerSystem.lua** → `local GlassMoltenGlassSkimLadleMaker` (zajemalke za strgalce)
9. **RoyalGlassKilnSootScraperMakerSystem.lua** → `local GlassKilnSootScraperMaker` (strgalci za sajne)
10. **RoyalGlassColorantSievingClothMakerSystem.lua** → `local GlassColorantSievingClothMaker` (krpe za sitanje)
11. **RoyalGlassAnnealingOvenThermocoupleMakerSystem.lua** → `local GlassAnnealingOvenThermocoupleMaker` (termoelementi)
12. **RoyalGlassEngravingWheelBearingMakerSystem.lua** → `local GlassEngravingWheelBearingMaker` (lezaji za kolesa)

### Livarski dodatki 13 (v3.11.897-v3.11.901)
13. **RoyalMoldCoatBrushSpinnerMakerSystem.lua** → `local MoldCoatBrushSpinnerMaker` (vrtilci za copice)
14. **RoyalPouringLadleSpoutLinerMakerSystem.lua** → `local PouringLadleSpoutLinerMaker` (obloge za izlive)
15. **RoyalSandTestCupMakerSystem.lua** → `local SandTestCupMaker` (skodelice za testiranje)
16. **RoyalCoreGasEscapeChannelMakerSystem.lua** → `local CoreGasEscapeChannelMaker` (kanali za plin)
17. **RoyalCastingLadlePreheatStandMakerSystem.lua** → `local CastingLadlePreheatStandMaker` (stojala za predgrevanje)

### PRE-FLIGHT CHECK
Vseh 10 datotek: 0 prior commits, absent — brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_glass13_foundry13_systems.py`
- Sintakticna preverba: `/home/z/my-project/scripts/check_new_systems_syntax.py`
- Vseh 10 novih datotek PASS sintakticne preverbe (lupa load())

## PATTERN ZA VSAK SISTEM

Vsak sistem mora imeti:
- 6 produktov (zelezni -> bronasti -> srebrni -> pozlaceni -> draguljasti -> kraljevski suvereni)
- 4 zgradbe (delavnica, hisa, mojstrski atelje, suverena palsa)
- Funkcije: `init`, `hireMaker`, `canBuild`, `build`, `getQualityBonus`, `canMake`, `make`, `completeMaking`, `update`, `getStats`
- `_G.NotificationCenter.notify` in `_G.GameEventBus.publish` s pcall
- Vraca lokalno tabelo
- Slovenian product/building names
- **POMEMBNO**: V `completeMaking` uporabljaj `productStock[m.productType]` (z `[m.` pred `productType]`) — ne `productStock.productType]` (to je okvarjena sintaksa)

## NASLEDNJI PAKET (v3.11.902–v3.11.911) — KNJIGOVEŠKI DODATKI 13 + KOVAŠKI DODATKI 13

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 13 (v3.11.902-v3.11.906) — predloga
18. **RoyalBookSpineRibbonMarkerMakerSystem.lua** → `local BookSpineRibbonMarkerMaker` (oznake z trakovi za hrbte)
19. **RoyalBookCoverPastePotLidMakerSystem.lua** → `local BookCoverPastePotLidMaker` (pokrovi za lepilne lončke)
20. **RoyalBookSewingCordTensionerMakerSystem.lua** → `local BookSewingCordTensionerMaker` (napenjalci za šivalne vrvice)
21. **RoyalBookEdgeGiltSizeDryingRackMakerSystem.lua** → `local BookEdgeGiltSizeDryingRackMaker` (police za sušenje pozlate)
22. **RoyalBookCoverBoardGrooveMakerSystem.lua** → `local BookCoverBoardGrooveMaker` (žlebovi za vezave)

### Kovaški dodatki 13 (v3.11.907-v3.11.911) — predloga
23. **RoyalForgeCoalChuteMakerSystem.lua** → `local ForgeCoalChuteMaker` (žlebovi za oglje)
24. **RoyalAnvilBasePlateMakerSystem.lua** → `local AnvilBasePlateMaker` (osnovne plošče za nakovalo)
25. **RoyalForgeDraftInducerMakerSystem.lua** → `local ForgeDraftInducerMaker` (vlečniki za vlek)
26. **RoyalQuenchTankThermometerMakerSystem.lua** → `local QuenchTankThermometerMaker` (termometri za kadi)
27. **RoyalSmithHammerHandleFinisherMakerSystem.lua** → `local SmithHammerHandleFinisherMaker` (končalci ročajev)

## WORKFLOW ZA NASLEDNJI PAKET

28. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 nacrtovanih datotek
2. Ustvari 10 .lua datotek z generatorsko skripto
3. Pozeni sintakticno preverbo
4. Posodobi CHANGELOG.md, README.md badge-je, NEXT_BATCH_HANDOFF.md
5. Git: commit, tag (v3.11.902 do v3.11.911), push
6. Build .love

## SPOROCILO ZA NOVO SEJO

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna razlicica je v3.11.901. Naslednji paket je v3.11.902–v3.11.911 (knjigoveski dodatki 13 + kovaski dodatki 13: BookSpineRibbonMarkerMaker, BookCoverPastePotLidMaker, BookSewingCordTensionerMaker, BookEdgeGiltSizeDryingRackMaker, BookCoverBoardGrooveMaker, ForgeCoalChuteMaker, AnvilBasePlateMaker, ForgeDraftInducerMaker, QuenchTankThermometerMaker, SmithHammerHandleFinisherMaker). Sledi navodilom v handoff dokumentu. Po koncanem paketu rocno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.902–v3.11.906: knjigoveski dodatki 13 (BookSpineRibbonMarkerMaker, BookCoverPastePotLidMaker, BookSewingCordTensionerMaker, BookEdgeGiltSizeDryingRackMaker, BookCoverBoardGrooveMaker)
- v3.11.907–v3.11.911: kovaski dodatki 13 (ForgeCoalChuteMaker, AnvilBasePlateMaker, ForgeDraftInducerMaker, QuenchTankThermometerMaker, SmithHammerHandleFinisherMaker)
- v3.11.912–v3.11.916: vrtni dodatki 13 (predlagano)
- v3.11.917–v3.11.921: mlinarski dodatki 13 (predlagano)
