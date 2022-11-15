local _, _, _, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles, quadArray = _G.indexBuildingQuads("market", true)
local MarketAlias = _G.class("MarketAlias", Structure)
function MarketAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    for k, v in ipairs(_G.stockpile.nodeList) do
        if v.gx == self.gx and v.gy == self.gy then
            table.remove(_G.stockpile.nodeList, k)
            break
        end
    end
    Structure.render(self)
end

function MarketAlias:onClick()
    self.parent.onClick()
end

function MarketAlias:serialize()
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
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function MarketAlias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    if data.tileKey then
        obj.tile = quadArray[data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end
    return obj
end

local Market = _G.class("Market", Structure)

Market.static.WIDTH = 5
Market.static.LENGTH = 5
Market.static.HEIGHT = 17

function Market:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "Market")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -45 * 2
    for tile = 1, tiles do
        local hsl = MarketAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = MarketAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile
            , 16)
        hsl.tileKey = tiles + 1 + tile
    end
    local tileQuads = require("objects.object_quads")
    for xx = 0, Market.static.WIDTH do
        for yy = 0, Market.static.LENGTH do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + gy, Structure) then
                MarketAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end


    self:applyBuildingHeightMap()

    Structure.render(self)
end

function Market:onClick()
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("market")
end

function Market:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function Market:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    return data
end

function Market.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return Market
