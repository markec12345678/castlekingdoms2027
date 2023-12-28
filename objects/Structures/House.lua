local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")

local tiles, quadArray = _G.indexBuildingQuads("housing (1)", true)
local HouseAlias = _G.class("HouseAlias", Structure)
function HouseAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function HouseAlias:serialize()
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

function HouseAlias.static:deserialize(data)
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

local House = _G.class("House", Structure)

House.static.WIDTH = 4
House.static.LENGTH = 4
House.static.HEIGHT = 17
House.static.ALIAS_NAME = "HouseAlias"
House.static.DESTRUCTIBLE = true

function House:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "House")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -39
    for tile = 1, tiles do
        local hsl = HouseAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = HouseAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile,
            16)
        hsl.tileKey = tiles + 1 + tile
    end

    for xx = 1, 3 do
        for yy = 1, 3 do
            HouseAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, self.offsetX, self.offsetY)
        end
    end

    self:applyBuildingHeightMap()
    ActionBar:updatePopulationCount()
    Structure.render(self)
end

function House:destroy()
    ActionBar:updatePopulationCount()
    Structure.destroy(self)
end

function House:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function House:serialize()
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
    data.tier = self.tier
    return data
end

function House.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function House:onClick()
    ActionBar:switchMode("house")
    _G.bus.emit(Events.UpgradeHouse, 1, self)
end

return House
