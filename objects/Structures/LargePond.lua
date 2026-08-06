local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local LargePondAlias = _G.class("LargePondAlias", Structure)
function LargePondAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    Structure.initialize(self, gx, gy, "LargePondAlias")
    self.tile = tile
    self.parent = parent
    self.offsetX = offsetX
    self.offsetY = offsetY
    self:render()
end

local LargePond = _G.class("LargePond", Structure)
LargePond.static.WIDTH = 6
LargePond.static.LENGTH = 6
LargePond.static.HEIGHT = 0
LargePond.static.ALIAS_NAME = "LargePondAlias"
LargePond.static.DESTRUCTIBLE = true
function LargePond:initialize(gx, gy, currentSprite)
    currentSprite = currentSprite or 1
    Structure.initialize(self, gx, gy, "LargePond")
    local tileKey = "tile_buildings_ponds (" .. currentSprite + 2 .. ")"
    local tiles, quadArray = _G.indexBuildingQuads(tileKey)
    self.currentSprite = currentSprite
    self.tile = tileQuads["empty"]
    self.offsetY = -80

    for tile = 1, tiles do
        LargePondAlias:new(quadArray[tile], self.gx + tile - 1, self.gy + tiles, self,
            self.offsetY + 24 + 8 + 16 - 8 * tile)
    end

    LargePondAlias:new(quadArray[tiles + 1], self.gx + tiles, self.gy + tiles, self, self.offsetY)

    for tile = 1, tiles do
        LargePondAlias:new(quadArray[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile), self,
            self.offsetY + 24 - 9 + 9 + 16 - 8 * (tiles - tile), 16)
    end

    for xx = -1, 6 do
        for yy = -1, 6 do
            _G.terrainSetTileAt(gx + xx, gy + yy, _G.terrainBiome.scarceGrass)
        end
    end

    for xx = 0, self.class.WIDTH - 1 do
        for yy = 0, self.class.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, "Structure") then
                LargePondAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    self:applyBuildingHeightMap(true)
end

function LargePond:destroy()
    Structure.destroy(self)
end

function LargePond:serialize()
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

function LargePond.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.currentSprite)
    Object.deserialize(obj, data)
    return obj
end

return LargePond
