# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.581**
- Skupaj Royal sistemov: **669**
- Skupaj Lua datotek: **1318**
- Sintaktična preverba: **1315/1318 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 669 Royal sisteme z igro:

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

## ZADNJE ZAKLJUČENI PAKET (v3.11.572–v3.11.581) — PERESNI DODATKI 2 + VRTNI DODATKI 2

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Peresni dodatki 2 (v3.11.572-v3.11.576)
1. **RoyalQuillTrimmerMakerSystem.lua** → `local QuillTrimmerMaker` (strižniki peres)
2. **RoyalInkwellStopperMakerSystem.lua** → `local InkwellStopperMaker` (zamaški za črnilnice)
3. **RoyalPenRestMakerSystem.lua** → `local PenRestMaker` (počivališča za peresa)
4. **RoyalInkwellDustCoverMakerSystem.lua** → `local InkwellDustCoverMaker` (prevleke za črnilnice)
5. **RoyalQuillMenderMakerSystem.lua** → `local QuillMenderMaker` (popravjalci peres)

### Vrtni dodatki 2 (v3.11.577-v3.11.581)
6. **RoyalGardenForkMakerSystem.lua** → `local GardenForkMaker` (vrtne vilice)
7. **RoyalHandTrowelMakerSystem.lua** → `local HandTrowelMaker` (ročne lopatke)
8. **RoyalBulbPlanterMakerSystem.lua** → `local BulbPlanterMaker` (sadičniki za čebulnice)
9. **RoyalGardenLineMakerSystem.lua** → `local GardenLineMaker` (vrtna vrvica)
10. **RoyalColdFrameMakerSystem.lua** → `local ColdFrameMaker` (hladni okvirji)

### POPRAVKI BUGOV V GENERATORSKEM SKRIPTI (v3.11.581)
- Prejšnja generatorska skripta je pustila `${MAKER_LOWER}` placeholder v datotekah (v `id` polju in v event publish). Nova skripta pravilno substituira vse placeholderje.
- Prejšnja skripta je imela okvarjeno sintakso `productStock.productType]` (manjkajoči `[m.`). Nova skripta uporablja pravilno `productStock[m.productType]`.
- Nova generatorska skripta: `/home/z/my-project/scripts/generate_quill2_garden2_systems.py`
- Sintaktična preverba (lupa load()): vseh 10 novih datotek PASS.

## PATTERN ZA VSAK SISTEM

Vsak sistem mora imeti:
- 6 produktov (železni → bronasti → srebrni → pozlačeni → draguljasti → kraljevski suvereni)
- 4 zgradbe (delavnica, hiša, mojstrski atelje, suverena palača)
- Funkcije: `init`, `hireMaker`, `canBuild`, `build`, `getQualityBonus`, `canMake`, `make`, `completeMaking`, `update`, `getStats`
- `_G.NotificationCenter.notify` in `_G.GameEventBus.publish` s pcall
- Vrača lokalno tabelo
- Slovenian product/building names
- **POMEMBNO**: V `completeMaking` uporabljaj `productStock[m.productType]` (z `[m.` pred `productType]`) — ne `productStock.productType]` (to je okvarjena sintaksa)

## NASLEDNJI PAKET (v3.11.582–v3.11.591) — PEKOVSKI DODATKI 2 + KUHINJSKI DODATKI 2

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Pekovski dodatki 2 (v3.11.582-v3.11.586)
1. **RoyalDoughDividerMakerSystem.lua** → `local DoughDividerMaker` (delilniki testa)
2. **RoyalBreadMoldMakerSystem.lua** → `local BreadMoldMaker` (modeli za kruh)
3. **RoyalCrustScorerMakerSystem.lua** → `local CrustScorerMaker` (zarezalci skorje)
4. **RoyalLoafPanMakerSystem.lua** → `local LoafPanMaker` (pekači za hlebce)
5. **RoyalCrumbTrayMakerSystem.lua** → `local CrumbTrayMaker` (pladnji za drobtine)

### Kuhinjski dodatki 2 (v3.11.587-v3.11.591)
6. **RoyalEggCupMakerSystem.lua** → `local EggCupMaker` (skodelice za jajca)
7. **RoyalButterDishMakerSystem.lua** → `local ButterDishMaker` (posodice za maslo)
8. **RoyalCheeseDomeMakerSystem.lua** → `local CheeseDomeMaker` (klopoti za sir)
9. **RoyalServingTongsMakerSystem.lua** → `local ServingTongsMaker` (servirne klešče)
10. **RoyalSugarTongsMakerSystem.lua** → `local SugarTongsMaker` (sladkorne klešče)

## WORKFLOW ZA NASLEDNJI PAKET

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "doughdivider|breadmold|crustscorer|loafpan|crumbtray|eggcup|butterdish|cheesedome|servingtongs|sugartongs"` (mora biti prazno)
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py`
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.582 do v3.11.591 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.581 → version-3.11.591
   - syntax-1315%2F1318 → syntax-1325%2F1328
   - Royal%20systems-669 → Royal%20systems-679
   - Lua%20files-1318 → Lua%20files-1328
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.582 do v3.11.591), push (če je remote na voljo)
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.591.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"`

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_quill2_garden2_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_bakery2_kitchen2_systems.py`
2. Spremeni `QUILL2_SYSTEMS` in `GARDEN2_SYSTEMS` sezname v `BAKERY2_SYSTEMS` in `KITCHEN2_SYSTEMS` z novimi sistemi
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_bakery2_kitchen2_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam v tej skripti)

## PREDLOGA ZA SISTEM (primer QuillTrimmerMaker, kot referenca)

```lua
local QuillTrimmerMaker = {}
local PRODUCTS = {
    iron_quilltrimmer = { name = "Železni strižnik peres", ironCost = 3, woodCost = 2, leatherCost = 1, time = 5, cost = 150, prestige = 4, happiness = 2, description = "Železni strižnik peres za pisarje." },
    -- ... 5 more products (bronze, silver, gilded, jewel_set, royal_sovereign)
}
local BUILDINGS = {
    quilltrimmer_workshop = { name = "Quilltrimmer delavnica", cost = { gold = 325, wood = 185, stone = 130, iron = 7 }, upkeep = 6, qualityBonus = 5 },
    -- ... 3 more buildings (house, master_atelier, sovereign_palace)
}
QuillTrimmerMaker.ironStock=16; QuillTrimmerMaker.bronzeStock=12; ... QuillTrimmerMaker.pearlStock=4
QuillTrimmerMaker.productStock = {}; QuillTrimmerMaker.buildings = {}; QuillTrimmerMaker.maker = nil; QuillTrimmerMaker.activeMaking = {}; QuillTrimmerMaker.totalProducts = 0; QuillTrimmerMaker.dayTimer = 0
function QuillTrimmerMaker.init() ... end
function QuillTrimmerMaker.hireMaker(n,s) ... end
function QuillTrimmerMaker.canBuild(id) ... end
function QuillTrimmerMaker.build(id) ... end
function QuillTrimmerMaker.getQualityBonus() ... end
function QuillTrimmerMaker.canMake(pt) ... end
function QuillTrimmerMaker.make(pt,qty) ... end
function QuillTrimmerMaker.completeMaking(m) ... QuillTrimmerMaker.productStock[m.productType]=(QuillTrimmerMaker.productStock[m.productType] or 0)+m.quantity ... end
function QuillTrimmerMaker.update(dt) ... end
function QuillTrimmerMaker.getStats() ... end
return QuillTrimmerMaker
```

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.581. Naslednji paket je v3.11.582–v3.11.591 (pekovski dodatki 2 + kuhinjski dodatki 2: DoughDividerMaker, BreadMoldMaker, CrustScorerMaker, LoafPanMaker, CrumbTrayMaker, EggCupMaker, ButterDishMaker, CheeseDomeMaker, ServingTongsMaker, SugarTongsMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.592–v3.11.601 — predlagano: steklarski dodatki 3 + livarski dodatki 3).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.582–v3.11.586: pekovski dodatki 2 (DoughDividerMaker, BreadMoldMaker, CrustScorerMaker, LoafPanMaker, CrumbTrayMaker)
- v3.11.587–v3.11.591: kuhinjski dodatki 2 (EggCupMaker, ButterDishMaker, CheeseDomeMaker, ServingTongsMaker, SugarTongsMaker)
- v3.11.592–v3.11.596: steklarski dodatki 3 (predlagano)
- v3.11.597–v3.11.601: livarski dodatki 3 (predlagano)
