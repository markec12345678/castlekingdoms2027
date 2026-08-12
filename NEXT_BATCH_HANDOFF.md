# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.761**
- Skupaj Royal sistemov: **849**
- Skupaj Lua datotek: **1498**
- Sintaktična preverba: **1495/1498 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
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

## ZADNJE ZAKLJUČENI PAKET (v3.11.752–v3.11.761) — KNJIGOVEŠKI DODATKI 8 + KOVAŠKI DODATKI 8

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 8 (v3.11.752-v3.11.756)
1. **RoyalBookSpineLiningClothMakerSystem.lua** → `local BookSpineLiningClothMaker` (podstavne tkanine)
2. **RoyalBookCoverGaugeMakerSystem.lua** → `local BookCoverGaugeMaker` (merilci za naslovnice)
3. **RoyalBookSewingFrameToggleMakerSystem.lua** → `local BookSewingFrameToggleMaker` (zatiči za okvire)
4. **RoyalBookEdgeColoringSpongeMakerSystem.lua** → `local BookEdgeColoringSpongeMaker` (gobe za barvanje)
5. **RoyalBookCoverBoardShearsMakerSystem.lua** → `local BookCoverBoardShearsMaker` (škarde za vezave)

### Kovaški dodatki 8 (v3.11.757-v3.11.761)
6. **RoyalForgeBellowsValveMakerSystem.lua** → `local ForgeBellowsValveMaker` (zaklopke za meh)
7. **RoyalAnvilFaceHardenerMakerSystem.lua** → `local AnvilFaceHardenerMaker` (utrjevalci nakovala)
8. **RoyalForgeBrickMakerSystem.lua** → `local ForgeBrickMaker` (opeke za peč)
9. **RoyalQuenchTankStirrerMakerSystem.lua** → `local QuenchTankStirrerMaker` (mešala za kadi)
10. **RoyalSmithTongsRingMakerSystem.lua** → `local SmithTongsRingMaker` (obroči za klešče)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_bookbinding8_blacksmith8_systems.py`
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

## NASLEDNJI PAKET (v3.11.762–v3.11.771) — VRTNI DODATKI 8 + MLINARSKI DODATKI 8

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 8 (v3.11.762-v3.11.766) — predloga
1. **RoyalGardenFurrowMakerSystem.lua** → `local GardenFurrowMaker` (brazdari za gredice)
2. **RoyalPlantTyingTwistMakerSystem.lua** → `local PlantTyingTwistMaker` (veza za rastline)
3. **RoyalGardenMulchForkMakerSystem.lua** → `local GardenMulchForkMaker` (vilice za zastirko)
4. **RoyalGardenSeedDibberPlateMakerSystem.lua** → `local GardenSeedDibberPlateMaker` (plošče za seme)
5. **RoyalGardenBowlSprayerMakerSystem.lua** → `local GardenBowlSprayerMaker` (skledaste škropilnice)

### Mlinarski dodatki 8 (v3.11.767-v3.11.771) — predloga
6. **RoyalMillstoneTenteringScrewMakerSystem.lua** → `local MillstoneTenteringScrewMaker` (vijačni napenjalci)
7. **RoyalGrainMoistureMeterMakerSystem.lua** → `local GrainMoistureMeterMaker` (merilci vlage žita)
8. **RoyalMillHopperVibratorMakerSystem.lua** → `local MillHopperVibratorMaker` (vibratorji za lijak)
9. **RoyalMillstoneDressingHammerMakerSystem.lua** → `local MillstoneDressingHammerMaker` (kladiva za oblikovanje)
10. **RoyalMillSailClothTensionerMakerSystem.lua** → `local MillSailClothTensionerMaker` (napenjalci jedrne tkanine)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalGardenFurrowMakerSystem.lua RoyalPlantTyingTwistMakerSystem.lua RoyalGardenMulchForkMakerSystem.lua RoyalGardenSeedDibberPlateMakerSystem.lua RoyalGardenBowlSprayerMakerSystem.lua RoyalMillstoneTenteringScrewMakerSystem.lua RoyalGrainMoistureMeterMakerSystem.lua RoyalMillHopperVibratorMakerSystem.lua RoyalMillstoneDressingHammerMakerSystem.lua RoyalMillSailClothTensionerMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.762 do v3.11.771 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.761 → version-3.11.771
   - syntax-1495%2F1498 → syntax-1505%2F1508
   - Royal%20systems-849 → Royal%20systems-859
   - Lua%20files-1498 → Lua%20files-1508
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.762 do v3.11.771), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.771.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_bookbinding8_blacksmith8_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_garden8_milling8_systems.py`
2. Spremeni `BOOKBINDING8_SYSTEMS` in `BLACKSMITH8_SYSTEMS` sezname v `GARDEN8_SYSTEMS` in `MILLING8_SYSTEMS`
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_garden8_milling8_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py`

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.761. Naslednji paket je v3.11.762–v3.11.771 (vrtni dodatki 8 + mlinarski dodatki 8: GardenFurrowMaker, PlantTyingTwistMaker, GardenMulchForkMaker, GardenSeedDibberPlateMaker, GardenBowlSprayerMaker, MillstoneTenteringScrewMaker, GrainMoistureMeterMaker, MillHopperVibratorMaker, MillstoneDressingHammerMaker, MillSailClothTensionerMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.762–v3.11.766: vrtni dodatki 8 (GardenFurrowMaker, PlantTyingTwistMaker, GardenMulchForkMaker, GardenSeedDibberPlateMaker, GardenBowlSprayerMaker)
- v3.11.767–v3.11.771: mlinarski dodatki 8 (MillstoneTenteringScrewMaker, GrainMoistureMeterMaker, MillHopperVibratorMaker, MillstoneDressingHammerMaker, MillSailClothTensionerMaker)
- v3.11.772–v3.11.776: steklarski dodatki 9 (predlagano)
- v3.11.777–v3.11.781: livarski dodatki 9 (predlagano)
