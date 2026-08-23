# Castle Kingdoms 2027 - Modding API

> Ta dokument opisuje modding API za Castle Kingdoms 2027. Modding API omogoča ustvarjanje lastnih modov, ki razširjajo igro z novimi zgradbami, enotami, viri, ali spremenijo obstoječe obnašanje.

Zadnja posodobitev: 2026-08-23 (v3.12.171)
Verzija API: 0.2.0 (alpha)

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

## ⚔️ Combat Systems API (v3.12.156-v3.12.165)

Nove combat sisteme lahko modderji uporabljajo za:
- Spremljanje morale posameznih enot
- SprožanjeAoE rally efektov
- Proceduralno generacijo zvokov
- Performance monitoring
- LOD-level based optimizations

### 🎖️ MoraleSystem API (v3.12.156-v3.12.159)

Dostop preko `_G.MoraleSystem`. Vsi klici so safe (pcall zaščiteni).

#### Pridobivanje morale

```lua
-- Pridobi morale posamezne enote (0-100)
local morale = _G.MoraleSystem.getMorale(someUnit)
print(string.format("Enota ima %.1f/100 morale", morale))

-- Preveri ali enota beži
if _G.MoraleSystem.isFleeing(someUnit) then
    print("Enota beži!")
end

-- Damage multiplier (uporablja se v CombatComponent)
local dmgMult = _G.MoraleSystem.getDamageMultiplier(someUnit)
-- dmgMult je 0-1: 1.0 = full damage, 0.0 = fleeing
```

#### Spreminjanje morale

```lua
-- Apply stress (zmanjšaj morale)
-- @param amount: negativno število (npr. -10)
-- @param source: "death", "outnumbered", "flanked", "low_hp", "ally_fleeing"
_G.MoraleSystem.applyStress(someUnit, -10, "custom_event")

-- Apply rally (povečaj morale)
-- @param amount: pozitivno število (npr. +5)
-- @param source: "heal", "kill", "lord", "ally_density", "out_of_combat", "formation"
_G.MoraleSystem.applyRally(someUnit, +5, "custom_rally")
```

#### AoE Rally (Lord ability)

```lua
-- Rally vse zaveznike v radius-u
-- @param x, y: center pozicija (world tile koordinate)
-- @param radius: v tile-ih (npr. 10)
-- @param amount: koliko morale dodati (default +25)
local affected = _G.MoraleSystem.rallyNearbyUnits(gx, gy, 10, 25)
print(string.format("Rally: %d enot okrepčenih", affected))
```

#### UI/HUD

```lua
-- Toggle prikaz morale barov
_G.MoraleSystem.toggle()

-- Set visibility directly
_G.MoraleSystem.setVisible(true)

-- Preveri ali so bars vidni
local visible = _G.MoraleSystem.isVisible()
```

#### Stats (za debug panel)

```lua
local stats = _G.MoraleSystem.getStats()
-- stats.trackedUnits - število sledenih enot
-- stats.fleeingUnits - število bežečih
-- stats.averageMorale - povprečna morale (0-100)
-- stats.gridCells - število spatial hash celic
-- stats.gridDirty - ali se grid rebuild-a naslednji tick
-- stats.tickRate - update interval (0.5s)
-- stats.visible - ali so bars vidni
```

#### Primer moda: Rally Banner

```lua
-- Mod ki postavi banner ki daje +5 morale/s vsem zaveznikom v 5-tile radiju

function onLoad()
    -- Registriraj periodic check
    ModLoader.registerTick(function(dt)
        if not _G.state then return end
        -- Najdi vse bannere (custom building)
        for _, obj in ipairs(_G.state.gameObjectList) do
            if obj.className == "RallyBanner" then
                -- Apply rally vsem zaveznikom v radiju
                _G.MoraleSystem.rallyNearbyUnits(obj.gx, obj.gy, 5, 5 * dt)
            end
        end
    end)
end
```

### 🔄 SpacingSystem API (v3.12.160)

Dostop preko `_G.SpacingSystem`. Anti-clustering sistem za enote v boju.

```lua
-- Toggle debug vizualizacijo (prikaz spacing radiusov)
_G.SpacingSystem.toggle()

-- Set visibility
_G.SpacingSystem.setVisible(true)

-- Force grid rebuild (če mod dodaja/odstranjuje enote)
_G.SpacingSystem.markGridDirty()

-- Stats
local stats = _G.SpacingSystem.getStats()
-- stats.unitsProcessed - število obdelanih enot ta frame
-- stats.repulsionsApplied - število aplikacij repulzije
-- stats.avgPushPerUnit - povprečni push (float)
-- stats.gridCells - število celic v spatial hash
-- stats.minSpacingAllies - minimal spacing za zaveznike (1.2 tile)
-- stats.minSpacingEnemies - minimal spacing za sovražnike (1.0 tile)
```

### 📊 LODSystem API (v3.12.165)

Dostop preko `_G.LODSystem`. Performance optimizacija z Level of Detail.

```lua
-- Preveri LOD level enote
local lod = _G.LODSystem.getLOD(someUnit)
-- LOD_HIGH = 0 (popoln detail)
-- LOD_MED  = 1 (zmanjšano)
-- LOD_LOW  = 2 (minimalno)
-- LOD_OFF  = 3 (izven ekrana)

local lodName = _G.LODSystem.getLODName(lod)
-- Vrne "HIGH", "MED", "LOW", ali "OFF"

-- Preveri ali naj se enota update-a ta frame
if _G.LODSystem.shouldUpdate(someUnit) then
    -- Update custom logiko
end

-- Preveri ali naj se animira
if _G.LODSystem.shouldAnimate(someUnit) then
    -- Update animacije
end

-- Preveri ali naj se riše
if _G.LODSystem.shouldDraw(someUnit) then
    -- Draw custom vizual
end

-- Toggle debug vizualizacijo (krogovi nad enotami)
_G.LODSystem.toggle()

-- Force grid dirty (če mod premika enote)
_G.LODSystem.markGridDirty()

-- Stats
local stats = _G.LODSystem.getStats()
-- stats.totalUnits - skupno enot
-- stats.lodHigh/Med/Low/Off - število v vsakem LOD
-- stats.skippedUpdates/Animations/Draws - kumulativno
-- stats.visible - ali je debug vklopljen
-- stats.frameCounter - trenutni frame
```

#### Primer moda: Custom particle sistem z LOD

```lua
-- Mod ki izpusti particle effect ob smrti enote, ampak samo za HIGH LOD

function onUnitDeath(unit)
    if not _G.LODSystem then return end

    -- Samo za enote z HIGH LOD (blizu kamere)
    if _G.LODSystem.getLOD(unit) ~= _G.LODSystem.LOD_HIGH then
        return  -- Skip particle effect za oddaljene enote
    end

    -- Spawn particle effect
    spawnDeathParticles(unit.gx, unit.gy)
end
```

### 🔊 ProceduralSFX API (v3.12.163-v3.12.164)

Dostop preko `_G.ProceduralSFX`. Generira zvokove proceduralno brez audio datotek.

```lua
-- Predvajaj zvok po imenu
-- @param name: "sword_swing", "sword_hit", "shield_block", "arrow_shoot",
--              "arrow_hit", "death_male", "death_female", "flee_scream",
--              "rally_horn", "morale_break", "cavalry_hooves", "retreat_bell"
-- @param gx, gy: world pozicija (za 3D audio, optional)
-- @param volume: 0-1 (optional, default 1)
_G.ProceduralSFX.play("sword_hit", unit.gx, unit.gy, 0.8)

-- Preveri ali zvok obstaja
if _G.ProceduralSFX.has("rally_horn") then
    _G.ProceduralSFX.play("rally_horn")
end

-- Pridobi love.Source direktno (za custom playback)
local source = _G.ProceduralSFX.getSound("death_male")
if source then
    source:setLooping(true)
    source:play()
end

-- Pridobi seznam vseh zvokov
local sounds = _G.ProceduralSFX.getSoundNames()
for _, name in ipairs(sounds) do
    print("  - " .. name)
end

-- Stats
local stats = _G.ProceduralSFX.getStats()
-- stats.soundCount - število generiranih zvokov (12)
-- stats.sampleRate - 44100 Hz
-- stats.estimatedMemoryKB - ~440 KB
-- stats.initialized - ali je init() uspešno končan

-- Reset (re-generira vse zvokove)
_G.ProceduralSFX.reset()
```

#### Primer moda: Custom unit z zvokom

```lua
-- Mod ki doda novo enoto (Battle Mage) z custom zvokom

local BattleMage = {}
function BattleMage:onAttack(target)
    -- Use procedural sword_hit zvok
    if _G.ProceduralSFX then
        _G.ProceduralSFX.play("sword_hit", self.gx, self.gy, 0.7)
    end

    -- Apply stress to target (fear effect)
    if _G.MoraleSystem then
        _G.MoraleSystem.applyStress(target, -8, "magical_fear")
    end

    -- Apply self rally (confidence)
    if _G.MoraleSystem then
        _G.MoraleSystem.applyRally(self, 3, "magical_confidence")
    end
end
```

### 🛡️ FormationSystem API (v3.12.161)

Dostop preko `_G.FormationSystem`.

```lua
-- Preveri ali je enota v formacijski koheziji
if _G.FormationSystem.isUnitInFormation(unit) then
    -- Unit dobi +3/tick morale bonus (auto-aplicirano v MoraleSystem)
    print("Unit je v formaciji")
end

-- Pridobi trenutno formacijo
local formName = _G.FormationSystem.getCurrentFormationName()
-- Vrne "Line", "Column", "Wedge", "Scatter", "Box", "Phalanx", "Skirmish"

-- Defense/Attack bonusi
local defBonus = _G.FormationSystem.getDefenseBonus()  -- npr. 1.2 (20% bonus)
local atkBonus = _G.FormationSystem.getAttackBonus()   -- npr. 1.0 (no bonus)
local spdBonus = _G.FormationSystem.getSpeedBonus()    -- npr. 0.9 (10% slower)

-- Spremeni formacijo
_G.FormationSystem.setFormation("phalanx")

-- Cycle skozi formacije
local next = _G.FormationSystem.cycleFormation()
```

### 📈 Performance Dashboard integracija (v3.12.166)

Mods lahko dodajo svoje statistike v PERFORMANCE tab:

```lua
-- Registriraj custom stats callback
if _G.PerformanceDashboard and _G.PerformanceDashboard.registerStats then
    _G.PerformanceDashboard.registerStats("MyMod", function()
        return {
            { label = "Active effects", value = tostring(myModActiveCount), color = {0.4, 0.85, 0.4} },
            { label = "Memory usage", value = string.format("%.1f KB", myModMemory), color = {0.7, 0.8, 0.9} },
        }
    end)
end
```

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
