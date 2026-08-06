-- terrain/Maps/WelshBorders.lua
-- Stronghold 2027 - Map: Welsh Borders (1081)
-- Mountainous frontier between England and Wales.

local Map = {}

Map.name = "WelshBorders"
Map.nameSlv = "Valižanska meja"
Map.description = "Rugged mountains and deep valleys. Perfect for guerrilla warfare."
Map.descriptionSlv = "Robovita gorovja in globoke doline. Popolno za gverilsko bojevanje."

Map.size = { width = 192, height = 192 }

Map.terrain = {
    baseType = "stone",
    features = {
        { type = "mountain", x = 60, y = 60, radius = 30, height = 30 },
        { type = "mountain", x = 140, y = 50, radius = 25, height = 25 },
        { type = "mountain", x = 100, y = 140, radius = 35, height = 35 },
        { type = "forest", x = 30, y = 130, radius = 12 },
        { type = "forest", x = 170, y = 150, radius = 10 },
        { type = "river", x = 0, y = 90, width = 192, height = 3 },
    },
}

Map.startingPositions = {
    { x = 30, y = 30, faction = 1 },    -- Player (east, flat land)
    { x = 100, y = 140, faction = 2 },  -- AI (in mountains)
}

Map.resources = {
    wood = { { x = 35, y = 135 }, { x = 175, y = 155 } },
    stone = { { x = 65, y = 65 }, { x = 145, y = 55 } },
    iron = { { x = 105, y = 145 }, { x = 80, y = 80 } },
}

Map.aiConfig = {
    personality = "defensive",  -- Welsh guerrilla tactics
    difficulty = "hard",
    startingUnits = { Archer = 15, Spearman = 3 },  -- Welsh were known archers
    startingBuildings = { "Keep" },
}

Map.historicalNote = "Wales was never fully conquered by William. The mountainous terrain favored Welsh guerrilla tactics. Marcher lordships and castles controlled the border for centuries."

return Map
