# Stronghold 2027

Modernizirana različica igre Stronghold (2001) za leto 2027, zgrajena na LÖVE 11.5 (Lua/LuaJIT).

[![Version](https://img.shields.io/badge/version-2.3.1-blue.svg)](https://github.com/markec12345678/stronghold2027/releases)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](LICENSE)
[![LÖVE](https://img.shields.io/badge/LÖVE-11.5-orange.svg)](https://love2d.org)
[![Syntax](https://img.shields.io/badge/syntax-569%2F572%20pass-brightgreen.svg)](#)
[![Bugs](https://img.shields.io/badge/bugs%20fixed-55-brightgreen.svg)](#)
[![Audit](https://img.shields.io/badge/audit%20rounds-14-blue.svg)](#)

## Prenosi

- **Zadnja izdaja**: [v2.3.1](https://github.com/markec12345678/stronghold2027/releases)
- **.love datoteka**: `stronghold2027-v2.3.1.love` (305 MB)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md) — 14 krogov pregleda, 55 popravkov

## Zagon

```cmd
& "C:\Program Files\LOVE\love.exe" "F:\pot\do\stronghold2027-v2.0.7.love"
```

Ali iz git checkout-a (zahteva [git-lfs](https://git-lfs.com/)):
```cmd
git clone https://github.com/markec12345678/stronghold2027.git
cd stronghold2027
git lfs install
git lfs pull
love .
```

## Statistika projekta

| Metrika | Vrednost |
|---------|----------|
| Lua datoteke | 572 |
| Vrstic kode | ~287.000 |
| GLSL shaderji | 12 |
| Jezikov | 32 |
| Verzij | 38 (v1.7.9 → v2.3.1) |
| Bug popravkov | 55 (14 krogov pregleda) |
| Syntax pass rate | 569/572 (99,5%) |
| PNG assetov | 1.206 |
| Registriranih globalov | 64 |

## Funkcije

### 🎮 Jedro igre
- **10 misij kampanje** s story cutscene-i v slovenščini
- **10 skirmish misij** s progresivno težavnostjo (Skirmish Trail)
- **5 co-op misij** za 2 igralca
- **Freebuild način** za sproščeno igranje
- **4 AI osebnosti** (aggressive, balanced, defensive, economic) × 6 težavnosti
- **Dynamic economy** — supply/demand, inflacija, sezonski modifikatorji
- **Combat system** — projektili, oklep, damage variance, game feel
- **5 bojnih formacij** (line, column, wedge, scatter, box) z bonusi
- **5 stopenj veterancy** (Novinec → Legendarni) z stat bonusi
- **4 oblegovalna orožja** (catapult, trebuchet, siege tower, battering ram)
- **6 vremenskih tipov** ki vplivajo na gameplay (farme, hitrost, vidljivost)
- **Fog of War** s 3 stanji (hidden, explored, visible)
- **5 festivalov** (turnir, gostija, plesi, sejem, verski praznik)
- **4 velikosti map** (Small 128 → Huge 768)
- **Dynamic unit cap** glede na FPS
- **Auto worker assignment** s prioriteto
- **Building upgrade tree** (5 poti, 2-4 tier-i)

### 🌐 Multiplayer
- **TCP/IP socket networking** (do 8 igralcev)
- **Lobby UI** — host/join, seznam igralcev, ready status
- **In-game chat** (Enter za odprtje)
- **Diplomacy** — 6 stanj (neutral, allied, war, truce, proposed_alliance, proposed_peace)
- **Trade system** — predlogi, darila, trade routes
- **Spectator mode** — opazovanje iger (TAB za preklop igralca)
- **Co-op campaign** — 2 igralca skupaj
- **Custom map sharing** — deljenje map med igralci
- **F9** — diplomacy & trade panel

### 🎨 HD Grafika
- **Normal mapping** za teren (Sobel filter iz heightmap)
- **Dynamic point lights** (do 32 luči — bakle, ogenj, zgradbe)
- **SSAO** (Screen-Space Ambient Occlusion)
- **ACES filmic tone mapping** + gamma korekcija
- **Bloom, color grading, vignette** shaderji
- **Day/night cycle** z dinamično osvetlitvijo
- **Weather system** (dež, sneg, megla, nevihta)
- **Particle effects** (7 tipov: spark, smoke, blood, dust, gold, fire, magic)
- **Construction animations** (progress bar, delci, proslava)
- **Visual polish** (UI animacije, hit/build/death efekti)

### 🔊 Zvok
- **Dynamic music** — 5 stanj (menu, peace, combat, victory, defeat)
- **SFX library** — 4 kategorije (combat, building, UI, environment)
- **3D positional audio** (glasnost glede na razdaljo)
- **Slovenian voice-over** — 30+ notifikacij v slovenščini
- **5 kategorij glasnosti** (master, sfx, music, speech, ambient)
- **AI personality dialogue** — 30+ unikatnih dialogov v slovenščini

### 🌍 Lokalizacija
- **32 jezikov** (slovenščina, angleščina, srbščina, grščina, bolgarščina, ...)
- **RTL podpora** (arabščina, hebrejščina)
- **Font detection** (cyrillic, greek, cjk, arabic)
- **Runtime preklop jezika**

### ♿ Dostopnost
- **Colorblind mode-i** (protanopia, deuteranopia, tritanopia)
- **Font scaling** (small, medium, large, extra large)
- **Reduced motion** (izklop screen shake)
- **High contrast mode**
- **Subtitles for speech**
- **Gamepad support** (polna podpora krmilnika z virtualnim kazalcem)
- **Auto-pause na focus loss**

### 🛠️ Orodja
- **Map Editor** (F4) — terrain painting, objects, save/load
- **Replay System** (Ctrl+R) — snemanje/predvajanje
- **Statistics Dashboard** (Ctrl+S) — session + lifetime statistike
- **Debug Console** (Tilde ~) — 12 ukazov
- **Crash Handler** (F11) — auto-disable failing systems
- **Performance Watchdog** — auto quality adjustment
- **Performance Benchmark** (Ctrl+P) — 6 avtomatiziranih testov
- **Release Checklist** (Ctrl+L) — 45 pre-release preverjanj
- **Integration Tests** (Ctrl+I) — 25 testov
- **Screenshot Manager** (Ctrl+M ali F12) — avtomatsko zajemanje
- **Object Pooling** — performance optimizacija
- **Pathfinding Optimizer** — JPS + caching
- **Auto-save** z crash recovery (vsakih 5 minut)
- **Save compatibility** z migration system

### 🔌 Modding
- **Mod loader** — scan /mods, load manifest.lua
- **Custom buildings, units, maps, scripts**
- **Hot-reload** za development
- **Steam Workshop integration** (subscribe/upload)
- **Sample mod** vključen (GoldMine building)

### 🏆 Steam Integration
- **10 achievements** (first_victory, campaign_complete, master_builder, ...)
- **Stats tracking** (buildings, kills, trades, alliances)
- **Leaderboard** (stub)
- **Steam Workshop** (subscribe/upload/import)

### 📚 Vadba & UX
- **10-korak interaktivni tutorial** v slovenščini (Ctrl+T)
- **40+ loading tips** v 8 kategorijah
- **Credits screen** (Ctrl+E)
- **End game screen** s statistiko
- **Loading tips** med nalaganjem
- **Keybind help** (F1) — prikaz vseh bližnjic v igri
- **Performance overlay** (F3) — FPS, memory, frame time

### 🎯 QoL izboljšave
- **Rally points** za barake (desni klik)
- **Right-click dismiss** za vse panele
- **Building queue** (shift+klik, max 10)
- **Minimap drag scroll** (klik in vlečenje)
- **Auto worker assignment** s prioriteto (Ctrl+Shift+W toggle)
- **Dynamic unit cap** glede na FPS
- **Building hotkeys** (Ctrl+1-9)
- **Game speed control** (Space, 1-4)
- **Unit command queue** (shift+klik za več ukazov)
- **Minimap** s terenom, zgradbami, kamero
- **Resource flow visualizer** (Ctrl+Y)
- **Auto-save indicator**

### 🧠 AI
- **4 osebnosti** z edinstvenimi dialogi
- **6 težavnosti** (Story → Nightmare)
- **Threat assessment** — AI se prilagaja moči igralca
- **AI personality dialogue** — 30+ dialogov v slovenščini
- **Smart building placement**
- **Defense response**
- **Difficulty adaptation**

## Tipke

Glej [KEYBINDS.md](KEYBINDS.md) za celovit seznam 50+ tipkovnih bližnjic (0 konfliktov po 14 krogih pregleda).

## Arhitektura

Glej [SYSTEMS.md](SYSTEMS.md) za popoln seznam vseh 130+ modulov.

## Razvoj

Glej [CONTRIBUTING.md](CONTRIBUTING.md) za vodič za razvijalce.

## Zgodovina razvoja

Glej [CHANGELOG.md](CHANGELOG.md) za vse verzije od v1.7.9 do v2.3.1 (38 verzij, 14 krogov pregleda, 55 popravkov).

## Licenca

Apache License 2.0 — glej [LICENSE](LICENSE)

## Avtorji

- **markec12345678** — razvoj
- **Stone Kingdoms** — osnovni codebase (Apache 2.0)
- **Kenney.nl** — CC0 asseti
- **Firefly Studios** — original Stronghold (2001)

## Povezave

- [GitHub](https://github.com/markec12345678/stronghold2027)
- [LÖVE](https://love2d.org)
- [Stone Kingdoms](https://gitlab.com/stone-kingdoms/stone-kingdoms)
