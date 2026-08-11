# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.481**
- Skupaj Royal sistemov: **569**
- Skupaj Lua datotek: **1218**
- Sintaktična preverba: **1215/1218 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 569 Royal sisteme z igro:

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

## NASLEDNJI PAKET (v3.11.482–v3.11.486) — PERESNA OPREMA

Ustvari 5 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

1. **RoyalQuillCutterMakerSystem.lua** → `local QuillCutterMaker` (rezalci peres)
2. **RoyalInkwellMakerSystem.lua** → `local InkwellMaker` (črnilnice)
3. **RoyalParchmentRackMakerSystem.lua** → `local ParchmentRackMaker` (stojala za pergament)
4. **RoyalWaxTabletMakerSystem.lua** → `local WaxTabletMaker` (voščene tablice)
5. **RoyalWritingStandMakerSystem.lua** → `local WritingStandMaker` (pisalne mizice)

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

3 točke za vsak sistem (najdi zadnji `S.GildingPressMaker` in dodaj za njim):

```lua
-- require block (po S.GildingPressMaker = require(...))
S.QuillCutterMaker = require("objects.Economy.RoyalQuillCutterMakerSystem")
S.InkwellMaker = require("objects.Economy.RoyalInkwellMakerSystem")
S.ParchmentRackMaker = require("objects.Economy.RoyalParchmentRackMakerSystem")
S.WaxTabletMaker = require("objects.Economy.RoyalWaxTabletMakerSystem")
S.WritingStandMaker = require("objects.Economy.RoyalWritingStandMakerSystem")

-- init block (po S.GildingPressMaker.init(); ...)
S.QuillCutterMaker.init(); _G.QuillCutterMaker = S.QuillCutterMaker
S.InkwellMaker.init(); _G.InkwellMaker = S.InkwellMaker
S.ParchmentRackMaker.init(); _G.ParchmentRackMaker = S.ParchmentRackMaker
S.WaxTabletMaker.init(); _G.WaxTabletMaker = S.WaxTabletMaker
S.WritingStandMaker.init(); _G.WritingStandMaker = S.WritingStandMaker

-- update block (po S.GildingPressMaker.update(dt))
S.QuillCutterMaker.update(dt)
S.InkwellMaker.update(dt)
S.ParchmentRackMaker.update(dt)
S.WaxTabletMaker.update(dt)
S.WritingStandMaker.update(dt)
```

**POMEMBNO:** `RoyalSystemsRegistry.init(S)` se izvede po vseh `init()` klicih, tako da bo auto-discover tudi teh 5 novih sistemov. Ni potrebno ročno registrirati v Registry.

## WORKFLOW

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "quillcutter|inkwell|parchmentrack|waxtablet|writingstand"` (mora biti prazno)
2. Ustvari 5 .lua datotek po predlogi (glej spodaj)
3. Registriraj v states/game.lua (3 točke)
4. Poženi: `python3 /home/z/my-project/scripts/check_my_changes.py` (za sintaktično preverbo)
5. Posodobi CHANGELOG.md (dodaj vnose za v3.11.482 do v3.11.486 na vrh)
6. Posodobi README.md badge-je:
   - version-3.11.481 → version-3.11.486
   - syntax-1215%2F1218 → syntax-1220%2F1223
   - Royal%20systems-569 → Royal%20systems-574
   - Lua%20files-1218 → Lua%20files-1223
7. Git: commit, tag (v3.11.482 do v3.11.486), push
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.486.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore" "scripts/lua_syntax_check.py"`

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

Za nove 5 sistemov (peresna oprema) spremeni:
- Imena produktov (npr. "železni rezalec peres", "železna črnilnica", "železno stojalo za pergament", "železna voščena tablica", "železni pisalni mizic")
- Imena zgradb (rezalna, črnilnična, pergamentna, voščena, pisalna delavnica/hiša/atelje/palača)
- Maker ime (Rezar, Črnilničar, Pergamentist, Voščar, Pisar)
- Event bus publish (quillcutter.completed, inkwell.completed, parchmentrack.completed, waxtablet.completed, writingstand.completed)

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.481. Naslednji paket je v3.11.482–v3.11.486 (peresna oprema: QuillCutterMaker, InkwellMaker, ParchmentRackMaker, WaxTabletMaker, WritingStandMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom (v3.11.487–v3.11.491 — predlagano: kovanska oprema: CoinPressMaker, CoinDieMaker, CoinBlankMaker, CoinSorterMaker, CoinScaleMaker).
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.482–v3.11.486: peresna oprema (QuillCutterMaker, InkwellMaker, ParchmentRackMaker, WaxTabletMaker, WritingStandMaker)
- v3.11.487–v3.11.491: kovanska oprema (CoinPressMaker, CoinDieMaker, CoinBlankMaker, CoinSorterMaker, CoinScaleMaker)
- v3.11.492–v3.11.496: glasbena oprema (StringWinderMaker, TuningPinMaker, BridgeMaker, SoundpostMaker, TailpieceMaker)
- v3.11.497–v3.11.501: aromatska oprema (IncenseMolderMaker, PerfumeBottleMaker, SachetMaker, PotpourriBowlMaker, ScentConeMaker)
