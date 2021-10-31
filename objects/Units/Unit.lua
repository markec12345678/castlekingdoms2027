local active_entities, object_batch = ...
local Object = require('objects.Object')

local Unit = class('Unit', Object)
function Unit:initialize(gx, gy, type, no_path_state)
    Object.initialize(self, gx, gy, type)
    self.endx = 0
    self.endy = 0
    self.fx = self.gx * 1000
    self.fy = self.gy * 1000
    self.previous_fx, self.previous_fy = self.fx, self.fy
    self.previous_cx = cx
    self.previous_cy = cx
    self.has_move_dir = false
    self.waypoint_x = nil
    self.waypoint_y = nil
    self.straight_walk_speed = 2400
    self.diagonal_walk_speed = 1500
    self.originalx = self.gx
    self.originaly = self.gy
    self.nd = {}
    self.nd_len = 0
    self.path = 0
    self.path_state = "None"
    self.move_dir = "none"
    self.update_dir = true
    self.previous_dir = "none"
    self.animated = true
    self.changed_chunks = 0
    self.no_path_state = no_path_state or "No path"
    self.lrcx, self.lrcy, self.lrx, self.lry = 0, 0, 0, 0
    addObjectAt(self.cx, self.cy, self.i, self.o, self)
    table.insert(active_entities, self)
    self:calculate_position()
end
function Unit:animate()
    local updated = self.animation:update(_G.dt)
    self.vert_id = self.i + self.o * chunk_width + 1
    updated = updated or self.previous_vert_id ~= self.vert_id
    if self.instancemesh then
        if self.last_chunk_instancemesh and self.changed_chunks > 0 then
            self.changed_chunks = self.changed_chunks - 1
            if self.changed_chunks == 0 then
                self.last_chunk_instancemesh:setVertex(self.last_chunk_vert_id)
                self.last_chunk_instancemesh = nil
            end
        elseif self.previous_vert_id ~= self.vert_id then
            self.instancemesh:setVertex(self.previous_vert_id)
        end
    end
    self.previous_vert_id = self.vert_id
    self.previous_fx, self.previous_fy = self.fx, self.fy
    updated = updated or
                  ((self.previous_fx ~= self.fx or self.previous_fy ~= self.fy) and Object.is_visible_on_screen(self))
    if self.instancemesh and updated then
        self.last_updated = 0
        local offset_x, offset_y = 0, 0
        if quad_offset[self.animation:getQuad()] then
            offset_x, offset_y = quad_offset[self.animation:getQuad()][1] or 0,
                quad_offset[self.animation:getQuad()][2] or 0
        end
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - _G.height_map[self.gx][self.gy])
        local qx, qy, qw, qh = quad:getViewport()
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh)
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
        self.vert_id = (self.i + self.o * chunk_width) + 1
        self.instancemesh = instancemesh
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh)
    end
end
function Unit:requestPath(xx, yy)
    _G.finder:requestPath(self.gx, self.gy, xx, yy)
    self.has_move_dir = false
    self.endx = xx
    self.endy = yy
    self.path_state = "Waiting for path"
end
function Unit:pathfind()
    if self.endx >= _G.chunks_wide * _G.chunk_width or self.endy >= _G.chunks_high * _G.chunk_height or self.endx < 0 or
        self.endy < 0 then
        self.path_state = "No path"
        self.state = self.no_path_state
        print("AVOIDED DISASTER, TODO: RETURN RESULT")
        return
    end
    -- self.path = _G.finder:getPath(math.round(self.gx), math.round(self.gy), self.endx, self.endy)
    self.path = _G.finder:getPath(self.gx, self.gy, self.endx, self.endy)
    if self.path then
        if type(self.path) == "table" then
            self.nd = {}
            local first, second = true, false -- skip the first node, because it's our position
            local count = 0
            for _, node in ipairs(self.path) do
                if not first then
                    self.nd[count] = node
                    count = count + 1
                    second = true
                else
                    self.nd[-1] = node
                    first = false
                end
            end
            self.nd_len = count
            if not second then
                self.waypoint_x = self.nd[-1][1] -- fixme If spawning right next to a tree, will throw error here
                self.waypoint_y = self.nd[-1][2]
            else
                self.waypoint_x = self.nd[0][1] -- fixme If spawning right next to a tree, will throw error here
                self.waypoint_y = self.nd[0][2]
            end
            self.move_dir = "none"
            self.path_state = "Found"
            return true
        elseif self.path == 2 then
            self.path_state = "No path"
            self.state = self.no_path_state
        end
    end
end
function Unit:calculate_position()
    -- slightly magic numbers?
    self.x = IsoX + ((self.fx * 0.001) % chunk_width - (self.fy * 0.001) % chunk_width) * tile_width * 0.5 - 31
    self.y = IsoY + ((self.fx * 0.001) % chunk_width + (self.fy * 0.001) % chunk_width) * tile_height * 0.5 - 50
    self.i, self.o = self.lrx, self.lry
end
function Unit:update_direction()
    local wx = self.waypoint_x
    local wy = self.waypoint_y
    local angle = math.atan2(wy - (self.fy * 0.001), wx - (self.fx * 0.001))
    if angle < 0 then
        angle = angle + 2 * math.pi
    end
    angle = angle * (180 / math.pi)
    angle = math.round(angle)

    if angle < 0 then
        angle = 360 + angle
    end
    if (angle >= 135 + 22 and angle <= 225 - 22) then -- direction is west 
        self.move_dir = "west"
        if self.previous_dir ~= "west" then
            self:update_position()
            self:dir_sub_update()
        end
    elseif (angle > 135 - 22 and angle < 135 + 22) then -- direction is southwest
        self.move_dir = "southwest"
        if self.previous_dir ~= "southwest" then
            self:update_position()
            self:dir_sub_update()
        end
    elseif (angle > 225 - 22 and angle < 225 + 22) then -- direction is northwest
        self.move_dir = "northwest"
        if self.previous_dir ~= "northwest" then
            self:update_position()
            self:dir_sub_update()
        end
    elseif (angle >= 225 + 22 and angle <= 315 - 22) then -- direction is north
        self.move_dir = "north"
        if self.previous_dir ~= "north" then
            self:update_position()
            self:dir_sub_update()
        end
    elseif (angle >= 45 + 22 and angle <= 135 - 22) then -- direction is south
        self.move_dir = "south"
        if self.previous_dir ~= "south" then
            self:update_position()
            self:dir_sub_update()
        end
    elseif ((angle >= 315 + 22 and angle <= 359) or (angle >= 0 and angle <= 45 - 22)) then -- direction is east
        self.move_dir = "east"
        if self.previous_dir ~= "east" then
            self:update_position()
            self:dir_sub_update()
        end
    elseif (angle > 45 - 22 and angle < 45 + 22) then -- direction is southeast
        self.move_dir = "southeast"
        if self.previous_dir ~= "southeast" then
            self:update_position()
            self:dir_sub_update()
        end
    elseif (angle > 315 - 22 and angle < 315 + 22) then -- direction is northeast
        self.move_dir = "northeast"
        if self.previous_dir ~= "northeast" then
            self:update_position()
            self:dir_sub_update()
        end
    end
    self.previous_dir = self.move_dir
end
function Unit:update_position()
    self.previous_cx, self.previous_cy = self.cx, self.cy
    self.gx, self.gy = math.round(self.fx * 0.001), math.round(self.fy * 0.001)
    self.cx, self.cy = math.floor((self.gx) / chunk_width), math.floor((self.gy) / chunk_width)

    local xx, yy = (math.round(self.gx)) % (chunk_width), (math.round(self.gy)) % (chunk_width)
    self.i, self.o = xx, yy
    if not isObjectAt(self.cx, self.cy, xx, yy, self) then
        addObjectAt(self.cx, self.cy, xx, yy, self)
    end
    if isObjectAt(self.cx, self.cy, self.originalx, self.originaly, self) and
        (self.originalx ~= math.round(self.gx) % chunk_width or self.originaly ~= math.round(self.gy) % chunk_width) then
        removeObjectAt(self.cx, self.cy, self.originalx, self.originaly, self)
    end
    if self.previous_cx ~= self.cx or self.previous_cy ~= self.cy then
        if not isObjectAt(self.cx, self.cy, xx, yy, self) then
            addObjectAt(self.cx, self.cy, xx, yy, self)
        end
        self.last_chunk_vert_id = self.vert_id
        self.last_chunk_instancemesh = self.instancemesh
        self.vert_id = xx + yy * chunk_width + 1
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - _G.height_map[self.gx][self.gy])
        local qx, qy, qw, qh = quad:getViewport()
        self.instancemesh = object_mesh[self.cx][self.cy]
        self.vert_data = {x, y, qx, qy, qw, qh}
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh)
        self.changed_chunks = 1
        -- :add
    end
    self.lrcx, self.lrcy, self.lrx, self.lry = self.cx, self.cy, xx, yy
    if self.originalx ~= math.round(self.gx) % chunk_width or self.originaly ~= math.round(self.gy) % chunk_width then
        self.originalx = math.round(self.gx) % chunk_width
        self.originaly = math.round(self.gy) % chunk_width
    end
    -- self.gx, self.gy = self.fx * 0.001, self.fy * 0.001
    self.gx, self.gy = math.round(self.fx * 0.001), math.round(self.fy * 0.001)
    -- self.gx, self.gy = self.cx * chunk_width + xx, self.cy * chunk_width + yy
end
function Unit:move(special)
    if not self.has_move_dir then
        self:dir_sub_update()
        self.has_move_dir = true
    end
    if self.move_dir == "west" then
        self.fx = self.fx - _G.dt * self.straight_walk_speed
        if self.fx < self.waypoint_x * 1000 then
            self.fx = self.waypoint_x * 1000
        end
    elseif self.move_dir == "south" then
        self.fy = self.fy + _G.dt * self.straight_walk_speed
        if self.fy > self.waypoint_y * 1000 then
            self.fy = self.waypoint_y * 1000
        end
    elseif self.move_dir == "north" then
        self.fy = self.fy - _G.dt * self.straight_walk_speed
        if self.fy < self.waypoint_y * 1000 then
            self.fy = self.waypoint_y * 1000
        end
    elseif self.move_dir == "east" then
        self.fx = self.fx + _G.dt * self.straight_walk_speed
        if self.fx > self.waypoint_x * 1000 then
            self.fx = self.waypoint_x * 1000
        end
    elseif self.move_dir == "northwest" then
        self.fx = self.fx - _G.dt * self.diagonal_walk_speed
        self.fy = self.fy - _G.dt * self.diagonal_walk_speed
        if self.fx < self.waypoint_x * 1000 then
            self.fx = self.waypoint_x * 1000
        end
        if self.fy < self.waypoint_y * 1000 then
            self.fy = self.waypoint_y * 1000
        end
    elseif self.move_dir == "northeast" then
        self.fx = self.fx + _G.dt * self.diagonal_walk_speed
        self.fy = self.fy - _G.dt * self.diagonal_walk_speed
        if self.fx > self.waypoint_x * 1000 then
            self.fx = self.waypoint_x * 1000
        end
        if self.fy < self.waypoint_y * 1000 then
            self.fy = self.waypoint_y * 1000
        end
    elseif self.move_dir == "southwest" then
        self.fx = self.fx - _G.dt * self.diagonal_walk_speed
        self.fy = self.fy + _G.dt * self.diagonal_walk_speed
        if self.fx < self.waypoint_x * 1000 then
            self.fx = self.waypoint_x * 1000
        end
        if self.fy > self.waypoint_y * 1000 then
            self.fy = self.waypoint_y * 1000
        end
    elseif self.move_dir == "southeast" then
        self.fx = self.fx + _G.dt * self.diagonal_walk_speed
        self.fy = self.fy + _G.dt * self.diagonal_walk_speed
        if self.fx > self.waypoint_x * 1000 then
            self.fx = self.waypoint_x * 1000
        end
        if self.fy > self.waypoint_y * 1000 then
            self.fy = self.waypoint_y * 1000
        end
    end
    self.previous_cx, self.previous_cy = self.cx, self.cy
    self.gx, self.gy = math.floor(self.fx * 0.001), math.floor(self.fy * 0.001)
    self.cx, self.cy = math.floor((self.gx) / chunk_width), math.floor((self.gy) / chunk_width)

    local xx, yy = (self.gx) % (chunk_width), (self.gy) % (chunk_width)
    self.i, self.o = xx, yy
    if not isObjectAt(self.cx, self.cy, xx, yy, self) then
        addObjectAt(self.cx, self.cy, xx, yy, self)
    end
    if isObjectAt(self.cx, self.cy, self.originalx, self.originaly, self) and
        (self.originalx ~= self.gx % chunk_width or self.originaly ~= self.gy % chunk_width) then
        removeObjectAt(self.cx, self.cy, self.originalx, self.originaly, self)
    end
    if self.previous_cx ~= self.cx or self.previous_cy ~= self.cy then
        if not isObjectAt(self.cx, self.cy, xx, yy, self) then
            addObjectAt(self.cx, self.cy, xx, yy, self)
        end
        self.last_chunk_vert_id = self.vert_id
        self.last_chunk_instancemesh = self.instancemesh
        local quad, x, y, _, _, _, _, _, _, _ = self.animation:getFrameInfo(self.x + (self.offset_x or 0) + offset_x,
            self.y + (self.offset_y or 0) + offset_y - _G.height_map[self.gx][self.gy])
        local qx, qy, qw, qh = quad:getViewport()
        self.vert_id = (self.i + self.o * chunk_width) + 1
        self.instancemesh = object_mesh[self.cx][self.cy]
        self.vert_data = {x, y, qx, qy, qw, qh}
        self.instancemesh:setVertex(self.vert_id, x, y, qx, qy, qw, qh)
        self.changed_chunks = 1
        -- self.qid = object_batch[self.cx][self.cy]:add(self.animation:getFrameInfo(self.x, self.y))
    end
    self.lrcx, self.lrcy, self.lrx, self.lry = self.cx, self.cy, xx, yy
    self:calculate_position()
    if self.originalx ~= self.gx % chunk_width or self.originaly ~= self.gy % chunk_width then
        self.originalx = self.gx % chunk_width
        self.originaly = self.gy % chunk_width
    end
end

return Unit
