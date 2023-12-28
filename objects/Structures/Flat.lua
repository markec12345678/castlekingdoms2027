local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")

local tiles, quadArray = _G.indexBuildingQuads("housing (2)", true)
local FlatAlias = _G.class("FlatAlias", Structure)
function FlatAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function FlatAlias:serialize()
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

function FlatAlias.static:deserialize(data)
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

local Flat = _G.class("Flat", Structure)

Flat.static.WIDTH = 4
Flat.static.LENGTH = 4
Flat.static.HEIGHT = 17
Flat.static.ALIAS_NAME = "FlatAlias"
Flat.static.DESTRUCTIBLE = true

function Flat:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "Flat")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.offsetX = 0
    self.offsetY = -52
    self.tile = quadArray[tiles + 1]
    for tile = 1, tiles do
        local hsl = FlatAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = FlatAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile,
            16)
        hsl.tileKey = tiles + 1 + tile
    end

    for xx = 1, 3 do
        for yy = 1, 3 do
            FlatAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, self.offsetX, self.offsetY)
        end
    end
    self:applyBuildingHeightMap()
    ActionBar:updatePopulationCount()

    Structure.render(self)
end

function Flat:destroy()
    ActionBar:updatePopulationCount()
    Structure.destroy(self)
end

function Flat:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function Flat:serialize()
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

function Flat.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function Flat:onClick()
    ActionBar:switchMode("house")
    _G.bus.emit(Events.UpgradeHouse, 2, self)
end

return Flat
