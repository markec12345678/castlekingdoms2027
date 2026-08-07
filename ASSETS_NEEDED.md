# Castle Kingdoms 2027 - Assets Needed

> Konkreten seznam vseh grafičnih in zvočnih assetov, ki jih projekt potrebuje.
> Namizni oblikovaleci lahko izberejo kategorijo in prispevajo.
>
> **Status legenda:**
> - ✅ Already exists (no action needed)
> - ⚠️ Exists but needs HD upgrade
> - ❌ Missing (must be created)

Zadnja posodobitev: 2026-08-01

---

## 🎨 Grafični Asseti

### 1. Tileset (najvišja prioriteta)

| Asset | Trenutno | Cilj | Status | Spec |
|-------|----------|------|--------|------|
| Main tileset (zgradbe, enote) | 2775×1962 | 7680×4320 (4K) | ⚠️ | PNG z alpha |
| Terrain tiles (trava, kamen, voda) | 64×64 | 256×256 | ⚠️ | PNG seamless |
| Cliff/rock tiles | 64×64 | 256×256 | ⚠️ | PNG z alpha |
| Water animation frames | 4 frames | 8 frames | ⚠️ | PNG strip |

**Specifikacije:**
- Format: PNG (lossless, 32-bit RGBA)
- Color space: sRGB
- Naming: `stronghold_assets_packed_v13-hd.png`

---

### 2. Building Sprites

Vsaka zgradba potrebuje naslednje frame-e:

| Enota | Idle | Construction | Damaged | Destroyed | Status |
|-------|------|--------------|---------|-----------|--------|
| Saxon Hall | 1 | 3 | 1 | 1 | ⚠️ |
| Wooden Keep | 1 | 3 | 1 | 1 | ⚠️ |
| Stone Keep | 1 | 3 | 1 | 1 | ⚠️ |
| Fortress | 1 | 3 | 1 | 1 | ⚠️ |
| Castle Kingdoms | 1 | 3 | 1 | 1 | ⚠️ |
| Stockpile | 1 | 3 | 1 | 1 | ⚠️ |
| Granary | 1 | 3 | 1 | 1 | ⚠️ |
| Barracks | 1 | 3 | 1 | 1 | ⚠️ |
| Stone Barracks | 1 | 3 | 1 | 1 | ⚠️ |
| Engineers Guild | 1 | 3 | 1 | 1 | ⚠️ |
| Tunnelers Guild | 1 | 3 | 1 | 1 | ⚠️ |
| Chapel | 1 | 3 | 1 | 1 | ⚠️ |
| Church | 1 | 3 | 1 | 1 | ⚠️ |
| Cathedral | 1 | 3 | 1 | 1 | ⚠️ |
| Apothecary | 1 | 3 | 1 | 1 | ⚠️ |
| Woodcutter Hut | 1 | 3 | 1 | 1 | ⚠️ |
| Iron Mine | 1 | 3 | 1 | 1 | ⚠️ |
| Market | 1 | 3 | 1 | 1 | ⚠️ |
| Quarry | 1 | 3 | 1 | 1 | ⚠️ |
| Fletcher Workshop | 1 | 3 | 1 | 1 | ⚠️ |
| Poleturner Workshop | 1 | 3 | 1 | 1 | ⚠️ |
| Blacksmith Workshop | 1 | 3 | 1 | 1 | ⚠️ |
| Armorer | 1 | 3 | 1 | 1 | ⚠️ |
| Windmill | 1 | 3 | 1 | 1 | ⚠️ |
| Bakery | 1 | 3 | 1 | 1 | ⚠️ |
| Brewery | 1 | 3 | 1 | 1 | ⚠️ |
| Inn | 1 | 3 | 1 | 1 | ⚠️ |
| Pitch Rig | 1 | 3 | 1 | 1 | ⚠️ |
| Orchard | 1 | 2 | 1 | 1 | ⚠️ |
| Wheat Farm | 1 | 2 | 1 | 1 | ⚠️ |
| Dairy Farm | 1 | 2 | 1 | 1 | ⚠️ |
| Hops Farm | 1 | 2 | 1 | 1 | ⚠️ |
| Hunter's Hut | 1 | 3 | 1 | 1 | ⚠️ |
| All defensive towers (5 types) | 1 each | 3 each | 1 each | 1 each | ⚠️ |
| All gates (8 types) | 1 each | 3 each | 1 each | 1 each | ⚠️ |
| All walls (3 types) | 1 each | 2 each | 1 each | 1 each | ⚠️ |
| All houses (4 types) | 1 each | 3 each | 1 each | 1 each | ⚠️ |
| All gardens (3 types) | 1 each | - | - | - | ⚠️ |
| All ponds (2 types) | 1 each | - | - | - | ⚠️ |
| Stable | 1 | 3 | 1 | 1 | ⚠️ |

**Skupaj: ~71 zgradb × 6 frame-ov = ~426 sprites**

---

### 3. Unit Sprites (z animacijami)

Vsaka enota potrebuje **8 smeri × 8 state-ov × 8 frame-ov = 512 frame-ov na enoto**

| Enota | Idle | Walk | Run | Attack | Death | Hit | Build | Repair | Status |
|-------|------|------|-----|--------|-------|-----|-------|--------|--------|
| Archer | 8×4 | 8×8 | 8×6 | 8×6 | 8×8 | 8×2 | - | - | ⚠️ (samo walk) |
| Crossbowman | 8×4 | 8×8 | 8×6 | 8×6 | 8×8 | 8×2 | - | - | ⚠️ |
| Spearman | 8×4 | 8×8 | 8×6 | 8×6 | 8×8 | 8×2 | - | - | ⚠️ |
| Pikeman | 8×4 | 8×8 | 8×6 | 8×6 | 8×8 | 8×2 | - | - | ⚠️ |
| Maceman | 8×4 | 8×8 | 8×6 | 8×6 | 8×8 | 8×2 | - | - | ⚠️ |
| Swordsman | 8×4 | 8×8 | 8×6 | 8×6 | 8×8 | 8×2 | - | - | ⚠️ |
| Knight | 8×4 | 8×8 | 8×6 | 8×6 | 8×8 | 8×2 | - | - | ⚠️ |
| Lord | 8×4 | 8×8 | 8×6 | 8×6 | 8×8 | 8×2 | - | - | ⚠️ |
| Peasant (worker) | 8×2 | 8×6 | - | - | 8×4 | 8×2 | 8×6 | 8×6 | ⚠️ |
| Woodcutter | 8×2 | 8×6 | - | - | 8×4 | 8×2 | 8×6 | - | ⚠️ |
| Stone mason | 8×2 | 8×6 | - | - | 8×4 | 8×2 | 8×6 | - | ⚠️ |
| Iron miner | 8×2 | 8×6 | - | - | 8×4 | 8×2 | 8×6 | - | ⚠️ |
| Baker | 8×2 | 8×6 | - | - | 8×4 | 8×2 | 8×6 | - | ⚠️ |
| Brewer | 8×2 | 8×6 | - | - | 8×4 | 8×2 | 8×6 | - | ⚠️ |
| Fletcher | 8×2 | 8×6 | - | - | 8×4 | 8×2 | 8×6 | - | ⚠️ |
| Poleturner | 8×2 | 8×6 | - | - | 8×4 | 8×2 | 8×6 | - | ⚠️ |
| Blacksmith | 8×2 | 8×6 | - | - | 8×4 | 8×2 | 8×6 | - | ⚠️ |
| Armorer | 8×2 | 8×6 | - | - | 8×4 | 8×2 | 8×6 | - | ⚠️ |
| Miller | 8×2 | 8×6 | - | - | 8×4 | 8×2 | 8×6 | - | ⚠️ |
| Innkeeper | 8×2 | 8×6 | - | - | 8×4 | 8×2 | 8×6 | - | ⚠️ |
| Priest | 8×2 | 8×6 | - | - | 8×4 | 8×2 | - | - | ⚠️ |
| Engineer | 8×2 | 8×6 | - | - | 8×4 | 8×2 | - | 8×6 | ⚠️ |
| Tunneler | 8×2 | 8×6 | - | - | 8×4 | 8×2 | - | 8×6 | ⚠️ |
| Deer (animal) | 4×2 | 4×4 | - | - | 4×4 | - | - | - | ⚠️ |
| Bear (animal) | 4×2 | 4×4 | - | 4×4 | 4×4 | - | - | - | ⚠️ |
| Rabbit | 4×2 | 4×4 | - | - | 4×4 | - | - | - | ⚠️ |
| Cow | 4×2 | 4×4 | - | - | 4×4 | - | - | - | ⚠️ |
| Chicken | 4×2 | 4×4 | - | - | 4×4 | - | - | - | ⚠️ |
| Horse | 4×2 | 4×4 | 4×4 | - | 4×4 | - | - | - | ⚠️ |

**Skupaj: ~30 enot × ~200 frame-ov = ~6000 sprites**

---

### 4. UI Elementi

| Asset | Trenutno | Cilj | Status |
|-------|----------|------|--------|
| Resource icons (9 surovin) | 32×32 | 128×128 | ⚠️ |
| Building icons (71 zgradb) | 32×32 | 128×128 | ⚠️ |
| Unit icons (30 enot) | 32×32 | 128×128 | ⚠️ |
| Action icons (build, demolish, upgrade) | 32×32 | 128×128 | ⚠️ |
| Button - primary (4 states) | 64×32 | 128×64 | ⚠️ |
| Button - secondary (4 states) | 64×32 | 128×64 | ⚠️ |
| Button - danger (4 states) | 64×32 | 128×64 | ⚠️ |
| Panel background | tiled | 1920×1080 | ⚠️ |
| Minimap frame | 256×256 | 512×512 | ⚠️ |
| Tooltip background | tiled | 512×256 | ⚠️ |
| Cursor (default, hover, click) | 16×16 | 32×32 | ⚠️ |
| Loading screen background | - | 3840×2160 | ❌ |
| Main menu background | - | 3840×2160 | ❌ |
| Settings panel background | - | 1920×1080 | ❌ |

---

### 5. Logos & Branding

| Asset | Format | Velikost | Status |
|-------|--------|----------|--------|
| Castle Kingdoms 2027 - main logo | PNG z alpha | 3840×2160 | ❌ |
| Castle Kingdoms 2027 - small logo | PNG z alpha | 1024×256 | ❌ |
| Castle Kingdoms 2027 - splash screen | PNG | 3840×2160 | ❌ |
| Castle Kingdoms 2027 - favicon | ICO/PNG | 32×32, 64×64, 128×128 | ❌ |
| Steam capsule (main) | PNG | 616×353 | ❌ |
| Steam capsule (small) | PNG | 231×87 | ❌ |
| Steam library capsule | PNG | 248×352 | ❌ |
| Steam page background | PNG | 1438×810 | ❌ |

---

### 6. Effect Sprites

| Asset | Frame-i | Velikost | Status |
|-------|---------|----------|--------|
| Fire (small) | 8 | 64×64 | ⚠️ |
| Fire (medium) | 8 | 128×128 | ⚠️ |
| Fire (large) | 8 | 256×256 | ⚠️ |
| Smoke (variations) | 8 each | 64×64 | ⚠️ |
| Explosion (stone) | 12 | 256×256 | ❌ |
| Explosion (wood) | 12 | 256×256 | ❌ |
| Explosion (gunpowder) | 16 | 512×512 | ❌ |
| Blood splatter | 4 | 64×64 | ❌ |
| Dust cloud | 6 | 64×64 | ⚠️ |
| Spark | 4 | 32×32 | ❌ |
| Lightning bolt | 6 | 256×1024 | ❌ |

---

### 7. Weather Particles

| Asset | Opis | Status |
|-------|------|--------|
| Rain drop (vertical) | 1×16 px, alpha gradient | ✅ (programsko) |
| Rain drop (wind angle) | 1×16 px, rotated | ✅ (programsko) |
| Snow flake | 4×4 px, soft circle | ✅ (programsko) |
| Fog overlay | tiled texture | ⚠️ |
| Lightning flash overlay | full screen white | ✅ (programsko) |

---

## 🔊 Zvočni Asseti

### 1. Ambient Sounds (looping)

| Asset | Trajanje | Format | Status |
|-------|----------|--------|--------|
| Wind loop (gentle) | 30s | OGG | ❌ |
| Wind loop (strong) | 30s | OGG | ❌ |
| Birds (forest) | 60s | OGG | ❌ |
| Birds (city) | 60s | OGG | ❌ |
| Fire crackling | 15s | OGG | ❌ |
| Rain (light) | 60s | OGG | ❌ |
| Rain (heavy) | 60s | OGG | ❌ |
| Thunder | 5s | OGG | ❌ |
| Crowd (market) | 30s | OGG | ❌ |
| Crowd (tavern) | 30s | OGG | ❌ |
| Stream/river | 30s | OGG | ❌ |
| Ocean waves | 60s | OGG | ❌ |

### 2. Combat SFX

| Asset | Trenutno | Status | Opomba |
|-------|----------|--------|--------|
| Arrow shoot | ✅ | ✓ | 2 variations |
| Arrow hit (flesh) | ✅ | ✓ | 4 variations |
| Arrow hit (stone) | ✅ | ✓ | 3 variations |
| Sword swing | ❌ | Missing | Need 3 variations |
| Sword hit (armor) | ✅ | ✓ | 5 variations |
| Sword hit (flesh) | ❌ | Missing | Need 3 variations |
| Spear thrust | ❌ | Missing | Need 2 variations |
| Mace hit | ❌ | Missing | Need 2 variations |
| Shield block | ✅ | ✓ | 1 (need more) |
| Death cry (male) | ✅ | ✓ | 8 variations |
| Death cry (female) | ❌ | Missing | Need 4 variations |
| Horse neigh | ❌ | Missing | Need 3 variations |
| Horse gallop | ❌ | Missing | Need 2 variations |
| Catapult fire | ❌ | Missing | Need 2 variations |
| Catapult impact | ❌ | Missing | Need 3 variations |
| Trebuchet fire | ❌ | Missing | Need 2 variations |

### 3. UI Sounds

| Asset | Trenutno | Status | Opomba |
|-------|----------|--------|--------|
| Button click | ✅ | ✓ | 1 variation |
| Button hover | ✅ | ✓ | 1 variation |
| Notification (info) | ❌ | Missing | |
| Notification (success) | ❌ | Missing | |
| Notification (warning) | ❌ | Missing | |
| Notification (error) | ❌ | Missing | |
| Building placed | ✅ | ✓ | 1 variation |
| Building destroyed | ❌ | Missing | |
| Unit recruited | ❌ | Missing | |
| Resource collected | ❌ | Missing | |

### 4. Music

| Asset | Trajanje | Status | Opomba |
|-------|----------|--------|--------|
| Main menu theme | 3-5 min | ⚠️ | Exists (need HD version) |
| Explore (peaceful) | 5-10 min | ❌ | Need 3-5 tracks |
| Combat (intense) | 3-5 min | ❌ | Need 2-3 tracks |
| Victory fanfare | 30s | ❌ | |
| Defeat theme | 1-2 min | ❌ | |

---

## 📁 File Naming Conventions

### Buildings
```
assets/buildings/{building_name}/
  idle.png
  construction_1.png
  construction_2.png
  construction_3.png
  damaged.png
  destroyed.png
```

### Units
```
assets/units/{unit_name}/
  idle_north.png
  idle_northeast.png
  idle_east.png
  ...
  walk_north_1.png
  walk_north_2.png
  ...
  attack_north_1.png
  attack_north_2.png
  ...
  death_north_1.png
  death_north_2.png
  ...
```

### UI
```
assets/ui/
  icons/
    resources/
      wood.png
      stone.png
      ...
    buildings/
      barracks.png
      ...
  buttons/
    primary_normal.png
    primary_hover.png
    primary_pressed.png
    primary_disabled.png
```

---

## 📊 Skupne zahteve

| Kategorija | Število asset-ov | Predviden čas |
|-----------|------------------|---------------|
| Tileset (HD) | 1 datoteka | 40 ur |
| Building sprites | ~426 | 100 ur |
| Unit sprites z animacijami | ~6000 | 500 ur |
| UI elementi | ~100 | 50 ur |
| Logos & branding | ~8 | 20 ur |
| Effect sprites | ~80 | 30 ur |
| Ambient sounds | ~12 | 10 ur |
| Combat SFX | ~30 | 15 ur |
| UI sounds | ~10 | 5 ur |
| Music | ~10 tracks | 100 ur |
| **SKUPNO** | **~6800 asset-ov** | **~870 ur** |

---

## 🎯 Prioritetni vrstni red za grafičnega oblikovalca

### Tier 1 (prvi teden, ~80 ur)
1. **Main tileset HD** - zamenja 2775×1962 z 7680×4320 (40 ur)
2. **UI ikone** - resource icons + building icons (20 ur)
3. **Loading screen** - cinematic grad ob zalivu (10 ur)
4. **Logotip** - Castle Kingdoms 2027 branding (10 ur)

### Tier 2 (drugi teden, ~120 ur)
5. **Attack animacije** za 8 vojaških enot (60 ur)
6. **Death animacije** za 8 vojaških enot (40 ur)
7. **Hit reaction** za 8 vojaških enot (20 ur)

### Tier 3 (tretji teden, ~100 ur)
8. **Idle animacije** za workerje (40 ur)
9. **Build animacije** za workerje (30 ur)
10. **Fire effect** - 3 velikosti z animacijo (15 ur)
11. **Smoke effect** - 3 variations (15 ur)

### Tier 4 (čakajoči)
- Music composition (100 ur)
- Voice acting (po potrebi)
- Additional language translations (sodelovanje s Crowdin)

---

## 📞 Kako prispevati

1. Poberi enega od zgoraj naštetih asset-ov
2. Ustvari skladno s specifikacijami (velikost, format, imenovanje)
3. Testiraj z LÖVE (pošlji .love paket za preizkus)
4. Pošlji Pull Request na `feat/hd-assets` vejo

**Kontakti:**
- GitHub Issues za vprašanja
- Pull Requests za oddajo asset-ov

---

## 💡 Smernice za umetnike

### Slog
- **Cilj:** Medieval realistic, vendar stiliziran (ne photorealistic)
- **Reference:** Age of Empires IV, Castle Kingdoms Definitive Edition, Manor Lords
- **Barvna paleta:** Tople zemeljske barve, bogate teksture

### Tehnične zahteve
- **PNG z alpha** za sprites
- **JPG** za ozadja (manjša datoteka)
- **OGG** za zvok (kompresija brez izgube za ambiente)
- **Optimizacija** z `optipng -o7` za PNG-je

### Konsistentnost
- Enaka osvetlitev na vseh asset-ih (sunčna svetloba od zgoraj desno)
- Enak nivo detajla (ne mešaj 32×32 z 256×256 v isti kategoriji)
- Enaki barvni toni za podobne objekte (npr. vse zgradbe iz kamna imajo enak kamen tone)

---

Hvala za tvoj prispevek k Castle Kingdoms 2027! 🏰🎨
