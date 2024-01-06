local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local anim = require("libraries.anim8")
local NotEnoughWorkersFloat = require("objects.Floats.NotEnoughWorkersFloat")

local tiles, quadArray = _G.indexBuildingQuads("pitch")

local ANIM_COLLECTING_PITCH = "Collecting_pitch"

local an = {
    [ANIM_COLLECTING_PITCH] = _G.indexQuads("anim_pitch_dugout", 48),
}

local PitchRigFx = {} --TBD

local PitchRigCooking = _G.class("PitchRigCooking", Structure)
function PitchRigCooking:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "PitchRig cooking")
    self.tile = tileQuads["empty"]
    self.animated = false
    self.brewingCycle = 0
    self.animation = anim.newAnimation(an[ANIM_COLLECTING_PITCH], 0.11, self:brewCallback_1(), ANIM_COLLECTING_PITCH)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.offsetX = -58
    self.offsetY = -72

    self:registerAsActiveEntity()
end

function PitchRigCooking:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animation = self.animation:serialize()
    data.animated = self.animated
    data.brewingCycle = self.brewingCycle
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function PitchRigCooking.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    obj.parent.cookingObj = obj
    local callback
    local anData = data.animation
    if anData.animationIdentifier == ANIM_COLLECTING_PITCH then
        callback = obj:brewCallback_1()
    end
    obj.animation = _G.anim.newAnimation(an[anData.animationIdentifier], 1, callback, anData.animationIdentifier)
    obj.animation:deserialize(anData)
    if obj.parent.restoreExitPoint then
        obj:findWorkerExitPointAndSendToStockpile()
    end

    return obj
end

function PitchRigCooking:brewCallback_1()
    return function()
        self:findWorkerExitPointAndSendToStockpile()
        self:deactivate()
    end
end

function PitchRigCooking:findWorkerExitPointAndSendToStockpile()
    self.parent:findExitPointTo("Stockpile", function(found, path)
        if found then
            self.parent:sendToStockpile()
        else
            print("No path found to stockpile!")
        end
    end)
end

function PitchRigCooking:animate()
    Structure.animate(self, _G.dt, true)
end

function PitchRigCooking:activate()
    self.animated = true
    self:animate()
end

function PitchRigCooking:deactivate()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
end

local PitchRigAlias = _G.class("PitchRigAlias", Structure)
function PitchRigAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function PitchRigAlias:serialize()
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

function PitchRigAlias.static:deserialize(data)
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

local PitchRig = _G.class("PitchRig", Structure)

PitchRig.static.WIDTH = 4
PitchRig.static.LENGTH = 4
PitchRig.static.HEIGHT = 17
PitchRig.static.ALIAS_NAME = "PitchRigAlias"
PitchRig.static.DESTRUCTIBLE = true

function PitchRig:initialize(gx, gy)
    _G.JobController:add("Pitcher", self)
    Structure.initialize(self, gx, gy, "PitchRig")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 400
    self.tile = quadArray[tiles + 1]
    self.working = false
    self.unloading = false
    self.offsetX = 0
    self.offsetY = -11
    self.freeSpots = 1
    self.worker = nil
    self.cookingObj = PitchRigCooking:new(self.gx + 3, self.gy + 2, self)

    for xx = -2, 5 do
        for yy = -2, 5 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.dirt, _G.terrainBiome.abundantGrass)
        end
    end
    for xx = -1, 4 do
        for yy = -1, 4 do
            _G.terrainSetTileAt(self.gx + xx, self.gy + yy, _G.terrainBiome.scarceGrass)
        end
    end

    for tile = 1, tiles do
        local bkr = PitchRigAlias:new(
            quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self, -self.offsetY + 8 * (tiles - tile + 1))
        bkr.tileKey = tile
    end
    for tile = 1, tiles do
        local bkr = PitchRigAlias:new(
            quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile, 16)
        bkr.tileKey = tiles + 1 + tile
    end

    PitchRigAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 3, self, self.offsetX, self.offsetY)
    PitchRigAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 3, self, self.offsetX, self.offsetY)
    PitchRigAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 2, self, self.offsetX, self.offsetY)
    PitchRigAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 2, self, self.offsetX, self.offsetY)
    PitchRigAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 1, self, self.offsetX, self.offsetY)
    PitchRigAlias:new(tileQuads["empty"], self.gx + 2, self.gy + 1, self, self.offsetX, self.offsetY)
    PitchRigAlias:new(tileQuads["empty"], self.gx + 3, self.gy + 1, self, self.offsetX, self.offsetY)

    self.float = NotEnoughWorkersFloat:new(self.gx + self.class.WIDTH - 1, self.gy + self.class.LENGTH - 1, 7, -112)
    self:applyBuildingHeightMap()
end

function PitchRig:destroy()
    self.float:destroy()
    Structure.destroy(self.cookingObj)
    self.cookingObj.toBeDeleted = true

    _G.JobController:remove("Pitcher", self)
    Structure.destroy(self)
    if self.worker then
        self.worker:quitJob()
    end
end

function PitchRig:onClick()
    --
end

function PitchRig:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function PitchRig:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.health = self.health
    data.working = self.working
    data.unloading = self.unloading
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    data.freeSpots = self.freeSpots
    if self.worker then
        data.worker = _G.state:serializeObject(self.worker)
    end
    return data
end

function PitchRig.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

function PitchRig:leave(sleepInsteadOfLeaving)
    if self.worker then
        _G.JobController:add("OxHandler", self)
        if sleepInsteadOfLeaving then
            self.worker:quitJob()
        else
            self.worker:leaveVillage()
        end
        self.worker = nil
        self.freeSpots = 1
        self.float:activate()
        self.cookingObj:deactivate()
        return true
    end
end

function PitchRig:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Pitcher", self)
        worker:quitJob()
        return
    end
    if self.freeSpots == 1 then
        self.worker = worker
        self.worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    end
    if self.freeSpots == 0 then
        self.float:deactivate()
    end
end

function PitchRig:work(worker)
    if self.worker.state == "Going to workplace" then
        self.worker.state = "Working"
        self.working = true
        worker.tile = tileQuads["empty"]
        worker.animated = false
        worker.gx = self.gx + 1
        worker.gy = self.gy + 2
        worker:jobUpdate()
        self.cookingObj:activate()
    else
        self.worker.state = "Working"
    end
end

function PitchRig:sendToStockpile()
    self:respawnWorker(self.worker, "Go to stockpile")
    self.working = false
    self.worker.needNewVertAsap = true
    self.cookingObj:deactivate()
end

return PitchRig
