-- objects/Config/KenneyAssetLoader.lua
-- Stronghold 2027 - Kenney CC0 Asset Loader
--
-- Provides alternative CC0 assets (Kenney.nl) for buildings, units,
-- and UI elements. Allows the game to run WITHOUT Firefly Studios assets.
--
-- All Kenney assets are CC0 (Public Domain) - no attribution required.
-- Source: https://kenney.nl/assets/medieval-rts
--         https://kenney.nl/assets/castle-kit
--
-- Usage:
--   local KenneyLoader = require("objects.Config.KenneyAssetLoader")
--   KenneyLoader.init()
--   local image = KenneyLoader.getBuildingImage("Barracks")
--   local image = KenneyLoader.getUnitImage("Archer")

local KenneyAssetMapping = require("objects.Config.KenneyAssetMapping")

local KenneyAssetLoader = {}

local initialized = false
local enabled = false

-- Cache for loaded images
local imageCache = {}

-- Base paths
local RTS_PATH = "assets/kenney/medieval-rts/PNG/Default size"
local CASTLE_PATH = "assets/kenney/castle-kit/Isometric"

-- Initialize
function KenneyAssetLoader.init()
    if initialized then return end
    initialized = true
    print("[KenneyLoader] Initialized - CC0 assets ready as alternative")
end

-- Enable/disable Kenney assets (vs original Firefly assets)
function KenneyAssetLoader.setEnabled(state)
    enabled = state
    if state then
        -- Clear cache so images are reloaded from Kenney
        imageCache = {}
        print("[KenneyLoader] ENABLED - using CC0 Kenney assets")
    else
        print("[KenneyLoader] DISABLED - using original assets")
    end
end

function KenneyAssetLoader.isEnabled()
    return enabled
end

-- Load an image with caching
local function loadImage(path)
    if imageCache[path] then
        return imageCache[path]
    end

    local ok, image = pcall(love.graphics.newImage, path)
    if ok and image then
        imageCache[path] = image
        return image
    end
    return nil
end

-- === BUILDING IMAGES ===

-- Get a building image (Kenney CC0)
-- @param buildingName string Our building name (e.g., "Barracks")
-- @return Image or nil if not found
function KenneyAssetLoader.getBuildingImage(buildingName)
    local path = KenneyAssetMapping.getBuildingPath(buildingName)
    if not path then return nil end
    return loadImage(path)
end

-- Get building image path
function KenneyAssetLoader.getBuildingPath(buildingName)
    return KenneyAssetMapping.getBuildingPath(buildingName)
end

-- === UNIT IMAGES ===

-- Get a unit image (Kenney CC0)
-- @param unitName string Our unit name (e.g., "Archer")
-- @return Image or nil
function KenneyAssetLoader.getUnitImage(unitName)
    local path = KenneyAssetMapping.getUnitPath(unitName)
    if not path then return nil end
    return loadImage(path)
end

function KenneyAssetLoader.getUnitPath(unitName)
    return KenneyAssetMapping.getUnitPath(unitName)
end

-- === FORTIFICATION IMAGES ===

function KenneyAssetLoader.getFortificationImage(fortName)
    local path = KenneyAssetMapping.getFortificationPath(fortName)
    if not path then return nil end
    return loadImage(path)
end

-- === TERRAIN IMAGES ===

function KenneyAssetLoader.getTerrainImage(terrainName)
    local path = KenneyAssetMapping.getTerrainPath(terrainName)
    if not path then return nil end
    return loadImage(path)
end

-- === ENVIRONMENT IMAGES ===

function KenneyAssetLoader.getEnvironmentImage(envName)
    local path = KenneyAssetMapping.getEnvironmentPath(envName)
    if not path then return nil end
    return loadImage(path)
end

-- === UI ICON GENERATION ===
-- Generate action bar icons from Kenney building images

-- Get action bar icon for a building
-- Returns a Kenney building image that can be used as button icon
function KenneyAssetLoader.getBuildingIcon(buildingName)
    -- Map building names to Kenney structure images
    local iconMap = {
        -- Resource buildings
        Woodcutter      = "Structure/medievalStructure_01.png",
        Quarry          = "Structure/medievalStructure_02.png",
        IronMine        = "Structure/medievalStructure_03.png",
        PitchRig        = "Structure/medievalStructure_04.png",

        -- Farms
        WheatFarm       = "Structure/medievalStructure_05.png",
        Orchard         = "Structure/medievalStructure_06.png",
        DairyFarm       = "Structure/medievalStructure_07.png",
        HopsFarm        = "Structure/medievalStructure_08.png",
        HunterHut       = "Structure/medievalStructure_09.png",

        -- Processing
        Windmill        = "Structure/medievalStructure_10.png",
        Bakery          = "Structure/medievalStructure_11.png",
        Brewery         = "Structure/medievalStructure_12.png",
        Inn             = "Structure/medievalStructure_13.png",

        -- Storage
        Stockpile      = "Structure/medievalStructure_14.png",
        Granary         = "Structure/medievalStructure_15.png",
        Armoury         = "Structure/medievalStructure_16.png",

        -- Military
        Barracks        = "Structure/medievalStructure_17.png",
        StoneBarracks   = "Structure/medievalStructure_18.png",
        EngineersGuild  = "Structure/medievalStructure_19.png",
        TunnelersGuild  = "Structure/medievalStructure_20.png",

        -- Workshops
        Fletcher        = "Structure/medievalStructure_21.png",
        Poleturner      = "Structure/medievalStructure_22.png",
        Blacksmith      = "Structure/medievalStructure_23.png",
        Armorer         = "Structure/medievalStructure_01.png",

        -- Religious
        Chapel          = "Structure/medievalStructure_05.png",
        Church          = "Structure/medievalStructure_10.png",
        Cathedral       = "Structure/medievalStructure_15.png",

        -- Housing
        Hovel           = "Structure/medievalStructure_06.png",
        Flat            = "Structure/medievalStructure_07.png",
        Residence       = "Structure/medievalStructure_08.png",
        BigResidence    = "Structure/medievalStructure_09.png",

        -- Economy
        Market          = "Structure/medievalStructure_13.png",

        -- Keep
        SaxonHall       = "Structure/medievalStructure_14.png",
        WoodenKeep      = "Structure/medievalStructure_16.png",
        Keep            = "Structure/medievalStructure_17.png",
        Fortress        = "Structure/medievalStructure_18.png",
        Stronghold      = "Structure/medievalStructure_19.png",

        -- Fortifications (from Castle Kit)
        WoodenWall      = "wallStud_NE.png",
        WoodenTower     = "towerSquareMid_SW.png",
        SquareTower     = "towerSquareMid_NE.png",
        RoundTower      = "towerRoundMid_NE.png",
        StoneGateSouth  = "wallDoor_NE.png",
        StoneGateEast   = "wallDoor_NW.png",
        StoneWall       = "wallFull_NE.png",

        -- Siege
        Catapult        = "siegeCatapult_SW.png",
        Trebuchet       = "siegeTrebuchet_SW.png",
        SiegeTower      = "siegeTower_N.png",
        Ballista        = "siegeBallista_NW.png",
    }

    local file = iconMap[buildingName]
    if not file then return nil end

    -- Check if it's a castle kit asset
    if file:match("wall") or file:match("tower") or file:match("siege") then
        return loadImage(CASTLE_PATH .. "/" .. file)
    end

    return loadImage(RTS_PATH .. "/" .. file)
end

-- === UNIT ICONS ===

function KenneyAssetLoader.getUnitIcon(unitName)
    local iconMap = {
        Archer      = "Unit/medievalUnit_01.png",
        Crossbowman = "Unit/medievalUnit_02.png",
        Spearman    = "Unit/medievalUnit_03.png",
        Pikeman     = "Unit/medievalUnit_04.png",
        Maceman     = "Unit/medievalUnit_05.png",
        Swordsman   = "Unit/medievalUnit_06.png",
        Knight      = "Unit/medievalUnit_07.png",
        Lord        = "Unit/medievalUnit_08.png",
        Peasant     = "Unit/medievalUnit_09.png",
        Engineer    = "Unit/medievalUnit_10.png",
    }

    local file = iconMap[unitName]
    if not file then return nil end
    return loadImage(RTS_PATH .. "/" .. file)
end

-- === RESOURCE ICONS ===
-- Generate resource icons from Kenney environment assets

function KenneyAssetLoader.getResourceIcon(resourceName)
    local iconMap = {
        wood    = "Environment/medievalEnvironment_09.png",  -- log
        stone   = "Environment/medievalEnvironment_04.png",  -- rock
        iron    = "Environment/medievalEnvironment_05.png",  -- rockLarge
        gold    = "Environment/medievalEnvironment_20.png",  -- chest
        wheat   = "Environment/medievalEnvironment_15.png",  -- hayBale
        food    = "Environment/medievalEnvironment_15.png",  -- hayBale
        ale     = "Environment/medievalEnvironment_10.png",  -- barrel
        tar     = "Environment/medievalEnvironment_10.png",  -- barrel
    }

    local file = iconMap[resourceName]
    if not file then return nil end
    return loadImage(RTS_PATH .. "/" .. file)
end

-- === SPRITE ATLAS ===
-- Create a sprite atlas from all Kenney building images for efficient rendering

local spriteAtlas = nil
local atlasQuads = {}

function KenneyAssetLoader.buildSpriteAtlas()
    if spriteAtlas then return spriteAtlas end

    -- Collect all building images
    local images = {}
    local maxWidth = 0
    local maxHeight = 0
    local totalCount = 0

    for name, _ in pairs(KenneyAssetMapping.buildings) do
        local img = KenneyAssetLoader.getBuildingImage(name)
        if img then
            table.insert(images, { name = name, image = img })
            local w, h = img:getDimensions()
            if w > maxWidth then maxWidth = w end
            if h > maxHeight then maxHeight = h end
            totalCount = totalCount + 1
        end
    end

    if totalCount == 0 then
        print("[KenneyLoader] No images for atlas")
        return nil
    end

    -- Create atlas (grid layout)
    local cols = math.ceil(math.sqrt(totalCount))
    local rows = math.ceil(totalCount / cols)
    local atlasW = cols * maxWidth
    local atlasH = rows * maxHeight

    -- Create canvas
    local canvas = love.graphics.newCanvas(atlasW, atlasH)
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    -- Draw each image
    for i, entry in ipairs(images) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local x = col * maxWidth
        local y = row * maxHeight

        love.graphics.draw(entry.image, x, y)

        -- Store quad
        atlasQuads[entry.name] = love.graphics.newQuad(
            x, y, maxWidth, maxHeight, atlasW, atlasH
        )
    end

    love.graphics.setCanvas()
    spriteAtlas = canvas

    print(string.format("[KenneyLoader] Sprite atlas built: %dx%d (%d buildings)", atlasW, atlasH, totalCount))
    return spriteAtlas
end

-- Get a quad from the sprite atlas
function KenneyAssetLoader.getAtlasQuad(buildingName)
    if not spriteAtlas then
        KenneyAssetLoader.buildSpriteAtlas()
    end
    return atlasQuads[buildingName]
end

-- === STATS ===

function KenneyAssetLoader.getStats()
    local cacheCount = 0
    for _ in pairs(imageCache) do cacheCount = cacheCount + 1 end

    return {
        enabled = enabled,
        cachedImages = cacheCount,
        atlasBuilt = spriteAtlas ~= nil,
        mapping = KenneyAssetMapping.getStats(),
    }
end

-- Clear cache
function KenneyAssetLoader.clearCache()
    imageCache = {}
    spriteAtlas = nil
    atlasQuads = {}
    print("[KenneyLoader] Cache cleared")
end

return KenneyAssetLoader
