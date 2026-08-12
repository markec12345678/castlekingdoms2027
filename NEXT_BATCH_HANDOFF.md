# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.831**
- Skupaj Royal sistemov: **919**
- Skupaj Lua datotek: **1568**
- Sintaktična preverba: **1565/1568 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
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

## ZADNJE ZAKLJUČENI PAKET (v3.11.822–v3.11.831) — VRTNI DODATKI 10 + MLINARSKI DODATKI 10

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 10 (v3.11.822-v3.11.826)
1. **RoyalGardenSoilScreenMakerSystem.lua** → `local GardenSoilScreenMaker` (sitane za prst)
2. **RoyalPlantSupportTrellisPanelMakerSystem.lua** → `local PlantSupportTrellisPanelMaker` (paneli za oporo)
3. **RoyalGardenTransplantingDibberMakerSystem.lua** → `local GardenTransplantingDibberMaker` (sadilniki za presajanje)
4. **RoyalGardenIrrigationTimerMakerSystem.lua** → `local GardenIrrigationTimerMaker` (casovniki za namakanje)
5. **RoyalGardenCompostAeratorSpikeMakerSystem.lua** → `local GardenCompostAeratorSpikeMaker` (bodala za kompost)

### Mlinarski dodatki 10 (v3.11.827-v3.11.831)
6. **RoyalMillstoneCraneWinchMakerSystem.lua** → `local MillstoneCraneWinchMaker` (vitki za dvig kamnov)
7. **RoyalGrainSamplerProbeMakerSystem.lua** → `local GrainSamplerProbeMaker` (sonde za vzorcenje)
8. **RoyalMillHopperVibratorSpringMakerSystem.lua** → `local MillHopperVibratorSpringMaker` (vzmeti za tresalec)
9. **RoyalMillstoneDressingCompassMakerSystem.lua** → `local MillstoneDressingCompassMaker` (sestila za oblikovanje)
10. **RoyalMillSailClothReinforcementStripMakerSystem.lua** → `local MillSailClothReinforcementStripMaker` (trakovi za ojacitev)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_garden10_milling10_systems.py`
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

## NASLEDNJI PAKET (v3.11.832–v3.11.841) — STEKLARSKI DODATKI 11 + LIVARSKI DODATKI 11

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 11 (v3.11.832-v3.11.836) — predloga
1. **RoyalGlassPipeShearsMakerSystem.lua** → `local GlassPipeShearsMaker` (skarde za pihanje)
2. **RoyalGlassKilnSightingPortCoverMakerSystem.lua** → `local GlassKilnSightingPortCoverMaker` (pokrovi za opazovalne odprtine)
3. **RoyalGlassColorantMortarPestleMakerSystem.lua** → `local GlassColorantMortarPestleMaker` (psti za barve)
4. **RoyalGlassAnnealingOvenDoorWheelMakerSystem.lua** → `local GlassAnnealingOvenDoorWheelMaker` (kolesa za vrata peči)
5. **RoyalGlassEngravingLatheChuckMakerSystem.lua** → `local GlassEngravingLatheChuckMaker` (stiskalniki za stružnico)

### Livarski dodatki 11 (v3.11.837-v3.11.841) — predloga
6. **RoyalMoldFlowTesterMakerSystem.lua** → `local MoldFlowTesterMaker` (preizkuševalci pretoka)
7. **RoyalPouringCrucibleDrierMakerSystem.lua** → `local PouringCrucibleDrierMaker` (sušilci za lončne peči)
8. **RoyalSandMullerBladeMakerSystem.lua** → `local SandMullerBladeMaker` (lopice mešalca peska)
9. **RoyalCoreGasVentPinMakerSystem.lua** → `local CoreGasVentPinMaker` (bolti za odzracevanje jedrc)
10. **RoyalCastingLadlePreheatBurnerMakerSystem.lua** → `local CastingLadlePreheatBurnerMaker` (gorilniki za predgrevanje)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 nacrtovanih datotek:
   ```bash
   for f in RoyalGlassPipeShearsMakerSystem.lua RoyalGlassKilnSightingPortCoverMakerSystem.lua RoyalGlassColorantMortarPestleMakerSystem.lua RoyalGlassAnnealingOvenDoorWheelMakerSystem.lua RoyalGlassEngravingLatheChuckMakerSystem.lua RoyalMoldFlowTesterMakerSystem.lua RoyalPouringCrucibleDrierMakerSystem.lua RoyalSandMullerBladeMakerSystem.lua RoyalCoreGasVentPinMakerSystem.lua RoyalCastingLadlePreheatBurnerMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Ce katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Pozeni sintakticno preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.832 do v3.11.841 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.831 → version-3.11.841
   - syntax-1565%2F1568 → syntax-1575%2F1578
   - Royal%20systems-919 → Royal%20systems-929
   - Lua%20files-1568 → Lua%20files-1578
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.832 do v3.11.841), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.841.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_garden10_milling10_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_glass11_foundry11_systems.py`
2. Spremeni `GARDEN10_SYSTEMS` in `MILLING10_SYSTEMS` sezname v `GLASS11_SYSTEMS` in `FOUNDRY11_SYSTEMS`
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Pozeni: `python3 /home/z/my-project/scripts/generate_glass11_foundry11_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py`

## SPOROCILO ZA NOVO SEJO

Ko zacnes novo sejo, poslji to sporocilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna razlicica je v3.11.831. Naslednji paket je v3.11.832–v3.11.841 (steklarski dodatki 11 + livarski dodatki 11: GlassPipeShearsMaker, GlassKilnSightingPortCoverMaker, GlassColorantMortarPestleMaker, GlassAnnealingOvenDoorWheelMaker, GlassEngravingLatheChuckMaker, MoldFlowTesterMaker, PouringCrucibleDrierMaker, SandMullerBladeMaker, CoreGasVentPinMaker, CastingLadlePreheatBurnerMaker). Sledi navodilom v handoff dokumentu. Po koncanem paketu rocno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.832–v3.11.836: steklarski dodatki 11 (GlassPipeShearsMaker, GlassKilnSightingPortCoverMaker, GlassColorantMortarPestleMaker, GlassAnnealingOvenDoorWheelMaker, GlassEngravingLatheChuckMaker)
- v3.11.837–v3.11.841: livarski dodatki 11 (MoldFlowTesterMaker, PouringCrucibleDrierMaker, SandMullerBladeMaker, CoreGasVentPinMaker, CastingLadlePreheatBurnerMaker)
- v3.11.842–v3.11.846: knjigoveski dodatki 11 (predlagano)
- v3.11.847–v3.11.851: kovaski dodatki 11 (predlagano)
