local object,object_batch, active_entities, tile_quads = ...
local Object = require("objects.Object")

local fr_walking_plank_east = {
	tile_quads[1985], tile_quads[1986], tile_quads[1987],
	tile_quads[1988], tile_quads[1989], tile_quads[1990],
	tile_quads[1991], tile_quads[1992]
}
local fr_walking_plank_north = {
	tile_quads[1993], tile_quads[1994], tile_quads[1995],
	tile_quads[1996], tile_quads[1997], tile_quads[1998],
	tile_quads[1999], tile_quads[2000]
}
local fr_walking_plank_west = {
	tile_quads[2041], tile_quads[2042], tile_quads[2043],
	tile_quads[2044], tile_quads[2045], tile_quads[2046],
	tile_quads[2047], tile_quads[2048]
}
local fr_walking_plank_south = {
	tile_quads[2017], tile_quads[2018], tile_quads[2019],
	tile_quads[2020], tile_quads[2021], tile_quads[2022],
	tile_quads[2023], tile_quads[2024]
}
local fr_walking_plank_northeast = {
	tile_quads[2001], tile_quads[2002], tile_quads[2003],
	tile_quads[2004], tile_quads[2005], tile_quads[2006],
	tile_quads[2007], tile_quads[2008]
}
local fr_walking_plank_northwest = {
	tile_quads[2009], tile_quads[2010], tile_quads[2011],
	tile_quads[2012], tile_quads[2013], tile_quads[2014],
	tile_quads[2015], tile_quads[2016]
}
local fr_walking_plank_southeast = {
	tile_quads[2025], tile_quads[2026], tile_quads[2027],
	tile_quads[2028], tile_quads[2029], tile_quads[2030],
	tile_quads[2031], tile_quads[2032]
}
local fr_walking_plank_southwest = {
	tile_quads[2033], tile_quads[2034], tile_quads[2035],
	tile_quads[2036], tile_quads[2037], tile_quads[2038],
	tile_quads[2039], tile_quads[2040]
}
local fr_walking_east = {
	tile_quads[2201],tile_quads[2202],tile_quads[2203],
	tile_quads[2204],tile_quads[2205],tile_quads[2206],
	tile_quads[2207],tile_quads[2208]
}
local fr_walking_north = {
	tile_quads[2209],tile_quads[2210],tile_quads[2211],
	tile_quads[2212],tile_quads[2213],tile_quads[2214],
	tile_quads[2215],tile_quads[2216]
}
local fr_walking_northeast = {
	tile_quads[2217],tile_quads[2218],tile_quads[2219],
	tile_quads[2220],tile_quads[2221],tile_quads[2222],
	tile_quads[2223],tile_quads[2224]
}
local fr_walking_northwest = {
	tile_quads[2225],tile_quads[2226],tile_quads[2227],
	tile_quads[2228],tile_quads[2229],tile_quads[2230],
	tile_quads[2231],tile_quads[2232]
}
local fr_walking_south = {
	tile_quads[2233],tile_quads[2234],tile_quads[2235],
	tile_quads[2236],tile_quads[2237],tile_quads[2238],
	tile_quads[2239],tile_quads[2240]
}
local fr_walking_southeast = {
	tile_quads[2241],tile_quads[2242],tile_quads[2243],
	tile_quads[2244],tile_quads[2245],tile_quads[2246],
	tile_quads[2247],tile_quads[2248]
}
local fr_walking_southwest = {
	tile_quads[2249],tile_quads[2250],tile_quads[2251],
	tile_quads[2252],tile_quads[2253],tile_quads[2254],
	tile_quads[2255],tile_quads[2256]
}
local fr_walking_west = {
	tile_quads[2257],tile_quads[2258],tile_quads[2259],
	tile_quads[2260],tile_quads[2261],tile_quads[2262],
	tile_quads[2263],tile_quads[2264]
}
local fr_cutting_northeast = { --note actually north
	tile_quads[2056],tile_quads[2057],tile_quads[2058],
	tile_quads[2059],tile_quads[2060],tile_quads[2061],
	tile_quads[2062],tile_quads[2063]
}

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
				self.originalx = self.gx 
				self.originaly = self.gy
				self.nd = {}
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
						--print("Trying to cut down "..self.target_tree.type)
						local tree_progress = 0
						if self.target_tree.type == "Pine tree" then
						tree_progress = self.target_tree:cut() else 
						self.state = "Looking to chop tree"	
							self.move_dir = "none"
						end
						if tree_progress == 2 then
							--self.animation = anim.newAnimation(fr_walking_north,0.15)
							self.i = (self.fx*0.001)%chunk_width
							self.o = (self.fy*0.001)%chunk_width
							self.move_dir = "none"
							self.count = 1
							tree_progress = 3			
								if _G.stockpile then
                                    self.state = "Going to stockpile"    
                                    local closest_node
                                    local distance = math.huge
                                    for k,v in ipairs(_G.stockpile.node_list) do
                                        local tmp = manhattan_distance(v.gx,v.gy,self.gx,self.gy)
                                        if tmp < distance then
                                            distance = tmp
                                            closest_node = v
                                        end
                                    end
                                    if not closest_node then self.state = "Looking to chop tree" else                                    
                                    self:pathfind(closest_node.gx,closest_node.gy) end
                                else self.state = "Looking to chop tree" end
						end
					else --print("State", self.state)
					end					
				end
				self.animation = anim.newAnimation(fr_walking_west,10)
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
					return true
				else print("Path not found!")
					self.state = "No trees"
					return false
				 end			
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
				if not closest_object then print("No trees nearby!") self.state = "No trees" return end
				self.target_tree = closest_object 
				--print("Target tree:", self.target_tree)
				self.endx = closest_object.gx
				self.endy = closest_object.gy
				if self:pathfind(self.endx,self.endy+1) then
				--print("Found tree at "..self.endx.."  "..self.endy)
					self.state = "Going to tree"
					closest_object.marked = true
				else self.state = "No trees" end --todo rename to stuck
			end
			function Woodcutter:update_direction()
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
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_plank_west,0.11) 
						else
							self.animation = anim.newAnimation(fr_walking_west,0.11)
						end
					end
				elseif (angle > 135-22 and angle < 135+22) then --direction is southwest
					self.move_dir = "southwest"
					if self.previous_dir ~= "southwest" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_plank_southwest,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_southwest,0.11)
						end
					end
				elseif (angle > 225-22 and angle < 225+22) then --direction is northwest
					self.move_dir = "northwest"
					if self.previous_dir ~= "northwest" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_plank_northwest,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_northwest,0.11)
						end
					end
				elseif (angle >= 225+22 and angle <= 315-22) then --direction is north
					self.move_dir = "north"
					if self.previous_dir ~= "north" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_plank_north,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_north,0.11)
						end
					end
				elseif (angle >= 45+22 and angle <= 135-22) then --direction is south
					self.move_dir = "south"
					if self.previous_dir ~= "south" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_plank_south,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_south,0.11)
						end
					end
				elseif ((angle >= 315+22 and angle <= 359) or (angle >=0 and angle <= 45-22)) then --direction is east
					self.move_dir = "east"
					if self.previous_dir ~= "east" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_plank_east,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_east,0.11)
						end
					end
				elseif (angle > 45-22 and angle < 45+22) then--direction is southeast
					self.move_dir = "southeast"
					if self.previous_dir ~= "southeast" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_plank_southeast,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_southeast,0.11)
						end
					end
				elseif (angle > 315-22 and angle < 315+22) then --direction is northeast
					self.move_dir = "northeast"
					if self.previous_dir ~= "northeast" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_plank_northeast,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_northeast,0.11)
						end
					end
				end
			end
			
			function Woodcutter:update()
				if self.state ~= "No trees" then
					if self.state == "Looking to chop tree" then
						self:find_tree()
					elseif self.move_dir == "none" and self.state == "Going to tree" then
						self:update_direction()
					elseif self.move_dir == "none" and self.state == "Going to stockpile" then
						self:update_direction()
					end
					self.timr = self.timr + 1
					self.timr = self.timr % 60
					if self.state == "Going to tree" or self.state == "Going to stockpile" then
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
							if object[self.cx][self.cy][xx][yy] == nil then
								object[self.cx][self.cy][xx][yy] = self
							end
							if object[self.cx][self.cy][self.originalx][self.originaly] == self 
							and (self.originalx ~= math.round(self.gx)%chunk_width or self.originaly ~= math.round(self.gy)%chunk_width)
							then
								object[self.cx][self.cy][self.originalx][self.originaly] = nil
							end
						if self.previous_cx ~= self.cx or self.previous_cy ~= self.cy then
							object[self.cx][self.cy][xx][yy] = self			
						    self.qid = object_batch[self.cx][self.cy]:add(self.animation:getFrameInfo(self.x, self.y))
						end							
						self.x = IsoX + ((self.fx*0.001)%chunk_width - (self.fy*0.001)%chunk_width) * tile_width  * 0.5 -31 --fixme magic numbers?
						self.y = IsoY + ((self.fx*0.001)%chunk_width + (self.fy*0.001)%chunk_width) * tile_height * 0.5 -50
						if self.originalx ~= math.round(self.gx)%chunk_width or self.originaly ~= math.round(self.gy)%chunk_width then
							self.originalx = math.round(self.gx)%chunk_width
							self.originaly = math.round(self.gy)%chunk_width
						end
					end
					if self.fx*0.001 == self.waypoint_x and self.fy*0.001 == self.waypoint_y and self.move_dir ~= "none" then
						if self.state == "Going to tree" then
							if self.count == self.nd_len then 
								self.state = "Cutting down"
								self.animation = anim.newAnimation(fr_cutting_northeast,0.12,self.cut)
								self.nd = {}
								self.waypoint_x, self.waypoint_y = nil, nil
								self.move_dir = "none"			
								self.count = 1					
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
						elseif self.state == "Going to stockpile" then
							if self.count == self.nd_len then
								_G.stockpile:store('wood')
								_G.stockpile:store('wood')
								_G.stockpile:store('wood')
								_G.stockpile:store('wood')
                    			--print(inspect(_G.stockpile.list,{depth = 3}))
								self.state = "Looking to chop tree"
								self.nd = {}
								self.waypoint_x, self.waypoint_y = nil, nil
								self.move_dir = "none"				
								self.count = 1		
								return 
							else
								self.waypoint_x = self.nd[self.count]._x
								self.waypoint_y = self.nd[self.count]._y
								self.previous_dir = self.move_dir
								self.move_dir = "none"									
							end
							self.count = self.count + 1
						end
					end
				end
			end
			function Woodcutter:animate()
				self:update()
				self.animation:update(dt)
			end
return Woodcutter