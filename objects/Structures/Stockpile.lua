local object, tile_quads, object_batch = ...
local Structure = require("objects.Structure")

local tiles, quad_array = indexBuildingQuads("stockpile")

local last_quad = quad_array[#quad_array]
local vx, vy, vw, vh = last_quad:getViewport()

-- fix rendering issue
local new_quad = love.graphics.newQuad(vx, vy, vw - 2, vh, imageW, imageH)
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

local offset_y = {
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
local Stockpile_alias = class('Stockpile_alias', Structure)
function Stockpile_alias:initialize(tile, gx, gy, parent, offset_y, offset_x, not_walkable)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    self.gx = gx
    self.gy = gy
    if not_walkable then
        setWalkable(self.gx, self.gy, 1)
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

local Stockpile = class('Stockpile', Structure)
function Stockpile:initialize(gx, gy, type)
    local mytype = "Static structure"
    Structure.initialize(self, gx, gy, mytype)
    setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.qid = nil
    self.tile = quad_array[tiles + 1]
    self.offset_x = 0
    self.offset_y = -12
    self.level = 1
    self.rotation = 1

    for tile = 1, tiles do
        local not_walkable = true
        if tile == 2 then
            not_walkable = false
        end
        Stockpile_alias:new(quad_array[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offset_y + 8 * (tiles - tile + 1), nil, not_walkable)
    end

    for tile = 1, tiles do
        local not_walkable = true
        if tile == 2 then
            not_walkable = false
        end
        Stockpile_alias:new(quad_array[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offset_y + 8 * tile, 16,
            nil, not_walkable)
    end

    for xx = -1, 5 do
        for yy = -1, 5 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrain_biome.dirt)
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
            _G.setHeight(self.gx + tile_x, self.gy + tile_y, 10)
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

    _G.stockpile.list[(#stockpile.list or 0) + 1] = self
    Structure.render(self)
end
function Stockpile:store(resource)
    local found = false
    for index = 1, 4 do
        if self.stockpile[index].type == resource and self.stockpile[index].quantity < max_quantity[resource] then
            self.stockpile[index].quantity = self.stockpile[index].quantity + 1
            _G.resources[resource] = _G.resources[resource] + 1
            found = true
            self:update_stockpile(index)
            return true
        end
    end
    if not found then
        for index = 1, 4 do
            if self.stockpile[index].empty then
                self.stockpile[index].empty = false
                self.stockpile[index].type = resource
                self.stockpile[index].quantity = 1
                _G.not_full_stockpiles[self.stockpile[index].type] =
                    _G.not_full_stockpiles[self.stockpile[index].type] + 1
                _G.resources[resource] = _G.resources[resource] + 1
                self.stockpile[index].key = #_G.stockpile.resources[resource] + 1
                _G.stockpile.resources[resource][self.stockpile[index].key] = self.stockpile[index]
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
            _G.not_full_stockpiles[resource] = _G.not_full_stockpiles[resource] + 1
        end
        from.quantity = from.quantity - 1
        _G.resources[resource] = _G.resources[resource] - 1
        found = true
        self:update_stockpile(from)
        return true
    end
    local found = false
    for index = 1, 4 do
        if self.stockpile[index].type == resource and self.stockpile[index].quantity > 0 then
            self.stockpile[index].quantity = self.stockpile[index].quantity - 1
            _G.resources[resource] = _G.resources[resource] - 1
            found = true
            self:update_stockpile(index)
            return true
        end
    end
    if not found then
        return false
    end
    return true
end
function Stockpile:update_stockpile(index)
    local pile
    if type(index) ~= "number" then
        pile = index
    else
        pile = self.stockpile[index]
    end
    if pile.quantity == 0 then
        table.remove(_G.stockpile.resources[pile.type], pile.key)
        _G.not_full_stockpiles[pile.type] = _G.not_full_stockpiles[pile.type] - 1
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
    if pile.quantity == max_quantity[pile.type] then
        _G.not_full_stockpiles[pile.type] = _G.not_full_stockpiles[pile.type] - 1
    end
end

return Stockpile
