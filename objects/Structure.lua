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
return Structure
