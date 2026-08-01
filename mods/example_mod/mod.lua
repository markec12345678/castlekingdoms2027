-- Example Mod for Stronghold 2027
-- This mod demonstrates the basic structure and API
--
-- To enable this mod, rename the directory from 'example_mod' to something else
-- (e.g., 'my_first_mod') and restart the game.

-- Mod metadata (required)
name = "Example Mod"
version = "1.0.0"
author = "Stronghold 2027 Team"
description = "An example mod that demonstrates the modding API. Adds a debug message when buildings are placed."

-- Dependencies (optional)
-- Format: { ["other_mod_name"] = "required_version" }
dependencies = {}

-- Lifecycle hooks (all optional)

-- Called when the mod is first loaded
function onLoad()
    print("[Example Mod] Loaded successfully!")
    print("[Example Mod] This mod adds debug messages when buildings are placed.")
end

-- Called when the mod is unloaded (game exit or mod disabled)
function onUnload()
    print("[Example Mod] Unloading...")
end

-- Called every frame (dt = delta time in seconds)
function onTick(dt)
    -- Example: could track play time, spawn events, etc.
end

-- Called when a building is placed on the map
function onBuildingPlaced(building)
    if building and building.class and building.class.name then
        print(string.format("[Example Mod] Building placed: %s at (%d, %d)",
            building.class.name, building.gx or 0, building.gy or 0))
    end
end

-- Called when a unit is recruited from a barracks
function onUnitRecruited(unit)
    if unit and unit.class and unit.class.name then
        print(string.format("[Example Mod] Unit recruited: %s", unit.class.name))
    end
end

-- Example of how to add custom resource (when API supports it)
-- function registerResources()
--     return {
--         { name = "magic_essence", icon = "magic_essence.png", storage = "stockpile" }
--     }
-- end

-- Example of how to add custom building (when API supports it)
-- function registerBuildings()
--     return {
--         {
--             id = "magic_tower",
--             name = "Magic Tower",
--             cost = { gold = 500, wood = 50, stone = 100 },
--             category = "military",
--             icon = "magic_tower_icon.png",
--             script = "scripts/buildings/magic_tower.lua"
--         }
--     }
-- end
