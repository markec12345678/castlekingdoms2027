local tileQuads = require("objects.object_quads")
local anim = require("libraries.anim8")
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local frames = _G.indexQuads("float_inaccessible", 16)
local sleepFrames = _G.indexQuads("sleep_float", 8)

local NotEnoughWorkersFloat = _G.class("NotEnoughWorkersFloat", Object)
function NotEnoughWorkersFloat:initialize(gx, gy, offsetX, offsetY, isDeserialized)
    Object.initialize(self, gx, gy)
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
    self.animated = true
    self.baseOffsetX, self.baseOffsetY = offsetX, offsetY
    self.offsetX = offsetX
    self.offsetY = offsetY
    self.workersAnimation = anim.newAnimation(frames, 0.065, nil, "NotEnoughWorkersFloat")
    self.sleepAnimation = anim.newAnimation(sleepFrames, 0.065, nil, "SleepFloat")
    self.animation = self.workersAnimation
    self.tile = tileQuads["float_inaccessible (1)"]
    if not isDeserialized then
        self:registerAsActiveEntity()
    end
end

function NotEnoughWorkersFloat:deactivate()
    self.animation:pause()
    self.animated = false
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
end

function NotEnoughWorkersFloat:destroy()
    self.toBeDeleted = true
    Object.destroy(self)
end

function NotEnoughWorkersFloat:activate(sleep)
    if sleep then
        self.animation = self.sleepAnimation
        self.offsetX, self.offsetY = self.baseOffsetX - 60, self.baseOffsetY - 30
    else
        self.offsetX, self.offsetY = self.baseOffsetX, self.baseOffsetY
        self.animation = self.workersAnimation
    end
    self.animation:resume()
    self.animated = true
    self.needNewVertAsap = true
end

function NotEnoughWorkersFloat:animate(dt)
    Structure.animate(self, love.timer.getDelta(), true)
end

function NotEnoughWorkersFloat:serialize()
    local data = {
        animated = self.animated,
        offsetX = self.offsetX,
        offsetY = self.offsetY,
    }
    local objectData = Object.serialize(self)
    for k, v in pairs(objectData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    return data
end

function NotEnoughWorkersFloat.static:deserialize(load)
    local obj = NotEnoughWorkersFloat:new(load.gx, load.gy, load.offsetX, load.offsetY, true)
    obj.animated = load.animated
    return obj
end

return NotEnoughWorkersFloat
