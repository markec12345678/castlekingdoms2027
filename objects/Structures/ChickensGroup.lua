local Structure = require("objects.Structure")
local Object = require("objects.Object")
local Chicken = require("objects.Units.Chicken")
local tileQuads = require("objects.object_quads")

local ChickensGroup = _G.class("ChickensGroup", Structure)
function ChickensGroup:initialize(gx, gy, parent)
    self.parent = parent
    Structure.initialize(self, gx, gy, "ChickensGroup")
    self.tile = tileQuads["empty"]
    self.animation = nil
    self.animated = false
    self.chickenOne = nil
    self.chickenTwo = nil
    self.chickenThree = nil
    self.lastTimeUpdate = 0
    self.offsetX = -51
    self.offsetY = -87

    self:registerAsActiveEntity()
end

function ChickensGroup:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.animated = false
    data.craftingCycle = self.craftingCycle
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    if self.chickensOne then
        data.chickensOne = _G.state:serializeObject(self.chickensOne)
    end
    if self.chickenTwo then
        data.chickenTwo = _G.state:serializeObject(self.chickenTwo)
    end
    if self.chickenThree then
        data.chickenThree = _G.state:serializeObject(self.chickenThree)
    end

    data.parent = _G.state:serializeObject(self.parent)
    return data
end

function ChickensGroup.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.parent = _G.state:dereferenceObject(data.parent)
    if data.chickenOne then
        obj.chickenOne = _G.state:dereferenceObject(data.chickenOne)
    end
    if data.chickenTwo then
        obj.chickenTwo = _G.state:dereferenceObject(data.chickenTwo)
    end
    if data.chickenThree then
        obj.chickenThree = _G.state:dereferenceObject(data.chickenThree)
    end
    obj.parent.chickens = obj
    obj:registerAsActiveEntity()
    return obj
end

function ChickensGroup:animate()
    Structure.animate(self, _G.dt, true)

    self.lastTimeUpdate = self.lastTimeUpdate + _G.dt
    if (self.lastTimeUpdate > 1) and (self.parent.chickenCounter ~= 3) then
        if self.parent.chickenCounter == 0 then
            self.chickenOne = Chicken:new(self.parent.gx + 5, self.parent.gy + 3, "Brown", {gx = self.parent.gx + 1, gy = self.parent.gy + 1})
        elseif self.parent.chickenCounter == 1 then
            self.chickenTwo = Chicken:new(self.parent.gx + 2, self.parent.gy + 5, "White", {gx = self.parent.gx + 2, gy = self.parent.gy + 2})
        elseif self.parent.chickenCounter == 2 then
            self.chickenThree = Chicken:new(self.parent.gx + 5, self.parent.gy + 5, "Brown", {gx = self.parent.gx + 3, gy = self.parent.gy + 3})
        end
        self.parent.chickenCounter = self.parent.chickenCounter + 1
        self.lastTimeUpdate = 0
    end
    if self.parent.chickenCounter == 3 then
        self.lastTimeUpdate = 0
        self:deactivate()
    end
end

function ChickensGroup:activate()
    self.animated = false
    self.lastTimeUpdate = 0
    -- self:animate(_G.dt)
end

function ChickensGroup:deactivate()
    self.tile = tileQuads["empty"]
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
    self.animated = false
    self.craftingCycle = 0
end

return ChickensGroup
