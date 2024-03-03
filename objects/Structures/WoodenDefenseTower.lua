local tiles, quadArray = _G.indexBuildingQuads("large_wooden_tower", false)
local Object = require("objects.Object")

local Structure = require("objects.Structure")

local WoodenDefenseTowerAlias = _G.class("WoodenDefenseTowerAlias", Structure)
function WoodenDefenseTowerAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = offsetY
    self:render()
end

function WoodenDefenseTowerAlias:serialize()
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

function WoodenDefenseTowerAlias.static:deserialize(data)
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

local WoodenDefenseTower = class("WoodenDefenseTower", Structure)
WoodenDefenseTower.static.WIDTH = 5
WoodenDefenseTower.static.LENGTH = 5
WoodenDefenseTower.static.HEIGHT = 17
WoodenDefenseTower.static.DESTRUCTIBLE = true
function WoodenDefenseTower:initialize(gx, gy, type)
    local mytype = "Wooden Defense Tower"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offsetY = -sh + 16 + 16 + 16 + 16 + 16

    for tile = 1, tiles do
        local wt = WoodenDefenseTowerAlias:new(
            quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self, self.offsetY - 8 * (tiles - tile + 1))
        wt.tileKey = tile
    end
    for tile = 1, tiles do
        local wt = WoodenDefenseTowerAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, self.offsetY - 8 * tile, 16)
        wt.tileKey = tiles + 1 + tile
    end
    local tileQuads = require("objects.object_quads")
    for xx = 0, WoodenDefenseTower.static.WIDTH - 1 do
        for yy = 0, WoodenDefenseTower.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, Structure) then
                WoodenDefenseTowerAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end

    self:applyBuildingHeightMap()
end

function WoodenDefenseTower:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    self:render()
end

function WoodenDefenseTower:serialize()
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

function WoodenDefenseTower.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return WoodenDefenseTower
