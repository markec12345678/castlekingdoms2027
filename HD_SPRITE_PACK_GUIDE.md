# HD Sprite Pack Guide — Royal System Tier 1

> Tehnične specifikacije in AI prompt predloge za generacijo prvih 50 HD sprite-ov.
> Generirano: 2026-08-23 | Verzija: v3.12.155
>
> Povezani dokumenti:
> - [ASSET_PRIORITY_PLAN.md](ASSET_PRIORITY_PLAN.md) — prioritete in faze
> - [HD_ASSETS_GUIDE.md](HD_ASSETS_GUIDE.md) — splošne tehnične specifikacije
> - [STEAM_STORE_PAGE.md](STEAM_STORE_PAGE.md) — Steam specifikacije

---

## 📋 Specifikacije Tier 1 sprite-ev

### Tehnične zahteve

| Parameter | Zahteva |
|-----------|---------|
| **Format** | PNG z alfa kanalom (PNG-32) |
| **Resolucija** | 256 × 256 pikslov |
| **Barvna globina** | 8-bitni RGBA (32-bit) |
| **Stil** | Srednjeveški, top-down, v skladu z obstoječo Stone Kingdoms estetiko |
| **Osvetlitev** | Zgornja (top-down), konsistentna z igro |
| **Perspektiva** | Rahlo izotermična (45° top-down, podobno Stronghold/Crusader Kings) |
| **Robovi** | Anti-aliased robovi na prosojnem ozadju |
| **Velikost datoteke** | < 200 KB na sprite |
| **LFS** | Da — `.gitattributes` že konfiguriran za `*.png` |

### Lokacija in poimenovanje

```
assets/royal_systems/tier1/<SystemBaseName>.png
```

Primeri:
- `assets/royal_systems/tier1/Abacus.png` (za `RoyalAbacusMakerSystem`)
- `assets/royal_systems/tier1/AleBrewer.png` (za `RoyalAleBrewerSystem`)
- `assets/royal_systems/tier1/AngelusBell.png` (za `RoyalAngelusBellMakerSystem`)

**Pravila normalizacije imen** (avtomatsko v `royal_icon_generator.lua`):
1. Odstrani `Royal` prefix
2. Odstrani `MakerSystem` suffix
3. Odstrani `System` suffix (če ni MakerSystem)
4. Odstrani `Maker` suffix (če je sam)

---

## 🎨 Estetski standardi

### Barvna paleta

Uporabi toplo, zemeljsko paleto v skladu s Stone Kingdoms:

| Element | Barva (HEX) | Opis |
|---------|-------------|------|
| Les (svetel) | `#D4A574` | Hrast, breza |
| Les (temen) | `#8B5A3C` | Hrast, oreh |
| Kamen (svetel) | `#B8B0A4` | Apnenec |
| Kamen (temen) | `#5C5550` | Granit |
| Železo | `#6B6E78` | Surovo železo |
| Jeklo | `#A8B0B8` | Polirano jeklo |
| Baker | `#C97850` | Topla bakerjeva |
| Medenina | `#D4A04F` | Zlata medenina |
| Srebro | `#D8DDE2` | Hladno srebro |
| Zlato | `#E8C04F` | Toplo zlato |
| Usnje (svetlo) | `#A87858` | Naravno usnje |
| Usnje (temno) | `#5C3A28` | Strojenoo usnje |
| Tekstil (rdeč) | `#A53B3B` | Rdeče barvilo |
| Tekstil (moder) | `#3B5BA5` | Indigo |
| Tekstil (zelen) | `#5A8C3B` | Rastlinsko zeleno |

### Kompozicija

Vsak sprite naj vsebuje:

1. **Glavni predmet** — center, ~70% površine
2. **Ozadje** — prosojno (alpha = 0), nikoli polno ozadje
3. **Senca** — mehka senca pod predmetom (~10% opacity, ~3px offset)
4. **Robni detaili** — 1-2 px tanek svetli rob na zgornji/levi strani za globino
5. **Textura** — subtilna, ne preveč glasna

### Kategorije — barvne konvencije

Vsaka kategorija ima lastno barvno identiteto (konsistentno z `royal_icon_generator.lua`):

| Kategorija | Primary barva | Predmet primarno |
|------------|---------------|------------------|
| Kovaštvo | Rdeče-rjava | Anvil, kladivo |
| Knjigoveštvo | Vijolična | Knjiga, pergament |
| Steklarstvo | Modra | Vial, kozarec |
| Mlinarstvo | Pšenično rumena | Žito, mlin |
| Vrtnarstvo | Zelena | Rastlina, list |
| Pekarstvo | Rjavo-zlata | Kruh, pecivo |
| Pivovarstvo | Jantarno rjava | sod piva |
| Orožje | Temno rdeča | Meč, sulica |
| Heraldika | Crest rdeča | Ščit, zastava |
| Astronomija | Temno modra | Zvezda, instrument |
| Vodovod | Vodna modra | Vodnjak, kopel |
| Živali | Živalsko rjava | Piščanec, pes |

---

## 🤖 AI-generacija — Prompt predloge

### Splošni AI prompt pattern

```
A medieval [ITEM_NAME] icon in the style of a top-down strategy game like
Stronghold Crusader. [ITEM_DESCRIPTION]. Hand-painted look, warm earthy
colors (browns, tans, golds, deep reds), soft top-down lighting, square
composition centered on a transparent background, soft shadow underneath,
subtle rim light on upper-left edge. The object should look used and
weathered, not pristine. Resolution: 256x256 pixels, PNG with alpha.
No text, no border, no UI elements.
```

### Specifični prompt-i za Top 50 sistemov (grupirano po kategoriji)

#### 🟥 Material Crafts

| # | Sistem | AI Prompt | Opomba |
|---|--------|-----------|--------|
| 1 | **Abacus** | "A wooden abacus with brass beads on vertical wires, ornate carved frame, polished wood, medieval merchant tool" | Tier 1, najvišja prioritet |
| 2 | **CutlerySmith** | "A medieval blacksmith's cutlery display: ornate knife, fork, and spoon with decorated handles, laid crossed on a wooden surface" | Kovaštvo |
| 3 | **CookwareFounder** | "A set of medieval copper cooking pots: a large cauldron, a saucepan, and a ladle, arranged diagonally, weathered patina" | |
| 4 | **Brick** | "A stack of handmade medieval clay bricks, reddish-orange, with straw imprints, weathered edges" | |
| 5 | **ClayDigger** | "A wooden shovel stuck in a pile of grey clay, with a wicker basket beside it, muddy ground" | |
| 6 | **CharcoalBurner** | "A medieval charcoal burner's mound: a smoking earth mound with a wooden air vent, surrounded by split logs" | |

#### 🟧 Food & Beverage

| # | Sistem | AI Prompt | Opomba |
|---|--------|-----------|--------|
| 7 | **AleBrewer** | "A wooden ale brewing setup: a large oak barrel with brass spigot, a wooden ladle, hops scattered on top" | Pivovarstvo |
| 8 | **BreadBaker** | "A round medieval loaf of dark rye bread, scored with a cross pattern, on a wooden peel, dusted with flour" | Pekarstvo |
| 9 | **Confectioner** | "An assortment of medieval sweets: marzipan fruits, honeyed nuts, and candied citrus peel on a small silver tray" | |
| 10 | **ButterChurner** | "A wooden butter churn with a wooden plunger, butter pat on a wooden board beside it, churned cream visible" | |
| 11 | **Cheese** | "A wheel of aged medieval cheese with a rind, cut to show interior, with a cheese knife, on a wooden board" | Mlekarstvo |
| 12 | **CiderPress** | "A wooden cider press with a screw mechanism, crushed apples visible, juice flowing into a bucket" | |
| 13 | **CoffeeRoaster** | "A medieval coffee roasting pan: a long-handled iron pan with green and roasted coffee beans, smoke rising" | |
| 14 | **FishSmoker** | "A wooden fish smoking rack with 3 hanging smoked fish, small fire underneath, smoke wisps" | |
| 15 | **Fisherman** | "A wooden fishing rod with a brass reel, a wicker basket with fish, a coil of rope" | |
| 16 | **FishingRod** | "A medieval fishing rod made of bamboo, with a bone handle, brass hooks, and a line wound around a wooden spool" | |

#### 🟨 Textile & Leather

| # | Sistem | AI Prompt | Opomba |
|---|--------|-----------|--------|
| 17 | **CanvasWeaver** | "A medieval loom with half-woven canvas, wooden frame, shuttle visible, woven cloth in earthy tones" | |
| 18 | **CarpetLoom** | "An ornate oriental rug on a wooden loom, intricate geometric patterns in reds and golds, half-rolled" | |
| 19 | **Crocheter** | "A wooden crochet hook with a half-finished doily in cream thread, a ball of yarn beside it" | |
| 20 | **Bobbin** | "Wooden bobbins wound with colored thread: red, blue, green, arranged in a stack, with a thimble on top" | |
| 21 | **Curtain** | "Heavy medieval velvet curtains in deep crimson, drawn back with a gold tassel cord, brass rod visible" | |
| 22 | **Furrier** | "A pile of medieval furs: fox pelts, rabbit skins, and a beaver pelt, arranged on a wooden table" | Usnjarstvo |
| 23 | **DyeStuff** | "Bundles of dried dye plants: woad (blue), madder (red), weld (yellow), tied with twine, in a basket" | |

#### 🟩 Light & Sound

| # | Sistem | AI Prompt | Opomba |
|---|--------|-----------|--------|
| 24 | **Candlestick** | "An ornate medieval brass candlestick with a lit beeswax candle, flame flickering, soft glow, warm light" | Osvetlitev |
| 25 | **Candelabra** | "A 5-armed medieval brass candelabra with all candles lit, ornate scrollwork, warm glow, soft shadows" | |
| 26 | **CrystalGoblet** | "A medieval crystal goblet with red wine, faceted glass catching light, ornate silver base, on a dark surface" | |
| 27 | **Drummer** | "A medieval drum with wooden frame and leather head, two drumsticks crossed on top, decorative red trim" | |
| 28 | **Flute** | "A medieval wooden flute with brass fittings, carved with decorative patterns, lying diagonally" | |
| 29 | **Fiddle** | "A medieval fiddle with a curved bow, wooden body, gut strings, ornate scroll at the neck" | |
| 30 | **Crumhorn** | "A medieval crumhorn: a curved wooden wind instrument with a brass reed cap, dark wood with decorative carving" | |
| 31 | **Cymbal** | "A pair of medieval brass finger cymbals with leather straps, ornate engraved pattern, slightly tarnished" | |

#### 🟦 Games & Toys

| # | Sistem | AI Prompt | Opomba |
|---|--------|-----------|--------|
| 32 | **BoardGame** | "A medieval chess set: ornate wooden board with carved pieces, half through a game, ivory and dark wood pieces" | |
| 33 | **CardDeck** | "A deck of medieval playing cards: hand-painted court cards (king, queen, jack) fanned out, weathered edges" | |
| 34 | **Domino** | "A set of medieval bone dominoes with black pips, arranged in a snake pattern on a wooden table" | |
| 35 | **DollHouse** | "A miniature medieval timber-framed dollhouse, with tiny furniture visible through open windows, weathered wood" | |

#### 🟪 Time & Science

| # | Sistem | AI Prompt | Opomba |
|---|--------|-----------|--------|
| 36 | **Calendar** | "A medieval perpetual calendar: a circular wooden disk with rotating inner wheel, zodiac symbols, brass fittings" | |
| 37 | **Compass** | "A medieval brass compass with a magnetic needle, ornate engravings, open showing the cardinal directions" | Astronomija |
| 38 | **ClockFacePainter** | "A medieval clock face: a brass disk with Roman numerals, ornate hands, decorative scrollwork around the edge" | |
| 39 | **BalanceScale** | "A medieval merchant's balance scale: brass beam with two pans, on a wooden stand, with brass weights beside it" | |

#### ⚜ Heraldika & Decorative

| # | Sistem | AI Prompt | Opomba |
|---|--------|-----------|--------|
| 40 | **Banner** | "A medieval heraldic banner hanging from a wooden pole: red lion rampant on a gold field, fringed bottom, weathered" | Heraldika |
| 41 | **Brooch** | "A medieval silver brooch with a cabochon ruby center, intricate filigree work, Celtic knot pattern" | |
| 42 | **CommemorativeToken** | "A medieval commemorative coin: gold with a king's profile on obverse, castle on reverse, ornate border" | |

#### 🌿 Nature & Cultivation

| # | Sistem | AI Prompt | Opomba |
|---|--------|-----------|--------|
| 43 | **AloeCultivator** | "A wooden planter with three aloe vera plants in terra cotta pots, a small bronze trowel beside them" | Vrtnarstvo |
| 44 | **ApiaryKeeper** | "A medieval woven beehive (skep) with a wooden base, bees flying around, honeycomb visible at the entrance" | Živali |
| 45 | **AviaryKeeper** | "A medieval birdcage with a falcon inside, ornate ironwork, perch with leather jess, decorative top" | |
| 46 | **ButterflyBreeder** | "A collection of pinned medieval butterflies in a wooden display case: 6 species, hand-written Latin labels" | |
| 47 | **CattleRancher** | "A medieval brown cow with horns, standing in profile, branding visible on flank, in a wooden pen" | |
| 48 | **CottonGin** | "A medieval cotton gin: a wooden hand-cranked machine with rollers, cotton fibers visible, on a wooden frame" | |

#### ⚗ Apothecary & Craft

| # | Sistem | AI Prompt | Opomba |
|---|--------|-----------|--------|
| 49 | **ApothecaryMortar** | "A medieval bronze apothecary mortar with a wooden pestle, dried herbs scattered around, small glass vial nearby" | Aptekarstvo |
| 50 | **BeakerBlower** | "A medieval glassblower's setup: a long blowpipe with a molten glass bulb at the end, glowing orange-red, on a wooden stand" | Steklarstvo |

---

## 🛠 Implementacijski workflow

### Faza 1: Priprava (1 dan)

1. **Namesti AI tooling** (enega od):
   - **Stable Diffusion XL** z LoRA za top-down asset-e
   - **Midjourney v6** z `--style raw --stylize 250` parameter
   - **DALL-E 3** preko OpenAI API

2. **Pripravi reference slike**:
   - Stone Kingdoms tileset (screenshot obstoječih zgradb)
   - Stronghold Crusader (2002) reference slike
   - Crusader Kings 3 UI elementi

3. **Test batch** (3 sprite-i):
   - Generiraj: `Abacus.png`, `AleBrewer.png`, `BreadBaker.png`
   - Preglej kvaliteto, konzistenco stila
   - Po potrebi prilagodi prompt-e

### Faza 2: Generacija (5 dni)

4. **Batch 1** (15 sprite-ev) — Material Crafts + Food
5. **Batch 2** (15 sprite-ev) — Textile + Light/Sound
6. **Batch 3** (10 sprite-ev) — Games + Science + Heraldika
7. **Batch 4** (10 sprite-ev) — Nature + Apothecary

### Faza 3: Cleanup in integracija (2 dni)

8. **Post-procesiranje** za vsak sprite:
   - Odstrani morebiten tekst iz generacije
   - Crop v 256×256 s centered kompozicijo
   - Dodaj soft shadow (CSS-like drop shadow)
   - Optimiziraj PNG (pngcrush / optipng)

9. **Integracija**:
   - Shrani kot `assets/royal_systems/tier1/<Name>.png`
   - LFS avtomatsko prevzame (`.gitattributes` konfiguriran)
   - Commit, push
   - **Ni potrebno spreminjati kode** — `royal_icon_generator.lua` samodejno zazna PNG (v3.12.154 override sistem)

10. **Test v igri**:
    - Zaženi LÖVE
    - Odpri Ctrl+R (Royal Systems Panel)
    - Preveri da ikone pravilno prikazujejo
    - Preveri v Ctrl+Shift+G (Tech Tree) in Ctrl+K (Market Dashboard)

---

## ✅ Kriteriji za sprejem (Acceptance criteria)

Vsak sprite mora izpolnjevati:

- [ ] 256×256 pikslov PNG z alfa kanalom
- [ ] Top-down / 45° perspektiva
- [ ] Top-down osvetlitev (svetloba od zgoraj)
- [ ] Konsistenten stil z drugimi sprite-i v batch-u
- [ ] Brez besedila ali UI elementov v sliki
- [ ] Mehka senca pod predmetom
- [ ] Anti-aliased robovi
- [ ] File size < 200 KB
- [ ] Ime se ujema z `SystemBaseName` (npr. `Abacus.png` za `RoyalAbacusMakerSystem`)
- [ ] Pregledno ozadje (alpha = 0)

---

## 💰 Ocenjeni stroški

### AI-generacija (samostojno)

| Strošek | Cena | Opis |
|---------|------|------|
| Midjourney subscription | 30 USD/mesec | Generacija vseh 50 sprite-ev v 1 mesecu |
| Stable Diffusion XL (lokalno) | 0 EUR | Open source, ampak zahteva GPU z 8GB+ VRAM |
| DALL-E 3 API | ~$0.04/sprite | ~2 EUR za vseh 50 sprite-ev |
| **Skupaj** | **2-30 EUR** | |

### Komisioniran umetnik

| Strošek | Cena | Opis |
|---------|------|------|
| Povprečna ura umetnika | 15-50 EUR | Odvisno od izkušenj |
| Čas na sprite | 2 uri | Za tier-1 kvaliteto |
| 50 sprite-ev × 2 uri × 25 EUR | **2500 EUR** | Srednja cena |

### Hibridni pristop (priporočeno)

1. AI-generiraj vse 50 (2 EUR)
2. Najemnik čiščenje najslabših 10 (100 EUR)
3. **Skupaj: 102 EUR** za odlične rezultate

---

## 🎯 Naslednji koraki

1. **Takoj**: Preglej ASSET_PRIORITY_PLAN.md za popoln seznam prioritete
2. **Faza 1**: Poženi test batch (3 sprite-i) za validacijo stila
3. **Faza 2**: Generiraj Batch 1-4 (50 sprite-ev)
4. **Faza 3**: Post-procesiranje in commit
5. **Faza 4**: Integracijski test v igri

Po končani Fazi 1 (50 Tier 1 sprite-ev) nadaljuj z:
- Tier 2 (100 sprite-ev) — ista skripta z manjšo resolucijo (128×128)
- HD tileset za teren
- HD zgradbe sprite-i (zgradbe v svetu, ne UI ikone)

---

## 📚 Povezani dokumenti

- [ASSET_PRIORITY_PLAN.md](ASSET_PRIORITY_PLAN.md) — prioritete in faze
- [HD_ASSETS_GUIDE.md](HD_ASSETS_GUIDE.md) — splošne tehnične specifikacije
- [STEAM_STORE_PAGE.md](STEAM_STORE_PAGE.md) — Steam specifikacije
- [PRESS_KIT.md](PRESS_KIT.md) — marketing materiali
- [README.md](README.md) — glavna dokumentacija

---

**Generirano z**: ta dokument (ročno napisan na osnovi analize v `scripts/royal_priority.json`)
**Datum**: 2026-08-23
**Verzija**: v3.12.155
