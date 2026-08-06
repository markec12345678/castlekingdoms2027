# HD Assets Guide - Stronghold 2027

> Ta dokument opisuje specifikacije za HD grafične asset-e, ki jih potrebujemo za Stronghold 2027 release. Namenjen je grafičnim oblikovalcem, ki želijo prispevati k projektu.

Zadnja posodobitev: 2026-08-01
Trenutna verzija assetov: v0.6.1 (original Firefly Studios)
Ciljna verzija: v1.0.0 HD (4K)

---

## 📋 Pregled trenutnih assetov

| Kategorija | Trenutna velikost | Število datotek | Ciljna resolucija |
|-----------|------------------|-----------------|-------------------|
| Tiles (zgradbe, enote, teren) | 54 MB | 4 | 4K (3840×2160) |
| UI elementi | 7.5 MB | 100+ | 2K (2560×1440) |
| Logotipi, ozadja | 25 MB | 10 | 4K (3840×2160) |
| Projektili | 0.6 MB | 50+ | 2K |
| Fonti | 3 MB | 10 | Retina |
| Action bar animacije | 0.6 MB | 1 | 4K strip |

**Trenutne dimenzije tileset-a:** 2775×1962 pixels
**Ciljna dimenzija tileset-a:** 7680×4320 pixels (4× povečanje)

---

## 🎨 Specifikacije za HD assete

### 1. Tiles (glavni tileset)

**Datoteka:** `assets/tiles/stronghold_assets_packed_v13-hd.png`

**Zahteve:**
- Resolucija: 7680×4320 pixels (4× od originala)
- Format: PNG (lossless, 32-bit RGBA)
- Bit depth: 8-bit na kanal
- Color space: sRGB
- Transparentnost: Alpha kanal za sprites
- Naming: `stronghold_assets_packed_v13-hd.png` (HD oznaka)

**Vsebina tileset-a:**
- Vse zgradbe (71 različnih)
- Vse enote (42 različnih)
- Terenski tile-i (trava, kamen, voda, pesek, sneg)
- Okrasni elementi (drevesa, skale, grmovje)
- Effekti (ogenj, dim, eksplozije)

### 2. UI elementi

**Direktorij:** `assets/ui/`

**Zahteve:**
- Resolucija: 2K (2560×1440) za ikone
- Format: PNG z alpha kanalom
- Dizajn: Modern, minimalističen (ne retro pixel art)
- Barvna paleta: Topli srednjeveški toni (zemeljske barve)
- Fonti: Vektorski, podpora za vse jezike

**Kategorije UI elementov:**

#### 2.1 Icons (ikone)
- Surovine: wood, stone, gold, wheat, iron, flour, hops, ale, pitch
- Zgradbe: grad, vojašnica, katedrala, žitnica, itd.
- Enote: lokostrelec, vitez, kopjaš, itd.
- Akcije: build, demolish, upgrade, cancel

#### 2.2 Buttons
- Primary action button (zelena, pozitivna akcija)
- Secondary button (nevtralna)
- Danger button (rdeča, destruktivna)
- Disabled state
- Hover state
- Active/pressed state

#### 2.3 Panels in okna
- Main menu background
- Settings panel
- Build menu panel
- Resource bar
- Minimap frame

### 3. Logotipi in ozadja

**Datoteka:** `assets/other/`

**Zahteve:**
- Logo: 4K (3840×2160) PNG z alpha
- Ozadja: 4K JPG (manjša datoteka, full color)
- Slog: Cinematic, ep srednjeveški pridih

**Potrebni logotipi:**
- `stronghold2027_logo_main.png` (4K, glavni logo)
- `stronghold2027_logo_small.png` (1K, za favicon in UI)
- `stronghold2027_splash.png` (4K, loading screen)

**Potrebna ozadja:**
- `main_menu_bg.jpg` (4K, grad ob zalivu)
- `loading_bg.jpg` (4K, bitka pred gradom)
- `settings_bg.jpg` (2K, notranjost gradu)

### 4. Animacije

**Direktorij:** `assets/animations/` (nov direktorij)

**Zahteve:**
- Sprite sheet format (vertical strip)
- 60 FPS playback
- Loopable
- Format: PNG z alpha

**Potrebne animacije:**
- Ogenj (variations: majhen, srednji, velik)
- Dim (variations: tanek, debel)
- Eksplozija (kamen, les, smodnik)
- Hoja enot (8 smeri za vsako enoto)
- Napad enot (swing, shoot, thrust)
- Smrt enot (3 variations)
- Zastave v vetru (5 različnih)
- Vodni valovi (loopable)

### 5. Fonti

**Direktorij:** `assets/fonts/`

**Zahteve:**
- Format: TTF in OTF
- Podpora za: Latin, Cyrillic, Greek, CJK
- Teže: Light, Regular, Bold, Black
- Stil: Srednjeveški, vendar berljiv

**Potrebovali bomo:**
- Glavni font (UI): Noto Sans ali Inter
- Display font (naslovi): Cinzel ali IM Fell
- Monospace (številke): JetBrains Mono

---

## 🛠️ Tehnične specifikacije

### Datotečni formati

| Asset tip | Format | Racionala |
|-----------|--------|-----------|
| Sprites (zgradbe, enote) | PNG | Lossless, alpha kanal |
| Ozadja | JPG | Manjša datoteka, full color |
| Animacije | PNG sprite sheet | Lossless, alpha |
| Fonti | TTF/OTF | Berljivost, skalabilnost |
| 3D modeli (option) | glTF | Če gremo v 2.5D |

### Konvencije poimenovanja

```
asset_<kategorija>_<ime>_<stanje>.png
```

Primeri:
```
building_barracks_idle.png
building_barracks_construction.png
unit_archer_walk_north.png
unit_archer_attack_east.png
icon_resource_wood.png
button_primary_hover.png
```

### Color palette (priporočena)

**Primarne barve:**
- Grad/struktura: `#8B4513` (saddle brown)
- Narava/trava: `#7CFC00` (lawn green)
- Nebo: `#87CEEB` (sky blue)
- Zemlja: `#8B7355` (tan)
- Kamen: `#708090` (slate gray)

**Akcentne barve:**
- Zlato: `#FFD700`
- Kri: `#8B0000`
- Magija/efekti: `#9370DB`

---

## 📁 Struktura direktorijev

```
assets/
├── tiles/
│   ├── stronghold_assets_packed_v13-hd.png    # 4K tileset
│   ├── stronghold_assets_packed_v13-hd.json   # Koordinate sprite-ov
│   └── info_tiles_strip.png
├── ui/
│   ├── icons/
│   │   ├── resources/
│   │   ├── buildings/
│   │   ├── units/
│   │   └── actions/
│   ├── buttons/
│   ├── panels/
│   └── cursors/
├── other/
│   ├── stronghold2027_logo_main.png
│   ├── stronghold2027_logo_small.png
│   ├── stronghold2027_splash.png
│   ├── main_menu_bg.jpg
│   ├── loading_bg.jpg
│   └── settings_bg.jpg
├── animations/
│   ├── fire/
│   ├── smoke/
│   ├── explosions/
│   └── weather/
├── fonts/
│   ├── inter-regular.ttf
│   ├── inter-bold.ttf
│   ├── cinzel-regular.ttf
│   └── JetBrainsMono.ttf
└── projectiles/
    └── arrows/  # HD arrow variations
```

---

## 🎯 Prioritetni asseti za Fazo 4

### Tier 1 (najvišja prioriteta - teden 1-4)
1. **HD tileset** (4K) - zamenja 2775×1962 z 7680×4320
2. **Modern UI icons** - zamenja vse ikone surovin in zgradb
3. **Modern buttons** - redesign vseh gumbov
4. **Main menu background** - cinematic grad

### Tier 2 (srednja prioriteta - teden 5-8)
5. **Loading screen** - z animacijo
6. **Logotip** - Stronghold 2027 branding
7. **Vodne animacije** - valovi, reflek
8. **Ogenj in dim** - particle effects

### Tier 3 (nižja prioriteta - teden 9-12)
9. **Fonti** - zamenjava z modernimi
10. **Dodatne animacije** - zastave, eksplozije
11. **Cursors** - HD mišeljni kurzor
12. **Minimap icons** - HD ikone za minimap

---

## ✅ Kako prispevati assete

### Pred oddajo

1. **Preveri specifikacije** v tem dokumentu
2. **Uporabi reference** iz originalnega Stronghold-a (screenshoti)
3. **Testiraj v igri** - zaženi `love .` in preveri delovanje
4. **Optimiziraj** - stisni PNG z `optipng -o7` ali `pngcrush`

### Proces oddaje

```bash
# 1. Kloniraj repozitorij
git clone https://github.com/markec12345678/stronghold2027.git
cd stronghold2027
git checkout feat/hd-assets

# 2. Dodaj svoje assete
cp moj_hd_tileset.png assets/tiles/stronghold_assets_packed_v13-hd.png

# 3. Commit in push
git add assets/tiles/stronghold_assets_packed_v13-hd.png
git commit -m "assets: dodaj HD tileset (4K resolucija)

- Zamenja original 2775×1962 z 7680×4320
- Vsebuje vse 71 zgradb in 42 enot
- Moderniziran slog z dodatnimi detajli
- Testirano v LÖVE 11.5"

git push origin feat/hd-assets

# 4. Odpri Pull Request na GitHubu
```

### Kriteriji za sprejem

- ✅ Ustrezna resolucija (glej specifikacije)
- ✅ Pravilen format (PNG/JPG)
- ✅ Alfa kanal kjer potreben
- ✅ Konzistenten slog z obstoječimi asseti
- ✅ Optimizirana datotečna velikost (<10MB za tileset)
- ✅ Testirano v LÖVE 11.5

---

## 🔧 Orodja za grafične oblikovalce

### Priporočena programska oprema

- **GIMP** (free, open source) - https://gimp.org/
- **Krita** (free, open source) - https://krita.org/
- **Inkscape** (free, vektorski) - https://inkscape.org/
- **Aseprite** (paid, pixel art) - https://aseprite.org/
- **Adobe Photoshop** (paid, professional)

### Optimizacija PNG-jev

```bash
# Install optimizator
sudo apt install optipng pngcrush

# Optimiziraj eno datoteko
optipng -o7 moj_asset.png

# Optimiziraj vse PNG-jev v direktoriju
find assets/ -name "*.png" -exec optipng -o7 {} \;
```

### Generiranje sprite sheet koordinat

```bash
# Use TexturePacker or ShoeBox
# Ali uporabi python script:
python3 -c "
from PIL import Image
img = Image.open('moj_tileset.png')
print(f'Dimensions: {img.size}')
print(f'Mode: {img.mode}')
"
```

---

## 📞 Kontakt in podpora

- **GitHub Issues:** [github.com/markec12345678/stronghold2027/issues](https://github.com/markec12345678/stronghold2027/issues)
- **Asset review:** Pošlji PR z `assets:` prefix v commit message
- **Vprašanja:** Odpri issue z `question` label

---

## 📜 Licenca

Vsi prispevani asseti morajo biti licencirani pod:
- **Apache 2.0** (enako kot koda), ALI
- **CC BY 4.0** (Creative Commons)

Prispevatelj obdrži avtorske pravice, vendar dovoli uporabo v projektu.

---

Hvala za tvoj prispevek k Stronghold 2027! 🏰✨
