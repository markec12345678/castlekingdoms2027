-- terrain/Maps/London.lua
-- Castle Kingdoms 2027 - Map: London (1066)
-- Medieval London with the Thames river. Site of William's coronation.

local Map = {}

Map.name = "London"
Map.nameSlv = "London"
Map.description = "Medieval London along the Thames. Build the Tower and secure the city."
Map.descriptionSlv = "Srednjeveški London ob Temzi. Zgradi Tower in zavaruj mesto."

Map.size = { width = 192, height = 192 }

Map.terrain = {
    baseType = "grass",
    features = {
        { type = "river", x = 0, y = 100, width = 192, height = 8 },  -- Thames
        { type = "bridge", x = 80, y = 100, width = 6, height = 8 },
        { type = "bridge", x = 120, y = 100, width = 6, height = 8 },
        { type = "forest", x = 20, y = 20, radius = 15 },
        { type = "forest", x = 170, y = 170, radius = 20 },
        { type = "hill", x = 100, y = 60, radius = 10, height = 8 },
    },
}

Map.startingPositions = {
    { x = 100, y = 60, faction = 1 },   -- Player (north of Thames)
    { x = 100, y = 150, faction = 2 },  -- AI (south of Thames)
}

Map.resources = {
    wood = { { x = 25, y = 25 }, { x = 175, y = 175 } },
    stone = { { x = 90, y = 40 }, { x = 110, y = 40 } },
    iron = { { x = 150, y = 50 }, { x = 50, y = 150 } },
}

Map.aiConfig = {
    personality = "balanced",
    difficulty = "medium",
    startingUnits = { Spearman = 5, Archer = 3 },
    startingBuildings = { "Keep", "Barracks" },
}

Map.historicalNote = "London was the largest city in England in 1066. William was crowned at Westminster Abbey on Christmas Day. The Tower of London was begun in 1078."

return Map
