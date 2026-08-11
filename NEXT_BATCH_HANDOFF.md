# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.471**
- Skupaj Royal sistemov: **559**
- Skupaj Lua datotek: **1208**
- Sintaktična preverba: **1205/1208 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## 🎉 NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 559 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.472–v3.11.476) — TKALSKA OPREMA

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalLoomHeddleMakerSystem.lua** → `local LoomHeddleMaker` (listovnice za statve)
2. **RoyalShuttleMakerSystem.lua** → `local ShuttleMaker` (čolničke za tkanje)
3. **RoyalBobbinWinderMakerSystem.lua** → `local BobbinWinderMaker` (navijalce vretencev)
4. **RoyalWarpBeamMakerSystem.lua** → `local WarpBeamMaker` (osnovne gredice)
5. **RoyalClothPresserMakerSystem.lua** → `local ClothPresserMaker` (stiskalce tkanin)

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

3 točke za vsak sistem (najdi zadnji `S.GlassFritMaker` in dodaj za njim):

```lua
-- require block (po S.GlassFritMaker = require(...))
S.LoomHeddleMaker = require("objects.Economy.RoyalLoomHeddleMakerSystem")
S.ShuttleMaker = require("objects.Economy.RoyalShuttleMakerSystem")
S.BobbinWinderMaker = require("objects.Economy.RoyalBobbinWinderMakerSystem")
S.WarpBeamMaker = require("objects.Economy.RoyalWarpBeamMakerSystem")
S.ClothPresserMaker = require("objects.Economy.RoyalClothPresserMakerSystem")

-- init block (po S.GlassFritMaker.init(); ...)
S.LoomHeddleMaker.init(); _G.LoomHeddleMaker = S.LoomHeddleMaker
S.ShuttleMaker.init(); _G.ShuttleMaker = S.ShuttleMaker
S.BobbinWinderMaker.init(); _G.BobbinWinderMaker = S.BobbinWinderMaker
S.WarpBeamMaker.init(); _G.WarpBeamMaker = S.WarpBeamMaker
S.ClothPresserMaker.init(); _G.ClothPresserMaker = S.ClothPresserMaker

-- update block (po S.GlassFritMaker.update(dt))
S.LoomHeddleMaker.update(dt)
S.ShuttleMaker.update(dt)
S.BobbinWinderMaker.update(dt)
S.WarpBeamMaker.update(dt)
S.ClothPresserMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "loomheddle|shuttle|bobbinwinder|warpbeam|clothpresser"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.472 do v3.11.476 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.471 → version-3.11.476
   - syntax-1205%2F1208 → syntax-1210%2F1213
   - Royal%20systems-559 → Royal%20systems-564
   - Lua%20files-1208 → Lua%20files-1213
7. Git: commit, tag (v3.11.472 do v3.11.476), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.476.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (tkalska oprema) spremeni:
- Imena produktov (npr. "železna listovnica za statve", "železni čolniček za tkanje", "železni navijalec vretencev", "železna osnovna gredica", "železno stiskalec tkanin")
- Imena zgradb (listovnična, čolnična, navijalna, gredična, stiskalna delavnica/hiša/atelje/palača)
- Maker ime (Listar, Čolničar, Navijalec, Gredičar, Stiskalec)
- Event bus publish (loomheddle.completed, shuttle.completed, bobbinwinder.completed, warpbeam.completed, clothpresser.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.471. Naslednji paket je v3.11.472–v3.11.476 (tkalska oprema: LoomHeddleMaker, ShuttleMaker, BobbinWinderMaker, WarpBeamMaker, ClothPresserMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.477–v3.11.481 — predlagano: knjigoveška oprema: BookPressMaker, StitchingAwlMaker, BindingCordMaker, LeatherCoverMaker, GildingPressMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.472–v3.11.476: tkalska oprema (LoomHeddleMaker, ShuttleMaker, BobbinWinderMaker, WarpBeamMaker, ClothPresserMaker)
- v3.11.477–v3.11.481: knjigoveška oprema (BookPressMaker, StitchingAwlMaker, BindingCordMaker, LeatherCoverMaker, GildingPressMaker)
- v3.11.482–v3.11.486: peresna oprema (QuillCutterMaker, InkwellMaker, ParchmentRackMaker, WaxTabletMaker, WritingStandMaker)
- v3.11.487–v3.11.491: kovanska oprema (CoinPressMaker, CoinDieMaker, CoinBlankMaker, CoinSorterMaker, CoinScaleMaker)

