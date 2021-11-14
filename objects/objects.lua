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
local Stone = love.filesystem.load('objects/Environment/Stone.lua')(object_batch, active_objects, tile_quads, object)
local Iron = love.filesystem.load('objects/Environment/Iron.lua')(object_batch, active_objects, tile_quads, object)
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
local Windmill = love.filesystem.load('objects/Structures/Windmill.lua')(active_entities, object, tile_quads,
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
package.loaded['objects.Environment.Stone'] = Stone
package.loaded['objects.Environment.Iron'] = Iron
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
package.loaded['objects.Structures.Windmill'] = Windmill
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

function removeObjectAt(cx, cy, x, y, object_to_remove)
    if x > 63 or y > 64 then
        print((debug.traceback("Error: trying to remove out of bounds unit", 1):gsub("\n[^\n]+$", "")))
        love.event.quit()
    end
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

function removeObjectFromClassAtGlobal(gx, gy, class_to_remove)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    local x = (gx) % (chunk_width)
    local y = (gy) % (chunk_width)
    if x > 63 or y > 64 then
        print((debug.traceback("Error: trying to remove out of bounds unit", 1):gsub("\n[^\n]+$", "")))
        love.event.quit()
    end
    if type(object[cx][cy][x][y]) == 'table' then
        for index, current_object in ipairs(object[cx][cy][x][y]) do
            if current_object.class.name == class_to_remove then
                table.remove(object[cx][cy][x][y], index)
                current_object:destroy()
                break
            end
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

function objectFromClassAtGlobal(gx, gy, obj_class)
    local cx = math.floor(gx / chunk_width)
    local cy = math.floor(gy / chunk_width)
    local x = (gx) % (chunk_width)
    local y = (gy) % (chunk_width)
    if type(object[cx][cy][x][y]) == 'table' then
        for _, current_object in ipairs(object[cx][cy][x][y]) do
            if current_object.class.name == obj_class then
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

_G.object_mesh = newAutotable(2)
_G.object_mesh_vert_id_map = newAutotable(3)

function genObjects(cx, cy)
    local chunk_x = cx or _G.current_chunk_x
    local chunk_y = cy or _G.current_chunk_y

    local treeverts = {{0, 0, 0, 0, 1.0, 1.0, 1.0, 1.0}, {1, 0, 1, 0, 1.0, 1.0, 1.0, 1.0},
                       {0, 1, 0, 1, 1.0, 1.0, 1.0, 1.0}, {1, 1, 1, 1, 1.0, 1.0, 1.0, 1.0}}
    if object_batch[chunk_x][chunk_y] == nil then
        object_batch[chunk_x][chunk_y] = love.graphics.newMesh(treeverts, "strip", "static")
    end
    local instancemesh = love.graphics.newMesh({{"InstancePosition", "float", 2}, {"UVOffset", "float", 2},
                                                {"ImageDim", "float", 2}},
        chunk_width * chunk_height * _G.vertices_per_tile, nil, "dynamic")
    _G.object_mesh[chunk_x][chunk_y] = instancemesh
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
                    local tree = OakTree:new(gx, gy, "Medium oak tree")
                    tree.animation:gotoFrame(math.random(1, 20))
                    tree_generated = true
                end
                if not tree_generated and love.math.random(800) == 4 then
                    local shrub = Shrub:new(gx, gy, "Short shrub")
                    shrub.animation:gotoFrame(math.random(1, 20))
                end
            end
            if not tree_generated and _G.stone_gen[math.round((gx) / 3) + 1][math.round((gy) / 3) + 1] ~= false then
                local border = false
                for lx = -1, 1, 1 do
                    for ly = -1, 1, 1 do
                        if not (lx == 0 and ly == 0) then
                            if _G.stone_gen[math.round((gx + lx) / 3) + 1][math.round((gy + ly) / 3) + 1] == false then
                                border = true
                            end
                        end
                    end
                end
                if border then
                    if love.math.random(1, 2) == 2 then
                        Stone:new(gx, gy)
                        if gy - 1 > 0 and not objectAtGlobal(gx, gy - 1) then
                            Stone:new(gx, gy - 1)
                        end
                    end
                else
                    Stone:new(gx, gy)
                    if gy - 1 > 0 and not objectAtGlobal(gx, gy - 1) then
                        Stone:new(gx, gy - 1)
                    end
                end
            end
            if not tree_generated and _G.iron_gen[math.round((gx) / 3) + 1][math.round((gy) / 3) + 1] ~= false then
                local border = false
                for lx = -1, 1, 1 do
                    for ly = -1, 1, 1 do
                        if not (lx == 0 and ly == 0) then
                            if _G.iron_gen[math.round((gx + lx) / 3) + 1][math.round((gy + ly) / 3) + 1] == false then
                                border = true
                            end
                        end
                    end
                end
                if border then
                    if love.math.random(1, 2) == 2 then
                        Iron:new(gx, gy)
                        if gy - 1 > 0 and not objectAtGlobal(gx, gy - 1) then
                            Iron:new(gx, gy - 1)
                        end
                    end
                else
                    Iron:new(gx, gy)
                    if gy - 1 > 0 and not objectAtGlobal(gx, gy - 1) then
                        Iron:new(gx, gy - 1)
                    end
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
                        ob.vert_id = _G.vertices_per_tile * (i + o * chunk_width) + 1
                        _G.object_mesh_vert_id_map[chunk_x][chunk_y][ob.vert_id] = true
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
        -- _G.saw.state = "Going to waypoint"
        -- _G.saw.nd = {}
        -- _G.saw.waypoint_x, _G.saw.waypoint_y = nil, nil
        -- _G.saw.move_dir = "none"
        -- _G.saw.count = 1
        -- _G.saw:requestPath(press.gx, press.gy)
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
        Peasant:new(_G.spawn_point_x, _G.spawn_point_y)
        local insp = object[press.cx][press.cy][press.x][press.y]
        if insp then
            print("____________")
            for _, ibj in pairs(insp) do
                print(ibj.type, ibj.vert_id, ibj.i, ibj.o, press.x, press.y, press.cx, press.cy)
                local remove_all_metatables = function(item, path)
                    if path[#path] ~= inspect.METATABLE then
                        return item
                    end
                end
                print(inspect(ibj, {
                    depth = 2,
                    process = remove_all_metatables
                }))
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

local function preload(dt)
    -- Animates all the objects once so they don't pop in when scrolling
    for i = 0, _G.chunks_wide - 1 do
        for o = 0, _G.chunks_high - 1 do
            if _G.chunk_objects[i][o] then
                for _, obj in pairs(_G.chunk_objects[i][o]) do
                    if obj.animated then
                        obj:animate(dt)
                    else
                        obj:update(dt)
                    end
                end
            end
        end
    end
end

local first_update = true
local function update(dt)
    _G.JobController:make_worker()
    prof.push("CUL")
    if previous_chunk_x ~= _G.current_chunk_x or previous_chunk_y ~= _G.current_chunk_y or _G.top_left_chunk_x ~=
        (_G.previous_top_left_chunk_x or 0) then
        _G.chunkUpdateList()
    end
    if first_update then
        preload(dt)
        first_update = false
    end
    prof.pop("CUL")
    prof.push("AE")
    previous_chunk_x = _G.current_chunk_x
    previous_chunk_y = _G.current_chunk_y
    _G.previous_top_left_chunk_x = _G.top_left_chunk_x
    _G.wheat_season_counter = _G.wheat_season_counter + dt
    if _G.wheat_season_counter > 5 then
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
                        else
                            obj:update(dt)
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
