local _, tileQuads, _ = ...
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles, quadArray = _G.indexBuildingQuads("granary (1)")
local FOOD = require("objects.Enums.Food")
local quadMap = {
    [FOOD.apples] = {},
    [FOOD.bread] = {},
    [FOOD.cheese] = {},
    [FOOD.meat] = {}
}

for i = 1, 8 do
    quadMap[FOOD.apples][#quadMap[FOOD.apples] + 1] = tileQuads["apple_goods (" .. tostring(i) .. ")"]
end

for i = 1, 32 do
    quadMap[FOOD.bread][#quadMap[FOOD.bread] + 1] = tileQuads["bread_goods (" .. tostring(i) .. ")"]
end

for i = 1, 16 do
    quadMap[FOOD.cheese][#quadMap[FOOD.cheese] + 1] = tileQuads["cheese_goods (" .. tostring(i) .. ")"]
    quadMap[FOOD.meat][#quadMap[FOOD.meat] + 1] = tileQuads["meat_goods (" .. tostring(i) .. ")"]
end

local offsetY = {
    [FOOD.apples] = {0, -1, -7, -11, -11, -16, -22, -23},
    [FOOD.bread] = {0, -3, -7, -10, -14, -14, -14, -14, -14, -14, -14, -14, -18 + 4, -18 + 4, -18 + 4, -18 + 4, -21 + 4,
        -24 + 4, -28 + 4, -31 + 4, -31 + 4, -31 + 4, -31 + 4, -31 + 4, -31 + 4, -31 + 4, -31 + 4, -31 + 4,
        -31 + 4, -31 + 4, -31 + 4, -31 + 4},
    [FOOD.cheese] = {0, -3, -6, -12, -12, -12, -18, -18, -18, -24, -24, -24, -30, -30, -30, -33},
    [FOOD.meat] = {0, -3, -6, -12, -12, -12, -18, -18, -18, -24, -24, -24, -30, -30, -30, -33}
}

local maxQuantity = {
    [FOOD.apples] = 8,
    [FOOD.bread] = 32,
    [FOOD.cheese] = 16,
    [FOOD.meat] = 16
}

local GranaryAlias = _G.class("GranaryAlias", Structure)
function GranaryAlias:initialize(tile, gx, gy, parent, offsetY, offsetX, serializeParent)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.serializeParent = not (serializeParent)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    for k, v in ipairs(_G.foodpile.nodeList) do
        if v.gx == self.gx and v.gy == self.gy then
            table.remove(_G.foodpile.nodeList, k)
            break
        end
    end
    Structure.render(self)
end

function GranaryAlias:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    if self.serializeParent then
        data.parent = _G.state:serializeObject(self.parent)
    end
    data.serializeParent = self.serializeParent
    data.tileKey = self.tileKey
    data.baseOffsetY = self.baseOffsetY
    data.additionalOffsetY = self.additionalOffsetY
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    return data
end

function GranaryAlias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.tileKey then
        obj.tile = quadArray[data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end
    if obj.serializeParent then
        obj.parent = _G.state:dereferenceObject(data.parent)
    end
    return obj
end

local Granary = _G.class("Granary", Structure)

Granary.static.WIDTH = 4
Granary.static.LENGTH = 4
Granary.static.HEIGHT = 17
Granary.static.DESTRUCTIBLE = false

function Granary:initialize(gx, gy, type)
    type = type or "Granary"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 1000
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -64 - 14

    self.hoverAction = true
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
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.dirt)
        end
    end

    self:applyBuildingHeightMap()

    for tile = 1, tiles do
        local gra = GranaryAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        gra.tileKey = tile
    end

    for tile = 1, tiles do
        local gra = GranaryAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile, 14)
        gra.tileKey = tiles + 1 + tile
    end

    self.foodpile[1].id = GranaryAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 1, self, 32 - 4, 0, true)
    self.foodpile[2].id = GranaryAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 1, self, 32 - 4, 0, true)
    self.foodpile[3].id = GranaryAlias:new(tileQuads["empty"], self.gx + 3, self.gy + 1, self, 32 - 4, 0, true)
    self.foodpile[4].id = GranaryAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 2, self, 32 - 4, 0, true)
    self.foodpile[5].id = GranaryAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 2, self, 32 - 4, 0, true)
    self.foodpile[6].id = GranaryAlias:new(tileQuads["empty"], self.gx + 3, self.gy + 2, self, 32 - 4, 0, true)
    self.foodpile[7].id = GranaryAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 3, self, 32 - 4, 0, true)
    self.foodpile[8].id = GranaryAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 3, self, 32 - 4, 0, true)
    self.foodpile[9].id = GranaryAlias:new(tileQuads["empty"], self.gx + 3, self.gy + 3, self, 32 - 4, 0, true)
    table.insert(_G.foodpile.nodeList, {
        gx = self.gx + 4,
        gy = self.gy + 4
    })
    table.insert(_G.foodpile.nodeList, {
        gx = self.gx - 1,
        gy = self.gy + 4
    })
    table.insert(_G.foodpile.nodeList, {
        gx = self.gx + 4,
        gy = self.gy - 1
    })
    table.insert(_G.foodpile.nodeList, {
        gx = self.gx - 1,
        gy = self.gy - 1
    })

    _G.foodpile.list[(#_G.foodpile.list or 0) + 1] = self
    Structure.render(self)
end

function Granary:onClick()
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("granary")
end

function Granary:store(food)
    for index = 1, #self.foodpile do
        if self.foodpile[index].type == food and self.foodpile[index].quantity < maxQuantity[food] then
            self.foodpile[index].quantity = self.foodpile[index].quantity + 1
            _G.state.food[food] = _G.state.food[food] + 1
            self:updateFoodpile(index)
            return true
        end
    end
    local found = false
    for index = 1, #self.foodpile do
        if self.foodpile[index].empty then
            self.foodpile[index].empty = false
            self.foodpile[index].type = food
            self.foodpile[index].quantity = 1
            _G.state.notFullFoods[self.foodpile[index].type] = _G.state.notFullFoods[self.foodpile[index].type] + 1
            _G.state.food[food] = _G.state.food[food] + 1
            self.foodpile[index].key = #_G.foodpile.food[food] + 1
            _G.foodpile.food[food][self.foodpile[index].key] = self.foodpile[index]
            self:updateFoodpile(index)
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
        if from.quantity == maxQuantity[food] then
            _G.state.notFullFoods[food] = _G.state.notFullFoods[food] + 1
        end
        from.quantity = from.quantity - 1
        _G.state.food[food] = _G.state.food[food] - 1
        self:updateFoodpile(from)
        return true
    end
    for index = 1, 9 do
        if self.foodpile[index].type == food and self.foodpile[index].quantity > 0 then
            self.foodpile[index].quantity = self.foodpile[index].quantity - 1
            _G.state.food[food] = _G.state.food[food] - 1
            self:updateFoodpile(index)
            return true
        end
    end
    return false
end

function Granary:updateFoodpile(index)
    local pile
    if type(index) ~= "number" then
        pile = index
    else
        pile = self.foodpile[index]
    end
    if pile.quantity == 0 then
        table.remove(_G.foodpile.food[pile.type], pile.key)
        _G.state.notFullFoods[pile.type] = _G.state.notFullFoods[pile.type] - 1
        pile.quantity = -1
        pile.type = nil
        pile.empty = true
        pile.id.tile = tileQuads["empty"]
        pile.id:render()
        return
    end
    pile.id.tile = quadMap[pile.type][pile.quantity]
    pile.id.additionalOffsetY = offsetY[pile.type][pile.quantity]
    pile.id.offsetY = pile.id.additionalOffsetY - pile.id.baseOffsetY
    pile.id:render()
    if pile.quantity == maxQuantity[pile.type] then
        _G.state.notFullFoods[pile.type] = _G.state.notFullFoods[pile.type] - 1
    end
end

function Granary:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.stPileRaw = {}
    for _, v in ipairs(self.foodpile) do
        data.stPileRaw[#data.stPileRaw + 1] = {}
        for sk, sv in pairs(v) do
            if sk ~= "id" then
                data.stPileRaw[#data.stPileRaw][sk] = sv
            else
                data.stPileRaw[#data.stPileRaw][sk] = _G.state:serializeObject(sv)
            end
        end
    end
    data.health = self.health
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.hoverAction = self.hoverAction
    return data
end

function Granary.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.foodpile = {}
    for idx, v in ipairs(data.stPileRaw) do
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
            obj:updateFoodpile(idx)
        end
    end
    obj.tile = quadArray[tiles + 1]
    Structure.render(obj)
    return obj
end

return Granary
