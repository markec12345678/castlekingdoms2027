local Object = require("objects.Object")
local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local OxUnit = require("objects.Units.Ox");

local OxTether = _G.class("OxTether", Structure)
function OxTether:initialize(gx, gy)
    _G.JobController:add("OxHandler", self)
    Structure.initialize(self, gx, gy, "OxTether")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tileQuads["stone_ox_base (1)"]
    self.health = 50
    self.offsetX = -15
    self.offsetY = -26
    self.freeSpots = 1
    self.oxUnit = OxUnit:new(gx + 1, gy + 3, self)
    self.oxWorker = nil
    self.quantity = 0

    for x = gx - 25, gx + 25 do
        for y = gy - 25, gy + 25 do
            local quarry = _G.objectFromClassAtGlobal(x, y, "Quarry")
            if quarry then
                quarry.isStandalone = false
            end
        end
    end

    for xx = -1, 2 do
        for yy = -1, 2 do
            if _G.objectFromClassAtGlobal(self.gx + xx, self.gy + yy, "Stone") then
                _G.removeObjectFromClassAtGlobal(self.gx + xx, self.gy + yy, "Stone")
            end
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.dirt)
        end
    end

    Structure:applyBuildingHeightMap(gx, gy, 2, 2, 4)
    Structure.render(self)
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
    if newQuantity == 8 then
        self.oxUnit:sendToStockpile()
    else
        self.quantity = newQuantity
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

function OxTether:join(worker)
    self.oxWorker = worker
    self.oxWorker.workplace = self
    self.freeSpots = 0
end

function OxTether:work(worker)
    worker:sendToQuarry()
end

function OxTether:update()
    self.tile = tileQuads["stone_ox_base (" .. self.quantity + 1 .. ")"]
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
    self.tile = tileQuads["stone_ox_base (1)"]
    self:update()
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
    else
        error("no ox worker")
    end

    return data
end

return OxTether
