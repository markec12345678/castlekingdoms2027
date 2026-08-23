# Beta Test Checklist — Castle Kingdoms 2027

> Strukturiran test plan za beta testiranje verzije v3.12.168+.
> Generirano: 2026-08-23 | Verzija: v3.12.169
>
> Povezani dokumenti:
> - [POLISH_PLAN.md](POLISH_PLAN.md) — roadmap
> - [DEMO_BUILD_GUIDE.md](DEMO_BUILD_GUIDE.md) — build navodila
> - [KEYBINDS.md](KEYBINDS.md) — vse bližnjice
> - [CHANGELOG.md](CHANGELOG.md) — zgodovina sprememb

---

## 🎯 Cilji beta testiranja

1. **Stability** — preveri da igra ne crash-a v 2+ urah igranja
2. **Performance** — potrdi 60+ FPS na 1080p z 100+ enotami
3. **Combat systems** — preveri delovanje morale, spacing, LOD, SFX
4. **Save/Load** — potrdi popoln cikel (save → load → vse deluje)
5. **UI/UX** — preveri vse panele in bližnjice
6. **Localization** — potrdi delovanje v vseh 32 jezikih

---

## 📋 Pred-pogoji za testiranje

### Tehnične zahteve

| Komponenta | Zahteva |
|------------|---------|
| OS | Windows 10+, macOS 11+, ali Linux (Ubuntu 20.04+) |
| RAM | 4 GB minimum, 8 GB priporočeno |
| GPU | OpenGL 3.3+ podpora |
| Disk | 500 MB prosto (305 MB z LFS) |
| LÖVE | 11.5 (vključeno v .love) |

### Priprava okolja

```bash
# Kloniraj repo
git clone https://github.com/markec12345678/castlekingdoms2027.git
cd castlekingdoms2027

# Prenesi LFS asset-e (potrebno za prave PNG)
git lfs install
git lfs pull

# Zaženi iz vira
love .

# ALI zgradi .love datoteko (glej v3.12.170)
./scripts/build_demo.sh
love castlekingdoms2027.love
```

---

## 🧪 Test scenariji

### Faza 1: Osnovna funkcionalnost (30 min)

#### 1.1 Zagon igre
- [ ] Igra se zažene brez napak v konzoli
- [ ] Glavni meni prikaže pravilno verzijo (v3.12.168+)
- [ ] Sprememba jezika deluje (preklopi na SLV, nato nazaj na ENG)
- [ ] Odpri nastavitve (V key) — vse 3 tabi delujejo

#### 1.2 Nova igra
- [ ] Začetek nove igre brez crash-a
- [ ] Mapa se naloži v < 3 sekundah
- [ ] Keep (grad) se pravilno postavi na start pozicijo
- [ ] Začetni viri (zlato, les, kamen, hrana) so pravilni

#### 1.3 Osnovne bližnjice
- [ ] F1 — odpri keybind help panel
- [ ] F2 — toggle UI zvok (slišiš klik)
- [ ] F3 — odpri performance overlay
- [ ] H — center view to keep
- [ ] N — odpri toast history
- [ ] Esc — odpri pause menu

### Faza 2: Economy sistem (45 min)

#### 2.1 Gradnja
- [ ] Postavi Stockpile (Ctrl+1)
- [ ] Postavi Granary (Ctrl+2)
- [ ] Postavi Woodcutter Hut (Ctrl+3)
- [ ] Postavi Quarry (Ctrl+4)
- [ ] Postavi Wheat Farm (Ctrl+5)
- [ ] Postavi Barracks (Ctrl+6)
- [ ] Postavi Market (Ctrl+7)
- [ ] Postavi Armoury (Ctrl+8)
- [ ] Postavi Inn (Ctrl+9)
- [ ] Vse zgradbe prikazujejo pravilne sprite-e

#### 2.2 Trgovina
- [ ] Odpri Market Dashboard (Ctrl+K)
- [ ] Cene 20 surovin se prikazujejo pravilno
- [ ] Sortiranje deluje (S key cycle)
- [ ] Search deluje (/ key)
- [ ] Leaderboard deluje (Q key toggle)
- [ ] Procedural ikone se prikazujejo ob imenih sistemov
- [ ] Event log se lahko razširi (V key)

#### 2.3 Royal Systems
- [ ] Odpri Royal Systems Panel (Ctrl+R)
- [ ] 990 sistemov se prikaže v listu
- [ ] Procedural ikone (16x16) prikazane ob imenih
- [ ] Search (/ key) filtrira sisteme
- [ ] Sortiranje (F key) deluje
- [ ] Kategorije (Tab key) ciklajo
- [ ] Klik na sistem prikaže detail panel z 48x48 ikono
- [ ] Najem mojstra deluje (če imas zlato)
- [ ] Gradnja delavnice deluje
- [ ] Izdelava produkta deluje

#### 2.4 Tech Tree
- [ ] Odpri Tech Tree Panel (Ctrl+Shift+G)
- [ ] Graf vozlišč se prikaže (891 deps)
- [ ] Search (/ key) deluje
- [ ] Hover tooltip prikaže procedural ikono (24x24)
- [ ] Klik na vozlišče fokusira sorodne
- [ ] 2x klik odpre Royal Systems Panel
- [ ] Toggle text/graf view (G key)
- [ ] Minimap (M key) deluje
- [ ] Sortiranje (S key) deluje
- [ ] Filter (L key) ciklja

### Faza 3: Combat sistem (60 min)

#### 3.1 Osnovni combat
- [ ] Spawn 5 Archerjev v Barracks
- [ ] Spawn 5 Spearmen v Barracks
- [ ] Spawn AI nasprotnik (F7)
- [ ] Izberi enote (klik ali drag)
- [ ] Premakni enote (desni klik)
- [ ] Napadi sovražnika (desni klik na enemy)
- [ ] Damage numbers se prikazujejo
- [ ] Health bar-i se prikazujejo
- [ ] Death animacija se predvaja
- [ ] Combat SFX se sliši (sword_hit, arrow_shoot)

#### 3.2 Morale System (v3.12.156-v3.12.159)
- [ ] Odpri Performance Dashboard (Ctrl+Shift+I → PERFORMANCE tab)
- [ ] Morale statistike se prikazujejo (sledene enote, povprečna morale)
- [ ] Toggle morale bars (Ctrl+Shift+Z) — prikaz nad enotami
- [ ] Boj z močnim sovražnikom — morale pada
- [ ] Ko morale pade pod 25 — enota začne bežati
- [ ] Flee scream zvok se sliši ob begu
- [ ] Morale break crack zvok se sliši
- [ ] Bežeča enota se premika 1.4x hitreje
- [ ] Bežeča enota se premika stran od sovražnika
- [ ] Ko enota pride 20 tile-ov stran — rally attempt
- [ ] Rally horn zvok ob uspešnem rally

#### 3.3 AI Morale (v3.12.157)
- [ ] AI nasprotnik umika ko je njegova morale broken
- [ ] Retreat bell zvok se sliši ob AI retreat
- [ ] Toast notification "Sovražnik se umika!"
- [ ] AI zasleduje bežeče sovražnikove enote

#### 3.4 Spacing System (v3.12.160)
- [ ] Toggle anti-clustering debug (Command Palette → "anti-clustering")
- [ ] Green circles se prikazujejo nad bojujočimi enotami
- [ ] Enote se ne prekrivajo v boju
- [ ] Spacing statistike v Performance Dashboard

#### 3.5 Formations
- [ ] Trenutna formacija se prikazuje v Performance Dashboard
- [ ] Cycle formacij (Ctrl+G) deluje
- [ ] Defense bonus se prikazuje
- [ ] Attack bonus se prikazuje
- [ ] Formation Bonus (+3/tick morale) se aplicira ko v formaciji

### Faza 4: Performance (30 min)

#### 4.1 LOD System (v3.12.165)
- [ ] Toggle LOD debug (Command Palette → "LOD debug")
- [ ] Green krog = HIGH, Yellow = MED, Orange = LOW, Red = OFF
- [ ] Spawn 100+ enot in preveri da se LOD prilagaja
- [ ] Auto-scaling thresholds delujejo (glej Performance Dashboard)
- [ ] FPS ostane > 30 z 100+ enotami

#### 4.2 Performance Dashboard (v3.12.166)
- [ ] Odpri (Ctrl+Shift+I → PERFORMANCE tab)
- [ ] FPS prikazan z barvno kodiranjem
- [ ] Memory (MB) prikazan
- [ ] Vsi 5 sekcije se prikazujejo:
  - [ ] PERFORMANCE (FPS, memory, enote)
  - [ ] LOD SISTEM (4 leveli + skip counts)
  - [ ] MORALE SISTEM (tracked, fleeing, avg morale)
  - [ ] SPACING SISTEM (processed, repulsions, push)
  - [ ] PROCEDURAL SFX (12 zvokov, sample rate, memory)
  - [ ] FORMACIJA (current, def/atk bonus)

#### 4.3 Procedural SFX (v3.12.163-v3.12.164)
- [ ] Procedural SFX inicializiran = true v dashboard
- [ ] 12 generiranih zvokov
- [ ] Sword hit zvok se sliši ob combat
- [ ] Arrow shoot zvok se sliši ob archer attack
- [ ] Death zvok se sliši ob unit death
- [ ] Toggle UI zvok (F2) izklopi vse UI zvok

### Faza 5: Save/Load (20 min)

#### 5.1 Save
- [ ] Shrani igro (Ctrl+S ali menu)
- [ ] Save datoteka se ustvari brez napak
- [ ] Toast notification o uspehu

#### 5.2 Load (v3.12.167)
- [ ] Naloži shranjeno igro
- [ ] Vira pravilno obnovljena
- [ ] Enota pravilno obnovljene na pozicijah
- [ ] Difficulty pravilno obnovljena
- [ ] Game speed pravilno obnovljena
- [ ] Achievement progress obnovljen
- [ ] Morale bars visibility obnovljena (če je bila ON)
- [ ] Spacing debug visibility obnovljena
- [ ] LOD debug visibility obnovljena

#### 5.3 Auto-save
- [ ] Auto-save deluje vsakih N minut (glej Ctrl+U)
- [ ] Crash backup se ustvari ob nepravilnem izhodu
- [ ] Auto-save overlay prikazuje timer

### Faza 6: UI Polish (30 min)

#### 6.1 Color Theme (v3.12.146)
- [ ] Cycle themes (Ctrl+Shift+J)
- [ ] 6 tem se pravilno prikaže (Zlat/Moder/Zelen/Rdeč/Temno/Vijoličen)
- [ ] Tema se shrani med sejami

#### 6.2 Event Log (v3.12.147)
- [ ] Odpri Event Log (Ctrl+Shift+L)
- [ ] Vsi game events se logirajo
- [ ] 6 kategorij z barvami
- [ ] Filter (1-6 številke) deluje
- [ ] Search deluje
- [ ] Click na entry prikaže detail

#### 6.3 Command Palette (v3.12.149)
- [ ] Odpri (Ctrl+Space)
- [ ] 24 ukazov v 2 kategorijah
- [ ] Search filterira real-time
- [ ] ↑↓ navigacija
- [ ] Enter izvede
- [ ] Click na rezultat izvede

#### 6.4 Unified Settings (v3.12.145)
- [ ] Odpri (Ctrl+Shift+E)
- [ ] 4 zavihki: Igra, UI, Prikaz, Igralec
- [ ] Slider, toggle, dropdown delujejo
- [ ] Reset gumb deluje
- [ ] Search (/ key) deluje

#### 6.5 Keyboard Shortcut Editor (v3.12.144)
- [ ] Odpri (Ctrl+Shift+K)
- [ ] 50+ keybindov prikazanih
- [ ] Click → poslušaj novo tipko
- [ ] Konflikt detection
- [ ] Reset posameznega keybinda
- [ ] Reset ALL
- [ ] Export/Import JSON

### Faza 7: Stress Test (45 min)

#### 7.1 Velike bitke
- [ ] Spawn 50 svojih enot
- [ ] Spawn 50 sovražnikovih enot
- [ ] Zaženi battle
- [ ] FPS ostane > 30 med bitko
- [ ] Morale sistem deluje pravilno z 100+ enotami
- [ ] Spacing deluje (ni prekrivanja)
- [ ] LOD prilagodi thresholds (auto-scaling)

#### 7.2 Long session
- [ ] Igraj 30 minut brez pavze
- [ ] Brez memory leak-a (glej Performance Dashboard memory counter)
- [ ] Brez crash-a
- [ ] Save in load po 30 minutah

#### 7.3 Edge cases
- [ ] Igra z 0 zlata (UI pravilno prikaže)
- [ ] Igra z 0 hrane (enote stradajo)
- [ ] Igra z 200+ enotami (LOD sistem vklopi)
- [ ] Igra z vsemi formacijami (Cycle preko vseh 7)
- [ ] Toggle vseh 6 barvnih tem v eni seji

---

## 🐛 Bug Reporting

### Format poročila

Za vsak bug, pošlji:

```
**Bug naslov**: [kratko]
**Verzija**: v3.12.168 (glej glavni meni)
**OS**: Windows/macOS/Linux + verzija
**Koraki do reprodukcije**:
1. ...
2. ...
3. ...
**Pričakoval**: ...
**Dobil**: ...
**Screenshot**: (če relevantno)
**Console output**: (če je bila napaka v konzoli, prilepi)
```

### Kritičnost

| Nivo | Opis | Odzivni čas |
|------|------|-------------|
| 🔴 Blocker | Igra crash-a, nemogoče nadaljevati | 24h |
| 🟠 Major | Glavna funkcionalnost ne deluje | 48h |
| 🟡 Minor | Manjša funkcionalnost, workaround obstaja | 1 teden |
| 🟢 Cosmetic | Vizualna napaka, ne vpliva na gameplay | 2 tedna |

### Kje poročati

- **GitHub Issues**: https://github.com/markec12345678/castlekingdoms2027/issues
- **Email**: (dodaj kontakt za beta test)

---

## ✅ Acceptance Criteria

Beta test je uspešen če:

- [ ] 0 blocker bugov
- [ ] < 5 major bugov
- [ ] < 20 minor bugov
- [ ] FPS > 30 v vseh test scenarijih
- [ ] Save/Load deluje v 100% primerih
- [ ] Vsi 7 faz testiranja končani
- [ ] vsaj 3 testiranci končali celoten checklist

---

## 📊 Test Matrix

Za vsako kombinacijo OS × jezik × težavnost:

| OS | Jezik | Težavnost | Testirano |
|----|-------|-----------|-----------|
| Windows 10 | ENG | Normal | ☐ |
| Windows 11 | SLV | Hard | ☐ |
| macOS 12 | ENG | Brutal | ☐ |
| macOS 13 | DEU | Peaceful | ☐ |
| Ubuntu 22.04 | SLV | Normal | ☐ |
| Ubuntu 24.04 | FRA | Easy | ☐ |

(Napolni za vsako kombinacijo)

---

## 🎯 Naslednji koraki po beta testu

1. Zberi vse bug reporte
2. Razvrsti po prioriteti (blocker → major → minor → cosmetic)
3. Popravi blockerje in majorje (v3.12.169+)
4. Drugi krog beta testiranja (s popravki)
5. Pripravi release candidate (v3.13.0)
6. Steam/GOG upload

---

**Generirano**: 2026-08-23
**Verzija**: v3.12.169
**Skupaj testov**: ~150
**Predviden čas testiranja**: ~4 ure na testiranca
