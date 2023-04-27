local tiles, quadArray = _G.indexBuildingQuads("wood_tower", false)
local Object = require("objects.Object")
local Structure = require("objects.Structure")

local WoodenTowerAlias = _G.class("WoodenTowerAlias", Structure)
function WoodenTowerAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = offsetY
    self:render()
end

function WoodenTowerAlias:serialize()
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

function WoodenTowerAlias.static:deserialize(data)
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

local WoodenTower = class("WoodenTower", Structure)
WoodenTower.static.WIDTH = 2
WoodenTower.static.LENGTH = 2
WoodenTower.static.HEIGHT = 17
WoodenTower.static.DESTRUCTIBLE = true
function WoodenTower:initialize(gx, gy, type)
    local mytype = "Wooden Tower"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offsetY = -sh + 16 + 16

    for tile = 1, tiles do
        local wt = WoodenTowerAlias:new(
            quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self, self.offsetY - 16 + 8 * (tiles - tile + 1))
        wt.tileKey = tile
    end
    for tile = 1, tiles do
        local wt = WoodenTowerAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, self.offsetY - 16 + 8 * tile, 16)
        wt.tileKey = tiles + 1 + tile
    end

    _G.terrainSetTileAt(self.gx, self.gy, _G.terrainBiome.none)
    _G.terrainSetTileAt(self.gx, self.gy + 1, _G.terrainBiome.none)
    _G.terrainSetTileAt(self.gx + 1, self.gy, _G.terrainBiome.none)
    _G.terrainSetTileAt(self.gx + 1, self.gy + 1, _G.terrainBiome.none)
    self:applyBuildingHeightMap()
end

function WoodenTower:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    self:render()
end

function WoodenTower:serialize()
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

function WoodenTower.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return WoodenTower
