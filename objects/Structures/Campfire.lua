local object, tile_quads, object_batch = ...
local Structure = require("objects.Structure")

local Campfire = class('Campfire', Structure)
function Campfire:initialize(gx, gy, type)
    Structure.initialize(self, gx, gy, type or "Campfire")
    setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.qid = nil
	self.tile = tile_quads["campfire (1)"]
	print(self.gx, self.gy)
    self.offset_x = 0
    self.offset_y = 0
    self.level = 1
    self.rotation = 1
    self.hover_action = true

    local ccx, ccy
    for xx = -2, 4 do
        for yy = -2, 4 do
            ccx, ccy = terrainSetTileAt(self.gx + xx, self.gy + yy,
                                        math.random(6, 8))
        end
    end
	update_terrain(ccx, ccy)
end

return Campfire
