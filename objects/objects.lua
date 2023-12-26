local objectAtlas = ...
local newAutotable = _G.newAutotable
local ScreenToIsoX, ScreenToIsoY = _G.ScreenToIsoX, _G.ScreenToIsoY
local chunkWidth, chunkHeight = _G.chunkWidth, _G.chunkHeight
local tileWidth, tileHeight = _G.tileWidth, _G.tileHeight
local love = _G.love
local bit = _G.bit
local prof = require("libraries.jprof")
local inspect = require("libraries.inspect")
local Object = require("objects.Object")
local console = require("libraries.console")
local showPaths = false
console.addCommand("togglePaths", function() showPaths = not showPaths end, "Show units paths")

local function recursiveLoadModules(folder, fileTree)
    local filesTable = love.filesystem.getDirectoryItems(folder)
    for _, v in ipairs(filesTable) do
        local file = folder .. "/" .. v
        local info = love.filesystem.getInfo(folder .. "/" .. v)
        if info then
            if info.type == "file" then
                local extension = file:match("^.+(%..+)$")
                if extension == ".lua" then
                    local filename = file:gsub("%.lua", "")
                    local filename = filename:gsub("/", ".")
                    require(filename)
                end
            elseif info.type == "directory" then
                fileTree = recursiveLoadModules(file, fileTree)
            end
        end
    end
    return fileTree
end

recursiveLoadModules("objects/Units", "")
recursiveLoadModules("objects/Structures", "")
recursiveLoadModules("objects/Environment", "")

local PineTree = require("objects.Environment.PineTree")
local Shrub = require("objects.Environment.Shrub")
local Stone = require("objects.Environment.Stone")
local Iron = require("objects.Environment.Iron")
local Rock_4x4 = require("objects.Environment.Rock_4x4")
local Rock_3x3 = require("objects.Environment.Rock_3x3")
local Rock_2x2 = require("objects.Environment.Rock_2x2")
local Rock_1x1 = require("objects.Environment.Rock_1x1")

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
----Calculate center chunk
local CenterX = math.round(ScreenToIsoX(_G.ScreenWidth / 2 - 16 + _G.state.viewXview,
    _G.ScreenHeight / 2 - 8 + _G.state.viewYview))
local CenterY = math.round(ScreenToIsoY(_G.ScreenWidth / 2 - 16 + _G.state.viewXview,
    _G.ScreenHeight / 2 - 8 + _G.state.viewYview))
---------------------------------------
_G.xchunk = math.floor(CenterX / (chunkWidth))
_G.ychunk = math.floor(CenterY / (chunkWidth))
----Generate spriteBatch
-- local canvas = love.graphics.newCanvas()
if not _G.testMode then
    objectAtlas:setFilter("nearest", "nearest")
end


_G.stockpile = require("objects.Controllers.StockpileController")
_G.foodpile = require("objects.Controllers.FoodController")
_G.weaponpile = require("objects.Controllers.WeaponController")
--- NOTE --------------------------
--- NOTE --------------------------
--- NOTE Object classes END ---

--- Add an _G.state.object at a location and add it to a table.
---@param cx number X position in Chunk.
---@param cy number Y position in Chunk.
---@param x number local X position in Chunk 0-63
---@param y number local Y position in Chunk 0-63
---@param objectToAdd Object Object to add.
---@return Object
function _G.addObjectAt(cx, cy, x, y, objectToAdd)
    if type(_G.state.object[cx][cy][x][y]) ~= "table" then
        _G.state.object[cx][cy][x][y] = {}
    end
    _G.state.object[cx][cy][x][y][#_G.state.object[cx][cy][x][y] + 1] = objectToAdd
    return objectToAdd
end

objectAtlas:setWrap("clampzero")

--- Add an _G.state.object at a location and add it to a table.
---@param cx number X position in Chunk.
---@param cy number Y position in Chunk.
---@param x number local X position in Chunk 0-63
---@param y number local Y position in Chunk 0-63
---@param objectToRemove? Object If provided: Removes that specific _G.state.object from the tile. If nil: Remove all objects from the tile.
function _G.removeObjectAt(cx, cy, x, y, objectToRemove)
    x = math.floor(x)
    y = math.floor(y)
    if x > 63 or y > 63 then
        print("Trying to remove at position", cx, cy, x, y)
        print((debug.traceback("Error: trying to remove out of bounds unit", 1):gsub("\n[^\n]+$", "")))
        love.event.quit()
    end
    -- If objectToRemove, then remove only that _G.state.object from the specified tile.
    if type(_G.state.object[cx][cy][x][y]) == "table" then
        if objectToRemove then
            for index, currentObject in ipairs(_G.state.object[cx][cy][x][y]) do
                if currentObject == objectToRemove then
                    table.remove(_G.state.object[cx][cy][x][y], index)
                    break
                end
            end
            -- If nil, then remove all objects from the specified tile.
        else
            for _, currentObject in ipairs(_G.state.object[cx][cy][x][y]) do
                currentObject:destroy()
            end
            _G.state.object[cx][cy][x][y] = {}
        end
    end
end

--- Remove a class from a Global position.
---@param gx number Global X coordinate.
---@param gy number Global Y coordinate.
---@param classToRemove string|table Name of the class to remove or the class itself.
function _G.removeObjectFromClassAtGlobal(gx, gy, classToRemove)
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if x > 63 or y > 64 then
        print("Trying to remove at position", cx, cy, x, y)
        print((debug.traceback("Error: global trying to remove out of bounds unit", 1):gsub("\n[^\n]+$", "")))
        love.event.quit()
    end
    if type(_G.state.object[cx][cy][x][y]) == "table" then
        for index, currentObject in ipairs(_G.state.object[cx][cy][x][y]) do
            if currentObject.class.name == classToRemove or currentObject.type == classToRemove then
                _G.state.map:setWalkable(gx, gy, 0)
                table.remove(_G.state.object[cx][cy][x][y], index)
                currentObject:destroy()
                Object.destroy(currentObject) --TODO: only here because of pine tree abusing the :destroy method
                break
            end
        end
    end
end

--- Returns the currentObject if it is of the given type.
---@param cx number X position in Chunk.
---@param cy number Y position in Chunk.
---@param x number local X position in Chunk 0-63
---@param y number local Y position in Chunk 0-63
---@param objType string Name of the Type.
function _G.objectFromTypeAt(cx, cy, x, y, objType)
    if type(_G.state.object[cx][cy][x][y]) == "table" then
        for _, currentObject in ipairs(_G.state.object[cx][cy][x][y]) do
            if (currentObject.type and currentObject.type == objType) or currentObject.class.name == objType then
                return currentObject
            end
        end
    end
    return false
end

--- Returns the currentObject if it is of the given type.
---@param cx number X position in Chunk.
---@param cy number Y position in Chunk.
---@param x number local X position in Chunk 0-63
---@param y number local Y position in Chunk 0-63
---@param objectCompared Object Object to compare.
function _G.isObjectAt(cx, cy, x, y, objectCompared)
    if type(_G.state.object[cx][cy][x][y]) == "table" then
        for _, currentObject in ipairs(_G.state.object[cx][cy][x][y]) do
            if currentObject == objectCompared then
                return currentObject
            end
        end
    end
    return false
end

--- Returns the currentObject if it is a table.
---@param gx number Global X coordinate.
---@param gy number Global Y coordinate.
---@param objClass string|table Name of the _G.state.object's class or the class itself.
---@return boolean|Object
function _G.objectFromClassAtGlobal(gx, gy, objClass)
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if type(_G.state.object[cx][cy][x][y]) == "table" then
        for _, currentObject in ipairs(_G.state.object[cx][cy][x][y]) do
            if currentObject.class.name == objClass or currentObject.class == objClass then
                return currentObject
            end
        end
    end
    return false
end

--- Returns the currentObject if it is a table.
---@param gx number Global X coordinate.
---@param gy number Global Y coordinate.
---@param objClass table|string Class or name of the _G.state.object's class.
---@return Object|false
function _G.objectFromSubclassAtGlobal(gx, gy, objClass)
    if (not _G.isGlobalCoordInsideMap(gx, gy)) then
        return false
    end
    if type(objClass) == "string" then
        objClass = _G.getClassByName(objClass)
        if not objClass then error(string.format("invalid class name: %s", objClass)) end
    end
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if type(_G.state.object[cx][cy][x][y]) == "table" then
        for _, currentObject in ipairs(_G.state.object[cx][cy][x][y]) do
            if currentObject.class.isSubclassOf and currentObject.class:isSubclassOf(objClass) then
                return currentObject
            end
        end
    end
    return false
end

--- Returns the currentObject if it is a table.
---@param gx number Global X coordinate.
---@param gy number Global Y coordinate.
---@param objClass table The _G.state.object's class.
---@return Object[]
function _G.allObjectsFromSubclassAtGlobal(gx, gy, objClass)
    local data = {}
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if type(_G.state.object[cx][cy][x][y]) == "table" then
        for _, currentObject in ipairs(_G.state.object[cx][cy][x][y]) do
            if currentObject.class.isSubclassOf and currentObject.class:isSubclassOf(objClass) then
                data[#data + 1] = currentObject
            end
        end
    end
    return data
end

---Returns whether something is an _G.state.object at a given location.
---@param cx number X position in Chunk.
---@param cy number Y position in Chunk.
---@param x number local X position in Chunk 0-63
---@param y number local Y position in Chunk 0-63
---@return boolean
function _G.objectAt(cx, cy, x, y)
    if (type(_G.state.object[cx][cy][x][y]) == "table" and next(_G.state.object[cx][cy][x][y]) == nil) or not _G.state.object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") then
        return false
    else
        return true
    end
end

function _G.importantObjectAt(cx, cy, x, y)
    if (type(_G.state.object[cx][cy][x][y]) == "table" and next(_G.state.object[cx][cy][x][y]) == nil) or not _G.state.object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") or objectFromTypeAt(cx, cy, x, y, "Tall shrub") or
        objectFromTypeAt(cx, cy, x, y, "Short shrub") then
        return false
    else
        return true
    end
end

function _G.isWithinKeepUpgradeRadius(gx, gy)
    for xx = -3, 3 do
        for yy = -3, 3 do
            if not (gx + xx < 0 or gy + yy < 0
                    or gx + xx > _G.chunkWidth * _G.chunksWide
                    or gy + yy > _G.chunkHeight * _G.chunksHigh) then
                local structure = _G.objectFromSubclassAtGlobal(gx + xx, gy + yy, "Structure")
                if structure then
                    structure = structure.parent or structure

                    if not structure.class then
                        return false
                    end

                    if structure.class.name == "SaxonHall" or structure.class.name == "Keep" or structure.class.name == "WoodenKeep" or structure.class.name == "Fortress" then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function _G.shouldTileBeWalkable(gx, gy)
    if _G.objectFromSubclassAtGlobal(gx, gy, "Structure") then
        return false
    end
    if _G.objectFromSubclassAtGlobal(gx, gy, "Tree") then
        return false
    end
    if _G.state.map:isWaterAt(gx, gy) then
        return false
    end
    return true
end

function _G.importantObjectAtGlobal(gx, gy)
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if (type(_G.state.object[cx][cy][x][y]) == "table" and next(_G.state.object[cx][cy][x][y]) == nil) or not _G.state.object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") or objectFromTypeAt(cx, cy, x, y, "Tall shrub") or
        objectFromTypeAt(cx, cy, x, y, "Short shrub") then
        return false
    else
        return true
    end
end

function _G.objectAtGlobal(gx, gy)
    local cx, cy, x, y = _G.getLocalCoordinatesFromGlobal(gx, gy)
    if (type(_G.state.object[cx][cy][x][y]) == "table" and next(_G.state.object[cx][cy][x][y]) == nil) or not _G.state.object[cx][cy][x][y] or
        objectFromTypeAt(cx, cy, x, y, "Stump") then
        return false
    else
        return true
    end
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
            if _G.state.objectBatch[xx][yy] ~= nil then
                love.graphics.drawInstanced(_G.state.objectBatch[xx][yy], _G.state.objectMesh[xx][yy]:getVertexCount(),
                    -_G.state.viewXview * _G.state.scaleX +
                    (xx * _G.state.scaleX - yy * _G.state.scaleX) * chunkWidth *
                    tileWidth * 0.5, -_G.state.viewYview * _G.state.scaleX +
                    (xx * _G.state.scaleX + yy * _G.state.scaleX) * chunkHeight * tileHeight * 0.5, 0,
                    _G.state.scaleX, _G.state.scaleX)
            end
        end
    end
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1, 1)

    if showPaths then
        for _, obj in ipairs(_G.state.activeEntities) do
            if obj:isVisibleOnScreen() then
                if obj.debugDrawPath then obj:debugDrawPath() end
            end
        end
    end
end

local function mousepressed(x, y, button)
    local mx, my = x, y
    press.gx, press.gy = _G.getTerrainTileOnMouse(mx, my)
    press.cx = math.floor(press.gx / chunkWidth)
    press.cy = math.floor(press.gy / chunkWidth)
    press.x = (press.gx) % (chunkWidth)
    press.y = (press.gy) % (chunkWidth)
    if button == 1 then
        local Structure = require("objects.Structure")
        if (not _G.isGlobalCoordInsideMap(press.gx, press.gy)) then
            return
        end
        local structure = _G.objectFromSubclassAtGlobal(press.gx, press.gy, Structure)
        local Unit = require("objects.Units.Unit")
        local unit = _G.objectFromSubclassAtGlobal(press.gx, press.gy, Unit)
        if structure then
            structure = structure.parent or structure
            if structure.onClick and not _G.DestructionController.active and not _G.BuildController.start then
                structure:onClick()
            else
                _G.BuildController:mousepressed(mx, my)
            end
        elseif unit and unit.onClick then
            local ActionBar = require("states.ui.ActionBar")
            if _G.selectedUnit ~= nil then
                _G.selectedUnitUI = _G.selectedUnit.type  --TEMPORARY SOLUTION IT WOULD BE NICE TO HANDLE IT WITH AN EVENT
                print(_G.selectedUnitUI)
            end
            ActionBar:switchMode("unitsUI")
            if not unit.onClick then
                print("clicked on it, but no onClick")
            else
                unit:onClick()
            end
        else
            _G.BuildController:mousepressed(mx, my)
        end
    elseif button == 2 then
        if _G.selectedUnit then
            _G.selectedUnit:gotoUserWaypoint(press.gx, press.gy)
        else
            _G.state.map:setWalkableWater(press.gx, press.gy)
            local loveframes = require("libraries.loveframes")
            local states = require("states.ui.states")
            if loveframes.GetState() == states.STATE_GRANARY then
                local ActionBar = require("states.ui.ActionBar")
                ActionBar:switchMode()
            end
        end
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

function _G.registerAnimatedEntity(obj)
    if _G.state.chunkObjects[obj.cx][obj.cy] == nil then
        _G.state.chunkObjects[obj.cx][obj.cy] = {}
    end
    _G.state.chunkObjects[obj.cx][obj.cy][obj] = obj
end

function _G.unregisterAnimatedEntity(obj)
    _G.state.chunkObjects[obj.cx][obj.cy][obj] = nil
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

    _G.state.hopsSeasonCounter = _G.state.hopsSeasonCounter + dt
    if _G.state.hopsSeasonCounter > 5 then
        _G.state.hopsSeasonCounter = 0
        _G.state.hopsGrowingSeason = true
    end
    if _G.state.hopsGrowingSeason and _G.state.hopsSeasonCounter > 0.5 then
        _G.state.hopsGrowingSeason = false
    end
    local updatedChunks = _G.newAutotable(2)
    local objectsToBeDeleted
    local needsToBeDeleted = false
    for idx, obj in ipairs(_G.state.activeEntities) do
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
        _G.state.activeEntities = _G.removeFromObjectsArray(_G.state.activeEntities, function(t, i, j)
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
    chunk = _G.state.object[press.cx][press.cy],
    mousepressed = mousepressed,
    active = _G.state.activeEntities,
}
return tableOfFunctions
