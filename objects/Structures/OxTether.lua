local Object = require("objects.Object")
local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local OxUnit = require("objects.Units.Ox")
local NotEnoughWorkersFloat = require("objects.Floats.NotEnoughWorkersFloat")

local _, quadArrayEast1 = _G.indexBuildingQuads("stone_oax_base (1)")
local _, quadArrayEast2 = _G.indexBuildingQuads("stone_oax_base (2)")
local _, quadArrayEast3 = _G.indexBuildingQuads("stone_oax_base (3)")
local _, quadArrayEast4 = _G.indexBuildingQuads("stone_oax_base (4)")
local _, quadArrayEast5 = _G.indexBuildingQuads("stone_oax_base (5)")
local _, quadArrayEast6 = _G.indexBuildingQuads("stone_oax_base (6)")
local _, quadArrayEast7 = _G.indexBuildingQuads("stone_oax_base (7)")
local _, quadArrayEast8 = _G.indexBuildingQuads("stone_oax_base (8)")
local tilesEast, quadArrayEast9 = _G.indexBuildingQuads("stone_oax_base (9)")


local buildingQuads = {
    quadArrayEast1,
    quadArrayEast2,
    quadArrayEast3,
    quadArrayEast4,
    quadArrayEast5,
    quadArrayEast6,
    quadArrayEast7,
    quadArrayEast8,
    quadArrayEast9,
}

local OxTetherAlias = _G.class("OxTetherAlias", Structure)
function OxTetherAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
    self.parent = parent
    Structure.initialize(self, gx, gy)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile or tileQuads["empty"]
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    Structure.render(self)
end

function OxTetherAlias:serialize()
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

function OxTetherAlias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    if data.tileKey then
        obj.tile = buildingQuads[1][data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end
    return obj
end

local OxTether = _G.class("OxTether", Structure)
OxTether.static.WIDTH = 2
OxTether.static.LENGTH = 2
OxTether.static.EFFECTIVE_WIDTH = 2
OxTether.static.EFFECTIVE_LENGTH = 4
OxTether.static.HEIGHT = 4
OxTether.static.ALIAS_NAME = nil
OxTether.static.DESTRUCTIBLE = true
OxTether.static.NAMEINDEX = "ox"

function OxTether:initialize(gx, gy)
    _G.JobController:add("OxHandler", self)
    Structure.initialize(self, gx, gy, "OxTether")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = buildingQuads[1][tilesEast + 1]
    self.health = 50
    self.offsetX = 0
    self.offsetY = -26
    self.freeSpots = 1
    self.oxUnit = OxUnit:new(gx + 1, gy + 3, self)
    self.oxWorker = nil
    self.quantity = 0

    for x = gx - 25, gx + 25, 5 do
        for y = gy - 25, gy + 25, 5 do
            local str = _G.objectFromSubclassAtGlobal(x, y, Structure)
            if str then
                str = str.parent or str
                if str.class.name == "Quarry" then
                    str.isStandalone = false
                end
                break
            end
        end
    end

    for tile = 1, tilesEast do
        local whf = OxTetherAlias:new(buildingQuads[1][tile], self.gx, self.gy + (tilesEast - tile + 1), self,
            -self.offsetY + 8 * (tilesEast - tile + 1))
        whf.tileKey = tile
    end

    for tile = 1, tilesEast do
        local whf = OxTetherAlias:new(buildingQuads[1][tilesEast + 1 + tile], self.gx + tile, self.gy, self,
            -self.offsetY + 8 * tile, 14)
        whf.tileKey = tilesEast + 1 + tile
    end


    for xx = -1, 2 do
        for yy = -1, 2 do
            if _G.objectFromClassAtGlobal(self.gx + xx, self.gy + yy, "Stone") then
                _G.removeObjectFromClassAtGlobal(self.gx + xx, self.gy + yy, "Stone")
            end
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.dirt)
        end
    end

    OxTetherAlias:new(nil, self.gx + 1, self.gy + 1, self, self.offsetX, self.offsetY)

    self:applyBuildingHeightMap()

    self.float = NotEnoughWorkersFloat:new(self.gx + self.class.WIDTH - 1, self.gy + self.class.LENGTH - 1, -1, -80)
end

function OxTether:destroy()
    _G.JobController:remove("OxHandler", self)
    -- force all quarrys in range to scan for other tethers in range
    -- and if necessary switch the quarry into standalone mode
    for x = self.gx - 25, self.gx + 25 do
        for y = self.gy - 25, self.gy + 25 do
            local tile = _G.objectFromClassAtGlobal(x, y, "Quarry")
            ---@cast tile Quarry
            if type(tile) ~= "boolean" then
                tile:onTetherDestruction(self)
            end
        end
    end
    if self.oxUnit then
        self.oxUnit:destroy()
    end
    self.float:destroy()

    Structure.destroy(self)

    if self.oxWorker then
        self.oxWorker:quitJob()
    end
end

function OxTether:add(amount)
    if amount == nil then
        amount = 1
    end
    local newQuantity = self.quantity + amount
    if newQuantity > 8 then
        print("Cannot add more than 8 Stone to Tether stack")
        return
    end
    self.quantity = newQuantity
    if newQuantity == 8 then
        self.oxUnit:sendToStockpile()
    end
    self:update()
end

function OxTether:take(amount)
    if amount == nil then
        amount = 1
    end
    local newQuantity = self.quantity + amount
    if newQuantity < 0 then
        print("Tether stack does not have enough stone")
        return
    end
    self.quantity = newQuantity
    self:update()
end

function OxTether:leave(sleepInsteadOfLeaving)
    if self.oxWorker then
        _G.JobController:add("OxHandler", self)
        if sleepInsteadOfLeaving then
            self.oxWorker:quitJob()
        else
            self.oxWorker:leaveVillage()
        end
        self.oxWorker = nil
        self.freeSpots = 1
        self.float:activate(sleepInsteadOfLeaving)
        return true
    end
end

function OxTether:join(worker)
    if self.health == -1 then
        _G.JobController:remove("OxHandler", self)
        worker:quitJob()
        return
    end

    self.oxWorker = worker
    self.oxWorker.workplace = self
    self.freeSpots = 0

    if self.freeSpots == 0 then
        self.float:deactivate()
    end
end

function OxTether:work(worker)
    worker:sendToQuarry()
end

function OxTether:update()
    self.tile = buildingQuads[self.quantity + 1][2]
    local obj1 = _G.objectFromClassAtGlobal(self.gx, self.gy + 1, OxTetherAlias)
    if obj1 then
        obj1.tilekey = 1
        obj1.tile = buildingQuads[self.quantity + 1][obj1.tilekey]
        obj1:render()
    end
    local obj2 = _G.objectFromClassAtGlobal(self.gx + 1, self.gy, OxTetherAlias)
    if obj2 then
        obj2.tilekey = 3
        obj2.tile = buildingQuads[self.quantity + 1][obj2.tilekey]
        obj2:render()
    end
    Structure.render(self)
end

function OxTether:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.health = data.health
    self.offsetX = data.offsetX
    self.offsetY = data.offsetY
    self.freeSpots = data.freeSpots
    self.oxUnit = _G.state:dereferenceObject(data.oxUnit)
    self.oxUnit.workplace = self
    self.quantity = data.quantity
    if data.oxWorker then
        self.oxWorker = _G.state:dereferenceObject(data.oxWorker)
        self.worker = self.oxWorker
        self.oxWorker.workplace = self
    end
    self.tile = buildingQuads[self.quantity + 1][2]
    self:render()
end

function OxTether.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    obj:load(data)
    return obj
end

function OxTether:serialize()
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
    data.freeSpots = self.freeSpots
    data.oxUnit = _G.state:serializeObject(self.oxUnit)
    data.quantity = self.quantity
    if self.oxWorker then
        data.oxWorker = _G.state:serializeObject(self.oxWorker)
    end

    return data
end

return OxTether
