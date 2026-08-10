# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.431**
- Skupaj Royal sistemov: **519**
- Skupaj Lua datotek: **1168**
- Sintaktična preverba: **1165/1168 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## 🎉 NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 519 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.432–v3.11.436) — ČESLARSKA OPREMA

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalCombMakerSystem.lua** → `local CombMaker` (glavniki)
2. **RoyalHairbrushMakerSystem.lua** → `local HairbrushMaker` (ščetke za lase)
3. **RoyalHairpinMakerSystem.lua** → `local HairpinMaker` (lasnice)
4. **RoyalBeardCombMakerSystem.lua** → `local BeardCombMaker` (glavniki za brado)
5. **RoyalLiceCombMakerSystem.lua** → `local LiceCombMaker` (glavniki za uši)

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

3 točke za vsak sistem (najdi zadnji `S.KnotBoardMaker` in dodaj za njim):

```lua
-- require block (po S.KnotBoardMaker = require(...))
S.CombMaker = require("objects.Economy.RoyalCombMakerSystem")
S.HairbrushMaker = require("objects.Economy.RoyalHairbrushMakerSystem")
S.HairpinMaker = require("objects.Economy.RoyalHairpinMakerSystem")
S.BeardCombMaker = require("objects.Economy.RoyalBeardCombMakerSystem")
S.LiceCombMaker = require("objects.Economy.RoyalLiceCombMakerSystem")

-- init block (po S.KnotBoardMaker.init(); ...)
S.CombMaker.init(); _G.CombMaker = S.CombMaker
S.HairbrushMaker.init(); _G.HairbrushMaker = S.HairbrushMaker
S.HairpinMaker.init(); _G.HairpinMaker = S.HairpinMaker
S.BeardCombMaker.init(); _G.BeardCombMaker = S.BeardCombMaker
S.LiceCombMaker.init(); _G.LiceCombMaker = S.LiceCombMaker

-- update block (po S.KnotBoardMaker.update(dt))
S.CombMaker.update(dt)
S.HairbrushMaker.update(dt)
S.HairpinMaker.update(dt)
S.BeardCombMaker.update(dt)
S.LiceCombMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "comb|hairbrush|hairpin|beardcomb|licecomb"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.432 do v3.11.436 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.431 → version-3.11.436
   - syntax-1165%2F1168 → syntax-1170%2F1173
   - Royal%20systems-519 → Royal%20systems-524
   - Lua%20files-1168 → Lua%20files-1173
7. Git: commit, tag (v3.11.432 do v3.11.436), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.436.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (česlarska oprema) spremeni:
- Imena produktov (npr. "železni glavnik", "železna ščetka za lase", "železna lasnica", "železni glavnik za brado", "železni glavnik za uši")
- Imena zgradb (glavnična, ščetkarska, lasnična, bradna, ušesna delavnica/hiša/atelje/palača)
- Maker ime (Glavnikar, Ščetkar, Lasničar, Bradar, Ušesar)
- Event bus publish (comb.completed, hairbrush.completed, hairpin.completed, beardcomb.completed, licecomb.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.431. Naslednji paket je v3.11.432–v3.11.436 (česlarska oprema: CombMaker, HairbrushMaker, HairpinMaker, BeardCombMaker, LiceCombMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.437–v3.11.441 — predlagano: sedlarski dodatki: SaddleSoapMaker, SaddlePolishMaker, LeatherConditionerMaker, StirrupLeatherMaker, BridleBuckleMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.432–v3.11.436: česlarska oprema (CombMaker, HairbrushMaker, HairpinMaker, BeardCombMaker, LiceCombMaker)
- v3.11.437–v3.11.441: sedlarski dodatki (SaddleSoapMaker, SaddlePolishMaker, LeatherConditionerMaker, StirrupLeatherMaker, BridleBuckleMaker)
- v3.11.442–v3.11.446: voščena oprema (CandleMoldMaker, WickSpinnerMaker, WaxDipperMaker, CandlestickBaseMaker, TaperRollerMaker)
- v3.11.447–v3.11.451: livarska oprema (CrucibleMaker, SandMoldMaker, IngotMoldMaker, FlaskMaker, CastingLadleMaker)

