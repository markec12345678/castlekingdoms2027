local active_entities, object_batch = ...
local Object = require('objects.Object')

    local Unit = class('Unit', Object)
        function Unit:initialize(cx,cy,i,o,x,y,type, no_path_state)
            Object.initialize(self,cx,cy,i,o,x,y,type)
            self.gx = chunk_width*self.cx+self.i
            self.gy = chunk_width*self.cy+self.o
            self.endx = 0
            self.endy = 0
            self.fx = self.gx*1000
            self.fy = self.gy*1000
            self.previous_cx = cx
            self.previous_cy = cx
            self.waypoint_x = 0
            self.waypoint_y = 0
            self.straight_walk_speed = 40
            self.diagonal_walk_speed = 25            
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
            self.no_path_state = no_path_state or "No path"
            self.lrcx, self.lrcy, self.lrx, self.lry = 0, 0, 0, 0            
			table.insert(active_entities,self)
        end
        function Unit:requestPath(xx, yy)							
            _G.finder:requestPath(self.gx, self.gy, xx, yy)
            self.endx = xx
            self.endy = yy
            self.path_state = "Waiting for path"
        end
        function Unit:pathfind()
            self.path = _G.finder:getPath(self.gx, self.gy, self.endx, self.endy)
            if self.path then
                if type(self.path) == "table" then
                    self.nd = {}
                    local first = true --skip the first node, because it's our position
                    local count = 0
                    for _, node in ipairs(self.path) do
                        if not first then
                            self.nd[count] = node
                            count = count + 1
                        else first = false end	
                    end
                    self.nd_len = count
                    self.waypoint_x = self.nd[0][1]--fixme If spawning right next to a tree, will throw error here
                    self.waypoint_y = self.nd[0][2]					
                    self.move_dir = "none"	
                    self.path_state = "Found"
                    return true
                elseif self.path == 2 then
                    self.path_state = "No path"
                    self.state = self.no_path_state
                end
            end		
        end
        function Unit:update_direction()
            local wx = self.waypoint_x
            local wy = self.waypoint_y
            local angle = math.atan2 (wy-(self.fy*0.001),wx-(self.fx*0.001))
            if angle < 0 then angle = angle+2*math.pi end
            angle = angle*(180/math.pi)
            angle = math.round (angle)						

            if angle<0 then angle = 360+angle end
            if (angle >= 135+22 and angle <= 225-22) then --direction is west 
                self.move_dir = "west"
                if self.previous_dir ~= "west" then
                    self:dir_sub_update(self.move_dir)
                end
            elseif (angle > 135-22 and angle < 135+22) then --direction is southwest
                self.move_dir = "southwest"
                if self.previous_dir ~= "southwest" then
                    self:dir_sub_update(self.move_dir)
                end
            elseif (angle > 225-22 and angle < 225+22) then --direction is northwest
                self.move_dir = "northwest"
                if self.previous_dir ~= "northwest" then
                    self:dir_sub_update(self.move_dir)
                end
            elseif (angle >= 225+22 and angle <= 315-22) then --direction is north
                self.move_dir = "north"
                if self.previous_dir ~= "north" then
                    self:dir_sub_update(self.move_dir)
                end
            elseif (angle >= 45+22 and angle <= 135-22) then --direction is south
                self.move_dir = "south"
                if self.previous_dir ~= "south" then
                    self:dir_sub_update(self.move_dir)
                end
            elseif ((angle >= 315+22 and angle <= 359) or (angle >=0 and angle <= 45-22)) then --direction is east
                self.move_dir = "east"
                if self.previous_dir ~= "east" then
                    self:dir_sub_update(self.move_dir)
                end
            elseif (angle > 45-22 and angle < 45+22) then--direction is southeast
                self.move_dir = "southeast"
                if self.previous_dir ~= "southeast" then
                    self:dir_sub_update(self.move_dir)
                end
            elseif (angle > 315-22 and angle < 315+22) then --direction is northeast
                self.move_dir = "northeast"
                if self.previous_dir ~= "northeast" then
                    self:dir_sub_update(self.move_dir)
                end
            end
            self.previous_dir = self.move_dir
        end			
        function Unit:move()
            if self.move_dir == "west" then
                self.fx = self.fx - self.straight_walk_speed
            elseif self.move_dir == "south" then
                self.fy = self.fy + self.straight_walk_speed
            elseif self.move_dir == "north" then
                self.fy = self.fy - self.straight_walk_speed
            elseif self.move_dir == "east" then
                self.fx = self.fx + self.straight_walk_speed
            elseif self.move_dir == "northwest" then
                self.fx = self.fx - self.diagonal_walk_speed
                self.fy = self.fy - self.diagonal_walk_speed
            elseif self.move_dir == "northeast" then
                self.fx = self.fx + self.diagonal_walk_speed
                self.fy = self.fy - self.diagonal_walk_speed
            elseif self.move_dir == "southwest" then 
                self.fx = self.fx - self.diagonal_walk_speed
                self.fy = self.fy + self.diagonal_walk_speed
            elseif self.move_dir == "southeast" then
                self.fx = self.fx + self.diagonal_walk_speed
                self.fy = self.fy + self.diagonal_walk_speed
            end						
            self.previous_cx, self.previous_cy = self.cx,self.cy 
            self.gx,self.gy= self.fx*0.001,self.fy*0.001
            self.cx,self.cy = math.floor((self.gx)/chunk_width), math.floor((self.gy)/chunk_width)
            
            local xx,yy
            xx, yy = (math.round(self.gx))%(chunk_width),(math.round(self.gy))%(chunk_width)
            if not isObjectAt(self.cx, self.cy, xx, yy, self) then
                addObjectAt(self.cx, self.cy, xx, yy, self)
            end
            if isObjectAt(self.cx, self.cy, self.originalx, self.originaly, self)
            and (self.originalx ~= math.round(self.gx)%chunk_width or self.originaly ~= math.round(self.gy)%chunk_width)
            then
                removeObjectAt(self.cx, self.cy, self.originalx, self.originaly, self)
            end
            if self.previous_cx ~= self.cx or self.previous_cy ~= self.cy then						
                if not isObjectAt(self.cx, self.cy, xx, yy, self) then
                    addObjectAt(self.cx, self.cy, xx, yy, self)	
                end
                self.qid = object_batch[self.cx][self.cy]:add(self.animation:getFrameInfo(self.x, self.y))
            end					
            self.lrcx, self.lrcy, self.lrx, self.lry = self.cx,self.cy,xx,yy			
            self.x = IsoX + ((self.fx*0.001)%chunk_width - (self.fy*0.001)%chunk_width) * tile_width  * 0.5 -31 --fixme magic numbers?
            self.y = IsoY + ((self.fx*0.001)%chunk_width + (self.fy*0.001)%chunk_width) * tile_height * 0.5 -50
            if self.originalx ~= math.round(self.gx)%chunk_width or self.originaly ~= math.round(self.gy)%chunk_width then
                self.originalx = math.round(self.gx)%chunk_width
                self.originaly = math.round(self.gy)%chunk_width
            end
        end

return Unit