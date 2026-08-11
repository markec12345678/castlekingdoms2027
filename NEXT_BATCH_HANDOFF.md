# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.501**
- Skupaj Royal sistemov: **589**
- Skupaj Lua datotek: **1238**
- Sintaktična preverba: **1235/1238 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 589 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.502–v3.11.506) — VOJAŠKA OPREMA

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalShieldBossMakerSystem.lua** → `local ShieldBossMaker` (ščitni bossi)
2. **RoyalSwordPommelMakerSystem.lua** → `local SwordPommelMaker` (mečni gumbi)
3. **RoyalScabbardChapeMakerSystem.lua** → `local ScabbardChapeMaker` (nožnice konice)
4. **RoyalHelmetCrestMakerSystem.lua** → `local HelmetCrestMaker` (čeladni grebeni)
5. **RoyalBannerPoleMakerSystem.lua** → `local BannerPoleMaker` (zastavni drogi)

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

3 točke za vsak sistem (najdi zadnji `S.ScentConeMaker` in dodaj za njim):

```lua
-- require block (po S.ScentConeMaker = require(...))
S.ShieldBossMaker = require("objects.Economy.RoyalShieldBossMakerSystem")
S.SwordPommelMaker = require("objects.Economy.RoyalSwordPommelMakerSystem")
S.ScabbardChapeMaker = require("objects.Economy.RoyalScabbardChapeMakerSystem")
S.HelmetCrestMaker = require("objects.Economy.RoyalHelmetCrestMakerSystem")
S.BannerPoleMaker = require("objects.Economy.RoyalBannerPoleMakerSystem")

-- init block (po S.ScentConeMaker.init(); ...)
S.ShieldBossMaker.init(); _G.ShieldBossMaker = S.ShieldBossMaker
S.SwordPommelMaker.init(); _G.SwordPommelMaker = S.SwordPommelMaker
S.ScabbardChapeMaker.init(); _G.ScabbardChapeMaker = S.ScabbardChapeMaker
S.HelmetCrestMaker.init(); _G.HelmetCrestMaker = S.HelmetCrestMaker
S.BannerPoleMaker.init(); _G.BannerPoleMaker = S.BannerPoleMaker

-- update block (po S.ScentConeMaker.update(dt))
S.ShieldBossMaker.update(dt)
S.SwordPommelMaker.update(dt)
S.ScabbardChapeMaker.update(dt)
S.HelmetCrestMaker.update(dt)
S.BannerPoleMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "shieldboss|swordpommel|scabbardchape|helmetcrest|bannerpole"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.502 do v3.11.506 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.501 → version-3.11.506
   - syntax-1235%2F1238 → syntax-1240%2F1243
   - Royal%20systems-589 → Royal%20systems-594
   - Lua%20files-1238 → Lua%20files-1243
7. Git: commit, tag (v3.11.502 do v3.11.506), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.506.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (vojaška oprema) spremeni:
- Imena produktov (npr. "železni ščitni boss", "železni mečni gumb", "železna nožnična konica", "železni čeladni greben", "železni zastavni drog")
- Imena zgradb (bosna, gumbna, nožnična, grebenska, zastavna delavnica/hiša/atelje/palača)
- Maker ime (Bosar, Gumbar, Nožničar, Grenar, Zastavar)
- Event bus publish (shieldboss.completed, swordpommel.completed, scabbardchape.completed, helmetcrest.completed, bannerpole.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.501. Naslednji paket je v3.11.502–v3.11.506 (vojaška oprema: ShieldBossMaker, SwordPommelMaker, ScabbardChapeMaker, HelmetCrestMaker, BannerPoleMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.507–v3.11.511 — predlagano: astrološka oprema: AstrolabeRingMaker, StarChartRackMaker, CelestialGlobeMaker, SundialGnomonMaker, CompassNeedleMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.502–v3.11.506: vojaška oprema (ShieldBossMaker, SwordPommelMaker, ScabbardChapeMaker, HelmetCrestMaker, BannerPoleMaker)
- v3.11.507–v3.11.511: astrološka oprema (AstrolabeRingMaker, StarChartRackMaker, CelestialGlobeMaker, SundialGnomonMaker, CompassNeedleMaker)
- v3.11.512–v3.11.516: urarska dodatki (PendulumRodMaker, EscapementLeverMaker, MainspringWinderMaker, ClockDialEngraverMaker, ChimeHammerMaker)
- v3.11.517–v3.11.521: kopalniška oprema (TowelRackMaker, SoapDishMaker, BathBucketMaker, SpongeHolderMaker, WashstandMaker)
