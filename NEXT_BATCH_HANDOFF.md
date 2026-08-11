# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.701**
- Skupaj Royal sistemov: **789**
- Skupaj Lua datotek: **1438**
- Sintaktična preverba: **1435/1438 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
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

## ZADNJE ZAKLJUČENI PAKET (v3.11.692–v3.11.701) — KNJIGOVEŠKI DODATKI 6 + KOVAŠKI DODATKI 6

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 6 (v3.11.692-v3.11.696)
1. **RoyalBookSpineRulerMakerSystem.lua** → `local BookSpineRulerMaker` (merilniki hrbtov)
2. **RoyalBookbindingGluePotMakerSystem.lua** → `local BookbindingGluePotMaker` (lepilni lončki)
3. **RoyalBookCoverDieMakerSystem.lua** → `local BookCoverDieMaker` (matrice za naslovnice)
4. **RoyalBookEdgeBurnisherMakerSystem.lua** → `local BookEdgeBurnisherMaker` (poliralci robov)
5. **RoyalBookbindingScrewPressMakerSystem.lua** → `local BookbindingScrewPressMaker` (vijačni stiskalniki)

### Kovaški dodatki 6 (v3.11.697-v3.11.701)
6. **RoyalForgeAshPanMakerSystem.lua** → `local ForgeAshPanMaker` (pepelniki)
7. **RoyalBickHornAnvilMakerSystem.lua** → `local BickHornAnvilMaker` (rogaste nakovalo)
8. **RoyalSlackTubHoodMakerSystem.lua** → `local SlackTubHoodMaker` (pokrovi za kalilne kadi)
9. **RoyalForgeChimneyDamperMakerSystem.lua** → `local ForgeChimneyDamperMaker` (zaklopniki dimnikov)
10. **RoyalBlacksmithViseMakerSystem.lua** → `local BlacksmithViseMaker` (kovaške primernice)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_bookbinding6_blacksmith6_systems.py`
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

## NASLEDNJI PAKET (v3.11.702–v3.11.711) — VRTNI DODATKI 6 + MLINARSKI DODATKI 6

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 6 (v3.11.702-v3.11.706) — predloga
1. **RoyalGardenSieveFrameMakerSystem.lua** → `local GardenSieveFrameMaker` (okvirji za sita)
2. **RoyalPlantSupportStakeMakerSystem.lua** → `local PlantSupportStakeMaker` (kolčki za oporo)
3. **RoyalGardenWateringTrayMakerSystem.lua** → `local GardenWateringTrayMaker` (pladnji za zalivanje)
4. **RoyalGardenToolRackMakerSystem.lua** → `local GardenToolRackMaker` (stojala za orodje)
5. **RoyalGardenClocheMakerSystem.lua** → `local GardenClocheMaker` (stekleni pokrovi)

### Mlinarski dodatki 6 (v3.11.707-v3.11.711) — predloga
6. **RoyalMillstoneQuillMakerSystem.lua** → `local MillstoneQuillMaker` (vretena mlinskih kamnov)
7. **RoyalGrainSpoutMakerSystem.lua** → `local GrainSpoutMaker` (žlivi za žito)
8. **RoyalMillHopperShakerMakerSystem.lua** → `local MillHopperShakerMaker` (tresoča stresala)
9. **RoyalMillstoneBushMakerSystem.lua** → `local MillstoneBushMaker` (ležajni bush-i)
10. **RoyalMillSailFrameMakerSystem.lua** → `local MillSailFrameMaker` (okvirji za jedra)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalGardenSieveFrameMakerSystem.lua RoyalPlantSupportStakeMakerSystem.lua RoyalGardenWateringTrayMakerSystem.lua RoyalGardenToolRackMakerSystem.lua RoyalGardenClocheMakerSystem.lua RoyalMillstoneQuillMakerSystem.lua RoyalGrainSpoutMakerSystem.lua RoyalMillHopperShakerMakerSystem.lua RoyalMillstoneBushMakerSystem.lua RoyalMillSailFrameMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.702 do v3.11.711 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.701 → version-3.11.711
   - syntax-1435%2F1438 → syntax-1445%2F1448
   - Royal%20systems-789 → Royal%20systems-799
   - Lua%20files-1438 → Lua%20files-1448
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.702 do v3.11.711), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.711.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_bookbinding6_blacksmith6_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_garden6_milling6_systems.py`
2. Spremeni `BOOKBINDING6_SYSTEMS` in `BLACKSMITH6_SYSTEMS` sezname v `GARDEN6_SYSTEMS` in `MILLING6_SYSTEMS`
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_garden6_milling6_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py`

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.701. Naslednji paket je v3.11.702–v3.11.711 (vrtni dodatki 6 + mlinarski dodatki 6: GardenSieveFrameMaker, PlantSupportStakeMaker, GardenWateringTrayMaker, GardenToolRackMaker, GardenClocheMaker, MillstoneQuillMaker, GrainSpoutMaker, MillHopperShakerMaker, MillstoneBushMaker, MillSailFrameMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.702–v3.11.706: vrtni dodatki 6 (GardenSieveFrameMaker, PlantSupportStakeMaker, GardenWateringTrayMaker, GardenToolRackMaker, GardenClocheMaker)
- v3.11.707–v3.11.711: mlinarski dodatki 6 (MillstoneQuillMaker, GrainSpoutMaker, MillHopperShakerMaker, MillstoneBushMaker, MillSailFrameMaker)
- v3.11.712–v3.11.716: steklarski dodatki 7 (predlagano)
- v3.11.717–v3.11.721: livarski dodatki 7 (predlagano)
