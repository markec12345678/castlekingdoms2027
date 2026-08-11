# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.591**
- Skupaj Royal sistemov: **679**
- Skupaj Lua datotek: **1328**
- Sintaktična preverba: **1325/1328 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 679 Royal sisteme z igro:

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

## ZADNJE ZAKLJUČENI PAKET (v3.11.582–v3.11.591) — PEKOVSKI DODATKI 2 + KUHINJSKI DODATKI 2

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Pekovski dodatki 2 (v3.11.582-v3.11.586)
1. **RoyalDoughDividerMakerSystem.lua** → `local DoughDividerMaker` (delilniki testa)
2. **RoyalBreadMoldMakerSystem.lua** → `local BreadMoldMaker` (modeli za kruh)
3. **RoyalCrustScorerMakerSystem.lua** → `local CrustScorerMaker` (zarezovalci skorje)
4. **RoyalLoafPanMakerSystem.lua** → `local LoafPanMaker` (pekači za hlebce)
5. **RoyalCrumbTrayMakerSystem.lua** → `local CrumbTrayMaker` (pladnji za drobtine)

### Kuhinjski dodatki 2 (v3.11.587-v3.11.591)
6. **RoyalEggCupMakerSystem.lua** → `local EggCupMaker` (skodelice za jajca)
7. **RoyalButterDishMakerSystem.lua** → `local ButterDishMaker` (posodice za maslo)
8. **RoyalCheeseDomeMakerSystem.lua** → `local CheeseDomeMaker` (klopoti za sir)
9. **RoyalServingTongsMakerSystem.lua** → `local ServingTongsMaker` (servirne klešče)
10. **RoyalSugarTongsMakerSystem.lua** → `local SugarTongsMaker` (sladkorne klešče)

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_bakery2_kitchen2_systems.py`
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

## NASLEDNJI PAKET (v3.11.592–v3.11.601) — STEKLARSKI DODATKI 3 + LIVARSKI DODATKI 3

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 3 (v3.11.592-v3.11.596) — predloga
1. **RoyalGlassKilnFurnitureMakerSystem.lua** → `local GlassKilnFurnitureMaker` (oprema za steklarske peči)
2. **RoyalGlassBenchMakerSystem.lua** → `local GlassBenchMaker` (delovni mizi za steklarje)
3. **RoyalGlassPuntyRodMakerSystem.lua** → `local GlassPuntyRodMaker` (palice za prenos stekla)
4. **RoyalGlassShearsMakerSystem.lua** → `local GlassShearsMaker` (škarde za steklo)
5. **RoyalGlassPolishingWheelMakerSystem.lua** → `local GlassPolishingWheelMaker` (polirni kolesa)

### Livarski dodatki 3 (v3.11.597-v3.11.601) — predloga
6. **RoyalFlaskMakerSystem.lua** → `local FlaskMaker` (livarske steklenice)
7. **RoyalCrucibleTongsMakerSystem.lua** → `local CrucibleTongsMaker` (klešče za crucible)
8. **RoyalSandRiddleMakerSystem.lua** → `local SandRiddleMaker` (sita za pesek)
9. **RoyalPouringLadleSystem.lua** → `local PouringLadleMaker` (livarske zajemalke)
10. **RoyalMoldClampMakerSystem.lua** → `local MoldClampMaker` (sponke za kalupe)

## WORKFLOW ZA NASLEDNJI PAKET

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "glasskilnfurniture|glassbench|glasspuntyrod|glassshears|glasspolishingwheel|flaskmaker|crucibletongs|sandriddle|pouringladle|moldclamp"` (mora biti prazno)
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam v tej skripti)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.592 do v3.11.601 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.591 → version-3.11.601
   - syntax-1325%2F1328 → syntax-1335%2F1338
   - Royal%20systems-679 → Royal%20systems-689
   - Lua%20files-1328 → Lua%20files-1338
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.592 do v3.11.601), push (če je remote na voljo)
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.601.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"`

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_bakery2_kitchen2_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_glass3_foundry3_systems.py`
2. Spremeni `BAKERY2_SYSTEMS` in `KITCHEN2_SYSTEMS` sezname v `GLASS3_SYSTEMS` in `FOUNDRY3_SYSTEMS` z novimi sistemi
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_glass3_foundry3_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)

## PREDLOGA ZA SISTEM (primer DoughDividerMaker, kot referenca)

```lua
local DoughDividerMaker = {}
local PRODUCTS = {
    iron_doughdivider = { name = "Železni delilnik testa", ironCost = 3, woodCost = 2, leatherCost = 1, time = 5, cost = 150, prestige = 4, happiness = 2, description = "Železni delilnik testa za pekove." },
    -- ... 5 more products (bronze, silver, gilded, jewel_set, royal_sovereign)
}
local BUILDINGS = {
    doughdivider_workshop = { name = "Doughdivider delavnica", cost = { gold = 325, wood = 185, stone = 130, iron = 7 }, upkeep = 6, qualityBonus = 5 },
    -- ... 3 more buildings (house, master_atelier, sovereign_palace)
}
DoughDividerMaker.ironStock=14; DoughDividerMaker.bronzeStock=12; ... DoughDividerMaker.pearlStock=4
DoughDividerMaker.productStock = {}; DoughDividerMaker.buildings = {}; DoughDividerMaker.maker = nil; DoughDividerMaker.activeMaking = {}; DoughDividerMaker.totalProducts = 0; DoughDividerMaker.dayTimer = 0
function DoughDividerMaker.init() ... end
function DoughDividerMaker.hireMaker(n,s) ... end
function DoughDividerMaker.canBuild(id) ... end
function DoughDividerMaker.build(id) ... end
function DoughDividerMaker.getQualityBonus() ... end
function DoughDividerMaker.canMake(pt) ... end
function DoughDividerMaker.make(pt,qty) ... end
function DoughDividerMaker.completeMaking(m) ... DoughDividerMaker.productStock[m.productType]=(DoughDividerMaker.productStock[m.productType] or 0)+m.quantity ... end
function DoughDividerMaker.update(dt) ... end
function DoughDividerMaker.getStats() ... end
return DoughDividerMaker
```

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.591. Naslednji paket je v3.11.592–v3.11.601 (steklarski dodatki 3 + livarski dodatki 3: GlassKilnFurnitureMaker, GlassBenchMaker, GlassPuntyRodMaker, GlassShearsMaker, GlassPolishingWheelMaker, FlaskMaker, CrucibleTongsMaker, SandRiddleMaker, PouringLadleMaker, MoldClampMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom.
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.592–v3.11.596: steklarski dodatki 3 (GlassKilnFurnitureMaker, GlassBenchMaker, GlassPuntyRodMaker, GlassShearsMaker, GlassPolishingWheelMaker)
- v3.11.597–v3.11.601: livarski dodatki 3 (FlaskMaker, CrucibleTongsMaker, SandRiddleMaker, PouringLadleMaker, MoldClampMaker)
- v3.11.602–v3.11.606: knjigoveški dodatki 3 (predlagano)
- v3.11.607–v3.11.611: kovaški dodatki 3 (predlagano)
