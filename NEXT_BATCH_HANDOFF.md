# HANDOFF DOKUMENT — Castle Kingdoms 2027

## TRENUTNO STANJE
- Različica: **v3.11.651**
- Skupaj Royal sistemov: **739**
- Skupaj Lua datotek: **1388**
- Sintaktična preverba: **1385/1388 pass** (3 znani false positives: moonscript.lua, test.lua, grid.lua)
- GitHub: sinhroniziran (vsi tagi pushani)
- Lokalni repo: `/home/z/my-project/castlekingdoms2027`
- .love datoteke: `/home/z/my-project/download/`

## NOVO: Royal Systems Registry + UI Panel (v3.11.382)

Od v3.11.382 projekt vključuje **centralen manager in UI panel**, ki povezuje vse 739 Royal sisteme z igro:

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

## ZADNJE ZAKLJUČENI PAKET (v3.11.642–v3.11.651) — VRTNI DODATKI 4 + MLINARSKI DODATKI 4

10 novih sistemov ustvarjenih v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Vrtni dodatki 4 (v3.11.642-v3.11.646)
1. **RoyalGardenSecateursMakerSystem.lua** → `local GardenSecateursMaker` (vrtni škarjici)
2. **RoyalHedgeShearsMakerSystem.lua** → `local HedgeShearsMaker` (škarje za žive meje)
3. **RoyalLawnAeratorMakerSystem.lua** → `local LawnAeratorMaker` (zračilci travnikov)
4. **RoyalGardenSprayerMakerSystem.lua** → `local GardenSprayerMaker` (vrtni škropilnice)
5. **RoyalCompostSieveMakerSystem.lua** → `local CompostSieveMaker` (sitane za kompost)

### Mlinarski dodatki 4 (v3.11.647-v3.11.651)
6. **RoyalMillstoneCraneHookMakerSystem.lua** → `local MillstoneCraneHookMaker` (kljuki za dvig mlinskih kamnov)
7. **RoyalGrainHopperLinerMakerSystem.lua** → `local GrainHopperLinerMaker` (obloge za lijake)
8. **RoyalMillDriveBeltMakerSystem.lua** → `local MillDriveBeltMaker` (pogonski jermeni)
9. **RoyalFlourPackerMakerSystem.lua** → `local FlourPackerMaker` (pakerji za moko)
10. **RoyalMillstoneGrooveReframerMakerSystem.lua** → `local MillstoneGrooveReframerMaker` (obnavljalci utorov)

### PRE-FLIGHT CHECK
Pred generiranjem je bila preverjena git zgodovina za vseh 10 datotek — vse so imele 0 prior commits in so bile odsotne iz workdir. Brez duplikatov, varno za generiranje.

### GENERATORSKA SKRIPTA
- Nova skripta: `/home/z/my-project/scripts/generate_garden4_milling4_systems.py`
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

## NASLEDNJI PAKET (v3.11.652–v3.11.661) — STEKLARSKI DODATKI 5 + LIVARSKI DODATKI 5

Ustvari 10 novih sistemov v `/home/z/my-project/castlekingdoms2027/objects/Economy/`:

### Steklarski dodatki 5 (v3.11.652-v3.11.656) — predloga
1. **RoyalGlassBlowingMoldMakerSystem.lua** → `local GlassBlowingMoldMaker` (modeli za pihanje stekla)
2. **RoyalGlassCoolingRackMakerSystem.lua** → `local GlassCoolingRackMaker` (ohlajevalne police)
3. **RoyalGlassBatch MixerMakerSystem.lua** → `local GlassBatchMixerMaker` (mešalci steklarske mešanice)
4. **RoyalGlassKilnSealMakerSystem.lua** → `local GlassKilnSealMaker` (tesnila za peči)
5. **RoyalGlassPolishingPadMakerSystem.lua** → `local GlassPolishingPadMaker` (polirne blazinice)

### Livarski dodatki 5 (v3.11.657-v3.11.661) — predloga
6. **RoyalInoculationLadleMakerSystem.lua** → `local InoculationLadleMaker` (inokulacijske zajemalke)
7. **RoyalDegassingLanceMakerSystem.lua** → `local DegassingLanceMaker` (plinilne kopja)
8. **RoyalThermocoupleSheathMakerSystem.lua** → `local ThermocoupleSheathMaker` (zaščite termoelementov)
9. **RoyalMoldCoatingBrushMakerSystem.lua** → `local MoldCoatingBrushMaker` (čopiči za premaze)
10. **RoyalCoreBoxMakerSystem.lua** → `local CoreBoxMaker` (jeklenke za jedrca)

## WORKFLOW ZA NASLEDNJI PAKET

1. **PRE-FLIGHT CHECK (obvezno)**: Preveri git zgodovino za vsako od 10 načrtovanih datotek:
   ```bash
   for f in RoyalGlassBlowingMoldMakerSystem.lua RoyalGlassCoolingRackMakerSystem.lua RoyalGlassBatchMixerMakerSystem.lua RoyalGlassKilnSealMakerSystem.lua RoyalGlassPolishingPadMakerSystem.lua RoyalInoculationLadleMakerSystem.lua RoyalDegassingLanceMakerSystem.lua RoyalThermocoupleSheathMakerSystem.lua RoyalMoldCoatingBrushMakerSystem.lua RoyalCoreBoxMakerSystem.lua; do
     count=$(git -C /home/z/my-project/castlekingdoms2027 log --all --oneline -- "objects/Economy/$f" | wc -l)
     exists=$(test -f "/home/z/my-project/castlekingdoms2027/objects/Economy/$f" && echo "EXISTS" || echo "absent")
     echo "$f: git_history=$count  $exists"
   done
   ```
   Vse morajo imeti `git_history=0` in `absent`. Če katera ima >0, izberi alternativno ime.
2. Ustvari 10 .lua datotek z generatorsko skripto (glej spodaj)
3. Poženi sintaktično preverbo: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam v tej skripti)
4. Posodobi CHANGELOG.md (dodaj vnose za v3.11.652 do v3.11.661 na vrh)
5. Posodobi README.md badge-je:
   - version-3.11.651 → version-3.11.661
   - syntax-1385%2F1388 → syntax-1395%2F1398
   - Royal%20systems-739 → Royal%20systems-749
   - Lua%20files-1388 → Lua%20files-1398
6. Posodobi NEXT_BATCH_HANDOFF.md (ta dokument) z naslednjim paketom
7. Git: commit, tag (v3.11.652 do v3.11.661), push
8. Build .love (POZOR: vedno cd v castlekingdoms2027 direktorij pred zip!):
   ```bash
   cd /home/z/my-project/castlekingdoms2027 && zip -r -q /home/z/my-project/download/castlekingdoms2027-v3.11.661.love . -x ".git/*" "tool-results/*" "*.love" ".gitignore"
   ```

## GENERATORSKA SKRIPTA — PRIMER

Glej `/home/z/my-project/scripts/generate_garden4_milling4_systems.py` kot referenco. Za nov paket:
1. Kopiraj skripto v `generate_glass5_foundry5_systems.py`
2. Spremeni `GARDEN4_SYSTEMS` in `MILLING4_SYSTEMS` sezname v `GLASS5_SYSTEMS` in `FOUNDRY5_SYSTEMS` z novimi sistemi
3. Spremeni imena produktov, makerjev, delavnic, etc.
4. Poženi: `python3 /home/z/my-project/scripts/generate_glass5_foundry5_systems.py`
5. Preveri sintakso: `python3 /home/z/my-project/scripts/check_new_systems_syntax.py` (posodobi NEW_FILES seznam)

## PREDLOGA ZA SISTEM (primer GardenSecateursMaker, kot referenca)

```lua
local GardenSecateursMaker = {}
local PRODUCTS = {
    iron_gardensecateurs = { name = "Železni vrtni škarjici", ironCost = 3, woodCost = 2, leatherCost = 1, time = 5, cost = 150, prestige = 4, happiness = 2, description = "Železni vrtni škarjici za vrtnarje." },
    -- ... 5 more products (bronze, silver, gilded, jewel_set, royal_sovereign)
}
local BUILDINGS = {
    gardensecateurs_workshop = { name = "Gardensecateurs delavnica", cost = { gold = 325, wood = 185, stone = 130, iron = 7 }, upkeep = 6, qualityBonus = 5 },
    -- ... 3 more buildings (house, master_atelier, sovereign_palace)
}
GardenSecateursMaker.ironStock=18; GardenSecateursMaker.bronzeStock=14; ... GardenSecateursMaker.pearlStock=4
GardenSecateursMaker.productStock = {}; GardenSecateursMaker.buildings = {}; GardenSecateursMaker.maker = nil; GardenSecateursMaker.activeMaking = {}; GardenSecateursMaker.totalProducts = 0; GardenSecateursMaker.dayTimer = 0
function GardenSecateursMaker.init() ... end
function GardenSecateursMaker.hireMaker(n,s) ... end
function GardenSecateursMaker.canBuild(id) ... end
function GardenSecateursMaker.build(id) ... end
function GardenSecateursMaker.getQualityBonus() ... end
function GardenSecateursMaker.canMake(pt) ... end
function GardenSecateursMaker.make(pt,qty) ... end
function GardenSecateursMaker.completeMaking(m) ... GardenSecateursMaker.productStock[m.productType]=(GardenSecateursMaker.productStock[m.productType] or 0)+m.quantity ... end
function GardenSecateursMaker.update(dt) ... end
function GardenSecateursMaker.getStats() ... end
return GardenSecateursMaker
```

## SPOROČILO ZA NOVO SEJO

Ko začneš novo sejo, pošlji to sporočilo:

```
Nadaljuj z razvojem Castle Kingdoms 2027. Preberi /home/z/my-project/castlekingdoms2027/NEXT_BATCH_HANDOFF.md za popolna navodila. Trenutna različica je v3.11.651. Naslednji paket je v3.11.652–v3.11.661 (steklarski dodatki 5 + livarski dodatki 5: GlassBlowingMoldMaker, GlassCoolingRackMaker, GlassBatchMixerMaker, GlassKilnSealMaker, GlassPolishingPadMaker, InoculationLadleMaker, DegassingLanceMaker, ThermocoupleSheathMaker, MoldCoatingBrushMaker, CoreBoxMaker). Sledi navodilom v handoff dokumentu. Po končanem paketu ročno posodobi NEXT_BATCH_HANDOFF.md z naslednjim paketom. POMEMBNO: pred generiranjem obvezno preveri git zgodovino za vsako datoteko!
```

## NASLEDNJI PAKETI (po vrsti)

- v3.11.652–v3.11.656: steklarski dodatki 5 (GlassBlowingMoldMaker, GlassCoolingRackMaker, GlassBatchMixerMaker, GlassKilnSealMaker, GlassPolishingPadMaker)
- v3.11.657–v3.11.661: livarski dodatki 5 (InoculationLadleMaker, DegassingLanceMaker, ThermocoupleSheathMaker, MoldCoatingBrushMaker, CoreBoxMaker)
- v3.11.662–v3.11.666: knjigoveški dodatki 5 (predlagano)
- v3.11.667–v3.11.671: kovaški dodatki 5 (predlagano)
