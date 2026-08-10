# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.396**
- Skupaj Royal sistemov: **484**
- Skupaj Lua datotek: **1133**
- Sintaktična preverba: **1130/1133 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## 🎉 NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 484 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.397–v3.11.401) — JERMENSKA OPREMA

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalSaddleMakerSystem.lua** → `local SaddleMaker` (sedla za konje)
2. **RoyalBridleMakerSystem.lua** → `local BridleMaker` (uzde)
3. **RoyalStirrupMakerSystem.lua** → `local StirrupMaker` (streme)
4. **RoyalHorseHarnessMakerSystem.lua** → `local HorseHarnessMaker` (jermene za konjsko vprego)
5. **RoyalSaddlebagMakerSystem.lua** → `local SaddlebagMaker` (sedlarne torbe)

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

3 točke za vsak sistem (najdi zadnji `S.WateringCanMaker` in dodaj za njim):

```lua
-- require block (po S.WateringCanMaker = require(...))
S.SaddleMaker = require("objects.Economy.RoyalSaddleMakerSystem")
S.BridleMaker = require("objects.Economy.RoyalBridleMakerSystem")
S.StirrupMaker = require("objects.Economy.RoyalStirrupMakerSystem")
S.HorseHarnessMaker = require("objects.Economy.RoyalHorseHarnessMakerSystem")
S.SaddlebagMaker = require("objects.Economy.RoyalSaddlebagMakerSystem")

-- init block (po S.WateringCanMaker.init(); ...)
S.SaddleMaker.init(); _G.SaddleMaker = S.SaddleMaker
S.BridleMaker.init(); _G.BridleMaker = S.BridleMaker
S.StirrupMaker.init(); _G.StirrupMaker = S.StirrupMaker
S.HorseHarnessMaker.init(); _G.HorseHarnessMaker = S.HorseHarnessMaker
S.SaddlebagMaker.init(); _G.SaddlebagMaker = S.SaddlebagMaker

-- update block (po S.WateringCanMaker.update(dt))
S.SaddleMaker.update(dt)
S.BridleMaker.update(dt)
S.StirrupMaker.update(dt)
S.HorseHarnessMaker.update(dt)
S.SaddlebagMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "saddle|bridle|stirrup|harness|saddlebag"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.397 do v3.11.401 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.396 → version-3.11.401
   - syntax-1130%2F1133 → syntax-1135%2F1138
   - Royal%20systems-484 → Royal%20systems-489
   - Lua%20files-1133 → Lua%20files-1138
7. Git: commit, tag (v3.11.397 do v3.11.401), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.401.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (jermenska oprema) spremeni:
- Imena produktov (npr. "železno sedlo", "železna uzda", "železno streme", "železni jermen za konjsko vprego", "železna sedlarna torba")
- Imena zgradb (sedlarska, uzdarska, stremska, jermenska, torbarska delavnica/hiša/atelje/palača)
- Maker ime (Sedlar, Uzdar, Stremar, Jermenar, Torbar)
- Event bus publish (saddle.completed, bridle.completed, stirrup.completed, harness.completed, saddlebag.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.396. Naslednji paket je v3.11.397–v3.11.401 (jermenska oprema: SaddleMaker, BridleMaker, StirrupMaker, HorseHarnessMaker, SaddlebagMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.402–v3.11.406 — predlagano: slikarska oprema: EaselMaker, PaintbrushMaker, PaletteMaker, PigmentGrinderMaker, CanvasStretcherMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.397–v3.11.401: jermenska oprema (SaddleMaker, BridleMaker, StirrupMaker, HorseHarnessMaker, SaddlebagMaker)
- v3.11.402–v3.11.406: slikarska oprema (EaselMaker, PaintbrushMaker, PaletteMaker, PigmentGrinderMaker, CanvasStretcherMaker)
- v3.11.407–v3.11.411: kuhinjska oprema (RollingPinMaker, CheeseGraterMaker, ButterChurnMaker, SpiceRackMaker, CuttingBoardMaker)
- v3.11.412–v3.11.416: steklarska oprema (GlassBlowerPipeMaker, GlassCutterMaker, GlassMoldMaker, AnnealingTongsMaker, GlassEngraverMaker)

