# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.406**
- Skupaj Royal sistemov: **494**
- Skupaj Lua datotek: **1143**
- Sintaktična preverba: **1140/1143 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## 🎉 NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 494 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.407–v3.11.411) — KUHINJSKA OPREMA

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalRollingPinMakerSystem.lua** → `local RollingPinMaker` (valjki za testo)
2. **RoyalCheeseGraterMakerSystem.lua** → `local CheeseGraterMaker` (ribniki za sir)
3. **RoyalButterChurnMakerSystem.lua** → `local ButterChurnMaker` (kadi za maslo)
4. **RoyalSpiceRackMakerSystem.lua** → `local SpiceRackMaker` (stojala za začimbe)
5. **RoyalCuttingBoardMakerSystem.lua** → `local CuttingBoardMaker` (deske za rezanje)

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

3 točke za vsak sistem (najdi zadnji `S.CanvasStretcherMaker` in dodaj za njim):

```lua
-- require block (po S.CanvasStretcherMaker = require(...))
S.RollingPinMaker = require("objects.Economy.RoyalRollingPinMakerSystem")
S.CheeseGraterMaker = require("objects.Economy.RoyalCheeseGraterMakerSystem")
S.ButterChurnMaker = require("objects.Economy.RoyalButterChurnMakerSystem")
S.SpiceRackMaker = require("objects.Economy.RoyalSpiceRackMakerSystem")
S.CuttingBoardMaker = require("objects.Economy.RoyalCuttingBoardMakerSystem")

-- init block (po S.CanvasStretcherMaker.init(); ...)
S.RollingPinMaker.init(); _G.RollingPinMaker = S.RollingPinMaker
S.CheeseGraterMaker.init(); _G.CheeseGraterMaker = S.CheeseGraterMaker
S.ButterChurnMaker.init(); _G.ButterChurnMaker = S.ButterChurnMaker
S.SpiceRackMaker.init(); _G.SpiceRackMaker = S.SpiceRackMaker
S.CuttingBoardMaker.init(); _G.CuttingBoardMaker = S.CuttingBoardMaker

-- update block (po S.CanvasStretcherMaker.update(dt))
S.RollingPinMaker.update(dt)
S.CheeseGraterMaker.update(dt)
S.ButterChurnMaker.update(dt)
S.SpiceRackMaker.update(dt)
S.CuttingBoardMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "rolling|grater|churn|spice|cutting"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.407 do v3.11.411 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.406 → version-3.11.411
   - syntax-1140%2F1143 → syntax-1145%2F1148
   - Royal%20systems-494 → Royal%20systems-499
   - Lua%20files-1143 → Lua%20files-1148
7. Git: commit, tag (v3.11.407 do v3.11.411), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.411.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (kuhinjska oprema) spremeni:
- Imena produktov (npr. "železni valjek za testo", "železni ribnik za sir", "železna kada za maslo", "železno stojalo za začimbe", "železna deska za rezanje")
- Imena zgradb (valjarska, ribniška, kadna, začimbična, rezalna delavnica/hiša/atelje/palača)
- Maker ime (Valjar, Ribnikar, Kadar, Začimbar, Rezar)
- Event bus publish (rollingpin.completed, cheesegrater.completed, butterchurn.completed, spicerack.completed, cuttingboard.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.406. Naslednji paket je v3.11.407–v3.11.411 (kuhinjska oprema: RollingPinMaker, CheeseGraterMaker, ButterChurnMaker, SpiceRackMaker, CuttingBoardMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.412–v3.11.416 — predlagano: steklarska oprema: GlassBlowerPipeMaker, GlassCutterMaker, GlassMoldMaker, AnnealingTongsMaker, GlassEngraverMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.407–v3.11.411: kuhinjska oprema (RollingPinMaker, CheeseGraterMaker, ButterChurnMaker, SpiceRackMaker, CuttingBoardMaker)
- v3.11.412–v3.11.416: steklarska oprema (GlassBlowerPipeMaker, GlassCutterMaker, GlassMoldMaker, AnnealingTongsMaker, GlassEngraverMaker)
- v3.11.417–v3.11.421: mlinarska oprema (MillstoneMaker, FlourSifterMaker, DoughHookMaker, GrainHopperMaker, SackLoaderMaker)
- v3.11.422–v3.11.426: klobučarska oprema (HatBlockMaker, HatBandMaker, HatPinMaker, HatFeatherMaker, HatBoxMaker)

