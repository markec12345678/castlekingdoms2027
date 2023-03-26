local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local LargeGardenAlias = _G.class("LargeGardenAlias", Structure)
function LargeGardenAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    Structure.initialize(self, gx, gy, "LargeGardenAlias")
    self.tile = tile
    self.parent = parent
    self.offsetX = offsetX
    self.offsetY = offsetY
    self:render()
end

local LargeGarden = _G.class("LargeGarden", Structure)
LargeGarden.static.WIDTH = 4
LargeGarden.static.LENGTH = 4
LargeGarden.static.HEIGHT = 0
LargeGarden.static.ALIAS_NAME = "LargeGardenAlias"
LargeGarden.static.DESTRUCTIBLE = true
function LargeGarden:initialize(gx, gy, currentSprite)
    Structure.initialize(self, gx, gy, "LargeGarden")
    local tileKey = "tile_buildings_gardens (" .. currentSprite + 9 .. ")"
    local tiles, quadArray = _G.indexBuildingQuads(tileKey, true)
    self.currentSprite = currentSprite
    self.tile = tileQuads["empty"]
    if currentSprite == 1 then
        self.offsetY = -64
    elseif currentSprite == 2 then
        self.offsetY = -52
    elseif currentSprite == 3 then
        self.offsetY = -56
    end

    for tile = 1, tiles do
        LargeGardenAlias:new(quadArray[tile], self.gx + tile - 1, self.gy + tiles, self,
            self.offsetY + 24 + 8 - 8 * tile)
    end

    LargeGardenAlias:new(quadArray[tiles + 1], self.gx + tiles, self.gy + tiles, self, self.offsetY)

    for tile = 1, tiles do
        LargeGardenAlias:new(quadArray[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile), self,
            self.offsetY + 24 - 9 + 9 - 8 * (tiles - tile), 16)
    end

    for xx = -1, 4 do
        for yy = -1, 4 do
            _G.terrainSetTileAt(gx + xx, gy + yy, _G.terrainBiome.scarceGrass)
        end
    end

    for xx = 0, self.class.WIDTH - 1 do
        for yy = 0, self.class.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, "Structure") then
                LargeGardenAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    self:applyBuildingHeightMap(true)
end

function LargeGarden:destroy()
    Structure.destroy(self)
end

function LargeGarden:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.currentSprite = self.currentSprite
    return data
end

function LargeGarden.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.currentSprite)
    Object.deserialize(obj, data)
    return obj
end

return LargeGarden
