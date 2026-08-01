# Stronghold 2027 - Asset Migration Plan

> Načrt za zamenjavo Firefly Studios assetov z brezplačnimi CC0 alternativami.
> Cilj: popolna neodvisnost od Firefly IP za komercialni izid.

Zadnja posodobitev: 2026-08-01

---

## 🎯 Zakaj zamenjati?

| Trenutno (Firefly) | Po migraciji (CC0) |
|--------------------|--------------------|
| ⚠️ Odvisnost od Firefly goodwill | ✅ Popolna neodvisnost |
| ⚠️ Pisno dovoljenje lahko prekličejo | ✅ CC0 = public domain, ne morejo preklicati |
| ⚠️ "Stronghold" ime je zaščiteno | ✅ Lastno ime, lastni asseti |
| ⚠️ Težko iti na Steam z originalnim look | ✅ Lasten stil, Steam-ready |
| ✅ Dobra kvaliteta (original) | ✅ Kenney + LPC je solidna kvaliteta |

---

## 📦 Priporočeni viri

### 1. Kenney.nl (PRIPOROČENO - glavni vir)

**Licenca:** CC0 (public domain) - BREZ atribucije, BREZ omejitev

| Paket | Kaj vsebuje | Število | URL |
|-------|------------|---------|-----|
| **Medieval RTS** | Izometrične zgradbe, enote, tiles | 120+ | https://kenney.nl/assets/medieval-rts |
| **Tiny Battle** | Pixel art enote, zgradbe, teren | 190+ | https://kenney.nl/assets/tiny-battle |
| **Castle Kit** | 3D modeli (zidovi, stolpi, siege) | 75 | https://kenney.nl/assets/castle-kit |
| **Retro Fantasy Kit** | Pixel art RPG tileset | 100+ | https://kenney.nl/assets/retro-fantasy-kit |
| **Tower Defense Kit** | Top-down zgradbe in enote | 200+ | https://kenney.nl/assets/tower-defense-kit |

**Skupno:** ~685+ assetov, vsi CC0, vsi komercialno brezplačni

**Prednosti:**
- Vsi CC0 - nobene pravne skrbi
- Konsistenten umetniški stil
- Specifično za RTS igre
- Brez atribucije (ne rabiš credit)
- Lahko spreminjaš in redistribuira

**Slabosti:**
- Manj realistični kot Firefly (bolj "indie" stil)
- Manj detajlov na zgradbah
- Treba adaptirati kodo za nove sprite dimenzije

### 2. OpenGameArt LPC (dopolnilni vir)

**Licenca:** CC-BY-SA 3.0 + GPLv3 (atribucija potrebna, komercialno OK)

| Kaj | Število | URL |
|-----|---------|-----|
| LPC Base Assets (tiles + characters) | 500+ | https://opengameart.org/content/liberated-pixel-cup-lpc-base-assets-sprites-map-tiles |
| LPC Medieval characters | 100+ | https://opengameart.org/content/lpc-medieval-fantasy-character-sprites |
| LPC Collection | 1000+ | https://opengameart.org/content/lpc-collection |
| LPC Art Collection + Others | 2000+ | https://opengameart.org/content/lpc-art-collection-others |

**Prednosti:**
- Ogromna količina assetov (5000+)
- Aktivna skupnost ki še dodaja
- Modularni character sprites (lahko zamenjaš orožje, oklep)
- 32x32 tile format (standarden)

**Slabosti:**
- CC-BY-SA = moraš navesti avtorje
- 32x32 pixel art (manjša od Kenney)
- 4 smeri (ne 8 kot naš sistem)

### 3. OpenGameArt CC0 Isometric (terrain tiles)

**Licenca:** CC0

| Kaj | Število | URL |
|-----|---------|-----|
| CC0 Isometric Floor Tiles | 1,049 | https://huggingface.co/datasets/nyuuzyou/OpenGameArt-CC0 |
| Medieval Building Tiles | 60 | https://opengameart.org/content/medieval-building-tiles |
| Medieval Stone Guard Tower | 1 | https://opengameart.org/content/medieval-stone-guard-tower-isometric-25d |

---

## 🗺️ Načrt migracije

### Faza 1: Terrain (1 teden)
- Prenesi Kenney "Medieval RTS" tiles
- Zamenjaj terrain tileset (trava, kamen, voda)
- Adaptiraj `terrain.lua` za nove tile dimenzije
- Testiraj renderiranje

### Faza 2: Buildings (2 tedna)
- Prenesi Kenney "Medieval RTS" structures
- Mapiraj vsako zgradbo na Kenney ekvivalent:
  - Woodcutter -> Kenney "Lumber Mill"
  - Quarry -> Kenney "Stone Quarry"
  - Barracks -> Kenney "Barracks"
  - Market -> Kenney "Market"
  - itd.
- Posodobi `object_quads.lua` z novimi koordinatami
- Testiraj gradnjo

### Faza 3: Units (2 tedna)
- Prenesi Kenney "Tiny Battle" units
- Mapiraj vsako enoto:
  - Archer -> Kenney "Archer"
  - Knight -> Kenney "Knight"
  - Swordsman -> Kenney "Swordsman"
  - itd.
- Posodobi `object_quads.lua` z novimi unit koordinatami
- Testiraj combat

### Faza 4: UI Elements (1 teden)
- Prenesi Kenney UI pack
- Zamenjaj ikone surovin
- Zamenjaj gumbe in panele
- Posodobi `assets/ui/` direktorij

### Faza 5: Terrain decorations (3 dni)
- Prenesi Kenney "Nature Kit" za drevesa, skale
- Zamenjaj drevesa in okrasne elemente
- Testiraj vizualni izgled

### Faza 6: Polish in testiranje (1 teden)
- Preveri vseh 10 misij z novimi asseti
- Testiraj AI z novimi enotami
- Posneti screenshoti za Steam
- Posneti trailer z novim look

**Skupni čas:** ~6 tednov (z 1 osebo)

---

## 📊 Primerjava kvalitete

| Kategorija | Firefly (trenutno) | Kenney CC0 | Razlika |
|-----------|-------------------|------------|---------|
| Zgradbe | Realistični, bogati detajli | Stylized, clean pixel art | Manj detajlov, a čist |
| Enota | 8 smeri, 8 animacij | 4-8 smeri, omejene animacije | Manj animacij |
| Terrain | 64x64 tiles, bogat | 32-64px tiles, simplificiran | Enostavnejši |
| UI | Profesionalni, polni | Minimalistični, clean | Drugačen stil |
| Skupni občutek | "AAA klasik" | "Indie hit" | Drugačen vibe |

### Ali je Kenney dovolj dober?

**DA, za naslednje razloge:**
1. Kenney asseti so uporabljeni v **tisočerih komercialnih igrah**
2. Stil je "indie chic" - priljubljen na Steam
3. CC0 = brez pravnih skrbi
4. Konzistenten stil = profesionalen izgled
5. Lahko dopolniš z lastnimi dodatki

**NE, če:**
- Želiš fotorealistično grafiko
- Želiš 100+ animacij per enota
- Želiš "Stronghold" look

---

## 💰 Stroški

| Opcija | Strošek | Čas |
|--------|---------|-----|
| Kenney CC0 (priporočeno) | **€0** | 6 tednov |
| LPC CC-BY-SA + Kenney | **€0** | 8 tednov |
| Lastni asseti ( commissioned) | **€2000-5000** | 3-6 mesecev |
| Kupljeni asseti (Unity Store) | **€200-1000** | 2 tedna |
| Firefly (trenutno) | **€0** (+ pravno tveganje) | 0 |

---

## ✅ Priporočilo

**1. IZBIRA: Kenney CC0 + dopolnitve iz OpenGameArt**

Prednosti:
- Brezplačno
- CC0 = brez pravnih skrbi
- ~685+ assetov pripravljenih za uporabo
- Konsistenten stil
- Komercialno brez omejitev

Naslednji koraki:
1. Prenesi Kenney "Medieval RTS" pack
2. Prenesi Kenney "Tiny Battle" pack
3. Prenesi Kenney "Castle Kit"
4. Začni z Fazo 1 (Terrain)
5. Po vsaki fazi testiraj z .love paketom

---

## 🔗 Linki za prenos

- Kenney Medieval RTS: https://kenney.nl/assets/medieval-rts
- Kenney Tiny Battle: https://kenney.nl/assets/tiny-battle
- Kenney Castle Kit: https://kenney.nl/assets/castle-kit
- Kenney vse: https://kenney.nl/assets
- OpenGameArt LPC: https://opengameart.org/content/liberated-pixel-cup-lpc-base-assets-sprites-map-tiles
- itch.io CC0 Medieval: https://itch.io/game-assets/assets-cc0/tag-medieval
