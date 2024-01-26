local Structure = require("objects.Structure")
local Object = require("objects.Object")
local SID = require("objects.Controllers.LanguageController").lines

local tiles, quadArray = _G.indexBuildingQuads("siege_building (1)", true)
local EngineersGuildAlias = _G.class("EngineersGuildAlias", Structure)
function EngineersGuildAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function EngineersGuildAlias:serialize()
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

function EngineersGuildAlias.static:deserialize(data)
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

local EngineersGuild = _G.class("EngineersGuild", Structure)

EngineersGuild.static.WIDTH = 5
EngineersGuild.static.LENGTH = 5
EngineersGuild.static.HEIGHT = 17
EngineersGuild.static.DESTRUCTIBLE = true
EngineersGuild.static.HOVERTEXT = SID.objects.hoverText.engineersGuild

function EngineersGuild:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "EngineersGuild")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -59
    for tile = 1, tiles do
        local hsl = EngineersGuildAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = EngineersGuildAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile
            , 16)
        hsl.tileKey = tiles + 1 + tile
    end
    local tileQuads = require("objects.object_quads")
    for xx = 0, EngineersGuild.static.WIDTH - 1 do
        for yy = 0, EngineersGuild.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, Structure) then
                EngineersGuildAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    for xx = 0, 5 do
        for yy = 0, 10 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
        end
    end
    self.freeSpots = _G.newAutotable(2)
    for xx = 1, 9 do
        for yy = 5, 9 do
            self.freeSpots[xx][yy] = _G.state.map:isWalkable(xx, yy)
        end
    end
    self:applyBuildingHeightMap()
end

function EngineersGuild:freeAllSpots()
    for xx = 1, 9 do
        for yy = 5, 9 do
            self.freeSpots[xx][yy] = _G.state.map:isWalkable(xx, yy)
        end
    end
end

function EngineersGuild:anyFreeSpots()
    for xx = 1, 9 do
        for yy = 5, 9 do
            if self.freeSpots[xx][yy] == true then
                return true
            end
        end
    end
    return false
end

function EngineersGuild:getNextFreeSpot(soldier)
    for xx = 1, 9 do
        for yy = 5, 9 do
            if self.freeSpots[xx][yy] == true then
                self.freeSpots[xx][yy] = soldier
                _G.soldiers = _G.soldiers + 1
                return self.gx + xx, self.gy + yy, "south"
            end
        end
    end
    self:freeAllSpots()
    return self:getNextFreeSpot(soldier)
end

function EngineersGuild:onClick()
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("guilds")
    _G.selectedRecruitLocation = self
end

function EngineersGuild:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function EngineersGuild:serialize()
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
    local freeSpots = {}
    for xx = 1, 9 do
        freeSpots[xx] = {}
        for yy = 5, 9 do
            freeSpots[xx][yy] = self.freeSpots[xx][yy]
            if freeSpots[xx][yy] and type(freeSpots[xx][yy]) ~= "boolean" then
                freeSpots[xx][yy] = _G.state:serializeObject(freeSpots[xx][yy])
            end
        end
    end
    data.freeSpots = freeSpots
    return data
end

function EngineersGuild.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function EngineersGuild:destroy()
    Structure.destroy(self)
end

return EngineersGuild
