# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.461**
- Skupaj Royal sistemov: **549**
- Skupaj Lua datotek: **1198**
- Sintaktična preverba: **1195/1198 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## 🎉 NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 549 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.462–v3.11.466) — KERAMIČNA OPREMA

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalPotteryWheelMakerSystem.lua** → `local PotteryWheelMaker` (lončarska kolesa)
2. **RoyalKilnFurnitureMakerSystem.lua** → `local KilnFurnitureMaker` (pešice za peči)
3. **RoyalClayExtruderMakerSystem.lua** → `local ClayExtruderMaker` (ekstruderji za glino)
4. **RoyalGlazeSieveMakerSystem.lua** → `local GlazeSieveMaker` (sitata za glazure)
5. **RoyalBisqueStandMakerSystem.lua** → `local BisqueStandMaker` (stojala za žganje keramike)

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

3 točke za vsak sistem (najdi zadnji `S.ClampMaker` in dodaj za njim):

```lua
-- require block (po S.ClampMaker = require(...))
S.PotteryWheelMaker = require("objects.Economy.RoyalPotteryWheelMakerSystem")
S.KilnFurnitureMaker = require("objects.Economy.RoyalKilnFurnitureMakerSystem")
S.ClayExtruderMaker = require("objects.Economy.RoyalClayExtruderMakerSystem")
S.GlazeSieveMaker = require("objects.Economy.RoyalGlazeSieveMakerSystem")
S.BisqueStandMaker = require("objects.Economy.RoyalBisqueStandMakerSystem")

-- init block (po S.ClampMaker.init(); ...)
S.PotteryWheelMaker.init(); _G.PotteryWheelMaker = S.PotteryWheelMaker
S.KilnFurnitureMaker.init(); _G.KilnFurnitureMaker = S.KilnFurnitureMaker
S.ClayExtruderMaker.init(); _G.ClayExtruderMaker = S.ClayExtruderMaker
S.GlazeSieveMaker.init(); _G.GlazeSieveMaker = S.GlazeSieveMaker
S.BisqueStandMaker.init(); _G.BisqueStandMaker = S.BisqueStandMaker

-- update block (po S.ClampMaker.update(dt))
S.PotteryWheelMaker.update(dt)
S.KilnFurnitureMaker.update(dt)
S.ClayExtruderMaker.update(dt)
S.GlazeSieveMaker.update(dt)
S.BisqueStandMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "potterywheel|kilnfurniture|clayextruder|glazesieve|bisquestand"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.462 do v3.11.466 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.461 → version-3.11.466
   - syntax-1195%2F1198 → syntax-1200%2F1203
   - Royal%20systems-549 → Royal%20systems-554
   - Lua%20files-1198 → Lua%20files-1203
7. Git: commit, tag (v3.11.462 do v3.11.466), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.466.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (keramična oprema) spremeni:
- Imena produktov (npr. "železno lončarsko kolo", "železne pešice za peči", "železni ekstruder za glino", "železno sito za glazure", "železno stojalo za žganje keramike")
- Imena zgradb (lončarska, pešična, ekstruderska, sitna, stojalna delavnica/hiša/atelje/palača)
- Maker ime (Lončar, Pešičar, Ekstruderar, Sitar, Stojalar)
- Event bus publish (potterywheel.completed, kilnfurniture.completed, clayextruder.completed, glazesieve.completed, bisquestand.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.461. Naslednji paket je v3.11.462–v3.11.466 (keramična oprema: PotteryWheelMaker, KilnFurnitureMaker, ClayExtruderMaker, GlazeSieveMaker, BisqueStandMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.467–v3.11.471 — predlagano: steklarski dodatki: GlassBatchMaker, GlassColorantMaker, GlassSeedMaker, GlassRibbonMaker, GlassFritMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.462–v3.11.466: keramična oprema (PotteryWheelMaker, KilnFurnitureMaker, ClayExtruderMaker, GlazeSieveMaker, BisqueStandMaker)
- v3.11.467–v3.11.471: steklarski dodatki (GlassBatchMaker, GlassColorantMaker, GlassSeedMaker, GlassRibbonMaker, GlassFritMaker)
- v3.11.472–v3.11.476: tkalska oprema (LoomHeddleMaker, ShuttleMaker, BobbinWinderMaker, WarpBeamMaker, ClothPresserMaker)
- v3.11.477–v3.11.481: knjigoveška oprema (BookPressMaker, StitchingAwlMaker, BindingCordMaker, LeatherCoverMaker, GildingPressMaker)

