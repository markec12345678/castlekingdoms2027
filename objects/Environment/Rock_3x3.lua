local _, _, tileQuads, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")

local Rock_3x3Alias = _G.class("Rock_3x3Alias", Structure)
Rock_3x3Alias.static.unserializable = true
function Rock_3x3Alias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    Structure.render(self)
end

local Rock_3x3 = _G.class("Rock_3x3", Structure)
Rock_3x3.static.WIDTH = 3
Rock_3x3.static.LENGTH = 3
Rock_3x3.static.HEIGHT = 15
function Rock_3x3:initialize(gx, gy, type)
    type = type or "Rock_3x3"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.tile = tileQuads["empty"]
    self.offsetX = 0
    self.offsetY = 0
    local rockVariation = 16 + love.math.random(1, 16)
    self.rockVariation = self.rockVariation or rockVariation
    local tiles, quadArray = _G.indexBuildingQuads("rocks_3x3tile (" .. rockVariation .. ")", false, 3)
    
    self:applyBuildingHeightMap(true)
    local _, _, _, centerTileOffsetY = quadArray[tiles + 1]:getViewport()

    for tile = 1, tiles do
        Rock_3x3Alias:new(quadArray[tile], self.gx + tile - 1, self.gy + tiles, self,
            centerTileOffsetY - 16 - 32 + 8 * tile)
    end

    Rock_3x3Alias:new(quadArray[tiles + 1], self.gx + tiles, self.gy + tiles, self, centerTileOffsetY - 16)

    for tile = 1, tiles do
        Rock_3x3Alias:new(quadArray[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile), self,
            centerTileOffsetY - 16 - 32 + 8 * (tiles - tile) + 8, 16)
    end
    Structure.render(self)
end

function Rock_3x3:serialize()
    local data = {}
    local objectData = Object.serialize(self)
    for k, v in pairs(objectData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.tileKey = self.tileKey
    data.offsetY = self.offsetY
    data.health = self.health
    data.rockVariation = self.rockVariation
    return data
end

function Rock_3x3.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type)
    Object.deserialize(obj, data)
    return obj
end

return Rock_3x3
