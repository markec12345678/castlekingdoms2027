local Structure = require("objects.Structure")
local Object = require("objects.Object")
local SID = require("objects.Controllers.LanguageController").lines

local tiles, quadArray = _G.indexBuildingQuads("siege_building (2)", true)
local TunnelersGuildAlias = _G.class("TunnelersGuildAlias", Structure)
function TunnelersGuildAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function TunnelersGuildAlias:serialize()
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

function TunnelersGuildAlias.static:deserialize(data)
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

local TunnelersGuild = _G.class("TunnelersGuild", Structure)

TunnelersGuild.static.WIDTH = 5
TunnelersGuild.static.LENGTH = 5
TunnelersGuild.static.HEIGHT = 17
TunnelersGuild.static.DESTRUCTIBLE = true
TunnelersGuild.static.HOVERTEXT = SID.objects.hoverText.tunnelersGuild

function TunnelersGuild:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "TunnelersGuild")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -59
    for tile = 1, tiles do
        local hsl = TunnelersGuildAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = TunnelersGuildAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile
            , 16)
        hsl.tileKey = tiles + 1 + tile
    end
    local tileQuads = require("objects.object_quads")
    for xx = 0, TunnelersGuild.static.WIDTH - 1 do
        for yy = 0, TunnelersGuild.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, Structure) then
                TunnelersGuildAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    for xx = 0, 5 do
        for yy = 0, 10 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
        end
    end
    self:applyBuildingHeightMap()
end

function TunnelersGuild:onClick()
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("guilds")
end

function TunnelersGuild:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function TunnelersGuild:serialize()
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

function TunnelersGuild.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function TunnelersGuild:destroy()
    Structure.destroy(self)
end

return TunnelersGuild
