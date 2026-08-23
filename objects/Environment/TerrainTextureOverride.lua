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

-- ============================================================
-- v3.12.210: Overlay draw system
-- Draws HD textures over existing terrain when HD is enabled.
-- Called from game.lua draw() after terrain is rendered.
-- ============================================================

-- Draw HD terrain overlay for visible tiles
-- This is a lightweight overlay: it draws HD textures on top of
-- the existing terrain tiles, replacing the visual without modifying
-- terrain.lua's internal tile assignment system.
function TerrainOverride.draw()
    if not HD_ENABLED then return end
    if not _G.state or not _G.state.gameObjectList then return end
    if not _G.state.map or not _G.state.map.terrainTile then return end
    if not _G.IsoToScreenX or not _G.IsoToScreenY then return end

    local tileW = _G.tileWidth or 64
    local tileH = _G.tileHeight or 32
    local viewX = _G.state.viewXview or 0
    local viewY = _G.state.viewYview or 0
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    -- Iterate over terrain tiles in visible area
    -- We check a reasonable range of chunks around the camera
    local cx = _G.currentChunkX or 0
    local cy = _G.currentChunkY or 0
    local chunkW = _G.chunkWidth or 16

    -- Check nearby chunks (3x3 around current)
    for dcx = -1, 1 do
        for dcy = -1, 1 do
            local checkCx = cx + dcx
            local checkCy = cy + dcy
            local chunkTiles = _G.state.map.terrainTile[checkCx]
            if chunkTiles then
                local cyTiles = chunkTiles[checkCy]
                if cyTiles then
                    for i = 0, chunkW - 1 do
                        local iTiles = cyTiles[i]
                        if iTiles then
                            for o = 0, chunkW - 1 do
                                local tile = iTiles[o]
                                if tile and tile[1] then
                                    -- tile = { quad, screenX, screenY, rotation, scaleX, scaleY }
                                    local screenX = tile[2] - viewX
                                    local screenY = tile[3] - viewY

                                    -- Cull tiles outside screen bounds
                                    if screenX > -HD_SIZE and screenX < screenW + HD_SIZE and
                                       screenY > -HD_SIZE and screenY < screenH + HD_SIZE then

                                        -- Determine biome for this tile
                                        -- The biome is stored in _G.state.map.terrain
                                        local biome = nil
                                        if _G.state.map.terrain and _G.state.map.terrain[checkCx] and
                                           _G.state.map.terrain[checkCx][checkCy] and
                                           _G.state.map.terrain[checkCx][checkCy][i] and
                                           _G.state.map.terrain[checkCx][checkCy][i][o] then
                                            biome = _G.state.map.terrain[checkCx][checkCy][i][o]
                                        end

                                        if biome then
                                            local hdTexture = TerrainOverride.get(biome)
                                            if hdTexture then
                                                -- Draw HD texture centered on tile position
                                                -- Scale to match tile size (HD_SIZE → tileW)
                                                local scaleX = tileW / HD_SIZE
                                                local scaleY = tileH / HD_SIZE
                                                love.graphics.setColor(1, 1, 1, 1)
                                                love.graphics.draw(hdTexture, screenX, screenY, 0, scaleX, scaleY)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

return TerrainOverride
