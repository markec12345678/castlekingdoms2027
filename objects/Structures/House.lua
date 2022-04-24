local _, _, _, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles, quad_array = _G.indexBuildingQuads("housing (1)", true)
local House_alias = _G.class('House_alias', Structure)
function House_alias:initialize(tile, gx, gy, parent, offset_y, offset_x)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.tile = tile
    self.base_offset_y = offset_y or 0
    self.additional_offset_y = 0
    self.offset_x = offset_x or 0
    self.offset_y = self.additional_offset_y - self.base_offset_y
    for k, v in ipairs(_G.stockpile.node_list) do
        if v.gx == self.gx and v.gy == self.gy then
            table.remove(_G.stockpile.node_list, k)
            break
        end
    end
    Structure.render(self)
end
function House_alias:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.tile_key = self.tile_key
    data.base_offset_y = self.base_offset_y
    data.additional_offset_y = self.additional_offset_y
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.parent = _G.state:serializeObject(self.parent)
    return data
end
function House_alias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    if data.tile_key then
        obj.tile = quad_array[data.tile_key]
        obj.tile_key = data.tile_key
        obj:render()
    end
    return obj
end

local House = _G.class('House', Structure)

House.static.WIDTH = 3
House.static.LENGTH = 3
House.static.HEIGHT = 17

function House:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "House")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quad_array[tiles + 1]
    self.offset_x = 0
    self.offset_y = -39
    for tile = 1, tiles do
        local hsl = House_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
        hsl.tile_key = tile
    end
    for tile = 1, tiles do
        local hsl = House_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offset_y + 8 * tile, 16)
        hsl.tile_key = tiles + 1 + tile
    end

    Structure:applyBuildingHeightMap(gx, gy, House.WIDTH, House.LENGTH, House.HEIGHT)

    _G.state.max_population = _G.state.max_population + 4

    Structure.render(self)
end
function House:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quad_array[tiles + 1]
    Structure.render(self)
end
function House:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    return data
end
function House.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return House
