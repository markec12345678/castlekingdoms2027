local _, _, tileQuads, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")

local RockAlias = _G.class("RockAlias", Structure)
function RockAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

local Rock = _G.class("Rock", Structure)
function Rock:initialize(gx, gy, type)
    type = type or "Rock"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.tileKey = "mountain_rocks_1tile (" .. love.math.random(1, 16) .. ")"
    self.tile = tileQuads[self.tileKey]
    self.offsetX = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offsetY = -sh + 14
    _G.buildingheightmap[self.cx][self.cy][self.i][self.o] = 12
    _G.scheduleTerrainUpdate(self.cx, self.cy, self.i, self.o)
    Structure.render(self)
end

function Rock:serialize()
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
    return data
end

function Rock.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    obj.tile = tileQuads[data.tileKey]
    obj:shadeFromTerrain()
    Structure.render(obj)
    _G.addObjectAt(obj.cx, obj.cy, obj.i, obj.o, obj)
    return obj
end

return Rock
