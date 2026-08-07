-- terrain/Maps/MapRegistry.lua
-- Castle Kingdoms 2027 v2.5.1 - Map Registry
-- Central registry of all available maps for campaign and skirmish.

local MapRegistry = {}

-- All available maps
local MAPS = {
    {
        key = "fernhaven",
        name = "Fernhaven",
        nameSlv = "Fernhaven",
        file = "terrain.Maps.Fernhaven",
        type = "campaign",
        era = "Fernhaven Saga",
        description = "The starting land of Sir Aldric's journey.",
        maxPlayers = 2,
    },
    {
        key = "hastings",
        name = "Hastings",
        nameSlv = "Hastings",
        file = "terrain.Maps.Hastings",
        type = "campaign",
        era = "Norman Conquest",
        description = "The legendary battlefield of 1066.",
        maxPlayers = 2,
    },
    {
        key = "london",
        name = "London",
        nameSlv = "London",
        file = "terrain.Maps.London",
        type = "campaign",
        era = "Norman Conquest",
        description = "Medieval London along the Thames.",
        maxPlayers = 2,
    },
    {
        key = "yorkshire",
        name = "Yorkshire",
        nameSlv = "Yorkshire",
        file = "terrain.Maps.Yorkshire",
        type = "campaign",
        era = "Norman Conquest",
        description = "The war-torn north of 1069.",
        maxPlayers = 3,
    },
    {
        key = "welsh_borders",
        name = "Welsh Borders",
        nameSlv = "Valižanska meja",
        file = "terrain.Maps.WelshBorders",
        type = "campaign",
        era = "Norman Conquest",
        description = "Mountainous frontier with Wales.",
        maxPlayers = 2,
    },
    {
        key = "rouen",
        name = "Rouen",
        nameSlv = "Rouen",
        file = "terrain.Maps.Rouen",
        type = "campaign",
        era = "Norman Conquest",
        description = "Norman capital under siege, 1087.",
        maxPlayers = 4,
    },
}

function MapRegistry.init()
    print("[MapRegistry] Initialized with " .. #MAPS .. " maps")
end

function MapRegistry.getAllMaps()
    return MAPS
end

function MapRegistry.getMap(key)
    for _, m in ipairs(MAPS) do
        if m.key == key then return m end
    end
    return nil
end

function MapRegistry.getMapsByEra(era)
    local result = {}
    for _, m in ipairs(MAPS) do
        if m.era == era then
            table.insert(result, m)
        end
    end
    return result
end

function MapRegistry.getMapCount()
    return #MAPS
end

return MapRegistry
