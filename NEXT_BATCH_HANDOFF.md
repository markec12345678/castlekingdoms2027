# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.721**
- Skupaj Royal sistemov: **809**
- Skupaj Lua datotek: **1458**
- Sintaktična preverba: **1455/1458 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
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

## ZADNJE ZAKLJUČENI PAKET (v3.11.712–v3.11.721) — STEKLARSKI DODATKI 7 + LIVARSKI DODATKI 7

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 7 (v3.11.712-v3.11.716)
1. **RoyalGlassPuntyWarmerMakerSystem.lua** → `local GlassPuntyWarmerMaker` (grevalniki palic)
2. **RoyalGlassKilnSpyMakerSystem.lua** → `local GlassKilnSpyMaker` (opazovalne odprtine)
3. **RoyalGlassColorantSpatulaMakerSystem.lua** → `local GlassColorantSpatulaMaker` (lopatice za barve)
4. **RoyalGlassAnnealingCartMakerSystem.lua** → `local GlassAnnealingCartMaker` (vozički za ohlajanje)
5. **RoyalGlassShearSpringMakerSystem.lua** → `local GlassShearSpringMaker` (vzmeti za škarde)

### Livarski dodatki 7 (v3.11.717-v3.11.721)
6. **RoyalMoldDryingStandMakerSystem.lua** → `local MoldDryingStandMaker` (stojala za sušenje)
7. **RoyalPouringConeMakerSystem.lua** → `local PouringConeMaker` (lijaki za vlivanje)
8. **RoyalSandConditionerMakerSystem.lua** → `local SandConditionerMaker` (kondicionerji peska)
9. **RoyalCorePasteMixerMakerSystem.lua** → `local CorePasteMixerMaker` (mešalniki jedrne paste)
10. **RoyalCastingBreakoutChiselMakerSystem.lua** → `local CastingBreakoutChiselMaker` (dleta za odklešanje)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_glass7_foundry7_systems.py`
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

## NASLEDNJI PAKET (v3.11.722–v3.11.731) — KNJIGOVEŠKI DODATKI 7 + KOVAŠKI DODATKI 7

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 7 (v3.11.722-v3.11.726) — predloga
1. **RoyalBookEndbandLoomMakerSystem.lua** → `local BookEndbandLoomMaker` (statvi za kapice)
2. **RoyalBookCoverCornerCutterMakerSystem.lua** → `local BookCoverCornerCutterMaker` (rezalniki robov naslovnic)
3. **RoyalBookSpineGlueBrushMakerSystem.lua** → `local BookSpineGlueBrushMaker` (čopiči za lepilo hrbtov)
4. **RoyalBookForedgeFanMakerSystem.lua** → `local BookForedgeFanMaker` (ventilatorji za prednji rob)
5. **RoyalBookCoverStampingFoilMakerSystem.lua** → `local BookCoverStampingFoilMaker` (folije za žig)

### Kovaški dodatki 7 (v3.11.727-v3.11.731) — predloga
6. **RoyalForgeTuyereBlockMakerSystem.lua** → `local ForgeTuyereBlockMaker` (bloki šob)
7. **RoyalAnvilStumpMakerSystem.lua** → `local AnvilStumpMaker` (panji za nakovalo)
8. **RoyalForgeHoodFlueMakerSystem.lua** → `local ForgeHoodFlueMaker` (napa za dim)
9. **RoyalHardyShankMakerSystem.lua** → `local HardyShankMaker` (drgi za trde nastavke)
10. **RoyalSlackTubLidMakerSystem.lua** → `local SlackTubLidMaker` (pokrovi za kalilne kadi)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalBookEndbandLoomMakerSystem.lua RoyalBookCoverCornerCutterMakerSystem.lua RoyalBookSpineGlueBrushMakerSystem.lua RoyalBookForedgeFanMakerSystem.lua RoyalBookCoverStampingFoilMakerSystem.lua RoyalForgeTuyereBlockMakerSystem.lua RoyalAnvilStumpMakerSystem.lua RoyalForgeHoodFlueMakerSystem.lua RoyalHardyShankMakerSystem.lua RoyalSlackTubLidMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.722 do v3.11.731 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.721 → version-3.11.731
   - syntax-1455%2F1458 → syntax-1465%2F1468
   - Royal%20systems-809 → Royal%20systems-819
   - Lua%20files-1458 → Lua%20files-1468
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.722 do v3.11.731), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.731.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_glass7_foundry7_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_bookbinding7_blacksmith7_systems.py`
2. Spremeni `GLASS7_SYSTEMS` in `FOUNDRY7_SYSTEMS` sezname v `BOOKBINDING7_SYSTEMS` in `BLACKSMITH7_SYSTEMS`
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_bookbinding7_blacksmith7_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py`

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.721. Naslednji paket je v3.11.722–v3.11.731 (knjigoveški dodatki 7 + kovaški dodatki 7: BookEndbandLoomMaker, BookCoverCornerCutterMaker, BookSpineGlueBrushMaker, BookForedgeFanMaker, BookCoverStampingFoilMaker, ForgeTuyereBlockMaker, AnvilStumpMaker, ForgeHoodFlueMaker, HardyShankMaker, SlackTubLidMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.722–v3.11.726: knjigoveški dodatki 7 (BookEndbandLoomMaker, BookCoverCornerCutterMaker, BookSpineGlueBrushMaker, BookForedgeFanMaker, BookCoverStampingFoilMaker)
- v3.11.727–v3.11.731: kovaški dodatki 7 (ForgeTuyereBlockMaker, AnvilStumpMaker, ForgeHoodFlueMaker, HardyShankMaker, SlackTubLidMaker)
- v3.11.732–v3.11.736: vrtni dodatki 7 (predlagano)
- v3.11.737–v3.11.741: mlinarski dodatki 7 (predlagano)
