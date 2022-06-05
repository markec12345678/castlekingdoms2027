local _, _, tileQuads, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")

local Rock_4x4Alias = _G.class("Rock_4x4Alias", Structure)
Rock_4x4Alias.static.unserializable = true
function Rock_4x4Alias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

local Rock_4x4 = _G.class("Rock_4x4", Structure)
Rock_4x4.static.WIDTH = 4
Rock_4x4.static.LENGTH = 4
Rock_4x4.static.HEIGHT = 17
function Rock_4x4:initialize(gx, gy, type)
    type = type or "Rock_4x4"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.tile = tileQuads["empty"]
    self.offsetX = 0
    self.offsetY = 0

    local rockVariation = love.math.random(1, 16)
    self.rockVariation = self.rockVariation or rockVariation
    local tiles, quadArray = _G.indexBuildingQuads("rocks_3x3tile (" .. rockVariation .. ")", false, 3)
    Structure:applyBuildingHeightMap(gx, gy, self.class.WIDTH, self.class.LENGTH, self.class.HEIGHT, true)
    local _, _, _, centerTileOffsetY = quadArray[tiles + 1]:getViewport()

    for tile = 1, tiles do
        Rock_4x4Alias:new(quadArray[tile], self.gx + tile - 1, self.gy + tiles, self,
            centerTileOffsetY - 16 - 32 + 8 * tile)
    end

    Rock_4x4Alias:new(quadArray[tiles + 1], self.gx + tiles, self.gy + tiles, self, centerTileOffsetY - 16)

    for tile = 1, tiles do
        Rock_4x4Alias:new(quadArray[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile), self,
            centerTileOffsetY - 16 - 32 + 8 * (tiles - tile) + 8, 16)
    end
    Structure.render(self)
end

function Rock_4x4:serialize()
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

function Rock_4x4.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type)
    Object.deserialize(obj, data)
    return obj
end

return Rock_4x4
