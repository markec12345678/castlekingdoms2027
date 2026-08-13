# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.881**
- Skupaj Royal sistemov: **967**
- Skupaj Lua datotek: **1618**
- Sintaktična preverba: **1615/1618 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
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

## ZADNJE ZAKLJUČENI PAKET (v3.11.872–v3.11.881) — KNJIGOVEŠKI DODATKI 12 + KOVAŠKI DODATKI 12

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 12 (v3.11.872-v3.11.876)
1. **RoyalBookSpineLabelPrinterMakerSystem.lua** → `local BookSpineLabelPrinterMaker` (tiskalniki za oznake)
2. **RoyalBookCoverPasteSpatulaMakerSystem.lua** → `local BookCoverPasteSpatulaMaker` (lopatice za pasto)
3. **RoyalBookSewingBenchLightMakerSystem.lua** → `local BookSewingBenchLightMaker` (svetila za klopi)
4. **RoyalBookEdgeGiltSizeBrushMakerSystem.lua** → `local BookEdgeGiltSizeBrushMaker` (copic za pozlate)
5. **RoyalBookCoverBoardEdgeTrimmerMakerSystem.lua** → `local BookCoverBoardEdgeTrimmerMaker` (obrezovalci robov)

### Kovaški dodatki 12 (v3.11.877-v3.11.881)
6. **RoyalForgeTuyereBrushMakerSystem.lua** → `local ForgeTuyereBrushMaker` (scetke za šobe)
7. **RoyalAnvilHornPolisherMakerSystem.lua** → `local AnvilHornPolisherMaker` (poliralci za rog)
8. **RoyalForgeCoalRakeToothMakerSystem.lua** → `local ForgeCoalRakeToothMaker` (zobje za grebalce)
9. **RoyalQuenchTankDrainValveMakerSystem.lua** → `local QuenchTankDrainValveMaker` (zaklopke za izpust)
10. **RoyalSmithTongsJawInsertMakerSystem.lua** → `local SmithTongsJawInsertMaker` (vstavki za klešče)

### PRE-FLIGHT CHECK
Vseh 10 datotek: 0 prior commits, absent — brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_bookbinding12_blacksmith12_systems.py`
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

## NASLEDNJI PAKET (v3.11.882–v3.11.891) — VRTNI DODATKI 12 + MLINARSKI DODATKI 12

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 12 (v3.11.882-v3.11.886) — predloga
1. **RoyalGardenSeedTapeMakerSystem.lua** → `local GardenSeedTapeMaker` (trakovi za seme)
2. **RoyalGardenSoilpHTesterMakerSystem.lua** → `local GardenSoilpHTesterMaker` (merilci pH prsti)
3. **RoyalGardenCompostSifterDrumMakerSystem.lua** → `local GardenCompostSifterDrumMaker` (bobni za sitanje komposta)
4. **RoyalGardenPlantRootWateringSpikeMakerSystem.lua** → `local GardenPlantRootWateringSpikeMaker` (bodala za zalivanje korenin)
5. **RoyalGardenFrostClothClipMakerSystem.lua** → `local GardenFrostClothClipMaker` (škarje za mraz za zadrževalci)

### Mlinarski dodatki 12 (v3.11.887-v3.11.891) — predloga
6. **RoyalMillstoneSpindleBearingMakerSystem.lua** → `local MillstoneSpindleBearingMaker` (ležaji za vretena)
7. **RoyalGrainHopperSlideGateMakerSystem.lua** → `local GrainHopperSlideGateMaker` (drsna zaklopnica za lijake)
8. **RoyalMillHopperLevelFloatMakerSystem.lua** → `local MillHopperLevelFloatMaker` (plavci za nivo žita)
9. **RoyalMillstoneDressingChalkMakerSystem.lua** → `local MillstoneDressingChalkMaker` (kreda za označevanje)
10. **RoyalMillSailClothTieDownStrapMakerSystem.lua** → `local MillSailClothTieDownStrapMaker` (pasovi za zategovanje)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 nacrtovanih datotek
2. Ustvari 10 .lua datotek z generatorsko skripto
3. Pozeni sintakticno preverbo
4. Posodobi CHANGELOG.md, README.md badge-je, NEXT_BATCH_HANDOFF.md
5. Git: commit, tag (v3.11.882 do v3.11.891), push
6. Build .love

## SPOROCILO ZA NOVO SEJO

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna razlicica je v3.11.881. Naslednji paket je v3.11.882–v3.11.891 (vrtni dodatki 12 + mlinarski dodatki 12: GardenSeedTapeMaker, GardenSoilpHTesterMaker, GardenCompostSifterDrumMaker, GardenPlantRootWateringSpikeMaker, GardenFrostClothClipMaker, MillstoneSpindleBearingMaker, GrainHopperSlideGateMaker, MillHopperLevelFloatMaker, MillstoneDressingChalkMaker, MillSailClothTieDownStrapMaker). Sledi navodilom v handoff dokumentu. Po koncanem paketu rocno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.882–v3.11.886: vrtni dodatki 12 (GardenSeedTapeMaker, GardenSoilpHTesterMaker, GardenCompostSifterDrumMaker, GardenPlantRootWateringSpikeMaker, GardenFrostClothClipMaker)
- v3.11.887–v3.11.891: mlinarski dodatki 12 (MillstoneSpindleBearingMaker, GrainHopperSlideGateMaker, MillHopperLevelFloatMaker, MillstoneDressingChalkMaker, MillSailClothTieDownStrapMaker)
- v3.11.892–v3.11.896: steklarski dodatki 13 (predlagano)
- v3.11.897–v3.11.901: livarski dodatki 13 (predlagano)
