# Castle Kingdoms 2027 — Demo Build Guide

How to create a demo version for Steam Next Fest or press coverage.

## Demo vs Full Version

| Feature | Demo | Full |
|---------|------|------|
| Campaign missions | 3 (of 10) | 10 |
| Skirmish trail | 3 (of 10) | 10 |
| Freebuild | ✓ | ✓ |
| Multiplayer | ✗ | ✓ (8 players) |
| Map editor | ✓ (save disabled) | ✓ |
| Mod loading | ✓ | ✓ |
| Playtime limit | 60 minutes | Unlimited |
| Save/load | ✗ | ✓ |

## Creating the Demo Build

### Step 1: Set demo flag
In `main.lua`, add at the top:
```lua
_G.isDemo = true
```

### Step 2: Mission restrictions
In `objects/Mission/MissionFramework.lua`, add:
```lua
if _G.isDemo and missionNumber > 3 then
    ModernUI.notifyError("Demo: samo 3 misije. Kupi polno verzijo!")
    return false
end
```

### Step 3: Skirmish restrictions
In `objects/Mission/SkirmishTrailSystem.lua`, add:
```lua
if _G.isDemo and missionId > 3 then
    ModernUI.notifyError("Demo: samo 3 skirmish misije.")
    return false
end
```

### Step 4: Multiplayer disabled
In `states/ui/multiplayer/lobby.lua`, add:
```lua
if _G.isDemo then
    ModernUI.notifyError("Multiplayer je na voljo v polni verziji.")
    return
end
```

### Step 5: Playtime limit
In `states/game.lua`, add to update:
```lua
if _G.isDemo then
    if not _G._demoTimer then _G._demoTimer = 0 end
    _G._demoTimer = _G._demoTimer + dt
    if _G._demoTimer > 3600 then  -- 60 minutes
        ModernUI.notifyInfo("Demo cas je potekel. Hvala za igranje!")
        love.event.quit()
    end
end
```

### Step 6: Demo watermark
In `states/game.lua` draw function:
```lua
if _G.isDemo then
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.print("DEMO", 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end
```

### Step 7: Build demo .love
```bash
# Set demo flag
echo "_G.isDemo = true" >> main.lua

# Build
zip -r castlekingdoms2027-demo.love . -x ".git/*"

# Remove demo flag from main.lua (for full build)
# (use git checkout to restore)
```

## Demo Distribution

- Upload to Steam as separate demo app
- Include in Steam Next Fest
- Share with press/content creators
- File size: ~305 MB (same as full, but features restricted)
- No time bomb needed (60-min limit is in-game)

## Converting Demo to Full

When player purchases the full game:
1. Demo save data is preserved (if save was enabled)
2. Full version unlocks all missions, multiplayer, saves
3. Demo timer removed
4. No need to re-download (same .love file, just different flag)
