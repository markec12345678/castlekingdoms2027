local Object = require("objects.Object")
local Structure = _G.class('Structure', Object)
function Structure:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
end
function Structure:render()
    if self.vert_id then
        return self:update_vertex()
    end
    if _G.object_mesh then
        local offset_x, offset_y = 0, 0
        if _G.quad_offset[self.tile] then
            offset_x, offset_y = _G.quad_offset[self.tile][1] or 0, _G.quad_offset[self.tile][2] or 0
        end
        local x, y = self.x + (self.offset_x or 0) + offset_x, self.y + (self.offset_y or 0) + offset_y
        local qx, qy, qw, qh = self.tile:getViewport()

        local new_vert = _G.getFreeVertexFromTile(self.cx, self.cy, self.i, self.o, true)
        if new_vert ~= false then
            self.vert_id = new_vert
            self.last_i, self.last_o = self.i, self.o
        else
            print("Structure did not receive Vertex for rendering, it should be of highest priority")
            love.event.quit()
        end
        self.instancemesh = _G.object_mesh[self.cx][self.cy]
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh)
    end
end
function Structure:destroy()
    if self.vert_id then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
    end
end
function Structure:update_vertex()
    if _G.object_mesh then
        local offset_x, offset_y = 0, 0
        if _G.quad_offset[self.tile] then
            offset_x, offset_y = _G.quad_offset[self.tile][1] or 0, _G.quad_offset[self.tile][2] or 0
        end
        local x, y = self.x + (self.offset_x or 0) + offset_x, self.y + (self.offset_y or 0) + offset_y
        local qx, qy, qw, qh = self.tile:getViewport()
        self.instancemesh = _G.object_mesh[self.cx][self.cy]
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh)
    end
end
function Structure:animate(dt, force_update)
    dt = dt or _G.dt
    if not self.animation or not self.animated then
        return
    end
    local updated = self.animation:update(dt) or force_update
    -- animation might have called a callback and deleted itself
    if not self.animation or not self.animated then
        return
    end
    if not self.instancemesh and _G.object_mesh then
        local offset_x, offset_y = 0, 0
        if quad_offset[self.animation:getQuad()] then
            offset_x, offset_y = quad_offset[self.animation:getQuad()][1] or 0,
                quad_offset[self.animation:getQuad()][2] or 0
        end
        local instancemesh = object_mesh[self.cx][self.cy]
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - _G.height_map[self.gx][self.gy])
        local qx, qy, qw, qh = quad:getViewport()
        self.vert_id = _G.getFreeVertexFromTile(self.cx, self.cy, self.i, self.o)
        if self.vert_id then
            self.instancemesh = instancemesh
            self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh)
        end
        return
    end
    if self.instancemesh and updated then
        local offset_x, offset_y = 0, 0
        if quad_offset[self.animation:getQuad()] then
            offset_x, offset_y = quad_offset[self.animation:getQuad()][1] or 0,
                quad_offset[self.animation:getQuad()][2] or 0
        end
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - _G.height_map[self.gx][self.gy])
        if quad then
            local qx, qy, qw, qh = quad:getViewport()
            self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh)
        end
        return
    end
end
return Structure
