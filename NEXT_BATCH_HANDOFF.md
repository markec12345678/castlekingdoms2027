# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.801**
- Skupaj Royal sistemov: **889**
- Skupaj Lua datotek: **1538**
- Sintaktična preverba: **1535/1538 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
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

## ZADNJE ZAKLJUČENI PAKET (v3.11.792–v3.11.801) — VRTNI DODATKI 9 + MLINARSKI DODATKI 9

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 9 (v3.11.792-v3.11.796)
1. **RoyalGardenPotBrushMakerSystem.lua** → `local GardenPotBrushMaker` (ščetke za lonce)
2. **RoyalPlantRootPrunerMakerSystem.lua** → `local PlantRootPrunerMaker` (škarje za korenine)
3. **RoyalGardenTrowelHolsterMakerSystem.lua** → `local GardenTrowelHolsterMaker` (nositelji za lopatko)
4. **RoyalGardenSoilThermometerMakerSystem.lua** → `local GardenSoilThermometerMaker` (termometri za prst)
5. **RoyalGardenPlantDibberDepthMarkMakerSystem.lua** → `local GardenPlantDibberDepthMarkMaker` (oznake globine)

### Mlinarski dodatki 9 (v3.11.797-v3.11.801)
6. **RoyalMillstoneGrainFeedChuteMakerSystem.lua** → `local MillstoneGrainFeedChuteMaker` (žlebovi za žito)
7. **RoyalGrainHopperAugerMakerSystem.lua** → `local GrainHopperAugerMaker` (spirale za lijake)
8. **RoyalMillHopperSightGlassMakerSystem.lua** → `local MillHopperSightGlassMaker` (okence za opazovanje)
9. **RoyalMillstoneDressingPickMakerSystem.lua** → `local MillstoneDressingPickMaker` (dleta za oblikovanje)
10. **RoyalMillSailClothGrommetMakerSystem.lua** → `local MillSailClothGrommetMaker` (obroči za tkanino)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_garden9_milling9_systems.py`
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

## NASLEDNJI PAKET (v3.11.802–v3.11.811) — STEKLARSKI DODATKI 10 + LIVARSKI DODATKI 10

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 10 (v3.11.802-v3.11.806) — predloga
1. **RoyalGlassGloryHoleDamperMakerSystem.lua** → `local GlassGloryHoleDamperMaker` (zaklopniki za glory hole)
2. **RoyalGlassColorantVialShakerMakerSystem.lua** → `local GlassColorantVialShakerMaker` (tresilci za vialice)
3. **RoyalGlassAnnealingTongJawsMakerSystem.lua** → `local GlassAnnealingTongJawsMaker` (čeljusti za klešče)
4. **RoyalGlassEngravingCopperWheelMakerSystem.lua** → `local GlassEngravingCopperWheelMaker` (bakrena rezbarska kolesa)
5. **RoyalGlassKilnBrickTongsMakerSystem.lua** → `local GlassKilnBrickTongsMaker` (klešče za opeke peči)

### Livarski dodatki 10 (v3.11.807-v3.11.811) — predloga
6. **RoyalMoldFlaskClampWedgeMakerSystem.lua** → `local MoldFlaskClampWedgeMaker` (klini za sponke steklenic)
7. **RoyalPouringLadleSkimmerSieveMakerSystem.lua** → `local PouringLadleSkimmerSieveMaker` (sitana za strgalce)
8. **RoyalSandCoolerMakerSystem.lua** → `local SandCoolerMaker` (hladilci za pesek)
9. **RoyalCoreVarnishBrushMakerSystem.lua** → `local CoreVarnishBrushMaker` (čopiči za lak jedrc)
10. **RoyalCastingLadleLiningTrowelMakerSystem.lua** → `local CastingLadleLiningTrowelMaker` (lopatke za obloge)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalGlassGloryHoleDamperMakerSystem.lua RoyalGlassColorantVialShakerMakerSystem.lua RoyalGlassAnnealingTongJawsMakerSystem.lua RoyalGlassEngravingCopperWheelMakerSystem.lua RoyalGlassKilnBrickTongsMakerSystem.lua RoyalMoldFlaskClampWedgeMakerSystem.lua RoyalPouringLadleSkimmerSieveMakerSystem.lua RoyalSandCoolerMakerSystem.lua RoyalCoreVarnishBrushMakerSystem.lua RoyalCastingLadleLiningTrowelMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.802 do v3.11.811 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.801 → version-3.11.811
   - syntax-1535%2F1538 → syntax-1545%2F1548
   - Royal%20systems-889 → Royal%20systems-899
   - Lua%20files-1538 → Lua%20files-1548
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.802 do v3.11.811), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.811.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_garden9_milling9_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_glass10_foundry10_systems.py`
2. Spremeni `GARDEN9_SYSTEMS` in `MILLING9_SYSTEMS` sezname v `GLASS10_SYSTEMS` in `FOUNDRY10_SYSTEMS`
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_glass10_foundry10_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py`

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.801. Naslednji paket je v3.11.802–v3.11.811 (steklarski dodatki 10 + livarski dodatki 10: GlassGloryHoleDamperMaker, GlassColorantVialShakerMaker, GlassAnnealingTongJawsMaker, GlassEngravingCopperWheelMaker, GlassKilnBrickTongsMaker, MoldFlaskClampWedgeMaker, PouringLadleSkimmerSieveMaker, SandCoolerMaker, CoreVarnishBrushMaker, CastingLadleLiningTrowelMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.802–v3.11.806: steklarski dodatki 10 (GlassGloryHoleDamperMaker, GlassColorantVialShakerMaker, GlassAnnealingTongJawsMaker, GlassEngravingCopperWheelMaker, GlassKilnBrickTongsMaker)
- v3.11.807–v3.11.811: livarski dodatki 10 (MoldFlaskClampWedgeMaker, PouringLadleSkimmerSieveMaker, SandCoolerMaker, CoreVarnishBrushMaker, CastingLadleLiningTrowelMaker)
- v3.11.812–v3.11.816: knjigoveški dodatki 10 (predlagano)
- v3.11.817–v3.11.821: kovaški dodatki 10 (predlagano)
