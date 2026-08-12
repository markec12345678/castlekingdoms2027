# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.771**
- Skupaj Royal sistemov: **859**
- Skupaj Lua datotek: **1508**
- Sintaktična preverba: **1505/1508 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
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

## ZADNJE ZAKLJUČENI PAKET (v3.11.762–v3.11.771) — VRTNI DODATKI 8 + MLINARSKI DODATKI 8

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 8 (v3.11.762-v3.11.766)
1. **RoyalGardenFurrowMakerSystem.lua** → `local GardenFurrowMaker` (brazdarji za gredice)
2. **RoyalPlantTyingTwistMakerSystem.lua** → `local PlantTyingTwistMaker` (veze za rastline)
3. **RoyalGardenMulchForkMakerSystem.lua** → `local GardenMulchForkMaker` (vilice za zastirko)
4. **RoyalGardenSeedDibberPlateMakerSystem.lua** → `local GardenSeedDibberPlateMaker` (plošče za seme)
5. **RoyalGardenBowlSprayerMakerSystem.lua** → `local GardenBowlSprayerMaker` (skledaste škropilnice)

### Mlinarski dodatki 8 (v3.11.767-v3.11.771)
6. **RoyalMillstoneTenteringScrewMakerSystem.lua** → `local MillstoneTenteringScrewMaker` (vijačni napenjalci)
7. **RoyalGrainMoistureMeterMakerSystem.lua** → `local GrainMoistureMeterMaker` (merilci vlage žita)
8. **RoyalMillHopperVibratorMakerSystem.lua** → `local MillHopperVibratorMaker` (vibratorji za lijak)
9. **RoyalMillstoneDressingHammerMakerSystem.lua** → `local MillstoneDressingHammerMaker` (kladiva za oblikovanje)
10. **RoyalMillSailClothTensionerMakerSystem.lua** → `local MillSailClothTensionerMaker` (napenjalci tkanine)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_garden8_milling8_systems.py`
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

## NASLEDNJI PAKET (v3.11.772–v3.11.781) — STEKLARSKI DODATKI 9 + LIVARSKI DODATKI 9

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 9 (v3.11.772-v3.11.776) — predloga
1. **RoyalGlassGatheringIronMakerSystem.lua** → `local GlassGatheringIronMaker` (zbiralne železne palice)
2. **RoyalGlassKilnDoorChainMakerSystem.lua** → `local GlassKilnDoorChainMaker` (verige za vrata peči)
3. **RoyalGlassColorantMullerMakerSystem.lua** → `local GlassColorantMullerMaker` (možnarji za barve)
4. **RoyalGlassAnnealingForkMakerSystem.lua** → `local GlassAnnealingForkMaker` (vilice za ohlajanje)
5. **RoyalGlassEngravingDiamondPointMakerSystem.lua** → `local GlassEngravingDiamondPointMaker` (diamantne konice za rezbarjenje)

### Livarski dodatki 9 (v3.11.777-v3.11.781) — predloga
6. **RoyalMoldCoatingRollerMakerSystem.lua** → `local MoldCoatingRollerMaker` (valji za premaze)
7. **RoyalPouringLadleLinerMakerSystem.lua** → `local PouringLadleLinerMaker` (obloge za zajemalke)
8. **RoyalSandReclaimerMakerSystem.lua** → `local SandReclaimerMaker` (obnavljalci peska)
9. **RoyalCoreWashingDipMakerSystem.lua** → `local CoreWashingDipMaker` (kopeli za pranje jedrc)
10. **RoyalCastingLadleSkimmerHookMakerSystem.lua** → `local CastingLadleSkimmerHookMaker` (kljuki za strgalce)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalGlassGatheringIronMakerSystem.lua RoyalGlassKilnDoorChainMakerSystem.lua RoyalGlassColorantMullerMakerSystem.lua RoyalGlassAnnealingForkMakerSystem.lua RoyalGlassEngravingDiamondPointMakerSystem.lua RoyalMoldCoatingRollerMakerSystem.lua RoyalPouringLadleLinerMakerSystem.lua RoyalSandReclaimerMakerSystem.lua RoyalCoreWashingDipMakerSystem.lua RoyalCastingLadleSkimmerHookMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.772 do v3.11.781 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.771 → version-3.11.781
   - syntax-1505%2F1508 → syntax-1515%2F1518
   - Royal%20systems-859 → Royal%20systems-869
   - Lua%20files-1508 → Lua%20files-1518
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.772 do v3.11.781), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.781.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_garden8_milling8_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_glass9_foundry9_systems.py`
2. Spremeni `GARDEN8_SYSTEMS` in `MILLING8_SYSTEMS` sezname v `GLASS9_SYSTEMS` in `FOUNDRY9_SYSTEMS`
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_glass9_foundry9_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py`

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.771. Naslednji paket je v3.11.772–v3.11.781 (steklarski dodatki 9 + livarski dodatki 9: GlassGatheringIronMaker, GlassKilnDoorChainMaker, GlassColorantMullerMaker, GlassAnnealingForkMaker, GlassEngravingDiamondPointMaker, MoldCoatingRollerMaker, PouringLadleLinerMaker, SandReclaimerMaker, CoreWashingDipMaker, CastingLadleSkimmerHookMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.772–v3.11.776: steklarski dodatki 9 (GlassGatheringIronMaker, GlassKilnDoorChainMaker, GlassColorantMullerMaker, GlassAnnealingForkMaker, GlassEngravingDiamondPointMaker)
- v3.11.777–v3.11.781: livarski dodatki 9 (MoldCoatingRollerMaker, PouringLadleLinerMaker, SandReclaimerMaker, CoreWashingDipMaker, CastingLadleSkimmerHookMaker)
- v3.11.782–v3.11.786: knjigoveški dodatki 9 (predlagano)
- v3.11.787–v3.11.791: kovaški dodatki 9 (predlagano)
