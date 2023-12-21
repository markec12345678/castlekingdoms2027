local _, _, _, _ = ...

local Structure = require("objects.Structure")
local Object = require("objects.Object")
local Drunkard = require("objects.Units.Drunkard")

local tiles, quadArray = _G.indexBuildingQuads("inn", true)
local InnAlias = _G.class("InnAlias", Structure)
function InnAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    Structure.render(self)
end

function InnAlias:serialize()
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

function InnAlias.static:deserialize(data)
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

local Inn = _G.class("Inn", Structure)

Inn.static.WIDTH = 5
Inn.static.LENGTH = 5
Inn.static.HEIGHT = 17
Inn.static.DESTRUCTIBLE = true

function Inn:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "Inn")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -90
    self.drunkard = Drunkard:new(gx + 3, gy + Inn.static.WIDTH, self)
    for tile = 1, tiles do
        local hsl = InnAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = InnAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile
            , 16)
        hsl.tileKey = tiles + 1 + tile
    end
    local tileQuads = require("objects.object_quads")
    for xx = 0, Inn.static.WIDTH - 1 do
        for yy = 0, Inn.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, Structure) then
                InnAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    self:applyBuildingHeightMap()
end

function Inn:destroy()
    if self.drunkard then
        self.drunkard.inn = nil
    end
    Structure.destroy(self)
end

function Inn:onClick()
    local ActionBar = require("states.ui.ActionBar")
    --ActionBar:switchMode("inn")
end

function Inn:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
    if data.drunkard then
        self.drunkard = _G.state:dereferenceObject(data.drunkard)
        self.drunkard.inn = self
    end
end

function Inn:serialize()
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
    if self.drunkard then
        data.drunkard = _G.state:serializeObject(self.drunkard)
    end

    return data
end

function Inn.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return Inn
