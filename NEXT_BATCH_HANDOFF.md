# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.521**
- Skupaj Royal sistemov: **609**
- Skupaj Lua datotek: **1258**
- Sintaktična preverba: **1255/1258 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 609 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.522–v3.11.526) — KUHINJSKI DODATKI

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalMortarPestleStandMakerSystem.lua** → `local MortarPestleStandMaker` (stojala za možnarje)
2. **RoyalSpiceGrinderMakerSystem.lua** → `local SpiceGrinderMaker` (mlinčki za začimbe)
3. **RoyalOlivePressMakerSystem.lua** → `local OlivePressMaker` (oljčne prese)
4. **RoyalWineStrainerMakerSystem.lua** → `local WineStrainerMaker` (cedila za vino)
5. **RoyalHoneyDipperMakerSystem.lua** → `local HoneyDipperMaker` (medne zajemalke)

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

3 točke za vsak sistem (najdi zadnji `S.WashstandMaker` in dodaj za njim):

```lua
-- require block (po S.WashstandMaker = require(...))
S.MortarPestleStandMaker = require("objects.Economy.RoyalMortarPestleStandMakerSystem")
S.SpiceGrinderMaker = require("objects.Economy.RoyalSpiceGrinderMakerSystem")
S.OlivePressMaker = require("objects.Economy.RoyalOlivePressMakerSystem")
S.WineStrainerMaker = require("objects.Economy.RoyalWineStrainerMakerSystem")
S.HoneyDipperMaker = require("objects.Economy.RoyalHoneyDipperMakerSystem")

-- init block (po S.WashstandMaker.init(); ...)
S.MortarPestleStandMaker.init(); _G.MortarPestleStandMaker = S.MortarPestleStandMaker
S.SpiceGrinderMaker.init(); _G.SpiceGrinderMaker = S.SpiceGrinderMaker
S.OlivePressMaker.init(); _G.OlivePressMaker = S.OlivePressMaker
S.WineStrainerMaker.init(); _G.WineStrainerMaker = S.WineStrainerMaker
S.HoneyDipperMaker.init(); _G.HoneyDipperMaker = S.HoneyDipperMaker

-- update block (po S.WashstandMaker.update(dt))
S.MortarPestleStandMaker.update(dt)
S.SpiceGrinderMaker.update(dt)
S.OlivePressMaker.update(dt)
S.WineStrainerMaker.update(dt)
S.HoneyDipperMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "mortarpestlestand|spicegrinder|olivepress|winestrainer|honeydipper"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.522 do v3.11.526 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.521 → version-3.11.526
   - syntax-1255%2F1258 → syntax-1260%2F1263
   - Royal%20systems-609 → Royal%20systems-614
   - Lua%20files-1258 → Lua%20files-1263
7. Git: commit, tag (v3.11.522 do v3.11.526), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.526.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (kuhinjski dodatki) spremeni:
- Imena produktov (npr. "železno stojalo za možnar", "železni mlinček za začimbe", "železna oljčna preša", "železno cedilo za vino", "železna medna zajemalka")
- Imena zgradb (stojalna, mlinčna, prešna, cedilna, medna delavnica/hiša/atelje/palača)
- Maker ime (Stojalar, Mlinar, Prešar, Cedilar, Medar)
- Event bus publish (mortarpestlestand.completed, spicegrinder.completed, olivepress.completed, winestrainer.completed, honeydipper.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.521. Naslednji paket je v3.11.522–v3.11.526 (kuhinjski dodatki: MortarPestleStandMaker, SpiceGrinderMaker, OlivePressMaker, WineStrainerMaker, HoneyDipperMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.527–v3.11.531 — predlagano: vrtni dodatki: GardenSieveMaker, PlantSupportMaker, WateringSpikeMaker, CompostAeratorMaker, SeedDrillPlowMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.522–v3.11.526: kuhinjski dodatki (MortarPestleStandMaker, SpiceGrinderMaker, OlivePressMaker, WineStrainerMaker, HoneyDipperMaker)
- v3.11.527–v3.11.531: vrtni dodatki (GardenSieveMaker, PlantSupportMaker, WateringSpikeMaker, CompostAeratorMaker, SeedDrillPlowMaker)
- v3.11.532–v3.11.536: pekovski dodatki (DoughScraperMaker, ProofingBasketMaker, BreadLameMaker, OvenPeelMaker, FlourShovelMaker)
- v3.11.537–v3.11.541: ribiški dodatki (FishHookMaker, FishingLineSpoolMaker, BaitBoxMaker, FishScalerMaker, NetMendingNeedleMaker)
