# Castle Kingdoms 2027 - Project Summary

> Končni povzetek projekta pred prehodom v asset/testing fazo.
> Datum: 2026-08-22 | Verzija: **v3.12.149**

---

## 📊 Končne številke

| Metric | Vrednost |
|--------|----------|
| Skupne Lua datoteke | 1664 |
| Vrstic kode | ~495.000 |
| GLSL shaderji | 12 |
| Kenney CC0 datoteke | 831 (14 MB) |
| Git tag-ov | 39 |
| Git vej | 35+ |
| Test preverjanj | 343 (100% pass) |
| Nil-safety warnings | 0 |
| Jeziki | 32 |
| Dokumentacija | 17+ .md datotek |
| GitHub Releases | 5+ (.love paketi) |
| Royal sistemov | 990 (v3.11.382-v3.11.971) |
| Royal Tech Tree | 891 deps · 165 verig · 786 multi-prereq (98.25x) |
| Dosežki | 37 |
| Tutorial hinti | 30 |
| UI paneli | 14+ modernih |
| Barvne teme | 6 |
| Težavnostne stopnje | 5 (peaceful/easy/normal/hard/brutal) |
| Game speed stopnje | 5 |
| Persistence datoteke | 20+ |
| Verzij od v1.7.9 | 146+

---

## 🏰 Kaj je Castle Kingdoms 2027?

Open source medieval castle RTS - modernized fork of Stone Kingdoms z:
- 10-misijsko kampanjo "The Lord of Fernhaven"
- 4 AI osebnosti z defense response in adaptation
- Dinamično ekonomijo z 20 surovinami, 4 letni časi, 10 eventov
- Combat z game feel (screen shake, hit flash, punch zoom, combat lines)
- 32 jezikov
- Modding API
- 990 Royal sistemov v povezovanem ekosistemu
- 14+ modernih UI panelov z animacijami in persistenco
- 6 barvnih tem
- 5 stopenj težavnosti z 11 modifierji
- Centralni event log z 6 kategorijami
- Command palette za hitri dostop do vseh funkcij
- Keyboard shortcut editor za customizacijo

---

## 🎮 Feature List (končni)

### Campaign (10 misij, 100%)
- The Lord of Fernhaven - Sir Markus → Kralj Valdemarja
- 6-fazni finalni siege (Mission 10)
- Campaign progress persistence
- 3 achievements
- Mission end screen + credits

### AI (85%)
- 4 osebnosti: Aggressive, Balanced, Defensive, Economic
- 4 težavnosti: Easy, Medium, Hard, Brutal
- Smart building placement (no clustering)
- Defense response (recall units when keep attacked)
- Difficulty adaptation (adjusts to player strength)
- 5-minutni grace period

### Combat (95%)
- 8 unit types z armor in damage calculation
- Projectile system (arrows, bolts, catapult rocks z arc)
- Screen shake, hit flash, punch zoom
- Combat order visualizer (rdeče/rumene črte)
- Formation system (line, column, wedge, spread)
- Health bars z color indicators

### Economy (90%)
- Dynamic market z supply/demand (20 surovin)
- 4 letni časi z vplivom na proizvodnjo
- 10 random economic events
- Trade caravans z escort in risk system
- Inflation system
- Market UI (M key) z trendi
- Caravan UI (C key) z active/history

### Game Feel (90%)
- Screen shake (4 stopnje)
- Hit flash na poškodovanih enotah
- Punch zoom ob smrti/eksploziji
- Build preview (ghost building z valid/invalid)
- Selection glow rings (pulsing)
- Hover highlight
- Drag-select box

### Visual (90%)
- HD shaderji (bloom, color grading, vignette, dynamic lighting)
- Day/night cycle
- Weather (6 tipov: clear, rain, heavy_rain, snow, fog, storm)
- Lightning effects
- Torch/fire light sources z flicker

### Audio (70%)
- Ambient crossfading (wind, birds, fire, rain, crowd)
- SFX z distance attenuation
- Music state machine (explore, combat, victory, defeat)
- Auto-adjust ambients

### UI/UX (98%)
- Modern settings panel (Ctrl+Shift+E, 4 zavihki: Igra, UI, Prikaz, Igralec)
- Settings persistence (20+ persisted datotek)
- Keybind help (F1, 50+ bližnjic, search, click-to-open)
- Keyboard Shortcut Editor (Ctrl+Shift+K, customizacija z persistenco)
- Mission end screen
- Credits screen
- Tutorial manager (Ctrl+Shift+O, 30 hintov z persistenco)
- Performance overlay (F3, 25+ sekcij)
- Season info widget
- Economic event log (Ctrl+Shift+L, 6 kategorij, 5 integriranih sistemov)
- Toast notification system (N, animirana obvestila)
- Color theme system (Ctrl+Shift+J, 6 tem z persistenco)
- Command palette (Ctrl+Space, 23 ukazov v 2 kategorijah)
- Minimap HUD widget (vedno-viden, click-to-navigate)
- Help overlay (H, kontekstualna pomoč + 15 tips)
- UI sound effects (F2 toggle, 14 semantičnih funkcij)
- UI panel animations (fade-in/out + slide za vse panele)
- Particle effects (konfeti, iskre, zlato, screen shake, flash)
- Difficulty panel (Ctrl+Shift+F, 5 stopenj z 11 modifierji)
- Game speed control (Space/1-4, 5 hitrosti z persistenco)
- Auto-save panel + overlay (Ctrl+U, drag-to-move, opacity)

### CC0 Assets (100%)
- 831 Kenney CC0 datotek (14 MB)
- KenneyAssetMapping (89 assetov)
- KenneyAssetLoader (caching, atlas)
- KenneySpriteRenderer (8 draw funkcij)
- KenneySpriteOverlay (game world rendering)
- Settings toggle (V key → Graphics → CC0 Assets)
- Fallback na original Original RTS ko je CC0 OFF

### Infrastructure (95%)
- Git LFS za binarne datoteke
- GitHub Actions CI/CD
- Custom test suite (343 checks)
- Nil-safety audit (0 warnings)
- Auto-save (vsakih 5 min, 3 sloti)
- Campaign progress persistence
- Settings persistence
- Modding API (alpha)

### Localization (100%)
- 32 jezikov: SLV, SRP, ELL, BUL, MKD, LIT, LAV, ENG, DEU, FRA, ITA, POL, POR, RUS, UKR, HUN, + 16 dodatnih
- Misije, zgradbe, skupine, obroki, davki, nastavitve, nasveti, UI, enote, surovine, meseci

---

## 🔗 Povezave

- **GitHub:** https://github.com/markec12345678/castlekingdoms2027
- **Latest release:** https://github.com/markec12345678/castlekingdoms2027/releases/tag/v1.5.3-kenney-rendering
- **Upstream:** https://gitlab.com/stone-kingdoms/stone-kingdoms

---

## 📋 Kaj je še potrebno

| # | Opravilo | Kdo |
|---|----------|-----|
| 1 | Testiranje .love paketa | Ti |
| 2 | HD grafični asseti (po izbiri: Kenney ali lastni) | Oblikovalec |
| 3 | Zvoki (ambient, SFX, voice) | Sound designer |
| 4 | Trailer snemanje | Skupaj |
| 5 | Steam upload | Skupaj |

---

## 📜 Licenca

- **Koda:** Apache 2.0
- **Kenney asseti:** CC0 (Public Domain)
- **Engine:** LÖVE 11.5 (Lua)

---

## 🙏 Zahvale

- **Stone Kingdoms ekipa** - odprtokodna baza
- **Kenney.nl** - CC0 medieval asseti
- **LÖVE community** - game engine
- **Crowdin prevajalci** - prevodi

---

## 🗓️ Razvojna zgodovina (146+ verzij)

| Verzija | Mejnik |
|---------|--------|
| v0.7.0 | Prvi alpha (slovenščina, modding, shaderji) |
| v0.7.1 | Combat integriran |
| v0.8.0 | 5 immersion sistemov |
| v0.9.0 | AI sistem |
| v0.9.1 | Ekonomija + prva misija |
| v1.0.0 | Kampanja končana (10 misij) |
| v1.1.0 | Polish pass (bugfix, balance, AI tuning) |
| v1.2.0 | Combat Order Visualizer |
| v1.2.2 | Full Settings System |
| v1.3.0 | AI Enhancements |
| v1.4.0 | Final Code Audit (feature complete) |
| v1.5.0 | Asset Migration Plan |
| v1.5.3 | Kenney CC0 Rendering |
| v1.6.0 | Final documentation |
| v3.11.382 | Royal Systems Registry + UI Panel |
| v3.11.971 | Vsi 990 Royal sistemov končani |
| v3.12.107 | Tech Tree MAKERS COMPLETE (98.25x) |
| v3.12.127 | Toast Notification System |
| v3.12.128 | Modern Achievement Panel |
| v3.12.129 | Statistics Panel |
| v3.12.130 | UI Sound Effects System |
| v3.12.131 | Particle Effects System |
| v3.12.132 | Tutorial Manager System |
| v3.12.133 | Difficulty Settings System (5 stopenj) |
| v3.12.139 | Game Speed Control Upgrade |
| v3.12.140-v3.12.141 | Save/Load Enhancement + Load State Restoration |
| v3.12.142 | Minimap HUD Widget |
| v3.12.143 | Help Overlay System |
| v3.12.144 | Keyboard Shortcut Editor |
| v3.12.145 | Unified Settings Panel |
| v3.12.146 | Color Theme System (6 tem) |
| v3.12.147-v3.12.148 | Event Log Panel + Integration |
| v3.12.149 | Command Palette (Ctrl+Space) |

**Faza 1-5 končana. Naslednja faza: HD asseti + beta testiranje + Steam/GOG priprava.**
