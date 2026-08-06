local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local SID = require("objects.Controllers.LanguageController").lines

local tiles, quadArray = _G.indexBuildingQuads("medium_stone_castle (1)")
local tileFortressDoor1 = tileQuads["doors_bits (9)"]
local tileFortressDoor2 = tileQuads["doors_bits (13)"]

local FortressDoor = _G.class("FortressDoor", Structure)
function FortressDoor:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = (offsetY or 0) + -67 + 16 - 11
    self:render()
end

local FortressAlias = _G.class("FortressAlias", Structure)
function FortressAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = -(offsetY or 0)
    self:render()
end

local Fortress = _G.class("Fortress", Structure)
Fortress.static.WIDTH = 9
Fortress.static.LENGTH = 9
Fortress.static.HEIGHT = 32
Fortress.static.DESTRUCTIBLE = false
Fortress.static.HOVERTEXT = SID.objects.hoverText.fortress
function Fortress:initialize(gx, gy, type)
    type = type or "Fortress (default)"
    Structure.initialize(self, gx, gy, type)
    self.health = 1000
    self.tile = tileQuads["empty"]
    self.offsetX = 0
    self.offsetY = -93 - 15
    _G.state.FortressX, _G.state.FortressY = gx, gy

    for tile = 1, tiles do
        FortressAlias:new(quadArray[tile], self.gx + tile, self.gy + tiles, self, -self.offsetY + 8 * tile + 93 - 17 - 15 - 16 + 109, -16)
    end

    local _, _, _, centerTileOffsetY = quadArray[tiles + 1]:getViewport()
    FortressAlias:new(quadArray[tiles + 1], self.gx + tiles, self.gy + tiles, self, centerTileOffsetY - 16)

    for tile = 1, tiles do
        FortressAlias:new(
            quadArray[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1) + 93 - 17 - 15 - 16 + 109, 32)
    end

    FortressDoor:new(tileFortressDoor1, self.gx + 3, self.gy + 9, self, -8)
    FortressDoor:new(tileFortressDoor2, self.gx + 5, self.gy + 9, self, -8 - 8, -2)
    _G.spawnPointX, _G.spawnPointY = self.gx + 4, self.gy + 10

    for xx = 0, self.class.WIDTH - 1 do
        for yy = 0, self.class.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, Structure) then
                FortressAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self)
            end
        end
    end
    FortressAlias:new(tileQuads["empty"], self.gx + 6, self.gy, self)
    FortressAlias:new(tileQuads["empty"], self.gx, self.gy + 6, self)

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
end

function Fortress:onClick()
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("keep_tax")
end

function Fortress.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type)
    Object.deserialize(obj, data)
    return obj
end

return Fortress
