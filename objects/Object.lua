local Object = class('Object')
function Object:initialize(gx, gy, type)
    self.i = (gx) % (chunk_width)
    self.o = (gy) % (chunk_width)
    self.cx = math.floor(gx / chunk_width)
    self.cy = math.floor(gy / chunk_width)
    self.x = IsoX + (self.i - self.o) * tile_width * 0.5
    self.y = IsoY + (self.i + self.o) * tile_height * 0.5
    self.gx = gx
    self.gy = gy
    self.type = type
    self.qid = 0
    self.to_be_deleted = false
end
function Object:is_visible_on_screen()
    if not (self.x + (self.cx - self.cy) * chunk_width * tile_width * 0.5 < TopLeftX or self.x + (self.cx - self.cy) *
        chunk_width * tile_width * 0.5 > BottomRightX or self.y + (self.cx + self.cy) * chunk_height * tile_height * 0.5 <
        TopLeftY or self.y + (self.cx + self.cy) * chunk_height * tile_height * 0.5 > BottomRightY) then
        return true
    end
    return false
end
function Object:update()
end
function Object:render()
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
            print("Object did not receive Vertex for rendering, it should be of highest priority")
            love.event.quit()
        end
        self.instancemesh = _G.object_mesh[self.cx][self.cy]
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh)
    end
end
function Object:destroy()
    if self.vert_id then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
    end
end
function Object:update_vertex()
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
return Object
