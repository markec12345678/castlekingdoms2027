local _, tileQuads = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles, quadArray = _G.indexBuildingQuads("small_wooden_castle (1)")
local tileSaxonHallDoor1 = tileQuads["doors_bits (3)"]
local tileSaxonHallDoor2 = tileQuads["doors_bits (4)"]

local SaxonHallDoor = _G.class("SaxonHallDoor", Structure)
function SaxonHallDoor:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = (offsetY or 0) + -67 + 16
    Structure.render(self)
end

local SaxonHallAlias = _G.class("SaxonHallAlias", Structure)
function SaxonHallAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    _G.state.keepX, _G.state.keepY = gx, gy
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = -(offsetY or 0)
    Structure.render(self)
end

local SaxonHall = _G.class("SaxonHall", Structure)

SaxonHall.static.WIDTH = 7
SaxonHall.static.LENGTH = 7
SaxonHall.static.HEIGHT = 23
SaxonHall.static.DESTRUCTIBLE = false

function SaxonHall:initialize(gx, gy, type)
    type = type or "SaxonHall (default)"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.tile = tileQuads["empty"]
    self.offsetX = 0
    self.offsetY = -93

    for tile = 1, tiles do
        SaxonHallAlias:new(quadArray[tile], self.gx + tile, self.gy + tiles, self, -self.offsetY + 8 * tile + 48, -16)
    end

    local _, _, _, centerTileOffsetY = quadArray[tiles + 1]:getViewport()
    SaxonHallAlias:new(quadArray[tiles + 1], self.gx + tiles, self.gy + tiles, self, centerTileOffsetY - 16)

    for tile = 1, tiles do
        SaxonHallAlias:new(
            quadArray[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile + 1), self,
                -self.offsetY + 8 * (tiles - tile + 1) + 48, 32)
    end

    SaxonHallDoor:new(tileSaxonHallDoor1, self.gx + 2, self.gy + 7, self)
    SaxonHallDoor:new(tileSaxonHallDoor2, self.gx + 4, self.gy + 7, self)
    _G.spawnPointX, _G.spawnPointY = self.gx + 3, self.gy + 8

    for xx = 0, 5 do 
        for yy = 0, 5 do 
            SaxonHallAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self)
        end
    end
    SaxonHallAlias:new(tileQuads["empty"], self.gx + 6, self.gy, self)
    SaxonHallAlias:new(tileQuads["empty"], self.gx, self.gy + 6, self)

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
function SaxonHall:onClick()
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("keep_tax")
end
function SaxonHall.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type)
    Object.deserialize(obj, data)
    return obj
end

return SaxonHall
