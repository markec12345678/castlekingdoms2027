local first_location_x, first_location_y, last_location_x, last_location_y = 0
local location_distance = 0
local angle, first = 0, 0
local ffi = require('ffi')

-- Terrain Initialize
----Rows and columns
local cols = chunk_width
local rows = chunk_height
----Chunk 2D array
-- Statuses: 
-- [1] loaded unsaved
-- [2] unloaded - chunk exist on hard disk
-- [3] loaded saved - chunk hasn't been changed so no need to save it
-- nil - chunk needs to be generated first

----Generate spriteBatch
local terrain_image = love.graphics.newImage("assets/tiles/image_strip.png")
terrain_image:setFilter('nearest', 'nearest')
local tile_quads = {}
local tile_offset = {}
local imageW, imageH = terrain_image:getWidth(), terrain_image:getHeight()
tile_quads[1] = love.graphics.newQuad(724, 1850, 29, 20, imageW, imageH)
tile_offset[1] = 5
tile_offset[2] = 5
tile_offset[3] = 5
tile_offset[4] = 5
tile_offset[5] = 5
tile_offset[6] = 0
tile_offset[7] = 0
tile_offset[8] = 0
tile_offset[9] = 0
tile_offset[10] = 0
tile_quads[2] = love.graphics.newQuad(724 + 30 + 2, 1850, 30, 20, imageW, imageH)
tile_quads[3] = love.graphics.newQuad(724 + 30 * 2 + 2 * 2, 1850, 30, 20, imageW, imageH)
tile_quads[4] = love.graphics.newQuad(724 + 30 * 3 + 2 * 3, 1850, 30, 20, imageW, imageH)
tile_quads[5] = love.graphics.newQuad(724 + 30 * 4 + 2 * 4, 1850, 30, 20, imageW, imageH)
-- tile_quads[6] = love.graphics.newQuad(724, 1891, 30, 16, imageW,imageH)
-- tile_quads[7] = love.graphics.newQuad(724+30+2, 1891, 30, 16, imageW,imageH)
-- tile_quads[8] = love.graphics.newQuad(724+30*2+2*2, 1891, 30, 16, imageW,imageH)
-- tile_quads[9] = love.graphics.newQuad(724+30*3+2*4, 1891, 30, 16, imageW,imageH)
-- tile_quads[10] = love.graphics.newQuad(724+30*3+2*4, 1891, 30, 16, imageW,imageH)
tile_quads[11] = love.graphics.newQuad(420, 1850, 30, 107, imageW, imageH)
tile_offset[11] = 107 - 16
tile_quads[12] = love.graphics.newQuad(450, 1850, 30, 107, imageW, imageH)
tile_offset[12] = 107 - 16
tile_quads[6] = love.graphics.newQuad(724, 1909, 30, 16, imageW, imageH)
tile_quads[7] = love.graphics.newQuad(724 + 30 + 2, 1909, 30, 16, imageW, imageH)
tile_quads[8] = love.graphics.newQuad(724 + 30 * 2 + 2 * 2, 1909, 30, 16, imageW, imageH)
tile_quads[9] = love.graphics.newQuad(724 + 30 * 3 + 2 * 4, 1909, 30, 16, imageW, imageH)
tile_quads[10] = love.graphics.newQuad(724 + 30 * 3 + 2 * 4, 1909, 30, 16, imageW, imageH)
local terrain_batch = newAutotable(2)
terrain_batch[0][0] = love.graphics.newSpriteBatch(terrain_image, chunk_width * chunk_height)

function getTerrainChunk()
    return chunk or {}
end

function getLocationDistance()
    return location_distance or 0
end

function update_terrain(chunk_x, chunk_y)
    local chunk_x = chunk_x or current_chunk_x
    local chunk_y = chunk_y or current_chunk_y
    if terrain_batch[chunk_x][chunk_y] == nil then
        terrain_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(terrain_image, chunk_width * chunk_height)
    end
    terrain_batch[chunk_x][chunk_y]:clear()
    for i = 0, chunk_width - 1, 1 do
        for o = 0, chunk_width - 1, 1 do
            terrain_batch[chunk_x][chunk_y]:add(tile_quads[terrain[chunk_x][chunk_y][i][o]],
                IsoX + (i - o) * tile_width * 0.5, IsoY + (i + o) * tile_height * 0.5 -
                    (tile_offset[terrain[chunk_x][chunk_y][i][o]] or 0), 0, 1.06666, 1)
        end
    end
end

local function genTerrain(cx, cy)
    local chunk_x = cx or current_chunk_x
    local chunk_y = cy or current_chunk_y
    if terrain_batch[chunk_x][chunk_y] == nil then
        terrain_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(terrain_image, chunk_width * chunk_height)
    end

    terrain_batch[chunk_x][chunk_y]:clear()
    terrain[cx][cy] = ffi.new("unsigned char[64][64]", {})
    for i = 0, chunk_width - 1, 1 do
        for o = 0, chunk_height - 1, 1 do
            local rand = math.round(love.math.noise(i, o) * 4) + 1
            terrain[cx][cy][i][o] = rand
            terrain_batch[chunk_x][chunk_y]:add(tile_quads[rand], IsoX + (i - o) * tile_width * 0.5, IsoY + (i + o) *
                tile_height * 0.5 - (tile_offset[terrain[chunk_x][chunk_y][i][o]] or 0), 0, 1.06666, 1)
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

local last_cx, last_cy = nil, nil
function terrainSetTileAt(gx, gy, tile)
    local i = (gx) % (chunk_width)
    local o = (gy) % (chunk_width)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    if terrain[cx] and terrain[cx][cy] then
        terrain[cx][cy][i][o] = tile
        if cx ~= last_cx or cy ~= last_cy then
            update_terrain(last_cx, last_cy)
        end
        last_cx, last_cy = cx, cy
        return cx, cy
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

    forest_update_counter = 0
    forest_update_limit = 3

    repeat
        print("updating")
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

local function genMap()
    -- FIXME MAGIC NUMBERS
    genForest()
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
    update_terrain = update_terrain,
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

