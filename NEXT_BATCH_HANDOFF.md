# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.751**
- Skupaj Royal sistemov: **839**
- Skupaj Lua datotek: **1488**
- Sintaktična preverba: **1485/1488 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
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

## ZADNJE ZAKLJUČENI PAKET (v3.11.742–v3.11.751) — STEKLARSKI DODATKI 8 + LIVARSKI DODATKI 8

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 8 (v3.11.742-v3.11.746)
1. **RoyalGlassBatchFeederMakerSystem.lua** → `local GlassBatchFeederMaker` (dajalniki mešanice)
2. **RoyalGlassKilnFlueDamperMakerSystem.lua** → `local GlassKilnFlueDamperMaker` (zaklopniki dimnika)
3. **RoyalGlassColorantSieveMakerSystem.lua** → `local GlassColorantSieveMaker` (sitane za barve)
4. **RoyalGlassAnnealingRollerMakerSystem.lua** → `local GlassAnnealingRollerMaker` (valji za ohlajanje)
5. **RoyalGlassEngravingWheelRestMakerSystem.lua** → `local GlassEngravingWheelRestMaker` (počivališča za kolesa)

### Livarski dodatki 8 (v3.11.747-v3.11.751)
6. **RoyalMoldVentWireCleanerMakerSystem.lua** → `local MoldVentWireCleanerMaker` (čistilci žic)
7. **RoyalPouringCrucibleTongsMakerSystem.lua** → `local PouringCrucibleTongsMaker` (klešče za livljenje)
8. **RoyalSandSieveShakerMakerSystem.lua** → `local SandSieveShakerMaker` (tresoče sitane)
9. **RoyalCoreDryingRackMakerSystem.lua** → `local CoreDryingRackMaker` (stojala za jedrca)
10. **RoyalCastingLadleNozzleMakerSystem.lua** → `local CastingLadleNozzleMaker` (šobe za zajemalke)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_glass8_foundry8_systems.py`
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

## NASLEDNJI PAKET (v3.11.752–v3.11.761) — KNJIGOVEŠKI DODATKI 8 + KOVAŠKI DODATKI 8

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 8 (v3.11.752-v3.11.756) — predloga
1. **RoyalBookSpineLiningClothMakerSystem.lua** → `local BookSpineLiningClothMaker` (podstavne tkanine za hrbte)
2. **RoyalBookCoverGaugeMakerSystem.lua** → `local BookCoverGaugeMaker` (merilci za naslovnice)
3. **RoyalBookSewingFrameToggleMakerSystem.lua** → `local BookSewingFrameToggleMaker` (zatiči za šivalne okvire)
4. **RoyalBookEdgeColoringSpongeMakerSystem.lua** → `local BookEdgeColoringSpongeMaker` (gobe za barvanje robov)
5. **RoyalBookCoverBoardShearsMakerSystem.lua** → `local BookCoverBoardShearsMaker` (škarde za vezave)

### Kovaški dodatki 8 (v3.11.757-v3.11.761) — predloga
6. **RoyalForgeBellowsValveMakerSystem.lua** → `local ForgeBellowsValveMaker` (zaklopke za meh)
7. **RoyalAnvilFaceHardenerMakerSystem.lua** → `local AnvilFaceHardenerMaker` (utrjevalci nakovala)
8. **RoyalForgeBrickMakerSystem.lua** → `local ForgeBrickMaker` (opeke za peč)
9. **RoyalQuenchTankStirrerMakerSystem.lua** → `local QuenchTankStirrerMaker` (mešalci za kalilne kadi)
10. **RoyalSmithTongsRingMakerSystem.lua** → `local SmithTongsRingMaker` (obroči za klešče)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalBookSpineLiningClothMakerSystem.lua RoyalBookCoverGaugeMakerSystem.lua RoyalBookSewingFrameToggleMakerSystem.lua RoyalBookEdgeColoringSpongeMakerSystem.lua RoyalBookCoverBoardShearsMakerSystem.lua RoyalForgeBellowsValveMakerSystem.lua RoyalAnvilFaceHardenerMakerSystem.lua RoyalForgeBrickMakerSystem.lua RoyalQuenchTankStirrerMakerSystem.lua RoyalSmithTongsRingMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.752 do v3.11.761 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.751 → version-3.11.761
   - syntax-1485%2F1488 → syntax-1495%2F1498
   - Royal%20systems-839 → Royal%20systems-849
   - Lua%20files-1488 → Lua%20files-1498
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.752 do v3.11.761), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.761.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_glass8_foundry8_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_bookbinding8_blacksmith8_systems.py`
2. Spremeni `GLASS8_SYSTEMS` in `FOUNDRY8_SYSTEMS` sezname v `BOOKBINDING8_SYSTEMS` in `BLACKSMITH8_SYSTEMS`
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_bookbinding8_blacksmith8_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py`

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.751. Naslednji paket je v3.11.752–v3.11.761 (knjigoveški dodatki 8 + kovaški dodatki 8: BookSpineLiningClothMaker, BookCoverGaugeMaker, BookSewingFrameToggleMaker, BookEdgeColoringSpongeMaker, BookCoverBoardShearsMaker, ForgeBellowsValveMaker, AnvilFaceHardenerMaker, ForgeBrickMaker, QuenchTankStirrerMaker, SmithTongsRingMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.752–v3.11.756: knjigoveški dodatki 8 (BookSpineLiningClothMaker, BookCoverGaugeMaker, BookSewingFrameToggleMaker, BookEdgeColoringSpongeMaker, BookCoverBoardShearsMaker)
- v3.11.757–v3.11.761: kovaški dodatki 8 (ForgeBellowsValveMaker, AnvilFaceHardenerMaker, ForgeBrickMaker, QuenchTankStirrerMaker, SmithTongsRingMaker)
- v3.11.762–v3.11.766: vrtni dodatki 8 (predlagano)
- v3.11.767–v3.11.771: mlinarski dodatki 8 (predlagano)
