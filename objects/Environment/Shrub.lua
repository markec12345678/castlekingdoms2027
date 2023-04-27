local _, _, _, _ = ...
local Object = require("objects.Object")

local quadOffset = require('objects.quad_offset')
local frShrub_1 = _G.indexQuads("tree_shrub1", 25, nil, true)
local frShrub_2 = _G.indexQuads("tree_shrub2", 25, nil, true)

local Shrub = _G.class('Shrub', Object)
function Shrub:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    self.health = 1
    if not type then
        if love.math.random(0, 1) == 0 then
            type = "Tall shrub"
        else
            type = "Short shrub"
        end
    end
    if type == "Tall shrub" then
        self.animation = _G.anim.newAnimation(frShrub_1, 0.1)
        self.offsetX = -32
        self.offsetY = -57
    elseif type == "Short shrub" then
        self.animation = _G.anim.newAnimation(frShrub_2, 0.1)
        self.offsetX = -11
        self.offsetY = -32
    end
    self.chop = false
    self.animated = true
    self.marked = false
    self.tile = nil
    self.active = false
    self.updateTimer = 0
    self.chunkKey = false
    if _G.state.chunkObjects[self.cx][self.cy] == nil then
        _G.state.chunkObjects[self.cx][self.cy] = {}
    end
    _G.state.chunkObjects[self.cx][self.cy][self] = self
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
    _G.state.map.buildingheightmap[self.cx][self.cy][self.i - 1][self.o] = 13.5
end

function Shrub:animate()
    local updated = false
    if _G.state.scaleX > 0.6 then
        updated = self.animation:update(_G.dt)
    end
    if self.instancemesh and updated then
        self.lastUpdated = 0
        local offsetX, offsetY = 0, 0
        if quadOffset[self.animation:getQuad()] then
            offsetX, offsetY = quadOffset[self.animation:getQuad()][1] or 0,
                quadOffset[self.animation:getQuad()][2] or 0
        end
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offsetX or 0) + offsetX,
            self.y + (self.offsetY or 0) + offsetY - _G.state.map.walkingHeightmap[self.gx][self.gy])
        local qx, qy, qw, qh = quad:getViewport()
        local elevationOffsetY = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        y = y - elevationOffsetY
        self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, 1)
        return
    end
    if not self.instancemesh and _G.state.objectMesh then
        local offsetX, offsetY = 0, 0
        if quadOffset[self.animation:getQuad()] then
            offsetX, offsetY = quadOffset[self.animation:getQuad()][1] or 0,
                quadOffset[self.animation:getQuad()][2] or 0
        end
        local instancemesh = _G.state.objectMesh[self.cx][self.cy]
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offsetX or 0) + offsetX,
            self.y + (self.offsetY or 0) + offsetY - _G.state.map.walkingHeightmap[self.gx][self.gy])
        local qx, qy, qw, qh = quad:getViewport()
        local elevationOffsetY = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevationOffsetY = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        y = y - elevationOffsetY
        self.vertId = _G.getFreeVertexFromTile(self.cx, self.cy, self.i, self.o)
        if not self.vertId then
            self.toBeRemoved = true
            return
        end
        self.instancemesh = instancemesh
        self.instancemesh:setVertex(self.vertId, x, y, qx, qy, qw, qh, 1)
    end
end

function Shrub:cut()
    if self.health > 0 then
        self.offsetX = self.baseOffsetX + 4
        self.offsetTimer = 0
        self.health = self.health - 1
    elseif self.health <= 0 then
        self:destroy()
    end
end

function Shrub:serialize()
    local data = {}
    local objectData = Object.serialize(self)
    for k, v in pairs(objectData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.gx = self.gx
    data.gy = self.gy
    data.health = self.health
    data.chop = self.chop
    data.animated = self.animated
    data.marked = self.marked
    data.tile = self.tile
    data.active = self.active
    data.updateTimer = self.updateTimer
    data.chunkKey = self.chunkKey
    return data
end

function Shrub.static:deserialize(data)
    local obj = self:new(data.gx, data.gy, data.type)
    Object.deserialize(obj, data)
    return obj
end

return Shrub
