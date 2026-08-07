-- terrain/Maps/Hastings.lua
-- Castle Kingdoms 2027 - Map: Hastings (1066)
-- Historical battlefield where William the Conqueror defeated King Harold.
-- Rolling hills with strategic high ground for the Saxon shield wall.

local Map = {}

Map.name = "Hastings"
Map.nameSlv = "Hastings"
Map.description = "The legendary battlefield of 1066. Rolling hills with strategic high ground."
Map.descriptionSlv = "Legendarno bojišče leta 1066. Valoviti hribi s strateško višino."

Map.size = {
    width = 192,
    height = 192,
}

Map.terrain = {
    -- Predominantly grass with some dirt paths
    baseType = "grass",
    features = {
        { type = "hill", x = 96, y = 80, radius = 20, height = 15 },  -- Senlac Hill (Saxon position)
        { type = "forest", x = 30, y = 30, radius = 15 },
        { type = "forest", x = 160, y = 40, radius = 12 },
        { type = "forest", x = 50, y = 160, radius = 18 },
        { type = "river", x = 0, y = 100, width = 192, height = 3 },  -- Shallow stream
    },
}

Map.startingPositions = {
    { x = 40, y = 140, faction = 1 },   -- Player (Norman, south)
    { x = 96, y = 80, faction = 2 },    -- AI (Saxon, on hill)
}

Map.resources = {
    wood = { { x = 35, y = 35 }, { x = 155, y = 45 }, { x = 55, y = 155 } },
    stone = { { x = 120, y = 130 }, { x = 60, y = 110 } },
    iron = { { x = 140, y = 100 }, { x = 80, y = 50 } },
}

Map.aiConfig = {
    personality = "defensive",  -- Saxon shield wall was defensive
    difficulty = "hard",
    startingUnits = { Spearman = 10, Archer = 5, Maceman = 5 },
    startingBuildings = { "Keep" },
}

Map.historicalNote = "The Battle of Hastings (Oct 14, 1066) was fought on Senlac Hill. Harold's Saxon shield wall held for hours until William's feigned retreat broke their formation."

return Map
