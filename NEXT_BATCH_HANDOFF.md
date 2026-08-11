# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.551**
- Skupaj Royal sistemov: **639**
- Skupaj Lua datotek: **1288**
- Sintaktična preverba: **1285/1288 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 639 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.552–v3.11.556) — USNJARSKI DODATKI 2

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalLeatherBurnisherMakerSystem.lua** → `local LeatherBurnisherMaker` (poliralci usnja)
2. **RoyalLeatherSplitterMakerSystem.lua** → `local LeatherSplitterMaker` (cepalci usnja)
3. **RoyalLeatherSkiverMakerSystem.lua** → `local LeatherSkiverMaker` (strgalci usnja)
4. **RoyalLeatherEdgeBevelerMakerSystem.lua** → `local LeatherEdgeBevelerMaker` (poševniki robov)
5. **RoyalLeatherCreaserMakerSystem.lua** → `local LeatherCreaserMaker` (gubalci usnja)

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

3 točke za vsak sistem (najdi zadnji `S.IngotCasterMaker` in dodaj za njim):

```lua
-- require block (po S.IngotCasterMaker = require(...))
S.LeatherBurnisherMaker = require("objects.Economy.RoyalLeatherBurnisherMakerSystem")
S.LeatherSplitterMaker = require("objects.Economy.RoyalLeatherSplitterMakerSystem")
S.LeatherSkiverMaker = require("objects.Economy.RoyalLeatherSkiverMakerSystem")
S.LeatherEdgeBevelerMaker = require("objects.Economy.RoyalLeatherEdgeBevelerMakerSystem")
S.LeatherCreaserMaker = require("objects.Economy.RoyalLeatherCreaserMakerSystem")

-- init block (po S.IngotCasterMaker.init(); ...)
S.LeatherBurnisherMaker.init(); _G.LeatherBurnisherMaker = S.LeatherBurnisherMaker
S.LeatherSplitterMaker.init(); _G.LeatherSplitterMaker = S.LeatherSplitterMaker
S.LeatherSkiverMaker.init(); _G.LeatherSkiverMaker = S.LeatherSkiverMaker
S.LeatherEdgeBevelerMaker.init(); _G.LeatherEdgeBevelerMaker = S.LeatherEdgeBevelerMaker
S.LeatherCreaserMaker.init(); _G.LeatherCreaserMaker = S.LeatherCreaserMaker

-- update block (po S.IngotCasterMaker.update(dt))
S.LeatherBurnisherMaker.update(dt)
S.LeatherSplitterMaker.update(dt)
S.LeatherSkiverMaker.update(dt)
S.LeatherEdgeBevelerMaker.update(dt)
S.LeatherCreaserMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "leatherburnisher|leathersplitter|leatherskiver|leatheredgebeveler|leathercreaser"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.552 do v3.11.556 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.551 → version-3.11.556
   - syntax-1285%2F1288 → syntax-1290%2F1293
   - Royal%20systems-639 → Royal%20systems-644
   - Lua%20files-1288 → Lua%20files-1293
7. Git: commit, tag (v3.11.552 do v3.11.556), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.556.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (usnjarski dodatki 2) spremeni:
- Imena produktov (npr. "železni poliralec usnja", "železni cepalec usnja", "železni strgalec usnja", "železni poševnik robov", "železni gubalec usnja")
- Imena zgradb (poliralna, cepalna, strgalna, poševna, gubalna delavnica/hiša/atelje/palača)
- Maker ime (Poliralec, Cepalec, Strgalec, Poševnik, Gubalec)
- Event bus publish (leatherburnisher.completed, leathersplitter.completed, leatherskiver.completed, leatheredgebeveler.completed, leathercreaser.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.551. Naslednji paket je v3.11.552–v3.11.556 (usnjarski dodatki 2: LeatherBurnisherMaker, LeatherSplitterMaker, LeatherSkiverMaker, LeatherEdgeBevelerMaker, LeatherCreaserMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.557–v3.11.561 — predlagano: klobučarski dodatki 2: HatBrimCurlerMaker, HatCrownBlockMaker, HatStretcherMaker, HatLiningMaker, HatBandBuckleMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.552–v3.11.556: usnjarski dodatki 2 (LeatherBurnisherMaker, LeatherSplitterMaker, LeatherSkiverMaker, LeatherEdgeBevelerMaker, LeatherCreaserMaker)
- v3.11.557–v3.11.561: klobučarski dodatki 2 (HatBrimCurlerMaker, HatCrownBlockMaker, HatStretcherMaker, HatLiningMaker, HatBandBuckleMaker)
- v3.11.562–v3.11.566: kovaški dodatki 2 (ForgeRakeMaker, AshShovelMaker, TongsRestMaker, QuenchBucketMaker, SlackTubMaker)
- v3.11.567–v3.11.571: mlinarski dodatki 2 (HopperScaleMaker, SackStitcherMaker, FlourSackMaker, GrainProbeMaker, MillstoneCraneMaker)
