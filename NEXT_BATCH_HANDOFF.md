# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.871**
- Skupaj Royal sistemov: **959**
- Skupaj Lua datotek: **1608**
- Sintaktična preverba: **1605/1608 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 769 Royal sisteme z igro:

- **`objects/Economy/RoyalSystemsRegistry.lua`** — auto-discovers vse sisteme, hook-a `completeMaking()`, dodeli bonus zlato (prestige × 10) ob končanem produktu
- **`states/ui/hud/royal_systems_panel.lua`** — full-screen UI panel (toggle s Ctrl+R), ki omogoča brskanje, najem mojstrov, gradnjo delavnic, izdelavo produktov, prodajo zalog
- **`states/ui/hud/keybind_help.lua`** — dodana Ctrl+R bližnjica
- **`scripts/test_registry.lua`** — test skripta (poženi z lupa)

Vsi novi sistemi, dodani po v3.11.382, so samodejno odkriti in prikazani v panelu — ni potrebe po ročni registraciji v Registry. Tudi ni potrebno več ročno registrirati sisteme v states/game.lua (require/init/update bloki) — zadnje pakete (od v3.11.542 naprej) pustimo neregistrirane, ker jih Registry sam odkrije preko S tabele.

## ZNANE NADGRADNJE ZA PRIHODNJE PAKETE

1. **Povezava z DynamicMarketSystem** — Royal produkti naj bodo prodani na tržnici
2. **Sprite-i za Royal sisteme** — trenutno so samo podatkovni, brez grafične podobe
3. **Grafikon produkcije** — zgodovina proizvodnje v panelu
4. **Sistemsko odvisnosti** — nekateri sistemi naj zahtevajo druge (npr. BellMaker zahteva Metalwork)

## ZADNJE ZAKLJUČENI PAKET (v3.11.862–v3.11.871) — STEKLARSKI DODATKI 12 + LIVARSKI DODATKI 12

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 12 (v3.11.862-v3.11.866)
1. **RoyalGlassBlowpipeCoolingRackMakerSystem.lua** → `local GlassBlowpipeCoolingRackMaker` (police za ohlajanje)
2. **RoyalGlassKilnBrickSawMakerSystem.lua** → `local GlassKilnBrickSawMaker` (žage za opeke)
3. **RoyalGlassColorantDryingTrayMakerSystem.lua** → `local GlassColorantDryingTrayMaker` (pladnji za barve)
4. **RoyalGlassAnnealingOvenInspectionMirrorMakerSystem.lua** → `local GlassAnnealingOvenInspectionMirrorMaker` (zrcala za pregled)
5. **RoyalGlassEngravingWheelDressingStoneMakerSystem.lua** → `local GlassEngravingWheelDressingStoneMaker` (brusni kamni)

### Livarski dodatki 12 (v3.11.867-v3.11.871)
6. **RoyalMoldFlaskAlignmentPinMakerSystem.lua** → `local MoldFlaskAlignmentPinMaker` (bolti za poravnavo)
7. **RoyalPouringLadleLiningCementMakerSystem.lua** → `local PouringLadleLiningCementMaker` (cement za obloge)
8. **RoyalSandBinderDispenserMakerSystem.lua** → `local SandBinderDispenserMaker` (dajalniki veziva)
9. **RoyalCorePrintBoxMakerSystem.lua** → `local CorePrintBoxMaker` (škatle za odtise)
10. **RoyalCastingLadleSkimmerHandleMakerSystem.lua** → `local CastingLadleSkimmerHandleMaker` (ročaji za strgalce)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_glass12_foundry12_systems.py`
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

## NASLEDNJI PAKET (v3.11.872–v3.11.881) — KNJIGOVEŠKI DODATKI 12 + KOVAŠKI DODATKI 12

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 12 (v3.11.872-v3.11.876) — predloga
1. **RoyalBookSpineLabelPrinterMakerSystem.lua** → `local BookSpineLabelPrinterMaker` (tiskalniki za oznake hrbtov)
2. **RoyalBookCoverPasteSpatulaMakerSystem.lua** → `local BookCoverPasteSpatulaMaker` (lopatice za pasto)
3. **RoyalBookSewingBenchLightMakerSystem.lua** → `local BookSewingBenchLightMaker` (svetila za šivalne klopi)
4. **RoyalBookEdgeGiltSizeBrushMakerSystem.lua** → `local BookEdgeGiltSizeBrushMaker` (čopiči za pozlate)
5. **RoyalBookCoverBoardEdgeTrimmerMakerSystem.lua** → `local BookCoverBoardEdgeTrimmerMaker` (obrezovalci robov)

### Kovaški dodatki 12 (v3.11.877-v3.11.881) — predloga
6. **RoyalForgeTuyereBrushMakerSystem.lua** → `local ForgeTuyereBrushMaker` (ščetke za šobe)
7. **RoyalAnvilHornPolisherMakerSystem.lua** → `local AnvilHornPolisherMaker` (poliralci za rog nakovala)
8. **RoyalForgeCoalRakeToothMakerSystem.lua** → `local ForgeCoalRakeToothMaker` (zobje za grebalce)
9. **RoyalQuenchTankDrainValveMakerSystem.lua** → `local QuenchTankDrainValveMaker` (zaklopke za izpust)
10. **RoyalSmithTongsJawInsertMakerSystem.lua** → `local SmithTongsJawInsertMaker` (vstavki za čeljusti klešč)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 nacrtovanih datotek
2. Ustvari 10 .lua datotek z generatorsko skripto
3. Pozeni sintakticno preverbo
4. Posodobi CHANGELOG.md, README.md badge-je, NEXT_BATCH_HANDOFF.md
5. Git: commit, tag (v3.11.872 do v3.11.881), push
6. Build .love

## SPOROCILO ZA NOVO SEJO

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna razlicica je v3.11.871. Naslednji paket je v3.11.872–v3.11.881 (knjigoveski dodatki 12 + kovaski dodatki 12: BookSpineLabelPrinterMaker, BookCoverPasteSpatulaMaker, BookSewingBenchLightMaker, BookEdgeGiltSizeBrushMaker, BookCoverBoardEdgeTrimmerMaker, ForgeTuyereBrushMaker, AnvilHornPolisherMaker, ForgeCoalRakeToothMaker, QuenchTankDrainValveMaker, SmithTongsJawInsertMaker). Sledi navodilom v handoff dokumentu. Po koncanem paketu rocno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.872–v3.11.876: knjigoveski dodatki 12 (BookSpineLabelPrinterMaker, BookCoverPasteSpatulaMaker, BookSewingBenchLightMaker, BookEdgeGiltSizeBrushMaker, BookCoverBoardEdgeTrimmerMaker)
- v3.11.877–v3.11.881: kovaski dodatki 12 (ForgeTuyereBrushMaker, AnvilHornPolisherMaker, ForgeCoalRakeToothMaker, QuenchTankDrainValveMaker, SmithTongsJawInsertMaker)
- v3.11.882–v3.11.886: vrtni dodatki 12 (predlagano)
- v3.11.887–v3.11.891: mlinarski dodatki 12 (predlagano)
