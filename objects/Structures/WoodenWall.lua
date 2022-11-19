local _, _, tile_quads, _ = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles = {tile_quads["tile_buildings_wood_wall (1)"], tile_quads["tile_buildings_wood_wall (2)"],
    tile_quads["tile_buildings_wood_wall (3)"], tile_quads["tile_buildings_wood_wall (4)"]}

local WoodenWall = _G.class('WoodenWall', Structure)
WoodenWall.static.WIDTH = 1
WoodenWall.static.LENGTH = 1
WoodenWall.static.HEIGHT = 17
WoodenWall.static.DESTRUCTIBLE = true
function WoodenWall:initialize(gx, gy, type)
    local mytype = "Wall"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.tile = tiles[love.math.random(1, 4)]
    self.offsetX = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offsetY = -(sh - 16)
    _G.terrainSetTileAt(self.gx, self.gy, _G.terrainBiome.dirt, _G.terrainBiome.abundant_grass)
    self:applyBuildingHeightMap()
end

function WoodenWall:serialize()
    local data = {}
    local objectData = Structure.serialize(self)
    for k, v in pairs(objectData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    return data
end

function WoodenWall.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type)
    Object.deserialize(obj, data)
    obj.health = data.health
    return obj
end

return WoodenWall
