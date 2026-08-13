# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.901**
- Skupaj Royal sistemov: **987**
- Skupaj Lua datotek: **1638**
- Sintaktična preverba: **1635/1638 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
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

## ZADNJE ZAKLJUČENI PAKET (v3.11.892–v3.11.901) — STEKLARSKI DODATKI 13 + LIVARSKI DODATKI 13

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 13 (v3.11.892-v3.11.896)
1. **RoyalGlassMoltenGlassSkimLadleMakerSystem.lua** → `local GlassMoltenGlassSkimLadleMaker` (zajemalke za strgalce)
2. **RoyalGlassKilnSootScraperMakerSystem.lua** → `local GlassKilnSootScraperMaker` (strgalci za sajne)
3. **RoyalGlassColorantSievingClothMakerSystem.lua** → `local GlassColorantSievingClothMaker` (krpe za sitanje)
4. **RoyalGlassAnnealingOvenThermocoupleMakerSystem.lua** → `local GlassAnnealingOvenThermocoupleMaker` (termoelementi)
5. **RoyalGlassEngravingWheelBearingMakerSystem.lua** → `local GlassEngravingWheelBearingMaker` (lezaji za kolesa)

### Livarski dodatki 13 (v3.11.897-v3.11.901)
6. **RoyalMoldCoatBrushSpinnerMakerSystem.lua** → `local MoldCoatBrushSpinnerMaker` (vrtilci za copice)
7. **RoyalPouringLadleSpoutLinerMakerSystem.lua** → `local PouringLadleSpoutLinerMaker` (obloge za izlive)
8. **RoyalSandTestCupMakerSystem.lua** → `local SandTestCupMaker` (skodelice za testiranje)
9. **RoyalCoreGasEscapeChannelMakerSystem.lua** → `local CoreGasEscapeChannelMaker` (kanali za plin)
10. **RoyalCastingLadlePreheatStandMakerSystem.lua** → `local CastingLadlePreheatStandMaker` (stojala za predgrevanje)

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
1. **RoyalBookSpineRibbonMarkerMakerSystem.lua** → `local BookSpineRibbonMarkerMaker` (oznake z trakovi za hrbte)
2. **RoyalBookCoverPastePotLidMakerSystem.lua** → `local BookCoverPastePotLidMaker` (pokrovi za lepilne lončke)
3. **RoyalBookSewingCordTensionerMakerSystem.lua** → `local BookSewingCordTensionerMaker` (napenjalci za šivalne vrvice)
4. **RoyalBookEdgeGiltSizeDryingRackMakerSystem.lua** → `local BookEdgeGiltSizeDryingRackMaker` (police za sušenje pozlate)
5. **RoyalBookCoverBoardGrooveMakerSystem.lua** → `local BookCoverBoardGrooveMaker` (žlebovi za vezave)

### Kovaški dodatki 13 (v3.11.907-v3.11.911) — predloga
6. **RoyalForgeCoalChuteMakerSystem.lua** → `local ForgeCoalChuteMaker` (žlebovi za oglje)
7. **RoyalAnvilBasePlateMakerSystem.lua** → `local AnvilBasePlateMaker` (osnovne plošče za nakovalo)
8. **RoyalForgeDraftInducerMakerSystem.lua** → `local ForgeDraftInducerMaker` (vlečniki za vlek)
9. **RoyalQuenchTankThermometerMakerSystem.lua** → `local QuenchTankThermometerMaker` (termometri za kadi)
10. **RoyalSmithHammerHandleFinisherMakerSystem.lua** → `local SmithHammerHandleFinisherMaker` (končalci ročajev)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 nacrtovanih datotek
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
