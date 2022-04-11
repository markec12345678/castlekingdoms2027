local _, tile_quads = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles, quad_array = _G.indexBuildingQuads("small_wooden_castle (1)")
local tile_castle_door_1 = tile_quads["doors_bits (3)"]
local tile_castle_door_2 = tile_quads["doors_bits (4)"]

local Castle_door = _G.class('Castle_door', Structure)
function Castle_door:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.tile = tile
    self.offset_x = offset_x or 0
    self.offset_y = (offset_y or 0) + -67 + 16
    Structure.render(self)
end

local Castle_alias = _G.class('Castle_alias', Structure)
function Castle_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.tile = tile
    self.offset_x = offset_x or 0
    self.offset_y = -(offset_y or 0)
    Structure.render(self)
end

local Castle = _G.class('Castle', Structure)
function Castle:initialize(gx, gy, type)
    type = type or "Castle (default)"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.tile = tile_quads["empty"]
    self.offset_x = 0
    self.offset_y = -93

    for tile = 1, tiles do
        Castle_alias:new(quad_array[tile], self.gx + tile, self.gy + tiles, self, -self.offset_y + 8 * tile + 48, -16)
    end

    local _, _, _, center_tile_offset_y = quad_array[tiles + 1]:getViewport()
    Castle_alias:new(quad_array[tiles + 1], self.gx + tiles, self.gy + tiles, self, center_tile_offset_y - 16)

    for tile = 1, tiles do
        Castle_alias:new(quad_array[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1) + 48, 32)
    end

    Castle_door:new(tile_castle_door_1, self.gx + 2, self.gy + 7, self)
    Castle_door:new(tile_castle_door_2, self.gx + 4, self.gy + 7, self)
    _G.spawn_point_x, _G.spawn_point_y = self.gx + 3, self.gy + 8

    for xx = 0, 6 do
        for yy = 0, 6 do
            local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(self.gx + xx, self.gy + yy)
            _G.buildingheightmap[ccx][ccy][xxx][yyy] = 23
        end
    end
    for xx = -2, 8 do
        for yy = -2, 8 do
            if yy == 7 or xx == 7 or xx == -1 or yy == -1 then
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.scarce_grass)
            elseif math.random(1, 3) == 1 then
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.scarce_grass)
            end
        end
    end
    Structure.render(self)
end
function Castle.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type)
    Object.deserialize(obj, data)
    return obj
end

return Castle
