local _, tile_quads, _ = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local tiles, quad_array = _G.indexBuildingQuads("stockpile")

local last_quad = quad_array[#quad_array]
local vx, vy, vw, vh = last_quad:getViewport()

-- fix rendering issue
local new_quad = love.graphics.newQuad(vx, vy, vw - 2, vh, _G.imageW, _G.imageH)
quad_array[#quad_array] = new_quad
local quad_map = {
    ["wood"] = {},
    ["stone"] = {},
    ["wheat"] = {},
    ["iron"] = {},
    ["flour"] = {}
}

for i = 1, 48 do
    quad_map["wood"][#quad_map["wood"] + 1] = tile_quads["wood_stockpile (" .. tostring(i) .. ")"]
    quad_map["stone"][#quad_map["stone"] + 1] = tile_quads["stone_stockpile (" .. tostring(i) .. ")"]
    quad_map["iron"][#quad_map["iron"] + 1] = tile_quads["iron_stockpile (" .. tostring(i) .. ")"]
end

for i = 1, 32 do
    quad_map["wheat"][#quad_map["wheat"] + 1] = tile_quads["wheat_stockpile (" .. tostring(i) .. ")"]
    quad_map["flour"][#quad_map["flour"] + 1] = tile_quads["flour_stockpile (" .. tostring(i) .. ")"]
end

local pile_offset_y = {
    ["wood"] = {-2, -2, -2, -4, -4, -4, -4, -5, -5, -5, -5, -7, -7, -7, -7, -10, -10, -10, -10, -11, -11, -11, -11, -13,
                -13, -13, -13, -15, -15, -15, -15, -17, -17, -17, -17, -20, -20, -20, -20, -21, -21, -21, -21, -23, -23,
                -23, -23, -25},
    ["stone"] = {-9, -9, -9, -9, -9, -9, -9, -9, -9, -18, -18, -18, -18, -18, -18, -18, -18, -18, -26, -26, -26, -26,
                 -26, -26, -26, -26, -26, -35, -35, -35, -35, -35, -35, -35, -35, -35, -43, -43, -43, -43, -43, -43,
                 -43, -43, -43, -47, -47, -47, -47},
    ["wheat"] = {-14, -14, -14, -14, -17, -17, -17, -19, -19, -19, -19, -19, -19, -19, -19, -19, -28, -28, -28, -28,
                 -31, -31, -31, -31, -31, -31, -31, -31, -33, -33, -35, -35},
    ["iron"] = {-5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10,
                -10, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -19, -19, -19, -19, -19, -19, -19, -19,
                -19, -19, -19, -19},
    ["flour"] = {-2, -2, -2, -2, -2, -2, -2, -3, -3, -3, -3, -3, -3, -3, -6, -6, -6, -6, -6, -6, -6, -6, -9, -13, -13,
                 -13, -13, -13, -13, -13, -14, -15}
}

local max_quantity = {
    ["wood"] = 48,
    ["stone"] = 48,
    ["wheat"] = 32,
    ["iron"] = 48,
    ["flour"] = 32
}
local Stockpile_alias = _G.class('Stockpile_alias', Structure)
function Stockpile_alias:initialize(tile, gx, gy, parent, offset_y, offset_x, not_walkable)
    Structure.initialize(self, gx, gy, "Stockpile alias")
    self.gx = gx
    self.gy = gy
    if not_walkable then
        _G.state.map:setWalkable(self.gx, self.gy, 1)
    end
    self.parent = parent
    self.qid = 0
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
function Stockpile_alias:render()
    Structure.render(self)
end
function Stockpile_alias:serialize()
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
    return data
end
function Stockpile_alias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.tile_key then
        obj.tile = quad_array[data.tile_key]
        obj.tile_key = data.tile_key
        obj:render()
    end
    return obj
end

local Stockpile = _G.class('Stockpile', Structure)
function Stockpile:initialize(gx, gy, type)
    type = type or "Stockpile"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.qid = nil
    self.tile = quad_array[tiles + 1]
    self.offset_x = 0
    self.offset_y = -12

    for tile = 1, tiles do
        local not_walkable = true
        if tile == 2 then
            not_walkable = false
        end
        local stp = Stockpile_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1), nil, not_walkable)
        stp.tile_key = tile
    end

    for tile = 1, tiles do
        local not_walkable = true
        if tile == 2 then
            not_walkable = false
        end
        local stp = Stockpile_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offset_y + 8 * tile, 16, nil, not_walkable)
        stp.tile_key = tiles + 1 + tile
    end

    for xx = -1, 5 do
        for yy = -1, 5 do
            if xx ~= -1 and yy ~= -1 and xx ~= 5 and yy ~= 5 then
                local xxx = (self.gx + xx) % (_G.chunk_width)
                local yyy = (self.gy + yy) % (_G.chunk_width)
                local ccx = math.floor((self.gx + xx) / _G.chunk_width)
                local ccy = math.floor((self.gy + yy) / _G.chunk_width)
                _G.buildingheightmap[ccx][ccy][xxx][yyy] = 12
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.none)
            else
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt)
            end
        end
    end
    Stockpile_alias:new(tile_quads["empty"], self.gx + 4, self.gy + 4 - 1, self)
    Stockpile_alias:new(tile_quads["empty"], self.gx + 4 - 1, self.gy + 4, self)
    Stockpile_alias:new(tile_quads["empty"], self.gx + 4 - 1, self.gy + 4, self)
    Stockpile_alias:new(tile_quads["empty"], self.gx + 3, self.gy + 1, self)
    Stockpile_alias:new(tile_quads["empty"], self.gx + 1, self.gy + 3, self)
    Stockpile_alias:new(tile_quads["empty"], self.gx + 3, self.gy + 3, self)
    Stockpile_alias:new(tile_quads["empty"], self.gx + 1, self.gy + 1, self)
    for tile_x = 0, tiles do
        for tile_y = 0, tiles do
            _G.state.map:setHeight(self.gx + tile_x, self.gy + tile_y, 10)
        end
    end

    self.stockpile = {}
    self.stockpile[1] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 1
    }
    self.stockpile[2] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 2
    }
    self.stockpile[3] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 3
    }
    self.stockpile[4] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 4
    }
    self.stockpile[1].id = Stockpile_alias:new(tile_quads["empty"], self.gx + 1, self.gy + 1, self, 32 - 4, -16)
    self.stockpile[2].id = Stockpile_alias:new(tile_quads["empty"], self.gx + 1, self.gy + 4, self, 32 - 4, -16)
    self.stockpile[3].id = Stockpile_alias:new(tile_quads["empty"], self.gx + 4, self.gy + 1, self, 32 - 4, -16)
    self.stockpile[4].id = Stockpile_alias:new(tile_quads["empty"], self.gx + 4, self.gy + 4, self, 32 - 4, -16)
    table.insert(_G.stockpile.node_list, {
        gx = self.gx + 2,
        gy = self.gy + 5
    })
    table.insert(_G.stockpile.node_list, {
        gx = self.gx - 1,
        gy = self.gy + 2
    })
    table.insert(_G.stockpile.node_list, {
        gx = self.gx + 2,
        gy = self.gy - 1
    })
    table.insert(_G.stockpile.node_list, {
        gx = self.gx + 5,
        gy = self.gy + 2
    })

    _G.stockpile.list[(#_G.stockpile.list or 0) + 1] = self
    Structure.render(self)
end
function Stockpile:store(resource)
    for index = 1, 4 do
        if self.stockpile[index].type == resource and self.stockpile[index].quantity < max_quantity[resource] then
            self.stockpile[index].quantity = self.stockpile[index].quantity + 1
            _G.state.resources[resource] = _G.state.resources[resource] + 1
            self:update_stockpile(index)
            return true
        end
    end
    local found = false
    if not found then
        for index = 1, 4 do
            local curr_pile = self.stockpile[index]
            if curr_pile.empty then
                curr_pile.empty = false
                curr_pile.type = resource
                curr_pile.quantity = 1
                _G.state.not_full_stockpiles[curr_pile.type] = _G.state.not_full_stockpiles[curr_pile.type] + 1
                _G.state.resources[resource] = _G.state.resources[resource] + 1
                curr_pile.key = #_G.stockpile.resources[resource] + 1
                _G.stockpile.resources[resource][curr_pile.key] = curr_pile
                self:update_stockpile(index)
                found = true
                break
            end
        end
    end
    if not found then
        return false
    else
        return true
    end
end
function Stockpile:take(resource, from)
    if from.type == resource and from.quantity > 0 then
        if from.quantity == max_quantity[resource] then
            _G.state.not_full_stockpiles[resource] = _G.state.not_full_stockpiles[resource] + 1
        end
        from.quantity = from.quantity - 1
        _G.state.resources[resource] = _G.state.resources[resource] - 1
        self:update_stockpile(from)
        return true
    end
    for index = 1, 4 do
        if self.stockpile[index].type == resource and self.stockpile[index].quantity > 0 then
            self.stockpile[index].quantity = self.stockpile[index].quantity - 1
            _G.state.resources[resource] = _G.state.resources[resource] - 1
            self:update_stockpile(index)
            return true
        end
    end
    return false
end
function Stockpile:update_stockpile(index)
    local pile
    if type(index) ~= "number" then
        pile = index
    else
        pile = self.stockpile[index]
    end
    if not _G.stockpile.resources[pile.type] then
        return
    end
    if pile.quantity == 0 then
        table.remove(_G.stockpile.resources[pile.type], pile.key)
        _G.state.not_full_stockpiles[pile.type] = _G.state.not_full_stockpiles[pile.type] - 1
        pile.quantity = -1
        pile.type = nil
        pile.empty = true
        pile.id.tile = tile_quads["empty"]
        pile.id:render()
        return
    elseif pile.quantity < 0 then
        pile.id.tile = tile_quads["empty"]
        pile.id:render()
        return
    end
    pile.id.tile = quad_map[pile.type][pile.quantity]
    pile.id.additional_offset_y = pile_offset_y[pile.type][pile.quantity]
    pile.id.offset_y = pile.id.additional_offset_y - pile.id.base_offset_y
    pile.id:render()
    if pile.quantity == max_quantity[pile.type] then
        _G.state.not_full_stockpiles[pile.type] = _G.state.not_full_stockpiles[pile.type] - 1
    end
end
function Stockpile:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    -- TODO: Check if node list is free before assigning it
    table.insert(_G.stockpile.node_list, {
        gx = self.gx + 2,
        gy = self.gy + 5
    })
    table.insert(_G.stockpile.node_list, {
        gx = self.gx - 1,
        gy = self.gy + 2
    })
    table.insert(_G.stockpile.node_list, {
        gx = self.gx + 2,
        gy = self.gy - 1
    })
    table.insert(_G.stockpile.node_list, {
        gx = self.gx + 5,
        gy = self.gy + 2
    })
    self.stockpile = {}
    self.stockpile[1] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 1
    }
    self.stockpile[2] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 2
    }
    self.stockpile[3] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 3
    }
    self.stockpile[4] = {
        id = nil,
        empty = true,
        type = nil,
        quantity = 0,
        index = 4
    }

    self.health = data.health
    self.offset_x = data.offset_x
    self.offset_y = data.offset_y

    _G.stockpile.list[(#_G.stockpile.list or 0) + 1] = self

    for idx, v in ipairs(data.st_pile_raw) do
        for sk, sv in pairs(v) do
            if sk == "id" then
                self.stockpile[idx][sk] = _G.state:dereferenceObject(sv)
                self.stockpile[idx][sk].parent = self
            else
                self.stockpile[idx][sk] = sv
            end
        end
        if v.quantity > 0 then
            if type(_G.stockpile.resources[v.type]) == "table" then
                _G.stockpile.resources[v.type][#_G.stockpile.resources[v.type] + 1] = self.stockpile[idx]
            else
                _G.stockpile.resources[v.type] = {self.stockpile[idx]}
            end
        end
    end
    data.st_pile_raw = nil
    self.tile = quad_array[tiles + 1]
    Structure.render(self)
    for idx, _ in ipairs(self.stockpile) do
        self:update_stockpile(idx)
    end
end
function Stockpile:serialize()
    local data = {}
    local struct_data = Structure.serialize(self)
    for k, v in pairs(struct_data) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.st_pile_raw = {}
    data.health = self.health
    data.offset_x = self.offset_x
    data.offset_y = self.offset_y
    for _, piles in ipairs(self.stockpile) do
        data.st_pile_raw[#data.st_pile_raw + 1] = {}
        for sk, sv in pairs(piles) do
            if sk == "id" then
                data.st_pile_raw[#data.st_pile_raw][sk] = _G.state:serializeObject(sv)
            else
                data.st_pile_raw[#data.st_pile_raw][sk] = sv
            end
        end
    end
    return data
end
function Stockpile.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return Stockpile
