# Castle Kingdoms 2027 — Release Notes

> Zgodovina izdaj projekta. Vsak release vsebuje povzetek novih funkcij,
> popravkov in znanih težav.
>
> GitHub: https://github.com/markec12345678/castlekingdoms2027/releases

---

## 🚀 v3.13.0-rc1 — Release Candidate 1 (2026-08-23)

**Prvi release candidate za v3.13.0 final.**

### 📊 Statistika RC1

| Metrika | Vrednost |
|---------|----------|
| Verzij v seji | 83 (v3.12.149 → v3.12.231) |
| Novih vrstic kode | ~9300+ |
| Novih sistemov | 11 |
| Pravih PNG assets | 239 |
| .love paket | 135 MB |
| Lua datotek | 1672 |
| PNG assetov | 1953 |
| Tag-ov | 7 |
| Sintaktičnih napak | 0 |

### 🎨 Asset sistemi (vsi končani!)

| Asset | Resolution | Count | Status |
|-------|-----------|-------|--------|
| Tier 1 Sprites | 256×256 | 50/50 | ✅ 100% |
| Tier 2 Sprites | 128×128 | 100/100 | ✅ 100% |
| Tier 3 Procedural | 64×64 | 840/840 | ✅ 100% |
| HD Terrain | 256×256 | 12/12 | ✅ 100% |
| HD Buildings | 256×256 | 50/50 | ✅ 100% |
| HD Units | 128×128 | 20/20 | ✅ 100% |
| Loading Screen | 1152×864 | 1/1 | ✅ |
| Main Menu BG | 1152×864 | 1/1 | ✅ |
| HD UI Icons | 64×64 | 7 | 🔄 |
| **Skupno** | | **239 PNG** | **~100%** |

### ✨ Novi sistemi (11)

1. **Combat Morale System** (v3.12.156-v3.12.161) — 7 stress virov, 6 rally virov, 5-stopinjski damage mult, AI integracija, anti-clustering, formation bonus
2. **Procedural SFX** (v3.12.163-v3.12.164) — 12 combat zvokov iz waveform-ov, brez audio datotek
3. **Performance LOD System** (v3.12.165) — 4 LOD leveli, auto-scaling, ~50% update reduction
4. **Performance Dashboard** (v3.12.166) — real-time stats za 5 sistemov
5. **Royal Icon Generator + Asset Override** (v3.12.152-v3.12.154) — procedural ikone za 990 sistemov + PNG fallback
6. **HD Terrain Override** (v3.12.207-v3.12.210) — 12 biome, overlay draw
7. **HD Building Override** (v3.12.212) — 50 zgradb, lazy load
8. **HD Unit Override** (v3.12.226) — 20 enot, lazy load
9. **Beta Test Checklist** (v3.12.169) — ~150 testov v 7 fazah
10. **Auto-build Pipeline** (v3.12.170-v3.12.175) — avtomatizirana build skripta
11. **Save/Load Enhancement** (v3.12.167) — visibility persisted za vse nove sisteme

### 🎮 Kako testirati RC1

1. Prenesi `castlekingdoms2027-v3.13.0-rc1.love` (135 MB)
2. Namesti LÖVE 11.5 iz https://love2d.org
3. Zaženi: `love castlekingdoms2027-v3.13.0-rc1.love`
4. Sledi `BETA_TEST_CHECKLIST.md` (~150 testov)

### 📦 Build info

- **Verzija**: v3.13.0-rc1
- **Commit**: 363686cb
- **.love**: 135 MB (1672 Lua, 1953 PNG)
- **LÖVE**: 11.5
- **Tag**: `v3.13.0-rc1`

### 7 tag-ov na GitHub

1. `v3.12.171-beta` — prvi beta
2. `v3.12.184-tier1-complete` — Tier 1 = 50/50
3. `v3.12.205-tier2-complete` — Tier 2 = 100/100
4. `v3.12.211-hd-terrain-complete` — HD Terrain = 12/12
5. `v3.12.223-hd-buildings-complete` — HD Buildings = 50/50
6. `v3.12.229-hd-units-complete` — HD Units = 20/20
7. `v3.13.0-rc1` — Release Candidate 1

---

## 🏰 v3.12.171-beta — First Beta Release (2026-08-23)

**Prvi release candidate za zunanje beta testiranje.**

### 📊 Statistika

| Metrika | Vrednost |
|---------|----------|
| Verzij v tej seji | 23 (v3.12.149 → v3.12.171) |
| Novih vrstic kode | ~5500 |
| Novih sistemov | 11 |
| Novih dokumentov | 4 |
| Skupne Lua datoteke | 1669 |
| Skupni PNG asseti | 1712 |
| .love paket velikost | 94 MB |
| Sintaktičnih napak | 0 |

### ✨ Novi sistemi

#### Combat Polish komplet (v3.12.156-v3.12.162)

- **Combat Morale System** — vsaka enota ima morale 0-100, ko pade pod 25
  enota lahko pobegne. 7 virov stresa (smrt zaveznika, nizek HP,
  preštevilčnost, obkoljenost...), 6 virov rally (zdravljenje, kill,
  Lord v bližini...). 5 stopenj damage multiplier.
- **Combat Morale AI Integration** — AI upošteva morale v 4 prioritetah:
  retreat če lastne enote bežijo, pursuit če sovražnik beži, defense-only
  če morale shaken, nižji threshold za napad če sovražnik wavering.
- **Performance optimizacija z spatial hash** — O(N*M) → O(N) za neighbor
  queries. ~2.2x speedup pri 100+ enotah.
- **Combat Retreat Order** — bežeče enote se dejansko premikajo stran od
  sovražnika z 1.4x speed boost. Avtomatski rally ko enota pride 20 tile-ov
  stran.
- **Combat Anti-Clustering System** — soft repulsion force preprečuje
  prekrivanje enot v boju. Spatial hash grid z 3-tile cell.
- **Formation Bonus integracija** — RALLY_FORMATION_BONUS (+3/tick) ko je
  enota v formacijski koheziji (2+ zavezniki v 4-tile radiju).

#### Audio & Performance (v3.12.163-v3.12.165)

- **Procedural Combat SFX** — 12 combat zvokov generiranih proceduralno
  iz waveform-ov (sine, square, noise). Brez zunanjih audio datotek.
  Vključuje: sword_swing, sword_hit, shield_block, arrow_shoot,
  arrow_hit, death_male, death_female, flee_scream, rally_horn,
  morale_break, cavalry_hooves, retreat_bell.
- **SFX integracija z Morale System** — flee_scream + morale_break ob
  begu, rally_horn ob Lord rally, retreat_bell ob AI retreat.
- **Performance LOD System** — 4 LOD leveli (HIGH/MED/LOW/OFF) z
  auto-scaling thresholds glede na število enot. ~50% update reduction
  pri 200+ enotah.

#### Beta Testing Infrastructure (v3.12.166-v3.12.168)

- **Performance & Combat Dashboard** — nov PERFORMANCE zavihek v
  Statistics Panel (Ctrl+Shift+I). Real-time stats za 5 sistemov:
  LOD/Morale/Spacing/SFX/Formacija.
- **Save/Load Enhancement** — visibility persisted za MoraleState,
  SpacingSystem, LODSystem. Kritičen per-unit cache reset ob loadu.
- **POLISH_PLAN.md posodobljen** — 4 nove postavke označene kot ✅ končane.

#### Beta Testing Documentation (v3.12.169-v3.12.171)

- **Beta Test Checklist** — ~150 testov v 7 fazah (osnovno/economy/
  combat/performance/save-load/UI/stress). Bug reporting format,
  acceptance criteria, test matrix.
- **.love build skripta** — avtomatizirana bash skripta z 6 fazami
  (pre-flight, LFS, syntax validation, build, verify, info). Testirana:
  94MB paket, 1669 Lua, 1712 PNG.
- **Modding API documentation** — razširjen MODDING_API.md z novim
  "Combat Systems API" section-om. 5 API-jev, 5 popolnih primerov modov.

### 🎨 Asset System (v3.12.151-v3.12.155)

- **Asset Priority Plan** — analiza 869 Royal sistemov, kategorizacija
  v 28 domenskih skupin, 4-fazni implementacijski plan.
- **Royal Icon Generator** — procedural Lua modul (~470 vrstic) ki
  generira 64×64 canvas ikone za 990 sistemov z 28 barvnimi kategorijami
  in 25+ dekorativnimi elementi.
- **Asset Override System** — modul samodejno uporabi PNG iz
  `assets/royal_systems/tier1/` če obstaja, sicer procedural fallback.
  Brezkodna integracija pravih sprite-ev.
- **HD Sprite Pack Guide** — 335 vrstic dokumentacije z AI-generacija
  prompt predlogami za vseh 50 Tier 1 sistemov.

### 📚 Dokumentacija sinhronizirana (v3.12.150)

- ROADMAP.md, NEXT_BATCH_HANDOFF.md, PROJECT_SUMMARY.md, KEYBINDS.md,
  README.md, CHANGELOG.md vsi posodobljeni na v3.12.149.

### 🎮 Kako testirati

1. Prenesi `castlekingdoms2027-v3.12.170.love` iz GitHub Releases
2. Namesti LÖVE 11.5 iz https://love2d.org
3. Zaženi: `love castlekingdoms2027-v3.12.170.love`
4. Sledi `BETA_TEST_CHECKLIST.md` (~150 testov)

### 🐛 Reportiranje bugov

- **GitHub Issues**: https://github.com/markec12345678/castlekingdoms2027/issues
- **Format**: Glej `BETA_TEST_CHECKLIST.md` sekcija "Bug Reporting"
- **Kritičnost**: Blocker (24h) / Major (48h) / Minor (1 teden) / Cosmetic (2 tedna)

### ✅ Acceptance criteria za uspešno beta

- 0 blocker bugov
- < 5 major bugov
- < 20 minor bugov
- FPS > 30 v vseh test scenarijih
- Save/Load deluje v 100% primerih
- Vsi 7 faz testiranja končani

### 📦 Build info

- **Verzija**: v3.12.171-beta
- **Commit**: 61bc7b6d
- **Datum**: 2026-08-23
- **Lua datoteke**: 1669
- **PNG asseti**: 1712
- **Velikost .love**: 94 MB
- **LÖVE**: 11.5

### 🗺️ Naslednji koraki po beta testu

1. Zberi vse bug reporte
2. Razvrsti po prioriteti (blocker → major → minor → cosmetic)
3. Popravi blockerje in majorje (v3.12.172+)
4. Drugi krog beta testiranja (s popravki)
5. Pripravi release candidate (v3.13.0)
6. Steam/GOG upload

---

## 📜 Prejšnji release-i

Za zgodovino prejšnjih izdaj glej [CHANGELOG.md](CHANGELOG.md).

---

**Hvala vsem beta testerjem!** 🎮

Vaši povratne informacije bodo pomagale oblikovati končno verzijo
Castle Kingdoms 2027.
