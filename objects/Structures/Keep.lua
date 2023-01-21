local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles, quadArray = _G.indexBuildingQuads("small_stone_castle (1)")
local tileKeepDoor1 = tileQuads["doors_bits (1)"]
local tileKeepDoor2 = tileQuads["doors_bits (5)"]

local KeepDoor = _G.class("KeepDoor", Structure)
function KeepDoor:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = (offsetY or 0) + -67 + 16
    self:render()
end

local KeepAlias = _G.class("KeepAlias", Structure)
function KeepAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.offsetX = offsetX or 0
    self.offsetY = -(offsetY or 0)
    self:render()
end

local Keep = _G.class("Keep", Structure)
Keep.static.WIDTH = 7
Keep.static.LENGTH = 7
Keep.static.HEIGHT = 25
Keep.static.DESTRUCTIBLE = false
Keep.static.HOVERTEXT = "Click to manage taxes"
function Keep:initialize(gx, gy, type)
    type = type or "Keep (default)"
    Structure.initialize(self, gx, gy, type)
    self.health = 1000
    self.tile = tileQuads["empty"]
    self.offsetX = 0
    self.offsetY = -93
    _G.state.keepX, _G.state.keepY = gx, gy

    for tile = 1, tiles do
        KeepAlias:new(quadArray[tile], self.gx + tile, self.gy + tiles, self, -self.offsetY + 8 * tile + 93 - 17, -16)
    end

    local _, _, _, centerTileOffsetY = quadArray[tiles + 1]:getViewport()
    KeepAlias:new(quadArray[tiles + 1], self.gx + tiles, self.gy + tiles, self, centerTileOffsetY - 16)

    for tile = 1, tiles do
        KeepAlias:new(
            quadArray[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1) + 93 - 17, 32)
    end

    KeepDoor:new(tileKeepDoor1, self.gx + 2, self.gy + 7, self, -8)
    KeepDoor:new(tileKeepDoor2, self.gx + 4, self.gy + 7, self, -8 - 8, -2)
    _G.spawnPointX, _G.spawnPointY = self.gx + 3, self.gy + 8

    for xx = 0, 5 do
        for yy = 0, 5 do
            KeepAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self)
        end
    end
    KeepAlias:new(tileQuads["empty"], self.gx + 6, self.gy, self)
    KeepAlias:new(tileQuads["empty"], self.gx, self.gy + 6, self)

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

function Keep:onClick()
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("keep_tax")
end

function Keep.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type)
    Object.deserialize(obj, data)
    return obj
end

return Keep
