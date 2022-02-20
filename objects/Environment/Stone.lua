local object_batch, active_objects, tile_quads, object = ...
local Object = require("objects.Object")

local tiles_stone = _G.indexQuads("tile_destroyed_stone", 32)

local Stone = class('Stone', Object)
function Stone:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    self.tile = tiles_stone[love.math.random(1, 32)]
    local _, _, _, lh = self.tile:getViewport()
    self.offset_y = 16 - lh + 3
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
    self:render()
    for xx = -4, 4 do
        for yy = -4, 4 do
            if love.math.random(1, 8) == 1 then
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt, _G.terrain_biome.abundant_grass)
            end
        end
    end
    for xx = -2, 2 do
        for yy = -2, 2 do
            if love.math.random(1, 8) == 2 then
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.abundant_grass_stones_white)
            end
        end
    end
    for xx = -3, 3 do
        for yy = -3, 3 do
            if love.math.random(1, 20) == 4 then
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.abundant_grass_stones_white)
            end
        end
    end
end

return Stone
