local _, _, _, _ = ...
local Object = require("objects.Object")

local tiles_stone = _G.indexQuads("tile_destroyed_stone", 32)

local Stone = _G.class('Stone', Object)
function Stone:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    self.tile_key = love.math.random(1, 32)
    self.tile = tiles_stone[self.tile_key]
    local _, _, _, lh = self.tile:getViewport()
    self.offset_y = 16 - lh + 3
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
    self:render()
    for xx = -4, 4 do
        for yy = -4, 4 do
            if love.math.random(1, 8) == 1 then
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt, _G.terrain_biome.abundant_grass)
            end
        end
    end
    for xx = -2, 2 do
        for yy = -2, 2 do
            if love.math.random(1, 8) == 2 then
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.abundant_grass_stones_white)
            end
        end
    end
    for xx = -3, 3 do
        for yy = -3, 3 do
            if love.math.random(1, 20) == 4 then
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.abundant_grass_stones_white)
            end
        end
    end
end

function Stone:serialize()
    local data = {}
    local object_data = Object.serialize(self)
    for k, v in pairs(object_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.tile_key = self.tile_key
    data.offset_y = self.offset_y
    return data
end

function Stone.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    obj.tile_key = data.tile_key
    obj.tile = tiles_stone[data.tile_key]
    obj:render()
    _G.addObjectAt(obj.cx, obj.cy, obj.i, obj.o, obj)
    return obj
end

return Stone
