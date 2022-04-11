local active_entities, object, tile_quads, object_batch = ...
local tiles, quad_array = _G.indexBuildingQuads("wood_tower", false)

local Structure = require("objects.Structure")

local WoodenTower_alias = _G.class('WoodenTower_alias', Structure)
function WoodenTower_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.tile = tile
    self.base_offset_y = offset_y or 0
    self.additional_offset_y = 0
    self.offset_x = offset_x or 0
    self.offset_y = self.additional_offset_y - self.base_offset_y
    for k, v in ipairs(_G.stockpile.node_list) do
        if v.gx == self.gx and v.gy == self.gy then
            table.remove(_G.stockpile.node_list, k)
            break
        end
    end
end

local WoodenTower = class('WoodenTower', Structure)
function WoodenTower:initialize(gx, gy, type)
    local mytype = "Walkable Wall"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.tile = quad_array[tiles + 1]
    self.offset_x = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offset_y = -64

    for tile = 1, tiles do
        WoodenTower_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
    end
    for tile = 1, tiles do
        WoodenTower_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offset_y + 8 * tile, 16)
    end

    _G.terrainSetTileAt(self.gx, self.gy, _G.terrain_biome.dirt, _G.terrain_biome.abundant_grass)
end

return WoodenTower
