local tileQuads = require("objects.object_quads")
local anim = require("libraries.anim8")
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local frames = _G.indexQuads("smoke_30_loop", 16)

local SmokeLoop = _G.class("SmokeLoop", Object)
function SmokeLoop:initialize(gx, gy, offsetX, offsetY, isDeserialized)
    Object.initialize(self, gx, gy)
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
    self.animated = true
    self.offsetX = offsetX
    self.offsetY = offsetY
    self.animation = anim.newAnimation(frames, 0.065, nil, "SmokeLoop")
    self.tile = tileQuads["smoke_30_loop (1)"]
    if not isDeserialized then
        self:registerAsActiveEntity()
    end
end

function SmokeLoop:deactivate()
    self.animation:pause()
    self.animated = false
    if self.instancemesh then
        _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
        self.instancemesh = nil
    end
end

function SmokeLoop:destroy()
    Object.destroy(self)
end

function SmokeLoop:activate()
    self.animation:resume()
    self.animated = true
    self.needNewVertAsap = true
end

function SmokeLoop:animate(dt)
    Structure.animate(self, love.timer.getDelta(), true)
end

function SmokeLoop:serialize()
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

function SmokeLoop.static:deserialize(load)
    local obj = SmokeLoop:new(load.gx, load.gy, load.offsetX, load.offsetY, true)
    obj.animated = load.animated
    return obj
end

return SmokeLoop
