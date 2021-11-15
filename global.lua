----Setup
math.randomseed(os.time())
math.random()
math.random()
math.random()
local ffi = require("ffi")
local bitser = require('libraries.bitser')
local tile_quads = require('objects.object_quads')
PROF_CAPTURE = false
prof = require("libraries.jprof")
prof.connect()

top_left_chunk_x = 0
top_left_chunk_y = 0
bottom_right_chunk_x = 0
bottom_right_chunk_y = 0
----Functions
function limitfps()
    -- LIMIT THE FPS TO 60, GOES IN DRAW EVENT
    local cur_time = love.timer.getTime()
    if next_time <= cur_time then
        next_time = cur_time
        return
    end
    love.timer.sleep(next_time - cur_time)
end

function reverse(t)
    local n = #t
    local i = 1
    while i < n do
        t[i], t[n] = t[n], t[i]
        i = i + 1
        n = n - 1
    end
    return t
end

function TileSitesInRectangle(tile_start, tile_end)

    local function Row(tile)
        return tile.x + tile.y
    end

    local function Column(tile)
        return tile.x - tile.y
    end

    local function TileSiteAt(row, column)
        local x = bit.rshift(row + column, 1)
        local y = bit.rshift(row - column, 1)
        return {
            x = x,
            y = y
        }
    end

    local firstRow = math.min(Row(tile_start), Row(tile_end))
    local lastRow = math.max(Row(tile_start), Row(tile_end))

    local firstColumn = math.min(Column(tile_start), Column(tile_end))
    local lastColumn = math.max(Column(tile_start), Column(tile_end))

    local result = {}
    for row = firstRow, lastRow do
        local shift = bit.band(bit.bxor(row, firstColumn), 1)
        for column = firstColumn + shift, lastColumn, 2 do
            result[#result + 1] = TileSiteAt(row, column)
        end
    end
    return result
end

function _G.indexBuildingQuads(quad_string, trim_last, last_width_offset)
    trim_last = trim_last or last_width_offset or false
    last_width_offset = last_width_offset or 0
    if trim_last and last_width_offset == 0 then
        last_width_offset = 8
    end
    -- TODO: Probably wont work for non-square buildings
    local result_array = {}
    local quad = tile_quads[quad_string]
    local x, y, w, h = quad:getViewport()
    local total_tiles_wide = math.ceil(w / _G.tile_width)
    local middle_count = 0
    for i = 1, total_tiles_wide - 1 do
        result_array[#result_array + 1] = love.graphics.newQuad(x + 16 * (i - 1), y, _G.tile_width / 2, h, imageW,
            imageH)
        middle_count = i
    end
    result_array[#result_array + 1] = love.graphics
                                          .newQuad(x + 16 * (middle_count), y, _G.tile_width, h, imageW, imageH)
    for i = middle_count + 2, middle_count + total_tiles_wide do
        if trim_last and i == middle_count + total_tiles_wide then
            result_array[#result_array + 1] = love.graphics.newQuad(x + 16 * (i), y,
                _G.tile_width / 2 - last_width_offset, h, imageW, imageH)
        else
            result_array[#result_array + 1] = love.graphics.newQuad(x + 16 * (i), y, _G.tile_width / 2, h, imageW,
                imageH)
        end
    end

    return total_tiles_wide - 1, result_array
end

function indexQuads(string, end_amount, start, reverse)
    local start = start or 1
    local temp_array = {}
    for i = start, end_amount do
        temp_array[#temp_array + 1] = tile_quads[string .. " (" .. tostring(i) .. ")"]
    end
    if reverse then
        for i = 2, end_amount do
            temp_array[#temp_array + 1] = tile_quads[string .. " (" .. tostring(end_amount - i) .. ")"]
        end
    end
    return temp_array
end

function printList(list)
    local l = list
    while l do
        print("Chunk: " .. (l.chunkx or "none") .. "|" .. (l.chunky or "none"))
        l = l.next
    end
end

function newAutotable(dim)
    local MT = {}
    for i = 1, dim do
        MT[i] = {
            __index = function(t, k)
                if i < dim then
                    t[k] = setmetatable({}, MT[i + 1])
                    return t[k]
                end
            end
        }
    end

    return setmetatable({}, MT[1])
end

function listInsert(list, key1, value1, key2, value2)
    list = {
        next = list,
        key1 = value1,
        key2 = value2
    }
end
terrain_chunks = nil
----Tiles
_G.vertices_per_tile = 4
function _G.getFreeVertexFromTile(cx, cy, local_x, local_y, last_vertex_first)
    last_vertex_first = last_vertex_first or false
    local vert_id = _G.vertices_per_tile * (local_x + local_y * chunk_width) + 1
    chunk_vertices = _G.object_mesh_vert_id_map[cx][cy]
    if chunk_vertices then
        if last_vertex_first then
            for i = 0, _G.vertices_per_tile - 1 do
                if not chunk_vertices[vert_id + i] then
                    _G.object_mesh_vert_id_map[cx][cy][vert_id + i] = true
                    return vert_id + i
                end
            end
        else
            for i = _G.vertices_per_tile - 1, 0, -1 do
                if not chunk_vertices[vert_id + i] then
                    _G.object_mesh_vert_id_map[cx][cy][vert_id + i] = true
                    return vert_id + i
                end
            end
        end
    end
    return false
end

function _G.freeVertexFromTile(cx, cy, vert_id)
    if not vert_id then
        return
    end
    chunk_vertices = _G.object_mesh_vert_id_map[cx][cy]
    if chunk_vertices then
        _G.object_mesh[cx][cy]:setVertex(vert_id)
        chunk_vertices[vert_id] = false
    else
        return true
    end
end
tile_width = 32
tile_height = 16
----Chunks
xchunk = 0
ychunk = 0
chunk_width = 64
chunk_height = 64
chunks_wide = 8
chunks_high = 8
current_chunk_x = 0
current_chunk_y = 0
CenterX = 0
CenterY = 0
previous_chunk_x = 0
previous_chunk_y = 0
chunkUpdateList = function()
end
previous_terrain_chunks = 0
----Terrain
_G.terrain = newAutotable(2)
if love.filesystem.getInfo and love.filesystem.getInfo("status.bin") then
    status = bitser.loadLoveFile("status.bin")
else
    status = newAutotable(2)
end
_G.chunk_objects = newAutotable(2)
----Offset
IsoX = 0
IsoY = -1400
----View
scale_x = 1
scale_y = 1
scroll_speed = 10
window_width, window_height = love.window.getMode()
view_xview = -100
view_yview = 4000
----Mouse
mx = 0
my = 0
LocalX = 0
LocalY = 0
time = 0
dttime = 0
lx_offset = 0
ly_offset = 0
px_img_y_offset = 0
tile_image = {}
----Version, title and window information
width, height, flags = love.window.getMode()
width = width or 1
height = height or 1
min_dt = 1 / 60
next_time = 0
----Objects related    
tile_offset, tile_offset_x = {}, {}
wood = 10
----Pathfinding data structures
_G.channel = {}
_G.channel.request = love.thread.getChannel("request")
_G.channel.receive = love.thread.getChannel("receive")
_G.channel.map_update = love.thread.getChannel("map_update")
function setWalkable(gx, gy, walkable)
    _G.channel.map_update:push({gx, gy, walkable})
end
collision_map = ffi.new("unsigned char[2048][2048]", {})
height_map = ffi.new("unsigned short[2048][2048]", {})
function setHeight(gx, gy, height)
    height_map[gx][gy] = height
end
----Resources
resources = {
    ['wood'] = 0,
    ['stone'] = 0,
    ['iron'] = 0,
    ['flour'] = 0,
    ['wheat'] = 0
}
food = {
    ["apples"] = 0,
    ["bread"] = 0,
    ["cheese"] = 0
}
not_full_stockpiles = {
    ["wood"] = 0,
    ["stone"] = 0,
    ["wheat"] = 0,
    ["iron"] = 0,
    ["flour"] = 0
}
not_full_foods = {
    ["apples"] = 0,
    ["bread"] = 0,
    ["cheese"] = 0
}
_G.wheat_season_counter = 0
_G.wheat_growing_season = false
----Libraries        
anim = require('libraries.anim8')
class = require('libraries.middleclass')
inspect = require('libraries.inspect')

function _G.string.starts_with(str, start)
    return str:sub(1, #start) == start
end

function _G.string.ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end
