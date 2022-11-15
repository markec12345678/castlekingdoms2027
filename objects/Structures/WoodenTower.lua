local _, _, _, _ = ...
local tiles, quadArray = _G.indexBuildingQuads("wood_tower", false)

local Structure = require("objects.Structure")

local WoodenTowerAlias = _G.class("WoodenTowerAlias", Structure)
function WoodenTowerAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = offsetY
    -- TODO: FIX THIS A BIG CAUSE OF BUGS
    -- for k, v in ipairs(_G.stockpile.node_list) do
    --     if v.gx == self.gx and v.gy == self.gy then
    --         table.remove(_G.stockpile.node_list, k)
    --         break
    --     end
    -- end
    self:render()
end

local WoodenTower = class("WoodenTower", Structure)
WoodenTower.static.WIDTH = 2
WoodenTower.static.LENGTH = 2
WoodenTower.static.HEIGHT = 17
WoodenTower.static.DESTRUCTIBLE = true
function WoodenTower:initialize(gx, gy, type)
    local mytype = "Wooden Tower"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offsetY = -sh + 16 + 16

    for tile = 1, tiles do
        WoodenTowerAlias:new(
            quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self, self.offsetY - 16 + 8 * (tiles - tile + 1))
    end
    for tile = 1, tiles do
        WoodenTowerAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, self.offsetY - 16 + 8 * tile, 16)
    end

    _G.terrainSetTileAt(self.gx, self.gy, _G.terrainBiome.none)
    _G.terrainSetTileAt(self.gx, self.gy + 1, _G.terrainBiome.none)
    _G.terrainSetTileAt(self.gx + 1, self.gy, _G.terrainBiome.none)
    _G.terrainSetTileAt(self.gx + 1, self.gy + 1, _G.terrainBiome.none)
    self:applyBuildingHeightMap()
    self:render()
end

return WoodenTower
