local object_batch, active_objects, tile_quads, object = ...
local Object = require("objects.Object")

local quad_offset = require('objects.quad_offset')
local fr_shrub_1 = indexQuads("tree_shrub1", 25, nil, true)
local fr_shrub_2 = indexQuads("tree_shrub2", 25, nil, true)

local Shrub = class('Shrub', Object)
function Shrub:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    self.gx = chunk_width * self.cx + self.i
    self.gy = chunk_width * self.cy + self.o
    self.health = 1
    if not type then
        if love.math.random(0, 1) == 0 then
            type = "Tall shrub"
        else
            type = "Short shrub"
        end
    end
    if type == "Tall shrub" then
        self.animation = anim.newAnimation(fr_shrub_1, 0.1)
        self.offset_x = -32
        self.offset_y = -57
    elseif type == "Short shrub" then
        self.animation = anim.newAnimation(fr_shrub_2, 0.1)
        self.offset_x = -11
        self.offset_y = -32
    end
    self.chop = false
    self.animated = true
    self.marked = false
    self.tile = nil
    self.active = false
    self.update_timer = 0
    self.chunk_key = false
    if _G.state.chunk_objects[self.cx][self.cy] == nil then
        _G.state.chunk_objects[self.cx][self.cy] = {}
    end
    _G.state.chunk_objects[self.cx][self.cy][self] = self
    addObjectAt(self.cx, self.cy, self.i, self.o, self)
    _G.buildingheightmap[self.cx][self.cy][self.i - 1][self.o] = 13.5
end
function Shrub:animate()
    local updated = false
    if _G.state.scale_x > 0.6 then
        updated = self.animation:update(dt)
    end
    if self.instancemesh and updated then
        self.last_updated = 0
        local offset_x, offset_y = 0, 0
        if quad_offset[self.animation:getQuad()] then
            offset_x, offset_y = quad_offset[self.animation:getQuad()][1] or 0,
                quad_offset[self.animation:getQuad()][2] or 0
        end
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - _G.state.map.walking_heightmap[self.gx][self.gy])
        local qx, qy, qw, qh = quad:getViewport()
        local elevation_offset_y = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevation_offset_y = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        y = y - elevation_offset_y
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh, 1)
        return
    end
    if not self.instancemesh and _G.state.object_mesh then
        local offset_x, offset_y = 0, 0
        if quad_offset[self.animation:getQuad()] then
            offset_x, offset_y = quad_offset[self.animation:getQuad()][1] or 0,
                quad_offset[self.animation:getQuad()][2] or 0
        end
        local instancemesh = _G.state.object_mesh[self.cx][self.cy]
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - _G.state.map.walking_heightmap[self.gx][self.gy])
        local qx, qy, qw, qh = quad:getViewport()
        local elevation_offset_y = 0
        if _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] then
            elevation_offset_y = _G.state.map.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        y = y - elevation_offset_y
        self.vert_id = _G.getFreeVertexFromTile(self.cx, self.cy, self.i, self.o)
        if not self.vert_id then
            self.to_be_removed = true
            return
        end
        self.instancemesh = instancemesh
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh, 1)
    end
end
function Shrub:cut()
    if self.health > 0 then
        self.offset_x = self.base_offset_x + 4
        self.offset_timer = 0
        self.health = self.health - 1
    elseif self.health <= 0 then
        self:destroy()
    end
end
function Shrub:serialize()
    local data = {}
    data.object = Object.serialize(self)
    data.class = Shrub.name
    data.gx = self.gx
    data.gy = self.gy
    data.health = self.health
    data.chop = self.chop
    data.animated = self.animated
    data.marked = self.marked
    data.tile = self.tile
    data.active = self.active
    data.update_timer = self.update_timer
    data.chunk_key = self.chunk_key
    return data
end
function Shrub.static:deserialize(data)
    local obj = self:new(data.object.gx, data.object.gy, data.object.type)
    Object.deserialize(self, data)
    return obj
end

return Shrub
