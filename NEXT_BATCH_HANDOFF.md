# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.891**
- Skupaj Royal sistemov: **977**
- Skupaj Lua datotek: **1628**
- Sintaktična preverba: **1625/1628 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
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

## ZADNJE ZAKLJUČENI PAKET (v3.11.882–v3.11.891) — VRTNI DODATKI 12 + MLINARSKI DODATKI 12

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 12 (v3.11.882-v3.11.886)
1. **RoyalGardenSeedTapeMakerSystem.lua** → `local GardenSeedTapeMaker` (traki za seme)
2. **RoyalGardenSoilpHTesterMakerSystem.lua** → `local GardenSoilpHTesterMaker` (merilci pH)
3. **RoyalGardenCompostSifterDrumMakerSystem.lua** → `local GardenCompostSifterDrumMaker` (bobni za kompost)
4. **RoyalGardenPlantRootWateringSpikeMakerSystem.lua** → `local GardenPlantRootWateringSpikeMaker` (bodala za korenine)
5. **RoyalGardenFrostClothClipMakerSystem.lua** → `local GardenFrostClothClipMaker` (scipalke za mraz)

### Mlinarski dodatki 12 (v3.11.887-v3.11.891)
6. **RoyalMillstoneSpindleBearingMakerSystem.lua** → `local MillstoneSpindleBearingMaker` (lezaji za vretena)
7. **RoyalGrainHopperSlideGateMakerSystem.lua** → `local GrainHopperSlideGateMaker` (drsne zaklopnice)
8. **RoyalMillHopperLevelFloatMakerSystem.lua** → `local MillHopperLevelFloatMaker` (plavci za nivo)
9. **RoyalMillstoneDressingChalkMakerSystem.lua** → `local MillstoneDressingChalkMaker` (kreda za oznake)
10. **RoyalMillSailClothTieDownStrapMakerSystem.lua** → `local MillSailClothTieDownStrapMaker` (pasovi za zateg)

### PRE-FLIGHT CHECK
Vseh 10 datotek: 0 prior commits, absent — brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_garden12_milling12_systems.py`
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

## NASLEDNJI PAKET (v3.11.892–v3.11.901) — STEKLARSKI DODATKI 13 + LIVARSKI DODATKI 13

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 13 (v3.11.892-v3.11.896) — predloga
1. **RoyalGlassMoltenGlassSkimLadleMakerSystem.lua** → `local GlassMoltenGlassSkimLadleMaker` (zajemalke za strgalce taline)
2. **RoyalGlassKilnSootScraperMakerSystem.lua** → `local GlassKilnSootScraperMaker` (strgalci za sajne)
3. **RoyalGlassColorantSievingClothMakerSystem.lua** → `local GlassColorantSievingClothMaker` (krpe za sitanje barv)
4. **RoyalGlassAnnealingOvenThermocoupleMakerSystem.lua** → `local GlassAnnealingOvenThermocoupleMaker` (termoelementi za peči)
5. **RoyalGlassEngravingWheelBearingMakerSystem.lua** → `local GlassEngravingWheelBearingMaker` (ležaji za rezbarska kolesa)

### Livarski dodatki 13 (v3.11.897-v3.11.901) — predloga
6. **RoyalMoldCoatBrushSpinnerMakerSystem.lua** → `local MoldCoatBrushSpinnerMaker` (vrtilci za čopiče premaza)
7. **RoyalPouringLadleSpoutLinerMakerSystem.lua** → `local PouringLadleSpoutLinerMaker` (obloge za izlive)
8. **RoyalSandTestCupMakerSystem.lua** → `local SandTestCupMaker` (skodelice za testiranje peska)
9. **RoyalCoreGasEscapeChannelMakerSystem.lua** → `local CoreGasEscapeChannelMaker` (kanali za plin jedrc)
10. **RoyalCastingLadlePreheatStandMakerSystem.lua** → `local CastingLadlePreheatStandMaker` (stojala za predgrevanje)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 nacrtovanih datotek
2. Ustvari 10 .lua datotek z generatorsko skripto
3. Pozeni sintakticno preverbo
4. Posodobi CHANGELOG.md, README.md badge-je, NEXT_BATCH_HANDOFF.md
5. Git: commit, tag (v3.11.892 do v3.11.901), push
6. Build .love

## SPOROCILO ZA NOVO SEJO

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna razlicica je v3.11.891. Naslednji paket je v3.11.892–v3.11.901 (steklarski dodatki 13 + livarski dodatki 13: GlassMoltenGlassSkimLadleMaker, GlassKilnSootScraperMaker, GlassColorantSievingClothMaker, GlassAnnealingOvenThermocoupleMaker, GlassEngravingWheelBearingMaker, MoldCoatBrushSpinnerMaker, PouringLadleSpoutLinerMaker, SandTestCupMaker, CoreGasEscapeChannelMaker, CastingLadlePreheatStandMaker). Sledi navodilom v handoff dokumentu. Po koncanem paketu rocno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.892–v3.11.896: steklarski dodatki 13 (GlassMoltenGlassSkimLadleMaker, GlassKilnSootScraperMaker, GlassColorantSievingClothMaker, GlassAnnealingOvenThermocoupleMaker, GlassEngravingWheelBearingMaker)
- v3.11.897–v3.11.901: livarski dodatki 13 (MoldCoatBrushSpinnerMaker, PouringLadleSpoutLinerMaker, SandTestCupMaker, CoreGasEscapeChannelMaker, CastingLadlePreheatStandMaker)
- v3.11.902–v3.11.906: knjigoveski dodatki 13 (predlagano)
- v3.11.907–v3.11.911: kovaski dodatki 13 (predlagano)
