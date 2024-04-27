local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")
local NotEnoughWorkersFloat = require("objects.Floats.NotEnoughWorkersFloat")

local tiles, quadArray = _G.indexBuildingQuads("church_small", true)
local ChapelAlias = _G.class("ChapelAlias", Structure)
function ChapelAlias:initialize(tile, gx, gy, parent, offsetY, offsetX)
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

function ChapelAlias:serialize()
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

function ChapelAlias.static:deserialize(data)
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

local chapelFx = {
    ["Chapel"] = { _G.fx["chapel"] }
}

local Chapel = _G.class("Chapel", Structure)

Chapel.static.WIDTH = 6
Chapel.static.LENGTH = 6
Chapel.static.HEIGHT = 17
Chapel.static.DESTRUCTIBLE = true

function Chapel:initialize(gx, gy)
    _G.JobController:add("Priest", self)
    Structure.initialize(self, gx, gy, "Chapel")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 50
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -85
    self.freeSpots = 1
    self.worker = nil

    for tile = 1, tiles do
        local hsl = ChapelAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = ChapelAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile
        , 16)
        hsl.tileKey = tiles + 1 + tile
    end
    for xx = 0, Chapel.static.WIDTH - 1 do
        for yy = 0, Chapel.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, Structure) then
                ChapelAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end
    self:applyBuildingHeightMap()

    self.float = NotEnoughWorkersFloat:new(self.gx, self.gy, 0, -64)
end

function Chapel:destroy()
    _G.JobController:remove("Priest", self)
    self.float:destroy()
    if self.worker then
        self.worker:quitJob()
    end
    Structure.destroy(self)
end

function Chapel:onClick()
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("religion")
    ActionBar:showCathedralOptions(false)
    _G.playSfx(self, chapelFx["Chapel"], true, 1)
end

function Chapel:work(worker)
    worker.gx = self.gx + 3
    worker.gy = self.gy + 6
    worker:jobUpdate()
end

function Chapel:leave(sleepInsteadOfLeaving)
    if self.worker then
        _G.JobController:add("Priest", self)
        if sleepInsteadOfLeaving then
            self.worker:quitJob()
        else
            self.worker:leaveVillage()
        end
        self.worker = nil
        self.freeSpots = 1
        self.float:activate(sleepInsteadOfLeaving)
        return true
    end
end

function Chapel:join(worker)
    if self.health == -1 then
        _G.JobController:remove("Priest", self)
        worker:quitJob()
        return
    end
    if self.freeSpots == 1 then
        self.worker = worker
        worker.workplace = self
        self.freeSpots = self.freeSpots - 1
    end
    if self.freeSpots == 0 then
        self.float:deactivate()
    end
end

function Chapel:exitTowardsStockpile()
    self:findExitPointTo("Stockpile", function(found, path)
        if found then
            self:sendWorkerToBlessBuilding()
        else
            print("No path found to stockpile!")
        end
    end)
end

function Chapel:sendWorkerToBlessBuilding()
    if self.worker then
        self:respawnWorker(self.worker, "Looking to bless")
        self.worker:onExitPointFound()
    end
end

function Chapel:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    if data.worker then
        self.worker = _G.state:dereferenceObject(data.worker)
        self.worker.workplace = self
    end
    self.tile = quadArray[tiles + 1]
    Structure.render(self)
end

function Chapel:serialize()
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
    if self.worker then
        data.worker = _G.state:serializeObject(self.worker)
    end
    return data
end

function Chapel.static:deserialize(data)
    local obj = self:allocate()
    obj:load(data)
    return obj
end

return Chapel
