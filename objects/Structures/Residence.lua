local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")

local tiles, quadArray = _G.indexBuildingQuads("housing (5)", true)
local ResidenceAlias = _G.class("ResidenceAlias", Structure)
function ResidenceAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function ResidenceAlias:serialize()
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

function ResidenceAlias.static:deserialize(data)
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

local Residence = _G.class("Residence", Structure)

Residence.static.WIDTH = 4
Residence.static.LENGTH = 4
Residence.static.HEIGHT = 17
Residence.static.ALIAS_NAME = "ResidenceAlias"
Residence.static.DESTRUCTIBLE = true

function Residence:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "Residence")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.offsetX = 0
    self.offsetY = -52
    self.tier = 3
    self.clickedHouseX = gx
    self.clickedHouseY = gy
    self.tierOneUpgraded = false
    self.tile = quadArray[tiles + 1]
    for tile = 1, tiles do
        local hsl = ResidenceAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = ResidenceAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile,
            16)
        hsl.tileKey = tiles + 1 + tile
    end

    for xx = 1, 3 do
        for yy = 1, 3 do
            ResidenceAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, self.offsetX, self.offsetY)
        end
    end
    self:applyBuildingHeightMap()
    ActionBar:updatePopulationCount()

    Structure.render(self)
end

function Residence:destroy()
    ActionBar:updatePopulationCount()
    Structure.destroy(self)
end

function Residence:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function Residence:serialize()
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
    data.clickedHouseX = self.clickedHouseX
    data.clickedHouseY = self.clickedHouseY
    return data
end

function Residence.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function Residence:onClick()
    ActionBar:switchMode("house")
    _G.bus.emit(Events.UpgradeHouse, 3, self)
end

return Residence
