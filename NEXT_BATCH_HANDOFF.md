# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.641**
- Skupaj Royal sistemov: **729**
- Skupaj Lua datotek: **1378**
- Sintaktična preverba: **1375/1378 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 729 Royal sisteme z igro:

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

## ZADNJE ZAKLJUČENI PAKET (v3.11.632–v3.11.641) — KNJIGOVEŠKI DODATKI 4 + KOVAŠKI DODATKI 4

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 4 (v3.11.632-v3.11.636)
1. **RoyalBookEdgePainterMakerSystem.lua** → `local BookEdgePainterMaker` (slikalci robov knjig)
2. **RoyalBookPressingWeightMakerSystem.lua** → `local BookPressingWeightMaker` (uteži za stiskanje knjig)
3. **RoyalBookbindingAwlMakerSystem.lua** → `local BookbindingAwlMaker` (šila za knjigoveštvo)
4. **RoyalBookThreadReelMakerSystem.lua** → `local BookThreadReelMaker` (vitice za knjigoveške niti)
5. **RoyalBookCoverCrimperMakerSystem.lua** → `local BookCoverCrimperMaker` (gubalci naslovnic)

### Kovaški dodatki 4 (v3.11.637-v3.11.641)
6. **RoyalCutterHardyMakerSystem.lua** → `local CutterHardyMaker` (trdi rezalniki za nakovalo)
7. **RoyalSetHammerMakerSystem.lua** → `local SetHammerMaker` (nastavitvena kladiva)
8. **RoyalBottomFullerMakerSystem.lua** → `local BottomFullerMaker` (spodnji fullerji)
9. **RoyalTopFullerMakerSystem.lua** → `local TopFullerMaker` (zgornji fullerji)
10. **RoyalAnvilHardyMakerSystem.lua** → `local AnvilHardyMaker` (trdi nastavki za nakovalo)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_bookbinding4_blacksmith4_systems.py`
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

## NASLEDNJI PAKET (v3.11.642–v3.11.651) — VRTNI DODATKI 4 + MLINARSKI DODATKI 4

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 4 (v3.11.642-v3.11.646) — predloga
1. **RoyalGardenSecateursMakerSystem.lua** → `local GardenSecateursMaker` (vrtni škarjici)
2. **RoyalHedgeShearsMakerSystem.lua** → `local HedgeShearsMaker` (škarje za žive meje)
3. **RoyalLawnAeratorMakerSystem.lua** → `local LawnAeratorMaker` (zračilci travnikov)
4. **RoyalGardenSprayerMakerSystem.lua** → `local GardenSprayerMaker` (škropilnice)
5. **RoyalCompostSieveMakerSystem.lua** → `local CompostSieveMaker` (sitana za kompost)

### Mlinarski dodatki 4 (v3.11.647-v3.11.651) — predloga
6. **RoyalMillstoneCraneHookMakerSystem.lua** → `local MillstoneCraneHookMaker` (kljuki za dvig mlinskih kamnov)
7. **RoyalGrainHopperLinerMakerSystem.lua** → `local GrainHopperLinerMaker` (obloge za lijake)
8. **RoyalMillDriveBeltMakerSystem.lua** → `local MillDriveBeltMaker` (pogonski jermeni za mline)
9. **RoyalFlourPackerMakerSystem.lua** → `local FlourPackerMaker` (pakerji za moko)
10. **RoyalMillstoneGrooveReframerMakerSystem.lua** → `local MillstoneGrooveReframerMaker` (obnavljalci utorov)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalGardenSecateursMakerSystem.lua RoyalHedgeShearsMakerSystem.lua RoyalLawnAeratorMakerSystem.lua RoyalGardenSprayerMakerSystem.lua RoyalCompostSieveMakerSystem.lua RoyalMillstoneCraneHookMakerSystem.lua RoyalGrainHopperLinerMakerSystem.lua RoyalMillDriveBeltMakerSystem.lua RoyalFlourPackerMakerSystem.lua RoyalMillstoneGrooveReframerMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam v tej skripti)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.642 do v3.11.651 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.641 → version-3.11.651
   - syntax-1375%2F1378 → syntax-1385%2F1388
   - Royal%20systems-729 → Royal%20systems-739
   - Lua%20files-1378 → Lua%20files-1388
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.642 do v3.11.651), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.651.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_bookbinding4_blacksmith4_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_garden4_milling4_systems.py`
2. Spremeni `BOOKBINDING4_SYSTEMS` in `BLACKSMITH4_SYSTEMS` sezname v `GARDEN4_SYSTEMS` in `MILLING4_SYSTEMS` z novimi sistemi
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_garden4_milling4_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)

## PREDLOGA ZA SISTEM (primer BookEdgePainterMaker, kot referenca)

```lua
local BookEdgePainterMaker = {}
local PRODUCTS = {
    iron_bookedgepainter = { name = "Železni slikalec robov knjig", ironCost = 3, woodCost = 2, leatherCost = 1, time = 5, cost = 150, prestige = 4, happiness = 2, description = "Železni slikalec robov knjig za knjigoveze." },
    -- ... 5 more products (bronze, silver, gilded, jewel_set, royal_sovereign)
}
local BUILDINGS = {
    bookedgepainter_workshop = { name = "Bookedgepainter delavnica", cost = { gold = 325, wood = 185, stone = 130, iron = 7 }, upkeep = 6, qualityBonus = 5 },
    -- ... 3 more buildings (house, master_atelier, sovereign_palace)
}
BookEdgePainterMaker.ironStock=12; BookEdgePainterMaker.bronzeStock=10; ... BookEdgePainterMaker.pearlStock=4
BookEdgePainterMaker.productStock = {}; BookEdgePainterMaker.buildings = {}; BookEdgePainterMaker.maker = nil; BookEdgePainterMaker.activeMaking = {}; BookEdgePainterMaker.totalProducts = 0; BookEdgePainterMaker.dayTimer = 0
function BookEdgePainterMaker.init() ... end
function BookEdgePainterMaker.hireMaker(n,s) ... end
function BookEdgePainterMaker.canBuild(id) ... end
function BookEdgePainterMaker.build(id) ... end
function BookEdgePainterMaker.getQualityBonus() ... end
function BookEdgePainterMaker.canMake(pt) ... end
function BookEdgePainterMaker.make(pt,qty) ... end
function BookEdgePainterMaker.completeMaking(m) ... BookEdgePainterMaker.productStock[m.productType]=(BookEdgePainterMaker.productStock[m.productType] or 0)+m.quantity ... end
function BookEdgePainterMaker.update(dt) ... end
function BookEdgePainterMaker.getStats() ... end
return BookEdgePainterMaker
```

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.641. Naslednji paket je v3.11.642–v3.11.651 (vrtni dodatki 4 + mlinarski dodatki 4: GardenSecateursMaker, HedgeShearsMaker, LawnAeratorMaker, GardenSprayerMaker, CompostSieveMaker, MillstoneCraneHookMaker, GrainHopperLinerMaker, MillDriveBeltMaker, FlourPackerMaker, MillstoneGrooveReframerMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.642–v3.11.646: vrtni dodatki 4 (GardenSecateursMaker, HedgeShearsMaker, LawnAeratorMaker, GardenSprayerMaker, CompostSieveMaker)
- v3.11.647–v3.11.651: mlinarski dodatki 4 (MillstoneCraneHookMaker, GrainHopperLinerMaker, MillDriveBeltMaker, FlourPackerMaker, MillstoneGrooveReframerMaker)
- v3.11.652–v3.11.656: steklarski dodatki 5 (predlagano)
- v3.11.657–v3.11.661: livarski dodatki 5 (predlagano)
