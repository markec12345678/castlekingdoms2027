# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.671**
- Skupaj Royal sistemov: **759**
- Skupaj Lua datotek: **1408**
- Sintaktična preverba: **1405/1408 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 759 Royal sisteme z igro:

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

## ZADNJE ZAKLJUČENI PAKET (v3.11.662–v3.11.671) — KNJIGOVEŠKI DODATKI 5 + KOVAŠKI DODATKI 5

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 5 (v3.11.662-v3.11.666)
1. **RoyalBookEdgeGilderMakerSystem.lua** → `local BookEdgeGilderMaker` (pozlačevalci robov knjig)
2. **RoyalBookbindingPressStoneMakerSystem.lua** → `local BookbindingPressStoneMaker` (kamni za stiskanje knjig)
3. **RoyalBookSpineCreaserMakerSystem.lua** → `local BookSpineCreaserMaker` (gubalci hrbtov knjig)
4. **RoyalBookMarkTasselMakerSystem.lua** → `local BookMarkTasselMaker` (loki za zaznamke)
5. **RoyalBookCoverInlayMakerSystem.lua** → `local BookCoverInlayMaker` (intarzije za naslovnice)

### Kovaški dodatki 5 (v3.11.667-v3.11.671)
6. **RoyalPritchelHoleMakerSystem.lua** → `local PritchelHoleMaker` (luknje za konice)
7. **RoyalBellHammerMakerSystem.lua** → `local BellHammerMaker` (zvočna kladiva)
8. **RoyalHotCutHardyMakerSystem.lua** → `local HotCutHardyMaker` (vroče rezalni trdi nastavki)
9. **RoyalCupolaTuyereMakerSystem.lua** → `local CupolaTuyereMaker` (šobe za kupole)
10. **RoyalForgeCokeRakeMakerSystem.lua** → `local ForgeCokeRakeMaker` (grebalci za koks)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_bookbinding5_blacksmith5_systems.py`
- Sintaktična preverba: `/home/z/my-project/scripts/check_new_systems_syntax.py`
- Vseh 10 novih datotek PASS sintaktične preverbe (lupa load())
- Skripta uporablja string.Template (ne f-string) za čisto Lua predlogo
- Pravilno substituira vse placeholderje vključno z ${maker_lower}
- Uporablja pravilno sintakso `productStock[m.productType]` (ne okvarjeno `productStock.productType]`)

## PATTERN ZA VSAK SISTEM

Vsak sistem mora imeti:
- 6 produktov (železni → bronasti → srebrni → pozlačeni → draguljasti → kraljevski suvereni)
- 4 zgradbe (delavnica, hiša, mojstrski atelje, suverena palača)
- Funkcije: `init`, `hireMaker`, `canBuild`, `build`, `getQualityBonus`, `canMake`, `make`, `completeMaking`, `update`, `getStats`
- `_G.NotificationCenter.notify` in `_G.GameEventBus.publish` s pcall
- Vrača lokalno tabelo
- Slovenian product/building names
- **POMEMBNO**: V `completeMaking` uporabljaj `productStock[m.productType]` (z `[m.` pred `productType]`) — ne `productStock.productType]` (to je okvarjena sintaksa)

## NASLEDNJI PAKET (v3.11.672–v3.11.681) — VRTNI DODATKI 5 + MLINARSKI DODATKI 5

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 5 (v3.11.672-v3.11.676) — predloga
1. **RoyalGardenTrowelSharpenerMakerSystem.lua** → `local GardenTrowelSharpenerMaker` (brusilci lopatk)
2. **RoyalTrellisMakerSystem.lua** → `local TrellisMaker` (loške rešetke za rastline)
3. **RoyalGardenTwineDispenserMakerSystem.lua** → `local GardenTwineDispenserMaker` (razdelilci vrvice)
4. **RoyalPlantLabelMakerSystem.lua** → `local PlantLabelMaker` (oznake za rastline)
5. **RoyalGardenKneelerMakerSystem.lua** → `local GardenKneelerMaker` (pohištvo za klečenje)

### Mlinarski dodatki 5 (v3.11.677-v3.11.681) — predloga
6. **RoyalMillstoneLifterHooksMakerSystem.lua** → `local MillstoneLifterHooksMaker` (kljuki za dviganje kamnov)
7. **RoyalGrainSieveMakerSystem.lua** → `local GrainSieveMaker` (sitana za žito)
8. **RoyalMillHopperAgitatorMakerSystem.lua** → `local MillHopperAgitatorMaker` (stresalci za lijak)
9. **RoyalMillstoneBalancerMakerSystem.lua** → `local MillstoneBalancerMaker` (uravnavalci mlinskih kamnov)
10. **RoyalMillSailClothMakerSystem.lua** → `local MillSailClothMaker` (jedrna tkanina za mlin)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalGardenTrowelSharpenerMakerSystem.lua RoyalTrellisMakerSystem.lua RoyalGardenTwineDispenserMakerSystem.lua RoyalPlantLabelMakerSystem.lua RoyalGardenKneelerMakerSystem.lua RoyalMillstoneLifterHooksMakerSystem.lua RoyalGrainSieveMakerSystem.lua RoyalMillHopperAgitatorMakerSystem.lua RoyalMillstoneBalancerMakerSystem.lua RoyalMillSailClothMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam v tej skripti)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.672 do v3.11.681 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.671 → version-3.11.681
   - syntax-1405%2F1408 → syntax-1415%2F1418
   - Royal%20systems-759 → Royal%20systems-769
   - Lua%20files-1408 → Lua%20files-1418
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.672 do v3.11.681), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.681.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_bookbinding5_blacksmith5_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_garden5_milling5_systems.py`
2. Spremeni `BOOKBINDING5_SYSTEMS` in `BLACKSMITH5_SYSTEMS` sezname v `GARDEN5_SYSTEMS` in `MILLING5_SYSTEMS` z novimi sistemi
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_garden5_milling5_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)

## PREDLOGA ZA SISTEM (primer BookEdgeGilderMaker, kot referenca)

```lua
local BookEdgeGilderMaker = {}
local PRODUCTS = {
    iron_bookedgegilder = { name = "Železni pozlačevalec robov", ironCost = 3, woodCost = 2, leatherCost = 1, time = 5, cost = 150, prestige = 4, happiness = 2, description = "Železni pozlačevalec robov za knjigoveze." },
    -- ... 5 more products (bronze, silver, gilded, jewel_set, royal_sovereign)
}
local BUILDINGS = {
    bookedgegilder_workshop = { name = "Bookedgegilder delavnica", cost = { gold = 325, wood = 185, stone = 130, iron = 7 }, upkeep = 6, qualityBonus = 5 },
    -- ... 3 more buildings (house, master_atelier, sovereign_palace)
}
BookEdgeGilderMaker.ironStock=12; BookEdgeGilderMaker.bronzeStock=10; ... BookEdgeGilderMaker.pearlStock=4
BookEdgeGilderMaker.productStock = {}; BookEdgeGilderMaker.buildings = {}; BookEdgeGilderMaker.maker = nil; BookEdgeGilderMaker.activeMaking = {}; BookEdgeGilderMaker.totalProducts = 0; BookEdgeGilderMaker.dayTimer = 0
function BookEdgeGilderMaker.init() ... end
function BookEdgeGilderMaker.hireMaker(n,s) ... end
function BookEdgeGilderMaker.canBuild(id) ... end
function BookEdgeGilderMaker.build(id) ... end
function BookEdgeGilderMaker.getQualityBonus() ... end
function BookEdgeGilderMaker.canMake(pt) ... end
function BookEdgeGilderMaker.make(pt,qty) ... end
function BookEdgeGilderMaker.completeMaking(m) ... BookEdgeGilderMaker.productStock[m.productType]=(BookEdgeGilderMaker.productStock[m.productType] or 0)+m.quantity ... end
function BookEdgeGilderMaker.update(dt) ... end
function BookEdgeGilderMaker.getStats() ... end
return BookEdgeGilderMaker
```

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.671. Naslednji paket je v3.11.672–v3.11.681 (vrtni dodatki 5 + mlinarski dodatki 5: GardenTrowelSharpenerMaker, TrellisMaker, GardenTwineDispenserMaker, PlantLabelMaker, GardenKneelerMaker, MillstoneLifterHooksMaker, GrainSieveMaker, MillHopperAgitatorMaker, MillstoneBalancerMaker, MillSailClothMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.672–v3.11.676: vrtni dodatki 5 (GardenTrowelSharpenerMaker, TrellisMaker, GardenTwineDispenserMaker, PlantLabelMaker, GardenKneelerMaker)
- v3.11.677–v3.11.681: mlinarski dodatki 5 (MillstoneLifterHooksMaker, GrainSieveMaker, MillHopperAgitatorMaker, MillstoneBalancerMaker, MillSailClothMaker)
- v3.11.682–v3.11.686: steklarski dodatki 6 (predlagano)
- v3.11.687–v3.11.691: livarski dodatki 6 (predlagano)
