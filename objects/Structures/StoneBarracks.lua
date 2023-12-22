local Structure = require("objects.Structure")
local Object = require("objects.Object")
local SID = require("objects.Controllers.LanguageController").lines

local tiles, quadArray = _G.indexBuildingQuads("barracks (2)", true)
local StoneBarracksAlias = _G.class("StoneBarracksAlias", Structure)
function StoneBarracksAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function StoneBarracksAlias:serialize()
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

function StoneBarracksAlias.static:deserialize(data)
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

local StoneBarracks = _G.class("StoneBarracks", Structure)

StoneBarracks.static.WIDTH = 5
StoneBarracks.static.LENGTH = 5
StoneBarracks.static.HEIGHT = 17
StoneBarracks.static.DESTRUCTIBLE = true
StoneBarracks.static.HOVERTEXT = SID.objects.hoverText.stoneBarracks

function StoneBarracks:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "StoneBarracks")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -80
    for tile = 1, tiles do
        local hsl = StoneBarracksAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = StoneBarracksAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile
        , 16)
        hsl.tileKey = tiles + 1 + tile
    end
    local tileQuads = require("objects.object_quads")
    for xx = 0, StoneBarracks.static.WIDTH - 1 do
        for yy = 0, StoneBarracks.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, Structure) then
                StoneBarracksAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    for xx = -1, 10 do
        for yy = -1, 10 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
        end
    end
    self.freeSpots = _G.newAutotable(2)
    for xx = 0, 9 do
        for yy = 0, 9 do
            if not (xx < 5 and yy < 5) and not (xx == 7 and yy == 2) and not (xx == 2 and yy == 7) and not (xx == 7 and yy == 7) then
                self.freeSpots[xx][yy] = _G.state.map:isWalkable(xx, yy)
                _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
            end
        end
    end
    self:applyBuildingHeightMap()
end

function StoneBarracks:anyFreeSpots()
    return true
end

function StoneBarracks:freeAllSpots()
    for xx = 0, 9 do
        for yy = 0, 9 do
            if not (xx < 5 and yy < 5) and not (xx == 7 and yy == 2) and not (xx == 2 and yy == 7) and not (xx == 7 and yy == 7) then
                self.freeSpots[xx][yy] = _G.state.map:isWalkable(xx, yy)
            end
        end
    end
end

function StoneBarracks:getNextFreeSpot(soldier)
    for xx = 0, 9 do
        for yy = 0, 9 do
            if not (xx < 5 and yy < 5) and not (xx == 7 and yy == 2) and not (xx == 2 and yy == 7) and not (xx == 7 and yy == 7) then
                if self.freeSpots[xx][yy] == true then
                    self.freeSpots[xx][yy] = soldier
                    _G.soldiers = _G.soldiers + 1
                    return self.gx + xx, self.gy + yy, "south"
                end
            end
        end
    end
    self:freeAllSpots()
    return self:getNextFreeSpot(soldier)
end

function StoneBarracks:onClick()
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("barracks")
    _G.selectedRecruitLocation = self
end

function StoneBarracks:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function StoneBarracks:serialize()
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

function StoneBarracks.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function StoneBarracks:destroy()
    _G.DestructionController:destroyAtLocation(self.gx + 7, self.gy + 7, false, true)
    _G.DestructionController:destroyAtLocation(self.gx + 2, self.gy + 7, false, true)
    _G.DestructionController:destroyAtLocation(self.gx + 7, self.gy + 2, false, true)

    Structure.destroy(self)
end

return StoneBarracks
