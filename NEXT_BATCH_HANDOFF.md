# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.631**
- Skupaj Royal sistemov: **719**
- Skupaj Lua datotek: **1368**
- Sintaktična preverba: **1365/1368 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 719 Royal sisteme z igro:

- **`objects/Economy/RoyalSystemsRegistry.lua`** — auto-discovers vse sisteme, hook-a `completeMaking()`, dodeli bonus zlato (prestige × 10) ob končanem produktu
- **`states/ui/hud/royal_systems_panel.lua`** — full-screen UI panel (toggle s Ctrl+R), ki omogoča brskanje, najem mojstrov, gradnjo delavnic, izdelavo produktov, prodajo zalog
- **`states/ui/hud/keybind_help.lua`** — dodana Ctrl+R bližnjica
- **`scripts/test_registry.lua`** — test skripta (poženi z lupa)

Vsi novi sistemi, dodani po v3.11.382, so samodejno odkriti in prikazani v panelu — ni potrebe po ročni registraciji v Registry. Tudi ni potrebno več ročno registrirati sisteme v states/game.lua (require/init/update bloki) — zadnje pakete (od v3.11.542 naprej) pustimo neregistrirane, ker jih Registry sam odkrije preko S tabele.

## ZNANE NADGRADNJE ZA PRIHODNJE PAKETE

1. **Povezava z DynamicMarketSystem** — Royal produkti naj bodo prodani na tržnici
2. **Sprite-i za Royal sisteme** — trenutno so samo podatkovni, brez grafične podobe
3. **Grafikon produkcije** — zgodovina proizvodnje v panelu
4. **Sistemsko odvisnosti** — nekateri sistemi naj zahtevajo druge (npr. BellMaker zahteva Metalwork)

## ZADNJE ZAKLJUČENI PAKET (v3.11.622–v3.11.631) — STEKLARSKI DODATKI 4 + LIVARSKI DODATKI 4

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 4 (v3.11.622-v3.11.626)
1. **RoyalGlassAnnealingCradleMakerSystem.lua** → `local GlassAnnealingCradleMaker` (zibke za ohlajanje stekla)
2. **RoyalGlassColorantMortarMakerSystem.lua** → `local GlassColorantMortarMaker` (možnarji za steklarske barve)
3. **RoyalGlassCaneSlicerMakerSystem.lua** → `local GlassCaneSlicerMaker` (rezalniki steklenih palic)
4. **RoyalGlassKilnDoorLifterMakerSystem.lua** → `local GlassKilnDoorLifterMaker` (dvigalci pečnih vrat)
5. **RoyalGlassEngravingWheelMakerSystem.lua** → `local GlassEngravingWheelMaker` (rezbarska kolesa)

### Livarski dodatki 4 (v3.11.627-v3.11.631)
6. **RoyalMoldReleaseAgentMakerSystem.lua** → `local MoldReleaseAgentMaker` (sredstva za ločitev kalupov)
7. **RoyalSprueCutterMakerSystem.lua** → `local SprueCutterMaker` (rezalniki vtokov)
8. **RoyalRiserBreakerMakerSystem.lua** → `local RiserBreakerMaker` (lomilci pen)
9. **RoyalSlurryMixerMakerSystem.lua** → `local SlurryMixerMaker` (mešalci livarske kaše)
10. **RoyalMoldDryingOvenMakerSystem.lua** → `local MoldDryingOvenMaker` (sušilne peči za kalupe)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_glass4_foundry4_systems.py`
- Sintaktična preverba: `/home/z/my-project/scripts/check_new_systems_syntax.py`
- Vseh 10 novih datotek PASS sintaktične preverbe (lupa load())
- Skripta uporablja string.Template (ne f-string) za čisto Lua predlogo
- Pravilno substituira vse placeholderje vključno z ${maker_lower}
- Uporablja pravilno sintakso `productStock[m.productType]` (ne okvarjeno `productStock.productType]`)

## PATTERN ZA VSAK SISTEM

Vsak sistem mora imeti:
- 6 produktov (železni → bronasti → srebrni → pozlačeni → draguljasti → kraljevski suvereni)
- 4 zgradbe (delavnica, hiša, mojstrski atelje, suverena palača)
- Funkcije: `init`, `hireMaker`, `canBuild`, `build`, `getQualityBonus`, `canMake`, `make`, `completeMaking`, `update`, `getStats`
- `_G.NotificationCenter.notify` in `_G.GameEventBus.publish` s pcall
- Vrača lokalno tabelo
- Slovenian product/building names
- **POMEMBNO**: V `completeMaking` uporabljaj `productStock[m.productType]` (z `[m.` pred `productType]`) — ne `productStock.productType]` (to je okvarjena sintaksa)

## NASLEDNJI PAKET (v3.11.632–v3.11.641) — KNJIGOVEŠKI DODATKI 4 + KOVAŠKI DODATKI 4

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 4 (v3.11.632-v3.11.636) — predloga
1. **RoyalBookEdgePainterMakerSystem.lua** → `local BookEdgePainterMaker` (slikalci robov knjig)
2. **RoyalBookPressingWeightMakerSystem.lua** → `local BookPressingWeightMaker` (uteži za stiskanje knjig)
3. **RoyalBookbindingAwlMakerSystem.lua** → `local BookbindingAwlMaker` (šila za knjigoveštvo)
4. **RoyalBookThreadReelMakerSystem.lua** → `local BookThreadReelMaker` (vitice za knjigoveške niti)
5. **RoyalBookCoverCrimperMakerSystem.lua** → `local BookCoverCrimperMaker` (gubalci naslovnic)

### Kovaški dodatki 4 (v3.11.637-v3.11.641) — predloga
6. **RoyalCutterHardyMakerSystem.lua** → `local CutterHardyMaker` (trdi rezalniki za nakovalo)
7. **RoyalSetHammerMakerSystem.lua** → `local SetHammerMaker` (nastavitvena kladiva)
8. **RoyalBottomFullerMakerSystem.lua** → `local BottomFullerMaker` (spodnji fullerji)
9. **RoyalTopFullerMakerSystem.lua** → `local TopFullerMaker` (zgornji fullerji)
10. **RoyalAnvilHardyMakerSystem.lua** → `local AnvilHardyMaker` (trdi nastavki za nakovalo)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalBookEdgePainterMakerSystem.lua RoyalBookPressingWeightMakerSystem.lua RoyalBookbindingAwlMakerSystem.lua RoyalBookThreadReelMakerSystem.lua RoyalBookCoverCrimperMakerSystem.lua RoyalCutterHardyMakerSystem.lua RoyalSetHammerMakerSystem.lua RoyalBottomFullerMakerSystem.lua RoyalTopFullerMakerSystem.lua RoyalAnvilHardyMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam v tej skripti)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.632 do v3.11.641 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.631 → version-3.11.641
   - syntax-1365%2F1368 → syntax-1375%2F1378
   - Royal%20systems-719 → Royal%20systems-729
   - Lua%20files-1368 → Lua%20files-1378
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.632 do v3.11.641), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.641.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_glass4_foundry4_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_bookbinding4_blacksmith4_systems.py`
2. Spremeni `GLASS4_SYSTEMS` in `FOUNDRY4_SYSTEMS` sezname v `BOOKBINDING4_SYSTEMS` in `BLACKSMITH4_SYSTEMS` z novimi sistemi
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_bookbinding4_blacksmith4_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)

## PREDLOGA ZA SISTEM (primer GlassAnnealingCradleMaker, kot referenca)

```lua
local GlassAnnealingCradleMaker = {}
local PRODUCTS = {
    iron_glassannealingcradle = { name = "Železni zibka za ohlajanje stekla", ironCost = 3, woodCost = 2, leatherCost = 1, time = 5, cost = 150, prestige = 4, happiness = 2, description = "Železni zibka za ohlajanje stekla za steklarje." },
    -- ... 5 more products (bronze, silver, gilded, jewel_set, royal_sovereign)
}
local BUILDINGS = {
    glassannealingcradle_workshop = { name = "Glassannealingcradle delavnica", cost = { gold = 325, wood = 185, stone = 130, iron = 7 }, upkeep = 6, qualityBonus = 5 },
    -- ... 3 more buildings (house, master_atelier, sovereign_palace)
}
GlassAnnealingCradleMaker.ironStock=14; GlassAnnealingCradleMaker.bronzeStock=12; ... GlassAnnealingCradleMaker.pearlStock=4
GlassAnnealingCradleMaker.productStock = {}; GlassAnnealingCradleMaker.buildings = {}; GlassAnnealingCradleMaker.maker = nil; GlassAnnealingCradleMaker.activeMaking = {}; GlassAnnealingCradleMaker.totalProducts = 0; GlassAnnealingCradleMaker.dayTimer = 0
function GlassAnnealingCradleMaker.init() ... end
function GlassAnnealingCradleMaker.hireMaker(n,s) ... end
function GlassAnnealingCradleMaker.canBuild(id) ... end
function GlassAnnealingCradleMaker.build(id) ... end
function GlassAnnealingCradleMaker.getQualityBonus() ... end
function GlassAnnealingCradleMaker.canMake(pt) ... end
function GlassAnnealingCradleMaker.make(pt,qty) ... end
function GlassAnnealingCradleMaker.completeMaking(m) ... GlassAnnealingCradleMaker.productStock[m.productType]=(GlassAnnealingCradleMaker.productStock[m.productType] or 0)+m.quantity ... end
function GlassAnnealingCradleMaker.update(dt) ... end
function GlassAnnealingCradleMaker.getStats() ... end
return GlassAnnealingCradleMaker
```

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.631. Naslednji paket je v3.11.632–v3.11.641 (knjigoveški dodatki 4 + kovaški dodatki 4: BookEdgePainterMaker, BookPressingWeightMaker, BookbindingAwlMaker, BookThreadReelMaker, BookCoverCrimperMaker, CutterHardyMaker, SetHammerMaker, BottomFullerMaker, TopFullerMaker, AnvilHardyMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.632–v3.11.636: knjigoveški dodatki 4 (BookEdgePainterMaker, BookPressingWeightMaker, BookbindingAwlMaker, BookThreadReelMaker, BookCoverCrimperMaker)
- v3.11.637–v3.11.641: kovaški dodatki 4 (CutterHardyMaker, SetHammerMaker, BottomFullerMaker, TopFullerMaker, AnvilHardyMaker)
- v3.11.642–v3.11.646: vrtni dodatki 4 (predlagano)
- v3.11.647–v3.11.651: mlinarski dodatki 4 (predlagano)
