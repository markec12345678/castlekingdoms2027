# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.541**
- Skupaj Royal sistemov: **629**
- Skupaj Lua datotek: **1278**
- Sintaktična preverba: **1275/1278 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 629 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.542–v3.11.546) — STEKLARSKI DODATKI 2

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalGlassKilnDoorMakerSystem.lua** → `local GlassKilnDoorMaker` (vrata za steklarske peči)
2. **RoyalGlassAnnealingOvenMakerSystem.lua** → `local GlassAnnealingOvenMaker` (peči za žarjenje stekla)
3. **RoyalGlassBatchFurnaceMakerSystem.lua** → `local GlassBatchFurnaceMaker` (peči za taljenje stekla)
4. **RoyalGlassGloryHoleMakerSystem.lua** → `local GlassGloryHoleMaker` (ognjene komore za oblikovanje)
5. **RoyalGlassMarverMakerSystem.lua** → `local GlassMarverMaker` (marmorirne plošče za steklo)

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

3 točke za vsak sistem (najdi zadnji `S.NetMendingNeedleMaker` in dodaj za njim):

```lua
-- require block (po S.NetMendingNeedleMaker = require(...))
S.GlassKilnDoorMaker = require("objects.Economy.RoyalGlassKilnDoorMakerSystem")
S.GlassAnnealingOvenMaker = require("objects.Economy.RoyalGlassAnnealingOvenMakerSystem")
S.GlassBatchFurnaceMaker = require("objects.Economy.RoyalGlassBatchFurnaceMakerSystem")
S.GlassGloryHoleMaker = require("objects.Economy.RoyalGlassGloryHoleMakerSystem")
S.GlassMarverMaker = require("objects.Economy.RoyalGlassMarverMakerSystem")

-- init block (po S.NetMendingNeedleMaker.init(); ...)
S.GlassKilnDoorMaker.init(); _G.GlassKilnDoorMaker = S.GlassKilnDoorMaker
S.GlassAnnealingOvenMaker.init(); _G.GlassAnnealingOvenMaker = S.GlassAnnealingOvenMaker
S.GlassBatchFurnaceMaker.init(); _G.GlassBatchFurnaceMaker = S.GlassBatchFurnaceMaker
S.GlassGloryHoleMaker.init(); _G.GlassGloryHoleMaker = S.GlassGloryHoleMaker
S.GlassMarverMaker.init(); _G.GlassMarverMaker = S.GlassMarverMaker

-- update block (po S.NetMendingNeedleMaker.update(dt))
S.GlassKilnDoorMaker.update(dt)
S.GlassAnnealingOvenMaker.update(dt)
S.GlassBatchFurnaceMaker.update(dt)
S.GlassGloryHoleMaker.update(dt)
S.GlassMarverMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "glasskilndoor|glassannealingoven|glassbatchfurnace|glassgloryhole|glassmarver"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.542 do v3.11.546 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.541 → version-3.11.546
   - syntax-1275%2F1278 → syntax-1280%2F1283
   - Royal%20systems-629 → Royal%20systems-634
   - Lua%20files-1278 → Lua%20files-1283
7. Git: commit, tag (v3.11.542 do v3.11.546), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.546.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (steklarski dodatki 2) spremeni:
- Imena produktov (npr. "železna vrata za steklarsko peč", "železna peč za žarjenje stekla", "železna peč za taljenje stekla", "železna ognjena komora za oblikovanje", "železna marmorirna plošča za steklo")
- Imena zgradb (vratna, žarilna, talilna, komorna, marmorirna delavnica/hiša/atelje/palača)
- Maker ime (Vratar, Žarilec, Talilec, Komorec, Marmorist)
- Event bus publish (glasskilndoor.completed, glassannealingoven.completed, glassbatchfurnace.completed, glassgloryhole.completed, glassmarver.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.541. Naslednji paket je v3.11.542–v3.11.546 (steklarski dodatki 2: GlassKilnDoorMaker, GlassAnnealingOvenMaker, GlassBatchFurnaceMaker, GlassGloryHoleMaker, GlassMarverMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.547–v3.11.551 — predlagano: livarski dodatki 2: SandCasterMaker, LostWaxMolderMaker, CentrifugalCasterMaker, VacuumCasterMaker, IngotCasterMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.542–v3.11.546: steklarski dodatki 2 (GlassKilnDoorMaker, GlassAnnealingOvenMaker, GlassBatchFurnaceMaker, GlassGloryHoleMaker, GlassMarverMaker)
- v3.11.547–v3.11.551: livarski dodatki 2 (SandCasterMaker, LostWaxMolderMaker, CentrifugalCasterMaker, VacuumCasterMaker, IngotCasterMaker)
- v3.11.552–v3.11.556: usnjarski dodatki 2 (LeatherBurnisherMaker, LeatherSplitterMaker, LeatherSkiverMaker, LeatherEdgeBevelerMaker, LeatherCreaserMaker)
- v3.11.557–v3.11.561: klobučarski dodatki 2 (HatBrimCurlerMaker, HatCrownBlockMaker, HatStretcherMaker, HatLiningMaker, HatBandBuckleMaker)
