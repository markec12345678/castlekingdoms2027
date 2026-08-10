# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.391**
- Skupaj Royal sistemov: **479**
- Skupaj Lua datotek: **1128**
- Sintaktična preverba: **1125/1128 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## 🎉 NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 479 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.392–v3.11.396) — VRTNARSKA OPREMA

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalPruningShearsMakerSystem.lua** → `local PruningShearsMaker` (škarje za obrezovanje)
2. **RoyalTopiaryFrameMakerSystem.lua** → `local TopiaryFrameMaker` (okvirji za topiary)
3. **RoyalGardenTrowelMakerSystem.lua** → `local GardenTrowelMaker` (vrtni lopatki)
4. **RoyalHedgeHookMakerSystem.lua** → `local HedgeHookMaker` (kavlji za živo mejo)
5. **RoyalWateringCanMakerSystem.lua** → `local WateringCanMaker` (zalivalke)

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

3 točke za vsak sistem (najdi zadnji `S.PhysicPotionMaker` in dodaj za njim):

```lua
-- require block (po S.PhysicPotionMaker = require(...))
S.PruningShearsMaker = require("objects.Economy.RoyalPruningShearsMakerSystem")
S.TopiaryFrameMaker = require("objects.Economy.RoyalTopiaryFrameMakerSystem")
S.GardenTrowelMaker = require("objects.Economy.RoyalGardenTrowelMakerSystem")
S.HedgeHookMaker = require("objects.Economy.RoyalHedgeHookMakerSystem")
S.WateringCanMaker = require("objects.Economy.RoyalWateringCanMakerSystem")

-- init block (po S.PhysicPotionMaker.init(); ...)
S.PruningShearsMaker.init(); _G.PruningShearsMaker = S.PruningShearsMaker
S.TopiaryFrameMaker.init(); _G.TopiaryFrameMaker = S.TopiaryFrameMaker
S.GardenTrowelMaker.init(); _G.GardenTrowelMaker = S.GardenTrowelMaker
S.HedgeHookMaker.init(); _G.HedgeHookMaker = S.HedgeHookMaker
S.WateringCanMaker.init(); _G.WateringCanMaker = S.WateringCanMaker

-- update block (po S.PhysicPotionMaker.update(dt))
S.PruningShearsMaker.update(dt)
S.TopiaryFrameMaker.update(dt)
S.GardenTrowelMaker.update(dt)
S.HedgeHookMaker.update(dt)
S.WateringCanMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "pruning|topiary|trowel|hedge|watering"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.392 do v3.11.396 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.391 → version-3.11.396
   - syntax-1125%2F1128 → syntax-1130%2F1133
   - Royal%20systems-479 → Royal%20systems-484
   - Lua%20files-1128 → Lua%20files-1133
7. Git: commit, tag (v3.11.392 do v3.11.396), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.396.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (vrtnarska oprema) spremeni:
- Imena produktov (npr. "železne škarje za obrezovanje", "železni okvir za topiary", "železna vrtna lopatka", "železni kavelj za živo mejo", "železna zalivalka")
- Imena zgradb (vrtnarska, topiarijska, lopatkarska, kaveljska, zalivalna delavnica/hiša/atelje/palača)
- Maker ime (Vrtnar, Topiarist, Lopatkar, Kaveljar, Zalivalec)
- Event bus publish (shears.completed, topiary.completed, trowel.completed, hedge.completed, watering.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.391. Naslednji paket je v3.11.392–v3.11.396 (vrtnarska oprema: PruningShearsMaker, TopiaryFrameMaker, GardenTrowelMaker, HedgeHookMaker, WateringCanMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.397–v3.11.401 — predlagano: jermenska oprema: SaddleMaker, BridleMaker, StirrupMaker, HorseHarnessMaker, SaddlebagMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.392–v3.11.396: vrtnarska oprema (PruningShearsMaker, TopiaryFrameMaker, GardenTrowelMaker, HedgeHookMaker, WateringCanMaker)
- v3.11.397–v3.11.401: jermenska oprema (SaddleMaker, BridleMaker, StirrupMaker, HorseHarnessMaker, SaddlebagMaker)
- v3.11.402–v3.11.406: slikarska oprema (EaselMaker, PaintbrushMaker, PaletteMaker, PigmentGrinderMaker, CanvasStretcherMaker)
- v3.11.407–v3.11.411: kuhinjska oprema (RollingPinMaker, CheeseGraterMaker, ButterChurnMaker, SpiceRackMaker, CuttingBoardMaker)

