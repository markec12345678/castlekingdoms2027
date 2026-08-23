-- objects/Environment/TerrainTextureOverride.lua
-- Castle Kingdoms 2027 v3.12.207 - HD Terrain Texture Override System
--
-- Allows HD terrain textures to be loaded from assets/terrain/hd/
-- without modifying terrain.lua. Falls back to original tileset if
-- HD texture is not found.
--
-- Design:
--   * Lookup: assets/terrain/hd/<biome>.png
--   * Each HD texture is 256x256 (4x the original 64x64 tile)
--   * Cached after first load
--   * Toggle with F7 (HD render pipeline already exists, this extends it)
--
-- Biomes supported (from terrain.lua _G.terrainBiome):
--   abundant_grass, dirt, scarce_grass, yellow_grass, orange_grass,
--   pitch_grass, mountain_grass_b, beach, sea_deep, sea_beach,
--   sea_walkable, land_stones_1_white_rock
--
-- Public API:
--   TerrainOverride.init()                 - preload all HD textures
--   TerrainOverride.get(biome)             - get HD Image or nil
--   TerrainOverride.has(biome)             - check if HD exists
--   TerrainOverride.toggle()               - toggle HD on/off
--   TerrainOverride.isEnabled()            - check if HD enabled
--   TerrainOverride.getStats()             - debug info

local TerrainOverride = {}

-- Cache: biome → love.Image (or nil if not found)
local textureCache = {}

-- Cache: biome → true (checked, not found — avoid re-checking disk)
local checkedCache = {}

-- HD enabled state (default: false, enable with F7 or toggle)
local HD_ENABLED = false
local VISIBILITY_FILE = "terrain_hd_enabled.txt"

-- HD texture directory
local HD_DIR = "assets/terrain/hd"

-- HD texture size (256x256 = 4x original 64x64)
local HD_SIZE = 256

-- All supported biomes (matching terrain.lua _G.terrainBiome)
local BIOMES = {
    "abundant_grass",
    "dirt",
    "scarce_grass",
    "yellow_grass",
    "orange_grass",
    "pitch_grass",
    "mountain_grass_b",
    "beach",
    "sea_deep",
    "sea_beach",
    "sea_walkable",
    "land_stones_1_white_rock",
}

-- ============================================================
-- Persistence
-- ============================================================

local function loadVisibility()
    local ok, content = pcall(love.filesystem.read, VISIBILITY_FILE)
    if ok and content then
        content = content:gsub("%s+$", "")
        if content == "1" or content == "true" then
            HD_ENABLED = true
        end
    end
end

local function saveVisibility()
    pcall(love.filesystem.write, VISIBILITY_FILE, HD_ENABLED and "1" or "0")
end

loadVisibility()

-- ============================================================
-- Public API
-- ============================================================

-- Try to load HD texture for a biome
-- @param biome string Biome name (e.g. "abundant_grass")
-- @return love.Image or nil if not found
function TerrainOverride.get(biome)
    if not biome then return nil end
    if not HD_ENABLED then return nil end

    -- Already checked?
    if checkedCache[biome] then
        return textureCache[biome]
    end
    checkedCache[biome] = true

    -- Try to load from HD directory
    local path = HD_DIR .. "/" .. biome .. ".png"
    local ok, imageData = pcall(love.image.newImageData, path)
    if ok and imageData then
        local ok2, image = pcall(love.graphics.newImage, imageData)
        if ok2 and image then
            image:setFilter("linear", "linear")
            textureCache[biome] = image
            return image
        end
    end

    -- Not found — return nil (terrain.lua will use original tileset)
    return nil
end

-- Check if HD texture exists for a biome
-- @param biome string
-- @return boolean
function TerrainOverride.has(biome)
    if not biome then return false end
    if checkedCache[biome] then
        return textureCache[biome] ~= nil
    end
    -- Force check
    local result = TerrainOverride.get(biome)
    return result ~= nil
end

-- Preload all HD textures
function TerrainOverride.init()
    local count = 0
    for _, biome in ipairs(BIOMES) do
        local tex = TerrainOverride.get(biome)
        if tex then
            count = count + 1
        end
    end
    print(string.format("[TerrainOverride] Initialized (%d HD textures loaded)", count))
    return count
end

-- Toggle HD on/off
function TerrainOverride.toggle()
    HD_ENABLED = not HD_ENABLED
    saveVisibility()
    if HD_ENABLED then
        -- Preload textures
        TerrainOverride.init()
    end
    if _G.NotificationCenter then
        pcall(function()
            _G.NotificationCenter.system("HD Terrain: " .. (HD_ENABLED and "VKLOPLJEN" or "IZKLOPLJEN"))
        end)
    end
    if _G.UISoundHelper then
        pcall(function() _G.UISoundHelper.playToggleOn() end)
    end
end

function TerrainOverride.isEnabled()
    return HD_ENABLED
end

function TerrainOverride.setEnabled(state)
    HD_ENABLED = state and true or false
    saveVisibility()
end

-- Get HD texture size
function TerrainOverride.getHDSize()
    return HD_SIZE
end

-- Get all biomes
function TerrainOverride.getBiomes()
    return BIOMES
end

-- Get list of biomes that have HD textures
function TerrainOverride.getAvailableHD()
    local available = {}
    for _, biome in ipairs(BIOMES) do
        if TerrainOverride.has(biome) then
            table.insert(available, biome)
        end
    end
    return available
end

-- Get stats for debugging
function TerrainOverride.getStats()
    local loadedCount = 0
    local availableCount = 0
    for _, biome in ipairs(BIOMES) do
        if checkedCache[biome] then
            if textureCache[biome] then
                loadedCount = loadedCount + 1
                availableCount = availableCount + 1
            end
        end
    end
    return {
        hdEnabled = HD_ENABLED,
        totalBiomes = #BIOMES,
        loadedTextures = loadedCount,
        availableTextures = availableCount,
        hdDir = HD_DIR,
        hdSize = HD_SIZE,
    }
end

-- Reset (clear cache)
function TerrainOverride.reset()
    for biome, image in pairs(textureCache) do
        if image and image.release then
            pcall(function() image:release() end)
        end
    end
    textureCache = {}
    checkedCache = {}
end

return TerrainOverride
