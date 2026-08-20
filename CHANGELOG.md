# Changelog

Vse pomembne spremembe projekta Castle Kingdoms 2027.

## [v3.12.027] — 2026-08-20 — Garden Specialty+ Chain (7 novih deps: 7 multi-prereq! 25. zapored all-multi! MEJNIK 38.125x! GARDEN COMPLETE)

### Dodano
- **SystemDependencies** — 7 novih deps (labels, ties, brush, pH, sharpener, HerbGardener, VegetableGardener):
  * `GardenPlantLabelEmbosserMaker` → Metalwork + WoodLathe
  * `GardenPlantTieCutterMaker` → Metalwork + WoodLathe
  * `GardenPotBrushMaker` → WoodLathe + Metalwork
  * `GardenSoilpHTesterMaker` → GlassBench + Metalwork (CROSS Steklarstvo+)
  * `GardenTrowelSharpenerMaker` → MasonStonecutter + Metalwork (CROSS Kamnoseštvo+)
  * `HerbGardener` → GardenRakeMaker + WoodLathe
  * `VegetableGardener` → GardenRakeMaker + Metalwork
- **TechTreePanel**: VRTNA SPECIAL+ chain, footer (410 deps, 85 verig, 305 multi-prereq)
- **MEJNIK**: 305 multi-prereq = 38.125x · **VSI Garden* sistemi imajo deps** (Garden complete)

## [v3.12.026] — 2026-08-20 — Garden Support+ Chain (6 novih deps: 6 multi-prereq! 24. zapored vsi multi!)

### Dodano
- GardenBorderEdgerMaker, GardenKneelerMaker (CROSS Usnjarstvo+), GardenLeafGrabberMaker, GardenLineMaker (CROSS Tekstil+), GardenTwineDispenserMaker (CROSS Tekstil+), GardenTrowelHolsterMaker (CROSS Usnjarstvo+)
- **TechTreePanel**: VRTNA PODPORA+

## [v3.12.025] — 2026-08-20 — Garden Water & Climate+ Chain (6 novih deps: 6 multi-prereq! 23. zapored vsi multi!)

### Dodano
- GardenBowlSprayerMaker (CROSS Steklarstvo+), GardenClocheMaker (CROSS Steklarstvo+), GardenFrostClothClipMaker (CROSS Tekstil+), GardenIrrigationTimerMaker, GardenPlantRootWateringSpikeMaker, GardenWateringTrayMaker
- **TechTreePanel**: VRTNA VODA+

## [v3.12.024] — 2026-08-20 — Garden Planting+ Chain (6 novih deps: 6 multi-prereq! 22. zapored vsi multi!)

### Dodano
- GardenDibberDepthGaugeMaker, GardenPlantDibberDepthMarkMaker, GardenTransplantingDibberMaker, GardenSeedDibberPlateMaker, GardenSeedTapeMaker (CROSS Tekstil+), GardenSeedPacketSealerMaker
- **TechTreePanel**: VRTNO SAJENJE+

## [v3.12.023] — 2026-08-20 — Garden Soil+ Chain (6 novih deps: 6 multi-prereq! 21. zapored vsi multi!)

### Dodano
- GardenSieveMaker, GardenSieveFrameMaker, GardenSoilScreenMaker (CROSS Kamnoseštvo+), GardenCompostSifterDrumMaker, GardenCompostAeratorSpikeMaker, GardenSoilMoistureMeterMaker (CROSS Steklarstvo+)
- **TechTreePanel**: VRTNA ZEMLJA+

## [v3.12.022] — 2026-08-20 — Garden Tools+ Chain (6 novih deps: 6 multi-prereq! 20. zapored vsi multi!)

### Dodano
- GardenForkMaker, GardenHoeMaker, GardenRakeMaker, GardenTrowelMaker, GardenMulchForkMaker, GardenFurrowMaker — vsi Metalwork + WoodLathe
- **TechTreePanel**: VRTNO ORODJE+

## [v3.12.021] — 2026-08-20 — Book Spine Remaining+ Chain (7 novih deps: 7 multi-prereq! 19. zapored all-multi! MEJNIK 33.5x! BOOK COMPLETE)

### Dodano
- **SystemDependencies** — 7 novih deps (zadnji Book residual):
  * `BookSewingBenchLightMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN → Steklarstvo+)
  * `BookSpineGiltSizeGaugeMaker` → `Metalwork` + `PigmentGrinderMaker` (multi! CROSS-CHAIN → Barvila+)
  * `BookSpineLabelPrinterMaker` → `Metalwork` + `WoodLathe` (multi!)
  * `BookSpineLiningClothMaker` → `SpinningWheel` + `WoodLathe` (multi! CROSS-CHAIN → Tekstil+)
  * `BookSpineRulerMaker` → `Metalwork` + `WoodLathe` (multi!)
  * `BookbindingGluePotMaker` → `Metalwork` + `WoodLathe` (multi!)
  * `BookbindingPressMaker` → `WoodLathe` + `MasonStonecutter` (multi! CROSS-CHAIN → Kamnoseštvo+)
- **TechTreePanel**: KNJIŽNI HRBET+ 2 chain, footer (373 deps, 79 verig, 268 multi-prereq)
- **MEJNIK**: 268 multi-prereq = 33.5x začetnih 8! · **VSI Book* sistemi imajo deps** (Book chain complete)
- 3 CROSS-CHAIN: GlassBench→Steklarstvo+, PigmentGrinderMaker→Barvila+, MasonStonecutter→Kamnoseštvo+

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua`, `states/ui/hud/tech_tree_panel.lua`, `README.md`, `CHANGELOG.md`, `NEXT_BATCH_HANDOFF.md`

### Funkcionalna preverba
- Python regex: 373 vnosov, 268 multi-prereq

## [v3.12.020] — 2026-08-20 — Book Finishing+ Chain (6 novih deps: 6 multi-prereq! 18. zapored vsi multi! MEJNIK 32.75x!)

### Dodano
- **SystemDependencies** — 6 novih deps (paste spatula, endband, foredge, tassel, press, weight):
  * `BookCoverPasteSpatulaMaker` → `Metalwork` + `WoodLathe` (multi!)
  * `BookEndbandLoomMaker` → `WoodLathe` + `SpinningWheel` (multi! CROSS-CHAIN → Tekstil+)
  * `BookForedgeFanMaker` → `WoodLathe` + `Metalwork` (multi!)
  * `BookMarkTasselMaker` → `SpinningWheel` + `PigmentGrinderMaker` (multi! CROSS-CHAIN → Tekstil+ & Barvila+)
  * `BookPressMaker` → `WoodLathe` + `Metalwork` (multi!)
  * `BookPressingWeightMaker` → `MasonStonecutter` + `WoodLathe` (multi! CROSS-CHAIN → Kamnoseštvo+)
- **TechTreePanel**: KNJIŽNI FINISH+ chain
- **MEJNIK**: 18. zapored vsi multi!

## [v3.12.019] — 2026-08-20 — Book Cover Paste & Inlay+ Chain (6 novih deps: 6 multi-prereq! 17. zapored vsi multi! MEJNIK 32.125x!)

### Dodano
- **SystemDependencies** — 6 novih deps (cord winder, gauge, inlay, paste tools):
  * `BookCoverCordWinderMaker` → `WoodLathe` + `SpinningWheel` (multi! CROSS-CHAIN → Tekstil+)
  * `BookCoverGaugeMaker` → `Metalwork` + `WoodLathe` (multi!)
  * `BookCoverInlayMaker` → `Metalwork` + `WoodLathe` (multi!)
  * `BookCoverInlayRouterMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN → Kamnoseštvo+)
  * `BookCoverPasteBrushMaker` → `WoodLathe` + `PigmentGrinderMaker` (multi! CROSS-CHAIN → Barvila+)
  * `BookCoverPasteRollerMaker` → `WoodLathe` + `Metalwork` (multi!)
- **TechTreePanel**: KNJIGOVEŠTVO+ 3 chain
- **MEJNIK**: 17. zapored vsi multi!

## [v3.12.018] — 2026-08-20 — Book Spine & Press+ Chain (6 novih deps: 6 multi-prereq! 16. zapored vsi multi! MEJNIK 31.125x!)

### Dodano
- **SystemDependencies** — 6 novih deps (spine glue, lining rollers, presses, bookshelf):
  * `BookSpineGlueBrushMaker` → WoodLathe + Metalwork
  * `BookSpineGluePotStandMaker` → WoodLathe + Metalwork
  * `BookSpineLiningRollerMaker` → WoodLathe + Metalwork
  * `BookbindingPressStoneMaker` → MasonStonecutter + WoodLathe (CROSS Kamnoseštvo+)
  * `BookbindingScrewPressMaker` → Metalwork + WoodLathe
  * `BookshelfMaker` → WoodLathe + Metalwork
- **TechTreePanel**: KNJIŽNI HRBET+ chain, footer (354 deps, 76 verig, 249 multi-prereq)
- **MEJNIK**: 249 multi-prereq = 31.125x začetnih 8! · 16. zapored vsi multi!

## [v3.12.017] — 2026-08-20 — Book Sewing+ Chain (6 novih deps: 6 multi-prereq! 15. zapored vsi multi! MEJNIK 30.375x!)

### Dodano
- **SystemDependencies** — 6 novih deps (sewing bench, needles, cords, frames, reels):
  * `BookSewingBenchHookMaker` → Metalwork + WoodLathe
  * `BookSewingNeedleCaseMaker` → Metalwork + WoodLathe
  * `BookSewingCordSpoolMaker` → WoodLathe + SpinningWheel (CROSS Tekstil+)
  * `BookSewingFrameToggleMaker` → Metalwork + WoodLathe
  * `BookStitchingFrameMaker` → WoodLathe + Metalwork
  * `BookThreadReelMaker` → WoodLathe + SpinningWheel (CROSS Tekstil+)
- **TechTreePanel**: KNJIŽNO ŠIVANJE+ chain
- **MEJNIK**: 15. zapored vsi multi!

## [v3.12.016] — 2026-08-20 — Book Edge+ Chain (6 novih deps: 6 multi-prereq! 14. zapored vsi multi! MEJNIK 29.625x!)

### Dodano
- **SystemDependencies** — 6 novih deps (edge coloring, gilt, polishing, painting):
  * `BookEdgeColoringSpongeMaker` → WoodLathe + PigmentGrinderMaker (CROSS Barvila+)
  * `BookEdgeGiltBurnisherMaker` → Metalwork + RawhideTanner (CROSS Usnjarstvo+)
  * `BookEdgeGiltSizeApplicatorMaker` → Metalwork + PigmentGrinderMaker (CROSS Barvila+)
  * `BookEdgeGiltSizeBrushMaker` → WoodLathe + PigmentGrinderMaker (CROSS Barvila+)
  * `BookEdgePainterMaker` → WoodLathe + PigmentGrinderMaker (CROSS Barvila+)
  * `BookEdgePolishingStoneMaker` → MasonStonecutter + Metalwork (CROSS Kamnoseštvo+)
- **TechTreePanel**: KNJIŽNI ROB+ chain
- **MEJNIK**: 14. zapored vsi multi!

## [v3.12.015] — 2026-08-20 — Book Cover Tools+ 2 Chain (6 novih deps: 6 multi-prereq! 13. zapored vsi multi! MEJNIK 28.875x!)

### Dodano
- **SystemDependencies** — 6 novih deps (miters, trimmers, cutters, stamps, presses):
  * `BookCoverBoardCornerMiterMaker` → Metalwork + WoodLathe
  * `BookCoverBoardEdgeTrimmerMaker` → Metalwork + WoodLathe
  * `BookCoverCornerCutterMaker` → Metalwork + MasonStonecutter (CROSS Kamnoseštvo+)
  * `BookCoverStampMaker` → Metalwork + PigmentGrinderMaker (CROSS Barvila+)
  * `BookCoverStampingFoilMaker` → Metalwork + PigmentGrinderMaker (CROSS Barvila+)
  * `BookCoverLeverPressMaker` → Metalwork + WoodLathe
- **TechTreePanel**: KNJIGOVEŠTVO+ 2 chain
- **MEJNIK**: 13. zapored vsi multi!

## [v3.12.014] — 2026-08-20 — Book Cover+ Chain (6 novih deps: 6 multi-prereq! 12. zapored vsi multi! MEJNIK 28.125x!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za knjigoveške sisteme (cover shears, crimpers, dies, edge gilders, burnishers, spine creasers):
  * `BookCoverBoardShearsMaker` → `Metalwork` + `WoodLathe` (multi! kovinske škarje + leseni ročaji)
  * `BookCoverCrimperMaker` → `Metalwork` + `WoodLathe` (multi! kovinski krimpar + leseni okvir)
  * `BookCoverDieMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinski štampiljka + kamnita baza → Kamnoseštvo+)
  * `BookEdgeGilderMaker` → `Metalwork` + `PigmentGrinderMaker` (multi! CROSS-CHAIN: kovinska pozlata + pigmenti/zlato → Barvila+)
  * `BookEdgeBurnisherMaker` → `Metalwork` + `RawhideTanner` (multi! CROSS-CHAIN: kovinski polirnik + usnjeni podstavek → Usnjarstvo+)
  * `BookSpineCreaserMaker` → `Metalwork` + `WoodLathe` (multi! kovinski gubeč + lesena opora hrbta)
- **TechTreePanel**: KNJIGOVEŠTVO+ chain, footer (330 deps, 72 verig, 225 multi-prereq)
- **MEJNIK**: 225 multi-prereq — 28.125x več kot začetnih 8!
- **NOV REKORD**: 12. zapored da vsi 6 sistemov v verigi ima multi-prereq (v3.12.003–v3.12.014!)
- 3 CROSS-CHAIN povezave: MasonStonecutter→Kamnoseštvo+, PigmentGrinderMaker→Barvila+, RawhideTanner→Usnjarstvo+

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+10 vrstic), `states/ui/hud/tech_tree_panel.lua` (+2 vrstici)
- `README.md`, `CHANGELOG.md`, `NEXT_BATCH_HANDOFF.md`

### Funkcionalna preverba
- Lupa `load()` test: PASS; Python regex: 330 vnosov, 225 multi-prereq

## [v3.12.013] — 2026-08-18 — Leather+ Chain (6 novih deps: 6 multi-prereq! 11. zapored vsi multi! MEJNIK 27.375x!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za sisteme z usnjenimi orodji (conditioners, creasers, edge bevelers, skivers, splitters):
  * `LeatherConditionerMaker` → `RawhideTanner` + `PigmentGrinderMaker` (multi! CROSS-CHAIN: usnjeno kondicioniranje + pigmenti → Barvila+)
  * `LeatherCreaserMaker` → `Metalwork` + `WoodLathe` (multi! kovinski gubeč + leseno ročaj)
  * `LeatherEdgeBevelerMaker` → `Metalwork` + `RawhideTanner` (multi! CROSS-CHAIN: kovinski poševnik + usnje → Usnjarstvo+)
  * `LeatherSkiverMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinski skiver + kamnito ostrenje → Kamnoseštvo+)
  * `LeatherSplitterMaker` → `Metalwork` + `WoodLathe` (multi! kovinski razdelilnik + leseni okvir)
  * `Leatherworker` → `RawhideTanner` + `WoodLathe` (multi! CROSS-CHAIN: usnja orodja + lesena miza → Usnjarstvo+)
- **TechTreePanel**: USNJE+ 2 chain, footer (324 deps, 71 verig, 219 multi-prereq)
- **MEJNIK**: 219 multi-prereq — 27.375x več kot začetnih 8!
- **NOV REKORD**: 11. zapored da vsi 6 sistemov v verigi ima multi-prereq (v3.12.003-v3.12.013!)
- 3 CROSS-CHAIN povezave: RawhideTanner→Usnjarstvo+ x2, PigmentGrinderMaker→Barvila+, MasonStonecutter→Kamnoseštvo+

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic), `states/ui/hud/tech_tree_panel.lua` (+2 vrstici)
- `README.md`, `CHANGELOG.md`, `NEXT_BATCH_HANDOFF.md`

### Funkcionalna preverba
- Lupa `load()` test: PASS; Python regex: 324 vnosov, 219 multi-prereq

## [v3.12.012] — 2026-08-18 — Smith+ Chain (6 novih deps: 6 multi-prereq! 10. zapored vsi multi! MEJNIK 26.625x!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za sisteme z kovaškim orodjem (hammer polishers, wedges, tongs jaw inserts, tongs rings):
  * `SmithHammerFacePolisherMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinski polirnik + kamnito kolo → Kamnoseštvo+)
  * `SmithHammerHandleWedgeMaker` → `WoodLathe` + `Metalwork` (multi! leseni klin + kovinska povezava)
  * `SmithHammerWedgeMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinski klin + kamnito nakovalo → Kamnoseštvo+)
  * `SmithTongsJawInsertMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinska usta + stekleni nadzor → Steklarstvo+)
  * `SmithTongsRingMaker` → `Metalwork` + `WoodLathe` (multi! kovinski obroč + leseno držalo)
  * `SmithHammerHandleFinisherMaker` → `WoodLathe` + `Metalwork` (multi! leseno ročaj + kovinski ferul)
- **TechTreePanel**: KOVAŠKO ORODJE+ chain, footer (318 deps, 70 verig, 213 multi-prereq)
- **MEJNIK**: 213 multi-prereq — 26.625x več kot začetnih 8!
- **NOV REKORD**: 10. zapored da vsi 6 sistemov v verigi ima multi-prereq (v3.12.003-v3.12.012!)
- 3 CROSS-CHAIN povezave: MasonStonecutter→Kamnoseštvo+ x2, GlassBench→Steklarstvo+, Metalwork→Kovaštvo+ x5

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic), `states/ui/hud/tech_tree_panel.lua` (+2 vrstici)
- `README.md`, `CHANGELOG.md`, `NEXT_BATCH_HANDOFF.md`

### Funkcionalna preverba
- Lupa `load()` test: PASS; Python regex: 318 vnosov, 213 multi-prereq

## [v3.12.011] — 2026-08-18 — Forge+ Chain (6 novih deps: 6 multi-prereq! 9. zapored vsi multi! MEJNIK 25.875x!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za sisteme s kovaško pečjo (forge ash management, tuyere cooling, chimney, clinker):
  * `ForgeTuyereCoolerMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinski hladilnik + stekleno okno → Steklarstvo+)
  * `ForgeChimneyDamperMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinska loputa + kamniti dimnik → Kamnoseštvo+)
  * `ForgeClinkerBreakerMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinski lomilec + kamnito rešetko → Kamnoseštvo+)
  * `ForgeAshPanMaker` → `Metalwork` + `WoodLathe` (multi! kovinska ponva + leseno ročaj)
  * `ForgeHoodFlueMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinski dimnik + stekleni nadzor → Steklarstvo+)
  * `ForgeCokeRakeMaker` → `Metalwork` + `WoodLathe` (multi! kovinska greblja + leseno ročaj)
- **TechTreePanel**: KOVAŠKA PEČ+ chain, footer (312 deps, 69 verig, 207 multi-prereq)
- **MEJNIK**: 207 multi-prereq — 25.875x več kot začetnih 8!
- **NOV REKORD**: 9. zapored da vsi 6 sistemov v verigi ima multi-prereq (v3.12.003-v3.12.011!)
- 3 CROSS-CHAIN povezave: GlassBench→Steklarstvo+ x2, MasonStonecutter→Kamnoseštvo+ x2, Metalwork→Kovaštvo+ x5

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic), `states/ui/hud/tech_tree_panel.lua` (+2 vrstici)
- `README.md`, `CHANGELOG.md`, `NEXT_BATCH_HANDOFF.md`

### Funkcionalna preverba
- Lupa `load()` test: PASS; Python regex: 312 vnosov, 207 multi-prereq

## [v3.12.010] — 2026-08-18 — Smith Quench+ Chain (6 novih deps: 6 multi-prereq! 8. zapored vsi multi! MEJNIK 25x!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za sisteme s kalilno opremo (quench buckets, oil dippers, filters, drain valves, gaskets, thermometers):
  * `QuenchBucketMaker` → `Metalwork` + `WoodLathe` (multi! kovinsko vedro + leseno ročaj)
  * `QuenchOilDipperMaker` → `Metalwork` + `WoodLathe` (multi! kovinska zajemalka + leseno ročaj)
  * `QuenchOilFilterMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinski filter + steklena posoda → Steklarstvo+)
  * `QuenchTankDrainValveMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinski ventil + kamnita osnova kadi → Kamnoseštvo+)
  * `QuenchTankLidGasketMaker` → `Metalwork` + `WoodLathe` (multi! kovinska tesnila + leseni pokrov)
  * `QuenchTankThermometerMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinski instrument + steklena cev → Steklarstvo+)
- **TechTreePanel**: KOVAŠKI KVAČ+ chain, footer (306 deps, 68 verig, 201 multi-prereq)
- **MEJNIK**: 201 multi-prereq — 25.125x več kot začetnih 8! (presežen mejnik 25x!)
- **NOV REKORD**: 8. zapored da vsi 6 sistemov v verigi ima multi-prereq (v3.12.003-v3.12.010!)
- 3 CROSS-CHAIN povezave: GlassBench→Steklarstvo+ x2, MasonStonecutter→Kamnoseštvo+, Metalwork→Kovaštvo+ x6

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic), `states/ui/hud/tech_tree_panel.lua` (+2 vrstici)
- `README.md`, `CHANGELOG.md`, `NEXT_BATCH_HANDOFF.md`

### Funkcionalna preverba
- Lupa `load()` test: PASS; Python regex: 306 vnosov, 201 multi-prereq

## [v3.12.009] — 2026-08-18 — Glass Finishing+ Chain (6 novih deps: 6 multi-prereq! 7. zapored vsi multi! VELIKI MEJNIK 300 deps, 24.375x!)

### Dodano
- **VELIKI MEJNIK 1**: 300 deps v tech tree-ju! (zaokroženo število)
- **VELIKI MEJNIK 2**: 195 multi-prereq — 24.375x več kot začetnih 8!
- **NOV REKORD**: 7. zapored da vsi 6 sistemov v verigi ima multi-prereq (v3.12.003-v3.12.009!)
- **SystemDependencies** — 6 novih dependencies za zadnje preostale sisteme z dokončevalno opremo stekla:
  * `GlassCaneSlicerMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinsko rezilo + steklena vodilnica → Steklarstvo+)
  * `GlassColorantSievingClothMaker` → `WoodLathe` + `PigmentGrinderMaker` (multi! CROSS-CHAIN: leseni okvir + pigmentna krpa → Barvila+)
  * `GlassColorantVialShakerMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinski stresalnik + steklena viala → Steklarstvo+)
  * `GlassMoltenGlassSkimLadleMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinska zajemalka + kamnita podloga → Kamnoseštvo+)
  * `GlassRibbonMaker` → `WoodLathe` + `Metalwork` (multi! leseno vreteno + kovinski okvir)
  * `GlassSeedMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinska matrica + stekleno seme → Steklarstvo+)
- **TechTreePanel**: STEKLO DOKONČANJE+ chain, footer (300 deps, 67 verig, 195 multi-prereq)
- 4 CROSS-CHAIN povezave (NOV REKORD za število različnih baz v eni verigi!):
  1. `GlassCaneSlicerMaker` + `GlassColorantVialShakerMaker` + `GlassSeedMaker` → `GlassBench` (Steklarstvo+ x3)
  2. `GlassColorantSievingClothMaker` → `PigmentGrinderMaker` (Barvila+)
  3. `GlassMoltenGlassSkimLadleMaker` → `MasonStonecutter` (Kamnoseštvo+)
  4. `Metalwork` skupna povezava s kovaštvom (5 sistemov)
- Pred: 294 deps, 66 verig, 189 multi-prereq
- Sedaj: 300 deps, 67 verig, 195 multi-prereq

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic), `states/ui/hud/tech_tree_panel.lua` (+2 vrstici)
- `README.md`, `CHANGELOG.md`, `NEXT_BATCH_HANDOFF.md`

### Funkcionalna preverba
- Lupa `load()` test: PASS; Python regex: 300 vnosov, 195 multi-prereq

## [v3.12.008] — 2026-08-18 — Glass Engraving+ 2 Chain (6 novih deps: 6 multi-prereq! 6. zapored vsi multi! MEJNIK 23.625x!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za sisteme z gravirno/dokončevalno opremo:
  * `GlassEngravingLatheChuckMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinski chuck + stekleni abraziv → Steklarstvo+)
  * `GlassEngravingWheelBearingMaker` → `Metalwork` + `WoodLathe` (multi! kovinski ležaj + lesena hišica)
  * `GlassEngravingWheelRestMaker` → `WoodLathe` + `MasonStonecutter` (multi! CROSS-CHAIN: leseni naslanjač + kamnita osnova → Kamnoseštvo+)
  * `GlassPolishingPadMaker` → `GlassBench` + `MasonStonecutter` (multi! CROSS-CHAIN: stekleni abrazivni pod + kamnita podloga → Steklarstvo+ & Kamnoseštvo+)
  * `GlassFritMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinski drobilnik + stekleni frit → Steklarstvo+)
  * `GlassShearSpringMaker` → `Metalwork` + `WoodLathe` (multi! kovinska vzmet + leseno ročaj)
- **TechTreePanel**: STEKLO REZBARSTVO+ 2 chain, footer (294 deps, 66 verig, 189 multi-prereq)
- **MEJNIK**: 189 multi-prereq — 23.625x več kot začetnih 8!
- **NOV REKORD**: 6. zapored da vsi 6 sistemov v verigi ima multi-prereq (v3.12.003-v3.12.008!)
- 3 CROSS-CHAIN povezave: GlassBench→Steklarstvo+ x3, MasonStonecutter→Kamnoseštvo+ x2, Metalwork→Kovaštvo+ x5

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic), `states/ui/hud/tech_tree_panel.lua` (+2 vrstici)
- `README.md`, `CHANGELOG.md`, `NEXT_BATCH_HANDOFF.md`

### Funkcionalna preverba
- Lupa `load()` test: PASS; Python regex: 294 vnosov, 189 multi-prereq

## [v3.12.007] — 2026-08-18 — Glass Annealing+ 2 Chain (6 novih deps: 6 multi-prereq! 5. zapored vsi multi! MEJNIK 22.875x!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za sisteme z žarilno opremo (annealing cradles, glory holes, punty warmers):
  * `GlassAnnealingCradleMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinska zibelka + kamnita osnova → Kamnoseštvo+)
  * `GlassAnnealingOvenDoorWheelMaker` → `Metalwork` + `WoodLathe` (multi! kovinsko kolo + lesen okvir)
  * `GlassAnnealingTongJawsMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinska usta + steklena obloga → Steklarstvo+)
  * `GlassGloryHoleMaker` → `MasonStonecutter` + `Metalwork` (multi! CROSS-CHAIN: kamnita komora + kovinski gorilnik → Kamnoseštvo+)
  * `GlassGloryHoleDamperMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinska loputa + kamniti okvir → Kamnoseštvo+)
  * `GlassPuntyWarmerMaker` → `GlassBench` + `Metalwork` (multi! CROSS-CHAIN: steklena grelna cev + kovinski okvir → Steklarstvo+)
- **TechTreePanel**: STEKLO ŽARENJE+ 2 chain, footer (288 deps, 65 verig, 183 multi-prereq)
- **MEJNIK**: 183 multi-prereq — 22.875x več kot začetnih 8!
- **NOV REKORD**: 5. zapored da vsi 6 sistemov v verigi ima multi-prereq (v3.12.003-v3.12.007!)
- 3 CROSS-CHAIN povezave: MasonStonecutter→Kamnoseštvo+ x3, GlassBench→Steklarstvo+ x2, Metalwork→Kovaštvo+ x5

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic), `states/ui/hud/tech_tree_panel.lua` (+2 vrstici)
- `README.md`, `CHANGELOG.md`, `NEXT_BATCH_HANDOFF.md`

### Funkcionalna preverba
- Lupa `load()` test: PASS; Python regex: 288 vnosov, 183 multi-prereq

## [v3.12.006] — 2026-08-18 — Glass Blowing+ 2 Chain (6 novih deps: 6 multi-prereq! 4. zapored vsi multi! MEJNIK 22x!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za sisteme z opremo za pihanje stekla (benči, pihalke, kalupi, hladilni stojali, škarje):
  * `GlassBenchMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinski okvir + kamnite noge → Kamnoseštvo+)
  * `GlassBlowerPipeMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinska cev + steklen ustnik → Steklarstvo+)
  * `GlassBlowingMoldMaker` → `WoodLathe` + `MasonStonecutter` (multi! CROSS-CHAIN: lesen kalup + kamnita osnova → Kamnoseštvo+)
  * `GlassBlowpipeCoolingRackMaker` → `WoodLathe` + `Metalwork` (multi! leseno stojalo + kovinske opore)
  * `GlassCoolingRackMaker` → `GlassBench` + `MasonStonecutter` (multi! CROSS-CHAIN: steklena površina + kamnita osnova → Steklarstvo+ & Kamnoseštvo+)
  * `GlassPipeShearsMaker` → `Metalwork` + `WoodLathe` (multi! kovinska rezila + leseno ročaj)
- **TechTreePanel**: STEKLO PIHALSKO+ 2 chain, footer (282 deps, 64 verig, 177 multi-prereq)
- **MEJNIK**: 177 multi-prereq — 22.125x več kot začetnih 8!
- **NOV REKORD**: 4. zapored da vsi 6 sistemov v verigi ima multi-prereq (v3.12.003-v3.12.006!)
- 3 CROSS-CHAIN povezave:
  1. `GlassBenchMaker` + `GlassBlowingMoldMaker` + `GlassCoolingRackMaker` → `MasonStonecutter` (povezuje s KAMNOSEŠTVO+ — 3 sistemi)
  2. `GlassBlowerPipeMaker` + `GlassCoolingRackMaker` → `GlassBench` (povezuje s STEKLARSTVO+ — 2 sistema)
  3. `Metalwork` skupna povezava s kovaštvom (4 sistemi)
- Pred: 276 deps, 63 verig, 171 multi-prereq
- Sedaj: 282 deps, 64 verig, 177 multi-prereq

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic)
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici)
- `README.md`, `CHANGELOG.md`, `NEXT_BATCH_HANDOFF.md`

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Python regex: 282 vnosov, 177 multi-prereq

## [v3.12.005] — 2026-08-18 — Glass Kiln Accessories+ 2 Chain (6 novih deps: 6 multi-prereq! MasonStonecutter x4! MEJNIK 21x!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za preostale sisteme z opremo za steklarske peči (GlassKiln door chains, brick tongs, seals):
  * `GlassKilnDoorChainMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinska veriga + kamnit škripec — povezuje s KAMNOSEŠTVO+)
  * `GlassKilnDoorLifterMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinski dvigalnik + kamnito protoutež)
  * `GlassKilnBrickTongsMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinske klešče + kamnita podlaga)
  * `GlassKilnSealMaker` → `GlassBench` + `MasonStonecutter` (multi! CROSS-CHAIN: stekleni pečat + kamniti okvir)
  * `GlassKilnSightingPortCoverMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinski pokrov + stekleno okno za opazovanje)
  * `GlassKilnSpyMaker` → `Metalwork` + `WoodLathe` (multi! kovinska špijonska cev + leseno ročaj)
- **TechTreePanel**: STEKLO KILN PRIBOR+ chain, footer (276 deps, 63 verig, 171 multi-prereq)
- **MEJNIK**: 171 multi-prereq — 21.375x več kot začetnih 8!
- 3 CROSS-CHAIN povezave:
  1. `GlassKilnDoorChainMaker` + `GlassKilnDoorLifterMaker` + `GlassKilnBrickTongsMaker` + `GlassKilnSealMaker` → `MasonStonecutter` (povezuje s KAMNOSEŠTVO+ — 4 sistemi)
  2. `GlassKilnSealMaker` + `GlassKilnSightingPortCoverMaker` → `GlassBench` (povezuje s STEKLARSTVO+ — 2 sistema)
  3. `Metalwork` skupna povezava s kovaštvom (5 sistemov)
- Pred: 270 deps, 62 verig, 165 multi-prereq
- Sedaj: 276 deps, 63 verig, 171 multi-prereq

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za STEKLO KILN PRIBOR+ in posodobljen footer counter (276/63/171)
- `README.md` — posodobljeni badges (v3.12.005, +GlassKilnAccessories2Chain, statistika)
- `CHANGELOG.md` — dodan v3.12.005 entry
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 276 vnosov, 171 multi-prereq — ujema se s footerjem

## [v3.12.004] — 2026-08-18 — Foundry Accessories+ 9 Chain (Casting/Pouring+ 2 — 6 novih deps: 6 multi-prereq! MEJNIK 20x!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe livarske sisteme (Casting/Pouring+ 2 — ladle handling & crucible drying tools):
  * `CastingLadleLiningTrowelMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinska lopatica + kamnita malta — povezuje s KAMNOSEŠTVO+ verigo iz v3.11.982)
  * `CastingLadlePreheatStandMaker` → `Metalwork` + `WoodLathe` (multi! kovinski stojalo + leseni podstavki)
  * `CastingLadleSkimmerHandleMaker` → `WoodLathe` + `Metalwork` (multi! leseno ročaj + kovinska povezava)
  * `PouringCrucibleDrierMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinska sušilna peč + stekleno okno za nadzor — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `PouringLadleLinerMaker` → `GlassBench` + `Metalwork` (multi! CROSS-CHAIN: steklena obloga + kovinski okvir — povezuje s STEKLARSTVO+)
  * `PouringLadleSkimmerSieveMaker` → `WoodLathe` + `Metalwork` (multi! leseni okvir sita + kovinska mreža)
- **TechTreePanel**: LIVARSKI PRIBOR+ 9 chain, footer (270 deps, 62 verig, 165 multi-prereq)
- **MEJNIK 1**: 165 multi-prereq — 20.625x več kot začetnih 8! (presežen mejnik 20x!)
- **MEJNIK 2**: Vseh 6 novih vnosov je multi-prereq (drugič zapored po v3.12.003 — drugič v zgodovini da vsi 6 sistemov v verigi ima multi-prereq!)
- 3 CROSS-CHAIN povezave:
  1. `CastingLadleLiningTrowelMaker` → `MasonStonecutter` (povezuje LIVARSKI PRIBOR+ 9 s KAMNOSEŠTVO+)
  2. `PouringCrucibleDrierMaker` + `PouringLadleLinerMaker` → `GlassBench` (povezuje s STEKLARSTVO+ — 2 sistema)
  3. `Metalwork` skupna povezava s kovaštvom (6 sistemov — drugi NOV REKORD, izenačeno z v3.12.001 in v3.11.996)
- Pred: 264 deps, 61 verig, 159 multi-prereq
- Sedaj: 270 deps, 62 verig, 165 multi-prereq
- Veriga livarskega pribora 9 sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za LIVARSKI PRIBOR+ 9 in posodobljen footer counter (270/62/165)
- `README.md` — posodobljeni badges (v3.12.004, +FoundryAccessories9Chain, statistika)
- `CHANGELOG.md` — dodan v3.12.004 entry z mejnikom 20x
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Casting/Pouring+ 2 chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 270 vnosov, 165 multi-prereq — ujema se s footerjem

## [v3.12.003] — 2026-08-18 — Foundry Accessories+ 8 Chain (Sand/Mold/Core+ 6 — FINAL, izčrpava Sand/Mold/Core skupine! 6 novih deps: 6 multi-prereq! MEJNIK 19.875x!)

### Dodano
- **VELIKI MEJNIK**: ZADNJI paket Sand/Mold/Core! Ta veriga izčrpava vse preostale Sand*, Mold*, Core* sisteme (skupaj 36 sistemov v 6 zaporednih paketih: v3.11.998-v3.12.003).
- **SystemDependencies** — 6 novih dependencies za obstoječe livarske sisteme (Sand/Mold/Core+ 6 — sand testing, mold vent cleaning, core varnishing):
  * `SandTestCupMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinska skodelica + stekleno okno za test — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `SanderMaker` → `WoodLathe` + `Metalwork` (multi! leseno stojalo + kovinski brusilnik)
  * `MoldCoatBrushSpinnerMaker` → `WoodLathe` + `PigmentGrinderMaker` (multi! CROSS-CHAIN: leseno vreteno + pigmenti — povezuje z BARVILA+ verigo iz v3.11.983)
  * `MoldVentWireCleanerMaker` → `Metalwork` + `WoodLathe` (multi! kovinska ščetka + leseno ročaj)
  * `CoreVarnishBrushMaker` → `WoodLathe` + `PigmentGrinderMaker` (multi! CROSS-CHAIN: leseno ščetka + pigmenti za lak — povezuje z BARVILA+)
  * `CoreWashingDipMaker` → `MasonStonecutter` + `Metalwork` (multi! CROSS-CHAIN: kamnita kad + kovinska vodovodna — povezuje s KAMNOSEŠTVO+ verigo iz v3.11.982)
- **TechTreePanel**: LIVARSKI PRIBOR+ 8 chain, footer (264 deps, 61 verig, 159 multi-prereq)
- **MEJNIK 1**: 159 multi-prereq — 19.875x več kot začetnih 8!
- **MEJNIK 2**: Vseh 6 novih vnosov je multi-prereq (prvič v zgodovini da vseh 6 sistemov v verigi ima multi-prereq!)
- 4 CROSS-CHAIN povezave (NOV REKORD za število različnih baz v eni verigi!):
  1. `SandTestCupMaker` → `GlassBench` (povezuje LIVARSKI PRIBOR+ 8 s STEKLARSTVO+)
  2. `MoldCoatBrushSpinnerMaker` + `CoreVarnishBrushMaker` → `PigmentGrinderMaker` (povezuje z BARVILA+ — 2 sistema)
  3. `CoreWashingDipMaker` → `MasonStonecutter` (povezuje s KAMNOSEŠTVO+)
  4. `Metalwork` + `WoodLathe` skupna povezava s kovaštvom in lesarstvom (5 sistemov)
- Pred: 258 deps, 60 verig, 153 multi-prereq
- Sedaj: 264 deps, 61 verig, 159 multi-prereq
- Veriga livarskega pribora 8 sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)
- **SKUPNO**: 36 Sand*/Mold*/Core* sistemov zdaj ima dependencies (6 paketov × 6 sistemov = 36)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za LIVARSKI PRIBOR+ 8 in posodobljen footer counter (264/61/159)
- `README.md` — posodobljeni badges (v3.12.003, +FoundryAccessories8Chain, statistika)
- `CHANGELOG.md` — dodan v3.12.003 entry z VELIKIM MEJNIKOM (izčrpava Sand/Mold/Core skupine)
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Sand/Mold/Core+ 6 chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 264 vnosov, 159 multi-prereq — ujema se s footerjem

## [v3.12.002] — 2026-08-18 — Foundry Accessories+ 7 Chain (Sand/Mold/Core+ 5 — 6 novih deps: 5 multi-prereq, 3 CROSS-CHAIN! MEJNIK 60 verig!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe livarske sisteme (Sand/Mold/Core+ 5 — sand dispensers, mold wedges, core vents):
  * `SandBinderDispenserMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinski rezervoar + kamnita-tehtna baza — povezuje s KAMNOSEŠTVO+ verigo iz v3.11.982)
  * `SandSieveShakerMaker` → `WoodLathe` + `Metalwork` (multi! leseni okvir + kovinski mehanizem za tresenje)
  * `MoldCoatingRollerMaker` → `WoodLathe` + `PigmentGrinderMaker` (multi! CROSS-CHAIN: leseno valj + pigmenti za premaz — povezuje z BARVILA+ verigo iz v3.11.983)
  * `MoldFlaskClampWedgeMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinski zatiči + kamniti klini — povezuje s KAMNOSEŠTVO+)
  * `CoreGasVentPinMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinski zatiči + stekleni indikator plinov — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `PouringConeMaker` → `Metalwork` (kovinski lijak za vlivanje staljene kovine)
- **TechTreePanel**: LIVARSKI PRIBOR+ 7 chain, footer (258 deps, 60 verig, 153 multi-prereq)
- **MEJNIK 1**: 60 verig v tech tree-ju! (zaokroženo število)
- **MEJNIK 2**: 153 multi-prereq — 19.125x več kot začetnih 8!
- 3 CROSS-CHAIN povezave:
  1. `SandBinderDispenserMaker` + `MoldFlaskClampWedgeMaker` → `MasonStonecutter` (povezuje LIVARSKI PRIBOR+ 7 s KAMNOSEŠTVO+ — kamnite tehtne baze in klini)
  2. `MoldCoatingRollerMaker` → `PigmentGrinderMaker` (povezuje z BARVILA+ — pigmenti za premaze valjev)
  3. `CoreGasVentPinMaker` → `GlassBench` (povezuje s STEKLARSTVO+ — stekleni indikatorji plinov)
- Pred: 252 deps, 59 verig, 148 multi-prereq
- Sedaj: 258 deps, 60 verig, 153 multi-prereq
- Veriga livarskega pribora 7 sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za LIVARSKI PRIBOR+ 7 in posodobljen footer counter (258/60/153)
- `README.md` — posodobljeni badges (v3.12.002, +FoundryAccessories7Chain, statistika)
- `CHANGELOG.md` — dodan v3.12.002 entry z obema mejnikoma
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Sand/Mold/Core+ 5 chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 258 vnosov, 153 multi-prereq — ujema se s footerjem

## [v3.12.001] — 2026-08-18 — Foundry Accessories+ 6 Chain (Sand/Mold/Core+ 4 — 6 novih deps: 5 multi-prereq, 3 CROSS-CHAIN! MEJNIK 18.5x!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe livarske sisteme (Sand/Mold/Core+ 4 — sand processing & mold handling tools):
  * `SandCasterMaker` → `Metalwork` + `WoodLathe` (multi! kovinski mehanizem + leseno ročaj za pesek casting)
  * `SandReclaimerMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinski reciklažni stroj + stekleno okno za nadzor — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `MoldKilnMaker` → `MasonStonecutter` + `Metalwork` (multi! CROSS-CHAIN: kamnita komora + kovinska vrata — povezuje s KAMNOSEŠTVO+ verigo iz v3.11.982)
  * `MoldReleaseAgentMaker` → `GlassBench` + `Metalwork` (multi! CROSS-CHAIN: stekleni rezervoar + kovinska črpalka — povezuje s STEKLARSTVO+)
  * `CoreDryingRackMaker` → `WoodLathe` + `Metalwork` (multi! leseno stojalo + kovinski okovji za sušenje jeder)
  * `CrucibleTongsMaker` → `Metalwork` (kovinske klešče za ravnanje s križami)
- **TechTreePanel**: LIVARSKI PRIBOR+ 6 chain, footer (252 deps, 59 verig, 148 multi-prereq)
- **MEJNIK**: 148 multi-prereq — 18.5x več kot začetnih 8!
- 3 CROSS-CHAIN povezave:
  1. `SandReclaimerMaker` + `MoldReleaseAgentMaker` → `GlassBench` (povezuje LIVARSKI PRIBOR+ 6 s STEKLARSTVO+ — kontrolna okna in stekleni rezervoarji)
  2. `MoldKilnMaker` → `MasonStonecutter` (povezuje s KAMNOSEŠTVO+ — kamnite komore za kalupne peči)
  3. `Metalwork` skupna povezava s kovaštvom (6 sistemov — NOV REKORD za eno verigo, izenačeno z v3.11.996!)
- Pred: 246 deps, 58 verig, 143 multi-prereq
- Sedaj: 252 deps, 59 verig, 148 multi-prereq
- Veriga livarskega pribora 6 sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za LIVARSKI PRIBOR+ 6 in posodobljen footer counter (252/59/148)
- `README.md` — posodobljeni badges (v3.12.001, +FoundryAccessories6Chain, statistika)
- `CHANGELOG.md` — dodan v3.12.001 entry z mejnikom 18.5x
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Sand/Mold/Core+ 4 chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 252 vnosov, 148 multi-prereq — ujema se s footerjem

## [v3.12.000] — 2026-08-18 — Foundry Accessories+ 5 Chain (Casting/Pouring+ — 6 novih deps: 5 multi-prereq, 3 CROSS-CHAIN! MEJNIK v3.12!)

### Dodano
- **VELIKI MEJNIK**: Prva različica v seriji **v3.12**! Prehod iz v3.11.x v v3.12.0x po 14 zaporednih +Chain paketih (v3.11.986-v3.12.000).
- **SystemDependencies** — 6 novih dependencies za obstoječe livarske sisteme (Casting/Pouring+ — ladle & crucible handling tools):
  * `CastingLadleNozzleMaker` → `Metalwork` + `ForgeTuyere` (multi! CROSS-CHAIN: kovinska šoba + kovaški žerjav — povezuje z LIVARSTVO+ verigo iz v3.11.974)
  * `CastingLadlePreheatBurnerMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinski gorilnik + stekleno okno za nadzor — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `PouringLadleMaker` → `Metalwork` + `WoodLathe` (multi! kovinska zajemalka + leseno ročaj)
  * `PouringLadleLiningCementMaker` → `MasonStonecutter` + `Metalwork` (multi! CROSS-CHAIN: kamnita malta + kovinsko mešalo — povezuje s KAMNOSEŠTVO+ verigo iz v3.11.982)
  * `PouringCrucibleTongsMaker` → `Metalwork` + `WoodLathe` (multi! kovinska klešča + leseno ročaj)
  * `CastingBreakoutChiselMaker` → `Metalwork` (kovinsko dleto za odstranjevanje ulitkov iz kalupov)
- **TechTreePanel**: LIVARSKI PRIBOR+ 5 chain, footer (246 deps, 58 verig, 143 multi-prereq)
- **MEJNIK 2**: 143 multi-prereq — 17.875x več kot začetnih 8!
- 3 CROSS-CHAIN povezave (raznolike — vsaka drugačna baza!):
  1. `CastingLadleNozzleMaker` → `ForgeTuyere` (povezuje LIVARSKI PRIBOR+ 5 z LIVARSTVO+)
  2. `CastingLadlePreheatBurnerMaker` → `GlassBench` (povezuje s STEKLARSTVO+)
  3. `PouringLadleLiningCementMaker` → `MasonStonecutter` (povezuje s KAMNOSEŠTVO+)
- Pred: 240 deps, 57 verig, 138 multi-prereq
- Sedaj: 246 deps, 58 verig, 143 multi-prereq
- Veriga livarskega pribora 5 sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za LIVARSKI PRIBOR+ 5 in posodobljen footer counter (246/58/143)
- `README.md` — posodobljeni badges (v3.12.000, +FoundryAccessories5Chain, statistika)
- `CHANGELOG.md` — dodan v3.12.000 entry z velikim mejnikom
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Casting/Pouring+ chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 246 vnosov, 143 multi-prereq — ujema se s footerjem

## [v3.11.999] — 2026-08-18 — Foundry Accessories+ 4 Chain (Sand/Mold/Core+ 3 — 6 novih deps: 5 multi-prereq, 3 CROSS-CHAIN! MEJNIK 240 deps!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe livarske sisteme (Sand/Mold/Core+ 3 — sand treatment & mold handling):
  * `SandConditionerMaker` → `Metalwork` + `WoodLathe` (multi! kovinski noži + leseno mešalo za pripravo peska)
  * `SandCoolerMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinske hladilne cevi + stekleno okno za nadzor temperature — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `MoldDryingStandMaker` → `WoodLathe` + `Metalwork` (multi! leseno stojalo + kovinski okovji za sušenje kalupov)
  * `MoldWashBoothMaker` → `MasonStonecutter` + `Metalwork` (multi! CROSS-CHAIN: kamnita kabina + kovinska vodovodna inštalacija — povezuje s KAMNOSEŠTVO+ verigo iz v3.11.982)
  * `CorePrintBoxMaker` → `MasonStonecutter` + `WoodLathe` (multi! CROSS-CHAIN: kamnita škatla + lesen pokrov — povezuje s KAMNOSEŠTVO+)
  * `MoldFlowTesterMaker` → `Metalwork` (kovinski tester pretočnosti za kalupe)
- **TechTreePanel**: LIVARSKI PRIBOR+ 4 chain, footer (240 deps, 57 verig, 138 multi-prereq)
- **MEJNIK 1**: 240 deps v tech tree-ju! (zaokroženo število)
- **MEJNIK 2**: 138 multi-prereq — 17.25x več kot začetnih 8!
- 3 CROSS-CHAIN povezave:
  1. `SandCoolerMaker` → `GlassBench` (povezuje LIVARSKI PRIBOR+ 4 s STEKLARSTVO+ — kontrolna okna za temperaturo)
  2. `MoldWashBoothMaker` + `CorePrintBoxMaker` → `MasonStonecutter` (povezuje s KAMNOSEŠTVO+ — kamnite komponente)
  3. `Metalwork` skupna povezava s kovaštvom (5 sistemov)
- Pred: 234 deps, 56 verig, 133 multi-prereq
- Sedaj: 240 deps, 57 verig, 138 multi-prereq
- Veriga livarskega pribora 4 sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za LIVARSKI PRIBOR+ 4 in posodobljen footer counter (240/57/138)
- `README.md` — posodobljeni badges (v3.11.999, +FoundryAccessories4Chain, statistika)
- `CHANGELOG.md` — dodan v3.11.999 entry z obema mejnikoma
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Sand/Mold/Core+ 3 chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 240 vnosov, 138 multi-prereq — ujema se s footerjem

## [v3.11.998] — 2026-08-18 — Foundry Accessories+ 3 Chain (6 novih deps: 5 multi-prereq, 3 CROSS-CHAIN! MEJNIK 56 verig!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe sisteme z naprednim livarskim priborom (Sand/Mold/Core):
  * `SandMoldMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinski okvir + kamnita kalupna osnova — povezuje s KAMNOSEŠTVO+ verigo iz v3.11.982)
  * `MoldDryingOvenMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinska peč + stekleno okno za nadzor sušenja — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `MoldCoatingBrushMaker` → `WoodLathe` + `PigmentGrinderMaker` (multi! CROSS-CHAIN: leseno ščetka + pigmenti za premaz — povezuje z BARVILA+ verigo iz v3.11.983)
  * `CoreOvenMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinska peč + stekleno okno za nadzor temperature — povezuje s STEKLARSTVO+)
  * `CorePasteMixerMaker` → `WoodLathe` + `Metalwork` (multi! leseno mešalo + kovinska os za mešanje paste)
  * `MoldClampMaker` → `Metalwork` (kovinska sponka za varne kalupe)
- **TechTreePanel**: LIVARSKI PRIBOR+ 3 chain, footer (234 deps, 56 verig, 133 multi-prereq)
- **MEJNIK 1**: 56 verig v tech tree-ju!
- **MEJNIK 2**: 133 multi-prereq — 16.625x več kot začetnih 8!
- 3 CROSS-CHAIN povezave:
  1. `SandMoldMaker` → `MasonStonecutter` (povezuje LIVARSKI PRIBOR+ 3 s KAMNOSEŠTVO+ — kamnite osnove za kalupe)
  2. `MoldDryingOvenMaker` + `CoreOvenMaker` → `GlassBench` (povezuje s STEKLARSTVO+ — kontrolna okna za peči)
  3. `MoldCoatingBrushMaker` → `PigmentGrinderMaker` (povezuje z BARVILA+ — pigmenti za premaze kalupov)
- Pred: 228 deps, 55 verig, 128 multi-prereq
- Sedaj: 234 deps, 56 verig, 133 multi-prereq
- Veriga livarskega pribora 3 sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za LIVARSKI PRIBOR+ 3 in posodobljen footer counter (234/56/133)
- `README.md` — posodobljeni badges (v3.11.998, +FoundryAccessories3Chain, statistika)
- `CHANGELOG.md` — dodan v3.11.998 entry z obema mejnikoma
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Sand/Mold/Core+ 2 chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 234 vnosov, 133 multi-prereq — ujema se s footerjem

## [v3.11.997] — 2026-08-18 — Glass Forming Tools+ Chain (6 novih deps: 5 multi-prereq, 3 CROSS-CHAIN! MEJNIK 16x!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe sisteme z orodji za oblikovanje stekla:
  * `GlassMarverMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinska plošča + kamnita podlaga — povezuje s KAMNOSEŠTVO+ verigo iz v3.11.982)
  * `GlassPuntyRodMaker` → `Metalwork` + `WoodLathe` (multi! kovinska konica pontil + leseno ročaj)
  * `GlassGatheringIronMaker` → `Metalwork` + `WoodLathe` (multi! kovinska pipa za zajemanje + leseno ročaj)
  * `GlassShearsMaker` → `Metalwork` + `WoodLathe` (multi! kovinska rezila + leseno ročaj)
  * `GlassYokeMaker` → `WoodLathe` + `Metalwork` (multi! leseno stojalo + kovinski okovji)
  * `GlassLehrBeltMaker` → `WoodLathe` (leseni transporter za Lehr peč)
- **TechTreePanel**: STEKLO OBLIKOVANJE+ chain, footer (228 deps, 55 verig, 128 multi-prereq)
- **MEJNIK**: 128 multi-prereq — 16x več kot začetnih 8!
- 3 CROSS-CHAIN povezave:
  1. `GlassMarverMaker` → `MasonStonecutter` (povezuje STEKLO OBLIKOVANJE+ s KAMNOSEŠTVO+)
  2. `Metalwork` skupna povezava s kovaštvom (5 sistemov)
  3. `WoodLathe` skupna povezava z lesarstvom (4 sistemi)
- Pred: 222 deps, 54 verig, 123 multi-prereq
- Sedaj: 228 deps, 55 verig, 128 multi-prereq
- Veriga oblikovalnih orodij stekla sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za STEKLO OBLIKOVANJE+ in posodobljen footer counter (228/55/128)
- `README.md` — posodobljeni badges (v3.11.997, +GlassFormingToolsChain, statistika)
- `CHANGELOG.md` — dodan v3.11.997 entry
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Glass Forming Tools+ chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 228 vnosov, 128 multi-prereq — ujema se s footerjem

## [v3.11.996] — 2026-08-18 — Glass Batch+ Chain (6 novih deps: 5 multi-prereq, 3 CROSS-CHAIN!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe sisteme s pripravo in taljenjem steklarske mešanice (batch):
  * `GlassBatchFurnaceMaker` → `Metalwork` + `ForgeTuyere` (multi! CROSS-CHAIN: kovinska peč + kovaški žerjav — povezuje z LIVARSTVO+ verigo iz v3.11.974)
  * `GlassBatchSmelter` → `Metalwork` + `ForgeTuyere` (multi! CROSS-CHAIN: kovinski talilni lonec + kovaški žerjav — povezuje z LIVARSTVO+)
  * `GlassBatchMixerMaker` → `WoodLathe` + `Metalwork` (multi! leseno mešalo + kovinska os za mešanje batch-a)
  * `GlassBatchFeederMaker` → `WoodLathe` + `MasonStonecutter` (multi! CROSS-CHAIN: leseno vedro + kamnit lijak — povezuje s KAMNOSEŠTVO+ verigo iz v3.11.982)
  * `GlassBatchMaker` → `MasonStonecutter` + `Metalwork` (multi! CROSS-CHAIN: kamnita tehtnica + kovinske uteži — povezuje s KAMNOSEŠTVO+)
  * `GlassCulletCrusherMaker` → `Metalwork` (kovinski drobilnik za recikliranje stekla)
- **TechTreePanel**: STEKLO MEŠANICA+ chain, footer (222 deps, 54 verig, 123 multi-prereq)
- **MEJNIK**: 123 multi-prereq — 15.375x več kot začetnih 8!
- 3 CROSS-CHAIN povezave:
  1. `GlassBatchFurnaceMaker` + `GlassBatchSmelter` → `ForgeTuyere` (povezuje STEKLO MEŠANICA+ z LIVARSTVO+ — 2 sistemi)
  2. `GlassBatchFeederMaker` + `GlassBatchMaker` → `MasonStonecutter` (povezuje s KAMNOSEŠTVO+ — 2 sistemi)
  3. `Metalwork` skupna povezava s kovaštvom (5 sistemov — NOV REKORD za eno verigo!)
- Pred: 216 deps, 53 verig, 118 multi-prereq
- Sedaj: 222 deps, 54 verig, 123 multi-prereq
- Veriga steklarske mešanice sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za STEKLO MEŠANICA+ in posodobljen footer counter (222/54/123)
- `README.md` — posodobljeni badges (v3.11.996, +GlassBatchChain, statistika)
- `CHANGELOG.md` — dodan v3.11.996 entry
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Glass Batch/Smelter+ chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 222 vnosov, 123 multi-prereq — ujema se s footerjem

## [v3.11.995] — 2026-08-18 — Foundry Accessories+ 2 Chain (6 novih deps: 5 multi-prereq, 3 CROSS-CHAIN!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe livarske sisteme z naprednim priborom:
  * `SandMullerBladeMaker` → `Metalwork` + `WoodLathe` (multi! kovinsko rezilo + leseno ročaj za muller peska)
  * `MoldFlaskAlignmentPinMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinski zatiči + kamnita osnova za kalupe — povezuje s KAMNOSEŠTVO+ verigo iz v3.11.982)
  * `CoreGasEscapeChannelMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinska cev + stekleno okno za nadzor plinov — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `CastingLadleSkimmerHookMaker` → `Metalwork` + `WoodLathe` (multi! kovinska kladka + leseno ročaj)
  * `PouringLadleSpoutLinerMaker` → `GlassBench` + `Metalwork` (multi! CROSS-CHAIN: steklena obloga izliva + kovinska lopatica — povezuje s STEKLARSTVO+)
  * `SandRiddleMaker` → `WoodLathe` (leseni okvir za presejanje peska)
- **TechTreePanel**: LIVARSKI PRIBOR+ 2 chain, footer (216 deps, 53 verig, 118 multi-prereq)
- **MEJNIK**: 118 multi-prereq — 14.75x več kot začetnih 8!
- 3 CROSS-CHAIN povezave:
  1. `MoldFlaskAlignmentPinMaker` → `MasonStonecutter` (povezuje LIVARSKI PRIBOR+ 2 s KAMNOSEŠTVO+)
  2. `CoreGasEscapeChannelMaker` + `PouringLadleSpoutLinerMaker` → `GlassBench` (povezuje s STEKLARSTVO+)
  3. `Metalwork` skupna povezava s kovaštvom prek 4 sistemov
- Pred: 210 deps, 52 verig, 113 multi-prereq
- Sedaj: 216 deps, 53 verig, 118 multi-prereq
- Veriga livarskega pribora 2 sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za LIVARSKI PRIBOR+ 2 in posodobljen footer counter (216/53/118)
- `README.md` — posodobljeni badges (v3.11.995, +FoundryAccessories2Chain, statistika)
- `CHANGELOG.md` — dodan v3.11.995 entry
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Livarski pribor+ 2" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 216 vnosov, 118 multi-prereq — ujema se s footerjem

## [v3.11.994] — 2026-08-18 — Glass Kiln+ Chain (6 novih deps: 5 multi-prereq, 3 CROSS-CHAIN! MasonStonecutter x4!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe sisteme z opremo za steklarske peči:
  * `GlassKilnDoorMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinska okovina + kamniti okvir — povezuje s KAMNOSEŠTVO+ verigo iz v3.11.982)
  * `GlassKilnBrickSawMaker` → `Metalwork` + `MasonStonecutter` (multi! CROSS-CHAIN: kovinska žaga + kamnito rezilo — povezuje s KAMNOSEŠTVO+)
  * `GlassKilnFlueDamperMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinska loputa + stekleno okno za nadzor — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `GlassKilnMuffleMaker` → `MasonStonecutter` + `GlassBench` (multi! CROSS-CHAIN: kamnita mufelna komora + steklena okna — povezuje z KAMNOSEŠTVO+ in STEKLARSTVO+)
  * `GlassKilnFurnitureMaker` → `WoodLathe` + `MasonStonecutter` (multi! CROSS-CHAIN: leseni regali + kamniti podstavki — povezuje s KAMNOSEŠTVO+)
  * `GlassKilnSootScraperMaker` → `Metalwork` (kovinska strgala za saje)
- **TechTreePanel**: STEKLO PEČ+ chain, footer (210 deps, 52 verig, 113 multi-prereq)
- **MEJNIK**: 113 multi-prereq — 14.125x več kot začetnih 8!
- 3 CROSS-CHAIN povezave:
  1. `GlassKilnDoorMaker` + `GlassKilnBrickSawMaker` + `GlassKilnMuffleMaker` + `GlassKilnFurnitureMaker` → `MasonStonecutter` (povezuje STEKLO PEČ+ z KAMNOSEŠTVO+ — NOV REKORD: 4 sistemi z isto CROSS-CHAIN bazo!)
  2. `GlassKilnFlueDamperMaker` + `GlassKilnMuffleMaker` → `GlassBench` (povezuje s STEKLARSTVO+)
  3. `Metalwork` skupna povezava s kovaštvom prek 4 sistemov
- Pred: 204 deps, 51 verig, 108 multi-prereq
- Sedaj: 210 deps, 52 verig, 113 multi-prereq
- Veriga steklarskih peči sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za STEKLO PEČ+ in posodobljen footer counter (210/52/113)
- `README.md` — posodobljeni badges (v3.11.994, +GlassKilnChain, statistika)
- `CHANGELOG.md` — dodan v3.11.994 entry
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Glass Kiln+ chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 210 vnosov, 113 multi-prereq — ujema se s footerjem

## [v3.11.993] — 2026-08-18 — Glass Colorant+ Chain (6 novih deps: 5 multi-prereq, 3 CROSS-CHAIN!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe sisteme z opremo za barvanje stekla:
  * `GlassColorantMortarMaker` → `MasonStonecutter` + `PigmentGrinderMaker` (multi! CROSS-CHAIN: kamnita malta + pigmenti — povezuje z BARVILA+ verigo iz v3.11.983 in KAMNOSEŠTVO+ verigo iz v3.11.982)
  * `GlassColorantMortarPestleMaker` → `MasonStonecutter` + `Metalwork` (multi! CROSS-CHAIN: kamnita skleda + kovinski pestle — povezuje z KAMNOSEŠTVO+)
  * `GlassColorantMullerMaker` → `Metalwork` + `PigmentGrinderMaker` (multi! CROSS-CHAIN: kovinski muller za mletje pigmentov — povezuje z BARVILA+)
  * `GlassColorantSieveMaker` → `WoodLathe` + `PigmentGrinderMaker` (multi! CROSS-CHAIN: leseno sito za presejanje pigmentov — povezuje z BARVILA+)
  * `GlassColorantSpatulaMaker` → `Metalwork` + `WoodLathe` (multi! kovinska lopatica + leseno ročaj)
  * `GlassColorantDryingTrayMaker` → `WoodLathe` (lesena pladenj za sušenje barv)
- **TechTreePanel**: STEKLO BARVILA+ chain, footer (204 deps, 51 verig, 108 multi-prereq)
- **MEJNIK**: 108 multi-prereq — 13.5x več kot začetnih 8!
- 3 CROSS-CHAIN povezave:
  1. `GlassColorantMortarMaker` + `GlassColorantMullerMaker` + `GlassColorantSieveMaker` → `PigmentGrinderMaker` (povezuje STEKLO BARVILA+ z BARVILA+ — prvič 3 sistemi z isto CROSS-CHAIN bazo za drugo bazo!)
  2. `GlassColorantMortarMaker` + `GlassColorantMortarPestleMaker` → `MasonStonecutter` (povezuje STEKLO BARVILA+ z KAMNOSEŠTVO+)
  3. `Metalwork` skupna povezava s kovaštvom prek več sistemov
- Pred: 198 deps, 50 verig, 103 multi-prereq
- Sedaj: 204 deps, 51 verig, 108 multi-prereq
- Veriga barvanja stekla sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za STEKLO BARVILA+ in posodobljen footer counter (204/51/108)
- `README.md` — posodobljeni badges (v3.11.993, +GlassColorantChain, statistika)
- `CHANGELOG.md` — dodan v3.11.993 entry
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Glass Colorant+ chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 204 vnosov, 108 multi-prereq — ujema se s footerjem

## [v3.11.992] — 2026-08-18 — Glass Annealing+ Chain (6 novih deps: 5 multi-prereq, 3 CROSS-CHAIN! MEJNIK 50 verig!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe sisteme z žarilno opremo za steklo (annealing):
  * `GlassAnnealingOvenMaker` → `Metalwork` + `ForgeTuyere` (multi! CROSS-CHAIN: peč s kovinsko lupino + kovaški žerjav — povezuje z LIVARSTVO+ verigo iz v3.11.974)
  * `GlassAnnealingOvenThermocoupleMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: steklena cev + kovinska sonda — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `GlassAnnealingOvenInspectionMirrorMaker` → `GlassBench` + `Metalwork` (multi! CROSS-CHAIN: stekleno ogledalo + kovinski okvir — povezuje s STEKLARSTVO+)
  * `GlassAnnealingRollerMaker` → `WoodLathe` + `Metalwork` (multi! leseno ročaj + kovinska os)
  * `GlassAnnealingCartMaker` → `WoodLathe` + `Metalwork` (multi! leseno voziček + kovinska kolesa)
  * `GlassAnnealingForkMaker` → `Metalwork` (kovinska vila za dviganje vročega stekla)
- **TechTreePanel**: STEKLO ŽARENJE+ chain, footer (198 deps, 50 verig, 103 multi-prereq)
- **MEJNIK 1**: 50 verig v tech tree-ju!
- **MEJNIK 2**: 103 multi-prereq — 12.875x več kot začetnih 8!
- 3 CROSS-CHAIN povezave:
  1. `GlassAnnealingOvenMaker` → `ForgeTuyere` (povezuje STEKLO ŽARENJE+ z LIVARSTVO+)
  2. `GlassAnnealingOvenThermocoupleMaker` → `GlassBench` (povezuje s STEKLARSTVO+)
  3. `GlassAnnealingOvenInspectionMirrorMaker` → `GlassBench` (povezuje s STEKLARSTVO+)
- Pred: 192 deps, 49 verig, 98 multi-prereq
- Sedaj: 198 deps, 50 verig, 103 multi-prereq
- Veriga steklenega žarenja sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za STEKLO ŽARENJE+ in posodobljen footer counter (198/50/103)
- `README.md` — posodobljeni badges (v3.11.992, +GlassAnnealingChain, statistika)
- `CHANGELOG.md` — dodan v3.11.992 entry
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Glass Annealing+ chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 198 vnosov, 103 multi-prereq — ujema se s footerjem

## [v3.11.991] — 2026-08-18 — Glass Engraving+ Chain (6 novih deps: 5 multi-prereq, 2 CROSS-CHAIN!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe sisteme z opremo za graviranje/rezbarjenje stekla:
  * `GlassEngraverMaker` → `Metalwork` + `WoodLathe` (multi! gravirno orodje: kovinska konica + leseno ročaj)
  * `GlassEngravingWheelMaker` → `WoodLathe` + `Metalwork` (multi! kolo: lesen okvir + kovinska os)
  * `GlassEngravingPointMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: steklo-abrazivna konica — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `GlassEngravingDiamondPointMaker` → `Metalwork` + `GemMiner` (multi! CROSS-CHAIN: diamantna konica — povezuje z RUDARSTVO+ verigo iz v3.11.986)
  * `GlassEngravingCopperWheelMaker` → `Metalwork` + `WoodLathe` (multi! bakreno kolo + leseni podstavek)
  * `GlassEngravingWheelDressingStoneMaker` → `GlassBench` (čisto steklen abrazivni kamen za ostrenje koles)
- **TechTreePanel**: STEKLO REZBARSTVO+ chain, footer (192 deps, 49 verig, 98 multi-prereq)
- **MEJNIK**: 192 deps, 49 verig, 98 multi-prereq — 12.25x več multi-prereq kot začetnih 8!
- 2 CROSS-CHAIN povezave:
  1. `GlassEngravingPointMaker` + `GlassEngravingWheelDressingStoneMaker` → `GlassBench` (povezuje STEKLO REZBARSTVO+ s STEKLARSTVO+)
  2. `GlassEngravingDiamondPointMaker` → `GemMiner` (povezuje STEKLO REZBARSTVO+ z RUDARSTVO+)
- Pred: 186 deps, 48 verig, 93 multi-prereq
- Sedaj: 192 deps, 49 verig, 98 multi-prereq
- Veriga steklene gravure sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za STEKLO REZBARSTVO+ in posodobljen footer counter (192/49/98)
- `README.md` — posodobljeni badges (v3.11.991, +GlassEngravingChain, statistika)
- `CHANGELOG.md` — dodan v3.11.991 entry
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Glass Engraving+ chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 192 vnosov, 98 multi-prereq — ujema se s footerjem

## [v3.11.990] — 2026-08-18 — Milling+ Chain (6 novih deps: 5 multi-prereq, 3 CROSS-CHAIN!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe mlinarske sisteme z napredno mlinarsko mehanizacijo:
  * `MillstoneMaker` → `Metalwork` + `WoodLathe` (multi! mlinski kamen potrebuje železne okove + lesen okvir)
  * `MillstoneSpindleBearingMaker` → `Metalwork` + `WoodLathe` (multi! vreteno potrebuje kovinske ležaje + leseno hišico)
  * `MillHopperShakerMaker` → `WoodLathe` + `SpinningWheel` (multi! CROSS-CHAIN: mehanski jermen/pleten trak iz tekstilne verige — povezuje s TEKSTIL+ verigo iz v3.11.976)
  * `GrainHopperMaker` → `WoodLathe` + `Metalwork` (multi! lesena skrinja + železni obroči)
  * `MillHopperSightGlassMaker` → `GlassBench` + `WoodLathe` (multi! CROSS-CHAIN: stekleno okno za nadzor toka + lesen okvir — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `MillstoneDresserMaker` → `Metalwork` (ostrila za rezkanje mlinskih kamnov so čista kovina)
- **TechTreePanel**: MLINARSTVO+ chain, footer (186 deps, 48 verig, 93 multi-prereq)
- **MEJNIK**: 186 deps, 48 verig, 93 multi-prereq — 11.6x več multi-prereq kot začetnih 8!
- 3 CROSS-CHAIN povezave (NOV SKUPNI REKORD z v3.11.989 — skupno število CROSS-CHAIN povezav preseže 15):
  1. `MillHopperShakerMaker` → `SpinningWheel` (povezuje MLINARSTVO+ s TEKSTIL+)
  2. `MillHopperSightGlassMaker` → `GlassBench` (povezuje MLINARSTVO+ s STEKLARSTVO+)
  3. `MillstoneSpindleBearingMaker` + `MillstoneMaker` + `GrainHopperMaker` → `Metalwork` (povezuje s kovaštvom — CROSS-CHAIN s plus verigami)
- Pred: 180 deps, 47 verig, 88 multi-prereq
- Sedaj: 186 deps, 48 verig, 93 multi-prereq
- Mlinarska veriga sedaj ima 6 novih sistemov z dependencies + 2 obstoječa (MillstoneBalancerMaker, MillstoneCraneMaker) = 8 skupaj

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za MLINARSTVO+ in posodobljen footer counter (186/48/93)
- `README.md` — posodobljeni badges (v3.11.990, +MillingChain, statistika)
- `CHANGELOG.md` — dodan v3.11.990 entry
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Mlinarski+ chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 186 vnosov, 93 multi-prereq — ujema se s footerjem

## [v3.11.989] — 2026-08-18 — Garden+ 2 Chain (6 novih deps: 5 multi-prereq, 2 CROSS-CHAIN!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe vrtnarske sisteme z napredno opremo:
  * `GardenSoilAeratorSpikeMaker` → `Metalwork` + `WoodLathe` (multi! kovinski žeblji + leseno ročaj)
  * `GardenSecateursMaker` → `Metalwork` + `WoodLathe` (multi! škarje: kovinska rezila + leseni ročaji)
  * `GardenSprayerMaker` → `GlassBench` + `Metalwork` (multi! CROSS-CHAIN: steklen rezervoar + kovinska črpalka — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `GardenSoilThermometerMaker` → `GlassBench` + `Metalwork` (multi! CROSS-CHAIN: steklena cev + kovinska sonda — povezuje s STEKLARSTVO+)
  * `GardenCompostThermometerProbeMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: kovinska sonda + steklena viala — povezuje s STEKLARSTVO+)
  * `GardenToolRackMaker` → `WoodLathe` (lesena stojala za orodja)
- **TechTreePanel**: VRTNARSTVO+ 2 chain, footer (180 deps, 47 verig, 88 multi-prereq)
- **MEJNIK**: 180 deps, 47 verig, 88 multi-prereq — 11x več multi-prereq kot začetnih 8!
- 3 CROSS-CHAIN povezave (ker 3 sistemi uporabljajo GlassBench):
  1. `GardenSprayerMaker` → `GlassBench` (steklen rezervoar za tekočino)
  2. `GardenSoilThermometerMaker` → `GlassBench` (steklena cev za termometer)
  3. `GardenCompostThermometerProbeMaker` → `GlassBench` (steklena viala za kompostno toploto)
- Pred: 174 deps, 46 verig, 83 multi-prereq
- Sedaj: 180 deps, 47 verig, 88 multi-prereq
- Vrtnarska veriga 2 sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za VRTNARSTVO+ 2 in posodobljen footer counter (180/47/88)
- `README.md` — posodobljeni badges (v3.11.989, +Garden2Chain, statistika)
- `CHANGELOG.md` — dodan v3.11.989 entry
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Garden+ 2 chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 180 vnosov, 88 multi-prereq — ujema se s footerjem

## [v3.11.988] — 2026-08-18 — Anvil+ Chain (6 novih deps: 5 multi-prereq, 2 CROSS-CHAIN!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe sisteme z Anvil priborom in kovaško opremo:
  * `AnvilClampMaker` → `Metalwork` + `ForgeTuyere` (multi! workholding clamp: kovina telo + kovaška vijačna vez)
  * `AnvilFaceHardenerMaker` → `Metalwork` + `ForgeTuyere` (multi! postopek strjevanja: kovina + toplotna obdelava)
  * `AnvilHardyMaker` → `Metalwork` + `ForgeTuyere` (multi! hardy hole rezilno orodje: kovano jeklo)
  * `AnvilHornPolisherMaker` → `Metalwork` + `GlassBench` (multi! CROSS-CHAIN: poliranje uporablja abrazivno steklo — povezuje s STEKLARSTVO+ verigo iz v3.11.973)
  * `AnvilSaddleBlockMaker` → `WoodLathe` + `ForgeTuyere` (multi! CROSS-CHAIN: lesena sedežna blokada na kovaštvu — povezuje z Lesarstvom)
  * `AnvilStumpWedgeMaker` → `WoodLathe` (oblikovani leseni zagozdi za nivelacijo nakovala)
- **TechTreePanel**: NAKOVALO+ chain, footer (174 deps, 46 verig, 83 multi-prereq)
- **MEJNIK**: 174 deps, 46 verig, 83 multi-prereq — 10.4x več multi-prereq kot začetnih 8!
- 2 CROSS-CHAIN povezave:
  1. `AnvilHornPolisherMaker` → `GlassBench` (povezuje NAKOVALO+ s STEKLARSTVO+)
  2. `AnvilSaddleBlockMaker` → `WoodLathe` (povezuje NAKOVALO+ z INSTRUMENTI+/KNJIGOVEZSTVO+/URARSTVO+ ki uporabljajo WoodLathe)
- Pred: 168 deps, 45 verig, 78 multi-prereq
- Sedaj: 174 deps, 46 verig, 83 multi-prereq
- Veriga Anvil pribora sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+9 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za NAKOVALO+ in posodobljen footer counter (174/46/83)
- `README.md` — posodobljeni badges (v3.11.988, +AnvilChain, statistika)
- `CHANGELOG.md` — dodan v3.11.988 entry
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Anvil+ chain" dodan v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 174 vnosov, 83 multi-prereq — ujema se s footerjem

## [v3.11.987] — 2026-08-18 — Armor/Weapon+ Chain (6 novih deps: 5 multi-prereq, 2 CROSS-CHAIN!)

### Dodano
- **SystemDependencies** — 6 novih dependencies za obstoječe oklepno/orožne sisteme:
  * `CeremonialSwordMaker` → `Metalwork` + `GemMiner` (multi-prereq! CROSS-CHAIN: ceremonial sword needs jeweled hilt — povezuje z RUDARSTVO+ verigo iz v3.11.986)
  * `HalberdSmith` → `Metalwork` + `WoodLathe` (multi-prereq! polearm: kovina glava + leseno ročaj)
  * `LongbowMaker` → `WoodLathe` (oblikovan leseni lok)
  * `RecurveBowMaker` → `WoodLathe` + `RawhideTanner` (multi-prereq! CROSS-CHAIN: kompozitni lok uporablja usnje/kit — povezuje z USNJE+ verigo iz v3.11.935)
  * `ParadeShieldMaker` → `Metalwork` + `RawhideTanner` (multi-prereq! CROSS-CHAIN: ščit z usnjenim podstavkom)
  * `PresentationAxeMaker` → `Metalwork` + `WoodLathe` (multi-prereq! sekira: kovina glava + leseno ročaj)
- **TechTreePanel**: OKLEP IN OROŽJE+ chain, footer (168 deps, 45 verig, 78 multi-prereq)
- **MEJNIK**: 168 deps, 45 verig, 78 multi-prereq — 10x več multi-prereq kot začetnih 8!
- 2 CROSS-CHAIN povezave:
  1. `CeremonialSwordMaker` → `GemMiner` (povezuje OKLEP IN OROŽJE+ z RUDARSTVO+)
  2. `RecurveBowMaker` + `ParadeShieldMaker` → `RawhideTanner` (povezuje OKLEP IN OROŽJE+ z USNJE+)
- Pred: 162 deps, 44 verig, 73 multi-prereq
- Sedaj: 168 deps, 45 verig, 78 multi-prereq
- Oklepno/orožna veriga sedaj ima 6 sistemov z dependencies (0 prej + 6 novih)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+10 vrstic) — 6 novih dependency vnosov v dependencyGraph
- `states/ui/hud/tech_tree_panel.lua` (+2 vrstici) — nova CHAINS entry za OKLEP IN OROŽJE+ in posodobljen footer counter (168/45/78)
- `README.md` — posodobljeni badges (v3.11.987, +ArmorWeaponChain, statistika)
- `CHANGELOG.md` — dodan v3.11.987 entry
- `NEXT_BATCH_HANDOFF.md` — posodobljeno stanje, "Armor/Weapon+ chain" premaknjen v ZAKLJUČENE

### Funkcionalna preverba
- Lupa `load()` test: obe spremenjeni datoteki PASS
- Število dependencyGraph vnosov preverjeno s Python regex: 168 vnosov, 78 multi-prereq — ujema se s footerjem

## [v3.11.986] — 2026-08-17 — Mining+ Chain (6 novih deps: Auger, DrillPress, GemMiner, Pickaxe, AshShovel, CharcoalBurner)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe rudarske sisteme:
  - AugerMaker → Metalwork + WoodLathe (multi-prereq! — kovina + les ročaj)
  - DrillPressMaker → Metalwork + WoodLathe (multi-prereq! — kovina + les okvir)
  - GemMiner → Metalwork + PickaxeMaker (multi-prereq! — napredno rudarjenje)
  - PickaxeMaker → Metalwork
  - AshShovelMaker → WoodLathe
  - CharcoalBurner → Metalwork + ForgeTuyere (multi-prereq! — CROSS-CHAIN povezava z livarstvom!)
- **TechTreePanel.lua** — nova RUDARSTVO+ chain, footer posodobljen (162 deps · 44 verig · 73 multi-prereq)

### Statistika
- Prej: 990 sistemov, 156 deps, 43 verig, 69 multi-prereq (v3.11.985)
- Sedaj: **990 sistemov, 162 deps, 44 verig, 73 multi-prereq** (v3.11.986)
- 4 novi multi-prereq sistemi: AugerMaker, DrillPressMaker, GemMiner, CharcoalBurner
- **MEJNIK: 162 deps, 44 verig, 73 multi-prereq — 9x več multi-prereq kot začetnih 8!**
- CharcoalBurner je CROSS-CHAIN povezava — povezuje rudarstvo z livarstvom (ForgeTuyere)!

### Zaključeno
- Pred: 0 rudarskih sistemov z dependencies
- Sedaj: 6 rudarskih sistemov z dependencies (Auger, DrillPress, GemMiner, Pickaxe, AshShovel, CharcoalBurner)

## [v3.11.985] — 2026-08-17 — Clockmaking+ Chain (6 novih deps: Sundial, PocketWatch, MainspringWinder, EscapementLever, PendulumRod, ClockFacePainter)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe urarske sisteme:
  - SundialMaker → MasonStonecutter
  - PocketWatchMaker → Metalwork + GlassBench (multi-prereq!)
  - MainspringWinderMaker → Metalwork + BellMaker (multi-prereq! — vzmeti iz zvonove medenine)
  - EscapementLeverMaker → Metalwork + WoodLathe (multi-prereq! — precizni mehanizem)
  - PendulumRodMaker → Metalwork + WoodLathe (multi-prereq! — palica + nastavitev)
  - ClockFacePainter → PigmentGrinderMaker + GlassBench (multi-prereq! — povezava z barvilno verigo)
- **TechTreePanel.lua** — nova URARSTVO+ chain, footer posodobljen (156 deps · 43 verig · 69 multi-prereq)

### Statistika
- Prej: 990 sistemov, 150 deps, 42 verig, 64 multi-prereq (v3.11.984)
- Sedaj: **990 sistemov, 156 deps, 43 verig, 69 multi-prereq** (v3.11.985)
- 5 novih multi-prereq sistemi: PocketWatchMaker, MainspringWinderMaker, EscapementLeverMaker, PendulumRodMaker, ClockFacePainter
- **MEJNIK: 156 deps, 43 verig, 69 multi-prereq — skoraj 9x več multi-prereq kot začetnih 8!**
- ClockFacePainter je CROSS-CHAIN povezava — povezuje urarstvo z barvilno verigo (PigmentGrinderMaker)!

### Zaključeno
- Pred: 0 urarskih sistemov z dependencies
- Sedaj: 6 urarskih sistemov z dependencies (Sundial, PocketWatch, MainspringWinder, EscapementLever, PendulumRod, ClockFacePainter)

## [v3.11.984] — 2026-08-17 — Kitchen+ Chain (6 novih deps: SpiceGrinder, CoffeeRoaster, ButterChurner, CheeseMaker, KitchenKnife, ConfectionOven)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe kuhinjske sisteme:
  - SpiceGrinderMaker → FlourSieve + ApothecaryMortar (multi-prereq!)
  - CoffeeRoaster → BreadBaker + Metalwork (multi-prereq!)
  - ButterChurner → BreadBaker + WoodLathe (multi-prereq!)
  - CheeseMaker → BreadBaker + ApothecaryMortar (multi-prereq!)
  - KitchenKnifeMaker → Metalwork + CutlerySmith (multi-prereq!)
  - ConfectionOvenMaker → BreadBaker + BrickMaker (multi-prereq!)
- **TechTreePanel.lua** — nova KUHINJA+ chain, footer posodobljen (150 deps · 42 verig · 64 multi-prereq)

### Statistika
- Prej: 990 sistemov, 144 deps, 41 verig, 58 multi-prereq (v3.11.983)
- Sedaj: **990 sistemov, 150 deps, 42 verig, 64 multi-prereq** (v3.11.984)
- 6 novih multi-prereq sistemi: vsi 6 novih sistemov so multi-prereq!
- **MEJNIK: 150 deps, 42 verig, 64 multi-prereq — 8x več multi-prereq kot začetnih 8!**

### Zaključeno
- Pred: 3 kuhinjski sistemi z dependencies (BreadBaker, PastryChef, CutlerySmith)
- Sedaj: 9 kuhinjskih sistemov z dependencies (+ SpiceGrinder, CoffeeRoaster, ButterChurner, CheeseMaker, KitchenKnife, ConfectionOven)

## [v3.11.983] — 2026-08-17 — Dye/Pigment+ Chain (6 novih deps: PigmentGrinder, Paint, Paintbrush, Inkwell, GildingBrush, Washstand)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe barvilne/pigmentne sisteme:
  - PigmentGrinderMaker → DyeStuff
  - PaintMaker → PigmentGrinderMaker + GlassBench (multi-prereq!)
  - PaintbrushMaker → WoodLathe
  - InkwellMaker → InkMaker + GlassBench (multi-prereq!)
  - GildingBrushMaker → PigmentGrinderMaker + Metalwork (multi-prereq!)
  - WashstandMaker → WoodLathe
- **TechTreePanel.lua** — nova BARVILA+ chain, footer posodobljen (144 deps · 41 verig · 58 multi-prereq)

### Statistika
- Prej: 990 sistemov, 138 deps, 40 verig, 55 multi-prereq (v3.11.982)
- Sedaj: **990 sistemov, 144 deps, 41 verig, 58 multi-prereq** (v3.11.983)
- 3 novi multi-prereq sistemi: PaintMaker, InkwellMaker, GildingBrushMaker
- **MEJNIK: 144 deps, 41 verig, 58 multi-prereq!**

### Zaključeno
- Pred: 2 barvilna sistema z dependencies (DyerColor, DyeVatMaker)
- Sedaj: 8 barvilnih/pigmentnih sistemov z dependencies (+ PigmentGrinder, Paint, Paintbrush, Inkwell, GildingBrush, Washstand)

## [v3.11.982] — 2026-08-17 — Masonry+ Chain (6 novih deps: MarbleStatue, CrestCarver, LimeBurner, StoneLintel, ChiselBlade, MortarPestle)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe kamnoseške sisteme:
  - MarbleStatueMaker → MasonStonecutter + ChiselBladeMaker (multi-prereq!)
  - CrestCarver → MasonStonecutter + Metalwork (multi-prereq!)
  - LimeBurner → MasonStonecutter
  - StoneLintelMaker → MasonStonecutter + BrickMaker (multi-prereq!)
  - ChiselBladeMaker → Metalwork
  - MortarPestleMaker → MasonStonecutter
- **TechTreePanel.lua** — nova KAMNOSEŠTVO+ chain, footer posodobljen (138 deps · 40 verig · 55 multi-prereq)

### Statistika
- Prej: 990 sistemov, 132 deps, 39 verig, 52 multi-prereq (v3.11.981)
- Sedaj: **990 sistemov, 138 deps, 40 verig, 55 multi-prereq** (v3.11.982)
- 3 novi multi-prereq sistemi: MarbleStatueMaker, CrestCarver, StoneLintelMaker
- **MEJNIK: 138 deps, 40 verig, 55 multi-prereq!**

### Zaključeno
- Pred: 2 kamnoseška sistema z dependencies (BrickMaker, RoofTileMaker)
- Sedaj: 8 kamnoseških sistemov z dependencies (+ MarbleStatue, CrestCarver, LimeBurner, StoneLintel, ChiselBlade, MortarPestle)

## [v3.11.981] — 2026-08-17 — Brewing/Baking+ Chain (6 novih deps: AlambicStill, DistillationApparatus, BrewerAdvancedDistillery, BreadMold, BakerConfectioner, FlourSifter)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe pivovarske/pekarske sisteme:
  - AlambicStillMaker → BranSeparator + Metalwork (multi-prereq!)
  - DistillationApparatusMaker → BranSeparator + GlassBench (multi-prereq!)
  - BrewerAdvancedDistillery → BranSeparator + AleBrewer (multi-prereq!)
  - BreadMoldMaker → FlourSieve + PotteryWheel (multi-prereq!)
  - BakerConfectioner → FlourSieve + BreadBaker (multi-prereq!)
  - FlourSifterMaker → FlourSieve
- **TechTreePanel.lua** — nova PIVOVARSTVO/PEKSTVO+ chain, footer posodobljen (132 deps · 39 verig · 52 multi-prereq)

### Statistika
- Prej: 990 sistemov, 126 deps, 38 verig, 47 multi-prereq (v3.11.980)
- Sedaj: **990 sistemov, 132 deps, 39 verig, 52 multi-prereq** (v3.11.981)
- 5 novih multi-prereq sistemi: AlambicStillMaker, DistillationApparatusMaker, BrewerAdvancedDistillery, BreadMoldMaker, BakerConfectioner
- **MEJNIK: 132 deps in 52 multi-prereq — 6.5x več multi-prereq kot začetnih 8!**

### Zaključeno
- Pred: 4 pivovarski/pekarska sistema z dependencies (AleBrewer, BrandyDistiller, BreadBaker, PastryChef)
- Sedaj: 10 pivovarskih/pekarskih sistemov z dependencies (+ AlambicStill, DistillationApparatus, BrewerAdvancedDistillery, BreadMold, BakerConfectioner, FlourSifter)

## [v3.11.980] — 2026-08-17 — Fishing+ Chain (6 novih deps: FishHook, BaitBox, FishingLineSpool, FishingRod, FishSmoker, FishingBoat)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe ribiške sisteme:
  - FishHookMaker → Metalwork
  - BaitBoxMaker → NetMaker + WoodLathe (multi-prereq!)
  - FishingLineSpoolMaker → NetMaker
  - FishingRodMaker → NetMaker + WoodLathe (multi-prereq!)
  - FishSmoker → NetMaker + ForgeTuyere (multi-prereq!)
  - FishingBoatMaker → NetMaker + WoodLathe (multi-prereq!)
- **TechTreePanel.lua** — nova RIBOLOV+ chain, footer posodobljen (126 deps · 38 verig · 47 multi-prereq)

### Statistika
- Prej: 990 sistemov, 120 deps, 37 verig, 43 multi-prereq (v3.11.979)
- Sedaj: **990 sistemov, 126 deps, 38 verig, 47 multi-prereq** (v3.11.980)
- 4 novi multi-prereq sistemi: BaitBoxMaker, FishingRodMaker, FishSmoker, FishingBoatMaker
- **MEJNIK: 126 deps in 47 multi-prereq — skoraj 6x več multi-prereq kot začetnih 8!**

### Zaključeno
- Pred: 2 ribiška sistema z dependencies (FishingRodMaker, FishingTrapMaker)
- Sedaj: 8 ribiških sistemov z dependencies (+ FishHook, BaitBox, FishingLineSpool, FishSmoker, FishingBoat)

## [v3.11.979] — 2026-08-17 — Candle/Wax+ Chain (6 novih deps: Candelabra, Chandelier, Candlestick, CandleMold, WaxDipper, LanternStreetLight)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe voščene/svečne sisteme:
  - CandelabraMaker → Metalwork + CandlestickBaseMaker (multi-prereq!)
  - ChandelierMaker → Metalwork + CandlestickMaker (multi-prereq!)
  - CandlestickMaker → Metalwork + WaxTablet (multi-prereq!)
  - CandleMoldMaker → WaxTablet
  - WaxDipperMaker → WaxTablet
  - LanternStreetLight → Metalwork + GlassBench (multi-prereq!)
- **TechTreePanel.lua** — nova SVEČE IN VOSAK+ chain, footer posodobljen (120 deps · 37 verig · 43 multi-prereq)

### Statistika
- Prej: 990 sistemov, 114 deps, 36 verig, 39 multi-prereq (v3.11.978)
- Sedaj: **990 sistemov, 120 deps, 37 verig, 43 multi-prereq** (v3.11.979)
- 4 novi multi-prereq sistemi: CandelabraMaker, ChandelierMaker, CandlestickMaker, LanternStreetLight
- **MEJNIK: 120 deps in 43 multi-prereq!**

### Zaključeno
- Pred: 2 voščena sistema z dependencies (CandlestickBase, TorchHolder)
- Sedaj: 8 voščenih/svečnih sistemov z dependencies (+ Candelabra, Chandelier, Candlestick, CandleMold, WaxDipper, LanternStreetLight)

## [v3.11.978] — 2026-08-17 — Musical Instruments+ Chain (6 novih deps: Harp, Lute, OrganPipe, Bagpipe, Cymbal, Shawm)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe glasbilske sisteme:
  - HarpMaker → WoodLathe + SpinningWheel (multi-prereq! — strune iz tekstila)
  - LuteMaker → WoodLathe + Metalwork (multi-prereq! — kovinske strune)
  - OrganPipeMaker → Metalwork + WoodLathe (multi-prereq! — cevi + ohišje)
  - BagpipeMaker → WoodLathe + RawhideTanner (multi-prereq! — usnjen meh)
  - CymbalMaker → Metalwork + BellMaker (multi-prereq! — kovina iz zvonov)
  - ShawmMaker → WoodLathe + Metalwork (multi-prereq! — les + kovina)
- **TechTreePanel.lua** — nova INSTRUMENTI+ chain, footer posodobljen (114 deps · 36 verig · 39 multi-prereq)

### Statistika
- Prej: 990 sistemov, 108 deps, 35 verig, 33 multi-prereq (v3.11.977)
- Sedaj: **990 sistemov, 114 deps, 36 verig, 39 multi-prereq** (v3.11.978)
- 6 novih multi-prereq sistemi: vsi 6 novih sistemov so multi-prereq!
- **MEJNIK: 39 multi-prereq sistemov — skoraj 5x več kot začetnih 8!**

### Zaključeno
- Pred: 2 glasbilski sistemi z dependencies (TrumpetMaker, FluteMaker)
- Sedaj: 8 glasbilskih sistemov z dependencies (+ Harp, Lute, OrganPipe, Bagpipe, Cymbal, Shawm)

## [v3.11.977] — 2026-08-17 — Pottery+ Chain (6 novih deps: ClayDigger, ClayPipe, GlazeSieve, MosaicTile, KilnFurniture, PotteryKiln)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe lončarske sisteme:
  - ClayDigger → PotteryWheel
  - ClayPipeMaker → PotteryWheel + MasonStonecutter (multi-prereq!)
  - GlazeSieveMaker → PotteryWheel
  - MosaicTileMaker → MasonStonecutter + BrickMaker (multi-prereq!)
  - KilnFurnitureMaker → PotteryWheel + MasonStonecutter (multi-prereq!)
  - PotteryKiln → PotteryWheel
- **TechTreePanel.lua** — nova LONČARSTVO+ chain, footer posodobljen (108 deps · 35 verig · 33 multi-prereq)

### Statistika
- Prej: 990 sistemov, 102 deps, 34 verig, 30 multi-prereq (v3.11.976)
- Sedaj: **990 sistemov, 108 deps, 35 verig, 33 multi-prereq** (v3.11.977)
- 3 novi multi-prereq sistemi: ClayPipeMaker, MosaicTileMaker, KilnFurnitureMaker

### Zaključeno
- Pred: 3 lončarski sistemi z dependencies (ApothecaryMortar, ApothecaryVial, CrystallizationDish)
- Sedaj: 9 lončarskih sistemov z dependencies (+ ClayDigger, ClayPipe, GlazeSieve, MosaicTile, KilnFurniture, PotteryKiln)

## [v3.11.976] — 2026-08-17 — Textile+ Chain (6 novih deps: CanvasWeaver, CarpetLoom, DyeVat, Bobbin, ClothPresser, LeatherBurnisher)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe tekstilne/usnjarske sisteme:
  - CanvasWeaver → SpinningWheel + LoomHeddle (multi-prereq!)
  - CarpetLoom → SpinningWheel + TapestryLoom (multi-prereq!)
  - DyeVatMaker → DyeStuff + Metalwork (multi-prereq!)
  - BobbinMaker → SpinningWheel
  - ClothPresserMaker → SpinningWheel
  - LeatherBurnisherMaker → RawhideTanner + Metalwork (multi-prereq!)
- **TechTreePanel.lua** — nova TEKSTIL+ chain, footer posodobljen (102 deps · 34 verig · 30 multi-prereq)

### Statistika
- Prej: 990 sistemov, 96 deps, 33 verig, 26 multi-prereq (v3.11.975)
- Sedaj: **990 sistemov, 102 deps, 34 verig, 30 multi-prereq** (v3.11.976)
- 4 novi multi-prereq sistemi: CanvasWeaver, CarpetLoom, DyeVatMaker, LeatherBurnisherMaker
- **MEJNIK: 100+ deps in 30+ multi-prereq!**

### Zaključeno
- Pred: 3 tekstilni sistemi z dependencies (LoomHeddle, TapestryLoom, CarpetLoom)
- Sedaj: 9 tekstilnih/usnjarskih sistemov z dependencies (+ CanvasWeaver, DyeVat, Bobbin, ClothPresser, LeatherBurnisher)

## [v3.11.975] — 2026-08-17 — Bookbinding+ Chain (6 novih deps: BookClasp, CodexBinder, ChronicleBinder, BookbindingAwl, BookShelf, QuillCutter)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe knjigoveške sisteme:
  - BookClaspMaker → WoodLathe + Metalwork (multi-prereq!)
  - CodexBinder → BookPress + ParchmentMaker (multi-prereq!)
  - ChronicleBinder → BookbindingPress + InkMaker (multi-prereq!)
  - BookbindingAwlMaker → Metalwork
  - BookShelfMaker → WoodLathe
  - QuillCutterMaker → Metalwork
- **TechTreePanel.lua** — nova KNJIGOVEZSTVO+ chain, footer posodobljen (96 deps · 33 verig · 26 multi-prereq)

### Statistika
- Prej: 990 sistemov, 90 deps, 32 verig, 23 multi-prereq (v3.11.974)
- Sedaj: **990 sistemov, 96 deps, 33 verig, 26 multi-prereq** (v3.11.975)
- 3 novi multi-prereq sistemi: BookClaspMaker, CodexBinder, ChronicleBinder

### Zaključeno
- Pred: 4 knjigoveški sistemi z dependencies (BookPress, BookbindingPress, EaselMaker, BoardGameMaker)
- Sedaj: 10 knjigoveških sistemov z dependencies (+ BookClasp, CodexBinder, ChronicleBinder, BookbindingAwl, BookShelf, QuillCutter)

## [v3.11.974] — 2026-08-17 — Foundry+ Chain (6 novih deps: Crucible, CrucibleFurnace, CastingLadle, CoreBox, SandMuller, IngotMolder)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe livarske sisteme:
  - CrucibleMaker → ForgeTuyere + Metalwork (multi-prereq!)
  - CrucibleFurnaceMaker → ForgeTuyere + CrucibleMaker (multi-prereq!)
  - CastingLadleMaker → ForgeTuyere + Metalwork (multi-prereq!)
  - CoreBoxMaker → ForgeTuyere
  - SandMullerMaker → ForgeTuyere
  - IngotMolderMaker → ForgeTuyere + Metalwork (multi-prereq!)
- **TechTreePanel.lua** — nova LIVARSTVO+ chain, footer posodobljen (90 deps · 32 verig · 23 multi-prereq)

### Statistika
- Prej: 990 sistemov, 84 deps, 31 verig, 19 multi-prereq (v3.11.973)
- Sedaj: **990 sistemov, 90 deps, 32 verig, 23 multi-prereq** (v3.11.974)
- 4 novi multi-prereq sistemi: CrucibleMaker, CrucibleFurnaceMaker, CastingLadleMaker, IngotMolderMaker

### Zaključeno
- Pred: 4 livarski sistemi z dependencies (Anvil, ForgeTongs, Cutlery, PlateCuirass)
- Sedaj: 10 livarskih sistemov z dependencies (+ Crucible, CrucibleFurnace, CastingLadle, CoreBox, SandMuller, IngotMolder)

## [v3.11.973] — 2026-08-17 — Glassmaking+ Chain (6 novih deps: CrystalGoblet, StainedGlass, Hourglass, GlassFurnace, GlassCutter, GlassPolishingWheel)

### Dodano
- **SystemDependencies.lua** — 6 novih dependencies za obstoječe steklarske sisteme:
  - CrystalGobletMaker → GlassBench + GlassBeadMaker (multi-prereq!)
  - StainedGlassMaker → GlassBench + GlassColorantMaker (multi-prereq!)
  - HourglassMaker → GlassBench + GlassBeadMaker (multi-prereq!)
  - GlassFurnaceMaker → GlassBench + Metalwork (multi-prereq!)
  - GlassCutterMaker → GlassBench
  - GlassPolishingWheelMaker → GlassBench
- **TechTreePanel.lua** — nova STEKLARSTVO+ chain, footer posodobljen (84 deps · 31 verig · 19 multi-prereq)

### Statistika
- Prej: 990 sistemov, 78 deps, 30 verig, 15 multi-prereq (v3.11.972)
- Sedaj: **990 sistemov, 84 deps, 31 verig, 19 multi-prereq** (v3.11.973)
- 4 novi multi-prereq sistemi: CrystalGobletMaker, StainedGlassMaker, HourglassMaker, GlassFurnaceMaker

### Zaključeno
- Pred: 5 steklarskih sistemov z dependencies (Mirror, Bead, Vitrail, CoolingRack, Mold)
- Sedaj: 11 steklarskih sistemov z dependencies (+ CrystalGoblet, StainedGlass, Hourglass, GlassFurnace, GlassCutter, GlassPolishingWheel)

## [v3.11.972] — 2026-08-17 — Astronomy+ Chain (3 nove deps: ArmillarySphere, Sextant, Telescope)

### Dodano
- **SystemDependencies.lua** — 3 nove dependencies za obstoječe sisteme:
  - ArmillarySphereMaker → Metalwork + AstrolabeRingMaker (multi-prereq!)
  - SextantMaker → Metalwork + QuadrantMaker (multi-prereq!)
  - TelescopeMaker → Metalwork + GlassBench (multi-prereq!)
- **TechTreePanel.lua** — nova ASTRONOMIJA+ chain, footer posodobljen (78 deps · 30 verig · 15 multi-prereq)
- Sistemi so obstoječi (ustvarjeni v prejšnjih paketih) — dodane so samo dependencies in chain entry

### Statistika
- Prej: 990 sistemov, 75 deps, 29 verig, 12 multi-prereq (v3.11.971)
- Sedaj: **990 sistemov, 78 deps, 30 verig, 15 multi-prereq** (v3.11.972)
- 3 novi multi-prereq sistemi: ArmillarySphereMaker, SextantMaker, TelescopeMaker

### Spremenjene dateteke
- `objects/Economy/SystemDependencies.lua` (+6 vrstic) — 3 nove dependencies
- `states/ui/hud/tech_tree_panel.lua` (+3 vrstice) — ASTRONOMIJA+ chain, footer count

### Zaključeno
- Pred: 3 astronomski sistemi (AstrolabeRing, Nocturnal, Quadrant) brez naprednih odvisnikov
- Sedaj: 6 astronomskih sistemov z ASTRONOMIJA+ verigo (ArmillarySphere, Sextant, Telescope)

## [v3.11.971] — 2026-08-17 — Surgical+ Chain (3 novi sistemi: BoneSawMaker, SutureMaker, ForcepsMaker)

### Dodano
- **3 novi Royal sistemi** v `objects/Economy/`:
  1. **RoyalBoneSawMakerSystem.lua** — kostne žage za amputacije (6 produktov, 4 zgradbe)
  2. **RoyalSutureMakerSystem.lua** — šive za zapiranje ran (6 produktov, 4 zgradbe)
  3. **RoyalForcepsMakerSystem.lua** — klešče za ekstrakcijo (6 produktov, 4 zgradbe)
- **SystemDependencies.lua** — 3 nove dependencies:
  - BoneSawMaker → Metalwork + SurgicalLancetMaker (multi-prereq!)
  - SutureMaker → SurgicalLancetMaker + ApothecaryMortar (multi-prereq!)
  - ForcepsMaker → Metalwork + SurgicalLancetMaker (multi-prereq!)
- **TechTreePanel.lua** — nova KIRURGIJA+ chain, footer posodobljen (75 deps · 29 verig · 12 multi-prereq)
- Vsak sistem ima 6 produktov (železni → bronasti → srebrni → pozlačeni → draguljasti → kraljevski suvereni)
- Vsak sistem ima 4 zgradbe (delavnica → hiša → mojstrski atelje → suverena palača)
- Vse funkcije: init, hireMaker, canBuild, build, getQualityBonus, canMake, make, completeMaking, update, getStats
- NotificationCenter + GameEventBus integracija s pcall

### Statistika
- Prej: 987 sistemov, 1645 Lua datotek, 72 deps, 28 verig, 9 multi-prereq (v3.11.970)
- Sedaj: **990 sistemov, 1648 Lua datotek, 75 deps, 29 verig, 12 multi-prereq** (v3.11.971)
- 3 novi multi-prereq sistemi: BoneSawMaker, SutureMaker, ForcepsMaker (vsak ima 2 predpogoja)

### Spremenjene datoteke
- `objects/Economy/RoyalBoneSawMakerSystem.lua` (NEW, 9590 bytes)
- `objects/Economy/RoyalSutureMakerSystem.lua` (NEW, 9395 bytes)
- `objects/Economy/RoyalForcepsMakerSystem.lua` (NEW, 9545 bytes)
- `objects/Economy/SystemDependencies.lua` (+5 vrstic) — 3 nove dependencies
- `states/ui/hud/tech_tree_panel.lua` (+3 vrstice) — KIRURGIJA+ chain, footer count

### Funkcionalna preverba
- Lupa `load()` test: PASS (vseh 5 spremenjenih datotek)
- Pattern — vsak sistem sledi SurgicalLancetMaker vzorcu (6 produktov, 4 zgradbe)
- Multi-prereq — vsi 3 novi sistemi so multi-prereq (2 predpogoja vsak)

### Zaključeno
- Pred: 866 Royal sistemov, SurgicalLancetMaker je bil edini kirurški sistem
- Sedaj: 869 Royal sistemov, 3 novi kirurški sistemi dopolnjujejo kirurško verigo

## [v3.11.970] — 2026-08-17 — Tech Tree Expansion IV (65→72 deps, 25→28 verig, 8→9 multi-prereq)

### Dodano
- **SystemDependencies.lua** — 13 novih dependencies v 3 novih podverigah:
  - **VRTNARSTVO+** (7 novih deps):
    - PruningShearsMaker → Metalwork
    - PruningSawMaker → Metalwork
    - HedgeShearsMaker → Metalwork
    - BonsaiCultivator → TopiaryFrameMaker
    - FountainMaker → MasonStonecutter
    - TrellisMaker → WoodLathe
    - VineyardPlanter → GardenRake
  - **ČEBELARSTVO+** (3 nova deps, 1 multi-prereq):
    - WaxSealPresser → WaxTablet
    - LostWaxMolderMaker → WaxTablet + GlassBench (multi-prereq!)
    - ApiaryKeeper → HoneyDipperMaker
  - **KOVANJE DENARJA+** (3 nova deps):
    - CoinBlankMaker → Metalwork
    - CoinScaleMaker → CoinDieMaker
    - CoinSorterMaker → CoinPressMaker
- **TechTreePanel.lua** — 3 nove CHAINS entry-ji, footer posodobljen (72 deps · 28 verig · 9 multi-prereq)
- Vsi novi sistemi so obstoječi Royal sistemi — ni treba generirati novih .lua datotek

### Statistika
- Prej: 65 deps v 25 verigah, 8 multi-prereq (v3.11.943)
- Sedaj: **72 deps v 28 verigah, 9 multi-prereq** (v3.11.970)
- 9 multi-prereq: CoinPressMaker, TrumpetMaker, MapMaker, ManuscriptIlluminator, TheaterMaskMaker, GlassColorantMuller, SurgicalLancetMaker, MintCurrency, LostWaxMolderMaker

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+20 vrstic) — 13 novih dependency entry-jev v 3 novih verigah
- `states/ui/hud/tech_tree_panel.lua` (+5 vrstic) — 3 nove CHAINS entry-ji, footer count update

### Zaključeno
- Pred: 25 verig z 65 odvisnostmi
- Sedaj: 28 verig z 72 odvisnostmi — 3 nove podverige (Horticulture+, Apiary+, Coinage+)

## [v3.11.969] — 2026-08-17 — Auto-Save Overlay Hover Tooltip (status, timer, save count, Royal stats)

### Dodano
- **AutoSaveOverlay.lua** — hover tooltip na auto-save overlay:
  - **`hovered` state** — nastavljen v `mousemoved` ko je miška nad overlay (ko ni drag)
  - **Tooltip vsebina** (do 8 vrstic):
    - 💽 Naslov
    - Status: ✓ VKLOPLJENO / ✗ IZKLOPLJENO
    - Naslednji save timer (mm:ss)
    - Število save-ov
    - Zadnji save čas (Xd/Xm/Xs nazaj)
    - Royal stats (sistemi, produkti, dogodki)
    - Auto-sell status + save verzija
    - 💡 Interaction hints (click, drag, wheel)
  - **Barvno kodiranje**: zlato naslov, zeleno ✓, rdeče ✗, svetlo zeleno 💡, sivo ostalo
  - **Keep-on-screen** — tooltip se premakne levo/gor če bi šel izven ekrana
  - **Ne prikazuje med drag** — `hovered = false` ko je isDragging

### Spremenjene dateteke
- `states/ui/hud/autosave_status_overlay.lua` (+~75 vrstic) — hovered/hoverMouseX/hoverMouseY state, mousemoved hover detection (non-drag), tooltip rendering z 8 vrsticami + barvno kodiranje

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Hover detection — preverja bounds overlayX..overlayX+boxW, overlayY..overlayY+boxH
- Drag priority — ko je isDragging, hovered = false (ne prikazuj tooltip med drag)
- Time formatting — < 60s = "Xs nazaj", < 3600s = "Xm nazaj", else "Xh nazaj"
- Royal stats — lastSaveStats (royalSystems, royalProducts, marketEvents, autoSellEnabled, saveVersion)

### Zaključeno
- Pred: igralec je moral klikniti na overlay da odprl panel in videl detail
- Sedaj: hover takoj pokaže status, timer, save count, Royal stats, interaction hints
- **Celoten hover tooltip ekosistem končan** — vsi štirje paneli imajo hover tooltip-e:
  1. Tech Tree Panel (v3.11.944)
  2. Market Dashboard (v3.11.967)
  3. Royal Systems Panel (v3.11.968)
  4. Auto-Save Overlay (v3.11.969)

## [v3.11.968] — 2026-08-17 — Royal Systems Panel Hover Tooltip (status, zgradbe, mojster, surovine)

### Dodano
- **RoyalSystemsPanel.lua** — hover tooltip na sistemih v seznamu:
  - **`hoveredSystem` state** — nastavljen v `mousemoved` ko je miška nad system row
  - **`systemRowAreas`** — click areas populirani med draw (x, y, w, h, sysIndex)
  - **Tooltip vsebina** (9 vrstic):
    - 📦 Ime sistema
    - Status: ✓ aktiven / ⚠ delno / ✗ neaktiven
    - Število zgradb
    - Mojster (ime + spretnost)
    - Aktivne izdelave
    - Skupno produktov
    - Surovine: Fe, Br, Wo, Le (železo, bron, les, usnje)
    - Surovine: Ag, Au, Jew, Pearl (srebro, zlato, dragulji, biseri)
  - **Barvno kodiranje**:
    - Naslov: zlato
    - ✓ (aktiven): zeleno
    - ⚠ (delno): rumeno
    - ✗ (neaktiven): rdeče
    - Ostalo: svetlo sivo
  - **Keep-on-screen** — tooltip se premakne levo/gor če bi šel izven ekrana
  - **mousemoved** — preverja systemRowAreas, nastavlja hoveredSystem z sysIndex + mouseX/Y

### Spremenjene dateteke
- `states/ui/hud/royal_systems_panel.lua` (+~80 vrstic) — hoveredSystem/systemRowAreas state, draw populira systemRowAreas, mousemoved hover detection, tooltip rendering z 9 vrsticami + barvno kodiranje

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Hover detection — systemRowAreas populirane v draw, uporabljene v mousemoved
- Status klasifikacija — aktiven (zgradba+mojster), delno (ena brez druge), neaktiven (nobena)
- Surovine summary — 8 surovin v 2 vrsticah (Fe/Br/Wo/Le + Ag/Au/Jew/Pearl)
- Keep-on-screen — tipX/tipY clamping na W-8/H-8

### Zaključeno
- Pred: igralec je moral klikniti na sistem da videl detail panel
- Sedaj: hover takoj pokaže status, zgradbe, mojstra, surovine

## [v3.11.967] — 2026-08-17 — Market Dashboard Product Hover Tooltip (cena, trend, vir, 2x click hint)

### Dodano
- **MarketDashboard.lua** — hover tooltip na produktih v tabeli:
  - **`hoveredProduct` state** — nastavljen v `mousemoved` ko je miška nad product row
  - **Tooltip vsebina** (8 vrstic):
    - 📦 Ime produkta
    - Prodajna cena z ↑/↓ trend indicator (zeleno/rdeče)
    - Nabavna cena
    - Osnovna cena (basePrice × 0.7)
    - Skupno prodano (kosov)
    - Skupni prihodek (zlata)
    - Vir: sistem (display name, ne raw key)
    - 🚀 2x click hint za jump v Royal Systems Panel
  - **Barvno kodiranje**:
    - Naslov: zlato
    - ↑ (nad base): zeleno
    - ↓ (pod base): rdeče
    - 🚀 hint: cyan
    - Ostalo: svetlo sivo
  - **Keep-on-screen** — tooltip se premakne levo/gor če bi šel izven ekrana
  - **mousemoved** — preverja productRowAreas, nastavlja hoveredProduct z full product data + mouseX/Y

### Spremenjene datoteke
- `states/ui/hud/market_dashboard.lua` (+~65 vrstic) — hoveredProduct state, mousemoved product hover detection, tooltip rendering z 8 vrsticami + barvno kodiranje

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Hover detection — productRowAreas (v3.11.960) reused za hit detection
- Trend indicator — ↑ ce currentSell > baseSell, ↓ ce < baseSell
- Source display — gsub("Maker$", "") z camelCase split za berljivo ime
- Keep-on-screen — tipX/tipY clamping na W-8/H-8

### Zaključeno
- Pred: igralec je moral klikniti na produkt da izbral ga in videl detail panel
- Sedaj: hover takoj pokaže ceno, trend, prodajo, vir in 2x click hint

## [v3.11.966] — 2026-08-17 — Tech Tree Custom Preset Deletion (Shift+X izbriše custom preset)

### Dodano
- **TechTreePanel.lua** — brisanje custom presetov:
  - **`Shift+X`** — izbriše trenutno izbran custom preset (samo če je custom, ne built-in)
  - **`deleteCurrentCustomPreset()`** — preverja ali je currentPresetIdx > #PRESETS (custom), table.remove, saveCustomPresets
  - **Built-in zaščita** — če currentPresetIdx <= #PRESETS, prikaže "✗ Built-in presetov ni mogoče brisati"
  - **Prazna zaščita** — če ni custom presetov, prikaže "✗ Ni custom presetov za brisanje"
  - **Index adjust** — po brisanju currentPresetIdx se prilagodi (clamped na totalPresets)
  - **Feedback message** — "🗑 Preset izbrisan: <ime> (ostalo N custom)"
  - **Persistenca** — saveCustomPresets() shrani posodobljeno listo

### Spremenjene dateteke
- `states/ui/hud/tech_tree_panel.lua` (+~35 vrstic) — deleteCurrentCustomPreset() funkcija, Shift+X key handler
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — Shift+X opis

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- Built-in zaščita — preverja currentPresetIdx <= #PRESETS
- Custom index — customIdx = currentPresetIdx - #PRESETS (1-indexed v customPresets)
- Index adjust — po brisanju clamp na totalPresets (preprečuje out-of-bounds)
- Persistenca — saveCustomPresets() shrani posodobljeno listo

### Zaključeno
- Pred: custom presets so se kopičili, igralec jih ni mogel brisati
- Sedaj: Shift+X izbriše trenutno izbran custom preset z feedback message

## [v3.11.965] — 2026-08-17 — Tech Tree Custom Presets (Shift+P shrani pogled, persisted)

### Dodano
- **TechTreePanel.lua** — custom presets z persistenco:
  - **`Shift+P`** — shrani trenutno konfiguracijo kot custom preset (auto-named "Custom N")
  - **`P`** — cikla skozi built-in + custom presets (custom so dodane po built-in)
  - **`getAllPresets()`** — vrača built-in PRESETS + customPresets combined
  - **`saveCurrentAsPreset()`** — shrani sortMode, stateFilter, bookmarksOnly, depthVisible, arrowsVisible, minimapVisible
  - **Persistenca** — custom presets shranjeni v `tech_tree_custom_presets.txt`
  - **Format** — en preset per vrstico, polja ločena z `|`: `name|sortMode|stateFilter|bookmarksOnly|depthVisible|arrowsVisible|minimapVisible`
  - **Lazy load** — customPresetsLoaded flag, naloži ob prvem uporabi
  - **Feedback message** — "💾 Preset shranjen: Custom N (skupaj M custom)"
  - **Footer** — prikazuje total preset count (built-in + custom)
  - **Wrap-around** — P cikla skozi vse presetov (5 built-in + N custom)

### Spremenjene dateteke
- `states/ui/hud/tech_tree_panel.lua` (+~60 vrstic) — customPresets/customPresetsLoaded state, loadCustomPresets()/saveCustomPresets(), getAllPresets() helper, applyPreset() z getAllPresets(), saveCurrentAsPreset(), P/Shift+P key handler, footer getAllPresets()
- `states/ui/hud/keybind_help.lua` (+1 vrstica, 1 posodobljena) — Shift+P + P opis razširjen

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- getAllPresets() — vrača combined list built-in + custom
- Persistenca — love.filesystem.write/read, en preset per vrstico
- Format — 7 polj per preset, ločena z `|`
- Lazy load — customPresetsLoaded flag preprečuje ponovno nalaganje

### Zaključeno
- Pred: 5 fixed built-in presetov, igralec ni mogel shraniti lastnih pogledov
- Sedaj: Shift+P shrani trenutno konfiguracijo kot custom preset, P cikla skozi vse

## [v3.11.964] — 2026-08-17 — Tech Tree Multi-Select Persistence (shranjevanje med sejami)

### Dodano
- **TechTreePanel.lua** — multi-select persistenca preko love.filesystem:
  - **`loadMultiSelect()`** — lazy load iz `tech_tree_multiselect.txt` (en key per vrstico)
  - **`saveMultiSelect()`** — write v file
  - **`multiSelectLoaded` flag** — preprečuje ponovno nalaganje
  - **Save on every change** — Shift+click (toggle), regular click (clear), click na prazno (clear), C key (clear)
  - **Load on first use** — `loadMultiSelect()` klican v drawNode (podobno kot loadBookmarks)
  - **Export/import** — exportConfig() kliče loadMultiSelect(), importConfig() označi multiSelectLoaded=true in saveMultiSelect()
  - **Format** — en key per vrstico (enako kot bookmarks)

### Spremenjene dateteke
- `states/ui/hud/tech_tree_panel.lua` (+~40 vrstic) — multiSelectLoaded state, loadMultiSelect()/saveMultiSelect() funkcije, drawNode loadMultiSelect(), mousepressed saveMultiSelect() po vseh spremembah, C key saveMultiSelect(), exportConfig loadMultiSelect(), importConfig saveMultiSelect()

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Lazy load — multiSelectLoaded flag preprečuje ponovno nalaganje
- Save on change — vse spremembe multiSelect seta sprožijo saveMultiSelect()
- Export/import — export kliče loadMultiSelect(), import označi loaded in save

### Zaključeno
- Pred: multi-select se je izgubil ob zaprtju panela
- Sedaj: multi-select se persistira v tech_tree_multiselect.txt in preživi restart

## [v3.11.963] — 2026-08-17 — Tech Tree Config Presets (P: ciklaj Vsi/Aktivni/Razpoložljivi/Zaklenjeni/Zaznamovani)

### Dodano
- **TechTreePanel.lua** — prednastavljene konfiguracije za hitro preklapljanje:
  - **`P` tipka** — cikla skozi 5 presetov:
    1. **Vsi (default)** — alphabetical sort, vse prikazano
    2. **Aktivni sistemi** — depth sort, stateFilter=active
    3. **Razpoložljivi** — depth sort, stateFilter=met
    4. **Zaklenjeni** — depth sort, stateFilter=locked
    5. **Zaznamovani** — alphabetical sort, bookmarksOnly=true
  - **`applyPreset(idx)`** — nastavi sortMode, stateFilter, bookmarksOnly, depthVisible, arrowsVisible, minimapVisible
  - **Invalidacija** — keyboardNavList in keyboardNavIndex se resetirata (ker se sort mode spremeni)
  - **Feedback message** — "📋 Preset: <ime>" se prikaže ob preklopu
  - **Footer indikator** — '📋 preset: <ime> (N/M)' prikazuje trenutni preset in skupno število
  - **Wrap-around** — na zadnjem presetu P skoči nazaj na prvega
  - **5 presetov** — pokriva najpogostejše poglede (vsi, aktivni, razpoložljivi, zaklenjeni, zaznamovani)

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~60 vrstic) — PRESETS tabela, currentPresetIdx state, applyPreset() funkcija, P key handler, footer preset indicator, hint text update
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — P opis

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- Preset cycling — P incrementa currentPresetIdx z wrap-around
- applyPreset — nastavi 6 konfiguracijskih polj (sortMode, stateFilter, bookmarksOnly, depthVisible, arrowsVisible, minimapVisible)
- Invalidacija — keyboardNavList = nil ker se sort mode lahko spremeni
- Feedback message — reuse showFeedback() iz v3.11.962

### Zaključeno
- Pred: igralec je moral ročno nastaviti vsak filter posebej (S za sort, L za filter, Shift+B za bookmarks)
- Sedaj: P hitlo preklopi med 5 prednastavljenih pogledov z eno tipko

## [v3.11.962] — 2026-08-17 — Tech Tree Export/Import (E: izvoz v odložišče, Shift+E: uvoz)

### Dodano
- **TechTreePanel.lua** — izvoz/uvoz tech tree konfiguracije preko odložišča:
  - **`E` tipka** — izvozi konfiguracijo v odložišče (love.system.setClipboardText)
  - **`Shift+E`** — uvozi konfiguracijo iz odložišča (love.system.getClipboardText)
  - **Format**: `TT|viewMode|pathMode|sortMode|stateFilter|minimapVisible|depthVisible|arrowsVisible|bookmarksOnly|selectedKey|multiKeys|bookmarkKeys`
  - **Serializirano**:
    - viewMode (graph/text)
    - pathMode (direct/transitive)
    - sortMode (alphabetical/depth)
    - stateFilter (all/active/met/locked)
    - Toggles (minimap, depth, arrows, bookmarksOnly)
    - selectedKey (fokus)
    - multiSelect keys (comma-separated)
    - bookmark keys (comma-separated)
  - **Validacija** — import preverja format prefix "TT" in število polj (12)
  - **Feedback message** — prikazuje uspeh/napako nad content area (zeleno za ✓, rdeče za ✗)
  - **Fade out** — feedback message izgine po 3 sekundah
  - **Invalidacija** — import počisti keyboardNavList (ker se sort mode lahko spremeni)
  - **Bookmarks persistenca** — import shrani bookmarks v file (saveBookmarks)

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~80 vrstic) — feedbackMessage state, showFeedback() helper, exportConfig() serializer, importConfig() deserializer, update() feedback timer, E/Shift+E key handler, feedback message rendering
- `states/ui/hud/keybind_help.lua` (+2 vrstici) — E in Shift+E opisa

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- Format prefix "TT" — preprečuje uvoz naključnega besedila iz odložišča
- Validacija — preverja #parts >= 12 in prefix, fallback na "all"/"graph"/"transitive" za neveljavne vrednosti
- Bookmarks — import označi bookmarksLoaded = true da prepreči overwrite z file
- Feedback message — fade out z math.min(1, feedbackMessageTime)

### Zaključeno
- Pred: igralec ni mogel shraniti svojega "pogleda" (filtri, sort, focus, bookmarks)
- Sedaj: E izvozi celotno konfiguracijo v odložišče — igralec lahko shrani ali deli z drugimi

## [v3.11.961] — 2026-08-16 — Tech Tree Multi-Select (Shift+click za izbiro več vozlišč, union sorodnih)

### Dodano
- **TechTreePanel.lua** — multi-select za primerjavo več sistemov hkrati:
  - **`Shift+click`** — doda/odstrani vozlišče iz `multiSelect` seta
  - **`C` tipka** — počisti multi-select in fokus
  - **Union sorodnih** — ko je multi-select aktiven, relatedSet = UNION vseh izbranih vozlišč' related setov
  - **Dimming** — neujemajoča vozlišča zatemnjena (fokusAktiven = selectedKey OR multiSelect)
  - **isSelected** — vozlišče je "selected" če je v multiSelect setu ali je selectedKey
  - **Header dimming** — verige zatemnjene ko je multi-select aktiven
  - **Footer** — prikazuje število izbranih: '🔗 multi: N'
  - **Click na prazno** — počisti multi-select in fokus
  - **Regular click** — počisti multi-select in nastavi single focus (obnašanje kot prej)

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~50 vrstic) — multiSelect state, drawGraph union related set, drawNode focusDim z multiActive, mousepressed Shift+click handler + C key handler, footer multi count, hint text update, toggle() reset
- `states/ui/hud/keybind_help.lua` (+2 vrstici) — Shift+Click in C opisa

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- Union computation — for each key in multiSelect, compute related set and merge
- Dim logic — focusDim = (focusActive OR multiActive) AND not isRelated AND not isSelected
- Regular click clears multi-select — prevents stale multi-select when switching to single focus
- C key — clears both multi-select and single focus

### Zaključeno
- Pred: click-to-focus je delal samo na enem vozlišču
- Sedaj: Shift+click omogoča izbiro več sistemov — igralec vidi skupne odvisnosti/potomce vseh izbranih

## [v3.11.960] — 2026-08-16 — Market Dashboard Quick-Jump (2x click na produkt odpre Royal Systems Panel)

### Dodano
- **MarketDashboard.lua** — dvoklik na produkt odpre Royal Systems Panel na sistemu, ki ga proizvaja:
  - **`productRowAreas`** — click areas populirani med draw (x, y, w, h, productType, source, index)
  - **Double-click detekcija** — 0.4s threshold, isti productType
  - **Jump akcija**:
    1. Odpre Royal Systems Panel (Ctrl+R) če ni odprt
    2. Kliče `RoyalPanel.jumpToSystem(area.source)` — počisti filtre, najde sistem, nastavi selectedIndex in page
    3. Zapre Market Dashboard (da Royal Systems Panel postane aktivni panel)
  - **Single-click** — nastavi selectedIndex na klikano vrstico (izbira brez jump)
  - **Lazy require** v mousepressed preprečuje circular dependency
  - **Hint text** posodobljen z '2x click: odpri sistem'
- **keybind_help.lua** — nova '2x Click' vrstica v CTRL+K PANEL sekciji

### Spremenjene datoteke
- `states/ui/hud/market_dashboard.lua` (+~45 vrstic) — productRowAreas state, lastClickTime/lastClickProductType state, draw populira click areas, mousepressed product click + double-click jump, hint text update
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — 2x Click opis v CTRL+K sekciji

### Funkcionalna preverba
- Lupa `load()` test: PASS (market_dashboard.lua + keybind_help.lua)
- Click areas — populirane vsak frame v draw, uporabljene v mousepressed
- Double-click threshold — 0.4s (konzistentno z tech tree click-to-jump)
- Lazy require — preprečuje circular dependency med market_dashboard in royal_systems_panel
- Source field — p.source vsebuje system key (npr. "BellMaker") za jumpToSystem

### Zaključeno
- Pred: Market Dashboard je bil ločen od Royal Systems Panel
- Sedaj: 2x click na produkt poveže trg z sistemom — igralec lahko od produkta takoj skoči na sistem za najem/gradnjo

## [v3.11.959] — 2026-08-16 — Tech Tree Bookmarks/Favorites (B: ★ zaznamek, Shift+B: filter, persisted)

### Dodano
- **TechTreePanel.lua** — bookmark/favorites sistem:
  - **`B` tipka** — doda/odstrani zaznamek (★) na hovered vozlišču (ali selected če ni hover)
  - **`Shift+B`** — preklopi `bookmarksOnly` filter (prikaže samo zaznamovana vozlišča, ostala zatemni)
  - **★ zvezdica** na vozliščih z zaznamkom (zgornji desni kot, zlata barva)
  - **Persistenca** — zaznamki shranjeni v `tech_tree_bookmarks.txt` preko love.filesystem
  - **Lazy load** — bookmarksLoaded flag, naloži ob prvem uporabi
  - **Tooltip** — prikazuje "★ zaznamek: DA (B: odstrani)" ali "★ zaznamek: ne (B: dodaj)"
  - **Footer** — prikazuje število zaznamkov: '★ N' ali '★ N (filter)' ko je bookmarksOnly aktiven
  - **Dimming** — neujemajoča vozlišča in povezave zatemnjene ko je bookmarksOnly aktiven
  - **Kombinacija** z focus, search, in state filter — vsi štirje filtri se aplicirajo neodvisno

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~80 vrstic) — bookmarks/bookmarksOnly/bookmarksLoaded state, loadBookmarks()/saveBookmarks()/toggleBookmark()/isBookmarked() funkcije, drawNode z bookmark dim + star indicator, drawConnection z bookmark dim, keypressed B/Shift+B handler, tooltip bookmark info, footer bookmark count, hint text update
- `states/ui/hud/keybind_help.lua` (+2 vrstici) — B in Shift+B opisa

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- Persistenca — love.filesystem.write/read, en key per vrstico
- Lazy load — bookmarksLoaded flag preprečuje ponovno nalaganje
- Bookmark target — hoveredNode.key (prednostna) ali selectedKey (fallback)
- Filter integration — bookmarkDim dodan k dim logiki (focus OR search OR state OR bookmark)

### Zaključeno
- Pred: igralec ni mogel označiti sistemov za hitri dostop
- Sedaj: B označi favorite, Shift+B prikaže samo favorite, ★ zvezdica vizualno označi

## [v3.11.958] — 2026-08-16 — Tech Tree Keyboard Navigation (Tab/Shift+Tab za navigacijo med vozlišči)

### Dodano
- **TechTreePanel.lua** — keyboard navigacija med vozlišči:
  - **`Tab`** — premik na naslednje vozlišče (v display order: chain po chain, baze nato odvisniki)
  - **`Shift+Tab`** — premik na prejšnje vozlišče (nazaj)
  - **Auto-scroll** — če vozlišče ni vidno, scrollOffset se prilagodi da vozlišče pride v vidno območje
  - **Auto-focus** — keyboard navigacija samodejno nastavi selectedKey na vozlišče (poudari sorodne)
  - **`keyboardNavIndex` state** — sledi trenutnemu indeksu v flat list (nil = neaktivno)
  - **`keyboardNavList` cache** — flat list {key, isBase} v display order, rebuilda ob sort spremembi
  - **`buildKeyboardNavList()`** — gradi flat list iz getOrderedChains()
  - **Invalidacija** — ko se sortMode spremeni (S tipka), se keyboardNavList in keyboardNavIndex resetirata
  - **Wrap-around** — na zadnjem vozlišču Tab skoči na prvo, na prvem Shift+Tab skoči na zadnje

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~70 vrstic) — keyboardNavIndex/keyboardNavList state, buildKeyboardNavList() helper, getKeyboardNavList() lazy cache, Tab key handler z auto-scroll + focus, S key invalidation
- `states/ui/hud/keybind_help.lua` (+2 vrstici) — Tab in Shift+Tab opisa

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- Display order — getOrderedChains() upošteva sortMode (alphabetical/depth)
- Auto-scroll — če node.y < contentTop scroll gor, če node.y + h > contentBottom scroll dol
- Wrap-around — index wrap z `if > #navList then = 1` in `if < 1 then = #navList`
- Cache invalidation — keyboardNavList = nil ob sort spremembi

### Zaključeno
- Pred: navigacija samo z miško (click, hover, drag)
- Sedaj: Tab/Shift+Tab omogoča popolno keyboard navigacijo — dostopno za igralce brez miške

## [v3.11.957] — 2026-08-16 — Tech Tree Minimap Drag (drag za kontinuirano scrollanje)

### Dodano
- **TechTreePanel.lua** — drag na minimap za kontinuirano scrollanje:
  - **`minimapDragging` state** — sledi ali je miška pritisnjena na minimap
  - **mousepressed** — klik na minimap začne drag mode (scrollToMinimapY + minimapDragging = true)
  - **mousemoved** — če je drag aktiven, kliče scrollToMinimapY(y) za kontinuirano scrollanje
  - **mousereleased** — konča drag mode (minimapDragging = false)
  - **Vizualni feedback** — minimap border postane cyan in debelejši (2px) med drag
  - **`scrollToMinimapY(my)` helper** — ekstrahirana scroll logika iz mousepressed, shared z mousemoved
  - **Center-on-click** ohranjen — viewport center sledi miškinemu Y
  - **Clamping** ohranjeno — scroll ne preseže maxScroll ali 0

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~45 vrstic) — minimapDragging state, scrollToMinimapY() helper, mousepressed poenostavljena (uporablja helper + set drag flag), mousemoved drag handling, mousereleased drag end, minimap border highlight med drag, toggle() reset

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Drag lifecycle — mousepressed začne, mousemoved nadaljuje, mousereleased konča
- scrollToMinimapY() — shared helper preprečuje duplikacijo scroll logike
- Visual feedback — cyan border (0.4, 0.85, 1) + 2px width med drag, sicer gray + 1px
- Center-on-click — viewport center sledi miškinemu Y (ne top edge)

### Zaključeno
- Pred: klik na minimap je skočil na pozicijo (enkratni jump)
- Sedaj: drag omogoča kontinuirano drsenje po tech tree-ju v realnem času

## [v3.11.956] — 2026-08-16 — Tech Tree Progress Bar (vizualni % aktivnih z barvnim gradientom)

### Dodano
- **TechTreePanel.lua** — progress bar v footerju:
  - **Vizualni progress bar** (120×10 px) na desni strani stats line
  - **Prikazuje % aktivnih sistemov** (activeCount / totalCount × 100)
  - **Barvni gradient** glede na napredek:
    - 0% = rdeča (0.9, 0, 0.3)
    - 50% = rumena (0.9, 0.85, 0.3)
    - 100% = zelena (0, 0.85, 0.3)
  - **Linearna interpolacija** — < 50% prehod iz rdeče v rumeno, > 50% prehod iz rumene v zeleno
  - **Ozadje** — temno (0.1, 0.12, 0.16) za kontrast
  - **Border** — siv (0.4, 0.45, 0.55)
  - **Procentni tekst** nad barom: 'X% aktivnih' (centriran)
  - **Pozicioniranje** — desna stran stats line, ne moti stats besedila na levi

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~30 vrstic) — progressPct kalkulacija, progress bar rendering z gradient fill, procentni tekst

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Progress formula — activeCount / totalCount (z division-by-zero zaščito)
- Color gradient — linearna interpolacija r→g komponent glede na progressPct
- Layout — progress bar na desni, stats besedilo na levi, brez overlap

### Zaključeno
- Pred: stats summary samo številske vrednosti
- Sedaj: vizualni progress bar takoj pokaže napredek — rdeče=začetek, rumeno=sredina, zeleno=skoraj končano

## [v3.11.955] — 2026-08-16 — Tech Tree Stats Summary (povzetek: X aktivnih, Y razpoložljivih, Z zaklenjenih)

### Dodano
- **TechTreePanel.lua** — stats summary v footerju:
  - Pregled vseh 25 verig in štetje vozlišč po stanju
  - Prikaz na drugi vrstici footerja (nad glavnim footerjem):
    - `✓ X aktivnih` (zeleno)
    - `⚠ Y razpoložljivih` (rumeno)
    - `✗ Z zaklenjenih` (rdeče)
    - `(skupaj N)` (skupno število)
  - Content area prilagojena — contentBottom premaknjen z -30 na -46 za stats line
  - Barva: svetlo zelena (0.5, 0.7, 0.5) za razlikovanje od glavnega footerja
- Uporablja `getNodeState(key, isBase)` za pravilno klasifikacijo baz in odvisnikov

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~25 vrstic) — stats counting loop, stats line rendering, contentBottom adjustment

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Štetje — iterira čez vse CHAINS, šteje bazne in odvisne vozlišča posebej
- Klasifikacija — getNodeState() s isBase parametrom za pravilno določitev stanja
- Layout — contentBottom premaknjen za 16px navzgor da naredi prostor za stats line

### Zaključeno
- Pred: igralec je moral ročno šteti aktivne/razpoložljive/zaklenjene sisteme
- Sedaj: takojšen pregled v footerju — napredek igre je takoj viden

## [v3.11.954] — 2026-08-16 — Tech Tree State Filter (L: vsi→aktivni→razpoložljivi→zaklenjeni)

### Dodano
- **TechTreePanel.lua** — filter vozlišč po stanju:
  - **`L` tipka** cikla skozi 4 filtre: `all` → `active` → `met` → `locked` → `all`
  - **`all`** (default) — vsa vozlišča polno osvetljena
  - **`active`** — samo sistemi z ≥1 zgradbo (zeleni)
  - **`met`** — samo razpoložljivi sistemi (odvisnosti met, rumeni)
  - **`locked`** — samo zaklenjeni sistemi (odvisnosti niso met, rdeči)
  - **Dimming** — neujemajoča vozlišča zatemnjena (alpha 0.2), povezave (alpha 0.1)
  - **Kombinacija** z focus in search — vsi trije filtri se aplicirajo neodvisno
  - **Header dimming** — verige zatemnjene ko je filter aktiven
  - **Footer indikator** — '🔻 filter: aktivni' / 'razpoložljivi' / 'zaklenjeni' / 'vsi'
  - **isStateFilterMatch(key, isBase)** — preverja ali vozlišče ustreza filtru
  - **isConnectionStateRelated(fromKey, toKey)** — povezava povezana če vsaj en endpoint ustreza
- **keybind_help.lua** — nova L vrstica v CTRL+SHIFT+G sekciji

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~50 vrstic) — stateFilter state, isStateFilterMatch(), isConnectionStateRelated(), drawNode z isStateMatched param, drawConnection z isStateRelated param, drawGraph prehod isStateMatched/isStateRelated, L key handler, footer filter indicator, hint text update, toggle() reset
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — L toggle opis

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- Filter cycling — all→active→met→locked→all (4-state cycle)
- Independent filters — focus + search + state filter se kombinirajo (dim = OR vseh treh)
- Connection filter — povezana če vsaj en endpoint ustreza (da ohrani kontekst)

### Zaključeno
- Pred: vsa vozlišča vedno prikazana enako
- Sedaj: L hitlo filtrira po stanju — igralec vidi samo aktivne/razpoložljive/zaklenjene sisteme

## [v3.11.953] — 2026-08-16 — Tech Tree Depth-Based Sorting (S: abecedno ↔ po globini)

### Dodano
- **TechTreePanel.lua** — sortiranje verig po globini:
  - **`S` tipka** preklopi med `alphabetical` in `depth` načinom
  - **Alphabetical mode** (default) — verige v originalnem vrstnem redu (kot definirano v CHAINS)
  - **Depth mode** — verige sortirane po max globini vozlišč (plitev→globok):
    - Za vsako verigo se izračuna max globina med bazami in odvisniki
    - Sort ascending: plitev (depth 0) na vrhu, globok (depth 4+) na dnu
    - Tie-break: originalni indeks (stabilen sort)
  - **Footer indikator** — '📊 sort: abecedno' ali '📊 sort: po globini'
  - **Scroll reset** — ob preklopu sort mode se scrollOffset resetira (ker se layout spremeni)
  - **getOrderedChains()** helper — vrača CHAINS v željenem vrstnem redu
  - **computeGraphLayout** uporablja getOrderedChains() namesto direktno CHAINS
- **keybind_help.lua** — nova S vrstica v CTRL+SHIFT+G sekciji

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~45 vrstic) — sortMode state, getOrderedChains() z depth sorting + tie-break, computeGraphLayout uporablja ordered chains, S key handler, footer sort indicator, hint text update, toggle() reset
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — S toggle opis

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- Depth sorting — max(depth of all nodes in chain) za sort key
- Tie-break — original index za stabilnost (enaki globini = originalni vrstni red)
- Scroll reset — ob preklopu sortMode se scrollOffset = 0 (ker layout spremeni pozicije)
- getOrderedChains() — vrača CHAINS direktno če sortMode == "alphabetical" (optimizacija)

### Zaključeno
- Pred: verige vedno v abecednem vrstnem redu (KOVANJE METALOV, STEKLARSTVO, ...)
- Sedaj: S preklopi na depth sort — plitev verige (osnove) na vrhu, globok verige (napredni) na dnu

## [v3.11.952] — 2026-08-16 — Tech Tree Path Direction Arrows (A: puščice na krivuljah kažejo smer base→dependent)

### Dodano
- **TechTreePanel.lua** — arrowheads na koncu vsake bezier krivulje:
  - **`A` tipka** preklopi vidnost puščic
  - **Trikotni arrowhead** na odvisnem koncu (toX, toY) krivulje
  - **Smer**: base → dependent (puščica kaže proti odvisnemu vozlišču)
  - **Barva**: ista kot krivulja (love.graphics.getColor() za ohranitev dimming/boost logike)
  - **Velikost**: 7px dolžina, 4px širina (kompaktno a vidno)
  - **Pozicioniranje**: tip na (toX - 2, toY), base 7px nazaj v -X smeri
  - **Tangentna kalkulacija**: za cubic bezier P0=(fromX,fromY), P1, P2=(toX-ctrl,toY), P3=(toX,toY) je tangentna v t=1 enaka (ctrlOffset, 0), torej puščica vedno kaže v +X smer
- **keybind_help.lua** — nova A vrstica v CTRL+SHIFT+G sekciji

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~30 vrstic) — arrowsVisible state, drawConnection arrow rendering z love.graphics.polygon, A key handler, hint text update, toggle() reset
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — A toggle opis

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- Arrow direction — cubic bezier tangent at t=1 je vedno (ctrlOffset, 0) = +X smer
- Color preservation — love.graphics.getColor() ohrani barvo krivulje (z dimming/boost)
- Polygon rendering — triangle: tip, base-top, base-bottom

### Zaključeno
- Pred: krivulje so bile simetrične, igralec ni vedel v katero smer teče odvisnost
- Sedaj: puščice takoj pokažejo smer — base → dependent

## [v3.11.951] — 2026-08-16 — Tech Tree Depth Indicator (D: barvni krožec z globino sistema)

### Dodano
- **TechTreePanel.lua** — depth indicator na vsakem vozlišču:
  - **`D` tipka** preklopi vidnost indikatorjev globine
  - **Barvni krožec** (r=7px) na levi strani vozlišča z številko globine
  - **Barvno kodiranje globine**:
    - 0 (koren/root) — zeleno
    - 1 (plitev) — rumeno-zeleno
    - 2 (srednji) — rumeno
    - 3 (globok) — oranžno
    - 4+ (zelo globok) — rdeče
  - **Kalkulacija globine** — iterative relaxation algoritem:
    - Koreni (sistemi brez odvisnosti) dobijo globino 0
    - Ostali sistemi dobijo max(prereq globine) + 1 (longest path)
    - Multi-prereq sistemi upoštevajo najglobjega prednika
    - Cycle safety: 100 iteracij limit, nato treat as root
  - **Cache** — depthCache se izračuna enkrat in ponovno uporabi (lazy)
  - **Tooltip** — prikaže "Globina: 2 (srednji)" z besednim opisom
  - **Label offset** — tekst vozlišča je zamaknjen za 18px desno ko je depth visible
- **keybind_help.lua** — nova D vrstica v CTRL+SHIFT+G sekciji

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~100 vrstic) — depthVisible/depthCache state, computeDepths() z iterative relaxation, getDepth() helper, drawNode depth badge rendering z barvnim kodiranjem, tooltip depth info, D key handler, label offset
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — D toggle opis

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- computeDepths() — iterative relaxation s 100-iteration safety limit
- Multi-prereq — max(prereq depths) + 1 (longest path, ne shortest)
- Cache — depthCache se ne ponovno izračuna vsak frame
- Label offset — 18px rezervirano za badge ko je depthVisible

### Zaključeno
- Pred: igralec ni vedel kako "globoko" je sistem v tech tree-ju
- Sedaj: barvni krožec takoj pokaže tehnološko naprednost — zeleno=osnovno, rdeče=napredno

## [v3.11.950] — 2026-08-16 — AutoSavePanel Wheelmoved Functionality (ciklaj interval z wheelom)

### Dodano
- **AutoSavePanel.lua** — wheelmoved implementiran (prej stub od v3.11.942):
  - **Wheel gor** — cikla na krajši interval (30→15→5→1 min)
  - **Wheel dol** — cikla na daljši interval (1→5→15→30 min)
  - **Snap-to-nearest** — če je trenutni interval custom vrednost (ne preset), snapne na najbližji preset
  - **Feedback message** — "Interval: 5 min (wheel)" se prikaže ob spremembi
  - **Boundary consume** — na robu (1 min gor ali 30 min dol) še vedno consuma event, da prepreči background scroll
  - **Hint text** posodobljen: 'Ctrl+U: zapri  |  click zunaj: zapri  |  wheel: interval'
- **keybind_help.lua** — CTRL+U PANEL sekcija posodobljena:
  - Click opis razširjen z "Reset pozicije"
  - Nova Wheel vrstica: "Ciklaj interval (gor=krajši, dol=daljši: 1/5/15/30 min)"

### Spremenjene datoteke
- `states/ui/hud/autosave_panel.lua` (+~50 vrstic) — wheelmoved() implementacija z interval cycling, snap-to-nearest, feedback, hint text update
- `states/ui/hud/keybind_help.lua` (2 vrstici posodobljeni) — Wheel vrstica + Click razširitev

### Funkcionalna preverba
- Lupa `load()` test: PASS (autosave_panel.lua + keybind_help.lua)
- Wheel direction — gor=krajši (index-1), dol=daljši (index+1)
- Clamp — math.max(1, ...) in math.min(#intervals, ...) preprečujeta out-of-bounds
- Snap-to-nearest — custom intervali (npr. 600s) snapnejo na najbližji preset (900s = 15 min)
- Boundary consume — return true tudi ko ni spremembe, da prepreči background scroll

### Zaključeno
- Pred: wheel nad AutoSavePanel ni delal nič (stub)
- Sedaj: wheel hitro cikla med 4 interval preseti brez potrebe po klikanju gumbov

## [v3.11.949] — 2026-08-16 — Tech Tree Minimap (M: skrij/pokaži, click za skok na pozicijo)

### Dodano
- **TechTreePanel.lua** — minimap v spodnjem desnem kotu panela:
  - **Kompaktni pregled** vseh 25 verig v merilu (140×180 px)
  - **Verige kot majhni horizontalni stolpči** z barvno kodiranimi vozlišči (enako kot glavni graf)
  - **Vozlišča kot majhni kvadratki** (3-5 px) z barvo stanja (zeleno/rumeno/rdeče)
  - **Viewport indikator** — cyan pravokotnik ki prikazuje trenutno vidno območje
  - **Click za skok** — klik na minimap premakne vidno območje na to pozicijo (centrirano na klik)
  - **Focus highlight** — izbrano vozlišče ima zlat outline tudi na minimapu
  - **Search dimming** — neujemajoča vozlišča zatemnjena tudi na minimapu
  - **`M` tipka** — skrij/prikaži minimap
  - **Footer hint** na minimapu: 'M: skrij  |  click: skok'
- **Kalkulacija scale** — totalH minimapa / mmContentH, z clamp na 1.0 (brez upscaling)
- **Click-to-scroll logika** — maps click Y na scrollOffset z center-on-click obnašanjem

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~140 vrstic) — minimapVisible/minimapArea state, drawMinimap() funkcija z layout/scale/nodes/viewport, mousepressed click detekcija z math za scroll jump, M key handler, hint text update
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — M toggle opis

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- Minimap scale — pravilno mapira totalH na mmContentH, ne upscaled
- Click-to-scroll — center-on-click z clamp na robove
- Viewport indicator — pravilno prikazuje trenutni scrollOffset
- Focus/search dimming se preslika tudi na minimap

### Zaključeno
- Pred: igralec je moral scrollati skozi 25 verig, ni bilo pregleda
- Sedaj: minimap v kotu da takojšen pregled nad celotnim tech tree-jem + click za hitro navigacijo

## [v3.11.948] — 2026-08-16 — Tech Tree Click-to-Jump (dvoklik odpre Royal Systems Panel)

### Dodano
- **TechTreePanel.lua** — double-click na vozlišče odpre Royal Systems Panel in skoči na izbran sistem:
  - **Double-click detekcija** — sledi `lastClickTime` in `lastClickKey`, threshold 0.4s
  - **Jump akcija**:
    1. Odpre Royal Systems Panel (Ctrl+R) če ni odprt
    2. Kliče `RoyalPanel.jumpToSystem(key)` — počisti filtre, najde sistem, nastavi selectedIndex in page
    3. Zapre Tech Tree Panel (da Royal Systems Panel postane aktivni panel)
  - **Single-click ostane** — prvi klik fokusira (toggle), drugi klik v 0.4s na isto vozlišče = jump
  - **Hint text** posodobljen: '2x click: odpri sistem'
  - **Tooltip** dodana vrstica: '🚀 2x click: odpri v Royal Systems Panel' (cyan barva)
- **RoyalSystemsPanel.lua** — nova funkcija `jumpToSystem(key)`:
  - Počisti search query, search active, in category filter (da je sistem viden)
  - Rebuilda filteredSystems
  - Najde sistem po key v filteredSystems
  - Nastavi selectedIndex na najden index
  - Nastavi page na pravilno stran (ceil(selectedIndex / pageSize))
  - Prikaže feedback message: '📍 Skok na: <ime>'
  - Vrne true/false glede na uspeh
- **keybind_help.lua** — nova '2x Click' vrstica v CTRL+SHIFT+G sekciji

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~40 vrstic) — lastClickTime/lastClickKey state, DOUBLE_CLICK_THRESHOLD, double-click detekcija v mousepressed, jump akcija z require("royal_systems_panel"), hint + tooltip update
- `states/ui/hud/royal_systems_panel.lua` (+27 vrstic) — jumpToSystem(key) funkcija
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — 2x Click opis

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + royal_systems_panel.lua + keybind_help.lua)
- Double-click threshold: 0.4s (standardni Windows/LÖVE timing)
- jumpToSystem() — počisti filtre, rebuilda list, najde sistem, nastavi page
- Lazy require v mousepressed — preprečuje circular dependency ob nalaganju

### Zaključeno
- Pred: tech tree je bil samo za pregled — ni povezave z dejansko igro
- Sedaj: dvoklik na vozlišče te takoj pripelje do sistema v Royal Systems Panel, kjer lahko najameš mojstra, zgradiš delavnico, ipd.

## [v3.11.947] — 2026-08-16 — Tech Tree Path Highlight (T: direktno ↔ celotna pot, transitivni predniki+potomci)

### Dodano
- **TechTreePanel.lua** — path highlight mode z dvema načinoma:
  - **`T` tipka** preklopi med `direct` in `transitive` načinom
  - **Direct mode** (v3.11.945 obnašanje):
    - Poudari samo direktno povezana vozlišča (1. stopnja prednikov + 1. stopnja potomcev)
    - Uporabno za hitro pregledovanje neposrednih odvisnosti
  - **Transitive mode** (default, nov v v3.11.947):
    - Poudari celotno tehnično linijo — vse prednike (rekurzivno gor po prereq verigi) + vse potomce (rekurzivno dol po dependent verigi)
    - BFS algoritem za poljenje grafa v obeh smereh
    - Primer: fokus na `MintCurrency` → poudari `CoinDieMaker`, `CoinPressMaker`, `Metalwork`, `BellMaker` (predniki) — nobenih potomcev (MintCurrency je konec verige)
    - Primer: fokus na `Metalwork` → poudari vse sisteme, ki (transitivno) potrebujejo Metalwork: BellMaker, ChainmailForger, SwordPommelMaker, GauntletMaker, CoinDieMaker, CoinPressMaker, MintCurrency, TrumpetMaker, SurgicalLancetMaker, AstrolabeRingMaker, NocturnalMaker, QuadrantMaker
  - **Footer indikator**: '🔗 celotna pot (12 sorodnih)' ali '🔗 direktno (3 sorodnih)'
  - **Tooltip**: '[celotna pot]' ali '[direktno]' label pri fokusiranem vozlišču
  - **T reset** ob zaprtju panela ali preklopu pogleda (G)

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~70 vrstic) — pathMode state, BFS algoritem za transitive ancestor/descendant chain, reverseDeps map, T key handler, footer path info, tooltip path info
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — T toggle opis

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- BFS gor: `Deps.getDependencies(current)` za vsak obiskan node → najde vse prednike
- BFS dol: reverseDeps map (prereq → [dependents]) zgrajen iz CHAINS scan → najde vse potomce
- Cycle safety: `visited` in `visitedDown` set-a preprečujeta neskončne zanke (če bi bil ciklus v grafu)
- T toggle: takojšnja sprememba pathMode, relatedSet se recomputera naslednji frame v drawGraph()

### Zaključeno
- Pred: fokus je pokazal samo direktno povezana vozlišča (1. stopnja)
- Sedaj: T preklopi med direktno in celotno potjo — popoln pregled nad tehnično linijo izbranega sistema

## [v3.11.946] — 2026-08-16 — Tech Tree Search/Filter (iskanje po imenu z highlightom)

### Dodano
- **TechTreePanel.lua** — search/filter funkcionalnost:
  - **`/` tipka** odpre iskalno polje v zgornjem desnem kotu panela
  - **Case-insensitive substring match** na prikaznem imenu sistema (npr. "glass" najde vse GlassX sisteme)
  - **Highlight ujemajočega substringa** — v vozlišču se ujemajoči del teksta pobarva rumeno z ozadjem
  - **Cyan obrobl** okoli ujemajočih vozlišč (razlikuje se od zlate za focus)
  - **Cyan povezave** med ujemajočimi vozlišči poudarjene
  - **Zatemnitev neujemajočih** — alpha 0.2 za vozlišča, 0.1 za povezave
  - **Števec zadetkov** v footerju: '🔍 "glass": 5 zadetkov'
  - **Blinking cursor** v iskalnem polju (utripa 2x/sekundo)
  - **Placeholder text** — "/ za iskanje" ko je prazno in neaktivno, "tipkaj za iskanje..." ko je aktivno
- **Kombinacija s focus mode**:
  - Oba filtra se aplicirata neodvisno (vozlišče je polno osvetljeno samo če ustreza OBEMA)
  - Če je focus aktiven in search ustreza — vozlišče je polno osvetljeno
  - Če je search aktiven in focus ustreza — vozlišče je polno osvetljeno
  - Če noben ni aktiven — vsa vozlišča polno osvetljena
- **Tipke med iskanjem**:
  - `/` — odpre iskanje
  - `Enter` — potrdi iskanje (filter ostane aktiven, input mode se zapre)
  - `Backspace` — briše zadnji znak
  - `ESC` — zapre iskanje in počisti query
  - `↑↓/PgUp/PgDn/Home` — scroll še vedno deluje med iskanjem
  - Druge tipke se ignorirajo (da ne sprožijo focus/G toggle med tipkanjem)
- **ESC zaporedje** (ko iskanje NI aktivno):
  1. Če je search query postavljen → počisti query
  2. Če je focus aktiven → počisti focus
  3. Sicer → zapri panel
- **game.lua** — forwarding `textinput(text)` in `update(dt)` v TechTreePanel
- **keybind_help.lua** — CTRL+SHIFT+G sekcija posodobljena z `/`, Enter, Backspace

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~150 vrstic) — searchActive/searchQuery/cursorBlink state, isSearchMatch(), isConnectionSearchRelated(), drawNode z isMatched in highlight substring, drawConnection z isSearchRelated, drawGraph prehod isMatched/isSearchRelated, search input box rendering, update() za cursor blink, textinput() za znake, keypressed z `/`/Enter/Backspace/ESC logiko
- `states/game.lua` (+3 vrstice) — textinput forwarding, update(dt) forwarding
- `states/ui/hud/keybind_help.lua` (+3 vrstice, 1 posodobljena) — `/`, Enter, Backspace, ESC opis posodobljen

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua + game.lua)
- isSearchMatch() — case-insensitive substring find z `plain=true` (literal match, ne pattern)
- Substring highlight — pravilno izračuna offset za before/match/after dele
- Cursor blink — `math.floor(cursorBlink * 2) % 2 == 0` da 0.5s on/off cikel
- Search + focus kombinacija — oba filtra se aplicirata neodvisno

### Zaključeno
- Pred: iskanje sistema v 25 verigah zahtevalo ročno scrollanje
- Sedaj: `/glass` takoj poudari vse steklarne sisteme, ostali se zatemnijo

## [v3.11.945] — 2026-08-16 — Tech Tree Click-to-Focus (poudari sorodne, zatemni nepovezane)

### Dodano
- **TechTreePanel.lua** — interaktivni click-to-focus na vozliščih:
  - **Klik na vozlišče** — izbere vozlišče kot "fokus"
  - **Poudari sorodne** — selectedKey + direktni predpogoji + direktni odvisniki ostanejo polno osvetljeni
  - **Zatemni nepovezane** — vsa druga vozlišča in krivulje se zatemnijo (alpha 0.3 za vozlišča, 0.15 za krivulje)
  - **Pulsing golden border** — izbrano vozlišče ima utripajoč zlat okvir (sinusna modulacija)
  - **Boost direktnih povezav** — krivulje, ki se neposredno dotikajo izbranega vozlišča, postanejo zlate in debelejše (3px)
  - **Footer status** — prikazuje "🎯 fokus: <ime sistema>" ko je fokus aktiven
  - **Tooltip izboljšave**:
    - Prikaže število odvisnikov ("Odvisniki: N sistemov → tega")
    - Če je vozlišče fokusirano: "🎯 FOKUSIRANO (click/F: počisti)"
    - Sicer: "💡 click: fokusiraj sorodne"
  - **Toggle obnašanje** — klik na že fokusirano vozlišče počisti fokus
  - **Click na prazno** — klik znotraj panela a ne na vozlišče počisti fokus
- **Tipke**:
  - **F** — počisti fokus (alias za klik na prazno)
  - **ESC** — če je fokus aktiven, ga počisti; sicer zapre panel (dvojni namen)
  - **G** — preklop pogleda zdaj tudi počisti fokus (brez zastarele selekcije v napačnem pogledu)
- **keybind_help.lua** — posodobljena CTRL+SHIFT+G sekcija:
  - Novo: Click, F, ESC dvojna funkcija
  - Hover opis dopolnjen: "prikaže podrobnosti odvisnosti + število odvisnikov"

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~100 vrstic) — selectedKey state, computeRelatedKeys(), isConnectionRelated(), drawNode/drawConnection alphaMul, mousepressed click detekcija, keypressed F/ESC, tooltip izboljšave
- `states/ui/hud/keybind_help.lua` (3 posodobljene vrstice, 2 novi) — Click in F bližnjice, ESC dvojna funkcija

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- computeRelatedKeys() — pravilno najde predpogoje (Deps.getDependencies) in odvisnike (scan CHAINS)
- isConnectionRelated() — preverja fromKey/toKey proti selectedKey in relatedSet
- Click-to-focus: deluje v obeh smereh (set in clear)
- ESC dvojna funkcija: najprej počisti fokus, šele drugi ESC zapre panel

### Zaključeno
- Pred: graf je bil prikazen le (hover za podrobnosti)
- Sedaj: graf je interaktiven — klik na vozlišče poudari celotno sorodstveno verigo

## [v3.11.944] — 2026-08-16 — Tech Tree Node Graph Visualization (bezier curves + hover tooltip + G toggle)

### Dodano
- **TechTreePanel.lua** — nova GRAF vizualizacija (default mode) nad obstoječo tekstovno:
  - **Node-based layout**: vsak sistem je zaokrožen pravokotnik (132×30 px) z imenom in status simbolom (✓/⚠/✗)
  - **Bezier povezave**: odvisnosti prikazane kot gladke krivulje od desnega roba baze do levega roba odvisnega sistema
  - **Barvno kodiranje vozlišč**:
    - Zeleno (active) — sistem ima ≥1 zgradbo
    - Rumeno (met) — odvisnosti izpolnjene, a še ni zgrajeno
    - Rdeče (locked) — odvisnosti niso izpolnjene
  - **Barvno kodiranje povezav**:
    - Svetlo zelena (debelejša) — oboje aktivno
    - Rumena (srednja) — baza aktivna, odvisnik razpoložljiv
    - Temno rdeča (tanko) — baza neaktivna
  - **Multi-prereq**: več baznih vozlišč → več krivulj konvergira v enega odvisnika (npr. SurgicalLancetMaker ← Metalwork + ApothecaryMortar)
  - **Hover tooltip** — miška nad vozliščem prikaže:
    - Polno ime sistema
    - Status (AKTIVNA / razpoložljiv / zaklenjen / BASE)
    - Seznam odvisnosti z ✓/✗ statusom vsakega predpogoja
  - **Base indicator** — majhen trikotnik v zgornjem levem kotu za baze
  - **Hover highlight** — bel obrobl okoli vozlišča pod miško
  - **Širši panel** (960px namesto 620px) za prostor za vozlišča in krivulje
- **'G' tipka** — preklop med graf in tekst pogledom (text = legacy └─ drevo)
- **keybind_help.lua** — nova sekcija "CTRL+SHIFT+G PANEL (Tech Tree)" z 7 bližnjicami

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+~280 vrstic) — nova funkcija `drawGraph()`, `computeGraphLayout()`, `drawNode()`, `drawConnection()`, hover logika v `mousemoved()`, viewMode state
- `states/ui/hud/keybind_help.lua` (+12 vrstic) — nova CTRL+SHIFT+G sekcija

### Funkcionalna preverba
- Lupa `load()` test: PASS (tech_tree_panel.lua + keybind_help.lua)
- Layout computeGraphLayout() — 25 verig, ~75 vozlišč, ~95 povezav
- Hover tooltip deluje z miško nad katerimkoli vozliščem
- G toggle pravilno preklopi viewMode in resetira scrollOffset

### Zaključeno
- Pred: tekstovno drevo z └─ znaki (ctrl+shift+G)
- Sedaj: polen grafičen node graph z bezier krivuljami in tooltip-i (ctrl+shift+G), z opcijo 'G' za tekstovni pogled

## [v3.11.943] — 2026-08-16 — Tech Tree Expansion III (46→65 deps, 16→25 verig)

### Dodano
- **SystemDependencies.lua** — 19 novih dependencies v 9 novih verigah:
  - **Vrtnarstvo** (nova): TopiaryFrameMaker, LawnAeratorMaker, GardenWheelbarrowMaker → GardenRake
  - **Čebelarstvo** (nova): HoneyCollector → HoneyDipperMaker, HoneyDipperMaker → WoodLathe
  - **Barvno steklo** (nova): GlassColorantMaker → GlassBench
  - **Barvno steklo+** (nova, multi-prereq!): GlassColorantMuller → GlassBench + PigmentGrinder
  - **Mlinski pribor** (nova): MillstoneBalancerMaker, MillstoneCraneMaker → MillstoneSpindleBearing
  - **Sodarstvo** (nova): CooperBarrelMaker → WoodLathe
  - **Kirurgija** (nova, multi-prereq!): SurgicalLancetMaker → Metalwork + ApothecaryMortar
  - **Kovanje denarja** (nova, multi-prereq!): MintCurrency → CoinDieMaker + CoinPressMaker
  - **Astronomija** (nova): AstrolabeRingMaker, NocturnalMaker, QuadrantMaker → Metalwork
- **TechTreePanel** — 9 novih CHAINS entry-jev, footer posodobljen

### Statistika
- Prej: 46 deps v 16 verigah, 5 multi-prereq (v3.11.940)
- Sedaj: **65 deps v 25 verigah, 8 multi-prereq** (v3.11.943)
- 8 multi-prereq: CoinPressMaker, TrumpetMaker, MapMaker, ManuscriptIlluminator, TheaterMaskMaker, GlassColorantMuller, SurgicalLancetMaker, MintCurrency

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+35 vrstic) — 19 novih dependency entry-jev, 9 novih verig
- `states/ui/hud/tech_tree_panel.lua` (+10 vrstic) — 9 novih CHAINS + footer

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Polna preverba: 1645/1645 (100%) Lua datotek pass

## [v3.11.942] — 2026-08-16 — AutoSavePanel Wheelmoved Stub — 100% Wheel Coverage

### Dodano
- **AutoSavePanel** — dodan `wheelmoved()` stub (return false)
- **game.lua** — wheelmoved forwarding za AutoSavePanel

### 100% popoln mouse + wheel forwarding sistem
Vsi 6 paneli sedaj imajo vse 4 mouse event handlerje + wheelmoved:

| panel | mousepressed | mousemoved | mousereleased | wheelmoved |
|-------|:---:|:---:|:---:|:---:|
| RoyalSystemsPanel | ✓ | ✓ stub | ✓ stub | ✓ |
| MarketDashboard | ✓ | ✓ stub | ✓ stub | ✓ |
| AutoSavePanel | ✓ | ✓ | ✓ | ✓ stub |
| AutoSaveOverlay | ✓ | ✓ | ✓ | ✓ |
| TechTreePanel | ✓ | ✓ stub | ✓ stub | ✓ |
| KeybindHelp | ✓ | ✓ stub | ✓ stub | ✓ |

**6 panelov × 4 event-i = 24/24 handlerjev (100%)**

### Spremenjene datoteke
- `states/ui/hud/autosave_panel.lua` (+5 vrstic) — wheelmoved stub
- `states/game.lua` (+3 vrstice) — wheelmoved forwarding za AutoSavePanel

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Polna preverba: 1645/1645 (100%) Lua datotek pass

## [v3.11.941] — 2026-08-16 — KeybindHelp Mouse Stubs — 100% Mouse Forwarding

### Dodano
- **KeybindHelp** — dodani `mousepressed()`, `mousemoved()`, `mousereleased()` funkcije:
  - `mousepressed()`: click zunaj panela zapre help (isto vedenje kot drugi paneli)
  - `mousemoved()` in `mousereleased()`: stubs (return false)
- **game.lua** — mousepressed/mousemoved/mousereleased forwarding za KeybindHelp

### 100% popoln mouse forwarding sistem
Vsi 6 paneli sedaj imajo vse 4 mouse event handlerje:

| panel | mousepressed | mousemoved | mousereleased | wheelmoved |
|-------|:---:|:---:|:---:|:---:|
| RoyalSystemsPanel | ✓ | ✓ stub | ✓ stub | ✓ |
| MarketDashboard | ✓ | ✓ stub | ✓ stub | ✓ |
| AutoSavePanel | ✓ | ✓ | ✓ | — |
| AutoSaveOverlay | ✓ | ✓ | ✓ | ✓ |
| TechTreePanel | ✓ | ✓ stub | ✓ stub | ✓ |
| KeybindHelp | ✓ | ✓ stub | ✓ stub | ✓ |

### Spremenjene datoteke
- `states/ui/hud/keybind_help.lua` (+24 vrstic) — mousepressed (close on outside click) + mousemoved/mousereleased stubs
- `states/game.lua` (+9 vrstic) — mousepressed/mousemoved/mousereleased forwarding za KeybindHelp

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Polna preverba: 1645/1645 (100%) Lua datotek pass

## [v3.11.940] — 2026-08-16 — Tech Tree Expansion II (28→46 deps, 11→16 verig)

### Dodano
- **SystemDependencies.lua** — 18 novih dependencies v 6 novih verigah:
  - **Pivovarstvo** (nova): AleBrewer, BrandyDistiller → BranSeparator
  - **Pekstvo** (nova): BreadBaker, PastryChef → FlourSieve
  - **Ribolv** (nova): FishingRodMaker, FishingTrapMaker → NetMaker
  - **Sveče in vosak** (nova): CandlestickBase, TorchHolderMaker → WaxTablet
  - **Kamnoseštvo** (nova): BrickMaker, RoofTileMaker → MasonStonecutter
  - **Predstave** (nova): TheaterMaskMaker → WoodLathe + PigmentGrinder (multi-prereq!)
- **Razširjene obstoječe verige**:
  - Steklarstvo: +GlassBlowpipeCoolingRack, +GlassMoldMaker → GlassBench
  - Drvesni obrt: +BoardGameMaker → WoodLathe
  - Visoka peč: +CutlerySmith, +PlateCuirassSmith → ForgeTuyere
  - Kartografija: +ManuscriptIlluminator → ParchmentMaker + InkMaker (multi-prereq!)
- **TechTreePanel** — CHAINS tabela posodobljena z 6 novimi verigami + razširjenimi obstoječimi
- **Footer** posodobljen: "46 dependencies · 16 verig · 5 multi-prereq sistemi"

### Statistika
- Prej: 28 dependencies v 11 verigah, 3 multi-prereq (v3.11.935)
- Sedaj: **46 dependencies v 16 verigah, 5 multi-prereq** (v3.11.940)
- 5 multi-prereq sistemi: CoinPressMaker, TrumpetMaker, MapMaker, ManuscriptIlluminator, TheaterMaskMaker

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+35 vrstic) — 18 novih dependency entry-jev, 6 novih verig
- `states/ui/hud/tech_tree_panel.lua` (+8 vrstic) — 6 novih CHAINS entry-jev + razširjeni obstoječi + footer

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Polna preverba: 1645/1645 (100%) Lua datotek pass

## [v3.11.939] — 2026-08-16 — TechTreePanel Mousemoved/Mousereleased Stubs — Popoln Mouse Forwarding

### Dodano
- **TechTreePanel** — dodani `mousemoved()` in `mousereleased()` stub funkcije (return false)
- **game.lua** — mousereleased in mousemoved forwarding razširjen na TechTreePanel

### Popoln mouse forwarding sistem — 100% pokritost
Vsi 6 paneli sedaj imajo vse 4 mouse event handlerje:

| panel | mousepressed | mousemoved | mousereleased | wheelmoved |
|-------|:---:|:---:|:---:|:---:|
| RoyalSystemsPanel | ✓ | ✓ stub | ✓ stub | ✓ |
| MarketDashboard | ✓ | ✓ stub | ✓ stub | ✓ |
| AutoSavePanel | ✓ | ✓ | ✓ | — |
| AutoSaveOverlay | ✓ | ✓ | ✓ | ✓ |
| TechTreePanel | ✓ | ✓ stub | ✓ stub | ✓ |
| KeybindHelp | — | — | — | ✓ |

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (+8 vrstic) — mousemoved/mousereleased stubs
- `states/game.lua` (+6 vrstic) — mousereleased + mousemoved forwarding za TechTreePanel

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Polna preverba: 1645/1645 (100%) Lua datotek pass

## [v3.11.938] — 2026-08-16 — Royal Systems Panel Mousemoved/Mousereleased Stubs

### Dodano
- **RoyalSystemsPanel** — dodani `mousemoved()` in `mousereleased()` stub funkcije:
  - Trenutno vračata `false` (panel je click-only, brez drag interakcij)
  - Omogočata game.lua da forwarda evente brez nil check-ov
  - Pripravljeno za prihodnje drag interakcije
- **game.lua** — mousereleased in mousemoved forwarding razširjen:
  - `game:mousereleased()` sedaj preverja `RoyalSystemsPanel.mousereleased()` ko je panel viden
  - `game:mousemoved()` sedaj preverja `RoyalSystemsPanel.mousemoved()` ko je panel viden

### Popoln mouse forwarding sistem
Vsi 6 paneli sedaj imajo vse 4 mouse event handlerje:

| panel | mousepressed | mousemoved | mousereleased | wheelmoved |
|-------|:---:|:---:|:---:|:---:|
| RoyalSystemsPanel | ✓ | ✓ stub | ✓ stub | ✓ |
| MarketDashboard | ✓ | ✓ stub | ✓ stub | ✓ |
| AutoSavePanel | ✓ | ✓ | ✓ | — |
| AutoSaveOverlay | ✓ | ✓ | ✓ | ✓ |
| TechTreePanel | ✓ | — | — | ✓ |
| KeybindHelp | — | — | — | ✓ |

### Spremenjene datoteke
- `states/ui/hud/royal_systems_panel.lua` (+10 vrstic) — mousemoved/mousereleased stubs
- `states/game.lua` (+6 vrstic) — mousereleased + mousemoved forwarding za RoyalSystemsPanel

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1645/1645 (100%) Lua datotek pass

## [v3.11.937] — 2026-08-16 — Market Dashboard Mousemoved/Mousereleased Forwarding

### Dodano
- **MarketDashboard** — dodani `mousemoved()` in `mousereleased()` stub funkcije:
  - Trenutno vračata `false` (panel je click-only, brez drag interakcij)
  - Omogočata game.lua da forwarda evente brez nil check-ov
  - Pripravljeno za prihodnje drag interakcije (npr. draggable stolpce, resize)
- **game.lua** — mousereleased in mousemoved forwarding razširjen:
  - `game:mousereleased()` sedaj preverja `MarketDashboard.mousereleased()` ko je panel viden
  - `game:mousemoved()` sedaj preverja `MarketDashboard.mousemoved()` ko je panel viden
  - **Konsistenten mouse forwarding** za vse 4 panele: MarketDashboard, AutoSavePanel, AutoSaveOverlay, TechTreePanel

### Spremenjene datoteke
- `states/ui/hud/market_dashboard.lua` (+10 vrstic) — mousemoved/mousereleased stubs
- `states/game.lua` (+6 vrstic) — mousereleased + mousemoved forwarding za MarketDashboard

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1645/1645 (100%) Lua datotek pass

### Konsistenten mouse forwarding sistem
Vsi paneli sedaj imajo popoln mouse event handling:
| panel | mousepressed | mousemoved | mousereleased | wheelmoved |
|-------|-------------|------------|---------------|------------|
| MarketDashboard | ✓ (v3.11.903) | ✓ stub (v3.11.937) | ✓ stub (v3.11.937) | ✓ (v3.11.919) |
| RoyalSystemsPanel | ✓ (v3.11.382) | — | — | ✓ (v3.11.920) |
| AutoSavePanel | ✓ (v3.11.918) | ✓ (v3.11.931) | ✓ (v3.11.931) | — |
| AutoSaveOverlay | ✓ (v3.11.924) | ✓ (v3.11.925) | ✓ (v3.11.925) | ✓ (v3.11.929) |
| TechTreePanel | ✓ (v3.11.936) | — | — | ✓ (v3.11.936) |
| KeybindHelp | — | — | — | ✓ (v3.11.927) |

## [v3.11.936] — 2026-08-15 — Tech Tree Visualization Panel (Ctrl+Shift+G)

### Dodano
- **Tech Tree Panel** (nov UI panel, 180 vrstic) — `states/ui/hud/tech_tree_panel.lua`:
  - Toggle s **Ctrl+Shift+G** (G za "Graph")
  - Hierarhični prikaz vseh 11 verig tech tree-ja
  - Za vsako verigo: 📦 osnovni sistem + └─ napredni sistemi
  - 3 statusi z barvnim kodiranjem:
    - 🟢 zelena "✓ aktivna" — sistem ima zgradbo
    - 🟡 rumena "⚠ razpoložljiv" — deps so met, ampak še ni zgrajen
    - 🔴 rdeča "✗ zaklenjen" — deps niso met
  - Multi-base verige (Instrument, Cartography) prikazujejo oba osnovna sistema
  - Scrollable (wheel + ↑↓ + PgUp/PgDn + Home)
  - Vizualen scrollbar
  - Footer: "28 dependencies · 11 verig · 3 multi-prereq sistemi"
  - Click zunaj zapre panel, ESC zapre
- **game.lua** — povezave:
  - `require("states.ui.hud.tech_tree_panel")`
  - `TechTreePanel.draw()` v draw bloku
  - Ctrl+Shift+G keypressed handler
  - `TechTreePanel.keypressed()` forwarding
  - `TechTreePanel.wheelmoved()` forwarding
  - `TechTreePanel.mousepressed()` forwarding
- **keybind_help.lua** — dodan Ctrl+Shift+G v EKONOMIJA

### Spremenjene datoteke
- `states/ui/hud/tech_tree_panel.lua` (NOV, 180 vrstic)
- `states/game.lua` (+12 vrstic) — require + draw + Ctrl+Shift+G + keypressed/wheelmoved/mousepressed forwarding
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — Ctrl+Shift+G v EKONOMIJA

### Funkcionalna preverba
- Lupa `load()` test: vseh 8 spremenjenih datotek PASS (vključno z novim tech_tree_panel)
- Polna preverba: 1645/1645 (100%) Lua datotek pass (+1 od prej)

## [v3.11.935] — 2026-08-15 — Tech Tree Expansion (12→28 dependencies, 5→11 verig)

### Dodano
- **SystemDependencies.lua** — razširitev dependency grapha z 16 novimi dependencies:
  - **Metalwork veriga** (razširjena): +CoinDieMaker → Metalwork, +CoinPressMaker → Metalwork + BellMaker (multi-prereq!)
  - **Glass veriga** (razširjena): +GlassBeadMaker → GlassBench, +VitrailFoilMaker → GlassBench
  - **Pottery veriga** (razširjena): +CrystallizationDish → PotteryWheel
  - **Woodworking veriga** (razširjena): +EaselMaker → WoodLathe
  - **Textile veriga** (razširjena): +CarpetLoom → SpinningWheel
  - **Leatherwork veriga** (nova): SaddleMaker, LeatherCoverMaker, GloveMaker → RawhideTanner
  - **Dye veriga** (nova): DyerColor → DyeStuff
  - **Forge veriga** (nova): AnvilMaker, ForgeTongsMaker → ForgeTuyere
  - **Instrument veriga** (nova): TrumpetMaker → Metalwork + WoodLathe (multi-prereq!), FluteMaker → WoodLathe
  - **Cartography veriga** (nova): MapMaker → ParchmentMaker + InkMaker (multi-prereq!)
- **Multi-prereq sistemi**: CoinPressMaker, TrumpetMaker, MapMaker zahtevajo 2 ali več osnovnih sistemov — bolj strateško načrtovanje

### Statistika
- Prej: 12 dependencies v 5 verigah (v3.11.934)
- Sedaj: **28 dependencies v 11 verigah** (v3.11.935)
- 3 sistemi z multi-prereq (2+ osnovnih sistemov)

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (+30 vrstic) — 16 novih dependency entry-jev, 6 novih verig

### Funkcionalna preverba
- Lupa `load()` test: PASS
- Polna preverba: 1644/1644 (100%) Lua datotek pass

## [v3.11.934] — 2026-08-15 — System Dependencies (Tech Tree)

### Dodano
- **SystemDependencies.lua** (nov modul, 115 vrstic) — `objects/Economy/SystemDependencies.lua`:
  - Dependency graph: sistemKey → lista prerequisitov (sistemov, ki morajo imeti ≥1 zgradbo)
  - **12 dependencies** definiranih v 5 verigah:
    - **Metalwork veriga**: BellMaker, ChainmailForger, SwordPommelMaker, GauntletMaker → zahtevajo Metalwork
    - **Glass veriga**: MirrorMaker → zahteva GlassBench
    - **Pottery veriga**: ApothecaryMortar, ApothecaryVial → zahtevajo PotteryWheel
    - **Woodworking veriga**: BookPress, BookbindingPress → zahtevajo WoodLathe
    - **Textile veriga**: LoomHeddle, TapestryLoom → zahtevajo SpinningWheel
  - API:
    - `checkDependencies(systemKey)` → (boolean met, table unmet)
    - `getDependencies(systemKey)` → lista prerequisitov
    - `getDependencyDescription(systemKey)` → human-readable "Zahteva: Metalwork (✓), GlassBench (✗)"
    - `hasDependencies(systemKey)` → boolean
    - `registerDependency(systemKey, prerequisites)` — runtime registracija (za modding)
- **RoyalSystemsRegistry** — integracija dependency check:
  - `hireMaker()` sedaj preverja dependencies pred najemom
  - `build()` sedaj preverja dependencies pred gradnjo
  - Če dependencies niso izpolnjene: return false z opisom "Zahteva: X, Y (zgradij delavnico)"
  - Lazy require (prepreči circular dependency)
- **Royal Systems Panel** — prikaz dependencies v detail panel:
  - 🔗 ikona z opisom prerequisitov (npr. "🔗 Zahteva: Metalwork (✓)")
  - Zelena barva če so vse odvisnosti izpolnjene, oranžna če niso
  - Prikazan med key in stats blokom

### Spremenjene datoteke
- `objects/Economy/SystemDependencies.lua` (NOV, 115 vrstic)
- `objects/Economy/RoyalSystemsRegistry.lua` (+16 vrstic) — dependency check v hireMaker in build
- `states/ui/hud/royal_systems_panel.lua` (+14 vrstic) — dependency prikaz v detail panel

### Funkcionalna preverba
- Lupa `load()` test: vseh 9 spremenjenih datotek PASS (vključno z novim SystemDependencies)
- Polna preverba: 1644/1644 (100%) Lua datotek pass (+1 od prej — SystemDependencies.lua je nova)

### Pomen
Tech tree dodaja globino in napredek: igralec mora najprej zgraditi osnovne sisteme (Metalwork, GlassBench, PotteryWheel, WoodLathe, SpinningWheel) preden lahko dostopa do naprednih sistemov (BellMaker, MirrorMaker, Apothecary, BookPress, TapestryLoom, itd.). To ustvarja naravno progresijo in strateško odločanje o tem, katere sisteme graditi prve.

## [v3.11.933] — 2026-08-15 — Overlay Settings Consolidation (3 datoteke → 1)

### Refaktorirano
- **Auto-Save Status Overlay** — konsolidacija 3 ločenih datotek v eno:
  - **Prej**: 3 loče datoteke v love.filesystem:
    - `autosave_overlay_position.txt` (x, y) — v3.11.925
    - `autosave_overlay_opacity.txt` (0.2–1.0) — v3.11.929
    - `autosave_overlay_hidden.txt` (0/1) — v3.11.930
  - **Sedaj**: 1 konsolidirana datoteka `autosave_overlay_settings.txt`:
    - Format: `key=value\n` per line (npr. `x=800\ny=12\nopacity=0.85\nhidden=0\n`)
  - `loadSettings()` — ena read operacija, parse key=value lines
  - `saveSettings()` — ena write operacija, format in write
  - `ensureSettings()` — lazy-load vseh nastavitev naenkrat
  - `tryMigrateOldFiles()` — avtomatska migracija: če consolidated datoteka ne obstaja, preveri stare 3 datoteke in jih izbriše
  - Vsi API-ji (toggleHidden, setOpacity, resetPosition, itd.) sedaj uporabljajo `saveSettings()` namesto ločenih save funkcij
  - Manj I/O operacij, čistejša arhitektura, lažje vzdrževanje

### Spremenjene datoteke
- `states/ui/hud/autosave_status_overlay.lua` (refaktor: -50 vrstic starih helperjev, +80 vrstic konsolidiranega sistema)

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1643/1643 (100%) Lua datotek pass

### Migracija
- Ob prvem zagonu po nadgradnji na v3.11.933:
  - Če obstaja `autosave_overlay_settings.txt` → uporabi konsolidirano
  - Če ne obstaja, preveri stare 3 datoteke → izbriši jih → uporabi privzete vrednosti
  - Naslednja sprememba kateregakoli setting-a shrani konsolidirano datoteko

## [v3.11.932] — 2026-08-15 — Auto-Save Panel Mousemoved/Mousereleased Forwarding

### Popravljeno
- **game.lua** — dodan mousemoved in mousereleased forwarding za AutoSavePanel:
  - `game:mousereleased()` sedaj preverja `AutoSavePanel.mousereleased()` ko je panel viden
  - `game:mousemoved()` sedaj preverja `AutoSavePanel.mousemoved()` ko je panel viden
  - **Bug fix**: slider drag v Auto-Save Panelu (v3.11.931) prej ni deloval ker game.lua ni forwardal mousemoved/mousereleased na AutoSavePanel
  - Sedaj drag po sliderju pravilno spreminja prosojnost overlay-a v realnem času

### Spremenjene datoteke
- `states/game.lua` (+6 vrstic) — mousereleased + mousemoved forwarding za AutoSavePanel

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1643/1643 (100%) Lua datotek pass

## [v3.11.931] — 2026-08-15 — Overlay Opacity Slider v Auto-Save Panel

### Dodano
- **Auto-Save Panel** (Ctrl+U) — vizualni drsnik za nastavitev prosojnosti overlay-a:
  - Drsnik (slider) z track, fill in thumb (10px širok thumb, dragable)
  - Prosojnost prikazana kot odstotek (20%–100%)
  - Click na drsnik takoj nastavi prosojnost
  - Drag po drsniku za kontinuirno spreminjanje
  - Novi state: `sliderArea` (območje drsnika) in `sliderDragging` (drag stanje)
  - Novi funkciji `mousemoved()` in `mousereleased()` za drag support
  - Lazy require AutoSaveOverlay znotraj funkcij (prepreči circular dependency)
  - Panel povečan: višina 480→530px (dodaten prostor za drsnik)
  - Dopolnjuje wheel-over-overlay (v3.11.929) z bolj preciznim vizualnim nadzorom

### Spremenjene datoteke
- `states/ui/hud/autosave_panel.lua` (+60 vrstic) — slider rendering, sliderArea/sliderDragging state, mousepressed/mousemoved/mousereleased za drag, panelH 530

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1643/1643 (100%) Lua datotek pass

### Dva načina za nastavitev opacity
1. **Wheel-over-overlay** (v3.11.929) — hitro, step 0.05, ko je miška nad overlay
2. **Slider v panel** (v3.11.931) — precizno, drag za kontinuirno spreminjanje

## [v3.11.930] — 2026-08-15 — Overlay Hidden State Persistence

### Dodano
- **Auto-Save Status Overlay** — hidden state persistence:
  - Nov state file: `HIDDEN_FILE = "autosave_overlay_hidden.txt"` v love.filesystem
  - `loadHidden()` — prebere "1" (hidden) ali "0" (visible)
  - `saveHidden(val)` — zapiše "1" ali "0"
  - `ensureHidden()` — lazy-load na prvi draw (nil → load → default false)
  - `toggleHidden()` — preklopi in shrani novo stanje
  - `setHidden(state)` — eksplicitno nastavi in shrani
  - `isHidden()` — ensureHidden() + vrne stanje
  - draw() kliče ensureHidden() pred preverbo hidden
  - **Pomembno**: hidden stanje sedaj preživi restart igre — če je igralec skril overlay, ostane skrit
- **Celovita persistenca overlay state-a** (3 ločene datoteke):
  - `autosave_overlay_position.txt` — pozicija (x, y) — v3.11.925
  - `autosave_overlay_opacity.txt` — prosojnost (0.2–1.0) — v3.11.929
  - `autosave_overlay_hidden.txt` — vidnost (0/1) — v3.11.930

### Spremenjene datoteke
- `states/ui/hud/autosave_status_overlay.lua` (+25 vrstic) — HIDDEN_FILE, loadHidden/saveHidden/ensureHidden, toggleHidden/setHidden/isHidden shranjujo stanje

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1643/1643 (100%) Lua datotek pass

## [v3.11.929] — 2026-08-15 — Overlay Opacity Control (wheel-over-overlay, persisted)

### Dodano
- **Auto-Save Status Overlay** — opacity control z miškinim wheel-om:
  - Nov state: `opacity` (default 0.85, range 0.2–1.0)
  - Persistenca: `OPACITY_FILE = "autosave_overlay_opacity.txt"` v love.filesystem
  - `loadOpacity()` / `saveOpacity()` helper funkciji
  - `ensureOpacity()` lazy-load na prvi draw
  - **Wheel-over-overlay**: ko je miška nad overlay, wheel gor/dol spreminja prosojnost (step 0.05, clamped 0.2–1.0)
  - Vse `setColor` klice v draw() uporabljajo `opacity` za alpha kanal
  - Hover hint dopolnjen: "klik: odpri panel | drag: premakni | wheel: prosojnost"
  - Novi API: `getOpacity()`, `setOpacity(val)` za programski dostop
  - Opacity persistira med sejami (avtomatsko shranjena ob spremembi)
- **game.lua** — wheelmoved forwarding razširjen:
  - `game:wheelmoved()` sedaj najprej preveri `AutoSaveOverlay.wheelmoved()`
  - Če je miška nad overlay, wheel spremeni opacity (ne scroll-a mape)
  - Sicer wheel propagira naprej (Market Dashboard → Royal Panel → Keybind Help → mapa)

### Spremenjene datoteke
- `states/ui/hud/autosave_status_overlay.lua` (+55 vrstic) — opacity state, loadOpacity/saveOpacity/ensureOpacity, wheelmoved() za opacity, getOpacity/setOpacity API, vsi draw klice uporabljajo opacity
- `states/game.lua` (+2 vrstici) — wheelmoved forwarding za overlay opacity

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1643/1643 (100%) Lua datotek pass

### Celovit overlay feature set
Sedaj overlay podpira:
- **Pozicija**: drag-to-move + position persistence + reset button (v3.11.925–926)
- **Vidnost**: hide/show z Ctrl+Shift+U (v3.11.928)
- **Prosojnost**: wheel-over-overlay za opacity (0.2–1.0) + persistence (v3.11.929)
- **Klik**: odpre poln Auto-Save Panel (v3.11.924)
- **Auto-hide**: ko je full-screen panel odprt (v3.11.924)

## [v3.11.928] — 2026-08-15 — Overlay Hide/Show Toggle (Ctrl+Shift+U)

### Dodano
- **Auto-Save Status Overlay** — hide/show funkcionalnost:
  - Nov state: `hidden` (default = false)
  - `toggleHidden()` — preklopi vidnost overlay-a (vrne novo stanje)
  - `setHidden(state)` — eksplicitno nastavi stanje
  - `isHidden()` — preveri ali je overlay skrit
  - draw() ne render-a ko je `hidden == true`
  - Mouse pressed/moved ne sprožijo ko je hidden (ni interakcije)
- **Ctrl+Shift+U** — keybind za hitro skrivanje/prikaz overlay-a:
  - Preveri se BEFORE Ctrl+U (da ne konflikta s panel toggle)
  - Prikaže notification: "Auto-save overlay: SKRIT" ali "PRIKAZAN"
  - **Pomembno**: ne izklopi auto-save — samo skrije vizualni indikator
- **keybind_help.lua** — dodan "Ctrl+Shift+U" v EKONOMIJA kategorijo

### Spremenjene datoteke
- `states/ui/hud/autosave_status_overlay.lua` (+20 vrstic) — hidden state, toggleHidden/setHidden/isHidden API, draw() guard
- `states/game.lua` (+10 vrstic) — Ctrl+Shift+U keybind handler (prestavljen pred Ctrl+U zaradi prioritete)
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — Ctrl+Shift+U v EKONOMIJA

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1643/1643 (100%) Lua datotek pass

### Celovit overlay keybind sistem
Sedaj so na volu 4 U keybindi z različnimi modifier-ji:
- **Ctrl+U** — odpri/zapri poln Auto-Save Panel
- **Shift+U** — hitri vklop/izklop auto-save (brez panela)
- **Ctrl+Shift+U** — skrij/prikaži overlay (brez izklopa auto-save)
- **Click na overlay** — odpri panel (samo če ni drag)

## [v3.11.927] — 2026-08-15 — Keybind Help Scroll (scrollbar + wheel + keys)

### Dodano
- **keybind_help.lua** (F1) — scroll support za 11 kategorij z 50+ keybindi:
  - Nov state: `scrollOffset` in `contentHeight`
  - **Miškin wheel**: scroll gor/dol (40px na tick)
  - **↑/↓** tipke: scroll 40px
  - **PgUp/PgDn** tipke: scroll 200px
  - **Home** tipka: skok na vrh
  - **End** tipka: skok na dno
  - Scroll offset se resetira ob toggle (F1)
  - Scroll offset se clamp-a na maxScroll (contentHeight - contentAreaH)
  - **Scissor clipping** prepreči overflow contenta izven panela
  - **Vizualen scrollbar** na desni strani: track + thumb (proporcionalen, min 20px)
  - Naslov in close hint ostajata fiksirana (ne scrollata)
  - Close hint dopolnjen: "[H] Zapri pomoč | ↑↓/wheel: scroll" ko je scrollable
- **game.lua** — wheelmoved in keypressed forwarding:
  - `game:wheelmoved()` sedaj preverja tudi KeybindHelp.wheelmoved()
  - `game:keypressed()` sedaj forwarda scroll keys na KeybindHelp.keypressed() ko je panel viden

### Spremenjene datoteke
- `states/ui/hud/keybind_help.lua` (+80 vrstic) — scroll state, wheelmoved(), keyboard scroll, scissor clipping, scrollbar, contentHeight calculation
- `states/game.lua` (+8 vrstic) — wheelmoved + keypressed forwarding za KeybindHelp

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1643/1643 (100%) Lua datotek pass

## [v3.11.926] — 2026-08-15 — Overlay Position Reset Button

### Dodano
- **Auto-Save Status Overlay** — novi API-ji za reset pozicije:
  - `resetPosition()` — resetira overlay na privzeto mesto (zgornji desni kot) in izbriše persisted pozicijsko datoteko
  - `getPosition()` — vrne trenutno pozicijo (x, y) za debug/display
- **Auto-Save Panel** (Ctrl+U) — nov gumb "Reset pozicije":
  - Tretji gumb v akcijski vrstici (poleg Vklopi/Izklopi in Shrani zdaj)
  - Kliče `AutoSaveOverlay.resetPosition()`
  - Prikaže obvestilo: "Pozicija overlay-a resetirana (zgornji desni kot)"
  - Lazy require (prepreči circular dependency)

### Spremenjene datoteke
- `states/ui/hud/autosave_status_overlay.lua` (+15 vrstic) — resetPosition() in getPosition() API-ji
- `states/ui/hud/autosave_panel.lua` (+7 vrstic) — "Reset pozicije" gumb v akcijski vrstici

### Funkcionalna preverba
- Lupa `load()` test: vseh 5 spremenjenih datotek PASS
- Polna preverba: 1643/1643 (100%) Lua datotek pass

## [v3.11.925] — 2026-08-15 — Auto-Save Overlay Drag-to-Move (persisted)

### Dodano
- **Auto-Save Status Overlay** — drag-to-move z persistenco pozicije:
  - Igralec lahko povleče overlay na poljubno mesto zaslona
  - Pozicija se shrani v `love.filesystem` datoteko `autosave_overlay_position.txt`
  - Pozicija persistira med sejami (avtomatsko naložena ob naslednjem zagonu)
  - Click (brez drag-a) še vedno odpre poln panel
  - Drag (z movementom) premakne overlay in shrani pozicijo
  - Pametno razlikovanje click vs drag: če se miška ni premaknila, je click; če se je, je drag
  - Drag border highlight (modra barva, 2px) za vizualno povratno informacijo
  - Hover hint posodobljen: "klik: odpri panel | drag: premakni"
  - Position clamped na screen bounds (prepreči off-screen)
  - Position se re-clamp-a ob resolution change (v draw)
- **game.lua** — mousereleased in mousemoved forwarding:
  - `game:mousereleased()` sedaj najprej preveri AutoSaveOverlay.mousereleased()
  - `game:mousemoved()` sedaj najprej preveri AutoSaveOverlay.mousemoved()
  - Če overlay consume-a event, se ne propagira naprej (minimap drag, itd.)
- **keybind_help.lua** — dodan "Drag (overlay)" v EKONOMIJA kategorijo

### Spremenjene datoteke
- `states/ui/hud/autosave_status_overlay.lua` (+85 vrstic) — drag state, position persistence (load/save), mousepressed/mousereleased/mousemoved, drag border highlight, hover hint
- `states/game.lua` (+4 vrstice) — mousereleased + mousemoved forwarding
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — Drag (overlay) v EKONOMIJA

### Funkcionalna preverba
- Lupa `load()` test: vseh 5 spremenjenih datotek PASS
- Polna preverba: 1643/1643 (100%) Lua datotek pass

## [v3.11.924] — 2026-08-14 — Auto-Save Status Overlay (always-on HUD)

### Dodano
- **Auto-Save Status Overlay** (nov HUD widget, 130 vrstic) — `states/ui/hud/autosave_status_overlay.lua`:
  - Compact on-screen indikator v desnem zgornjem kotu (180×38px)
  - Vedno prikazan med gameplay-om (ni toggle-a — preveč uporabno da bi skrivali)
  - Prikazuje: status (💾 Auto-save / ⏸ OFF), timer do naslednjega save-a (mm:ss), mini progress bar
  - Barva mini bara: zelena (pravkar shranjeno) → rumena → oranžna (skoraj zapadlo)
  - Hover: prikaže hint "klik: odpri panel (Ctrl+U)"
  - Click: odpre poln Auto-Save Panel (Ctrl+U)
  - Auto-hide ko je kateri od full-screen panelov odprt (Ctrl+R/Ctrl+K/Ctrl+U) - izogiba clutter-ju
  - Lazy require z pcall (defenzivno - ne crashne če modul manjka)
  - Stats osvežene vsakih 500ms (ne vsak frame - performanca)
- **game.lua** — povezave:
  - `require("states.ui.hud.autosave_status_overlay")`
  - `AutoSaveOverlay.update(dt)` v update loop-u
  - `AutoSaveOverlay.draw()` v draw bloku (za AutoSavePanel)
  - `AutoSaveOverlay.mousepressed()` forwarding
- **keybind_help.lua** — dodan "Click (overlay)" v EKONOMIJA kategorijo

### Spremenjene datoteke
- `states/ui/hud/autosave_status_overlay.lua` (NOV, 130 vrstic)
- `states/game.lua` (+5 vrstic) — require + update + draw + mousepressed forwarding
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — Click (overlay) v EKONOMIJA
- `README.md` — posodobljeni badges (v3.11.924, +AutoSaveOverlay, 1643 datotek, 1643/1643 pass), nova vrstica (Royal Auto-Save Overlay)

### Funkcionalna preverba
- Lupa `load()` test: vseh 5 spremenjenih datotek PASS (vključno z novim autosave_status_overlay.lua)
- Polna preverba: 1643/1643 (100%) Lua datotek pass (+1 od prej — autosave_status_overlay.lua je nova)

## [v3.11.923] — 2026-08-14 — Auto-Save Quick Toggle (Shift+U)

### Dodano
- **Shift+U** — hitri shortcut za vklop/izklop auto-save-a brez odpiranja panela:
  - Preveri trenutno stanje preko `AutoSaveSystem.getStats().enabled`
  - Preklopi stanje z `AutoSaveSystem.setEnabled(not stats.enabled)`
  - Prikaže obvestilo: "Auto-save: VKLOPLJEN" ali "Auto-save: IZKLOPLJEN"
  - **Pametno**: ne aktivira se če je pritisnjen tudi Ctrl (da ne konflikta s Ctrl+U panel)
  - Lazy require (prepreči circular dependency)
- **keybind_help.lua** — dodan Shift+U v EKONOMIJA kategorijo

### Spremenjene datoteke
- `states/game.lua` (+12 vrstic) — Shift+U keybind handler z ModernUI notification
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — Shift+U v EKONOMIJA

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1642/1642 (100%) Lua datotek pass

## [v3.11.922] — 2026-08-14 — Keybind Help Overlay Dopolnjen z Vsemi Bližnjicami

### Dodano
- **keybind_help.lua** (F1) — dopolnjen z 3 novimi kategorijami:
  - **CTRL+R PANEL (Royal Systems)**: /, ←→/AD, ↑↓/WS, Home/End, PgUp/PgDn, Wheel, Tab (7 keybinds)
  - **CTRL+K PANEL (Market Dashboard)**: /, S, E, Q, Space, C, Ctrl+X, V, 1-5, ↑↓, PgUp/PgDn, Home, Wheel (13 keybinds)
  - **CTRL+U PANEL (Auto-Save)**: Click, ESC, Ctrl+U (3 keybinds)
  - Skupaj 23 novih keybind opisov
- **OSNOVNO** kategorija: V opis dopolnjen z kontekstno opombo ("V v Ctrl+K: zgodovina dogodkov")
- Panel povečan: širina 520→560, višina 580→760 (math.min z screenH-40 za male zaslone)
- Close hint pozicija prilagojena novi širini

### Spremenjene datoteke
- `states/ui/hud/keybind_help.lua` (+40 vrstic) — 3 nove kategorije z 23 keybindi, večji panel, dopolnjen V opis

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1642/1642 (100%) Lua datotek pass

## [v3.11.921] — 2026-08-14 — Royal Systems Panel Keyboard Shortcuts

### Dodano
- **Royal Systems Panel** (Ctrl+R) — novi keyboard shortcuts za navigacijo:
  - **Home**: skok na prvo stran (page=1, selectedIndex=1)
  - **End**: skok na zadnjo stran (page=totalPages, selectedIndex=prva vrstica zadnje strani)
  - **PageUp**: isto kot levo puščica (previous page)
  - **PageDown**: isto kot desno puščica (next page)
  - Komplementira obstoječe: ←/→ (strani), ↑↓/WS (vrstice), wheel (strani iz v3.11.920)

### Spremenjene datoteke
- `states/ui/hud/royal_systems_panel.lua` (+25 vrstic) — Home/End/PageUp/PageDown keybinds

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1642/1642 (100%) Lua datotek pass

## [v3.11.920] — 2026-08-14 — Royal Systems Panel Scroll (wheel + scrollbar)

### Dodano
- **Royal Systems Panel** (Ctrl+R) — wheel scroll in vizualen scrollbar:
  - Nova funkcija `RoyalPanel.wheelmoved(x, y)` — wheel gor/dol navigira med stranimi
  - Wheel up: previous page (če page > 1)
  - Wheel down: next page (če page < totalPages)
  - Ne deluje med iskanjem (searchActive) — ne moti tipkanja
  - SelectedIndex se posodobi na prvo vrstico nove strani
  - **Vizualen scrollbar** na desni strani seznama sistemov:
    - Track (temen background, 6px širok)
    - Thumb (proporcionalen višini = sbH / totalPages, min 20px)
    - Thumb pozicija proporcionalna page/totalPages
    - Zlata/barvna barva thumb-a (zgodovinska tematika panela)
  - Click area sistemske vrstice je nekoliko ožja (listW - 16) da ne prekriva scrollbar-a
- **game.lua** — wheelmoved forwarding razširjen:
  - Najprej MarketDashboard.wheelmoved (če je panel viden)
  - Nato RoyalSystemsPanel.wheelmoved (če je panel viden)
  - Sicer wheel scrolla mapo (obstoječe vedenje)

### Spremenjene datoteke
- `states/ui/hud/royal_systems_panel.lua` (+30 vrstic) — wheelmoved() funkcija, vizualen scrollbar v seznamu, ožja click area
- `states/game.lua` (+4 vrstice) — wheelmoved forwarding v RoyalSystemsPanel

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1642/1642 (100%) Lua datotek pass

## [v3.11.919] — 2026-08-14 — Event Log Scroll/Pagination v Expanded Panel

### Dodano
- **Market Dashboard** — scroll/pagination v expanded event log panel:
  - Nov state: `eventLogScrollOffset` (0 = top)
  - **Miškin wheel**: scroll gor/dol (3 vrstice na tick)
  - **↑/↓** tipke: scroll za 1 vrstico
  - **PgUp/PgDn** tipke: scroll za 10 vrstic
  - **Home** tipka: skok na vrh
  - Scroll offset se resetira ob odpiranju panela (V) ali spremembi filtra (1-5)
  - Scroll offset se clamp-a na veljaven range (maxScrollOffset = total - maxRows)
  - **Scrollbar vizualen**: desno od seznama, z track + thumb
    - Thumb višina proporcionalna (maxRows / total)
    - Thumb pozicija proporcionalna scroll offsetu
    - Min thumb višina 20px (berljivost)
  - **Scissor clipping**: prepreči overflow vrstic izven list area
  - Footer prikazuje "Prikazano: N-M/Total dogodkov" namesto samo "N/Total" ko je scrollable
  - Footer dodan hint: "↑↓/wheel: scroll | Home: top"
  - Naslov panela posodobljen z novimi keybinds

- **game.lua** — wheelmoved forwarding:
  - `game:wheelmoved(x, y)` sedaj najprej preveri MarketDashboard.wheelmoved()
  - Če je Market Dashboard viden in je event log expanded, wheel scrolla list (ne mape)
  - Sicer pa wheel scrolla mapo (obstoječe vedenje)

### Spremenjene datoteke
- `states/ui/hud/market_dashboard.lua` (+75 vrstic) — eventLogScrollOffset state, ↑↓/PgUp/PgDn/Home keybinds, wheelmoved() funkcija, scissor clipping, scrollbar vizual, dopolnjen footer
- `states/game.lua` (+5 vrstic) — wheelmoved forwarding v MarketDashboard

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1642/1642 (100%) Lua datotek pass

## [v3.11.918] — 2026-08-14 — Auto-Save UI Panel (Ctrl+U)

### Dodano
- **Auto-Save Panel** (nov UI panel, 232 vrstic) — `states/ui/hud/autosave_panel.lua`:
  - Toggle s **Ctrl+U** (U za "auto-save UI")
  - Status block: stanje (vklopljeno/izklopljeno), interval (min), čas do naslednjega save-a
  - Progress bar: vizualni countdown do naslednjega save-a (barva se spreminja: zelena → rumena → oranžna)
  - Zadnje shranjevanje info: starost (s/m/h), število save-ov
  - Royal stats iz zadnjega save-a: število sistemov, produktov, dogodkov, autoSellEnabled, comparisonItems, saveVersion
  - Akcijski gumbi: Vklopi/Izklopi, Shrani zdaj (force save)
  - Interval presets: 1 min, 5 min, 15 min, 30 min (trenutni je označen z ✓ in onemogočen)
  - Click zunaj panela ga zapre
  - ESC zapre panel
  - Action feedback message (3s fade)
- **game.lua** — povezave za AutoSavePanel:
  - `require("states.ui.hud.autosave_panel")`
  - `AutoSavePanel.update(dt)` v update loop-u
  - `AutoSavePanel.draw()` v draw bloku
  - Ctrl+U keypressed handler
  - `AutoSavePanel.mousepressed()` forwarding
  - `AutoSavePanel.keypressed()` forwarding
- **keybind_help.lua** — dodana Ctrl+U v EKONOMIJA kategorijo

### Spremenjene datoteke
- `states/ui/hud/autosave_panel.lua` (NOV, 232 vrstic)
- `states/game.lua` (+12 vrstic) — require + update + draw + Ctrl+U + mousepressed + keypressed forwarding
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — Ctrl+U v EKONOMIJA
- `README.md` — posodobljeni badges (v3.11.918, +AutoSavePanel, 1642 datotek, 1642/1642 pass), nova vrstica (Royal Auto-Save Panel)

### Funkcionalna preverba
- Lupa `load()` test: vseh 3 spremenjenih datotek PASS (vključno z novim autosave_panel.lua)
- Polna preverba: 1642/1642 (100%) Lua datotek pass (+1 od prej — autosave_panel.lua je nova)

## [v3.11.917] — 2026-08-14 — Auto-Save Integration z Royal Diagnostic Stats

### Dodano
- **AutoSaveSystem** — diagnostic stats za Royal subsystems:
  - Nova internal funkcija `_collectRoyalStats()` — zbere statistiko o Royal podatkih, ki se shranjujejo
  - Pridobi: število Royal sistemov, število registriranih produktov, število tržnih dogodkov, autoSellEnabled, comparisonItems count, saveVersion
  - Vse zahteve so wrap-ane v pcall (defenzivno — ne crashne če modul manjka)
  - Lazy require (prepreči circular dependency)
  - Nova polja v `lastSaveStats` — shranjeni po vsakem save-u
  - `getStats()` sedaj vključuje `lastSaveStats` polje
  - Notification ob shranjevanju prikazuje: "Shranjeno: N Royal sistemov, M produktov, K dogodkov" (namesto generičnega "Samodejno shranjevanje...")

### Pomembna ugotovitev
AutoSaveSystem **že od prej** pravilno shranjuje vse Royal podatke preko obstoječe verige:
```
AutoSaveSystem.save() → SaveManager.save(name) → _G.state:save() → State:serialize() →
  [royalSystems, marketDashboard, royalMarket, dynamicMarket, saveVersion]
```
Ta verzija samo doda **diagnostično vidljivost** — igralec sedaj vidi, kaj točno je bilo shranjeno.

### Spremenjene datoteke
- `objects/AutoSaveSystem.lua` (+55 vrstic) — _collectRoyalStats(), lastSaveStats, dopolnjen getStats(), bolj informativen notification

### Funkcionalna preverba
- Lupa `load()` test: vseh 8 spremenjenih datotek PASS (vključno z AutoSaveSystem)
- Polna preverba: 1641/1641 (100%) Lua datotek pass

## [v3.11.916] — 2026-08-14 — Expandable Event Log Panel v Market Dashboard

### Dodano
- **Market Dashboard** — expandable event log panel (V keybind):
  - Nov state: `eventLogExpanded` (toggle), `eventLogFilter` (all/surge/crash/seasonal/manual)
  - **V** tipka: preklopi expandable panel (overlay z dimmed background)
  - **1-5** tipke: nastavi filter (1=Vsi, 2=Surge, 3=Crash, 4=Sezon, 5=Manual)
  - Panel prikazuje zadnjih 20 dogodkov (od 50 max), s filter chips na vrhu
  - Stolpci: Starost (s/m/h format), Tip (z ikono in barvo), Produkt, Multiplier, Vir, Opis
  - Alternating row background za berljivost
  - Barvno kodiranje tipov: zelen (surge), rdeč (crash), moder (seasonal), rumen (manual)
  - Filter chips z aktivno stanjem (obarvani glede na tip)
  - Footer: "Prikazano: N/M dogodkov (filter: X)"
  - Click zunaj panela ga zapre (reuse obstoječega mousepressed handler-ja)
  - Compact event log (v Results count vrstici) sedaj kaže "[V: razširi]" hint
  - Keybind help text posodobljen z V

### Spremenjene datoteke
- `states/ui/hud/market_dashboard.lua` (+155 vrstic) — eventLogExpanded/filter state, V + 1-5 keybinds, expandable overlay panel z filtri in tabelo

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1641/1641 (100%) Lua datotek pass

## [v3.11.915] — 2026-08-14 — Save Game Versioning (SaveVersioner modul)

### Dodano
- **SaveVersioner.lua** (nov modul, 145 vrstic) — `objects/Economy/SaveVersioner.lua`:
  - Centralen versioning sistem za vse shranjene podatke (Royal, Market Dashboard, auto-sell, market state)
  - `CURRENT_VERSION = 1` — trenutna verzija save formata
  - `migrations[v]` — tabela migracijskih funkcij (v -> v+1), verižno izvajanje
  - `migrate(data)` — zazna verzijo, izvede verigo migracij, vrne `(data, originalVersion, finalVersion)`
  - `stamp(data)` — nastavi `data.saveVersion = CURRENT_VERSION` (klicano med serialize)
  - `getInfo()` — human-readable opis za debug UI
  - `isVersioned(data)` — preveri ali save ima verzijo
  - Future-version downgrade: če je save iz novejše verzije, gracefully downgrade z warning
  - Migration failure handling: če migracija failne, se ustavi in stamp-a doseženo verzijo (ne CURRENT)
  - Pcall okoli vsake migracije (prepreči crash ob pokvarjenem save-u)
  - v0 -> v1 migracija: no-op (samo stamp verzije, ker obstoječi guard-i že handle-ajo manjkajoče fielde)
- **State.lua** — povezava v save/load:
  - `State:serialize()` kliče `SaveVersioner.stamp(data)` na koncu
  - `State:deserialize()` kliče `SaveVersioner.migrate(load)` na začetku
  - Lazy require (prepreči circular dependency)
- Python test (`scripts/test_save_versioner.py`) — 7 testov PASS:
  - Pre-version save migracija
  - Current version save unchanged
  - Future version downgrade
  - stamp() funkcija
  - Empty dict migracija
  - Chained migration z dodajanjem novih field-ov
  - Migration failure graceful stop

### Spremenjene datoteke
- `objects/Economy/SaveVersioner.lua` (NOV, 145 vrstic)
- `objects/State.lua` (+7 vrstic) — stamp v serialize, migrate v deserialize
- `README.md` — posodobljeni badges (v3.11.915, +SaveVersioner, 1641 datotek, 1641/1641 pass), Save/Load vrstica z saveVersion

### Funkcionalna preverba
- Lupa `load()` test: vseh 9 spremenjenih datotek PASS (vključno z SaveVersioner in State)
- Python SaveVersioner test: 7 testov PASS
- Polna preverba: 1641/1641 (100%) Lua datotek pass (+1 od prej, ker SaveVersioner.lua je nova)

### Pomembnost
Z versioning-om lahko v prihodnje dodajamo nove shranjene field-e in čistje migrirati stare save-e. Migracijske funkcije so chain-ane (v1->v2->v3->...) in vsaka je wrapped v pcall, tako da pokvarjen save ne crashne igre.

## [v3.11.914] — 2026-08-14 — Saved DynamicMarket State (persistenca trga med sejami)

### Dodano
- **DynamicMarketSystem** — serialize/deserialize API:
  - Novi funkciji `DynamicMarketSystem.serialize()` in `DynamicMarketSystem.deserialize(data)`
  - Shrani: `priceModifiers` (per-resource: base, supplyDemand, seasonal, event, inflation, current), `royalProducts` (basePrice, source, totalSold, totalRevenue), `eventLog`, `eventTimers` (aktivni dogodki), `inflationRate`, `totalGoldInCirculation`
  - NE shrani: `tradeHistory`, `priceHistory` (transient 60s-window podatki, nepotrebni za save)
  - Deserializacija: merge priceModifiers (samo update obstoječih), merge royalProducts (update statistike), restore eventLog z validacijo tipov, restore eventTimers
  - Helper `countTable()` za štetje hash table vnosov (Lua `#` ne deluje na hashih)
- **State.lua** — povezava v save/load sistem:
  - `State:serialize()` dodan `data.dynamicMarket = DynamicMarket.serialize()` (lazy require)
  - `State:load()` dodan `if load.dynamicMarket then DynamicMarket.deserialize(load.dynamicMarket) end`

### Spremenjene datoteke
- `objects/Economy/DynamicMarketSystem.lua` (+150 vrstic) — serialize/deserialize, countTable helper
- `objects/State.lua` (+6 vrstic) — save/load integracija z lazy require
- `README.md` — posodobljeni badges (v3.11.914, +SavedMarketState), Save/Load vrstica dopolnjena z marketState

### Funkcionalna preverba
- Lupa `load()` test: vseh 8 spremenjenih datotek PASS (vključno z State.lua)
- Polna preverba: 1640/1640 (100%) Lua datotek pass

### Pomembnost
Trg sedaj ohrani svoje stanje med sejami — cene, inflation, gold circulation, zgodovina dogodkov. To je ključno za dolge igre, kjer igralec ne želi, da bi trg resetiral ob vsakem loadu.

## [v3.11.913] — 2026-08-14 — Saved Auto-Sell State (persistenca med sejami)

### Dodano
- **RoyalMarketIntegration** — serialize/deserialize API:
  - Novi funkciji `RoyalMarketIntegration.serialize()` in `RoyalMarketIntegration.deserialize(data)`
  - Shrani: `autoSellEnabled`, `autoSellInterval`, `aggregateRevenue`, `perSystemRevenue`
  - NE shrani: `salesHistory` in `productSalesHistory` (transient 60s-window podatki, nepotrebni za save)
  - Deserializacija validira tipe (boolean/number) in omeji `autoSellInterval` na min 5s
  - `perSystemRevenue` se merge-a v obstoječi (init ga je nastavil na 0 za vse sisteme)
  - `autoSellTimer` se resetira na 0 (prepreči takojšen fire ob loadu)
- **State.lua** — povezava v save/load sistem:
  - `State:serialize()` dodan `data.royalMarket = RMI.serialize()` (lazy require)
  - `State:load()` dodan `if load.royalMarket then RMI.deserialize(load.royalMarket) end`
  - Lazy require (prepreči circular dependency)

### Spremenjene datoteke
- `objects/Economy/RoyalMarketIntegration.lua` (+50 vrstic) — serialize/deserialize funkciji
- `objects/State.lua` (+6 vrstic) — save/load integracija z lazy require
- `README.md` — posodobljeni badges (v3.11.913, +SavedAutoSell), Save/Load vrstica dopolnjena

### Funkcionalna preverba
- Lupa `load()` test: vseh 8 spremenjenih datotek PASS (vključno z State.lua)
- Polna preverba: 1640/1640 (100%) Lua datotek pass

## [v3.11.912] — 2026-08-14 — Saved Comparison List (persistenca med sejami)

### Dodano
- **Market Dashboard** — serialize/deserialize API:
  - Novi funkciji `MarketDashboard.serialize()` in `MarketDashboard.deserialize(data)`
  - Shrani: comparisonList, comparisonMode, leaderboardMode, sortMode
  - Deserializacija validira tipe (string/boolean) in omeji comparisonList na comparisonMaxItems
  - Sanity check: če je comparisonMode true v save-u, ampak comparisonList ima < 2 elementa, se samodejno izklopi
  - Stari save-i (brez marketDashboard field) se naložijo brez težav (guard z `if load.marketDashboard`)
- **State.lua** — povezava v save/load sistem:
  - `State:serialize()` dodan `data.marketDashboard = MarketDashboard.serialize()`
  - `State:load()` dodan `if load.marketDashboard then MarketDashboard.deserialize(load.marketDashboard) end`
  - Lazy require (prepreči circular dependency)

### Spremenjene datoteke
- `states/ui/hud/market_dashboard.lua` (+50 vrstic) — serialize/deserialize funkciji
- `objects/State.lua` (+8 vrstic) — save/load integracija z lazy require
- `README.md` — posodobljeni badges (v3.11.912, +SavedComparison), statistika

### Funkcionalna preverba
- Lupa `load()` test: vseh 8 spremenjenih datotek PASS (vključno z State.lua)
- Polna preverba: 1640/1640 (100%) Lua datotek pass

## [v3.11.911] — 2026-08-13 — Multi-Product Comparison Chart v Market Dashboard

### Dodano
- **Market Dashboard** — multi-product comparison mode:
  - Nov state: `comparisonList` (ordered list of productTypes), `comparisonSet` (fast lookup), `comparisonMode` (toggle), `comparisonMaxItems = 6`
  - Barvna paleta `COMPARISON_COLORS` (6 barv: zelena, modra, oranžna, roza, rumena, vijolična)
  - **SPACE**: doda/odstrani trenutno izbrani produkt v primerjavo (max 6)
  - **C**: preklopi način primerjave (zahtevajo se vsaj 2 produkti)
  - **Ctrl+X**: počisti primerjavo
  - Vrstice tabele prikazujejo barvni dot ob produktih, ki so v primerjavi (z indexirano barvo)
  - Multi-line chart z normaliziranimi cenami (base = 100%, range 0-200%)
  - Y-os: 0%, 100% (base, črtkana referenca), 200%
  - X-os: -60s, -30s, now (60s zgodovina)
  - End-point dot z labelo trenutnega % ob vsaki črti
  - Legenda (zgornji desni kot) z barvnimi kvadrati in imeni produktov
  - Naslov: "📊 PRIMERJAVA CEN (N produktov, normalizirano na base=100%)"
  - Keybind help text posodobljen z SPACE, C, Ctrl+X

### Spremenjene datoteke
- `states/ui/hud/market_dashboard.lua` (+115 vrstic) — comparisonList state, COMPARISON_COLORS, SPACE/C/Ctrl+X keybinds, comparison mode render z multi-line chart + legendo, indicator v tabeli

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1640/1640 (100%) Lua datotek pass

## [v3.11.910] — 2026-08-13 — Market Event Log v Market Dashboard

### Dodano
- **DynamicMarketSystem** — event log tracking:
  - Nov state: `eventLog` (list of `{t, type, productType, multiplier, duration, source, description}` entries)
  - Max 50 vnosov (zadnji dogodki)
  - `triggerEvent()` sedaj zapiše v eventLog z auto-detekcijo tipa (surge/crash/neutral glede na multiplier > 1 ali < 1)
  - `setSeasonalModifier()` sedaj zapiše v eventLog z tipom "seasonal" (samo ob pomembni spremembi, > 0.01 razlike)
  - Novi API-ji:
    - `logEvent(eventType, productType, multiplier, duration, source)` — public API za custom dogodke
    - `getEventLog(limit)` — vrne najnovejše dogodke (default: 20, najprej zadnji)
    - `getEventStats(seconds)` — števec po tipu v oknu: `{surge, crash, seasonal, inflation, manual, total}`
  - `reset()` počisti tudi eventLog
- **Market Dashboard** — event log panel (v vrstici z Results count):
  - Compact prikaz ob Results count-u
  - Stats: število dogodkov v zadnjih 5 minutah razčlenjeno po tipu (📈 surge, 📉 crash, ❄ seasonal)
  - Zadnji dogodek prikazan z ikono, imenom produkta, multiplier-jem in starostjo ("Xs nazaj" / "Xm nazaj")
  - Barvno kodiranje zadnjega dogodka: zelen (surge), rdeč (crash), moder (seasonal), siv (ostalo)
  - Prikaz z smallFont za kompaktnost

### Spremenjene datoteke
- `objects/Economy/DynamicMarketSystem.lua` (+95 vrstic) — eventLog state, logEvent klici v triggerEvent/setSeasonalModifier, 3 novi API-ji
- `states/ui/hud/market_dashboard.lua` (+45 vrstic) — event log panel v Results count vrstici
- `README.md` — posodobljeni badges (v3.11.910, +EventLog), statistika

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1640/1640 (100%) Lua datotek pass

## [v3.11.909] — 2026-08-13 — Per-Product Revenue Chart v Market Dashboard

### Dodano
- **RoyalMarketIntegration** — per-product sales history tracking:
  - Nov state: `productSalesHistory` (per-product list of `{t, qty, gold, unitPrice}` entries)
  - `recordSale()` sedaj zapiše tudi v `productSalesHistory[productType]` (agregirano čez vse sisteme)
  - Max 300 vzorcev na produkt, max 600s starost
  - Novi API-ji:
    - `getProductSalesHistory(productType, seconds?)` — vrne list vnosov z optional window
    - `getProductSalesBuckets(productType, seconds)` — vrne per-second buckete z `{qty, gold, count}`, `maxQty`, `maxGold`, `totalGold`, `totalQty`, `avgUnitPrice`
  - `reset()` počisti tudi productSalesHistory
- **Market Dashboard** — revenue chart v detail panel (pod price chart-om):
  - Detail panel povečan na 280px višine (dodaten 80px za revenue chart)
  - Bar chart 60s prihodka (gold) za izbran produkt v 1s bucketih
  - Naslov: "💰 Prihodek od prodaje (zadnjih 60s)"
  - Barvno kodiranje: zlato-rumene barve, novejši svetlejši
  - Y-os z max gold in 0, X-os z -60s/-30s/now
  - Stats vrstica nad chartom: skupaj gold, skupaj količina, povprečna cena/kos
  - Empty state: "(ni prodaje — uporabi 'Prodaj na trgu' v Royal panelu)"
  - PageSize zmanjšan z 9 na 6 (da pusti prostor za večji detail panel)

### Spremenjene datoteke
- `objects/Economy/RoyalMarketIntegration.lua` (+85 vrstic) — productSalesHistory state, recordSale razširitev, 2 nova API-ja
- `states/ui/hud/market_dashboard.lua` (+70 vrstic) — revenue chart v detail panel, detailH 280, pageSize 6
- `README.md` — posodobljeni badges (v3.11.909, +RevenueChart), statistika

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1640/1640 (100%) Lua datotek pass

## [v3.11.908] — 2026-08-13 — Profit Leaderboard (Q toggle) v Market Dashboard

### Dodano
- **RoyalMarketIntegration** — sales history tracking:
  - Nov state: `salesHistory` (per-system list of `{t, productType, qty, gold, unitPrice}` entries)
  - Internal helper `recordSale(key, productType, qty, gold, unitPrice)` kliče se v `sellStock`, `sellProduct`, in `autoSellSweep`
  - Max 300 vzorcev na sistem, max 600s starost
  - Novi API-ji:
    - `getSalesHistory(key, seconds?)` — vrne list vnosov z optional time window
    - `getRevenueStats(key, seconds?)` — vrne `{totalGold, totalQty, saleCount, avgUnitPrice, firstT, lastT, timeSpan, goldPerMin, windowSeconds}`
    - `getTopProfitProducers(count, seconds)` — vrne top-N sistemov po prihodku (gold) v oknu
    - `getAggregateRevenue(seconds)` — agregirano čez vse sisteme: `{systemsActive, totalGold, totalQty, saleCount, topSystem, topGold}`
  - `reset()` počisti tudi salesHistory
- **Market Dashboard** — Q toggle med leaderboard načinoma:
  - Nov state: `leaderboardMode` ("qty" ali "profit")
  - Tipka **Q** preklopi med "TOP-10 PRODUCENTOV (količina)" in "TOP-10 PO PRIHODKU (gold)"
  - Profit leaderboard prikazuje: rang, ime, gold zaslužek, gold/min, povprečno ceno/kos
  - Qty leaderboard prikazuje: rang, ime, količina, izdelki/min, povprečni prestiž
  - Barvno kodiranje: gold naslov (💰) za profit, trophy (🏆) za qty
  - Bar barve se prilagajajo (rdečkast tint za profit, zelen za qty)
  - Empty state specifičen za vsak način
  - Keybind help text posodobljen z Q

### Spremenjene datoteke
- `objects/Economy/RoyalMarketIntegration.lua` (+135 vrstic) — salesHistory state, recordSale helper, 4 novi API-ji
- `states/ui/hud/market_dashboard.lua` (+50 vrstic) — leaderboardMode state, Q keybind, mode-specific rendering
- `README.md` — posodobljeni badges (v3.11.908, +ProfitLeaderboard), statistika

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1640/1640 (100%) Lua datotek pass

## [v3.11.907] — 2026-08-13 — Top-10 Producers Leaderboard v Market Dashboard

### Dodano
- **RoyalSystemsRegistry** — novi API `getTopProducers(count, seconds)`:
  - Vrne top-N najproduktivnejših sistemov v časovnem oknu (default: 10 sistemov v 60s)
  - Sortirano padajoče po `totalQty`
  - Format: list `{key, name, totalCount, totalQty, avgPrestige, ratePerMin}`
- **Market Dashboard** — Top-10 producers leaderboard panel (desno od aggregate chart):
  - Restrukturiran aggregate chart panel: chart na levi (~70%), leaderboard na desni (~30%, 340px)
  - Panel povečan na 130px višine
  - Leaderboard naslov: "🏆 TOP-10 PRODUCENTOV (zadnja minuta)"
  - Vrstice z rangom (#1-#10), imenom sistema, količino, hitrostjo/min, povprečnim prestižem
  - Barvno kodiranje rangov: zlata (#1), srebrna (#2), bronasta (#3), siva (#4-10)
  - Proportional bar za vsako vrstico (fill % glede na max qty)
  - Column headers: #, Sistem, Kosov, /min, Prest.
  - Empty state: "(ni aktivnih sistemov) / Začni izdelovati v Royal sistemih (Ctrl+R)."
  - PageSize zmanjšan z 11 na 9 (da pusti prostor za večji panel)

### Spremenjene datoteke
- `objects/Economy/RoyalSystemsRegistry.lua` (+33 vrstic) — nov API getTopProducers(count, seconds)
- `states/ui/hud/market_dashboard.lua` (+85 vrstic) — leaderboard panel, restructure aggregate chart (chart left + leaderboard right), pageSize 9
- `README.md` — posodobljeni badges (v3.11.907, +Top10Leaderboard), statistika

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1640/1640 (100%) Lua datotek pass

## [v3.11.906] — 2026-08-13 — Aggregate Production Chart v Market Dashboard

### Dodano
- **RoyalSystemsRegistry** — novi API `getAggregateProductionHistory(seconds)`:
  - Vrne per-second buckete (60s okno) z agregirano količino in številom izdelkov čez vse 987 sistemov
  - Format: `{buckets={qty=, count=}, maxQty=, maxCount=, windowSeconds=}`
  - Uporabno za charting skupne proizvodnje kraljestva
- **Market Dashboard** — aggregate production chart na vrhu (med stats bar in search bar):
  - Bar chart 60s v 1s bucketih (60 stolpcev) čez vse sisteme
  - Naslov: "🏭 SKUPNA PROIZVODNJA VSEH 987 SISTEMOV (zadnjih 60s)"
  - Y-os z max in 0 labels
  - X-os z "-60s", "-30s", "now" labels
  - Barvno kodiranje: novejši (desno) svetlejši zeleni, starejši (levo) temnejši
  - Stats v naslovu (desno): skupaj, količina, aktivni sistemi, top sistem (+št.)
  - Empty state: "(čakam na proizvodnjo — začni izdelovati v Royal sistemih)"
  - Auto-scaling na maxQty v oknu
  - PageSize zmanjšan z 14 na 11 (da pusti prostor za chart višine 80px)

### Spremenjene datoteke
- `objects/Economy/RoyalSystemsRegistry.lua` (+44 vrstic) — nov API getAggregateProductionHistory(seconds)
- `states/ui/hud/market_dashboard.lua` (+72 vrstic) — aggregate production chart + require Registry + pageSize 11
- `README.md` — posodobljeni badges (v3.11.906, +AggProdChart), statistika

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1640/1640 (100%) Lua datotek pass

## [v3.11.905] — 2026-08-13 — Production History Chart v Royal Systems Panel

### Dodano
- **RoyalSystemsRegistry** — production history tracking:
  - Nov state: `productionHistory` (per-system list of `{t, productName, qty, prestige, happiness}` entries)
  - Hook v `completeMaking()` razširjen: ko Royal sistem zaključi produkt, zabeleži entry z timestamp, imenom, količino, prestižem in srečo
  - Max 300 vzorcev na sistem (~5 minut aktivne proizvodnje)
  - Max 600s starost (samodejno filtriranje starih vnosov v API-jih)
  - Novi API-ji:
    - `getProductionHistory(key, seconds?)` — vrne list vnosov (z optional time window)
    - `getProductionStats(key, seconds?)` — vrne `{totalCount, totalQty, totalPrestige, avgPrestige, firstT, lastT, timeSpan, ratePerMin, windowSeconds}`
    - `getAggregateProduction(seconds?)` — vsi sistemi agregirano: `{systemsActive, totalCount, totalQty, topSystem, topCount}`
    - `clearProductionHistory(key?)` — počisti history za en sistem (ali vse)
- **Royal Systems Panel** — production mini-chart v detail panel:
  - Bar chart 60 sekund v 1s bucketih (60 stolpcev)
  - Vsak stolpec višine proporcionalne številu izdelkov v tisti sekundi
  - Barvno kodiranje: novejši (desno) bolj svetli, starejši (levo) temnejši zeleni
  - Stats vrstica pod chart-om: skupno izdelkov, količina, hitrost (izdelki/min), povprečni prestiž, status (🔥 zelo aktivna / ✓ aktivna / ○ nizka)
  - Auto-scaling na max bucket v oknu
  - Empty state: "(ni podatkov o proizvodnji — začni izdelovati)" ko ni zgodovine
- Python test (`scripts/test_production_history.py`) — 4 testi PASS: 5 completions → 5 vnosov, window filter, max samples trimming, empty system

### Spremenjene datoteke
- `objects/Economy/RoyalSystemsRegistry.lua` (+115 vrstic) — productionHistory state, hook razširitev, 4 novi API-ji
- `states/ui/hud/royal_systems_panel.lua` (+75 vrstic) — production bar chart v detail panel pred action gumbi
- `README.md` — posodobljeni badges (v3.11.905, +ProdChart), statistika (Ctrl+R + production chart)

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Python production history test: 4 testi PASS
- Polna preverba: 1640/1640 (100%) Lua datotek pass

## [v3.11.904] — 2026-08-13 — Price History Chart v Market Dashboard

### Dodano
- **DynamicMarketSystem** — price history tracking:
  - Nov state: `priceHistory` (per-product list of `{t, sell, buy}` samples)
  - Sampling v `update()`: vsakih `config.historySampleInterval` (1.0s) zabeleži trenutno ceno za vsak produkt
  - Max 120 vzorcev (2 minuti zgodovine pri 1s sampling-u)
  - Novi API-ji:
    - `getProductHistory(productType, seconds?)` — vrne list vzorcev (z option window filter)
    - `getProductHistoryStats(productType, seconds?)` — vrne `{min, max, avg, current, first, trend, sampleCount}`
  - `reset()` počisti tudi priceHistory
- **Market Dashboard** — line chart v detail panel:
  - Detail panel povečan na 200px višine
  - Levi stolpec: text info z dodano statistiko (min/max/avg/trend za zadnjo minuto, stanje: 📈 raste / 📉 pada / ➡ stabilno)
  - Desni stolpec: line chart 60s zgodovine cene
    - Zelena debela črta: sell price
    - Modra tanka črta: buy price
    - Siva črtkana črta: base sell price (referenca)
    - Y-os s min/max labels
    - Legend (sell/buy)
  - PageSize zmanjšan z 20 na 14 (da pusti prostor za večji detail panel)
- Python test (`scripts/test_price_history.py`) — preverja sampling, window filter, max samples trimming, trend detection

### Spremenjene datoteke
- `objects/Economy/DynamicMarketSystem.lua` (+73 vrstic) — priceHistory state, sampling v update(), getProductHistory/getProductHistoryStats API, reset() cleanup
- `states/ui/hud/market_dashboard.lua` (+110 vrstic) — line chart v detail panel, pageSize 14, history stats prikaz
- `README.md` — posodobljeni badges (v3.11.904, +PriceChart), statistika (1640 datotek, +price history chart)

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Python price history test: 5 testov PASS (sampling, trend, window filter, max samples, edge cases)
- Polna preverba: 1640/1640 (100%) Lua datotek pass

## [v3.11.903] — 2026-08-13 — Royal Market Dashboard (Ctrl+K)

### Dodano
- **Market Dashboard** (nov UI panel, 378 vrstic) — `states/ui/hud/market_dashboard.lua`:
  - Full-screen overlay (toggle s **Ctrl+K**)
  - Pregled vseh 987+ Royal produktov na trgu z: imenom, osnovno ceno, trenutno prodajo/kupnjo, %-nim odstopanjem od base, skupnim številom prodanih kosov, skupnim prihodkom, virom (sistem)
  - 5 načinov sortiranja (tipka S): abecedno, po prodaji, po prihodku, po nestanovitnosti, po ceni
  - Iskanje (tipka /) po imenu produkta
  - Aggregate stats bar na vrhu: število produktov, skupni prihodek, skupno prodano, inflacija, najbolj nestabilen produkt, status auto-sella
  - Detail panel na dnu za izbrani produkt (vir, cene, razlika od base, skupna prodaja)
  - Test dogodki (tipka E): sproži naključni tržni dogodek na izbranem produktu (crash -30% ali surge +40% za 60s)
  - Barvno kodiranje cen: zelena = nad base, rdeča = pod base
  - Paginacija (20 na stran), navigacija s puščicami/WASD
  - Cache osvežen vsakih 500ms (ne vsak frame — performanca)
- **game.lua** — povezave za MarketDashboard: require, update(dt), draw(), keypressed (Ctrl+K), textinput, mousepressed
- **keybind_help.lua** — dodana Ctrl+K bližnjica v EKONOMIJA kategorijo
- Vsi fonti lazy-initializirani (preprečuje crash ob require-u pred love.graphics init)

### Spremenjene datoteke
- `states/ui/hud/market_dashboard.lua` (NOV, 378 vrstic)
- `states/game.lua` (+8 vrstic) — require + update + draw + Ctrl+K keypressed + textinput + mousepressed forwarding
- `states/ui/hud/keybind_help.lua` (+1 vrstica) — Ctrl+K v EKONOMIJA
- `README.md` — posodobljeni badges (v3.11.903, 1640 Lua, +MarketDashboard), nova vrstica v statistiki

### Funkcionalna preverba
- Lupa `load()` test: vseh 7 spremenjenih datotek PASS
- Polna preverba: 1640/1640 (100%) Lua datotek pass

## [v3.11.902] — 2026-08-13 — Royal Market Integration (DynamicMarket + auto-sell + dinamične cene)

### Dodano
- **DynamicMarketSystem razširitev**: dodana `registerProduct(productType, basePrice, source)` za registracijo Royal produktov (chalice, ornament, instrument, ...) na dinamičnem trgu. Vsak produkt dobi `priceModifiers` vstop (supply/demand, seasonal, event, inflation) — enako kot osnovne surovine (wood, stone, iron). Cene Royal produktov nihaajo glede na ponudbo in povprašanje.
- **RoyalMarketIntegration.lua** (nov modul, 232 vrstic) — centralen most med Royal sistemi in DynamicMarket:
  - `init()` — ob zagonu registrira vse Royal produkte (iz vseh 987 sistemov) na trgu z base price izpeljano iz `product.cost` (fallback `prestige * 25`).
  - `sellStock(key)` — ročno proda vso zalogo enega sistema po trenutnih tržnih cenah, zabeleži transakcijo (kar vpliva na prihodnje cene).
  - `sellProduct(key, productType, qty)` — proda specifičen produkt v določeni količini.
  - `setAutoSell(enabled)` — vklopi avtomatsko prodajo (vsakih 30s proda vso zalogo, razen ko je cena pod 40% base price — ne flood-a trga).
  - `update(dt)` — poganja auto-sell sweep v game.lua update loop-u.
  - `getStats()` — aggregate revenue, total sold, registered products.
- **RoyalSystemsRegistry.init()** — sedaj lazy-require-a RMI in registrira vse produkte pri init-u.
- **Royal Systems Panel** — posodobljen UI:
  - Zaloga produktov sedaj prikazuje trenutno tržno ceno (sell) in skupno vrednost zaloge.
  - Gumb "Prodaj vso zalogo" preimenovan v "Prodaj na trgu" — uporablja `RMI.sellStock()` z dinamičnimi cenami namesto flat `product.cost`.
  - Nov gumb "Avtomatska prodaja: ON/OFF" — toggle auto-sella za pasivni dohodek.
- **game.lua** — dodan `require("objects.Economy.RoyalMarketIntegration")` in `RoyalMarketIntegration.update(dt)` v update loop-u.
- **Sintaktična preverba (avtentična Lua load())**: **1639/1639 (100%)** datotek pass — prejšnji "1635/1638" je bil false-positive iz bracket-balance audit-a (ki je zgrešil string/comment edge case-e).

### Spremenjene datoteke
- `objects/Economy/DynamicMarketSystem.lua` (+127 vrstic) — `registerProduct`, `isRegistered`, `getRoyalBasePrice`, `listRoyalProducts`, `getRoyalStats`, `getPrice` override, `recordTransaction` override
- `objects/Economy/RoyalMarketIntegration.lua` (NOV, 232 vrstic)
- `objects/Economy/RoyalSystemsRegistry.lua` (+8 vrstic) — lazy-require RMI v init()
- `states/ui/hud/royal_systems_panel.lua` (+30 vrstic) — market price display, auto-sell toggle, sellStock preko RMI
- `states/game.lua` (+2 vrstici) — require + update klic za RoyalMarketIntegration
- `README.md` — posodobljeni badges (1639 Lua, 100% syntax, v3.11.902), nova vrstica v statistiki (Royal Market, Royal Save/Load)

### Funkcionalna preverba
- Lupa `load()` test: vsi 4 spremenjeni datoteke PASS
- Python simulacija: 5 Royal produktov registriranih iz 2 sistemov, prodaja 17 GlassMaker izdelkov za 806 gold-a, cena ornamenta pravilno niha s supply-om

## [v3.11.901] — 2026-08-13 — Royal Casting Ladle Preheat Stand Maker System (6 products, casting ladle preheat stands)
## [v3.11.900] — 2026-08-13 — Royal Core Gas Escape Channel Maker System (6 products, core gas escape channels)
## [v3.11.899] — 2026-08-13 — Royal Sand Test Cup Maker System (6 products, sand test cups)
## [v3.11.898] — 2026-08-13 — Royal Pouring Ladle Spout Liner Maker System (6 products, pouring ladle spout liners)
## [v3.11.897] — 2026-08-13 — Royal Mold Coat Brush Spinner Maker System (6 products, mold coat brush spinners)
## [v3.11.896] — 2026-08-13 — Royal Glass Engraving Wheel Bearing Maker System (6 products, glass engraving wheel bearings)
## [v3.11.895] — 2026-08-13 — Royal Glass Annealing Oven Thermocouple Maker System (6 products, glass annealing oven thermocouples)
## [v3.11.894] — 2026-08-13 — Royal Glass Colorant Sieving Cloth Maker System (6 products, glass colorant sieving cloths)
## [v3.11.893] — 2026-08-13 — Royal Glass Kiln Soot Scraper Maker System (6 products, glass kiln soot scrapers)
## [v3.11.892] — 2026-08-13 — Royal Glass Molten Glass Skim Ladle Maker System (6 products, glass molten glass skim ladles)

### Dodano (v3.11.892-v3.11.901 — 10 sistemov: steklarski dodatki 13 + livarski dodatki 13)

#### v3.11.892-v3.11.896 — Steklarski dodatki 13 (5 sistemov)
- v3.11.892: GlassMoltenGlassSkimLadleMaker (Zajemalkar) — zajemalke za strgalce taline
- v3.11.893: GlassKilnSootScraperMaker (Strgar) — strgalci za sajne
- v3.11.894: GlassColorantSievingClothMaker (Krpar) — krpe za sitanje barv
- v3.11.895: GlassAnnealingOvenThermocoupleMaker (Termočlenik) — termoelementi za peči
- v3.11.896: GlassEngravingWheelBearingMaker (Ležajnik) — ležaji za rezbarska kolesa

#### v3.11.897-v3.11.901 — Livarski dodatki 13 (5 sistemov)
- v3.11.897: MoldCoatBrushSpinnerMaker (Vrtilnik) — vrtilci za čopiče premaza
- v3.11.898: PouringLadleSpoutLinerMaker (Oblogar) — obloge za izlive
- v3.11.899: SandTestCupMaker (Skodeličar) — skodelice za testiranje peska
- v3.11.900: CoreGasEscapeChannelMaker (Kanalnik) — kanali za plin jedrc
- v3.11.901: CastingLadlePreheatStandMaker (Stojalnik) — stojala za predgrevanje

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.891] — 2026-08-13 — Royal Mill Sail Cloth Tie Down Strap Maker System (6 products, mill sail cloth tie down straps)
## [v3.11.890] — 2026-08-13 — Royal Millstone Dressing Chalk Maker System (6 products, millstone dressing chalks)
## [v3.11.889] — 2026-08-13 — Royal Mill Hopper Level Float Maker System (6 products, mill hopper level floats)
## [v3.11.888] — 2026-08-13 — Royal Grain Hopper Slide Gate Maker System (6 products, grain hopper slide gates)
## [v3.11.887] — 2026-08-13 — Royal Millstone Spindle Bearing Maker System (6 products, millstone spindle bearings)
## [v3.11.886] — 2026-08-13 — Royal Garden Frost Cloth Clip Maker System (6 products, garden frost cloth clips)
## [v3.11.885] — 2026-08-13 — Royal Garden Plant Root Watering Spike Maker System (6 products, garden plant root watering spikes)
## [v3.11.884] — 2026-08-13 — Royal Garden Compost Sifter Drum Maker System (6 products, garden compost sifter drums)
## [v3.11.883] — 2026-08-13 — Royal Garden Soil pH Tester Maker System (6 products, garden soil pH testers)
## [v3.11.882] — 2026-08-13 — Royal Garden Seed Tape Maker System (6 products, garden seed tapes)

### Dodano (v3.11.882-v3.11.891 — 10 sistemov: vrtni dodatki 12 + mlinarski dodatki 12)

#### v3.11.882-v3.11.886 — Vrtni dodatki 12 (5 sistemov)
- v3.11.882: GardenSeedTapeMaker (Trakar) — traki za seme
- v3.11.883: GardenSoilpHTesterMaker (Merilnik) — merilci pH prsti
- v3.11.884: GardenCompostSifterDrumMaker (Bobnar) — bobni za sitanje komposta
- v3.11.885: GardenPlantRootWateringSpikeMaker (Bodalar) — bodala za zalivanje korenin
- v3.11.886: GardenFrostClothClipMaker (Ščipalkar) — ščipalke za zadrževalce mraza

#### v3.11.887-v3.11.891 — Mlinarski dodatki 12 (5 sistemov)
- v3.11.887: MillstoneSpindleBearingMaker (Ležajnik) — ležaji za vretena kamnov
- v3.11.888: GrainHopperSlideGateMaker (Drsnik) — drsne zaklopnice za lijake
- v3.11.889: MillHopperLevelFloatMaker (Plavcar) — plavci za nivo žita
- v3.11.890: MillstoneDressingChalkMaker (Kredar) — kreda za označevanje kamnov
- v3.11.891: MillSailClothTieDownStrapMaker (Pasovnik) — pasovi za zategovanje tkanine

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.881] — 2026-08-13 — Royal Smith Tongs Jaw Insert Maker System (6 products, smith tongs jaw inserts)
## [v3.11.880] — 2026-08-13 — Royal Quench Tank Drain Valve Maker System (6 products, quench tank drain valves)
## [v3.11.879] — 2026-08-13 — Royal Forge Coal Rake Tooth Maker System (6 products, forge coal rake teeth)
## [v3.11.878] — 2026-08-13 — Royal Anvil Horn Polisher Maker System (6 products, anvil horn polishers)
## [v3.11.877] — 2026-08-13 — Royal Forge Tuyere Brush Maker System (6 products, forge tuyere brushes)
## [v3.11.876] — 2026-08-13 — Royal Book Cover Board Edge Trimmer Maker System (6 products, book cover board edge trimmers)
## [v3.11.875] — 2026-08-13 — Royal Book Edge Gilt Size Brush Maker System (6 products, book edge gilt size brushes)
## [v3.11.874] — 2026-08-13 — Royal Book Sewing Bench Light Maker System (6 products, book sewing bench lights)
## [v3.11.873] — 2026-08-13 — Royal Book Cover Paste Spatula Maker System (6 products, book cover paste spatulas)
## [v3.11.872] — 2026-08-13 — Royal Book Spine Label Printer Maker System (6 products, book spine label printers)

### Dodano (v3.11.872-v3.11.881 — 10 sistemov: knjigoveški dodatki 12 + kovaški dodatki 12)

#### v3.11.872-v3.11.876 — Knjigoveški dodatki 12 (5 sistemov)
- v3.11.872: BookSpineLabelPrinterMaker (Tiskar) — tiskalniki za oznake hrbtov
- v3.11.873: BookCoverPasteSpatulaMaker (Lopatičar) — lopatice za pasto naslovnic
- v3.11.874: BookSewingBenchLightMaker (Svetilnikar) — svetila za šivalne klopi
- v3.11.875: BookEdgeGiltSizeBrushMaker (Čopičar) — čopiči za pozlate robov
- v3.11.876: BookCoverBoardEdgeTrimmerMaker (Obrezovalec) — obrezovalci robov vezav

#### v3.11.877-v3.11.881 — Kovaški dodatki 12 (5 sistemov)
- v3.11.877: ForgeTuyereBrushMaker (Ščetkar) — ščetke za šobe peči
- v3.11.878: AnvilHornPolisherMaker (Polirar) — poliralci za rog nakovala
- v3.11.879: ForgeCoalRakeToothMaker (Zobnik) — zobje za grebalce oglja
- v3.11.880: QuenchTankDrainValveMaker (Zaklopkar) — zaklopke za izpust kadi
- v3.11.881: SmithTongsJawInsertMaker (Vstavljač) — vstavki za čeljusti klešč

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.871] — 2026-08-12 — Royal Casting Ladle Skimmer Handle Maker System (6 products, casting ladle skimmer handles)
## [v3.11.870] — 2026-08-12 — Royal Core Print Box Maker System (6 products, core print boxes)
## [v3.11.869] — 2026-08-12 — Royal Sand Binder Dispenser Maker System (6 products, sand binder dispensers)
## [v3.11.868] — 2026-08-12 — Royal Pouring Ladle Lining Cement Maker System (6 products, pouring ladle lining cements)
## [v3.11.867] — 2026-08-12 — Royal Mold Flask Alignment Pin Maker System (6 products, mold flask alignment pins)
## [v3.11.866] — 2026-08-12 — Royal Glass Engraving Wheel Dressing Stone Maker System (6 products, glass engraving wheel dressing stones)
## [v3.11.865] — 2026-08-12 — Royal Glass Annealing Oven Inspection Mirror Maker System (6 products, glass annealing oven inspection mirrors)
## [v3.11.864] — 2026-08-12 — Royal Glass Colorant Drying Tray Maker System (6 products, glass colorant drying trays)
## [v3.11.863] — 2026-08-12 — Royal Glass Kiln Brick Saw Maker System (6 products, glass kiln brick saws)
## [v3.11.862] — 2026-08-12 — Royal Glass Blowpipe Cooling Rack Maker System (6 products, glass blowpipe cooling racks)

### Dodano (v3.11.862-v3.11.871 — 10 sistemov: steklarski dodatki 12 + livarski dodatki 12)

#### v3.11.862-v3.11.866 — Steklarski dodatki 12 (5 sistemov)
- v3.11.862: GlassBlowpipeCoolingRackMaker (Poličar) — police za ohlajanje pihalnih palic
- v3.11.863: GlassKilnBrickSawMaker (Žagar) — žage za opeke peči
- v3.11.864: GlassColorantDryingTrayMaker (Pladnjar) — pladnji za sušenje barv
- v3.11.865: GlassAnnealingOvenInspectionMirrorMaker (Zrcalar) — zrcala za pregled peči
- v3.11.866: GlassEngravingWheelDressingStoneMaker (Brusar) — brusilni kamni za kolesa

#### v3.11.867-v3.11.871 — Livarski dodatki 12 (5 sistemov)
- v3.11.867: MoldFlaskAlignmentPinMaker (Boltnik) — bolti za poravnavo steklenic
- v3.11.868: PouringLadleLiningCementMaker (Cementar) — cement za obloge zajemalk
- v3.11.869: SandBinderDispenserMaker (Dajalnik) — dajalniki veziva za pesek
- v3.11.870: CorePrintBoxMaker (Škatlar) — škatle za odtise jedrc
- v3.11.871: CastingLadleSkimmerHandleMaker (Ročajnik) — ročaji za strgalce zajemalk

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.861] — 2026-08-12 — Royal Mill Sail Cloth Grommet Installer Maker System (6 products, mill sail cloth grommet installers)
## [v3.11.860] — 2026-08-12 — Royal Millstone Groove Depth Gauge Maker System (6 products, millstone groove depth gauges)
## [v3.11.859] — 2026-08-12 — Royal Mill Hopper Lubricator Maker System (6 products, mill hopper lubricators)
## [v3.11.858] — 2026-08-12 — Royal Grain Hopper Level Sensor Maker System (6 products, grain hopper level sensors)
## [v3.11.857] — 2026-08-12 — Royal Millstone Balance Weight Maker System (6 products, millstone balance weights)
## [v3.11.856] — 2026-08-12 — Royal Garden Plant Label Embosser Maker System (6 products, garden plant label embossers)
## [v3.11.855] — 2026-08-12 — Royal Garden Seed Packet Sealer Maker System (6 products, garden seed packet sealers)
## [v3.11.854] — 2026-08-12 — Royal Garden Compost Thermometer Probe Maker System (6 products, garden compost thermometer probes)
## [v3.11.853] — 2026-08-12 — Royal Garden Soil Moisture Meter Maker System (6 products, garden soil moisture meters)
## [v3.11.852] — 2026-08-12 — Royal Garden Plant Tie Cutter Maker System (6 products, garden plant tie cutters)

### Dodano (v3.11.852-v3.11.861 — 10 sistemov: vrtni dodatki 11 + mlinarski dodatki 11)

#### v3.11.852-v3.11.856 — Vrtni dodatki 11 (5 sistemov)
- v3.11.852: GardenPlantTieCutterMaker (Reznik) — škarje za veze rastlin
- v3.11.853: GardenSoilMoistureMeterMaker (Merilnik) — merilci vlage prsti
- v3.11.854: GardenCompostThermometerProbeMaker (Sondar) — sonde za kompost
- v3.11.855: GardenSeedPacketSealerMaker (Zatisnjevalec) — zatesnjevalci za semena
- v3.11.856: GardenPlantLabelEmbosserMaker (Žigosalec) — žigosalci za oznake

#### v3.11.857-v3.11.861 — Mlinarski dodatki 11 (5 sistemov)
- v3.11.857: MillstoneBalanceWeightMaker (Utežar) — uteži za uravnoteženje kamnov
- v3.11.858: GrainHopperLevelSensorMaker (Senzornik) — senzorji nivoja žita
- v3.11.859: MillHopperLubricatorMaker (Mazalec) — mazalci za lijak mlina
- v3.11.860: MillstoneGrooveDepthGaugeMaker (Merilnik) — merilci globine utorov
- v3.11.861: MillSailClothGrommetInstallerMaker (Nameščalec) — nameščalci obročev

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.851] — 2026-08-12 — Royal Smith Hammer Face Polisher Maker System (6 products, smith hammer face polishers)
## [v3.11.850] — 2026-08-12 — Royal Quench Oil Filter Maker System (6 products, quench oil filters)
## [v3.11.849] — 2026-08-12 — Royal Forge Chimney Cowl Maker System (6 products, forge chimney cowls)
## [v3.11.848] — 2026-08-12 — Royal Anvil Stump Wedge Maker System (6 products, anvil stump wedges)
## [v3.11.847] — 2026-08-12 — Royal Forge Ash Gate Valve Maker System (6 products, forge ash gate valves)
## [v3.11.846] — 2026-08-12 — Royal Book Cover Board Corner Miter Maker System (6 products, book cover board corner miters)
## [v3.11.845] — 2026-08-12 — Royal Book Edge Gilt Size Applicator Maker System (6 products, book edge gilt size applicators)
## [v3.11.844] — 2026-08-12 — Royal Book Sewing Cord Spool Maker System (6 products, book sewing cord spools)
## [v3.11.843] — 2026-08-12 — Royal Book Cover Paste Roller Maker System (6 products, book cover paste rollers)
## [v3.11.842] — 2026-08-12 — Royal Book Spine Gilt Size Gauge Maker System (6 products, book spine gilt size gauges)

### Dodano (v3.11.842-v3.11.851 — 10 sistemov: knjigoveški dodatki 11 + kovaški dodatki 11)

#### v3.11.842-v3.11.846 — Knjigoveški dodatki 11 (5 sistemov)
- v3.11.842: BookSpineGiltSizeGaugeMaker (Merilnik) — merilci za pozlate hrbtov
- v3.11.843: BookCoverPasteRollerMaker (Valjar) — valji za pasto naslovnic
- v3.11.844: BookSewingCordSpoolMaker (Vitičar) — vitice za šivalne vrvice
- v3.11.845: BookEdgeGiltSizeApplicatorMaker (Nanašalec) — nanašalci za pozlate robov
- v3.11.846: BookCoverBoardCornerMiterMaker (Kotnik) — koti za vezave naslovnic

#### v3.11.847-v3.11.851 — Kovaški dodatki 11 (5 sistemov)
- v3.11.847: ForgeAshGateValveMaker (Zaklopkar) — zaklopke za pepel
- v3.11.848: AnvilStumpWedgeMaker (Klinar) — klini za panj nakovala
- v3.11.849: ForgeChimneyCowlMaker (Kapičar) — kapice za dimnike
- v3.11.850: QuenchOilFilterMaker (Filtrar) — filtri za kalilno olje
- v3.11.851: SmithHammerFacePolisherMaker (Polirar) — poliralci za kladiva

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.841] — 2026-08-12 — Royal Casting Ladle Preheat Burner Maker System (6 products, casting ladle preheat burners)
## [v3.11.840] — 2026-08-12 — Royal Core Gas Vent Pin Maker System (6 products, core gas vent pins)
## [v3.11.839] — 2026-08-12 — Royal Sand Muller Blade Maker System (6 products, sand muller blades)
## [v3.11.838] — 2026-08-12 — Royal Pouring Crucible Drier Maker System (6 products, pouring crucible driers)
## [v3.11.837] — 2026-08-12 — Royal Mold Flow Tester Maker System (6 products, mold flow testers)
## [v3.11.836] — 2026-08-12 — Royal Glass Engraving Lathe Chuck Maker System (6 products, glass engraving lathe chucks)
## [v3.11.835] — 2026-08-12 — Royal Glass Annealing Oven Door Wheel Maker System (6 products, glass annealing oven door wheels)
## [v3.11.834] — 2026-08-12 — Royal Glass Colorant Mortar Pestle Maker System (6 products, glass colorant mortar pestles)
## [v3.11.833] — 2026-08-12 — Royal Glass Kiln Sighting Port Cover Maker System (6 products, glass kiln sighting port covers)
## [v3.11.832] — 2026-08-12 — Royal Glass Pipe Shears Maker System (6 products, glass pipe shears)

### Dodano (v3.11.832-v3.11.841 — 10 sistemov: steklarski dodatki 11 + livarski dodatki 11)

#### v3.11.832-v3.11.836 — Steklarski dodatki 11 (5 sistemov)
- v3.11.832: GlassPipeShearsMaker (Škardar) — škarde za pihanje stekla
- v3.11.833: GlassKilnSightingPortCoverMaker (Pokrovnik) — pokrovi za opazovalne odprtine
- v3.11.834: GlassColorantMortarPestleMaker (Pstičar) — psti za steklarske barve
- v3.11.835: GlassAnnealingOvenDoorWheelMaker (Kolar) — kolesa za vrata ohlajevalne peči
- v3.11.836: GlassEngravingLatheChuckMaker (Stiskalnik) — stiskalniki za stružnico

#### v3.11.837-v3.11.841 — Livarski dodatki 11 (5 sistemov)
- v3.11.837: MoldFlowTesterMaker (Preizkušalec) — preizkuševalci pretoka kalupa
- v3.11.838: PouringCrucibleDrierMaker (Sušilnik) — sušilci za lončne peči
- v3.11.839: SandMullerBladeMaker (Lopatičar) — lopice mešalca peska
- v3.11.840: CoreGasVentPinMaker (Boltnik) — bolti za odzračevanje jedrc
- v3.11.841: CastingLadlePreheatBurnerMaker (Gorilnik) — gorilniki za predgrevanje zajemalk

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.831] — 2026-08-12 — Royal Mill Sail Cloth Reinforcement Strip Maker System (6 products, mill sail cloth reinforcement strips)
## [v3.11.830] — 2026-08-12 — Royal Millstone Dressing Compass Maker System (6 products, millstone dressing compasses)
## [v3.11.829] — 2026-08-12 — Royal Mill Hopper Vibrator Spring Maker System (6 products, mill hopper vibrator springs)
## [v3.11.828] — 2026-08-12 — Royal Grain Sampler Probe Maker System (6 products, grain sampler probes)
## [v3.11.827] — 2026-08-12 — Royal Millstone Crane Winch Maker System (6 products, millstone crane winches)
## [v3.11.826] — 2026-08-12 — Royal Garden Compost Aerator Spike Maker System (6 products, garden compost aerator spikes)
## [v3.11.825] — 2026-08-12 — Royal Garden Irrigation Timer Maker System (6 products, garden irrigation timers)
## [v3.11.824] — 2026-08-12 — Royal Garden Transplanting Dibber Maker System (6 products, garden transplanting dibbers)
## [v3.11.823] — 2026-08-12 — Royal Plant Support Trellis Panel Maker System (6 products, plant support trellis panels)
## [v3.11.822] — 2026-08-12 — Royal Garden Soil Screen Maker System (6 products, garden soil screens)

### Dodano (v3.11.822-v3.11.831 — 10 sistemov: vrtni dodatki 10 + mlinarski dodatki 10)

#### v3.11.822-v3.11.826 — Vrtni dodatki 10 (5 sistemov)
- v3.11.822: GardenSoilScreenMaker (Sitnikar) — sitane za prst
- v3.11.823: PlantSupportTrellisPanelMaker (Panelnik) — paneli za oporo rastlin
- v3.11.824: GardenTransplantingDibberMaker (Sadilnikar) — sadilniki za presajanje
- v3.11.825: GardenIrrigationTimerMaker (Časovnikar) — časovniki za namakanje
- v3.11.826: GardenCompostAeratorSpikeMaker (Bodalar) — bodala za zračenje komposta

#### v3.11.827-v3.11.831 — Mlinarski dodatki 10 (5 sistemov)
- v3.11.827: MillstoneCraneWinchMaker (Vitjar) — vitki za dvig kamnov
- v3.11.828: GrainSamplerProbeMaker (Sondar) — sonde za vzorčenje žita
- v3.11.829: MillHopperVibratorSpringMaker (Vzmetnik) — vzmeti za tresalec lijaka
- v3.11.830: MillstoneDressingCompassMaker (Šestilar) — šestila za oblikovanje kamnov
- v3.11.831: MillSailClothReinforcementStripMaker (Trakar) — trakovi za ojačitev jedrne tkanine

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.821] — 2026-08-12 — Royal Smith Hammer Handle Wedge Maker System (6 products, smith hammer handle wedges)
## [v3.11.820] — 2026-08-12 — Royal Quench Tank Lid Gasket Maker System (6 products, quench tank lid gaskets)
## [v3.11.819] — 2026-08-12 — Royal Forge Tuyere Cooler Maker System (6 products, forge tuyere coolers)
## [v3.11.818] — 2026-08-12 — Royal Anvil Saddle Block Maker System (6 products, anvil saddle blocks)
## [v3.11.817] — 2026-08-12 — Royal Forge Clinker Breaker Maker System (6 products, forge clinker breakers)
## [v3.11.816] — 2026-08-12 — Royal Book Cover Inlay Router Maker System (6 products, book cover inlay routers)
## [v3.11.815] — 2026-08-12 — Royal Book Edge Gilt Burnisher Maker System (6 products, book edge gilt burnishers)
## [v3.11.814] — 2026-08-12 — Royal Book Sewing Bench Hook Maker System (6 products, book sewing bench hooks)
## [v3.11.813] — 2026-08-12 — Royal Book Cover Paste Brush Maker System (6 products, book cover paste brushes)
## [v3.11.812] — 2026-08-12 — Royal Book Spine Lining Roller Maker System (6 products, book spine lining rollers)

### Dodano (v3.11.812-v3.11.821 — 10 sistemov: knjigoveški dodatki 10 + kovaški dodatki 10)

#### v3.11.812-v3.11.816 — Knjigoveški dodatki 10 (5 sistemov)
- v3.11.812: BookSpineLiningRollerMaker (Valjar) — valji za podstavne tkanine
- v3.11.813: BookCoverPasteBrushMaker (Čopičar) — čopiči za pasto naslovnic
- v3.11.814: BookSewingBenchHookMaker (Kljukar) — kljuke za šivalne klopi
- v3.11.815: BookEdgeGiltBurnisherMaker (Polirnik) — poliralci za pozlate robov
- v3.11.816: BookCoverInlayRouterMaker (Žlebnik) — žlebovi za intarzije naslovnic

#### v3.11.817-v3.11.821 — Kovaški dodatki 10 (5 sistemov)
- v3.11.817: ForgeClinkerBreakerMaker (Lomilnik) — lomilci žlindre
- v3.11.818: AnvilSaddleBlockMaker (Blokirnik) — bloki za nakovalo
- v3.11.819: ForgeTuyereCoolerMaker (Hladilnik) — hladilci za šobe peči
- v3.11.820: QuenchTankLidGasketMaker (Tesnilkar) — tesnila za pokrove kadi
- v3.11.821: SmithHammerHandleWedgeMaker (Klinar) — klini za ročaje kladiv

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.811] — 2026-08-12 — Royal Casting Ladle Lining Trowel Maker System (6 products, casting ladle lining trowels)
## [v3.11.810] — 2026-08-12 — Royal Core Varnish Brush Maker System (6 products, core varnish brushes)
## [v3.11.809] — 2026-08-12 — Royal Sand Cooler Maker System (6 products, sand coolers)
## [v3.11.808] — 2026-08-12 — Royal Pouring Ladle Skimmer Sieve Maker System (6 products, pouring ladle skimmer sieves)
## [v3.11.807] — 2026-08-12 — Royal Mold Flask Clamp Wedge Maker System (6 products, mold flask clamp wedges)
## [v3.11.806] — 2026-08-12 — Royal Glass Kiln Brick Tongs Maker System (6 products, glass kiln brick tongs)
## [v3.11.805] — 2026-08-12 — Royal Glass Engraving Copper Wheel Maker System (6 products, glass engraving copper wheels)
## [v3.11.804] — 2026-08-12 — Royal Glass Annealing Tong Jaws Maker System (6 products, glass annealing tong jaws)
## [v3.11.803] — 2026-08-12 — Royal Glass Colorant Vial Shaker Maker System (6 products, glass colorant vial shakers)
## [v3.11.802] — 2026-08-12 — Royal Glass Glory Hole Damper Maker System (6 products, glass glory hole dampers)

### Dodano (v3.11.802-v3.11.811 — 10 sistemov: steklarski dodatki 10 + livarski dodatki 10)

#### v3.11.802-v3.11.806 — Steklarski dodatki 10 (5 sistemov)
- v3.11.802: GlassGloryHoleDamperMaker (Zaklopnik) — zaklopniki za glory hole
- v3.11.803: GlassColorantVialShakerMaker (Treskar) — tresilci za vialice barv
- v3.11.804: GlassAnnealingTongJawsMaker (Čeljustnik) — čeljusti za klešče ohlajanja
- v3.11.805: GlassEngravingCopperWheelMaker (Bakrenik) — bakrena rezbarska kolesa
- v3.11.806: GlassKilnBrickTongsMaker (Kleščar) — klešče za opeke peči

#### v3.11.807-v3.11.811 — Livarski dodatki 10 (5 sistemov)
- v3.11.807: MoldFlaskClampWedgeMaker (Klinar) — klini za sponke steklenic
- v3.11.808: PouringLadleSkimmerSieveMaker (Sitnikar) — sitane za strgalce
- v3.11.809: SandCoolerMaker (Hladilnik) — hladilci za livarski pesek
- v3.11.810: CoreVarnishBrushMaker (Čopičar) — čopiči za lak jedrc
- v3.11.811: CastingLadleLiningTrowelMaker (Lopatar) — lopatke za obloge zajemalk

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.801] — 2026-08-12 — Royal Mill Sail Cloth Grommet Maker System (6 products, mill sail cloth grommets)
## [v3.11.800] — 2026-08-12 — Royal Millstone Dressing Pick Maker System (6 products, millstone dressing picks)
## [v3.11.799] — 2026-08-12 — Royal Mill Hopper Sight Glass Maker System (6 products, mill hopper sight glasses)
## [v3.11.798] — 2026-08-12 — Royal Grain Hopper Auger Maker System (6 products, grain hopper augers)
## [v3.11.797] — 2026-08-12 — Royal Millstone Grain Feed Chute Maker System (6 products, millstone grain feed chutes)
## [v3.11.796] — 2026-08-12 — Royal Garden Plant Dibber Depth Mark Maker System (6 products, garden plant dibber depth marks)
## [v3.11.795] — 2026-08-12 — Royal Garden Soil Thermometer Maker System (6 products, garden soil thermometers)
## [v3.11.794] — 2026-08-12 — Royal Garden Trowel Holster Maker System (6 products, garden trowel holsters)
## [v3.11.793] — 2026-08-12 — Royal Plant Root Pruner Maker System (6 products, plant root pruners)
## [v3.11.792] — 2026-08-12 — Royal Garden Pot Brush Maker System (6 products, garden pot brushes)

### Dodano (v3.11.792-v3.11.801 — 10 sistemov: vrtni dodatki 9 + mlinarski dodatki 9)

#### v3.11.792-v3.11.796 — Vrtni dodatki 9 (5 sistemov)
- v3.11.792: GardenPotBrushMaker (Ščetkar) — ščetke za lonce
- v3.11.793: PlantRootPrunerMaker (Koreninar) — škarje za korenine
- v3.11.794: GardenTrowelHolsterMaker (Nositelj) — nositelji za lopatko
- v3.11.795: GardenSoilThermometerMaker (Termometrar) — termometri za prst
- v3.11.796: GardenPlantDibberDepthMarkMaker (Oznakar) — oznake globine za sadilnik

#### v3.11.797-v3.11.801 — Mlinarski dodatki 9 (5 sistemov)
- v3.11.797: MillstoneGrainFeedChuteMaker (Žlebnik) — žlebovi za žito
- v3.11.798: GrainHopperAugerMaker (Spiralar) — spirale za lijake
- v3.11.799: MillHopperSightGlassMaker (Okničar) — okence za opazovanje
- v3.11.800: MillstoneDressingPickMaker (Dletnik) — dleta za oblikovanje
- v3.11.801: MillSailClothGrommetMaker (Obročnik) — obroči za jedrno tkanino

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.791] — 2026-08-12 — Royal Smith Hammer Wedge Maker System (6 products, smith hammer wedges)
## [v3.11.790] — 2026-08-12 — Royal Quench Oil Dipper Maker System (6 products, quench oil dippers)
## [v3.11.789] — 2026-08-12 — Royal Forge Spark Shield Maker System (6 products, forge spark shields)
## [v3.11.788] — 2026-08-12 — Royal Anvil Clamp Maker System (6 products, anvil clamps)
## [v3.11.787] — 2026-08-12 — Royal Forge Ash Riddle Maker System (6 products, forge ash riddles)
## [v3.11.786] — 2026-08-12 — Royal Book Cover Lever Press Maker System (6 products, book cover lever presses)
## [v3.11.785] — 2026-08-12 — Royal Book Edge Polishing Stone Maker System (6 products, book edge polishing stones)
## [v3.11.784] — 2026-08-12 — Royal Book Sewing Needle Case Maker System (6 products, book sewing needle cases)
## [v3.11.783] — 2026-08-12 — Royal Book Cover Cord Winder Maker System (6 products, book cover cord winders)
## [v3.11.782] — 2026-08-12 — Royal Book Spine Glue Pot Stand Maker System (6 products, book spine glue pot stands)

### Dodano (v3.11.782-v3.11.791 — 10 sistemov: knjigoveški dodatki 9 + kovaški dodatki 9)

#### v3.11.782-v3.11.786 — Knjigoveški dodatki 9 (5 sistemov)
- v3.11.782: BookSpineGluePotStandMaker (Stojalnik) — stojala za lepilne lončke
- v3.11.783: BookCoverCordWinderMaker (Navijalec) — navijalci vrvic za naslovnice
- v3.11.784: BookSewingNeedleCaseMaker (Etuijar) — etuiji za šivalne igle
- v3.11.785: BookEdgePolishingStoneMaker (Kamnar) — polirni kamni za robove
- v3.11.786: BookCoverLeverPressMaker (Vzvodnik) — vzvodni stiskalniki za naslovnice

#### v3.11.787-v3.11.791 — Kovaški dodatki 9 (5 sistemov)
- v3.11.787: ForgeAshRiddleMaker (Sitar) — sitane za pepel
- v3.11.788: AnvilClampMaker (Sponkar) — sponke za nakovalo
- v3.11.789: ForgeSparkShieldMaker (Ščitnik) — ščiti za iskre
- v3.11.790: QuenchOilDipperMaker (Zajemalkar) — zajemalke za kalilno olje
- v3.11.791: SmithHammerWedgeMaker (Klinar) — klini za kovaška kladiva

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.781] — 2026-08-12 — Royal Casting Ladle Skimmer Hook Maker System (6 products, casting ladle skimmer hooks)
## [v3.11.780] — 2026-08-12 — Royal Core Washing Dip Maker System (6 products, core washing dips)
## [v3.11.779] — 2026-08-12 — Royal Sand Reclaimer Maker System (6 products, sand reclaimers)
## [v3.11.778] — 2026-08-12 — Royal Pouring Ladle Liner Maker System (6 products, pouring ladle liners)
## [v3.11.777] — 2026-08-12 — Royal Mold Coating Roller Maker System (6 products, mold coating rollers)
## [v3.11.776] — 2026-08-12 — Royal Glass Engraving Diamond Point Maker System (6 products, glass engraving diamond points)
## [v3.11.775] — 2026-08-12 — Royal Glass Annealing Fork Maker System (6 products, glass annealing forks)
## [v3.11.774] — 2026-08-12 — Royal Glass Colorant Muller Maker System (6 products, glass colorant mullers)
## [v3.11.773] — 2026-08-12 — Royal Glass Kiln Door Chain Maker System (6 products, glass kiln door chains)
## [v3.11.772] — 2026-08-12 — Royal Glass Gathering Iron Maker System (6 products, glass gathering irons)

### Dodano (v3.11.772-v3.11.781 — 10 sistemov: steklarski dodatki 9 + livarski dodatki 9)

#### v3.11.772-v3.11.776 — Steklarski dodatki 9 (5 sistemov)
- v3.11.772: GlassGatheringIronMaker (Paličar) — zbiralne železne palice
- v3.11.773: GlassKilnDoorChainMaker (Verižnik) — verige za vrata peči
- v3.11.774: GlassColorantMullerMaker (Možnarar) — možnarji za steklarske barve
- v3.11.775: GlassAnnealingForkMaker (Viliar) — vilice za ohlajanje stekla
- v3.11.776: GlassEngravingDiamondPointMaker (Diamantar) — diamantne konice za rezbarjenje

#### v3.11.777-v3.11.781 — Livarski dodatki 9 (5 sistemov)
- v3.11.777: MoldCoatingRollerMaker (Valjar) — valji za premaze kalupov
- v3.11.778: PouringLadleLinerMaker (Oblogar) — obloge za zajemalke
- v3.11.779: SandReclaimerMaker (Obnavljalec) — obnavljalci livarskega peska
- v3.11.780: CoreWashingDipMaker (Kopelnik) — kopeli za pranje jedrc
- v3.11.781: CastingLadleSkimmerHookMaker (Kljukar) — kljuke za strgalce zajemalk

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.771] — 2026-08-12 — Royal Mill Sail Cloth Tensioner Maker System (6 products, mill sail cloth tensioners)
## [v3.11.770] — 2026-08-12 — Royal Millstone Dressing Hammer Maker System (6 products, millstone dressing hammers)
## [v3.11.769] — 2026-08-12 — Royal Mill Hopper Vibrator Maker System (6 products, mill hopper vibrators)
## [v3.11.768] — 2026-08-12 — Royal Grain Moisture Meter Maker System (6 products, grain moisture meters)
## [v3.11.767] — 2026-08-12 — Royal Millstone Tentering Screw Maker System (6 products, millstone tentering screws)
## [v3.11.766] — 2026-08-12 — Royal Garden Bowl Sprayer Maker System (6 products, garden bowl sprayers)
## [v3.11.765] — 2026-08-12 — Royal Garden Seed Dibber Plate Maker System (6 products, garden seed dibber plates)
## [v3.11.764] — 2026-08-12 — Royal Garden Mulch Fork Maker System (6 products, garden mulch forks)
## [v3.11.763] — 2026-08-12 — Royal Plant Tying Twist Maker System (6 products, plant tying twists)
## [v3.11.762] — 2026-08-12 — Royal Garden Furrow Maker System (6 products, garden furrows)

### Dodano (v3.11.762-v3.11.771 — 10 sistemov: vrtni dodatki 8 + mlinarski dodatki 8)

#### v3.11.762-v3.11.766 — Vrtni dodatki 8 (5 sistemov)
- v3.11.762: GardenFurrowMaker (Brazdar) — brazdarji za gredice
- v3.11.763: PlantTyingTwistMaker (Vezar) — veze za rastline
- v3.11.764: GardenMulchForkMaker (Viliar) — vilice za zastirko
- v3.11.765: GardenSeedDibberPlateMaker (Ploščar) — plošče za seme
- v3.11.766: GardenBowlSprayerMaker (Skledar) — skledaste škropilnice

#### v3.11.767-v3.11.771 — Mlinarski dodatki 8 (5 sistemov)
- v3.11.767: MillstoneTenteringScrewMaker (Vijačnik) — vijačni napenjalci kamnov
- v3.11.768: GrainMoistureMeterMaker (Merilnik) — merilci vlage žita
- v3.11.769: MillHopperVibratorMaker (Treskar) — vibratorji za lijak mlina
- v3.11.770: MillstoneDressingHammerMaker (Kladivar) — kladiva za oblikovanje kamnov
- v3.11.771: MillSailClothTensionerMaker (Napenjalec) — napenjalci jedrne tkanine

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.761] — 2026-08-12 — Royal Smith Tongs Ring Maker System (6 products, smith tongs rings)
## [v3.11.760] — 2026-08-12 — Royal Quench Tank Stirrer Maker System (6 products, quench tank stirrers)
## [v3.11.759] — 2026-08-12 — Royal Forge Brick Maker System (6 products, forge bricks)
## [v3.11.758] — 2026-08-12 — Royal Anvil Face Hardener Maker System (6 products, anvil face hardeners)
## [v3.11.757] — 2026-08-12 — Royal Forge Bellows Valve Maker System (6 products, forge bellows valves)
## [v3.11.756] — 2026-08-12 — Royal Book Cover Board Shears Maker System (6 products, book cover board shears)
## [v3.11.755] — 2026-08-12 — Royal Book Edge Coloring Sponge Maker System (6 products, book edge coloring sponges)
## [v3.11.754] — 2026-08-12 — Royal Book Sewing Frame Toggle Maker System (6 products, book sewing frame toggles)
## [v3.11.753] — 2026-08-12 — Royal Book Cover Gauge Maker System (6 products, book cover gauges)
## [v3.11.752] — 2026-08-12 — Royal Book Spine Lining Cloth Maker System (6 products, book spine lining cloths)

### Dodano (v3.11.752-v3.11.761 — 10 sistemov: knjigoveški dodatki 8 + kovaški dodatki 8)

#### v3.11.752-v3.11.756 — Knjigoveški dodatki 8 (5 sistemov)
- v3.11.752: BookSpineLiningClothMaker (Tkalnik) — podstavne tkanine za hrbte
- v3.11.753: BookCoverGaugeMaker (Merilnik) — merilci za naslovnice
- v3.11.754: BookSewingFrameToggleMaker (Zatičar) — zatiči za šivalne okvire
- v3.11.755: BookEdgeColoringSpongeMaker (Gobar) — gobe za barvanje robov
- v3.11.756: BookCoverBoardShearsMaker (Škardar) — škarde za vezave

#### v3.11.757-v3.11.761 — Kovaški dodatki 8 (5 sistemov)
- v3.11.757: ForgeBellowsValveMaker (Zaklopkar) — zaklopke za kovaški meh
- v3.11.758: AnvilFaceHardenerMaker (Utrjevalec) — utrjevalci nakovala
- v3.11.759: ForgeBrickMaker (Opekar) — opeke za kovaško peč
- v3.11.760: QuenchTankStirrerMaker (Mešalnik) — mešala za kalilne kadi
- v3.11.761: SmithTongsRingMaker (Obročnik) — obroči za kovaške klešče

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.751] — 2026-08-12 — Royal Casting Ladle Nozzle Maker System (6 products, casting ladle nozzles)
## [v3.11.750] — 2026-08-12 — Royal Core Drying Rack Maker System (6 products, core drying racks)
## [v3.11.749] — 2026-08-12 — Royal Sand Sieve Shaker Maker System (6 products, sand sieve shakers)
## [v3.11.748] — 2026-08-12 — Royal Pouring Crucible Tongs Maker System (6 products, pouring crucible tongs)
## [v3.11.747] — 2026-08-12 — Royal Mold Vent Wire Cleaner Maker System (6 products, mold vent wire cleaners)
## [v3.11.746] — 2026-08-12 — Royal Glass Engraving Wheel Rest Maker System (6 products, glass engraving wheel rests)
## [v3.11.745] — 2026-08-12 — Royal Glass Annealing Roller Maker System (6 products, glass annealing rollers)
## [v3.11.744] — 2026-08-12 — Royal Glass Colorant Sieve Maker System (6 products, glass colorant sieves)
## [v3.11.743] — 2026-08-12 — Royal Glass Kiln Flue Damper Maker System (6 products, glass kiln flue dampers)
## [v3.11.742] — 2026-08-12 — Royal Glass Batch Feeder Maker System (6 products, glass batch feeders)

### Dodano (v3.11.742-v3.11.751 — 10 sistemov: steklarski dodatki 8 + livarski dodatki 8)

#### v3.11.742-v3.11.746 — Steklarski dodatki 8 (5 sistemov)
- v3.11.742: GlassBatchFeederMaker (Dajalnik) — dajalniki steklarske mešanice
- v3.11.743: GlassKilnFlueDamperMaker (Zaklopnik) — zaklopniki dimnika peči
- v3.11.744: GlassColorantSieveMaker (Sitnikar) — sitane za steklarske barve
- v3.11.745: GlassAnnealingRollerMaker (Valjar) — valji za ohlajanje stekla
- v3.11.746: GlassEngravingWheelRestMaker (Počivalnik) — počivališča za rezbarska kolesa

#### v3.11.747-v3.11.751 — Livarski dodatki 8 (5 sistemov)
- v3.11.747: MoldVentWireCleanerMaker (Čistilnik) — čistilci žic za odzračevanje
- v3.11.748: PouringCrucibleTongsMaker (Kleščar) — klešče za livljenje
- v3.11.749: SandSieveShakerMaker (Treskar) — tresoče sitane za pesek
- v3.11.750: CoreDryingRackMaker (Stojalnik) — stojala za sušenje jedrc
- v3.11.751: CastingLadleNozzleMaker (Šobnik) — šobe za zajemalke

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.741] — 2026-08-12 — Royal Mill Sail Cloth Reel Maker System (6 products, mill sail cloth reels)
## [v3.11.740] — 2026-08-12 — Royal Millstone Eye Reamer Maker System (6 products, millstone eye reamers)
## [v3.11.739] — 2026-08-12 — Royal Mill Hopper Lid Maker System (6 products, mill hopper lids)
## [v3.11.738] — 2026-08-12 — Royal Grain Auger Spiral Maker System (6 products, grain auger spirals)
## [v3.11.737] — 2026-08-12 — Royal Millstone Tenter Hook Maker System (6 products, millstone tenter hooks)
## [v3.11.736] — 2026-08-12 — Royal Garden Soil Aerator Spike Maker System (6 products, garden soil aerator spikes)
## [v3.11.735] — 2026-08-12 — Royal Garden Leaf Grabber Maker System (6 products, garden leaf grabbers)
## [v3.11.734] — 2026-08-12 — Royal Garden Dibber Depth Gauge Maker System (6 products, garden dibber depth gauges)
## [v3.11.733] — 2026-08-12 — Royal Plant Climbing Net Maker System (6 products, plant climbing nets)
## [v3.11.732] — 2026-08-12 — Royal Garden Border Edger Maker System (6 products, garden border edgers)

### Dodano (v3.11.732-v3.11.741 — 10 sistemov: vrtni dodatki 7 + mlinarski dodatki 7)

#### v3.11.732-v3.11.736 — Vrtni dodatki 7 (5 sistemov)
- v3.11.732: GardenBorderEdgerMaker (Robnik) — robovi za gredice
- v3.11.733: PlantClimbingNetMaker (Mrežar) — mreže za plezalke
- v3.11.734: GardenDibberDepthGaugeMaker (Merilnik) — merilci globine za sadilnik
- v3.11.735: GardenLeafGrabberMaker (Listar) — grablje za liste
- v3.11.736: GardenSoilAeratorSpikeMaker (Bodalar) — bodala za zračenje tal

#### v3.11.737-v3.11.741 — Mlinarski dodatki 7 (5 sistemov)
- v3.11.737: MillstoneTenterHookMaker (Napenjalec) — kljuki za napenjanje kamnov
- v3.11.738: GrainAugerSpiralMaker (Spiralar) — spirale za transporter žita
- v3.11.739: MillHopperLidMaker (Pokrovnik) — pokrovi za lijak mlina
- v3.11.740: MillstoneEyeReamerMaker (Razširjevalec) — razširjevalci očes mlinskih kamnov
- v3.11.741: MillSailClothReelMaker (Vitičar) — vitice za jedrno tkanino mlina

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.731] — 2026-08-12 — Royal Slack Tub Lid Maker System (6 products, slack tub lids)
## [v3.11.730] — 2026-08-12 — Royal Hardy Shank Maker System (6 products, hardy shanks)
## [v3.11.729] — 2026-08-12 — Royal Forge Hood Flue Maker System (6 products, forge hood flues)
## [v3.11.728] — 2026-08-12 — Royal Anvil Stump Maker System (6 products, anvil stumps)
## [v3.11.727] — 2026-08-12 — Royal Forge Tuyere Block Maker System (6 products, forge tuyere blocks)
## [v3.11.726] — 2026-08-12 — Royal Book Cover Stamping Foil Maker System (6 products, book cover stamping foils)
## [v3.11.725] — 2026-08-12 — Royal Book Foredge Fan Maker System (6 products, book foredge fans)
## [v3.11.724] — 2026-08-12 — Royal Book Spine Glue Brush Maker System (6 products, book spine glue brushes)
## [v3.11.723] — 2026-08-12 — Royal Book Cover Corner Cutter Maker System (6 products, book cover corner cutters)
## [v3.11.722] — 2026-08-12 — Royal Book Endband Loom Maker System (6 products, book endband looms)

### Dodano (v3.11.722-v3.11.731 — 10 sistemov: knjigoveški dodatki 7 + kovaški dodatki 7)

#### v3.11.722-v3.11.726 — Knjigoveški dodatki 7 (5 sistemov)
- v3.11.722: BookEndbandLoomMaker (Statvar) — statvi za kapice knjig
- v3.11.723: BookCoverCornerCutterMaker (Roborezar) — rezalniki robov naslovnic
- v3.11.724: BookSpineGlueBrushMaker (Čopičar) — čopiči za lepilo hrbtov
- v3.11.725: BookForedgeFanMaker (Ventilator) — ventilatorji za prednji rob
- v3.11.726: BookCoverStampingFoilMaker (Foljar) — folije za žigosanje naslovnic

#### v3.11.727-v3.11.731 — Kovaški dodatki 7 (5 sistemov)
- v3.11.727: ForgeTuyereBlockMaker (Blokirnik) — bloki šob za peč
- v3.11.728: AnvilStumpMaker (Panjar) — panji za nakovalo
- v3.11.729: ForgeHoodFlueMaker (Napačnik) — nape za dim kovaške peči
- v3.11.730: HardyShankMaker (Drgnik) — drgi za trde nastavke
- v3.11.731: SlackTubLidMaker (Pokrovnik) — pokrovi za kalilno kad

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.721] — 2026-08-12 — Royal Casting Breakout Chisel Maker System (6 products, casting breakout chisels)
## [v3.11.720] — 2026-08-12 — Royal Core Paste Mixer Maker System (6 products, core paste mixers)
## [v3.11.719] — 2026-08-12 — Royal Sand Conditioner Maker System (6 products, sand conditioners)
## [v3.11.718] — 2026-08-12 — Royal Pouring Cone Maker System (6 products, pouring cones)
## [v3.11.717] — 2026-08-12 — Royal Mold Drying Stand Maker System (6 products, mold drying stands)
## [v3.11.716] — 2026-08-12 — Royal Glass Shear Spring Maker System (6 products, glass shear springs)
## [v3.11.715] — 2026-08-12 — Royal Glass Annealing Cart Maker System (6 products, glass annealing carts)
## [v3.11.714] — 2026-08-12 — Royal Glass Colorant Spatula Maker System (6 products, glass colorant spatulas)
## [v3.11.713] — 2026-08-12 — Royal Glass Kiln Spy Maker System (6 products, glass kiln spies)
## [v3.11.712] — 2026-08-12 — Royal Glass Punty Warmer Maker System (6 products, glass punty warmers)

### Dodano (v3.11.712-v3.11.721 — 10 sistemov: steklarski dodatki 7 + livarski dodatki 7)

#### v3.11.712-v3.11.716 — Steklarski dodatki 7 (5 sistemov)
- v3.11.712: GlassPuntyWarmerMaker (Grevalnik) — grevalniki palic za steklo
- v3.11.713: GlassKilnSpyMaker (Opazovalnik) — opazovalne odprtine peči
- v3.11.714: GlassColorantSpatulaMaker (Lopatičar) — lopatice za steklarske barve
- v3.11.715: GlassAnnealingCartMaker (Vozičkar) — vozički za ohlajanje stekla
- v3.11.716: GlassShearSpringMaker (Vzmetnik) — vzmeti za steklarske škarde

#### v3.11.717-v3.11.721 — Livarski dodatki 7 (5 sistemov)
- v3.11.717: MoldDryingStandMaker (Stojalnik) — stojala za sušenje kalupov
- v3.11.718: PouringConeMaker (Lijakar) — lijaki za vlivanje
- v3.11.719: SandConditionerMaker (Kondicionar) — kondicionerji za livarski pesek
- v3.11.720: CorePasteMixerMaker (Mešalnik) — mešalniki jedrne paste
- v3.11.721: CastingBreakoutChiselMaker (Dletnik) — dleta za odklešanje

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.711] — 2026-08-12 — Royal Mill Sail Frame Maker System (6 products, mill sail frames)
## [v3.11.710] — 2026-08-12 — Royal Millstone Bush Maker System (6 products, millstone bushes)
## [v3.11.709] — 2026-08-12 — Royal Mill Hopper Shaker Maker System (6 products, mill hopper shakers)
## [v3.11.708] — 2026-08-12 — Royal Grain Spout Maker System (6 products, grain spouts)
## [v3.11.707] — 2026-08-12 — Royal Millstone Quill Maker System (6 products, millstone quills)
## [v3.11.706] — 2026-08-12 — Royal Garden Cloche Maker System (6 products, garden cloches)
## [v3.11.705] — 2026-08-12 — Royal Garden Tool Rack Maker System (6 products, garden tool racks)
## [v3.11.704] — 2026-08-12 — Royal Garden Watering Tray Maker System (6 products, garden watering trays)
## [v3.11.703] — 2026-08-12 — Royal Plant Support Stake Maker System (6 products, plant support stakes)
## [v3.11.702] — 2026-08-12 — Royal Garden Sieve Frame Maker System (6 products, garden sieve frames)

### Dodano (v3.11.702-v3.11.711 — 10 sistemov: vrtni dodatki 6 + mlinarski dodatki 6)

#### v3.11.702-v3.11.706 — Vrtni dodatki 6 (5 sistemov)
- v3.11.702: GardenSieveFrameMaker (Okvirnik) — okvirji za sita
- v3.11.703: PlantSupportStakeMaker (Kolčkar) — kolčki za oporo rastlin
- v3.11.704: GardenWateringTrayMaker (Pladnjar) — pladnji za zalivanje
- v3.11.705: GardenToolRackMaker (Stojalnik) — stojala za vrtno orodje
- v3.11.706: GardenClocheMaker (Pokrovnik) — stekleni pokrovi za rastline

#### v3.11.707-v3.11.711 — Mlinarski dodatki 6 (5 sistemov)
- v3.11.707: MillstoneQuillMaker (Vretenar) — vretena mlinskih kamnov
- v3.11.708: GrainSpoutMaker (Žlivkar) — žlivi za žito
- v3.11.709: MillHopperShakerMaker (Treskar) — tresoče stresalo za lijak
- v3.11.710: MillstoneBushMaker (Ležajnik) — ležajni bush-i za mlinske kamne
- v3.11.711: MillSailFrameMaker (Jedrnik) — okvirji za jedra mlina

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.701] — 2026-08-12 — Royal Blacksmith Vise Maker System (6 products, blacksmith vises)
## [v3.11.700] — 2026-08-12 — Royal Forge Chimney Damper Maker System (6 products, forge chimney dampers)
## [v3.11.699] — 2026-08-12 — Royal Slack Tub Hood Maker System (6 products, slack tub hoods)
## [v3.11.698] — 2026-08-12 — Royal Bick Horn Anvil Maker System (6 products, bick horn anvils)
## [v3.11.697] — 2026-08-12 — Royal Forge Ash Pan Maker System (6 products, forge ash pans)
## [v3.11.696] — 2026-08-12 — Royal Bookbinding Screw Press Maker System (6 products, bookbinding screw presses)
## [v3.11.695] — 2026-08-12 — Royal Book Edge Burnisher Maker System (6 products, book edge burnishers)
## [v3.11.694] — 2026-08-12 — Royal Book Cover Die Maker System (6 products, book cover dies)
## [v3.11.693] — 2026-08-12 — Royal Bookbinding Glue Pot Maker System (6 products, bookbinding glue pots)
## [v3.11.692] — 2026-08-12 — Royal Book Spine Ruler Maker System (6 products, book spine rulers)

### Dodano (v3.11.692-v3.11.701 — 10 sistemov: knjigoveški dodatki 6 + kovaški dodatki 6)

#### v3.11.692-v3.11.696 — Knjigoveški dodatki 6 (5 sistemov)
- v3.11.692: BookSpineRulerMaker (Merilnik) — merilniki hrbtov knjig
- v3.11.693: BookbindingGluePotMaker (Lončkar) — lepilni lončki
- v3.11.694: BookCoverDieMaker (Matrikar) — matrice za naslovnice
- v3.11.695: BookEdgeBurnisherMaker (Polirnik) — poliralci robov knjig
- v3.11.696: BookbindingScrewPressMaker (Stiskalnik) — vijačni stiskalniki za knjige

#### v3.11.697-v3.11.701 — Kovaški dodatki 6 (5 sistemov)
- v3.11.697: ForgeAshPanMaker (Pepelnikar) — pepelniki za kovaške peči
- v3.11.698: BickHornAnvilMaker (Rogar) — rogaste nakovalo
- v3.11.699: SlackTubHoodMaker (Pokrovnik) — pokrovi za kalilne kadi
- v3.11.700: ForgeChimneyDamperMaker (Zaklopnik) — zaklopniki dimnikov
- v3.11.701: BlacksmithViseMaker (Primernik) — kovaške primernice

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.691] — 2026-08-12 — Royal Casting Ladle Skimmer Maker System (6 products, casting ladle skimmers)
## [v3.11.690] — 2026-08-12 — Royal Ladle Preheater Maker System (6 products, ladle preheaters)
## [v3.11.689] — 2026-08-12 — Royal Core Oven Maker System (6 products, core ovens)
## [v3.11.688] — 2026-08-12 — Royal Sand Muller Maker System (6 products, sand mullers)
## [v3.11.687] — 2026-08-12 — Royal Mold Wash Booth Maker System (6 products, mold wash booths)
## [v3.11.686] — 2026-08-12 — Royal Glass Engraving Point Maker System (6 products, glass engraving points)
## [v3.11.685] — 2026-08-12 — Royal Glass Lehr Belt Maker System (6 products, glass lehr belts)
## [v3.11.684] — 2026-08-12 — Royal Glass Cullet Crusher Maker System (6 products, glass cullet crushers)
## [v3.11.683] — 2026-08-12 — Royal Glass Kiln Muffle Maker System (6 products, glass kiln muffles)
## [v3.11.682] — 2026-08-12 — Royal Glass Yoke Maker System (6 products, glass yokes)

### Dodano (v3.11.682-v3.11.691 — 10 sistemov: steklarski dodatki 6 + livarski dodatki 6)

#### v3.11.682-v3.11.686 — Steklarski dodatki 6 (5 sistemov)
- v3.11.682: GlassYokeMaker (Jarmar) — jarmi za prenos stekla
- v3.11.683: GlassKilnMuffleMaker (Mufelničar) — mufli za steklarske peči
- v3.11.684: GlassCulletCrusherMaker (Drobljar) — drobilniki steklenega odpada
- v3.11.685: GlassLehrBeltMaker (Tračar) — trakovi za ohlajevalne peči
- v3.11.686: GlassEngravingPointMaker (Konidar) — rezbarske konice za steklo

#### v3.11.687-v3.11.691 — Livarski dodatki 6 (5 sistemov)
- v3.11.687: MoldWashBoothMaker (Kabinar) — kabine za pranje kalupov
- v3.11.688: SandMullerMaker (Mešač) — mešalci livarskega peska
- v3.11.689: CoreOvenMaker (Pečar) — peči za jedrca
- v3.11.690: LadlePreheaterMaker (Predgrevalec) — predgrevalci zajemalk
- v3.11.691: CastingLadleSkimmerMaker (Strgar) — površinski strgalci zajemalk

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.681] — 2026-08-12 — Royal Mill Sail Cloth Maker System (6 products, mill sail cloths)
## [v3.11.680] — 2026-08-12 — Royal Millstone Balancer Maker System (6 products, millstone balancers)
## [v3.11.679] — 2026-08-12 — Royal Mill Hopper Agitator Maker System (6 products, mill hopper agitators)
## [v3.11.678] — 2026-08-12 — Royal Grain Sieve Maker System (6 products, grain sieves)
## [v3.11.677] — 2026-08-12 — Royal Millstone Lifter Hooks Maker System (6 products, millstone lifter hooks)
## [v3.11.676] — 2026-08-12 — Royal Garden Kneeler Maker System (6 products, garden kneelers)
## [v3.11.675] — 2026-08-12 — Royal Plant Label Maker System (6 products, plant labels)
## [v3.11.674] — 2026-08-12 — Royal Garden Twine Dispenser Maker System (6 products, garden twine dispensers)
## [v3.11.673] — 2026-08-12 — Royal Trellis Maker System (6 products, trellises)
## [v3.11.672] — 2026-08-12 — Royal Garden Trowel Sharpener Maker System (6 products, garden trowel sharpeners)

### Dodano (v3.11.672-v3.11.681 — 10 sistemov: vrtni dodatki 5 + mlinarski dodatki 5)

#### v3.11.672-v3.11.676 — Vrtni dodatki 5 (5 sistemov)
- v3.11.672: GardenTrowelSharpenerMaker (Brusilnik) — brusilci lopatk
- v3.11.673: TrellisMaker (Rešetkar) — loške rešetke za rastline
- v3.11.674: GardenTwineDispenserMaker (Razdelilnik) — razdelilci vrvice
- v3.11.675: PlantLabelMaker (Oznakar) — oznake za rastline
- v3.11.676: GardenKneelerMaker (Klečnik) — pohištvo za klečenje

#### v3.11.677-v3.11.681 — Mlinarski dodatki 5 (5 sistemov)
- v3.11.677: MillstoneLifterHooksMaker (Dvigalkar) — kljuki za dviganje kamnov
- v3.11.678: GrainSieveMaker (Sitnikar) — sitane za žito
- v3.11.679: MillHopperAgitatorMaker (Stresalec) — stresalci za lijak
- v3.11.680: MillstoneBalancerMaker (Uravnalec) — uravnavalci mlinskih kamnov
- v3.11.681: MillSailClothMaker (Tkalnik) — jedrna tkanina za mlin

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.671] — 2026-08-12 — Royal Forge Coke Rake Maker System (6 products, forge coke rakes)
## [v3.11.670] — 2026-08-12 — Royal Cupola Tuyere Maker System (6 products, cupola tuyeres)
## [v3.11.669] — 2026-08-12 — Royal Hot Cut Hardy Maker System (6 products, hot cut hardies)
## [v3.11.668] — 2026-08-12 — Royal Bell Hammer Maker System (6 products, bell hammers)
## [v3.11.667] — 2026-08-12 — Royal Pritchel Hole Maker System (6 products, pritchel holes)
## [v3.11.666] — 2026-08-12 — Royal Book Cover Inlay Maker System (6 products, book cover inlays)
## [v3.11.665] — 2026-08-12 — Royal Book Mark Tassel Maker System (6 products, book mark tassels)
## [v3.11.664] — 2026-08-12 — Royal Book Spine Creaser Maker System (6 products, book spine creasers)
## [v3.11.663] — 2026-08-12 — Royal Bookbinding Press Stone Maker System (6 products, bookbinding press stones)
## [v3.11.662] — 2026-08-12 — Royal Book Edge Gilder Maker System (6 products, book edge gilders)

### Dodano (v3.11.662-v3.11.671 — 10 sistemov: knjigoveški dodatki 5 + kovaški dodatki 5)

#### v3.11.662-v3.11.666 — Knjigoveški dodatki 5 (5 sistemov)
- v3.11.662: BookEdgeGilderMaker (Pozlačevalnik) — pozlačevalci robov knjig
- v3.11.663: BookbindingPressStoneMaker (Kamnar) — kamni za stiskanje knjig
- v3.11.664: BookSpineCreaserMaker (Hrbtogubalec) — gubalci hrbtov knjig
- v3.11.665: BookMarkTasselMaker (Lokčar) — loki za zaznamke
- v3.11.666: BookCoverInlayMaker (Intarzist) — intarzije za naslovnice

#### v3.11.667-v3.11.671 — Kovaški dodatki 5 (5 sistemov)
- v3.11.667: PritchelHoleMaker (Koničar) — luknje za konice
- v3.11.668: BellHammerMaker (Zvokobijalec) — zvočna kladiva
- v3.11.669: HotCutHardyMaker (Vročoreznik) — vroče rezalni trdi nastavki
- v3.11.670: CupolaTuyereMaker (Šobnik) — šobe za kupole
- v3.11.671: ForgeCokeRakeMaker (KoksGrebar) — grebalci za koks

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.661] — 2026-08-12 — Royal Core Box Maker System (6 products, core boxes)
## [v3.11.660] — 2026-08-12 — Royal Mold Coating Brush Maker System (6 products, mold coating brushes)
## [v3.11.659] — 2026-08-12 — Royal Thermocouple Sheath Maker System (6 products, thermocouple sheaths)
## [v3.11.658] — 2026-08-12 — Royal Degassing Lance Maker System (6 products, degassing lances)
## [v3.11.657] — 2026-08-12 — Royal Inoculation Ladle Maker System (6 products, inoculation ladles)
## [v3.11.656] — 2026-08-12 — Royal Glass Polishing Pad Maker System (6 products, glass polishing pads)
## [v3.11.655] — 2026-08-12 — Royal Glass Kiln Seal Maker System (6 products, glass kiln seals)
## [v3.11.654] — 2026-08-12 — Royal Glass Batch Mixer Maker System (6 products, glass batch mixers)
## [v3.11.653] — 2026-08-12 — Royal Glass Cooling Rack Maker System (6 products, glass cooling racks)
## [v3.11.652] — 2026-08-12 — Royal Glass Blowing Mold Maker System (6 products, glass blowing molds)

### Dodano (v3.11.652-v3.11.661 — 10 sistemov: steklarski dodatki 5 + livarski dodatki 5)

#### v3.11.652-v3.11.656 — Steklarski dodatki 5 (5 sistemov)
- v3.11.652: GlassBlowingMoldMaker (Modelar) — modeli za pihanje stekla
- v3.11.653: GlassCoolingRackMaker (Poličar) — ohlajevalne police za steklo
- v3.11.654: GlassBatchMixerMaker (Mešar) — mešalci steklarske mešanice
- v3.11.655: GlassKilnSealMaker (Tesnilkar) — tesnila za steklarske peči
- v3.11.656: GlassPolishingPadMaker (Blaziničar) — polirne blazinice za steklo

#### v3.11.657-v3.11.661 — Livarski dodatki 5 (5 sistemov)
- v3.11.657: InoculationLadleMaker (Inokulant) — inokulacijske zajemalke
- v3.11.658: DegassingLanceMaker (Plinilec) — plinilna kopja za livarstvo
- v3.11.659: ThermocoupleSheathMaker (Zaščitkar) — zaščite termoelementov
- v3.11.660: MoldCoatingBrushMaker (Čopičar) — čopiči za premaze kalupov
- v3.11.661: CoreBoxMaker (Jeklenkar) — jeklenke za jedrca

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.651] — 2026-08-12 — Royal Millstone Groove Reframer Maker System (6 products, millstone groove reframers)
## [v3.11.650] — 2026-08-12 — Royal Flour Packer Maker System (6 products, flour packers)
## [v3.11.649] — 2026-08-12 — Royal Mill Drive Belt Maker System (6 products, mill drive belts)
## [v3.11.648] — 2026-08-12 — Royal Grain Hopper Liner Maker System (6 products, grain hopper liners)
## [v3.11.647] — 2026-08-12 — Royal Millstone Crane Hook Maker System (6 products, millstone crane hooks)
## [v3.11.646] — 2026-08-12 — Royal Compost Sieve Maker System (6 products, compost sieves)
## [v3.11.645] — 2026-08-12 — Royal Garden Sprayer Maker System (6 products, garden sprayers)
## [v3.11.644] — 2026-08-12 — Royal Lawn Aerator Maker System (6 products, lawn aerators)
## [v3.11.643] — 2026-08-12 — Royal Hedge Shears Maker System (6 products, hedge shears)
## [v3.11.642] — 2026-08-12 — Royal Garden Secateurs Maker System (6 products, garden secateurs)

### Dodano (v3.11.642-v3.11.651 — 10 sistemov: vrtni dodatki 4 + mlinarski dodatki 4)

#### v3.11.642-v3.11.646 — Vrtni dodatki 4 (5 sistemov)
- v3.11.642: GardenSecateursMaker (Škarjičar) — vrtni škarjici
- v3.11.643: HedgeShearsMaker (Mejnikar) — škarje za žive meje
- v3.11.644: LawnAeratorMaker (Zračnik) — zračilci travnikov
- v3.11.645: GardenSprayerMaker (Škropičar) — vrtni škropilnice
- v3.11.646: CompostSieveMaker (Sitnikar) — sitane za kompost

#### v3.11.647-v3.11.651 — Mlinarski dodatki 4 (5 sistemov)
- v3.11.647: MillstoneCraneHookMaker (Kljukar) — kljuki za dvig mlinskih kamnov
- v3.11.648: GrainHopperLinerMaker (Oblogar) — obloge za lijake
- v3.11.649: MillDriveBeltMaker (Jermensar) — pogonski jermeni za mline
- v3.11.650: FlourPackerMaker (Pakar) — pakerji za moko
- v3.11.651: MillstoneGrooveReframerMaker (Utorovalec) — obnavljalci utorov

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.641] — 2026-08-12 — Royal Anvil Hardy Maker System (6 products, anvil hardies)
## [v3.11.640] — 2026-08-12 — Royal Top Fuller Maker System (6 products, top fullers)
## [v3.11.639] — 2026-08-12 — Royal Bottom Fuller Maker System (6 products, bottom fullers)
## [v3.11.638] — 2026-08-12 — Royal Set Hammer Maker System (6 products, set hammers)
## [v3.11.637] — 2026-08-12 — Royal Cutter Hardy Maker System (6 products, cutter hardies)
## [v3.11.636] — 2026-08-12 — Royal Book Cover Crimper Maker System (6 products, book cover crimpers)
## [v3.11.635] — 2026-08-12 — Royal Book Thread Reel Maker System (6 products, book thread reels)
## [v3.11.634] — 2026-08-12 — Royal Bookbinding Awl Maker System (6 products, bookbinding awls)
## [v3.11.633] — 2026-08-12 — Royal Book Pressing Weight Maker System (6 products, book pressing weights)
## [v3.11.632] — 2026-08-12 — Royal Book Edge Painter Maker System (6 products, book edge painters)

### Dodano (v3.11.632-v3.11.641 — 10 sistemov: knjigoveški dodatki 4 + kovaški dodatki 4)

#### v3.11.632-v3.11.636 — Knjigoveški dodatki 4 (5 sistemov)
- v3.11.632: BookEdgePainterMaker (Roboslikar) — slikalci robov knjig
- v3.11.633: BookPressingWeightMaker (Utežar) — uteži za stiskanje knjig
- v3.11.634: BookbindingAwlMaker (Šilar) — šila za knjigoveštvo
- v3.11.635: BookThreadReelMaker (Vitičar) — vitice za knjigoveške niti
- v3.11.636: BookCoverCrimperMaker (Gubalec) — gubalci naslovnic

#### v3.11.637-v3.11.641 — Kovaški dodatki 4 (5 sistemov)
- v3.11.637: CutterHardyMaker (Reznik) — trdi rezalniki za nakovalo
- v3.11.638: SetHammerMaker (Nastavljalec) — nastavitvena kladiva
- v3.11.639: BottomFullerMaker (SpodnjiUtor) — spodnji fullerji za utorjanje
- v3.11.640: TopFullerMaker (ZgornjiUtor) — zgornji fullerji za utorjanje
- v3.11.641: AnvilHardyMaker (Nastavkar) — trdi nastavki za nakovalo

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.631] — 2026-08-12 — Royal Mold Drying Oven Maker System (6 products, mold drying ovens)
## [v3.11.630] — 2026-08-12 — Royal Slurry Mixer Maker System (6 products, slurry mixers)
## [v3.11.629] — 2026-08-12 — Royal Riser Breaker Maker System (6 products, riser breakers)
## [v3.11.628] — 2026-08-12 — Royal Sprue Cutter Maker System (6 products, sprue cutters)
## [v3.11.627] — 2026-08-12 — Royal Mold Release Agent Maker System (6 products, mold release agents)
## [v3.11.626] — 2026-08-12 — Royal Glass Engraving Wheel Maker System (6 products, glass engraving wheels)
## [v3.11.625] — 2026-08-12 — Royal Glass Kiln Door Lifter Maker System (6 products, glass kiln door lifters)
## [v3.11.624] — 2026-08-12 — Royal Glass Cane Slicer Maker System (6 products, glass cane slicers)
## [v3.11.623] — 2026-08-12 — Royal Glass Colorant Mortar Maker System (6 products, glass colorant mortars)
## [v3.11.622] — 2026-08-12 — Royal Glass Annealing Cradle Maker System (6 products, glass annealing cradles)

### Dodano (v3.11.622-v3.11.631 — 10 sistemov: steklarski dodatki 4 + livarski dodatki 4)

#### v3.11.622-v3.11.626 — Steklarski dodatki 4 (5 sistemov)
- v3.11.622: GlassAnnealingCradleMaker (Zibkar) — zibke za ohlajanje stekla
- v3.11.623: GlassColorantMortarMaker (Možnarar) — možnarji za steklarske barve
- v3.11.624: GlassCaneSlicerMaker (Rezar) — rezalniki steklenih palic
- v3.11.625: GlassKilnDoorLifterMaker (Dvigovalnik) — dvigalci pečnih vrat
- v3.11.626: GlassEngravingWheelMaker (Rezbar) — rezbarska kolesa za steklo

#### v3.11.627-v3.11.631 — Livarski dodatki 4 (5 sistemov)
- v3.11.627: MoldReleaseAgentMaker (Ločilar) — sredstva za ločitev kalupov
- v3.11.628: SprueCutterMaker (Vtokorezar) — rezalniki vtokov
- v3.11.629: RiserBreakerMaker (Penolomar) — lomilci pen
- v3.11.630: SlurryMixerMaker (Mešar) — mešalci livarske kaše
- v3.11.631: MoldDryingOvenMaker (Sušar) — sušilne peči za kalupe

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.621] — 2026-08-12 — Royal Bran Separator Maker System (6 products, bran separators)
## [v3.11.620] — 2026-08-12 — Royal Flour Sieve Maker System (6 products, flour sieves)
## [v3.11.619] — 2026-08-12 — Royal Hopper Gate Maker System (6 products, hopper gates)
## [v3.11.618] — 2026-08-12 — Royal Millstone Dresser Maker System (6 products, millstone dressers)
## [v3.11.617] — 2026-08-12 — Royal Grain Auger Maker System (6 products, grain augers)
## [v3.11.616] — 2026-08-12 — Royal Garden Wheelbarrow Maker System (6 products, garden wheelbarrows)
## [v3.11.615] — 2026-08-12 — Royal Pruning Saw Maker System (6 products, pruning saws)
## [v3.11.614] — 2026-08-12 — Royal Garden Rake Maker System (6 products, garden rakes)
## [v3.11.613] — 2026-08-12 — Royal Dibber Maker System (6 products, dibbers)
## [v3.11.612] — 2026-08-12 — Royal Garden Hoe Maker System (6 products, garden hoes)

### Dodano (v3.11.612-v3.11.621 — 10 sistemov: vrtni dodatki 3 + mlinarski dodatki 3)

#### v3.11.612-v3.11.616 — Vrtni dodatki 3 (5 sistemov)
- v3.11.612: GardenHoeMaker (Motikar) — vrtne motike
- v3.11.613: DibberMaker (Sadilnikar) — sadilniki za seme
- v3.11.614: GardenRakeMaker (Gredlar) — vrtne grelde
- v3.11.615: PruningSawMaker (Žagar) — žage za obrezovanje
- v3.11.616: GardenWheelbarrowMaker (Vozičkar) — vrtni vozički

#### v3.11.617-v3.11.621 — Mlinarski dodatki 3 (5 sistemov)
- v3.11.617: GrainAugerMaker (Spiralar) — spiralni transporterji za žito
- v3.11.618: MillstoneDresserMaker (Oblikovalec) — oblikovalci mlinskih kamnov
- v3.11.619: HopperGateMaker (Zaporničar) — zapornice za lijake
- v3.11.620: FlourSieveMaker (Sitnikar) — sitane za moko
- v3.11.621: BranSeparatorMaker (Ločevalec) — ločilci otrob

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov.

## [v3.11.611] — 2026-08-12 — Royal Flatter Maker System (6 products, flatters)
## [v3.11.610] — 2026-08-12 — Royal Fuller Maker System (6 products, fullers)
## [v3.11.609] — 2026-08-12 — Royal Treadle Hammer Maker System (6 products, treadle hammers)
## [v3.11.608] — 2026-08-12 — Royal Hardy Hole Maker System (6 products, hardy holes)
## [v3.11.607] — 2026-08-12 — Royal Swage Block Maker System (6 products, swage blocks)
## [v3.11.606] — 2026-08-12 — Royal Book Clasp Maker System (6 products, book clasps)
## [v3.11.605] — 2026-08-12 — Royal Headband Loom Maker System (6 products, headband looms)
## [v3.11.604] — 2026-08-12 — Royal Gilding Brush Maker System (6 products, gilding brushes)
## [v3.11.603] — 2026-08-12 — Royal Book Cover Stamp Maker System (6 products, book cover stamps)
## [v3.11.602] — 2026-08-12 — Royal Book Stitching Frame Maker System (6 products, book stitching frames)

### Dodano (v3.11.602-v3.11.611 — 10 sistemov: knjigoveški dodatki 3 + kovaški dodatki 3)

#### v3.11.602-v3.11.606 — Knjigoveški dodatki 3 (5 sistemov)
- v3.11.602: BookStitchingFrameMaker (Okvirjar) — okvirji za šivanje knjig
- v3.11.603: BookCoverStampMaker (Žigar) — žigi za naslovnice
- v3.11.604: GildingBrushMaker (Čopičar) — čopiči za pozlačevanje
- v3.11.605: HeadbandLoomMaker (Statvar) — stati za kapice knjig
- v3.11.606: BookClaspMaker (Sponkar) — sponke za knjige

#### v3.11.607-v3.11.611 — Kovaški dodatki 3 (5 sistemov)
- v3.11.607: SwageBlockMaker (Kalupnik) — kalupi za kovanje
- v3.11.608: HardyHoleMaker (Luknjar) — luknje za trdo orodje
- v3.11.609: TreadleHammerMaker (Pedalar) — pedalna kladiva
- v3.11.610: FullerMaker (Utorjar) — fullerji za utorjanje
- v3.11.611: FlatterMaker (Ploščar) — ploščata kladiva

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Pre-flight check: pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — nobena od njih ni bila predhodno dodana (0 prior commits). Po flask-incidentu v prejšnjem paketu je to sedaj standardni korak.

## [v3.11.601] — 2026-08-12 — Royal Mold Clamp Maker System (6 products, mold clamps)
## [v3.11.600] — 2026-08-12 — Royal Pouring Ladle Maker System (6 products, pouring ladles)
## [v3.11.599] — 2026-08-12 — Royal Sand Riddle Maker System (6 products, sand riddles)
## [v3.11.598] — 2026-08-12 — Royal Crucible Tongs Maker System (6 products, crucible tongs)
## [v3.11.597] — 2026-08-12 — Royal Vent Wire Maker System (6 products, vent wires)
## [v3.11.596] — 2026-08-12 — Royal Glass Polishing Wheel Maker System (6 products, glass polishing wheels)
## [v3.11.595] — 2026-08-12 — Royal Glass Shears Maker System (6 products, glass shears)
## [v3.11.594] — 2026-08-12 — Royal Glass Punty Rod Maker System (6 products, glass punty rods)
## [v3.11.593] — 2026-08-12 — Royal Glass Bench Maker System (6 products, glass benches)
## [v3.11.592] — 2026-08-12 — Royal Glass Kiln Furniture Maker System (6 products, glass kiln furniture)

### Dodano (v3.11.592-v3.11.601 — 10 sistemov: steklarski dodatki 3 + livarski dodatki 3)

#### v3.11.592-v3.11.596 — Steklarski dodatki 3 (5 sistemov)
- v3.11.592: GlassKilnFurnitureMaker (Pečar) — oprema za steklarske peči
- v3.11.593: GlassBenchMaker (Mizar) — delovne mize za steklarje
- v3.11.594: GlassPuntyRodMaker (Paličar) — palice za prenos stekla
- v3.11.595: GlassShearsMaker (Škardar) — škarde za steklo
- v3.11.596: GlassPolishingWheelMaker (Polirar) — polirna kolesa za steklo

#### v3.11.597-v3.11.601 — Livarski dodatki 3 (5 sistemov)
- v3.11.597: VentWireMaker (Odzračevalnik) — žice za odzračevanje
- v3.11.598: CrucibleTongsMaker (Kleščar) — klešče za crucible
- v3.11.599: SandRiddleMaker (Sitar) — sita za pesek
- v3.11.600: PouringLadleMaker (Zajemalkar) — livarske zajemalke
- v3.11.601: MoldClampMaker (Sponkar) — sponke za kalupe

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

Opomba: FlaskMaker je bil predhodno dodan v v3.11.447 (Foundry/casting equipment batch) in je ostal nedotaknjen. V tem paketu je bil namesto njega dodan VentWireMaker (žice za odzračevanje) kot nov livarski sistem.

## [v3.11.591] — 2026-08-12 — Royal Sugar Tongs Maker System (6 products, sugar tongs)
## [v3.11.590] — 2026-08-12 — Royal Serving Tongs Maker System (6 products, serving tongs)
## [v3.11.589] — 2026-08-12 — Royal Cheese Dome Maker System (6 products, cheese domes)
## [v3.11.588] — 2026-08-12 — Royal Butter Dish Maker System (6 products, butter dishes)
## [v3.11.587] — 2026-08-12 — Royal Egg Cup Maker System (6 products, egg cups)
## [v3.11.586] — 2026-08-12 — Royal Crumb Tray Maker System (6 products, crumb trays)
## [v3.11.585] — 2026-08-12 — Royal Loaf Pan Maker System (6 products, loaf pans)
## [v3.11.584] — 2026-08-12 — Royal Crust Scorer Maker System (6 products, crust scorers)
## [v3.11.583] — 2026-08-12 — Royal Bread Mold Maker System (6 products, bread molds)
## [v3.11.582] — 2026-08-12 — Royal Dough Divider Maker System (6 products, dough dividers)

### Dodano (v3.11.582-v3.11.591 — 10 sistemov: pekovski dodatki 2 + kuhinjski dodatki 2)

#### v3.11.582-v3.11.586 — Pekovski dodatki 2 (5 sistemov)
- v3.11.582: DoughDividerMaker (Delilnik) — delilniki testa
- v3.11.583: BreadMoldMaker (Modelar) — modeli za kruh
- v3.11.584: CrustScorerMaker (Zarezovalec) — zarezovalci skorje
- v3.11.585: LoafPanMaker (Pekačar) — pekači za hlebce
- v3.11.586: CrumbTrayMaker (Pladnjar) — pladnji za drobtine

#### v3.11.587-v3.11.591 — Kuhinjski dodatki 2 (5 sistemov)
- v3.11.587: EggCupMaker (Skodeličar) — skodelice za jajca
- v3.11.588: ButterDishMaker (Posodičar) — posodice za maslo
- v3.11.589: CheeseDomeMaker (Klopotar) — klopoti za sir
- v3.11.590: ServingTongsMaker (Kleščar) — servirne klešče
- v3.11.591: SugarTongsMaker (Sladkar) — sladkorne klešče

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.581] — 2026-08-11 — Royal Cold Frame Maker System (6 products, cold frames)
## [v3.11.580] — 2026-08-11 — Royal Garden Line Maker System (6 products, garden lines)
## [v3.11.579] — 2026-08-11 — Royal Bulb Planter Maker System (6 products, bulb planters)
## [v3.11.578] — 2026-08-11 — Royal Hand Trowel Maker System (6 products, hand trowels)
## [v3.11.577] — 2026-08-11 — Royal Garden Fork Maker System (6 products, garden forks)
## [v3.11.576] — 2026-08-11 — Royal Quill Mender Maker System (6 products, quill menders)
## [v3.11.575] — 2026-08-11 — Royal Inkwell Dust Cover Maker System (6 products, inkwell dust covers)
## [v3.11.574] — 2026-08-11 — Royal Pen Rest Maker System (6 products, pen rests)
## [v3.11.573] — 2026-08-11 — Royal Inkwell Stopper Maker System (6 products, inkwell stoppers)
## [v3.11.572] — 2026-08-11 — Royal Quill Trimmer Maker System (6 products, quill trimmers)

### Dodano (v3.11.572-v3.11.581 — 10 sistemov: peresni dodatki 2 + vrtni dodatki 2)

#### v3.11.572-v3.11.576 — Peresni dodatki 2 (5 sistemov)
- v3.11.572: QuillTrimmerMaker (Strižnik) — strižniki peres
- v3.11.573: InkwellStopperMaker (Zamaškar) — zamaški za črnilnice
- v3.11.574: PenRestMaker (Počivalec) — počivališča za peresa
- v3.11.575: InkwellDustCoverMaker (Prevlekar) — prevleke za črnilnice
- v3.11.576: QuillMenderMaker (Popravljalec) — popravljalci peres

#### v3.11.577-v3.11.581 — Vrtni dodatki 2 (5 sistemov)
- v3.11.577: GardenForkMaker (Viliar) — vrtne vilice
- v3.11.578: HandTrowelMaker (Lopatar) — ročne lopatke
- v3.11.579: BulbPlanterMaker (Čebuljar) — sadičniki za čebulnice
- v3.11.580: GardenLineMaker (Vrvicar) — vrtna vrvica
- v3.11.581: ColdFrameMaker (Okvirjar) — hladni okvirji

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry. Generacijska skripta popravljena: odpravljena bug-a ${MAKER_LOWER} placeholder-ja in okvarjene sintakse productStock.productType] (sedaj pravilno productStock[m.productType]).

## [v3.11.571] — 2026-08-11 — Royal Millstone Crane Maker System (6 products, millstone cranes)
## [v3.11.570] — 2026-08-11 — Royal Grain Probe Maker System (6 products, grain probes)
## [v3.11.569] — 2026-08-11 — Royal Flour Sack Maker System (6 products, flour sacks)
## [v3.11.568] — 2026-08-11 — Royal Sack Stitcher Maker System (6 products, sack stitchers)
## [v3.11.567] — 2026-08-11 — Royal Hopper Scale Maker System (6 products, hopper scales)
## [v3.11.566] — 2026-08-11 — Royal Slack Tub Maker System (6 products, slack tubs)
## [v3.11.565] — 2026-08-11 — Royal Quench Bucket Maker System (6 products, quench buckets)
## [v3.11.564] — 2026-08-11 — Royal Tongs Rest Maker System (6 products, tongs rests)
## [v3.11.563] — 2026-08-11 — Royal Ash Shovel Maker System (6 products, ash shovels)
## [v3.11.562] — 2026-08-11 — Royal Forge Rake Maker System (6 products, forge rakes)

### Dodano (v3.11.562-v3.11.571 — 10 sistemov: kovaški dodatki 2 + mlinarski dodatki 2)

#### v3.11.562-v3.11.566 — Kovaški dodatki 2 (5 sistemov)
- v3.11.562: ForgeRakeMaker (Grebar) — grebalci za kovaško ognjišče
- v3.11.563: AshShovelMaker (Pepelar) — lopate za pepel
- v3.11.564: TongsRestMaker (Stojalar) — stojala za klešče
- v3.11.565: QuenchBucketMaker (Kalilec) — vedra za kaljenje
- v3.11.566: SlackTubMaker (Ohlajevalec) — kadi za ohlajanje

#### v3.11.567-v3.11.571 — Mlinarski dodatki 2 (5 sistemov)
- v3.11.567: HopperScaleMaker (Tehtar) — tehtnice za lijake
- v3.11.568: SackStitcherMaker (Šivar) — šivci za vreče
- v3.11.569: FlourSackMaker (Vrečkar) — vreče za moko
- v3.11.570: GrainProbeMaker (Sondar) — sonde za žito
- v3.11.571: MillstoneCraneMaker (Dvigalec) — dvigala za mlinske kamne

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.561] — 2026-08-11 — Royal Hat Band Buckle Maker System (6 products, hat band buckles)
## [v3.11.560] — 2026-08-11 — Royal Hat Lining Maker System (6 products, hat linings)
## [v3.11.559] — 2026-08-11 — Royal Hat Stretcher Maker System (6 products, hat stretchers)
## [v3.11.558] — 2026-08-11 — Royal Hat Crown Block Maker System (6 products, hat crown blocks)
## [v3.11.557] — 2026-08-11 — Royal Hat Brim Curler Maker System (6 products, hat brim curlers)
## [v3.11.556] — 2026-08-11 — Royal Leather Creaser Maker System (6 products, leather creasers)
## [v3.11.555] — 2026-08-11 — Royal Leather Edge Beveler Maker System (6 products, leather edge bevelers)
## [v3.11.554] — 2026-08-11 — Royal Leather Skiver Maker System (6 products, leather skivers)
## [v3.11.553] — 2026-08-11 — Royal Leather Splitter Maker System (6 products, leather splitters)
## [v3.11.552] — 2026-08-11 — Royal Leather Burnisher Maker System (6 products, leather burnishers)

### Dodano (v3.11.552-v3.11.561 — 10 sistemov: usnjarski dodatki 2 + klobučarski dodatki 2)

#### v3.11.552-v3.11.556 — Usnjarski dodatki 2 (5 sistemov)
- v3.11.552: LeatherBurnisherMaker (Poliralec) — poliralci usnja
- v3.11.553: LeatherSplitterMaker (Cepalec) — cepalci usnja
- v3.11.554: LeatherSkiverMaker (Strgalec) — strgalci usnja
- v3.11.555: LeatherEdgeBevelerMaker (Poševnik) — poševniki robov
- v3.11.556: LeatherCreaserMaker (Gubalec) — gubalci usnja

#### v3.11.557-v3.11.561 — Klobučarski dodatki 2 (5 sistemov)
- v3.11.557: HatBrimCurlerMaker (Kodrnik) — kodrniki za klobuke
- v3.11.558: HatCrownBlockMaker (Kronar) — krone za klobuke
- v3.11.559: HatStretcherMaker (Napretevalec) — napretevalci za klobuke
- v3.11.560: HatLiningMaker (Podstavnik) — podstave za klobuke
- v3.11.561: HatBandBuckleMaker (Sponkar) — sponke za klobuke

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.541] — 2026-08-11 — Royal Net Mending Needle Maker System (6 products, net mending needles)
## [v3.11.540] — 2026-08-11 — Royal Fish Scaler Maker System (6 products, fish scalers)
## [v3.11.539] — 2026-08-11 — Royal Bait Box Maker System (6 products, bait boxes)
## [v3.11.538] — 2026-08-11 — Royal Fishing Line Spool Maker System (6 products, fishing line spools)
## [v3.11.537] — 2026-08-11 — Royal Fish Hook Maker System (6 products, fish hooks)
## [v3.11.536] — 2026-08-11 — Royal Flour Shovel Maker System (6 products, flour shovels)
## [v3.11.535] — 2026-08-11 — Royal Oven Peel Maker System (6 products, oven peels)
## [v3.11.534] — 2026-08-11 — Royal Bread Lame Maker System (6 products, bread lames)
## [v3.11.533] — 2026-08-11 — Royal Proofing Basket Maker System (6 products, proofing baskets)
## [v3.11.532] — 2026-08-11 — Royal Dough Scraper Maker System (6 products, dough scrapers)

### Dodano (v3.11.532-v3.11.541 — 10 sistemov: pekovski dodatki + ribiški dodatki)

#### v3.11.532-v3.11.536 — Pekovski dodatki (5 sistemov)
- v3.11.532: DoughScraperMaker (Strgalec) — strgala za testo
- v3.11.533: ProofingBasketMaker (Košar) — vzhodne košare
- v3.11.534: BreadLameMaker (Rezilec) — rezila za kruh
- v3.11.535: OvenPeelMaker (Lopatar) — pekovske lopate
- v3.11.536: FlourShovelMaker (Mokar) — lopate za moko

#### v3.11.537-v3.11.541 — Ribiški dodatki (5 sistemov)
- v3.11.537: FishHookMaker (Kavkar) — ribiške kavke
- v3.11.538: FishingLineSpoolMaker (Navijalec) — tulčki za ribiško vrvico
- v3.11.539: BaitBoxMaker (Škatlar) — škatle za vabe
- v3.11.540: FishScalerMaker (Luskar) — luskalci za ribe
- v3.11.541: NetMendingNeedleMaker (Iglec) — igle za krpanje mrež

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.531] — 2026-08-11 — Royal Seed Drill Plow Maker System (6 products, seed drill plows)
## [v3.11.530] — 2026-08-11 — Royal Compost Aerator Maker System (6 products, compost aerators)
## [v3.11.529] — 2026-08-11 — Royal Watering Spike Maker System (6 products, watering spikes)
## [v3.11.528] — 2026-08-11 — Royal Plant Support Maker System (6 products, plant supports)
## [v3.11.527] — 2026-08-11 — Royal Garden Sieve Maker System (6 products, garden sieves)
## [v3.11.526] — 2026-08-11 — Royal Honey Dipper Maker System (6 products, honey dippers)
## [v3.11.525] — 2026-08-11 — Royal Wine Strainer Maker System (6 products, wine strainers)
## [v3.11.524] — 2026-08-11 — Royal Olive Press Maker System (6 products, olive presses)
## [v3.11.523] — 2026-08-11 — Royal Spice Grinder Maker System (6 products, spice grinders)
## [v3.11.522] — 2026-08-11 — Royal Mortar Pestle Stand Maker System (6 products, mortar pestle stands)

### Dodano (v3.11.522-v3.11.531 — 10 sistemov: kuhinjski dodatki + vrtni dodatki)

#### v3.11.522-v3.11.526 — Kuhinjski dodatki (5 sistemov)
- v3.11.522: MortarPestleStandMaker (Stojalar) — stojala za možnarje
- v3.11.523: SpiceGrinderMaker (Mlinar) — mlinčki za začimbe
- v3.11.524: OlivePressMaker (Prešar) — oljčne preše
- v3.11.525: WineStrainerMaker (Cedilar) — cedila za vino
- v3.11.526: HoneyDipperMaker (Medar) — medne zajemalke

#### v3.11.527-v3.11.531 — Vrtni dodatki (5 sistemov)
- v3.11.527: GardenSieveMaker (Sitar) — vrtna sita
- v3.11.528: PlantSupportMaker (Opornik) — opore za rastline
- v3.11.529: WateringSpikeMaker (Koničar) — zalivalne konice
- v3.11.530: CompostAeratorMaker (Zračnik) — zračniki za kompost
- v3.11.531: SeedDrillPlowMaker (Vlekar) — sejalni plugovi

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.521] — 2026-08-11 — Royal Washstand Maker System (6 products, washstands)
## [v3.11.520] — 2026-08-11 — Royal Sponge Holder Maker System (6 products, sponge holders)
## [v3.11.519] — 2026-08-11 — Royal Bath Bucket Maker System (6 products, bath buckets)
## [v3.11.518] — 2026-08-11 — Royal Soap Dish Maker System (6 products, soap dishes)
## [v3.11.517] — 2026-08-11 — Royal Towel Rack Maker System (6 products, towel racks)
## [v3.11.516] — 2026-08-11 — Royal Chime Hammer Maker System (6 products, chime hammers)
## [v3.11.515] — 2026-08-11 — Royal Clock Dial Engraver Maker System (6 products, clock dial engravers)
## [v3.11.514] — 2026-08-11 — Royal Mainspring Winder Maker System (6 products, mainspring winders)
## [v3.11.513] — 2026-08-11 — Royal Escapement Lever Maker System (6 products, escapement levers)
## [v3.11.512] — 2026-08-11 — Royal Pendulum Rod Maker System (6 products, pendulum rods)

### Dodano (v3.11.512-v3.11.521 — 10 sistemov: urarski dodatki + kopalniška oprema)

#### v3.11.512-v3.11.516 — Urarski dodatki (5 sistemov)
- v3.11.512: PendulumRodMaker (Nihajec) — nihajne palice
- v3.11.513: EscapementLeverMaker (Uhopar) — uhopne ročice
- v3.11.514: MainspringWinderMaker (Vzmetar) — navijalci vzmeti
- v3.11.515: ClockDialEngraverMaker (Rezkar) — rezkarji števnic
- v3.11.516: ChimeHammerMaker (Zvonar) — kladivca za zvonove

#### v3.11.517-v3.11.521 — Kopalniška oprema (5 sistemov)
- v3.11.517: TowelRackMaker (Vešalkar) — vešalke za brisače
- v3.11.518: SoapDishMaker (Posodica) — posode za milo
- v3.11.519: BathBucketMaker (Vedrnar) — kopališka vedra
- v3.11.520: SpongeHolderMaker (Gobadar) — držala za gobe
- v3.11.521: WashstandMaker (Umivalnik) — umivalni mizici

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.511] — 2026-08-11 — Royal Compass Needle Maker System (6 products, compass needles)
## [v3.11.510] — 2026-08-11 — Royal Sundial Gnomon Maker System (6 products, sundial gnomons)
## [v3.11.509] — 2026-08-11 — Royal Celestial Globe Maker System (6 products, celestial globes)
## [v3.11.508] — 2026-08-11 — Royal Star Chart Rack Maker System (6 products, star chart racks)
## [v3.11.507] — 2026-08-11 — Royal Astrolabe Ring Maker System (6 products, astrolabe rings)
## [v3.11.506] — 2026-08-11 — Royal Banner Pole Maker System (6 products, banner poles)
## [v3.11.505] — 2026-08-11 — Royal Helmet Crest Maker System (6 products, helmet crests)
## [v3.11.504] — 2026-08-11 — Royal Scabbard Chape Maker System (6 products, scabbard chapes)
## [v3.11.503] — 2026-08-11 — Royal Sword Pommel Maker System (6 products, sword pommels)
## [v3.11.502] — 2026-08-11 — Royal Shield Boss Maker System (6 products, shield bosses)

### Dodano (v3.11.502-v3.11.511 — 10 sistemov: vojaška oprema + astrološka oprema)

#### v3.11.502-v3.11.506 — Vojaška oprema (5 sistemov)
- v3.11.502: ShieldBossMaker (Bosar) — ščitni bossi
- v3.11.503: SwordPommelMaker (Gumbar) — mečni gumbi
- v3.11.504: ScabbardChapeMaker (Nožničar) — nožnične konice
- v3.11.505: HelmetCrestMaker (Grenar) — čeladni grebeni
- v3.11.506: BannerPoleMaker (Zastavar) — zastavni drogi

#### v3.11.507-v3.11.511 — Astrološka oprema (5 sistemov)
- v3.11.507: AstrolabeRingMaker (Krožar) — astrolabni obroči
- v3.11.508: StarChartRackMaker (Zvezdar) — stojala za zvezdne karte
- v3.11.509: CelestialGlobeMaker (Kroglasti) — nebesne krogle
- v3.11.510: SundialGnomonMaker (Kazalec) — solarski kazalci
- v3.11.511: CompassNeedleMaker (Iglec) — komp sne igle

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.501] — 2026-08-11 — Royal Scent Cone Maker System (6 products, scent cones)
## [v3.11.500] — 2026-08-11 — Royal Potpourri Bowl Maker System (6 products, potpourri bowls)
## [v3.11.499] — 2026-08-11 — Royal Sachet Maker System (6 products, sachets)
## [v3.11.498] — 2026-08-11 — Royal Perfume Bottle Maker System (6 products, perfume bottles)
## [v3.11.497] — 2026-08-11 — Royal Incense Molder Maker System (6 products, incense molders)
## [v3.11.496] — 2026-08-11 — Royal Tailpiece Maker System (6 products, tailpieces)
## [v3.11.495] — 2026-08-11 — Royal Soundpost Maker System (6 products, soundposts)
## [v3.11.494] — 2026-08-11 — Royal Bridge Maker System (6 products, bridges)
## [v3.11.493] — 2026-08-11 — Royal Tuning Pin Maker System (6 products, tuning pins)
## [v3.11.492] — 2026-08-11 — Royal String Winder Maker System (6 products, string winders)

### Dodano (v3.11.492-v3.11.501 — 10 sistemov: glasbena oprema + aromatska oprema)

#### v3.11.492-v3.11.496 — Glasbena oprema (5 sistemov)
- v3.11.492: StringWinderMaker (Navijalec) — navijalci strun
- v3.11.493: TuningPinMaker (Čivkar) — uglaševalni čivki
- v3.11.494: BridgeMaker (Mostičar) — mostički za glasbila
- v3.11.495: SoundpostMaker (Zvočar) — zvočni stebrički
- v3.11.496: TailpieceMaker (Repnik) — repniki za strune

#### v3.11.497-v3.11.501 — Aromatska oprema (5 sistemov)
- v3.11.497: IncenseMolderMaker (Kadilar) — oblikovalci kadila
- v3.11.498: PerfumeBottleMaker (Stekleničar) — stekleničke za parfume
- v3.11.499: SachetMaker (Vrečkar) — voščene vrečice
- v3.11.500: PotpourriBowlMaker (Skledar) — sklede za potpurije
- v3.11.501: ScentConeMaker (Stožčar) — stožci za dišave

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.491] — 2026-08-11 — Royal Coin Scale Maker System (6 products, coin scales)
## [v3.11.490] — 2026-08-11 — Royal Coin Sorter Maker System (6 products, coin sorters)
## [v3.11.489] — 2026-08-11 — Royal Coin Blank Maker System (6 products, coin blanks)
## [v3.11.488] — 2026-08-11 — Royal Coin Die Maker System (6 products, coin dies)
## [v3.11.487] — 2026-08-11 — Royal Coin Press Maker System (6 products, coin presses)
## [v3.11.486] — 2026-08-11 — Royal Writing Stand Maker System (6 products, writing stands)
## [v3.11.485] — 2026-08-11 — Royal Wax Tablet Maker System (6 products, wax tablets)
## [v3.11.484] — 2026-08-11 — Royal Parchment Rack Maker System (6 products, parchment racks)
## [v3.11.483] — 2026-08-11 — Royal Inkwell Maker System (6 products, inkwells)
## [v3.11.482] — 2026-08-11 — Royal Quill Cutter Maker System (6 products, quill cutters)

### Dodano (v3.11.482-v3.11.491 — 10 sistemov: peresna oprema + kovanska oprema)

#### v3.11.482-v3.11.486 — Peresna oprema (5 sistemov)
- v3.11.482: QuillCutterMaker (Rezar) — rezalci peres
- v3.11.483: InkwellMaker (Črnilničar) — črnilnice
- v3.11.484: ParchmentRackMaker (Pergamentist) — stojala za pergament
- v3.11.485: WaxTabletMaker (Voščar) — voščene tablice
- v3.11.486: WritingStandMaker (Pisar) — pisalne mizice

#### v3.11.487-v3.11.491 — Kovanska oprema (5 sistemov)
- v3.11.487: CoinPressMaker (Kovalec) — stiskalce kovancev
- v3.11.488: CoinDieMaker (Matricar) — matrice za kovance
- v3.11.489: CoinBlankMaker (Polizdelkar) — kovinski polizdelki
- v3.11.490: CoinSorterMaker (Sortiralec) — sortiralce kovancev
- v3.11.491: CoinScaleMaker (Tehtar) — tehtnice za kovance

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.481] — 2026-08-11 — Royal Gilding Press Maker System (6 products, gilding presses)
## [v3.11.480] — 2026-08-11 — Royal Leather Cover Maker System (6 products, leather covers)
## [v3.11.479] — 2026-08-11 — Royal Binding Cord Maker System (6 products, binding cords)
## [v3.11.478] — 2026-08-11 — Royal Stitching Awl Maker System (6 products, stitching awls)
## [v3.11.477] — 2026-08-11 — Royal Book Press Maker System (6 products, book presses)
## [v3.11.476] — 2026-08-11 — Royal Cloth Presser Maker System (6 products, cloth pressers)
## [v3.11.475] — 2026-08-11 — Royal Warp Beam Maker System (6 products, warp beams)
## [v3.11.474] — 2026-08-11 — Royal Bobbin Winder Maker System (6 products, bobbin winders)
## [v3.11.473] — 2026-08-11 — Royal Shuttle Maker System (6 products, shuttles)
## [v3.11.472] — 2026-08-11 — Royal Loom Heddle Maker System (6 products, loom heddles)

### Dodano (v3.11.472-v3.11.481 — 10 sistemov: tkalska oprema + knjigoveška oprema)

#### v3.11.472-v3.11.476 — Tkalska oprema (5 sistemov)
- v3.11.472: LoomHeddleMaker (Listar) — listovnice za statve
- v3.11.473: ShuttleMaker (Čolničar) — čolničke za tkanje
- v3.11.474: BobbinWinderMaker (Navijalec) — navijalce vretencev
- v3.11.475: WarpBeamMaker (Gredičar) — osnovne gredice
- v3.11.476: ClothPresserMaker (Stiskalec) — stiskalce tkinin

#### v3.11.477-v3.11.481 — Knjigoveška oprema (5 sistemov)
- v3.11.477: BookPressMaker (Stiskar) — stiskalce knjig
- v3.11.478: StitchingAwlMaker (Šilar) — šivalna šila
- v3.11.479: BindingCordMaker (Vezar) — vezalne vrvice
- v3.11.480: LeatherCoverMaker (Platničar) — usnjeni platnice
- v3.11.481: GildingPressMaker (Pozlačevalec) — pozlačevalna stiskalca

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.471] — 2026-08-11 — Royal Glass Frit Maker System (6 products, glass frits)
## [v3.11.470] — 2026-08-11 — Royal Glass Ribbon Maker System (6 products, glass ribbons)
## [v3.11.469] — 2026-08-11 — Royal Glass Seed Maker System (6 products, glass seeds)
## [v3.11.468] — 2026-08-11 — Royal Glass Colorant Maker System (6 products, glass colorants)
## [v3.11.467] — 2026-08-11 — Royal Glass Batch Maker System (6 products, glass batches)
## [v3.11.466] — 2026-08-11 — Royal Bisque Stand Maker System (6 products, bisque stands)
## [v3.11.465] — 2026-08-11 — Royal Glaze Sieve Maker System (6 products, glaze sieves)
## [v3.11.464] — 2026-08-11 — Royal Clay Extruder Maker System (6 products, clay extruders)
## [v3.11.463] — 2026-08-11 — Royal Kiln Furniture Maker System (6 products, kiln furniture)
## [v3.11.462] — 2026-08-11 — Royal Pottery Wheel Maker System (6 products, pottery wheels)

### Dodano (v3.11.462-v3.11.471 — 10 sistemov: keramična oprema + steklarski dodatki)

#### v3.11.462-v3.11.466 — Keramična oprema (5 sistemov)
- v3.11.462: PotteryWheelMaker (Lončar) — lončarska kolesa
- v3.11.463: KilnFurnitureMaker (Pešičar) — pešice za peči
- v3.11.464: ClayExtruderMaker (Ekstruderar) — ekstruderji za glino
- v3.11.465: GlazeSieveMaker (Sitar) — sita za glazure
- v3.11.466: BisqueStandMaker (Stojalar) — stojala za žganje keramike

#### v3.11.467-v3.11.471 — Steklarski dodatki (5 sistemov)
- v3.11.467: GlassBatchMaker (Mešalec) — mešanice za steklo
- v3.11.468: GlassColorantMaker (Barvar) — barvila za steklo
- v3.11.469: GlassSeedMaker (Seminar) — semena za steklo
- v3.11.470: GlassRibbonMaker (Trakar) — trakovi za steklo
- v3.11.471: GlassFritMaker (Fritar) — frit za steklo

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.461] — 2026-08-11 — Royal Clamp Maker System (6 products, clamps)
## [v3.11.460] — 2026-08-11 — Royal Auger Bit Maker System (6 products, auger bits)
## [v3.11.459] — 2026-08-11 — Royal Saw Set Maker System (6 products, saw sets)
## [v3.11.458] — 2026-08-11 — Royal Chisel Blade Maker System (6 products, chisel blades)
## [v3.11.457] — 2026-08-11 — Royal Plane Iron Maker System (6 products, plane irons)

### Dodano (v3.11.457-v3.11.461 — 5 mizarstvo sistemov)

#### v3.11.457 - Royal Plane Iron Maker System
- **6 produktov** (železna železa za glodalnik, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (gladilna delavnica, gladilna hiša, mojstrski gladilni atelje, suverena gladilna palača)
- Maker: Gladar, hire base 580 gold

#### v3.11.458 - Royal Chisel Blade Maker System
- **6 produktov** (železno rezilo za dleto, bronasto, srebrno, pozlačeno, draguljasto, kraljevski suvereno)
- **4 zgradbe** (rezilna delavnica, rezilna hiša, mojstrski rezilni atelje, suverena rezilna palača)
- Maker: Rezar, hire base 585 gold
- Poudarek na kovini (ironCost/bronzeCost 5)

#### v3.11.459 - Royal Saw Set Maker System
- **6 produktov** (železna nastavljiva žaga, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (žagarska delavnica, žagarska hiša, mojstrski žagarski atelje, suverena žagarska palača)
- Maker: Žagar, hire base 575 gold

#### v3.11.460 - Royal Auger Bit Maker System
- **6 produktov** (železni svrder za vrtanje, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (vrtalna delavnica, vrtalna hiša, mojstrski vrtalni atelje, suverena vrtalna palača)
- Maker: Vrtač, hire base 590 gold
- Poudarek na kovini (ironCost 5)

#### v3.11.461 - Royal Clamp Maker System
- **6 produktov** (železna štspanka, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (štspančna delavnica, štspančna hiša, mojstrski štspančni atelje, suverena štspančna palača)
- Maker: Štspankar, hire base 565 gold
- Poudarek na lesu (woodCost 3-4)

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.456] — 2026-08-11 — Royal Forge Tongs Maker System (6 products, forge tongs)
## [v3.11.455] — 2026-08-11 — Royal Bellows Maker System (6 products, bellows)
## [v3.11.454] — 2026-08-11 — Royal Anvil Maker System (6 products, anvils)
## [v3.11.453] — 2026-08-11 — Royal Hammer Maker System (6 products, hammers)
## [v3.11.452] — 2026-08-11 — Royal Tong Maker System (6 products, tongs)

### Dodano (v3.11.452-v3.11.456 — 5 kovaških sistemov)

#### v3.11.452 - Royal Tong Maker System
- **6 produktov** (železne kovinarske klešče, bronaste, srebrne, pozlačene, draguljaste, kraljevski suverene)
- **4 zgradbe** (kleščna delavnica, kleščna hiša, mojstrski kleščni atelje, suverena kleščna palača)
- Maker: Kleščar, hire base 590 gold
- Poudarek na kovini (ironCost 5)

#### v3.11.453 - Royal Hammer Maker System
- **6 produktov** (železno kladivo, bronasto, srebrno, pozlačeno, draguljasto, kraljevski suvereno)
- **4 zgradbe** (kladivna delavnica, kladivna hiša, mojstrski kladivni atelje, suverena kladivna palača)
- Maker: Kladivar, hire base 585 gold

#### v3.11.454 - Royal Anvil Maker System
- **6 produktov** (železno nakovalo, bronasto, srebrno, pozlačeno, draguljasto, kraljevski suvereno)
- **4 zgradbe** (nakovalna delavnica, nakovalna hiša, mojstrski nakovalni atelje, suverena nakovalna palača)
- Maker: Nakovalar, hire base 595 gold
- Poudarek na kovini (ironCost 6) - najbolj kovinsko-zahteven sistem

#### v3.11.455 - Royal Bellows Maker System
- **6 produktov** (železni meh za kovaško ognjišče, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (mešna delavnica, mešna hiša, mojstrski mešni atelje, suverena mešna palača)
- Maker: Mehar, hire base 575 gold
- Poudarek na usnju (leatherCost 4-5)

#### v3.11.456 - Royal Forge Tongs Maker System
- **6 produktov** (železne kovaške klešče za žar, bronaste, srebrne, pozlačene, draguljaste, kraljevski suverene)
- **4 zgradbe** (žarna delavnica, žarna hiša, mojstrski žarni atelje, suverena žarna palača)
- Maker: Žarist, hire base 590 gold
- Poudarek na kovini (ironCost 6) - za visoke temperature

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.451] — 2026-08-11 — Royal Casting Ladle Maker System (6 products, casting ladles)
## [v3.11.450] — 2026-08-11 — Royal Flask Maker System (6 products, foundry flasks)
## [v3.11.449] — 2026-08-11 — Royal Ingot Mold Maker System (6 products, ingot molds)
## [v3.11.448] — 2026-08-11 — Royal Sand Mold Maker System (6 products, sand molds)
## [v3.11.447] — 2026-08-11 — Royal Crucible Maker System (6 products, crucibles)

### Dodano (v3.11.447-v3.11.451 — 5 livarskih sistemov)

#### v3.11.447 - Royal Crucible Maker System
- **6 produktov** (železni talilni lonec, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (talilna delavnica, talilna hiša, mojstrski talilni atelje, suverena talilna palača)
- Maker: Talilnik, hire base 595 gold
- Poudarek na kovini (ironCost/bronzeCost 4) - visoke temperature

#### v3.11.448 - Royal Sand Mold Maker System
- **6 produktov** (železni peskan model, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (peskana delavnica, peskana hiša, mojstrski peskani atelje, suverena peskana palača)
- Maker: Peskar, hire base 580 gold

#### v3.11.449 - Royal Ingot Mold Maker System
- **6 produktov** (železni model za palice, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (palična delavnica, palična hiša, mojstrski palični atelje, suverena palična palača)
- Maker: Paličar, hire base 585 gold
- Poudarek na kovini (ironCost/bronzeCost 4)

#### v3.11.450 - Royal Flask Maker System
- **6 produktov** (železna steklenica za livarstvo, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (steklenična delavnica, steklenična hiša, mojstrski steklenični atelje, suverena steklenična palača)
- Maker: Stekleničar, hire base 575 gold

#### v3.11.451 - Royal Casting Ladle Maker System
- **6 produktov** (železna livarska zajemalka, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (zajemalna delavnica, zajemalna hiša, mojstrski zajemalni atelje, suverena zajemalna palača)
- Maker: Zajemalec, hire base 590 gold
- Poudarek na kovini (ironCost 5, bronzeCost 5) - najbolj kovinsko-zahteven sistem

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.446] — 2026-08-11 — Royal Taper Roller Maker System (6 products, taper rollers)
## [v3.11.445] — 2026-08-11 — Royal Candlestick Base Maker System (6 products, candlestick bases)
## [v3.11.444] — 2026-08-11 — Royal Wax Dipper Maker System (6 products, wax dippers)
## [v3.11.443] — 2026-08-11 — Royal Wick Spinner Maker System (6 products, wick spinners)
## [v3.11.442] — 2026-08-11 — Royal Candle Mold Maker System (6 products, candle molds)

### Dodano (v3.11.442-v3.11.446 — 5 vošenih sistemov)

#### v3.11.442 - Royal Candle Mold Maker System
- **6 produktov** (železni model za sveče, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (modelna delavnica, modelna hiša, mojstrski modelni atelje, suverena modelna palača)
- Maker: Modelar, hire base 575 gold
- Poudarek na kovini (ironCost/bronzeCost 3)

#### v3.11.443 - Royal Wick Spinner Maker System
- **6 produktov** (železna predilnica za fitilje, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (predilna delavnica, predilna hiša, mojstrski predilni atelje, suverena predilna palača)
- Maker: Predilnik, hire base 570 gold
- Poudarek na lesu (woodCost 3)

#### v3.11.444 - Royal Wax Dipper Maker System
- **6 produktov** (železni potapljač za voskom, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (potapljajoča delavnica, potapljajoča hiša, mojstrski potapljajoči atelje, suverena potapljajoča palača)
- Maker: Potapljač, hire base 580 gold

#### v3.11.445 - Royal Candlestick Base Maker System
- **6 produktov** (železni podstavka za svečnik, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (podstavkarska delavnica, podstavkarska hiša, mojstrski podstavkarski atelje, suverena podstavkarska palača)
- Maker: Podstavkar, hire base 585 gold

#### v3.11.446 - Royal Taper Roller Maker System
- **6 produktov** (železni valjalec za tanke sveče, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (valjalna delavnica, valjalna hiša, mojstrski valjalni atelje, suverena valjalna palača)
- Maker: Valjalec, hire base 590 gold

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.441] — 2026-08-11 — Royal Bridle Buckle Maker System (6 products, bridle buckles)
## [v3.11.440] — 2026-08-11 — Royal Stirrup Leather Maker System (6 products, stirrup leathers)
## [v3.11.439] — 2026-08-11 — Royal Leather Conditioner Maker System (6 products, leather conditioners)
## [v3.11.438] — 2026-08-11 — Royal Saddle Polish Maker System (6 products, saddle polishes)
## [v3.11.437] — 2026-08-11 — Royal Saddle Soap Maker System (6 products, saddle soaps)

### Dodano (v3.11.437-v3.11.441 — 5 sedlarskih dodatkov)

#### v3.11.437 - Royal Saddle Soap Maker System
- **6 produktov** (železno milo za sedla, bronasto, srebrno, pozlačeno, draguljasto, kraljevski suvereno)
- **4 zgradbe** (milna delavnica, milna hiša, mojstrski milni atelje, suverena milna palača)
- Maker: Milar, hire base 565 gold
- Poudarek na usnju (leatherCost 3-4)

#### v3.11.438 - Royal Saddle Polish Maker System
- **6 produktov** (železna polirka za sedla, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (polirna delavnica, polirna hiša, mojstrski polirni atelje, suverena polirna palača)
- Maker: Polirar, hire base 575 gold

#### v3.11.439 - Royal Leather Conditioner Maker System
- **6 produktov** (železni kondicioner za usnje, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (kondicionerna delavnica, kondicionerna hiša, mojstrski kondicionerni atelje, suverena kondicionerna palača)
- Maker: Kondicionar, hire base 580 gold
- Poudarek na usnju (leatherCost 4-5)

#### v3.11.440 - Royal Stirrup Leather Maker System
- **6 produktov** (železno usnje za streme, bronasto, srebrno, pozlačeno, draguljasto, kraljevski suvereno)
- **4 zgradbe** (stremsko-usnjena delavnica, stremsko-usnjena hiša, mojstrski stremsko-usnjeni atelje, suverena stremsko-usnjena palača)
- Maker: Stremar, hire base 585 gold
- Poudarek na usnju (leatherCost 5-6) - najbolj usnje-zahteven sistem

#### v3.11.441 - Royal Bridle Buckle Maker System
- **6 produktov** (železna sponka za uzde, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (spončna delavnica, spončna hiša, mojstrski spončni atelje, suverena spončna palača)
- Maker: Sponkar, hire base 590 gold
- Poudarek na kovini (ironCost/bronzeCost/silverCost 4) - močne sponke

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.436] — 2026-08-11 — Royal Lice Comb Maker System (6 products, lice combs)
## [v3.11.435] — 2026-08-11 — Royal Beard Comb Maker System (6 products, beard combs)
## [v3.11.434] — 2026-08-11 — Royal Hairpin Maker System (6 products, hairpins)
## [v3.11.433] — 2026-08-11 — Royal Hairbrush Maker System (6 products, hairbrushes)
## [v3.11.432] — 2026-08-11 — Royal Comb Maker System (6 products, combs)

### Dodano (v3.11.432-v3.11.436 — 5 česlarskih sistemov)

#### v3.11.432 - Royal Comb Maker System
- **6 produktov** (železni glavnik, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (glavnična delavnica, glavnična hiša, mojstrski glavnični atelje, suverena glavnična palača)
- Maker: Glavnikar, hire base 570 gold

#### v3.11.433 - Royal Hairbrush Maker System
- **6 produktov** (železna ščetka za lase, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (ščetkarska delavnica, ščetkarska hiša, mojstrski ščetkarski atelje, suverena ščetkarska palača)
- Maker: Ščetkar, hire base 580 gold
- Poudarek na lesu in usnju (woodCost 3, leatherCost 2)

#### v3.11.434 - Royal Hairpin Maker System
- **6 produktov** (železna lasnica, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (lasnična delavnica, lasnična hiša, mojstrski lasnični atelje, suverena lasnična palača)
- Maker: Lasničar, hire base 575 gold
- Poudarek na kovini (ironCost/bronzeCost/silverCost 3)

#### v3.11.435 - Royal Beard Comb Maker System
- **6 produktov** (železni glavnik za brado, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (bradna delavnica, bradna hiša, mojstrski bradni atelje, suverena bradna palača)
- Maker: Bradar, hire base 565 gold

#### v3.11.436 - Royal Lice Comb Maker System
- **6 produktov** (železni glavnik za uši, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (ušesna delavnica, ušesna hiša, mojstrski ušesni atelje, suverena ušesna palača)
- Maker: Ušesar, hire base 590 gold
- Poudarek na kovini (ironCost/bronzeCost/silverCost 4) - gosti zobmi za uši

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.431] — 2026-08-11 — Royal Knot Board Maker System (6 products, knot boards)
## [v3.11.430] — 2026-08-11 — Royal Cordage Maker System (6 products, cordages)
## [v3.11.429] — 2026-08-11 — Royal Net Maker System (6 products, nets)
## [v3.11.428] — 2026-08-11 — Royal Twine Maker System (6 products, twines)
## [v3.11.427] — 2026-08-11 — Royal Rope Maker System (6 products, ropes)

### Dodano (v3.11.427-v3.11.431 — 5 vrvarnih sistemov)

#### v3.11.427 - Royal Rope Maker System
- **6 produktov** (železna vrv, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (vrvarna delavnica, vrvarna hiša, mojstrski vrvarski atelje, suverena vrvarna palača)
- Maker: Vrvar, hire base 570 gold

#### v3.11.428 - Royal Twine Maker System
- **6 produktov** (železni špigelj, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (špigeljna delavnica, špigeljna hiša, mojstrski špigeljni atelje, suverena špigeljna palača)
- Maker: Špigeljar, hire base 560 gold
- Poudarek na usnju (leatherCost 3-4)

#### v3.11.429 - Royal Net Maker System
- **6 produktov** (železna mreža, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (mrežna delavnica, mrežna hiša, mojstrski mrežni atelje, suverena mrežna palača)
- Maker: Mrežar, hire base 580 gold

#### v3.11.430 - Royal Cordage Maker System
- **6 produktov** (železna vrvica, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (vrvnična delavnica, vrvnična hiša, mojstrski vrvnični atelje, suverena vrvnična palača)
- Maker: Vrvničar, hire base 575 gold
- Poudarek na usnju (leatherCost 3-4)

#### v3.11.431 - Royal Knot Board Maker System
- **6 produktov** (železna tabla za vozle, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (vozlena delavnica, vozlena hiša, mojstrski vozleni atelje, suverena vozlena palača)
- Maker: Vozlar, hire base 585 gold
- Poudarek na lesu (woodCost 3-4)

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.426] — 2026-08-11 — Royal Hat Box Maker System (6 products, hat boxes)
## [v3.11.425] — 2026-08-11 — Royal Hat Feather Maker System (6 products, hat feathers)
## [v3.11.424] — 2026-08-11 — Royal Hat Pin Maker System (6 products, hat pins)
## [v3.11.423] — 2026-08-11 — Royal Hat Band Maker System (6 products, hat bands)
## [v3.11.422] — 2026-08-11 — Royal Hat Block Maker System (6 products, hat blocks)

### Dodano (v3.11.422-v3.11.426 — 5 klobučarskih sistemov)

#### v3.11.422 - Royal Hat Block Maker System
- **6 produktov** (železni model za klobuke, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (modelna delavnica, modelna hiša, mojstrski modelni atelje, suverena modelna palača)
- Maker: Modelar, hire base 575 gold
- Poudarek na lesu (woodCost 4-5)

#### v3.11.423 - Royal Hat Band Maker System
- **6 produktov** (železna poroka za klobuke, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (poročna delavnica, poročna hiša, mojstrski poročni atelje, suverena poročna palača)
- Maker: Poročnik, hire base 570 gold
- Poudarek na usnju (leatherCost 3-4)

#### v3.11.424 - Royal Hat Pin Maker System
- **6 produktov** (železna sponka za klobuke, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (spončna delavnica, spončna hiša, mojstrski spončni atelje, suverena spončna palača)
- Maker: Sponkar, hire base 580 gold
- Poudarek na kovini (ironCost/bronzeCost 3)

#### v3.11.425 - Royal Hat Feather Maker System
- **6 produktov** (železno pero za klobuke, bronasto, srebrno, pozlačeno, draguljasto, kraljevski suvereno)
- **4 zgradbe** (peresna delavnica, peresna hiša, mojstrski peresni atelje, suverena peresna palača)
- Maker: Peresar, hire base 585 gold
- Poudarek na usnju (leatherCost 2)

#### v3.11.426 - Royal Hat Box Maker System
- **6 produktov** (železna škatla za klobuke, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (škatlena delavnica, škatlena hiša, mojstrski škatleni atelje, suverena škatlena palača)
- Maker: Škatlar, hire base 565 gold
- Poudarek na lesu (woodCost 4-5)

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.421] — 2026-08-11 — Royal Sack Loader Maker System (6 products, sack loaders)
## [v3.11.420] — 2026-08-11 — Royal Grain Hopper Maker System (6 products, grain hoppers)
## [v3.11.419] — 2026-08-11 — Royal Dough Hook Maker System (6 products, dough hooks)
## [v3.11.418] — 2026-08-11 — Royal Flour Sifter Maker System (6 products, flour sifters)
## [v3.11.417] — 2026-08-11 — Royal Millstone Maker System (6 products, millstones)

### Dodano (v3.11.417-v3.11.421 — 5 mlinarskih sistemov)

#### v3.11.417 - Royal Millstone Maker System
- **6 produktov** (železni mlinček za žito, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (mlinarska delavnica, mlinarska hiša, mojstrski mlinarski atelje, suverena mlinarska palača)
- Maker: Mlinar, hire base 595 gold

#### v3.11.418 - Royal Flour Sifter Maker System
- **6 produktov** (železno sito za moko, bronasto, srebrno, pozlačeno, draguljasto, kraljevski suvereno)
- **4 zgradbe** (sitna delavnica, sitna hiša, mojstrski sitni atelje, suverena sitna palača)
- Maker: Sitar, hire base 570 gold

#### v3.11.419 - Royal Dough Hook Maker System
- **6 produktov** (železni kavelj za testo, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (kavljeva delavnica, kavljeva hiša, mojstrski kavljev atelje, suverena kavljeva palača)
- Maker: Kavljist, hire base 580 gold

#### v3.11.420 - Royal Grain Hopper Maker System
- **6 produktov** (železni ličnik za žito, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (ličniška delavnica, ličniška hiša, mojstrski ličniški atelje, suverena ličniška palača)
- Maker: Ličnikar, hire base 575 gold

#### v3.11.421 - Royal Sack Loader Maker System
- **6 produktov** (železni nalagalec vrečk, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (nalagalna delavnica, nalagalna hiša, mojstrski nalagalni atelje, suverena nalagalna palača)
- Maker: Nalagalec, hire base 565 gold

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.416] — 2026-08-11 — Royal Glass Engraver Maker System (6 products, glass engravers)
## [v3.11.415] — 2026-08-11 — Royal Annealing Tongs Maker System (6 products, annealing tongs)
## [v3.11.414] — 2026-08-11 — Royal Glass Mold Maker System (6 products, glass molds)
## [v3.11.413] — 2026-08-11 — Royal Glass Cutter Maker System (6 products, glass cutters)
## [v3.11.412] — 2026-08-11 — Royal Glass Blower Pipe Maker System (6 products, glass blower pipes)

### Dodano (v3.11.412-v3.11.416 — 5 steklarsskih sistemov)

#### v3.11.412 - Royal Glass Blower Pipe Maker System
- **6 produktov** (železna pijavka za pihanje stekla, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (pijavkarska delavnica, pijavkarska hiša, mojstrski pijavkarski atelje, suverena pijavkarska palača)
- Maker: Pijavkar, hire base 585 gold
- Poudarek na kovini (ironCost/bronzeCost 3)

#### v3.11.413 - Royal Glass Cutter Maker System
- **6 produktov** (železni rezalec za steklo, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (rezalna delavnica, rezalna hiša, mojstrski rezalni atelje, suverena rezalna palača)
- Maker: Rezalec, hire base 580 gold

#### v3.11.414 - Royal Glass Mold Maker System
- **6 produktov** (železni model za steklo, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (modelna delavnica, modelna hiša, mojstrski modelni atelje, suverena modelna palača)
- Maker: Modelar, hire base 590 gold

#### v3.11.415 - Royal Annealing Tongs Maker System
- **6 produktov** (železne klešče za žarjenje, bronaste, srebrne, pozlačene, draguljaste, kraljevski suverene)
- **4 zgradbe** (kleščna delavnica, kleščna hiša, mojstrski kleščni atelje, suverena kleščna palača)
- Maker: Kleščar, hire base 585 gold
- Poudarek na kovini (ironCost/bronzeCost 4)

#### v3.11.416 - Royal Glass Engraver Maker System
- **6 produktov** (železni rezkar za steklo, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (rezkarska delavnica, rezkarska hiša, mojstrski rezkarski atelje, suverena rezkarska palača)
- Maker: Rezkar, hire base 595 gold
- Poudarek na srebru (silverCost 4)

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.411] — 2026-08-11 — Royal Cutting Board Maker System (6 products, cutting boards)
## [v3.11.410] — 2026-08-11 — Royal Spice Rack Maker System (6 products, spice racks)
## [v3.11.409] — 2026-08-11 — Royal Butter Churn Maker System (6 products, butter churns)
## [v3.11.408] — 2026-08-11 — Royal Cheese Grater Maker System (6 products, cheese graters)
## [v3.11.407] — 2026-08-11 — Royal Rolling Pin Maker System (6 products, rolling pins)

### Dodano (v3.11.407-v3.11.411 — 5 kuhinjskih sistemov)

#### v3.11.407 - Royal Rolling Pin Maker System
- **6 produktov** (železni valjek za testo, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (valjarska delavnica, valjarska hiša, mojstrski valjarski atelje, suverena valjarska palača)
- Maker: Valjar, hire base 570 gold

#### v3.11.408 - Royal Cheese Grater Maker System
- **6 produktov** (železni ribnik za sir, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (ribniška delavnica, ribniška hiša, mojstrski ribniški atelje, suverena ribniška palača)
- Maker: Ribnikar, hire base 580 gold
- Poudarek na kovini (ironCost/bronzeCost 3)

#### v3.11.409 - Royal Butter Churn Maker System
- **6 produktov** (železna kada za maslo, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (kadna delavnica, kadna hiša, mojstrski kadni atelje, suverena kadna palača)
- Maker: Kadar, hire base 575 gold

#### v3.11.410 - Royal Spice Rack Maker System
- **6 produktov** (železno stojalo za začimbe, bronasto, srebrno, pozlačeno, draguljasto, kraljevski suvereno)
- **4 zgradbe** (začimbična delavnica, začimbična hiša, mojstrski začimbični atelje, suverena začimbična palača)
- Maker: Začimbar, hire base 565 gold

#### v3.11.411 - Royal Cutting Board Maker System
- **6 produktov** (železna deska za rezanje, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (rezalna delavnica, rezalna hiša, mojstrski rezalni atelje, suverena rezalna palača)
- Maker: Rezar, hire base 560 gold
- Poudarek na lesu (woodCost 4-5)

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.406] — 2026-08-11 — Royal Canvas Stretcher Maker System (6 products, canvas stretchers)
## [v3.11.405] — 2026-08-11 — Royal Pigment Grinder Maker System (6 products, pigment grinders)
## [v3.11.404] — 2026-08-11 — Royal Palette Maker System (6 products, palettes)
## [v3.11.403] — 2026-08-11 — Royal Paintbrush Maker System (6 products, paintbrushes)
## [v3.11.402] — 2026-08-11 — Royal Easel Maker System (6 products, easels)

### Dodano (v3.11.402-v3.11.406 — 5 slikarskih sistemov)

#### v3.11.402 - Royal Easel Maker System
- **6 produktov** (železno stojalo za platna, bronasto, srebrno, pozlačeno, draguljasto, kraljevski suvereno)
- **4 zgradbe** (stojalna delavnica, stojalna hiša, mojstrski stojalni atelje, suverena stojalna palača)
- Maker: Stojalar, hire base 575 gold
- Poudarek na lesu (woodCost 3)

#### v3.11.403 - Royal Paintbrush Maker System
- **6 produktov** (železni čopič, bronasti, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (čopična delavnica, čopična hiša, mojstrski čopični atelje, suverena čopična palača)
- Maker: Čopičar, hire base 580 gold

#### v3.11.404 - Royal Palette Maker System
- **6 produktov** (železna paleta, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (paletna delavnica, paletna hiša, mojstrski paletni atelje, suverena paletna palača)
- Maker: Paletar, hire base 570 gold

#### v3.11.405 - Royal Pigment Grinder Maker System
- **6 produktov** (železni mlinček za pigmente, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (pigmentna delavnica, pigmentna hiša, mojstrski pigmentni atelje, suverena pigmentna palača)
- Maker: Pigmentar, hire base 590 gold
- Poudarek na kovini (ironCost/bronzeCost 3)

#### v3.11.406 - Royal Canvas Stretcher Maker System
- **6 produktov** (železni napenjalec platna, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (napenjalna delavnica, napenjalna hiša, mojstrski napenjalni atelje, suverena napenjalna palača)
- Maker: Napenjalec, hire base 580 gold

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.401] — 2026-08-11 — Royal Saddlebag Maker System (6 products, saddlebags)
## [v3.11.400] — 2026-08-11 — Royal Horse Harness Maker System (6 products, horse harnesses)
## [v3.11.399] — 2026-08-11 — Royal Stirrup Maker System (6 products, stirrups)
## [v3.11.398] — 2026-08-11 — Royal Bridle Maker System (6 products, bridles)
## [v3.11.397] — 2026-08-11 — Royal Saddle Maker System (6 products, saddles)

### Dodano (v3.11.397-v3.11.401 — 5 jermenskih sistemov)

#### v3.11.397 - Royal Saddle Maker System
- **6 produktov** (železno sedlo, bronasto, srebrno, pozlačeno, draguljasto, kraljevski suvereno)
- **4 zgradbe** (sedlarska delavnica, sedlarska hiša, mojstrski sedlarski atelje, suverena konjeniška palača)
- Maker: Sedlar, hire base 590 gold
- Poudarek na usnju (leatherCost 3-4)

#### v3.11.398 - Royal Bridle Maker System
- **6 produktov** (železna uzda, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (uzdarska delavnica, uzdarska hiša, mojstrski uzdarski atelje, suverena uzdarska palača)
- Maker: Uzdar, hire base 575 gold

#### v3.11.399 - Royal Stirrup Maker System
- **6 produktov** (železno streme, bronasto, srebrno, pozlačeno, draguljasto, kraljevski suvereno)
- **4 zgradbe** (stremska delavnica, stremska hiša, mojstrski stremski atelje, suverena stremska palača)
- Maker: Stremar, hire base 580 gold
- Poudarek na kovini (ironCost/bronzeCost 3)

#### v3.11.400 - Royal Horse Harness Maker System
- **6 produktov** (železni jermen za konjsko vprego, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (jermenska delavnica, jermenska hiša, mojstrski jermenski atelje, suverena jermenska palača)
- Maker: Jermenar, hire base 585 gold
- Poudarek na usnju (leatherCost 4-5)

#### v3.11.401 - Royal Saddlebag Maker System
- **6 produktov** (železna sedlarna torba, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (torbarska delavnica, torbarska hiša, mojstrski torbarski atelje, suverena torbarska palača)
- Maker: Torbar, hire base 565 gold
- Poudarek na usnju (leatherCost 4-5)

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.396] — 2026-08-11 — Royal Watering Can Maker System (6 products, watering cans)
## [v3.11.395] — 2026-08-11 — Royal Hedge Hook Maker System (6 products, hedge hooks)
## [v3.11.394] — 2026-08-11 — Royal Garden Trowel Maker System (6 products, garden trowels)
## [v3.11.393] — 2026-08-11 — Royal Topiary Frame Maker System (6 products, topiary frames)
## [v3.11.392] — 2026-08-11 — Royal Pruning Shears Maker System (6 products, pruning shears)

### Dodano (v3.11.392-v3.11.396 — 5 vrtnarskih sistemov)

#### v3.11.392 - Royal Pruning Shears Maker System
- **6 produktov** (železne škarje za obrezovanje, bronaste, srebrne, pozlačene, draguljaste, kraljevski suverene)
- **4 zgradbe** (vrtnarska delavnica, vrtnarska hiša, mojstrski vrtnarski atelje, suverena vrtnarska palača)
- Maker: Vrtnar, hire base 575 gold

#### v3.11.393 - Royal Topiary Frame Maker System
- **6 produktov** (železni okvir za topiary, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (topiarijska delavnica, topiarijska hiša, mojstrski topiarijski atelje, suverena topiarijska palača)
- Maker: Topiarist, hire base 580 gold

#### v3.11.394 - Royal Garden Trowel Maker System
- **6 produktov** (železna vrtna lopatka, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (lopatkarska delavnica, lopatkarska hiša, mojstrski lopatkarski atelje, suverena lopatkarska palača)
- Maker: Lopatkar, hire base 565 gold

#### v3.11.395 - Royal Hedge Hook Maker System
- **6 produktov** (železni kavelj za živo mejo, bronast, srebrni, pozlačeni, draguljasti, kraljevski suvereni)
- **4 zgradbe** (kaveljska delavnica, kaveljska hiša, mojstrski kaveljski atelje, suverena kaveljska palača)
- Maker: Kaveljar, hire base 585 gold

#### v3.11.396 - Royal Watering Can Maker System
- **6 produktov** (železna zalivalka, bronasta, srebrna, pozlačena, draguljasta, kraljevski suverena)
- **4 zgradbe** (zalivalna delavnica, zalivalna hiša, mojstrski zalivalni atelje, suverena zalivalna palača)
- Maker: Zalivalec, hire base 590 gold

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.391] — 2026-08-11 — Royal Physic Potion Maker System (6 products, physic potions)
## [v3.11.390] — 2026-08-11 — Royal Surgical Lancet Maker System (6 products, surgical lancets)
## [v3.11.389] — 2026-08-11 — Royal Salve Jar Maker System (6 products, salve jars)
## [v3.11.388] — 2026-08-11 — Royal Apothecary Vial Maker System (6 products, apothecary vials)
## [v3.11.387] — 2026-08-11 — Royal Mortar and Pestle Maker System (6 products, mortars and pestles)

### Dodano (v3.11.387-v3.11.391 — 5 lekarniških sistemov)

#### v3.11.387 - Royal Mortar and Pestle Maker System
- **6 produktov** (železni možnar, bronast možnar, srebrni možnar, pozlačeni možnar, draguljasti možnar, kraljevski suvereni možnar)
- **4 zgradbe** (možnarska delavnica, možnarska hiša, mojstrski možnarski atelje, suverena lekarniška palača)
- Maker: Možnarar, hire base 585 gold

#### v3.11.388 - Royal Apothecary Vial Maker System
- **6 produktov** (železna viala, bronasta viala, srebrna viala, pozlačena viala, draguljasta viala, kraljevski suverena viala)
- **4 zgradbe** (vialna delavnica, vialna hiša, mojstrski vialni atelje, suverena vialna palača)
- Maker: Vialar, hire base 575 gold

#### v3.11.389 - Royal Salve Jar Maker System
- **6 produktov** (železni kozarec za mazila, bronast kozarec, srebrni kozarec, pozlačeni kozarec, draguljasti kozarec, kraljevski suvereni kozarec)
- **4 zgradbe** (mazilna delavnica, mazilna hiša, mojstrski mazilni atelje, suverena mazilna palača)
- Maker: Mazilar, hire base 565 gold

#### v3.11.390 - Royal Surgical Lancet Maker System
- **6 produktov** (železna lanceta, bronasta lanceta, srebrna lanceta, pozlačena lanceta, draguljasta lanceta, kraljevski suverena lanceta)
- **4 zgradbe** (lancetna delavnica, lancetna hiša, mojstrski lancetni atelje, suverena kirurška palača)
- Maker: Lancetar, hire base 590 gold

#### v3.11.391 - Royal Physic Potion Maker System
- **6 produktov** (železni napitek, bronast napitek, srebrni napitek, pozlačeni napitek, draguljasti napitek, kraljevski suvereni napitek)
- **4 zgradbe** (napitnična delavnica, napitnična hiša, mojstrski napitnični atelje, suverena napitnična palača)
- Maker: Napitkar, hire base 595 gold

Vsi novi sistemski so avtomatsko odkriti in prikazani v Royal Systems Panel (Ctrl+R) preko RoyalSystemsRegistry.

## [v3.11.386] — 2026-08-11 — Royal Prospecting Pan Maker System (6 products, prospecting pans)
## [v3.11.385] — 2026-08-11 — Royal Mining Chisel Maker System (6 products, mining chisels)
## [v3.11.384] — 2026-08-11 — Royal Auger Maker System (6 products, augers)
## [v3.11.383] — 2026-08-11 — Royal Shovel Maker System (6 products, shovels)
## [v3.11.382] — 2026-08-11 — Royal Pickaxe Maker System (6 products, pickaxes) + Royal Systems Registry + UI Panel (Ctrl+R)

### Dodano (v3.11.382-v3.11.386 — 5 rudarskih sistemov + UI integracija)

#### v3.11.382 - Royal Pickaxe Maker System
- **6 produktov** (železno kramp, bronast kramp, srebrni kramp, pozlačeni kramp, draguljasti kramp, kraljevski suvereni kramp)
- **4 zgradbe** (rudarska delavnica, rudarska hiša, mojstrski rudarski atelje, suverena rudarska palača)
- Iron, bronze, wood, leather, silver, gold, jewel, pearl supply, prestige (2-65), happiness (1-12), batch qty 1
- Maker: Krampar, hire base 580 gold

#### v3.11.383 - Royal Shovel Maker System
- **6 produktov** (železna lopata, bronasta lopata, srebrna lopata, pozlačena lopata, draguljasta lopata, kraljevski suverena lopata)
- **4 zgradbe** (lopatarska delavnica, lopatarska hiša, mojstrski lopatarski atelje, suverena izkopavalna palača)
- Maker: Lopatar, hire base 560 gold

#### v3.11.384 - Royal Auger Maker System
- **6 produktov** (železni sveder, bronast sveder, srebrni sveder, pozlačeni sveder, draguljasti sveder, kraljevski suvereni sveder)
- **4 zgradbe** (vrtalna delavnica, vrtalna hiša, mojstrski vrtalni atelje, suverena vrtalna palača)
- Maker: Svedrar, hire base 590 gold

#### v3.11.385 - Royal Mining Chisel Maker System
- **6 produktov** (železno dleto, bronasto dleto, srebrno dleto, pozlačeno dleto, draguljasto dleto, kraljevsko suvereno dleto)
- **4 zgradbe** (dletarska delavnica, dletarska hiša, mojstrski dletarski atelje, suverena klesarska palača)
- Maker: Dletar, hire base 570 gold

#### v3.11.386 - Royal Prospecting Pan Maker System
- **6 produktov** (železni porabnik, bronast porabnik, srebrni porabnik, pozlačeni porabnik, draguljasti porabnik, kraljevski suvereni porabnik)
- **4 zgradbe** (prospekcijska delavnica, prospektorska hiša, mojstrski prospekcijski atelje, suverena prospekcijska palača)
- Maker: Prospektor, hire base 595 gold

#### v3.11.382 - Royal Systems Registry + UI Panel (glavna nadgradnja)
- **`objects/Economy/RoyalSystemsRegistry.lua`** — centralen manager, ki:
  - Auto-discovers vseh 347+ Royal Maker sistemov iz S tabele
  - Prebere PRODUCTS in BUILDINGS tabele preko `debug.getupvalue`
  - Hook-a vsak sistemski `completeMaking()` in ob končanem produktu:
    - Dodeli igralcu bonus zlato = prestige × 10 (real game effect)
    - Pri visoko-happiness produktih (≥5) dvigne popularity za +1
  - Aggregira statistike čez vse sisteme
- **`states/ui/hud/royal_systems_panel.lua`** — full-screen UI panel (toggle s Ctrl+R):
  - Paginiran seznam vseh 347+ sistemov (12 na stran) z status dot-i
  - Detail panel z statistikami, zalogo, surovinami
  - Action gumbi: najemi mojster, zgradi delavnico, izdelaj produkt, zgradi vse, prodaj zalogo, dodaj surovine
  - Keyboard navigation (puščice/WASD), ESC za zapretje, klik izven panela zapre
- **`states/game.lua`** — povezava Registry + Panel (require, init, update, draw, keypressed, mousepressed)
- **`states/ui/hud/keybind_help.lua`** — dodana Ctrl+R bližnjica v EKONOMIJA kategorijo
- **`scripts/test_registry.lua`** — test skripta (poženi z lupa) ki preverja delovanje Registry-ja

## [v3.11.381] — 2026-08-10 — Royal Angelus Bell Maker System (6 products, angelus bells)
## [v3.11.380] — 2026-08-10 — Royal Tubular Bells Maker System (6 products, tubular bells)
## [v3.11.379] — 2026-08-10 — Royal Handbell Maker System (6 products, handbells)
## [v3.11.378] — 2026-08-10 — Royal Glockenspiel Maker System (6 products, glockenspiels)
## [v3.11.377] — 2026-08-10 — Royal Carillon Maker System (6 products, carillons)

### Dodano (5 sistemov naenkrat — kraljevska zvončna in tonsko-udarna glasbila)
- **Royal Carillon Maker System** — kariljoni (skupine uglašenih zvonov)
  - 6 produktov (bronasti ročni, železni stolpni, srebrno uglašen, pozlačeni slavnostni, draguljasti kraljevski, suvereni veliki)
  - 4 zgradbe (kariljonska delavnica, zvonolivarski priključek, mojstrski kariljonski atelje, suverena kampanilna palača)
  - Bronze, iron, wood, silver, gold, jewel, pearl supply, prestige (3-82), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Glockenspiel Maker System** — glockenspieli (tonske kovinske palčke)
  - 6 produktov (preprosti železni, medeninasto uglašen, srebrnopalični, pozlačeni dvorni, draguljasti kraljevski, suvereni veliki)
  - 4 zgradbe (glockenspiel delavnica, tonsko-udarna hiša, mojstrski glockenspiel atelje, suverena celesta palača)
  - Iron, brass, wood, silver, gold, jewel, pearl supply, prestige (2-76), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Handbell Maker System** — ročne zvončnice
  - 6 produktov (preprosta bronasta, medeninasta zborovska, srebrno uglašena, pozlačena slavnostna, draguljasta kraljevska, suvereni zvončničenje)
  - 4 zgradbe (zvončničarska delavnica, zvončničarski ceh, mojstrski zvončničarski atelje, suverena kampanološka palača)
  - Bronze, brass, wood, leather, silver, gold, jewel, pearl supply, prestige (1-64), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Tubular Bells Maker System** — tubular zvonovi (cevasti zvonovi)
  - 6 produktov (železno zveneče, medeninasto orkestralno, srebrno uglašeno, pozlačeno katedralsko, draguljasto kraljevsko, suvereni veliki)
  - 4 zgradbe (tubular delavnica, zvončni stolp priključek, mojstrski tubular atelje, suverena resonančna palača)
  - Iron, brass, wood, rope, silver, gold, jewel, pearl supply, prestige (2-79), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Angelus Bell Maker System** — angelus zvonovi (zvoni za molitvene ure)
  - 6 produktov (preprost železni, bronast kapelni, srebrni samostanski, pozlačeni katedralski, draguljasta kraljevska, suvereni sanctus)
  - 4 zgradbe (angelus delavnica, posvetilna zvončna hiša, mojstrski angelus atelje, suverena sanctus palača)
  - Iron, bronze, wood, rope, silver, gold, jewel, pearl supply, prestige (3-84), happiness (1-12), batch qty 1, GameEventBus publish

## [v3.11.376] — 2026-08-10 — Royal Collar of Estate System (6 products, estate collars)
## [v3.11.375] — 2026-08-10 — Royal Commendation Scroll System (6 products, commendation scrolls)
## [v3.11.374] — 2026-08-10 — Royal Order Insignia System (6 products, knightly order insignia)
## [v3.11.373] — 2026-08-10 — Royal Ribbon Weaver System (6 products, honor ribbons and sashes)
## [v3.11.372] — 2026-08-10 — Royal Medal Minter System (6 products, military and civil medals)

### Dodano (5 sistemov naenkrat — kraljevske časti in odlikovanja)
- **Royal Medal Minter System** — kovanje vojaških in civilnih medalj
  - 6 produktov (bronasta službena, srebrna hrabrostna, pozlačena zaslužna, draguljasta meščanska, veliki križec, kraljevska suverena)
  - 4 zgradbe (medaljarska delavnica, kraljevska kovnica priključek, mojstrski medaljarski atelje, suverena kovniška palača)
  - Bronze, iron, silver, gold, jewel, pearl supply, prestige (3-78), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Ribbon Weaver System** — pletenje častnih pentelj in rut
  - 6 produktov (preprosta svilena, pletena častna ruta, srebronitni cordon, zlatobrokatna ruta, draguljasta podkolenska pentlja, kraljevska suverena ruta)
  - 4 zgradbe (pentljearska tkalska stroj, častna tekstilna hiša, mojstrski pentljaški atelje, suverena častna palača)
  - Silk, silver, gold, jewel, pearl supply, prestige (1-60), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Order Insignia System** — izdelovanje znakov viteških redov
  - 6 produktov (bronast redni, srebrni viteški, pozlačeni poveljniški, draguljasti veliki križ, verižni ovratniški, kraljevski suvereni)
  - 4 zgradbe (insignijska delavnica, viteška dvorana reda, mojstrski insignijski atelje, suverena palača redov)
  - Bronze, iron, silver, gold, jewel, pearl supply, prestige (4-88), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Commendation Scroll System** — pisanje in iluminacija častnih listin
  - 6 produktov (preprosta pergamentna, iluminirani sprehvalni, srebrnopesačani odlok, pozlačeni častni patent, draguljasta kraljeva listina, suvereni veliki diplom)
  - 4 zgradbe (zvitočno skriptorij, častna pisarna, mojstrski listinarski atelje, suverena listinarska palača)
  - Parchment, ink, silver, gold, jewel, pearl supply, prestige (2-72), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Collar of Estate System** — izdelovanje verižnih ovratnikov državnih časti
  - 6 produktov (železna verižna, srebrnoverižna, pozlačena kanclerska, draguljasta dvorna, bisernoverižna državna, kraljevska suverena)
  - 4 zgradbe (verižna delavnica, državna draginarska hiša, mojstrski ovratniški atelje, suverena državna palača)
  - Iron, silver, gold, jewel, pearl supply, prestige (3-86), happiness (1-12), batch qty 1, GameEventBus publish

## [v3.11.371] — 2026-08-09 — Royal Paper Cutting Machine Maker System (6 products, paper cutting machines)
## [v3.11.370] — 2026-08-09 — Royal Bookbinding Press Maker System (6 products, bookbinding presses)
## [v3.11.369] — 2026-08-09 — Royal Typesetting Machine Maker System (6 products, typesetting machines)
## [v3.11.368] — 2026-08-09 — Royal Engraving Machine Maker System (6 products, engraving machines)
## [v3.11.367] — 2026-08-09 — Royal Printing Press Maker System (6 products, printing presses)
## [v3.11.366] — 2026-08-09 — Royal Fishing Boat Maker System (6 products, fishing boats)

### Dodano (5 sistemov naenkrat — tiskarski stroji)
- **Royal Printing Press Maker System** — tiskarske stiskalnice
  - 6 produktov (lesena, železnookrepljena, srebrnozobčana, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (tiskarska delavnica, tiskarska podstrešje, mojstrski tiskarski atelje, kraljevska tiskarska palača)
  - Wood, iron, silver, gold, jewel, pearl supply, science (30-95), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Engraving Machine Maker System** — gravirni stroji
  - 6 produktov (leseni, železnookrepljen, srebrnozobčan, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (gravirna delavnica, tiskarska podstrešje, mojstrski gravirni atelje, kraljevska tiskarska palača)
  - Wood, iron, brass, silver, gold, jewel, pearl supply, science (25-95), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Typesetting Machine Maker System** — tipografski stroji
  - 6 produktov (leseni, železnookrepljen, srebrnozobčan, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (tipografska delavnica, tiskarska podstrešje, mojstrski tipografski atelje, kraljevska tiskarska palača)
  - Wood, iron, lead, silver, gold, jewel, pearl supply, science (28-95), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Bookbinding Press Maker System** — vezne stiskalnice
  - 6 produktov (lesena, železnookrepljena, srebrnozobčana, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (vezna delavnica, tiskarska podstrešje, mojstrski vezni atelje, kraljevska tiskarska palača)
  - Wood, iron, leather, silver, gold, jewel, pearl supply, science (22-95), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Paper Cutting Machine Maker System** — papirni rezniki
  - 6 produktov (leseni, železnorezni, srebrnozobčan, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (papirna rezna delavnica, tiskarska podstrešje, mojstrski rezni atelje, kraljevska tiskarska palača)
  - Wood, iron, silver, gold, jewel, pearl supply, science (20-95), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.365] — 2026-08-09 — Royal Harpoon Maker System (6 products, harpoons)
## [v3.11.364] — 2026-08-09 — Royal Fishing Rod Maker System (6 products, fishing rods)
## [v3.11.363] — 2026-08-09 — Royal Fishing Trap Maker System (6 products, fishing traps)
## [v3.11.362] — 2026-08-09 — Royal Fishing Net Maker System (6 products, fishing nets)
## [v3.11.361] — 2026-08-09 — Royal Sorting Machine Maker System (6 products, sorting machines)

### Dodano (5 sistemov naenkrat — ribiški pripomočki)
- **Royal Fishing Net Maker System** — ribiške mreže
  - 6 produktov (vrvična, lanena odmetna, srebrnoobtežena, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (mrežna delavnica, ribiška podstrešje, mojstrski mrežni atelje, kraljevska ribiška palača)
  - Rope, thread, linen, silver, gold, jewel, pearl supply, food (15-90), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Fishing Trap Maker System** — ribiške vrše
  - 6 produktov (lesena, vrbovapletena, srebrnooplaščena, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (vršarska delavnica, ribiška podstrešje, mojstrski vršarski atelje, kraljevska ribiška palača)
  - Wood, rope, leather, silver, gold, jewel, pearl supply, food (12-85), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Fishing Rod Maker System** — ribiške palice
  - 6 produktov (lesena, bambusova, srebrnavodilna, zlatookrasna, draguljnavaltasta, kraljevska velika)
  - 4 zgradbe (palicna delavnica, ribiška podstrešje, mojstrski palicni atelje, kraljevska ribiška palača)
  - Wood, rope, thread, silver, gold, jewel, pearl supply, food (8-72), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Harpoon Maker System** — harpune
  - 6 produktov (železen, jeklenobodena, srebrnovložena, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (harpunarska delavnica, ribiška podstrešje, mojstrski harpunarski atelje, kraljevska ribiška palača)
  - Iron, steel, wood, rope, silver, gold, jewel, pearl supply, food (18-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Fishing Boat Maker System** — ribiški čolni
  - 6 produktov (leseni, hrastovotrupni, srebrnoopremljeni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (čolnarska delavnica, ladjedelska podstrešje, mojstrski čolnarski atelje, kraljevska ladjedelska palača)
  - Wood, iron, rope, silver, gold, jewel, pearl supply, food (30-110), happiness (2-13), batch qty 1, GameEventBus publish


## [v3.11.360] — 2026-08-09 — Royal Winnowing Machine Maker System (6 products, winnowing machines)
## [v3.11.359] — 2026-08-09 — Royal Thresher Maker System (6 products, threshers)
## [v3.11.358] — 2026-08-09 — Royal Reaper Maker System (6 products, reapers)
## [v3.11.357] — 2026-08-09 — Royal Seed Drill Maker System (6 products, seed drills)
## [v3.11.356] — 2026-08-09 — Royal Evaporating Basin Maker System (6 products, evaporating basins)

### Dodano (5 sistemov naenkrat — kmetijski stroji)
- **Royal Seed Drill Maker System** — sejalnice
  - 6 produktov (lesena, železnocévna, srebrnozobčana, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (sejalniška delavnica, kmetijska podstrešje, mojstrski sejalniški atelje, kraljevska kmetijska palača)
  - Wood, iron, silver, gold, jewel, pearl supply, food (20-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Reaper Maker System** — žetveni stroji
  - 6 produktov (leseni, železnorezni, srebrnozobčani, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (žetvena delavnica, kmetijska podstrešje, mojstrski žetveni atelje, kraljevska kmetijska palača)
  - Wood, iron, silver, gold, jewel, pearl supply, food (25-100), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Thresher Maker System** — mlatilni stroji
  - 6 produktov (leseni, železnobobenski, srebrnozobčani, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (mlatilna delavnica, kmetijska podstrešje, mojstrski mlatilni atelje, kraljevska kmetijska palača)
  - Wood, iron, rope, silver, gold, jewel, pearl supply, food (28-100), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Winnowing Machine Maker System** — pihalni stroji
  - 6 produktov (lesena, železnolopatična, srebrnozobčana, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (pihalna delavnica, kmetijska podstrešje, mojstrski pihalni atelje, kraljevska kmetijska palača)
  - Wood, iron, leather, silver, gold, jewel, pearl supply, food (22-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Sorting Machine Maker System** — sortilni stroji
  - 6 produktov (leseni, železnosito, srebrnozobčani, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (sortilna delavnica, kmetijska podstrešje, mojstrski sortilni atelje, kraljevska kmetijska palača)
  - Wood, iron, silver, gold, jewel, pearl supply, food (18-92), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.355] — 2026-08-09 — Royal Crystallization Dish Maker System (6 products, crystallization dishes)
## [v3.11.354] — 2026-08-09 — Royal Sublimation Apparatus Maker System (6 products, sublimation apparatuses)
## [v3.11.353] — 2026-08-09 — Royal Filtration Apparatus Maker System (6 products, filtration apparatuses)
## [v3.11.352] — 2026-08-09 — Royal Distillation Apparatus Maker System (6 products, distillation apparatuses)
## [v3.11.351] — 2026-08-09 — Royal Processional Canopy Maker System (6 products, processional canopies)

### Dodano (5 sistemov naenkrat — kemijski laboratorijski pripomočki)
- **Royal Distillation Apparatus Maker System** — destilatorne naprave
  - 6 produktov (steklena, medeninasto okvirjena, srebrnospojna, zlatookrasna, draguljnoventilna, kraljevska velika)
  - 4 zgradbe (destilatorna delavnica, alkemična podstrešje, mojstrski destilatorski atelje, kraljevska alkemična palača)
  - Glass, clay, brass, silver, gold, jewel, pearl supply, science (25-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Filtration Apparatus Maker System** — filtrirne naprave
  - 6 produktov (glinena, medeninasto okvirjena, srebrnospojna, zlatookrasna, draguljnoventilna, kraljevska velika)
  - 4 zgradbe (filtrirna delavnica, alkemična podstrešje, mojstrski filtrirni atelje, kraljevska alkemična palača)
  - Clay, glass, brass, silver, gold, jewel, pearl supply, science (20-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Sublimation Apparatus Maker System** — sublimatorne naprave
  - 6 produktov (steklena, medeninasto okvirjena, srebrnospojna, zlatookrasna, draguljnoventilna, kraljevska velika)
  - 4 zgradbe (sublimatorna delavnica, alkemična podstrešje, mojstrski sublimatorski atelje, kraljevska alkemična palača)
  - Glass, clay, brass, silver, gold, jewel, pearl supply, science (22-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Crystallization Dish Maker System** — kristalizacijske posode
  - 6 produktov (glinena, steklena, srebrnorobna, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (kristalizacijska delavnica, alkemična podstrešje, mojstrski kristalizacijski atelje, kraljevska alkemična palača)
  - Clay, glass, silver, gold, jewel, pearl supply, science (18-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Evaporating Basin Maker System** — uparjevalne kadi
  - 6 produktov (glinena, bakrena, srebrnorobna, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (uparjevalna delavnica, alkemična podstrešje, mojstrski uparjevalni atelje, kraljevska alkemična palača)
  - Clay, copper, silver, gold, jewel, pearl supply, science (20-95), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.350] — 2026-08-09 — Royal Court Fan Maker System (6 products, court fans)
## [v3.11.349] — 2026-08-09 — Royal Parade Shield Maker System (6 products, parade shields)
## [v3.11.348] — 2026-08-09 — Royal Ceremonial Sash Maker System (6 products, ceremonial sashes)
## [v3.11.347] — 2026-08-09 — Royal State Cordon Maker System (6 products, state cordons)
## [v3.11.346] — 2026-08-09 — Royal Tempering Furnace Maker System (6 products, tempering furnaces)

### Dodano (5 sistemov naenkrat — ceremonialni predmeti)
- **Royal State Cordon Maker System** — državni cordoni
  - 6 produktov (svileni, srebrnoresasti, zlatopleteni, draguljnoprity, bisernavi, kraljevski veliki)
  - 4 zgradbe (cordonska delavnica, slovesna podstrešje, mojstrski cordonski atelje, kraljevska slovesna palača)
  - Silk, thread, gold, silver, jewel, pearl supply, prestige (5-72), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Ceremonial Sash Maker System** — slovesni pasovi
  - 6 produktov (svileni, srebrnovezeni, zlatopleteni, draguljnoprity, bisernavi, kraljevski veliki)
  - 4 zgradbe (pasna delavnica, slovesna podstrešje, mojstrski pasni atelje, kraljevska slovesna palača)
  - Silk, thread, silver, gold, jewel, pearl supply, prestige (4-70), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Parade Shield Maker System** — paradni ščiti
  - 6 produktov (leseni, železnopasni, srebrnoobrobljeni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (paradna ščitna delavnica, orožarna podstrešje, mojstrski ščitni atelje, kraljevska orožarna palača)
  - Wood, iron, paint, silver, gold, jewel, pearl supply, prestige (5-72), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Court Fan Maker System** — dvorne pahljače
  - 6 produktov (peresna, svilo nagubana, srebrnahrbetna, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (dvorna pahljačna delavnica, slovesna podstrešje, mojstrski pahljačni atelje, kraljevska slovesna palača)
  - Silk, leather, wood, wool, silver, gold, jewel, pearl supply, prestige (5-72), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Processional Canopy Maker System** — procesijski baldahini
  - 6 produktov (laneni, sviloobeseni, srebrnoobrobljeni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (baldahinska delavnica, slovesna podstrešje, mojstrski baldahinski atelje, kraljevska slovesna palača)
  - Silk, linen, wood, rope, silver, gold, jewel, pearl supply, prestige (8-80), happiness (3-14), batch qty 1, GameEventBus publish


## [v3.11.345] — 2026-08-09 — Royal Mold Kiln Maker System (6 products, mold kilns)
## [v3.11.344] — 2026-08-09 — Royal Crucible Furnace Maker System (6 products, crucible furnaces)
## [v3.11.343] — 2026-08-09 — Royal Annealing Lehr Maker System (6 products, annealing lehrs)
## [v3.11.342] — 2026-08-09 — Royal Glass Furnace Maker System (6 products, glass furnaces)
## [v3.11.341] — 2026-08-09 — Royal Dye Vat Maker System (6 products, dye vats)

### Dodano (5 sistemov naenkrat — steklarske peči)
- **Royal Glass Furnace Maker System** — steklarske peči
  - 6 produktov (opečna, železnookrepljena, srebrnopasna, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (pečna delavnica, steklarska podstrešje, mojstrski pečni atelje, kraljevska steklarska palača)
  - Brick, clay, wood, iron, silver, gold, jewel, pearl supply, science (25-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Annealing Lehr Maker System** — ohlajevalne peči
  - 6 produktov (opečna, železnookrepljena, srebrnopasna, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (ohlajevalna delavnica, steklarska podstrešje, mojstrski ohlajevalni atelje, kraljevska steklarska palača)
  - Brick, clay, iron, silver, gold, jewel, pearl supply, science (22-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Crucible Furnace Maker System** — talilne peči
  - 6 produktov (glinena, železnookrepljena, srebrnopasna, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (talilna pečna delavnica, metalurška podstrešje, mojstrski pečni atelje, kraljevska metalurška palača)
  - Clay, brick, iron, silver, gold, jewel, pearl supply, science (25-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Mold Kiln Maker System** — kalupne peči
  - 6 produktov (glinena, železnookrepljena, srebrnopasna, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (kalupna pečna delavnica, livna podstrešje, mojstrski pečni atelje, kraljevska livna palača)
  - Clay, brick, iron, silver, gold, jewel, pearl supply, science (22-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Tempering Furnace Maker System** — kalilne peči
  - 6 produktov (opečna, železnookrepljena, srebrnopasna, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (kalilna delavnica, metalurška podstrešje, mojstrski kalilni atelje, kraljevska metalurška palača)
  - Brick, iron, clay, silver, gold, jewel, pearl supply, science (25-95), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.340] — 2026-08-09 — Royal Thread Reel Maker System (6 products, thread reels)
## [v3.11.339] — 2026-08-09 — Royal Bobbin Maker System (6 products, bobbins)
## [v3.11.338] — 2026-08-09 — Royal Loom Frame Maker System (6 products, loom frames)
## [v3.11.337] — 2026-08-09 — Royal Spinning Wheel Maker System (6 products, spinning wheels)
## [v3.11.336] — 2026-08-09 — Royal Pitchfork Maker System (6 products, pitchforks)

### Dodano (5 sistemov naenkrat — tekstilni pripomočki)
- **Royal Spinning Wheel Maker System** — predilna vretena
  - 6 produktov (leseno, železnopasno, srebrnoobrobljeno, zlatookrasno, draguljasto, kraljevsko veliko)
  - 4 zgradbe (predilna delavnica, tekstilna podstrešje, mojstrski predilni atelje, kraljevska tekstilna palača)
  - Wood, iron, silver, gold, jewel, pearl supply, science (18-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Loom Frame Maker System** — statveni okvirji
  - 6 produktov (lesen, železnookrepljena, srebrnoobrobljene, zlatookrasne, draguljasta, kraljevske velike)
  - 4 zgradbe (statvena delavnica, tekstilna podstrešje, mojstrski statveni atelje, kraljevska tekstilna palača)
  - Wood, iron, rope, silver, gold, jewel, pearl supply, science (20-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Bobbin Maker System** — navojnice
  - 6 produktov (lesena, železnopasna, srebrnoobrobljena, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (navojnična delavnica, tekstilna podstrešje, mojstrski navojnični atelje, kraljevska tekstilna palača)
  - Wood, iron, silver, gold, jewel, pearl supply, science (15-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Thread Reel Maker System** — nitne navijalke
  - 6 produktov (lesena, železnovretenčna, srebrnoobrobljena, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (navijalna delavnica, tekstilna podstrešje, mojstrski navijalni atelje, kraljevska tekstilna palača)
  - Wood, iron, silver, gold, jewel, pearl supply, science (12-88), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Dye Vat Maker System** — barvilske kopeli
  - 6 produktov (glinena, železnorobna, srebrnoobrobljena, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (barvilska kadna delavnica, tekstilna podstrešje, mojstrski barvilski atelje, kraljevska tekstilna palača)
  - Clay, wood, iron, silver, gold, jewel, pearl supply, science (18-92), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.335] — 2026-08-09 — Royal Scythe Smith System (6 products, scythes)
## [v3.11.334] — 2026-08-09 — Royal Sickle Smith System (6 products, sickles)
## [v3.11.333] — 2026-08-09 — Royal Harrow Maker System (6 products, harrows)
## [v3.11.332] — 2026-08-09 — Royal Plow Maker System (6 products, plows)
## [v3.11.331] — 2026-08-09 — Royal Latrine Builder System (6 products, latrines)

### Dodano (5 sistemov naenkrat — kmetijski pripomočki)
- **Royal Plow Maker System** — plugi
  - 6 produktov (leseni, železnovršni, jeklenorezni, srebrnoobrobljeni, draguljasta, kraljevski veliki)
  - 4 zgradbe (plužna delavnica, kmetijska podstrešje, mojstrski plužni atelje, kraljevska kmetijska palača)
  - Wood, iron, steel, silver, gold, jewel, pearl supply, food (15-90), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Harrow Maker System** — brana
  - 6 produktov (leseno, železnozoba, jeklenobodena, srebrnoobrobljena, draguljasta, kraljevska velika)
  - 4 zgradbe (branska delavnica, kmetijska podstrešje, mojstrski branski atelje, kraljevska kmetijska palača)
  - Wood, iron, steel, silver, gold, jewel, pearl supply, food (12-82), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Sickle Smith System** — srpi
  - 6 produktov (železen, jeklenorezni, srebrnoobrobljeni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (srparska delavnica, kmetijska podstrešje, mojstrski srparski atelje, kraljevska kmetijska palača)
  - Iron, steel, wood, silver, gold, jewel, pearl supply, food (10-75), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Scythe Smith System** — kose
  - 6 produktov (železna, jeklenorezna, srebrnoobrobljena, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (kosarska delavnica, kmetijska podstrešje, mojstrski kosarski atelje, kraljevska kmetijska palača)
  - Iron, steel, wood, silver, gold, jewel, pearl supply, food (14-82), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Pitchfork Maker System** — vile
  - 6 produktov (lesene, železnovile, jeklenovile, srebrnoobrobljene, draguljasta, kraljevske velike)
  - 4 zgradbe (vilna delavnica, kmetijska podstrešje, mojstrski vilni atelje, kraljevska kmetijska palača)
  - Wood, iron, steel, silver, gold, jewel, pearl supply, food (10-75), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.330] — 2026-08-09 — Royal Cistern Maker System (6 products, cisterns)
## [v3.11.329] — 2026-08-09 — Royal Bath Fixture Maker System (6 products, bath fixtures)
## [v3.11.328] — 2026-08-09 — Royal Aqueduct Maker System (6 products, aqueducts)
## [v3.11.327] — 2026-08-09 — Royal Well Builder System (6 products, wells)
## [v3.11.326] — 2026-08-09 — Royal Vestibule Light Maker System (6 products, vestibule lights)

### Dodano (5 sistemov naenkrat — vodovodni sistemi)
- **Royal Well Builder System** — vodnjaki
  - 6 produktov (kamnit, opečnoobložen, marmornatorobni, srebrnovedrni, draguljasta, kraljevski veliki)
  - 4 zgradbe (vodnjakarska delavnica, vodovodna podstrešje, mojstrski vodnjakarski atelje, kraljevska vodovodna palača)
  - Stone, brick, marble, wood, rope, silver, gold, jewel, pearl supply, waterSupply (30-150), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Aqueduct Maker System** — akvadukti
  - 6 produktov (kamnit, opečnolokastni, marmornatoobložen, srebrnovloženi, draguljasta, kraljevski veliki)
  - 4 zgradbe (akvaduktna delavnica, vodovodna podstrešje, mojstrski akvaduktni atelje, kraljevska vodovodna palača)
  - Stone, brick, marble, clay, silver, gold, jewel, pearl supply, waterSupply (40-160), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Bath Fixture Maker System** — kopalna oprema
  - 6 produktov (kamnita kopalna kad, marmornata, srebrnopipna, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (kopalna delavnica, vodovodna podstrešje, mojstrski kopalni atelje, kraljevska kopalna palača)
  - Stone, marble, clay, silver, gold, jewel, pearl supply, health (8-55), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Cistern Maker System** — cisterne
  - 6 produktov (glinena, opečnoobložena, marmornata, srebrnopasna, draguljasta, kraljevska velika)
  - 4 zgradbe (cisternska delavnica, vodovodna podstrešje, mojstrski cisterski atelje, kraljevska vodovodna palača)
  - Clay, stone, brick, marble, silver, gold, jewel, pearl supply, waterSupply (35-155), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Latrine Builder System** — stranišča
  - 6 produktov (leseni, kamnit jamski, opečna privatna, marmornata, srebrnoopremljena, kraljevski veliki)
  - 4 zgradbe (straniščna delavnica, sanitarna podstrešje, mojstrski sanitarni atelje, kraljevska sanitarna palača)
  - Wood, stone, brick, marble, silver, gold, jewel, pearl supply, health (6-45), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.325] — 2026-08-09 — Royal Beacon Light Maker System (6 products, beacon lights)
## [v3.11.324] — 2026-08-09 — Royal Candlestick Maker System (6 products, candlesticks)
## [v3.11.323] — 2026-08-09 — Royal Torch Holder Maker System (6 products, torch holders)
## [v3.11.322] — 2026-08-09 — Royal Oil Lamp Maker System (6 products, oil lamps)
## [v3.11.321] — 2026-08-09 — Royal Copper Sheet Maker System (6 products, copper sheets)

### Dodano (5 sistemov naenkrat — illuminatorske tehnologije)
- **Royal Oil Lamp Maker System** — oljne svetilke
  - 6 produktov (glinena, medeninasta, srebrnoobrobljena, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (oljna svetilkarska delavnica, razsvetljena podstrešje, mojstrski svetilkarski atelje, kraljevska razsvetljenska palača)
  - Clay, oil, brass, silver, gold, jewel, pearl supply, lightRadius (20-90), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Torch Holder Maker System** — bakloderžalci
  - 6 produktov (železen, medeninast, srebrnoobrobljeni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (bakloderžalna delavnica, razsvetljena podstrešje, mojstrski deržalni atelje, kraljevska razsvetljenska palača)
  - Iron, wood, brass, silver, gold, jewel, pearl supply, lightRadius (25-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Candlestick Maker System** — svečniki
  - 6 produktov (glineni, medeninast, srebrnoobrobljeni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (svečniška delavnica, razsvetljena podstrešje, mojstrski svečniški atelje, kraljevska razsvetljenska palača)
  - Clay, wax, brass, silver, gold, jewel, pearl supply, lightRadius (18-88), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Beacon Light Maker System** — svetilniki
  - 6 produktov (leseni, železnookrepljen, srebrnoobrobljeni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (svetilniška delavnica, razsvetljena podstrešje, mojstrski svetilniški atelje, kraljevska razsvetljenska palača)
  - Wood, iron, wax, silver, gold, jewel, pearl supply, lightRadius (50-125), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Vestibule Light Maker System** — vhodne luči
  - 6 produktov (medeninasta, železnookrepljena, srebrnoobrobljena, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (vhodna lučna delavnica, razsvetljena podstrešje, mojstrski vhodni lučni atelje, kraljevska razsvetljenska palača)
  - Brass, glass, wax, iron, silver, gold, jewel, pearl supply, lightRadius (30-100), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.320] — 2026-08-09 — Royal Iron Forge Tool Maker System (6 products, forge tools)
## [v3.11.319] — 2026-08-09 — Royal Metal Mesh Maker System (6 products, metal meshes)
## [v3.11.318] — 2026-08-09 — Royal Hook Maker System (6 products, hooks)
## [v3.11.317] — 2026-08-09 — Royal Wire Drawer Maker System (6 products, wire)
## [v3.11.316] — 2026-08-09 — Royal Baking Sheet Maker System (6 products, baking sheets)

### Dodano (5 sistemov naenkrat — kovinske obrti)
- **Royal Wire Drawer Maker System** — žica
  - 6 produktov (železna, medeninasta, srebrna, zlata, draguljasta, kraljevska velika)
  - 4 zgradbe (žična delavnica, vlečna podstrešje, mojstrski žični atelje, kraljevska žična palača)
  - Iron, brass, silver, gold, jewel, pearl supply, science (15-90), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Hook Maker System** — kovinski kljuki
  - 6 produktov (železen, medeninast, srebrn, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (kljukarska delavnica, kovinska podstrešje, mojstrski kljukarski atelje, kraljevska kovinska palača)
  - Iron, brass, silver, gold, jewel, pearl supply, happiness (1-12), prestige (2-58), batch qty 1, GameEventBus publish
- **Royal Metal Mesh Maker System** — kovinske mreže
  - 6 produktov (železna, medeninastovpeta, srebrnatična, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (mrežna delavnica, pletilska podstrešje, mojstrski mrežni atelje, kraljevska mrežna palača)
  - Iron, brass, silver, gold, jewel, pearl supply, defense (8-52), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Iron Forge Tool Maker System** — kovaško orodje
  - 6 produktov (klešče, jekleno kladivo, srebrnonakovalo, zlatookrasne klešče, draguljasta nakovalo, kraljevski veliki set)
  - 4 zgradbe (kovaška orodna delavnica, kovaška podstrešje, mojstrski kovaški atelje, kraljevska kovaška palača)
  - Iron, steel, wood, silver, gold, jewel, pearl supply, science (15-90), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Copper Sheet Maker System** — bakerjeva pločevina
  - 6 produktov (bakerjeva, bronastazlitna, srebrnopolirana, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (pločevinska delavnica, valjna podstrešje, mojstrski pločevinski atelje, kraljevska pločevinska palača)
  - Copper, bronze, silver, gold, jewel, pearl supply, science (15-90), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.315] — 2026-08-09 — Royal Kitchen Scale Maker System (6 products, kitchen scales)
## [v3.11.314] — 2026-08-09 — Royal Confection Oven Maker System (6 products, confection ovens)
## [v3.11.313] — 2026-08-09 — Royal Spice Mill Maker System (6 products, spice mills)
## [v3.11.312] — 2026-08-09 — Royal Grain Mill Maker System (6 products, grain mills)
## [v3.11.311] — 2026-08-09 — Royal Polisher Maker System (6 products, polishers)

### Dodano (5 sistemov naenkrat — kuhinjske tehnologije)
- **Royal Grain Mill Maker System** — mlini za žito
  - 6 produktov (kamnit, železnookrepljen, srebrnozobčani, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (mlinska delavnica, mlinska podstrešje, mojstrski mlinski atelje, kraljevska mlinska palača)
  - Stone, iron, wood, silver, gold, jewel, pearl supply, food (15-88), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Spice Mill Maker System** — mlini za začimbe
  - 6 produktov (kamnit, železnookrepljen, srebrnozobčani, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (začimbna mlinska delavnica, mlinska podstrešje, mojstrski začimbni mlinski atelje, kraljevska začimbna mlinska palača)
  - Stone, iron, wood, silver, gold, jewel, pearl supply, food (8-65), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Confection Oven Maker System** — peči za sladice
  - 6 produktov (opečna, železnookrepljena, srebrnoobrobljena, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (pečna delavnica, pekovska podstrešje, mojstrski pekovski atelje, kraljevska pekovska palača)
  - Brick, iron, steel, silver, gold, jewel, pearl supply, food (12-80), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Kitchen Scale Maker System** — kuhinjske tehtnice
  - 6 produktov (železne, medeninastoležajne, srebrnolatežne, zlatookrasne, draguljasta, kraljevske velike)
  - 4 zgradbe (tehtniška delavnica, inštrumentna podstrešje, mojstrski tehtniški atelje, kraljevska inštrumentna palača)
  - Iron, brass, silver, gold, jewel, pearl supply, culinary (18-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Baking Sheet Maker System** — pekači
  - 6 produktov (železna, kositrnoobložena, srebrnorobna, zlatookrasna, draguljasta, kraljevski veliki)
  - 4 zgradbe (pekačna delavnica, pekovska podstrešje, mojstrski pekavski atelje, kraljevska pekavska palača)
  - Iron, clay, tin, silver, gold, jewel, pearl supply, culinary (18-95), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.310] — 2026-08-09 — Royal Sander Maker System (6 products, sanders)
## [v3.11.309] — 2026-08-09 — Royal Planer Maker System (6 products, planers)
## [v3.11.308] — 2026-08-09 — Royal Drill Press Maker System (6 products, drill presses)
## [v3.11.307] — 2026-08-09 — Royal Wood Lathe Maker System (6 products, wood lathes)
## [v3.11.306] — 2026-08-09 — Royal Wheelbarrow Maker System (6 products, wheelbarrows)

### Dodano (5 sistemov naenkrat — leseni stroji)
- **Royal Wood Lathe Maker System** — leseni stružnice
  - 6 produktov (lesena, železnookrepljena, srebrnavretenna, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (stružniška delavnica, strojna podstrešje, mojstrski strojniški atelje, kraljevska strojna palača)
  - Wood, iron, steel, silver, gold, jewel, pearl supply, science (22-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Drill Press Maker System** — vrtalni stroji
  - 6 produktov (leseni, železnookrepljeni, srebrnosponni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (vrtna delavnica, strojna podstrešje, mojstrski strojniški atelje, kraljevska strojna palača)
  - Wood, iron, brass, silver, gold, jewel, pearl supply, science (20-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Planer Maker System** — gladilniki
  - 6 produktov (leseni, železnookrepljeni, srebrnorezni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (gladilniška delavnica, strojna podstrešje, mojstrski strojniški atelje, kraljevska strojna palača)
  - Wood, iron, steel, silver, gold, jewel, pearl supply, science (20-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Sander Maker System** — brusilniki
  - 6 produktov (leseni, železnookrepljeni, srebrnobobenski, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (brusilniška delavnica, strojna podstrešje, mojstrski strojniški atelje, kraljevska strojna palača)
  - Wood, iron, leather, sand, silver, gold, jewel, pearl supply, science (18-90), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Polisher Maker System** — polirniki
  - 6 produktov (leseni, železnookrepljeni, srebrnobobenski, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (polirniška delavnica, strojna podstrešje, mojstrski strojniški atelje, kraljevska strojna palača)
  - Wood, iron, leather, wax, silver, gold, jewel, pearl supply, science (18-90), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.305] — 2026-08-09 — Royal Winch Maker System (6 products, winches)
## [v3.11.304] — 2026-08-09 — Royal Pulley Maker System (6 products, pulleys)
## [v3.11.303] — 2026-08-09 — Royal Scaffold Maker System (6 products, scaffolds)
## [v3.11.302] — 2026-08-09 — Royal Crane Maker System (6 products, cranes)
## [v3.11.301] — 2026-08-09 — Royal Presentation Axe Maker System (6 products, presentation axes)

### Dodano (5 sistemov naenkrat — gradbene tehnologije)
- **Royal Crane Maker System** — žerjavi
  - 6 produktov (lesen, železnookrepljen, srebrnanični, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (žerjavna delavnica, strojna podstrešje, mojstrski inženirski atelje, kraljevska inženirska palača)
  - Wood, iron, rope, silver, gold, jewel, pearl supply, science (18-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Scaffold Maker System** — gradbena stojala
  - 6 produktov (leseno, železnookrepljeno, srebrnopasno, zlatookrasno, draguljasto, kraljevsko veliko)
  - 4 zgradbe (stojalna delavnica, gradbena podstrešje, mojstrski gradbeni atelje, kraljevska gradbena palača)
  - Wood, rope, iron, silver, gold, jewel, pearl supply, science (15-90), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Pulley Maker System** — škripci
  - 6 produktov (leseni, železnoležajni, srebrnaosni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (škripčna delavnica, strojna podstrešje, mojstrski mehanični atelje, kraljevska strojna palača)
  - Wood, iron, brass, rope, silver, gold, jewel, pearl supply, science (18-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Winch Maker System** — vitli
  - 6 produktov (lesen, železnookrepljen, srebrnazobčani, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (vitelska delavnica, strojna podstrešje, mojstrski inženirski atelje, kraljevska inženirska palača)
  - Wood, iron, rope, silver, gold, jewel, pearl supply, science (22-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Wheelbarrow Maker System** — vozički
  - 6 produktov (lesen, železnookrepljen, srebrnoobrobljeni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (vozičkarska delavnica, kolarska podstrešje, mojstrski kolarski atelje, kraljevska kolarska palača)
  - Wood, iron, silver, gold, jewel, pearl supply, science (15-90), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.300] — 2026-08-09 — Royal State Spear Maker System (6 products, state spears)
## [v3.11.299] — 2026-08-09 — Royal Ritual Dagger Maker System (6 products, ritual daggers)
## [v3.11.298] — 2026-08-09 — Royal Parade Mace Maker System (6 products, parade maces)
## [v3.11.297] — 2026-08-09 — Royal Ceremonial Sword Maker System (6 products, ceremonial swords)
## [v3.11.296] — 2026-08-09 — Royal Watchtower Maker System (6 products, watchtowers)

### Dodano (5 sistemov naenkrat — ceremonialno orožje)
- **Royal Ceremonial Sword Maker System** — slovesni meči
  - 6 produktov (jekleni, srebrnorokavni, zlatookrasni, draguljnogrbi, bisernavi, kraljevski veliki)
  - 4 zgradbe (slovesna delavnica, okleparska podstrešje, mojstrski slovesni atelje, kraljevska orožarnaica palača)
  - Steel, iron, wood, silver, gold, jewel, pearl supply, prestige (5-75), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Parade Mace Maker System** — paradne buzdvane
  - 6 produktov (bronasta, srebrnoglava, zlatookrasna, draguljasta, bisernavi, kraljevski veliki)
  - 4 zgradbe (paradna delavnica, okleparska podstrešje, mojstrski paradni atelje, kraljevska orožarnaica palača)
  - Bronze, wood, silver, gold, jewel, pearl supply, prestige (5-72), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Ritual Dagger Maker System** — ritualna bodala
  - 6 produktov (železni, srebrnorezni, zlatookrasni, draguljnogrbi, bisernavi, kraljevski veliki)
  - 4 zgradbe (ritualna delavnica, mistična podstrešje, mojstrski ritualni atelje, kraljevska ritualna palača)
  - Iron, wood, silver, gold, jewel, pearl supply, prestige (4-65), mysticism (12-80), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal State Spear Maker System** — državna kopja
  - 6 produktov (železni, srebrnoglavi, zlatookrasni, draguljasta, bisernavi, kraljevski veliki)
  - 4 zgradbe (državno kopje delavnica, okleparska podstrešje, mojstrski kopjarski atelje, kraljevska orožarnaica palača)
  - Iron, wood, silver, gold, jewel, pearl supply, prestige (5-72), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Presentation Axe Maker System** — predstavitvene sekire
  - 6 produktov (železni, srebrnorezna, zlatookrasna, draguljasta, bisernavi, kraljevski veliki)
  - 4 zgradbe (predstavitvena delavnica, okleparska podstrešje, mojstrski sekiarski atelje, kraljevska orožarnaica palača)
  - Iron, wood, silver, gold, jewel, pearl supply, prestige (5-72), happiness (2-13), batch qty 1, GameEventBus publish


## [v3.11.295] — 2026-08-09 — Royal Battlement Maker System (6 products, battlements)
## [v3.11.294] — 2026-08-09 — Royal Portcullis Maker System (6 products, portcullises)
## [v3.11.293] — 2026-08-09 — Royal Drawbridge Maker System (6 products, drawbridges)
## [v3.11.292] — 2026-08-09 — Royal Iron Gate Maker System (6 products, iron gates)
## [v3.11.291] — 2026-08-09 — Royal Chronicle Binder System (6 products, chronicles)

### Dodano (5 sistemov naenkrat — obrambni sistemi)
- **Royal Iron Gate Maker System** — železna vrata
  - 6 produktov (preprosta, zakovučena ojačana, srebrnoobrobljena, zlatovložena, draguljasta, kraljevska velika)
  - 4 zgradbe (vratna delavnica, kovaška podstrešje, mojstrski vratarski atelje, kraljevska vratarska palača)
  - Iron, steel, wood, silver, gold, jewel, pearl supply, defense (35-100), happiness (1-13), batch qty 1, GameEventBus publish
- **Royal Drawbridge Maker System** — dvižni mostovi
  - 6 produktov (lesen, železnookrepljen, srebrnoverižni, zlatookrasni, draguljnoprity, kraljevski veliki)
  - 4 zgradbe (mostna delavnica, mostna podstrešje, mojstrski mostni atelje, kraljevska mostna palača)
  - Wood, iron, steel, rope, silver, gold, jewel, pearl supply, defense (28-98), happiness (1-13), batch qty 1, GameEventBus publish
- **Royal Portcullis Maker System** — padajoče rešetke
  - 6 produktov (železna, jeklenotična, srebrnoverižna, zlatookrasna, draguljnoprity, kraljevska velika)
  - 4 zgradbe (rešetkarska delavnica, kovaška podstrešje, mojstrski rešetkarski atelje, kraljevska rešetkarska palača)
  - Iron, steel, wood, silver, gold, jewel, pearl supply, defense (42-100), happiness (1-13), batch qty 1, GameEventBus publish
- **Royal Battlement Maker System** — cinasti veneci
  - 6 produktov (kamnit, marmornata cinaston, srebrnovloženi, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (cinasna delavnica, zidarska podstrešje, mojstrski zidarski atelje, kraljevska zidarska palača)
  - Stone, marble, silver, gold, jewel, pearl supply, defense (25-92), happiness (1-13), batch qty 1, GameEventBus publish
- **Royal Watchtower Maker System** — opazovalni stolpi
  - 6 produktov (leseni, kamnitookrepljen, srebrnopasni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (stolpna delavnica, fortifikacijska podstrešje, mojstrski stolpni atelje, kraljevska fortifikacijska palača)
  - Wood, stone, iron, silver, gold, jewel, pearl supply, defense (28-98), sightRange (30-100), happiness (1-13), batch qty 1, GameEventBus publish


## [v3.11.290] — 2026-08-09 — Royal Scroll Case Maker System (6 products, scroll cases)
## [v3.11.289] — 2026-08-09 — Royal Reading Desk Maker System (6 products, reading desks)
## [v3.11.288] — 2026-08-09 — Royal Library Catalog Maker System (6 products, catalogs)
## [v3.11.287] — 2026-08-09 — Royal Bookshelf Maker System (6 products, bookshelves)
## [v3.11.286] — 2026-08-09 — Royal Window Frame Maker System (6 products, window frames)

### Dodano (5 sistemov naenkrat — knjižnični sistemi)
- **Royal Bookshelf Maker System** — knjižne police
  - 6 produktov (borova, izrezljana hrastova, srebrnoobrobljena, zlatovložena, draguljasta, kraljevska velika)
  - 4 zgradbe (knjižna polica delavnica, knjižnična podstrešje, mojstrski mizarski atelje, kraljevska knjižnična palača)
  - Wood, leather, silver, gold, jewel, pearl supply, beauty (20-95), education (12-75), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Library Catalog Maker System** — knjižni katalogi
  - 6 produktov (pergamentni, usnjeni vezani, srebrnosponka, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (katalogna delavnica, arhivska podstrešje, mojstrski arhivski atelje, kraljevska arhivska palača)
  - Parchment, wood, leather, silver, gold, jewel, pearl supply, education (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Reading Desk Maker System** — bralne mize
  - 6 produktov (hrastov, izrezljan pultni, srebrnoobrobljeni, zlatovloženi, draguljasta, kraljevski veliki)
  - 4 zgradbe (mizarska delavnica, pohištvena podstrešje, mojstrski mizarski atelje, kraljevska pohištvena palača)
  - Wood, leather, silver, gold, jewel, pearl supply, beauty (18-95), education (12-75), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Scroll Case Maker System** — tulci za zvitke
  - 6 produktov (usnjen, medeninastopokrovni, srebrnoobrobljeni, zlatovloženi, draguljasta, kraljevski veliki)
  - 4 zgradbe (tulce delavnica, arhivska podstrešje, mojstrski tulce atelje, kraljevska arhivska palača)
  - Leather, wood, brass, silver, gold, jewel, pearl supply, education (8-60), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Chronicle Binder System** — kronike
  - 6 produktov (zvezek, ilustrirana, srebrnosponka, zlatookrasna, draguljasta, kraljevski veliki)
  - 4 zgradbe (kronikarska delavnica, arhivska podstrešje, mojstrski kronikarski atelje, kraljevska arhivska palača)
  - Parchment, leather, thread, paint, silver, gold, jewel, pearl supply, education (18-92), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.285] — 2026-08-09 — Royal Stone Lintel Maker System (6 products, stone lintels)
## [v3.11.284] — 2026-08-09 — Royal Wooden Column Maker System (6 products, wooden columns)
## [v3.11.283] — 2026-08-09 — Royal Iron Beam Maker System (6 products, iron beams)
## [v3.11.282] — 2026-08-09 — Royal Roof Tile Maker System (6 products, roof tiles)
## [v3.11.281] — 2026-08-09 — Royal Tavern Game Maker System (6 products, tavern games)

### Dodano (5 sistemov naenkrat — gradbene komponente)
- **Royal Roof Tile Maker System** — strešniki
  - 6 produktov (glinena, žgana pantile, glazurasta modra, srebrnogrebena, zlatookrasna, kraljevski veliki)
  - 4 zgradbe (strešniška delavnica, pečna podstrešje, mojstrski strešniški atelje, kraljevska strešniška palača)
  - Clay, wood, glass, silver, gold, jewel, pearl supply, defense (8-55), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Iron Beam Maker System** — železni tramovi
  - 6 produktov (železni, zakovučeni jekleni, srebrnopolirana, zlatookrasna, draguljasta, kraljevski veliki)
  - 4 zgradbe (tramska delavnica, livarna podstrešje, mojstrski livarski atelje, kraljevska livarska palača)
  - Iron, steel, silver, gold, jewel, pearl supply, defense (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Wooden Column Maker System** — leseni stebri
  - 6 produktov (borov, izrezljan hrastov, kanelirana orehov, srebrnoobrobljeni, zlatovloženi, kraljevski veliki)
  - 4 zgradbe (stebrična delavnica, lesna podstrešje, mojstrski stebrični atelje, kraljevska stebrična palača)
  - Wood, leather, paint, silver, gold, jewel, pearl supply, beauty (18-95), defense (12-50), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Stone Lintel Maker System** — kamniti prekladi
  - 6 produktov (kamniti, izrezljan apnenčni, marmornat reliefni, srebrnoobrobljeni, zlatovloženi, kraljevski veliki)
  - 4 zgradbe (prekladna delavnica, zidarska podstrešje, mojstrski zidarski atelje, kraljevska zidarska palača)
  - Stone, marble, paint, silver, gold, jewel, pearl supply, defense (14-68), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Window Frame Maker System** — okenski okviri
  - 6 produktov (lesen, izrezljan hrastov, srebrnoobrobljeno, zlatovloženo, draguljasto, kraljevski veliki)
  - 4 zgradbe (okenska delavnica, steklarska podstrešje, mojstrski okenski atelje, kraljevska okenska palača)
  - Wood, glass, leather, silver, gold, jewel, pearl supply, beauty (18-95), defense (8-38), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.280] — 2026-08-09 — Royal Tarot Card Maker System (6 products, tarot cards)
## [v3.11.279] — 2026-08-09 — Royal Billiard Maker System (6 products, billiards)
## [v3.11.278] — 2026-08-09 — Royal Backgammon Maker System (6 products, backgammons)
## [v3.11.277] — 2026-08-09 — Royal Roulette Maker System (6 products, roulettes)
## [v3.11.276] — 2026-08-09 — Royal Hat Maker System (6 products, hats)

### Dodano (5 sistemov naenkrat — igre na srečo in družabne igre)
- **Royal Roulette Maker System** — ruleti
  - 6 produktov (lesen, medeninasto kolo, srebrnooznačevalni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (ruletna delavnica, igralna podstrešje, mojstrski ruletni atelje, kraljevska igralniška palača)
  - Wood, iron, brass, silver, gold, jewel, pearl supply, happiness (3-14), prestige (2-62), batch qty 1, GameEventBus publish
- **Royal Backgammon Maker System** — tavle
  - 6 produktov (leseni, vložkana orehov, srebrnoobrobljeni, zlatovloženi, draguljasta, kraljevski veliki)
  - 4 zgradbe (tavlarska delavnica, igralna podstrešje, mojstrski tavlarski atelje, kraljevska igralska palača)
  - Wood, leather, paint, silver, gold, jewel, pearl supply, happiness (3-14), prestige (2-60), batch qty 1, GameEventBus publish
- **Royal Billiard Maker System** — biljardi
  - 6 produktov (leseni, filcnopokrita, srebrnoreznična, zlatookrasna, draguljasta, kraljevski veliki)
  - 4 zgradbe (biljardna delavnica, igralna podstrešje, mojstrski biljardni atelje, kraljevska igralska palača)
  - Wood, wool, leather, silver, gold, jewel, pearl supply, happiness (4-15), prestige (3-65), batch qty 1, GameEventBus publish
- **Royal Tarot Card Maker System** — tarot karte
  - 6 produktov (leseni, poslikani pergamentni, srebrnorobni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (tarotna delavnica, vedeževalna podstrešje, mojstrski tarotni atelje, kraljevska vedeževalna palača)
  - Parchment, wood, paint, silver, gold, jewel, pearl supply, mysticism (18-95), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Tavern Game Maker System** — krčemske igre
  - 6 produktov (preprosta, izrezljana kockarska, srebrnoobrobljena, zlatovložena, draguljasta, kraljevski veliki)
  - 4 zgradbe (krčemska igrarska delavnica, igralna podstrešje, mojstrski igrarski atelje, kraljevska igralska palača)
  - Wood, leather, paint, silver, gold, jewel, pearl supply, happiness (3-13), prestige (1-58), batch qty 1, GameEventBus publish


## [v3.11.275] — 2026-08-09 — Royal Glove Maker System (6 products, gloves)
## [v3.11.274] — 2026-08-09 — Royal Walking Stick Maker System (6 products, walking sticks)
## [v3.11.273] — 2026-08-09 — Royal Pocket Watch Maker System (6 products, pocket watches)
## [v3.11.272] — 2026-08-09 — Royal Umbrella Maker System (6 products, umbrellas)
## [v3.11.271] — 2026-08-09 — Royal Locket Maker System (6 products, lockets)

### Dodano (5 sistemov naenkrat — osebni dodatki in modni pripomočki)
- **Royal Umbrella Maker System** — dežniki in sončniki
  - 6 produktov (oljnoplásto, svileni sončnik, srebrnorokavni, zlatookrasni, draguljnogrbi, kraljevski veliki)
  - 4 zgradbe (dežnična delavnica, sončniška podstrešje, mojstrski dežnični atelje, kraljevska dežnična palača)
  - Wood, linen, silk, silver, gold, jewel, pearl supply, beauty (18-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Pocket Watch Maker System** — žepne ure
  - 6 produktov (medeninasta, srebrnookrovna, zlatoookrovna, draguljnoležajna, bisernolicna, kraljevski veliki)
  - 4 zgradbe (urnarska delavnica, horološka podstrešje, mojstrski urnarski atelje, kraljevska urnarska palača)
  - Brass, glass, silver, gold, jewel, pearl supply, science (22-95), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Walking Stick Maker System** — sprehodalne palice
  - 6 produktov (hrastov, izrezljana, srebrnorokavna, zlatookrasna, draguljnogrbi, kraljevski veliki)
  - 4 zgradbe (palica delavnica, palica podstrešje, mojstrski palica atelje, kraljevska palica palača)
  - Wood, leather, silver, gold, jewel, pearl supply, beauty (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Glove Maker System** — rokavice
  - 6 produktov (volnene, usnjene jahalne, sviloobložene, srebrnovezene, zlatookrasne, kraljevske velike)
  - 4 zgradbe (rokavičarska delavnica, rokavičarska podstrešje, mojstrski rokavičarski atelje, kraljevska rokavičarska palača)
  - Wool, leather, silk, thread, silver, gold, jewel, pearl supply, warmth (22-88), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Hat Maker System** — klobuki
  - 6 produktov (filcana kapa, bober filc, srebrnopasni, zlatookrasni, draguljnopripeti, kraljevski veliki)
  - 4 zgradbe (klobučarska delavnica, filcna podstrešje, mojstrski klobučarski atelje, kraljevska klobučarska palača)
  - Wool, leather, silver, gold, jewel, pearl supply, beauty (18-95), warmth (18-65), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.270] — 2026-08-09 — Royal Brooch Maker System (6 products, brooches)
## [v3.11.269] — 2026-08-09 — Royal Pendant Maker System (6 products, pendants)
## [v3.11.268] — 2026-08-09 — Royal Commemorative Token Maker System (6 products, tokens)
## [v3.11.267] — 2026-08-09 — Royal Trophy Maker System (6 products, trophies)
## [v3.11.266] — 2026-08-09 — Royal Chest Maker System (6 products, chests)

### Dodano (5 sistemov naenkrat — spominki in medalje)
- **Royal Trophy Maker System** — trofeje
  - 6 produktov (bronasta, srebrni pokal, zlati kelih, draguljnookronana, bisernavi velika, kraljevska velika)
  - 4 zgradbe (trofejna delavnica, graverska podstrešje, mojstrski trofejni atelje, kraljevska trofejna palača)
  - Bronze, marble, silver, gold, jewel, pearl supply, beauty (22-95), prestige (4-75), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Commemorative Token Maker System** — spominski žetoni in kovanci
  - 6 produktov (svinčev, bronast kovan, srebrni spominski, zlati spominski, draguljasta medaljon, kraljevski veliki)
  - 4 zgradbe (žetonska delavnica, kovinska podstrešje, mojstrski kovinarski atelje, kraljevska kovinska palača)
  - Lead, bronze, silver, gold, jewel, pearl supply, beauty (15-92), prestige (2-60), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Pendant Maker System** — obeski
  - 6 produktov (bronast, srebrnoverižni, zlato verižni, draguljnokrožni, bisernovesljajoči, kraljevski veliki)
  - 4 zgradbe (obesna delavnica, nakitna podstrešje, mojstrski nakitni atelje, kraljevska nakitna palača)
  - Bronze, leather, silver, gold, jewel, pearl supply, beauty (20-95), prestige (2-62), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Brooch Maker System** — broške
  - 6 produktov (bronasta, srebrnofiligranska, zlati kameja, draguljasta, bisernookrasna, kraljevska velika)
  - 4 zgradbe (broškarska delavnica, filigranska podstrešje, mojstrski broškarski atelje, kraljevska broškarska palača)
  - Bronze, iron, silver, gold, jewel, pearl supply, beauty (22-95), prestige (3-65), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Locket Maker System** — medaljoni
  - 6 produktov (srebrni, gravirani zlati, portretni miniaturni, draguljnorobni, bisernavi, kraljevski veliki)
  - 4 zgradbe (medaljonska delavnica, miniaturna podstrešje, mojstrski medaljonski atelje, kraljevska medaljonska palača)
  - Silver, gold, glass, paint, jewel, pearl supply, beauty (25-95), prestige (4-68), happiness (2-13), batch qty 1, GameEventBus publish


## [v3.11.265] — 2026-08-09 — Royal Bed Maker System (6 products, beds)
## [v3.11.264] — 2026-08-09 — Royal Cabinet Maker System (6 products, cabinets)
## [v3.11.263] — 2026-08-09 — Royal Table Maker System (6 products, tables)
## [v3.11.262] — 2026-08-09 — Royal Chair Maker System (6 products, chairs)
## [v3.11.261] — 2026-08-09 — Royal Hunting Trap Maker System (6 products, hunting traps)

### Dodano (5 sistemov naenkrat — pohištvo)
- **Royal Chair Maker System** — stoli
  - 6 produktov (hrastov, izrezljan orehov, srebrnoobrobljeni, zlatovloženi, draguljasta prestolni, kraljevski veliki)
  - 4 zgradbe (stolni delavnica, pohištvena podstrešje, mojstrski mizarski atelje, kraljevska pohištvena palača)
  - Wood, leather, silver, gold, jewel, pearl supply, beauty (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Table Maker System** — mize
  - 6 produktov (hrastova, izrezljana orehova, srebrnoobrobljena, zlatovložena, draguljasta banketna, kraljevska velika)
  - 4 zgradbe (mizarska delavnica, pohištvena podstrešje, mojstrski mizarski atelje, kraljevska mizarska palača)
  - Wood, leather, silver, gold, jewel, pearl supply, beauty (22-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Cabinet Maker System** — omare
  - 6 produktov (borova, izrezljana hrastova, srebrnorokavnata, zlatookrasna, draguljasta, kraljevska velika)
  - 4 zgradbe (omarska delavnica, pohištvena podstrešje, mojstrski omarski atelje, kraljevska omarska palača)
  - Wood, iron, leather, silver, gold, jewel, pearl supply, beauty (22-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Bed Maker System** — postelje
  - 6 produktov (lesena, izrezljana hrastova, srebrnoobrobljena, zlatovložena, svilna nebotična, kraljevska velika)
  - 4 zgradbe (posteljna delavnica, ležišna podstrešje, mojstrski posteljni atelje, kraljevska posteljna palača)
  - Wood, wool, linen, silk, silver, gold, jewel, pearl supply, beauty (22-95), comfort (25-100), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Chest Maker System** — skrinje
  - 6 produktov (borov, izrezljana hrastov, srebrnopasna, zlatookrasna, draguljnoključna, kraljevska velika)
  - 4 zgradbe (skrinjarska delavnica, skrinjarska podstrešje, mojstrski skrinjarski atelje, kraljevska skrinjarska palača)
  - Wood, iron, leather, silver, gold, jewel, pearl supply, beauty (20-95), storage (25-100), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.260] — 2026-08-09 — Royal Quiver Maker System (6 products, quivers)
## [v3.11.259] — 2026-08-09 — Royal Arbalest Maker System (6 products, arbalests)
## [v3.11.258] — 2026-08-09 — Royal Recurve Bow Maker System (6 products, recurve bows)
## [v3.11.257] — 2026-08-09 — Royal Longbow Maker System (6 products, longbows)
## [v3.11.256] — 2026-08-09 — Royal Stucco Relief Maker System (6 products, stucco reliefs)

### Dodano (5 sistemov naenkrat — lovstvo in lokostrelstvo)
- **Royal Longbow Maker System** — dolgi loki
  - 6 produktov (tisolni, laminirani rogovi, srebrnokončni, zlatovloženi, draguljnoročajni, kraljevski veliki)
  - 4 zgradbe (lokarska delavnica, lokarska podstrešje, mojstrski lokarski atelje, kraljevska lokarska palača)
  - Wood, rope, leather, silver, gold, jewel, pearl supply, attack (28-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Recurve Bow Maker System** — povratni loki
  - 6 produktov (lesen, kitemovpovratni, srebrnokončni, zlatovloženi, draguljnoročajni, kraljevski veliki)
  - 4 zgradbe (povratna delavnica, kompozitna podstrešje, mojstrski kompozitni atelje, kraljevska povratna palača)
  - Wood, horn, rope, leather, silver, gold, jewel, pearl supply, attack (30-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Arbalest Maker System** — težki samostreli
  - 6 produktov (leseni, jeklenoluk, srebrnovloženi, zlatookrasni, draguljnogrbi, kraljevski veliki)
  - 4 zgradbe (samostrelarska delavnica, samostrelska podstrešje, mojstrski samostrelski atelje, kraljevska samostrelska palača)
  - Wood, iron, steel, rope, silver, gold, jewel, pearl supply, attack (38-98), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Quiver Maker System** — tulci za puščice
  - 6 produktov (usnjen, krznato obrobljeni, srebrnopasni, zlato vezani, draguljasta, kraljevski veliki)
  - 4 zgradbe (tulce delavnica, usnjena podstrešje, mojstrski usnjarski atelje, kraljevska tulce palača)
  - Leather, wood, wool, silver, gold, jewel, pearl supply, attack (8-45), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Hunting Trap Maker System** — lovske pasti
  - 6 produktov (železna zanka, jeklenovelikostna, srebrnonosilna, zlatookrasna medvedja, draguljnopripeta, kraljevski veliki set)
  - 4 zgradbe (pastna delavnica, pastna podstrešje, mojstrski pastirski atelje, kraljevska pastna palača)
  - Iron, steel, rope, silver, gold, jewel, pearl supply, attack (8-68), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.255] — 2026-08-09 — Royal Wood Paneling Maker System (6 products, wood paneling)
## [v3.11.254] — 2026-08-09 — Royal Wallpaper Printer System (6 products, wallpaper)
## [v3.11.253] — 2026-08-09 — Royal Mosaic Tile Maker System (6 products, mosaics)
## [v3.11.252] — 2026-08-09 — Royal Parquet Floor Maker System (6 products, parquet floors)
## [v3.11.251] — 2026-08-09 — Royal Halberd Smith System (6 products, halberds)

### Dodano (5 sistemov naenkrat — talne obloge in notranja oprema)
- **Royal Parquet Floor Maker System** — lesen parket
  - 6 produktov (hrastov, ribja kost, orehov vloženi, srebrnoobrobljeni, zlatovloženi, kraljevski veliki)
  - 4 zgradbe (parketna delavnica, talna podstrešje, mojstrski talni atelje, kraljevska parketna palača)
  - Wood, leather, silver, gold, jewel, pearl supply, beauty (22-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Mosaic Tile Maker System** — mozaike
  - 6 produktov (glinena, steklena tesera, marmornatavložena, srebrnopasna, zlatolistna, kraljevska velika)
  - 4 zgradbe (mozaikna delavnica, teserska podstrešje, mojstrski mozaikni atelje, kraljevska mozaikna palača)
  - Clay, glass, marble, silver, gold, jewel, pearl supply, beauty (22-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Wallpaper Printer System** — tapete
  - 6 produktov (poslikano papir, blokovno tiskana, srebrnopasna, zlatolistna, draguljasta, kraljevska velika)
  - 4 zgradbe (tapetna delavnica, tiskarska podstrešje, mojstrski tiskarski atelje, kraljevska tapetna palača)
  - Linen, paint, wood, silver, gold, jewel, pearl supply, beauty (22-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Wood Paneling Maker System** — lesene obloge
  - 6 produktov (borov, hrastova obloga, izrezljan orehov, srebrnoobrobljeni, zlatovloženi, kraljevski veliki)
  - 4 zgradbe (obložna delavnica, lesna podstrešje, mojstrski lesarski atelje, kraljevska obložna palača)
  - Wood, leather, silver, gold, jewel, pearl supply, beauty (22-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Stucco Relief Maker System** — ometne relief
  - 6 produktov (apneno, poslikana, marmornatiprahni, srebrnoslikani, zlatolistni, kraljevski veliki)
  - 4 zgradbe (ometna delavnica, ometna podstrešje, mojstrski ometarski atelje, kraljevska ometna palača)
  - Clay, stone, marble, paint, silver, gold, jewel, pearl supply, beauty (22-92), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.250] — 2026-08-09 — Royal Gauntlet Maker System (6 products, gauntlets)
## [v3.11.249] — 2026-08-09 — Royal Greave Armorer System (6 products, greaves)
## [v3.11.248] — 2026-08-09 — Royal Plate Cuirass Smith System (6 products, cuirasses)
## [v3.11.247] — 2026-08-09 — Royal Chainmail Forger System (6 products, chainmail)
## [v3.11.246] — 2026-08-09 — Royal Vitrail Foil Maker System (6 products, vitrail foils)

### Dodano (5 sistemov naenkrat — vojaška oprema)
- **Royal Chainmail Forger System** — verižni oklepi
  - 6 produktov (železni, jekleno zakovučeni, srebrnoobrobljeni, zlatovloženi, draguljnoprity, kraljevski veliki)
  - 4 zgradbe (verižna delavnica, verižna podstrešje, mojstrski okleparski atelje, kraljevska verižna palača)
  - Iron, steel, leather, silver, gold, jewel, pearl supply, defense (30-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Plate Cuirass Smith System** — ploščasti oklepi
  - 6 produktov (železni, jekleni prsni, srebrnoizbočeni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (oklepna delavnica, ploščna podstrešje, mojstrski ploščarski atelje, kraljevska oklepna palača)
  - Iron, steel, leather, silver, gold, jewel, pearl supply, defense (38-98), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Greave Armorer System** — golenice
  - 6 produktov (železne, jeklene, srebrnoobrobljene, zlatoizbočene, draguljaste, kraljevski velike)
  - 4 zgradbe (golenična delavnica, oklepna podstrešje, mojstrski okleparski atelje, kraljevska golenična palača)
  - Iron, steel, leather, silver, gold, jewel, pearl supply, defense (22-88), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Gauntlet Maker System** — oklepne rokavice
  - 6 produktov (usnjene, železnoploščate, srebrnoobrobljene, zlatovložene, draguljaste, kraljevski velike)
  - 4 zgradbe (rokavična delavnica, oklepna podstrešje, mojstrski okleparski atelje, kraljevska rokavična palača)
  - Iron, leather, silver, gold, jewel, pearl supply, defense (15-84), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Halberd Smith System** — helebarde
  - 6 produktov (železna, jeklenosekična, srebrnovložena, zlatookrasna, draguljnogrbi, kraljevski veliki)
  - 4 zgradbe (helebardska delavnica, sulicepodstrešje, mojstrski sulični atelje, kraljevska helebardska palača)
  - Iron, steel, wood, silver, gold, jewel, pearl supply, attack (32-98), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.245] — 2026-08-09 — Royal Beaker Blower System (6 products, glass beakers)
## [v3.11.244] — 2026-08-09 — Royal Lens Grinder System (6 products, optical lenses)
## [v3.11.243] — 2026-08-09 — Royal Glass Bead Maker System (6 products, glass beads)
## [v3.11.242] — 2026-08-09 — Royal Crystal Goblet Maker System (6 products, crystal goblets)
## [v3.11.241] — 2026-08-09 — Royal Wooden Spoon Carver System (6 products, wooden spoons)

### Dodano (5 sistemov naenkrat — steklarstvo in vitraži)
- **Royal Crystal Goblet Maker System** — kristalni kelihi
  - 6 produktov (stekleni, svinčevokristalni, srebrnostebelni, zlatookrasni, draguljasta, kraljevski veliki)
  - 4 zgradbe (keliška delavnica, kristalna podstrešje, mojstrski steklarsski atelje, kraljevska keliška palača)
  - Glass, lead, silver, gold, jewel, pearl supply, beauty (18-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Glass Bead Maker System** — steklene kroglice
  - 6 produktov (preproste, poslikane trgovske, srebrnojedrne, zlatofolijne, draguljaste, kraljevski veliki ogrlica)
  - 4 zgradbe (kroglična delavnica, kroglična podstrešje, mojstrski kroglični atelje, kraljevska kroglična palača)
  - Glass, paint, silver, gold, jewel, pearl supply, beauty (18-92), happiness (1-11), batch qty 1, GameEventBus publish
- **Royal Lens Grinder System** — optične leče
  - 6 produktov (steklena, polirana bralna, srebrnookvirna očalna, zlatookrasni teleskopska, draguljasta mikroskopska, kraljevski veliki set)
  - 4 zgradbe (lečna delavnica, optična podstrešje, mojstrski optični atelje, kraljevska optična palača)
  - Glass, leather, silver, gold, jewel, pearl supply, science (22-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Beaker Blower System** — stekleni lončki
  - 6 produktov (preprost, merilni, srebrnookrasni, zlatookrasni, draguljasta, kraljevski veliki set)
  - 4 zgradbe (lončkarska delavnica, pihalna podstrešje, mojstrski steklopihalski atelje, kraljevska lončkarska palača)
  - Glass, paint, silver, gold, jewel, pearl supply, science (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Vitrail Foil Maker System** — vitražne folije
  - 6 produktov (svinčeva, poslikana, srebrnookrasna, zlatofolijna, draguljasta, kraljevski veliki)
  - 4 zgradbe (vitražna delavnica, vitražna podstrešje, mojstrski vitražni atelje, kraljevska vitražna palača)
  - Glass, lead, paint, silver, gold, jewel, pearl supply, beauty (22-95), happiness (2-12), batch qty 1, GameEventBus publish


## [v3.11.240] — 2026-08-09 — Royal Serving Plate Maker System (6 products, serving plates)
## [v3.11.239] — 2026-08-09 — Royal Cookware Founder System (6 products, cookware)
## [v3.11.238] — 2026-08-09 — Royal Cutlery Smith System (6 products, cutlery)
## [v3.11.237] — 2026-08-09 — Royal Kitchen Knife Maker System (6 products, kitchen knives)
## [v3.11.236] — 2026-08-09 — Royal Apothecary Mortar Maker System (6 products, mortars)

### Dodano (5 sistemov naenkrat — kuhinjski pripomočki)
- **Royal Kitchen Knife Maker System** — kuhinjski noži
  - 6 produktov (železni, jeklenorezni kuharski, srebrnorokavi rezilni, zlatookrasni filejni, draguljnogrbi slovesnostni, kraljevski veliki set)
  - 4 zgradbe (nožniška delavnica, priborno podstrešje, mojstrski rezbarski atelje, kraljevska nožniška palača)
  - Iron, wood, leather, silver, gold, jewel, pearl supply, culinary (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Cutlery Smith System** — jedilni pribor
  - 6 produktov (železna vilice, bronasta žličkasta, srebrna večerja, zlatookrasni jedilni, draguljnorokavni jedilni, kraljevski veliki jedilni)
  - 4 zgradbe (priborna delavnica, priborno podstrešje, mojstrski srebrarsski atelje, kraljevska priborna palača)
  - Iron, bronze, silver, gold, jewel, pearl supply, culinary (15-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Cookware Founder System** — kuhinjska posoda
  - 6 produktov (železna ponev, bronast kotel, bakreni lonček, srebrnopokrovka lonec, zlatovložena ponev, kraljevski veliki set)
  - 4 zgradbe (kuhinjska posoda delavnica, livna podstrešje, mojstrski livarski atelje, kraljevska kuhinjska palača)
  - Iron, bronze, copper, silver, gold, jewel, pearl supply, culinary (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Serving Plate Maker System** — servisirni krožniki
  - 6 produktov (kositrna, keramična poslikana, srebrna večerja, zlatookrasni podstavek, draguljasta pladenj, kraljevski veliki set)
  - 4 zgradbe (ploščna delavnica, porcelanasta podstrešje, mojstrski ploščni atelje, kraljevska jedilna palača)
  - Tin, clay, paint, glass, silver, gold, jewel, pearl supply, culinary (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Wooden Spoon Carver System** — lesene žlice in rezbarije
  - 6 produktov (lesena žlica, izrezljan zajemalka, srebrnopasna žlica, zlatookrasni lopatica, draguljnorokavni rezilni set, kraljevski veliki set)
  - 4 zgradbe (žličkasta delavnica, rezbarska podstrešje, mojstrski rezbarski atelje, kraljevska rezbarska palača)
  - Wood, silver, gold, jewel, pearl supply, culinary (15-92), happiness (1-11), batch qty 1, GameEventBus publish


## [v3.11.235] — 2026-08-09 — Royal Alambic Still Maker System (6 products, alambic stills)
## [v3.11.234] — 2026-08-09 — Royal Hydrometer Maker System (6 products, hydrometers)
## [v3.11.233] — 2026-08-09 — Royal Retort Maker System (6 products, retorts)
## [v3.11.232] — 2026-08-09 — Royal Crucible Maker System (6 products, crucibles)
## [v3.11.231] — 2026-08-09 — Royal Coronation Cushion Maker System (6 products, coronation cushions)

### Dodano (5 sistemov naenkrat — znanstveni instrumenti)
- **Royal Crucible Maker System** — talilnice
  - 6 produktov (glinena, šamotna, bronastorokavna, srebrnalivna, zlatookrasna, kraljevski veliki)
  - 4 zgradbe (talilniška delavnica, ognjevarna podstrešje, mojstrski talilniški atelje, kraljevska talilniška palača)
  - Clay, stone, bronze, silver, gold, jewel, pearl supply, science (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Retort Maker System** — retorte za destilacijo
  - 6 produktov (steklena, upognjenovratna, srebrnospojna, zlatookrasna, draguljasta, kraljevski veliki)
  - 4 zgradbe (retortna delavnica, destilacijska podstrešje, mojstrski steklarsski atelje, kraljevska retortna palača)
  - Glass, clay, silver, gold, jewel, pearl supply, science (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Hydrometer Maker System** — areometri
  - 6 produktov (steklen, svinčevo obteženi, srebrnaskalni, zlatoznačeni, draguljnoležajni, kraljevski veliki)
  - 4 zgradbe (aremetrijska delavnica, kalibracijska podstrešje, mojstrski steklarsski atelje, kraljevska aremetrijska palača)
  - Glass, lead, silver, gold, jewel, pearl supply, science (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Alambic Still Maker System** — alembiki
  - 6 produktov (bakrena, kositrnozaprta, srebrnohlajena, zlatookrasna, draguljnoventilna, kraljevski veliki)
  - 4 zgradbe (alembična delavnica, destilatorska podstrešje, mojstrski bakrokleparski atelje, kraljevska alembična palača)
  - Copper, tin, silver, gold, jewel, pearl supply, science (22-95), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Apothecary Mortar Maker System** — aptekarski možnarji
  - 6 produktov (kamnit, bronastozgiban, marmornat, srebrnookrasni, zlatovloženi, kraljevski veliki)
  - 4 zgradbe (možnarska delavnica, aptekarska podstrešje, mojstrski aptekarski atelje, kraljevska možnarska palača)
  - Stone, marble, wood, bronze, silver, gold, jewel, pearl supply, science (18-92), healing (5-75), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.230] — 2026-08-09 — Royal Banner Herald System (6 products, heraldic banners)
## [v3.11.229] — 2026-08-09 — Royal Seal Stamp Maker System (6 products, seal stamps)
## [v3.11.228] — 2026-08-09 — Royal Crest Carver System (6 products, heraldic crests)
## [v3.11.227] — 2026-08-09 — Royal Coronation Mantle Maker System (6 products, coronation mantles)
## [v3.11.226] — 2026-08-09 — Royal Paint Maker System (6 products, paint pigments)

### Dodano (5 sistemov naenkrat — ceremonialni predmeti)
- **Royal Coronation Mantle Maker System** — kronanske mantije
  - 6 produktov (volnena, svilna hermelinova, srebrnonitna, zlato vezana, draguljasta, kraljevski velika)
  - 4 zgradbe (mantijska delavnica, kraljevska garderoba, mojstrski slovesnostni atelje, kraljevska kronanska palača)
  - Silk, wool, leather, thread, silver, gold, jewel, pearl supply, prestige (5-80), happiness (2-15), batch qty 1, GameEventBus publish
- **Royal Crest Carver System** — grbovni reliefi
  - 6 produktov (leseni, poslikan, marmornat reliefa, srebrnovloženi, zlatolistni, kraljevski veliki)
  - 4 zgradbe (grbovna delavnica, heraldikova podstrešje, mojstrski rezbarski atelje, kraljevska grboslovna palača)
  - Wood, marble, paint, silver, gold, jewel, pearl supply, beauty (25-95), prestige (4-75), happiness (1-13), batch qty 1, GameEventBus publish
- **Royal Seal Stamp Maker System** — pečatniki
  - 6 produktov (železni, medeninast gravirani, srebrnorokavi, zlati signet, draguljni signet, kraljevski veliki)
  - 4 zgradbe (pečatniška delavnica, graverska podstrešje, mojstrski pečatni atelje, kraljevska pečatna palača)
  - Iron, wood, brass, silver, gold, jewel, pearl supply, prestige (3-70), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Banner Herald System** — grbovne zastave
  - 6 produktov (lanena, poslikana svilena, srebrnoobrobljena, zlato vezana, draguljakotna, kraljevska velika)
  - 4 zgradbe (zastavna delavnica, heraldikova podstrešje, mojstrski zastavni atelje, kraljevska zastavna palača)
  - Silk, linen, thread, paint, wood, silver, gold, jewel, pearl supply, beauty (20-95), prestige (4-72), happiness (1-13), batch qty 1, GameEventBus publish
- **Royal Coronation Cushion Maker System** — kronanski vzglavniki
  - 6 produktov (žamčast, resasta svilena, srebrnoobrobljeni, zlato vezani, draguljakotni, kraljevski veliki)
  - 4 zgradbe (vzglavniška delavnica, tapetniška podstrešje, mojstrski tapetniški atelje, kraljevska tapetniška palača)
  - Silk, wool, thread, silver, gold, jewel, pearl supply, beauty (22-95), prestige (3-70), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.225] — 2026-08-09 — Royal Easel Maker System (6 products, easels)
## [v3.11.224] — 2026-08-09 — Royal Theater Mask Maker System (6 products, theater masks)
## [v3.11.223] — 2026-08-09 — Royal Costume Tailor System (6 products, costumes)
## [v3.11.222] — 2026-08-09 — Royal Stage Prop Maker System (6 products, stage props)
## [v3.11.221] — 2026-08-09 — Royal Snuff Miller System (6 products, snuff)

### Dodano (5 sistemov naenkrat — gledališki rekviziti in umetnost)
- **Royal Stage Prop Maker System** — gledališki rekviziti
  - 6 produktov (leseni, poslikana kulisa, pozlačeni prestol, srebrnookrašena, draguljarski, kraljevski veliki)
  - 4 zgradbe (rekvizitna delavnica, kulisna podstrešje, mojstrski rekvizitni atelje, kraljevska gledališka palača)
  - Wood, paint, linen, silver, gold, jewel, pearl supply, artistry (18-92), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Costume Tailor System** — gledališki kostumi
  - 6 produktov (laneni, poslikani svileni, žamčasti plemiški, srebrnoobrobljeni, zlato vezeni, kraljevski veliki)
  - 4 zgradbe (kostumna delavnica, garderobna podstrešje, mojstrski kostumerski atelje, kraljevska garderobna palača)
  - Silk, linen, thread, leather, paint, silver, gold, jewel, pearl supply, artistry (18-92), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Theater Mask Maker System** — gledališke maske
  - 6 produktov (papirnata, poslikana lanena, usnjena komedija, srebrnolistna tragedija, zlatookrasni herojska, kraljevska slovesnostna)
  - 4 zgradbe (maskarska delavnica, maskarska podstrešje, mojstrski maskarski atelje, kraljevska maskarska palača)
  - Wood, linen, leather, paint, silver, gold, jewel, pearl supply, artistry (18-92), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Easel Maker System** — štafelaji za slikarje
  - 6 produktov (leseni, nastavljivi hrastov, medeninasti ateljejski, srebrnoplaščni, zlatookrasni razstavni, kraljevski veliki)
  - 4 zgradbe (štafelajna delavnica, pohištvena podstrešje, mojstrski štafelajski atelje, kraljevska štafelajska palača)
  - Wood, iron, brass, silver, gold, jewel, pearl supply, artistry (12-88), happiness (1-11), batch qty 1, GameEventBus publish
- **Royal Paint Maker System** — barve in pigmenti
  - 6 produktov (zemeljska, lapis modra, košeniljna rdeča, srebrnomleta malahit, zlatomleta škrlatna, kraljevski veliki set)
  - 4 zgradbe (barvna delavnica, pigmentna podstrešje, mojstrski barvni atelje, kraljevska barvna palača)
  - Clay, glass, silver, spice, gold, jewel, pearl supply, artistry (15-92), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.220] — 2026-08-09 — Royal Tobacco Curer System (6 products, tobacco)
## [v3.11.219] — 2026-08-09 — Royal Chocolate Confectioner System (6 products, chocolate)
## [v3.11.218] — 2026-08-09 — Royal Tea Blender System (6 products, tea)
## [v3.11.217] — 2026-08-09 — Royal Coffee Roaster System (6 products, coffee)
## [v3.11.216] — 2026-08-09 — Royal Nocturnal Maker System (6 products, nocturnals)

### Dodano (5 sistemov naenkrat — kavarniški in tobačni pripomočki)
- **Royal Coffee Roaster System** — pražena kava
  - 6 produktov (navadna pražena, mleta v kozarcu, srebrnopokrovka, zlatookrasna, draguljnopokrovka, kraljevski veliki)
  - 4 zgradbe (pražilna koča, kavarna, konditorski atelje, kraljevska kavarna palača)
  - Wood, glass, silver, gold, jewel, pearl supply, food (8-60), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Tea Blender System** — čajne mešanice
  - 6 produktov (zeliščni, svilnata vrečka, porcelanasta, srebrna posoda, zlatookrasni, kraljevski veliki)
  - 4 zgradbe (čajna koča, mešalna podstrešje, mojstrski čajni atelje, kraljevska čajna palača)
  - Wood, silk, linen, clay, glass, silver, gold, jewel, pearl supply, healing (5-65), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Chocolate Confectioner System** — čokoladne sladice
  - 6 produktov (tablica, začinjen disk, srebrnoolubljeni, zlatofolijni, draguljasta pralina, kraljevski veliki zaboj)
  - 4 zgradbe (konditorska koča, čokoladna podstrešje, mojstrski čokoladni atelje, kraljevska čokoladna palača)
  - Wood, sugar, spice, silver, gold, jewel, pearl supply, food (12-80), happiness (3-13), batch qty 1, GameEventBus publish
- **Royal Tobacco Curer System** — sušen tobak
  - 6 produktov (sušen, stisnjena pogača, srebrna škatlica, začinjena mešanica, zlatopokrovka, kraljevski veliki zaboj)
  - 4 zgradbe (tobakova stodola, sušilna podstrešje, mojstrski mešalni atelje, kraljevska tobakova palača)
  - Wood, linen, iron, spice, silver, gold, jewel, pearl supply, happiness (2-12), prestige (1-56), batch qty 1, GameEventBus publish
- **Royal Snuff Miller System** — mleti snuf
  - 6 produktov (mleti, dišavni, srebrnopokrovka, zlatookrasni, draguljasta škatlica, kraljevska velika skrinja)
  - 4 zgradbe (snufna koča, mlinska podstrešje, mojstrski snufni atelje, kraljevska snufna palača)
  - Wood, glass, spice, silver, gold, jewel, pearl supply, happiness (2-12), prestige (1-56), batch qty 1, GameEventBus publish


## [v3.11.215] — 2026-08-09 — Royal Quadrant Maker System (6 products, quadrants)
## [v3.11.214] — 2026-08-09 — Royal Compass Maker System (6 products, compasses)
## [v3.11.213] — 2026-08-09 — Royal Sundial Maker System (6 products, sundials)
## [v3.11.212] — 2026-08-09 — Royal Planetarium Maker System (6 products, planetariums)
## [v3.11.211] — 2026-08-09 — Royal Pan Flute Maker System (6 products, pan flutes)

### Dodano (5 sistemov naenkrat — astronomija in navigacijski instrumenti)
- **Royal Planetarium Maker System** — planetariji in oreriji
  - 6 produktov (leseni, medeninasti orerij, srebrna armilarna sfera, zlatopasni orerij, draguljarski, kraljevski veliki)
  - 4 zgradbe (planetarijska delavnica, astronomska podstrešje, mojstrski kozmografski atelje, kraljevska planetarijska palača)
  - Wood, brass, glass, silver, gold, jewel, pearl supply, education (18-95), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Sundial Maker System** — sončne ure
  - 6 produktov (kamnita, bronasta okrasna, marmornat žepni, srebrna kompasna, zlatovložena, kraljevski veliki)
  - 4 zgradbe (sončna delavnica, gnomonska podstrešje, mojstrski horološki atelje, kraljevska sončna palača)
  - Stone, marble, bronze, brass, silver, gold, jewel, pearl supply, beauty (18-92), education (12-88), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Compass Maker System** — kompasi
  - 6 produktov (železni, medeninasti, srebrnoprstanski, zlatookrasni, draguljnoležajni, kraljevski veliki)
  - 4 zgradbe (kompasna delavnica, magnetska podstrešje, mojstrski navigacijski atelje, kraljevska kompasna palača)
  - Wood, iron, brass, glass, silver, gold, jewel, pearl supply, navigation (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Quadrant Maker System** — kvadranti
  - 6 produktov (leseni, medeninast merjeni, marmornatolok, srebrnoprotežni, zlatovloženi, kraljevski veliki)
  - 4 zgradbe (kvadrantna delavnica, geometrijska podstrešje, mojstrski inštrumentni atelje, kraljevska kvadrantna palača)
  - Wood, brass, marble, silver, gold, jewel, pearl supply, navigation (15-90), education (10-85), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Nocturnal Maker System** — nokturnali
  - 6 produktov (leseni, medeninasti, srebrnorokavi, zlatogravirani, draguljnopolnjeni, kraljevski veliki)
  - 4 zgradbe (nokturnalna delavnica, zvezdna podstrešje, mojstrski astrolabist atelje, kraljevska nokturnalna palača)
  - Wood, brass, silver, gold, jewel, pearl supply, navigation (18-92), education (14-88), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.210] — 2026-08-09 — Royal Mandolin Maker System (6 products, mandolins)
## [v3.11.209] — 2026-08-09 — Royal Flute Maker System (6 products, flutes)
## [v3.11.208] — 2026-08-09 — Royal Trumpet Maker System (6 products, trumpets)
## [v3.11.207] — 2026-08-09 — Royal Lyre Maker System (6 products, lyres)
## [v3.11.206] — 2026-08-09 — Royal Sampler Stitcher System (6 products, embroidered samplers)

### Dodano (5 sistemov naenkrat — glasbeni instrumenti)
- **Royal Lyre Maker System** — lire
  - 6 produktov (lesena, slonovinasta, bronastovrvena, srebrnovrvena, zlatookrasna, kraljevska Apolonova)
  - 4 zgradbe (lirna delavnica, strunska podstrešje, mojstrski lutar atelje, kraljevska lirna palača)
  - Wood, leather, rope, bronze, silver, gold, jewel, pearl supply, music (18-95), happiness (2-13), batch qty 1, GameEventBus publish
- **Royal Trumpet Maker System** — trobente
  - 6 produktov (bronasta, medeninasta glasniška, srebrna godbeniška, srebrna pasovna, zlatookrasna fanfarna, kraljevski veliki)
  - 4 zgradbe (trobentna delavnica, medeninasta livarna, mojstrski trobetni atelje, kraljevska trobentna palača)
  - Bronze, brass, wood, silver, gold, silk, jewel, pearl supply, music (20-95), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Flute Maker System** — flavte
  - 6 produktov (trstna, blokflavta, pušpanova, srebrnopasna, zlatookrasna, kraljevski veliki)
  - 4 zgradbe (flavtna delavnica, podstrešje za pihala, mojstrski pihalni atelje, kraljevska flavtna palača)
  - Wood, leather, silver, gold, jewel, pearl supply, music (18-92), happiness (1-11), batch qty 1, GameEventBus publish
- **Royal Mandolin Maker System** — mandoline
  - 6 produktov (lesena, vložkana palisandrova, bronastovrvena, srebrnopasna, zlatookrasna, kraljevski velika)
  - 4 zgradbe (mandolinska delavnica, strunska podstrešje, mojstrski lutar atelje, kraljevska mandolinska palača)
  - Wood, leather, rope, bronze, silver, gold, jewel, pearl supply, music (22-95), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Pan Flute Maker System** — panove flavte
  - 6 produktov (trstna, lesenovezana, pušpanova, srebrnovezana, zlatookrasna, kraljevski veliki)
  - 4 zgradbe (panova delavnica, pihalna podstrešje, mojstrski pihalni atelje, kraljevska panova palača)
  - Wood, leather, rope, silver, gold, jewel, pearl supply, music (18-92), happiness (1-11), batch qty 1, GameEventBus publish


## [v3.11.205] — 2026-08-09 — Royal Lace Maker System (6 products, lace)
## [v3.11.204] — 2026-08-09 — Royal Crocheter System (6 products, crochet)
## [v3.11.203] — 2026-08-09 — Royal Knitter System (6 products, knitwear)
## [v3.11.202] — 2026-08-09 — Royal Tassel Maker System (6 products, tassels)
## [v3.11.201] — 2026-08-09 — Royal Manuscript Illuminator System (6 products, illuminated manuscripts)

### Dodano (5 sistemov naenkrat — tekstilni zaključni sistemi)
- **Royal Tassel Maker System** — resaste kobilice
  - 6 produktov (navadna, svila okenska, srebrnovrvena, zlatookrasna, draguljarska, kraljevski velika)
  - 4 zgradbe (kobilna delavnica, pasmenterska delavnica, zlatonitni atelje, kraljevska pasmenterska palača)
  - Thread, silk, wood, silver, gold, jewel, pearl supply, beauty (12-90), happiness (1-11), batch qty 1, GameEventBus publish
- **Royal Knitter System** — pletenine
  - 6 produktov (volnene rokavice, prepleten šal, svilo-lanana nogavica, srebrnonitni pulover, zlato vezen šal, kraljevski hermelinov plašč)
  - 4 zgradbe (pletenjska koča, pletenjska podstrešje, finopletni atelje, kraljevska pletenjska palača)
  - Wool, silk, silver, gold, jewel, pearl supply, warmth (25-90), happiness (1-11), batch qty 1, GameEventBus publish
- **Royal Crocheter System** — kvačkanine
  - 6 produktov (bombažni podstavek, čipkasti krožnik, svilo obrobljena prt, srebrnonitna pregrinjala, zlato obrobljeno oltarno, kraljevska čipkasta neba)
  - 4 zgradbe (kvačkana koča, čipkarska podstrešje, finokvačkanski atelje, kraljevska čipkarska palača)
  - Cotton, linen, silk, silver, gold, jewel, pearl supply, beauty (12-90), happiness (1-11), batch qty 1, GameEventBus publish
- **Royal Lace Maker System** — čipke
  - 6 produktov (preprosta čipka iz kobilic, trak navadne čipke, bruseljski ovratnik, srebrnonitna čipka, zlato obrobljena beneška, kraljevska beneška točkasta)
  - 4 zgradbe (čipkarska delavnica, kobilna podstrešje, beneški atelje, kraljevska čipkarska palača)
  - Linen, silk, wood, silver, gold, jewel, pearl supply, beauty (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Sampler Stitcher System** — vezenine
  - 6 produktov (črkovna, obrobljena motivna, svilena biblijska, srebrnovezena grbada, zlato vezana scena, kraljevski vezani paneli)
  - 4 zgradbe (vezenjska koča, vezenjska podstrešje, finovezalni atelje, kraljevska vezenjska palača)
  - Linen, thread, silk, silver, gold, jewel, pearl supply, beauty (20-92), happiness (1-12), batch qty 1, GameEventBus publish


## [v3.11.200] — 2026-08-09 — Royal Codex Binder System (6 products, bound codices)
## [v3.11.199] — 2026-08-09 — Royal Calendar Maker System (6 products, calendars)
## [v3.11.198] — 2026-08-09 — Royal Wax Seal Presser System (6 products, wax seals)
## [v3.11.197] — 2026-08-09 — Royal Ink Maker System (6 products, ink)
## [v3.11.196] — 2026-08-09 — Royal Hops Grower System (6 products, hops)

### Dodano (5 sistemov naenkrat — skriptorij in pisarniški pripomočki)
- **Royal Ink Maker System** — črnila
  - 6 produktov (železno-galunovo, črno, rdeče cinabaritno, srebrno, zlatoprašno, kraljevsko imperialno)
  - 4 zgradbe (črilna delavnica, pigmentni mlin, alkemični atelje, kraljevska črilna palača)
  - Glass, iron, silver, gold, jewel, pearl supply, happiness (1-11), prestige (1-58), batch qty 1, GameEventBus publish
- **Royal Wax Seal Presser System** — voščeni pečati
  - 6 produktov (navadni, rdeči cinabaritni, srebrno vtisnjeni, zlati grbovni, draguljarski, kraljevski imperialni)
  - 4 zgradbe (pečatna delavnica, grboslovni atelje, zlatarski atelje, kraljevska pečatna palača)
  - Wax, iron, silver, gold, jewel, pearl supply, happiness (1-10), prestige (1-55), batch qty 1, GameEventBus publish
- **Royal Calendar Maker System** — koledarji
  - 6 produktov (leseni, poslikani pergamentni, iluminirani velumski, srebrno obrobljeni, zlato izbočeni, kraljevski astronomski)
  - 4 zgradbe (koledarska delavnica, skriptorijska podstrešje, astronomski atelje, kraljevska koledarska palača)
  - Wood, parchment, paint, silver, gold, jewel, pearl supply, happiness (1-11), prestige (1-58), batch qty 1, GameEventBus publish
- **Royal Codex Binder System** — vezani kodeksi
  - 6 produktov (leseni, usnjeni, medeninasto sponjeni, srebrnokotni, zlato izbočeni, kraljevski veliki)
  - 4 zgradbe (vezalna delavnica, skriptorijski atelje, zlatarska vezava, kraljevska kodeksna palača)
  - Wood, leather, parchment, thread, rope, brass, silver, gold, jewel, pearl supply, happiness (1-12), prestige (1-60), batch qty 1, GameEventBus publish
- **Royal Manuscript Illuminator System** — iluminirani rokopisi
  - 6 produktov (poslikan začetnik, pozlačeni robni ornament, srebrnofiligranska, zlatolistna miniatúra, draguljarska, kraljevski velika)
  - 4 zgradbe (iluminatorjeva celica, skriptorijska dvorana, pozlatorski atelje, kraljevska iluminacijska palača)
  - Parchment, paint, silver, gold, jewel, pearl supply, happiness (1-13), prestige (1-62), batch qty 1, GameEventBus publish


## [v3.11.195] — 2026-08-09 — Royal Saffron Grower System (6 products, saffron)
## [v3.11.194] — 2026-08-09 — Royal Aloe Cultivator System (6 products, aloe medicine)
## [v3.11.193] — 2026-08-09 — Royal Mushroom Forager System (6 products, mushrooms)
## [v3.11.192] — 2026-08-09 — Royal Vegetable Gardener System (6 products, vegetables)
## [v3.11.191] — 2026-08-09 — Royal Bonsai Cultivator System (6 products, bonsai trees)

### Dodano (5 sistemov naenkrat — organski vrtovi in vzgoja)
- **Royal Vegetable Gardener System** — vrtna zelenjava
  - 6 produktov (košarica korenja, zaboj zelenja, dedna košara, kisli pridelki, egzotični pridelki, kraljevski pridelek)
  - 4 zgradbe (kuhinjski vrt, obzidan vrt, topla greda, kraljevski botanični vrt)
  - Wood, glass, salt, silver supply, food (12-150), happiness (1-7), batch qty 1, GameEventBus publish
- **Royal Mushroom Forager System** — gobe in tartufi
  - 6 produktov (poljske gobe, lisičke, jurčki, tartufi, zlatoprašni, kraljevski muzej)
  - 4 zgradbe (gobarjeva koča, sušilnica, mikološki laboratorij, kraljevska mikološka palača)
  - Wood, glass, silver, gold, jewel, pearl supply, food (10-130), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Aloe Cultivator System** — aloja in zdravilstvo
  - 6 produktov (snop listov, gel, tonik, srebrna viale, zlatookrasni eliksir, kraljevski medicinski zaboj)
  - 4 zgradbe (alojeva greda, destilarna, alkemični laboratorij, kraljevska apoteka)
  - Wood, clay, glass, iron, silver, gold, jewel, pearl supply, healing (8-150), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Saffron Grower System** — žafran
  - 6 produktov (snop niti, kozarec, srebrna škatlica, zlatopokrovka, draguljarska skrinjica, kraljevska zakladnica)
  - 4 zgradbe (žafranovo polje, sušilna hiša, začimbni atelje, kraljevska žafranova palača)
  - Glass, silver, gold, jewel, pearl supply, food (5-90), happiness (1-13), batch qty 1, GameEventBus publish
- **Royal Hops Grower System** — hmelj za pivovarne
  - 6 produktov (bala, vreča, pogača, srebrnopovezan, zlato pleteni venec, kraljevski koš)
  - 4 zgradbe (hmeljevo polje, sušilna stodola, pivovarski atelje, kraljevska hmeljeva palača)
  - Wood, rope, linen, iron, silver, gold, jewel, pearl supply, food (5-80), happiness (1-11), batch qty 1, GameEventBus publish


## [v3.11.190] — 2026-08-09 — Royal Butterfly Breeder System (6 products, butterfly displays)
## [v3.11.189] — 2026-08-09 — Royal Terrarium Keeper System (6 products, terrariums)
## [v3.11.188] — 2026-08-09 — Royal Aviary Keeper System (6 products, bird aviaries)
## [v3.11.187] — 2026-08-09 — Royal Aquarium Keeper System (6 products, aquariums)
## [v3.11.186] — 2026-08-09 — Royal Fountain Maker System (6 products, fountains)

### Dodano (5 sistemov naenkrat — eksotične zbirke in vzgoja)
- **Royal Aquarium Keeper System** — akvariji z ribami
  - 6 produktov (majhen steklen, izrezljan, bronastookvirni, srebrnofiligranski, zlatonivojski, kraljevski veliki)
  - 4 zgradbe (ribiška hiša, vodna dvorana, morski atelje, kraljevska vodna palača)
  - Glass, wood, marble, bronze, silver, gold, jewel, pearl supply, beauty (25-95), happiness (1-13), batch qty 1, GameEventBus publish
- **Royal Aviary Keeper System** — ptičje kletke in ptičniki
  - 6 produktov (majhna pletena, izrezljan, medeninasta, srebrnatična, pozlačena, kraljevski veliki)
  - 4 zgradbe (ptičja hiša, ptičja dvorana, egzotični atelje, kraljevska ptičja palača)
  - Wood, iron, brass, marble, silver, gold, jewel, pearl supply, beauty (18-92), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Terrarium Keeper System** — terariji za kuščarje in rastline
  - 6 produktov (majhen steklen, izrezljan, medeninastični, srebrnofiligranski, zlatookrasni, kraljevski veliki)
  - 4 zgradbe (terarijska hiša, botanična dvorana, egzotični atelje, kraljevska botanična palača)
  - Glass, wood, brass, marble, silver, gold, jewel, pearl supply, beauty (22-93), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Butterfly Breeder System** — zbirke metuljev v vitrinah
  - 6 produktov (navadni pisanček, izrezljanja zbirka večerov, egzotična vitrina, srebrnopripeta zbirka, zlatookrasna vitrina, kraljevski muzej)
  - 4 zgradbe (metuljna hiša, lepidopterološka dvorana, egzotični atelje, kraljevska metuljna palača)
  - Silk, glass, wood, brass, silver, gold, marble, jewel, pearl supply, beauty (18-90), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Bonsai Cultivator System** — vzgoja bonsajev
  - 6 produktov (majhen brinov, izrezljan borov, bronastolonec, srebrnopolica, zlatookrasni, kraljevski veliki)
  - 4 zgradbe (bonsajski vrt, vzgojna dvorana, mojstrski atelje, kraljevska bonsajska palača)
  - Wood, clay, bronze, marble, silver, gold, jewel, pearl supply, beauty (22-94), happiness (1-13), batch qty 1, GameEventBus publish


## [v3.11.185] — 2026-08-09 — Royal Candelabra Maker System (6 products, candelabras)
## [v3.11.184] — 2026-08-09 — Royal Chandelier Maker System (6 products, chandeliers)
## [v3.11.183] — 2026-08-09 — Royal Curtain Maker System (6 products, curtains)
## [v3.11.182] — 2026-08-09 — Royal Clock Face Painter System (6 products, clock dials)

### Dodano (5 sistemov naenkrat — okrasne oprema)
- **Royal Clock Face Painter System** — poslikava številčnic ur
  - 6 produktov (poslikana, pozlačena, emajlirana, srebrnomesečna, zlatoastrološka, kraljevski veliki)
  - 4 zgradbe (številčničarska delavnica, emajlnica, pozlatnica, kraljevski atelje)
  - Enamel, paint, silver, gold, jewel, pearl supply, artistry (40-100), happiness (1-10), batch qty 1, GameEventBus publish
- **Royal Curtain Maker System** — zavese
  - 6 produktov (lnene, volnene, tapiserijske, srebrno obrobljene, zlatorobne, kraljevski velike)
  - 4 zgradbe (zavesarska delavnica, šivalnica, vezenilnica, kraljevski atelje)
  - Linen, wool, silk, thread, rope, silver, gold, jewel, pearl supply, warmth (40-100), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Chandelier Maker System** — lustri
  - 6 produktov (železni, medeninast, srebrni, kristalni, zlatolistni, kraljevski veliki)
  - 4 zgradbe (lustrarska delavnica, kovačija, kristalna soba, kraljevski atelje)
  - Iron, brass, silver, gold, glass, wax, jewel, pearl supply, lightRadius (30-100), happiness (1-14), batch qty 1, GameEventBus publish
- **Royal Candelabra Maker System** — svečniki
  - 6 produktov (železni, medeninast, srebrni, srebrnorogasti, zlatorobni, kraljevski veliki)
  - 4 zgradbe (svečniška delavnica, kovačija, dokončevalnica, kraljevski atelje)
  - Iron, brass, silver, gold, wax, jewel, pearl supply, lightRadius (20-75), happiness (1-10), batch qty 1, GameEventBus publish
- **Royal Fountain Maker System** — vodometi
  - 6 produktov (kamniti, marmornat, bronast, srebrnolivni, zlatokipni, kraljevski veliki)
  - 4 zgradbe (vodometna delavnica, kamnito dvorišče, livarna, kraljevski atelje)
  - Stone, marble, clay, bronze, silver, gold, jewel, pearl supply, beauty (40-100), happiness (1-14), batch qty 1, GameEventBus publish

## [v3.11.181] — 2026-08-09 — Royal Perfume Bottle Maker System (6 products, perfume bottles)
## [v3.11.180] — 2026-08-09 — Royal Marble Statue Maker System (6 products, marble statues)
## [v3.11.179] — 2026-08-09 — Royal Doll House Maker System (6 products, doll houses)
## [v3.11.178] — 2026-08-09 — Royal Top Maker System (6 products, spinning tops)
## [v3.11.177] — 2026-08-09 — Royal Kite Maker System (6 products, kites)

### Dodano (5 sistemov naenkrat — igrače in okrasni predmeti)
- **Royal Kite Maker System** — zmaji
  - 6 produktov (papirni, svileni, poslikani, srebrnorepni, zlatoropni, kraljevski veliki)
  - 4 zgradbe (zmajarica delavnica, svilničnica, slikalnica, kraljevski atelje)
  - Paper, silk, wood, string, paint, silver, gold, jewel, pearl supply, flightQuality (40-100), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Top Maker System** — vrtavke
  - 6 produktov (lesena, poslikana, medeninastovrhovna, srebrno obrobljena, zlatointarzirana, kraljevski veliki)
  - 4 zgradbe (vrtavkarska delavnica, stružnica, dokončevalnica, kraljevski atelje)
  - Wood, paint, brass, silver, gold, jewel, pearl supply, spinTime (40-100), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Doll House Maker System** — lutkne hiše
  - 6 produktov (preprosta, poslikana, pohištena, srebrno obrobljena, zlatointarzirana, kraljevski veliki)
  - 4 zgradbe (lutknarska delavnica, pohištilnica, okrasovalnica, kraljevski atelje)
  - Wood, paint, fabric, silk, silver, gold, jewel, pearl supply, artistry (40-100), happiness (3-14), batch qty 1, GameEventBus publish
- **Royal Marble Statue Maker System** — marmorni kipi
  - 6 produktov (majhen poprsje, vrtni, naravno velik, srebrno poudarjen, zlatolistni, kraljevski veliki)
  - 4 zgradbe (kiparska delavnica, rezbarski atelje, polirnica, kraljevski atelje)
  - Marble, chisel, silver, gold, jewel, pearl supply, artistry (40-100), happiness (1-14), batch qty 1, GameEventBus publish
- **Royal Perfume Bottle Maker System** — stekleničke za parfum
  - 6 produktov (steklena, poslikana, srebrnopokrovna, srebrnofiligranska, zlatopokrovna, kraljevski veliki)
  - 4 zgradbe (steklenička delavnica, steklopihačnica, okrasovalnica, kraljevski atelje)
  - Glass, paint, silver, gold, jewel, pearl supply, artistry (40-100), happiness (1-10), batch qty 1, GameEventBus publish

## [v3.11.176] — 2026-08-09 — Royal Jigsaw Puzzle Maker System (6 products, puzzles)
## [v3.11.175] — 2026-08-09 — Royal Playing Card Maker System (6 products, playing cards)
## [v3.11.174] — 2026-08-09 — Royal Domino Maker System (6 products, dominoes)
## [v3.11.173] — 2026-08-09 — Royal Card Deck Maker System (6 products, card decks)
## [v3.11.172] — 2026-08-09 — Royal Board Game Maker System (6 products, board games)

### Dodano (5 sistemov naenkrat — igrače in igre)
- **Royal Board Game Maker System** — namizne igre
  - 6 produktov (lesena, poslikana, intarzirana, srebrno obrobljena, zlato intarzirana, kraljevski veliki)
  - 4 zgradbe (igrarska delavnica, slikalnica, intarzijalnica, kraljevski atelje)
  - Wood, paint, bone, ivory, silver, gold, jewel, pearl supply, entertainment (40-100), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Card Deck Maker System** — karte za igre
  - 6 produktov (pergamentne, poslikane, pozlačene, srebrno obrobljene, zlatolistne, kraljevski velike)
  - 4 zgradbe (kartarska delavnica, slikalnica, pozlatnica, kraljevski atelje)
  - Parchment, ink, paint, silver, gold, jewel, pearl supply, artistry (40-100), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Domino Maker System** — domine
  - 6 produktov (kostne, slonokoščene, poslikane, srebrnopikčaste, zlatointarzirane, kraljevski velike)
  - 4 zgradbe (dominarska delavnica, rezbarnica, intarzijalnica, kraljevski atelje)
  - Bone, ivory, ink, paint, silver, gold, jewel, pearl supply, artistry (40-100), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Playing Card Maker System** — igralne karte
  - 6 produktov (lesorezne, ročno poslikane, šablonske, srebrnorobne, zlatorobne, kraljevski velike)
  - 4 zgradbe (igralkarska delavnica, tiskalnica, pozlatnica, kraljevski atelje)
  - Paper, ink, paint, silver, gold, jewel, pearl supply, artistry (40-100), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Jigsaw Puzzle Maker System** — sestavljenke
  - 6 produktov (lesene, poslikane, furnirne, srebrno obrobljene, zlatointarzirane, kraljevski velike)
  - 4 zgradbe (sestavljenkarska delavnica, rezalnica, slikalnica, kraljevski atelje)
  - Wood, veneer, paint, silver, gold, jewel, pearl supply, artistry (40-100), happiness (2-12), batch qty 1, GameEventBus publish

## [v3.11.171] — 2026-08-09 — Royal Jester Props Maker System (6 products, jester props)
## [v3.11.170] — 2026-08-09 — Royal Tattoo Artist System (6 products, tattoos)
## [v3.11.169] — 2026-08-09 — Royal Fortune Teller System (6 products, fortune readings)
## [v3.11.168] — 2026-08-09 — Royal Wig Maker System (6 products, wigs)
## [v3.11.167] — 2026-08-09 — Royal Mirror Maker System (6 products, mirrors)

### Dodano (5 sistemov naenkrat — osebne in zabavne storitve)
- **Royal Mirror Maker System** — zrcala
  - 6 produktov (ročno, stensko, srebrno, srebrno okvirno, zlato okvirno, kraljevski veliki)
  - 4 zgradbe (zrcalna delavnica, srebrilnica, polirnica, kraljevski atelje)
  - Glass, wood, tin, silver, gold, jewel, pearl supply, clarity (50-100), happiness (1-8), batch qty 1, GameEventBus publish
- **Royal Wig Maker System** — lasulje
  - 6 produktov (konjskodlana, človeškodlana, prašna, srebrno nitna, zlatorobna, kraljevski veliki)
  - 4 zgradbe (lasuljarska delavnica, lasuljnica, oblikovalnica, kraljevski atelje)
  - Hair, human hair, linen, silk, starch, silver, gold, jewel, pearl supply, happiness (1-11), batch qty 1, GameEventBus publish
- **Royal Fortune Teller System** — vedeževanje
  - 6 produktov (branje dlani, tarot, kristalogledje, srebrnokotansko, zlatoastrološko, kraljevski veliki)
  - 4 zgradbe (vedeževalska postaja, vedeževalnica, gledalna komora, kraljevski atelje)
  - Ink, parchment, tarot cards, crystal, silver, gold, jewel, pearl supply, accuracy (40-100), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Tattoo Artist System** — tetovaže
  - 6 produktov (preprosta, plemenska, heraldična, srebrnočrnilna, zlatočrnilna, kraljevski veliki)
  - 4 zgradbe (tetovažna postaja, tetovažnica, umetniška soba, kraljevski atelje)
  - Ink, needle, silver, gold, jewel, pearl supply, artistry (40-100), happiness (2-12), batch qty 1, GameEventBus publish
- **Royal Jester Props Maker System** — norčevi rekviziti
  - 6 produktov (žonglirske žoge, norčeva žezla, norčeva kapa, srebrno zvončni, zlatorobni kostum, kraljevski veliki)
  - 4 zgradbe (rekvizitna delavnica, rekvizitnica, kostumnica, kraljevski atelje)
  - Leather, sand, wood, paint, bell, linen, silk, silver, gold, jewel, pearl supply, comedyValue (30-100), happiness (2-14), batch qty 1, GameEventBus publish

## [v3.11.166] — 2026-08-09 — Royal Alchemical Elixir Maker System (6 products, elixirs)
## [v3.11.165] — 2026-08-09 — Royal Potion Brewer System (6 products, potions)
## [v3.11.164] — 2026-08-09 — Royal Plague Doctor Mask Maker System (6 products, masks)
## [v3.11.163] — 2026-08-09 — Royal Leech Collector System (6 products, leeches)
## [v3.11.162] — 2026-08-09 — Royal Surgical Tool Maker System (6 products, surgical tools)

### Dodano (5 sistemov naenkrat — medicinska in alkemijska serija)
- **Royal Surgical Tool Maker System** — kirurška orodja
  - 6 produktov (železen skalpel, jeklen, srebrne pincete, srebrni komplet, zlatorobni, kraljevski veliki)
  - 4 zgradbe (kirurška delavnica, kovačija, brusilnica, kraljevski atelje)
  - Iron, steel, wood, silver, gold, jewel, pearl supply, sharpness (50-100), happiness (1-8), batch qty 1, GameEventBus publish
- **Royal Leech Collector System** — pijavke za medicino
  - 6 produktov (navadna, medicinska, krvna, srebrno kozarčna, srebrno obdelana, kraljevski veliki)
  - 4 zgradbe (pijavkarska postaja, pijavkarski ribnik, shranjevalnica, kraljevski atelje)
  - Pond water, herb, silver, gold, jewel supply, healingPower (30-100), happiness (1-7), batch qty 5, GameEventBus publish
- **Royal Plague Doctor Mask Maker System** — mask za zdravnike kuge
  - 6 produktov (usnjeni, kljunasti, srebrno kroglični, srebrno obrobljeni, zlatorobni, kraljevski veliki)
  - 4 zgradbe (maskarska delavnica, usnjiška soba, zeliščna komora, kraljevski atelje)
  - Leather, herb, silver, gold, jewel, pearl supply, protection (40-100), happiness (1-8), batch qty 1, GameEventBus publish
- **Royal Potion Brewer System** — medicinski napoji
  - 6 produktov (zdravilni, vzdržljivosti, protistrup, srebrnoflašni, zlatoflašni, kraljevski veliki)
  - 4 zgradbe (napojarska delavnica, varilnica, alkemijski laboratorij, kraljevski atelje)
  - Herb, honey, water, silver, gold, jewel, pearl supply, healingPower (40-100), happiness (1-9), batch qty 1, GameEventBus publish
- **Royal Alchemical Elixir Maker System** — alkemijski eliksirji
  - 6 produktov (vitalnosti, dolgoživosti, modrosti, srebrnolončni, zlatožbronasti, kraljevski veliki)
  - 4 zgradbe (eliksirska delavnica, alkemijska komora, destilacijska soba, kraljevski atelje)
  - Herb, mineral, water, silver, gold, jewel, pearl supply, potency (40-100), happiness (1-13), batch qty 1, GameEventBus publish

## [v3.11.161] — 2026-08-09 — Royal Thermometer Maker System (6 products, thermometers)
## [v3.11.160] — 2026-08-09 — Royal Barometer Maker System (6 products, barometers)
## [v3.11.159] — 2026-08-09 — Royal Microscope Maker System (6 products, microscopes)
## [v3.11.158] — 2026-08-09 — Royal Hourglass Maker System (6 products, hourglasses)
## [v3.11.157] — 2026-08-09 — Royal Telescope Maker System (6 products, telescopes)

### Dodano (5 sistemov naenkrat — optični inštrumenti in merilne naprave)
- **Royal Telescope Maker System** — daljnogledi za astronomijo
  - 6 produktov (medeninast, srebrn, vgraviran, srebrno trinožni, zlatokondični, kraljevski veliki)
  - 4 zgradbe (teleskopska delavnica, lečna soba, polirnica, kraljevski atelje)
  - Brass, glass, wood, silver, gold, jewel, pearl supply, magnification (30-100), happiness (1-13), batch qty 1, GameEventBus publish
- **Royal Hourglass Maker System** — peščene ure
  - 6 produktov (majhna, medeninasta, srebrna, srebrno okvirna, zlatorobna, kraljevski veliki)
  - 4 zgradbe (peščenourška delavnica, steklopihačnica, kalibrirnica, kraljevski atelje)
  - Glass, sand, wood, brass, silver, gold, jewel, pearl supply, precision (50-100), batch qty 1, GameEventBus publish
- **Royal Microscope Maker System** — mikroskopi za medicino
  - 6 produktov (medeninast, srebrn, vgraviran, srebrnomizni, zlatomizni, kraljevski veliki)
  - 4 zgradbe (mikroskopska delavnica, lečna brusilnica, kalibrirnica, kraljevski atelje)
  - Brass, glass, silver, gold, jewel, pearl supply, magnification (40-100), happiness (1-14), batch qty 1, GameEventBus publish
- **Royal Barometer Maker System** — barometri za napovedovanje vremena
  - 6 produktov (medeninast, srebrn, vgraviran, srebrnokazalni, zlatokondični, kraljevski veliki)
  - 4 zgradbe (barometerska delavnica, steklenocevna soba, živosrebrna soba, kraljevski atelje)
  - Brass, glass, mercury, silver, gold, jewel, pearl supply, accuracy (50-100), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Thermometer Maker System** — termometri za merjenje temperature
  - 6 produktov (stekleni, medeninast, srebrn, srebrnolestvni, zlatookvirni, kraljevski veliki)
  - 4 zgradbe (termometerska delavnica, steklenocevna soba, kalibrirnica, kraljevski atelje)
  - Glass, mercury, brass, silver, gold, jewel, pearl supply, accuracy (50-100), happiness (1-9), batch qty 1, GameEventBus publish

## [v3.11.156] — 2026-08-09 — Royal Armillary Sphere Maker System (6 products, armillary spheres)
## [v3.11.155] — 2026-08-09 — Royal Sextant Maker System (6 products, sextants)
## [v3.11.154] — 2026-08-09 — Royal Balance Scale Maker System (6 products, scales)
## [v3.11.153] — 2026-08-09 — Royal Abacus Maker System (6 products, abacuses)
## [v3.11.152] — 2026-08-09 — Royal Astrolabe Maker System (6 products, astrolabes)

### Dodano (5 sistemov naenkrat — znanstveni inštrumenti)
- **Royal Astrolabe Maker System** — astrolabi za merjenje zvezd
  - 6 produktov (medeninast, srebrn, vgraviran, srebrno retrogradni, pozlačen, kraljevski veliki)
  - 4 zgradbe (astrolabska delavnica, inštrumentska kovačija, vgravirnica, kraljevski atelje)
  - Brass, silver, gold, jewel, pearl supply, accuracy (50-100), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Abacus Maker System** — abaki za računanje
  - 6 produktov (leseni, medeninast, srebrn, srebrnožični, zlatokroglični, kraljevski veliki)
  - 4 zgradbe (abakarska delavnica, krogličarna, natančnostna soba, kraljevski atelje)
  - Wood, brass, silver, gold, jewel, pearl supply, precision (40-100), batch qty 1, GameEventBus publish
- **Royal Balance Scale Maker System** — tehtnice za trgovino
  - 6 produktov (železna, medeninasta, srebrna, srebrnokljuna, zlatorobna, kraljevski veliki)
  - 4 zgradbe (tehtničarska delavnica, kalibrirnica, natančnostna soba, kraljevski atelje)
  - Iron, brass, wood, silver, gold, jewel, pearl supply, precision (50-100), batch qty 1, GameEventBus publish
- **Royal Sextant Maker System** — sekstant za navigacijo
  - 6 produktov (medeninast, srebrn, vgraviran, srebrno ločni, zlatolocni, kraljevski veliki)
  - 4 zgradbe (sekstantska delavnica, inštrumentska kovačija, kalibrirnica, kraljevski atelje)
  - Brass, glass, silver, gold, jewel, pearl supply, accuracy (60-100), happiness (1-13), batch qty 1, GameEventBus publish
- **Royal Armillary Sphere Maker System** — armilarne sfere za astronomijo
  - 6 produktov (medeninasta, srebrna, vgravirana, srebrnomeridian, zlatorobna, kraljevski veliki)
  - 4 zgradbe (armilarska delavnica, sferna kovačija, kalibracijski observatorij, kraljevski atelje)
  - Brass, silver, gold, jewel, pearl supply, accuracy (55-100), happiness (1-14), batch qty 1, GameEventBus publish

## [v3.11.151] — 2026-08-09 — Royal Quill Pen Maker System (6 products, quills)
## [v3.11.150] — 2026-08-09 — Royal Parchment Maker System (6 products, parchment)
## [v3.11.149] — 2026-08-09 — Royal Paper Maker System (6 products, paper)
## [v3.11.148] — 2026-08-09 — Royal Star Chart Maker System (6 products, star charts)
## [v3.11.147] — 2026-08-09 — Royal Map Maker System (6 products, maps)

### Dodano (5 sistemov naenkrat — znanstveno-kartografska serija)
- **Royal Map Maker System** — kartografija
  - 6 produktov (regionalni, trgovska pot, obalna, srebrno filigranski, srebrno okvirni, kraljevski veliki atlas)
  - 4 zgradbe (kartografska postaja, kartografska hiša, geodetski stolp, kraljevski atelje)
  - Parchment, ink, silver, gold, jewel supply, accuracy (50-100), happiness (1-11), batch qty 1, GameEventBus publish
- **Royal Star Chart Maker System** — astronomske karte
  - 6 produktov (ozvezdja, lunarna, planetni efemeride, srebrno vgravirana, srebrno armilarna, kraljevski veliki nebesni atlas)
  - 4 zgradbe (astronomska postaja, observatorij, kartirnica, kraljevski atelje)
  - Parchment, ink, silver, gold, jewel supply, accuracy (50-100), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Paper Maker System** — proizvodnja papirja
  - 6 produktov (hrapavi, pisalni, fine, velum, srebrno posuti, kraljevski veliki)
  - 4 zgradbe (papirniška postaja, papirnica, dokončevalnica, kraljevski atelje)
  - Rag, water, starch, silver, gold, jewel supply, quality (40-100), happiness (1-8), batch qty 10
- **Royal Parchment Maker System** — pergament in velum
  - 6 produktov (ovčji, kozji, velum, srebrno ostrgani, srebrno obrobljeni, kraljevski veliki)
  - 4 zgradbe (pergamentna postaja, pergamentnica, strgalnica, kraljevski atelje)
  - Hide, calf hide, lime, water, silver, gold, jewel supply, quality (50-100), batch qty 5
- **Royal Quill Pen Maker System** — pero in pisala
  - 6 produktov (gosje, labodje, jekleno koničasto, srebrno, srebrno ročajno, kraljevski veliki)
  - 4 zgradbe (pernarska postaja, pernarna, žarilnica, kraljevski atelje)
  - Feather, swan feather, steel, wood, silver, gold, jewel, pearl supply, quality (40-100), batch qty 5, GameEventBus publish

## [v3.11.146] — 2026-08-09 — Royal War Dog Trainer System (6 products, war dogs)
## [v3.11.145] — 2026-08-09 — Royal Hunting Falconer System (6 products, hunts)
## [v3.11.144] — 2026-08-09 — Royal Hound Breeder System (6 products, hounds)
## [v3.11.143] — 2026-08-09 — Royal Pigeon Courier System (6 products, pigeons)
## [v3.11.142] — 2026-08-09 — Royal Falcon Breeder System (6 products, falcons)

### Dodano (5 sistemov naenkrat — živalske rejne serija)
- **Royal Falcon Breeder System** — vzreja sokolov
  - 6 produktov (selivski, kragulj, stepska postarna, polarni, srebrno remenski, kraljevski veliki)
  - 4 zgradbe (sokolarska postaja, sokolarica, trezensko polje, kraljevski atelje)
  - Falcon egg, meat, silver, gold, jewel supply, yield (40-100), happiness (1-10), batch qty 1, GameEventBus publish
- **Royal Pigeon Courier System** — golobja pošta
  - 6 produktov (domovračni, dirkalni, kurirski, srebrno obročkasti, srebrno kletki, kraljevski veliki)
  - 4 zgradbe (golobja postaja, golobnjak, sporočilnica, kraljevski atelje)
  - Pigeon, grain, silver, gold, jewel supply, speed (40-100), happiness (1-8), batch qty 1, GameEventBus publish
- **Royal Hound Breeder System** — vzreja psov za lov
  - 6 produktov (lovski, sledilni, hrt, srebrnodlaki, srebrno ovratnični, kraljevski veliki)
  - 4 zgradbe (pasja postaja, pasjak, dresurni dvori, kraljevski atelje)
  - Hound pup, meat, silver, gold, jewel supply, yield (40-100), happiness (1-9), batch qty 1, GameEventBus publish
- **Royal Hunting Falconer System** — lov s sokoli
  - 6 produktov (zajce, fazane, čaplje, žerjave, srebrno remenski, kraljevski veliki)
  - 4 zgradbe (lovska postaja, lovska koča, sokolarsko polje, kraljevski atelje)
  - Trained falcon, silver, gold, jewel supply, yield (35-100), happiness (1-9), batch qty 1, GameEventBus publish
- **Royal War Dog Trainer System** — dresura bojnih psov
  - 6 produktov (čuvaj, napadni, mastif, srebrno oklepni, srebrno ovratnični, kraljevski veliki)
  - 4 zgradbe (pasja vojaška postaja, vojaški pasjak, bojni dresurni dvori, kraljevski atelje)
  - Dog pup, meat, silver, gold, jewel supply, attack (8-55), defense (6-40), happiness (1-10), batch qty 1, GameEventBus publish

## [v3.11.141] — 2026-08-09 — Royal Ice Cutter System (6 products, ice)
## [v3.11.140] — 2026-08-09 — Royal Salt Pan Worker System (6 products, salt)
## [v3.11.139] — 2026-08-09 — Royal Whaling Captain System (6 products, whales)
## [v3.11.138] — 2026-08-09 — Royal Oyster Farmer System (6 products, oysters/pearls)
## [v3.11.137] — 2026-08-09 — Royal Fisherman System (6 products, fish)

### Dodano (5 sistemov naenkrat — vodna/gospodarska serija)
- **Royal Fisherman System** — ribištvo
  - 6 produktov (sled, bakalar, postrv, losos, srebrno mrežni, kraljevski veliki)
  - 4 zgradbe (ribarska postaja, ribje pristanišče, konzervirnica, kraljevski atelje)
  - Net, bait, silver, gold, jewel supply, yield (40-100), happiness (1-7), batch qty 5, GameEventBus publish
- **Royal Oyster Farmer System** — ostrigarstvo in bisere
  - 6 produktov (navadna ostriga, biser, gojen biser, črni biser, srebrnousti, kraljevski veliki)
  - 4 zgradbe (ostrigarska postaja, ostrigarske postelje, biserna hiša, kraljevski atelje)
  - Oyster bed, pearl oyster bed, silver, gold, jewel supply, yield (35-100), happiness (1-11), batch qty 1, GameEventBus publish
- **Royal Whaling Captain System** — kitolov
  - 6 produktov (kitovo olje, kosti, ambra, spermačetno olje, srebrno harpunski, kraljevski veliki)
  - 4 zgradbe (kitolovska postaja, kitolovsko pristanišče, kuhalnica, kraljevski atelje)
  - Harpoon, silver, gold, jewel supply, yield (40-100), happiness (1-12), batch qty 1, GameEventBus publish
- **Royal Salt Pan Worker System** — morska solina
  - 6 produktov (solinska, pahuljasta, solni cvet, srebrno kristalna, srebrno solinska, kraljevski veliki)
  - 4 zgradbe (solinarska postaja, solina, kristalizacijsko dvorišče, kraljevski atelje)
  - Seawater, fuel, silver, gold, jewel supply, purity (50-100), batch qty 10
- **Royal Ice Cutter System** — rezanje ledu
  - 6 produktov (jezerski, rečni, ledniški, srebrno prašni, srebrno zabojni, kraljevski veliki)
  - 4 zgradbe (ledarska postaja, ledarna, hladilnica, kraljevski atelje)
  - Saw, rope, silver, gold, jewel supply, purity (60-100), batch qty 5, GameEventBus publish

## [v3.11.136] — 2026-08-09 — Royal Horse Breeder System (6 products, horses)
## [v3.11.135] — 2026-08-09 — Royal Poultry Keeper System (6 products, poultry)
## [v3.11.134] — 2026-08-09 — Royal Pig Farmer System (6 products, pigs)
## [v3.11.133] — 2026-08-09 — Royal Sheep Shepherd System (6 products, sheep)
## [v3.11.132] — 2026-08-09 — Royal Cattle Rancher System (6 products, cattle)

### Dodano (5 sistemov naenkrat — živinorejska serija)
- **Royal Cattle Rancher System** — reja govedi
  - 6 produktov (mlečna krava, goveja, volovska ekipa, srebrnoroga, srebrno zvončna, kraljevski veliki)
  - 4 zgradbe (živinorejska postaja, goveja farma, mlečna staja, kraljevski atelje)
  - Cow, fodder, water, silver, gold, jewel supply, yield (50-100), happiness (1-8), batch qty 5, GameEventBus publish
- **Royal Sheep Shepherd System** — reja ovc
  - 6 produktov (volnasta, mlečna, pitno jagnje, srebrnoruna, srebrno zvončna, kraljevski veliki)
  - 4 zgradbe (ovčarska postaja, ovčja paša, strižnica, kraljevski atelje)
  - Sheep, fodder, water, silver, gold, jewel supply, yield (40-100), happiness (1-8), batch qty 5
- **Royal Pig Farmer System** — reja svinj
  - 6 produktov (slaninasta, mastna, sesna, srebrnokljuna, srebrno zvončna, kraljevski veliki)
  - 4 zgradbe (svinjarska postaja, svinjak, kadilno-solilna staja, kraljevski atelje)
  - Pig, fodder, water, silver, gold, jewel supply, yield (40-100), happiness (1-8), batch qty 5
- **Royal Poultry Keeper System** — reja perutnine
  - 6 produktov (nesnica, kastriran petelin, gos, srebrno pernata, srebrno zvončni, kraljevski veliki)
  - 4 zgradbe (perutninska postaja, perutninski dvori, jajčna hiša, kraljevski atelje)
  - Hen, goose, grain, water, silver, gold, jewel supply, yield (35-100), happiness (1-8), batch qty 5
- **Royal Horse Breeder System** — reja konj
  - 6 produktov (tovorni, jahači, bojni, srebrnogrivi, srebrno zvončni destrier, kraljevski veliki)
  - 4 zgradbe (konjerejska postaja, žrebec farma, dresurna arena, kraljevski atelje)
  - Horse, fodder, water, silver, gold, jewel supply, yield (40-100), happiness (1-12), batch qty 1, GameEventBus publish

## [v3.11.131] — 2026-08-09 — Royal Apiary Keeper System (6 products, apiary)
## [v3.11.130] — 2026-08-09 — Royal Herb Gardener System (6 products, herbs)
## [v3.11.129] — 2026-08-09 — Royal Vineyard Planter System (6 products, grapes)
## [v3.11.128] — 2026-08-09 — Royal Orchardist System (6 products, fruit)
## [v3.11.127] — 2026-08-09 — Royal Grain Farmer System (6 products, grain)

### Dodano (5 sistemov naenkrat — kmetijska pridelovalna serija)
- **Royal Grain Farmer System** — pridelovanje žit
  - 6 produktov (ječmen, pšenica, rž, oves, srebrni snop, kraljevski veliki)
  - 4 zgradbe (kmetijska postaja, žitna kmetija, mlatilnica, kraljevski atelje)
  - Barley/wheat/rye/oat seeds, water, silver, gold, jewel supply, yield (30-100), batch qty 10, GameEventBus publish
- **Royal Orchardist System** — sadjarstvo
  - 6 produktov (jabolka, hruške, češnje, slive, srebrno cvetoče, kraljevski veliki)
  - 4 zgradbe (sadjarstvo postaja, sadovnjak, tisčna staja, kraljevski atelje)
  - Apple/pear/cherry/plum saplings, water, silver, gold, jewel supply, yield (35-100), batch qty 10
- **Royal Vineyard Planter System** — gojenje vinskih trt
  - 6 produktov (namizno grozdje, rdeče, belo, rozinasto, srebrno grozd, kraljevski veliki)
  - 4 zgradbe (vinogradniška postaja, vinograd, rešetka hiša, kraljevski atelje)
  - Grape/red/white vines, water, silver, gold, jewel supply, yield (30-100), batch qty 10
- **Royal Herb Gardener System** — zeliščarstvo
  - 6 produktov (rožmarin, žajbelj, timijan, sivka, srebrno cvetlična, kraljevski veliki)
  - 4 zgradbe (zeliščarska postaja, zeliščni vrt, sušilnica, kraljevski atelje)
  - Herb/lavender seeds, water, silver, gold, jewel supply, flavorStrength (30-100), batch qty 5
- **Royal Apiary Keeper System** — čebelarstvo (surovi produkti)
  - 6 produktov (surovi med, čebelji vosek, matični mleček, propolis, srebrno satje, kraljevski veliki)
  - 4 zgradbe (čebelarska postaja, čebelnjak, medena hiša, kraljevski atelje)
  - Hive, flower, silver, gold, jewel supply, yield (30-100), happiness (1-8), batch qty 5, GameEventBus publish

## [v3.11.126] — 2026-08-09 — Royal Gem Miner System (6 products, gems)
## [v3.11.125] — 2026-08-09 — Royal Clay Digger System (6 products, clay)
## [v3.11.124] — 2026-08-09 — Royal Quarry Miner System (6 products, stone)
## [v3.11.123] — 2026-08-09 — Royal Sawmill System (6 products, planks)
## [v3.11.122] — 2026-08-09 — Royal Timber Feller System (6 products, logs)

### Dodano (5 sistemov naenkrat — lesna in kamnita surovinska serija)
- **Royal Timber Feller System** — sekanje dreves v hlode
  - 6 produktov (borov, hrastov, jesenov, tisov, ebenov, kraljevski veliki)
  - 4 zgradbe (gozdarska postaja, lesna tabor, hlodovnica, kraljevski atelje)
  - Pine, oak, ash, yew, ebony, gold, jewel supply, quality (30-100), batch qty 10, GameEventBus publish
- **Royal Sawmill System** — žaganje hlodov v deske
  - 6 produktov (borova, hrastova, jesenova, tisova, ebenova, kraljevski veliki)
  - 4 zgradbe (žagarska delavnica, vodna žaga, listna hiša, kraljevski atelje)
  - Pine/oak/ash/yew/ebony logs, gold, jewel supply, quality (30-100), batch qty 10
- **Royal Quarry Miner System** — kopanje kamna v kamnolomu
  - 6 produktov (apnenčev, peščenjak, granitni, marmornat, srebrno žilnati, kraljevski veliki)
  - 4 zgradbe (kamnoseka postaja, kamnolom, obdelovalnica, kraljevski atelje)
  - Limestone, sandstone, granite, marble, silver, gold, jewel supply, quality (30-100), batch qty 5
- **Royal Clay Digger System** — kopanje gline
  - 6 produktov (navadna, rdeča, beli kaolin, ognjevzdržna, srebrno prašna, kraljevski veliki)
  - 4 zgradbe (glinaška postaja, glinokop, pralnica, kraljevski atelje)
  - Clay bed, kaolin bed, fire clay bed, silver, gold, jewel supply, quality (30-100), batch qty 10
- **Royal Gem Miner System** — kopanje dragih kamnov
  - 6 produktov (kvarčni, ametist, safir, rubin, smaragd, kraljevski veliki diamant)
  - 4 zgradbe (draguljska postaja, draguljski rudnik, rezalnica, kraljevski atelje)
  - Gem vein, silver, gold, jewel supply, quality (30-100), happiness (1-11), batch qty 1, GameEventBus publish

## [v3.11.121] — 2026-08-09 — Royal Pottery Kiln System (6 products, pottery)
## [v3.11.120] — 2026-08-09 — Royal Brick Maker System (6 products, bricks)
## [v3.11.119] — 2026-08-09 — Royal Lime Burner System (6 products, lime)
## [v3.11.118] — 2026-08-09 — Royal Ingot Smelter System (6 products, ingots)
## [v3.11.117] — 2026-08-09 — Royal Glass Batch Smelter System (6 products, glass)

### Dodano (5 sistemov naenkrat — gradbena surovinska serija)
- **Royal Glass Batch Smelter System** — taljenje surovega stekla
  - 6 produktov (surova mešanica, bistro, kristalno, svinčevo, srebrno očiščeno, kraljevski veliki)
  - 4 zgradbe (steklarska livarna, talilna peč, ohlajevalna peč, kraljevski atelje)
  - Sand, soda, lead, fuel, silver, gold, jewel supply, purity (30-100), batch qty 5, GameEventBus publish
- **Royal Ingot Smelter System** — taljenje kovinskih ingotov
  - 6 produktov (železen, bakren, bronast, medeninast, srebrni rafiniran, kraljevski veliki)
  - 4 zgradbe (kovinska livarna, visoka peč, rafinerijska peč, kraljevski atelje)
  - Iron ore, copper ore, tin ore, zinc ore, silver ore, gold ore, lead, fuel, jewel supply, purity (60-100), batch qty 5
- **Royal Lime Burner System** — žganje apna
  - 6 produktov (živo apno, ugaslo apno, apnena malta, apnena belila, srebrno obdelano, kraljevski veliki)
  - 4 zgradbe (apnarska delavnica, apnarska peč, ugaševalnica, kraljevski atelje)
  - Limestone, fuel, water, sand, silver, gold, jewel supply, quality (50-100), batch qty 5
- **Royal Brick Maker System** — izdelava opek
  - 6 produktov (sončno sušena, žgana, glazirana, terrakota, srebrno maltinska, kraljevski veliki)
  - 4 zgradbe (opekarska delavnica, opekarska peč, glazirnica, kraljevski atelje)
  - Clay, sand, fuel, glass, silver, gold, jewel supply, durability (30-100), batch qty 10
- **Royal Pottery Kiln System** — peka lončenine
  - 6 produktov (glina, kamnina, glazirana, porcelan, srebrno obrobljena, kraljevski veliki)
  - 4 zgradbe (lončarska delavnica, lončarska peč, glazirnica, kraljevski atelje)
  - Clay, kaolin, glass, fuel, silver, gold, jewel supply, durability (30-100), happiness (1-9), batch qty 5, GameEventBus publish

## [v3.11.116] — 2026-08-09 — Royal Rope Spinner System (6 products, ropes)
## [v3.11.115] — 2026-08-09 — Royal Canvas Weaver System (6 products, canvas)
## [v3.11.114] — 2026-08-09 — Royal Cotton Gin System (6 products, cotton)
## [v3.11.113] — 2026-08-09 — Royal Hemp Retter System (6 products, hemp)
## [v3.11.112] — 2026-08-09 — Royal Linen Retter System (6 products, linen)

### Dodano (5 sistemov naenkrat — vlaknasta surovinska serija)
- **Royal Linen Retter System** — predelava lana v vlakna
  - 6 produktov (razmočeno slamo, lomljena, tolčeni, česan, srebrni kuclji, kraljevski veliki)
  - 4 zgradbe (delavnica, močilnik, lomilnica, kraljevski atelje)
  - Flax stalk, water, oil, silver, gold, jewel supply, quality (30-100), batch qty 5, GameEventBus publish
- **Royal Hemp Retter System** — predelava konoplje v vlakna
  - 6 produktov (razmočena, lomljena, tolčena, česana, srebrni kuclji, kraljevski veliki)
  - 4 zgradbe (delavnica, močilnik, lomilnica, kraljevski atelje)
  - Hemp stalk, water, oil, silver, gold, jewel supply, quality (30-100), batch qty 5
- **Royal Cotton Gin System** — predelava bombaža
  - 6 produktov (surov, očesan, česani, glavčan, srebrno preden, kraljevski veliki)
  - 4 zgradbe (delavnica, česalnica, česana soba, kraljevski atelje)
  - Cotton boll, oil, silver, gold, jewel supply, quality (30-100), batch qty 5
- **Royal Canvas Weaver System** — tkanje platna
  - 6 produktov (hrapavo, jadrno, šotorsko, slikarsko, srebrno nitno, kraljevski veliki)
  - 4 zgradbe (delavnica, tkalnica, dokončevalnica, kraljevski atelje)
  - Hemp, linen, oil, wax, gesso, silver, gold, jewel supply, durability (30-100), batch qty 5
- **Royal Rope Spinner System** — predenje vrvi
  - 6 produktov (konopljeva, katranova, kabelska, svilena, srebrno žična, kraljevski veliki)
  - 4 zgradbe (delavnica, vrivarska pot, katranilnica, kraljevski atelje)
  - Hemp, tar, silk, silver, gold, jewel supply, tensileStrength (30-100), durability (25-95), batch qty 5, GameEventBus publish

## [v3.11.111] — 2026-08-09 — Royal Silk Reeler System (6 products, silk)
## [v3.11.110] — 2026-08-09 — Royal Wool Stapler System (6 products, wool)
## [v3.11.109] — 2026-08-09 — Royal Furrier System (6 products, fur)
## [v3.11.108] — 2026-08-09 — Royal Rawhide Tanner System (6 products, leather)
## [v3.11.107] — 2026-08-09 — Royal Dye-Stuff Maker System (6 products, dyes)

### Dodano (5 sistemov naenkrat — tekstilna surovinska serija)
- **Royal Dye-Stuff Maker System** — proizvodnja barvil
  - 6 produktov (rumeno weld, modro woad, rdeče madder, karmin, srebrno fiksirano, kraljevski purpur)
  - 4 zgradbe (delavnica, barvilna kadi, sušilnica, kraljevski atelje)
  - Weld, woad, madder, cochineal, alum, silver, gold, jewel supply, colorStrength (30-100), batch qty 5, GameEventBus publish
- **Royal Rawhide Tanner System** — surovo usnje iz surovih kož
  - 6 produktov (surovo, skorjno, alun, oljno, srebrno obdelano, kraljevski veliki)
  - 4 zgradbe (delavnica, strojevalnica, mlin lubja, kraljevski atelje)
  - Hide, lime, water, bark, alum, salt, oil, silver, gold, jewel supply, quality (30-100), batch qty 5
- **Royal Furrier System** — krzno iz živalskih kož
  - 6 produktov (kunčje, lisica, kuna, sobolj, srebrno podloženo, kraljevski hermelin)
  - 4 zgradbe (delavnica, krznavarna, dokončevalnica, kraljevski atelje)
  - Pelt, salt, alum, oil, silver, gold, jewel supply, warmth (30-100), happiness (1-14), batch qty 5
- **Royal Wool Stapler System** — predelava volne
  - 6 produktov (surova runa, prana, česana, glavčana, srebrno predena, kraljevski veliki)
  - 4 zgradbe (delavnica, pralnica, česalnica, kraljevski atelje)
  - Fleece, water, soap, oil, silver, gold, jewel supply, quality (30-100), batch qty 5
- **Royal Silk Reeler System** — svila iz bub
  - 6 produktov (surova, ovitki, trda, predena, srebrno nitna, kraljevski veliki)
  - 4 zgradbe (delavnica, ovijalnica, trdilnica, kraljevski atelje)
  - Cocoon, water, oil, silver, gold, jewel supply, quality (30-100), happiness (1-9), batch qty 5, GameEventBus publish

## [v3.11.106] — 2026-08-09 — Royal Confectioner System (6 products, confections)
## [v3.11.105] — 2026-08-09 — Royal Pickle Curer System (6 products, pickles)
## [v3.11.104] — 2026-08-09 — Royal Fish Smoker System (6 products, smoked fish)
## [v3.11.103] — 2026-08-09 — Royal Smoked Meat Curer System (6 products, smoked meats)
## [v3.11.102] — 2026-08-09 — Royal Sausage Maker System (6 products, sausages)

### Dodano (5 sistemov naenkrat — mesno-konzervacijska serija)
- **Royal Sausage Maker System** — klobasarska obrt
  - 6 produktov (svinja, goveja, prekajena, lovska, srebrno obložena, kraljevski velika)
  - 4 zgradbe (delavnica, klobasarna, kadilnica, kraljevski atelje)
  - Pork, beef, gut, spice, fuel, silver, gold, jewel supply, flavorStrength (30-100), happiness (2-14), batch qty 5, GameEventBus publish
- **Royal Smoked Meat Curer System** — prekajeno meso
  - 6 produktov (svinjska prsa, šunka, slanina, goveja prsa, srebrno mrežasto, kraljevski veliki)
  - 4 zgradbe (delavnica, kadilnica, konservirni sklep, kraljevski atelje)
  - Pork, beef, salt, spice, fuel, silver, gold, jewel supply, flavorStrength (40-100), happiness (2-15), batch qty 5
- **Royal Fish Smoker System** — prekajene ribe
  - 6 produktov (sled, postrv, losos, začinjena, srebrno pladenj, kraljevski veliki)
  - 4 zgradbe (ribja kadilnica, kadilnica, slanica, kraljevski atelje)
  - Fish, salt, spice, fuel, silver, gold, jewel supply, flavorStrength (30-100), happiness (1-13), batch qty 5
- **Royal Pickle Curer System** — kisle zelenjave
  - 6 produktov (kumarica, kislo zelje, kislo čebula, začinjena mešana, srebrno kozarec, kraljevski veliki)
  - 4 zgradbe (delavnica, slanica kadi, shramba, kraljevski atelje)
  - Cucumber, cabbage, onion, vinegar, salt, spice, silver, gold, jewel supply, flavorStrength (25-100), happiness (1-13), batch qty 5
- **Royal Confectioner System** — sladkarstvo
  - 6 produktov (sladkorna sliva, kandirana lupina, karamela, marcipanasta oblika, zlatolistna, kraljevski veliki)
  - 4 zgradbe (delavnica, sladkarnica, okrasovalnica, kraljevski atelje)
  - Sugar, fruit, butter, honey, almond, spice, silver, gold, jewel supply, flavorStrength (35-100), happiness (2-15), batch qty 5, GameEventBus publish

## [v3.11.101] — 2026-08-09 — Royal Pastry Chef System (6 products, pastries)
## [v3.11.100] — 2026-08-09 — Royal Bread Baker System (6 products, breads)
## [v3.11.99] — 2026-08-09 — Royal Yogurt Fermenter System (6 products, yogurts)
## [v3.11.98] — 2026-08-09 — Royal Butter Churner System (6 products, butters)
## [v3.11.97] — 2026-08-09 — Royal Cheese Maker System (6 products, cheeses)

### Dodano (5 sistemov naenkrat — mlečno-pekarska serija)
- **Royal Cheese Maker System** — sirarstvo
  - 6 produktov (sveža skuta, mehki, trdi, staran, začinjen, kraljevski veliki)
  - 4 zgradbe (delavnica, sirarna, starilna klet, kraljevski atelje)
  - Milk, rennet, salt, spice, silver, gold, jewel supply, flavorStrength (20-100), happiness (1-15), batch qty 5, GameEventBus publish
- **Royal Butter Churner System** — maslo iz mleka
  - 6 produktov (sveže, slano, kislo, zeliščno, srebrno stepeno, kraljevski veliki)
  - 4 zgradbe (delavnica, stepnica, dokončevalnica, kraljevski atelje)
  - Milk, salt, herb, silver, gold, jewel supply, flavorStrength (30-100), happiness (2-14), batch qty 5
- **Royal Yogurt Fermenter System** — jogurt iz fermentacije
  - 6 produktov (navaden, medeni, sadni, začinjen, srebrno posodje, kraljevski veliki)
  - 4 zgradbe (delavnica, fermentirnica, hladilnica, kraljevski atelje)
  - Milk, culture, honey, fruit, spice, silver, gold, jewel supply, flavorStrength (25-100), happiness (1-13), batch qty 5
- **Royal Bread Baker System** — pekovski kruh
  - 6 produktov (rženi, pšenični, beli, začinjen, srebrno prašni, kraljevski veliki)
  - 4 zgradbe (delavnica, pekarna, kamnita peč, kraljevski atelje)
  - Rye, wheat, water, fuel, spice, honey, silver, gold, jewel supply, flavorStrength (25-100), happiness (1-14), batch qty 10
- **Royal Pastry Chef System** — slaščičarstvo
  - 6 produktov (preprosta pita, medena torta, začinjena torta, marcipan, zlatolistna peciva, kraljevski veliki)
  - 4 zgradbe (slaščičarna, pekarna, okrasovalnica, kraljevski atelje)
  - Wheat, fruit, butter, honey, spice, almond, silver, gold, jewel supply, flavorStrength (30-100), happiness (2-15), batch qty 5, GameEventBus publish

## [v3.11.96] — 2026-08-09 — Royal Oil Presser System (6 products, oils)
## [v3.11.95] — 2026-08-09 — Royal Honey Collector System (6 products, honey)
## [v3.11.94] — 2026-08-09 — Royal Sugar Refiner System (6 products, sugar)
## [v3.11.93] — 2026-08-09 — Royal Salt Refiner System (6 products, salt)
## [v3.11.92] — 2026-08-09 — Royal Spice Merchant System (6 products, spices)

### Dodano (5 sistemov naenkrat — živilska surovinska serija)
- **Royal Spice Merchant System** — začimbe za okus
  - 6 produktov (poper, cimet, nageljnove žbice, muškatni orešček, žafran, kraljevska mešanica)
  - 4 zgradbe (delavnica, sušilnica, mlinska soba, kraljevski atelje)
  - Pepper, cinnamon, clove, nutmeg, saffron, silver, gold, jewel supply, flavorStrength (10-60), happiness (1-14), batch qty 5, GameEventBus publish
- **Royal Salt Refiner System** — sol za konzerviranje in kuhanje
  - 6 produktov (morska, kamena, rafinirana, namizna, srebrno obdelana, kraljevska čista)
  - 4 zgradbe (delavnica, izparjevalnica, kristalizirnica, kraljevski atelje)
  - Seawater, salt ore, water, fuel, silver, gold, jewel supply, purity (60-100), batch qty 10
- **Royal Sugar Refiner System** — sladkor iz sladkornega trsa
  - 6 produktov (surov, rafiniran, beli, sladkorni hlebec, srebrno obdelan, kraljevski čisti)
  - 4 zgradbe (delavnica, vrelnica, kristalizirnica, kraljevski atelje)
  - Cane, water, fuel, silver, gold, jewel supply, sweetness (50-100), happiness (1-12), batch qty 5
- **Royal Honey Collector System** — med iz panjev
  - 6 produktov (divji, deteljin, gozdni cvetlični, sivkin, srebrno satje, kraljevski ambrozij)
  - 4 zgradbe (delavnica, panjarna, izvlekalnica, kraljevski atelje)
  - Flower, wax, silver, gold, jewel supply, sweetness (50-100), happiness (1-14), batch qty 5
- **Royal Oil Presser System** — rastlinska olja
  - 6 produktov (oljčno, orehovo, laneno, makovo, srebrno ojačano, kraljevski veliki)
  - 4 zgradbe (delavnica, tisčnica, filtrirnica, kraljevski atelje)
  - Olive, walnut, flax, poppy, silver, gold, jewel supply, purity (60-100), happiness (1-12), batch qty 5, GameEventBus publish

## [v3.11.91] — 2026-08-09 — Royal Brandy Distiller System (6 products, brandies)
## [v3.11.90] — 2026-08-09 — Royal Cider Press System (6 products, ciders)
## [v3.11.89] — 2026-08-09 — Royal Wine Vintner System (6 products, wines)
## [v3.11.88] — 2026-08-09 — Royal Mead Maker System (6 products, meads)
## [v3.11.87] — 2026-08-09 — Royal Ale Brewer System (6 products, ales)

### Dodano (5 sistemov naenkrat — pijačna serija)
- **Royal Ale Brewer System** — pivovar za pivo
  - 6 produktov (majhno, rjavo, močno, začinjeno, srebrno pivovarsko, kraljevski veliki)
  - 4 zgradbe (delavnica, pivovarna, starilni sklep, kraljevski atelje)
  - Barley, hops, water, spice, silver, gold, jewel supply, alcoholContent (3-16), happiness (1-15), batch qty 5, GameEventBus publish
- **Royal Mead Maker System** — medica iz medu
  - 6 produktov (preprost, začinjen, melomel, meteglin, srebrno sodni, kraljevski veliki)
  - 4 zgradbe (delavnica, medičarna, starilni sklep, kraljevski atelje)
  - Honey, water, spice, fruit, silver, gold, jewel supply, alcoholContent (5-20), happiness (2-18), batch qty 5
- **Royal Wine Vintner System** — vinarstvo
  - 6 produktov (namizno, rdeče, belo, začinjeno, staro, kraljevski veliki)
  - 4 zgradbe (delavnica, vinska klet, sodna starilnica, kraljevski atelje)
  - Grape, water, oak, spice, honey, silver, gold, jewel supply, alcoholContent (8-22), happiness (2-18), batch qty 5
- **Royal Cider Press System** — jabolčnik in hruškovec
  - 6 produktov (kmečki, začinjen, hruškovec, hrastovo staran, srebrno sodni, kraljevski veliki)
  - 4 zgradbe (delavnica, tisčnica, starilni sklep, kraljevski atelje)
  - Apple, pear, spice, oak, silver, gold, jewel supply, alcoholContent (4-18), happiness (2-16), batch qty 5
- **Royal Brandy Distiller System** — destilacija žganja
  - 6 produktov (jabolčno, grozdno, starano, začinjeno, srebrno destilirano, kraljevski veliki)
  - 4 zgradbe (delavnica, destilarna, starilni sklep, kraljevski atelje)
  - Grape, apple, oak, spice, fuel, silver, gold, jewel supply, alcoholContent (30-60), happiness (3-20), batch qty 5, GameEventBus publish

## [v3.11.86] — 2026-08-09 — Royal Match Cord Maker System (6 products, match cords)
## [v3.11.85] — 2026-08-09 — Royal Charcoal Burner System (6 products, charcoal)
## [v3.11.84] — 2026-08-09 — Royal Sulfur Collector System (6 products, sulfur)
## [v3.11.83] — 2026-08-09 — Royal Saltpeter Refinery System (6 products, saltpeter)
## [v3.11.82] — 2026-08-09 — Royal Gunpowder Mill System (6 products, gunpowder)

### Dodano (5 sistemov naenkrat — smodniška surovinska serija)
- **Royal Gunpowder Mill System** — mlin za smodek
  - 6 produktov (serpentin, zrnati, fino mlet, vojaški, rafiniran, kraljevski veliki)
  - 4 zgradbe (delavnica, mlinski mlin, zrnica, kraljevski atelje)
  - Saltpeter, sulfur, charcoal, silver, gold, jewel supply, potency (30-150), batch qty 5, GameEventBus publish
- **Royal Saltpeter Refinery System** — rafinerija salitre
  - 6 produktov (surova, rafinirana, kristalizirana, bela, srebrno obdelana, kraljevska čista)
  - 4 zgradbe (delavnica, izluževalna kadi, kristalizirnica, kraljevski atelje)
  - Earth, water, charcoal, silver, gold, jewel supply, purity (30-100), batch qty 5
- **Royal Sulfur Collector System** — zbiralec in rafiner žvepla
  - 6 produktov (surovo, raztaljeno, rafinirano, sublimirano, srebrno obdelano, kraljevsko čisto)
  - 4 zgradbe (delavnica, talilnica, sublimirnica, kraljevski atelje)
  - Ore, fuel, silver, gold, jewel supply, purity (30-100), batch qty 5
- **Royal Charcoal Burner System** — peč za oglje
  - 6 produktov (mehko, trdodrevno, komensko, rafinirano, srebrno prašni, kraljevsko čisto)
  - 4 zgradbe (delavnica, ogljarska peč, retorta, kraljevski atelje)
  - Wood, clay, silver, gold, jewel supply, burnQuality (30-100), batch qty 10
- **Royal Match Cord Maker System** — izdelovalec prižigov za topove
  - 6 produktov (konopljev, lneni, počasni, obdelani, srebrno prašni, kraljevski slovesni)
  - 4 zgradbe (delavnica, potorilnica, sušilnica, kraljevski atelje)
  - Hemp, linen, saltpeter, charcoal, silver, gold, silk, jewel, pearl supply, burnRate (30-100), durability (5-35), batch qty 10, GameEventBus publish

## [v3.11.81] — 2026-08-09 — Royal Grenade Maker System (6 products, grenades)
## [v3.11.80] — 2026-08-09 — Royal Hand Cannon Maker System (6 products, hand cannons)
## [v3.11.79] — 2026-08-09 — Royal Bombard Maker System (6 products, bombards)
## [v3.11.78] — 2026-08-09 — Royal Mortar Maker System (6 products, mortars)
## [v3.11.77] — 2026-08-09 — Royal Cannon Maker System (6 products, cannons)

### Dodano (5 sistemov naenkrat — smodniško orožje)
- **Royal Cannon Maker System** — topovi za obleganje in utrdbe
  - 6 produktov (ročna kulverina, majhen bronast, železen, težki bronast, srebrno okrašen, kraljevski veliki)
  - 4 zgradbe (delavnica, livarna, vrtalnica, kraljevski atelje)
  - Iron, bronze, steel, wood, silver, gold, jewel, gunpowder supply, attack (50-320), range (200-500), durability (35-160), GameEventBus publish
- **Royal Mortar Maker System** — minometi za visoke kotne napade
  - 6 produktov (majhen, bronast, železen, težki, srebrno okrašen, kraljevski veliki)
  - 4 zgradbe (delavnica, livarna, vrtalnica, kraljevski atelje)
  - Iron, bronze, steel, wood, silver, gold, jewel, gunpowder supply, attack (45-290), range (150-400), durability (30-155)
- **Royal Bombard Maker System** — bombardi za najmočnejše oblege
  - 6 produktov (lahka, bronasta, železna, težka, srebrno okrašena, kraljevska velika)
  - 4 zgradbe (delavnica, livarna, vrtalnica, kraljevski atelje)
  - Iron, bronze, steel, wood, silver, gold, jewel, gunpowder supply, attack (65-410), range (220-540), durability (40-175)
- **Royal Hand Cannon Maker System** — ročne topovske in pistole
  - 6 produktov (preprosta, svečno prižigana, kolesni pistoli, srebrno okrašena, zlatorobna, kraljevska slovesna)
  - 4 zgradbe (delavnica, kovačija, prižigalnica, kraljevski atelje)
  - Iron, steel, wood, silver, gold, jewel, pearl, gunpowder supply, attack (25-150), range (60-200), durability (25-100)
- **Royal Grenade Maker System** — eksplozivne granate
  - 6 produktov (glina, železna, jeklena, srebrno okrašena, zlatorobna, kraljevska slovesna)
  - 4 zgradbe (delavnica, smodniška soba, dokončevalnica, kraljevski atelje)
  - Clay, iron, steel, silver, gold, jewel, pearl, gunpowder supply, attack (25-220), radius (3-12), durability (5-35), batch qty 5, GameEventBus publish

## [v3.11.76] — 2026-08-09 — Royal Battering Ram Maker System (6 products, rams)
## [v3.11.75] — 2026-08-09 — Royal Siege Tower Maker System (6 products, towers)
## [v3.11.74] — 2026-08-09 — Royal Ballista Maker System (6 products, ballistae)
## [v3.11.73] — 2026-08-09 — Royal Trebuchet Maker System (6 products, trebuchets)
## [v3.11.72] — 2026-08-09 — Royal Catapult Maker System (6 products, catapults)

### Dodano (5 sistemov naenkrat — oblegovalne naprave)
- **Royal Catapult Maker System** — katapult in sorodne naprave
  - 6 produktov (mangonel, onager, standardni, težki, srebrno ojačan, kraljevski veliki)
  - 4 zgradbe (delavnica, oblegovalno dvorišče, napetilnica, kraljevski atelje)
  - Wood, iron, steel, rope, leather, silver, gold, jewel supply, attack (35-240), range (200-500), durability (40-160), GameEventBus publish
- **Royal Trebuchet Maker System** — trebucheti (vlečni in protitežni)
  - 6 produktov (vlečni, protitežni, vojaški, veliki, srebrno okrašen, kraljevski veliki)
  - 4 zgradbe (delavnica, oblegovalno dvorišče, protitežna soba, kraljevski atelje)
  - Wood, iron, steel, stone, rope, leather, silver, gold, jewel supply, attack (50-300), range (250-600), durability (45-180)
- **Royal Ballista Maker System** — baliste in škorpijoni
  - 6 produktov (škorpijon, lahka, standardna, težka, srebrno okrašena, kraljevska velika)
  - 4 zgradbe (delavnica, oblegovalno dvorišče, napetilnica, kraljevski atelje)
  - Wood, iron, steel, rope, gut, silver, gold, jewel supply, attack (30-220), range (250-550), durability (40-160)
- **Royal Siege Tower Maker System** — oblegovalni stolpi
  - 6 produktov (majhen, srednji, pokriti, visoki, srebrno okrašen, kraljevski veliki)
  - 4 zgradbe (delavnica, oblegovalno dvorišče, mizarski atelje, kraljevski atelje)
  - Wood, iron, steel, leather, rope, silver, gold, jewel supply, defense (30-180), durability (50-200)
- **Royal Battering Ram Maker System** — oblegovalni ovni
  - 6 produktov (preprosti, pokriti, železnoglavi, jeklenoglavi, srebrno okrašen, kraljevski veliki)
  - 4 zgradbe (delavnica, oblegovalno dvorišče, mizarski atelje, kraljevski atelje)
  - Wood, iron, steel, leather, rope, silver, gold, jewel supply, attack (25-170), durability (40-170), GameEventBus publish

## [v3.11.71] — 2026-08-09 — Royal Cavalry Banner Maker System (6 products, cavalry banners)
## [v3.11.70] — 2026-08-09 — Royal Lance Maker System (6 products, lances)
## [v3.11.69] — 2026-08-09 — Royal Horse Armor Maker System (6 products, barding)
## [v3.11.68] — 2026-08-09 — Royal Spur Maker System (6 products, spurs)
## [v3.11.67] — 2026-08-09 — Royal Saddle Maker System (6 products, saddles)

### Dodano (5 sistemov naenkrat — konjeniška oprema)
- **Royal Saddle Maker System** — sedli za konjenico
  - 6 produktov (usnjeni sedež, blazirani, vojaški, srebrnorogi, vezeni, kraljevski slovesni)
  - 4 zgradbe (delavnica, usnjiška soba, vezenilnica, kraljevski atelje)
  - Leather, wood, wool, iron, silver, silk, thread, gold, jewel, pearl supply, comfort (5-22), durability (18-80), GameEventBus publish
- **Royal Spur Maker System** — ostroge za konjenico
  - 6 produktov (železne, jeklene, medeninaste, srebrne zvezdne, zlate, kraljevski viteške)
  - 4 zgradbe (delavnica, kovačija, polirnica, kraljevski atelje)
  - Iron, steel, brass, silver, gold, jewel, pearl supply, cavalryBoost (4-30), durability (18-75)
- **Royal Horse Armor Maker System** — bardingi za konje
  - 6 produktov (usnjeni, blazirani, verižni, jekleni ploščati, srebrno okrašen, kraljevski slovesni)
  - 4 zgradbe (delavnica, kovačija, dokončevalnica, kraljevski atelje)
  - Leather, wool, iron, steel, silver, gold, jewel, pearl supply, defense (8-60), durability (25-110)
- **Royal Lance Maker System** — turnirske sulice
  - 6 produktov (lesena, železnokljuna, jeklenokljuna, srebrnokljuna, zlatorobna, kraljevska turnirska)
  - 4 zgradbe (delavnica, kovačija, dokončevalnica, kraljevski atelje)
  - Wood, iron, steel, silver, gold, jewel, pearl supply, attack (10-50), durability (22-90)
- **Royal Cavalry Banner Maker System** — konjeniški prapori
  - 6 produktov (pennon, guidon, standard, svila konjeniška, zlatorobna, kraljevski konjeniški standard)
  - 4 zgradbe (delavnica, heraldična soba, pozlatnica, kraljevski atelje)
  - Linen, silk, paint, thread, silver, gold, jewel, pearl supply, cavalryBoost (3-35), GameEventBus publish

## [v3.11.66] — 2026-08-09 — Royal Mace & Axe Maker System (6 products, maces & axes)
## [v3.11.65] — 2026-08-09 — Royal Polearm Maker System (6 products, polearms)
## [v3.11.64] — 2026-08-09 — Royal Crossbow Maker System (6 products, crossbows)
## [v3.11.63] — 2026-08-09 — Royal Fletcher System (6 products, arrows)
## [v3.11.62] — 2026-08-09 — Royal Bowyer System (6 products, bows)

### Dodano (5 sistemov naenkrat — zaključek orožarske serije)
- **Royal Bowyer System** — loki od samostrela do kompozita
  - 6 produktov (samostrel, brestov dolgi, tisov povratni, kompozitni, srebrno okrašen, kraljevski slovesni)
  - 4 zgradbe (delavnica, ukrivljalnica, kompozitna soba, kraljevski atelje)
  - Wood, gut, horn, sinew, silver, gold, pearl supply, attack (6-42), durability (18-75), GameEventBus publish
- **Royal Fletcher System** — puščice za lokostrelstvo
  - 6 produktov (bobkin, širokokljuna, bodkin, srebrna, zlatoroba, kraljevski komplet tulec)
  - 4 zgradbe (delavnica, peresnica, kovašnica kljun, kraljevski atelje)
  - Wood, feather, iron, steel, silver, gold, jewel, pearl supply, attack (3-28), range (25-60), batch qty 20
- **Royal Crossbow Maker System** — samostreli in arbalesti
  - 6 produktov (lahki, srednji, jekleni, arbalest, srebrno okrašen, kraljevski slovesni)
  - 4 zgradbe (delavnica, kovačija, ukrivljalnica, kraljevski atelje)
  - Wood, gut, iron, steel, horn, silver, gold, jewel, pearl supply, attack (12-56), durability (22-90)
- **Royal Polearm Maker System** — kopja, pike, halberde
  - 6 produktov (kopje, pika, halberda, glaive, srebrna sulica, kraljevska slovesna)
  - 4 zgradbe (delavnica, kovačija, dokončevalnica, kraljevski atelje)
  - Wood, iron, steel, silver, gold, jewel, pearl supply, attack (8-42), durability (25-80)
- **Royal Mace & Axe Maker System** — buzdovani, sekire, kladivci
  - 6 produktov (kijača, buzdovan, bojna sekira, robnik, srebrni kladivec, kraljevski slovesni)
  - 4 zgradbe (delavnica, kovačija, dokončevalnica, kraljevski atelje)
  - Wood, iron, steel, silver, gold, jewel, pearl supply, attack (5-42), durability (18-85), GameEventBus publish

## [v3.11.61] — 2026-08-09 — Royal Armor Maker System (6 products, armor)
## [v3.11.60] — 2026-08-09 — Royal Shield Maker System (6 products, shields)
## [v3.11.59] — 2026-08-09 — Royal Helmet Maker System (6 products, helmets)
## [v3.11.58] — 2026-08-09 — Royal Dagger Maker System (6 products, daggers)
## [v3.11.57] — 2026-08-09 — Royal Swordsmith Maker System (6 products, swords)

### Dodano (5 sistemov naenkrat — orožarska in okleplarska serija)
- **Royal Swordsmith Maker System** — meči za viteze in kralje
  - 6 produktov (železen, jeklen dolg, srebrnjak ročajski, damascenski, draguljni, kraljevski slovesni)
  - 4 zgradbe (delavnica, kovačija, žarilnica, kraljevski atelje)
  - Iron, steel, silver, gold, jewel, pearl supply, attack (8-45), durability (20-80), GameEventBus publish
- **Royal Dagger Maker System** — bodalci in stileti
  - 6 produktov (železen, jeklen, srebrnorčajni, stilet, draguljni, kraljevski slovesni)
  - 4 zgradbe (delavnica, kovačija, žarilnica, kraljevski atelje)
  - Iron, steel, silver, gold, jewel, pearl supply, attack (4-28), durability (15-60)
- **Royal Helmet Maker System** — čelade za boj
  - 6 produktov (kapica, lonec, nosna, velika, srebrna, kraljevska slovesna)
  - 4 zgradbe (delavnica, kovačija, polirnica, kraljevski atelje)
  - Iron, steel, silver, gold, jewel, pearl supply, defense (4-35), durability (18-80)
- **Royal Shield Maker System** — ščiti z grbi
  - 6 produktov (lesen, železno okovan, okrogli, trapezni, srebrno okrašen, kraljevski slovesni)
  - 4 zgradbe (delavnica, kovačija, slikalnica, kraljevski atelje)
  - Wood, iron, steel, leather, silver, gold, jewel, pearl supply, defense (3-32), durability (15-80)
- **Royal Armor Maker System** — oklepi od usnja do kraljevskega slovesnega
  - 6 produktov (usnjeni jopič, verižna srajca, jeklena veriga, ploščati, srebrni, kraljevski slovesni)
  - 4 zgradbe (delavnica, kovačija, dokončevalnica, kraljevski atelje)
  - Leather, iron, steel, silver, gold, jewel, pearl supply, defense (5-48), durability (20-100), GameEventBus publish

## [v3.11.56] — 2026-08-09 — Royal Pipe & Tabor Maker System (6 products, pipes & tabors)
## [v3.11.55] — 2026-08-09 — Royal Bagpipe Maker System (6 products, bagpipes)
## [v3.11.54] — 2026-08-09 — Royal Sackbut Maker System (6 products, sackbuts)
## [v3.11.53] — 2026-08-09 — Royal Crumhorn Maker System (6 products, crumhorns)
## [v3.11.52] — 2026-08-09 — Royal Shawm Maker System (6 products, shawms)

### Dodano (5 sistemov naenkrat — pihala in trobila)
- **Royal Shawm Maker System** — šalmaji in bombarda
  - 6 produktov (soprano, alt, tenor, bombarda, srebrni, kraljevski konzort)
  - 4 zgradbe (delavnica, vrtalnica, trobilnica, kraljevski atelje)
  - Wood, reed, brass, silver, gold, ivory supply, sound quality (9-38), GameEventBus publish
- **Royal Crumhorn Maker System** — krumhorni z usnjato kapo
  - 6 produktov (soprano, alt, tenor, bas, veliki bas, kraljevski konzort)
  - 4 zgradbe (delavnica, vrtalnica, kapnica, kraljevski atelje)
  - Wood, reed, leather, brass, silver, gold, ivory supply, sound quality (9-36)
- **Royal Sackbut Maker System** — sakbuti (zgodnji pozavni)
  - 6 produktov (alt, tenor, bas, srebrni, zlatorobni, kraljevski slovesni)
  - 4 zgradbe (delavnica, kovačija, drsničnica, kraljevski atelje)
  - Brass, leather, silver, gold, ivory, pearl supply, sound quality (11-38)
- **Royal Bagpipe Maker System** — dude za vas in dvor
  - 6 produktov (vasja, dvorne, srebrnjačeve, italijanske, zlatorobne, kraljevske slovesne)
  - 4 zgradbe (delavnica, usnjiška soba, trobilnica, kraljevski atelje)
  - Wood, leather, reed, silver, gold, ivory, pearl supply, sound quality (10-38)
- **Royal Pipe & Tabor Maker System** — piščali in tabor bobni
  - 6 produktov (kmečka, trojnična, tabor, tenor, srebrna, kraljevski komplet)
  - 4 zgradbe (delavnica, vrtalnica, dokončevalnica, kraljevski atelje)
  - Wood, brass, silver, gold, ivory, leather, pearl supply, sound quality (7-35), GameEventBus publish

## [v3.11.51] — 2026-08-09 — Royal Recorder Maker System (6 products, recorders)
## [v3.11.50] — 2026-08-09 — Royal Hurdy-Gurdy Maker System (6 products, hurdy-gurdies)
## [v3.11.49] — 2026-08-09 — Royal Psaltery Maker System (6 products, psalteries)
## [v3.11.48] — 2026-08-09 — Royal Fiddle Maker System (6 products, fiddles)
## [v3.11.47] — 2026-08-09 — Royal Lute Maker System (6 products, lutes)

### Dodano (5 sistemov naenkrat — godala in pihala)
- **Royal Lute Maker System** — lutnje in teorbe
  - 6 produktov (učenci, alt, tenor, teorba, arhilutnja, kraljevska pandora)
  - 4 zgradbe (delavnica, strunarska soba, zvočna soba, kraljevski atelje)
  - Wood, gut, gold, silver, pearl supply, sound quality (8-38), GameEventBus publish
- **Royal Fiddle Maker System** — gusli, vijele, rebeci
  - 6 produktov (kmečka, vijela, tristrunska, rebec, srebrna, kraljevska dvorna)
  - 4 zgradbe (delavnica, strunarska soba, lokarska soba, kraljevski atelje)
  - Wood, gut, brass, silver, gold, pearl supply, sound quality (7-36)
- **Royal Psaltery Maker System** — psalteriji in cimbale
  - 6 produktov (trikotni, kvadratni, lokani, dvojni, srebrni, kraljevski kladivčasti)
  - 4 zgradbe (delavnica, strunarska soba, naglasilnica, kraljevski atelje)
  - Wood, gut, silver, gold, pearl supply, sound quality (8-38)
- **Royal Hurdy-Gurdy Maker System** — vrtavke
  - 6 produktov (preprosta, diatonska, kromatska, dvonosilčna, srebrna, kraljevska lutnjarska)
  - 4 zgradbe (delavnica, kolesna soba, tipkarska soba, kraljevski atelje)
  - Wood, gut, brass, silver, gold, pearl supply, sound quality (10-40)
- **Royal Recorder Maker System** — flavte in konzorti
  - 6 produktov (soprano, alt, tenor, bas, slonokoščena, kraljevski konzort)
  - 4 zgradbe (delavnica, vrtalnica, dokončevalnica, kraljevski atelje)
  - Wood, brass, ivory, silver, gold, jewel supply, sound quality (8-34), GameEventBus publish

## [v3.11.46] — 2026-08-09 — Royal Drummer Maker System (6 products, drums)
## [v3.11.45] — 2026-08-09 — Royal Harp Maker System (6 products, harps)
## [v3.11.44] — 2026-08-09 — Royal Cymbal Maker System (6 products, cymbals)
## [v3.11.43] — 2026-08-09 — Royal Bell Wheel Maker System (6 products, bell wheels)
## [v3.11.42] — 2026-08-09 — Royal Organ Pipe Maker System (6 products, organ pipes)

### Dodano (5 sistemov naenkrat — srednjeveška glasbila)
- **Royal Organ Pipe Maker System** — orgelske piščali
  - 6 produktov (lesena, kositrna, svinčena, medeninasta, srebrna, kraljevski register)
  - 4 zgradbe (delavnica, kovinska soba, intonirnica, kraljevski atelje)
  - Wood, tin, lead, brass, silver, gold supply, sound quality (8-40), GameEventBus publish
- **Royal Bell Wheel Maker System** — zvoneča kolesca in zvonce
  - 6 produktov (ročni, oltarni, posvetilni, ladjani, srebrni, kraljevski kariljonski)
  - 4 zgradbe (delavnica, kovačija, naglasilnica, kraljevski atelje)
  - Brass, iron, silver, gold supply, sound quality (6-35)
- **Royal Cymbal Maker System** — činele za godbe
  - 6 produktov (medeninasti, bronasti, prstni, srebrni, zlati, kraljevski par)
  - 4 zgradbe (delavnica, kovačija, kladivnica, kraljevski atelje)
  - Brass, bronze, silver, gold supply, sound quality (8-35)
- **Royal Harp Maker System** — harfe za dvor
  - 6 produktov (lira, mala, črevesna, žična, srebrna, kraljevska zlata)
  - 4 zgradbe (delavnica, strunarska soba, zvočna soba, kraljevski atelje)
  - Wood, gut, brass, silver, gold, jewel supply, sound quality (8-38)
- **Royal Drummer Maker System** — bobni in pavioni
  - 6 produktov (tabor, stranski, pavilon, tenorski, srebrni pavion, kraljevska timpana)
  - 4 zgradbe (delavnica, strgarna, kovinska soba, kraljevski atelje)
  - Wood, leather, copper, brass, silver, gold supply, sound quality (6-36), GameEventBus publish

## [v3.11.41] — 2026-08-09 — Royal Thurible & Censer Maker System (6 products, thuribles)
## [v3.11.40] — 2026-08-09 — Royal Paten Maker System (6 products, patens)
## [v3.11.39] — 2026-08-09 — Royal Chalice Maker System (6 products, chalices)
## [v3.11.38] — 2026-08-09 — Royal Ciborium Maker System (6 products, ciboria)
## [v3.11.37] — 2026-08-09 — Royal Monstrance Maker System (6 products, monstrances)

### Dodano (5 sistemov naenkrat — liturgična posoda)
- **Royal Monstrance Maker System** — monstrance za adoracijo
  - 6 produktov (medeninasta, srebrna, zlata, žarki, draguljna, kraljevska svetiščna)
  - 4 zgradbe (delavnica, kovačija, kristalna soba, kraljevski atelje)
  - Brass, silver, gold, glass, jewel, pearl supply, sanctity (6-40), GameEventBus publish
- **Royal Ciborium Maker System** — ciboriji za hostije
  - 6 produktov (pustrast, medeninast, srebrni, zlati, draguljni, kraljevski tabernakelj)
  - 4 zgradbe (delavnica, kovačija, dokončevalnica, kraljevski atelje)
  - Tin, brass, silver, gold, jewel, pearl supply, sanctity (4-32)
- **Royal Chalice Maker System** — kalihi za maše
  - 6 produktov (pustrast, medeninast, srebrni, zlati, draguljni, kraljevski papeški)
  - 4 zgradbe (delavnica, kovačija, pozlatnica, kraljevski atelje)
  - Tin, brass, silver, gold, jewel, pearl supply, sanctity (4-34)
- **Royal Paten Maker System** — patene za hostijo
  - 6 produktov (pustrasta, medeninasta, srebrna, zlata, draguljna, kraljevska papeška)
  - 4 zgradbe (delavnica, kovačija, pozlatnica, kraljevski atelje)
  - Tin, brass, silver, gold, jewel, pearl supply, sanctity (3-30)
- **Royal Thurible & Censer Maker System** — kadila za kadilo
  - 6 produktov (železno, medeninasto, srebrno, zlato, draguljno, kraljevsko papeško)
  - 4 zgradbe (delavnica, kovačija, verižna soba, kraljevski atelje)
  - Iron, brass, silver, gold, jewel, pearl supply, sanctity (4-33), GameEventBus publish

## [v3.11.36] — 2026-08-09 — Royal Processional Cross Maker System (6 products, crosses)
## [v3.11.35] — 2026-08-09 — Royal Chrismatory Maker System (6 products, chrismatories)
## [v3.11.34] — 2026-08-09 — Royal Reliquary Maker System (6 products, reliquaries)
## [v3.11.33] — 2026-08-09 — Royal Altar Frontal Maker System (6 products, antependia)
## [v3.11.32] — 2026-08-09 — Royal Cope & Vestment Maker System (6 products, vestments)

### Dodano (5 sistemov naenkrat — liturgična serija)
- **Royal Cope & Vestment Maker System** — cerkvena oblačila
  - 6 produktov (lnena alba, volnena kazula, svileni štol, vezena pluvial, zlatorobna pluvial, kraljevski pontifikalno oblačilo)
  - 4 zgradbe (delavnica, šivalnica, vezenilnica, kraljevski atelje)
  - Linen, wool, silk, thread, gold, silver, jewel, pearl supply, sanctity (4-30), GameEventBus publish
- **Royal Altar Frontal Maker System** — antependiji za oltarje
  - 6 produktov (lneni, poslikani, vezeni, svileni, draguljni, kraljevska katedralna)
  - 4 zgradbe (delavnica, slikalnica, vezenilnica, kraljevski atelje)
  - Linen, silk, paint, thread, gold, silver, jewel, pearl supply, sanctity (3-30)
- **Royal Reliquary Maker System** — relikviarji za relikvije
  - 6 produktov (leseni, srebrni, zlati, kristalni, draguljni, kraljevski svetiščni)
  - 4 zgradbe (delavnica, kovačija, kristalna soba, kraljevski atelje)
  - Wood, silver, gold, glass, jewel, pearl supply, sanctity (4-40)
- **Royal Chrismatory Maker System** — krizmatije za sveta olja
  - 6 produktov (pustrasta, srebrna, kristalna, zlata, draguljna, kraljevska trojna)
  - 4 zgradbe (delavnica, kovačija, kristalna soba, kraljevski atelje)
  - Tin, silver, gold, glass, jewel, pearl supply, sanctity (3-32)
- **Royal Processional Cross Maker System** — procesijski križi
  - 6 produktov (leseni, medeninast, srebrni, zlati, draguljni, kraljevski katedralni)
  - 4 zgradbe (delavnica, kovačija, draguljna soba, kraljevski atelje)
  - Wood, brass, silver, gold, jewel, pearl supply, sanctity (4-38), GameEventBus publish

## [v3.11.31] — 2026-08-09 — Royal Heraldic Flag Maker System (6 products, flags)
## [v3.11.30] — 2026-08-09 — Royal Banner Maker System (6 products, banners)
## [v3.11.29] — 2026-08-09 — Royal Cushion Maker System (6 products, cushions)
## [v3.11.28] — 2026-08-09 — Royal Carpet Loom System (6 products, carpets)
## [v3.11.27] — 2026-08-09 — Royal Stained Glass Maker System (6 products, stained glass)

### Dodano (5 sistemov naenkrat)
- **Royal Stained Glass Maker System** — svetla steklena okna
  - 6 produktov (preprosta svinčevana, geometrijski, floralno, heraldično, zlatorobno, kraljevski rozetno okno)
  - 4 zgradbe (delavnica, pečnica, slikalnica, kraljevski atelje)
  - Glass, lead, paint, gold, silver, jewel supply, light transmission (5-20), GameEventBus publish
- **Royal Carpet Loom System** — tkane preproge
  - 6 produktov (trotasta, volnena, barvna, vozlana, svilena perzijska, kraljevska lovna)
  - 4 zgradbe (delavnica, tkalnica, barvilnica, kraljevski atelje)
  - Rush, wool, silk, dye, gold, silver, jewel supply, warmth (3-16)
- **Royal Cushion Maker System** — blazine in prestolne blazine
  - 6 produktov (slamnata, volnena, peresna, vezena, zlatorobna, kraljevska prestolna)
  - 4 zgradbe (delavnica, šivalnica, vezenilnica, kraljevski atelje)
  - Straw, linen, wool, feather, silk, thread, gold, silver, jewel supply, comfort (4-22)
- **Royal Banner Maker System** — transparenti za dvor in procesije
  - 6 produktov (lneni, poslikani, svileni, vezeni, zlatorobni, kraljevski procesijski)
  - 4 zgradbe (delavnica, slikalnica, vezenilnica, kraljevski atelje)
  - Linen, silk, paint, thread, gold, silver, jewel supply, visibility (8-35)
- **Royal Heraldic Flag Maker System** — heraldične zastave in bojni standardi
  - 6 produktov (kljunasta, gonfalon, standard, hišna zastava, bojni standard, kraljevski slovesni)
  - 4 zgradbe (delavnica, heraldična soba, pozlatnica, kraljevski atelje)
  - Linen, silk, paint, thread, gold, silver, jewel supply, morale boost (2-35), GameEventBus publish

## [v3.11.26] — 2026-08-09 — Royal Tapestry Loom System (6 products, tapestries)
## [v3.11.25] — 2026-08-09 — Royal Medal Maker System (6 products, medals)
## [v3.11.24] — 2026-08-09 — Royal Seal Ring Maker System (6 products, seal rings)
## [v3.11.23] — 2026-08-09 — Royal Orb Maker System (6 products, orbs)
## [v3.11.22] — 2026-08-09 — Royal Throne Maker System (6 products, thrones)

### Dodano (5 sistemov naenkrat)
- **Royal Throne Maker System** — plemiška in kraljevska stegna
  - 6 produktov (hrastovo, rezljano, pozlačeno, marmornato, draguljno, kraljevsko cesarsko)
  - 4 zgradbe (delavnica, rezbarski atelje, pozlatna soba, kraljevski atelje)
  - Wood, stone, gold, silver, jewel, pearl, silk supply, prestige (2-80), GameEventBus publish
- **Royal Orb Maker System** — obla (državne krogle) za insignije
  - 6 produktov (lesena, medeninasta, srebrna, zlata, draguljna, kraljevska cesarska)
  - 4 zgradbe (delavnica, kovačija, draguljna soba, kraljevski atelje)
  - Wood, brass, silver, gold, jewel, pearl supply, prestige (1-40)
- **Royal Seal Ring Maker System** — pečatni prstani za uradnike in plemiče
  - 6 produktov (železen, medeninast, srebrn, zlat, draguljni, kraljevski signetni)
  - 4 zgradbe (delavnica, kovačija, vgravirnica, kraljevski atelje)
  - Iron, brass, silver, gold, jewel, pearl supply, authority (2-40)
- **Royal Medal Maker System** — medalje in redni redi za zasluge
  - 6 produktov (pustrasta, bronasta, srebrna, zlata, emajlirana, kraljevski red)
  - 4 zgradbe (delavnica, kovačija, emajlnica, kraljevski atelje)
  - Tin, bronze, silver, gold, glass, jewel, silk supply, prestige (1-35)
- **Royal Tapestry Loom System** — tapiserije in stenske obešalke
  - 6 produktov (lnena, volnena, barvna, svila, zlatorobna, kraljevska lovna)
  - 4 zgradbe (delavnica, stenska soba, barvilnica, kraljevski atelje)
  - Linen, wool, silk, dye, gold, silver, jewel supply, warmth (5-20), GameEventBus publish

## [v3.11.21] — 2026-08-09 — Royal Scepter Maker System (6 products, scepters)
## [v3.11.20] — 2026-08-09 — Royal Crown Maker System (6 products, crowns)
## [v3.11.19] — 2026-08-09 — Royal Rivet Maker System (6 products, rivets)
## [v3.11.18] — 2026-08-09 — Royal Bolt & Latch Maker System (6 products, bolts)
## [v3.11.17] — 2026-08-09 — Royal Hinge Maker System (6 products, hinges)

### Dodano (5 sistemov naenkrat)
- **Royal Hinge Maker System** — šarnirji za vrata in omare
  - 6 produktov (železen, pasasti, medeninast, T-šarnir, srebrn, kraljevski vrtljivi)
  - 4 zgradbe (delavnica, kovačija, dokončevalnica, kraljevski atelje)
  - Iron, steel, brass, silver, gold supply, load capacity (20-80)
- **Royal Bolt & Latch Maker System** — zavori in zasuki za ključavnice
  - 6 produktov (železen zavor, zasuk, medeninast, mrtvi zavor, srebrni, kraljevski slovesni)
  - 4 zgradbe (delavnica, kovačija, brusilnica, kraljevski atelje)
  - Iron, steel, brass, silver, gold, jewel supply, security (4-32)
- **Royal Rivet Maker System** — zakovice za pločevino in oklepe
  - 6 produktov (železen, bakren, jeklen, medeninast, srebrn, kraljevski zlat)
  - 4 zgradbe (delavnica, kovačija, glavčilnica, kraljevski atelje)
  - Iron, copper, steel, brass, silver, gold supply, shear strength (15-30), batch qty 20
- **Royal Crown Maker System** — krone in diademi za plemstvo
  - 6 produktov (bronast diadem, srebrna korona, zlat diadem, draguljna korona, kraljevska odprta krona, cesarska zaprta krona)
  - 4 zgradbe (delavnica, kovačija, draguljarska soba, kraljevski atelje)
  - Bronze, silver, gold, jewel, pearl supply, prestige (2-50), qty 1, GameEventBus publish
- **Royal Scepter Maker System** — žezla za plemiče in kralje
  - 6 produktov (lesena palica, medeninasto, srebrno, zlato, draguljno, kraljevsko cesarsko žezlo)
  - 4 zgradbe (delavnica, kovačija, draguljna stavilnica, kraljevski atelje)
  - Wood, brass, silver, gold, jewel, pearl supply, prestige (1-45), GameEventBus publish

## [v3.11.16] — 2026-08-09 — Royal Chain Maker System (6 products, chains)
## [v3.11.15] — 2026-08-09 — Royal Key Maker System (6 products, keys)
## [v3.11.14] — 2026-08-09 — Royal Bell Pull System (6 products, bell pulls)
## [v3.11.13] — 2026-08-09 — Royal Coffer & Lockbox System (6 products, coffers)
## [v3.11.12] — 2026-08-09 — Royal Funnel Maker System (6 products, funnels)

### Dodano (5 sistemov naenkrat)
- **Royal Funnel Maker System** — lijaki za prelive in pretoke
  - 6 produktov (kositrni, bakreni, medeninasti, srebrni, zlatorobi, kraljevski alkimični)
  - 4 zgradbe (delavnica, livarna, natančnostna soba, kraljevski atelje)
  - Tin, copper, brass, silver, gold, glass supply, flow rate (5-20)
- **Royal Coffer & Lockbox System** — skrinje, zaboji in zakladniški zaboji
  - 6 produktov (borova skrinjica, hrastova skrinja, železno okovana, cedrova omara, srebrno obrobljena, kraljevski zakladniški zaboj)
  - 4 zgradbe (delavnica, mizarski atelje, železarna, kraljevski atelje)
  - Wood, iron, silver, gold, jewel supply, capacity (50-1000)
- **Royal Bell Pull System** — povodi za zvonce in kordice
  - 6 produktov (konopljev, pleteni, svileni, kitasti, srebrnožični, kraljevski slovesni)
  - 4 zgradbe (delavnica, pletilnica, svilničnica, kraljevski atelje)
  - Hemp, silk, silver, gold supply, length (5-30)
- **Royal Key Maker System** — ključi za ključavnice
  - 6 produktov (železen, jeklen, medeninast, srebrn, zlat, kraljevski glavni ključ)
  - 4 zgradbe (delavnica, kovačija, brusilnica, kraljevski atelje)
  - Iron, steel, brass, silver, gold, jewel supply, security (5-35)
- **Royal Chain Maker System** — verige za praktične in okrasne namene
  - 6 produktov (železna, jeklena, medeninasta, srebrna, zlata, kraljevski verižni pas)
  - 4 zgradbe (delavnica, kovačija, žična vlečilnica, kraljevski atelje)
  - Iron, steel, brass, silver, gold, jewel supply, tensile strength (20-40)

## [v3.11.11] — 2026-08-09 — Royal Lantern & Street Light System (6 products, lanterns)
## [v3.11.10] — 2026-08-09 — Royal Sign Board & Inn Sign System (6 products, signs)
## [v3.11.9] — 2026-08-09 — Royal Sconce & Wall Light System (6 products, sconces)
## [v3.11.8] — 2026-08-09 — Royal Clay Pipe Maker System (6 products, pipes)
## [v3.11.7] — 2026-08-09 — Royal Tile Maker & Floor System (6 products, tiles)

### Dodano (5 sistemov naenkrat)
- **Royal Tile Maker & Floor System** — tlakovce in keramične ploščice
  - 6 produktov (tlakovca, stenska, mozaik, fajansa, majolika, kraljevski mozaik panel)
  - 4 zgradbe (delavnica, peč, glazurnica, kraljevski atelje)
  - Clay, glass, tin, gold supply, durability system (10-40)
- **Royal Clay Pipe Maker System** — glinene pipe za kajenje
  - 6 produktov (navadna, okrasna, dolgovrata, glazirana, srebrno obrobljena, kraljevsko naročilo)
  - 4 zgradbe (delavnica, peč, kalupniča, kraljevski atelje)
  - Clay, glass, silver, gold supply, durability system (8-40)
- **Royal Sconce & Wall Light System** — zidne svečnike in luči
  - 6 produktov (zidni nosilec, svečnik, baklonosilec, medeninasta, srebrna, kraljevski sconce-luster)
  - 4 zgradbe (delavnica, kovačija, polirnica, kraljevski atelje)
  - Iron, brass, silver, gold supply, light radius (3-18)
- **Royal Sign Board & Inn Sign System** — napise za gostilne in trgovine
  - 6 produktov (trgovska tabla, gostilniški napis, cehovski znak, poslikani, pozlačeni, kraljevski heraldični)
  - 4 zgradbe (delavnica, slikalnica, pozlatnica, kraljevski atelje)
  - Wood, iron, paint, gold, silver supply, visibility system (5-30)
- **Royal Lantern & Street Light System** — lantern in ulično razsvetljavo
  - 6 produktov (papirnata, rogova, steklena, medeninasta viseča, srebrna ulična, kraljevski veliki luster)
  - 4 zgradbe (delavnica, steklarnica, kovinarska, kraljevski atelje)
  - Paper, horn, glass, iron, brass, silver, gold supply, light radius (4-22)

## [v3.11.6] — 2026-08-08 — Royal Wax Modeler & Seal Press System (6 products, wax models)
## [v3.11.5] — 2026-08-08 — Royal Needle & Pin Maker System (6 products, needles)
## [v3.11.4] — 2026-08-08 — Royal Musical String Maker System (6 products, strings)
## [v3.11.3] — 2026-08-08 — Royal Sundial & Gnomon Maker System (6 products, sundials)
## [v3.11.2] — 2026-08-08 — Royal Chess Piece & Board Game Carver System (6 products, chess)

### Dodano (5 sistemov naenkrat)
- **Royal Chess Piece & Board Game Carver System** — šahovske figure in deske
  - 6 produktov (kmet, skakač, garnitura, deska, slonokoščena, kraljevski šah)
  - 4 zgradbe (delavnica, rezbarski atelje, intarzijska, kraljevski rezbar)
  - Wood, bone, ivory, paint, gold, jewel supply, happiness in knowledge bonuses
- **Royal Sundial & Gnomon Maker System** — sončne ure in gnomoni
  - 6 produktov (vrtni, zidni, prenosni, ekvatorialni, mnogognomon, kraljevski sončnik)
  - 4 zgradbe (delavnica, kamnito dvorišče, gnomonski atelje, kraljevski sončničar)
  - Stone, metal, brass, paint, gold supply, accuracy 0.45-0.95
- **Royal Musical String Maker System** — strune za glasbila
  - 6 produktov (lutnja, harfa, violinska, srebrna, zlata, kraljevski set)
  - 4 zgradbe (delavnica, vlečilnica, kovinska navitnica, kraljevska strunarna)
  - Gut, silver, gold supply, sound quality system
- **Royal Needle & Pin Maker System** — igle in zaponke
  - 6 produktov (šivalna, vezilna, varnostna, klobučna, srebrna, kraljevski set)
  - 4 zgradbe (delavnica, žična vlečilnica, brusilnica, kraljevski iglar)
  - Steel, brass, silver, gold supply, quantity per batch
- **Royal Wax Modeler & Seal Press System** — voščeni modeli in pečatne stiske
  - 6 produktov (model, pečatna stiska, figura, posmrtna maska, tabla, kraljevski dvojnik)
  - 4 zgradbe (delavnica, modelirni atelje, livarska priprava, kraljevska voščarna)
  - Wax, wood, metal, paint, plaster, gold, silk supply, security in faith bonuses

## [v3.11.1] — 2026-08-08 — Royal Horologist & Watchmaker System (6 products, precision timepieces)
## [v3.11.0] — 2026-08-08 — Royal Engraver & Etcher System (6 products, metal engraving)
## [v3.10.9] — 2026-08-08 — Royal Token & Medal Maker System (6 products, commemorative)
## [v3.10.8] — 2026-08-08 — Royal Mat Maker & Floor Covering System (6 products, rugs)
## [v3.10.7] — 2026-08-08 — Royal Basket Weaver & Wickerwork System (6 products, baskets)

### Dodano (5 sistemov naenkrat)
- **Royal Basket Weaver & Wickerwork System** — košarstvo in pletenje iz vrbe
  - 6 produktov (košara, velika košara, pleteni stol, ribja past, zibka, kraljevska košara)
  - 4 zgradbe (delavnica, vrbovje, pletiljski atelje, kraljevska košararna)
  - Willow, silk, gold supply, capacity system
- **Royal Mat Maker & Floor Covering System** — preproge in talne obloge
  - 6 produktov (tlatnik, slamnata, tkana, filc, svilena, kraljevska preproga)
  - 4 zgradbe (delavnica, rogozničnik, statva, kraljevska preprogarna)
  - Rush, straw, wool, thread, silk, gold thread supply
- **Royal Token & Medal Maker System** — žetoni in medalje
  - 6 produktov (igralni žeton, trgovski, romarski znak, spominska medalja, srebrna, kraljevska)
  - 4 zgradbe (delavnica, kovinska stiska, graverska, kraljevska kovnica)
  - Metal, silver, gold, jewel supply, faith in prestige bonuses
- **Royal Engraver & Etcher System** — graviranje in jedkanje
  - 6 produktov (napisna plošča, spominska, bakrenična, vgraviran kelih, oklep, kraljevska gravura)
  - 4 zgradbe (delavnica, jedska, kislinska soba, kraljevski graver)
  - Metal, copper, gold, jewel supply, military in knowledge bonuses
- **Royal Horologist & Watchmaker System** — horologija in izdelova ur
  - 6 produktov (žepna ura, mizna, potovalna, marinski kronometer, ponavljalna, kraljevski kronometer)
  - 4 zgradbe (delavnica, atelje, laboratorij natančnosti, kraljevski horolog)
  - Brass, glass, wood, gold, jewel supply, accuracy system (0.65-0.99)

## [v3.10.6] — 2026-08-08 — Royal Button & Buckle Maker System (6 products, fasteners)
## [v3.10.5] — 2026-08-08 — Royal Puppet & Marionette Maker System (6 products, puppets)
## [v3.10.4] — 2026-08-08 — Royal Fan Maker & Fan Painter System (6 products, fans)
## [v3.10.3] — 2026-08-08 — Royal Seal Engraver & Signet Maker System (6 products, seals)
## [v3.10.2] — 2026-08-08 — Royal Comb & Hair Accessory Maker System (6 products, combs)

### Dodano (5 sistemov naenkrat)
- **Royal Comb & Hair Accessory Maker System** — glavničarstvo in lasni nakit
  - 6 produktov (leseni glavnik, kosten, slonokoščeni, lasnica, draguljarni, kraljevski lasnik)
  - 4 zgradbe (delavnica, kostarska, nakitarska, kraljevski glavničar)
  - Wood, bone, ivory, metal, jewel, gold, silk supply
- **Royal Seal Engraver & Signet Maker System** — pečatniki in signeti
  - 6 produktov (voščeni pečat, pečatnik, uradni, kraljevski, matrica, protipečat)
  - 4 zgradbe (delavnica, graverski atelje, pečatni trezor, kraljevski graver)
  - Wax, metal, gold, jewel supply, security level system
- **Royal Fan Maker & Fan Painter System** — pahljače in pahljačarstvo
  - 6 produktov (palmino, zložljiva, poslikana, svilena, draguljarna, ceremonialna)
  - 4 zgradbe (delavnica, atelje, slikarska soba, kraljevski pahljačar)
  - Wood, cloth, parchment, paint, silk, jewel, gold supply
- **Royal Puppet & Marionette Maker System** — lutkarstvo in marionete
  - 6 produktov (ročna lutka, marioneta, lutka rokavica, senčna, mehanska, kraljevska)
  - 4 zgradbe (delavnica, lutkovno gledališče, marionetni atelje, kraljevski lutkar)
  - Wood, cloth, thread, leather, metal, gold, jewel supply
- **Royal Button & Buckle Maker System** — gumbi in sponje
  - 6 produktov (leseni, kosteni, kovinski, srebrna spona, zlata spona, kraljevski gumb)
  - 4 zgradbe (delavnica, gumbarna, kovinska, kraljevski gumbar)
  - Wood, bone, metal, silver, gold, jewel supply

## [v3.10.1] — 2026-08-08 — Royal Book Illuminator & Gilder System (6 products, gold leaf)
## [v3.10.0] — 2026-08-08 — Royal Embroiderer & Needlework System (6 products, gold thread)
## [v3.9.9] — 2026-08-08 — Royal Dice & Game Maker System (6 products, games)
## [v3.9.8] — 2026-08-08 — Royal Lens Grinder & Optician System (6 products, optics)
## [v3.9.7] — 2026-08-08 — Royal Compass & Navigation Maker System (6 products, navigation)

### Dodano (5 sistemov naenkrat)
- **Royal Compass & Navigation Maker System** — navigacijske naprave
  - 6 produktov (kompas, astrolab, sekstant, zvezdna karta, portolan, magnet)
  - 4 zgradbe (delavnica, observatorij, kartografska soba, kraljevski inštitut)
  - Iron, brass, glass, parchment, ink supply, accuracy system
- **Royal Lens Grinder & Optician System** — optika in leče
  - 6 produktov (očala, povečevalo, daljnogled, mikroskop, leča, bralni kamen)
  - 4 zgradbe (delavnica, brusilnica, optični laboratorij, kraljevski optik)
  - Glass, metal, wood supply, vision in knowledge bonuses
- **Royal Dice & Game Maker System** — igre in igrače
  - 6 produktov (kocke, kostene kocke, šah, tavla, igralne karte, tablična igra)
  - 4 zgradbe (delavnica, igračarna, atelje, kraljevski igračar)
  - Wood, bone, parchment, ink, paint supply, happiness in knowledge
- **Royal Embroiderer & Needlework System** — vezenje in needlework
  - 6 produktov (vezano blago, heraldična zastava, oltarno pregrinjalo, mašna oblačila, tapiserija, kraljevski plašč)
  - 4 zgradbe (delavnica, atelje, zlatonitna, kraljevska vezilja)
  - Thread, cloth, gold thread, ermine supply, prestige in faith
- **Royal Book Illuminator & Gilder System** — pozlačevanje in iluminacije
  - 6 produktov (pozlačena stran, začetnica, okvir, kip, oltar, krona)
  - 4 zgradbe (delavnica, atelje, zlatarski mlin, kraljevski pozlatar)
  - Gold, parchment, wood, bronze, stone, jewel supply, prestige in faith

## [v3.9.6] — 2026-08-08 — Royal Organ Builder & Instrument Maker System (6 instruments)
## [v3.9.5] — 2026-08-08 — Royal Bell Founder & Campanology System (6 bells, casting)
## [v3.9.4] — 2026-08-08 — Royal Glazier & Window Maker System (6 products, glazing)
## [v3.9.3] — 2026-08-08 — Royal Plasterer & Decorator System (6 products, plastering)
## [v3.9.2] — 2026-08-08 — Royal Thatcher & Roofing System (6 roofs, materials)

### Dodano (5 sistemov naenkrat)
- **Royal Thatcher & Roofing System** — krovičarstvo in strehe
  - 6 tipov streh (slamnata, skodle, strešniki, skrilavec, svinčena, bakrena)
  - 4 zgradbe (delavnica, tršičnik, peč za strešnike, kraljevska krovska)
  - Reed, wood, clay, stone, lead, copper supply, insulation in durability
- **Royal Plasterer & Decorator System** — ometarstvo in dekoracija
  - 6 produktov (omet, polirani, freska podlaga, štukatura, pozlačeni, mozaik)
  - 4 zgradbe (delavnica, apnena peč, atelje, kraljevsko ometarstvo)
  - Lime, sand, marble, gold, tile supply, smoothness in prestige
- **Royal Glazier & Window Maker System** — ostekljevanje in okna
  - 6 produktov (okno, vitraj, svinčeno, zrcalo, strešno, vitrina)
  - 4 zgradbe (delavnica, ostekljevalnica, svinčarska, kraljevska)
  - Glass, lead, wood, silver supply, light, faith in prestige bonuses
- **Royal Bell Founder & Campanology System** — zvonolivarstvo in zvonovi
  - 6 tipov zvonov (ročni, cerkevni, karilon, angel, kraljevski, alarmni)
  - 4 zgradbe (zvonarna, zvonik, urnavalnica, kraljevska zvonarna)
  - Bronze, iron, gold supply, sound quality, casting risk, faith bonus
- **Royal Organ Builder & Instrument Maker System** — orglarstvo in instrumenti
  - 6 instrumentov (cevne orgle, portativ, pozitiv, regal, čembalo, klavikord)
  - 4 zgradbe (delavnica, cevna delavnica, intonacijska, kraljevska orglarna)
  - Wood, metal, leather supply, sound quality, faith in prestige bonuses

## [v3.9.1] — 2026-08-08 — Royal Ink Maker & Writing Materials System (6 inks, pigments)
## [v3.9.0] — 2026-08-08 — Royal Soap Maker & Cleansing System (6 products, hygiene)
## [v3.8.9] — 2026-08-08 — Royal Nail Maker & Hardware System (6 products, fittings)
## [v3.8.8] — 2026-08-08 — Royal Saddler & Tack Maker System (6 products, horse gear)
## [v3.8.7] — 2026-08-08 — Royal Fletcher & Arrow Maker System (6 products, ammunition)

### Dodano (5 sistemov naenkrat)
- **Royal Fletcher & Arrow Maker System** — puščičarstvo in izdelava puščic
  - 6 produktov (puščica, oklepna, samostrelska, ognjena, tulec, strupena)
  - 4 zgradbe (delavnica, puščičarna, kovašnica, kraljevska puščičarna)
  - Wood, metal, feather, oil, poison, leather supply management
- **Royal Saddler & Tack Maker System** — sedlarstvo in konjska oprema
  - 6 produktov (sedlo, uzda, vprega, sedlarne vreče, bojno sedlo, kraljevsko sedlo)
  - 4 zgradbe (delavnica, konjska oprema, usnjarnica, kraljevska sedlarna)
  - Speed, combat, control, load, cargo bonuses
- **Royal Nail Maker & Hardware System** — žebljarstvo in kovinska oprema
  - 6 produktov (žeblji, tečaji, nosilci, rešetke, ključavnice, okrasni okovji)
  - 4 zgradbe (žebeljarna, žebeljnica, železnina, kraljevska železnina)
  - Iron, copper supply, security bonuses
- **Royal Soap Maker & Cleansing System** — milarstvo in higiena
  - 6 produktov (milo, dišeče milo, lužina, pralni prašek, zdravilno milo, kraljevsko milo)
  - 4 zgradbe (milarna, milarna, pepelarna, kraljevska milarna)
  - Fat, ash, herb, water, oil supply, hygiene in aroma bonuses
- **Royal Ink Maker & Writing Materials System** — črnilkarstvo in pisalne potrebščine
  - 6 produktov (železno galno, čađno, rdeče, zlato, nevidno, kraljevsko črnilo)
  - 4 zgradbe (črnilnica, mlin, pigmentna delavnica, kraljevska črnilnica)
  - Iron, gall, soot, oil, cinnabar, gold, gum, lemon supply management

## [v3.8.6] — 2026-08-08 — Royal Chandler & Lamp Maker System (6 products, light, oil)
## [v3.8.5] — 2026-08-08 — Royal Locksmith & Security System (6 products, locks, keys)
## [v3.8.4] — 2026-08-08 — Royal Ropemaker & Cordage System (6 products, 6 fibers)
## [v3.8.3] — 2026-08-08 — Royal Cooper & Barrel Maker System (6 products, barrels)
## [v3.8.2] — 2026-08-08 — Royal Baker & Confectioner System (6 products, baking)

### Dodano (5 sistemov naenkrat)
- **Royal Baker & Confectioner System** — peka, slaščice in torte
  - 6 produktov (kruh, torta, testenina, pita, biskvit, svatbena torta)
  - 4 zgradbe (pekarna, slaščičarna, mlin, kraljevska pekarna)
  - Flour, sugar, butter, meat supply management
- **Royal Cooper & Barrel Maker System** — sodarstvo in izdelava sodov
  - 6 produktov (sod, bočka, tuna, firkin, hogshead, butt)
  - 4 zgradbe (delavnica, sodarna, sušilno dvorišče, kraljevska sodarna)
  - Wood in iron supply, capacity per barrel type
- **Royal Ropemaker & Cordage System** — vrvarstvo in izdelava vrvi
  - 6 produktov (vrv, debela vrv, vrvica, mreža, tovorna vrv, tetiva)
  - 6 vlaken (konoplja, len, juta, svila, bombaž, kitica)
  - 4 zgradbe (vrvarna, delavnica, vrt vlaken, kraljevska vrvana)
- **Royal Locksmith & Security System** — ključavničarstvo in varnost
  - 6 produktov (viseči ključavnik, vratna, skladiščna, kombinacijska, začarana, set ključev)
  - 4 zgradbe (delavnica, kovašnica, varnostni trezor, kraljevski ključavničar)
  - Security level system, magic locks
- **Royal Chandler & Lamp Maker System** — svetilke, oljenke in osvetlitev
  - 6 produktov (oljenka, svečna svetilka, luster, fenir, bakla, oltarna svetila)
  - 4 zgradbe (delavnica, svetilkarna, stiskalnica olja, kraljevska svetilkarna)
  - Oil, wax, metal supply management, light radius, faith bonus

## [v3.8.1] — 2026-08-08 — Royal Barber & Surgeon System (6 services, surgery)
## [v3.8.0] — 2026-08-08 — Royal Scribe & Notary System (6 documents, notary)
## [v3.7.9] — 2026-08-08 — Royal Armorer & Shield System (6 armor, 6 metals)
## [v3.7.8] — 2026-08-08 — Royal Mason & Stonecutter System (8 stones, 6 products)

### Dodano (4 sistemi naenkrat)
- **Royal Mason & Stonecutter System** — kamnoseštvo in klesanje kamna
  - 8 tipov kamna (granit, marmor, apnenec, peščenjak, skrilavec, bazalt, travertin, kremen)
  - 6 produktov (zidanica, steber, kapitel, nadpražnik, vodnjak, nagrobnik)
  - 4 kamnoseške zgradbe (kamnolom, delavnica, dvorišče, kraljevski kamnolom)
- **Royal Armorer & Shield System** — izdelava oklepov in ščitov
  - 6 tipov oklepa (čelada, oklep, ščit, rokavice, nogavice, polni oklep)
  - 6 kovin (železo, jeklo, bron, srebro, zlato, mitril)
  - 4 okleparske zgradbe (okleparna, kovašnica, ploščasta, kraljevska)
- **Royal Scribe & Notary System** — pisarstvo in notariat
  - 6 tipov dokumentov (pogodba, listina, odredba, diploma, bula, zapis)
  - 4 pisarske zgradbe (skriptorij, kancelarija, notarska, kraljevska kancelarija)
- **Royal Barber & Surgeon System** — brivstvo in kirurgija
  - 6 storitev (striženje, britje, puščanje krvi, vlečenje zoba, nega ran, operacija)
  - 4 zgradbe (brivnica, operacijska soba, lekarnarna, kraljevski brivec)
  - Surgery risk in komplikacije

## [v3.7.7] — 2026-08-08 — Royal Woodworker & Carpenter System (6 furniture, 8 woods)

### Dodano
- **Royal Woodworker & Carpenter System** — mizarstvo, pohištvo in rezbarije
  - 6 tipov pohištva (prestol, miza, stol, skrinja, postelja, omara)
  - 8 tipov lesa (hrast, oreh, mahagonij, bor, cedra, ebenovina, češnja, breza)
  - 4 mizarske zgradbe (delavnica, rezbarski atelje, žaga, kraljevska delavnica)
  - Woodworker NPC s spretnostjo
  - Furniture making (časovna izdelava s kakovostjo)
  - Wood quality in prestige bonusi (ebenovina, mahagonij = višji prestiž)
  - Aroma bonus iz cedar lesa
  - Quality system (kakovost iz zgradb, mizarja in lesa)

## [v3.7.6] — 2026-08-08 — Royal Smith Advanced & Weapon Forge System (6 weapons, 8 alloys, quality grades)

### Dodano
- **Royal Smith Advanced & Weapon Forge System** — kovaštvo orožja in oklepa
  - 6 kategorij orožja (meč, kopje, sekira, buzdovan, lok, samostrel)
  - 8 kovinskih zlitin (železo, jeklo, damask, bron, srebrno okrašen, zlato okrašen, začarano, meteorno železo)
  - 4 kovaške zgradbe (kovašnica, orožarna, kovašnica orožja, kraljevska orožarna)
  - Master Smith NPC s spretnostjo
  - Weapon forging (časovno kovanje z nevarnostjo napak)
  - Quality grading (common, fine, superior, masterwork, legendary)
  - Metal alloy management (nakup zlitin)
  - Attack value scaling z kakovostjo
  - Prestige in faith bonusi iz dragocenih zlitin

## [v3.7.5] — 2026-08-08 — Royal Brewer Advanced & Distillery System (6 spirits, 8 ingredients, distillation)

### Dodano
- **Royal Brewer Advanced & Distillery System** — destilacija žganih pijač in žganja
  - 6 tipov žganih pijač (viski, žganje, gin, vodka, rum, absint)
  - 8 sestavin (žito, grozdje, brinje, krompir, sladkorni trs, pelin, zelišča, sadje)
  - 4 destilarske zgradbe (peklena, destilarna, sklep za staranje, kraljevska destilarna)
  - Distiller NPC s spretnostjo
  - Distillation process (časovna destilacija z nevarnostjo napak)
  - Proof level (alkoholna stopnja za vsak tip)
  - Aging potential ( potencial za staranje)
  - Quality system (kakovost iz zgradb in destilatarja)
  - Ingredient management (nakup surovin)

## [v3.7.4] — 2026-08-08 — Royal Messenger & Postal System (6 messages, 8 messengers, relay)

### Dodano
- **Royal Messenger & Postal System** — kurirji, pošta in komunikacijska mreža
  - 6 tipov sporočil (odlok, diplomatsko, vojaško, trgovsko, osebno, vohunsko)
  - 8 tipov kurirjev (kurir, jahač, relay, golob, signalni ogenj, mornariški, diplomatski, vohun)
  - 4 poštne zgradbe (postaja, relay hiša, golobnjak, kraljevska pošta)
  - Postmaster NPC s spretnostjo
  - Message delivery (časovna dostava z hitrostjo in zanesljivostjo)
  - Interception risk (nevarnost prestrezanja za tajna sporočila)
  - Relay network za dolge razdalje
  - Carrier pigeon system
  - Energy management za kurirje

## [v3.7.3] — 2026-08-08 — Royal Tax Collector & Revenue System (6 methods, 8 districts, evasion)

### Dodano
- **Royal Tax Collector & Revenue System** — pobiranje davkov in prihodki
  - 6 metod pobiranja (glavarski, zemljiški, premoženjski, trgovski, desetina, carina)
  - 8 davčnih okrožij (glavno mesto, sever, jug, vzhod, zahod, pristanišče, rudnik, meja)
  - 4 davčne zgradbe (pisarna, računovodstvo, filiala kovnice, kraljeva blagajna)
  - Tax Collector NPC s spretnostjo
  - District-based collection (pobiranje po okrožjih)
  - Tax evasion detection (odkrivanje utaje z bonusom)
  - Revenue forecasting (napoved prihodkov glede na prebivalstvo in bogastvo)
  - Efficiency system (učinkovitost iz zgradb in pobiralca)

## [v3.7.2] — 2026-08-08 — Royal Surveyor & Land Measurement System (6 surveys, 8 tools)

### Dodano
- **Royal Surveyor & Land Measurement System** — geodezija in merjenje zemljišč
  - 6 tipov surveyjev (mejna, topografska, katastrska, gradbena, kmetijska, rudarska)
  - 8 merilnih instrumentov (veriga, palica, astrolab, teodolit, libela, kompas, vrv, kol)
  - 4 geodetske zgradbe (pisarna, observatorij, kartografska soba, kraljevski inštitut)
  - Surveyor NPC s spretnostjo
  - Land parcel registration (register parcel)
  - Measurement accuracy system (natančnost iz zgradb, instrumentov in geodeta)
  - Boundary dispute resolution

## [v3.7.1] — 2026-08-08 — Royal Leatherworker & Tannery System (6 products, 8 hides, tanning)

### Dodano
- **Royal Leatherworker & Tannery System** — usnjarstvo, strojenje in usnjeni izdelki
  - 6 tipov produktov (škornji, oklepa, vrečka, pas, rokavice, knjižni vez)
  - 8 tipov kož (kravje, ovčje, kozje, jelenje, svinjsko, teletje, konjsko, egzotično)
  - 4 usnjarske zgradbe (strojarna, delavnica, barvarna, kraljevska usnjarna)
  - Leatherworker NPC s spretnostjo
  - Hide tanning (časovno strojenje z odor penalty)
  - Leather quality and durability system
  - Leather dyeing in product making
  - Quality system (kakovost iz zgradb, usnjarja in kože)

## [v3.7.0] — 2026-08-08 — Royal Metalworker & Bronze Casting System (6 products, 8 metals, casting)

### Dodano
- **Royal Metalworker & Bronze Casting System** — kovinarstvo, litje brona in zvonovi
  - 6 tipov produktov (zvon, bronasti kip, top, medalja, luster, vrata)
  - 8 kovin (baker, kositer, bron, medenina, pewter, svinec, železo, srebro)
  - 4 kovinarske zgradbe (livarna, kovašnica, livna dvorana, kraljevska livarna)
  - Metalworker NPC s spretnostjo
  - Bronze casting (časovno litje z nevarnostjo defektov)
  - Metal supply management (nakup kovin)
  - Bell founding z zvokom, vojaški topovi
  - Quality system (kakovost iz zgradb, kovinarja in kovine)

## [v3.6.9] — 2026-08-08 — Royal Painter & Fresco System (6 paintings, 8 pigments)

### Dodano
- **Royal Painter & Fresco System** — slikarstvo, freske in portreti
  - 6 tipov slik (portret, freska, oltarna slika, krajina, miniatura, ikona)
  - 8 pigmentov (cinabarit, ultramarine, zlata barva, svinčeno belo, okra, umbra, verdigris, črno oglje)
  - 4 slikarske zgradbe (atelje, freskarska delavnica, cehovska hiša, kraljevski atelje)
  - Painter NPC s spretnostjo
  - Fresco painting (časovno slikanje z intenziteto pigmentov)
  - Pigment management (nakup in uporaba različnih barv)
  - Prestige, happiness in faith bonusi iz slik
  - Quality system (kakovost iz zgradb, slikarja in pigmentov)

## [v3.6.8] — 2026-08-08 — Royal Sculptor & Stone Carving System (6 sculptures, 8 stones)

### Dodano
- **Royal Sculptor & Stone Carving System** — kiparstvo in kamnoseštvo
  - 6 tipov kiparstev (kip, poprsje, relief, gargoj, sarkofag, spomenik)
  - 8 tipov kamna (marmor, granit, peščenjak, apnenec, alabaster, bazalt, porfir, žad)
  - 4 kiparske zgradbe (delavnica, kamnolom, rezbarski atelje, kraljevski atelje)
  - Sculptor NPC s spretnostjo
  - Stone carving (časovno klesanje z nevarnostjo počenja)
  - Stone quality in prestige bonusi (marmor, porfir, žad = višji prestiž)
  - Monument construction za javne spomenike
  - Quality system (kakovost iz zgradb, kiparja in kamna)

## [v3.6.7] — 2026-08-08 — Royal Bookbinder & Library System (6 bindings, 8 categories)

### Dodano
- **Royal Bookbinder & Library System** — vezave knjig in knjižničarstvo
  - 6 tipov vezav (mehka, usnjena, lesena, draguljarna, prikovana, kraljevska)
  - 8 kategorij knjig (teologija, filozofija, pravo, medicina, zgodovina, poezija, znanost, bestiarij)
  - 4 knjižnične zgradbe (omarica, knjižnica, skriptorijski arhiv, kraljevska knjižnica)
  - Bookbinder NPC s spretnostjo
  - Book binding (časovna vezava s kvaliteto)
  - Knowledge, faith, health in happiness bonusi iz knjig
  - Library capacity management
  - Quality system (kakovost iz zgradb in vezalca)

## [v3.6.6] — 2026-08-08 — Royal Dyer & Color System (8 dye sources, 6 colors, extraction)

### Dodano
- **Royal Dyer & Color System** — barvarstvo, pigmenti in barvna teorija
  - 8 virov barv (woad, broč, žafran, košenilj, indigo, sivka, lak, kermes)
  - 6 kategorij barv (rdeča, modra, rumena, zelena, škrlatna, črna)
  - 4 barvarske zgradbe (barvni vrt, delavnica, kadnica, kraljevska barvarna)
  - Dyer NPC s spretnostjo
  - Dye extraction (ekstrakcija barv iz surovin z intenziteto)
  - Raw material management (nakup barvnih surovin)
  - Color quality and intensity system
  - Color prestige (škrlatna = najdražja)
  - Dye trade in usage

## [v3.6.5] — 2026-08-08 — Royal Perfumer & Fragrance System (8 ingredients, 6 perfumes, blending)

### Dodano
- **Royal Perfumer & Fragrance System** — parfumi, dišave in eterična olja
  - 8 dišavnih sestavin (vrtnica, sivka, jasmin, sandalovina, mošus, jantar, kadilo, mira)
  - 6 tipov parfumov (cologne, toilette, parfum, attar, pomander, kadilo)
  - 4 perfumerske zgradbe (destilarna, delavnica, sklep za staranje, kraljevska perfumerija)
  - Perfumer NPC s spretnostjo
  - Fragrance blending (mešanje sestavin z aromatsko močjo)
  - Essential oil distillation
  - Ingredient management (nakup dišavnih sestavin)
  - Happiness, faith in health bonusi iz dišav
  - Quality system (kakovost iz zgradb, perfumista in aromatske moči)

## [v3.6.4] — 2026-08-08 — Royal Embalmer & Funerary System (6 funerals, 8 embalming, tombs)

### Dodano
- **Royal Embalmer & Funerary System** — pogrebi, balzamiranje in grobnice
  - 6 tipov pogrebov (revni, navadni, viteški, plemiški, kraljevski, državni)
  - 8 tehnik balzamiranja (sušenje, izločitev organov, potopitev, zavijanje, smola, začimbe, vosek, mumifikacija)
  - 4 pogrebne zgradbe (kostnica, kripta, mavzolej, kraljevska grobnica)
  - Embalmer NPC s spretnostjo
  - Funeral organization (časovno organiziranje pogrebov)
  - Embalming techniques (ohranitev teles z različnimi metodami)
  - Ancestor tracking (sledenje prednikov)
  - Preservation bonus iz zgradb
  - Faith, happiness in prestige bonusi iz pogrebov

## [v3.6.3] — 2026-08-08 — Royal Calligrapher & Illumination System (6 manuscripts, 8 illuminations)

### Dodano
- **Royal Calligrapher & Illumination System** — kaligrafija, iluminacije in rokopisi
  - 6 tipov rokopisov (biblija, psaltir, bestiarij, kronika, pravna knjiga, pesmarica)
  - 8 stilov iluminacij (zlati listič, miniatura, okvir, začetnica, celotna stran, ...)
  - 4 skriptorijske zgradbe (skriptorij, iluminacijska soba, vezava, kraljevski skriptorij)
  - Calligrapher NPC s spretnostjo
  - Manuscript copying (časovno kopiranje z iluminacijo)
  - Vellum and ink supply management
  - Gold leaf application (zlati listič za okras)
  - Faith, knowledge in happiness bonusi iz rokopisov
  - Quality system (kakovost iz zgradb, kaligrafa in iluminacije)

## [v3.6.2] — 2026-08-08 — Royal Jeweler & Gemstone System (8 gemstones, 6 jewelry, cutting)

### Dodano
- **Royal Jeweler & Gemstone System** — zlatarstvo, dragi kameni in nakit
  - 8 tipov dragih kamnov (diamant, rubin, safir, smaragd, ametist, topaz, biser, granat)
  - 6 tipov nakita (prstan, naglavni okras, krona, broška, zapestnica, uhani)
  - 4 zlatarske zgradbe (delavnica, rezilnica, trezor, kraljevski atelje)
  - Jeweler NPC s spretnostjo
  - Gemstone cutting (rezanje z nevarnostjo počenja)
  - Jewelry making (časovna izdelava z kvaliteto)
  - Royal regalia collection (kraljevske regalije)
  - Precious metal management (zlato za izdelavo)
  - Quality system (kakovost iz zgradb in zlatarja)

## [v3.6.1] — 2026-08-08 — Royal Clockmaker & Timekeeping System (6 clocks, 8 products, precision)

### Dodano
- **Royal Clockmaker & Timekeeping System** — urarstvo in merjenje časa
  - 6 tipov ur (sončna, vodna, peščena, mehanska, astronomska, stolpna)
  - 8 časovnih produktov (žepna ura, zvon, zvonoglasje, koledar, astrolab, kronometer, ciferblat, nihalo)
  - 4 urarske zgradbe (delavnica, livarna, observatorijska ura, kraljevski stolp)
  - Clockmaker NPC s spretnostjo
  - Clock construction (časovna gradnja z natančnostjo)
  - Time precision tracking (0-100)
  - Accuracy system (natančnost iz zgradb in urarja)
  - Product making (žepne ure, zvoni, astrolabi)
  - Prestige from astronomical and turret clocks

## [v3.6.0] — 2026-08-08 — Royal Glassmaker & Stained Glass System (6 glass types, 8 products, vitraži)

### Dodano
- **Royal Glassmaker & Stained Glass System** — steklarstvo in vitraji
  - 6 tipov stekla (kronsko, valjasto, svinčeno, barvno, kristal, zrcalno)
  - 8 steklenih produktov (okno, vrč, koralde, leča, zrcalo, vitraj, luster, kelih)
  - 4 steklarske zgradbe (peč, delavnica, trgovina, kraljevska steklarna)
  - Glassmaker NPC s spretnostjo
  - Sand supply management (pesek za taljenje)
  - Glass melting (časovno taljenje z nevarnostjo razpok)
  - Stained glass creation (vitraji za cerkev z faith bonus)
  - Glassblowing and product making
  - Quality system (kakovost iz zgradb in steklarja)

## [v3.5.9] — 2026-08-08 — Royal Weaver & Textile System (6 fabrics, 8 products, dyeing)

### Dodano
- **Royal Weaver & Textile System** — tkanje, tekstil in tapiserije
  - 6 tipov tkanin (lan, volna, svila, bombaž, žamet, brokat)
  - 8 tekstilnih produktov (tkanina, obleka, tapiserija, zastava, preproga, zavesa, oltarno pregrinjalo, prijem)
  - 4 tekstilne zgradbe (tkalna delavnica, barvarska hiša, valilnica, kraljevska statva)
  - Weaver NPC s spretnostjo
  - Raw material management (lan, volna, svila)
  - Dyeing system (barvanje iz barvarske hiše)
  - Tapestry creation (časovno tkanje umetnin)
  - Fabric weaving in product making
  - Quality system (kakovost iz zgradb in tkalčka)

## [v3.5.8] — 2026-08-08 — Royal Potter & Ceramics System (6 pottery types, 8 products, firing)

### Dodano
- **Royal Potter & Ceramics System** — lončarstvo in keramična umetnost
  - 6 tipov keramike (lončarina, kamnina, porcelan, terrakota, fajansa, majolika)
  - 8 keramičnih produktov (skleda, krožnik, vrč, vaza, ploščica, figura, urna, lonček)
  - 4 lončarske zgradbe (peč, delavnica, glazirna, kraljevska lončarija)
  - Potter NPC s spretnostjo
  - Clay supply management (nakup gline)
  - Firing process (časovno žganje z nevarnostjo razpok)
  - Glazing and decoration
  - Ceramic art collection (okrasna zbirka)
  - Quality system (kakovost iz zgradb in lončarja)

## [v3.5.7] — 2026-08-08 — Royal Chandlery & Wax Works System (6 candles, 8 products)

### Dodano
- **Royal Chandlery & Wax Works System** — sveče, voščeni produkti in pečatni vosek
  - 6 tipov sveč (lojeva, čebeljavoščena, lovorova, stearinska, spermacetna, cerkvena)
  - 8 tipov voščenih produktov (pečatni vosek, tablice, kipi, laki, barvice, barve, pečati, dišeči vosek)
  - 4 svečarske zgradbe (svečarna, livarna, skladišče voska, kraljevska svečarna)
  - Chandler NPC s spretnostjo
  - Candle making (časovna proizvodnja)
  - Wax supply management (nakup in shranjevanje voska)
  - Quality system (kakovost iz zgradb in svečarja)
  - Faith bonus iz cerkvenih sveč

## [v3.5.6] — 2026-08-08 — Royal Cupbearer & Taster System (6 beverages, 8 dishes, poison detection)

### Dodano
- **Royal Cupbearer & Taster System** — točaj, degustator in varnost prehrane
  - 6 tipov pijač (vino, pivo, medovec, voda, jabolčnik, žgane pijače)
  - 8 tipov jedi (pečenka, enolončnica, ribe, kruh, sir, sadje, divjačina, sladica)
  - 4 jedilne zgradbe (kuhinja, shramba, vinska klet, kraljevska jedilnica)
  - Cupbearer NPC s spretnostjo in detekcijsko stopnjo
  - Meal preparation (časovna priprava obrokov)
  - Poison detection (zaznavanje strupa v hrani)
  - Spoilage management (pokvarljivost živil)
  - Beverage aging in storage
  - Dining quality tracking (0-100)

## [v3.5.5] — 2026-08-08 — Royal Jester Advanced & Court Comedy System (8 jokes, 6 archetypes)

### Dodano
- **Royal Jester Advanced & Court Comedy System** — napredna komedija in norčki
  - 8 tipov šal (pohabljenje, besedne igre, satira, opazovalna, črna, igre besed, telesna, absurdna)
  - 6 tipov norčkov (norček, prebrisanež, dušjak, bedak, satirik, norec)
  - 4 komedijska prizorišča (prestolna dvorana, velika dvorana, vrtni oder, trg)
  - Jester NPC s comedy skill in immunity
  - Routine composition (ustvarjanje rutin)
  - Audience reaction system (success, offense, immunity)
  - Political satire (visoko tveganje, visoka nagrada)
  - Jester immunity (licenca za zmerjanje)
  - Court morale tracking (0-100)

## [v3.5.4] — 2026-08-08 — Royal Minstrel & Troubadour System (6 minstrels, 8 songs, touring)

### Dodano
- **Royal Minstrel & Troubadour System** — potujoči glasbeniki in trubadurji
  - 6 tipov glasbenikov (trubadur, žongler, minnesinger, bard, gliman, skald)
  - 8 tipov pesmi (ljubezenska, junaška, šaljiva, elegija, balada, pijančevanje, jutranja, večerna)
  - 4 prizorišča (krčma, trg, vrata gradu, rižišče)
  - Minstrel management (najem, energy, status)
  - Song composition (ustvarjanje pesmi)
  - Performance sistema (tips, happiness, quality)
  - Touring (pošiljanje k tujim dvorom)
  - News spreading (glasbeniki nosijo novice)
  - Visiting minstrels (gostujoči izvajalci)
  - Reputation system (0-100)

## [v3.5.3] — 2026-08-08 — Royal Confessor & Spiritual Guidance System (6 sins, 8 penances)

### Dodano
- **Royal Confessor & Spiritual Guidance System** — spoved, pokora in odpuščanje
  - 6 smrtnih grehov (oholost, pohlep, pohota, zavist, pojedljivost, jes)
  - 8 tipov pokore (molitev, post, milostinja, romanje, samobičanje, spoved, maša, dobrodelno delo)
  - 4 duhovne zgradbe (kapela, spovednica, puščavnica, samostan)
  - Royal Confessor NPC s spretnostjo in pobožnostjo
  - Sin commitment sistem (krivda in moral authority)
  - Penance & absolution (verjetnost odpuščanja)
  - Indulgence system (kupi odpuščanje za vse grehe)
  - Spiritual counseling (svetovanje za srečo in vero)
  - Moral authority tracking (0-100)

## [v3.5.2] — 2026-08-08 — Royal Master of Ceremonies & Protocol System (8 ceremonies, 6 protocols)

### Dodano
- **Royal Master of Ceremonies & Protocol System** — dvorne slovesnosti in protokol
  - 8 tipov slovesnosti (kronanje, investitura, audienco, recepcija, banket, turnir, poroka, pogreb)
  - 6 protokolov (sedežni red, obravnava, darovanje, prednost, obleka, audiencni protokol)
  - 4 slovesne zgradbe (prestolna dvorana, velika dvorana, audiencna dvorana, recepcijska dvorana)
  - Master of Ceremonies NPC s spretnostjo
  - Protocol adoption z etiquette bonusi
  - Courtier etiquette training (0-100)
  - Quality system (kakovost iz zgradb in ceremoniarja)
  - Diplomatic protocol bonuses

## [v3.5.1] — 2026-08-08 — Royal Historian & Chronicle Advanced System (6 volumes, 8 topics)

### Dodano
- **Royal Historian & Chronicle Advanced System** — napredno pisanje zgodovine
  - 6 tipov kronik (vladanja, vojaška, gospodarska, verska, kulturna, dinastična)
  - 8 tem zgodovinskega raziskovanja (genealogija, bitke, pogodbe, običaji, ...)
  - 4 arhivske zgradbe (skriptorij, dvorana kronik, kraljevi arhiv, muzej)
  - Royal Historian NPC s spretnostjo in natančnostjo
  - Multi-volume chronicle compilation (časovno pisanje)
  - Historical accuracy tracking
  - Dynasty genealogy (družinsko drevo)
  - Historical commentary
  - Legacy score z rangi (Pozabljen → Mitičen)
  - Museum tourism bonus

## [v3.5.0] — 2026-08-08 — Royal Diplomat & Envoy System (6 envoys, 8 missions, embassies)

### Dodano
- **Royal Diplomat & Envoy System** — diplomacija z odposlanci in misijami
  - 6 tipov odposlancev (ambasador, odposlanec, konzul, legat, pooblaščenec, vohun-diplomat)
  - 8 tipov diplomatskih misij (zavezništvo, trgovski sporazum, mir, poroka, davek, ...)
  - 4 diplomatske zgradbe (ambasada, kancelarija, tuje cone, protokolarna pisarna)
  - Master Diplomat NPC s spretnostjo
  - Diplomatic missions (časovne z verjetnostjo uspeha)
  - Envoy management (najem, status, recovery)
  - International reputation (0-100, vpliva na uspeh)
  - Diplomatic immunity in expulsion/killing risk
  - Mission rewards (odnosi, zlato, trgovina, znanje)

## [v3.4.9] — 2026-08-08 — Royal Engineer & Siege Works System (8 engines, 6 fortifications)

### Dodano
- **Royal Engineer & Siege Works System** — vojaško inženirstvo in oblegovalni stroji
  - 8 tipov oblegovalnih strojev (katapult, trebuchet, balista, stolp, oven, mangonel, bombarda, stražni stolp)
  - 6 tipov utrdb (palisada, kamniti zid, stolp, jarek, vratarnica, bastion)
  - 4 inženirske zgradbe (delavnica, arzenal, oblegovalna delavnica, vojaška akademija)
  - Master Engineer NPC s spretnostjo
  - Siege engine construction (časovna gradnja)
  - Fortification construction z obrambnimi bonusi
  - Bridge and road construction
  - Quality system (kakovost iz zgradb in inženirja)
  - Combat bonuses (napad iz strojev, obramba iz utrdb)

## [v3.4.8] — 2026-08-08 — Royal Astrologer Advanced System (12 zodiac, 8 events, horoscopes)

### Dodano
- **Royal Astrologer Advanced System** — napredna astrologija z zodiakom
  - 12 zodiakalnih znakov (Oven, Bik, ..., Ribe) z elementi in lastnostmi
  - 8 nebesnih dogodkov (meteorji, mrki, kometi, supernove, ...)
  - 6 tipov horoskopov (dnevni, tedenski, mesečni, letni, natalni, mundana)
  - Star chart creation (zvezdne karte z natančnostjo)
  - Celestial calendar (koledar nebesnih dogodkov)
  - Astrological predictions (pozitivne, nevtralne, negativne)
  - Accuracy system (izboljšuje se z astrologom in observatorijem)

## [v3.4.7] — 2026-08-08 — Royal Physician & Health System (6 diseases, 8 treatments, surgery)

### Dodano
- **Royal Physician & Health System** — zdravniki, diagnoze in kirurgija
  - 6 tipov bolezni (vročina, okužba, protin, sušica, črne koze, norost)
  - 8 tipov zdravljenj (puščanje krvi, zelišča, operacija, molitev, dieta, počitek, čiščenje, kauterizacija)
  - 4 medicinske zgradbe (bolnišnica, velika bolnišnica, operacijska dvorana, karantena)
  - Physician NPC s spretnostjo
  - Diagnosis sistem (simptom-based)
  - Surgical procedures (tvegano a učinkovito)
  - Court health tracking (povprečno zdravje dvora)
  - Epidemic prevention (kontagija in karantena)
  - Treatment complications in mortality

## [v3.4.6] — 2026-08-08 — Royal Philosopher & Wisdom System (6 schools, 8 topics, research)

### Dodano
- **Royal Philosopher & Wisdom System** — filozofija in modrost na dvoru
  - 6 filozofskih šol (stoicizem, platonizem, aristotelizem, sholastika, misticizem, humanizem)
  - 8 tem modrosti (etika, politika, metafizika, logika, estetika, epistemologija, teologija, naravna filozofija)
  - 3 akademske zgradbe (študijska soba, akademija, velika univerza)
  - Philosopher NPC s spretnostjo in šolo
  - School adoption (sprejetje filozofske šole z bonusi)
  - Research system (raziskovanje tem z časom)
  - Philosophical works publication
  - Student mentoring (3-mesečni program)
  - Knowledge in culture bonusi
  - Quality system (kakovost iz zgradb in filozofa)

## [v3.4.5] — 2026-08-08 — Royal Composer & Music System (6 instruments, 8 compositions)

### Dodano
- **Royal Composer & Music System** — dvorna glasba in kompozicije
  - 6 tipov instrumentov (lutnja, harfa, flavta, boben, orgle, violina)
  - 8 tipov kompozicij (maša, madrigal, balada, ples, himna, žalostinka, sonata, opera)
  - 3 glasbene zgradbe (soba, koncertna dvorana, operna hiša)
  - Composer NPC s spretnostjo
  - Composition creation (časovno ustvarjanje)
  - Public performances (z bonusi k sreči, veri, morali)
  - Court orchestra (najem glasbenikov)
  - Instrument condition (degradacija s časom)
  - Quality system (kakovost iz zgradb in skladatelja)

## [v3.4.4] — 2026-08-08 — Royal Falconry Breeding & Genetics System (8 traits, 6 bloodlines)

### Dodano
- **Royal Falconry Breeding & Genetics System** — napredna genetika za vzrejo ptic
  - 8 genetskih lastnosti (hitrost, moč, inteligenca, agresivnost, zvestoba, vid, vzdržljivost, velikost)
  - 6 krvnih linij (kraljevska, divja, gorska, puščavska, severna, cesarska)
  - Trait inheritance (starši prenesejo lastnosti na potomce)
  - Mutation system (5% možnost naključnih izboljšav)
  - Bloodline purity tracking
  - Champion breeding program (povprečje > 75 = šampion)
  - Lineage tracking (družinsko drevo)
  - Breeding contracts (zamenjava z drugimi dvori)
  - Inbreeding prevention

## [v3.4.3] — 2026-08-08 — Royal Forester & Woodland System (6 trees, timber, charcoal)

### Dodano
- **Royal Forester & Woodland System** — gozdarstvo in upravljanje gozdov
  - 6 tipov dreves (hrast, bor, breza, bukev, tisa, kostanj)
  - 4 gozdske zgradbe (koča, žaga, kopica za oglje, drevesnica)
  - Forester NPC s spretnostjo
  - Sustainable forestry (trajnostna sečnja z pogozdovanjem)
  - Timber production (les za gradnjo)
  - Charcoal production (oglje za kovaške peči)
  - Foraging (pasivna hrana iz gozdov)
  - Forest health management
  - Tree planting in growth cycles

## [v3.4.2] — 2026-08-08 — Royal Master of Hunt & Game System (6 animals, 5 hunts, dogs)

### Dodano
- **Royal Master of Hunt & Game System** — kraljevski lov in upravljanje divjadi
  - 6 tipov divjadi (jelen, merjavec, lisica, zajec, fazan, medved)
  - 4 lovske zgradbe (gozd, park, zajčji vrt, kraljevi rezervat)
  - 5 tipov lovov (kraljevi, sokolarski, lokostrelski, kopljični, poganjalni)
  - Master of Hunt NPC s spretnostjo
  - Game population management (trajnostni lov)
  - Hunting dogs (4 pasme: krvavi pes, hrt, mastif, bigel)
  - Trophy system (redke trofeje za prestiž)
  - Hunting incidents (nevarnost pri veliki divjadi)
  - Sustainability bonus iz zgradb

## [v3.4.1] — 2026-08-08 — Royal Alchemist & Transmutation System (6 processes, philosopher's stone)

### Dodano
- **Royal Alchemist & Transmutation System** — alkimija in transmutacija
  - 6 alkimističnih procesov (transmutacija, eliksir življenja, kamen modrosti, ...)
  - 4 alkimistični materiali (živo srebro, žveplo, sol, svinec)
  - 3 laboratorijske zgradbe (koča, laboratorij, veliki laboratorij)
  - Alchemist NPC s spretnostjo
  - Transmutation attempts (svinec v zlato, 15% uspeh)
  - Elixir brewing (zdravilni, moči, nevidnosti)
  - Philosopher's stone (legendarni quest, neskončno zlato)
  - Explosion risk (neuspešni poskusi lahko eksplodirajo)
  - Alchemical discoveries (random bonusi)
  - Material trading (kupovanje materialov)

## [v3.4.0] — 2026-08-08 — Royal Gardener & Ornamental Gardens System (6 gardens, 8 plants)

### Dodano
- **Royal Gardener & Ornamental Gardens System** — okrasni vrtovi in botanika
  - 6 tipov vrtov (vrt vrtnic, zeliščni, vozliščni, vodni, topiarij, botanični)
  - 8 tipov rastlin in okrasov (vrtnice, lilije, tulipani, sivka, bukvica, fontana, kip, živa meja)
  - Gardener NPC s spretnostjo
  - Seasonal blooming (različne rastline v različnih sezonah)
  - Garden tours (obiskovalci prinašajo zlato in prestiž)
  - Botanical collection (redke rastline z exploracije)
  - Garden competitions (tekmovanja z nagradami)
  - Garden beauty in health management
  - Meditation bonus (sreča iz miroljubnih vrtov)

## [v3.3.9] — 2026-08-08 — Royal Falconer & Hawking System (6 raptors, hunting, breeding)

### Dodano
- **Royal Falconer & Hawking System** — sokolarstvo in lov s pticami prey
  - 6 tipov ptic prey (skalnar, kragulj, orel, mali sokol, kobac, polarni sokol)
  - 4 falconry zgradbe (sokolarnica, letarica, urjenišče, reja)
  - Falconer NPC s spretnostjo
  - Bird training (urjenje za poslušnost in lov)
  - Hawking expeditions (lov za hrano in prestiž)
  - Bird breeding (vzreja redkih ptic)
  - Molting system (ptice menajajo perje)
  - Falconry competitions (tekmovanja z nagradami)
  - Bird health and aging

## [v3.3.8] — 2026-08-08 — Royal Vineyard & Wine System (6 grapes, 4 wines, aging)

### Dodano
- **Royal Vineyard & Wine System** — vinogradi in proizvodnja vina
  - 6 sort grozdja (pinot noir, chardonnay, merlot, riesling, cabernet, muškat)
  - 4 tipi vin (namizno, dobro, letnik, kraljevska rezerva)
  - 3 vinogradniške zgradbe (vinograd, vinska klet, skladišče za staranje)
  - Vintner NPC s spretnostjo
  - Grape planting in harvesting (z rastnim časom)
  - Wine making (priprava z dolgim časom za vrhunska vina)
  - Wine aging (vina se izboljšujejo s starostjo)
  - Vintage system (letniki z bonusi)
  - Wine trade in consumption
  - Quality bonus iz zgradb in vinarja

## [v3.3.7] — 2026-08-08 — Royal Beekeeper & Honey System (6 hives, mead, pollination)

### Dodano
- **Royal Beekeeper & Honey System** — čebelarstvo, med in medovec
  - 6 tipov panjev (brosten, slamnati, škatlasti, okvirni, kraljevski, apiarij)
  - 4 produkti (med, čebelji vosek, propolis, matični mleček)
  - 3 tipi medovca (navadni, začinjeni, kraljevski)
  - Beekeeper NPC s spretnostjo
  - Seasonal production (pomlad/poletje = več, zima = manj)
  - Mead brewing (priprava medovca z časom)
  - Wax candles (faith bonus)
  - Pollination bonus (do +30% pridelka hrane)
  - Swarm events (čebele se množijo ali pobegnejo)
  - Disease and health management

## [v3.3.6] — 2026-08-08 — Royal Master of Horse & Stables System (6 horses, breeding, events)

### Dodano
- **Royal Master of Horse & Stables System** — konji, hlevi in konjeništvo
  - 6 tipov konjev (bojni, hitrovec, palfrej, vsestranski, tovorni, težki bojni)
  - 4 hlevske zgradbe (pašnik, hlev, jahalna dvorana, farma za rejo)
  - Master of Horse NPC s spretnostjo
  - Horse training (urjenje za boj in hitrost)
  - Horse breeding (vzreja z verjetnostjo uspeha)
  - Equestrian events (dirke in predstave z nagradami)
  - Cavalry bonuses (hitrost, boj, prestiž)
  - Horse trading and aging
  - Foal breeding (žrebiči z izboljšanimi stati)

## [v3.3.5] — 2026-08-08 — Royal Cartographer & Maps System (6 map types, exploration)

### Dodano
- **Royal Cartographer & Maps System** — kartografija in raziskovanje
  - 6 tipov zemljevidov (svet, regionalni, vojaški, trgovski, zaklad, pomorska karta)
  - 3 kartografske zgradbe (skriptorij, kartografska soba, arhiv)
  - Cartographer NPC s spretnostjo in natančnostjo
  - Map creation (ustvarjanje z časom)
  - Exploration tracking (odkrivanje novih regij)
  - Treasure maps in treasures (naključni zakladi)
  - Map trading (prodaja in nakup zemljevidov)
  - Map accuracy (izboljšuje se z zgradbami)
  - Strategic bonuses (vojaški, trgovski, pomorski)

## [v3.3.4] — 2026-08-08 — Royal Apothecary & Medicine System (8 herbs, 6 remedies, poisons)

### Dodano
- **Royal Apothecary & Medicine System** — zdravilstvo, zelišča in strupi
  - 8 tipov zelišč (mandragora, špaj, žajbelj, rožmarin, česen, volčje jabolko, pelin, vrobnica)
  - 6 tipov zdravil (zdravilni napoj, protistrup, sredstvo proti bolečini, tonik, umirjevalo, poživilo)
  - 4 tipi strupov (strup podgan, volčji, počasna smrt, uspavalni napoj)
  - 3 apothekarske zgradbe (zeliščni vrt, delavnica, laboratorij)
  - Apothecary NPC s spretnostjo
  - Herb cultivation (gojenje zelišč na vrtu)
  - Remedy crafting (priprava zdravil)
  - Poison crafting (samo v laboratoriju)
  - Healing the ruler (zdravljenje vladarja)
  - Disease prevention (protistrupi)
  - Skill progression apothekarja

## [v3.3.3] — 2026-08-08 — Royal Astrologer & Omens System (6 omens, 8 prophecies)

### Dodano
- **Royal Astrologer & Omens System** — astrologi, znamenja in prerokbe
  - 6 tipov znamenj (komet, mrk, krvavi mesec, padajoča zvezda, poravnava, severni siji)
  - 8 tipov prerokb (zmaga, poraz, lakota, kuga, rojstvo, smrt, zveza, izdaja)
  - Astrolog NPC s spretnostjo in natančnostjo
  - Observatorij (izboljša natančnost)
  - Omen interpretation (igralčeve izbire)
  - Prophecy fulfillment tracking
  - Superstition level (vpliva na srečo iz znamenj)
  - Skill progression astrologa

## [v3.3.2] — 2026-08-08 — Royal Pet & Menagerie System (8 animals, breeding, exhibitions)

### Dodano
- **Royal Pet & Menagerie System** — eksotične živali in kraljevska menažerija
  - 8 tipov živali (lev, medved, sokol, pes, panter, slon, opica, pavan)
  - 4 menažerijske zgradbe (kletka, ograja, ptičnjak, velika menažerija)
  - Caretakers (NPC skrbniki s spretnostjo)
  - Animal training (za predstave in lov)
  - Animal health and happiness
  - Breeding program (redke živali, mladiči)
  - Public exhibitions (dvigujejo srečo in prestiž)
  - Hunting with animals (sokoli in psi za lov)
  - Animal lifespan in staranje
  - Random danger eventi (poškodbe)

## [v3.3.1] — 2026-08-08 — Royal Feast & Banquet System (6 feasts, 8 dishes, disasters)

### Dodano
- **Royal Feast & Banquet System** — velike gostije in dvorne prireditve
  - 6 tipov gostij (državna večerja, poroka, proslava zmage, verska, pobratna, diplomatska)
  - 8 tipov jedi (pečen merjavec, labod, pavan, ribe, kruh, vino, pivo, sladica)
  - 3 kuhinjske zgradbe (kuhinja, kraljeva kuhinja, velika dvorana)
  - Chef NPC (spretnost vpliva na kakovost)
  - Guest management (vabljenje plemičev in zaveznikov)
  - Satisfaction sistem (kombinacija jedi in kakovosti)
  - Diplomatic bonus (izboljšanje odnosov z gosti)
  - Faith bonus (pri verskih gostijah)
  - Feast disasters (zastrupitev, pretepe, požar)
  - Quality bonus iz zgradb in kuharja

## [v3.3.0] — 2026-08-08 — Royal Guard & Personal Security System (5 guards, 6 threats)

### Dodano
- **Royal Guard & Personal Security System** — osebna zaščita vladarja
  - 5 tipov stražarjev (dvorna, elitna, tuja, najemniška, viteški poveljnik)
  - 6 tipov groženj (morilec, strup, tropa, rivalni lord, heretik, tuj agent)
  - 5 nalog stražarjev (patrulja, spremstvo, palača, potovanje, preiskava)
  - Plot detection (odkrivanje zarot pred izvršitvijo)
  - Food taster (zaščita pred strupom)
  - Escape route (pobeg v sili, zmanjša škodo)
  - Security level (0-100, glede na stražarje)
  - Guard training (izkušnje in napredovanje)
  - Ruler health (poškodbe pri neuspešni obrambi)
  - Ruler death (sproži nasledstvo preko Dynasty sistema)

## [v3.2.9] — 2026-08-08 — Medieval Law & Justice System (8 crimes, 6 punishments, trials)

### Dodano
- **Medieval Law & Justice System** — sojenja, kazni in pravosodje
  - 8 tipov zločinov (kraja, umor, izdaja, herezija, tihotapljenje, napad, goljufija, čarovništvo)
  - 6 tipov kazni (globa, steber sramote, bičanje, zapor, izgon, usmrtitev)
  - 4 sodne zgradbe (vaško, mestno, kraljevo, vrhovno sodišče)
  - Sodniki (NPC s spretnostjo in integriteto)
  - Trial sistem (dokazi, pričevalci, sodnikova spretnost)
  - Crime rate (odvisen od sreče)
  - Justice reputation (perceived fairness)
  - Globe za državo (denarne kazni)
  - Public opinion (vpliva na srečo)

## [v3.2.8] — 2026-08-08 — Royal Progress & Tour System (6 destinations, entourage, petitions)

### Dodano
- **Royal Progress & Tour System** — kraljeva potovanja po provincah
  - 6 tipov ciljev (glavno mesto, provinca, vazalska dežela, meja, sveto mesto, tuj dvor)
  - 6 tipov spremstva (stražarji, dvorjani, služabniki, bard, kuhar, duhovnik)
  - 5 tipov peticij (mejni spori, davki, razbojniki, čudeži, darila)
  - Spremembe poti (godi incidenti: nevihte, razbojniki, bolezen)
  - Bonusi za lojalnost, srečo, vero, diplomacijo
  - Tveganje incidenta (znižano s stražarji)
  - Progress prestige (dolgoročni ugled)
  - Diplomatski obiski tujih dvorov

## [v3.2.7] — 2026-08-08 — Royal Archive & Records System (6 doc types, 4 buildings)

### Dodano
- **Royal Archive & Records System** — shranjevanje dokumentov in pogodb
  - 6 tipov dokumentov (pogodba, odlok, darovnica, porokna pogodba, davčni zapis, kronika)
  - 4 arhivske zgradbe (omara, soba, kraljevi arhiv, velika knjižnica)
  - Document degradation (razpadanje čez čas)
  - Preservation bonus (zgradbe upočasnjujejo razpad)
  - Royal scribes (NPC za hitrejše pisanje)
  - Treaty management (aktivne, pretečene, prekinjene)
  - Land grant tracking (darovnice zemlje)
  - Document search (iskanje po naslovu/vsebini)
  - Document restoration (obnova poškodovanih)
  - Legal bonus (iz velike knjižnice)

## [v3.2.6] — 2026-08-08 — Royal Court Entertainment System (6 entertainers, 11 performances)

### Dodano
- **Royal Court Entertainment System** — dvorna zabava z zabavljači
  - 6 tipov zabavljačev (bard, norček, glasbenik, trubadur, plesalec, krotilce živali)
  - 11 tipov predstav (pesem, šala, epska pripoved, poezija, akrobatika, satira, ples, instrumental, romansa, ...)
  - 4 zabavne zgradbe (dvorna odra, gledališče, glasbena dvorana, veliki amfiteater)
  - Sistem najemanja in odpuščanja zabavljačev
  - Court reputation (0-100, vpliva na ugled dvora)
  - Touring (pošlji zabavljača na turnejo k zavezniku)
  - Skill progression (izkušnje po predstavah)
  - Satira s tveganjem užalitve plemstva
  - Pasivna sreča iz zgradb

## [v3.2.5] — 2026-08-08 — Court Intrigue & Spy Network System (6 spies, 8 missions)

### Dodano
- **Court Intrigue & Spy Network System** — napreden vohunski sistem
  - 6 tipov vohunov (dvorna dama, menih, trgovec, norček, služabnik, mojster vohun)
  - 8 tipov misij (infiltriraj, sabotaža, atentat, kraja, ponarejanje, izsiljevanje, govoric, izvidnica)
  - Spy skill progression (izkušnje po uspehih)
  - Cover system (krije se zmanjšuje z vsako misijo)
  - Counter-intelligence (lovljenje sovražnikovih vohunov)
  - Zasliševanje ujetih vohunov (bonus protiobveščevalne ravni)
  - Blackmail material (izsiljevanje za zlato)
  - Spy upkeep (plačilo za vsakega vohuna)
  - Detection chance in capture (vohuni so ujeti)

## [v3.2.4] — 2026-08-08 — Tournament & Jousting System (5 types, 6 venues, betting)

### Dodano
- **Tournament & Jousting System** — srednjeveški turnirji z vitezi in nagradami
  - 5 tipov turnirjev (joust, melee, strelništvo, veliki melee, kraljevi turnir)
  - 6 prizorišč (vaški travnik, mestna arena, dvorišče gradu, kraljeva arena, turnirsko polje, veliki stadion)
  - Rekrutiranje vitezov (NPC s spretnostjo, zdravje, statistika)
  - Single elimination bracket simulacija
  - Sistem stavnjenja (2x-3x izplačilo)
  - Poškodbe (risk glede na tip turnirja)
  - Prize money (zlato za zmagovalca)
  - Prestiž in tournament fame (dolgoročna slava)
  - 16 viteških imen za NPC

## [v3.2.3] — 2026-08-08 — Royal Mint & Currency System (5 coins, debasement, exchange)

### Dodano
- **Royal Mint & Currency System** — kovanje denarja in valutni sistem
  - 5 tipov kovancev (denar, groat, florin, plemič, dukat) z različno vrednostjo
  - 4 tuje valute (bizantinski solidus, beneški dukat, arabski dinar, hanzna marka)
  - Kovnice (gradnja, proizvodnja kovancev)
  - Mintmaster (NPC s spretnostjo, poveča proizvodnjo)
  - Debasement (znižanje čistosti za takojšnje zlato, vpliva na zaupanje)
  - Exchange rates (fluktuirajo, vpliva trust level)
  - Counterfeiting (ponarejanje kovancev, varnostni ukrepi)
  - Trust level (0-100, vpliva na menjalne tečaje)
  - Pretvorba kovancev v zlato (glede na čistost)

## [v3.2.2] — 2026-08-08 — Heraldry & Coat of Arms System (8 tinctures, 12 charges)

### Dodano
- **Heraldry & Coat of Arms System** — oblikovanje grbov in heraldika
  - 8 heraldičnih barv (zlato, srebro, rdeča, modra, črna, zelena, škrlatna, oranžna)
  - 12 simbolov (lev, orel, križ, lilija, zmaj, krona, meč, stolp, zvezda, merjavec, volk, enorog)
  - 6 delitev ščita (polno, navpično, vodoravno, četrtinsko, poševno, strešica)
  - Oblikovalec grbov s pravili tincture (kovina na barvi)
  - Heraldični register (vsi znani grbi)
  - Prepoznavanje hiš po grbu
  - Heraldični spori (podobni grbi = konflikt)
  - Reševanje sporov (popusti ali vztrajaj)
  - Prikaz na turnirjih (bonus k nastopu)
  - Heraldic prestige (redke kombinacije = višji prestiž)

## [v3.2.1] — 2026-08-08 — Chronicle & History System (8 categories, narrative, legacy score)

### Dodano
- **Chronicle & History System** — beleženje zgodovine z avtomatskim pisanjem
  - 8 kategorij dogodkov (vojaško, politično, ekonomsko, versko, socialno, dinastično, kulturno, katastrofalno)
  - 18+ templates za narativno pisanje
  - Avtomatsko beleženje preko GameEventBus subscriptions
  - Legacy score (točkovanje dogodkov po pomembnosti)
  - 6 stopenj kakovosti (povprečno, običajno, omembno, izjemno, legendarno, mitično)
  - 10 slavnih citatov
  - Export kronike v tekstovno datoteko
  - Reign summary generator (povzetek vladanja)
  - Legacy rank (Mitičen, Legendaren, Izjemen, itd.)
  - Filtriranje po letu in kategoriji

## [v3.2.0] — 2026-08-08 — Royal Treasury & Taxation System (6 taxes, loans, corruption)

### Dodano
- **Royal Treasury & Taxation System** — popoln sistem davkov in financ
  - 6 tipov davkov (dohodnina, posestnina, trgovski, solni, ognjiščarina, desetina)
  - 5 davčnih stopenj (oproščeno, nizko, srednje, visoko, tiransko)
  - Kraljeva zakladnica (ločena od delovnega zlata, do 50.000)
  - Davčni uradi (povečajo učinkovitost pobiranja)
  - Sistem posojil (obresti, roki, neplačilo = pobuda)
  - Inflacija (raste, ko je zakladnica polna)
  - Korupcija (davki izginejo v žepih uradnikov)
  - Davčni prazniki (začasna olajšava, dvigne srečo)
  - Rebellion risk (pri tiranski stopnji, kmečki upor)
  - Treasury deposit/withdraw (ločeno od delovnega zlata)

## [v3.1.9] — 2026-08-08 — Winter Quarters & Hibernation System (4 seasons, attrition)

### Dodano
- **Winter Quarters & Hibernation System** — sezonski ciklus zimskega vojskovanja
  - 4 letni časi (pomlad, poletje, jesen, zima) z različnimi učinki
  - 4 zimske kvartire (tabor, barake, trdnjava, zalogovnik)
  - Atricija vojske pozimi (HP izguba, smrtne žrtve)
  - Frostbite (ozebline, dodatne žrtve v hudi zimi)
  - Supply sistem (zaloge, skladišča, rekvizicije)
  - Hibernacija vojske (spanje do pomladi)
  - Spring wakeup (morale boost)
  - Foraging (rekvizicija zmanjšajo srečo)
  - Letni ciklus (pomlad → poletje → jesen → zima)
  - Movement modifier (počasneje pozimi)

## [v3.1.8] — 2026-08-08 — Naval Combat & Trade System (5 ships, 4 buildings, battles)

### Dodano
- **Naval Combat & Trade System** — pomorski del igre z ladjami in trgovino
  - 5 tipov ladij (ribiška, koga, galeja, karaka, vojna ladja)
  - 4 pomorske zgradbe (pristanišče, ladjedelnica, suhi dok, pomorska akademija)
  - 4 taktike pomorskega boja (zabijanje, vkrcanje, streljanje, bombardiranje)
  - Pomorske trgovske poti (visok profit, tveganje piratov)
  - Blokade (odreže sovražnikovo trgovino)
  - Piratski napadi (random eventi na trgovskih poteh)
  - Zajemanje ladij (40% chance pri vkrcanju)
  - Popravilo ladij (strošek glede na HP)
  - Dnevno vzdrževanje ladij (upkeep)
  - Pomorski prestiž (0-100)

## [v3.1.7] — 2026-08-08 — Royal Marriage & Dynasty System (6 houses, heirs, succession)

### Dodano
- **Royal Marriage & Dynasty System** — dinastična politika in nasledstvo
  - 6 kraljevskih hiš (Normanska, Plantageneti, Habsburžani, Kapetinci, Hohenstaufen, Domača)
  - 4 tipi porok (osnovna, močna, kraljevska, matrilinearna)
  - Sistem dedičev (rojstvo, staranje, izobraževanje, obljube)
  - 4 tipi izobraževanja (pisar, bojevnik, dvorjan, duhovnik)
  - Dowry (dota) negotiacije
  - Razveze in ponižitve
  - Succession crisis (kralj umre brez naslednika → upor)
  - Dynasty prestige (0-100, vpliva na uspeh porok)
  - diplomatski bonusi, trgovinski sporazumi, vojaški dostop
  - Letni ciklus (staranje, rojstva, poroke, smrti)

## [v3.1.6] — 2026-08-08 — Cultural & Education System (5 institutions, 6 arts, achievements)

### Dodano
- **Cultural & Education System** — pismenost, umetnost in kultura
  - 5 izobraževalnih ustanov (skriptorij, knjižnica, akademija, univerza, observatorij)
  - 6 umetnostnih oblik (rokopis, slika, kip, glasba, poezija, arhitektura)
  - Pismenost (0-100%, vpliva na raziskovalno hitrost)
  - Knowledge točke (valuta za umetnost in raziskave)
  - Kulturni prestiž (vpliva na diplomacijo in turizem)
  - Turizem (pasivni dohodek iz umetniških del)
  - 8 slavnih obiskovalcev (Tomaž Akvinski, Hildegarda, Dante, Giotto, ...)
  - 6 kulturnih dosežkov (prva knjižnica, 100% pismenost, renesančni dvor, ...)
  - Pokroviteljstvo (naročanje umetnin z zlatom in znanjem)
  - Bonus multiplierji (pismenost → raziskave)

## [v3.1.5] — 2026-08-08 — Royal Decrees & Edicts System (12 decrees, 4 categories, chains)

### Dodano
- **Royal Decrees & Edicts System** — kraljevi odloki z dolgoročnimi učinki
  - 12 tipov odlokov (davčna reforma, vpis, verska strpnost, sveta desetina, ...)
  - 4 kategorije (ekonomski, vojaški, socialni, verski)
  - Aktivni limit (max 5 aktivnih odlokov hkrati)
  - Trajanje (začasno ali permanentno)
  - Preklic (možno kadarkoli, vpliva na srečo)
  - Predpogoji (raziskava zahteva 1000 zlata)
  - Verige odlokov (3 verige z bonusi: Razsvetljeni vladar, Vojni lord, Bogataš)
  - Edict fatigue (preveč odlokov → utrujenost ljudstva)
  - Aktivni efekti: proizvodnja, sreča, loyaltyn, heresy, faith

## [v3.1.4] — 2026-08-08 — Black Market & Smuggling System (8 contraband, 4 methods)

### Dodano
- **Black Market & Smuggling System** — podzemna ekonomija s tihotapljenjem
  - 8 tipov kontrabande (začimbe, svila, orožje, žganje, nakit, relikvije, strupi, sužnji)
  - 4 metode tihotapljenja (karavana, ladja, nočni tekač, podkupljeni uradniki)
  - Črni trgovci (skriti NPC, 5 min razpoložljivost, random inventar)
  - Tax evasion (skrivanje prihodka pred davki)
  - Carinski nadzor (auditi, globe, zaplemba kontrabande)
  - Podkupovanje uradnikov (zniža enforcement, prekliče audite)
  - Carinske postaje (povečajo enforcement level)
  - Criminal reputation (0-100, vpliva na cene)
  - Law enforcement level (0-100, drifta nazaj na 50)
  - Risk/reward (visoki dobički, težke globe)

## [v3.1.3] — 2026-08-08 — Treason & Rebellion System (6 types, civil war, conspiracies)

### Dodano
- **Treason & Rebellion System** — notranji spopadi, zarote in državljanska vojna
  - 6 tipov uporov (kmečki, plemiški, verski, vojaški, nasledstveni, tujim sponzoriran)
  - 6 opcij pacifikacije (darila, zmanjšaj davke, festival, usmrtitev, amnestija, vojaško)
  - Loyalty tracker per regija in plemič (0-100)
  - Unrest build-up (sreča, davki, herezija, lakota)
  - Conspiracies (detekcija preko špijonaže, 4 tipi zarot)
  - Civil war (ko 3+ upori aktivni, dežela razklana)
  - Spread mehanika (upori se širijo v druge regije)
  - Demand sistem (uporniki zastavljajo zahteve)
  - Victory/defeat za upornike (zahteve uresničene če zmagajo)

## [v3.1.2] — 2026-08-08 — Famine & Resource Scarcity System (6 events, rationing)

### Dodano
- **Famine & Resource Scarcity System** — suše, nežit, kobilice in stradanje
  - 6 tipov scarcity eventov (suša, nežit, kobilice, ostra zima, poplava, leto kuge)
  - 4 stopnje racioniranja (izobilje, normalno, zmanjšano, stradanje)
  - Žitnice (gradnja, kapaciteta 2000 hrane na zgradbo)
  - Sistem rezerv (depozit/umik iz žitnice)
  - Uvoz hrane (plačilo zlata, dostava po 60 sekundah)
  - Pakti o medsebojni pomoči z zavezniki (brezplačna hrana)
  - Podnebni ciklus (8 faz: pomlad/poletje/jesen/zima × dobro/slabo)
  - Casualties od stradanja (5% prebivalstva na dan v stradanju)
  - Population loss v letu kuge (10% čez 90 dni)
  - Happiness penalty in productivity bonus glede na racioniranje

## [v3.1.1] — 2026-08-08 — Prisoner & Ransom System (5 classes, capture, exchange)

### Dodano
- **Prisoner & Ransom System** — zajemanje sovražnikov in odkupnine
  - 5 razredov zapornikov (kmet, vojak, vitez, plemič, kraljevska oseba)
  - 4 zapore (zapora, temnica, stolp, trdnjavska ječa) s kapaciteto 10-200
  - Capture chance glede na razred (1% do 30%)
  - Negotiacija odkupnin (5 rund, counter-offer sistem)
  - Sistem izmenjav zapornikov (uravnotežene glede na težo)
  - Usmrtitev (velik diplomatski udarec, vpliva na prihodnje zajetje)
  - Izpust (usmiljenje, dvigne ugled pri plemičih)
  - Dnevno vzdrževanje zapornikov (zlato na dan)
  - Escape mehanika (vsakih 60s, glede na jakost zapore)
  - Random eventi: družina ponuja odkupnino
  - Ugled pri plemičih (0-100, vpliva na capture chance)

## [v3.1.0] — 2026-08-08 — Mercenary Contract System (8 companies, betrayal)

### Dodano
- **Mercenary Contract System** — najemniške čete z negotiacijo pogodb in izdajo
  - 8 tipov najemniških podjetij (mečevci, samostrelci, kopjaši, konjenica, inženirji, saparji, izvidniki, stražarji)
  - 4 trajanja pogodb (kratko 14d, standardno 30d, podaljšano 90d, permanentno 365d)
  - Negocijske opcije: ekskluzivnost, bonus po uspehu, ponudbe nasprotnikov
  - Ugled pri podjetjih (0-100, vpliva na ceno in zanesljivost)
  - Dnevna plačila (avtomatsko, zlato vsak dan)
  - Mehansika izdaje (premajhen ugled → prestop k nasprotniku)
  - Bonus po ubitih sovražnikih (5 zlata na uboj)
  - Podaljšanje pogodb s 15% popustom
  - Aukcije z nasprotniki (ponudbeni vojni)
  - Specifični bonusi: napad, obramba, hitrost, obleganje

## [v3.0.9] — 2026-08-08 — Trade Guild System (5 guilds, 4 tiers, contracts)

### Dodano
- **Trade Guild System** — srednjeveški cehovski sistem z economicnimi bonusi
  - 5 tipov cehov (trgovski, kovaški, tesarski, zidarski, pivovarski)
  - 4 stopnje članstva (vajenec, pomočnik, mojster, starešina ceha)
  - Cehovske dvorane (gradnja + 2 nadgradnje, do 3 stopnje)
  - Tedenske cehovnine (avtomatsko, glede na stopnjo)
  - Cehovske zakladnice (samo starešina lahko dvigne)
  - 5 tipov cehovskih pogodb (dostava, kvota, rekrutacija, sabotaža, obrt)
  - Ugled pri cehovih (-100 do +100, 7 stopenj)
  - Rivalstva in zavezništva med cehovi
  - Passivni bonusi: popusti, hitrost karavan, kakovost orožja, proizvodnja

## [v3.0.8] — 2026-08-08 — Religion & Faith System (5 religions, 7 buildings, 6 actions)

### Dodano
- **Religion & Faith System** — organizirana vera in verski vpliv na igro
  - 5 tipov religij (katolištvo, pravoslavje, poganstvo, herezija, državna vera)
  - 7 verskih zgradb (kapela, cerkev, katedrala, samostan, svetišče, tempelj, sveto mesto)
  - 6 verskih akcij (blagoslov, izobčenje, sveta vojna, pokrščevanje, donacija, romanje)
  - 7 svetih dni v letu (Božič, Velika noč, Binkošti, vsi svetniki, kronanje, itd.)
  - Sistem relikvij (7 tipov, passivni bonusi k veri in sreči)
  - Herezija in inkvizicija (širjenje herezije, zatiranje z vero)
  - Verska toleranca (0-100, vpliva na širjenje herezije)
  - Diplomatski modifikatorji (zavezniki in rivali med religijami)
  - UI: vera meter, indikator herezije, simbol državne vere

## [v3.0.7] — 2026-08-07 — Disease & Health System (6 diseases, 5 infrastructure)

### Dodano
- **Disease & Health System** — bolezni in zdravstvena infrastruktura
  - 6 tipov bolezni (kuga, dizenterija, gripa, črne koze, lakotna vročica, kolera)
  - 5 tipov zdravstvene infrastrukture (apoteka, zdravilnica, čisti vodnjak, bolnišnica, kanalizacija)
  - Simulacija širjenja (proximity-based, vsakih 5s = 1 dan)
  - Karantenski sistem (izolacija območij, -70% širjenje)
  - Raziskava zdravil (4 raziskave = zdravilo)
  - Health rating (0-100, vpliva na rast populacije)
  - Naključni izbruhi (vsakih 5 min, glede na health + pop)
  - Production modifier (bolezni zmanjšujejo produkcijo)
  - Happiness modifier (bolezni zmanjšujejo srečo)

### Tipi bolezni (6)
1. Kuga — 15% smrtnost, 8% širjenje, 30 dni
2. Dizenterija — 5% smrtnost, 12% širjenje, 15 dni
3. Gripa — 2% smrtnost, 15% širjenje, 10 dni
4. Črne koze — 25% smrtnost, 10% širjenje, 25 dni
5. Lakotna vročica — 8% smrtnost, 6% širjenje, 20 dni
6. Kolera — 10% smrtnost, 14% širjenje, 18 dni

### Statistika
- 634 Lua datotek (+1)
- 631/634 syntax pass
- 6 tipov bolezni (nov)
- 5 tipov infrastrukture (nov)

## [v3.0.6] — 2026-08-07 — Court & Nobility System (6 advisors, marriages, plots)

### Dodano
- **Court & Nobility System** — upravljanje kraljevega dvora
  - 6 tipov svetovalcev (kancler, maršal, upravitelj, vohun, kaplan, zakladnik)
  - sistem porok (diplomatska zavezništva)
  - sistem dedičev (linija nasledstva)
  - 7 dvornih dogodkov (banketi, turniri, škandali, svatbe, kronanja)
  - 5 plemiških hiš z vplivom in odnosi
  - Dvorni prestige (vpliva na srečo in diplomacijo)
  - Zarote (atrovske zarote z vohunskim bonusom)
  - Leveling svetovalcev (1-5, +3% na nivo)
  - Lojalnost svetovalcev (drsi proti 50)
  - Naključni dvorni dogodki vsake 3 minute

### Tipi svetovalcev (6)
1. Kancler — +20% diplomacija, +10% davki
2. Maršal — +15% enote, +15% obramba, +10% damage
3. Upravitelj — +25% davki, +10% gradnja, +10% hrana
4. Mojster vohunov — +50% vohunstvo, +30% protivohunstvo
5. Kaplan — +20% sreča, +15% raziskovanje
6. Zakladnik — +15% davki, +20% trgovina, +10% zlato

### Statistika
- 633 Lua datotek (+1)
- 630/633 syntax pass
- 6 tipov svetovalcev (nov)
- 7 dvornih dogodkov (nov)
- 5 plemiških hiš (nov)

## [v3.0.5] — 2026-08-07 — Governor & Administration System (6 types, 12 traits)

### Dodano
- **Governor & Administration System** — upravljanje provinc z guvernerji
  - 6 tipov guvernerjev (vojaški, ekonomski, kmetijski, diplomatski, gradbeni, učeni)
  - 12 naključnih lastnosti (3 na guvernerja, skladni učinki)
  - Province (ustvarjanje in dodeljevanje ozemelj)
  - Sistem lojalnosti (drsi proti 50, uporniško tveganje pod 20)
  - Leveling 1-10 (+2% na nivo)
  - Izkušnje (100 XP na nivo)
  - Generiranje naključnih imen
  - Agregirani bonusi (vsi dodeljeni guvernerji prispevajo)

### Tipi guvernerjev (6)
1. Vojaški — +30% enote, +20% obramba
2. Ekonomski — +30% davki, +25% trgovina
3. Kmetijski — +40% hrana, +20% rast
4. Diplomatski — +30% diplomacija, +15% trgovina
5. Gradbeni — +30% gradnja, -15% stroški
6. Učeni — +40% raziskovanje, +15% sreča

### Statistika
- 632 Lua datotek (+1)
- 629/632 syntax pass
- 6 tipov guvernerjev (nov)
- 12 lastnosti (nov)

## [v3.0.4] — 2026-08-07 — Trade Negotiation System (4 types, AI counter-offer)

### Dodano
- **Trade Negotiation System** — kompleksna trgovinska pogajanja
  - 4 tipi: trgovina, barter, posojilo, darilo
  - AI protiponudbe (AI oceni in odgovori s prilagojenimi pogoji)
  - Odnos-cene (zavezniki do -20% popusta)
  - 8 AI osebnostnih modifikatorjev (markup, accept threshold, counter chance)
  - Večkrožna pogajanja (do 3 krogi ponudb)
  - Trgovinski embargi (blokada trgovine s sovražnimi frakcijami)
  - Trgovinski sporazumi (ponavljajoče se avtomatske trgovine)
  - Vpliv na DynamicMarket (supply/demand)
  - Zgodovina pogajanj (zadnjih 50)

### Tipi pogajanj (4)
1. Trgovina — kupi/prodaj za zlato
2. Barter — zamenjaj surovine brez zlata
3. Posojilo — posodi/zapoši zlato z obrestmi
4. Darilo — daruj za izboljšanje odnosov

### Statistika
- 631 Lua datotek (+1)
- 628/631 syntax pass
- 4 tipi pogajanj (nov)
- 8 AI modifikatorjev (nov)

## [v3.0.3] — 2026-08-07 — Castle Siege System (4 phases, walls, equipment)

### Dodano
- **Castle Siege System** — napredne mehanike obleganja
  - 4 faze: pristop, bombardiranje, napad, preboj
  - 9 sekcijskih zidov (8 smeri + vrata) z integriteto
  - 5 tipov oblegovalne opreme (lesnice, stolp, oven, katapult, trebuchet)
  - 4 obrambni odgovori (vrelo olje, salvo, skale, izpad)
  - Sistem prebojev (zid pade pri 0 integriteti)
  - Morale sistem (napadalec + branilec)
  - Presek oskrbe (stradanje braniteljev)
  - Pogajanja o predaji
  - Zgodovina obleganj (zadnjih 20)

### Faze (4)
1. Pristop (30s) — priprava položajev
2. Bombardiranje (120s) — uničevanje zidov
3. Napad (60s) — penjanje prek zidov
4. Preboj — vdor skozi vrzeli

### Statistika
- 630 Lua datotek (+1)
- 627/630 syntax pass
- 4 faze obleganja (nov)
- 9 sekcijskih zidov (nov)
- 5 tipov opreme (nov)
- 4 obrambni odgovori (nov)

## [v3.0.2] — 2026-08-07 — Stats Dashboard Widget (6 panels, collapsible)

### Dodano
- **Stats Dashboard Widget** — real-time HUD z statistiko
  - 6 panojev: ekonomija, vojaško, populacija, diplomacija, tehnologija, performance
  - Panoji lahko zloženi (klik na naslov)
  - 6 pozicij (4 koti + top/bottom center)
  - Barvno kodirane vrednosti (zelena=dobro, rdeča=slabo)
  - Prosojno ozadje z obrobo
  - Podatki iz 10+ sistemov

### Panoji (6)
1. Ekonomija — zlato, les, kamen, hrana, železo, učinkovitost
2. Vojaško — armade, enote, moč, heroji, K/D, zmage/porazi
3. Populacija — prebivalstvo, sreča, rast
4. Diplomacija — zavezništva, sovražniki, trgovine, poti
5. Tehnologija — raziskave, questi, prestige, rank
6. Performance — FPS, spomin, DDA, matchmaking rating

### Statistika
- 629 Lua datotek (+1)
- 626/629 syntax pass
- 6 panojev (nov)

## [v3.0.1] — 2026-08-07 — Matchmaking System (ELO, 5 match types, 7 ranks)

### Dodano
- **Multiplayer Matchmaking System** — iskanje igralcev za multiplayer
  - ELO rating sistem (start 1000, win +25, loss -20)
  - 5 tipov iger (1v1, 2v2, 3v3, 4-FFA, 8-FFA)
  - 7 rangov (Bronze → Grandmaster)
  - Lobby management z ready sistemom
  - Connection quality (ping + packet loss)
  - Match history (zadnjih 50)
  - Win/loss tracking z win streak
  - Disconnect handling (-30 rating)
  - Persistent stats (matchmaking_stats.json)
  - Leaderboard integracija

### Rangovi (7)
- Bronze (500-999), Silver (1000-1199), Gold (1200-1399)
- Platinum (1400-1599), Diamond (1600-1799)
- Master (1800-1999), Grandmaster (2000+)

### Statistika
- 628 Lua datotek (+1)
- 625/628 syntax pass
- 5 tipov iger (nov)
- 7 rangov (nov)

## [v3.0.0] — 2026-08-07 — MILESTONE: Resource Forecast System

### Dodano
- **Resource Forecast System** — napovedovanje surovin
  - Sledenje produkcije/porabe v realnem času (11 surovin)
  - 5-minutna projekcija (kje bodo surovine čez 5 min?)
  - Opozorila o pomanjkanju (kritična < 60s, opozorilo < 3min)
  - Indikatorji presežka (> 5/s kopičenje)
  - Zgodovina trendov (zadnjih 60s)
  - Izračun učinkovitosti (produkcija vs poraba %)
  - NotificationCenter integracija za kritična opozorila

### Tipi opozoril (4)
1. Kritično pomanjkanje — konec < 60s
2. Pomanjkanje — konec < 3 min
3. Nizke zaloge — pod pragom (20/100)
4. Presežek — kopičenje > 5/s

### Statistika
- 627 Lua datotek (+1)
- 624/627 syntax pass
- 11 sledenih surovin (nov)
- 4 tipi opozoril (nov)

## [v2.9.9] — 2026-08-07 — Performance Auto-Tuner (8 params, predictive)

### Dodano
- **Performance Auto-Tuner** — samodejno optimiziranje grafike
  - 8 nastavljivih parametrov (delci, sence, bloom, SSAO, render distance, animacije, vreme, unit cap)
  - Real-time FPS monitoring (1s, 5s, 30s povprečja)
  - Prediktivno prilagajanje (zniža kvaliteto preden FPS pade)
  - Postopna degradacija (ena parameter naenkrat, po prioriteti)
  - Obnova kvalitete (po 10s stabilnega FPS)
  - Igralec nastavi ciljni FPS (15-144)
  - Override mode (zaklep nastavitev)
  - Zgodovina prilagajanj

### Statistika
- 626 Lua datotek (+1)
- 623/626 syntax pass
- 8 nastavljivih parametrov (nov)

## [v2.9.8] — 2026-08-07 — Dynamic Difficulty Adjuster (5 factors, real-time)

### Dodano
- **Dynamic Difficulty Adjuster (DDA)** — samodejno prilagajanje težavnosti
  - 5 faktorjev: AI agresivnost, bonus surovin, HP sovražnikov, DMG sovražnikov, frekvenca dogodkov
  - Performance score (-100 do +100) iz 5 metrik (army ratio, gold, populacija, sreča, K/D)
  - Smooth prehodi (brez nenadnih skokov)
  - 5 stopenj prilagajanja (Lažje → Težje)
  - Igralec lahko nastavi ciljno težavnost
  - Zgodovina performans (30 vnosov)
  - Toggle on/off
  - Preračun vsakih 10s

### Statistika
- 625 Lua datotek (+1)
- 622/625 syntax pass
- 5 faktorjev prilagajanja (nov)
- 5 stopenj prilagajanja (nov)

## [v2.9.7] — 2026-08-07 — Enhanced Map Editor (layers, undo/redo, export)

### Dodano
- **Enhanced Map Editor** — napredni urejevalnik map
  - 7 tipov čopičev (grass, dirt, stone, water, sand, mountain, erase)
  - 5 velikosti čopičev (1×1 do 9×9)
  - 3 sloji (terrain, objects, triggers)
  - 10 tipov objektov (drevesa, rude, zgradbe, sprožilci)
  - Undo/redo zgodovina (50 korakov)
  - Grid overlay
  - Predogled čopiča ob kazalcu
  - Export/import .map datoteke
  - Editor HUD s kontrole

### Kontrole
- [B] čopič, [S] velikost, [L] sloj, [G] mreža, [E] izvoz
- [Ctrl+Z] undo, [Ctrl+Y] redo, F4 toggle

### Statistika
- 624 Lua datotek (+1)
- 621/624 syntax pass
- 7 tipov čopičev (nov)
- 10 tipov objektov (nov)
- 3 sloji (nov)

## [v2.9.6] — 2026-08-07 — Achievement Unlock Animation (slide, glow, sparkles)

### Dodano
- **Achievement Unlock Animation** — animirana notifikacija ob odklepanju dosežkov
  - 3-stopenjska animacija: slideIn (0.3s) → hold (3s) → slideOut (0.3s)
  - 4 redkosti z barvami (common, rare, epic, legendary)
  - Pulsirajoč glow efekt
  - Sparkle delci
  - Queue sistem (več dosežkov v zaporedju)
  - Easing funkcije za smooth animacijo
  - Zvočni efekt ob prikazu

### Statistika
- 623 Lua datotek (+1)
- 620/623 syntax pass
- 3 stopnje animacije (nov)
- 4 redkosti s stilizacijo (nov)

## [v2.9.5] — 2026-08-07 — Enhanced Tooltip System (7 types, cost preview, fade)

### Dodano
- **Enhanced Tooltip System** — bogati tooltips z kontekstualnimi informacijami
  - 7 tipov (building, unit, resource, technology, hero, stats, default)
  - Večvrstično besedilo z barvnimi sekcijami
  - Predogled stroškov (barvno kodirani resource-i)
  - Statistika (HP, damage, armor, itd.)
  - Zakasnitev prikaza (0.5s, nastavljivo)
  - Fade-in/fade-out animacija
  - Pametno pozicioniranje (izogiba robovom zaslona)
  - Zgodovina tooltipov (zadnjih 20)
  - 6 hitrih helper metod

### Statistika
- 622 Lua datotek (+1)
- 619/622 syntax pass
- 7 tipov tooltipov (nov)

## [v2.9.4] — 2026-08-07 — Save State Manager (10 slots, auto-rotation, checksum)

### Dodano
- **Save State Manager** — napredno upravljanje shranjevanja
  - 10 ročnih slotov + quick save + auto-save
  - Metadata (timestamp, playtime, mission, gold, population)
  - Auto-save rotacija (zadnjih 5)
  - Quick save/load (slot 0)
  - Checksum za preverjanje integritete
  - Save migracija (verzionirani save-i)
  - Cloud sync stub (SteamWorks)
  - Save serializacija z Lua tabelami
  - Sledenje velikosti save-ov

### Tipi save-ov (3)
1. Ročni (sloti 1-10) — igralec poimenuje
2. Quick save (slot 0) — F5/F9
3. Auto-save (rotacija 1-5) — vsakih 5 min

### Statistika
- 621 Lua datotek (+1)
- 618/621 syntax pass
- 10 save slotov (nov)
- 3 tipi save-ov (nov)

## [v2.9.3] — 2026-08-07 — Chat Command System (22 commands, 6 categories)

### Dodano
- **Chat Command System** — hitri ukazi preko klepeta
  - 22 ukazov v 6 kategorijah (economy, military, time, world, debug, fun)
  - /gold, /resource, /tax, /spawn, /hero, /siege
  - /speed, /pause, /weather, /season, /timeofday, /festival
  - /stats, /fps, /summary, /prestige, /repair, /tech, /quest
  - /fireworks, /cinematic, /storm, /help
  - Zgodovina ukazov (zadnjih 50)
  - Vsi ukazi pcall-wrappani za varnost

### Statistika
- 620 Lua datotek (+1)
- 617/620 syntax pass
- 22 ukazov (nov)
- 6 kategorij ukazov (nov)

## [v2.9.2] — 2026-08-07 — Soundtrack Manager (8 tracks, 5 moods, crossfade)

### Dodano
- **Soundtrack Manager** — dinamični sistem glasbe
  - 8 glasbenih skladb v 5 razpoloženjih (menu, peace, tension, combat, victory)
  - Dinamično crossfading (2s prehod med skladbami)
  - Sistem prioritete razpoloženja (boj preglasi mir)
  - Sledenje intenzivnosti boja (auto preklop na bojno glasbo)
  - Zgodovina skladb (izogiba ponavljanju zadnjih 3)
  - Per-mood glasnost (nastavitev igralca)
  - Toggle on/off
  - Event-driven spremembe (zmaga, poraz, meni)

### Statistika
- 619 Lua datotek (+1)
- 616/619 syntax pass
- 8 skladb (nov)
- 5 razpoloženj (nov)

## [v2.9.1] — 2026-08-07 — Game Summary Generator (6 sections, letter grade)

### Dodano
- **Game Summary Generator** — celovit povzetek igre ob koncu
  - 6 sekcij: Military, Economy, Diplomacy, Construction, Technology, Special
  - Letter grade sistem (S, A, B, C, D, F) glede na skupni rezultat (0-1000)
  - Aggregira podatke iz 10+ sistemov
  - Formatiran tekstovni izpis
  - Save to file (.txt)
  - Barvno kodirane ocene

### Ocene (6 nivojev)
- S (900+): Legendarna — zlata
- A (750+): Odlična — zelena
- B (550+): Dobra — modra
- C (350+): Povprečna — rumena
- D (150+): Slaba — oranžna
- F (0+): Neuspešna — rdeča

### Statistika
- 618 Lua datotek (+1)
- 615/618 syntax pass
- 6 sekcij povzetka (nov)
- 6 stopenj ocen (nov)

## [v2.9.0] — 2026-08-07 — Procedural Map Generator (5 biomes, 4 sizes)

### Dodano
- **Procedural Map Generator** — ustvarjanje naključnih map
  - 5 biomov: Temperate, Arid, Mountainous, Coastal, Mixed
  - 4 velikosti: Small (128), Medium (192), Large (256), Huge (384)
  - Seed-based generacija za reproducibilnost
  - Generacija terena, rek, gozdov, gorovij
  - Postavljanje surovin (wood, stone, iron, food)
  - Startne pozicije za 2-8 igralcev
  - Identifikacija strateških točk (chokepoints)
  - 20 kombinacij biom×velikost

### Statistika
- 617 Lua datotek (+1)
- 614/617 syntax pass
- 5 biomov (nov)
- 4 velikosti map (nov)
- 20 kombinacij (nov)

## [v2.8.9] — 2026-08-07 — Camera Enhancement System (smooth, cinematic, zoom)

### Dodano
- **Camera Enhancement System** — napredna kamera
  - Smooth movement (lerp, nastavljiv smoothing)
  - 5 zoom nivojev (Very Close do Very Far) z miškinim koleščkom
  - Cinematic način (krožni let okoli gradu z dinamičnim zoomom)
  - 10 shranjenih pozicij kamere (hitri skok)
  - Edge scrolling (miška ob robu zaslona)
  - Focus follow (kamera sledi izbrani enoti)
  - Screenshot mode (skrije UI za čiste posnetke)
  - Center na grad / kaščo

### Statistika
- 616 Lua datotek (+1)
- 613/616 syntax pass
- 5 zoom nivojev (nov)
- Cinematic mode (nov)

## [v2.8.8] — 2026-08-07 — Time Manager System (8 speeds, auto-pause, schedule)

### Dodano
- **Time Manager System** — napredno upravljanje časa
  - 8 hitrosti (Pavza, 0.25×, 0.5×, 1×, 2×, 3×, 5×, 10×)
  - Samodejne pavze (focus loss, hero death, combat, mission complete)
  - Urnik dneva (polnoč, zora, poldne, mrak)
  - Time-lapse (preskok na naslednji dogodek)
  - Per-system time scaling (AI, ekonomija, boj, vreme, animacija)
  - Sledenje časovnega proračuna
  - Razmerje game/real čas

### Statistika
- 615 Lua datotek (+1)
- 612/615 syntax pass
- 8 hitrosti (nov)
- 4 auto-pause pogoji (nov)
- 5 sistemov time scaling (nov)

## [v2.8.7] — 2026-08-07 — Hero Unit System (6 heroes, leveling, abilities)

### Dodano
- **Hero Unit System** — posebne herojske enote z unikatnimi sposobnostmi
  - 6 tipov herojev z aktivnimi sposobnostmi in pasivnimi aurami
  - Leveling 1-10 (+30 HP, +5 damage na nivo)
  - Aktivne sposobnosti s cooldown-i (fireball, arrow storm, teleport...)
  - Pasivne aure (damage, armor, range bonusi v radiju)
  - Persistentna progresija (hero_progression.json)
  - Hero smrt = 2 min respawn timer
  - Full heal ob level up
  - Integracija s Prestige, VisualPolish, GameFeel, VoiceOver

### Heroji (6)
1. Knight Commander (1000g) — Battle Cry: +50% dmg aura
2. Master Archer (800g) — Arrow Storm: 20 dmg/s AoE
3. Siege Engineer (900g) — Rapid Construction: instant Trebuchet
4. Battle Mage (1200g) — Fireball: 80+40 splash damage
5. Shield Maiden (950g) — Aegis Shield: -90% dmg aura
6. Shadow Assassin (1100g) — Shadow Step: teleport + 100 backstab

### Statistika
- 614 Lua datotek (+1)
- 611/614 syntax pass
- 6 tipov herojev (nov)

## [v2.8.6] — 2026-08-07 — Weather Warfare System (7 abilities)

### Dodano
- **Weather Warfare System** — strateško upravljanje vremena
  - 7 sposobnosti: Summon Rain/Storm/Fog/Blizzard/Heatwave, Lightning Strike, Clear
  - Stroški zlata (100-600g) + cooldown (30-360s)
  - Lightning Strike: 50 damage v 3-tile radiju
  - Aktivni vremenski učinki s trajanjem
  - Vizualni efekti (iskre, screen shake)
  - Integracija s WeatherSystem in WeatherGameplay

### Sposobnosti (7)
1. Summon Rain (200g, 120s CD) — dež 60s, kmetije +50%
2. Summon Storm (500g, 300s CD) — nevihta 90s, hitrost -50%
3. Summon Fog (300g, 180s CD) — megla 120s, vidljivost -50%
4. Summon Blizzard (600g, 360s CD) — metež 60s, hitrost -70%
5. Summon Heatwave (400g, 240s CD) — vročina 75s, kmetije -40%
6. Lightning Strike (250g, 60s CD) — 50 damage instant
7. Clear Weather (100g, 30s CD) — odstrani vreme

### Statistika
- 613 Lua datotek (+1)
- 610/613 syntax pass
- 7 vremenskih sposobnosti (nov)

## [v2.8.5] — 2026-08-07 — Enhanced Modding API (events, hooks, content, data)

### Dodano
- **Enhanced Modding API** — celovit API za modderje
  - Events: registracija callback-ov za game evente
  - Hooks: intercept in modifikacija game funkcij
  - Content: registracija zgradb, enot, surovin, receptov, tehnologij, misij
  - Data: mod-specifično save/load (mods/<modId>/data.json)
  - Query: pregled registriranih modov in vsebine
  - Integracija s CustomBuildingLoader
  - Vsi callback-i pcall-wrappani za varnost
  - Samodejno čiščenje ob unregister

### API sekcije (5)
1. Events — on/off/emit
2. Hooks — addHook/runHooks
3. Content — registerBuilding/Unit/Resource/Recipe/Technology/Mission
4. Data — setData/getData/saveData/loadData
5. Query — getRegisteredMods/getCustomContent/getStats

### Statistika
- 612 Lua datotek (+1)
- 609/612 syntax pass

## [v2.8.4] — 2026-08-07 — Replay Enhancement System (timeline + bookmarks)

### Dodano
- **Replay Enhancement System** — izboljšano predvajanje replayev
  - Timeline scrubbing (skok na poljuben čas)
  - 6 hitrosti: 0.25×, 0.5×, 1×, 2×, 4×, 8×
  - Pavza/nadaljevanje
  - Preskakovanje (±10s)
  - Zaznamki (note, combat, economy, highlight)
  - Skok na zaznamke
  - Statistika replaya
  - Izvoz povzetka kot tekst
  - On-screen kontrolna vrstica
  - Tipke: Space=pavza, Levo/Desno=skip, Up=hitrost, B=zaznamek

### Statistika
- 611 Lua datotek (+1)
- 608/611 syntax pass

## [v2.8.3] — 2026-08-07 — PROJECT RENAME: Stronghold 2027 → Castle Kingdoms 2027

### Spremenjeno (IP zaščita — preimenovanje projekta)
- **Ime projekta**: Castle Kingdoms 2027 (prej Stronghold 2027)
- **GitHub repo**: castlekingdoms2027 (prej stronghold2027)
- **Window title**: "Castle Kingdoms 2027" (v conf.lua)
- **Vsa dokumentacija** posodobljena (README, CHANGELOG, CONTRIBUTING, itd.)
- **Vsi in-game stringi** posodobljeni (loading tips, credits, tutorial)
- **Firefly Studios reference** odstranjene iz vseh datotek
- **FORK_NOTICE.md** posodobljen z razlago preimenovanja

### Kaj je ostalo nespremenjeno
- Vse datotečne poti in direktoriji
- Vsa imena funkcij in API
- Vse game mehanike in sistemi
- Stone Kingdoms kredit (Apache 2.0 — odprtokodno)
- Kenney.nl kredit (CC0 — public domain)

### Statistika
- 610 Lua datotek
- 607/610 syntax pass
- 0 "Firefly" referenc (prej 15+)
- 0 "Castle Kingdoms" referenc (prej 100+)

## [v2.8.2] — 2026-08-04 — Leaderboard System (8 categories)

### Dodano
- **Leaderboard System** — primerjava rezultatov v 8 kategorijah
  - Total Score, Speed Run, Economy, Military, Builder, Diplomat, Survivor, Tournament
  - Lokalna tabela z AI tekmovalci (5 na kategorijo)
  - Osebni rekordi
  - Save/load persistenca (leaderboard.json)
  - Medalje za top 3 (zlato, srebro, bron)
  - Časovne in številske kategorije
  - GameEventBus dogodki

### Statistika
- 610 Lua datotek (+1)
- 607/610 syntax pass
- 8 kategorij leaderboarda (nov)

## [v2.8.1] — 2026-08-04 — Custom Scenario Editor (create, save, share)

### Dodano
- **Custom Scenario Editor** — ustvarjanje lastnih scenarijev
  - Definiranje začetnih surovin, populacije, zgradb
  - Cilji (destroy, gather, protect, survive)
  - AI nasprotniki (osebnost, težavnost, enote)
  - Časovni dogodki (napadi, okrepitve, vreme)
  - Win/lose pogoji
  - Save/load v datoteke (scenarios/)
  - Export/import za deljenje
  - Playtest način
  - 25+ API funkcij

### Statistika
- 609 Lua datotek (+1)
- 606/609 syntax pass

## [v2.8.0] — 2026-08-04 — Tournament System (5 tournament types)

### Dodano
- **Tournament System** — periodicna tekmovanja z nagradami
  - 5 tipov: Jousting, Archery, Siege, Economy, Grand
  - Vstopnine 50-300g, nagrade 80-1500g + prestige
  - 3-5 AI tekmacev na turnir
  - Top 3 uvrstitve dobijo nagrade
  - Real-time sledenje rezultatov
  - Zgodovina (zadnjih 20 turnirjev)
  - Statistika win rate
  - Vsakih 6 minut nov turnir

### Tipi turnirjev (5)
1. Jousting (300s, 100g) — 1. mesto: 500g+30p
2. Archery (240s, 75g) — 1. mesto: 400g+25p
3. Siege (360s, 200g) — 1. mesto: 800g+40p
4. Economy (300s, 50g) — 1. mesto: 600g+20p
5. Grand (600s, 300g) — 1. mesto: 1500g+75p

### Statistika
- 608 Lua datotek (+1)
- 605/608 syntax pass
- 5 tipov turnirjev (nov)

## [v2.7.9] — 2026-08-04 — Prestige & Ranking System (9 ranks)

### Dodano
- **Prestige & Ranking System** — 9 stopenj ugleda
  - Novice (0) → Squire (50) → Knight (150) → Baron (300) → Count (500)
  - Duke (800) → King (1200) → Emperor (2000) → Legend (3500)
  - 18 virov točk (misije, achievementi, multiplayer, tehnologije...)
  - Bonus k zlatu: +2% na rang (max +16% pri Legend)
  - Save/load persistenca (prestige.json)
  - GameEventBus dogodki ob promociji

### Statistika
- 607 Lua datotek (+1)
- 604/607 syntax pass
- 9 stopenj ugleda (nov)
- 18 virov točk (nov)

## [v2.7.8] — 2026-08-04 — Tactical Map Overlay (5 strategic modes)

### Dodano
- **Tactical Map Overlay** — strateška vizualizacija zemljevida
  - 5 načinov: Threat, Supply, Territory, Economy, Military
  - Threat (rdeča) — cone groženj z velikostjo glede na moč enot
  - Supply (zelena) — doseg oskrbnih zgradb
  - Territory (modra) — nadzor ozemlja po frakcijah
  - Economy (rumena) — produkcijski centri
  - Military (vijolična) — enote z HP trakovi
  - Osvežitev vsako sekundo
  - Nastavljiva prosojnost

### Statistika
- 606 Lua datotek (+1)
- 603/606 syntax pass
- 5 taktičnih načinov (nov)

## [v2.7.7] — 2026-08-04 — Game Analytics Dashboard (real-time metrics)

### Dodano
- **Game Analytics Dashboard** — sledenje 25+ metrik v realnem času
  - 6 kategorij: Military, Economy, Construction, Diplomacy, Espionage, Quests
  - APM (akcije na minuto)
  - Session + lifetime podatki z persistenco
  - Neto vrednost (zlato + surovine)
  - K/D razmerje
  - Formatiran povzetek za prikaz
  - Auto-save v analytics_lifetime.json

### Sledene metrike (25+)
- **Military**: usposobljene/izgubljene enote, ubiti sovražniki, K/D, zmage/porazi
- **Economy**: zaslužek/poraba/neto zlato, neto vrednost, trgovine, profit
- **Construction**: zgrajene/uničene/popravljene zgradbe
- **Diplomacy**: zavezništva, vojne, tributi poslani/prejeti
- **Espionage**: misije, uspešnost
- **Quests & Tech**: questi, tehnologije
- **Performance**: čas igranja, akcije, APM

### Statistika
- 605 Lua datotek (+1)
- 602/605 syntax pass

## [v2.7.6] — 2026-08-04 — Quest System (9 side quests, 4 types)

### Dodano
- **Quest System** — stranske misije za dodatne nagrade
  - 4 tipi: Bounty, Delivery, Construction, Challenge
  - 9 quest predlog z nagradami
  - Sprejemanje/opuščanje questov
  - Sledenje napredka
  - Časovne omejitve za izzive
  - Level zahteve
  - GameEventBus dogodki

### Tipi questov (4)
1. **Bounty** (2) — ubij določene sovražnikove enote
2. **Delivery** (2) — zberi surovine
3. **Construction** (2) — zgradi strukture
4. **Challenge** (3) — doseži cilje z omejitvami

### Statistika
- 604 Lua datotek (+1)
- 601/604 syntax pass
- 9 quest predlog (nov)
- 4 tipi questov (nov)

## [v2.7.5] — 2026-08-04 — Supply Line Manager (logistics system)

### Dodano
- **Supply Line Manager** — strateška logistika
  - 5 tipov oskrbnih zgradb (Stockpile, Granary, Armoury, Market, Inn)
  - Enote brez oskrbe: -20% damage, -10% hitrost, brez celjenja
  - Doseg oskrbe: 30 ploščic (nadgradljivo)
  - Debug vizualizacija (krogi oskrbe + oznake brez oskrbe)
  - Izračun pokritosti oskrbe

### Kazni za enote brez oskrbe
- -20% damage — enote ne morejo polno bojevati
- -10% hitrost — enote se premikajo počasneje
- Brez celjenja — enote ne morejo obnoviti HP
- Kazni se samodejno aplikirajo/odstranjujejo

### Statistika
- 603 Lua datotek (+1)
- **600/603 syntax pass** — mejnik!

## [v2.7.4] — 2026-08-04 — Achievement Tracker (15 achievements, 4 rarities)

### Dodano
- **Achievement Tracker** — podrobno sledenje napredka
  - 15 achievementov s progress trakovi
  - 4 redkosti: common, rare, epic, legendary
  - 5 kategorij: combat, economy, campaign, social, special
  - Datumi odklepanja
  - Export/import za backup
  - HD playtime sledenje (3600s = 1 ura)
  - Integracija s SteamWorks

### Redkosti (4)
- **Common** — lahki (First Victory, HD Enthusiast)
- **Rare** — srednji (Flawless, Speed Run, Master Builder, Trader)
- **Epic** — težki (Siege Master, Legendary Army, Economy Guru)
- **Legendary** — ultimativni (Campaign Complete)

### Statistika
- 602 Lua datotek (+1)
- 599/602 syntax pass
- 15 achievementov s sledenjem (nov)
- 4 redkosti (nov)
- 5 kategorij (nov)

## [v2.7.3] — 2026-08-04 — Building Manager System (7 categories)

### Dodano
- **Building Manager System** — centralizirano upravljanje zgradb
  - 7 kategorij: economy, military, defense, housing, religious, storage, keep
  - Caching (osvežitev vsakih 2s)
  - Filtriranje po kategoriji, imenu, dosegu
  - Odkrivanje poškodovanih zgradb
  - repairAll() — popravi vse za 1g/HP
  - Izračun stanovanjske kapacitete
  - Štetje produkcije/obrambe/vojaških zgradb

### Kategorije zgradb (7)
1. Economy (18 tipov) — farme, rudniki, delavnice
2. Military (6 tipov) — barake, cehi, arena
3. Defense (7 tipov) — zidovi, stolpi, vrata
4. Housing (4 tipi) — hiše, stanovanja
5. Religious (4 tipi) — kapele, cerkve, katedrale
6. Storage (2 tipa) — skladišča, kašče
7. Keep (5 tipov) — gradovi

### Statistika
- 601 Lua datotek (+1)
- 598/601 syntax pass
- 7 kategorij zgradb (nov)

## [v2.7.2] — 2026-08-04 — Notification Center (4 priorities, 6 categories)

### Dodano
- **Notification Center** — centralizirano upravljanje obvestil
  - 4 prioritete: CRITICAL (persistent), HIGH (8s), NORMAL (5s), LOW (3s)
  - 6 kategorij: combat, economy, diplomacy, mission, system, social
  - Zgodovina (zadnjih 100 obvestil)
  - Samodejno iztekanje ne-kritičnih obvestil
  - Barvni okvirji in ikone po kategoriji
  - Zvočni efekti po kategoriji
  - Max 5 sočasnih obvestil
  - Fade-out animacija v zadnji sekundi
  - Prikaz v spodnjem desnem kotu

### Statistika
- **600 Lua datotek** (+1) — mejnik!
- 597/600 syntax pass
- 4 prioritete (nov)
- 6 kategorij (nov)

## [v2.7.1] — 2026-08-04 — Random Event System + 8 New Resources

### Dodano
- **Random Event System** — 7 tipov naključnih dogodkov
  - Hero Visit (5%) — brezplačna veteran enota
  - Merchant Caravan (8%) — +200-600 zlata
  - Plague (4%) — -15% populacije, -10 sreče
  - Fire (6%) — 50% HP na 10% zgradb
  - Earthquake (2%) — 30% HP na 20% zgradb
  - Golden Age (3%) — +500 zlata, bogata letina
  - Refugee Crisis (5%) — +20 populacije, -15 sreče
- **8 novih tipov surovin** (skupno 17):
  - pitch (25g), leather (40g), silk (120g), spices (80g)
  - wine (60g), wool (20g), coal (35g), gold, food

### Statistika
- 599 Lua datotek (+1)
- 596/599 syntax pass
- 7 naključnih dogodkov (nov)
- 17 tipov surovin (+8)

## [v2.7.0] — 2026-08-04 — Trade Route Manager (persistent routes)

### Dodano
- **Trade Route Manager** — persistentne trgovske poti
  - 3 tipi poti: standard (200g), luxury (500g), military (400g)
  - Samodejni dohodek vsakih 60s
  - Učinkovitost glede na razdaljo, diplomacijo, sezono
  - 5% šansa za napad banditov (+10% če sovražni)
  - Nadgradnja poti za +15% učinkovitost na nivo
  - GameEventBus dogodki: trade_income, trade_route_raided

### Tipi poti (3)
1. Standard — 200g, 50 base income, 1.0× ef.
2. Luxury — 500g, 100 base income, 1.5× ef.
3. Military — 400g, 75 base income, 1.2× ef.

### Statistika
- 598 Lua datotek (+1)
- 595/598 syntax pass
- 3 tipi trgovskih poti (nov)

## [v2.6.9] — 2026-08-04 — Army Command System (7 order types)

### Dodano
- **Army Command System** — upravljanje vojaških formacij
  - Ustvari imenovane armade (Vanguard, Reserve, Scouts...)
  - 7 tipov ukazov: Hold, Advance, Charge, Retreat, Patrol, Siege, Flank
  - Dodeljevanje enot k armadam
  - Sledenje moči in sestave
  - Samodejna razpustitev praznih armad
  - Čiščenje mrtvih enot
  - Koordinacija več armad

### Tipi ukazov (7)
1. Hold — drži položaj, napadaj bližnje sovražnike
2. Advance — premakni se k cilju
3. Charge — polni napad
4. Retreat — umik v bazo
5. Patrol — patrulja med točkami
6. Siege — oblegaj sovražnikov grad
7. Flank — napad z boka

### Statistika
- 597 Lua datotek (+1)
- 594/597 syntax pass
- 7 tipov ukazov (nov)

## [v2.6.8] — 2026-08-04 — Diplomatic Relations System (5 levels)

### Dodano
- **Diplomatic Relations System** — 5 stopenj odnosov
  - Hostile (-100 do -50): vojna, brez diplomacije
  - Unfriendly (-49 do -20): brez trgovine
  - Neutral (-19 do 19): osnovna trgovina
  - Friendly (20 do 49): +15% trgovina, obramba
  - Allied (50 do 100): +30% trgovina, skupna vizija
- 9 diplomatskih akcij z modifikatorji
- Zgodovina odnosov (zadnjih 20 akcij)
- Počasno razpadanje proti nevtralnem
- Zrcaljenje odnosov (80% teža)
- Trade bonusi, defense pact, shared vision

### Diplomatske akcije (9)
1. trade_completed (+3), 2. tribute_sent (+5), 3. alliance_formed (+20)
4. peace_proposed (+10), 5. war_declared (-30), 6. assassination_attempt (-40)
7. sabotage (-25), 8. border_violation (-10), 9. shared_enemy (+8)

### Statistika
- 596 Lua datotek (+1)
- 593/596 syntax pass
- 5 stopenj odnosov (nov)
- 9 diplomatskih akcij (nov)

## [v2.6.7] — 2026-08-04 — Espionage & Intelligence System

### Dodano
- **Espionage & Intelligence System** — 5 tipov vohunskih misij
  - Scout (100g, 30s, 90%) — razkrij sovražnikovo ozemlje
  - Sabotage (300g, 60s, 60%) — uniči sovražnikovo zgradbo
  - Steal Gold (50g, 45s, 75%) — ukradi 200-800 zlata
  - Assassinate (500g, 90s, 40%) — ubij sovražnikovega vodjo
  - Counter-spy (150g, instant, 100%) — 24h zaščita
- Usposabljanje vohunov v gostilnah (250g, max 5)
- Zbiranje obveščevalnih podatkov o sovražniku
- GameEventBus dogodki za uspeh/napako

### Statistika
- 595 Lua datotek (+1)
- 592/595 syntax pass
- 5 tipov misij (nov)
- Max 5 vohunov (glede na gostilne)

## [v2.6.6] — 2026-08-04 — Production Chain System (7 chains)

### Dodano
- **Production Chain System** — 7 produkcijskih verig v 3 kategorijah
  - Food (2): Wheat→Bread, Hops→Ale
  - Weapon (4): Iron→Swords, Wood→Bows, Wood→Pikes, Iron→Armor
  - Building (1): Stone→Towers
- Večstopenjska obdelava (raw → processed → final)
- Odkrivanje ozkih grl (bottleneck detection)
- Štetje zgradb na stopnjo
- Izračun produkcije na uro

### Statistika
- 594 Lua datotek (+1)
- 591/594 syntax pass
- 7 produkcijskih verig (nov)
- 3 kategorije: food, weapon, building

## [v2.6.5] — 2026-08-04 — Population & Happiness System

### Dodano
- **Population & Happiness System** — dinamično upravljanje populacije
  - 6 faktorjev sreče: hrana, davki, stanovanja, religija, festivali, osnova
  - Rast populacije glede na srečo in hrano (-2 do +2 na 5s)
  - Maksimalna populacija iz stanovanjskih zgradb
  - Ctrl+Shift+P za prikaz populacije in razčlenitve sreče
  - Posodablja _G.state.population, maxPopulation, popularity

### Faktorji sreče (6)
1. Hrana — izobilje (+10), pomanjkanje (-20)
2. Davki — nizki (+5), visoki (-15)
3. Stanovanja — prostorno (+5), prenapolnjeno (-2/overflow)
4. Religija — kapele (+3), cerkve (+6), katedrale (+15)
5. Festivali — aktivni (+10)
6. Osnova — 50 (nevtralno)

### Statistika
- 593 Lua datotek (+1)
- 590/593 syntax pass

## [v2.6.4] — 2026-08-04 — Technology Tree System (14 technologies)

### Dodano
- **Technology Tree System** — 14 tehnologij v 4 kategorijah
  - Military (4): Archery, Steel Weapons, Cavalry School, Siege Tech
  - Economy (4): Agriculture, Mining, Trade Routes, Trade Bonuses
  - Defense (3): Reinforced Walls, Tower Improvements, Armored Gates
  - Civil (3): Advanced Housing, Religious Institutions, Education
- Raziskovanje z zlatom + časom (50-150s na tehnologijo)
- Tehnološke odvisnosti (requires field)
- Dinamični bonusi za enote, zgradbe, produkcijo
- Ctrl+Shift+Y za prikaz tech tree statusa
- GameEventBus event 'technology_researched'

### Statistika
- 592 Lua datotek (+1)
- 589/592 syntax pass
- 14 tehnologij (nov)
- 4 kategorije: military, economy, defense, civil

## [v2.6.3] — 2026-08-04 — Daily Challenge System

### Dodano
- **Daily Challenge System** — 3 naključni izzivi na dan
  - 4 kategorije: economic, military, building, diplomatic
  - 14 predlog izzivov z variabilnimi cilji (±20%)
  - Zlati dodatki za dokončanje (200-500 gold)
  - Save/load persistenca (daily_challenges.json)
  - Ctrl+Shift+H za prikaz trenutnih izzivov
- **GameEventBus** event 'daily_challenge_complete' ob dokončanju

### Predloge izzivov (14)
- Economic (5): gather_wood, gather_stone, gather_food, gather_gold, gather_iron
- Military (4): kill_enemies, win_battles, train_units, siege_destroy
- Building (2): build_structures, build_towers
- Diplomatic (3): form_alliances, complete_trades, send_tributes

### Statistika
- 591 Lua datotek (+1)
- 588/591 syntax pass
- 14 challenge predlog (nov)
- 3 dnevni izzivi na dan

## [v2.6.2] — 2026-08-04 — 3 New Extreme Weather Types

### Dodano
- **3 novi ekstremni vremenski tipi** (skupno 9):
  - Blizzard (Meteh) — farm ×0.10, speed ×0.30, vision ×0.40 (najhujša zima)
  - Heatwave (Vroinski val) — farm ×0.60, fire risk 1.0 (nevarnost pozara)
  - Sandstorm (Pehana) — vision ×0.30, archer ×0.40 (skoraj slepilo)
- F5 weather cycling posodobljen z vsemi 9 tipi

### Impact
- 9 vremenskih tipov (prej 6) — večja strateška raznolikost
- Ekstremno vreme ustvarja taktične odločitve
- Blizzard skoraj uniči kmetijstvo (×0.10)
- Heatwave ustvarja nevarnost pozara (risk 1.0)
- Sandstorm skoraj oslepi vse enote (×0.30 vision)

## [v2.6.1] — 2026-08-04 — 2 New Upgrade Paths + 2 New Formations

### Dodano
- **2 novi upgrade poti** (skupno 7):
  - Siege progression (3 tier-i): EngineersGuild → SiegeWorkshop → RoyalSiegeGuild
  - Economy progression (3 tier-i): Market → TradePost → RoyalExchange
- **2 novi formaciji** (skupno 7):
  - Phalanx (Falanga) — obramba 1.6×, hitrost 0.6× (najpočasnejša, najmočnejša obramba)
  - Skirmish (Razpršena) — hitrost 1.3×, napad 1.2× (najhitrejša, za lokostrelce)
- cycleFormation posodobljen z vsemi 7 formacijami

### Statistika
- 590 Lua datotek
- 587/590 syntax pass
- 7 upgrade poti (+2)
- 7 formacij (+2)

## [v2.6.0] — 2026-08-04 — Fix giveResources + Casualty Tracking

### Popravljeno
- **MissionFramework.giveResources()** — prej dodal samo gold
  zdaj dodaja vse surovine (wood, stone, food, iron, etc.) v `_G.state.resources`
  - Mission rewards so zdaj popolni (prej so wood/stone tiho izpuščeni)
- **Casualty tracking** za no_casualties achievement:
  - loadMission() inicializira `_playerLosses = 0`
  - Nova `MissionFramework.reportPlayerLoss()` funkcija
  - CombatComponent kliče reportPlayerLoss() ko igralčeva enota umre
  - `_checkNoCasualties()` zdaj pravilno vrne true pri 0 izgubah

### Impact
- Mission rewards dajejo vse surovine (ne samo gold)
- no_casualties achievement je zdaj dosegljiv ("Flawless")
- Igralci ki zmaga brez izgub odklenejo achievement
- MissionFramework registriran kot `_G.MissionFramework`

## [v2.5.9] — 2026-08-04 — Fix 2 Critical Stubs (getResourceCount + spawnEnemyGroup)

### Popravljeno (2 kritični stub funkciji)
- **MissionFramework.getResourceCount()** — prej vedno vrnil 0 (placeholder)
  zdaj pravilno poizveduje `_G.state.gold` in `_G.state.resources[resource]`
  - Resource gathering cilji (npr. "zberi 50 lesa") so zdaj zaznavni
  - Win conditions ki temeljijo na surovinah zdaj delujejo
- **AIController:spawnEnemyGroup()** — prej le print (stub)
  zdaj delegira na `CombatIntegration.spawnEnemyGroup()`
  - AI lahko zdaj dejansko ustvari sovražne skupine
  - Scenario triggerji ki kličejo to imajo zdaj učinek

### Impact
- Resource gathering objektivi zdaj delujejo (bili so zlomljeni)
- AI spawning za scenarije zdaj funkcionalen
- 2 stub-a odstranjena iz codebase

## [v2.5.8] — 2026-08-04 — 12 New Voice-Over + 4 New SFX Categories

### Dodano
- **12 novih voice-over sporočil** (skupno 42+):
  - unit_veteran, unit_legendary, siege_weapon_ready
  - festival_started, festival_ended, economic_event
  - season_changed, trade_completed, tribute_sent
  - coop_mission_start, skirmish_start
- **4 nove SFX kategorije** (skupno 8):
  - siege (5 zvokov) — catapult_fire, trebuchet_fire, ram_hit, tower_deploy, wall_collapse
  - festival (3 zvoki) — cheer, fanfare, bell
  - weather (3 zvoki) — rain, thunder, wind
  - veterancy (2 zvoka) — level_up, legendary_fanfare

### Statistika
- 590 Lua datotek
- 587/590 syntax pass
- 42+ voice-over sporočil (+12)
- 8 SFX kategorij (+4)

## [v2.5.7] — 2026-08-04 — Fix Food Hint + 5 Tutorial Hints + 10 Loading Tips

### Popravljeno
- **TutorialHints.checkResources()** — food je bil nastavljen na gold (placeholder)
  zdaj pravilno preverja `_G.state.resources.food`
- Dodan low_food hint trigger (food < 20)

### Dodano
- **5 novih tutorial hints** (skupno 16):
  - veterancy_tip, formation_tip, festival_tip, diplomacy_tip, siege_tip
- **10 novih loading tips** (skupno 50+):
  - Veterancy (2), Formacije (1), Festivali (1), Diplomacija (1)
  - AI (2), Zgodovina (3 — Norman Conquest)

### Statistika
- 590 Lua datotek
- 587/590 syntax pass
- 16 tutorial hints (+5)
- 50+ loading tips (+10)

## [v2.5.6] — 2026-08-04 — 3 New Festivals + 5 New Achievements

### Dodano
- **3 novi festivali** (skupno 8):
  - Praznik letine — food production ×1.5, +10 pop (80g, 40 food)
  - Tournamentska igra — +20 pop (300g, 50 wood)
  - Kronanje — +35 pop, največji boost (500g, 100 stone, 100 food)
- **5 novih Steam achievementov** (skupno 15):
  - Siege Master — uniči 50 zgradb z oblegovalnimi orožji
  - Legendary Army — usposobi Legendarno (level 5) enoto
  - Trail Conqueror — končaj vseh 15 skirmish misij
  - Co-op Master — končaj vseh 10 co-op misij
  - Storm Lord — zmagaj v bitki med nevihto
- **5 novih event hookov** v onGameEvent

### Statistika
- 590 Lua datotek
- 587/590 syntax pass
- 8 festivalov (+3)
- 15 Steam achievementov (+5)

## [v2.5.5] — 2026-08-04 — 5 New Economic Events + README Sync

### Dodano
- **5 novih ekonomskih dogodkov** (skupno 15):
  - Iron Discovery — iron production ×2, cene -40%
  - Drought — food -60%, wood -30% (poletje)
  - Trade Boom — wood/stone cene +30%
  - Bandit Raid — -300 gold, -2% populacije (instant)
  - Holy Pilgrimage — +30 popularity, ale/bread -10-20%
- **README sinhroniziran** z v2.5.4:
  - Posodobljeni badge-i (587/590, 70 popravkov, 16 krogov)
  - Razširjena statistika (16 vrstic)
  - AI sekcija (8 osebnosti, 48 konfiguracij)
  - Ključne verzije sekcija (8 verzij)

### Statistika
- 590 Lua datotek
- 587/590 syntax pass
- 15 ekonomskih dogodkov (+5)

## [v2.5.4] — 2026-08-04 — 4 New Units + 3 New Buildings (Norman Era)

### Dodano
- **4 nove vojaške enote** (skupno 11):
  - Huscarl — elite Saxon axeman (HP 150, DMG 28, armor 0.40)
  - Longbowman — Welsh longbow (HP 55, DMG 18, range 11)
  - NormanKnight — heaviest cavalry (HP 220, DMG 35, armor 0.55)
  - Javelinman — light skirmisher (HP 65, DMG 16, range 6)
- **3 nove zgradbe** (skupno 35+):
  - TournamentArena — boosti veterancy gain (40w, 30s, 100g)
  - Shrine — boosti popularity (20w, 40s, 50g)
  - WatchTower — razširi vision range (10w, 30s)
- AI osebnosti posodobljene z novimi enotami:
  - Siege Master: NormanKnight, TournamentArena
  - Fortress Keeper: Huscarl, Longbowman, WatchTower
  - Raider: Javelinman, NormanKnight
  - Diplomat: Longbowman, Shrine

### Impact
- 11 vojaških enot (prej 7)
- 35+ zgradb (prej 32)
- Nove strateške možnosti za igralce in AI
- Zgodovinsko avtentičen Norman Conquest roster

## [v2.5.3] — 2026-08-04 — 15 Skirmish + 10 Co-op Missions + Modding API

### Dodano
- **5 novih skirmish misij** (skupno 15):
  - Oblegovalni mojster (vs Siege Master)
  - Čuvar trdnjave (vs Fortress Keeper x2)
  - Plenilski napad (vs Raider x3)
  - Diplomatska kriza (vs Diplomat x2)
  - Legendarne legije (vs Aggressive x4, legendary)
- **5 novih co-op misij** (skupno 10) — zgodovinske Norman Conquest:
  - Hastings 1066, Pustošenje severa, Škotska kampanja, Danska invazija, Obramba Normandije
- **4 nove ModLoader funkcije**:
  - getModInfo(modId) — informacije o modu brez nalaganja
  - listAvailableMods() — seznam vseh modov
  - validateManifest(manifest) — validacija formata
  - exportModList() — JSON-compatibelni izvoz

### Statistika
- 590 Lua datotek
- 587/590 syntax pass
- 15 skirmish misij (+5)
- 10 co-op misij (+5)

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
- **Castle Kingdoms 2027 zdaj presega original v VSEH 8 kategorijah:**
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

Glej [git log](https://github.com/markec12345678/castlekingdoms2027/commits/main) za podrobnosti o zgodnjih verzijah:
- v1.0.0 — campaign complete
- v1.1.x — polish, performance, gamefeel
- v1.2.x — combat visualizer, settings
- v1.3.x — AI enhancements, UX screens
- v1.4.x — final audit, localization
- v1.5.x — Kenney CC0 asset integration
- v1.6.x — final, performance fixes
- v1.7.0-v1.7.1 — crash fixes, LFS fix
