local object,object_batch, active_entities, tile_quads = ...
local Object = require("objects.Object")
		local Woodcutter = class('Woodcutter', Object)
			function Woodcutter:initialize(cx,cy,i,o,x,y,type)
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
				self.state = 'Looking to chop tree'
				self.path = 0
				self.straight_walk_speed = 40
				self.diagonal_walk_speed = 25
				self.originalx = i 
				self.originaly = o
				self.nd = newAutotable(1)
				self.nd_len = 0
				self.marked = 0
				self.path = 0
				self.count = 1
				self.timr = 0
				self.move_dir = "none"
				self.update_dir = true
				self.previous_dir = "none"
				self.target_tree = 0
				self.cut = function() 
					if self.state == "Cutting down" then
					print("Trying to cut down "..self.target_tree.type)
					local tree_progress = 0
					if self.target_tree.type == "Pine tree" then
					tree_progress = self.target_tree:cut() else 
					self.state = "Looking to chop tree"	
						self.move_dir = "none"
						end
					if tree_progress == 2 then
						--self.animation = anim.newAnimation(self.fr_walking_north,0.15)
						self.i = (self.fx*0.001)%chunk_width
						self.o = (self.fy*0.001)%chunk_width
						self.state = "Looking to chop tree"	
						self.move_dir = "none"
						self.count = 1
						tree_progress = 3			
						end
						else print("State", self.state)
						end
				end
				self.fr_walking_east = {
					tile_quads[2201],tile_quads[2202],tile_quads[2203],
					tile_quads[2204],tile_quads[2205],tile_quads[2206],
					tile_quads[2207],tile_quads[2208]
				}
				self.fr_walking_north = {
					tile_quads[2209],tile_quads[2210],tile_quads[2211],
					tile_quads[2212],tile_quads[2213],tile_quads[2214],
					tile_quads[2215],tile_quads[2216]
				}
				self.fr_walking_northeast = {
					tile_quads[2217],tile_quads[2218],tile_quads[2219],
					tile_quads[2220],tile_quads[2221],tile_quads[2222],
					tile_quads[2223],tile_quads[2224]
				}
				self.fr_walking_northwest = {
					tile_quads[2225],tile_quads[2226],tile_quads[2227],
					tile_quads[2228],tile_quads[2229],tile_quads[2230],
					tile_quads[2231],tile_quads[2232]
				}
				self.fr_walking_south = {
					tile_quads[2233],tile_quads[2234],tile_quads[2235],
					tile_quads[2236],tile_quads[2237],tile_quads[2238],
					tile_quads[2239],tile_quads[2240]
				}
				self.fr_walking_southeast = {
					tile_quads[2241],tile_quads[2242],tile_quads[2243],
					tile_quads[2244],tile_quads[2245],tile_quads[2246],
					tile_quads[2247],tile_quads[2248]
				}
				self.fr_walking_southwest = {
					tile_quads[2249],tile_quads[2250],tile_quads[2251],
					tile_quads[2252],tile_quads[2253],tile_quads[2254],
					tile_quads[2255],tile_quads[2256]
				}
				self.fr_walking_west = {
					tile_quads[2257],tile_quads[2258],tile_quads[2259],
					tile_quads[2260],tile_quads[2261],tile_quads[2262],
					tile_quads[2263],tile_quads[2264]
				}
				self.fr_cutting_northeast = { --warning actually north --TODO why not name it north then?
					tile_quads[2056],tile_quads[2057],tile_quads[2058],
					tile_quads[2059],tile_quads[2060],tile_quads[2061],
					tile_quads[2062],tile_quads[2063]
				}
				self.animation = anim.newAnimation(self.fr_walking_west,10)
				table.insert(active_entities,self)
				end 
			function Woodcutter:pathfind(xx,yy)
				--print("Called",self.gx, self.gy, xx, yy)
				-- -- Calculates the path, and its length
				self.path = _G.finder:getPath(self.gx, self.gy, xx, yy)
				if self.path then
				  	self.nd = {}
					local first = true --skip the first node, because it's our position
					--print("Printing steps:")
					local countt = 0
					for node, count in self.path:nodes() do
						--print(('Step: %d - x: %d - y: %d'):format(count,node._x,node._y))
						if not first then
							self.nd[countt] = node
							countt = countt + 1
						else first = false end	
					end
					self.nd_len = countt
					--print("Length",self.nd_len,self.count)
					self.waypoint_x = self.nd[0]._x 
				 	self.waypoint_y = self.nd[0]._y
					--print("Waypoint: "..self.waypoint_x,self.waypoint_y)						
				 	self.move_dir = "none"	
				else print("Path not found!")
					self.state = "No trees" end			
			end
			function Woodcutter:check_trees(cx,cy)
				local chunkx,chunky = cx or self.cx,cy or self.cy 
				local closest_object, closest_distance = nil,10000000
				if _G.chunk_objects[chunkx][chunky] then
					for index, obj in ipairs ( _G.chunk_objects[chunkx][chunky] ) do 
						if obj.type == 'Pine tree' and obj.marked == false then
							if _G.nodes[obj.gx][obj.gy+1].walkable == 0 then
								local dist = manhattan_distance(self.gx,self.gy, obj.gx, obj.gy)
								if dist < closest_distance then 
									closest_object = obj
									closest_distance = dist
								end
							end
						end
					end
				end
				if not closest_object then return false,false else return closest_object,closest_distance end
			end
			function Woodcutter:find_tree()
				local closest_object, closest_distance = nil,10000000
				local objt,disto
					objt,disto = self:check_trees(self.cx,self.cy)
					if disto and disto < closest_distance then  
							closest_object = objt
							closest_distance = disto
					end
					objt,disto = self:check_trees(self.cx+1,self.cy)
					if disto and disto < closest_distance then  
							closest_object = objt
							closest_distance = disto
					end
					objt,disto = self:check_trees(self.cx+1,self.cy+1)
					if disto and disto < closest_distance then  
							closest_object = objt
							closest_distance = disto
					end
					objt,disto = self:check_trees(self.cx+1,self.cy-1)
					if disto and disto < closest_distance then  
							closest_object = objt
							closest_distance = disto
					end
					objt,disto = self:check_trees(self.cx-1,self.cy+1)
					if disto and disto < closest_distance then  
							closest_object = objt
							closest_distance = disto
					end
					objt,disto = self:check_trees(self.cx-1,self.cy)
					if disto and disto < closest_distance then  
							closest_object = objt
							closest_distance = disto
					end
					objt,disto = self:check_trees(self.cx-1,self.cy-1)
					if disto and disto < closest_distance then  
							closest_object = objt
							closest_distance = disto
					end
					objt,disto = self:check_trees(self.cx,self.cy+1)
					if disto and disto < closest_distance then  
							closest_object = objt
							closest_distance = disto
					end
					objt,disto = self:check_trees(self.cx,self.cy-1)
					if disto and disto < closest_distance then  
							closest_object = objt
							closest_distance = disto
					end
				if not closest_object then print("No trees nearby!") return end
				self.target_tree = closest_object 
				--print("Target tree:", self.target_tree)
				self.endx = closest_object.gx
				self.endy = closest_object.gy
				self:pathfind(self.endx,self.endy+1)
				--print("Found tree at "..self.endx.."  "..self.endy)
				self.state = "Going to tree"
				closest_object.marked = true
			end
			function Woodcutter:sub_update()
					self.previous_cx,self.previous_cy = self.cx,self.cy
					local xx, yy = ((self.fx*0.001) % chunk_width), ((self.fy*0.001) % chunk_width)
						self.cx,self.cy = math.floor((self.fx*0.001)/(chunk_width)),math.floor((self.fy*0.001)/(chunk_width))
						if self.move_dir == "northwest" then						
							if xx == 0 and yy ~= 0 then
								self.cx,self.cy = math.floor((self.fx*0.001-1)/(chunk_width)),math.floor((self.fy*0.001)/(chunk_width)) 
							elseif xx == 0 and yy == 0 then
								self.cx,self.cy = math.floor((self.fx*0.001-1)/(chunk_width)),math.floor((self.fy*0.001-1)/(chunk_width)) 
							elseif xx~= 0 and yy == 0 then
								self.cx,self.cy = math.floor((self.fx*0.001)/(chunk_width)),math.floor((self.fy*0.001-1)/(chunk_width)) 
							end
						elseif self.move_dir == "northeast" then						
							if xx == 63 and yy ~= 0 then
								self.cx,self.cy = math.floor((self.fx*0.001+1)/(chunk_width)),math.floor((self.fy*0.001)/(chunk_width)) 
							elseif xx == 63 and yy == 0 then
								self.cx,self.cy = math.floor((self.fx*0.001)/(chunk_width)),math.floor((self.fy*0.001-1)/(chunk_width)) 
							elseif xx~= 63 and yy == 0 then
								self.cx,self.cy = math.floor((self.fx*0.001-1)/(chunk_width)),math.floor((self.fy*0.001-1)/(chunk_width)) 
							end
						elseif self.move_dir == "southwest" then						
							if xx == 0 and yy ~= 63 then
								self.cx,self.cy = math.floor((self.fx*0.001-1)/(chunk_width)),math.floor((self.fy*0.001)/(chunk_width)) 
							elseif xx == 0 and yy == 63 then
								self.cx,self.cy = math.floor((self.fx*0.001-1)/(chunk_width)),math.floor((self.fy*0.001-1)/(chunk_width)) 
							elseif xx ~= 0 and yy == 63 then
								self.cx,self.cy = math.floor((self.fx*0.001)/(chunk_width)),math.floor((self.fy*0.001-1)/(chunk_width)) 
							end
						elseif self.move_dir == "north" then 
							self.cx,self.cy = math.floor((self.fx*0.001)/(chunk_width)),math.floor((self.fy*0.001-1)/(chunk_width)) 
						elseif self.move_dir == "east" then 
							self.cx,self.cy = math.floor((self.fx*0.001+1)/(chunk_width)),math.floor((self.fy*0.001)/(chunk_width)) 
						elseif self.move_dir == "west" then 
							self.cx,self.cy = math.floor((self.fx*0.001-1)/(chunk_width)),math.floor((self.fy*0.001)/(chunk_width)) 
						elseif self.move_dir == "south" then 
							self.cx,self.cy = math.floor((self.fx*0.001)/(chunk_width)),math.floor((self.fy*0.001+1)/(chunk_width)) 
						end
					-- print("{coords} = "..xx.."|"..yy)
					-- print("{position} = "..self.cx.."l"..self.cy.." --x,y ="..(self.gx).."-l-"..self.gy)
					if self.previous_cx ~= self.cx or self.previous_cy ~= self.cy then --update chunk location
						--print("---Moved across chunks from "..self.previous_cx.."|"..self.previous_cy.." to "..self.cx.."|"..self.cy)
						-- object_batch[self.previous_cx][self.previous_cy]:set(self.qid,tile_quads[0],0,0) 
						-- object[self.cx][self.cy][xx][yy] = self
						-- object[self.previous_cx][self.previous_cy][self.originalx][self.originaly] = nil
						-- self.qid = object_batch[self.cx][self.cy]:add(self.animation:getFrameInfo(self.x, self.y))
					else --print("Didn't move across chunks") 
					end
					if object[self.cx][self.cy][xx][yy] == nil then			
						object[self.cx][self.cy][xx][yy] = self
						object[self.cx][self.cy][self.originalx][self.originaly] = nil
						self.originalx = xx
						self.originaly = yy
					end
				end
			function Woodcutter:update()
				if self.state ~= "No trees" then
					if self.state == "Looking to chop tree" then
						self:find_tree()
					elseif self.move_dir == "none" and self.state == "Going to tree" then
						local wx = self.waypoint_x
						local wy = self.waypoint_y
						local angle = math.atan2 (wy-(self.fy*0.001),wx-(self.fx*0.001))
						if angle < 0 then angle = angle+2*math.pi end
						angle = angle*(180/math.pi)
						angle = math.round (angle)						

						--print("Calculated angle with wy("..wy.."), self.fy*0.001("..((self.fy*0.001))..
						--"),wx("..wx..") and self.fx*0.001("..((self.fx*0.001))..")")
						if angle<0 then angle = 360+angle end
							if (angle >= 135+22 and angle <= 225-22) then --direction is west 
								self.move_dir = "west"
								if self.previous_dir ~= "west" then
									self.animation = anim.newAnimation(self.fr_walking_west,0.11) 
								end
							elseif (angle > 135-22 and angle < 135+22) then --direction is southwest
								self.move_dir = "southwest"
								if self.previous_dir ~= "southwest" then
									self.animation = anim.newAnimation(self.fr_walking_southwest,0.11)
								end
							elseif (angle > 225-22 and angle < 225+22) then --direction is northwest
								self.move_dir = "northwest"
								if self.previous_dir ~= "northwest" then
									self.animation = anim.newAnimation(self.fr_walking_northwest,0.11)
								end
							elseif (angle >= 225+22 and angle <= 315-22) then --direction is north
								self.move_dir = "north"
								if self.previous_dir ~= "north" then
									self.animation = anim.newAnimation(self.fr_walking_north,0.11)
								end
							elseif (angle >= 45+22 and angle <= 135-22) then --direction is south
								self.move_dir = "south"
								if self.previous_dir ~= "south" then
									self.animation = anim.newAnimation(self.fr_walking_south,0.11)
								end
							elseif ((angle >= 315+22 and angle <= 359) or (angle >=0 and angle <= 45-22)) then --direction is east
								self.move_dir = "east"
								if self.previous_dir ~= "east" then
									self.animation = anim.newAnimation(self.fr_walking_east,0.11)
								end
							elseif (angle > 45-22 and angle < 45+22) then--direction is southeast
								self.move_dir = "southeast"
								if self.previous_dir ~= "southeast" then
									self.animation = anim.newAnimation(self.fr_walking_southeast,0.11)
								end
							elseif (angle > 315-22 and angle < 315+22) then --direction is northeast
								self.move_dir = "northeast"
								if self.previous_dir ~= "northeast" then
									self.animation = anim.newAnimation(self.fr_walking_northeast,0.11)
								end
							end
						--print("Move dir is now "..self.move_dir, angle)
					end
					self.x = IsoX + ((self.fx*0.001)%chunk_width - (self.fy*0.001)%chunk_width) * tile_width  * 0.5 -31 --fixme magic numbers?
					self.y = IsoY + ((self.fx*0.001)%chunk_width + (self.fy*0.001)%chunk_width) * tile_height * 0.5 -50
					self.timr = self.timr + 1
					self.timr = self.timr % 60
					if self.state == "Going to tree" then
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
						if (self.fx*0.001)==math.floor(self.fx*0.001) and (self.fy*0.001)==math.floor(self.fy*0.001) then 
							--print("Position ",self.fx*0.001,self.fy*0.001) 
							self.gx,self.gy= self.fx*0.001,self.fy*0.001
							self:sub_update()
							end
					end
					if self.fx*0.001 == self.waypoint_x and self.fy*0.001 == self.waypoint_y and self.state ~= "Cutting down" and self.move_dir ~= "none" then
							if self.count == self.nd_len then 
								self.state = "Cutting down"
								self.animation = anim.newAnimation(self.fr_cutting_northeast,0.12,self.cut)
								self.nd = {}
								self.waypoint_x, self.waypoint_y = nil, nil
								return 
							else
								--print("Reached checkpoint "..self.count,self.nd_len)
								self.waypoint_x = self.nd[self.count]._x
								self.waypoint_y = self.nd[self.count]._y
								--print("Waypoint is now "..self.waypoint_x,self.waypoint_y)
								self.previous_dir = self.move_dir
								self.move_dir = "none"									
							end
							self.count = self.count + 1
					end
				end
			end
			function Woodcutter:animate()
				self:update()
				self.animation:update(dt)
			end
return Woodcutter