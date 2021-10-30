local object_image = ...
local newAutotable = _G.newAutotable
local ScreenToIsoX, ScreenToIsoY = _G.ScreenToIsoX, _G.ScreenToIsoY
local chunk_width, chunk_height = _G.chunk_width, _G.chunk_height
local tile_width, tile_height = _G.tile_width, _G.tile_height
local love = _G.love
local bit = _G.bit
local prof = require("libraries.jprof")
local inspect = require("libraries.inspect")
-- Declarations
----Library setup
-- local bitser = require("libraries.bitser")
----Direction and distance
local quad_offset = require('objects.quad_offset')
----Location thing
local location = {
    gx = 0,
    gy = 0,
    x = 0,
    y = 0,
    cx = 0,
    cy = 0
}
function location:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
local press = location:new()
----Rows and columns
----Chunk 2D array
local active_objects = newAutotable(1)
local active_entities = newAutotable(1)
_G.active_chunks = {}
local object = newAutotable(4)
----Calculate center chunk
local CenterX = math.round(ScreenToIsoX(_G.width / 2 - 16 + _G.view_xview, _G.height / 2 - 8 + _G.view_yview));
local CenterY = math.round(ScreenToIsoY(_G.width / 2 - 16 + _G.view_xview, _G.height / 2 - 8 + _G.view_yview))
---------------------------------------
_G.xchunk = math.floor(CenterX / (chunk_width))
_G.ychunk = math.floor(CenterY / (chunk_width))
----Generate spriteBatch
local object_batch = newAutotable(2)
local shadow_batch = newAutotable(2)
-- local canvas = love.graphics.newCanvas()
if not _G.test_mode then
    object_image:setFilter('nearest', 'nearest')
end
local tile_quads = require('objects.object_quads')

--- NOTE Object classes START ---
--- NOTE --------------------------
--- NOTE --------------------------
local Unit = love.filesystem.load('objects/Units/Unit.lua')(active_entities, object_batch)
package.loaded['objects.Units.Unit'] = Unit

local Tree = love.filesystem.load('objects/Environment/Tree.lua')(object_batch, active_objects, tile_quads, object)
local PineTree = love.filesystem.load('objects/Environment/PineTree.lua')(object_batch, active_objects, tile_quads,
    object, Tree)
local OakTree = love.filesystem.load('objects/Environment/OakTree.lua')(object_batch, active_objects, tile_quads,
    object, Tree)
local Shrub = love.filesystem.load('objects/Environment/Shrub.lua')(object_batch, active_objects, tile_quads, object)
local Woodcutter = love.filesystem.load('objects/Units/Woodcutter.lua')(object, tile_quads)
local Stonemason = love.filesystem.load('objects/Units/Stonemason.lua')(object, tile_quads)
local Peasant = love.filesystem.load('objects/Units/Peasant.lua')(object, tile_quads)
local OrchardFarmer = love.filesystem.load('objects/Units/OrchardFarmer.lua')(object, tile_quads)
local WheatFarmer = love.filesystem.load('objects/Units/WheatFarmer.lua')(object, tile_quads)
local Miner = love.filesystem.load('objects/Units/Miner.lua')(object, tile_quads)
local Castle = love.filesystem.load('objects/Structures/Castle.lua')(object, tile_quads)
local Stockpile = love.filesystem.load('objects/Structures/Stockpile.lua')(object, tile_quads, object_batch)
local Granary = love.filesystem.load('objects/Structures/Granary.lua')(object, tile_quads, object_batch)
local Quarry = love.filesystem.load('objects/Structures/Quarry.lua')(active_entities, object, tile_quads, object_batch)
local Mine = love.filesystem.load('objects/Structures/Mine.lua')(active_entities, object, tile_quads, object_batch)
local WoodcutterHut = love.filesystem.load('objects/Structures/WoodcutterHut.lua')(active_entities, object, tile_quads,
    object_batch)
local WoodenWall = love.filesystem.load('objects/Structures/WoodenWall.lua')(active_entities, object, tile_quads,
    object_batch)
local WoodenWallWalkable = love.filesystem.load('objects/Structures/WoodenWallWalkable.lua')(active_entities, object,
    tile_quads, object_batch)
local WoodenTower = love.filesystem.load('objects/Structures/WoodenTower.lua')(active_entities, object, tile_quads,
    object_batch)
local Campfire = love.filesystem.load('objects/Structures/Campfire.lua')(object, tile_quads, object_batch)
local Orchard = love.filesystem.load('objects/Structures/Orchard.lua')(object, tile_quads, object_batch)
local WheatFarm = love.filesystem.load('objects/Structures/WheatFarm.lua')(object, tile_quads, object_batch)
package.loaded['objects.Environment.Tree'] = Tree
package.loaded['objects.Environment.PineTree'] = PineTree
package.loaded['objects.Environment.OakTree'] = OakTree
package.loaded['objects.Environment.Shrub'] = Shrub
package.loaded['objects.Units.Woodcutter'] = Woodcutter
package.loaded['objects.Units.Stonemason'] = Stonemason
package.loaded['objects.Units.Peasant'] = Peasant
package.loaded['objects.Units.OrchardFarmer'] = OrchardFarmer
package.loaded['objects.Units.WheatFarmer'] = WheatFarmer
package.loaded['objects.Units.Miner'] = Miner
package.loaded['objects.Structures.Castle'] = Castle
package.loaded['objects.Structures.Stockpile'] = Stockpile
package.loaded['objects.Structures.Granary'] = Granary
package.loaded['objects.Structures.Quarry'] = Quarry
package.loaded['objects.Structures.Mine'] = Mine
package.loaded['objects.Structures.WoodcutterHut'] = WoodcutterHut
package.loaded['objects.Structures.WoodenWall'] = WoodenWall
package.loaded['objects.Structures.WoodenWallWalkable'] = WoodenWallWalkable
package.loaded['objects.Structures.WoodenTower'] = WoodenTower
package.loaded['objects.Structures.Campfire'] = Campfire
package.loaded['objects.Structures.Orchard'] = Orchard
package.loaded['objects.Structures.WheatFarm'] = WheatFarm
_G.stockpile = require('objects.Controllers.StockpileController')
_G.foodpile = require('objects.Controllers.FoodController')
--- NOTE --------------------------
--- NOTE --------------------------
--- NOTE Object classes END ---

function addObjectAt(cx, cy, x, y, object_to_add)
    if type(object[cx][cy][x][y]) ~= 'table' then
        object[cx][cy][x][y] = {}
    end
    object[cx][cy][x][y][#object[cx][cy][x][y] + 1] = object_to_add
    return object_to_add
end

object_image:setWrap("clampzero")
_G.object_mesh = newAutotable(2)

function removeObjectAt(cx, cy, x, y, object_to_remove)
    if type(object[cx][cy][x][y]) == 'table' then
        if object_to_remove then
            for index, current_object in ipairs(object[cx][cy][x][y]) do
                if current_object == object_to_remove then
                    table.remove(object[cx][cy][x][y], index)
                    break
                end
            end
        else
            for _, current_object in ipairs(object[cx][cy][x][y]) do
                current_object:destroy()
            end
            object[cx][cy][x][y] = {}
        end
    end
end

function objectFromTypeAt(cx, cy, x, y, obj_type)
    if type(object[cx][cy][x][y]) == 'table' then
        for _, current_object in ipairs(object[cx][cy][x][y]) do
            if (current_object.type and current_object.type == obj_type) or current_object.class.name == obj_type then
                return current_object
            end
        end
    end
    return false
end

function isObjectAt(cx, cy, x, y, object_compared)
    if type(object[cx][cy][x][y]) == 'table' then
        for _, current_object in ipairs(object[cx][cy][x][y]) do
            if current_object == object_compared then
                return current_object
            end
        end
    end
    return false
end

function objectAt(cx, cy, x, y)
    if (type(object[cx][cy][x][y]) == 'table' and next(object[cx][cy][x][y]) == nil) or not object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") then
        return false
    else
        return true
    end
end

function importantObjectAt(cx, cy, x, y)
    if (type(object[cx][cy][x][y]) == 'table' and next(object[cx][cy][x][y]) == nil) or not object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") or objectFromTypeAt(cx, cy, x, y, "Tall shrub") or
        objectFromTypeAt(cx, cy, x, y, "Short shrub") then
        return false
    else
        return true
    end
end

function importantObjectAtGlobal(gx, gy)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    local x = (gx) % (chunk_width)
    local y = (gy) % (chunk_width)
    if (type(object[cx][cy][x][y]) == 'table' and next(object[cx][cy][x][y]) == nil) or not object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") or objectFromTypeAt(cx, cy, x, y, "Tall shrub") or
        objectFromTypeAt(cx, cy, x, y, "Short shrub") then
        return false
    else
        return true
    end
end

function clearEnvironmentObjectAtGlobal(gx, gy)
    -- TODO: finish
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    local x = (gx) % (chunk_width)
    local y = (gy) % (chunk_width)
    if (type(object[cx][cy][x][y]) == 'table' and next(object[cx][cy][x][y]) == nil) or not object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") or objectFromTypeAt(cx, cy, x, y, "Tall shrub") or
        objectFromTypeAt(cx, cy, x, y, "Short shrub") then
        return false
    else
        return true
    end
end

function objectAtGlobal(gx, gy)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    local x = (gx) % (chunk_width)
    local y = (gy) % (chunk_width)
    if (type(object[cx][cy][x][y]) == 'table' and next(object[cx][cy][x][y]) == nil) or not object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") then
        return false
    else
        return true
    end
end

function genObjects(cx, cy)
    local chunk_x = cx or _G.current_chunk_x
    local chunk_y = cy or _G.current_chunk_y

    local treeverts = {{0, 0, 0, 0, 1.0, 1.0, 1.0, 1.0}, {1, 0, 1, 0, 1.0, 1.0, 1.0, 1.0},
                       {0, 1, 0, 1, 1.0, 1.0, 1.0, 1.0}, {1, 1, 1, 1, 1.0, 1.0, 1.0, 1.0}}
    if object_batch[chunk_x][chunk_y] == nil then
        object_batch[chunk_x][chunk_y] = love.graphics.newMesh(treeverts, "strip", "static")
    end
    local instancemesh = love.graphics.newMesh({{"InstancePosition", "float", 2}, {"UVOffset", "float", 2},
                                                {"ImageDim", "float", 2}}, 4096, nil, "dynamic")
    for i = 0, chunk_width - 1, 1 do
        for o = 0, chunk_height - 1, 1 do
            local gx = chunk_width * cx + i
            local gy = chunk_width * cy + o
            local tree_generated = false
            if _G.forest_gen[math.round((gx) / 8) + 1][math.round((gy) / 8) + 1] ~= false then
                _G.terrainSetTileAt(gx, gy, _G.terrain_biome.scarce_grass)
                local rand = math.random(5)
                if rand ~= 3 then
                    goto continue
                end
                if objectAtGlobal(gx, gy + 1) then
                    goto continue
                end
                if objectAtGlobal(gx, gy - 1) then
                    goto continue
                end
                if objectAtGlobal(gx + 1, gy + 1) then
                    goto continue
                end
                if objectAtGlobal(gx + 1, gy) then
                    goto continue
                end
                if objectAtGlobal(gx + 1, gy - 1) then
                    goto continue
                end
                if objectAtGlobal(gx - 1, gy + 1) then
                    goto continue
                end
                if objectAtGlobal(gx - 1, gy) then
                    goto continue
                end
                if objectAtGlobal(gx - 1, gy - 1) then
                    goto continue
                end
                local rand = math.random(2)
                if rand ~= 2 then
                    goto continue
                end
                if love.math.random(1, 25) == 1 then
                    PineTree:new(gx, gy, "Dead pine tree")
                else
                    local tree = PineTree:new(gx, gy, "Pine tree")
                    tree.animation:gotoFrame(math.random(1, 20))
                end
                tree_generated = true
            elseif not tree_generated then
                if objectAtGlobal(gx, gy - 1) then
                    goto continue
                end
                local chance = 0
                for sx = -1, 1 do
                    for sy = -1, 1 do
                        if _G.forest_gen[math.round((gx) / 8) + 1 + sx] and
                            _G.forest_gen[math.round((gx) / 8) + 1 + sx][math.round((gy) / 8) + 1 + sy] == true then
                            chance = chance + 1
                        end
                    end
                end
                if chance > 0 then
                    local rand = math.random(20 - chance)
                    if rand ~= 3 and rand ~= 5 then
                        if rand == 4 then
                            local shrub = Shrub:new(gx, gy, "Tall shrub")
                            shrub.animation:gotoFrame(math.random(1, 20))
                        end
                        goto continue
                    end
                    local tree = PineTree:new(gx, gy, "Medium pine tree")
                    tree.animation:gotoFrame(math.random(1, 20))
                    tree_generated = true
                    goto continue
                else
                    for sx = -2, 2 do
                        for sy = -2, 2 do
                            if _G.forest_gen[math.round((gx) / 8) + 1 + sx] and
                                _G.forest_gen[math.round((gx) / 8) + 1 + sx][math.round((gy) / 8) + 1 + sy] == true then
                                chance = chance + 1
                            end
                        end
                    end
                end
                if chance > 0 then
                    local rand = math.random(30 - chance)
                    if rand ~= 3 then
                        if rand == 4 then
                            local tree = PineTree:new(gx, gy, "Very small pine tree")
                            tree.animation:gotoFrame(math.random(1, 20))
                        end
                        if rand == 5 then
                            local shrub = Shrub:new(gx, gy, "Tall shrub")
                            shrub.animation:gotoFrame(math.random(1, 20))
                        end
                        goto continue
                    end
                    local tree = PineTree:new(gx, gy, "Small pine tree")
                    tree.animation:gotoFrame(math.random(1, 20))
                    tree_generated = true
                    goto continue
                end
                if not tree_generated and love.math.random(1000) == 4 then
                    local tree = PineTree:new(gx, gy, "Small pine tree")
                    tree.animation:gotoFrame(math.random(1, 20))
                    tree_generated = true
                end
                if not tree_generated and love.math.random(800) == 4 then
                    local shrub = Shrub:new(gx, gy, "Short shrub")
                    shrub.animation:gotoFrame(math.random(1, 20))
                end
            end
            if objectAt(cx, cy, i, o) then
                local n = 0
                for _, ob in ipairs(object[cx][cy][i][o]) do
                    n = n + 1
                    if n > 1 then
                        print("More than one!", ob.type)
                    end
                    if ob.animated then
                        local offset_x, offset_y = 0, 0
                        if quad_offset[ob.animation:getQuad()] then
                            offset_x, offset_y = quad_offset[ob.animation:getQuad()][1] or 0,
                                quad_offset[ob.animation:getQuad()][2] or 0
                        end
                        local quad, x, y, _, _, _, _, _, _, _ =
                            ob.animation:getFrameInfo(ob.x + (ob.offset_x or 0) + offset_x, ob.y + (ob.offset_y or 0) +
                                offset_y - _G.height_map[ob.gx][ob.gy])
                        local qx, qy, qw, qh = quad:getViewport()
                        ob.vert_id = (i + o * chunk_width) + 1
                        ob.instancemesh = instancemesh
                        instancemesh:setVertex(ob.vert_id, x, y, qx, qy, qw, qh)
                        ob.vert_data = {x, y, qx, qy, qw, qh}
                    end
                end
            end
            ::continue::
        end
    end
    object_batch[chunk_x][chunk_y]:setTexture(object_image)
    object_batch[chunk_x][chunk_y]:attachAttribute("InstancePosition", instancemesh, "perinstance")
    object_batch[chunk_x][chunk_y]:attachAttribute("UVOffset", instancemesh, "perinstance")
    object_batch[chunk_x][chunk_y]:attachAttribute("ImageDim", instancemesh, "perinstance")
    _G.object_mesh[chunk_x][chunk_y] = instancemesh
end

local flag = 0
local low_prio_chunks = _G.newAutotable(2)
function update_objects(cx, cy, low_priority)
    -- REMOVE: Deprecated
    local chunk_x = cx or _G.current_chunk_x
    local chunk_y = cy or _G.current_chunk_y
    if chunk_x < 0 or chunk_y < 0 or chunk_x > _G.chunks_wide or chunk_y > _G.chunks_high then
        return
    end
    if low_priority then
        if type(low_prio_chunks[cx][cy]) == "number" then
            low_prio_chunks[cx][cy] = low_prio_chunks[cx][cy] + 1
            if low_prio_chunks[cx][cy] < 40 * (1 - _G.scale_x) then
                return
            end
            low_prio_chunks[cx][cy] = 1
        else
            low_prio_chunks[cx][cy] = 1
        end
    elseif _G.scale_x < 0.5 then
        flag = flag + 1
        if not low_priority and flag < (1 - _G.scale_x) * 5 then
            return
        end
        flag = math.floor(love.math.random(-1, 1) + 0.5)
    end
    -- object_batch[chunk_x][chunk_y] = object_batch[chunk_x][chunk_y] or
    --                                      love.graphics.newSpriteBatch(object_image, chunk_width * chunk_height)
    -- object_batch[chunk_x][chunk_y]:clear()
    local vertices = {}
    for i = 0, chunk_width - 1, 1 do
        for o = 0, chunk_height - 1, 1 do
            local object_index = object[cx][cy][i][o]
            if type(object_index) == 'table' then
                local c = false
                for _, obj in ipairs(object_index) do
                    c = true
                    if obj.cx ~= chunk_x or obj.cy ~= chunk_y then
                        removeObjectAt(cx, cy, i, o, obj)
                        goto continue
                    end
                    if obj.animated then
                        -- local offset_x, offset_y = 0, 0
                        -- if quad_offset[obj.animation:getQuad()] then
                        --     offset_x, offset_y = quad_offset[obj.animation:getQuad()][1] or 0,
                        --         quad_offset[obj.animation:getQuad()][2] or 0
                        -- end
                        -- if obj.qid then
                        --     object_batch[chunk_x][chunk_y]:set(obj.qid,
                        --         obj.animation:getFrameInfo(obj.x + (obj.offset_x or 0) + offset_x, obj.y +
                        --             (obj.offset_y or 0) + offset_y - _G.height_map[obj.gx][obj.gy]))
                        -- else
                        -- obj.qid = object_batch[chunk_x][chunk_y]:add(
                        --     obj.animation:getFrameInfo(obj.x + (obj.offset_x or 0) + offset_x, obj.y +
                        --         (obj.offset_y or 0) + offset_y - _G.height_map[obj.gx][obj.gy]))
                        -- end

                        local offset_x, offset_y = 0, 0
                        if quad_offset[obj.animation:getQuad()] then
                            offset_x, offset_y = quad_offset[obj.animation:getQuad()][1] or 0,
                                quad_offset[obj.animation:getQuad()][2] or 0
                        end
                        obj.spritebatch = object_batch[chunk_x][chunk_y]
                        local quad, x, y, _, _, _, _, _, _, _ = obj.animation:getFrameInfo(
                            obj.x + (obj.offset_x or 0) + offset_x,
                            obj.y + (obj.offset_y or 0) + offset_y - _G.height_map[obj.gx][obj.gy])
                        local qx, qy, qw, qh = quad:getViewport()
                        obj.vert_id = #vertices + 1
                        obj.instancemesh = object_mesh[chunk_x][chunk_y]
                        vertices[#vertices + 1] = obj:animate(_G.dt)
                    else
                        local offset_x, offset_y = 0, 0
                        if quad_offset[obj.tile] then
                            offset_x, offset_y = quad_offset[obj.tile][1] or 0, quad_offset[obj.tile][2] or 0
                        end
                        obj.qid = object_batch[chunk_x][chunk_y]:add(obj.tile, obj.x + (obj.offset_x or 0) + offset_x,
                            obj.y + (obj.offset_y or 0) + offset_y)
                    end
                    ::continue::
                end
                if not c then
                    object[cx][cy][i][o] = nil
                end
            end
        end
    end
    _G.object_mesh[chunk_x][chunk_y]:setVertices(vertices)
    -- object_batch[chunk_x][chunk_y]:flush()
end

local shader = love.graphics.newShader [[
varying vec2 uvoff;
varying vec2 imgdim;

#ifdef VERTEX
attribute vec2 InstancePosition;
attribute vec2 UVOffset;
attribute vec2 ImageDim;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    uvoff = UVOffset;
    imgdim = ImageDim;
    vertex_position.xy *= ImageDim;
    vertex_position.xy += InstancePosition;
	return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    texture_coords.x = (uvoff.x + imgdim.x*texture_coords.x)/8192.0;
    texture_coords.y = (uvoff.y + imgdim.y*texture_coords.y)/9694.0;
    vec4 texcolor = Texel(tex, texture_coords);
    return texcolor * color;
}
#endif
]]
local function draw_object()
    local tile_start_x, tile_start_y, tile_end_x, tile_end_y = _G.top_left_chunk_x - 1, _G.top_left_chunk_y,
        _G.bottom_right_chunk_x + 1, _G.bottom_right_chunk_y

    local firstRow = math.min(tile_start_x + tile_start_y, tile_end_x + tile_end_y)
    local lastRow = math.max(tile_start_x + tile_start_y, tile_end_x + tile_end_y)

    local firstColumn = math.min(tile_start_x - tile_start_y, tile_end_x - tile_end_y)
    local lastColumn = math.max(tile_start_x - tile_start_y, tile_end_x - tile_end_y)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setShader(shader)
    for row = firstRow, lastRow do
        local shift = bit.band(bit.bxor(row, firstColumn), 1)
        for column = firstColumn + shift, lastColumn, 2 do
            local xx, yy = bit.rshift(row + column, 1), bit.rshift(row - column, 1)
            if object_batch[xx][yy] ~= nil then
                love.graphics.drawInstanced(object_batch[xx][yy], object_mesh[xx][yy]:getVertexCount(),
                    -_G.view_xview * _G.scale_x + (xx * _G.scale_x - yy * _G.scale_x) * chunk_width * tile_width * 0.5,
                    -_G.view_yview * _G.scale_x + (xx * _G.scale_x + yy * _G.scale_x) * chunk_height * tile_height * 0.5,
                    0, _G.scale_x, _G.scale_y)
            end
        end
    end
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1, 1)
end

local function mousepressed(x, y, button)
    local mx, my = x, y
    local vx = mx - _G.width / 2
    local vy = my - _G.height / 2
    LocalX = math.round(ScreenToIsoX(vx / _G.scale_x + _G.view_xview - 16, vy / _G.scale_x + _G.view_yview - 8));
    LocalY = math.round(ScreenToIsoY(vx / _G.scale_x + _G.view_xview - 16, vy / _G.scale_x + _G.view_yview - 8));
    local MX, MY = love.mouse.getPosition()
    MX = (MX - _G.width / 2) / _G.scale_x + _G.view_xview - 16
    MY = (MY - _G.height / 2) / _G.scale_x + _G.view_yview - 8
    LocalX = math.round(ScreenToIsoX(MX, MY))
    LocalY = math.round(ScreenToIsoY(MX, MY))
    press.gx = LocalX
    press.gy = LocalY
    press.x = (LocalX) % (chunk_width)
    press.y = (LocalY) % (chunk_width)
    press.cx = math.floor(LocalX / chunk_width)
    press.cy = math.floor(LocalY / chunk_width)
    if button == 1 then
        _G.BuildController:build(press.gx, press.gy)
        -- if not objectAt(press.cx, press.cy, press.x, press.y) then
        --     WoodenWall:new(press.gx, press.gy)
        -- end
    elseif button == 2 then
        -- if not objectAt(press.cx, press.cy, press.x, press.y) then
        --     -- OakTree:new(press.gx, press.gy)
        --     -- WoodenTower:new(press.gx, press.gy)
        --     -- Woodcutter:new(press.gx, press.gy, "Woodcutter")
        --     -- Woodcutter:new(press.gx, press.gy, "Woodcutter")
        --     -- Woodcutter:new(press.gx, press.gy, "Woodcutter")
        --     -- Woodcutter:new(press.gx, press.gy, "Woodcutter")
        -- end
    elseif button == 3 then
        -- WoodenWallWalkable:new(press.gx, press.gy)
        local insp = object[press.cx][press.cy][press.x][press.y]
        if insp then
            print("____________")
            for _, ibj in pairs(insp) do
                -- print(ibj.type, ibj.x + (ibj.cx - ibj.cy) * chunk_width * tile_width * 0.5,
                --     ibj.y + (ibj.cx + ibj.cy) * chunk_width * tile_height * 0.5)
                -- print(ibj.type, (view_xview) - 1920 / 2 - 100, (view_yview) - 1080 / 2 - 100)
                -- print(ibj.type, ((view_xview) - 1920 / 2 - 100) * scale_x, ((view_yview) - 1080 / 2 - 100) * scale_y)
                -- print(ibj.type, ((view_xview) - 1920 / 2 - 100) / scale_x, ((view_yview) - 1080 / 2 - 100) / scale_y)
                -- print(ibj.type, ((view_xview) - 1920 / 2 - 100) / scale_x, ((view_yview) - 1080 / 2 - 100) * scale_y)
            end
            -- print(inspect(insp))
        end
    end
end

local function update(dt)
    _G.JobController:make_worker()
    prof.push("CUL")
    if previous_chunk_x ~= _G.current_chunk_x or previous_chunk_y ~= _G.current_chunk_y or _G.top_left_chunk_x ~=
        (_G.previous_top_left_chunk_x or 0) then
        _G.chunkUpdateList()
    end
    prof.pop("CUL")
    prof.push("AE")
    previous_chunk_x = _G.current_chunk_x
    previous_chunk_y = _G.current_chunk_y
    _G.previous_top_left_chunk_x = _G.top_left_chunk_x
    _G.wheat_season_counter = _G.wheat_season_counter + dt
    if _G.wheat_season_counter > 20 then
        _G.wheat_season_counter = 0
        _G.wheat_growing_season = true
    end
    if _G.wheat_growing_season and _G.wheat_season_counter > 0.5 then
        _G.wheat_growing_season = false
    end
    local updated_chunks = _G.newAutotable(2)
    for idx, obj in pairs(active_entities) do
        if obj.to_be_deleted then
            active_entities[idx] = nil
        else
            obj:animate(dt)
        end
    end
    prof.pop("AE")
    prof.push("UPDATE_OBJECTS")
    -- Render the center chunks with higher priority
    prof.pop("UPDATE_OBJECTS")
    prof.push("UPDATE_CHUNK_OBJ")

    local super_slow_mode = false
    if scale_x < 0.31 then
        super_slow_mode = true
    end
    local l = _G.terrain_chunks
    local vert
    while l do
        if l.chunkx == nil then
            break
        end
        updated_chunks[l.chunkx][l.chunky] = true
        if not super_slow_mode or love.math.random(1, 10) == 1 then
            if _G.chunk_objects[l.chunkx][l.chunky] then
                for _, obj in pairs(_G.chunk_objects[l.chunkx][l.chunky]) do
                    if obj.animated then
                        if obj:is_visible_on_screen() then
                            obj:animate(dt)
                        end
                    else
                        obj:update(dt)
                    end
                end
            end
        end
        l = l.next
    end
    -- Render the edge chunks with lower priority
    local tile_start_x, tile_start_y, tile_end_x, tile_end_y = _G.top_left_chunk_x - 1, _G.top_left_chunk_y,
        _G.bottom_right_chunk_x + 1, _G.bottom_right_chunk_y

    local firstRow = math.min(tile_start_x + tile_start_y, tile_end_x + tile_end_y)
    local lastRow = math.max(tile_start_x + tile_start_y, tile_end_x + tile_end_y)

    local firstColumn = math.min(tile_start_x - tile_start_y, tile_end_x - tile_end_y)
    local lastColumn = math.max(tile_start_x - tile_start_y, tile_end_x - tile_end_y)

    for row = firstRow, lastRow do
        local shift = bit.band(bit.bxor(row, firstColumn), 1)
        for column = firstColumn + shift, lastColumn, 2 do
            local xx, yy = bit.rshift(row + column, 1), bit.rshift(row - column, 1)
            if updated_chunks[xx][yy] ~= true then
                if love.math.random(1, 5) == 1 then
                    if _G.chunk_objects[xx][yy] then
                        for _, obj in pairs(_G.chunk_objects[xx][yy]) do
                            if obj.animated then
                                if obj:is_visible_on_screen() then
                                    obj:animate(dt)
                                end
                            else
                                obj:update(dt)
                            end
                        end
                    end
                end
            end
        end
    end
    prof.pop("UPDATE_CHUNK_OBJ")
end

local tableOfFunctions = {
    update = update,
    draw = draw_object,
    chunk = object[press.cx][press.cy],
    mousereleased = _G.mousereleased,
    mousepressed = mousepressed,
    active = active_objects,
    object = object,
    batch = object_batch,
    shadow = shadow_batch,
    update_objects = update_objects,
    addObjectAt = addObjectAt
}
return tableOfFunctions
