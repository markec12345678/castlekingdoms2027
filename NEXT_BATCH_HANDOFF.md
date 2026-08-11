# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.511**
- Skupaj Royal sistemov: **599**
- Skupaj Lua datotek: **1248**
- Sintaktična preverba: **1245/1248 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 599 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.512–v3.11.516) — URARSKI DODATKI

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalPendulumRodMakerSystem.lua** → `local PendulumRodMaker` (nihajne palice)
2. **RoyalEscapementLeverMakerSystem.lua** → `local EscapementLeverMaker` (uhopne ročice)
3. **RoyalMainspringWinderMakerSystem.lua** → `local MainspringWinderMaker` (navijalce vzmeti)
4. **RoyalClockDialEngraverMakerSystem.lua** → `local ClockDialEngraverMaker` (rezkarje števnice)
5. **RoyalChimeHammerMakerSystem.lua** → `local ChimeHammerMaker` (kladivca za zvonove)

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

3 točke za vsak sistem (najdi zadnji `S.CompassNeedleMaker` in dodaj za njim):

```lua
-- require block (po S.CompassNeedleMaker = require(...))
S.PendulumRodMaker = require("objects.Economy.RoyalPendulumRodMakerSystem")
S.EscapementLeverMaker = require("objects.Economy.RoyalEscapementLeverMakerSystem")
S.MainspringWinderMaker = require("objects.Economy.RoyalMainspringWinderMakerSystem")
S.ClockDialEngraverMaker = require("objects.Economy.RoyalClockDialEngraverMakerSystem")
S.ChimeHammerMaker = require("objects.Economy.RoyalChimeHammerMakerSystem")

-- init block (po S.CompassNeedleMaker.init(); ...)
S.PendulumRodMaker.init(); _G.PendulumRodMaker = S.PendulumRodMaker
S.EscapementLeverMaker.init(); _G.EscapementLeverMaker = S.EscapementLeverMaker
S.MainspringWinderMaker.init(); _G.MainspringWinderMaker = S.MainspringWinderMaker
S.ClockDialEngraverMaker.init(); _G.ClockDialEngraverMaker = S.ClockDialEngraverMaker
S.ChimeHammerMaker.init(); _G.ChimeHammerMaker = S.ChimeHammerMaker

-- update block (po S.CompassNeedleMaker.update(dt))
S.PendulumRodMaker.update(dt)
S.EscapementLeverMaker.update(dt)
S.MainspringWinderMaker.update(dt)
S.ClockDialEngraverMaker.update(dt)
S.ChimeHammerMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "pendulumrod|escapementlever|mainspringwinder|clockdialengraver|chimehammer"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.512 do v3.11.516 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.511 → version-3.11.516
   - syntax-1245%2F1248 → syntax-1250%2F1253
   - Royal%20systems-599 → Royal%20systems-604
   - Lua%20files-1248 → Lua%20files-1253
7. Git: commit, tag (v3.11.512 do v3.11.516), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.516.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (urarski dodatki) spremeni:
- Imena produktov (npr. "železna nihajna palica", "železna uhopna ročica", "železni navijalec vzmeti", "železni rezkar števnice", "železno kladivce za zvonove")
- Imena zgradb (nihajna, uhopna, vzmetna, rezkalna, zvončna delavnica/hiša/atelje/palača)
- Maker ime (Nihajec, Uhopar, Vzmetar, Rezkar, Zvonar)
- Event bus publish (pendulumrod.completed, escapementlever.completed, mainspringwinder.completed, clockdialengraver.completed, chimehammer.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.511. Naslednji paket je v3.11.512–v3.11.516 (urarski dodatki: PendulumRodMaker, EscapementLeverMaker, MainspringWinderMaker, ClockDialEngraverMaker, ChimeHammerMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.517–v3.11.521 — predlagano: kopalniška oprema: TowelRackMaker, SoapDishMaker, BathBucketMaker, SpongeHolderMaker, WashstandMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.512–v3.11.516: urarski dodatki (PendulumRodMaker, EscapementLeverMaker, MainspringWinderMaker, ClockDialEngraverMaker, ChimeHammerMaker)
- v3.11.517–v3.11.521: kopalniška oprema (TowelRackMaker, SoapDishMaker, BathBucketMaker, SpongeHolderMaker, WashstandMaker)
- v3.11.522–v3.11.526: kuhinjska dodatki (MortarPestleStandMaker, SpiceGrinderMaker, OlivePressMaker, WineStrainerMaker, HoneyDipperMaker)
- v3.11.527–v3.11.531: vrtni dodatki (GardenSieveMaker, PlantSupportMaker, WateringSpikeMaker, CompostAeratorMaker, SeedDrillPlowMaker)
