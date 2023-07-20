local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local actionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")

local tiles, quadArray = _G.indexBuildingQuads("house_big (1)", true)
local BigResidenceAlias = _G.class("BigResidenceAlias", Structure)
function BigResidenceAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function BigResidenceAlias:serialize()
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

function BigResidenceAlias.static:deserialize(data)
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

local BigResidence = _G.class("BigResidence", Structure)

BigResidence.static.WIDTH = 4
BigResidence.static.LENGTH = 4
BigResidence.static.HEIGHT = 17
BigResidence.static.ALIAS_NAME = "BigResidenceAlias"
BigResidence.static.DESTRUCTIBLE = true

function BigResidence:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "BigResidence")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.offsetX = 0
    self.offsetY = -80
    self.tier = 4
    self.clickedHouseX = gx
    self.clickedHouseY = gy
    self.tierOneUpgraded = false
    self.tile = quadArray[tiles + 1]
    for tile = 1, tiles do
        local hsl = BigResidenceAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = BigResidenceAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile,
            16)
        hsl.tileKey = tiles + 1 + tile
    end

    for xx = 1, 3 do
        for yy = 1, 3 do
            BigResidenceAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, self.offsetX, self.offsetY)
        end
    end
    self:applyBuildingHeightMap()
    actionBar:updatePopulationCount()

    Structure.render(self)
end

function BigResidence:destroy()
    actionBar:updatePopulationCount()
    Structure.destroy(self)
end

function BigResidence:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function BigResidence:serialize()
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

function BigResidence.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function BigResidence:onClick()
    if _G.state.tier >= 5 then
        X = self.clickedHouseX
        Y = self.clickedHouseY
    end
    _G.bus.emit(Events.OnHouseUpgraded, self.tier, X, Y)
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("house")
end

return BigResidence
