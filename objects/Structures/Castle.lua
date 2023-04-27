local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles, quadArray = _G.indexBuildingQuads("small_wooden_castle (1)")
local tileCastleDoor1 = tileQuads["doors_bits (3)"]
local tileCastleDoor2 = tileQuads["doors_bits (4)"]

local CastleDoor = _G.class("CastleDoor", Structure)
function CastleDoor:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = (offsetY or 0) + -67 + 16
    Structure.render(self)
end

local CastleAlias = _G.class("CastleAlias", Structure)
function CastleAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = -(offsetY or 0)
    Structure.render(self)
end

local Castle = _G.class("Castle", Structure)

Castle.static.WIDTH = 7
Castle.static.LENGTH = 7
Castle.static.HEIGHT = 23

function Castle:initialize(gx, gy, type)
    type = type or "Castle (default)"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.tile = tileQuads["empty"]
    self.offsetX = 0
    self.offsetY = -93

    for tile = 1, tiles do
        CastleAlias:new(quadArray[tile], self.gx + tile, self.gy + tiles, self, -self.offsetY + 8 * tile + 48, -16)
    end

    local _, _, _, centerTileOffsetY = quadArray[tiles + 1]:getViewport()
    CastleAlias:new(quadArray[tiles + 1], self.gx + tiles, self.gy + tiles, self, centerTileOffsetY - 16)

    for tile = 1, tiles do
        CastleAlias:new(
            quadArray[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1) + 48, 32)
    end

    CastleDoor:new(tileCastleDoor1, self.gx + 2, self.gy + 7, self)
    CastleDoor:new(tileCastleDoor2, self.gx + 4, self.gy + 7, self)
    _G.spawnPointX, _G.spawnPointY = self.gx + 3, self.gy + 8

    self:applyBuildingHeightMap()
    for xx = -2, 8 do
        for yy = -2, 8 do
            if yy == 7 or xx == 7 or xx == -1 or yy == -1 then
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
            elseif math.random(1, 3) == 1 then
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
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
