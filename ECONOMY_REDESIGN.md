# Stronghold 2027 - Economy Redesign

> Predlog izboljšav ekonomskega sistema za bolj zanimivo in uravnoteženo igro.

Zadnja posodobitev: 2026-08-01

---

## 📊 Trenutno stanje

### Surovine
- **Gold** - valuta za trgovino in rekrutacijo
- **Wood** - gradbeni material
- **Stone** - gradbeni material (napredne zgradbe)
- **Wheat** - pridelek za moko
- **Iron** - za orožje in oklep
- **Flour** - predelana pšenica
- **Hops** - za ale
- **Ale** - pijača za popularnost
- **Pitch** - za ogenj/obrambo
- **Food** (kruh, meso, sir, jabolka) - za prehrano prebivalstva

### Zgradbe (ekonomske)
- Woodcutter, Quarry, IronMine, PitchRig - surovine
- WheatFarm, Orchard, DairyFarm, HopsFarm, HunterHut - hrana
- Windmill, Bakery, Brewery, Inn - predelava
- Stockpile, Granary, Armoury - shranjevanje
- Market - trgovina

---

## 🎯 Cilji redesigna

1. **Globja ekonomija** - več strateških odločitev
2. **Trgovina z nihajočimi cenami** - dinamika
3. **Proizvodne verige** - medsebojna odvisnost
4. **Ravnovesje zgradb** - vsaka uporabna
5. **Težavnost** - postopna rast

---

## 💰 Novi sistem cen

### Proizvodne zgradbe (cena)

| Zgradba | Wood | Stone | Gold | Čas gradnje |
|---------|------|-------|------|-------------|
| Woodcutter Hut | 5 | 0 | 0 | 5s |
| Quarry | 15 | 0 | 0 | 10s |
| Iron Mine | 20 | 5 | 0 | 15s |
| Pitch Rig | 25 | 0 | 0 | 15s |
| Wheat Farm | 15 | 0 | 0 | 10s |
| Orchard | 20 | 0 | 0 | 10s |
| Dairy Farm | 20 | 5 | 0 | 12s |
| Hops Farm | 20 | 5 | 0 | 12s |
| Hunter's Hut | 10 | 0 | 0 | 8s |
| Windmill | 30 | 10 | 0 | 20s |
| Bakery | 25 | 10 | 0 | 20s |
| Brewery | 30 | 10 | 0 | 25s |
| Inn | 40 | 20 | 0 | 30s |
| Stockpile | 10 | 0 | 0 | 5s |
| Granary | 30 | 5 | 0 | 15s |
| Armoury | 25 | 15 | 0 | 20s |
| Market | 30 | 15 | 50 | 30s |
| Fletcher Workshop | 20 | 5 | 0 | 15s |
| Poleturner Workshop | 20 | 5 | 0 | 15s |
| Blacksmith Workshop | 25 | 10 | 0 | 20s |
| Armorer Workshop | 25 | 15 | 0 | 25s |

### Proizvodne stopnje (na minuto)

| Zgradba | Proizvaja | Količina/min | Opomba |
|---------|-----------|--------------|--------|
| Woodcutter | Wood | 12 | Odvisno od dreves v bližini |
| Quarry | Stone | 8 | Odvisno od kamna v bližini |
| Iron Mine | Iron | 5 | Omejena zaloga |
| Pitch Rig | Pitch | 4 | Samo v močvirjih |
| Wheat Farm | Wheat | 10 | Odvisno od plodnosti |
| Orchard | Apples | 8 | |
| Dairy Farm | Cheese | 6 | |
| Hops Farm | Hops | 8 | |
| Hunter's Hut | Meat | 5 | Omejeno z divjačino |
| Windmill | Flour | 8 (iz 10 wheat) | 80% učinkovitost |
| Bakery | Bread | 6 (iz 8 flour) | 75% učinkovitost |
| Brewery | Ale | 5 (iz 8 hops) | 63% učinkovitost |
| Fletcher | Bows/Crossbows | 3 | 2 wood = 1 bow |
| Poleturner | Spears/Pikes | 3 | 2 wood = 1 spear |
| Blacksmith | Swords/Maces | 2 | 2 iron = 1 sword |
| Armorer | Armor | 2 | 3 iron = 1 armor |

---

## 📈 Dinamične cene (Market)

### Osnovne cene

| Surovina | Nakup | Prodaja |
|----------|-------|---------|
| Wood | 5 | 3 |
| Stone | 8 | 5 |
| Iron | 15 | 10 |
| Wheat | 4 | 2 |
| Flour | 8 | 5 |
| Hops | 6 | 4 |
| Ale | 12 | 8 |
| Pitch | 20 | 15 |
| Bread | 10 | 7 |
| Apples | 6 | 4 |
| Cheese | 12 | 8 |
| Meat | 15 | 10 |

### Nihajoče cene (nov sistem)

Cene se spreminjajo glede na:

1. **Supply/Demand** - če veliko prodajaš, cena pade
2. **Letni časi** - pšenica pozimi dražja
3. **Slaba letina** - random event, cene hrane +50%
4. **Lakota** - če zmanjka hrane v regiji, cene rastejo
5. **Inflacija** - če preveč zlata v krogu, cene rastejo

### Implementacija

```lua
-- PriceModifier za vsako surovino
local priceModifier = {
    base = 1.0,
    supply = 1.0,    -- 0.5-1.5 glede na zalogo
    season = 1.0,    -- 0.8-1.2 glede na letni čas
    event = 1.0,     -- 1.0-1.5 za random events
    inflation = 1.0, -- raste s količino zlata v igri
}

local finalPrice = basePrice * priceModifier.base * priceModifier.supply *
                   priceModifier.season * priceModifier.event * priceModifier.inflation
```

---

## 🏭 Proizvodne verige

### Veriga za kruh
```
Wheat Farm → Wheat → Windmill → Flour → Bakery → Bread → Granary
```

### Veriga za ale
```
Hops Farm → Hops → Brewery → Ale → Inn → Popularnost +
```

### Veriga za orožje
```
Iron Mine → Iron → Blacksmith → Sword/Mace → Armoury → Barracks
Woodcutter → Wood → Fletcher → Bow/Crossbow → Armoury → Barracks
Woodcutter → Wood → Poleturner → Spear/Pike → Armoury → Barracks
Iron Mine → Iron → Armorer → Armor → Armoury → Barracks
```

### Veriga za obrambo
```
Pitch Rig → Pitch → Engineer → Molotov → Defense Tower
Quarry → Stone → Mason → Wall/Tower → Defense
```

---

## ⚖️ Ravnovesje zgradb

### Trenutno (neuravnoteženo)
- Nekatere zgradbe so neuporabne (Apothecary, Stable)
- Premalo razlik med zgradbami iste kategorije

### Novo ravnovesje

| Kategorija | Zgradba | Prednost | Slabost |
|-----------|---------|----------|---------|
| House | Hovel | Cenitev (5 wood) | Samo 4 prebivalci |
| House | Flat | Srednje (20 wood) | 8 prebivalcev |
| House | Residence | Drago (40 wood, 10 stone) | 12 prebivalcev |
| House | Big Residence | Zelo drago | 16 prebivalcev, +popularnost |
| Tower | Wooden Tower | Cenit | Šibak |
| Tower | Perimeter Tower | Opazovalni | Samo lokostrelci |
| Tower | Defense Tower | Srednje | +1 enota |
| Tower | Square Tower | Drago | +2 enoti, war machines |
| Tower | Round Tower | Zelo drago | +3 enote, najmočnejši |

---

## 🌍 Trgovina z AI nasprotniki

### Nov sistem karavan

1. **Lokalni trg** - trenutni Market (zgradba v tvojem gradu)
2. **Mednarodni trg** - pošlji karavano k sosedu
3. **Piratski napadi** - karavane so lahko napadene

### Implementacija

```lua
-- Karavana
{
    from = "player_keep",
    to = "ai_faction_2_keep",
    goods = { wood = 50 },
    payment = 250,  -- gold
    escort = { "Knight", "Archer" },  -- protection
    travelTime = 60,  -- seconds
    riskLevel = 0.1,  -- 10% chance of pirate attack
}
```

---

## 📉 Davčni sistem (poglobljen)

### Trenutno
- 9 stopenj davka
- Statifno (spremeniš in ostane)

### Nov sistem

1. **Progressive tax** - višji dohodek = višji davek
2. **Tax holidays** - začasno znižanje za popularnost
3. **Tax collectors** - potrebuješ zgradbo za višje stopnje
4. **Tax evasion** - nezadovoljni prebivalci ne plačajo

---

## 🎲 Random events (ekonomske)

| Event | Verjetnost | Učinek |
|-------|-----------|--------|
| Bumper harvest | 5%/leto | +50% crop yield |
| Blight | 3%/leto | -50% crop yield |
| Gold rush | 1%/leto | +500 gold |
| Plague | 2%/leto | -10% population |
| Trade boom | 5%/leto | +20% trade prices |
| Trade bust | 5%/leto | -20% trade prices |
| Mild winter | 10%/leto | -20% food consumption |
| Harsh winter | 5%/leto | +30% food consumption |

---

## 📊 Metrici za spremljanje ravnovesja

| Metric | Cilj |
|--------|------|
| Čas do prvih 100 gold | 2-5 minut |
| Čas do prvih 5 vojakov | 5-10 minut |
| Čas do kamnite trdnjave | 15-25 minut |
| Čas do 100 prebivalcev | 20-30 minut |
| Ravnovesje gold/wood/stone | Približno 3:2:1 |

---

## 🚀 Implementacija

### Faza 1 (1 teden)
- Posodobiti cene v `objects/Enums/goodsPrices.lua`
- Dodati proizvodne stopnje v zgradbe
- Implementirati supply/demand v Market

### Faza 2 (2 tedna)
- Dodati letne čase in vpliv na cene
- Implementirati random events
- Dodati karavane za mednarodno trgovino

### Faza 3 (1 teden)
- Progressive tax sistem
- Tax evasion mehanika
- Balansiranje (playtesting)

---

Ta redesign bo naredil ekonomijo bolj zanimivo in dinamično, kar bo povečalo replayability in strateško globino igre.
