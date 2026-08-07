-- terrain/Maps/Yorkshire.lua
-- Castle Kingdoms 2027 - Map: Yorkshire (1069)
-- Devastated northern England during the Harrying of the North.

local Map = {}

Map.name = "Yorkshire"
Map.nameSlv = "Yorkshire"
Map.description = "The war-torn north. Burned villages and harsh winter terrain."
Map.descriptionSlv = "Razdravljena severna Anglija. Požgane vasi in ostro zimsko teren."

Map.size = { width = 192, height = 192 }

Map.terrain = {
    baseType = "dirt",  -- Devastated land
    features = {
        { type = "forest", x = 40, y = 40, radius = 12 },
        { type = "forest", x = 150, y = 30, radius = 10 },
        { type = "forest", x = 160, y = 160, radius = 15 },
        { type = "hill", x = 100, y = 100, radius = 25, height = 20 },  -- York hill
        { type = "river", x = 50, y = 0, width = 4, height = 192 },  -- Ouse river
        { type = "snow", x = 0, y = 0, width = 192, height = 60 },  -- Snow in north
    },
}

Map.startingPositions = {
    { x = 90, y = 100, faction = 1 },   -- Player (at York)
    { x = 30, y = 160, faction = 2 },   -- AI (rebel stronghold)
    { x = 160, y = 40, faction = 3 },   -- AI 2 (Danish invaders)
}

Map.resources = {
    wood = { { x = 45, y = 45 }, { x = 155, y = 35 }, { x = 165, y = 165 } },
    stone = { { x = 110, y = 110 }, { x = 95, y = 120 } },
    iron = { { x = 140, y = 130 }, { x = 70, y = 90 } },
}

Map.aiConfig = {
    personality = "aggressive",
    difficulty = "hard",
    startingUnits = { Spearman = 8, Archer = 4, Maceman = 3 },
    startingBuildings = { "Keep", "Barracks" },
}

Map.historicalNote = "The Harrying of the North (1069-70) devastated Yorkshire. William burned villages, slaughtered livestock, and salted fields. 100,000 people starved."

return Map
