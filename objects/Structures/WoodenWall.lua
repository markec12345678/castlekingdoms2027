local _, _, tile_quads, _ = ...
local Structure = require("objects.Structure")

local tiles = {tile_quads["tile_buildings_wood_wall (1)"], tile_quads["tile_buildings_wood_wall (2)"],
    tile_quads["tile_buildings_wood_wall (3)"], tile_quads["tile_buildings_wood_wall (4)"]}

local WoodenWall = class('WoodenWall', Structure)
WoodenWall.static.WIDTH = 1
WoodenWall.static.LENGTH = 1
WoodenWall.static.HEIGHT = 17
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
    self:render()
end

return WoodenWall
