local _, _, _, _ = ...
local tiles, quadArray = _G.indexBuildingQuads("large_tower (1)", false)
local Object = require("objects.Object")

local Structure = require("objects.Structure")

local SquareTowerAlias = _G.class("SquareTowerAlias", Structure)
function SquareTowerAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = offsetY
    self:render()
end

function SquareTowerAlias:serialize()
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

function SquareTowerAlias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    if data.tileKey then
        obj.tile = quadArray[data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end
    return obj
end

local SquareTower = class("SquareTower", Structure)
SquareTower.static.WIDTH = 6
SquareTower.static.LENGTH = 6
SquareTower.static.HEIGHT = 17
SquareTower.static.DESTRUCTIBLE = true
function SquareTower:initialize(gx, gy, type)
    local mytype = "Square Tower"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offsetY = -sh + 16 + 16 + 16 + 16 + 16 + 16

    for tile = 1, tiles do
        local wt = SquareTowerAlias:new(
            quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self, self.offsetY - 8 * (tiles - tile + 1))
        wt.tileKey = tile
    end
    for tile = 1, tiles do
        local wt = SquareTowerAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, self.offsetY - 8 * tile, 16)
        wt.tileKey = tiles + 1 + tile
    end
    local tileQuads = require("objects.object_quads")
    for xx = 0, SquareTower.static.WIDTH - 1 do
        for yy = 0, SquareTower.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + gy, Structure) then
                SquareTowerAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end

    self:applyBuildingHeightMap()
end

function SquareTower:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    self:render()
end

function SquareTower:serialize()
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
    return data
end

function SquareTower.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return SquareTower
