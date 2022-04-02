local object_batch, active_objects, tile_quads, object = ...
local Object = require("objects.Object")

local tiles_iron = _G.indexQuads("tile_land3_iron", 16)

local Iron = class('Iron', Object)
function Iron:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    self.tile = tiles_iron[love.math.random(1, 16)]
    local _, _, _, lh = self.tile:getViewport()
    self.offset_y = 16 - lh + 3
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
    self:render()
    for xx = -2, 2 do
        for yy = -2, 2 do
            if love.math.random(1, 8) == 2 then
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.mountain_grass)
            end
        end
    end
    for xx = -3, 3 do
        for yy = -3, 3 do
            if love.math.random(1, 20) == 4 then
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.mountain_grass)
            end
        end
    end
end

function Iron:serialize()
    local data = {}
    local object_data = Object.serialize(self)
    for k, v in pairs(object_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    return data
end

function Iron.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type)
    Object.deserialize(obj, data)
    return obj
end

return Iron
