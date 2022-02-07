local active_entities, object, tile_quads, object_batch = ...

local Structure = require("objects.Structure")

local Rock_alias = _G.class('Rock_alias', Structure)
function Rock_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self.gx = gx
    self.gy = gy
    _G.setWalkable(self.gx, self.gy, 1)
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
    setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.qid = nil
    self.tile = tile_quads["empty"]
    self.offset_x = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offset_y = 0

    local tiles, quad_array = _G.indexBuildingQuads("rocks_3x3tile (" .. love.math.random(1, 16) .. ")", false, 3)
    for xx = 0, 3 do
        for yy = 0, 3 do
            local xxx = (self.gx + xx) % (chunk_width)
            local yyy = (self.gy + yy) % (chunk_width)
            local ccx = math.floor((self.gx + xx) / chunk_width)
            local ccy = math.floor((self.gy + yy) / chunk_width)
            _G.buildingheightmap[ccx][ccy][xxx][yyy] = 15
        end
    end
    for xx = 0, 3 do
        for yy = 0, 3 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.none)
        end
    end
    local _, _, _, center_tile_offset_y = quad_array[tiles + 1]:getViewport()

    for tile = 1, tiles do
        Rock_alias:new(quad_array[tile], self.gx + tile - 1, self.gy + tiles, self,
            center_tile_offset_y - 14 - 32 + 8 * tile)
    end

    Rock_alias:new(quad_array[tiles + 1], self.gx + tiles, self.gy + tiles, self, center_tile_offset_y - 14)

    for tile = 1, tiles do
        Rock_alias:new(quad_array[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile), self,
            center_tile_offset_y - 14 - 32 + 8 * (tiles - tile) + 8, 16)
    end
    Structure.render(self)
end

return Rock
