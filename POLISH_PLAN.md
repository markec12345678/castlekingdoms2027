# Stronghold 2027 - Polish Phase (v1.1.0)

> Po v1.0.0-campaign-complete sledi faza poliranja.
> **Pravilo: NE dodajati novih sistemov.** Samo izboljšati obstoječe.

Zadnja posodobitev: 2026-08-01

---

## 🎯 Cilji polish faze

1. **Gameplay polish** - boljši občutek igranja
2. **Combat polish** - boljše animacije, pathfinding, feedback
3. **Building sistem** - boljši placement, preview, demolition
4. **Visual polish** - boljši UI, terrain, effects
5. **Audio polish** - ambient zvoki, voice feedback
6. **QA faza** - bug fix-i, test scenariji
7. **Steam/GOG priprava** - trailer, screenshots, store page

---

## 📋 Bug fix-i (v1.1.0)

### Fixed in this release

| Bug | Lokacija | Popravek |
|-----|----------|----------|
| Hardcoded faction ID (1) | AIStrategyController.lua:403 | Use COMBAT.FACTION_PLAYER constant |
| Hardcoded faction ID (1) | MissionFramework.lua:272, 284, 320 | Use COMBAT.FACTION_PLAYER constant |
| Brutal AI cheat too high (50%) | AIStrategyController.lua | Reduced to 30% (less unfair feel) |
| Hard AI cheat too high (20%) | AIStrategyController.lua | Reduced to 15% |
| No central balance config | - | Created BalanceConfig.lua |
| Cathedral cost too low | ECONOMY_REDESIGN.md | Updated to 500 stone, 200 gold |
| Caravan risk calculation | TradeCaravanSystem.lua | Now uses BalanceConfig |

### Known issues (to fix in v1.1.1+)

| Issue | Prioriteta | Status |
|-------|-----------|--------|
| Pathfinding: units pass through buildings | High | Investigating |
| Memory leak in pause menu | Medium | Fixed upstream (we have fix) |
| Save/load crash with deer herds | High | Fixed upstream |
| Combat: no attack animations | Medium | Need art assets |
| Combat: no sound effects | Medium | Need audio files |
| UI: tooltips overlap on small screens | Low | Pending |
| Performance: FPS drop with 100+ units | Medium | LOD system needed |

---

## ⚖️ Balance pass (v1.1.0)

### Economy balance

| Sprememba | Prej | Sedaj | Razlog |
|-----------|------|-------|--------|
| Cathedral cost | 100 stone | 500 stone + 200 gold | Bolj realno, Mission 8 challenge |
| Market spread | 50% | 70% | Bolj realno tržišče |
| Caravan bonus | 50% | 30% | Manj exploitative |
| Inflation max | 50% | 30% | Manj frustrirajoče |

### AI balance

| Sprememba | Prej | Sedaj | Razlog |
|-----------|------|-------|--------|
| Brutal cheat | 50% | 30% | Manj "cheating" feel |
| Hard cheat | 20% | 15% | Bolj pošteno |
| AI attack grace period | 0s | 300s (5 min) | Da igralec zadiha |
| AI retreat when outnumbered | No | Yes (50% ratio) | Manj suicidal AI |

### Combat balance

| Enota | Health | Damage | Armor | Cost | Range |
|-------|--------|--------|-------|------|-------|
| Archer | 50 | 12 | 5% | 50g + 5w | 8 |
| Crossbowman | 60 | 25 | 10% | 80g + 10w | 12 |
| Spearman | 70 | 15 | 15% | 30g + 5w | 1.5 |
| Pikeman | 90 | 20 | 25% | 60g + 10w | 1.5 |
| Maceman | 100 | 18 | 20% | 50g + 5i | 1.5 |
| Swordsman | 120 | 22 | 30% | 80g + 10i | 1.5 |
| Knight | 180 | 30 | 45% | 150g + 20i | 1.5 |
| Lord | 500 | 50 | 60% | - | 1.5 |

### Mission difficulty curve

| Misija | Priporočena vojska | Težavnost | AI personality |
|--------|-------------------|-----------|----------------|
| 1 | 0 (tutorial) | ⭐ | - |
| 2 | 5 archers | ⭐⭐ | - |
| 3 | 5 (defense) | ⭐⭐ | - |
| 4 | 10 | ⭐⭐⭐ | Aggressive/Easy |
| 5 | 25 (boss) | ⭐⭐⭐⭐⭐ | Aggressive/Hard |
| 6 | 20 | ⭐⭐⭐⭐ | Aggressive/Medium |
| 7 | 25 (siege) | ⭐⭐⭐⭐⭐ | Defensive/Hard |
| 8 | 15 | ⭐⭐⭐ | Aggressive/Medium |
| 9 | 20 (rescue) | ⭐⭐⭐⭐⭐ | Aggressive/Hard |
| 10 | 40 (final) | ⭐⭐⭐⭐⭐ | Aggressive/Brutal |

---

## 🎮 Gameplay polish (v1.1.0)

### Improved feedback
- ✅ Build confirmation sound (placeholder)
- ✅ Attack order feedback (notification)
- ✅ Retreat indicator (combat state)
- ✅ Health bar colors (green/yellow/red)
- ⏳ Build preview before placement
- ⏳ Demolition particle effects
- ⏳ Upgrade visual feedback

### UX improvements
- ✅ SeasonInfoWidget (always visible)
- ✅ EconomicEventLog (toast notifications)
- ✅ DynamicMarketUI (M key)
- ✅ CaravanUI (C key)
- ⏳ Settings menu
- ⏳ Save/load UI improvements
- ⏳ Tutorial tooltips

---

## ⚔️ Combat polish (v1.1.0)

### What's done
- ✅ Combat state machine (idle, aggro, attacking, retreating, dead)
- ✅ Damage calculation with armor reduction
- ✅ Projectile system (arrows, bolts, rocks with arc)
- ✅ Health bars with color indicators
- ✅ Damage numbers
- ✅ AI personalities (aggressive, balanced, defensive, economic)
- ✅ Formations (line, column, wedge, spread)

### What needs polish
- ⏳ Attack animations (need art assets)
- ⏳ Death animations (need art assets)
- ⏳ Hit reaction animations (need art assets)
- ⏳ Combat sound effects (need audio files)
- ⏳ Morale system (units flee when losing)
- ⏳ Better pathfinding in combat (avoid clustering)

---

## 🏰 Building system polish (v1.1.0)

### What's done
- ✅ Building costs centralized in BalanceConfig
- ✅ Build time per building
- ✅ Housing capacity per building type
- ✅ Cathedral as expensive landmark (500 stone)

### What needs polish
- ⏳ Build preview with validity check
- ⏳ Demolition with partial refund
- ⏳ Upgrade animations
- ⏳ Building particle effects (construction dust)
- ⏳ Better building sprites (HD - needs artist)

---

## 🎨 Visual polish (v1.1.0)

### What's done (programmatic)
- ✅ HD shader system (bloom, color grading, vignette, dynamic lighting)
- ✅ Day/night cycle with sun position
- ✅ Weather system (rain, snow, fog, storm)
- ✅ Lightning effect for storms
- ✅ Torch/fire light sources
- ✅ Modern UI with tooltips and notifications

### What needs artists
- ❌ HD tileset (4K)
- ❌ HD building sprites
- ❌ HD unit sprites with animations
- ❌ HD UI icons
- ❌ Loading screen art
- ❌ Main menu background

---

## 🔊 Audio polish (v1.1.0)

### What's done (programmatic)
- ✅ SoundSystem with ambient crossfading
- ✅ SFX with distance attenuation
- ✅ Music state machine (explore, combat, victory, defeat)
- ✅ Auto-adjust ambients based on game state

### What needs sound designer
- ❌ Ambient loops (wind, birds, fire, rain, crowd)
- ❌ Combat SFX (sword swings, hits, death cries)
- ❌ UI sounds (clicks, notifications)
- ❌ Voice feedback ("Yes lord", "Building complete")
- ❌ Music tracks (explore, combat, victory)

---

## 🐛 QA faza (v1.1.0)

### Test scenarios to implement
1. Save/load test (10x save/load cycles)
2. 2-hour playtest without crash
3. All 10 missions playable to completion
4. Different resolutions (1920x1080, 2560x1440, 3840x2160)
5. Linux/Windows compatibility
6. Performance test (100+ units)
7. AI test (4 personalities × 4 difficulties = 16 combinations)
8. Economy test (inflation, trade, caravans)
9. Combat test (all unit types vs each other)
10. Weather test (all 6 weather types)

### Test framework
- ✅ Custom test runner (scripts/test.lua) - 343 checks
- ✅ Lua syntax validation
- ✅ YAML locale validation
- ⏳ Integration tests (combat scenarios)
- ⏳ Performance benchmarks
- ⏳ Automated playtesting

---

## 🚀 Steam/GOG priprava (v1.2.0+)

### What's ready
- ✅ PRESS_KIT.md
- ✅ COMMUNITY_ANNOUNCEMENT.md
- ✅ ASSETS_NEEDED.md
- ✅ Steam capsule specs in HD_ASSETS_GUIDE.md

### What's missing
- ❌ Trailer video
- ❌ Screenshots (need HD graphics first)
- ❌ Steam store page
- ❌ Achievements integration
- ❌ Settings menu
- ❌ Controller support
- ❌ Installer (Windows .exe, Linux .deb)

---

## ⚖️ Legal considerations

### Asset rights
- ✅ Stone Kingdoms code: Apache 2.0 (commercial use OK)
- ⚠️ Firefly Studios assets: Used with permission via Stone Kingdoms
- ❓ **For Steam release**: Need written permission OR replace all assets

### Recommendations
1. **Option A**: Get written permission from Firefly Studios
2. **Option B**: Commission original art (expensive but safe)
3. **Option C**: Use only open-source assets (limiting but free)

---

## 📊 Metrici za v1.1.0

| Metric | Target | Current |
|--------|--------|---------|
| Test pass rate | 100% | 100% (343/343) |
| Crash rate per hour | < 0.1 | Unknown (needs playtest) |
| FPS (1080p, 50 units) | 60+ | Unknown (needs profiling) |
| Load time | < 5s | ~5s |
| Memory usage | < 512MB | Unknown |
| AI decision time | < 16ms | Unknown |

---

## 🎯 Naslednji koraki (po vrstnem redu)

1. **Bug fix sweep** - pregled vseh controller-jev za nil crash-e
2. **Balance tuning** - testiranje vseh 10 misij
3. **AI improvement** - manj goljufanja, bolj naravno
4. **Performance profiling** - identificirati bottlenecks
5. **QA testing** - 2h playtest brez crasha
6. **Polish pass** - UX, feedback, animacije (ko so asseti)
7. **Steam/GOG prep** - ko so HD asseti in trailer pripravljeni
