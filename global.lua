math.randomseed(os.time())
math.random()
math.random()
math.random()

local tile_quads = require('objects.object_quads')
_G.classes = {}
_G.anim = require('libraries.anim8')
_G.class = require('libraries.middleclass')
_G.inspect = require('libraries.inspect')
_G.ffi = require("ffi")
_G.PROF_CAPTURE = false
_G.prof = require("libraries.jprof")
_G.prof.connect()
_G.MAX_FPS = 60

function _G.reverse(t)
    local n = #t
    local i = 1
    while i < n do
        t[i], t[n] = t[n], t[i]
        i = i + 1
        n = n - 1
    end
    return t
end

function _G.getClassByName(class_name)
    return _G.classes[class_name]
end

function _G.indexBuildingQuads(quad_string, trim_last, last_width_offset)
    trim_last = trim_last or last_width_offset or false
    last_width_offset = last_width_offset or 0
    if trim_last and last_width_offset == 0 then
        last_width_offset = 8
    end
    -- NOTE: Probably wont work for non-square buildings
    local result_array = {}
    local quad = tile_quads[quad_string]
    local x, y, w, h = quad:getViewport()
    local total_tiles_wide = math.ceil(w / _G.tile_width)
    local middle_count = 0
    for i = 1, total_tiles_wide - 1 do
        result_array[#result_array + 1] = love.graphics.newQuad(x + 16 * (i - 1), y, _G.tile_width / 2, h, _G.imageW,
            _G.imageH)
        middle_count = i
    end
    result_array[#result_array + 1] = love.graphics.newQuad(x + 16 * (middle_count), y, _G.tile_width, h, _G.imageW,
        _G.imageH)
    for i = middle_count + 2, middle_count + total_tiles_wide do
        if trim_last and i == middle_count + total_tiles_wide then
            result_array[#result_array + 1] = love.graphics.newQuad(x + 16 * (i), y,
                _G.tile_width / 2 - last_width_offset, h, _G.imageW, _G.imageH)
        else
            result_array[#result_array + 1] = love.graphics.newQuad(x + 16 * (i), y, _G.tile_width / 2, h, _G.imageW,
                _G.imageH)
        end
    end

    return total_tiles_wide - 1, result_array
end

function _G.indexQuads(string, end_amount, start, reverse)
    start = start or 1
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

function _G.newAutotable(dim)
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

----Tiles
function _G.getFreeVertexFromTile(cx, cy, local_x, local_y, last_vertex_first)
    last_vertex_first = last_vertex_first or false
    local vert_id = _G.state.vertices_per_tile * (local_x + local_y * chunk_width) + 1
    local chunk_vertices = _G.state.object_mesh_vert_id_map[cx][cy]
    if last_vertex_first then
        for i = 2, _G.state.vertices_per_tile - 1 do
            if not chunk_vertices[vert_id + i] then
                _G.state.object_mesh_vert_id_map[cx][cy][vert_id + i] = true
                return vert_id + i
            end
        end
    else
        for i = _G.state.vertices_per_tile - 1, 2, -1 do
            if not chunk_vertices[vert_id + i] then
                _G.state.object_mesh_vert_id_map[cx][cy][vert_id + i] = true
                return vert_id + i
            end
        end
    end
    return false
end

function _G.getTerrainVertex(cx, cy, local_x, local_y)
    local vert_id = _G.state.vertices_per_tile * (local_x + local_y * chunk_width) + 2
    _G.state.object_mesh_vert_id_map[cx][cy][vert_id] = true
    return vert_id
end

function _G.getChevronVertex(cx, cy, local_x, local_y)
    local vert_id = _G.state.vertices_per_tile * (local_x + local_y * chunk_width) + 1
    _G.state.object_mesh_vert_id_map[cx][cy][vert_id] = true
    return vert_id
end

function _G.freeVertexFromTile(cx, cy, vert_id)
    if not vert_id then
        return
    end
    chunk_vertices = _G.state.object_mesh_vert_id_map[cx][cy]
    if chunk_vertices then
        _G.state.object_mesh[cx][cy]:setVertex(vert_id)
        chunk_vertices[vert_id] = false
    else
        return true
    end
end
_G.tile_width = 32
_G.tile_height = 16
_G.chunk_width = 64
_G.chunk_height = 64
-- UI
_G.TOOLTIP_DELAY = 0.1
----Chunks
_G.xchunk = 0
_G.ychunk = 0
_G.chunks_wide = 8
_G.chunks_high = 8
_G.current_chunk_x = 0
_G.current_chunk_y = 0
_G.CenterX = 0
_G.CenterY = 0
_G.previous_chunk_x = 0
_G.previous_chunk_y = 0
_G.previous_terrain_chunks = 0
----Terrain
-- if love.filesystem.getInfo and love.filesystem.getInfo("status.bin") then
--     print("Save file found..")
--     _G.state = State.load("status.bin")
-- else
--     print("No save file, starting new game..")
-- end
----Offset
_G.IsoX = 0
_G.IsoY = -1400
----View
_G.scroll_speed = 10
_G.window_width, _G.window_height = love.window.getMode()
----Mouse
_G.mx = 0
_G.my = 0
_G.LocalX = 0
_G.LocalY = 0
----Version, title and window information
local _
_G.ScreenWidth, _G.ScreenHeight, _ = love.window.getMode()
----Pathfinding data structures
_G.channel = {}
_G.channel.request = love.thread.getChannel("request")
_G.channel.receive = love.thread.getChannel("receive")
_G.channel.map_update = love.thread.getChannel("map_update")
_G.channel2 = {}
_G.channel2.map_update = love.thread.getChannel("map_update2")

----Resources
----Libraries

function _G.string.starts_with(str, start)
    return str:sub(1, #start) == start
end

function _G.string.ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function _G.play_sfx(obj, sfx)
    if type(sfx) == "table" then
        sfx = sfx[math.random(#sfx)]
    end
    sfx:setRelative(false)
    sfx:setPosition((obj.x + (obj.cx - obj.cy) * _G.chunk_width * _G.tile_width * 0.5) / 100,
        (obj.y + (obj.cx + obj.cy) * _G.chunk_height * _G.tile_height * 0.5) / 100, 4.1)
    sfx:setPitch(1 + love.math.random(-10, 10) / 100)
    sfx:play()
end

function _G.manual_gc(time_budget, safetynet_megabytes, disable_otherwise)
    local max_steps = 1000
    local steps = 0
    local start_time = love.timer.getTime()
    while love.timer.getTime() - start_time < time_budget do
        collectgarbage("step", 1)
        steps = steps + 1
    end
    -- safety net
    if safetynet_megabytes and collectgarbage("count") / 1024 > safetynet_megabytes then
        collectgarbage("collect")
    end
    -- don't collect gc outside this margin
    if disable_otherwise then
        collectgarbage("stop")
    end
end
