local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local tiles, quadArray = _G.indexBuildingQuads("stockpile")
local actionBar = require("states.ui.ActionBar")
local SID = require("objects.Controllers.LanguageController").lines

local lastQuad = quadArray[#quadArray]
local vx, vy, vw, vh = lastQuad:getViewport()

-- fix rendering issue
local newQuad = love.graphics.newQuad(vx, vy, vw - 2, vh, _G.imageW, _G.imageH)
quadArray[#quadArray] = newQuad
local quadMap = {
    ["wood"] = {},
    ['hop'] = {},
    ["stone"] = {},
    ["iron"] = {},
    ["tar"] = {},
    ["flour"] = {},
    ["ale"] = {},
    ["wheat"] = {}
}

for i = 1, 48 do
    quadMap["wood"][#quadMap["wood"] + 1] = tileQuads["wood_stockpile (" .. tostring(i) .. ")"]
    quadMap["stone"][#quadMap["stone"] + 1] = tileQuads["stone_stockpile (" .. tostring(i) .. ")"]
    quadMap["iron"][#quadMap["iron"] + 1] = tileQuads["iron_stockpile (" .. tostring(i) .. ")"]
end

for i = 1, 32 do
    quadMap["wheat"][#quadMap["wheat"] + 1] = tileQuads["wheat_stockpile (" .. tostring(i) .. ")"]
    quadMap["flour"][#quadMap["flour"] + 1] = tileQuads["flour_stockpile (" .. tostring(i) .. ")"]
end

for i = 1, 16 do
    quadMap["tar"][#quadMap["tar"] + 1] = tileQuads["pitch_stockpile (" .. tostring(i) .. ")"]
    quadMap["ale"][#quadMap["ale"] + 1] = tileQuads["kegs_stockpile (" .. tostring(i) .. ")"]
    quadMap["hop"][#quadMap["hop"] + 1] = tileQuads["hops_stockpile (" .. tostring(i) .. ")"]
end

local pileOffsetY = {
    ["wood"] = { -2, -2, -2, -4, -4,
        -4, -4, -5, -5, -5,
        -5, -7, -7, -7, -7,
        -10, -10, -10, -10, -11,
        -11, -11, -11, -13, -13,
        -13, -13, -15, -15, -15,
        -15, -17, -17, -17, -17,
        -20, -20, -20, -20, -21,
        -21, -21, -21, -23, -23,
        -23, -23, -25
    },
    ["stone"] = { -9 + 3, -9 + 3, -9 + 3, -9 + 3, -9 + 3,
        -9 + 3, -9 + 3, -9 + 3, -9 + 3, -18 + 3,
        -18 + 3, -18 + 3, -18 + 3, -18 + 3, -18 + 3,
        -18 + 3, -18 + 3, -18 + 3, -26 + 3, -26 + 3,
        -26 + 3, -26 + 3, -26 + 3, -26 + 3, -26 + 3,
        -26 + 3, -26 + 3, -35 + 3, -35 + 3, -35 + 3,
        -35 + 3, -35 + 3, -35 + 3, -35 + 3, -35 + 3,
        -35 + 3, -43 + 3, -43 + 3, -43 + 3, -43 + 3,
        -43 + 3, -43 + 3, -43 + 3, -43 + 3, -47 + 3,
        -47 + 3, -47 + 3, -47 + 3
    },
    ["wheat"] = { -14 + 4, -14 + 4, -14 + 4, -14 + 4, -17 + 3,
        -17 + 3, -17 + 3, -19 + 3, -19 + 3, -19 + 3,
        -19 + 3, -19 + 3, -19 + 3, -19 + 3, -19 + 3,
        -19 + 3, -28 + 3, -28 + 3, -28 + 3, -28 + 3,
        -31 + 3, -31 + 3, -31 + 3, -31 + 3, -31 + 3,
        -31 + 3, -31 + 3, -31 + 3, -33 + 3, -33 + 3,
        -35 + 3, -35 + 3
    },
    ["iron"] = { -5 + 2, -5 + 2, -5 + 2, -5 + 2, -5 + 2,
        -5 + 2, -5 + 2, -5 + 2, -5 + 2, -5 + 2,
        -5 + 2, -5 + 2, -10 + 2, -10 + 2, -10 + 2,
        -10 + 2, -10 + 2, -10 + 2, -10 + 2, -10 + 2,
        -10 + 2, -10 + 2, -10 + 2, -10 + 2, -15 + 2,
        -15 + 2, -15 + 2, -15 + 2, -15 + 2, -15 + 2,
        -15 + 2, -15 + 2, -15 + 2, -15 + 2, -15 + 2,
        -15 + 2, -19 + 2, -19 + 2, -19 + 2, -19 + 2,
        -19 + 2, -19 + 2, -19 + 2, -19 + 2, -19 + 2,
        -19 + 2, -19 + 2, -19 + 2
    },
    ["flour"] = { -2, -2, -2, -2, -2,
        -2, -2, -3, -3, -3,
        -3, -3, -3, -3, -6,
        -6, -6, -6, -6, -6,
        -6, -6, -9, -13, -13,
        -13, -13, -13, -13, -13,
        -14, -15
    },
    ["tar"] = { -12 + 4, -12 + 4, -12 + 4, -12 + 4, -12 + 4,
        -12 + 4, -12 + 4, -12 + 4, -12 + 4, -17 + 4,
        -17 + 4, -17 + 4, -17 + 4, -19 + 4, -22 + 4,
        -29 + 4
    },
    ["ale"] = { -16 + 4, -16 + 4, -16 + 4, -16 + 4, -16 + 4,
        -16 + 4, -16 + 4, -16 + 4, -16 + 4, -20 + 4,
        -20 + 4, -20 + 4, -20 + 4, -21 + 4, -30 + 4,
        -30 + 4
    },
    ["hop"] = { -11 + 4, -11 + 4, -11 + 4, -11 + 4, -11 + 4,
        -11 + 4, -11 + 4, -11 + 4, -11 + 4, -14 + 4,
        -14 + 4, -14 + 4, -14 + 4, -14 + 4, -20 + 4,
        -20 + 4
    }
}

local maxQuantity = {
    ["wood"] = 48,
    ["stone"] = 48,
    ["wheat"] = 32,
    ["iron"] = 48,
    ["flour"] = 32,
    ["hop"] = 16,
    ["tar"] = 16,
    ["ale"] = 16
}
local StockpileAlias = _G.class("StockpileAlias", Structure)
function StockpileAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    self.parent = parent
    Structure.initialize(self, gx, gy, "Stockpile alias")
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    Structure.render(self)
end

function StockpileAlias:render()
    Structure.render(self)
end

function StockpileAlias:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.tileKey = self.tileKey
    data.baseOffsetY = self.baseOffsetY
    data.additionalOffsetY = self.additionalOffsetY
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    return data
end

function StockpileAlias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.tileKey then
        obj.tile = quadArray[data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end
    return obj
end

local Stockpile = _G.class("Stockpile", Structure)
Stockpile.static.WIDTH = 5
Stockpile.static.LENGTH = 5
Stockpile.static.HEIGHT = 12
Stockpile.static.DESTRUCTIBLE = false
Stockpile.static.HOVERTEXT = SID.objects.hoverText.stockpile
function Stockpile:initialize(gx, gy, type)
    type = type or "Stockpile"
    Structure.initialize(self, gx, gy, type)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    _G.state.map:setWalkable(self.gx + 1, self.gy, 1)
    _G.state.map:setWalkable(self.gx + 1, self.gy + 1, 1)
    _G.state.map:setWalkable(self.gx, self.gy + 1, 1)

    _G.state.map:setWalkable(self.gx + 3, self.gy, 1)
    _G.state.map:setWalkable(self.gx + 3 + 1, self.gy, 1)
    _G.state.map:setWalkable(self.gx + 3 + 1, self.gy + 1, 1)
    _G.state.map:setWalkable(self.gx + 3, self.gy + 1, 1)

    _G.state.map:setWalkable(self.gx + 3, self.gy + 3, 1)
    _G.state.map:setWalkable(self.gx + 3 + 1, self.gy + 3, 1)
    _G.state.map:setWalkable(self.gx + 3 + 1, self.gy + 3 + 1, 1)
    _G.state.map:setWalkable(self.gx + 3, self.gy + 3 + 1, 1)

    _G.state.map:setWalkable(self.gx, self.gy + 3, 1)
    _G.state.map:setWalkable(self.gx + 1, self.gy + 3, 1)
    _G.state.map:setWalkable(self.gx + 1, self.gy + 3 + 1, 1)
    _G.state.map:setWalkable(self.gx, self.gy + 3 + 1, 1)
    self.health = 1000
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -12

    self.aliases = {
        StockpileAlias:new(tileQuads["empty"], self.gx + 4, self.gy + 4 - 1, self),
        StockpileAlias:new(tileQuads["empty"], self.gx + 4 - 1, self.gy + 4, self),
        StockpileAlias:new(tileQuads["empty"], self.gx + 4 - 1, self.gy + 4, self),
        StockpileAlias:new(tileQuads["empty"], self.gx + 3, self.gy + 1, self),
        StockpileAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 3, self),
        StockpileAlias:new(tileQuads["empty"], self.gx + 3, self.gy + 3, self),
        StockpileAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 1, self),
        StockpileAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 1, self),
        StockpileAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 2, self),
        StockpileAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 2, self),
        StockpileAlias:new(tileQuads["empty"], self.gx + 3, self.gy + 2, self),
        StockpileAlias:new(tileQuads["empty"], self.gx + 4, self.gy + 2, self),
        StockpileAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 3, self),
        StockpileAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 4, self),
    }
    for tile = 1, tiles do
        local stp = StockpileAlias:new(
            quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self, -self.offsetY + 8 * (tiles - tile + 1), nil)
        stp.tileKey = tile
        self.aliases[#self.aliases + 1] = stp
    end

    for tile = 1, tiles do
        local stp = StockpileAlias:new(
            quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile, 16, nil)
        stp.tileKey = tiles + 1 + tile
        self.aliases[#self.aliases + 1] = stp
    end

    for xx = -1, 5 do
        for yy = -1, 5 do
            if xx ~= -1 and yy ~= -1 and xx ~= 5 and yy ~= 5 then
                local ccx, ccy, xxx, yyy = _G.getLocalCoordinatesFromGlobal(self.gx + xx, self.gy + yy)
                _G.state.map.buildingheightmap[ccx][ccy][xxx][yyy] = self.class.static.HEIGHT
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.none)
            else
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.dirt)
            end
        end
    end
    for tileX = 0, tiles do
        for tileY = 0, tiles do
            _G.state.map:setHeight(self.gx + tileX, self.gy + tileY, 10)
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
    self.stockpile[1].id = StockpileAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 1, self, 32 - 4, -16)
    self.stockpile[2].id = StockpileAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 4, self, 32 - 4, -16)
    self.stockpile[3].id = StockpileAlias:new(tileQuads["empty"], self.gx + 4, self.gy + 1, self, 32 - 4, -16)
    self.stockpile[4].id = StockpileAlias:new(tileQuads["empty"], self.gx + 4, self.gy + 4, self, 32 - 4, -16)
    table.insert(
        _G.stockpile.nodeList, {
            gx = self.gx + 2,
            gy = self.gy + 2
        })

    _G.stockpile.list[(#_G.stockpile.list or 0) + 1] = self
    Structure.render(self)
end

function Stockpile:onClick()
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("stockpile")
end

function Stockpile:store(resource)
    for index = 1, 4 do
        if self.stockpile[index].type == resource and self.stockpile[index].quantity < maxQuantity[resource] then
            self.stockpile[index].quantity = self.stockpile[index].quantity + 1
            _G.state.resources[resource] = _G.state.resources[resource] + 1
            self:updateStockpile(index)
            return true
        end
    end
    local found = false
    if not found then
        for index = 1, 4 do
            local currPile = self.stockpile[index]
            if currPile.empty then
                currPile.empty = false
                currPile.type = resource
                currPile.quantity = 1
                _G.state.notFullStockpiles[currPile.type] = _G.state.notFullStockpiles[currPile.type] + 1
                _G.state.resources[resource] = _G.state.resources[resource] + 1
                currPile.key = #_G.stockpile.resources[resource] + 1
                _G.stockpile.resources[resource][currPile.key] = currPile
                self:updateStockpile(index)
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
        if from.quantity == maxQuantity[resource] then
            _G.state.notFullStockpiles[resource] = _G.state.notFullStockpiles[resource] + 1
        end
        from.quantity = from.quantity - 1
        _G.state.resources[resource] = _G.state.resources[resource] - 1
        self:updateStockpile(from)
        return true
    end
    for index = 1, 4 do
        if self.stockpile[index].type == resource and self.stockpile[index].quantity > 0 then
            self.stockpile[index].quantity = self.stockpile[index].quantity - 1
            _G.state.resources[resource] = _G.state.resources[resource] - 1
            self:updateStockpile(index)
            return true
        end
    end
    return false
end

function Stockpile:updateStockpile(index)
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
        _G.state.notFullStockpiles[pile.type] = _G.state.notFullStockpiles[pile.type] - 1
        pile.quantity = -1
        pile.type = nil
        pile.empty = true
        pile.id.tile = tileQuads["empty"]
        pile.id:render()
        return
    elseif pile.quantity < 0 then
        pile.id.tile = tileQuads["empty"]
        pile.id:render()
        return
    end
    pile.id.tile = quadMap[pile.type][pile.quantity]
    pile.id.additionalOffsetY = pileOffsetY[pile.type][pile.quantity]
    pile.id.offsetY = pile.id.additionalOffsetY - pile.id.baseOffsetY
    pile.id:render()
    if pile.quantity == maxQuantity[pile.type] then
        _G.state.notFullStockpiles[pile.type] = _G.state.notFullStockpiles[pile.type] - 1
    end
    actionBar:updateStockpileResourcesCount()
end

function Stockpile:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    -- TODO: Check if node list is free before assigning it
    table.insert(
        _G.stockpile.nodeList, {
            gx = self.gx + 2,
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
    self.offsetX = data.offsetX
    self.offsetY = data.offsetY

    _G.stockpile.list[(#_G.stockpile.list or 0) + 1] = self

    for idx, v in ipairs(data.stPileRaw) do
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
                local newKey = #_G.stockpile.resources[v.type] + 1
                _G.stockpile.resources[v.type][newKey] = self.stockpile[idx]
                self.stockpile[idx].key = newKey
            else
                _G.stockpile.resources[v.type] = { self.stockpile[idx] }
            end
        end
    end
    self.aliases = {}
    data.stPileRaw = nil
    for i, v in ipairs(data.aliases) do
        self.aliases[i] = _G.state:dereferenceObject(v)
        self.aliases[i].parent = self
    end
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
    for idx, _ in ipairs(self.stockpile) do
        self:updateStockpile(idx)
    end
end

function Stockpile:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.stPileRaw = {}
    data.health = self.health
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    for _, piles in ipairs(self.stockpile) do
        data.stPileRaw[#data.stPileRaw + 1] = {}
        for sk, sv in pairs(piles) do
            if sk == "id" then
                data.stPileRaw[#data.stPileRaw][sk] = _G.state:serializeObject(sv)
            else
                data.stPileRaw[#data.stPileRaw][sk] = sv
            end
        end
    end
    data.aliases = {}
    for i, v in ipairs(self.aliases) do
        data.aliases[i] = _G.state:serializeObject(v)
    end
    return data
end

function Stockpile.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return Stockpile
