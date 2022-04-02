local _, _, tile_quads, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")

local Rock_alias = _G.class('Rock_alias', Structure)
function Rock_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self.gx = gx
    self.gy = gy
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.tile = tile
    self.base_offset_y = offset_y or 0
    self.additional_offset_y = 0
    self.offset_x = offset_x or 0
    self.offset_y = self.additional_offset_y - self.base_offset_y
    Structure.render(self)
end

local Rock = _G.class('Rock', Structure)
function Rock:initialize(gx, gy, type)
    type = type or "Rock"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 100
    self.qid = nil
    self.tile_key = "mountain_rocks_1tile (" .. love.math.random(1, 16) .. ")"
    self.tile = tile_quads[self.tile_key]
    self.offset_x = 0
    local _, _, _, sh = self.tile:getViewport()
    self.offset_y = -sh + 16
    _G.buildingheightmap[self.cx][self.cy][self.i][self.o] = 15
    Structure.render(self)
end

function Rock:serialize()
    local data = {}
    local object_data = Object.serialize(self)
    for k, v in pairs(object_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.tile_key = self.tile_key
    data.offset_y = self.offset_y
    data.health = self.health
    return data
end

function Rock.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    obj.tile = tile_quads[data.tile_key]
    Structure.render(obj)
    _G.addObjectAt(obj.cx, obj.cy, obj.i, obj.o, obj)
    return obj
end

return Rock
