# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.571**
- Skupaj Royal sistemov: **659**
- Skupaj Lua datotek: **1308**
- Sintaktična preverba: **1305/1308 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 659 Royal sisteme z igro:

- **`objects/Economy/RoyalSystemsRegistry.lua`** — auto-discovers vse sisteme, hook-a `completeMaking()`, dodeli bonus zlato (prestige × 10) ob končanem produktu
- **`states/ui/hud/royal_systems_panel.lua`** — full-screen UI panel (toggle s Ctrl+R), ki omogoča brskanje, najem mojstrov, gradnjo delavnic, izdelavo produktov, prodajo zalog
- **`states/ui/hud/keybind_help.lua`** — dodana Ctrl+R bližnjica
- **`scripts/test_registry.lua`** — test skripta (poženi z lupa)

Vsi novi sistemi, dodani po v3.11.382, so samodejno odkriti in prikazani v panelu — ni potrebe po ročni registraciji v Registry.

## ZNANE NADGRADNJE ZA PRIHODNJE PAKETE

1. **Povezava z DynamicMarketSystem** — Royal produkti naj bodo prodani na tržnici
2. **Sprite-i za Royal sisteme** — trenutno so samo podatkovni, brez grafične podobe
3. **Grafikon produkcije** — zgodovina proizvodnje v panelu
4. **Sistemsko odvisnosti** — nekateri sistemi naj zahtevajo druge (npr. BellMaker zahteva Metalwork)

## NASLEDNJI PAKET (v3.11.572–v3.11.576) — PERESNI DODATKI 2

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalQuillTrimmerMakerSystem.lua** → `local QuillTrimmerMaker` (strižniki peres)
2. **RoyalInkwellStopperMakerSystem.lua** → `local InkwellStopperMaker` (zamaški za črnilnice)
3. **RoyalPenRestMakerSystem.lua** → `local PenRestMaker` (počivališča za peresa)
4. **RoyalInkwellDustCoverMakerSystem.lua** → `local InkwellDustCoverMaker` (prevleke za črnilnice)
5. **RoyalQuillMenderMakerSystem.lua** → `local QuillMenderMaker` (popravjalci peres)

## PATTERN ZA VSAK SISTEM

Vsak sistem mora imeti:
- 6 produktov (železni → bronasti → srebrni → pozlačeni → draguljasti → kraljevski suvereni)
- 4 zgradbe (delavnica, hiša, mojstrski atelje, suverena palača)
- Funkcije: `init`, `hireMaker`, `canBuild`, `build`, `getQualityBonus`, `canMake`, `make`, `completeMaking`, `update`, `getStats`
- `_G.NotificationCenter.notify` in `_G.GameEventBus.publish` s pcall
- Vrača lokalno tabelo
- Slovenian product/building names
- **POMEMBNO**: V `completeMaking` uporabljaj `productStock[m.productType]` (z `[m.` pred `productType]`) — ne `productStock.productType]` (to je okvarjena sintaksa)

## REGISTRACIJA V states/game.lua

3 točke za vsak sistem (najdi zadnji `S.MillstoneCraneMaker` in dodaj za njim):

```lua
-- require block (po S.MillstoneCraneMaker = require(...))
S.QuillTrimmerMaker = require("objects.Economy.RoyalQuillTrimmerMakerSystem")
S.InkwellStopperMaker = require("objects.Economy.RoyalInkwellStopperMakerSystem")
S.PenRestMaker = require("objects.Economy.RoyalPenRestMakerSystem")
S.InkwellDustCoverMaker = require("objects.Economy.RoyalInkwellDustCoverMakerSystem")
S.QuillMenderMaker = require("objects.Economy.RoyalQuillMenderMakerSystem")

-- init block (po S.MillstoneCraneMaker.init(); ...)
S.QuillTrimmerMaker.init(); _G.QuillTrimmerMaker = S.QuillTrimmerMaker
S.InkwellStopperMaker.init(); _G.InkwellStopperMaker = S.InkwellStopperMaker
S.PenRestMaker.init(); _G.PenRestMaker = S.PenRestMaker
S.InkwellDustCoverMaker.init(); _G.InkwellDustCoverMaker = S.InkwellDustCoverMaker
S.QuillMenderMaker.init(); _G.QuillMenderMaker = S.QuillMenderMaker

-- update block (po S.MillstoneCraneMaker.update(dt))
S.QuillTrimmerMaker.update(dt)
S.InkwellStopperMaker.update(dt)
S.PenRestMaker.update(dt)
S.InkwellDustCoverMaker.update(dt)
S.QuillMenderMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "quilltrimmer|inkwellstopper|penrest|inkwelldustcover|quillmender"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.572 do v3.11.576 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.571 → version-3.11.576
   - syntax-1305%2F1308 → syntax-1310%2F1313
   - Royal%20systems-659 → Royal%20systems-664
   - Lua%20files-1308 → Lua%20files-1313
7. Git: commit, tag (v3.11.572 do v3.11.576), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.576.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

## PREDLOGA ZA SISTEM (primer PickaxeMaker, kot referenca)

```lua
local PickaxeMaker = {}
local PRODUCTS = {
    iron_pickaxe = { name = "Železno kramp", ironCost = 2, woodCost = 2, leatherCost = 1, time = 5, cost = 130, prestige = 2, happiness = 1, description = "Železno kramp za rudarjenje." },
    -- ... 5 more products
}
local BUILDINGS = {
    pickaxe_workshop = { name = "Rudarska delavnica", cost = { gold = 300, wood = 160, stone = 120, iron = 6 }, upkeep = 6, qualityBonus = 5 },
    -- ... 3 more buildings
}
PickaxeMaker.ironStock = 12; PickaxeMaker.bronzeStock = 10; ... PickaxeMaker.pearlStock = 4
PickaxeMaker.productStock = {}; PickaxeMaker.buildings = {}; PickaxeMaker.maker = nil; PickaxeMaker.activeMaking = {}; PickaxeMaker.totalProducts = 0; PickaxeMaker.dayTimer = 0
function PickaxeMaker.init() ... end
function PickaxeMaker.hireMaker(n,s) ... end
function PickaxeMaker.canBuild(id) ... end
function PickaxeMaker.build(id) ... end
function PickaxeMaker.getQualityBonus() ... end
function PickaxeMaker.canMake(pt) ... end
function PickaxeMaker.make(pt,qty) ... end
function PickaxeMaker.completeMaking(m) ... PickaxeMaker.productStock[m.productType]=(PickaxeMaker.productStock[m.productType] or 0)+m.quantity ... end
function PickaxeMaker.update(dt) ... end
function PickaxeMaker.getStats() ... end
return PickaxeMaker
```

Za nove 5 sistemov (peresni dodatki 2) spremeni:
- Imena produktov (npr. "železni strižnik peres", "železni zamašek za črnilnico", "železno počivališče za peresa", "železna prevleka za črnilnico", "železni popravjalec peres")
- Imena zgradb (strižna, zamašna, počivalna, prevlečna, popravljena delavnica/hiša/atelje/palača)
- Maker ime (Strižnik, Zamaškar, Počivalec, Prevlekar, Popravljalec)
- Event bus publish (quilltrimmer.completed, inkwellstopper.completed, penrest.completed, inkwelldustcover.completed, quillmender.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.571. Naslednji paket je v3.11.572–v3.11.576 (peresni dodatki 2: QuillTrimmerMaker, InkwellStopperMaker, PenRestMaker, InkwellDustCoverMaker, QuillMenderMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.577–v3.11.581 — predlagano: vrtni dodatki 2: GardenForkMaker, HandTrowelMaker, BulbPlanterMaker, GardenLineMaker, ColdFrameMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.572–v3.11.576: peresni dodatki 2 (QuillTrimmerMaker, InkwellStopperMaker, PenRestMaker, InkwellDustCoverMaker, QuillMenderMaker)
- v3.11.577–v3.11.581: vrtni dodatki 2 (GardenForkMaker, HandTrowelMaker, BulbPlanterMaker, GardenLineMaker, ColdFrameMaker)
- v3.11.582–v3.11.586: pekovski dodatki 2 (DoughDividerMaker, BreadMoldMaker, CrustScorerMaker, LoafPanMaker, CrumbTrayMaker)
- v3.11.587–v3.11.591: kuhinjski dodatki 2 (EggCupMaker, ButterDishMaker, CheeseDomeMaker, ServingTongsMaker, SugarTongsMaker)
