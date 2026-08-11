# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.621**
- Skupaj Royal sistemov: **709**
- Skupaj Lua datotek: **1358**
- Sintaktična preverba: **1355/1358 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 709 Royal sisteme z igro:

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

## ZADNJE ZAKLJUČENI PAKET (v3.11.612–v3.11.621) — VRTNI DODATKI 3 + MLINARSKI DODATKI 3

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 3 (v3.11.612-v3.11.616)
1. **RoyalGardenHoeMakerSystem.lua** → `local GardenHoeMaker` (vrtne motike)
2. **RoyalDibberMakerSystem.lua** → `local DibberMaker` (sadilniki za seme)
3. **RoyalGardenRakeMakerSystem.lua** → `local GardenRakeMaker` (vrtne grelde)
4. **RoyalPruningSawMakerSystem.lua** → `local PruningSawMaker` (žage za obrezovanje)
5. **RoyalGardenWheelbarrowMakerSystem.lua** → `local GardenWheelbarrowMaker` (vrtni vozički)

### Mlinarski dodatki 3 (v3.11.617-v3.11.621)
6. **RoyalGrainAugerMakerSystem.lua** → `local GrainAugerMaker` (spiralni transporterji za žito)
7. **RoyalMillstoneDresserMakerSystem.lua** → `local MillstoneDresserMaker` (oblikovalci mlinskih kamnov)
8. **RoyalHopperGateMakerSystem.lua** → `local HopperGateMaker` (zapornice za lijake)
9. **RoyalFlourSieveMakerSystem.lua** → `local FlourSieveMaker` (sitane za moko)
10. **RoyalBranSeparatorMakerSystem.lua** → `local BranSeparatorMaker` (ločilci otrob)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek:
```
for f in RoyalGardenHoeMakerSystem.lua RoyalDibberMakerSystem.lua ...; do
  count=$(git log --all --oneline -- "objects/Economy/$f" | wc -l)
  echo "$f: $count prior commits"
done
```
Vseh 10 datotek je imelo 0 prior commits in so bile odsotne iz workdir — nobenih duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_garden3_milling3_systems.py`
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

## NASLEDNJI PAKET (v3.11.622–v3.11.631) — STEKLARSKI DODATKI 4 + LIVARSKI DODATKI 4

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 4 (v3.11.622-v3.11.626) — predloga
1. **RoyalGlassAnnealingCradleMakerSystem.lua** → `local GlassAnnealingCradleMaker` (zibke za ohlajanje stekla)
2. **RoyalGlassColorantMortarMakerSystem.lua** → `local GlassColorantMortarMaker` (možnarji za barve)
3. **RoyalGlassCaneSlicerMakerSystem.lua** → `local GlassCaneSlicerMaker` (rezalniki steklenih palic)
4. **RoyalGlassKilnDoorLifterMakerSystem.lua** → `local GlassKilnDoorLifterMaker` (dvigalci pečnih vrat)
5. **RoyalGlassEngravingWheelMakerSystem.lua** → `local GlassEngravingWheelMaker` (rezbarska kolesa)

### Livarski dodatki 4 (v3.11.627-v3.11.631) — predloga
6. **RoyalMoldReleaseAgentMakerSystem.lua** → `local MoldReleaseAgentMaker` (sredstva za ločitev kalupov)
7. **RoyalSprueCutterMakerSystem.lua** → `local SprueCutterMaker` (rezalniki vtokov)
8. **RoyalRiserBreakerMakerSystem.lua** → `local RiserBreakerMaker` (lomilci pen)
9. **RoyalSlurryMixerMakerSystem.lua** → `local SlurryMixerMaker` (mešalci livarske kaše)
10. **RoyalMoldDryingOvenMakerSystem.lua** → `local MoldDryingOvenMaker` (sušilne peči za kalupe)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalGlassAnnealingCradleMakerSystem.lua RoyalGlassColorantMortarMakerSystem.lua RoyalGlassCaneSlicerMakerSystem.lua RoyalGlassKilnDoorLifterMakerSystem.lua RoyalGlassEngravingWheelMakerSystem.lua RoyalMoldReleaseAgentMakerSystem.lua RoyalSprueCutterMakerSystem.lua RoyalRiserBreakerMakerSystem.lua RoyalSlurryMixerMakerSystem.lua RoyalMoldDryingOvenMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam v tej skripti)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.622 do v3.11.631 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.621 → version-3.11.631
   - syntax-1355%2F1358 → syntax-1365%2F1368
   - Royal%20systems-709 → Royal%20systems-719
   - Lua%20files-1358 → Lua%20files-1368
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.622 do v3.11.631), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.631.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_garden3_milling3_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_glass4_foundry4_systems.py`
2. Spremeni `GARDEN3_SYSTEMS` in `MILLING3_SYSTEMS` sezname v `GLASS4_SYSTEMS` in `FOUNDRY4_SYSTEMS` z novimi sistemi
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_glass4_foundry4_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)

## PREDLOGA ZA SISTEM (primer GardenHoeMaker, kot referenca)

```lua
local GardenHoeMaker = {}
local PRODUCTS = {
    iron_gardenhoe = { name = "Železni vrtna motika", ironCost = 3, woodCost = 2, leatherCost = 1, time = 5, cost = 150, prestige = 4, happiness = 2, description = "Železni vrtna motika za vrtnarje." },
    -- ... 5 more products (bronze, silver, gilded, jewel_set, royal_sovereign)
}
local BUILDINGS = {
    gardenhoe_workshop = { name = "Gardenhoe delavnica", cost = { gold = 325, wood = 185, stone = 130, iron = 7 }, upkeep = 6, qualityBonus = 5 },
    -- ... 3 more buildings (house, master_atelier, sovereign_palace)
}
GardenHoeMaker.ironStock=16; GardenHoeMaker.bronzeStock=12; ... GardenHoeMaker.pearlStock=4
GardenHoeMaker.productStock = {}; GardenHoeMaker.buildings = {}; GardenHoeMaker.maker = nil; GardenHoeMaker.activeMaking = {}; GardenHoeMaker.totalProducts = 0; GardenHoeMaker.dayTimer = 0
function GardenHoeMaker.init() ... end
function GardenHoeMaker.hireMaker(n,s) ... end
function GardenHoeMaker.canBuild(id) ... end
function GardenHoeMaker.build(id) ... end
function GardenHoeMaker.getQualityBonus() ... end
function GardenHoeMaker.canMake(pt) ... end
function GardenHoeMaker.make(pt,qty) ... end
function GardenHoeMaker.completeMaking(m) ... GardenHoeMaker.productStock[m.productType]=(GardenHoeMaker.productStock[m.productType] or 0)+m.quantity ... end
function GardenHoeMaker.update(dt) ... end
function GardenHoeMaker.getStats() ... end
return GardenHoeMaker
```

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.621. Naslednji paket je v3.11.622–v3.11.631 (steklarski dodatki 4 + livarski dodatki 4: GlassAnnealingCradleMaker, GlassColorantMortarMaker, GlassCaneSlicerMaker, GlassKilnDoorLifterMaker, GlassEngravingWheelMaker, MoldReleaseAgentMaker, SprueCutterMaker, RiserBreakerMaker, SlurryMixerMaker, MoldDryingOvenMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.622–v3.11.626: steklarski dodatki 4 (GlassAnnealingCradleMaker, GlassColorantMortarMaker, GlassCaneSlicerMaker, GlassKilnDoorLifterMaker, GlassEngravingWheelMaker)
- v3.11.627–v3.11.631: livarski dodatki 4 (MoldReleaseAgentMaker, SprueCutterMaker, RiserBreakerMaker, SlurryMixerMaker, MoldDryingOvenMaker)
- v3.11.632–v3.11.636: knjigoveški dodatki 4 (predlagano)
- v3.11.637–v3.11.641: kovaški dodatki 4 (predlagano)
