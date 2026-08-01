# Stronghold 2027 - Razvojni načrt

> Ta dokument spremlja napredek projekta in določa kratkoročne ter dolgoročne cilje.

Zadnja posodobitev: 2026-08-01

---

## 📊 Trenutno stanje

| Komponenta | Stanje | Verzija |
|-----------|--------|---------|
| Fork repozitorija | ✅ Končano | 0.6.1-upstream |
| Git LFS konfiguracija | ✅ Končano | - |
| LÖVE 11.5 namestitev | ✅ Končano | - |
| Slovenščina (slv.yaml) | ✅ Končano | 1.0 |
| CI/CD pipeline | ✅ Končano | - |
| Dev veje | ✅ Končano | - |
| Bug analiza | ✅ Končano | - |
| Pathfinding fix | ⏳ Načrtovano | - |
| HD asseti | ⏳ Načrtovano | - |
| Combat sistem | ⏳ Načrtovano | - |

---

## 🎯 Faze projekta

### ✅ Faza 0: Priprava (končano)
- [x] Fork Stone Kingdoms iz GitLab v GitHub
- [x] Konfiguracija Git LFS za velike datoteke
- [x] Push celotne zgodovine (1451 commitov, 8 tagov)
- [x] Namestitev LÖVE 11.5
- [x] Analiza arhitekture projekta
- [x] Ustvarjanje FORK_NOTICE.md in README.md
- [x] Konfiguracija git user.name/email
- [x] Ustvarjanje dev veje (feat/bugfixes, feat/hd-assets, feat/slovenian-polish)

### ✅ Faza 1a: Slovenščina (končano)
- [x] Prevedi vseh 472 vrstic besedila
- [x] Registriraj SLV v Languages enum
- [x] Dodaj v LanguageController
- [x] Validacija YAML sintakse
- [x] Commit in push na GitHub

### 🔄 Faza 1b: CI/CD in procesi (v teku)
- [x] GitHub Actions workflow (lint, yaml-validate, build)
- [x] CONTRIBUTING.md
- [x] BUGFIX_STRATEGY.md
- [ ] ROADMAP.md (ta dokument)
- [ ] ISSUE_TEMPLATE.md
- [ ] PULL_REQUEST_TEMPLATE.md
- [ ] CODEOWNERS

### ⏳ Faza 2: Kritični bugfixi (naslednji 1-2 tedna)
- [ ] Setup testnega okolja z X11/VNC
- [ ] Reprodukcija "deer herd load crash"
- [ ] Fix pathfinding skozi zgradbe
- [ ] Dodaj test framework (busted obstaja)
- [ ] Setup Sentry crash reporting (ločen od upstream)

### ⏳ Faza 3: Izboljšave UI/UX (1-2 meseca)
- [ ] Modernizacija menijev
- [ ] Boljši tooltips
- [ ] Configurable hotkeys UI
- [ ] Slovenski govori (po potrebi)

### ⏳ Faza 4: HD grafika (3-6 mesecev)
- [ ] Zamenjava tileset-a z 4K verzijo
- [ ] HD zgradbe sprite-i
- [ ] HD enote sprite-i
- [ ] Modern UI elementi
- [ ] Particle effects
- [ ] Dynamic lighting

### ⏳ Faza 5: Nove vsebine (2-3 meseci)
- [ ] Combat sistem
- [ ] AI nasprotniki
- [ ] Nove kampanje
- [ ] Multiplayer (optional)
- [ ] Modding support

### ⏳ Faza 6: Poliranje in izid (1-2 meseca)
- [ ] Beta testiranje
- [ ] Optimizacija performans
- [ ] Lokalizacija v 5+ novih jezikov
- [ ] Priprava Steam/GOG stran
- [ ] Marketing materiali
- [ ] Release!

---

## 🏗️ Tehnični dolg

| Element | Opis | Prioriteta |
|---------|------|-----------|
| Pathfinding | Enote gredo skozi zgradbe | Visoka |
| Save/Load crash | Crash ob nalaganju z jeleni | Visoka |
| Apothecary | "Currently not functional" | Nizka |
| Stable | "Temporarily not functional" | Nizka |
| Combat sistem | Ni implementiran | Visoka |
| Religion bonus | Ni implementiran | Srednja |
| Maypole | "Temporarily disabled" | Nizka |

---

## 📈 Metrici uspeha

### Kratkoročni (3 mesece)
- 0 kritičnih crash-ev
- 60+ FPS na 1080p
- Čas nalaganja < 3s
- 12+ podprtih jezikov

### Srednjeročni (6 mesecev)
- Combat sistem delujoč
- HD grafika za vse zgradbe
- 144+ FPS na 1440p
- 15+ podprtih jezikov

### Dolgoročni (12 mesecev - izid)
- Multiplayer (če željeno)
- Modding API
- Steam/GOG izid
- 4K teksture za vse
- 20+ podprtih jezikov

---

## 📅 Roki (predhodni)

| Faza | Predvideni rok |
|------|----------------|
| Faza 1 (setup) | 2026-08-15 |
| Faza 2 (bugfix) | 2026-09-15 |
| Faza 3 (UI/UX) | 2026-11-15 |
| Faza 4 (HD grafika) | 2027-03-15 |
| Faza 5 (nove vsebine) | 2027-06-15 |
| Faza 6 (poliranje) | 2027-08-15 |
| **Izid** | **2027-09-01** |

---

## 🎮 Platforme za izid

| Platforma | Načrt | Stanje |
|-----------|-------|--------|
| Windows | Da | Testirano |
| macOS | Da | Testirano |
| Linux | Da | Testirano |
| Steam | Da | Načrtovano |
| GOG | Da | Načrtovano |
| itch.io | Da | Načrtovano |
| Web (browser) | Možno | Raziskovano |
| Mobilne | Možno | Raziskovano |
