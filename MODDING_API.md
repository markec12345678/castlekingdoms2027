# Castle Kingdoms 2027 - Modding API

> Ta dokument opisuje modding API za Castle Kingdoms 2027. Modding API omogoča ustvarjanje lastnih modov, ki razširjajo igro z novimi zgradbami, enotami, viri, ali spremenijo obstoječe obnašanje.

Zadnja posodobitev: 2026-08-01
Verzija API: 0.1.0 (alpha)

---

## 🚀 Hitri začetek

### 1. Ustvari mod

```bash
cd mods/
cp -r example_mod my_first_mod
cd my_first_mod
```

### 2. Uredi `mod.lua`

```lua
name = "My First Mod"
version = "1.0.0"
author = "Your Name"
description = "What does this mod do?"

function onLoad()
    print("My mod loaded!")
end
```

### 3. Zaženi igro

```bash
love .
```

Mod se bo samodejno naložil ob zagonu igre.

---

## 📁 Struktura moda

```
mods/my_mod/
├── mod.lua              # Required - metadata in entry point
├── assets/              # Optional - mod-specific assets
│   ├── icons/
│   ├── buildings/
│   └── units/
├── locale/              # Optional - translations
│   ├── en.yaml
│   └── sl.yaml
└── scripts/             # Optional - additional Lua scripts
    ├── buildings/
    └── units/
```

---

## 📜 Mod.lua format

### Obvezna polja

| Polje | Tip | Opis |
|-------|-----|------|
| `name` | string | Prikazno ime moda |
| `version` | string | Verzija (semver) |
| `author` | string | Avtor moda |
| `description` | string | Kratek opis |

### Opcijska polja

| Polje | Tip | Opis |
|-------|-----|------|
| `dependencies` | table | Seznam drugih modov, ki so potrebni |
| `onLoad` | function | Klicano ob nalaganju moda |
| `onUnload` | function | Klicano ob razbremenitvi moda |
| `onTick(dt)` | function | Klicano vsak frame |
| `onBuildingPlaced(building)` | function | Klicano ko je zgradba postavljena |
| `onUnitRecruited(unit)` | function | Klicano ko je enota rekrutirana |

### Primer

```lua
name = "Medieval Warfare Expansion"
version = "2.1.0"
author = "Janez Novak"
description = "Adds 5 new military units and 3 siege weapons"

dependencies = {
    -- ["core_combat"] = "1.0.0"  -- zahteva drug mod
}

function onLoad()
    print("Medieval Warfare loaded!")
end

function onTick(dt)
    -- logika, ki se izvaja vsak frame
end

function onBuildingPlaced(building)
    if building.class.name == "Barracks" then
        print("New barracks placed!")
    end
end
```

---

## 🎣 Hooks (dogodki)

Modding API uporablja hook sistem za komunikacijo z glavno igro.

### Razpoložljivi hook-i

| Hook | Parametri | Kdaj se sproži |
|------|-----------|----------------|
| `onLoad` | () | Mod je naložen |
| `onUnload` | () | Mod je razbremenjen |
| `onTick` | (dt) | Vsak frame (dt = delta time) |
| `onBuildingPlaced` | (building) | Ko igralec postavi zgradbo |
| `onUnitRecruited` | (unit) | Ko igralec rekrutira enoto |

### Načrtovani hook-i (v prihodnjih verzijah)

- `onResourceGathered(resource, amount)`
- `onCombatStart(attacker, defender)`
- `onCombatEnd(winner, loser)`
- `onMissionStart(missionId)`
- `onMissionComplete(missionId, success)`
- `onSaveGame(filename)`
- `onLoadGame(filename)`

---

## 🔧 Mod API funkcije

Ko je mod naložen, ima dostop do naslednjih globalnih funkcij:

### Game state

```lua
-- Dostop do game state
local state = _G.state

-- Dostop do virov
local gold = _G.state.gold
local wood = _G.state.wood

-- Dostop do trenutnega zemljevida
local map = _G.state.map
local isWalkable = map:isWalkable(gx, gy)
```

### Spawn entitet

```lua
-- Spawn enote (ko bo API podprt)
local Unit = require("objects.Units.Archer")
local archer = Archer:new(gx, gy, factionIndex)
```

### UI integracija

```lua
-- Dodaj gumb v UI (ko bo API podprt)
-- (v pripravi)
```

---

## 📦 Distribucija modov

### Pakiranje

```bash
cd mods/my_mod/
zip -r my_mod_v1.0.0.zip .
```

### Namestitev

Uporabnik kopira zip v `mods/` direktorij in ga razpakira:

```bash
cd mods/
unzip my_mod_v1.0.0.zip -d my_mod/
```

---

## 🛡️ Varnost

Modding API je **sandboxed** - modi nimajo dostopa do:
- Datotečnega sistema izven igre
- Omrežnih povezav
- Sistemskega okolja

Vsi API klici so validirani. Napake v modih ne crash-ajo igre.

---

## 📞 Podpora

- **GitHub Issues:** [github.com/markec12345678/castlekingdoms2027/issues](https://github.com/markec12345678/castlekingdoms2027/issues)
- **Modding wiki:** (v pripravi)
- **Discord:** (v pripravi)

---

## 📜 Licenca

Modi so last njihovih avtorjev. Priporočamo:
- **MIT licenco** za odprtokodne mode
- **CC BY 4.0** za asset-e

Castle Kingdoms 2027 ne prevzema odgovornosti za vsebino modov.

---

## 🗺️ Roadmap modding API

### Verzija 0.1.0 (trenutna)
- ✅ Osnovna struktura modov
- ✅ Lifecycle hook-i (onLoad, onUnload, onTick)
- ✅ Event hook-i (onBuildingPlaced, onUnitRecruited)
- ✅ Mod discovery in loading

### Verzija 0.2.0 (načrtovano)
- ⏳ Mod settings UI
- ⏳ Mod loading order konfiguracija
- ⏳ Conflict resolution sistem

### Verzija 0.3.0 (načrtovano)
- ⏳ Custom resource registration
- ⏳ Custom building registration
- ⏳ Custom unit registration

### Verzija 1.0.0 (načrtovano)
- ⏳ Workshop integration (Steam)
- ⏳ Mod dependency resolver
- ⏳ Hot-reload med razvojem
- ⏳ Mod profiling orodja

---

Hvala, da ustvarjaš mode za Castle Kingdoms 2027! 🎮
