# Stronghold 2027

Modernizirana različica igre Stronghold (2001) za leto 2027, zgrajena na LÖVE 11.5 (Lua/LuaJIT).

[![Version](https://img.shields.io/badge/version-1.18.0-blue.svg)](https://github.com/markec12345678/stronghold2027)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](LICENSE)
[![LÖVE](https://img.shields.io/badge/LÖVE-11.5-orange.svg)](https://love2d.org)

## Prenosi

- **Zadnja izdaja**: [v1.18.0](https://github.com/markec12345678/stronghold2027/releases/tag/v1.18.0)
- **.love datoteka**: `stronghold2027-v1.18.0.love` (305 MB)

## Zagon

```cmd
& "C:\Program Files\LOVE\love.exe" "F:\pot\do\stronghold2027-v1.18.0.love"
```

Ali iz git checkout-a (zahteva [git-lfs](https://git-lfs.com/)):
```cmd
git clone https://github.com/markec12345678/stronghold2027.git
cd stronghold2027
git lfs install
git lfs pull
love .
```

## Funkcije

### 🎮 Jedro igre
- **10 misij kampanje** s story cutscene-i v slovenščini
- **Freebuild način** za sproščeno igranje
- **4 AI osebnosti** (aggressive, balanced, defensive, economic) × 4 težavnosti
- **Dynamic economy** — supply/demand, inflacija, sezonski modifikatorji
- **Combat system** — projektili, oklep, damage variance, game feel

### 🌐 Multiplayer
- **TCP/IP socket networking** (do 8 igralcev)
- **Lobby UI** — host/join, seznam igralcev, ready status
- **In-game chat** (Enter za odprtje)
- **Diplomacy** — 6 stanj (neutral, allied, war, truce, proposed_alliance, proposed_peace)
- **Trade system** — predlogi, darila, trade routes
- **F9** — diplomacy & trade panel

### 🎨 HD Grafika
- **Normal mapping** za teren (Sobel filter iz heightmap)
- **Dynamic point lights** (do 32 luči — bakle, ogenj, zgradbe)
- **SSAO** (Screen-Space Ambient Occlusion)
- **ACES filmic tone mapping** + gamma korekcija
- **Bloom, color grading, vignette** shaderji
- **Day/night cycle** z dinamično osvetlitvijo
- **Weather system** (dež, sneg, megla, nevihta)

### 🔊 Zvok
- **Dynamic music** — 5 stanj (menu, peace, combat, victory, defeat)
- **SFX library** — 4 kategorije (combat, building, UI, environment)
- **3D positional audio** (glasnost glede na razdaljo)
- **Slovenian voice-over** — 30+ notifikacij v slovenščini
- **5 kategorij glasnosti** (master, sfx, music, speech, ambient)

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
- **Auto-pause na focus loss**

### 🛠️ Orodja
- **Map Editor** (F12) — terrain painting, objects, save/load
- **Replay System** (Ctrl+R) — snemanje/predvajanje
- **Statistics Dashboard** (Ctrl+S) — session + lifetime statistike
- **Debug Console** (Tilde ~) — 12 ukazov
- **Crash Handler** (F11) — auto-disable failing systems
- **Performance Watchdog** — auto quality adjustment
- **Release Checklist** (Ctrl+L) — 20 pre-release preverjanj

### 🔌 Modding
- **Mod loader** — scan /mods, load manifest.lua
- **Custom buildings, units, maps, scripts**
- **Hot-reload** za development
- **Sample mod** vključen (GoldMine building)

### 🏆 Steam Integration
- **10 achievements** (first_victory, campaign_complete, master_builder, ...)
- **Stats tracking** (buildings, kills, trades, alliances)
- **Leaderboard** (stub)
- **Rich presence** (stub)

### 📚 Vadba
- **10-korak interaktivni tutorial** v slovenščini
- **Ctrl+T** za zagon

## Tipke

| Tipka | Funkcija |
|-------|----------|
| F5 | Cycle weather |
| F6 | Cycle time of day |
| F7 | Toggle HD pipeline |
| F8 | Refresh lights |
| F9 | Diplomacy & trade panel |
| F10 | Run mission tests |
| F11 | Crash log + stats |
| F12 | Map Editor |
| Ctrl+T | Tutorial |
| Ctrl+O | Unified Settings |
| Ctrl+B | Spawn catapult |
| Ctrl+L | Release checklist |
| Ctrl+R | Replay recording |
| Ctrl+S | Statistics |
| Tilde (~) | Debug console |
| Enter | Chat |
| M | Market UI |
| C | Caravan UI |
| V | Game feel settings |
| H | Keybind help |

## Arhitektura

```
stronghold2027/
├── main.lua                    # Vhodna točka
├── conf.lua                    # LÖVE konfiguracija
├── states/                     # Game states
│   ├── game.lua               # Glavna igra
│   ├── start_menu.lua         # Glavni meni
│   ├── splash_screen.lua      # Splash
│   └── ui/                    # UI komponente
│       ├── multiplayer/       # Lobby, chat, diplomacy
│       ├── settings/          # Unified settings
│       └── construction/      # Action bar buttons
├── objects/                    # Game objects & systems
│   ├── AI/                    # AI controller, strategy
│   ├── Audio/                 # Music, SFX, voice-over
│   ├── Combat/                # Combat, siege weapons
│   ├── Config/                # Balance, localization, accessibility
│   ├── Economy/               # Market, trade, caravans
│   ├── Environment/           # Lighting, HD pipeline, normal maps
│   ├── Mission/               # Campaign, story
│   ├── Modding/               # Mod loader, custom buildings
│   ├── Network/               # Multiplayer, diplomacy, trade
│   ├── Performance/           # Optimizer, profiler
│   ├── QA/                    # Tests, crash handler, replay
│   ├── Steam/                 # Achievements, integration
│   └── Tutorial/              # Tutorial system
├── shaders/                    # GLSL shaders
│   ├── normal_mapping.glsl
│   ├── point_lights.glsl
│   ├── ssao.glsl
│   ├── tonemap.glsl
│   ├── bloom.glsl
│   └── dynamic_lighting.glsl
├── locale/                     # 32 jezikov (YAML)
├── mods/                       # Mod direktorij
│   └── sample_mod/            # Sample mod (GoldMine)
├── assets/                     # Slike, zvoki, fonti
├── saves/                      # Save datoteke
└── sounds/                     # Glasba, SFX, speech
```

## Razvoj

### Zahteve
- [LÖVE 11.5](https://love2d.org)
- [Git LFS](https://git-lfs.com) (za asset checkout)
- Lua 5.1 / LuaJIT

### Build
```cmd
git clone https://github.com/markec12345678/stronghold2027.git
cd stronghold2027
git lfs install
git lfs pull
:: Zagon:
love .
:: Ali build .love datoteke:
zip -r stronghold2027.love . -x ".git/*"
```

### Testiranje
- **F10** — Run mission test suite (10 campaign missions)
- **Ctrl+L** — Release checklist (20 checks)
- **Tilde (~)** — Debug console

## Zgodovina razvoja

| Verzija | Datum | Opis |
|---------|-------|------|
| v1.7.9 | 2025-08-02 | Action bar SetScale fix |
| v1.8.0 | 2025-08-02 | HD Asset Pipeline |
| v1.9.0 | 2025-08-02 | Multiplayer (TCP/IP) |
| v1.10.0 | 2025-08-02 | Diplomacy & Trade |
| v1.11.0 | 2025-08-02 | Polish & Bug Fix |
| v1.12.0 | 2025-08-02 | Modding API + Steam |
| v1.13.0 | 2025-08-02 | Sound Design |
| v1.14.0 | 2025-08-02 | Replay + Stats + Map Editor |
| v1.15.0 | 2025-08-02 | Localization + Accessibility + Tutorial |
| v1.16.0 | 2025-08-02 | Campaign Story + Siege Weapons |
| v1.17.0 | 2025-08-02 | Release Candidate |
| v1.18.0 | 2025-08-02 | Save Compat + Profiles + Console |

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
