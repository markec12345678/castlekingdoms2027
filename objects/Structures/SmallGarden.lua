local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local SmallGardenAlias = _G.class("SmallGardenAlias", Structure)
function SmallGardenAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    Structure.initialize(self, gx, gy, "SmallGardenAlias")
    self.tile = tile
    self.parent = parent
    self.offsetX = offsetX
    self.offsetY = offsetY
    self:render()
end

local SmallGarden = _G.class("SmallGarden", Structure)
SmallGarden.static.WIDTH = 2
SmallGarden.static.LENGTH = 2
SmallGarden.static.HEIGHT = 0
SmallGarden.static.ALIAS_NAME = "SmallGardenAlias"
SmallGarden.static.DESTRUCTIBLE = true
function SmallGarden:initialize(gx, gy, currentSprite)
    currentSprite = currentSprite or 1
    Structure.initialize(self, gx, gy, "SmallGarden")
    local tileKey = "tile_buildings_gardens (" .. currentSprite .. ")"
    local tiles, quadArray = _G.indexBuildingQuads(tileKey, true)
    self.currentSprite = currentSprite
    self.tile = tileQuads["empty"]
    if currentSprite == 1 then
        self.offsetY = -34
    elseif currentSprite == 2 then
        self.offsetY = -20
    elseif currentSprite == 3 then
        self.offsetY = -20
    elseif currentSprite == 4 then
        self.offsetY = -20
    elseif currentSprite == 5 then
        self.offsetY = -18
    elseif currentSprite == 6 then
        self.offsetY = -18
    end


    for tile = 1, tiles do
        SmallGardenAlias:new(quadArray[tile], self.gx + tile - 1, self.gy + tiles, self,
            self.offsetY + 8 * tile)
    end

    SmallGardenAlias:new(quadArray[tiles + 1], self.gx + tiles, self.gy + tiles, self, self.offsetY)

    for tile = 1, tiles do
        SmallGardenAlias:new(quadArray[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile), self,
            self.offsetY + 8 + 8 * (tiles - tile), 16)
    end

    for xx = 0, self.class.WIDTH - 1 do
        for yy = 0, self.class.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, "Structure") then
                SmallGardenAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    for xx = -1, 2 do
        for yy = -1, 2 do
            _G.terrainSetTileAt(gx + xx, gy + yy, _G.terrainBiome.scarceGrass)
        end
    end
    self:applyBuildingHeightMap()
end

function SmallGarden:destroy()
    Structure.destroy(self)
end

function SmallGarden:serialize()
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

function SmallGarden.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.currentSprite)
    Object.deserialize(obj, data)
    return obj
end

return SmallGarden
