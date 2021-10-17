local object, tile_quads = ...
local Structure = require("objects.Structure")

local tiles, quad_array = _G.indexBuildingQuads("small_wooden_castle (1)")
local tile_castle_door_1 = tile_quads["doors_bits (3)"]
local tile_castle_door_2 = tile_quads["doors_bits (4)"]

local Castle_door = _G.class('Castle_door', Structure)
function Castle_door:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self.gx = gx
    self.gy = gy
    _G.setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = nil
    self.tile = tile
    self.offset_x = offset_x or 0
    self.offset_y = -67 + 16
end

local Castle_alias = class('Castle_alias', Structure)
function Castle_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self.gx = gx
    self.gy = gy
    setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = nil
    self.tile = tile
    self.offset_x = offset_x or 0
    self.offset_y = -(offset_y or 0)
end

local Castle = class('Castle', Structure)
function Castle:initialize(gx, gy, type)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.qid = nil
    self.tile = quad_array[tiles + 1]
    self.offset_x = 0
    self.offset_y = -93
    self.level = 1
    self.rotation = 1
    for tile = 1, tiles do
        Castle_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
    end

    for tile = 1, tiles do
        Castle_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offset_y + 8 * tile, 16)
    end

    Castle_alias:new(tile_quads["empty"], self.gx - 5 + 6, self.gy + 6, self)
    Castle_alias:new(tile_quads["empty"], self.gx - 4 + 6, self.gy + 6, self)
    Castle_alias:new(tile_quads["empty"], self.gx - 3 + 6, self.gy + 6, self)
    Castle_alias:new(tile_quads["empty"], self.gx - 2 + 6, self.gy + 6, self)
    Castle_alias:new(tile_quads["empty"], self.gx - 1 + 6, self.gy + 6, self)

    Castle_alias:new(tile_quads["empty"], self.gx + 6, self.gy + 6, self)

    Castle_alias:new(tile_quads["empty"], self.gx + 6, self.gy - 1 + 6, self)
    Castle_alias:new(tile_quads["empty"], self.gx + 6, self.gy - 2 + 6, self)
    Castle_alias:new(tile_quads["empty"], self.gx + 6, self.gy - 3 + 6, self)
    Castle_alias:new(tile_quads["empty"], self.gx + 6, self.gy - 4 + 6, self)
    Castle_alias:new(tile_quads["empty"], self.gx + 6, self.gy - 5 + 6, self)
    Castle_door:new(tile_castle_door_1, self.gx + 2, self.gy + 7, self)
    Castle_door:new(tile_castle_door_2, self.gx + 4, self.gy + 7, self)
    _G.spawn_point_x, _G.spawn_point_y = self.gx + 3, self.gy + 8

    local ccx, ccy
    for xx = -2, 8 do
        for yy = -2, 8 do
            if yy == 7 or xx == 7 or xx == -1 or yy == -1 then
                ccx, ccy = terrainSetTileAt(self.gx + xx, self.gy + yy, math.random(6, 8))
            elseif math.random(1, 3) == 1 then
                ccx, ccy = terrainSetTileAt(self.gx + xx, self.gy + yy, math.random(6, 8))
            end
        end
    end

    update_terrain(ccx, ccy)
end

return Castle
