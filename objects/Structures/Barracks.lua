local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles, quadArray = _G.indexBuildingQuads("barracks (1)", true)
local BarracksAlias = _G.class("BarracksAlias", Structure)
function BarracksAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function BarracksAlias:serialize()
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

function BarracksAlias.static:deserialize(data)
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

local Barracks = _G.class("Barracks", Structure)

Barracks.static.WIDTH = 5
Barracks.static.LENGTH = 5
Barracks.static.HEIGHT = 17
Barracks.static.DESTRUCTIBLE = true
Barracks.static.HOVERTEXT = "Click to recruit units"

function Barracks:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "Barracks")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -69
    for tile = 1, tiles do
        local hsl = BarracksAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = BarracksAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile
            , 16)
        hsl.tileKey = tiles + 1 + tile
    end
    local tileQuads = require("objects.object_quads")
    for xx = 0, Barracks.static.WIDTH - 1 do
        for yy = 0, Barracks.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, Structure) then
                BarracksAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    for xx = -1, 10 do
        for yy = -1, 10 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
        end
    end
    self:applyBuildingHeightMap()
end

function Barracks:onClick()
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("barracks")
end

function Barracks:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function Barracks:serialize()
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

function Barracks.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function Barracks:destroy()
    _G.DestructionController:destroyAtLocation(self.gx + 7, self.gy + 7, false, true)
    _G.DestructionController:destroyAtLocation(self.gx + 2, self.gy + 7, false, true)
    _G.DestructionController:destroyAtLocation(self.gx + 7, self.gy + 2, false, true)

    Structure.destroy(self)
end

return Barracks
