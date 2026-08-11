# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.681**
- Skupaj Royal sistemov: **769**
- Skupaj Lua datotek: **1418**
- Sintaktična preverba: **1415/1418 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 769 Royal sisteme z igro:

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

## ZADNJE ZAKLJUČENI PAKET (v3.11.672–v3.11.681) — VRTNI DODATKI 5 + MLINARSKI DODATKI 5

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 5 (v3.11.672-v3.11.676)
1. **RoyalGardenTrowelSharpenerMakerSystem.lua** → `local GardenTrowelSharpenerMaker` (brusilci lopatk)
2. **RoyalTrellisMakerSystem.lua** → `local TrellisMaker` (loške rešetke za rastline)
3. **RoyalGardenTwineDispenserMakerSystem.lua** → `local GardenTwineDispenserMaker` (razdelilci vrvice)
4. **RoyalPlantLabelMakerSystem.lua** → `local PlantLabelMaker` (oznake za rastline)
5. **RoyalGardenKneelerMakerSystem.lua** → `local GardenKneelerMaker` (pohištvo za klečenje)

### Mlinarski dodatki 5 (v3.11.677-v3.11.681)
6. **RoyalMillstoneLifterHooksMakerSystem.lua** → `local MillstoneLifterHooksMaker` (kljuki za dviganje kamnov)
7. **RoyalGrainSieveMakerSystem.lua** → `local GrainSieveMaker` (sitane za žito)
8. **RoyalMillHopperAgitatorMakerSystem.lua** → `local MillHopperAgitatorMaker` (stresalci za lijak)
9. **RoyalMillstoneBalancerMakerSystem.lua** → `local MillstoneBalancerMaker` (uravnavalci mlinskih kamnov)
10. **RoyalMillSailClothMakerSystem.lua** → `local MillSailClothMaker` (jedrna tkanina za mlin)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_garden5_milling5_systems.py`
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

## NASLEDNJI PAKET (v3.11.682–v3.11.691) — STEKLARSKI DODATKI 6 + LIVARSKI DODATKI 6

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 6 (v3.11.682-v3.11.686) — predloga
1. **RoyalGlassYokeMakerSystem.lua** → `local GlassYokeMaker` (jarmi za prenos stekla)
2. **RoyalGlassKilnMuffleMakerSystem.lua** → `local GlassKilnMuffleMaker` (muffle za peči)
3. **RoyalGlassCulletCrusherMakerSystem.lua** → `local GlassCulletCrusherMaker` (drobilci steklenega odpada)
4. **RoyalGlassLehrBeltMakerSystem.lua** → `local GlassLehrBeltMaker` (trakovi za ohlajevalne peči)
5. **RoyalGlassEngravingPointMakerSystem.lua** → `local GlassEngravingPointMaker` (rezbarske konice)

### Livarski dodatki 6 (v3.11.687-v3.11.691) — predloga
6. **RoyalMoldWashBoothMakerSystem.lua** → `local MoldWashBoothMaker` (kabine za pranje kalupov)
7. **RoyalSandMullerMakerSystem.lua** → `local SandMullerMaker` (mešalci livarskega peska)
8. **RoyalCoreOvenMakerSystem.lua** → `local CoreOvenMaker` (peči za jedrca)
9. **RoyalLadlePreheaterMakerSystem.lua** → `local LadlePreheaterMaker` (predgrevalci zajemalk)
10. **RoyalCastingLadleSkimmerMakerSystem.lua** → `local CastingLadleSkimmerMaker` (površinski strgalci zajemalk)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalGlassYokeMakerSystem.lua RoyalGlassKilnMuffleMakerSystem.lua RoyalGlassCulletCrusherMakerSystem.lua RoyalGlassLehrBeltMakerSystem.lua RoyalGlassEngravingPointMakerSystem.lua RoyalMoldWashBoothMakerSystem.lua RoyalSandMullerMakerSystem.lua RoyalCoreOvenMakerSystem.lua RoyalLadlePreheaterMakerSystem.lua RoyalCastingLadleSkimmerMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam v tej skripti)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.682 do v3.11.691 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.681 → version-3.11.691
   - syntax-1415%2F1418 → syntax-1425%2F1428
   - Royal%20systems-769 → Royal%20systems-779
   - Lua%20files-1418 → Lua%20files-1428
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.682 do v3.11.691), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.691.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_garden5_milling5_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_glass6_foundry6_systems.py`
2. Spremeni `GARDEN5_SYSTEMS` in `MILLING5_SYSTEMS` sezname v `GLASS6_SYSTEMS` in `FOUNDRY6_SYSTEMS` z novimi sistemi
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_glass6_foundry6_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)

## PREDLOGA ZA SISTEM (primer GardenTrowelSharpenerMaker, kot referenca)

```lua
local GardenTrowelSharpenerMaker = {}
local PRODUCTS = {
    iron_gardentrowelsharpener = { name = "Železni brusilec lopatk", ironCost = 3, woodCost = 2, leatherCost = 1, time = 5, cost = 150, prestige = 4, happiness = 2, description = "Železni brusilec lopatk za vrtnarje." },
    -- ... 5 more products (bronze, silver, gilded, jewel_set, royal_sovereign)
}
local BUILDINGS = {
    gardentrowelsharpener_workshop = { name = "Gardentrowelsharpener delavnica", cost = { gold = 325, wood = 185, stone = 130, iron = 7 }, upkeep = 6, qualityBonus = 5 },
    -- ... 3 more buildings (house, master_atelier, sovereign_palace)
}
GardenTrowelSharpenerMaker.ironStock=16; GardenTrowelSharpenerMaker.bronzeStock=12; ... GardenTrowelSharpenerMaker.pearlStock=4
GardenTrowelSharpenerMaker.productStock = {}; GardenTrowelSharpenerMaker.buildings = {}; GardenTrowelSharpenerMaker.maker = nil; GardenTrowelSharpenerMaker.activeMaking = {}; GardenTrowelSharpenerMaker.totalProducts = 0; GardenTrowelSharpenerMaker.dayTimer = 0
function GardenTrowelSharpenerMaker.init() ... end
function GardenTrowelSharpenerMaker.hireMaker(n,s) ... end
function GardenTrowelSharpenerMaker.canBuild(id) ... end
function GardenTrowelSharpenerMaker.build(id) ... end
function GardenTrowelSharpenerMaker.getQualityBonus() ... end
function GardenTrowelSharpenerMaker.canMake(pt) ... end
function GardenTrowelSharpenerMaker.make(pt,qty) ... end
function GardenTrowelSharpenerMaker.completeMaking(m) ... GardenTrowelSharpenerMaker.productStock[m.productType]=(GardenTrowelSharpenerMaker.productStock[m.productType] or 0)+m.quantity ... end
function GardenTrowelSharpenerMaker.update(dt) ... end
function GardenTrowelSharpenerMaker.getStats() ... end
return GardenTrowelSharpenerMaker
```

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.681. Naslednji paket je v3.11.682–v3.11.691 (steklarski dodatki 6 + livarski dodatki 6: GlassYokeMaker, GlassKilnMuffleMaker, GlassCulletCrusherMaker, GlassLehrBeltMaker, GlassEngravingPointMaker, MoldWashBoothMaker, SandMullerMaker, CoreOvenMaker, LadlePreheaterMaker, CastingLadleSkimmerMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.682–v3.11.686: steklarski dodatki 6 (GlassYokeMaker, GlassKilnMuffleMaker, GlassCulletCrusherMaker, GlassLehrBeltMaker, GlassEngravingPointMaker)
- v3.11.687–v3.11.691: livarski dodatki 6 (MoldWashBoothMaker, SandMullerMaker, CoreOvenMaker, LadlePreheaterMaker, CastingLadleSkimmerMaker)
- v3.11.692–v3.11.696: knjigoveški dodatki 6 (predlagano)
- v3.11.697–v3.11.701: kovaški dodatki 6 (predlagano)
