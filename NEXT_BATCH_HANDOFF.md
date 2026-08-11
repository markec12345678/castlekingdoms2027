# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.741**
- Skupaj Royal sistemov: **829**
- Skupaj Lua datotek: **1478**
- Sintaktična preverba: **1475/1478 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
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

## ZADNJE ZAKLJUČENI PAKET (v3.11.732–v3.11.741) — VRTNI DODATKI 7 + MLINARSKI DODATKI 7

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 7 (v3.11.732-v3.11.736)
1. **RoyalGardenBorderEdgerMakerSystem.lua** → `local GardenBorderEdgerMaker` (robovi za gredice)
2. **RoyalPlantClimbingNetMakerSystem.lua** → `local PlantClimbingNetMaker` (mreže za plezalke)
3. **RoyalGardenDibberDepthGaugeMakerSystem.lua** → `local GardenDibberDepthGaugeMaker` (merilci globine)
4. **RoyalGardenLeafGrabberMakerSystem.lua** → `local GardenLeafGrabberMaker` (grablje za liste)
5. **RoyalGardenSoilAeratorSpikeMakerSystem.lua** → `local GardenSoilAeratorSpikeMaker` (bodala za zračenje)

### Mlinarski dodatki 7 (v3.11.737-v3.11.741)
6. **RoyalMillstoneTenterHookMakerSystem.lua** → `local MillstoneTenterHookMaker` (kljuki za napenjanje)
7. **RoyalGrainAugerSpiralMakerSystem.lua** → `local GrainAugerSpiralMaker` (spirale za transporter)
8. **RoyalMillHopperLidMakerSystem.lua** → `local MillHopperLidMaker` (pokrovi za lijak)
9. **RoyalMillstoneEyeReamerMakerSystem.lua** → `local MillstoneEyeReamerMaker` (razširjevalci očes)
10. **RoyalMillSailClothReelMakerSystem.lua** → `local MillSailClothReelMaker` (vitice za tkanino)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_garden7_milling7_systems.py`
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

## NASLEDNJI PAKET (v3.11.742–v3.11.751) — STEKLARSKI DODATKI 8 + LIVARSKI DODATKI 8

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 8 (v3.11.742-v3.11.746) — predloga
1. **RoyalGlassBatchFeederMakerSystem.lua** → `local GlassBatchFeederMaker` (dajalci steklarske mešanice)
2. **RoyalGlassKilnFlueDamperMakerSystem.lua** → `local GlassKilnFlueDamperMaker` (zaklopniki dimnika)
3. **RoyalGlassColorantSieveMakerSystem.lua** → `local GlassColorantSieveMaker` (sitana za barve)
4. **RoyalGlassAnnealingRollerMakerSystem.lua** → `local GlassAnnealingRollerMaker` (valji za ohlajanje)
5. **RoyalGlassEngravingWheelRestMakerSystem.lua** → `local GlassEngravingWheelRestMaker` (počivališča za rezbarska kolesa)

### Livarski dodatki 8 (v3.11.747-v3.11.751) — predloga
6. **RoyalMoldVentWireCleanerMakerSystem.lua** → `local MoldVentWireCleanerMaker` (čistilci žic za odzračevanje)
7. **RoyalPouringCrucibleTongsMakerSystem.lua** → `local PouringCrucibleTongsMaker` (klešče za livljenje)
8. **RoyalSandSieveShakerMakerSystem.lua** → `local SandSieveShakerMaker` (tresoče sitane za pesek)
9. **RoyalCoreDrying RackMakerSystem.lua** → `local CoreDryingRackMaker` (stojala za sušenje jedrc)
10. **RoyalCastingLadleNozzleMakerSystem.lua** → `local CastingLadleNozzleMaker` (šobe za zajemalke)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalGlassBatchFeederMakerSystem.lua RoyalGlassKilnFlueDamperMakerSystem.lua RoyalGlassColorantSieveMakerSystem.lua RoyalGlassAnnealingRollerMakerSystem.lua RoyalGlassEngravingWheelRestMakerSystem.lua RoyalMoldVentWireCleanerMakerSystem.lua RoyalPouringCrucibleTongsMakerSystem.lua RoyalSandSieveShakerMakerSystem.lua RoyalCoreDryingRackMakerSystem.lua RoyalCastingLadleNozzleMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.742 do v3.11.751 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.741 → version-3.11.751
   - syntax-1475%2F1478 → syntax-1485%2F1488
   - Royal%20systems-829 → Royal%20systems-839
   - Lua%20files-1478 → Lua%20files-1488
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.742 do v3.11.751), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.751.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_garden7_milling7_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_glass8_foundry8_systems.py`
2. Spremeni `GARDEN7_SYSTEMS` in `MILLING7_SYSTEMS` sezname v `GLASS8_SYSTEMS` in `FOUNDRY8_SYSTEMS`
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_glass8_foundry8_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py`

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.741. Naslednji paket je v3.11.742–v3.11.751 (steklarski dodatki 8 + livarski dodatki 8: GlassBatchFeederMaker, GlassKilnFlueDamperMaker, GlassColorantSieveMaker, GlassAnnealingRollerMaker, GlassEngravingWheelRestMaker, MoldVentWireCleanerMaker, PouringCrucibleTongsMaker, SandSieveShakerMaker, CoreDryingRackMaker, CastingLadleNozzleMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.742–v3.11.746: steklarski dodatki 8 (GlassBatchFeederMaker, GlassKilnFlueDamperMaker, GlassColorantSieveMaker, GlassAnnealingRollerMaker, GlassEngravingWheelRestMaker)
- v3.11.747–v3.11.751: livarski dodatki 8 (MoldVentWireCleanerMaker, PouringCrucibleTongsMaker, SandSieveShakerMaker, CoreDryingRackMaker, CastingLadleNozzleMaker)
- v3.11.752–v3.11.756: knjigoveški dodatki 8 (predlagano)
- v3.11.757–v3.11.761: kovaški dodatki 8 (predlagano)
