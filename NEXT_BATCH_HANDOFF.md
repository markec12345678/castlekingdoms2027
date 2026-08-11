# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.456**
- Skupaj Royal sistemov: **544**
- Skupaj Lua datotek: **1193**
- Sintaktična preverba: **1190/1193 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## 🎉 NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 544 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.457–v3.11.461) — MIZARSTVO

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalPlaneIronMakerSystem.lua** → `local PlaneIronMaker` (železa za glodalnike)
2. **RoyalChiselBladeMakerSystem.lua** → `local ChiselBladeMaker` (rezila za dleta)
3. **RoyalSawSetMakerSystem.lua** → `local SawSetMaker` (nastavljive žage)
4. **RoyalAugerBitMakerSystem.lua** → `local AugerBitMaker` (svrdri za vrtanje)
5. **RoyalClampMakerSystem.lua** → `local ClampMaker` (štspanke)

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

3 točke za vsak sistem (najdi zadnji `S.ForgeTongsMaker` in dodaj za njim):

```lua
-- require block (po S.ForgeTongsMaker = require(...))
S.PlaneIronMaker = require("objects.Economy.RoyalPlaneIronMakerSystem")
S.ChiselBladeMaker = require("objects.Economy.RoyalChiselBladeMakerSystem")
S.SawSetMaker = require("objects.Economy.RoyalSawSetMakerSystem")
S.AugerBitMaker = require("objects.Economy.RoyalAugerBitMakerSystem")
S.ClampMaker = require("objects.Economy.RoyalClampMakerSystem")

-- init block (po S.ForgeTongsMaker.init(); ...)
S.PlaneIronMaker.init(); _G.PlaneIronMaker = S.PlaneIronMaker
S.ChiselBladeMaker.init(); _G.ChiselBladeMaker = S.ChiselBladeMaker
S.SawSetMaker.init(); _G.SawSetMaker = S.SawSetMaker
S.AugerBitMaker.init(); _G.AugerBitMaker = S.AugerBitMaker
S.ClampMaker.init(); _G.ClampMaker = S.ClampMaker

-- update block (po S.ForgeTongsMaker.update(dt))
S.PlaneIronMaker.update(dt)
S.ChiselBladeMaker.update(dt)
S.SawSetMaker.update(dt)
S.AugerBitMaker.update(dt)
S.ClampMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "planeiron|chiselblade|sawset|augerbit|clampmaker"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.457 do v3.11.461 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.456 → version-3.11.461
   - syntax-1190%2F1193 → syntax-1195%2F1198
   - Royal%20systems-544 → Royal%20systems-549
   - Lua%20files-1193 → Lua%20files-1198
7. Git: commit, tag (v3.11.457 do v3.11.461), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.461.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (mizarstvo) spremeni:
- Imena produktov (npr. "železna železa za glodalnik", "železno rezilo za dleto", "železna nastavljiva žaga", "železni svrder za vrtanje", "železna štspanka")
- Imena zgradb (gladilna, rezilna, žagarska, vrtalna, štspančna delavnica/hiša/atelje/palača)
- Maker ime (Gladar, Rezar, Žagar, Vrtač, Štspankar)
- Event bus publish (planeiron.completed, chiselblade.completed, sawset.completed, augerbit.completed, clamp.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.456. Naslednji paket je v3.11.457–v3.11.461 (mizarstvo: PlaneIronMaker, ChiselBladeMaker, SawSetMaker, AugerBitMaker, ClampMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.462–v3.11.466 — predlagano: keramična oprema: PotteryWheelMaker, KilnFurnitureMaker, ClayExtruderMaker, GlazeSieveMaker, BisqueStandMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.457–v3.11.461: mizarstvo (PlaneIronMaker, ChiselBladeMaker, SawSetMaker, AugerBitMaker, ClampMaker)
- v3.11.462–v3.11.466: keramična oprema (PotteryWheelMaker, KilnFurnitureMaker, ClayExtruderMaker, GlazeSieveMaker, BisqueStandMaker)
- v3.11.467–v3.11.471: steklarska dodatki (GlassBatchMaker, GlassColorantMaker, GlassSeedMaker, GlassRibbonMaker, GlassFritMaker)
- v3.11.472–v3.11.476: tkalska oprema (LoomHeddleMaker, ShuttleMaker, BobbinWinderMaker, WarpBeamMaker, ClothPresserMaker)

