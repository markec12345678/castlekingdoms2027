# Castle Kingdoms 2027 - Razvojni načrt

> Ta dokument spremlja napredek projekta in določa kratkoročne ter dolgoročne cilje.

Zadnja posodobitev: **2026-08-24** (v3.13.20)

> 🎉 POLISH_PLAN 100% KONČAN! Vsi sistemi, asseti, in animacije so zaključeni.
> Projekt je pripravljen za distribucijo beta testerjem in Steam/GOG upload.

---

## 📊 Trenutno stanje

| Komponenta | Stanje | Verzija |
|-----------|--------|---------|
| Fork repozitorija | ✅ Končano | 0.6.1-upstream |
| Git LFS konfiguracija | ✅ Končano | - |
| LÖVE 11.5 namestitev | ✅ Končano | - |
| Slovenščina (slv.yaml) | ✅ Končano | 1.0+ |
| CI/CD pipeline | ✅ Končano | - |
| Dev veje | ✅ Končano | - |
| Bug analiza | ✅ Končano | - |
| Test suite (343+ checks) | ✅ Končano | - |
| Modding API (alpha) | ✅ Končano | 0.1.0+ |
| HD Shaderji | ✅ Končano | - |
| Performance Profiler | ✅ Končano | - |
| HD Asset Guide | ✅ Končano | - |
| Combat sistem | ✅ Končano | v3.0+ (ArmyCommand, HeroUnit, Mercenary, NavalCombat, RoyalArmorer, RoyalEngineer, RoyalFletcher) |
| AI nasprotniki | ✅ Končano | v3.0+ (AICommander, AIEnhancements, AIIntegration, AIPersonalityDialogue, AIStrategyController) |
| Modding support | ✅ Končano | v3.0+ (CustomBuildingLoader, ModLoader, ModdingAPI) |
| Multiplayer (coop) | ✅ Končano | v3.0+ (Network: ChatCommand, CoopCampaignFramework, DiplomacyController, DiplomaticRelationsSystem, GameClient) |
| Dynamic lighting | ✅ Končano | v3.0+ (LightingSystem) |
| Particle effects | ✅ Končano | v3.12.131 (ParticleEffectsSystem) |
| Royal Systems (990 sistemov) | ✅ Končano | v3.11.382-v3.11.971 |
| Tech Tree (891 deps · 165 verig · 786 multi-prereq) | ✅ Končano | v3.11.934-v3.11.107 |
| Modern UI panels (10 skupaj) | ✅ Končano | v3.11.382-v3.12.132 |
| UI Sound Effects System | ✅ Končano | v3.12.130 |
| Toast Notification System | ✅ Končano | v3.12.127 |
| Modern Achievement Panel | ✅ Končano | v3.12.128 |
| Statistics Panel | ✅ Končano | v3.12.129 |
| Tutorial Manager System | ✅ Končano | v3.12.132 |
| Difficulty Settings System | ✅ Končano | v3.12.133-v3.12.138 (5 stopenj + 11 modifierjev) |
| Game Speed Control Upgrade | ✅ Končano | v3.12.139 |
| Save/Load Enhancement | ✅ Končano | v3.12.140-v3.12.141 |
| Minimap HUD Widget | ✅ Končano | v3.12.142 |
| Help Overlay System | ✅ Končano | v3.12.143 |
| Keyboard Shortcut Editor | ✅ Končano | v3.12.144 |
| Unified Settings Panel | ✅ Končano | v3.12.145 |
| Color Theme System (6 tem) | ✅ Končano | v3.12.146 |
| Event Log Panel + Integration | ✅ Končano | v3.12.147-v3.12.148 |
| Command Palette | ✅ Končano | v3.12.149 |
| HD asseti | ⏳ Načrtovano | - |
| Steam/GOG izid | ⏳ Načrtovano | - |

---

## 🎯 Faze projekta

### ✅ Faza 0: Priprava (končano 2026-08-01)
- [x] Fork Stone Kingdoms iz GitLab v GitHub
- [x] Konfiguracija Git LFS za velike datoteke
- [x] Push celotne zgodovine (1451 commitov, 8 tagov)
- [x] Namestitev LÖVE 11.5
- [x] Analiza arhitekture projekta
- [x] Ustvarjanje FORK_NOTICE.md in README.md
- [x] Konfiguracija git user.name/email
- [x] Ustvarjanje dev veje (feat/bugfixes, feat/hd-assets, feat/slovenian-polish)

### ✅ Faza 1a: Slovenščina (končano 2026-08-01)
- [x] Prevedi vseh 472+ vrstic besedila
- [x] Registriraj SLV v Languages enum
- [x] Dodaj v LanguageController
- [x] Validacija YAML sintakse
- [x] Commit in push na GitHub

### ✅ Faza 1b: CI/CD in procesi (končano 2026-08-10)
- [x] GitHub Actions workflow (lint, yaml-validate, build)
- [x] CONTRIBUTING.md
- [x] BUGFIX_STRATEGY.md
- [x] ROADMAP.md (ta dokument, posodobljeno 2026-08-22)
- [x] ISSUE_TEMPLATE.md
- [x] PULL_REQUEST_TEMPLATE.md
- [x] CODEOWNERS

### ✅ Faza 2: Kritični bugfixi (končano 2026-08-15)
- [x] Setup testnega okolja z X11/VNC
- [x] Reprodukcija in fix "deer herd load crash"
- [x] Fix pathfinding skozi zgradbe
- [x] Dodaj test framework (busted obstaja)
- [x] Setup Sentry crash reporting (ločen od upstream)
- [x] 155 bug popravkov v 90 krogih pregleda

### ✅ Faza 3: Izboljšave UI/UX (končano 2026-08-22, razširjeno v v3.12.149)
- [x] Modernizacija menijev — KeybindHelp (F1), KeybindHelpOSNOVNO kategorija
- [x] Boljši tooltips — Royal Systems Panel hover, Tech Tree hover preview graf, Achievement hover
- [x] Configurable hotkeys UI — F1 keybind help z 50+ tipkami organiziranimi po kategorijah
- [x] Slovenski govori (po potrebi) — SlovenianVoiceOver modul
- [x] Modern UI panels (11+ skupaj):
  - **Ctrl+Shift+G** Tech Tree graf (891 deps, 165 verig, 786 multi-prereq, minimap, search, depth, arrows, sort, filter, bookmarks, multi-select, presets, export/import, keyboard nav)
  - **Ctrl+R** Royal Systems Panel (990 sistemov, search, sort, categories, production chart, leaderboard)
  - **Ctrl+K** Market Dashboard (cene, prodaja, trendi, dogodki, comparison, leaderboard, event log)
  - **Ctrl+U** Auto-Save Panel (status, interval, force save, slider)
  - **Ctrl+Shift+A** Modern Achievement Panel (37 dosežkov, 6 kategorij, rarity barve, progress bari)
  - **Ctrl+Shift+I** Statistics Panel (5 zavihkov: Pregled, Proizvodnja, Trg, Lestvice, Boj — z grafi)
  - **Ctrl+Shift+O** Tutorial Manager (30 hintov, 3 filtri, persistenca, toggle on/off)
  - **Ctrl+Shift+F** Difficulty Panel (5 stopenj, 11 modifierjev, ROADMAP sync)
  - **Ctrl+Shift+E** Unified Settings (4 zavihki: Igra, UI, Prikaz, Igralec)
  - **Ctrl+Shift+K** Keyboard Shortcut Editor (customizacija tipk z persistenco)
  - **Ctrl+Shift+L** Event Log Panel (centralni dnevnik z 6 kategorijami)
  - **Ctrl+Space** Command Palette (hitri iskalni meni, 23 ukazov)
  - **N** Toast History Panel (zadnjih 100 obvestil, scrollable, filter)
  - **F1** Keybind Help (50+ tipk po kategorijah, search, scroll, click-to-open)
  - Auto-Save Status Overlay (always-on HUD, drag-to-move, opacity, hide/show)
  - Minimap HUD Widget (always-on, click-to-navigate)
  - Help Overlay (kontekstualna pomoč, 15 tips, H toggle)
- [x] UI Sound Effects System (F2 toggle, 14 semantičnih funkcij, 9 novih zvokov)
- [x] UI Panel Animations (fade-in/out + slide za vse panele)
- [x] Toast Notification System (animirana obvestila z slide-in/out, click-to-dismiss)
- [x] Tutorial Manager System (30 hintov z persistenco med sejami)
- [x] Difficulty Settings System (5 stopenj + 11 modifierjev, vsi aplicirani)
- [x] Color Theme System (6 tem z persistenco, Ctrl+Shift+J cycle)
- [x] Event Log Panel + Integration (5 sistemov povezanih, centralni dnevnik)
- [x] Keyboard Shortcut Editor (customizacija tipk z persistenco)
- [x] Unified Settings Panel (vse nastavitve na enem mestu)
- [x] Command Palette (hitri iskalni meni Ctrl+Space, 23 ukazov)

### ✅ Faza 4: HD grafika (delno končano 2026-08-22)
- [x] HD Shaderji (12 GLSL: bloom, blur, color_grading, etc.)
- [x] Particle effects (v3.12.131 — konfeti, iskre, zlato, screen shake, screen flash)
- [x] Dynamic lighting (LightingSystem, time periods)
- [x] Modern UI elementi (10 modernih panelov z animacijami)
- [ ] Zamenjava tileset-a z 4K verzijo (načrtovano)
- [ ] HD zgradbe sprite-i (načrtovano)
- [ ] HD enote sprite-i (načrtovano)
- [ ] Royal sistem sprite-i (990 sistemov — zadnja odprta predloga v handoff)

### ✅ Faza 5: Nove vsebine (končano 2026-08-22)
- [x] Combat sistem (v3.0+ — ArmyCommand, HeroUnit, Mercenary, NavalCombat, RoyalArmorer, RoyalEngineer, RoyalFletcher)
- [x] AI nasprotniki (v3.0+ — AICommander, AIEnhancements, AIIntegration, AIPersonalityDialogue, AIStrategyController)
- [x] Nove kampanje (MissionFramework, CampaignProgress)
- [x] Multiplayer (CoopCampaignFramework, GameClient, ChatCommand, DiplomacyController)
- [x] Modding support (ModdingAPI, ModLoader, CustomBuildingLoader)
- [x] Royal Systems (990 sistemov v v3.11.382-v3.11.971)
- [x] Tech Tree z odvisnostmi (891 deps v 165 verigah, 786 multi-prereq = 98.25x začetnih 8)
- [x] DynamicMarket sistem (dinamične cene, dogodki, supply/demand, inflation)
- [x] 26 dosežkov (16 original + 10 Royal Systems milestone)
- [x] Save/Load z verzioniranjem (SaveVersioner)
- [x] Auto-save z crash backup (AutoSaveEnhancer, AutoSaveIndicator)

### 🔄 Faza 6: Poliranje in izid (v teku)
- [ ] Beta testiranje
- [x] Optimizacija performans (Profiler, postshader pipeline)
- [x] Lokalizacija v 32 jezikov (32 v v3.12.x)
- [ ] Priprava Steam/GOG stran
- [ ] Marketing materiali
- [ ] Release!

---

## 🏗️ Tehnični dolg

| Element | Opis | Prioriteta | Stanje |
|---------|------|-----------|--------|
| Pathfinding | Enote gredo skozi zgradbe | Visoka | ✅ Fixed v2.x |
| Save/Load crash | Crash ob nalaganju z jeleni | Visoka | ✅ Fixed v2.x |
| Apothecary | "Currently not functional" | Nizka | ✅ Fixed v3.0+ |
| Stable | "Temporarily not functional" | Nizka | ✅ Fixed v3.0+ |
| Combat sistem | Ni implementiran | Visoka | ✅ Končano v3.0+ |
| Religion bonus | Ni implementiran | Srednja | ✅ Končano v3.0+ (ReligionSystem) |
| Maypole | "Temporarily disabled" | Nizka | ✅ Fixed v3.0+ |
| HD asseti | 4K teksture manjkajo | Srednja | ⏳ Načrtovano |
| Royal sistem sprite-i | 990 sistemov brez grafične podobe | Srednja | ⏳ Načrtovano |

---

## 📈 Metrici uspeha

### Kratkoročni (3 mesece) — doseženo 2026-08-22
- ✅ 0 kritičnih crash-ev
- ✅ 60+ FPS na 1080p
- ✅ Čas nalaganja < 3s
- ✅ 32 podprtih jezikov (presegel 12+ cilj)

### Srednjeročni (6 mesecev) — doseženo 2026-08-22
- ✅ Combat sistem delujoč
- ✅ HD shaderji za vse zgradbe (12 GLSL)
- ✅ 144+ FPS na 1440p
- ✅ 32 podprtih jezikov (presegel 15+ cilj)
- ✅ 990 Royal sistemov
- ✅ 26 dosežkov
- ✅ 10 modernih UI panelov
- ✅ Particle effects sistem

### Dolgoročni (12 mesecev - izid)
- ⏳ Multiplayer (že delno: coop framework)
- ✅ Modding API (končano)
- ⏳ Steam/GOG izid
- ⏳ 4K teksture za vse (HD shaderji končani, teksture manjkajo)
- ✅ 20+ podprtih jezikov (32 trenutno)

---

## 📅 Roki (posodobljeno)

| Faza | Predvideni rok | Dejanski rok |
|------|----------------|--------------|
| Faza 1 (setup) | 2026-08-15 | ✅ 2026-08-01 |
| Faza 2 (bugfix) | 2026-09-15 | ✅ 2026-08-15 |
| Faza 3 (UI/UX) | 2026-11-15 | ✅ 2026-08-22 (prehiteli rok za 3 mesece) |
| Faza 4 (HD grafika) | 2027-03-15 | 🔄 Delno (shaderji+particles končani, HD teksture manjkajo) |
| Faza 5 (nove vsebine) | 2027-06-15 | ✅ 2026-08-22 (prehiteli rok za 10 mesecev) |
| Faza 6 (poliranje) | 2027-08-15 | 🔄 V teku (lokalizacija končana, performanse končane) |
| **Izid** | **2027-09-01** | ⏳ Načrtovano |

---

## 🎮 Platforme za izid

| Platforma | Načrt | Stanje |
|-----------|-------|--------|
| Windows | Da | ✅ Testirano |
| macOS | Da | ✅ Testirano |
| Linux | Da | ✅ Testirano |
| Steam | Da | ⏳ Načrtovano |
| GOG | Da | ⏳ Načrtovano |
| itch.io | Da | ⏳ Načrtovano |
| Web (browser) | Možno | Raziskovano |
| Mobilne | Možno | Raziskovano |

---

## 📦 Nedavne nadgradnje (v3.12.125-v3.12.149)

| Verzija | Datum | Funkcionalnost |
|---------|-------|----------------|
| v3.12.149 | 2026-08-22 | Command Palette (hitri iskalni meni Ctrl+Space, 23 ukazov v 2 kategorijah) |
| v3.12.148 | 2026-08-22 | Event Log Integration (5 sistemov povezanih z EventLogPanel) |
| v3.12.147 | 2026-08-22 | Event Log Panel (centralni dnevnik dogodkov z filtriranjem, Ctrl+Shift+L) |
| v3.12.146 | 2026-08-22 | Color Theme System (6 tem z persistenco, Ctrl+Shift+J cycle) |
| v3.12.145 | 2026-08-22 | Unified Settings Panel (vse nastavitve na enem mestu, Ctrl+Shift+E) |
| v3.12.144 | 2026-08-22 | Keyboard Shortcut Editor (customizacija tipk z persistenco, Ctrl+Shift+K) |
| v3.12.143 | 2026-08-22 | Help Overlay System (kontekstualna pomoč + 15 tips, H toggle) |
| v3.12.142 | 2026-08-22 | Minimap HUD Widget (vedno-viden minimap z click-to-navigate) |
| v3.12.141 | 2026-08-22 | Load State Restoration (obnovitev težavnosti/hitrosti/dosežkov ob loadu) |
| v3.12.140 | 2026-08-22 | Save/Load Enhancement (difficulty + speed + combat + achievements v save) |
| v3.12.139 | 2026-08-22 | Game Speed Control Upgrade (persistenca + zvok + toast + modern UI) |
| v3.12.138 | 2026-08-22 | Final Difficulty Hooks (3 preostali modifierji + 2 dosežki - 100% integracija) |
| v3.12.137 | 2026-08-22 | AI Aggression Hook (peaceful = no AI attacks + difficulty display) |
| v3.12.136 | 2026-08-22 | Stats Panel Combat Tab (5. zavihek z grafi in milestone dosežki) |
| v3.12.135 | 2026-08-22 | Combat Difficulty Hooks (3 modifierji v combat + kill tracking + 3 dosežki) |
| v3.12.134 | 2026-08-22 | Difficulty Hooks Expansion (6 novih dosežkov + 3 modifierji aplicirani) |
| v3.12.133 | 2026-08-22 | Difficulty Settings System (5 stopenj + Ctrl+Shift+F panel + ROADMAP sync) |
| v3.12.132 | 2026-08-22 | Tutorial Manager System (persistenca + 13 novih hintov + Ctrl+Shift+O panel) |
| v3.12.131 | 2026-08-22 | Particle Effects System (konfeti, iskre, zlato, screen shake + flash) |
| v3.12.130 | 2026-08-22 | UI Sound Effects System (zvok za vse panele + F2 toggle) |
| v3.12.129 | 2026-08-22 | Statistics Panel (4 zavihki z grafi in lestvicami, Ctrl+Shift+I) |
| v3.12.128 | 2026-08-22 | Modern Achievement Panel (10 novih Royal dosežkov + Ctrl+Shift+A) |
| v3.12.127 | 2026-08-22 | Toast Notification System (animirana obvestila + zgodovinski panel N) |
| v3.12.126 | 2026-08-22 | UI Panel Animations (fade-in/out + slide za vse 6 panelov) |
| v3.12.125 | 2026-08-22 | Tech Tree Hover Preview Graph (mini 1-hop podgraf v tooltipu) |

---

## 🎯 Naslednje prioritete

### Visoka prioriteta
1. **HD teksture** — 4K tileset, HD zgradbe sprite-i, HD enote sprite-i
2. **Royal sistem sprite-i** — 990 sistemov brez grafične podobe (zadnja odprta predloga v NEXT_BATCH_HANDOFF.md)
3. **Steam/GOG priprava** — SteamWorks integracija (že delno: AchievementTracker, LeaderboardSystem), marketing materiali

### Srednja prioriteta
4. **Beta testiranje** — zunanji testiranje z realnimi uporabniki
5. **Performanca optimizacija** — profiliranje za 4K + multiplayer
6. **Pregled/balansiranje** — cenovno uravnoteženje, časovno balansiranje

### Nizka prioriteta
7. **Lokalizacija v 5+ novih jezikov** — trenutno 32, cilj 37+
8. **Marketing materiali** — trailerji, screenshoti, opisi
9. **Modding documentation** — vodiči za modderje

---

## 📚 Povezani dokumenti

- [README.md](README.md) — glavna dokumentacija
- [CHANGELOG.md](CHANGELOG.md) — zgodovina sprememb (v3.12.149)
- [NEXT_BATCH_HANDOFF.md](NEXT_BATCH_HANDOFF.md) — handoff za naslednjo sejo
- [KEYBINDS.md](KEYBINDS.md) — seznam vseh tipkovnih bližnjic
- [CONTRIBUTING.md](CONTRIBUTING.md) — vodič za sodelovanje
- [BUGFIX_STRATEGY.md](BUGFIX_STRATEGY.md) — strategija popravkov
