# Stronghold 2027 - Combat Integration Guide

> Ta dokument opisuje, kako je combat sistem integriran v igro in kako ga testirati.

Zadnja posodobitev: 2026-08-01
Verzija: 0.7.1-combat-alpha

---

## 🎮 Kako igrati (F8 test scenario)

### Aktivacija

1. **Zaženi igro:** `love .`
2. **Naloži mapo:** Freebuild -> Fernhaven ali Grasslands
3. **Počakaj,** da se mapa naloži (lahko traja 10-30 sekund)
4. **Pritisni F8** za aktivacijo combat test scenarija

### Kaj se zgodi ob aktivaciji

- **3 friendly Knights** se spawnajo blizu tvojega gradu (faction: PLAYER)
- **5 enemy Archers** se spawnajo na razdalji ~20 tile-ov (faction: ENEMY_1)
- **3 enemy Macemen** se spawnajo še nekoliko bližje (faction: ENEMY_2)
- V konzoli se izpišejo pozicije spawn-a

### Kako napadati

1. **Levi klik + drag** - izberi friendly unit-e (kvadrat izbire)
2. **Desni klik na sovražnika** - izdaj ukaz za napad
3. Izbrane enote se bodo premaknile proti sovražniku in napadle

### Auto-Aggro

- Vse enote (tudi sovražne) imajo auto-aggro
- Ko pride sovražnik v range (12 tile-ov), enota samodejno napade
- Archerji streljajo iz distance (range 8)
- Macemen in Knight-i morajo priti blizu (range 1.5)

### Keybindings

| Tipka | Akcija |
|-------|--------|
| **F8** | Toggle combat test scenario (spawn/odstrani enote) |
| **F9** | Izpiši combat statistike v konzolo |
| **F3** | Toggle profiler overlay (FPS, memory) |
| **F4** | Toggle detailed profiler (section timing) |
| **Desni klik** | Premakni izbrane enote ALI napadi sovražnika |

---

## 🏗️ Arhitektura

### Komponente

```
┌─────────────────────────────────────────────────────────────┐
│                    states/game.lua                          │
│  (main game loop - kliče CombatIntegration.update/draw)     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              objects/Combat/CombatIntegration.lua           │
│  (koordinator - povezuje vse combat kontrolerje)             │
└─────┬──────────┬──────────┬──────────┬──────────────────────┘
      │          │          │          │
      ▼          ▼          ▼          ▼
┌───────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐
│ Combat    │ │Projectile│ │   AI     │ │ HealthBar    │
│Controller │ │Controller│ │Controller│ │ Controller   │
│           │ │           │ │          │ │              │
│- damage   │ │- arrows   │ │- aggro   │ │- barve HP    │
│- cooldown │ │- bolts    │ │- retreat │ │- prikaz samo │
│- death    │ │- rocks    │ │- group   │ │  za pošk.    │
└─────┬─────┘ └──────────┘ └──────────┘ └──────────────┘
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│           objects/Combat/CombatComponent.lua                │
│  (mixin - doda combat sposobnosti vsaki Unit)               │
│                                                             │
│  Adds: health, maxHealth, faction, combatState, target,     │
│        attack(), takeDamage(), findNearestEnemy(), die()    │
└─────────────────────────────────────────────────────────────┘
```

### Hook v Commander

`CombatIntegration.hookCommander()` override-a `Commander:mousereleased()`:
- Če desni klik z izbranimi enotami na sovražniku → **attack order**
- Sicer → originalna logika (premakni enote)

### Hook v game loop

V `states/game.lua`:
- `delayedInit()` - kliče `CombatIntegration.init()`
- `game:update(dt)` - kliče `CombatIntegration.update(dt)`
- `game:draw()` - kliče `CombatIntegration.draw()`
- `game:keypressed()` - doda F8 (test) in F9 (stats)

---

## 🎯 Damage Calculation

### Formula

```
actualDamage = baseDamage × (1 - targetArmor) × random(0.9, 1.1)
```

### Primeri

| Napadalec | Žrtev | Base Damage | Armor | Actual Damage (avg) |
|-----------|-------|-------------|-------|---------------------|
| Archer | Archer | 12 | 0.05 | ~11.4 |
| Knight | Maceman | 30 | 0.20 | ~24.0 |
| Crossbowman | Knight | 25 | 0.45 | ~13.75 |
| Maceman | Spearman | 18 | 0.15 | ~15.3 |

### Health Values

| Enota | Health | Armor | Damage | Range |
|-------|--------|-------|--------|-------|
| Archer | 50 | 0.05 | 12 | 8 (medium) |
| Crossbowman | 60 | 0.10 | 25 | 12 (long) |
| Spearman | 70 | 0.15 | 15 | 5 (short) |
| Pikeman | 90 | 0.25 | 20 | 5 (short) |
| Maceman | 100 | 0.20 | 18 | 1.5 (melee) |
| Swordsman | 120 | 0.30 | 22 | 1.5 (melee) |
| Knight | 180 | 0.45 | 30 | 1.5 (melee) |
| Lord | 500 | 0.60 | 50 | 1.5 (melee) |

---

## 🤖 AI Osebnosti

| Osebnost | Aggro Range | Retreate HP | Group Up | Chase Duration |
|----------|-------------|-------------|----------|----------------|
| Aggressive | 15 | 10% | 3+ | 20s |
| Balanced | 12 | 25% | 2+ | 12s |
| Defensive | 8 | 40% | 2+ | 8s |

### Faction Assignment

| Faction | Osebnost |
|---------|----------|
| FACTION_PLAYER | (player-controlled) |
| FACTION_ENEMY_1 | Aggressive |
| FACTION_ENEMY_2 | Balanced |
| FACTION_ENEMY_3 | Defensive |
| FACTION_NEUTRAL | (animals, no combat) |

---

## 🏹 Projectile System

| Tip | Hitrost | Arc Height | Damage | Splash |
|-----|---------|------------|--------|--------|
| Arrow | 10 tiles/s | 2 | 12 | - |
| Bolt | 15 tiles/s | 0.5 | 25 | - |
| Rock | 4 tiles/s | 8 | 100 | 3 tiles radius |

### Visual

- Arrow: majhen rjav krožec (radius 2)
- Bolt: srednji siv krožec (radius 3)
- Rock: velik sivi krožec (radius 6) z arc parabolo

---

## 🧪 Testiranje

### Ročno testiranje

1. **F8 aktivacija** - preveri, da se enote spawnajo
2. **Izbira enot** - levi klik + drag, preveri, da se izberejo
3. **Attack order** - desni klik na sovražnika, preveri, da se enote premaknejo
4. **Auto-aggro** - pusti enemy enote, da se približajo, preveri, da friendly sami napadejo
5. **Damage numbers** - rdeče številke nad enotami
6. **Health bars** - nad poškodovanimi enotami se prikaže barva (zelena/rumena/rdeča)
7. **Projectiles** - archerji streljajo puščice, ki letijo po paraboli
8. **Death** - ko HP doseže 0, enota umre in izgine
9. **F9 stats** - preveri število napadov, ubijanj, damage

### Test scenariji

#### Scenario A: Knight vs Archer (melee vs ranged)
1. F8 - spawn vse
2. Izberi 3 knight-e
3. Desni klik na enemy archer-ja
4. Knight-i naj tečejo proti archer-ju
5. Archer-ji streljajo puščice
6. Ko knight-i pridejo blizu, napadejo archer-je
7. Preveri, da archer-ji umrejo

#### Scenario B: Auto-aggro (brez ukazov)
1. F8 - spawn vse
2. NE izdajaj ukazov
3. Počakaj, da enemy enote pridejo v range
4. Friendly knight-i naj sami napadejo
5. Preveri, da se bitka začne brez igralčevega posega

#### Scenario C: Retreat
1. F8 - spawn vse
2. Poškoduj friendly knight (konzola: `knight.health = 10`)
3. Preveri, da knight začne bežati
4. Preveri, da se umakne

---

## 🐛 Known Limitations (Faza 2 alpha)

- **Animations:** Trenutno se uporabljajo default walk animacije, attack animacije še niso povezane
- **Sound effects:** Manjkajo combat zvoki (mačevanje, streljanje, kriki)
- **Pathfinding:** Enote lahko obtičijo, če je pot blokirana
- **Group tactics:** AI se še ne zaveda skupine (vsak unit išče svojega najbližjega sovražnika)
- **Building attacks:** Trenutno samo enote napadajo druge enote, ne zgradb
- **Siege weapons:** Catapult še ni povezan z obstoječimi siege unit-i

---

## 📞 Podpora

- **Bug reports:** GitHub Issues
- **Feature requests:** GitHub Issues z `enhancement` label
- **Console commands:** `combat_test()` - aktivira test scenario

---

## 🗺️ Naslednji koraki (Faza 2b)

1. **Attack animacije** - povezati z unit animation sistemom
2. **Sound effects** - dodati combat zvoke
3. **Building attacks** - omogočiti napad na zgradbe
4. **Siege integration** - povezati catapult/trebuchet z ProjectileController
5. **Group tactics** - implementirati formation-based AI
6. **Loot/victory** - dodati reward sistem po bitki
7. **Death animations** - padajoče/počene enote
8. **Combat music** - preklop na bojevno glasbo med bitko
