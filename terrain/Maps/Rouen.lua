-- terrain/Maps/Rouen.lua
-- Castle Kingdoms 2027 - Map: Rouen (1087)
-- Capital of Normandy, site of William's death. Final defense mission.

local Map = {}

Map.name = "Rouen"
Map.nameSlv = "Rouen"
Map.description = "Norman capital under siege. Defend William's ancestral homeland."
Map.descriptionSlv = "Normanska prestolnica pod obleganjem. Brani Viljemovo domovino prednikov."

Map.size = { width = 192, height = 192 }

Map.terrain = {
    baseType = "grass",
    features = {
        { type = "river", x = 0, y = 100, width = 192, height = 6 },  -- Seine
        { type = "bridge", x = 90, y = 100, width = 6, height = 6 },
        { type = "hill", x = 96, y = 70, radius = 15, height = 12 },  -- Castle hill
        { type = "forest", x = 25, y = 25, radius = 18 },
        { type = "forest", x = 170, y = 30, radius = 15 },
        { type = "forest", x = 30, y = 170, radius = 14 },
        { type = "forest", x = 165, y = 160, radius = 16 },
    },
}

Map.startingPositions = {
    { x = 96, y = 70, faction = 1 },    -- Player (on castle hill, north of Seine)
    { x = 96, y = 160, faction = 2 },   -- AI (French, south)
    { x = 30, y = 120, faction = 3 },   -- AI 2 (French flanking)
    { x = 160, y = 120, faction = 4 },  -- AI 3 (French flanking)
}

Map.resources = {
    wood = { { x = 30, y = 30 }, { x = 175, y = 35 }, { x = 35, y = 175 }, { x = 165, y = 165 } },
    stone = { { x = 85, y = 60 }, { x = 110, y = 60 } },
    iron = { { x = 140, y = 80 }, { x = 60, y = 80 } },
}

Map.aiConfig = {
    personality = "aggressive",
    difficulty = "nightmare",
    startingUnits = { Knight = 10, Crossbowman = 8, Spearman = 5 },
    startingBuildings = { "Keep", "Barracks", "StoneBarracks" },
}

Map.historicalNote = "Rouen was the capital of the Duchy of Normandy. William died here on September 9, 1087, after being wounded during the burning of Mantes. His tomb is at Caen."

return Map
