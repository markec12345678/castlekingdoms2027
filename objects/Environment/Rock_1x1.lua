local active_entities, object, tile_quads, object_batch = ...

local Structure = require("objects.Structure")

local Rock_alias = _G.class('Rock_alias', Structure)
function Rock_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self.gx = gx
    self.gy = gy
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.tile = tile
    self.base_offset_y = offset_y or 0
    self.additional_offset_y = 0
    self.offset_x = offset_x or 0
    self.offset_y = self.additional_offset_y - self.base_offset_y
    Structure.render(self)
end

local Rock = class('Rock', Structure)
function Rock:initialize(gx, gy, type)
    local mytype = "Rock"
    Structure.initialize(self, gx, gy, mytype)
    self.gx = chunk_width * self.cx + self.i
    self.gy = chunk_width * self.cy + self.o
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.qid = nil
    self.tile = tile_quads["mountain_rocks_1tile (" .. love.math.random(1, 16) .. ")"]
    self.offset_x = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offset_y = -sh + 16

    _G.buildingheightmap[self.cx][self.cy][self.i][self.o] = 15
    Structure.render(self)
end

return Rock
