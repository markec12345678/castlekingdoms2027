# Analiza znanih težav in strategija popravkov

Datum: 2026-08-01
Veja: `feat/bugfixes`
Stran 1 od 1

---

## Pregled stanja (upstream v0.6.1)

### Kritični bug-i iz GitLab issue tracker-ja (milestone 0.7)

1. **Game crashes when loading saved file with deer herds**
   - Tip: Crash
   - Reproducija: shrani igro z jeleni, naloži
   - Verjetna lokacija: `objects/Herds/` ali `objects/Controllers/HerdController.lua`

2. **Pathfinding: enote gredo skozi zgradbe**
   - Tip: Gameplay
   - Reproducija: postavi zgradbo po tem, ko enota najde pot
   - Verjetna lokacija: `libraries/pathfinding_thread.lua`, `libraries/jumper/`

3. **Stable buildings crash (kamnolom, rudnik)**
   - Tip: Crash
   - Reproducija: različni scenariji
   - Verjetna lokacija: `objects/Structures/Quarry.lua`, `objects/Structures/IronMine.lua`

### TODO/FIXME v kodi (134 skupaj)

| Kategorija | Število | Prioriteta |
|-----------|---------|-----------|
| sounds/music.lua (loadanje iz nastavitev) | 1 | Nizka |
| libraries/ (vključno third-party) | 8 | Nizka |
| states/ui/market_trade.lua (gumbi, zvoki) | 25+ | Srednja |
| states/ui/ActionBarButton.lua (hover zvoki) | 2 | Nizka |
| states/ui/economic/window.lua (misije) | 2 | Srednja |
| states/ui/base.lua (resize update) | 1 | Srednja |
| Ostalo | 95+ | Raznoliko |

### Ključne besedne ugotovitve iz Changelog-a

**Stabilno delujoče (v0.6.1):**
- Gradnja vseh osnovnih zgradb
- Ekonomski sistem (les, kamen, hrana, zlato)
- Vojaške enote (vendar brez bojevanja)
- Pathfinding (z znanimi bug-i)
- Save/Load (z znanimi crash-i)
- Prevodi (9 jezikov + naša slovenščina)

**Nedelujoče/placeholder:**
- Apothecary (lekarna) - "Currently not functional"
- Stable (konjušnica) - "Temporarily not functional"
- Bojevanje (combat) - enote se lahko premikajo, vendar brez bojevanja
- Maypole - "Temporarily disabled"
- Religion popularity bonus - še ni implementiran
- Nivoji nad Stronghold (poslednji keep upgrade)

---

## Strategija popravkov za Stronghold 2027

### Faza A: Kritični crash-i (1-2 tedna)
1. **Load saved game crash** z jeleni
   - Reproducija v testnem okolju
   - Analiza stack trace
   - Fix in `HerdController.lua`

2. **Building placement crash**
   - Testiranje različnih scenarijev
   - Verjetno težava v `BuildController.lua`

### Faza B: Pathfinding (2-3 tedna)
1. **Enote gredo skozi zgradbe**
   - Invalidacija path cache ob postavitvi zgradbe
   - Re-path vseh aktivnih enot

2. **Enote se zatikajo**
   - Bolj robusten A* algorithm
   - Dodat fallback mehanizem

### Faza C: Pripravljenost za bojevanje (1-2 meseca)
- Implementacija combat sistema
- AI nasprotniki
- Oblegovalni stroji

### Faza D: HD grafika (paralelno, 3-6 mesecev)
- Zamenjava vseh PNG asset-ov z 4K verzijami
- Modern UI redesign
- Particle effects, lighting

---

## Konkretni prvi koraki (ta teden)

1. **Setup testnega okolja z X11/VNC** za dejansko testiranje
2. **Reprodukcija "deer herd load crash"** - zapišemo korake
3. **Analiza stack trace** iz Sentry reportov
4. **Pripraviti enote teste** (busted framework že obstaja v repozitoriju)
5. **CI pipeline** - GitHub Actions za avtomatske teste

---

## Določitev prioritet za ekipo (2 osebi)

### Razvijalec 1 (markec12345678)
- Pathfinding bug-i
- Crash fix-i
- Performance optimizacije

### Razvijalec 2
- HD asset creation (GIMP/Photoshop)
- UI redesign
- Testiranje in QA

### Skupno
- Code review vsak pull request
- Slovenski prevod - dodatno poliranje
- Dokumentacija

---

## Metrici za sledenje napredka

| Metric | Trenutno | Cilj (3 meseci) | Cilj (6 mesecev) |
|--------|----------|----------------|------------------|
| Število odprtih bugov | ~50+ | < 20 | < 5 |
| Crash rate na uro igranja | unknown | < 1 | < 0.1 |
| FPS (1080p, modern HW) | ~30-60 | 60+ | 144+ |
| Čas nalaganja | ~5s | < 3s | < 1s |
| Število podprtih jezikov | 10 | 12 | 15+ |
