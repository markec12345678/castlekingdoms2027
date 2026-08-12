# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.851**
- Skupaj Royal sistemov: **939**
- Skupaj Lua datotek: **1588**
- Sintaktična preverba: **1585/1588 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
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

## ZADNJE ZAKLJUČENI PAKET (v3.11.842–v3.11.851) — KNJIGOVEŠKI DODATKI 11 + KOVAŠKI DODATKI 11

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 11 (v3.11.842-v3.11.846)
1. **RoyalBookSpineGiltSizeGaugeMakerSystem.lua** → `local BookSpineGiltSizeGaugeMaker` (merilci za pozlate)
2. **RoyalBookCoverPasteRollerMakerSystem.lua** → `local BookCoverPasteRollerMaker` (valji za pasto)
3. **RoyalBookSewingCordSpoolMakerSystem.lua** → `local BookSewingCordSpoolMaker` (vitice za vrvice)
4. **RoyalBookEdgeGiltSizeApplicatorMakerSystem.lua** → `local BookEdgeGiltSizeApplicatorMaker` (nanašalci za pozlate)
5. **RoyalBookCoverBoardCornerMiterMakerSystem.lua** → `local BookCoverBoardCornerMiterMaker` (koti za vezave)

### Kovaški dodatki 11 (v3.11.847-v3.11.851)
6. **RoyalForgeAshGateValveMakerSystem.lua** → `local ForgeAshGateValveMaker` (zaklopke za pepel)
7. **RoyalAnvilStumpWedgeMakerSystem.lua** → `local AnvilStumpWedgeMaker` (klini za panj)
8. **RoyalForgeChimneyCowlMakerSystem.lua** → `local ForgeChimneyCowlMaker` (kapice za dimnik)
9. **RoyalQuenchOilFilterMakerSystem.lua** → `local QuenchOilFilterMaker` (filtri za olje)
10. **RoyalSmithHammerFacePolisherMakerSystem.lua** → `local SmithHammerFacePolisherMaker` (poliralci za kladiva)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_bookbinding11_blacksmith11_systems.py`
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

## NASLEDNJI PAKET (v3.11.852–v3.11.861) — VRTNI DODATKI 11 + MLINARSKI DODATKI 11

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 11 (v3.11.852-v3.11.856) — predloga
1. **RoyalGardenPlantTieCutterMakerSystem.lua** → `local GardenPlantTieCutterMaker` (škarje za veze)
2. **RoyalGardenSoilMoistureMeterMakerSystem.lua** → `local GardenSoilMoistureMeterMaker` (merilci vlage prsti)
3. **RoyalGardenCompostThermometerProbeMakerSystem.lua** → `local GardenCompostThermometerProbeMaker` (sonde za kompost)
4. **RoyalGardenSeedPacketSealerMakerSystem.lua** → `local GardenSeedPacketSealerMaker` (zatesnjevalci za semena)
5. **RoyalGardenPlantLabelEmbosserMakerSystem.lua** → `local GardenPlantLabelEmbosserMaker` (žigosalci za oznake)

### Mlinarski dodatki 11 (v3.11.857-v3.11.861) — predloga
6. **RoyalMillstoneBalanceWeightMakerSystem.lua** → `local MillstoneBalanceWeightMaker` (uteži za uravnoteženje)
7. **RoyalGrainHopperLevelSensorMakerSystem.lua** → `local GrainHopperLevelSensorMaker` (senzorji nivoja žita)
8. **RoyalMillHopperLubricatorMakerSystem.lua** → `local MillHopperLubricatorMaker` (mazalci za lijak)
9. **RoyalMillstoneGrooveDepthGaugeMakerSystem.lua** → `local MillstoneGrooveDepthGaugeMaker` (merilci globine utorov)
10. **RoyalMillSailClothGrommetInstallerMakerSystem.lua** → `local MillSailClothGrommetInstallerMaker` (nameščalci obročev)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 nacrtovanih datotek:
   ```bash
   for f in RoyalGardenPlantTieCutterMakerSystem.lua RoyalGardenSoilMoistureMeterMakerSystem.lua RoyalGardenCompostThermometerProbeMakerSystem.lua RoyalGardenSeedPacketSealerMakerSystem.lua RoyalGardenPlantLabelEmbosserMakerSystem.lua RoyalMillstoneBalanceWeightMakerSystem.lua RoyalGrainHopperLevelSensorMakerSystem.lua RoyalMillHopperLubricatorMakerSystem.lua RoyalMillstoneGrooveDepthGaugeMakerSystem.lua RoyalMillSailClothGrommetInstallerMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Ce katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Pozeni sintakticno preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.852 do v3.11.861 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.851 → version-3.11.861
   - syntax-1585%2F1588 → syntax-1595%2F1598
   - Royal%20systems-939 → Royal%20systems-949
   - Lua%20files-1588 → Lua%20files-1598
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.852 do v3.11.861), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.861.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_bookbinding11_blacksmith11_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_garden11_milling11_systems.py`
2. Spremeni `BOOKBINDING11_SYSTEMS` in `BLACKSMITH11_SYSTEMS` sezname v `GARDEN11_SYSTEMS` in `MILLING11_SYSTEMS`
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Pozeni: `python3 /home/z/my-project/scripts/generate_garden11_milling11_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py`

## SPOROCILO ZA NOVO SEJO

Ko zacnes novo sejo, poslji to sporocilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna razlicica je v3.11.851. Naslednji paket je v3.11.852–v3.11.861 (vrtni dodatki 11 + mlinarski dodatki 11: GardenPlantTieCutterMaker, GardenSoilMoistureMeterMaker, GardenCompostThermometerProbeMaker, GardenSeedPacketSealerMaker, GardenPlantLabelEmbosserMaker, MillstoneBalanceWeightMaker, GrainHopperLevelSensorMaker, MillHopperLubricatorMaker, MillstoneGrooveDepthGaugeMaker, MillSailClothGrommetInstallerMaker). Sledi navodilom v handoff dokumentu. Po koncanem paketu rocno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.852–v3.11.856: vrtni dodatki 11 (GardenPlantTieCutterMaker, GardenSoilMoistureMeterMaker, GardenCompostThermometerProbeMaker, GardenSeedPacketSealerMaker, GardenPlantLabelEmbosserMaker)
- v3.11.857–v3.11.861: mlinarski dodatki 11 (MillstoneBalanceWeightMaker, GrainHopperLevelSensorMaker, MillHopperLubricatorMaker, MillstoneGrooveDepthGaugeMaker, MillSailClothGrommetInstallerMaker)
- v3.11.862–v3.11.866: steklarski dodatki 12 (predlagano)
- v3.11.867–v3.11.871: livarski dodatki 12 (predlagano)
