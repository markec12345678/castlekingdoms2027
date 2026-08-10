# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.416**
- Skupaj Royal sistemov: **504**
- Skupaj Lua datotek: **1153**
- Sintaktična preverba: **1150/1153 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## 🎉 NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 504 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.417–v3.11.421) — MLINARSKA OPREMA

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalMillstoneMakerSystem.lua** → `local MillstoneMaker` (mlinčki za žito)
2. **RoyalFlourSifterMakerSystem.lua** → `local FlourSifterMaker` (sitata za moko)
3. **RoyalDoughHookMakerSystem.lua** → `local DoughHookMaker` (kavlji za testo)
4. **RoyalGrainHopperMakerSystem.lua** → `local GrainHopperMaker` (ličnike za žito)
5. **RoyalSackLoaderMakerSystem.lua** → `local SackLoaderMaker` (nalagalce vrečk)

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

3 točke za vsak sistem (najdi zadnji `S.GlassEngraverMaker` in dodaj za njim):

```lua
-- require block (po S.GlassEngraverMaker = require(...))
S.MillstoneMaker = require("objects.Economy.RoyalMillstoneMakerSystem")
S.FlourSifterMaker = require("objects.Economy.RoyalFlourSifterMakerSystem")
S.DoughHookMaker = require("objects.Economy.RoyalDoughHookMakerSystem")
S.GrainHopperMaker = require("objects.Economy.RoyalGrainHopperMakerSystem")
S.SackLoaderMaker = require("objects.Economy.RoyalSackLoaderMakerSystem")

-- init block (po S.GlassEngraverMaker.init(); ...)
S.MillstoneMaker.init(); _G.MillstoneMaker = S.MillstoneMaker
S.FlourSifterMaker.init(); _G.FlourSifterMaker = S.FlourSifterMaker
S.DoughHookMaker.init(); _G.DoughHookMaker = S.DoughHookMaker
S.GrainHopperMaker.init(); _G.GrainHopperMaker = S.GrainHopperMaker
S.SackLoaderMaker.init(); _G.SackLoaderMaker = S.SackLoaderMaker

-- update block (po S.GlassEngraverMaker.update(dt))
S.MillstoneMaker.update(dt)
S.FlourSifterMaker.update(dt)
S.DoughHookMaker.update(dt)
S.GrainHopperMaker.update(dt)
S.SackLoaderMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "millstone|floursifter|doughhook|grainhopper|sackloader"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.417 do v3.11.421 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.416 → version-3.11.421
   - syntax-1150%2F1153 → syntax-1155%2F1158
   - Royal%20systems-504 → Royal%20systems-509
   - Lua%20files-1153 → Lua%20files-1158
7. Git: commit, tag (v3.11.417 do v3.11.421), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.421.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (mlinarska oprema) spremeni:
- Imena produktov (npr. "železni mlinček za žito", "železno sito za moko", "železni kavelj za testo", "železni ličnik za žito", "železni nalagalec vrečk")
- Imena zgradb (mlinarska, sitna, kavljeva, ličniška, nalagalna delavnica/hiša/atelje/palača)
- Maker ime (Mlinar, Sitar, Kavljist, Ličnikar, Nalagalec)
- Event bus publish (millstone.completed, floursifter.completed, doughhook.completed, grainhopper.completed, sackloader.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.416. Naslednji paket je v3.11.417–v3.11.421 (mlinarska oprema: MillstoneMaker, FlourSifterMaker, DoughHookMaker, GrainHopperMaker, SackLoaderMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.422–v3.11.426 — predlagano: klobučarska oprema: HatBlockMaker, HatBandMaker, HatPinMaker, HatFeatherMaker, HatBoxMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.417–v3.11.421: mlinarska oprema (MillstoneMaker, FlourSifterMaker, DoughHookMaker, GrainHopperMaker, SackLoaderMaker)
- v3.11.422–v3.11.426: klobučarska oprema (HatBlockMaker, HatBandMaker, HatPinMaker, HatFeatherMaker, HatBoxMaker)
- v3.11.427–v3.11.431: vrvarna oprema (RopeMaker, TwineMaker, NetMaker, CordageMaker, KnotBoardMaker)
- v3.11.432–v3.11.436: česlarska oprema (CombMaker, HairbrushMaker, HairpinMaker, BeardCombMaker, LiceCombMaker)

