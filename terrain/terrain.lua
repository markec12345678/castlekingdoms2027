local first_location_x, first_location_y, last_location_x, last_location_y = 0
local location_distance = 0
local angle, first = 0, 0
local ffi = require('ffi')
local tile_quads = require('terrain.terrain_quads')

-- Terrain Initialize
----Rows and columns
local cols = chunk_width
local rows = chunk_height
local chunk_width, chunk_height = _G.chunk_width, _G.chunk_height
local tiles_to_update_in_chunk = _G.newAutotable(4)
local secondary_tiles_to_update_in_chunk = _G.newAutotable(4)
local tertiary_tiles_to_update_in_chunk = _G.newAutotable(4)
local second_chunks_to_update = {}
local chunks_set = newAutotable(2)
----Chunk 2D array
-- Statuses: 
-- [1] loaded unsaved
-- [2] unloaded - chunk exist on hard disk
-- [3] loaded saved - chunk hasn't been changed so no need to save it
-- nil - chunk needs to be generated first

----Generate spriteBatch
local terrain_image = _G.object_image
_G.heightmap = newAutotable(4)
local heightmap = _G.heightmap
local shadowmap = newAutotable(4)
_G.shadowmap = shadowmap
_G.buildingheightmap = newAutotable(4)
local tileheight = _G.buildingheightmap
local terrain_tile = newAutotable(4)
_G.terrain_biome = {
    ["abundant_grass"] = "abundant_grass",
    ["dirt"] = "dirt",
    ["none"] = "none",
    ["scarce_grass"] = "scarce_grass",
    ["yellow_grass"] = "yellow_grass",
    ["orange_grass"] = "orange_grass",
    ["pitch_grass"] = "pitch_grass",
    ["mountain_grass"] = "mountain_grass_b",
    ["beach"] = "beach",
    ["sea"] = "sea_deep",
    ["sea_beach"] = "sea_beach",
    ["abundant_grass_stones_white"] = "land_stones_1_white_rock"
}
local terrain = _G.terrain
local terrain_batch = newAutotable(2)
terrain_batch[0][0] = love.graphics.newSpriteBatch(terrain_image, chunk_width * chunk_height)

function getTerrainChunk()
    return chunk or {}
end

function getLocationDistance()
    return location_distance or 0
end

local function check_max_size_biome(biome, cx, cy, i, o, keys_to_skip, verbose)
    local current_height = 0
    if shadowmap[cx][cy][i][o] ~= 0 and shadowmap[cx][cy][i][o] ~= nil then
        return 1
    end
    if heightmap[cx][cy][i + 0][o + 0] ~= nil and heightmap[cx][cy][i + 0][o + 0] ~= current_height then
        return 1
    end
    if i + 1 >= chunk_width - 1 or o + 1 >= chunk_height - 1 then
        return 1
    end
    if _G.terrain[cx][cy][i + 0][o + 1] ~= biome or keys_to_skip[cx][cy][i + 0][o + 1] then
        return 1
    end
    if heightmap[cx][cy][i + 0][o + 1] ~= nil and heightmap[cx][cy][i + 0][o + 1] ~= current_height then
        return 1
    end
    if shadowmap[cx][cy][i + 0][o + 1] ~= 0 and shadowmap[cx][cy][i + 0][o + 1] ~= nil then
        return 1
    end
    if _G.terrain[cx][cy][i + 1][o + 1] ~= biome or keys_to_skip[cx][cy][i + 1][o + 1] then
        return 1
    end
    if heightmap[cx][cy][i + 1][o + 1] ~= nil and heightmap[cx][cy][i + 1][o + 1] ~= current_height then
        return 1
    end
    if shadowmap[cx][cy][i + 1][o + 1] ~= 0 and shadowmap[cx][cy][i + 1][o + 1] ~= nil then
        return 1
    end
    if _G.terrain[cx][cy][i + 1][o + 0] ~= biome or keys_to_skip[cx][cy][i + 1][o + 0] then
        return 1
    end
    if heightmap[cx][cy][i + 1][o + 0] ~= nil and heightmap[cx][cy][i + 1][o + 0] ~= current_height then
        return 1
    end
    if shadowmap[cx][cy][i + 1][o + 0] ~= 0 and shadowmap[cx][cy][i + 1][o + 0] ~= nil then
        return 1
    end
    if i + 2 >= chunk_width - 1 or o + 2 >= chunk_height - 1 then
        return 2
    end
    if shadowmap[cx][cy][i + 2][o + 2] ~= 0 and shadowmap[cx][cy][i + 2][o + 2] ~= nil then
        return 2
    end
    if _G.terrain[cx][cy][i + 2][o + 0] ~= biome or keys_to_skip[cx][cy][i + 2][o + 0] then
        return 2
    end
    if heightmap[cx][cy][i + 2][o + 0] ~= nil and heightmap[cx][cy][i + 2][o + 0] ~= current_height then
        return 2
    end
    if shadowmap[cx][cy][i + 2][o + 0] ~= 0 and shadowmap[cx][cy][i + 2][o + 0] ~= nil then
        return 2
    end
    if _G.terrain[cx][cy][i + 2][o + 1] ~= biome or keys_to_skip[cx][cy][i + 2][o + 1] then
        return 2
    end
    if heightmap[cx][cy][i + 2][o + 1] ~= nil and heightmap[cx][cy][i + 2][o + 1] ~= current_height then
        return 2
    end
    if shadowmap[cx][cy][i + 2][o + 1] ~= 0 and shadowmap[cx][cy][i + 2][o + 1] ~= nil then
        return 2
    end
    if _G.terrain[cx][cy][i + 2][o + 2] ~= biome or keys_to_skip[cx][cy][i + 2][o + 2] then
        return 2
    end
    if heightmap[cx][cy][i + 2][o + 2] ~= nil and heightmap[cx][cy][i + 2][o + 2] ~= current_height then
        return 2
    end
    if shadowmap[cx][cy][i + 2][o + 2] ~= 0 and shadowmap[cx][cy][i + 2][o + 2] ~= nil then
        return 2
    end
    if _G.terrain[cx][cy][i + 0][o + 2] ~= biome or keys_to_skip[cx][cy][i + 0][o + 2] then
        return 2
    end
    if heightmap[cx][cy][i + 0][o + 2] ~= nil and heightmap[cx][cy][i + 0][o + 2] ~= current_height then
        return 2
    end
    if shadowmap[cx][cy][i + 0][o + 2] ~= 0 and shadowmap[cx][cy][i + 0][o + 2] ~= nil then
        return 2
    end
    if _G.terrain[cx][cy][i + 1][o + 2] ~= biome or keys_to_skip[cx][cy][i + 1][o + 2] then
        return 2
    end
    if heightmap[cx][cy][i + 1][o + 2] ~= nil and heightmap[cx][cy][i + 1][o + 2] ~= current_height then
        return 2
    end
    if shadowmap[cx][cy][i + 1][o + 2] ~= 0 and shadowmap[cx][cy][i + 1][o + 2] ~= nil then
        return 2
    end
    if i + 3 >= chunk_width - 1 or o + 3 >= chunk_height - 1 then
        return 3
    end
    if shadowmap[cx][cy][i + 3][o + 3] ~= 0 and shadowmap[cx][cy][i + 3][o + 3] ~= nil then
        return 1
    end
    if _G.terrain[cx][cy][i + 3][o + 0] ~= biome or keys_to_skip[cx][cy][i + 3][o + 0] then
        return 3
    end
    if heightmap[cx][cy][i + 3][o + 0] ~= nil and heightmap[cx][cy][i + 3][o + 0] ~= current_height then
        return 3
    end
    if shadowmap[cx][cy][i + 3][o + 0] ~= 0 and shadowmap[cx][cy][i + 3][o + 0] ~= nil then
        return 3
    end
    if _G.terrain[cx][cy][i + 3][o + 1] ~= biome or keys_to_skip[cx][cy][i + 3][o + 1] then
        return 3
    end
    if heightmap[cx][cy][i + 3][o + 1] ~= nil and heightmap[cx][cy][i + 3][o + 1] ~= current_height then
        return 3
    end
    if shadowmap[cx][cy][i + 3][o + 1] ~= 0 and shadowmap[cx][cy][i + 3][o + 1] ~= nil then
        return 3
    end
    if _G.terrain[cx][cy][i + 3][o + 2] ~= biome or keys_to_skip[cx][cy][i + 3][o + 2] then
        return 3
    end
    if heightmap[cx][cy][i + 3][o + 2] ~= nil and heightmap[cx][cy][i + 3][o + 2] ~= current_height then
        return 3
    end
    if shadowmap[cx][cy][i + 3][o + 2] ~= 0 and shadowmap[cx][cy][i + 3][o + 2] ~= nil then
        return 3
    end
    if _G.terrain[cx][cy][i + 3][o + 3] ~= biome or keys_to_skip[cx][cy][i + 3][o + 3] then
        return 3
    end
    if heightmap[cx][cy][i + 3][o + 3] ~= nil and heightmap[cx][cy][i + 3][o + 3] ~= current_height then
        return 3
    end
    if shadowmap[cx][cy][i + 3][o + 3] ~= 0 and shadowmap[cx][cy][i + 3][o + 3] ~= nil then
        return 3
    end
    if _G.terrain[cx][cy][i + 0][o + 3] ~= biome or keys_to_skip[cx][cy][i + 0][o + 3] then
        return 3
    end
    if heightmap[cx][cy][i + 0][o + 3] ~= nil and heightmap[cx][cy][i + 0][o + 3] ~= current_height then
        return 3
    end
    if shadowmap[cx][cy][i + 0][o + 3] ~= 0 and shadowmap[cx][cy][i + 0][o + 3] ~= nil then
        return 3
    end
    if _G.terrain[cx][cy][i + 1][o + 3] ~= biome or keys_to_skip[cx][cy][i + 1][o + 3] then
        return 3
    end
    if heightmap[cx][cy][i + 1][o + 3] ~= nil and heightmap[cx][cy][i + 1][o + 3] ~= current_height then
        return 3
    end
    if shadowmap[cx][cy][i + 1][o + 3] ~= 0 and shadowmap[cx][cy][i + 1][o + 3] ~= nil then
        return 3
    end
    if _G.terrain[cx][cy][i + 2][o + 3] ~= biome or keys_to_skip[cx][cy][i + 2][o + 3] then
        return 3
    end
    if heightmap[cx][cy][i + 2][o + 3] ~= nil and heightmap[cx][cy][i + 2][o + 3] ~= current_height then
        return 3
    end
    if shadowmap[cx][cy][i + 2][o + 3] ~= 0 and shadowmap[cx][cy][i + 2][o + 3] ~= nil then
        return 3
    end
    return 4
end

local function free_multi_tile_terrain(size, keys_to_skip, cx, cy, i, o)
    keys_to_skip[cx][cy][i][o] = false
    terrain_tile[cx][cy][i][o] = nil
    secondary_tiles_to_update_in_chunk[cx][cy][i][o] = true
    tertiary_tiles_to_update_in_chunk[cx][cy][i][o] = true
    keys_to_skip[cx][cy][i + 1][o] = false
    terrain_tile[cx][cy][i + 1][o] = nil
    secondary_tiles_to_update_in_chunk[cx][cy][i + 1][o] = true
    tertiary_tiles_to_update_in_chunk[cx][cy][i + 1][o] = true
    keys_to_skip[cx][cy][i + 1][o + 1] = false
    terrain_tile[cx][cy][i + 1][o + 1] = nil
    secondary_tiles_to_update_in_chunk[cx][cy][i + 1][o + 1] = true
    tertiary_tiles_to_update_in_chunk[cx][cy][i + 1][o + 1] = true
    keys_to_skip[cx][cy][i][o + 1] = false
    terrain_tile[cx][cy][i][o + 1] = nil
    secondary_tiles_to_update_in_chunk[cx][cy][i][o + 1] = true
    tertiary_tiles_to_update_in_chunk[cx][cy][i][o + 1] = true
    if size >= 3 then
        keys_to_skip[cx][cy][i + 2][o] = false
        terrain_tile[cx][cy][i + 2][o] = nil
        secondary_tiles_to_update_in_chunk[cx][cy][i + 2][o] = true
        tertiary_tiles_to_update_in_chunk[cx][cy][i + 2][o] = true
        keys_to_skip[cx][cy][i + 2][o + 1] = false
        terrain_tile[cx][cy][i + 2][o + 1] = nil
        secondary_tiles_to_update_in_chunk[cx][cy][i + 2][o + 1] = true
        tertiary_tiles_to_update_in_chunk[cx][cy][i + 2][o + 1] = true
        keys_to_skip[cx][cy][i + 2][o + 2] = false
        terrain_tile[cx][cy][i + 2][o + 2] = nil
        secondary_tiles_to_update_in_chunk[cx][cy][i + 2][o + 2] = true
        tertiary_tiles_to_update_in_chunk[cx][cy][i + 2][o + 2] = true
        keys_to_skip[cx][cy][i][o + 2] = false
        terrain_tile[cx][cy][i][o + 2] = nil
        secondary_tiles_to_update_in_chunk[cx][cy][i][o + 2] = true
        tertiary_tiles_to_update_in_chunk[cx][cy][i][o + 2] = true
        keys_to_skip[cx][cy][i + 1][o + 2] = false
        terrain_tile[cx][cy][i + 1][o + 2] = nil
        secondary_tiles_to_update_in_chunk[cx][cy][i + 1][o + 2] = true
        tertiary_tiles_to_update_in_chunk[cx][cy][i + 1][o + 2] = true
    end
    if size >= 4 then
        keys_to_skip[cx][cy][i + 3][o] = false
        terrain_tile[cx][cy][i + 3][o] = nil
        secondary_tiles_to_update_in_chunk[cx][cy][i + 3][o] = true
        tertiary_tiles_to_update_in_chunk[cx][cy][i + 3][o] = true
        keys_to_skip[cx][cy][i + 3][o + 1] = false
        terrain_tile[cx][cy][i + 3][o + 1] = nil
        secondary_tiles_to_update_in_chunk[cx][cy][i + 3][o + 1] = true
        tertiary_tiles_to_update_in_chunk[cx][cy][i + 3][o + 1] = true
        keys_to_skip[cx][cy][i + 3][o + 2] = false
        terrain_tile[cx][cy][i + 3][o + 2] = nil
        secondary_tiles_to_update_in_chunk[cx][cy][i + 3][o + 2] = true
        tertiary_tiles_to_update_in_chunk[cx][cy][i + 3][o + 2] = true
        keys_to_skip[cx][cy][i + 3][o + 3] = false
        terrain_tile[cx][cy][i + 3][o + 3] = nil
        secondary_tiles_to_update_in_chunk[cx][cy][i + 3][o + 3] = true
        tertiary_tiles_to_update_in_chunk[cx][cy][i + 3][o + 3] = true
        keys_to_skip[cx][cy][i][o + 3] = false
        terrain_tile[cx][cy][i][o + 3] = nil
        secondary_tiles_to_update_in_chunk[cx][cy][i][o + 3] = true
        tertiary_tiles_to_update_in_chunk[cx][cy][i][o + 3] = true
        keys_to_skip[cx][cy][i + 1][o + 3] = false
        terrain_tile[cx][cy][i + 1][o + 3] = nil
        secondary_tiles_to_update_in_chunk[cx][cy][i + 1][o + 3] = true
        tertiary_tiles_to_update_in_chunk[cx][cy][i + 1][o + 3] = true
        keys_to_skip[cx][cy][i + 2][o + 3] = false
        terrain_tile[cx][cy][i + 2][o + 3] = nil
        secondary_tiles_to_update_in_chunk[cx][cy][i + 2][o + 3] = true
        tertiary_tiles_to_update_in_chunk[cx][cy][i + 2][o + 3] = true
    end
end

local function multi_tile_terrain(size, keys_to_skip, cx, cy, i, o, biome)
    terrain_tile[cx][cy][i][o] = nil
    keys_to_skip[cx][cy][i][o] = {
        i,
        o,
        ["size"] = 2,
        ["biome"] = biome,
        ["cx"] = cx,
        ["cy"] = cy
    }
    keys_to_skip[cx][cy][i + 1][o] = {i, o}
    terrain_tile[cx][cy][i + 1][o] = nil
    keys_to_skip[cx][cy][i + 1][o + 1] = {i, o}
    terrain_tile[cx][cy][i + 1][o + 1] = nil
    keys_to_skip[cx][cy][i][o + 1] = {i, o}
    terrain_tile[cx][cy][i][o + 1] = nil
    if size >= 3 then
        terrain_tile[cx][cy][i][o] = nil
        keys_to_skip[cx][cy][i][o] = {
            i,
            o,
            ["size"] = 3,
            ["biome"] = biome,
            ["cx"] = cx,
            ["cy"] = cy
        }
        keys_to_skip[cx][cy][i + 2][o] = {i, o}
        terrain_tile[cx][cy][i + 2][o] = nil
        keys_to_skip[cx][cy][i + 2][o + 1] = {i, o}
        terrain_tile[cx][cy][i + 2][o + 1] = nil
        keys_to_skip[cx][cy][i + 2][o + 2] = {i, o}
        terrain_tile[cx][cy][i + 2][o + 2] = nil
        keys_to_skip[cx][cy][i][o + 2] = {i, o}
        terrain_tile[cx][cy][i][o + 2] = nil
        keys_to_skip[cx][cy][i + 1][o + 2] = {i, o}
        terrain_tile[cx][cy][i + 1][o + 2] = nil
    end
    if size >= 4 then
        terrain_tile[cx][cy][i][o] = nil
        keys_to_skip[cx][cy][i][o] = {
            i,
            o,
            ["size"] = 4,
            ["biome"] = biome,
            ["cx"] = cx,
            ["cy"] = cy
        }
        keys_to_skip[cx][cy][i + 3][o] = {i, o}
        terrain_tile[cx][cy][i + 3][o] = nil
        keys_to_skip[cx][cy][i + 3][o + 1] = {i, o}
        terrain_tile[cx][cy][i + 3][o + 1] = nil
        keys_to_skip[cx][cy][i + 3][o + 2] = {i, o}
        terrain_tile[cx][cy][i + 3][o + 2] = nil
        keys_to_skip[cx][cy][i + 3][o + 3] = {i, o}
        terrain_tile[cx][cy][i + 3][o + 3] = nil
        keys_to_skip[cx][cy][i][o + 3] = {i, o}
        terrain_tile[cx][cy][i][o + 3] = nil
        keys_to_skip[cx][cy][i + 1][o + 3] = {i, o}
        terrain_tile[cx][cy][i + 1][o + 3] = nil
        keys_to_skip[cx][cy][i + 2][o + 3] = {i, o}
        terrain_tile[cx][cy][i + 2][o + 3] = nil
    end
end

local chunks_to_update = {}
local function schedule_terrain_update(cx, cy, i, o)
    tiles_to_update_in_chunk[cx][cy][i][o] = true
    tertiary_tiles_to_update_in_chunk[cx][cy][i][o] = true
    for x = -4, 4 do
        for y = -4, 4 do
            secondary_tiles_to_update_in_chunk[cx][cy][i + x][o + y] = true
            tertiary_tiles_to_update_in_chunk[cx][cy][i + x][o + y] = true
        end
    end
    if not chunks_set[cx][cy] then
        chunks_to_update[#chunks_to_update + 1] = {cx, cy}
        chunks_set[cx][cy] = true
    end
end

function _G.terrainElevateTileAt(gx, gy)
    local i = (gx) % (chunk_width)
    local o = (gy) % (chunk_width)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    if _G.terrain[cx] and _G.terrain[cx][cy] then
        if heightmap[cx][cy][i][o] then
            heightmap[cx][cy][i][o] = heightmap[cx][cy][i][o] + 1
        else
            heightmap[cx][cy][i][o] = 1
        end
        heightmap[cx][cy][i][o] = math.min(heightmap[cx][cy][i][o], 80)
        schedule_terrain_update(cx, cy, i, o)
    end
end

function _G.terrainSetHeight(gx, gy, value)
    -- print(gx, gy)
    local i = (gx) % (chunk_width)
    local o = (gy) % (chunk_width)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    heightmap[cx][cy][i][o] = value
    schedule_terrain_update(cx, cy, i, o)
end

local keys_to_skip = newAutotable(4)

local function multiTileCalculate(current_biome, cx, cy, i, o)
    local l_scale = 1.06
    local tile_width, tile_height = _G.tile_width, _G.tile_height
    local max_size = check_max_size_biome(current_biome, cx, cy, i, o, keys_to_skip)
    local upper_border
    if max_size == 1 then
        upper_border = 16
    elseif max_size == 2 then
        upper_border = 20
    elseif max_size == 3 then
        upper_border = 24
    elseif max_size == 4 then
        upper_border = 28
    end
    if current_biome == _G.terrain_biome.abundant_grass_stones_white then
        upper_border = 16
    elseif current_biome == _G.terrain_biome.sea then
        upper_border = 8
    end
    local rand = love.math.random(1, upper_border)
    if current_biome ~= _G.terrain_biome.abundant_grass_stones_white and current_biome ~= _G.terrain_biome.sea then
        local rand2 = love.math.random(1, upper_border)
        local rand3 = love.math.random(1, upper_border)
        rand = math.max(rand, rand2, rand3)
    end
    if current_biome == _G.terrain_biome.none then
        rand = 0
    end
    local tile_key
    local l_offset_x, l_offset_y = 0, 0
    if current_biome == _G.terrain_biome.sea_beach then
        local gx = chunk_width * cx + i
        local gy = chunk_width * cy + o
        local north = _G.getTerrainBiomeAt(gx, gy - 1) == _G.terrain_biome.sea
        local south = _G.getTerrainBiomeAt(gx, gy + 1) == _G.terrain_biome.sea
        local east = _G.getTerrainBiomeAt(gx + 1, gy) == _G.terrain_biome.sea
        local west = _G.getTerrainBiomeAt(gx - 1, gy) == _G.terrain_biome.sea
        local ne = _G.getTerrainBiomeAt(gx + 1, gy - 1) == _G.terrain_biome.sea
        local nw = _G.getTerrainBiomeAt(gx - 1, gy - 1) == _G.terrain_biome.sea
        local se = _G.getTerrainBiomeAt(gx + 1, gy + 1) == _G.terrain_biome.sea
        local sw = _G.getTerrainBiomeAt(gx - 1, gy + 1) == _G.terrain_biome.sea
        tile_key = "yellow_grass_1x1 (1)"
        if north then
            if east then
                tile_key = "sea_beach_sw_outside (" .. tostring(love.math.random(1, 2)) .. ")"
            elseif west then
                tile_key = "sea_beach_se_outside (" .. tostring(love.math.random(1, 2)) .. ")"
            else
                tile_key = "sea_beach_s (" .. tostring(love.math.random(1, 4)) .. ")"
            end
        elseif south then
            if east then
                tile_key = "sea_beach_nw_outside (" .. tostring(love.math.random(1, 2)) .. ")"
            elseif west then
                tile_key = "sea_beach_ne_outside (" .. tostring(love.math.random(1, 2)) .. ")"
            else
                tile_key = "sea_beach_n (" .. tostring(love.math.random(1, 4)) .. ")"
            end
        elseif east then
            tile_key = "sea_beach_w (" .. tostring(love.math.random(1, 4)) .. ")"
        elseif west then
            tile_key = "sea_beach_e (" .. tostring(love.math.random(1, 4)) .. ")"
        elseif ne then
            tile_key = "sea_beach_sw_inside (" .. tostring(love.math.random(1, 2)) .. ")"
        elseif nw then
            tile_key = "sea_beach_se_inside (" .. tostring(love.math.random(1, 2)) .. ")"
        elseif se then
            tile_key = "sea_beach_nw_inside (" .. tostring(love.math.random(1, 2)) .. ")"
        elseif sw then
            tile_key = "sea_beach_ne_inside (" .. tostring(love.math.random(1, 2)) .. ")"
        end
    else
        if rand == 0 then
            -- No tile, skip
        elseif rand <= 16 then
            tile_key = terrain[cx][cy][i][o] .. "_1x1 (" .. tostring(rand) .. ")"
            local _, _, _, lh = tile_quads[tile_key]:getViewport()
            l_offset_y = 16 - lh
        elseif rand > 16 and rand <= 20 then
            l_offset_x = -16 - 4
            multi_tile_terrain(2, keys_to_skip, cx, cy, i, o, current_biome)
            tile_key = terrain[cx][cy][i][o] .. "_2x2 (" .. tostring(21 - rand) .. ")"
            local _, _, lw, lh = tile_quads[tile_key]:getViewport()
            l_offset_y = 32 - lh
            l_offset_x = l_offset_x + 62 - lw
        elseif rand > 20 and rand <= 24 then
            l_offset_x = -32
            multi_tile_terrain(3, keys_to_skip, cx, cy, i, o, current_biome)
            tile_key = terrain[cx][cy][i][o] .. "_3x3 (" .. tostring(25 - rand) .. ")"
            local _, _, lw, lh = tile_quads[tile_key]:getViewport()
            l_offset_y = 48 - lh
            l_offset_x = l_offset_x + 94 - lw
        else
            l_offset_x = -32 - 16
            multi_tile_terrain(4, keys_to_skip, cx, cy, i, o, current_biome)
            tile_key = terrain[cx][cy][i][o] .. "_4x4 (" .. tostring(29 - rand) .. ")"
            local _, _, lw, lh = tile_quads[tile_key]:getViewport()
            l_offset_y = 64 - lh
            l_offset_x = l_offset_x + 124 - lw
        end
    end
    if rand == 0 then
        terrain_tile[cx][cy][i][o] = nil
    else
        terrain_tile[cx][cy][i][o] = {tile_quads[tile_key], _G.IsoX + (i - o) * tile_width * 0.5 + l_offset_x,
                                      _G.IsoY + (i + o) * tile_height * 0.5 + l_offset_y, 0, l_scale, l_scale}
    end
end

local function update_terrain_2nd_pass(chunk_x, chunk_y)
    local cx = chunk_x or _G.current_chunk_x
    local cy = chunk_y or _G.current_chunk_y
    for i = 0, chunk_width - 1, 1 do
        for o = 0, chunk_width - 1, 1 do
            if secondary_tiles_to_update_in_chunk[cx][cy][i] and secondary_tiles_to_update_in_chunk[cx][cy][i][o] then
                local current_biome = terrain[cx][cy][i][o]
                local multi_tile_origin
                if keys_to_skip[cx][cy][i][o] then
                    local cur_idx = keys_to_skip[cx][cy][i][o]
                    if cur_idx["size"] then
                        multi_tile_origin = cur_idx
                    else
                        multi_tile_origin = keys_to_skip[cx][cy][cur_idx[1]][cur_idx[2]]
                    end
                    local mt = multi_tile_origin
                    if mt.biome ~= current_biome then
                        terrain_tile[cx][cy][cur_idx[1]][cur_idx[2]] = {}
                        free_multi_tile_terrain(multi_tile_origin.size, keys_to_skip, cx, cy, mt[1], mt[2])
                    end
                end
                if keys_to_skip[cx][cy][i][o] then
                    goto end_multi_tile
                end
                multiTileCalculate(current_biome, cx, cy, i, o)

            end
            ::end_multi_tile::
        end
    end
    secondary_tiles_to_update_in_chunk[cx][cy] = nil
end

local empty_table = newAutotable(4)
local function update_terrain(chunk_x, chunk_y)
    local cx = chunk_x or _G.current_chunk_x
    local cy = chunk_y or _G.current_chunk_y
    if terrain_batch[chunk_x][chunk_y] == nil then
        terrain_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(terrain_image, chunk_width * chunk_height)
    end
    terrain_batch[chunk_x][chunk_y]:clear()
    for i = 0, chunk_width - 1, 1 do
        for o = 0, chunk_width - 1, 1 do
            local gx = chunk_width * cx + i
            local gy = chunk_width * cy + o
            local average_height
            local total_height = 0
            for sx = -1, 1 do
                for sy = -1, 1 do
                    if not (sx == 0 and sy == 0) then
                        local cur_i = (gx + sx) % (chunk_width)
                        local cur_o = (gy + sy) % (chunk_width)
                        local cur_cx = math.floor((gx + sx) / chunk_width)
                        local cur_cy = math.floor((gy + sy) / chunk_width)
                        if heightmap[cur_cx] and heightmap[cur_cx][cur_cy] then
                            total_height = total_height + (heightmap[cur_cx][cur_cy][cur_i][cur_o] or 0)
                        end
                    end
                end
            end
            -- average_height = total_height / 8
            -- local prev_heightmap_value = heightmap[cx][cy][i][o] or 0
            -- heightmap[cx][cy][i][o] = math.floor(math.max(average_height, (heightmap[cx][cy][i][o] or 0)))
            if heightmap[cx][cy][i][o] ~= prev_heightmap_value then
                tiles_to_update_in_chunk[cx][cy][i][o] = true
            end
            local prev_i = (gx - 1) % (chunk_width)
            local prev_o = (gy + 1) % (chunk_width)
            local prev_cx = math.floor((gx - 1) / chunk_width)
            local prev_cy = math.floor((gy + 1) / chunk_width)

            local prev_height, prev_shadow, prev_tileheight = 0, 0, 0
            local curr_tileheight = tileheight[cx][cy][i][o] or 0
            if _G.terrain[prev_cx] and _G.terrain[prev_cx][prev_cy] then
                prev_height = heightmap[prev_cx][prev_cy][prev_i][prev_o] or 0
                prev_height = 75 * prev_height / (40 + prev_height)
                prev_shadow = shadowmap[prev_cx][prev_cy][prev_i][prev_o] or 0
                prev_tileheight = tileheight[prev_cx][prev_cy][prev_i][prev_o] or 0
                -- prev_tileheight = 75 * prev_tileheight / (40 + prev_tileheight)
                -- total_height = 75 * (prev_height + prev_tileheight) / (40 + (prev_height + prev_tileheight))
            end
            shadowmap[cx][cy][i][o] = math.max(math.max(prev_height + prev_tileheight, prev_shadow) - 3.5, 0)

            local prev1_i = (gx - 1) % (chunk_width)
            local prev1_o = (gy) % (chunk_width)
            local prev1_cx = math.floor((gx - 1) / chunk_width)
            local prev1_cy = math.floor((gy) / chunk_width)
            local prev2_i = (gx) % (chunk_width)
            local prev2_o = (gy + 1) % (chunk_width)
            local prev2_cx = math.floor((gx) / chunk_width)
            local prev2_cy = math.floor((gy + 1) / chunk_width)
            local prev1_height = heightmap[prev1_cx][prev1_cy][prev1_i][prev1_o] or 0
            prev1_height = 75 * prev1_height / (40 + prev1_height)
            local prev1_shadow = shadowmap[prev1_cx][prev1_cy][prev1_i][prev1_o] or 0
            local prev1_tileheight = tileheight[prev1_cx][prev1_cy][prev1_i][prev1_o] or 0
            local prev2_height = heightmap[prev2_cx][prev2_cy][prev2_i][prev2_o] or 0
            prev2_height = 75 * prev2_height / (40 + prev2_height)
            local prev2_shadow = shadowmap[prev2_cx][prev2_cy][prev2_i][prev2_o] or 0
            local prev2_tileheight = tileheight[prev2_cx][prev2_cy][prev2_i][prev2_o] or 0
            local prev1_shadow_value = math.max(math.max(prev1_height + prev1_tileheight, prev1_shadow) - 3.5, 0)
            local prev2_shadow_value = math.max(math.max(prev2_height + prev2_tileheight, prev2_shadow) - 3.5, 0)

            local prev3_i = (gx + 1) % (chunk_width)
            local prev3_o = (gy) % (chunk_width)
            local prev3_cx = math.floor((gx + 1) / chunk_width)
            local prev3_cy = math.floor((gy) / chunk_width)
            local prev3_height = heightmap[prev3_cx][prev3_cy][prev3_i][prev3_o] or 0
            prev3_height = 75 * prev3_height / (40 + prev3_height)
            local prev3_tileheight = tileheight[prev3_cx][prev3_cy][prev3_i][prev3_o] or 0
            local prev3_shadow = shadowmap[prev3_cx][prev3_cy][prev3_i][prev3_o] or 0
            local prev3_shadow_value = math.max(math.max(prev3_height + prev3_tileheight, prev3_shadow) - 3.5, 0)

            local prev4_i = (gx) % (chunk_width)
            local prev4_o = (gy - 1) % (chunk_width)
            local prev4_cx = math.floor((gx) / chunk_width)
            local prev4_cy = math.floor((gy - 1) / chunk_width)
            local prev4_height = heightmap[prev4_cx][prev4_cy][prev4_i][prev4_o] or 0
            prev4_height = 75 * prev4_height / (40 + prev4_height)
            local prev4_tileheight = tileheight[prev4_cx][prev4_cy][prev4_i][prev4_o] or 0
            local prev4_shadow = shadowmap[prev4_cx][prev4_cy][prev4_i][prev4_o] or 0
            local prev4_shadow_value = math.max(math.max(prev4_height + prev4_tileheight, prev4_shadow) - 3.5, 0)
            -- shadowmap[cx][cy][i][o] = math.max(shadowmap[cx][cy][i][o], prev1_shadow_value / 2, prev2_shadow_value / 2)
            if (prev1_shadow_value == prev2_shadow_value) and prev1_shadow_value > shadowmap[cx][cy][i][o] then
                shadowmap[cx][cy][i][o] = prev1_shadow_value
            end
            local current_shadow = shadowmap[cx][cy][i][o] or 0
            local elevation_offset_y = heightmap[cx][cy][i][o] or 0
            local elevation_value = 75 * elevation_offset_y / (40 + elevation_offset_y)
            local is_in_shadow = current_shadow > elevation_offset_y or current_shadow > elevation_value
            if not is_in_shadow then
                local interpolated_shadow_val = (prev1_shadow_value * 2 + prev2_shadow_value * 2 + prev3_shadow_value +
                                                    prev4_shadow_value) / 6
                shadowmap[cx][cy][i][o] = interpolated_shadow_val
            end

            if tiles_to_update_in_chunk[cx][cy][i] and tiles_to_update_in_chunk[cx][cy][i][o] then
                local current_biome = terrain[cx][cy][i][o]
                local multi_tile_origin
                if keys_to_skip[cx][cy][i][o] then
                    local cur_idx = keys_to_skip[cx][cy][i][o]
                    if cur_idx["size"] then
                        multi_tile_origin = cur_idx
                    else
                        multi_tile_origin = keys_to_skip[cx][cy][cur_idx[1]][cur_idx[2]]
                    end
                    local mt = multi_tile_origin
                    local max_size = check_max_size_biome(current_biome, mt.cx, mt.cy, mt[1], mt[2], keys_to_skip)
                    if max_size ~= mt.size or multi_tile_origin.biome ~= current_biome then
                        terrain_tile[cx][cy][mt[1]][mt[2]] = {}
                        free_multi_tile_terrain(multi_tile_origin.size, keys_to_skip, cx, cy, mt[1], mt[2])
                    end
                end
                if keys_to_skip[cx][cy][i][o] then
                    goto continue
                end
                multiTileCalculate(current_biome, cx, cy, i, o)
            end
            ::continue::
            if shadowmap[cx][cy][i][o] and shadowmap[cx][cy][i][o] > 0 and terrain[cx][cy] then
                local current_biome = terrain[cx][cy][i][o]
                local multi_tile_origin
                if keys_to_skip[cx][cy][i][o] then
                    local cur_idx = keys_to_skip[cx][cy][i][o]
                    if cur_idx["size"] then
                        multi_tile_origin = cur_idx
                    else
                        multi_tile_origin = keys_to_skip[cx][cy][cur_idx[1]][cur_idx[2]]
                    end
                    local mt = multi_tile_origin
                    local max_size = check_max_size_biome(current_biome, mt.cx, mt.cy, mt[1], mt[2], empty_table, true)
                    if max_size ~= mt.size then
                        terrain_tile[cx][cy][mt[1]][mt[2]] = {}
                        free_multi_tile_terrain(multi_tile_origin.size, keys_to_skip, cx, cy, mt[1], mt[2])
                    end
                end
            end
        end
    end
    update_terrain_2nd_pass(cx, cy)
end

local function tileShouldBeCliff(my_gx, my_gy)
    local i = (my_gx) % (chunk_width)
    local o = (my_gy) % (chunk_width)
    local cx = math.floor(my_gx / chunk_width)
    local cy = math.floor(my_gy / chunk_width)
    local my_height = heightmap[cx][cy][i][o] or 0
    local gx, gy = my_gx + 1, my_gy
    i = (gx) % (chunk_width)
    o = (gy) % (chunk_width)
    cx = math.floor(gx / chunk_width)
    cy = math.floor(gy / chunk_width)
    local tile_left_height = heightmap[cx][cy][i][o] or 0
    if (my_height - tile_left_height) > 8 then
        return true
    end
    gx, gy = my_gx, my_gy + 1
    i = (gx) % (chunk_width)
    o = (gy) % (chunk_width)
    cx = math.floor(gx / chunk_width)
    cy = math.floor(gy / chunk_width)
    local tile_right_height = heightmap[cx][cy][i][o] or 0
    if (my_height - tile_right_height) > 8 then
        return true
    end
    gx, gy = my_gx + 1, my_gy + 1
    i = (gx) % (chunk_width)
    o = (gy) % (chunk_width)
    cx = math.floor(gx / chunk_width)
    cy = math.floor(gy / chunk_width)
    if terrain[cx][cy] and terrain[cx][cy][i] and terrain[cx][cy][i][o] == _G.terrain_biome.none then
        return true
    end
    gx, gy = my_gx, my_gy + 1
    i = (gx) % (chunk_width)
    o = (gy) % (chunk_width)
    cx = math.floor(gx / chunk_width)
    cy = math.floor(gy / chunk_width)
    if terrain[cx][cy] and terrain[cx][cy][i] and terrain[cx][cy][i][o] == _G.terrain_biome.none then
        return true
    end
    gx, gy = my_gx + 1, my_gy
    i = (gx) % (chunk_width)
    o = (gy) % (chunk_width)
    cx = math.floor(gx / chunk_width)
    cy = math.floor(gy / chunk_width)
    if terrain[cx][cy] and terrain[cx][cy][i] and terrain[cx][cy][i][o] == _G.terrain_biome.none then
        return true
    end
end

local function refresh_terrain(chunk_x, chunk_y)
    local cx = chunk_x or _G.current_chunk_x
    local cy = chunk_y or _G.current_chunk_y
    tiles_to_update_in_chunk[cx][cy] = nil
    for i = 0, chunk_width - 1, 1 do
        for o = 0, chunk_width - 1, 1 do
            if tertiary_tiles_to_update_in_chunk[cx][cy][i] and tertiary_tiles_to_update_in_chunk[cx][cy][i][o] == true and
                terrain[cx][cy][i][o] ~= _G.terrain_biome.none then
                local vert_id = _G.getTerrainVertex(cx, cy, i, o)
                local chevron_id = _G.getChevronVertex(cx, cy, i, o)
                local instancemesh = _G.object_mesh[cx][cy]
                instancemesh:setVertex(vert_id)
                local elevation_offset_y = heightmap[cx][cy][i][o] or 0
                local elevation_value = 75 * elevation_offset_y / (40 + elevation_offset_y)
                local shadow_value = shadowmap[cx][cy][i][o] or 0
                local this_tileheight = tileheight[cx][cy][i][o] or 0
                local is_in_shadow = shadow_value > elevation_offset_y or shadow_value > elevation_value
                shadow_value = math.min((shadow_value - elevation_value) / 40, 0.6)

                -- -- CHECK IF PREVIOUS TILE HAS THE SAME HEIGHT
                local gx = chunk_width * cx + i
                local gy = chunk_width * cy + o
                local prev_i = (gx - 1) % (chunk_width)
                local prev_o = (gy + 1) % (chunk_width)
                local prev_cx = math.floor((gx - 1) / chunk_width)
                local prev_cy = math.floor((gy + 1) / chunk_width)

                local prev_height, prev_shadow, prev_tileheight = 0, 0, 0
                prev_height = heightmap[prev_cx][prev_cy][prev_i][prev_o] or 0
                prev_shadow = shadowmap[prev_cx][prev_cy][prev_i][prev_o] or 0
                prev_tileheight = tileheight[prev_cx][prev_cy][prev_i][prev_o] or 0
                local prev_elevation_value = 75 * prev_height / (40 + prev_height)
                local prev_shadow_value = math.min((prev_shadow - prev_elevation_value / 40) / 40, 0.45) / 1.25
                local prev_in_shadow = prev_shadow > prev_height
                if prev_height <= elevation_offset_y and prev_tileheight <= this_tileheight and not prev_in_shadow and
                    shadow_value > elevation_value then
                    is_in_shadow = false
                end
                if this_tileheight > 0 then
                    is_in_shadow = true
                end

                -- shadow_value = math.min((shadow_value - elevation_value / 40) / 40, 0.45) / 1.25
                local tile_has_slope = false
                local tiles_with_slope = 0
                for xx = -1, 1 do
                    for yy = -1, 1 do
                        local pi = (gx + xx) % (chunk_width)
                        local po = (gy + yy) % (chunk_width)
                        local pcx = math.floor((gx + xx) / chunk_width)
                        local pcy = math.floor((gy + yy) / chunk_width)
                        if heightmap[pcx][pcy][pi][po] and heightmap[pcx][pcy][pi][po] ~= elevation_offset_y then
                            tiles_with_slope = tiles_with_slope + 1
                        end
                    end
                end
                if tiles_with_slope > 5 then
                    tile_has_slope = true
                end
                local hill_tile_base, hill_tile_sunny_side, hill_tile_normal
                local skip_multi_tile = false
                local t = terrain_tile[cx][cy][i][o]
                if not t or #t <= 0 then
                    skip_multi_tile = true
                    t =
                        {nil, _G.IsoX + (i - o) * tile_width * 0.5, _G.IsoY + (i + o) * tile_height * 0.5, 0, 1.06, 1.06}
                end
                local is_cliff = tileShouldBeCliff(gx, gy)
                local cliff_chevron
                local tile_overriden = false
                local hill_chevron_sunny_side, hill_chevron_normal, hill_chevron_base
                local l_scale = 1.06666
                if elevation_offset_y ~= 0 then
                    local num = tostring(math.min(math.floor(elevation_offset_y / 6), 15) + 1)
                    -- local sunny_rand = tostring(love.math.random(1, 4))
                    -- local normal_rand = tostring(love.math.random(5, 8))
                    local sunny_rand = tostring((i + o) % 5 + 1)
                    -- local normal_rand = tostring((i + o) % 4 + 5)
                    local normal_rand = love.math.random(1, 8)
                    if terrain[cx][cy][i][o] == _G.terrain_biome.scarce_grass then
                        -- terrain[cx][cy][i][o] = _G.terrain_biome.abundant_grass
                        -- normal_rand = tostring((i + o + 1) % 16 + 1)
                        normal_rand = love.math.random(1, 16)
                        if elevation_offset_y < 33 and elevation_offset_y > 10 then
                            hill_tile_base = "mountain_grass_a_1x1 ("
                        elseif elevation_offset_y < 66 then
                            hill_tile_base = "mountain_grass_b_1x1 ("
                        elseif elevation_offset_y >= 66 then
                            hill_tile_base = "mountain_grass_b_1x1 ("
                        else
                            hill_tile_base = "hill_" .. num .. " ("
                            normal_rand = love.math.random(5, 8)
                            -- normal_rand = tostring((i + o) % 4 + 5)
                        end
                    else
                        hill_tile_base = "hill_" .. num .. " ("
                    end
                    hill_chevron_base = "hill_chevron_" .. num .. " ("
                    hill_tile_sunny_side = hill_tile_base .. sunny_rand .. ")"
                    hill_chevron_sunny_side = hill_chevron_base .. sunny_rand .. ")"
                    hill_tile_normal = hill_tile_base .. normal_rand .. ")"
                    hill_chevron_normal = hill_chevron_base .. normal_rand .. ")"
                    hill_tile_normal = tile_quads[hill_tile_normal]
                    hill_tile_sunny_side = tile_quads[hill_tile_sunny_side]
                    hill_chevron_normal = tile_quads[hill_chevron_normal]
                    hill_chevron_sunny_side = tile_quads[hill_chevron_sunny_side]
                    -- cliff_chevron = tile_quads["rock_cliff (" .. tostring(love.math.random(1, 31)) .. ")"]
                    cliff_chevron = tile_quads["sand_cliffs (" .. tostring((i + o) % 31 + 1) .. ")"]
                end
                local light_value = 1
                if is_in_shadow then
                    local max_shadow = math.min(0.9, 1 - shadow_value)
                    if elevation_offset_y ~= 0 then
                        if is_cliff then
                            local qx, qy, qw, qh = cliff_chevron:getViewport()
                            instancemesh:setVertex(chevron_id, t[2], t[3] - elevation_offset_y * 2 + 8, qx, qy, qw, qh,
                                1 - shadow_value, l_scale)
                        else
                            local qx, qy, qw, qh = hill_chevron_normal:getViewport()
                            instancemesh:setVertex(chevron_id, t[2], t[3] - elevation_offset_y * 2 + 8, qx, qy, qw, qh,
                                1 - shadow_value, l_scale)
                        end
                        local qx, qy, qw, qh = hill_tile_normal:getViewport()
                        instancemesh:setVertex(vert_id, t[2], t[3] - elevation_offset_y * 2, qx, qy, qw, qh,
                            1 - shadow_value, l_scale)
                        tile_overriden = true
                    end
                    light_value = max_shadow
                else
                    local light_modifier = elevation_offset_y / 50
                    if light_modifier > 0 and tile_has_slope and elevation_offset_y ~= 0 then
                        light_value = 0.85
                        if is_cliff then
                            local qx, qy, qw, qh = cliff_chevron:getViewport()
                            instancemesh:setVertex(chevron_id, t[2], t[3] - elevation_offset_y * 2 + 8, qx, qy, qw, qh,
                                0.9 + math.min(light_modifier, 0.11), l_scale)
                        else
                            local qx, qy, qw, qh = hill_chevron_sunny_side:getViewport()
                            instancemesh:setVertex(chevron_id, t[2], t[3] - elevation_offset_y * 2 + 8, qx, qy, qw, qh,
                                0.9 + math.min(light_modifier, 0.11), l_scale)
                        end
                        local qx, qy, qw, qh = hill_tile_sunny_side:getViewport()
                        instancemesh:setVertex(vert_id, t[2], t[3] - elevation_offset_y * 2, qx, qy, qw, qh,
                            0.9 + math.min(light_modifier, 0.11), l_scale)
                        tile_overriden = true
                    elseif elevation_offset_y ~= 0 then
                        light_value = 1
                        if is_cliff then
                            local qx, qy, qw, qh = cliff_chevron:getViewport()
                            instancemesh:setVertex(chevron_id, t[2], t[3] - elevation_offset_y * 2 + 8, qx, qy, qw, qh,
                                1, l_scale)
                        else
                            local qx, qy, qw, qh = hill_chevron_normal:getViewport()
                            instancemesh:setVertex(chevron_id, t[2], t[3] - elevation_offset_y * 2 + 8, qx, qy, qw, qh,
                                1, l_scale)
                        end
                        local qx, qy, qw, qh = hill_tile_normal:getViewport()
                        instancemesh:setVertex(vert_id, t[2], t[3] - elevation_offset_y * 2, qx, qy, qw, qh, 1, l_scale)
                        tile_overriden = true
                    end
                end
                if not skip_multi_tile and not tile_overriden and t[1] then
                    local qx, qy, qw, qh = t[1]:getViewport()
                    instancemesh:setVertex(vert_id, t[2], t[3] - elevation_offset_y * 2, qx, qy, qw, qh, light_value,
                        l_scale)
                end
            elseif terrain[cx][cy][i][o] == _G.terrain_biome.none then
                local vert_id = _G.getTerrainVertex(cx, cy, i, o)
                local instancemesh = _G.object_mesh[cx][cy]
                instancemesh:setVertex(vert_id)
            end
        end
    end
    tertiary_tiles_to_update_in_chunk[cx][cy] = nil
end

function _G.getTerrainTileOnMouse(mx, my)
    local MX, MY, rMX, rMY
    rMX = (mx - _G.width / 2) / _G.scale_x + _G.view_xview - 16
    rMY = (my - _G.height / 2) / _G.scale_x + _G.view_yview
    local max_tiles = 20
    local offset_y
    local LocalX = math.round(ScreenToIsoX(rMX, rMY))
    local LocalY = math.round(ScreenToIsoY(rMX, rMY))
    local last_valid_gx, last_valid_gy = LocalX, LocalY
    for tiles_iterated = 0, max_tiles do
        offset_y = tiles_iterated * 8
        MX = (mx - _G.width / 2) / _G.scale_x + _G.view_xview - 16
        MY = (my + offset_y * _G.scale_x - _G.height / 2) / _G.scale_x + _G.view_yview - 8
        LocalX = math.round(ScreenToIsoX(MX, MY))
        LocalY = math.round(ScreenToIsoY(MX, MY))
        local gx = LocalX
        local gy = LocalY
        local i = (LocalX) % (chunk_width)
        local o = (LocalY) % (chunk_width)
        local cx = math.floor(LocalX / chunk_width)
        local cy = math.floor(LocalY / chunk_width)
        local elevation_offset_y = (heightmap[cx][cy][i][o] or 0) * 2
        local t = terrain_tile[cx][cy][i][o]
        local cy_offset = (cx + cy) * chunk_height * tile_height * 0.5
        if not t or #t <= 0 then
            t = {nil, _G.IsoX + (i - o) * tile_width * 0.5, _G.IsoY + (i + o) * tile_height * 0.5, 0, 1.06, 1.06}
        end
        local recty = t[3] - elevation_offset_y + cy_offset
        if rMY >= recty then
            last_valid_gx, last_valid_gy = gx, gy
        end
    end
    return last_valid_gx, last_valid_gy
end

local function update()
    for _, chunk in ipairs(chunks_to_update) do
        update_terrain(chunk[1], chunk[2])
        refresh_terrain(chunk[1], chunk[2])
        chunks_set[chunk[1]][chunk[2]] = nil
    end
    chunks_to_update = {}
end
local function genTerrain(cx, cy)
    local chunk_x = cx or current_chunk_x
    local chunk_y = cy or current_chunk_y
    if terrain_batch[chunk_x][chunk_y] == nil then
        terrain_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(terrain_image, chunk_width * chunk_height)
    end
    _G.allocateMesh(cx, cy)
    terrain[cx][cy] = newAutotable(2)
    for i = 0, chunk_width - 1, 1 do
        for o = 0, chunk_height - 1, 1 do
            local gx = chunk_width * cx + i
            local gy = chunk_width * cy + o
            terrain[cx][cy][i][o] = _G.terrain_biome.abundant_grass
            schedule_terrain_update(cx, cy, i, o)
            -- if _G.lake_gen[gx + 1][gy + 1] ~= false then
            --     local border = false
            --     for lx = -1, 1, 1 do
            --         for ly = -1, 1, 1 do
            --             if not (lx == 0 and ly == 0) then
            --                 if _G.lake_gen[gx + lx + 1] and _G.lake_gen[gx + lx + 1][gy + ly + 1] == false then
            --                     border = true
            --                 end
            --             end
            --         end
            --     end
            --     if border then
            --         terrain[cx][cy][i][o] = _G.terrain_biome.sea_beach
            --     else
            --         terrain[cx][cy][i][o] = _G.terrain_biome.sea
            --     end
            -- end
        end
    end
    genObjects(cx, cy) -- TODO OPTIMIZE: move genObjects in this loop so we don't loop twice!
end

local function chunkDraw()
    -- Deprecated
end
function _G.terrainSetTileAt(gx, gy, biome, from)
    local i = (gx) % (chunk_width)
    local o = (gy) % (chunk_width)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    if _G.terrain[cx] and _G.terrain[cx][cy] then
        if from then
            if _G.terrain[cx][cy][i][o] == from then
                _G.terrain[cx][cy][i][o] = biome
                schedule_terrain_update(cx, cy, i, o)
            end
        else
            _G.terrain[cx][cy][i][o] = biome
            schedule_terrain_update(cx, cy, i, o)
        end
    end
end

function _G.getTerrainBiomeAt(gx, gy)
    local i = (gx) % (chunk_width)
    local o = (gy) % (chunk_width)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    if _G.terrain[cx] and _G.terrain[cx][cy] then
        return _G.terrain[cx][cy][i][o]
    end
end

local function genForest()
    _G.forest_gen = {}

    for x = 1, math.round((_G.chunks_wide * _G.chunk_width) / 8) + 1 do
        forest_gen[x] = {}
        for y = 1, math.round((_G.chunks_high * _G.chunk_height) / 8) + 1 do
            local Value = love.math.random(0, 100)
            if Value < 45 then
                forest_gen[x][y] = true
            else
                forest_gen[x][y] = false
            end
        end
    end

    local forest_update_counter = 0
    local forest_update_limit = 3

    repeat
        for x = 1, #forest_gen do
            for y = 1, #forest_gen[x] do
                local tile = forest_gen[x][y]
                local neighbors_alive = 0
                for I = 0, 9 do
                    if I ~= 4 then
                        offset_x = math.floor(I % 3) - 1
                        offset_y = math.floor(I / 3) - 1

                        if forest_gen[x + offset_x] and forest_gen[x + offset_x][y + offset_y] and
                            forest_gen[x + offset_x][y + offset_y] then
                            neighbors_alive = neighbors_alive + 1
                        end
                    end
                end

                if tile and neighbors_alive < 4 then
                    forest_gen[x][y] = false
                end
                if not tile and neighbors_alive > 5 then
                    forest_gen[x][y] = true
                end
            end
        end

        forest_update_counter = forest_update_counter + 1
    until (forest_update_counter == forest_update_limit)
end

local function genStone()
    _G.stone_gen = {}
    local total_stones = 0
    for x = 1, math.round((_G.chunks_wide * _G.chunk_width) / 3) + 1 do
        stone_gen[x] = {}
        for y = 1, math.round((_G.chunks_high * _G.chunk_height) / 3) + 1 do
            local Value = love.math.random(0, 100)
            if Value < 37 then
                if not (_G.forest_gen[math.round((x * 2.66) / 8) + 1][math.round((y * 2.66) / 8) + 1] ~= false) then
                    stone_gen[x][y] = true
                    total_stones = total_stones + 1
                else
                    stone_gen[x][y] = false
                end
            else
                stone_gen[x][y] = false
            end
        end
    end

    local stone_update_counter = 0
    local stone_update_limit = 20

    repeat
        for x = 1, #stone_gen do
            for y = 1, #stone_gen[x] do
                local tile = stone_gen[x][y]
                local neighbors_alive = 0
                for I = 0, 9 do
                    if I ~= 4 then
                        offset_x = math.floor(I % 3) - 1
                        offset_y = math.floor(I / 3) - 1

                        if stone_gen[x + offset_x] and stone_gen[x + offset_x][y + offset_y] and
                            stone_gen[x + offset_x][y + offset_y] then
                            neighbors_alive = neighbors_alive + 1
                        end
                    end
                end

                if tile and neighbors_alive < 4 then
                    stone_gen[x][y] = false
                    total_stones = total_stones - 1
                end
                if not tile and neighbors_alive > 5 then
                    stone_gen[x][y] = true
                    total_stones = total_stones + 1
                end
            end
        end

        stone_update_counter = stone_update_counter + 1
    until (stone_update_counter == stone_update_limit)
    print(total_stones)
    return total_stones
end

local function genIron()
    _G.iron_gen = {}
    local total_iron = 0
    for x = 1, math.round((_G.chunks_wide * _G.chunk_width) / 3) + 1 do
        iron_gen[x] = {}
        for y = 1, math.round((_G.chunks_high * _G.chunk_height) / 3) + 1 do
            local Value = love.math.random(0, 100)
            if Value < 38 then
                if not (_G.forest_gen[math.round((x * 2.66) / 8) + 1][math.round((y * 2.66) / 8) + 1] ~= false) and
                    not (_G.stone_gen[x][y] ~= false) then
                    iron_gen[x][y] = true
                    total_iron = total_iron + 1
                else
                    iron_gen[x][y] = false
                end
            else
                iron_gen[x][y] = false
            end
        end
    end

    local iron_update_counter = 0
    local iron_update_limit = 20

    repeat
        for x = 1, #iron_gen do
            for y = 1, #iron_gen[x] do
                local tile = iron_gen[x][y]
                local neighbors_alive = 0
                for I = 0, 9 do
                    if I ~= 4 then
                        offset_x = math.floor(I % 3) - 1
                        offset_y = math.floor(I / 3) - 1

                        if iron_gen[x + offset_x] and iron_gen[x + offset_x][y + offset_y] and
                            iron_gen[x + offset_x][y + offset_y] then
                            neighbors_alive = neighbors_alive + 1
                        end
                    end
                end

                if tile and neighbors_alive < 4 then
                    iron_gen[x][y] = false
                    total_iron = total_iron - 1
                end
                if not tile and neighbors_alive > 5 then
                    iron_gen[x][y] = true
                    total_iron = total_iron + 1
                end
            end
        end

        iron_update_counter = iron_update_counter + 1
    until (iron_update_counter == iron_update_limit)
    print("Iron in map", total_iron)
    return total_iron
end

local function genLake()
    _G.lake_gen = {}
    local total_lake = 0
    for x = 1, math.round((_G.chunks_wide * _G.chunk_width)) + 1 do
        lake_gen[x] = {}
        for y = 1, math.round((_G.chunks_high * _G.chunk_height)) + 1 do
            local Value = love.math.random(0, 100)
            if Value < 50 then
                if true then
                    lake_gen[x][y] = true
                    total_lake = total_lake + 1
                else
                    lake_gen[x][y] = false
                end
            else
                lake_gen[x][y] = false
            end
        end
    end

    local lake_update_counter = 0
    local lake_update_limit = 30

    repeat
        for x = 1, #lake_gen do
            for y = 1, #lake_gen[x] do
                local tile = lake_gen[x][y]
                local neighbors_alive = 0
                for I = 0, 9 do
                    if I ~= 4 then
                        offset_x = math.floor(I % 3) - 1
                        offset_y = math.floor(I / 3) - 1

                        if lake_gen[x + offset_x] and lake_gen[x + offset_x][y + offset_y] and
                            lake_gen[x + offset_x][y + offset_y] then
                            neighbors_alive = neighbors_alive + 1
                        end
                    end
                end

                if tile and neighbors_alive < 4 then
                    lake_gen[x][y] = false
                    total_lake = total_lake - 1
                end
                if not tile and neighbors_alive > 5 then
                    lake_gen[x][y] = true
                    total_lake = total_lake + 1
                end
            end
        end

        lake_update_counter = lake_update_counter + 1
    until (lake_update_counter == lake_update_limit)
    -- print("lake in map", total_lake)
    return total_lake
end

local function genMap()
    genForest()
    -- repeat
    _G.stone_gen = {}
    local stones = genStone()
    -- until stones > 170 and stones < 300
    -- repeat
    _G.iron_gen = {}
    local iron = genIron()
    -- until iron > 100 and iron < 250
    -- genLake()
    for i = 0, _G.chunks_wide - 1 do
        for o = 0, _G.chunks_high - 1 do -- usually both are 32 (jumper is set like that with magic numbers)
            genTerrain(i, o)
            _G.status[i][o] = 2
        end
    end
end

local function allocateSpriteBatches()
    -- FIXME MAGIC NUMBERS
    for i = 0, _G.chunks_wide do
        for o = 0, _G.chunks_high do
            if terrain_batch[i][o] == nil then
                terrain_batch[i][o] = love.graphics.newSpriteBatch(terrain_image, chunk_width * chunk_height)
            end
        end
    end
end

local tableOfFunctions = {
    update = update,
    draw = chunkDraw,
    chunk = chunk,
    mousepressed = function()
    end,
    batch = terrain_batch,
    genTerrain = genTerrain,
    terrain = tile,
    genMap = genMap,
    allocateSpriteBatches = allocateSpriteBatches
}
return tableOfFunctions

