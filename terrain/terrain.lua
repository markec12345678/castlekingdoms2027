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
----Chunk 2D array
-- Statuses: 
-- [1] loaded unsaved
-- [2] unloaded - chunk exist on hard disk
-- [3] loaded saved - chunk hasn't been changed so no need to save it
-- nil - chunk needs to be generated first

----Generate spriteBatch
local terrain_image = love.graphics.newImage("assets/tiles/terrain_pack.png")
terrain_image:setFilter('nearest', 'nearest')
local tile_offset = {}
local terrain_tile = newAutotable(4)
local imageW, imageH = terrain_image:getWidth(), terrain_image:getHeight()
_G.terrain_biome = {
    ["abundant_grass"] = "abundant_grass",
    ["dirt"] = "dirt",
    ["scarce_grass"] = "scarce_grass",
    ["yellow_grass"] = "yellow_grass",
    ["orange_grass"] = "orange_grass",
    ["pitch_grass"] = "pitch_grass",
    ["mountain_grass"] = "mountain_grass_b",
    ["beach"] = "beach",
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

local function check_max_size_biome(biome, cx, cy, i, o, keys_to_skip)
    if i + 1 >= chunk_width - 1 or o + 1 >= chunk_height - 1 then
        return 1
    end
    if _G.terrain[cx][cy][i + 0][o + 1] ~= biome or keys_to_skip[cx][cy][i + 0][o + 1] then
        return 1
    end
    if _G.terrain[cx][cy][i + 1][o + 1] ~= biome or keys_to_skip[cx][cy][i + 1][o + 1] then
        return 1
    end
    if _G.terrain[cx][cy][i + 1][o + 0] ~= biome or keys_to_skip[cx][cy][i + 1][o + 0] then
        return 1
    end
    if i + 2 >= chunk_width - 1 or o + 2 >= chunk_height - 1 then
        return 2
    end
    if _G.terrain[cx][cy][i + 2][o + 0] ~= biome or keys_to_skip[cx][cy][i + 2][o + 0] then
        return 2
    end
    if _G.terrain[cx][cy][i + 2][o + 1] ~= biome or keys_to_skip[cx][cy][i + 2][o + 1] then
        return 2
    end
    if _G.terrain[cx][cy][i + 2][o + 2] ~= biome or keys_to_skip[cx][cy][i + 2][o + 2] then
        return 2
    end
    if _G.terrain[cx][cy][i + 0][o + 2] ~= biome or keys_to_skip[cx][cy][i + 0][o + 2] then
        return 2
    end
    if _G.terrain[cx][cy][i + 1][o + 2] ~= biome or keys_to_skip[cx][cy][i + 1][o + 2] then
        return 2
    end
    if i + 3 >= chunk_width - 1 or o + 3 >= chunk_height - 1 then
        return 3
    end
    if _G.terrain[cx][cy][i + 3][o + 0] ~= biome or keys_to_skip[cx][cy][i + 3][o + 0] then
        return 3
    end
    if _G.terrain[cx][cy][i + 3][o + 1] ~= biome or keys_to_skip[cx][cy][i + 3][o + 1] then
        return 3
    end
    if _G.terrain[cx][cy][i + 3][o + 2] ~= biome or keys_to_skip[cx][cy][i + 3][o + 2] then
        return 3
    end
    if _G.terrain[cx][cy][i + 3][o + 3] ~= biome or keys_to_skip[cx][cy][i + 3][o + 3] then
        return 3
    end
    if _G.terrain[cx][cy][i + 0][o + 3] ~= biome or keys_to_skip[cx][cy][i + 0][o + 3] then
        return 3
    end
    if _G.terrain[cx][cy][i + 1][o + 3] ~= biome or keys_to_skip[cx][cy][i + 1][o + 3] then
        return 3
    end
    if _G.terrain[cx][cy][i + 2][o + 3] ~= biome or keys_to_skip[cx][cy][i + 2][o + 3] then
        return 3
    end
    return 4
end

local function free_multi_tile_terrain(size, keys_to_skip, cx, cy, i, o)
    keys_to_skip[cx][cy][i][o] = false
    secondary_tiles_to_update_in_chunk[cx][cy][i][o] = true
    keys_to_skip[cx][cy][i + 1][o] = false
    secondary_tiles_to_update_in_chunk[cx][cy][i + 1][o] = true
    keys_to_skip[cx][cy][i + 1][o + 1] = false
    secondary_tiles_to_update_in_chunk[cx][cy][i + 1][o + 1] = true
    keys_to_skip[cx][cy][i][o + 1] = false
    secondary_tiles_to_update_in_chunk[cx][cy][i][o + 1] = true
    if size >= 3 then
        keys_to_skip[cx][cy][i + 2][o] = false
        secondary_tiles_to_update_in_chunk[cx][cy][i + 2][o] = true
        keys_to_skip[cx][cy][i + 2][o + 1] = false
        secondary_tiles_to_update_in_chunk[cx][cy][i + 2][o + 1] = true
        keys_to_skip[cx][cy][i + 2][o + 2] = false
        secondary_tiles_to_update_in_chunk[cx][cy][i + 2][o + 2] = true
        keys_to_skip[cx][cy][i][o + 2] = false
        secondary_tiles_to_update_in_chunk[cx][cy][i][o + 2] = true
        keys_to_skip[cx][cy][i + 1][o + 2] = false
        secondary_tiles_to_update_in_chunk[cx][cy][i + 1][o + 2] = true
    end
    if size >= 4 then
        keys_to_skip[cx][cy][i + 3][o] = false
        secondary_tiles_to_update_in_chunk[cx][cy][i + 3][o] = true
        keys_to_skip[cx][cy][i + 3][o + 1] = false
        secondary_tiles_to_update_in_chunk[cx][cy][i + 3][o + 1] = true
        keys_to_skip[cx][cy][i + 3][o + 2] = false
        secondary_tiles_to_update_in_chunk[cx][cy][i + 3][o + 2] = true
        keys_to_skip[cx][cy][i + 3][o + 3] = false
        secondary_tiles_to_update_in_chunk[cx][cy][i + 3][o + 3] = true
        keys_to_skip[cx][cy][i][o + 3] = false
        secondary_tiles_to_update_in_chunk[cx][cy][i][o + 3] = true
        keys_to_skip[cx][cy][i + 1][o + 3] = false
        secondary_tiles_to_update_in_chunk[cx][cy][i + 1][o + 3] = true
        keys_to_skip[cx][cy][i + 2][o + 3] = false
        secondary_tiles_to_update_in_chunk[cx][cy][i + 2][o + 3] = true
    end
end

local function multi_tile_terrain(size, keys_to_skip, cx, cy, i, o, biome)
    keys_to_skip[cx][cy][i][o] = {
        i,
        o,
        ["size"] = 2,
        ["biome"] = biome
    }
    keys_to_skip[cx][cy][i + 1][o] = {i, o}
    keys_to_skip[cx][cy][i + 1][o + 1] = {i, o}
    keys_to_skip[cx][cy][i][o + 1] = {i, o}
    if size >= 3 then
        keys_to_skip[cx][cy][i][o] = {
            i,
            o,
            ["size"] = 3,
            ["biome"] = biome
        }
        keys_to_skip[cx][cy][i + 2][o] = {i, o}
        keys_to_skip[cx][cy][i + 2][o + 1] = {i, o}
        keys_to_skip[cx][cy][i + 2][o + 2] = {i, o}
        keys_to_skip[cx][cy][i][o + 2] = {i, o}
        keys_to_skip[cx][cy][i + 1][o + 2] = {i, o}
    end
    if size >= 4 then
        keys_to_skip[cx][cy][i][o] = {
            i,
            o,
            ["size"] = 4,
            ["biome"] = biome
        }
        keys_to_skip[cx][cy][i + 3][o] = {i, o}
        keys_to_skip[cx][cy][i + 3][o + 1] = {i, o}
        keys_to_skip[cx][cy][i + 3][o + 2] = {i, o}
        keys_to_skip[cx][cy][i + 3][o + 3] = {i, o}
        keys_to_skip[cx][cy][i][o + 3] = {i, o}
        keys_to_skip[cx][cy][i + 1][o + 3] = {i, o}
        keys_to_skip[cx][cy][i + 2][o + 3] = {i, o}
    end
end

local chunks_to_update = {}
local function schedule_terrain_update(cx, cy, i, o)
    tiles_to_update_in_chunk[cx][cy][i][o] = true
    for x = -4, 4 do
        for y = -4, 4 do
            secondary_tiles_to_update_in_chunk[cx][cy][i + x][o + y] = true
        end
    end
    chunks_to_update[string.format("%d_%d", cx, cy)] = {cx, cy}
end

local keys_to_skip = newAutotable(4)

local function update_terrain(chunk_x, chunk_y)
    local cx = chunk_x or _G.current_chunk_x
    local cy = chunk_y or _G.current_chunk_y
    if terrain_batch[chunk_x][chunk_y] == nil then
        terrain_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(terrain_image, chunk_width * chunk_height)
    end
    local l_scale = 1.06
    terrain_batch[chunk_x][chunk_y]:clear()
    for i = 0, chunk_width - 1, 1 do
        for o = 0, chunk_width - 1, 1 do
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
                    if multi_tile_origin.biome ~= current_biome then
                        terrain_tile[cx][cy][cur_idx[1]][cur_idx[2]] = {}
                        free_multi_tile_terrain(multi_tile_origin.size, keys_to_skip, cx, cy, cur_idx[1], cur_idx[2])
                    end
                end
                if keys_to_skip[cx][cy][i][o] then
                    goto continue
                end
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
                end
                local rand = love.math.random(1, upper_border)
                local rand2 = love.math.random(1, upper_border)
                local rand3 = love.math.random(1, upper_border)
                rand = math.max(rand, rand2, rand3)
                local tile_key
                local l_offset_x, l_offset_y = 0, 0
                if rand <= 16 then
                    tile_key = terrain[cx][cy][i][o] .. "_1x1 (" .. tostring(rand) .. ")"
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
                terrain_tile[cx][cy][i][o] = {tile_quads[tile_key], _G.IsoX + (i - o) * tile_width * 0.5 + l_offset_x,
                                              _G.IsoY + (i + o) * tile_height * 0.5 + l_offset_y, 0, l_scale, l_scale}
                terrain_batch[cx][cy]:add(tile_quads[tile_key], _G.IsoX + (i - o) * tile_width * 0.5 + l_offset_x,
                    _G.IsoY + (i + o) * tile_height * 0.5 + l_offset_y, 0, l_scale, l_scale)
            else
                if terrain_tile[cx][cy][i][o] and #terrain_tile[chunk_x][chunk_y][i][o] > 0 then
                    terrain_batch[cx][cy]:add(unpack(terrain_tile[cx][cy][i][o]))
                end
            end
            ::continue::
        end
    end
    for i = 0, chunk_width - 1, 1 do
        for o = 0, chunk_width - 1, 1 do
            if secondary_tiles_to_update_in_chunk[cx][cy][i] and secondary_tiles_to_update_in_chunk[cx][cy][i][o] then
                local current_biome = terrain[cx][cy][i][o]
                local multi_tile_origin
                local this_tile = false
                if keys_to_skip[cx][cy][i][o] then
                    local cur_idx = keys_to_skip[cx][cy][i][o]
                    if cur_idx["size"] then
                        multi_tile_origin = cur_idx
                    else
                        multi_tile_origin = keys_to_skip[cx][cy][cur_idx[1]][cur_idx[2]]
                    end
                    if multi_tile_origin.biome ~= current_biome then
                        terrain_tile[cx][cy][cur_idx[1]][cur_idx[2]] = {}
                        free_multi_tile_terrain(multi_tile_origin.size, keys_to_skip, cx, cy, cur_idx[1], cur_idx[2])
                    end
                end
                if keys_to_skip[cx][cy][i][o] then
                    if multi_tile_origin and multi_tile_origin.size == 2 and this_tile then
                        print("skipping", i, o)
                    end
                    goto end_multi_tile
                end
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
                end
                local rand = love.math.random(1, upper_border)
                local rand2 = love.math.random(1, upper_border)
                local rand3 = love.math.random(1, upper_border)
                rand = math.max(rand, rand2, rand3)
                local tile_key
                local l_offset_x, l_offset_y = 0, 0
                if rand <= 16 then
                    tile_key = terrain[cx][cy][i][o] .. "_1x1 (" .. tostring(rand) .. ")"
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
                terrain_tile[cx][cy][i][o] = {tile_quads[tile_key], _G.IsoX + (i - o) * tile_width * 0.5 + l_offset_x,
                                              _G.IsoY + (i + o) * tile_height * 0.5 + l_offset_y, 0, l_scale, l_scale}
                terrain_batch[cx][cy]:add(tile_quads[tile_key], _G.IsoX + (i - o) * tile_width * 0.5 + l_offset_x,
                    _G.IsoY + (i + o) * tile_height * 0.5 + l_offset_y, 0, l_scale, l_scale)

            else
                if terrain_tile[cx][cy][i][o] and #terrain_tile[chunk_x][chunk_y][i][o] > 0 then
                    terrain_batch[cx][cy]:add(unpack(terrain_tile[cx][cy][i][o]))
                end
            end
            ::end_multi_tile::
        end
    end
    secondary_tiles_to_update_in_chunk[cx][cy] = nil
end

local function refresh_terrain(chunk_x, chunk_y)
    local cx = chunk_x or _G.current_chunk_x
    local cy = chunk_y or _G.current_chunk_y
    if terrain_batch[chunk_x][chunk_y] == nil then
        terrain_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(terrain_image, chunk_width * chunk_height)
    end
    tiles_to_update_in_chunk[cx][cy] = nil
    terrain_batch[chunk_x][chunk_y]:clear()
    for i = 0, chunk_width - 1, 1 do
        for o = 0, chunk_width - 1, 1 do
            if terrain_tile[chunk_x][chunk_y][i][o] and #terrain_tile[chunk_x][chunk_y][i][o] > 0 then
                terrain_batch[cx][cy]:add(unpack(terrain_tile[cx][cy][i][o]))
            end
        end
    end
end

local function update()
    for _, chunk in pairs(chunks_to_update) do
        update_terrain(chunk[1], chunk[2])
        refresh_terrain(chunk[1], chunk[2])
    end
    chunks_to_update = {}
end
local function genTerrain(cx, cy)
    local chunk_x = cx or current_chunk_x
    local chunk_y = cy or current_chunk_y
    if terrain_batch[chunk_x][chunk_y] == nil then
        terrain_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(terrain_image, chunk_width * chunk_height)
    end
    terrain[cx][cy] = newAutotable(2)
    for i = 0, chunk_width - 1, 1 do
        for o = 0, chunk_height - 1, 1 do
            schedule_terrain_update(cx, cy, i, o)
            terrain[cx][cy][i][o] = terrain_biome.abundant_grass
        end
    end
    genObjects(cx, cy) -- TODO OPTIMIZE: move genObjects in this loop so we don't loop twice!
end

local function chunkDraw()
    local tile_start_x, tile_start_y, tile_end_x, tile_end_y = top_left_chunk_x - 1, top_left_chunk_y,
        bottom_right_chunk_x + 1, bottom_right_chunk_y

    local firstRow = math.min(tile_start_x + tile_start_y, tile_end_x + tile_end_y)
    local lastRow = math.max(tile_start_x + tile_start_y, tile_end_x + tile_end_y)

    local firstColumn = math.min(tile_start_x - tile_start_y, tile_end_x - tile_end_y)
    local lastColumn = math.max(tile_start_x - tile_start_y, tile_end_x - tile_end_y)

    for row = firstRow, lastRow do
        local shift = bit.band(bit.bxor(row, firstColumn), 1)
        for column = firstColumn + shift, lastColumn, 2 do
            local xx, yy = bit.rshift(row + column, 1), bit.rshift(row - column, 1)
            if terrain_batch[xx][yy] ~= nil then
                love.graphics.draw(terrain_batch[xx][yy], -view_xview * scale_x + (xx * scale_x - yy * scale_x) *
                    chunk_width * tile_width * 0.5,
                    -view_yview * scale_x + (xx * scale_x + yy * scale_x) * chunk_height * tile_height * 0.5, 0,
                    scale_x, scale_y)
            end
        end
    end
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

local function genMap()
    genForest()
    repeat
        _G.stone_gen = {}
        local stones = genStone()
    until stones > 400 -- and stones < 550
    repeat
        _G.iron_gen = {}
        local iron = genIron()
    until iron > 100 and iron < 250
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

