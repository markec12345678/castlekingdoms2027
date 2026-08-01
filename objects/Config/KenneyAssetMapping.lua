-- objects/Config/KenneyAssetMapping.lua
-- Stronghold 2027 - Kenney CC0 Asset Mapping
--
-- Maps our building/unit names to Kenney Medieval RTS asset filenames.
-- All Kenney assets are CC0 (public domain) - no attribution required.
--
-- Asset source: https://kenney.nl/assets/medieval-rts
--               https://kenney.nl/assets/castle-kit

local KenneyAssetMapping = {}

-- Base path for Kenney assets
local BASE_PATH = "assets/kenney/medieval-rts/PNG/Default size"
local CASTLE_PATH = "assets/kenney/castle-kit/Isometric"

-- === BUILDING MAPPING ===
-- Maps our building names to Kenney structure PNG filenames
KenneyAssetMapping.buildings = {
    -- Resource gathering
    Woodcutter      = { file = "Structure/medievalStructure_01.png", category = "resource" },
    Quarry          = { file = "Structure/medievalStructure_02.png", category = "resource" },
    IronMine        = { file = "Structure/medievalStructure_03.png", category = "resource" },
    PitchRig        = { file = "Structure/medievalStructure_04.png", category = "resource" },

    -- Food production
    WheatFarm       = { file = "Structure/medievalStructure_05.png", category = "food" },
    Orchard         = { file = "Structure/medievalStructure_06.png", category = "food" },
    DairyFarm       = { file = "Structure/medievalStructure_07.png", category = "food" },
    HopsFarm        = { file = "Structure/medievalStructure_08.png", category = "food" },
    HunterHut       = { file = "Structure/medievalStructure_09.png", category = "food" },

    -- Processing
    Windmill        = { file = "Structure/medievalStructure_10.png", category = "processing" },
    Bakery          = { file = "Structure/medievalStructure_11.png", category = "processing" },
    Brewery         = { file = "Structure/medievalStructure_12.png", category = "processing" },
    Inn             = { file = "Structure/medievalStructure_13.png", category = "processing" },

    -- Storage
    Stockpile      = { file = "Structure/medievalStructure_14.png", category = "storage" },
    Granary         = { file = "Structure/medievalStructure_15.png", category = "storage" },
    Armoury         = { file = "Structure/medievalStructure_16.png", category = "storage" },

    -- Military
    Barracks        = { file = "Structure/medievalStructure_17.png", category = "military" },
    StoneBarracks   = { file = "Structure/medievalStructure_18.png", category = "military" },
    EngineersGuild  = { file = "Structure/medievalStructure_19.png", category = "military" },
    TunnelersGuild  = { file = "Structure/medievalStructure_20.png", category = "military" },

    -- Workshops
    Fletcher        = { file = "Structure/medievalStructure_21.png", category = "workshop" },
    Blacksmith      = { file = "Structure/medievalStructure_22.png", category = "workshop" },
    Armorer         = { file = "Structure/medievalStructure_23.png", category = "workshop" },
    Poleturner      = { file = "Structure/medievalStructure_01.png", category = "workshop" }, -- reuse

    -- Religious
    Chapel          = { file = "Structure/medievalStructure_05.png", category = "religious" }, -- reuse
    Church          = { file = "Structure/medievalStructure_10.png", category = "religious" }, -- reuse
    Cathedral       = { file = "Structure/medievalStructure_15.png", category = "religious" }, -- reuse

    -- Housing
    Hovel           = { file = "Structure/medievalStructure_06.png", category = "housing" },
    Flat            = { file = "Structure/medievalStructure_07.png", category = "housing" },
    Residence       = { file = "Structure/medievalStructure_08.png", category = "housing" },
    BigResidence    = { file = "Structure/medievalStructure_09.png", category = "housing" },

    -- Market
    Market          = { file = "Structure/medievalStructure_13.png", category = "economy" },

    -- Keep upgrades
    SaxonHall       = { file = "Structure/medievalStructure_14.png", category = "keep" },
    WoodenKeep      = { file = "Structure/medievalStructure_16.png", category = "keep" },
    Keep            = { file = "Structure/medievalStructure_17.png", category = "keep" },
    Fortress        = { file = "Structure/medievalStructure_18.png", category = "keep" },
    Stronghold      = { file = "Structure/medievalStructure_19.png", category = "keep" },
}

-- === UNIT MAPPING ===
-- Maps our unit names to Kenney unit PNG filenames
KenneyAssetMapping.units = {
    Archer          = { file = "Unit/medievalUnit_01.png" },
    Crossbowman     = { file = "Unit/medievalUnit_02.png" },
    Spearman        = { file = "Unit/medievalUnit_03.png" },
    Pikeman         = { file = "Unit/medievalUnit_04.png" },
    Maceman         = { file = "Unit/medievalUnit_05.png" },
    Swordsman       = { file = "Unit/medievalUnit_06.png" },
    Knight          = { file = "Unit/medievalUnit_07.png" },
    Lord            = { file = "Unit/medievalUnit_08.png" },
    Peasant         = { file = "Unit/medievalUnit_09.png" },
    Engineer        = { file = "Unit/medievalUnit_10.png" },
}

-- === CASTLE/FORTIFICATION MAPPING ===
-- Maps to Kenney Castle Kit (isometric)
KenneyAssetMapping.fortifications = {
    WoodenWall      = { file = "wallStud_NE.png", path = CASTLE_PATH },
    WoodenTower     = { file = "towerSquareMid_SW.png", path = CASTLE_PATH },
    SquareTower     = { file = "towerSquareMid_NE.png", path = CASTLE_PATH },
    RoundTower      = { file = "towerRoundMid_NE.png", path = CASTLE_PATH },
    StoneGateSouth  = { file = "wallDoor_NE.png", path = CASTLE_PATH },
    StoneGateEast   = { file = "wallDoor_NW.png", path = CASTLE_PATH },
    StoneWall       = { file = "wallFull_NE.png", path = CASTLE_PATH },

    -- Siege weapons
    Catapult        = { file = "siegeCatapult_SW.png", path = CASTLE_PATH },
    Trebuchet       = { file = "siegeTrebuchet_SW.png", path = CASTLE_PATH },
    SiegeTower      = { file = "siegeTower_N.png", path = CASTLE_PATH },
    Ballista        = { file = "siegeBallista_NW.png", path = CASTLE_PATH },
}

-- === TERRAIN TILES ===
-- Maps to Kenney Medieval RTS tiles (64x64)
KenneyAssetMapping.terrain = {
    grass           = { file = "Tile/medievalTile_01.png" },
    grassDark       = { file = "Tile/medievalTile_02.png" },
    grassLight      = { file = "Tile/medievalTile_03.png" },
    dirt            = { file = "Tile/medievalTile_04.png" },
    dirtDark        = { file = "Tile/medievalTile_05.png" },
    stone           = { file = "Tile/medievalTile_06.png" },
    stoneDark       = { file = "Tile/medievalTile_07.png" },
    sand            = { file = "Tile/medievalTile_08.png" },
    water           = { file = "Tile/medievalTile_09.png" },
    waterDeep       = { file = "Tile/medievalTile_10.png" },
    snow            = { file = "Tile/medievalTile_11.png" },
    ice             = { file = "Tile/medievalTile_12.png" },
}

-- === ENVIRONMENT DECORATIONS ===
KenneyAssetMapping.environment = {
    tree            = { file = "Environment/medievalEnvironment_01.png" },
    treePine        = { file = "Environment/medievalEnvironment_02.png" },
    treeOak         = { file = "Environment/medievalEnvironment_03.png" },
    rock            = { file = "Environment/medievalEnvironment_04.png" },
    rockLarge       = { file = "Environment/medievalEnvironment_05.png" },
    bush            = { file = "Environment/medievalEnvironment_06.png" },
    flowers         = { file = "Environment/medievalEnvironment_07.png" },
    stump           = { file = "Environment/medievalEnvironment_08.png" },
    log             = { file = "Environment/medievalEnvironment_09.png" },
    barrel          = { file = "Environment/medievalEnvironment_10.png" },
    crate           = { file = "Environment/medievalEnvironment_11.png" },
    flag            = { file = "Environment/medievalEnvironment_12.png" },
    campfire        = { file = "Environment/medievalEnvironment_13.png" },
    torch           = { file = "Environment/medievalEnvironment_14.png" },
    hayBale         = { file = "Environment/medievalEnvironment_15.png" },
    fence           = { file = "Environment/medievalEnvironment_16.png" },
    signpost        = { file = "Environment/medievalEnvironment_17.png" },
    well            = { file = "Environment/medievalEnvironment_18.png" },
    cart            = { file = "Environment/medievalEnvironment_19.png" },
    chest           = { file = "Environment/medievalEnvironment_20.png" },
    banner          = { file = "Environment/medievalEnvironment_21.png" },
}

-- === HELPER FUNCTIONS ===

-- Get full path for a building asset
function KenneyAssetMapping.getBuildingPath(buildingName)
    local mapping = KenneyAssetMapping.buildings[buildingName]
    if not mapping then return nil end
    return BASE_PATH .. "/" .. mapping.file
end

-- Get full path for a unit asset
function KenneyAssetMapping.getUnitPath(unitName)
    local mapping = KenneyAssetMapping.units[unitName]
    if not mapping then return nil end
    return BASE_PATH .. "/" .. mapping.file
end

-- Get full path for a fortification asset
function KenneyAssetMapping.getFortificationPath(fortName)
    local mapping = KenneyAssetMapping.fortifications[fortName]
    if not mapping then return nil end
    local path = mapping.path or CASTLE_PATH
    return path .. "/" .. mapping.file
end

-- Get full path for a terrain tile
function KenneyAssetMapping.getTerrainPath(terrainName)
    local mapping = KenneyAssetMapping.terrain[terrainName]
    if not mapping then return nil end
    return BASE_PATH .. "/" .. mapping.file
end

-- Get full path for an environment asset
function KenneyAssetMapping.getEnvironmentPath(envName)
    local mapping = KenneyAssetMapping.environment[envName]
    if not mapping then return nil end
    return BASE_PATH .. "/" .. mapping.file
end

-- Load an image for a building (with error handling)
function KenneyAssetMapping.loadBuildingImage(buildingName)
    local path = KenneyAssetMapping.getBuildingPath(buildingName)
    if not path then return nil end
    local ok, image = pcall(love.graphics.newImage, path)
    if ok then return image end
    print("[KenneyMapping] Could not load: " .. path)
    return nil
end

-- Load an image for a unit
function KenneyAssetMapping.loadUnitImage(unitName)
    local path = KenneyAssetMapping.getUnitPath(unitName)
    if not path then return nil end
    local ok, image = pcall(love.graphics.newImage, path)
    if ok then return image end
    print("[KenneyMapping] Could not load: " .. path)
    return nil
end

-- Get stats
function KenneyAssetMapping.getStats()
    local buildingCount = 0
    for _ in pairs(KenneyAssetMapping.buildings) do buildingCount = buildingCount + 1 end
    local unitCount = 0
    for _ in pairs(KenneyAssetMapping.units) do unitCount = unitCount + 1 end
    local fortCount = 0
    for _ in pairs(KenneyAssetMapping.fortifications) do fortCount = fortCount + 1 end
    local terrainCount = 0
    for _ in pairs(KenneyAssetMapping.terrain) do terrainCount = terrainCount + 1 end
    local envCount = 0
    for _ in pairs(KenneyAssetMapping.environment) do envCount = envCount + 1 end

    return {
        buildings = buildingCount,
        units = unitCount,
        fortifications = fortCount,
        terrain = terrainCount,
        environment = envCount,
        total = buildingCount + unitCount + fortCount + terrainCount + envCount,
        license = "CC0 (Public Domain)",
        source = "https://kenney.nl/assets/medieval-rts",
    }
end

return KenneyAssetMapping
