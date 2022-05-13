local objectAtlas = ...
local newAutotable = _G.newAutotable
local ScreenToIsoX, ScreenToIsoY = _G.ScreenToIsoX, _G.ScreenToIsoY
local chunkWidth, chunkHeight = _G.chunkWidth, _G.chunkHeight
local tileWidth, tileHeight = _G.tileWidth, _G.tileHeight
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
local activeEntities = newAutotable(1)
local object = _G.state.object
----Calculate center chunk
local CenterX = math.round(
    ScreenToIsoX(
        _G.ScreenWidth / 2 - 16 + _G.state.viewXview, _G.ScreenHeight / 2 - 8 + _G.state.viewYview));
local CenterY = math.round(
    ScreenToIsoY(
        _G.ScreenWidth / 2 - 16 + _G.state.viewXview, _G.ScreenHeight / 2 - 8 + _G.state.viewYview))
---------------------------------------
_G.xchunk = math.floor(CenterX / (chunkWidth))
_G.ychunk = math.floor(CenterY / (chunkWidth))
----Generate spriteBatch
local objectBatch = newAutotable(2)
local shadowBatch = newAutotable(2)
-- local canvas = love.graphics.newCanvas()
if not _G.testMode then
    objectAtlas:setFilter("nearest", "nearest")
end
local tileQuads = require("objects.object_quads")

--- NOTE Object classes START ---
--- NOTE --------------------------
--- NOTE --------------------------
local Unit = love.filesystem.load("objects/Units/Unit.lua")(activeEntities, objectBatch)
package.loaded["objects.Units.Unit"] = Unit

local Tree = love.filesystem.load("objects/Environment/Tree.lua")(objectBatch, activeEntities, tileQuads, object)
local PineTree = love.filesystem.load("objects/Environment/PineTree.lua")(
    objectBatch, activeEntities, tileQuads, object, Tree)
local OakTree = love.filesystem.load("objects/Environment/OakTree.lua")(
    objectBatch, activeEntities, tileQuads, object, Tree)
local Shrub = love.filesystem.load("objects/Environment/Shrub.lua")(objectBatch, activeEntities, tileQuads, object)
local Stone = love.filesystem.load("objects/Environment/Stone.lua")(objectBatch, activeEntities, tileQuads, object)
local Iron = love.filesystem.load("objects/Environment/Iron.lua")(objectBatch, activeEntities, tileQuads, object)
local Woodcutter = love.filesystem.load("objects/Units/Woodcutter.lua")(object, tileQuads)
local Baker = love.filesystem.load("objects/Units/Baker.lua")(object, tileQuads)
local Stonemason = love.filesystem.load("objects/Units/Stonemason.lua")(object, tileQuads)
local Peasant = love.filesystem.load("objects/Units/Peasant.lua")(object, tileQuads)
local OrchardFarmer = love.filesystem.load("objects/Units/OrchardFarmer.lua")(object, tileQuads)
local WheatFarmer = love.filesystem.load("objects/Units/WheatFarmer.lua")(object, tileQuads)
local Miner = love.filesystem.load("objects/Units/Miner.lua")(object, tileQuads)
local Castle = love.filesystem.load("objects/Structures/Castle.lua")(object, tileQuads)
local Stockpile = love.filesystem.load("objects/Structures/Stockpile.lua")(object, tileQuads, objectBatch)
local Granary = love.filesystem.load("objects/Structures/Granary.lua")(object, tileQuads, objectBatch)
local Quarry = love.filesystem.load("objects/Structures/Quarry.lua")(activeEntities, object, tileQuads, objectBatch)
local Mine = love.filesystem.load("objects/Structures/Mine.lua")(activeEntities, object, tileQuads, objectBatch)
local WoodcutterHut = love.filesystem.load("objects/Structures/WoodcutterHut.lua")(
    activeEntities, object, tileQuads, objectBatch)
local Windmill = love.filesystem.load("objects/Structures/Windmill.lua")(activeEntities, object, tileQuads, objectBatch)
local Bakery = love.filesystem.load("objects/Structures/Bakery.lua")(activeEntities, object, tileQuads, objectBatch)
local House = love.filesystem.load("objects/Structures/House.lua")(activeEntities, object, tileQuads, objectBatch)
local WoodenWall = love.filesystem.load("objects/Structures/WoodenWall.lua")(
    activeEntities, object, tileQuads, objectBatch)
local WoodenWallWalkable = love.filesystem.load("objects/Structures/WoodenWallWalkable.lua")(
    activeEntities, object, tileQuads, objectBatch)
local WoodenTower = love.filesystem.load("objects/Structures/WoodenTower.lua")(
    activeEntities, object, tileQuads, objectBatch)
local Rock_4x4 = love.filesystem.load("objects/Environment/Rock_4x4.lua")(
    activeEntities, object, tileQuads, objectBatch)
local Rock_3x3 = love.filesystem.load("objects/Environment/Rock_3x3.lua")(
    activeEntities, object, tileQuads, objectBatch)
local Rock_2x2 = love.filesystem.load("objects/Environment/Rock_2x2.lua")(
    activeEntities, object, tileQuads, objectBatch)
local Rock_1x1 = love.filesystem.load("objects/Environment/Rock_1x1.lua")(
    activeEntities, object, tileQuads, objectBatch)
local Campfire = love.filesystem.load("objects/Structures/Campfire.lua")(activeEntities, tileQuads, objectBatch)
local Orchard = love.filesystem.load("objects/Structures/Orchard.lua")(activeEntities, tileQuads, objectBatch)
local WheatFarm = love.filesystem.load("objects/Structures/WheatFarm.lua")(
    object, tileQuads, objectBatch, activeEntities)
package.loaded["objects.Environment.Tree"] = Tree
package.loaded["objects.Environment.PineTree"] = PineTree
package.loaded["objects.Environment.OakTree"] = OakTree
package.loaded["objects.Environment.Shrub"] = Shrub
package.loaded["objects.Environment.Stone"] = Stone
package.loaded["objects.Environment.Iron"] = Iron
package.loaded["objects.Environment.Rock_4x4"] = Rock_4x4
package.loaded["objects.Environment.Rock_3x3"] = Rock_3x3
package.loaded["objects.Environment.Rock_2x2"] = Rock_2x2
package.loaded["objects.Environment.Rock_1x1"] = Rock_1x1
package.loaded["objects.Units.Woodcutter"] = Woodcutter
package.loaded["objects.Units.Baker"] = Baker
package.loaded["objects.Units.Stonemason"] = Stonemason
package.loaded["objects.Units.Peasant"] = Peasant
package.loaded["objects.Units.OrchardFarmer"] = OrchardFarmer
package.loaded["objects.Units.WheatFarmer"] = WheatFarmer
package.loaded["objects.Units.Miner"] = Miner
package.loaded["objects.Structures.Castle"] = Castle
package.loaded["objects.Structures.Stockpile"] = Stockpile
package.loaded["objects.Structures.Granary"] = Granary
package.loaded["objects.Structures.Quarry"] = Quarry
package.loaded["objects.Structures.Mine"] = Mine
package.loaded["objects.Structures.WoodcutterHut"] = WoodcutterHut
package.loaded["objects.Structures.Windmill"] = Windmill
package.loaded["objects.Structures.Bakery"] = Bakery
package.loaded["objects.Structures.House"] = House
package.loaded["objects.Structures.WoodenWall"] = WoodenWall
package.loaded["objects.Structures.WoodenWallWalkable"] = WoodenWallWalkable
package.loaded["objects.Structures.WoodenTower"] = WoodenTower
package.loaded["objects.Structures.Campfire"] = Campfire
package.loaded["objects.Structures.Orchard"] = Orchard
package.loaded["objects.Structures.WheatFarm"] = WheatFarm
_G.stockpile = require("objects.Controllers.StockpileController")
_G.foodpile = require("objects.Controllers.FoodController")
--- NOTE --------------------------
--- NOTE --------------------------
--- NOTE Object classes END ---

function addObjectAt(cx, cy, x, y, objectToAdd)
    if type(object[cx][cy][x][y]) ~= "table" then
        object[cx][cy][x][y] = {}
    end
    object[cx][cy][x][y][#object[cx][cy][x][y] + 1] = objectToAdd
    return objectToAdd
end

objectAtlas:setWrap("clampzero")

function _G.removeObjectAt(cx, cy, x, y, objectToRemove)
    if x > 63 or y > 63 then
        print((debug.traceback("Error: trying to remove out of bounds unit", 1):gsub("\n[^\n]+$", "")))
        love.event.quit()
    end
    if type(object[cx][cy][x][y]) == "table" then
        if objectToRemove then
            for index, currentObject in ipairs(object[cx][cy][x][y]) do
                if currentObject == objectToRemove then
                    table.remove(object[cx][cy][x][y], index)
                    break
                end
            end
        else
            for _, currentObject in ipairs(object[cx][cy][x][y]) do
                currentObject:destroy()
            end
            object[cx][cy][x][y] = {}
        end
    end
end

function _G.removeObjectFromClassAtGlobal(gx, gy, classToRemove)
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if x > 63 or y > 64 then
        print((debug.traceback("Error: trying to remove out of bounds unit", 1):gsub("\n[^\n]+$", "")))
        love.event.quit()
    end
    if type(object[cx][cy][x][y]) == "table" then
        for index, currentObject in ipairs(object[cx][cy][x][y]) do
            if currentObject.class.name == classToRemove or currentObject.type == classToRemove then
                table.remove(object[cx][cy][x][y], index)
                currentObject:destroy()
                break
            end
        end
    end
end

function objectFromTypeAt(cx, cy, x, y, objType)
    if type(object[cx][cy][x][y]) == "table" then
        for _, currentObject in ipairs(object[cx][cy][x][y]) do
            if (currentObject.type and currentObject.type == objType) or currentObject.class.name == objType then
                return currentObject
            end
        end
    end
    return false
end

function _G.isObjectAt(cx, cy, x, y, objectCompared)
    if type(object[cx][cy][x][y]) == "table" then
        for _, currentObject in ipairs(object[cx][cy][x][y]) do
            if currentObject == objectCompared then
                return currentObject
            end
        end
    end
    return false
end

function _G.objectFromClassAtGlobal(gx, gy, objClass)
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if type(object[cx][cy][x][y]) == "table" then
        for _, currentObject in ipairs(object[cx][cy][x][y]) do
            if currentObject.class.name == objClass then
                return currentObject
            end
        end
    end
    return false
end

function objectAt(cx, cy, x, y)
    if (type(object[cx][cy][x][y]) == "table" and next(object[cx][cy][x][y]) == nil) or not object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") then
        return false
    else
        return true
    end
end

function _G.importantObjectAt(cx, cy, x, y)
    if (type(object[cx][cy][x][y]) == "table" and next(object[cx][cy][x][y]) == nil) or not object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") or objectFromTypeAt(cx, cy, x, y, "Tall shrub") or
        objectFromTypeAt(cx, cy, x, y, "Short shrub") then
        return false
    else
        return true
    end
end

function _G.importantObjectAtGlobal(gx, gy)
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if (type(object[cx][cy][x][y]) == "table" and next(object[cx][cy][x][y]) == nil) or not object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") or objectFromTypeAt(cx, cy, x, y, "Tall shrub") or
        objectFromTypeAt(cx, cy, x, y, "Short shrub") then
        return false
    else
        return true
    end
end

function objectAtGlobal(gx, gy)
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if (type(object[cx][cy][x][y]) == "table" and next(object[cx][cy][x][y]) == nil) or not object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") then
        return false
    else
        return true
    end
end

function _G.allocateMesh(cx, cy)
    local chunkX = cx
    local chunkY = cy
    local treeverts = {{0, 0, 0, 0, 1.0, 1.0, 1.0, 1.0, 1.0}, {1, 0, 1, 0, 1.0, 1.0, 1.0, 1.0, 1.0},
                       {0, 1, 0, 1, 1.0, 1.0, 1.0, 1.0, 1.0}, {1, 1, 1, 1, 1.0, 1.0, 1.0, 1.0, 1.0}}
    if objectBatch[chunkX][chunkY] == nil then
        objectBatch[chunkX][chunkY] = love.graphics.newMesh(treeverts, "strip", "static")
    end
    local instancemesh = love.graphics.newMesh(
        {{"InstancePosition", "float", 2}, {"UVOffset", "float", 2}, {"ImageDim", "float", 2},
         {"ImageShade", "float", 1}, {"Scale", "float", 2}},
            _G.chunkWidth * _G.chunkHeight * _G.state.verticesPerTile + 1000, nil, "dynamic")
    _G.state.objectMesh[chunkX][chunkY] = instancemesh
    objectBatch[chunkX][chunkY]:setTexture(objectAtlas)
    objectBatch[chunkX][chunkY]:attachAttribute("InstancePosition", instancemesh, "perinstance")
    objectBatch[chunkX][chunkY]:attachAttribute("UVOffset", instancemesh, "perinstance")
    objectBatch[chunkX][chunkY]:attachAttribute("ImageDim", instancemesh, "perinstance")
    objectBatch[chunkX][chunkY]:attachAttribute("ImageShade", instancemesh, "perinstance")
    objectBatch[chunkX][chunkY]:attachAttribute("Scale", instancemesh, "perinstance")
end

function _G.genObjects(cx, cy)
    for i = 0, chunkWidth - 1, 1 do
        for o = 0, chunkHeight - 1, 1 do
            local gx = chunkWidth * cx + i
            local gy = chunkWidth * cy + o
            local treeGenerated = false
            if _G.getWaterAt(gx, gy) then
                goto continue
            end
            if _G.forestGen[math.round((gx) / 8) + 1][math.round((gy) / 8) + 1] ~= false then
                _G.terrainSetTileAt(gx, gy, _G.terrainBiome.scarceGrass)
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
                treeGenerated = true
            elseif not treeGenerated then
                if objectAtGlobal(gx, gy - 1) then
                    goto continue
                end
                local chance = 0
                for sx = -1, 1 do
                    for sy = -1, 1 do
                        if _G.forestGen[math.round((gx) / 8) + 1 + sx] and
                            _G.forestGen[math.round((gx) / 8) + 1 + sx][math.round((gy) / 8) + 1 + sy] == true then
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
                            if _G.forestGen[math.round((gx) / 8) + 1 + sx] and
                                _G.forestGen[math.round((gx) / 8) + 1 + sx][math.round((gy) / 8) + 1 + sy] == true then
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
                if not treeGenerated and love.math.random(1000) == 4 then
                    local tree = PineTree:new(gx, gy, "Medium pine tree")
                    tree.animation:gotoFrame(math.random(1, 20))
                    treeGenerated = true
                end
                if not treeGenerated and love.math.random(800) == 4 then
                    local shrub = Shrub:new(gx, gy, "Short shrub")
                    shrub.animation:gotoFrame(math.random(1, 20))
                end
            end
            if not treeGenerated and _G.stoneGen[math.round((gx) / 3) + 1][math.round((gy) / 3) + 1] ~= false then
                local border = false
                for lx = -1, 1, 1 do
                    for ly = -1, 1, 1 do
                        if not (lx == 0 and ly == 0) then
                            if _G.stoneGen[math.round((gx + lx) / 3) + 1][math.round((gy + ly) / 3) + 1] == false then
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
            if not treeGenerated and _G.ironGen[math.round((gx) / 3) + 1][math.round((gy) / 3) + 1] ~= false then
                local border = false
                for lx = -1, 1, 1 do
                    for ly = -1, 1, 1 do
                        if not (lx == 0 and ly == 0) then
                            if _G.ironGen[math.round((gx + lx) / 3) + 1][math.round((gy + ly) / 3) + 1] == false then
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

local shader = love.graphics.newShader("shaders/main.glsl")
local function drawObject()
    local tileStartX, tileStartY, tileEndX, tileEndY = _G.state.topLeftChunkX - 1, _G.state.topLeftChunkY,
        _G.state.bottomRightChunkX + 1, _G.state.bottomRightChunkY

    local firstRow = math.min(tileStartX + tileStartY, tileEndX + tileEndY)
    local lastRow = math.max(tileStartX + tileStartY, tileEndX + tileEndY)

    local firstColumn = math.min(tileStartX - tileStartY, tileEndX - tileEndY)
    local lastColumn = math.max(tileStartX - tileStartY, tileEndX - tileEndY)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setShader(shader)
    for row = firstRow, lastRow do
        local shift = bit.band(bit.bxor(row, firstColumn), 1)
        for column = firstColumn + shift, lastColumn, 2 do
            local xx, yy = bit.rshift(row + column, 1), bit.rshift(row - column, 1)
            if objectBatch[xx][yy] ~= nil then
                love.graphics.drawInstanced(
                    objectBatch[xx][yy], _G.state.objectMesh[xx][yy]:getVertexCount(), -_G.state.viewXview *
                        _G.state.scaleX + (xx * _G.state.scaleX - yy * _G.state.scaleX) * chunkWidth * tileWidth * 0.5,
                        -_G.state.viewYview * _G.state.scaleX + (xx * _G.state.scaleX + yy * _G.state.scaleX) *
                            chunkHeight * tileHeight * 0.5, 0, _G.state.scaleX, _G.state.scaleX)
            end
        end
    end
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1, 1)
end

local function mousepressed(x, y, button)
    local mx, my = x, y
    press.gx, press.gy = _G.getTerrainTileOnMouse(mx, my)
    press.cx = math.floor(press.gx / chunkWidth)
    press.cy = math.floor(press.gy / chunkWidth)
    press.x = (press.gx) % (chunkWidth)
    press.y = (press.gy) % (chunkWidth)
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

        local insp = object[press.cx][press.cy][press.x][press.y]
        if insp then
            print("____________")
            for _, ibj in pairs(insp) do
                print(ibj, ibj.gx, ibj.gy)
                print(inspect(ibj:serialize()))
                --     print(ibj.type, ibj.vertId, ibj.i, ibj.o, press.x, press.y, press.cx, press.cy)
                --     local removeAllMetatables = function(item, path)
                --         if path[#path] ~= inspect.METATABLE then
                --             return item
                --         end
                --     end
                --     print(inspect(ibj, {
                --         depth = 2,
                --         process = removeAllMetatables
                --     }))
                --     -- print(ibj.type, ibj.x + (ibj.cx - ibj.cy) * chunkWidth * tileWidth * 0.5,
                --     --     ibj.y + (ibj.cx + ibj.cy) * chunkWidth * tileHeight * 0.5)
                --     -- print(ibj.type, (_G.state.viewXview) - 1920 / 2 - 100, (_G.state.viewYview) - 1080 / 2 - 100)
            end
        end
    end
end

local function preload(dt)
    -- Animates all the objects once so they don't pop in when scrolling
    for i = 0, _G.chunksWide - 1 do
        for o = 0, _G.chunksHigh - 1 do
            if _G.state.chunkObjects[i][o] then
                for _, obj in pairs(_G.state.chunkObjects[i][o]) do
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
    return _G.state.map:setWater(gx, gy)
end

function _G.removeWaterAt(gx, gy)
    return _G.state.map:removeWater(gx, gy)
end

function _G.getWaterAt(gx, gy)
    return _G.state.map:isWaterAt(gx, gy)
end

local firstUpdate = true
local function update(dt)
    _G.JobController:makeWorker()
    prof.push("CUL")
    if firstUpdate then
        preload(dt)
        firstUpdate = false
    end
    prof.pop("CUL")
    prof.push("AE")
    _G.state.previousTopLeftChunkX = _G.state.topLeftChunkX
    _G.state.wheatSeasonCounter = _G.state.wheatSeasonCounter + dt
    if _G.state.wheatSeasonCounter > 5 then
        _G.state.wheatSeasonCounter = 0
        _G.state.wheatGrowingSeason = true
    end
    if _G.state.wheatGrowingSeason and _G.state.wheatSeasonCounter > 0.5 then
        _G.state.wheatGrowingSeason = false
    end
    local updatedChunks = _G.newAutotable(2)
    local objectsToBeDeleted
    local needsToBeDeleted = false
    for idx, obj in ipairs(activeEntities) do
        if obj.toBeDeleted then
            if needsToBeDeleted == false then
                needsToBeDeleted = true
                objectsToBeDeleted = {}
            end
            objectsToBeDeleted[idx] = true
        else
            obj:animate(dt)
        end
    end
    if needsToBeDeleted then
        activeEntities = _G.arrayRemove(
            activeEntities, function(t, i, j)
                return not objectsToBeDeleted[i]
            end)
    end
    prof.pop("AE")

    prof.push("UPDATE_CHUNK_OBJ")
    local tileStartX, tileStartY, tileEndX, tileEndY = _G.state.topLeftChunkX - 1, _G.state.topLeftChunkY,
        _G.state.bottomRightChunkX + 1, _G.state.bottomRightChunkY

    local firstRow = math.min(tileStartX + tileStartY, tileEndX + tileEndY)
    local lastRow = math.max(tileStartX + tileStartY, tileEndX + tileEndY)

    local firstColumn = math.min(tileStartX - tileStartY, tileEndX - tileEndY)
    local lastColumn = math.max(tileStartX - tileStartY, tileEndX - tileEndY)

    for row = firstRow, lastRow do
        local shift = bit.band(bit.bxor(row, firstColumn), 1)
        for column = firstColumn + shift, lastColumn, 2 do
            local xx, yy = bit.rshift(row + column, 1), bit.rshift(row - column, 1)
            if updatedChunks[xx][yy] ~= true then
                if _G.state.chunkObjects[xx][yy] then
                    for _, obj in pairs(_G.state.chunkObjects[xx][yy]) do
                        if obj.animated then
                            if obj:isVisibleOnScreen() then
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
    prof.pop("UPDATE_CHUNK_OBJ")
end

local tableOfFunctions = {
    update = update,
    draw = drawObject,
    chunk = object[press.cx][press.cy],
    mousereleased = _G.mousereleased,
    mousepressed = mousepressed,
    active = activeEntities,
    object = object,
    batch = objectBatch,
    shadow = shadowBatch,
    addObjectAt = addObjectAt
}
return tableOfFunctions
