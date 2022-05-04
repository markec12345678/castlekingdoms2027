local _, _, tileQuads, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")

local Rock_2x2Alias = _G.class('Rock_2x2Alias', Structure)
Rock_2x2Alias.static.unserializable = true
function Rock_2x2Alias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    Structure.render(self)
end

local Rock_2x2 = _G.class('Rock_2x2', Structure)
function Rock_2x2:initialize(gx, gy, type, rockVariation)
    type = type or "Rock_2x2"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.tile = tileQuads["empty"]
    self.offsetX = 0
    self.offsetY = 0
    rockVariation = rockVariation or love.math.random(1, 16)
    self.rockVariation = rockVariation
    local tiles, quadArray = _G.indexBuildingQuads("rocks_2x2tile (" .. rockVariation .. ")", false, 3)
    for xx = 0, 1 do
        for yy = 0, 1 do
            local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(self.gx + xx, self.gy + yy)
            _G.buildingheightmap[ccx][ccy][xxx][yyy] = 15
        end
    end
    local _, _, _, centerTileOffsetY = quadArray[tiles + 1]:getViewport()

    for tile = 1, tiles do
        Rock_2x2Alias:new(quadArray[tile], self.gx + tile - 1, self.gy + tiles, self,
            centerTileOffsetY - 14 + 16 - 32 + 8 * tile)
    end

    Rock_2x2Alias:new(quadArray[tiles + 1], self.gx + tiles, self.gy + tiles, self, centerTileOffsetY - 14)

    for tile = 1, tiles do
        Rock_2x2Alias:new(quadArray[tiles + 1 + tile], self.gx + tiles, self.gy + (tiles - tile), self,
            centerTileOffsetY - 14 - 32 + 8 * (tiles - tile) + 8 + 16, 16)
    end
    Structure.render(self)
end

function Rock_2x2:serialize()
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

function Rock_2x2.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type, data.rockVariation)
    Object.deserialize(obj, data)
    return obj
end

return Rock_2x2
