local active_entities, object, tile_quads, object_batch = ...
local Structure = require("objects.Structure")

local tiles = {tile_quads["tile_buildings_wood_wall (1)"], tile_quads["tile_buildings_wood_wall (2)"],
               tile_quads["tile_buildings_wood_wall (3)"], tile_quads["tile_buildings_wood_wall (4)"]}

local WoodenWall = class('WoodenWall', Structure)
function WoodenWall:initialize(gx, gy, type)
    local mytype = "Wall"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.tile = tiles[love.math.random(1, 4)]
    self.offset_x = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offset_y = -(sh - 16)

    _G.buildingheightmap[self.cx][self.cy][self.i][self.o] = 19
    _G.terrainSetTileAt(self.gx, self.gy, _G.terrain_biome.dirt, _G.terrain_biome.abundant_grass)
    self:render()
end

return WoodenWall
