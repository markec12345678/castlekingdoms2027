local active_entities, object, tile_quads, object_batch = ...
local Structure = require("objects.Structure")

local WoodenWallWalkable = class('WoodenWallWalkable', Structure)
function WoodenWallWalkable:initialize(gx, gy, type)
    local mytype = "Walkable Wall"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.tile = tile_quads["wood_wall_walkable"]
    self.offset_x = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offset_y = -(sh - 16)

    _G.terrainSetTileAt(self.gx, self.gy, _G.terrain_biome.dirt, _G.terrain_biome.abundant_grass)
end

return WoodenWallWalkable
