local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local MediumGardenAlias = _G.class("MediumGardenAlias", Structure)
function MediumGardenAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    Structure.initialize(self, gx, gy, "MediumGardenAlias")
    self.tile = tile
    self.parent = parent
    self.offsetX = offsetX
    self.offsetY = offsetY
    self:render()
end

local MediumGarden = _G.class("MediumGarden", Structure)
MediumGarden.static.WIDTH = 3
MediumGarden.static.LENGTH = 3
MediumGarden.static.HEIGHT = 0
MediumGarden.static.ALIAS_NAME = "MediumGardenAlias"
MediumGarden.static.DESTRUCTIBLE = true
function MediumGarden:initialize(gx, gy, currentSprite)
    currentSprite = currentSprite or 1
    Structure.initialize(self, gx, gy, "MediumGarden")
    local tileKey = "tile_buildings_gardens (" .. currentSprite + 6 .. ")"
    local tiles, quadArray = _G.indexBuildingQuads(tileKey)
    self.currentSprite = currentSprite
    self.tile = tileQuads["empty"]
    if currentSprite == 1 then
        self.offsetY = -48 + 3 - 8
    elseif currentSprite == 2 then
        self.offsetY = -42 + 3 - 8
    elseif currentSprite == 3 then
        self.offsetY = -32 + 3 - 8
    end

    for tile = 1, tiles do
        MediumGardenAlias:new(quadArray[tile], self.gx + tile - 1, self.gy + tiles, self,
            self.offsetY + 24 - 8 * tile)
    end

    MediumGardenAlias:new(quadArray[tiles + 1], self.gx + tiles, self.gy + tiles, self, self.offsetY)

    for tile = 1, tiles do
        MediumGardenAlias:new(quadArray[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile), self,
            self.offsetY + 24 - 9 - 8 * (tiles - tile), 16)
    end

    for xx = 0, self.class.WIDTH - 1 do
        for yy = 0, self.class.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, "Structure") then
                MediumGardenAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    for xx = -1, 3 do
        for yy = -1, 3 do
            _G.terrainSetTileAt(gx + xx, gy + yy, _G.terrainBiome.scarceGrass)
        end
    end
    self:applyBuildingHeightMap()
end

function MediumGarden:destroy()
    Structure.destroy(self)
end

function MediumGarden:serialize()
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

function MediumGarden.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.currentSprite)
    Object.deserialize(obj, data)
    return obj
end

return MediumGarden
