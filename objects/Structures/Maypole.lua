local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")


local MaypoleAlias = _G.class("MaypoleAlias", Structure)
function MaypoleAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    Structure.initialize(self, gx, gy, "MaypoleAlias")
    self.tile = tile
    self.parent = parent
    self.offsetX = offsetX
    self.offsetY = offsetY
    self:render()
end

local Maypole = _G.class("Maypole", Structure)
Maypole.static.WIDTH = 3
Maypole.static.LENGTH = 3
Maypole.static.HEIGHT = 0
Maypole.static.ALIAS_NAME = "MaypoleAlias"
Maypole.static.DESTRUCTIBLE = true
function Maypole:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "Maypole")
    local tileKey = "anim_maypole_full (1)"
    local tiles, quadArray = _G.indexBuildingQuads(tileKey, false, 3)
    self.tile = tileQuads["empty"]
    self.offsetY = -96 + 16

    for tile = 1, tiles do
        MaypoleAlias:new(quadArray[tile], self.gx + tile - 1, self.gy + tiles, self,
            self.offsetY + 24 - 8 * tile)
    end

    MaypoleAlias:new(quadArray[tiles + 1], self.gx + tiles, self.gy + tiles, self, self.offsetY)

    for tile = 1, tiles do
        MaypoleAlias:new(quadArray[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile), self,
            self.offsetY + 24 - 9 + 1 - 8 * (tiles - tile), 16)
    end

    for xx = -1, 3 do
        for yy = -1, 3 do
            _G.terrainSetTileAt(gx + xx, gy + yy, _G.terrainBiome.scarceGrass)
        end
    end

    for xx = 0, self.class.WIDTH - 1 do
        for yy = 0, self.class.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, "Structure") then
                MaypoleAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end

    self:applyBuildingHeightMap(true)
end

function Maypole:destroy()
    Structure.destroy(self)
end

function Maypole:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    return data
end

function Maypole.static:deserialize(data)
    local obj = self:new(data.gx, data.gy)
    Object.deserialize(obj, data)
    return obj
end

return Maypole
