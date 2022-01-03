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
        local elevation_offset_y = 0
        if _G.heightmap[self.cx][self.cy][self.i][self.o] then
            elevation_offset_y = _G.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        local x, y = self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - elevation_offset_y
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
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh, 1)
    end
end
function Object:render_alias()
    if self.vert_id then
        return self:update_vertex()
    end
    if _G.object_mesh then
        local offset_x, offset_y = 0, 0
        if _G.quad_offset[self.tile] then
            offset_x, offset_y = _G.quad_offset[self.tile][1] or 0, _G.quad_offset[self.tile][2] or 0
        end
        local elevation_offset_y = 0
        if _G.heightmap[self.cx][self.cy][self.i][self.o] then
            elevation_offset_y = _G.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        local x, y = self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - elevation_offset_y
        local qx, qy, qw, qh = self.tile:getViewport()
        local cx = math.floor((self.gx - 1) / chunk_width)
        local cy = math.floor((self.gy - 1) / chunk_width)
        local xx = (self.gx - 1) % (chunk_width)
        local yy = (self.gy - 1) % (chunk_width)
        local new_vert = _G.getFreeVertexFromTile(cx, cy, xx, yy, true)
        if new_vert ~= false then
            self.vert_id = new_vert
            self.last_i, self.last_o = self.i, self.o
        else
            print("Object did not receive Vertex for rendering, it should be of highest priority")
            love.event.quit()
        end
        self.instancemesh = _G.object_mesh[self.cx][self.cy]
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh, 1)
    end
end
function Object:destroy()
    if self.vert_id then
        _G.freeVertexFromTile(self.cx, self.cy, self.vert_id)
    end
    _G.removeObjectAt(self.cx, self.cy, self.i, self.o, self)
    _G.chunk_objects[self.cx][self.cy][self] = nil
    self = nil
end
function Object:update_vertex()
    if _G.object_mesh then
        local offset_x, offset_y = 0, 0
        if _G.quad_offset[self.tile] then
            offset_x, offset_y = _G.quad_offset[self.tile][1] or 0, _G.quad_offset[self.tile][2] or 0
        end
        local elevation_offset_y = 0
        if _G.heightmap[self.cx][self.cy][self.i][self.o] then
            elevation_offset_y = _G.heightmap[self.cx][self.cy][self.i][self.o] * 2
        end
        local x, y = self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - elevation_offset_y
        local qx, qy, qw, qh = self.tile:getViewport()
        self.instancemesh = _G.object_mesh[self.cx][self.cy]
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh, 1)
    end
end
return Object
