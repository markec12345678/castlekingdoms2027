local _, _, tileQuads, _ = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local WalkableWoodenWall = _G.class('WalkableWoodenWall', Structure)
WalkableWoodenWall.static.WIDTH = 1
WalkableWoodenWall.static.LENGTH = 1
WalkableWoodenWall.static.HEIGHT = 15
WalkableWoodenWall.static.DESTRUCTIBLE = true
function WalkableWoodenWall:initialize(gx, gy)
    Structure.initialize(self, gx, gy)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.tile = tileQuads["wood_wall_walkable"]
    self.offsetX = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offsetY = -(sh - 16)
    self:applyBuildingHeightMap()
end

function WalkableWoodenWall:serialize()
    local data = {}
    local objectData = Structure.serialize(self)
    for k, v in pairs(objectData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    return data
end

function WalkableWoodenWall.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type)
    Object.deserialize(obj, data)
    obj.health = data.health
    return obj
end

return WalkableWoodenWall
