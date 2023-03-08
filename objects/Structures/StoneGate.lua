local _, _, _, _ = ...
local tilesEast, quadArrayEast = _G.indexBuildingQuads("small_stone_gate (1)")
local tilesSouth, quadArraySouth = _G.indexBuildingQuads("small_stone_gate (2)")

local Structure = require("objects.Structure")
local Object = require("objects.Object")

local StoneGateAlias = _G.class("StoneGateAlias", Structure)
function StoneGateAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    self.parent = parent
    Structure.initialize(self, gx, gy)
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = offsetY
    self:render()
end

function StoneGateAlias:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.tileKey = self.tileKey
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function StoneGateAlias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    local arr
    if obj.parent.orientation == "east" then
        arr = quadArrayEast
    else
        arr = quadArraySouth
    end
    if data.tileKey then
        obj.tile = arr[data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end
    return obj
end

local StoneGate = _G.class("StoneGate", Structure)
StoneGate.static.WIDTH = 5
StoneGate.static.LENGTH = 5
StoneGate.static.HEIGHT = 17
StoneGate.static.DESTRUCTIBLE = true
function StoneGate:initialize(gx, gy, orientation)
    Structure.initialize(self, gx, gy)
    self.health = 100
    local arr, tiles
    if orientation == "east" then
        arr, tiles = quadArrayEast, tilesEast
    else
        arr, tiles = quadArraySouth, tilesSouth
    end
    self.orientation = orientation
    self.tile = arr[tiles + 1]
    self.offsetX = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offsetY = -sh + 80


    for x = 0, 5 do
        for y = 0, 5 do
            _G.state.map:setWalkable(gx + x, gy + y, 1)
            if self.orientation == "east" and y == 2 then
                _G.state.map:setWalkable(gx + x, gy + y, 0)
            end
            if self.orientation == "south" and x == 2 then
                _G.state.map:setWalkable(gx + x, gy + y, 0)
            end
        end
    end

    for tile = 1, tiles do
        local wg = StoneGateAlias:new(arr[tile], self.gx, self.gy + (tiles - tile + 1), self,
            self.offsetY - 8 * (tiles - tile + 1))
        wg.tileKey = tile
    end

    for tile = 1, tiles do
        local wg = StoneGateAlias:new(arr[tiles + 1 + tile], self.gx + tile, self.gy, self,
            self.offsetY - 8 * tile, 16)
        wg.tileKey = tiles + 1 + tile
    end

    local wg = StoneGateAlias:new(arr[tiles + 1], self.gx + 2, self.gy + 2, self,
        -self.offsetY)
    wg.tileKey = tiles + 1

    local tileQuads = require("objects.object_quads")
    for xx = 0, StoneGate.static.WIDTH - 1 do
        for yy = 0, StoneGate.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + gy, Structure) then
                StoneGateAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end

    self:applyBuildingHeightMap(nil, true)
end

function StoneGate:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    local arr, tiles
    if self.orientation == "east" then
        arr, tiles = quadArrayEast, tilesEast
    else
        arr, tiles = quadArraySouth, tilesSouth
    end
    self.tile = arr[tiles + 1]
    self:render()
end

function StoneGate:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.orientation = self.orientation
    return data
end

function StoneGate.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return StoneGate
