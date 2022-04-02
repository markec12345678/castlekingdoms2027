local _, tile_quads, _ = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles, quad_array = _G.indexBuildingQuads("granary (1)")

local quad_map = {
    ["apples"] = {},
    ["bread"] = {},
    ["cheese"] = {}
}

for i = 1, 8 do
    quad_map["apples"][#quad_map["apples"] + 1] = tile_quads["apple_goods (" .. tostring(i) .. ")"]
end

for i = 1, 32 do
    quad_map["bread"][#quad_map["bread"] + 1] = tile_quads["bread_goods (" .. tostring(i) .. ")"]
end

for i = 1, 16 do
    quad_map["cheese"][#quad_map["cheese"] + 1] = tile_quads["cheese_goods (" .. tostring(i) .. ")"]
end

local offset_y = {
    ["apples"] = {0, -1, -7, -11, -11, -16, -22, -23},
    ["bread"] = {0, -3, -7, -10, -14, -14, -14, -14, -14, -14, -14, -14, -18 + 4, -18 + 4, -18 + 4, -18 + 4, -21 + 4,
                 -24 + 4, -28 + 4, -31 + 4, -31 + 4, -31 + 4, -31 + 4, -31 + 4, -31 + 4, -31 + 4, -31 + 4, -31 + 4,
                 -31 + 4, -31 + 4, -31 + 4, -31 + 4},
    ["cheese"] = {0, -3, -6, -12, -12, -12, -18, -18, -18, -24, -24, -24, -30, -30, -30, -33}
}

local max_quantity = {
    ["apples"] = 8,
    ["bread"] = 32,
    ["cheese"] = 16
}
local Granary_alias = _G.class('Granary_alias', Structure)
function Granary_alias:initialize(tile, gx, gy, parent, offset_y, offset_x, serialize_parent)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self.serialize_parent = not (serialize_parent)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.parent = parent
    self.qid = 0
    self.tile = tile
    self.base_offset_y = offset_y or 0
    self.additional_offset_y = 0
    self.offset_x = offset_x or 0
    self.offset_y = self.additional_offset_y - self.base_offset_y
    for k, v in ipairs(_G.foodpile.node_list) do
        if v.gx == self.gx and v.gy == self.gy then
            table.remove(_G.foodpile.node_list, k)
            break
        end
    end
    Structure.render(self)
end
function Granary_alias:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    if self.serialize_parent then
        data.parent = _G.state:serializeObject(self.parent)
    end
    data.serialize_parent = self.serialize_parent
    data.tile_key = self.tile_key
    data.base_offset_y = self.base_offset_y
    data.additional_offset_y = self.additional_offset_y
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    return data
end
function Granary_alias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.tile_key then
        obj.tile = quad_array[data.tile_key]
        obj.tile_key = data.tile_key
        obj:render()
    end
    if obj.serialize_parent then
        obj.parent = _G.state:dereferenceObject(data.parent)
    end
    return obj
end

local Granary = _G.class('Granary', Structure)
function Granary:initialize(gx, gy, type)
    type = type or "Granary"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.qid = nil
    self.tile = quad_array[tiles + 1]
    self.offset_x = 0
    self.offset_y = -64 - 14

    self.hover_action = true
    self.foodpile = {}
    self.foodpile[1] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 1
    }
    self.foodpile[2] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 2
    }
    self.foodpile[3] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 3
    }
    self.foodpile[4] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 4
    }
    self.foodpile[5] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 5
    }
    self.foodpile[6] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 6
    }
    self.foodpile[7] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 7
    }
    self.foodpile[8] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 8
    }
    self.foodpile[9] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 9
    }

    for xx = -1, 4 do
        for yy = -1, 4 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt)
            if xx ~= -1 and yy ~= -1 and xx ~= 4 and yy ~= 4 then
                local xxx = (self.gx + xx) % (_G.chunk_width)
                local yyy = (self.gy + yy) % (_G.chunk_width)
                local ccx = math.floor((self.gx + xx) / _G.chunk_width)
                local ccy = math.floor((self.gy + yy) / _G.chunk_width)
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.none)
                _G.buildingheightmap[ccx][ccy][xxx][yyy] = 17
            end
        end
    end

    for tile = 1, tiles do
        local gra = Granary_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1))
        gra.tile_key = tile
    end

    for tile = 1, tiles do
        local gra = Granary_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offset_y + 8 * tile, 14)
        gra.tile_key = tiles + 1 + tile
    end
    -- Granary_alias:new(tile_quads["empty"], self.gx + 3, self.gy + 3, self, 0, 0)
    -- Granary_alias:new(tile_quads["empty"], self.gx + 2, self.gy + 3, self, 0, 0)
    -- Granary_alias:new(tile_quads["empty"], self.gx + 1, self.gy + 3, self, 0, 0)
    -- Granary_alias:new(tile_quads["empty"], self.gx + 3, self.gy + 2, self, 0, 0)
    -- Granary_alias:new(tile_quads["empty"], self.gx + 3, self.gy + 1, self, 0, 0)

    self.foodpile[1].id = Granary_alias:new(tile_quads["empty"], self.gx + 1, self.gy + 1, self, 32 - 4, 0, true)
    self.foodpile[2].id = Granary_alias:new(tile_quads["empty"], self.gx + 2, self.gy + 1, self, 32 - 4, 0, true)
    self.foodpile[3].id = Granary_alias:new(tile_quads["empty"], self.gx + 3, self.gy + 1, self, 32 - 4, 0, true)
    self.foodpile[4].id = Granary_alias:new(tile_quads["empty"], self.gx + 1, self.gy + 2, self, 32 - 4, 0, true)
    self.foodpile[5].id = Granary_alias:new(tile_quads["empty"], self.gx + 2, self.gy + 2, self, 32 - 4, 0, true)
    self.foodpile[6].id = Granary_alias:new(tile_quads["empty"], self.gx + 3, self.gy + 2, self, 32 - 4, 0, true)
    self.foodpile[7].id = Granary_alias:new(tile_quads["empty"], self.gx + 1, self.gy + 3, self, 32 - 4, 0, true)
    self.foodpile[8].id = Granary_alias:new(tile_quads["empty"], self.gx + 2, self.gy + 3, self, 32 - 4, 0, true)
    self.foodpile[9].id = Granary_alias:new(tile_quads["empty"], self.gx + 3, self.gy + 3, self, 32 - 4, 0, true)
    table.insert(_G.foodpile.node_list, {
        gx = self.gx + 4,
        gy = self.gy + 4
    })
    table.insert(_G.foodpile.node_list, {
        gx = self.gx - 1,
        gy = self.gy + 4
    })
    table.insert(_G.foodpile.node_list, {
        gx = self.gx + 4,
        gy = self.gy - 1
    })
    table.insert(_G.foodpile.node_list, {
        gx = self.gx - 1,
        gy = self.gy - 1
    })

    _G.foodpile.list[(#_G.foodpile.list or 0) + 1] = self
    Structure.render(self)
end
function Granary:store(food)
    for index = 1, #self.foodpile do
        if self.foodpile[index].type == food and self.foodpile[index].quantity < max_quantity[food] then
            self.foodpile[index].quantity = self.foodpile[index].quantity + 1
            _G.state.food[food] = _G.state.food[food] + 1
            self:update_foodpile(index)
            return true
        end
    end
    local found = false
    for index = 1, #self.foodpile do
        if self.foodpile[index].empty then
            self.foodpile[index].empty = false
            self.foodpile[index].type = food
            self.foodpile[index].quantity = 1
            _G.state.not_full_foods[self.foodpile[index].type] = _G.state.not_full_foods[self.foodpile[index].type] + 1
            _G.state.food[food] = _G.state.food[food] + 1
            self.foodpile[index].key = #_G.foodpile.food[food] + 1
            _G.foodpile.food[food][self.foodpile[index].key] = self.foodpile[index]
            self:update_foodpile(index)
            found = true
            break
        end
    end
    if not found then
        return false
    else
        return true
    end
end
function Granary:take(food, from)
    if from.type == food and from.quantity > 0 then
        if from.quantity == max_quantity[food] then
            _G.state.not_full_foods[food] = _G.state.not_full_foods[food] + 1
        end
        from.quantity = from.quantity - 1
        _G.state.food[food] = _G.state.food[food] - 1
        self:update_foodpile(from)
        return true
    end
    for index = 1, 9 do
        if self.foodpile[index].type == food and self.foodpile[index].quantity > 0 then
            self.foodpile[index].quantity = self.foodpile[index].quantity - 1
            _G.state.food[food] = _G.state.food[food] - 1
            self:update_foodpile(index)
            return true
        end
    end
    return false
end
function Granary:update_foodpile(index)
    local pile
    if type(index) ~= "number" then
        pile = index
    else
        pile = self.foodpile[index]
    end
    if pile.quantity == 0 then
        table.remove(_G.foodpile.food[pile.type], pile.key)
        _G.state.not_full_foods[pile.type] = _G.state.not_full_foods[pile.type] - 1
        pile.quantity = -1
        pile.type = nil
        pile.empty = true
        pile.id.tile = tile_quads["empty"]
        pile.id:render()
        return
    end
    pile.id.tile = quad_map[pile.type][pile.quantity]
    pile.id.additional_offset_y = offset_y[pile.type][pile.quantity]
    pile.id.offset_y = pile.id.additional_offset_y - pile.id.base_offset_y
    pile.id:render()
    -- if object_batch[pile.id.cx][pile.id.cy] then
    --     object_batch[pile.id.cx][pile.id.cy]:set(pile.id.qid, pile.id.tile, pile.id.x + pile.id.offset_x,
    --         pile.id.y + pile.id.offset_y)
    -- end
    if pile.quantity == max_quantity[pile.type] then
        _G.state.not_full_foods[pile.type] = _G.state.not_full_foods[pile.type] - 1
    end
end

function Granary:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.st_pile_raw = {}
    for _, v in ipairs(self.foodpile) do
        data.st_pile_raw[#data.st_pile_raw + 1] = {}
        for sk, sv in pairs(v) do
            if sk ~= "id" then
                data.st_pile_raw[#data.st_pile_raw][sk] = sv
            else
                data.st_pile_raw[#data.st_pile_raw][sk] = _G.state:serializeObject(sv)
            end
        end
    end
    data.health = self.health
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    data.hover_action = self.hover_action
    return data
end
function Granary.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.foodpile = {}
    for idx, v in ipairs(data.st_pile_raw) do
        obj.foodpile[idx] = {}
        for sk, sv in pairs(v) do
            if sk == "id" then
                obj.foodpile[idx][sk] = _G.state:dereferenceObject(sv)
                obj.foodpile[idx][sk].parent = obj
            else
                obj.foodpile[idx][sk] = sv
            end
        end
    end
    for idx, pile in ipairs(obj.foodpile) do
        if pile.quantity > 0 then
            obj:update_foodpile(idx)
        end
    end
    obj.tile = quad_array[tiles + 1]
    Structure.render(obj)
    return obj
end

return Granary
