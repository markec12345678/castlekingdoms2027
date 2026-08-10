# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.426**
- Skupaj Royal sistemov: **514**
- Skupaj Lua datotek: **1163**
- Sintaktična preverba: **1160/1163 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## 🎉 NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 514 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.427–v3.11.431) — VRVARNA OPREMA

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalRopeMakerSystem.lua** → `local RopeMaker` (vrvi)
2. **RoyalTwineMakerSystem.lua** → `local TwineMaker` (špigelj)
3. **RoyalNetMakerSystem.lua** → `local NetMaker` (mreže)
4. **RoyalCordageMakerSystem.lua** → `local CordageMaker` (vrvice)
5. **RoyalKnotBoardMakerSystem.lua** → `local KnotBoardMaker` (tabele za vozle)

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

3 točke za vsak sistem (najdi zadnji `S.HatBoxMaker` in dodaj za njim):

```lua
-- require block (po S.HatBoxMaker = require(...))
S.RopeMaker = require("objects.Economy.RoyalRopeMakerSystem")
S.TwineMaker = require("objects.Economy.RoyalTwineMakerSystem")
S.NetMaker = require("objects.Economy.RoyalNetMakerSystem")
S.CordageMaker = require("objects.Economy.RoyalCordageMakerSystem")
S.KnotBoardMaker = require("objects.Economy.RoyalKnotBoardMakerSystem")

-- init block (po S.HatBoxMaker.init(); ...)
S.RopeMaker.init(); _G.RopeMaker = S.RopeMaker
S.TwineMaker.init(); _G.TwineMaker = S.TwineMaker
S.NetMaker.init(); _G.NetMaker = S.NetMaker
S.CordageMaker.init(); _G.CordageMaker = S.CordageMaker
S.KnotBoardMaker.init(); _G.KnotBoardMaker = S.KnotBoardMaker

-- update block (po S.HatBoxMaker.update(dt))
S.RopeMaker.update(dt)
S.TwineMaker.update(dt)
S.NetMaker.update(dt)
S.CordageMaker.update(dt)
S.KnotBoardMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "rope|twine|netmaker|cordage|knotboard"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.427 do v3.11.431 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.426 → version-3.11.431
   - syntax-1160%2F1163 → syntax-1165%2F1168
   - Royal%20systems-514 → Royal%20systems-519
   - Lua%20files-1163 → Lua%20files-1168
7. Git: commit, tag (v3.11.427 do v3.11.431), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.431.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (vrvarna oprema) spremeni:
- Imena produktov (npr. "železna vrv", "železni špigelj", "železna mreža", "železna vrvica", "železna tabla za vozle")
- Imena zgradb (vrvarna, špigeljna, mrežna, vrvnična, vozlena delavnica/hiša/atelje/palača)
- Maker ime (Vrvar, Špigeljar, Mrežar, Vrvničar, Vozlar)
- Event bus publish (rope.completed, twine.completed, net.completed, cordage.completed, knotboard.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.426. Naslednji paket je v3.11.427–v3.11.431 (vrvarna oprema: RopeMaker, TwineMaker, NetMaker, CordageMaker, KnotBoardMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.432–v3.11.436 — predlagano: česlarska oprema: CombMaker, HairbrushMaker, HairpinMaker, BeardCombMaker, LiceCombMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.427–v3.11.431: vrvarna oprema (RopeMaker, TwineMaker, NetMaker, CordageMaker, KnotBoardMaker)
- v3.11.432–v3.11.436: česlarska oprema (CombMaker, HairbrushMaker, HairpinMaker, BeardCombMaker, LiceCombMaker)
- v3.11.437–v3.11.441: sedlarski dodatki (SaddleSoapMaker, SaddlePolishMaker, LeatherConditionerMaker, StirrupLeatherMaker, BridleBuckleMaker)
- v3.11.442–v3.11.446: voščena oprema (CandleMoldMaker, WickSpinnerMaker, WaxDipperMaker, CandlestickBaseMaker, TaperRollerMaker)

