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
local active_entities = newAutotable(1)
_G.active_chunks = {}
local object = _G.state.object
----Calculate center chunk
local CenterX = math.round(ScreenToIsoX(_G.ScreenWidth / 2 - 16 + _G.state.view_xview,
    _G.ScreenHeight / 2 - 8 + _G.state.view_yview));
local CenterY = math.round(ScreenToIsoY(_G.ScreenWidth / 2 - 16 + _G.state.view_xview,
    _G.ScreenHeight / 2 - 8 + _G.state.view_yview))
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

local Tree = love.filesystem.load('objects/Environment/Tree.lua')(object_batch, active_entities, tile_quads, object)
local PineTree = love.filesystem.load('objects/Environment/PineTree.lua')(object_batch, active_entities, tile_quads,
    object, Tree)
local OakTree = love.filesystem.load('objects/Environment/OakTree.lua')(object_batch, active_entities, tile_quads,
    object, Tree)
local Shrub = love.filesystem.load('objects/Environment/Shrub.lua')(object_batch, active_entities, tile_quads, object)
local Stone = love.filesystem.load('objects/Environment/Stone.lua')(object_batch, active_entities, tile_quads, object)
local Iron = love.filesystem.load('objects/Environment/Iron.lua')(object_batch, active_entities, tile_quads, object)
local Woodcutter = love.filesystem.load('objects/Units/Woodcutter.lua')(object, tile_quads)
local Baker = love.filesystem.load('objects/Units/Baker.lua')(object, tile_quads)
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
local Bakery = love.filesystem.load('objects/Structures/Bakery.lua')(active_entities, object, tile_quads, object_batch)
local House = love.filesystem.load('objects/Structures/House.lua')(active_entities, object, tile_quads, object_batch)
local WoodenWall = love.filesystem.load('objects/Structures/WoodenWall.lua')(active_entities, object, tile_quads,
    object_batch)
local WoodenWallWalkable = love.filesystem.load('objects/Structures/WoodenWallWalkable.lua')(active_entities, object,
    tile_quads, object_batch)
local WoodenTower = love.filesystem.load('objects/Structures/WoodenTower.lua')(active_entities, object, tile_quads,
    object_batch)
local Rock_4x4 = love.filesystem.load('objects/Environment/Rock_4x4.lua')(active_entities, object, tile_quads,
    object_batch)
local Rock_3x3 = love.filesystem.load('objects/Environment/Rock_3x3.lua')(active_entities, object, tile_quads,
    object_batch)
local Rock_2x2 = love.filesystem.load('objects/Environment/Rock_2x2.lua')(active_entities, object, tile_quads,
    object_batch)
local Rock_1x1 = love.filesystem.load('objects/Environment/Rock_1x1.lua')(active_entities, object, tile_quads,
    object_batch)
local Campfire = love.filesystem.load('objects/Structures/Campfire.lua')(active_entities, tile_quads, object_batch)
local Orchard = love.filesystem.load('objects/Structures/Orchard.lua')(active_entities, tile_quads, object_batch)
local WheatFarm = love.filesystem.load('objects/Structures/WheatFarm.lua')(object, tile_quads, object_batch,
    active_entities)
package.loaded['objects.Environment.Tree'] = Tree
package.loaded['objects.Environment.PineTree'] = PineTree
package.loaded['objects.Environment.OakTree'] = OakTree
package.loaded['objects.Environment.Shrub'] = Shrub
package.loaded['objects.Environment.Stone'] = Stone
package.loaded['objects.Environment.Iron'] = Iron
package.loaded['objects.Environment.Rock_4x4'] = Rock_4x4
package.loaded['objects.Environment.Rock_3x3'] = Rock_3x3
package.loaded['objects.Environment.Rock_2x2'] = Rock_2x2
package.loaded['objects.Environment.Rock_1x1'] = Rock_1x1
package.loaded['objects.Units.Woodcutter'] = Woodcutter
package.loaded['objects.Units.Baker'] = Baker
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
package.loaded['objects.Structures.Bakery'] = Bakery
package.loaded['objects.Structures.House'] = House
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

function _G.removeObjectAt(cx, cy, x, y, object_to_remove)
    if x > 63 or y > 63 then
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

function _G.removeObjectFromClassAtGlobal(gx, gy, class_to_remove)
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if x > 63 or y > 64 then
        print((debug.traceback("Error: trying to remove out of bounds unit", 1):gsub("\n[^\n]+$", "")))
        love.event.quit()
    end
    if type(object[cx][cy][x][y]) == 'table' then
        for index, current_object in ipairs(object[cx][cy][x][y]) do
            if current_object.class.name == class_to_remove or current_object.type == class_to_remove then
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

function _G.isObjectAt(cx, cy, x, y, object_compared)
    if type(object[cx][cy][x][y]) == 'table' then
        for _, current_object in ipairs(object[cx][cy][x][y]) do
            if current_object == object_compared then
                return current_object
            end
        end
    end
    return false
end

function _G.objectFromClassAtGlobal(gx, gy, obj_class)
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
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

function _G.importantObjectAt(cx, cy, x, y)
    if (type(object[cx][cy][x][y]) == 'table' and next(object[cx][cy][x][y]) == nil) or not object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") or objectFromTypeAt(cx, cy, x, y, "Tall shrub") or
        objectFromTypeAt(cx, cy, x, y, "Short shrub") then
        return false
    else
        return true
    end
end

function _G.importantObjectAtGlobal(gx, gy)
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if (type(object[cx][cy][x][y]) == 'table' and next(object[cx][cy][x][y]) == nil) or not object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") or objectFromTypeAt(cx, cy, x, y, "Tall shrub") or
        objectFromTypeAt(cx, cy, x, y, "Short shrub") then
        return false
    else
        return true
    end
end

function objectAtGlobal(gx, gy)
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if (type(object[cx][cy][x][y]) == 'table' and next(object[cx][cy][x][y]) == nil) or not object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") then
        return false
    else
        return true
    end
end

function _G.allocateMesh(cx, cy)
    local chunk_x = cx
    local chunk_y = cy
    local treeverts = {{0, 0, 0, 0, 1.0, 1.0, 1.0, 1.0}, {1, 0, 1, 0, 1.0, 1.0, 1.0, 1.0},
                       {0, 1, 0, 1, 1.0, 1.0, 1.0, 1.0}, {1, 1, 1, 1, 1.0, 1.0, 1.0, 1.0}}
    if object_batch[chunk_x][chunk_y] == nil then
        object_batch[chunk_x][chunk_y] = love.graphics.newMesh(treeverts, "strip", "static")
    end
    local instancemesh = love.graphics.newMesh({{"InstancePosition", "float", 2}, {"UVOffset", "float", 2},
                                                {"ImageDim", "float", 2}, {"ImageShade", "float", 1},
                                                {"ScaleX", "float", 1}},
        chunk_width * chunk_height * _G.state.vertices_per_tile + 1000, nil, "dynamic")
    _G.state.object_mesh[chunk_x][chunk_y] = instancemesh
    object_batch[chunk_x][chunk_y]:setTexture(object_image)
    object_batch[chunk_x][chunk_y]:attachAttribute("InstancePosition", instancemesh, "perinstance")
    object_batch[chunk_x][chunk_y]:attachAttribute("UVOffset", instancemesh, "perinstance")
    object_batch[chunk_x][chunk_y]:attachAttribute("ImageDim", instancemesh, "perinstance")
    object_batch[chunk_x][chunk_y]:attachAttribute("ImageShade", instancemesh, "perinstance")
    object_batch[chunk_x][chunk_y]:attachAttribute("ScaleX", instancemesh, "perinstance")
end

function _G.genObjects(cx, cy)
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
                rand = math.random(2)
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
                    goto continue
                end
                if not tree_generated and love.math.random(1000) == 4 then
                    local tree = PineTree:new(gx, gy, "Medium pine tree")
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
            ::continue::
        end
    end
end

local shader = love.graphics.newShader [[
varying vec2 uvoff;
varying vec2 imgdim;
varying float imgshd;

#ifdef VERTEX
attribute vec2 InstancePosition;
attribute vec2 UVOffset;
attribute vec2 ImageDim;
attribute float ImageShade;
attribute float ScaleX;
varying float imgscale;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    uvoff = UVOffset;
    imgdim = ImageDim;
    imgshd = ImageShade;
    imgscale = ScaleX;
    if (imgscale == 0) {
        imgscale = 1.0;
    }
    vertex_position.xy *= ImageDim;
    vertex_position.x *= imgscale;
    vertex_position.xy += InstancePosition;
	return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    color.xyz *= imgshd;
    texture_coords.x = (uvoff.x + imgdim.x*texture_coords.x)/8192.0;
    texture_coords.y = (uvoff.y + imgdim.y*texture_coords.y)/12000.0;
    vec4 texcolor = Texel(tex, texture_coords);
    return texcolor * color;
}
#endif
]]
local function draw_object()
    local tile_start_x, tile_start_y, tile_end_x, tile_end_y = _G.state.top_left_chunk_x - 1, _G.state.top_left_chunk_y,
        _G.state.bottom_right_chunk_x + 1, _G.state.bottom_right_chunk_y

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
                love.graphics.drawInstanced(object_batch[xx][yy], _G.state.object_mesh[xx][yy]:getVertexCount(),
                    -_G.state.view_xview * _G.state.scale_x + (xx * _G.state.scale_x - yy * _G.state.scale_x) *
                        chunk_width * tile_width * 0.5,
                    -_G.state.view_yview * _G.state.scale_x + (xx * _G.state.scale_x + yy * _G.state.scale_x) *
                        chunk_height * tile_height * 0.5, 0, _G.state.scale_x, _G.state.scale_x)
            end
        end
    end
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1, 1)
end

local function mousepressed(x, y, button)
    local mx, my = x, y
    press.gx, press.gy = _G.getTerrainTileOnMouse(mx, my)
    press.cx = math.floor(press.gx / chunk_width)
    press.cy = math.floor(press.gy / chunk_width)
    press.x = (press.gx) % (chunk_width)
    press.y = (press.gy) % (chunk_width)
    if button == 1 then
        _G.BuildController:mousepressed(mx, my)
    elseif button == 3 then
        -- require("objects.Controllers.Ferdnhoven")
        -- _G.getTerrainTileOnMouse(mx, my)
        if not objectAt(press.cx, press.cy, press.x, press.y) then
            if love.keyboard.isDown("1") then
                Rock_1x1:new(press.gx, press.gy)
            elseif love.keyboard.isDown("2") then
                Rock_2x2:new(press.gx, press.gy)
            elseif love.keyboard.isDown("3") then
                Rock_3x3:new(press.gx, press.gy)
            elseif love.keyboard.isDown("4") then
                Rock_4x4:new(press.gx, press.gy)
            end
        end
        -- for i = -2, 2 do
        --     for o = -2, 2 do
        --         if i == 2 or i == -2 or o == 2 or o == -2 then
        --             _G.terrainSetTileAt(press.gx + i, press.gy + o, _G.terrain_biome.sea_beach,
        --                 _G.terrain_biome.abundant_grass)
        --         else
        --             _G.terrainSetTileAt(press.gx + i, press.gy + o, _G.terrain_biome.sea)
        --         end
        --     end
        -- end
        -- WoodenWallWalkable:new(press.gx, press.gy)
        -- _G.terrainElevateTileAt(press.gx, press.gy)
        -- _G.terrainElevateTileAt(press.gx, press.gy)

        -- for xxx = -2, 2 do
        --     for yyy = -2, 2 do
        --         if xxx == 0 and yyy == 0 then
        --         else
        --             _G.terrainElevateTileAt(press.gx + xxx, press.gy + yyy)
        --             _G.terrainElevateTileAt(press.gx + xxx, press.gy + yyy)
        --         end
        --     end
        -- end

        -- for xxx = -1, 1 do
        --     for yyy = -1, 1 do
        --         _G.terrainElevateTileAt(press.gx + xxx, press.gy + yyy)
        --         _G.terrainElevateTileAt(press.gx + xxx, press.gy + yyy)
        --     end
        -- end
        -- Peasant:new(_G.spawn_point_x, _G.spawn_point_y)

        local insp = object[press.cx][press.cy][press.x][press.y]
        if insp then
            print("____________")
            for _, ibj in pairs(insp) do
                print(ibj, ibj.gx, ibj.gy)
                print(inspect(ibj:serialize()))
                --     print(ibj.type, ibj.vert_id, ibj.i, ibj.o, press.x, press.y, press.cx, press.cy)
                --     local remove_all_metatables = function(item, path)
                --         if path[#path] ~= inspect.METATABLE then
                --             return item
                --         end
                --     end
                --     print(inspect(ibj, {
                --         depth = 2,
                --         process = remove_all_metatables
                --     }))
                --     -- print(ibj.type, ibj.x + (ibj.cx - ibj.cy) * chunk_width * tile_width * 0.5,
                --     --     ibj.y + (ibj.cx + ibj.cy) * chunk_width * tile_height * 0.5)
                --     -- print(ibj.type, (_G.state.view_xview) - 1920 / 2 - 100, (_G.state.view_yview) - 1080 / 2 - 100)
            end
            -- -- print(inspect(insp))
        end
    end
end

local function preload(dt)
    -- Animates all the objects once so they don't pop in when scrolling
    for i = 0, _G.chunks_wide - 1 do
        for o = 0, _G.chunks_high - 1 do
            if _G.state.chunk_objects[i][o] then
                for _, obj in pairs(_G.state.chunk_objects[i][o]) do
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

function _G.setWaterAt(gx, gy)
    _G.state.map:setWater(gx, gy)
end

local first_update = true
local function update(dt)
    if love.mouse.isDown(2) then
        local MX, MY = love.mouse.getPosition()
        MX = (MX - _G.ScreenWidth / 2) / _G.state.scale_x + _G.state.view_xview - 16
        MY = (MY - _G.ScreenHeight / 2) / _G.state.scale_x + _G.state.view_yview - 8
        local pgx = math.round(ScreenToIsoX(MX, MY))
        local pgy = math.round(ScreenToIsoY(MX, MY))
        -- Lake gen
        -- for i = -2, 2 do
        --     for o = -2, 2 do
        --         if i == 2 or i == -2 or o == 2 or o == -2 then
        --             _G.terrainSetTileAt(pgx + i, pgy + o, _G.terrain_biome.sea_beach, _G.terrain_biome.abundant_grass)
        --         else
        --             _G.terrainSetTileAt(pgx + i, pgy + o, _G.terrain_biome.sea)
        --         end
        --     end
        -- end

        _G.terrainElevateTileAt(pgx + 0, pgy + 0)
        _G.terrainElevateTileAt(pgx + 0, pgy + 0)
        for xxx = -1, 1 do
            for yyy = -1, 1 do
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
                _G.terrainElevateTileAt(pgx + xxx, pgy + yyy)
            end
        end
    end
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
    _G.state.previous_top_left_chunk_x = _G.state.top_left_chunk_x
    _G.state.wheat_season_counter = _G.state.wheat_season_counter + dt
    if _G.state.wheat_season_counter > 5 then
        _G.state.wheat_season_counter = 0
        _G.state.wheat_growing_season = true
    end
    if _G.state.wheat_growing_season and _G.state.wheat_season_counter > 0.5 then
        _G.state.wheat_growing_season = false
    end
    local updated_chunks = _G.newAutotable(2)
    local objects_to_be_deleted
    local needs_to_be_deleted = false
    for idx, obj in ipairs(active_entities) do
        if obj.to_be_deleted then
            if needs_to_be_deleted == false then
                needs_to_be_deleted = true
                objects_to_be_deleted = {}
            end
            objects_to_be_deleted[idx] = true
        else
            obj:animate(dt)
        end
    end
    if needs_to_be_deleted then
        active_entities = _G.arrayRemove(active_entities, function(t, i, j)
            return not objects_to_be_deleted[i]
        end)
    end

    prof.pop("AE")
    prof.push("UPDATE_OBJECTS")
    -- Render the center chunks with higher priority
    prof.pop("UPDATE_OBJECTS")
    prof.push("UPDATE_CHUNK_OBJ")

    local super_slow_mode = false
    if _G.state.scale_x < 0.31 then
        super_slow_mode = true
    end
    local l = _G.state.terrain_chunks
    while l do
        if l.chunkx == nil then
            break
        end
        updated_chunks[l.chunkx][l.chunky] = true
        if not super_slow_mode or love.math.random(1, 10) == 1 then
            if _G.state.chunk_objects[l.chunkx][l.chunky] then
                for _, obj in pairs(_G.state.chunk_objects[l.chunkx][l.chunky]) do
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
    local tile_start_x, tile_start_y, tile_end_x, tile_end_y = _G.state.top_left_chunk_x - 1, _G.state.top_left_chunk_y,
        _G.state.bottom_right_chunk_x + 1, _G.state.bottom_right_chunk_y

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
                    if _G.state.chunk_objects[xx][yy] then
                        for _, obj in pairs(_G.state.chunk_objects[xx][yy]) do
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
    active = active_entities,
    object = object,
    batch = object_batch,
    shadow = shadow_batch,
    addObjectAt = addObjectAt
}
return tableOfFunctions
