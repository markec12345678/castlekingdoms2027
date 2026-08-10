# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.386**
- Skupaj Royal sistemov: **474**
- Skupaj Lua datotek: **1123**
- Sintaktična preverba: **1120/1123 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## 🎉 NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Prejšnji paket je prinesel **veliko nadgradnjo** — ne samo 5 novih rudarskih sistemov, ampak tudi centralen manager in UI panel, ki končno poveže vse 474 Royal sisteme z igro:

- **`objects/Economy/RoyalSystemsRegistry.lua`** — auto-discovers vse sisteme, hook-a `completeMaking()`, dodeli bonus zlato (prestige × 10) ob končanem produktu
- **`states/ui/hud/royal_systems_panel.lua`** — full-screen UI panel (toggle s Ctrl+R), ki omogoča brskanje, najem mojstrov, gradnjo delavnic, izdelavo produktov, prodajo zalog
- **`states/ui/hud/keybind_help.lua`** — dodana Ctrl+R bližnjica
- **`scripts/test_registry.lua`** — test skripta (poženi z lupa)

Prej so bili Royal sistemi nevidni (noben UI, nobena integracija). Sedaj so dostopni preko Ctrl+R in ob vsakem končanem produktu dajejo real game bonus (zlato + popularity).

## NASLEDNJI PAKET (v3.11.387–v3.11.391) — LEKARNIŠKA POSODA

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalMortarPestleMakerSystem.lua** → `local MortarPestleMaker` (možnarji in pestili)
2. **RoyalApothecaryVialMakerSystem.lua** → `local ApothecaryVialMaker` (stekleničke za lekarne)
3. **RoyalSalveJarMakerSystem.lua** → `local SalveJarMaker` (kozarci za mazila)
4. **RoyalSurgicalLancetMakerSystem.lua** → `local SurgicalLancetMaker` (kirurški skalpeli/lancete)
5. **RoyalPhysicPotionMakerSystem.lua** → `local PhysicPotionMaker` (zdravilni napitki)

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

3 točke za vsak sistem (najdi zadnji `S.ProspectingPanMaker` in dodaj za njim):

```lua
-- require block (po S.ProspectingPanMaker = require(...))
S.MortarPestleMaker = require("objects.Economy.RoyalMortarPestleMakerSystem")
S.ApothecaryVialMaker = require("objects.Economy.RoyalApothecaryVialMakerSystem")
S.SalveJarMaker = require("objects.Economy.RoyalSalveJarMakerSystem")
S.SurgicalLancetMaker = require("objects.Economy.RoyalSurgicalLancetMakerSystem")
S.PhysicPotionMaker = require("objects.Economy.RoyalPhysicPotionMakerSystem")

-- init block (po S.ProspectingPanMaker.init(); ...)
S.MortarPestleMaker.init(); _G.MortarPestleMaker = S.MortarPestleMaker
S.ApothecaryVialMaker.init(); _G.ApothecaryVialMaker = S.ApothecaryVialMaker
S.SalveJarMaker.init(); _G.SalveJarMaker = S.SalveJarMaker
S.SurgicalLancetMaker.init(); _G.SurgicalLancetMaker = S.SurgicalLancetMaker
S.PhysicPotionMaker.init(); _G.PhysicPotionMaker = S.PhysicPotionMaker

-- update block (po S.ProspectingPanMaker.update(dt))
S.MortarPestleMaker.update(dt)
S.ApothecaryVialMaker.update(dt)
S.SalveJarMaker.update(dt)
S.SurgicalLancetMaker.update(dt)
S.PhysicPotionMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "mortar|vial|salve|lancet|potion"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.387 do v3.11.391 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.386 → version-3.11.391
   - syntax-1120%2F1123 → syntax-1125%2F1128
   - Royal%20systems-474 → Royal%20systems-479
   - Lua%20files-1123 → Lua%20files-1128
7. Git: commit, tag (v3.11.387 do v3.11.391), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.391.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (lekarniška posoda) spremeni:
- Imena produktov (npr. "železni možnar", "železna viala", "železni kozarec za mazila", "železna lanceta", "železni napitek")
- Imena zgradb (možnarska, vialna, mazilna, lancetna, napitnična delavnica/hiša/atelje/palača)
- Maker ime (Možnarar, Vialar, Mazilar, Lancetar, Napitkar)
- Event bus publish (mortar.completed, vial.completed, salve.completed, lancet.completed, potion.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.386. Naslednji paket je v3.11.387–v3.11.391 (lekarniška posoda: MortarPestleMaker, ApothecaryVialMaker, SalveJarMaker, SurgicalLancetMaker, PhysicPotionMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.392–v3.11.396 — predlagano: vrtnarska oprema: PruningShearsMaker, TopiaryFrameMaker, GardenTrowelMaker, HedgeHookMaker, WateringCanMaker).

GitHub PAT: (uporabi prejšnji PAT ali ustvari novega — stari je bil v sporočilu izpostavljen, priporočljivo ga je preklicati)
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.387–v3.11.391: lekarniška posoda (MortarPestleMaker, ApothecaryVialMaker, SalveJarMaker, SurgicalLancetMaker, PhysicPotionMaker)
- v3.11.392–v3.11.396: vrtnarska oprema (PruningShearsMaker, TopiaryFrameMaker, GardenTrowelMaker, HedgeHookMaker, WateringCanMaker)
- v3.11.397–v3.11.401: jermenska oprema (SaddleMaker, BridleMaker, StirrupMaker, HorseHarnessMaker, SaddlebagMaker)
- v3.11.402–v3.11.406: slikarska oprema (EaselMaker, PaintbrushMaker, PaletteMaker, PigmentGrinderMaker, CanvasStretcherMaker)
