# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.611**
- Skupaj Royal sistemov: **699**
- Skupaj Lua datotek: **1348**
- Sintaktična preverba: **1345/1348 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 699 Royal sisteme z igro:

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

## ZADNJE ZAKLJUČENI PAKET (v3.11.602–v3.11.611) — KNJIGOVEŠKI DODATKI 3 + KOVAŠKI DODATKI 3

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 3 (v3.11.602-v3.11.606)
1. **RoyalBookStitchingFrameMakerSystem.lua** → `local BookStitchingFrameMaker` (okvirji za šivanje knjig)
2. **RoyalBookCoverStampMakerSystem.lua** → `local BookCoverStampMaker` (žigi za naslovnice)
3. **RoyalGildingBrushMakerSystem.lua** → `local GildingBrushMaker` (čopiči za pozlačevanje)
4. **RoyalHeadbandLoomMakerSystem.lua** → `local HeadbandLoomMaker` (stati za kapice knjig)
5. **RoyalBookClaspMakerSystem.lua** → `local BookClaspMaker` (sponke za knjige)

### Kovaški dodatki 3 (v3.11.607-v3.11.611)
6. **RoyalSwageBlockMakerSystem.lua** → `local SwageBlockMaker` (kalupi za kovanje)
7. **RoyalHardyHoleMakerSystem.lua** → `local HardyHoleMaker` (luknje za trdo orodje)
8. **RoyalTreadleHammerMakerSystem.lua** → `local TreadleHammerMaker` (pedalna kladiva)
9. **RoyalFullerMakerSystem.lua** → `local FullerMaker` (fullerji za utorjanje)
10. **RoyalFlatterMakerSystem.lua** → `local FlatterMaker` (ploščata kladiva)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek:
```
for f in RoyalBookStitchingFrameMakerSystem.lua RoyalBookCoverStampMakerSystem.lua ...; do
  count=$(git log --all --oneline -- "objects/Economy/$f" | wc -l)
  echo "$f: $count prior commits"
done
```
Vseh 10 datotek je imelo 0 prior commits — nobenih duplikatov, varno za generiranje. To je sedaj standardni korak po flask-incidentu v v3.11.597 paketu (kjer je FlaskMaker že obstajal od v3.11.447).

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_bookbinding3_blacksmith3_systems.py`
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

## NASLEDNJI PAKET (v3.11.612–v3.11.621) — VRTNI DODATKI 3 + MLINARSKI DODATKI 3

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 3 (v3.11.612-v3.11.616) — predloga
1. **RoyalGardenHoeMakerSystem.lua** → `local GardenHoeMaker` (vrtne motike)
2. **RoyalDibberMakerSystem.lua** → `local DibberMaker` (sadilniki za seme)
3. **RoyalGardenRakeMakerSystem.lua** → `local GardenRakeMaker` (vrtne grelde)
4. **RoyalPruningSawMakerSystem.lua** → `local PruningSawMaker` (žage za obrezovanje)
5. **RoyalGardenWheelbarrowMakerSystem.lua** → `local GardenWheelbarrowMaker` (vrtni vozički)

### Mlinarski dodatki 3 (v3.11.617-v3.11.621) — predloga
6. **RoyalGrainAugerMakerSystem.lua** → `local GrainAugerMaker` (žitni spiralni transporter)
7. **RoyalMillstoneDresserMakerSystem.lua** → `local MillstoneDresserMaker` (oblikovalci mlinskih kamnov)
8. **RoyalHopperGateMakerSystem.lua** → `local HopperGateMaker` (zapornice za lijake)
9. **RoyalFlourSieveMakerSystem.lua** → `local FlourSieveMaker` (sitana za moko)
10. **RoyalBranSeparatorMakerSystem.lua** → `local BranSeparatorMaker` (ločilci otrob)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalGardenHoeMakerSystem.lua RoyalDibberMakerSystem.lua RoyalGardenRakeMakerSystem.lua RoyalPruningSawMakerSystem.lua RoyalGardenWheelbarrowMakerSystem.lua RoyalGrainAugerMakerSystem.lua RoyalMillstoneDresserMakerSystem.lua RoyalHopperGateMakerSystem.lua RoyalFlourSieveMakerSystem.lua RoyalBranSeparatorMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam v tej skripti)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.612 do v3.11.621 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.611 → version-3.11.621
   - syntax-1345%2F1348 → syntax-1355%2F1358
   - Royal%20systems-699 → Royal%20systems-709
   - Lua%20files-1348 → Lua%20files-1358
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.612 do v3.11.621), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.621.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_bookbinding3_blacksmith3_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_garden3_milling3_systems.py`
2. Spremeni `BOOKBINDING3_SYSTEMS` in `BLACKSMITH3_SYSTEMS` sezname v `GARDEN3_SYSTEMS` in `MILLING3_SYSTEMS` z novimi sistemi
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_garden3_milling3_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)

## PREDLOGA ZA SISTEM (primer BookStitchingFrameMaker, kot referenca)

```lua
local BookStitchingFrameMaker = {}
local PRODUCTS = {
    iron_bookstitchingframe = { name = "Železni okvir za šivanje knjig", ironCost = 3, woodCost = 2, leatherCost = 1, time = 5, cost = 150, prestige = 4, happiness = 2, description = "Železni okvir za šivanje knjig za knjigoveze." },
    -- ... 5 more products (bronze, silver, gilded, jewel_set, royal_sovereign)
}
local BUILDINGS = {
    bookstitchingframe_workshop = { name = "Bookstitchingframe delavnica", cost = { gold = 325, wood = 185, stone = 130, iron = 7 }, upkeep = 6, qualityBonus = 5 },
    -- ... 3 more buildings (house, master_atelier, sovereign_palace)
}
BookStitchingFrameMaker.ironStock=12; BookStitchingFrameMaker.bronzeStock=10; ... BookStitchingFrameMaker.pearlStock=4
BookStitchingFrameMaker.productStock = {}; BookStitchingFrameMaker.buildings = {}; BookStitchingFrameMaker.maker = nil; BookStitchingFrameMaker.activeMaking = {}; BookStitchingFrameMaker.totalProducts = 0; BookStitchingFrameMaker.dayTimer = 0
function BookStitchingFrameMaker.init() ... end
function BookStitchingFrameMaker.hireMaker(n,s) ... end
function BookStitchingFrameMaker.canBuild(id) ... end
function BookStitchingFrameMaker.build(id) ... end
function BookStitchingFrameMaker.getQualityBonus() ... end
function BookStitchingFrameMaker.canMake(pt) ... end
function BookStitchingFrameMaker.make(pt,qty) ... end
function BookStitchingFrameMaker.completeMaking(m) ... BookStitchingFrameMaker.productStock[m.productType]=(BookStitchingFrameMaker.productStock[m.productType] or 0)+m.quantity ... end
function BookStitchingFrameMaker.update(dt) ... end
function BookStitchingFrameMaker.getStats() ... end
return BookStitchingFrameMaker
```

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.611. Naslednji paket je v3.11.612–v3.11.621 (vrtni dodatki 3 + mlinarski dodatki 3: GardenHoeMaker, DibberMaker, GardenRakeMaker, PruningSawMaker, GardenWheelbarrowMaker, GrainAugerMaker, MillstoneDresserMaker, HopperGateMaker, FlourSieveMaker, BranSeparatorMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.612–v3.11.616: vrtni dodatki 3 (GardenHoeMaker, DibberMaker, GardenRakeMaker, PruningSawMaker, GardenWheelbarrowMaker)
- v3.11.617–v3.11.621: mlinarski dodatki 3 (GrainAugerMaker, MillstoneDresserMaker, HopperGateMaker, FlourSieveMaker, BranSeparatorMaker)
- v3.11.622–v3.11.626: steklarski dodatki 4 (predlagano)
- v3.11.627–v3.11.631: livarski dodatki 4 (predlagano)
