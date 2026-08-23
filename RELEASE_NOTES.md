# Castle Kingdoms 2027 — Release Notes

> Zgodovina izdaj projekta. Vsak release vsebuje povzetek novih funkcij,
> popravkov in znanih težav.
>
> GitHub: https://github.com/markec12345678/castlekingdoms2027/releases

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
