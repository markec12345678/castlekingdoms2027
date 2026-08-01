# Stronghold 2027

> Open source medieval castle RTS - a modernized fork of Stone Kingdoms with HD graphics, dynamic economy, AI opponents, and a 10-mission campaign.

[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](LICENSE)
[![Status](https://img.shields.io/badge/status-feature--complete-brightgreen)]()
[![Version](https://img.shields.io/badge/version-v1.3.2--completeness-orange)]()

---

## 🎮 Features

### Campaign (10 Missions)
- **The Lord of Fernhaven** - complete story arc
- Sir Markus returns from exile to claim the throne of Valdemar
- Progressive difficulty (⭐ to ⭐⭐⭐⭐⭐)
- 6-phase final siege (Mission 10)
- Campaign progress saved between sessions
- 3 achievements (First Victory, Halfway, King of Valdemar)

### AI System
- 4 personalities: Aggressive, Balanced, Defensive, Economic
- 4 difficulties: Easy, Medium, Hard, Brutal
- Smart building placement (no clustering)
- Strategic attack timing (not random)
- Defense response (recalls units when keep attacked)
- Difficulty adaptation (adjusts to player strength)
- 5-minute grace period (no early attacks)

### Combat
- 8 unit types (Archer, Crossbowman, Spearman, Pikeman, Maceman, Swordsman, Knight, Lord)
- Damage calculation with armor reduction
- Projectile system (arrows, bolts, catapult rocks with arc)
- Health bars with color indicators
- Screen shake, hit flash, punch zoom
- Combat order visualizer (red lines to targets, yellow to destinations)
- Formation system (line, column, wedge, spread)

### Economy
- Dynamic market with supply/demand pricing
- 20 tradeable resources
- 4 seasons (Spring, Summer, Autumn, Winter) affecting production
- 10 random economic events (blight, gold rush, plague, festival, etc.)
- Trade caravans to AI factions (30% better prices, escort system)
- Inflation system

### Game Feel
- Screen shake (4 intensity levels)
- Hit flash on damaged units
- Punch zoom on deaths/explosions
- Smooth camera (lerp)
- Build preview (ghost building with valid/invalid indicator)
- Selection glow rings (pulsing)
- Hover highlight
- Drag-select box

### Visual Systems
- HD shaders (bloom, color grading, vignette, dynamic lighting)
- Day/night cycle (10-minute default)
- Weather system (clear, rain, heavy rain, snow, fog, storm)
- Lightning effects during storms
- Torch/fire light sources with flicker
- Season-colored UI widgets

### Audio
- Ambient sound crossfading (wind, birds, fire, rain, crowd)
- SFX with distance attenuation and stereo panning
- Music state machine (explore, combat, victory, defeat)
- Auto-adjust ambients based on game state

### UI/UX
- Dynamic market UI (M key) - 20 resources with trends
- Caravan UI (C key) - send trade caravans with escort
- Settings panel (V key) - 16 settings in 3 tabs (Game Feel, Audio, Graphics)
- Keybind help (H key) - 25+ shortcuts in 8 categories
- Mission end screen (victory/defeat with stats)
- Credits screen (scrolling, after campaign)
- Tutorial hints (12 contextual tips)
- Performance overlay (F3) - 25+ profiling sections
- Season info widget (always visible)
- Economic event log (toast notifications)

### Infrastructure
- Settings persistence (settings.json)
- Campaign progress persistence (campaign_progress.json)
- Auto-save every 5 minutes (3 rotating slots)
- Performance profiling system
- Tiered entity update (60Hz/10Hz/2Hz)
- AI tick optimizer (5 frequency categories)
- Memory profiler with leak detection
- Modding API (alpha)
- CI/CD pipeline (GitHub Actions)
- Custom test suite (343 checks)

### Localization
- 16 languages supported
- Slovenian (complete, 472 lines)
- Serbian, Greek, Bulgarian, Macedonian, Lithuanian, Latvian (partial)
- English, German, French, Italian, Polish, Portuguese, Russian, Ukrainian, Hungarian (complete)

---

## 🚀 Quick Start

### Option A: Download .love package (recommended)
1. Install [LÖVE 11.5+](https://love2d.org/)
2. Download `stronghold2027-v1.2.1.love` from [Releases](https://github.com/markec12345678/stronghold2027/releases)
3. Double-click the .love file

### Option B: Build from source
```bash
git lfs install
git clone https://github.com/markec12345678/stronghold2027.git
cd stronghold2027
git lfs pull
love .
```

---

## ⌨️ Keybinds

| Key | Function |
|-----|----------|
| H | Keybind help |
| V | Settings (game feel, audio, graphics) |
| M | Market UI (dynamic prices) |
| C | Caravan UI (trade with AI) |
| F3 | Performance overlay |
| F5 | Change weather |
| F6 | Change time of day |
| F7 | Spawn AI opponent |
| F8 | Combat test scenario |
| F9 | Combat statistics |
| F10 | AI debug info |
| F11 | Economy debug info |
| F12 | Load campaign mission 1 |

---

## 📁 Project Structure

```
stronghold2027/
├── objects/
│   ├── AI/                    # AI system (5 modules)
│   ├── Animation/             # Animation state machine
│   ├── Audio/                 # Sound system
│   ├── Combat/                # Combat system (3 modules)
│   ├── Config/                # Balance & settings config
│   ├── Controllers/           # Game controllers (20+)
│   ├── Economy/               # Dynamic market, seasons, events, caravans
│   ├── Environment/           # Lighting system
│   ├── Feedback/              # Game feel (6 modules)
│   ├── Mission/               # Mission framework, campaign progress
│   ├── Performance/           # Profiling (4 modules)
│   └── UI/                    # Modern UI system
├── states/
│   ├── ui/
│   │   ├── economy/           # Market & caravan UI
│   │   ├── hud/               # HUD widgets (6 modules)
│   │   └── settings/          # Settings panel
│   └── game.lua               # Main game loop
├── saves/Missions/campaign/   # 10 campaign missions
├── locale/                    # 16 language files
├── shaders/                   # GLSL shaders (8 files)
├── mods/                      # Modding API
└── scripts/                   # Tests, benchmarks, build scripts
```

---

## 📊 Stats

| Metric | Value |
|--------|-------|
| Lua files | 300+ |
| Lines of code | 215,000+ |
| Buildings | 71 |
| Units | 42 |
| Campaign missions | 10 |
| AI personalities | 4 |
| Languages | 16 |
| Git tags | 28 |
| Test checks | 343 (100% pass) |

---

## 📜 License

Apache 2.0 - see [LICENSE](LICENSE)

Original Stone Kingdoms assets used with permission from Firefly Studios.

---

## 🙏 Credits

- **Firefly Studios** - Original Stronghold game and asset permission
- **Stone Kingdoms team** - Open source base
- **LÖVE community** - Game engine
- **markec12345678** - Stronghold 2027 development
