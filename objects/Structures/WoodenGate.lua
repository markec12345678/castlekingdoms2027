local _, _, _, _ = ...
local tilesEast, quadArrayEast = _G.indexBuildingQuads("wooden_gate (1)")
local tilesSouth, quadArraySouth = _G.indexBuildingQuads("wooden_gate (2)")

local Structure = require("objects.Structure")
local Object = require("objects.Object")

local WoodenGateAlias = _G.class("WoodenGateAlias", Structure)
function WoodenGateAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    self.parent = parent
    Structure.initialize(self, gx, gy)
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = offsetY
    self:render()
end

function WoodenGateAlias:serialize()
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

function WoodenGateAlias.static:deserialize(data)
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

local WoodenGate = _G.class("WoodenGate", Structure)
WoodenGate.static.WIDTH = 3
WoodenGate.static.LENGTH = 3
WoodenGate.static.HEIGHT = 17
WoodenGate.static.DESTRUCTIBLE = true
function WoodenGate:initialize(gx, gy, orientation)
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
    self.offsetY = -sh + 32 + 16


    for x = 0, 2 do
        for y = 0, 2 do
            _G.state.map:setWalkable(gx + x, gy + y, 1)
            if self.orientation == "east" and y == 1 then
                _G.state.map:setWalkable(gx + x, gy + y, 0)
            end
            if self.orientation == "south" and x == 1 then
                _G.state.map:setWalkable(gx + x, gy + y, 0)
            end
        end
    end

    for tile = 1, tiles do
        local wg = WoodenGateAlias:new(arr[tile], self.gx, self.gy + (tiles - tile + 1), self,
            self.offsetY - 0 - 8 * (tiles - tile + 1))
        wg.tileKey = tile
    end

    for tile = 1, tiles do
        local wg = WoodenGateAlias:new(arr[tiles + 1 + tile], self.gx + tile, self.gy, self,
            self.offsetY - 0 - 8 * tile, 16)
        wg.tileKey = tiles + 1 + tile
    end



    for tile = 1, tiles do
        if not _G.objectFromClassAtGlobal(self.gx + tile - 1, self.gy + 2, WoodenGateAlias) then
            local wg = WoodenGateAlias:new(arr[tile], self.gx + tile - 1, self.gy + 2, self,
                self.offsetY - 8 - 8 * tile)
            wg.tileKey = tile
        end
    end

    for tile = 1, tiles do
        if not _G.objectFromClassAtGlobal(self.gx + 2, self.gy - tile + 2, WoodenGateAlias) then
            local wg = WoodenGateAlias:new(arr[tiles + 1 + tile], self.gx + 2, self.gy - tile + 2, self,
                self.offsetY - 8 - 8 * (tiles - tile + 1), 16)
            wg.tileKey = tiles + 1 + tile
        end
    end
    local wg = WoodenGateAlias:new(arr[tiles + 1], self.gx + 2, self.gy + 2, self,
        self.offsetY - 32)
    wg.tileKey = tiles + 1

    self:applyBuildingHeightMap(nil, true)
end

function WoodenGate:load(data)
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

function WoodenGate:serialize()
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

function WoodenGate.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return WoodenGate
