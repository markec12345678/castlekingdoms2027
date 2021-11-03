local Object = require("objects.Object")
local Structure = _G.class('Structure', Object)
function Structure:initialize(gx, gy, type)
    Object.initialize(self, gx, gy, type)
    _G.addObjectAt(self.cx, self.cy, self.i, self.o, self)
end
function Structure:render()
    if _G.object_mesh then
        local offset_x, offset_y = 0, 0
        if _G.quad_offset[self.tile] then
            offset_x, offset_y = _G.quad_offset[self.tile][1] or 0, _G.quad_offset[self.tile][2] or 0
        end
        local x, y = self.x + (self.offset_x or 0) + offset_x, self.y + (self.offset_y or 0) + offset_y
        local qx, qy, qw, qh = self.tile:getViewport()
        self.vert_id = _G.vertices_per_tile * (self.i + self.o * _G.chunk_width) + 1
        self.instancemesh = _G.object_mesh[self.cx][self.cy]
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh)
    end
end
return Structure
