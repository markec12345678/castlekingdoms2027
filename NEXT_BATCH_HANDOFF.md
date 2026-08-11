# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.441**
- Skupaj Royal sistemov: **529**
- Skupaj Lua datotek: **1178**
- Sintaktična preverba: **1175/1178 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## 🎉 NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 529 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.442–v3.11.446) — VOŠČENA OPREMA

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalCandleMoldMakerSystem.lua** → `local CandleMoldMaker` (modeli za sveče)
2. **RoyalWickSpinnerMakerSystem.lua** → `local WickSpinnerMaker` (predilnice za fitilje)
3. **RoyalWaxDipperMakerSystem.lua** → `local WaxDipperMaker` (potapljalci za voskom)
4. **RoyalCandlestickBaseMakerSystem.lua** → `local CandlestickBaseMaker` (podstavki za svečnike)
5. **RoyalTaperRollerMakerSystem.lua** → `local TaperRollerMaker` (valjarji za tanke sveče)

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

3 točke za vsak sistem (najdi zadnji `S.BridleBuckleMaker` in dodaj za njim):

```lua
-- require block (po S.BridleBuckleMaker = require(...))
S.CandleMoldMaker = require("objects.Economy.RoyalCandleMoldMakerSystem")
S.WickSpinnerMaker = require("objects.Economy.RoyalWickSpinnerMakerSystem")
S.WaxDipperMaker = require("objects.Economy.RoyalWaxDipperMakerSystem")
S.CandlestickBaseMaker = require("objects.Economy.RoyalCandlestickBaseMakerSystem")
S.TaperRollerMaker = require("objects.Economy.RoyalTaperRollerMakerSystem")

-- init block (po S.BridleBuckleMaker.init(); ...)
S.CandleMoldMaker.init(); _G.CandleMoldMaker = S.CandleMoldMaker
S.WickSpinnerMaker.init(); _G.WickSpinnerMaker = S.WickSpinnerMaker
S.WaxDipperMaker.init(); _G.WaxDipperMaker = S.WaxDipperMaker
S.CandlestickBaseMaker.init(); _G.CandlestickBaseMaker = S.CandlestickBaseMaker
S.TaperRollerMaker.init(); _G.TaperRollerMaker = S.TaperRollerMaker

-- update block (po S.BridleBuckleMaker.update(dt))
S.CandleMoldMaker.update(dt)
S.WickSpinnerMaker.update(dt)
S.WaxDipperMaker.update(dt)
S.CandlestickBaseMaker.update(dt)
S.TaperRollerMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "candlemold|wickspinner|waxdipper|candlestickbase|taperroller"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.442 do v3.11.446 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.441 → version-3.11.446
   - syntax-1175%2F1178 → syntax-1180%2F1183
   - Royal%20systems-529 → Royal%20systems-534
   - Lua%20files-1178 → Lua%20files-1183
7. Git: commit, tag (v3.11.442 do v3.11.446), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.446.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (voščena oprema) spremeni:
- Imena produktov (npr. "železni model za sveče", "železna predilnica za fitilje", "železni potapljalce za voskom", "železni podstavka za svečnik", "železni valjalec za tanke sveče")
- Imena zgradb (modelna, predilna, potapljajoča, podstavkarska, valjalna delavnica/hiša/atelje/palača)
- Maker ime (Modelar, Predilnik, Potapljač, Podstavkar, Valjalec)
- Event bus publish (candlemold.completed, wickspinner.completed, waxdipper.completed, candlestickbase.completed, taperroller.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.441. Naslednji paket je v3.11.442–v3.11.446 (voščena oprema: CandleMoldMaker, WickSpinnerMaker, WaxDipperMaker, CandlestickBaseMaker, TaperRollerMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.447–v3.11.451 — predlagano: livarska oprema: CrucibleMaker, SandMoldMaker, IngotMoldMaker, FlaskMaker, CastingLadleMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.442–v3.11.446: voščena oprema (CandleMoldMaker, WickSpinnerMaker, WaxDipperMaker, CandlestickBaseMaker, TaperRollerMaker)
- v3.11.447–v3.11.451: livarska oprema (CrucibleMaker, SandMoldMaker, IngotMoldMaker, FlaskMaker, CastingLadleMaker)
- v3.11.452–v3.11.456: kovaška orodja (TongMaker, HammerMaker, AnvilMaker, BellowsMaker, ForgeTongsMaker)
- v3.11.457–v3.11.461: mizarstvo (PlaneIronMaker, ChiselBladeMaker, SawSetMaker, AugerBitMaker, ClampMaker)

