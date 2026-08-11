# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.601**
- Skupaj Royal sistemov: **689**
- Skupaj Lua datotek: **1338**
- Sintaktična preverba: **1335/1338 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 689 Royal sisteme z igro:

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

## ZADNJE ZAKLJUČENI PAKET (v3.11.592–v3.11.601) — STEKLARSKI DODATKI 3 + LIVARSKI DODATKI 3

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 3 (v3.11.592-v3.11.596)
1. **RoyalGlassKilnFurnitureMakerSystem.lua** → `local GlassKilnFurnitureMaker` (oprema za steklarske peči)
2. **RoyalGlassBenchMakerSystem.lua** → `local GlassBenchMaker` (delovne mize za steklarje)
3. **RoyalGlassPuntyRodMakerSystem.lua** → `local GlassPuntyRodMaker` (palice za prenos stekla)
4. **RoyalGlassShearsMakerSystem.lua** → `local GlassShearsMaker` (škarde za steklo)
5. **RoyalGlassPolishingWheelMakerSystem.lua** → `local GlassPolishingWheelMaker` (polirna kolesa za steklo)

### Livarski dodatki 3 (v3.11.597-v3.11.601)
6. **RoyalVentWireMakerSystem.lua** → `local VentWireMaker` (žice za odzračevanje)
7. **RoyalCrucibleTongsMakerSystem.lua** → `local CrucibleTongsMaker` (klešče za crucible)
8. **RoyalSandRiddleMakerSystem.lua** → `local SandRiddleMaker` (sita za pesek)
9. **RoyalPouringLadleMakerSystem.lua** → `local PouringLadleMaker` (livarske zajemalke)
10. **RoyalMoldClampMakerSystem.lua** → `local MoldClampMaker` (sponke za kalupe)

**POMEMBNO:** V paketu je bil prvotno načrtovan FlaskMaker, vendar je bilo ugotovljeno, da `RoyalFlaskMakerSystem.lua` že obstaja od v3.11.447 (Foundry/casting equipment batch). Da bi se izognili duplikatu, je bil FlaskMaker zamenjan z VentWireMaker (žice za odzračevanje) — novo, komplementarno livarsko orodje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_glass3_foundry3_systems.py`
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

## NASLEDNJI PAKET (v3.11.602–v3.11.611) — KNJIGOVEŠKI DODATKI 3 + KOVAŠKI DODATKI 3

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Knjigoveški dodatki 3 (v3.11.602-v3.11.606) — predloga
1. **RoyalBookStitchingFrameMakerSystem.lua** → `local BookStitchingFrameMaker` (okvirji za šivanje knjig)
2. **RoyalBookCoverStampMakerSystem.lua** → `local BookCoverStampMaker` (žig za naslovnice)
3. **RoyalGildingBrushMakerSystem.lua** → `local GildingBrushMaker` (čopiči za pozlačevanje)
4. **RoyalHeadbandLoomMakerSystem.lua** → `local HeadbandLoomMaker` (statve za kapice)
5. **RoyalBookClaspMakerSystem.lua** → `local BookClaspMaker` (sponke za knjige)

### Kovaški dodatki 3 (v3.11.607-v3.11.611) — predloga
6. **RoyalSwageBlockMakerSystem.lua** → `local SwageBlockMaker` (kalupi za kovanje)
7. **RoyalHardyHoleMakerSystem.lua** → `local HardyHoleMaker` (luknje za trdo orodje)
8. **RoyalTreadleHammerMakerSystem.lua** → `local TreadleHammerMaker` (pedalna kladiva)
9. **RoyalFullerMakerSystem.lua** → `local FullerMaker` (fullerji za utorjanje)
10. **RoyalFlatterMakerSystem.lua** → `local FlatterMaker` (ploščati kladiva)

## WORKFLOW ZA NASLEDNJI PAKET

1. Preveri duplikate: `ls objects/Economy/ | grep -iE "bookstitchingframe|bookcoverstamp|gildingbrush|headbandloom|bookclasp|swageblock|hardyhole|treadlehammer|fuller|flatter"` (mora biti prazno)
   - **POMEMBNO**: Pred generiranjem vedno preveri tudi git zgodovino: `git log --all --oneline -- "objects/Economy/ImeDatoteke.lua"`. V prejšnjem paketu je bilo ugotovljeno, da RoyalFlaskMakerSystem.lua že obstaja od v3.11.447 — FlaskMaker je bil zato zamenjan z VentWireMaker.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam v tej skripti)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.602 do v3.11.611 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.601 → version-3.11.611
   - syntax-1335%2F1338 → syntax-1345%2F1348
   - Royal%20systems-689 → Royal%20systems-699
   - Lua%20files-1338 → Lua%20files-1348
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.602 do v3.11.611), push (če je remote na voljo)
8. Build .love: `cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.611.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"`

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_glass3_foundry3_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_bookbinding3_blacksmith3_systems.py`
2. Spremeni `GLASS3_SYSTEMS` in `FOUNDRY3_SYSTEMS` sezname v `BOOKBINDING3_SYSTEMS` in `BLACKSMITH3_SYSTEMS` z novimi sistemi
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_bookbinding3_blacksmith3_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)

## PREDLOGA ZA SISTEM (primer GlassKilnFurnitureMaker, kot referenca)

```lua
local GlassKilnFurnitureMaker = {}
local PRODUCTS = {
    iron_glasskilnfurniture = { name = "Železni oprema za steklarske peči", ironCost = 3, woodCost = 2, leatherCost = 1, time = 5, cost = 150, prestige = 4, happiness = 2, description = "Železni oprema za steklarske peči za steklarje." },
    -- ... 5 more products (bronze, silver, gilded, jewel_set, royal_sovereign)
}
local BUILDINGS = {
    glasskilnfurniture_workshop = { name = "Glasskilnfurniture delavnica", cost = { gold = 325, wood = 185, stone = 130, iron = 7 }, upkeep = 6, qualityBonus = 5 },
    -- ... 3 more buildings (house, master_atelier, sovereign_palace)
}
GlassKilnFurnitureMaker.ironStock=14; GlassKilnFurnitureMaker.bronzeStock=12; ... GlassKilnFurnitureMaker.pearlStock=4
GlassKilnFurnitureMaker.productStock = {}; GlassKilnFurnitureMaker.buildings = {}; GlassKilnFurnitureMaker.maker = nil; GlassKilnFurnitureMaker.activeMaking = {}; GlassKilnFurnitureMaker.totalProducts = 0; GlassKilnFurnitureMaker.dayTimer = 0
function GlassKilnFurnitureMaker.init() ... end
function GlassKilnFurnitureMaker.hireMaker(n,s) ... end
function GlassKilnFurnitureMaker.canBuild(id) ... end
function GlassKilnFurnitureMaker.build(id) ... end
function GlassKilnFurnitureMaker.getQualityBonus() ... end
function GlassKilnFurnitureMaker.canMake(pt) ... end
function GlassKilnFurnitureMaker.make(pt,qty) ... end
function GlassKilnFurnitureMaker.completeMaking(m) ... GlassKilnFurnitureMaker.productStock[m.productType]=(GlassKilnFurnitureMaker.productStock[m.productType] or 0)+m.quantity ... end
function GlassKilnFurnitureMaker.update(dt) ... end
function GlassKilnFurnitureMaker.getStats() ... end
return GlassKilnFurnitureMaker
```

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.601. Naslednji paket je v3.11.602–v3.11.611 (knjigoveški dodatki 3 + kovaški dodatki 3: BookStitchingFrameMaker, BookCoverStampMaker, GildingBrushMaker, HeadbandLoomMaker, BookClaspMaker, SwageBlockMaker, HardyHoleMaker, TreadleHammerMaker, FullerMaker, FlatterMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom.
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.602–v3.11.606: knjigoveški dodatki 3 (BookStitchingFrameMaker, BookCoverStampMaker, GildingBrushMaker, HeadbandLoomMaker, BookClaspMaker)
- v3.11.607–v3.11.611: kovaški dodatki 3 (SwageBlockMaker, HardyHoleMaker, TreadleHammerMaker, FullerMaker, FlatterMaker)
- v3.11.612–v3.11.616: mlinarski dodatki 3 (predlagano)
- v3.11.617–v3.11.621: vrtni dodatki 3 (predlagano)
