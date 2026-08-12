# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.821**
- Skupaj Royal sistemov: **909**
- Skupaj Lua datotek: **1558**
- Sintaktična preverba: **1555/1558 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
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

## ZADNJE ZAKLJUČENI PAKET (v3.11.812–v3.11.821) — KNJIGOVEŠKI DODATKI 10 + KOVAŠKI DODATKI 10

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 10 (v3.11.812-v3.11.816)
1. **RoyalBookSpineLiningRollerMakerSystem.lua** → `local BookSpineLiningRollerMaker` (valji za podstavne tkanine)
2. **RoyalBookCoverPasteBrushMakerSystem.lua** → `local BookCoverPasteBrushMaker` (copic za pasto)
3. **RoyalBookSewingBenchHookMakerSystem.lua** → `local BookSewingBenchHookMaker` (kljuke za klopi)
4. **RoyalBookEdgeGiltBurnisherMakerSystem.lua** → `local BookEdgeGiltBurnisherMaker` (poliralci za pozlate)
5. **RoyalBookCoverInlayRouterMakerSystem.lua** → `local BookCoverInlayRouterMaker` (zlebovi za intarzije)

### Kovaški dodatki 10 (v3.11.817-v3.11.821)
6. **RoyalForgeClinkerBreakerMakerSystem.lua** → `local ForgeClinkerBreakerMaker` (lomilci zlindre)
7. **RoyalAnvilSaddleBlockMakerSystem.lua** → `local AnvilSaddleBlockMaker` (bloki za nakovalo)
8. **RoyalForgeTuyereCoolerMakerSystem.lua** → `local ForgeTuyereCoolerMaker` (hladilci za šobe)
9. **RoyalQuenchTankLidGasketMakerSystem.lua** → `local QuenchTankLidGasketMaker` (tesnila za pokrove)
10. **RoyalSmithHammerHandleWedgeMakerSystem.lua** → `local SmithHammerHandleWedgeMaker` (klini za ročaje)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_bookbinding10_blacksmith10_systems.py`
- Sintaktična preverba: `/home/z/my-project/scripts/check_new_systems_syntax.py`
- Vseh 10 novih datotek PASS sintaktične preverbe (lupa load())

## PATTERN ZA VSAK SISTEM

Vsak sistem mora imeti:
- 6 produktov (železni → bronasti → srebrni → pozlačeni → draguljasti → kraljevski suvereni)
- 4 zgradbe (delavnica, hiša, mojstrski atelje, suverena palača)
- Funkcije: `init`, `hireMaker`, `canBuild`, `build`, `getQualityBonus`, `canMake`, `make`, `completeMaking`, `update`, `getStats`
- `_G.NotificationCenter.notify` in `_G.GameEventBus.publish` s pcall
- Vrača lokalno tabelo
- Slovenian product/building names
- **POMEMBNO**: V `completeMaking` uporabljaj `productStock[m.productType]` (z `[m.` pred `productType]`) — ne `productStock.productType]` (to je okvarjena sintaksa)

## NASLEDNJI PAKET (v3.11.822–v3.11.831) — VRTNI DODATKI 10 + MLINARSKI DODATKI 10

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 10 (v3.11.822-v3.11.826) — predloga
1. **RoyalGardenSoilScreenMakerSystem.lua** → `local GardenSoilScreenMaker` (sitana za prst)
2. **RoyalPlantSupportTrellisPanelMakerSystem.lua** → `local PlantSupportTrellisPanelMaker` (paneli za oporo)
3. **RoyalGardenTransplantingDibberMakerSystem.lua** → `local GardenTransplantingDibberMaker` (sadilniki za presajanje)
4. **RoyalGardenIrrigationTimerMakerSystem.lua** → `local GardenIrrigationTimerMaker` (časovniki za namakanje)
5. **RoyalGardenCompostAeratorSpikeMakerSystem.lua** → `local GardenCompostAeratorSpikeMaker` (bodala za kompost)

### Mlinarski dodatki 10 (v3.11.827-v3.11.831) — predloga
6. **RoyalMillstoneCraneWinchMakerSystem.lua** → `local MillstoneCraneWinchMaker` (vitice za dvig kamnov)
7. **RoyalGrainSamplerProbeMakerSystem.lua** → `local GrainSamplerProbeMaker` (sonde za vzorčenje)
8. **RoyalMillHopperVibratorSpringMakerSystem.lua** → `local MillHopperVibratorSpringMaker` (vzmeti za tresalce)
9. **RoyalMillstoneDressingCompassMakerSystem.lua** → `local MillstoneDressingCompassMaker` (šestili za oblikovanje)
10. **RoyalMillSailClothReinforcementStripMakerSystem.lua** → `local MillSailClothReinforcementStripMaker` (trakovi za ojačitev)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalGardenSoilScreenMakerSystem.lua RoyalPlantSupportTrellisPanelMakerSystem.lua RoyalGardenTransplantingDibberMakerSystem.lua RoyalGardenIrrigationTimerMakerSystem.lua RoyalGardenCompostAeratorSpikeMakerSystem.lua RoyalMillstoneCraneWinchMakerSystem.lua RoyalGrainSamplerProbeMakerSystem.lua RoyalMillHopperVibratorSpringMakerSystem.lua RoyalMillstoneDressingCompassMakerSystem.lua RoyalMillSailClothReinforcementStripMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.822 do v3.11.831 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.821 → version-3.11.831
   - syntax-1555%2F1558 → syntax-1565%2F1568
   - Royal%20systems-909 → Royal%20systems-919
   - Lua%20files-1558 → Lua%20files-1568
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.822 do v3.11.831), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.831.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_bookbinding10_blacksmith10_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_garden10_milling10_systems.py`
2. Spremeni `BOOKBINDING10_SYSTEMS` in `BLACKSMITH10_SYSTEMS` sezname v `GARDEN10_SYSTEMS` in `MILLING10_SYSTEMS`
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_garden10_milling10_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py`

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.821. Naslednji paket je v3.11.822–v3.11.831 (vrtni dodatki 10 + mlinarski dodatki 10: GardenSoilScreenMaker, PlantSupportTrellisPanelMaker, GardenTransplantingDibberMaker, GardenIrrigationTimerMaker, GardenCompostAeratorSpikeMaker, MillstoneCraneWinchMaker, GrainSamplerProbeMaker, MillHopperVibratorSpringMaker, MillstoneDressingCompassMaker, MillSailClothReinforcementStripMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.822–v3.11.826: vrtni dodatki 10 (GardenSoilScreenMaker, PlantSupportTrellisPanelMaker, GardenTransplantingDibberMaker, GardenIrrigationTimerMaker, GardenCompostAeratorSpikeMaker)
- v3.11.827–v3.11.831: mlinarski dodatki 10 (MillstoneCraneWinchMaker, GrainSamplerProbeMaker, MillHopperVibratorSpringMaker, MillstoneDressingCompassMaker, MillSailClothReinforcementStripMaker)
- v3.11.832–v3.11.836: steklarski dodatki 11 (predlagano)
- v3.11.837–v3.11.841: livarski dodatki 11 (predlagano)
