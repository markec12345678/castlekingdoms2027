local _, _, _, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")
local NotEnoughWorkersFloat = require("objects.Structures.NotEnoughWorkersFloat")

local tiles, quadArray = _G.indexBuildingQuads("apothecary", true)
local ApothecaryAlias = _G.class("ApothecaryAlias", Structure)
local Apothecary = _G.class("Apothecary", Structure)

function ApothecaryAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    Structure.render(self)
end

function ApothecaryAlias:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.tileKey = self.tileKey
    data.baseOffsetY = self.baseOffsetY
    data.additionalOffsetY = self.additionalOffsetY
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function ApothecaryAlias.static:deserialize(data)
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

Apothecary.static.WIDTH = 6
Apothecary.static.LENGTH = 6
Apothecary.static.HEIGHT = 17
Apothecary.static.DESTRUCTIBLE = true

function Apothecary:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "Apothecary")
    self.animated = false
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 50
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -85
    self.freeSpots = 1
    self.worker = nil

    for tile = 1, tiles do
        local hsl = ApothecaryAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = ApothecaryAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile, 16)
        hsl.tileKey = tiles + 1 + tile
    end
    local tileQuads = require("objects.object_quads")
    for xx = 0, Apothecary.static.WIDTH - 1 do
        for yy = 0, Apothecary.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, Structure) then
                ApothecaryAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    self:applyBuildingHeightMap()

    self.float = NotEnoughWorkersFloat:new(self.gx, self.gy, 0, -64)
end

function Apothecary:destroy()
    self.float:destroy()
    if self.worker then
        self.worker:die()
    end
    Structure.destroy(self)
end

function Apothecary:onClick()
    local ActionBar = require("states.ui.ActionBar")
end

function Apothecary:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function Apothecary:serialize()
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
    data.freeSpots = self.freeSpots
    if self.worker then
        data.worker = _G.state:serializeObject(self.worker)
    end
    return data
end

function Apothecary.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return Apothecary
