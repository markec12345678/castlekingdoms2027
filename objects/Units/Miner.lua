local object,object_batch, active_entities, tile_quads = ...
local Object = require("objects.Object")

local fr_walking_east = {
    tile_quads[1857],tile_quads[1858],tile_quads[1859],
    tile_quads[1860],tile_quads[1861],tile_quads[1862],
    tile_quads[1863],tile_quads[1864],
}
local fr_walking_north = {
    tile_quads[1865],tile_quads[1866],tile_quads[1867],
    tile_quads[1868],tile_quads[1869],tile_quads[1870],
    tile_quads[1871],tile_quads[1872],
}
local fr_walking_northeast = {
    tile_quads[1873],tile_quads[1874],tile_quads[1875],
    tile_quads[1876],tile_quads[1877],tile_quads[1878],
    tile_quads[1879],tile_quads[1880],
}
local fr_walking_northwest = {
    tile_quads[1881],tile_quads[1882],tile_quads[1883],
    tile_quads[1884],tile_quads[1885],tile_quads[1886],
    tile_quads[1887],tile_quads[1888],
}
local fr_walking_south = {
    tile_quads[1889],tile_quads[1890],tile_quads[1891],
    tile_quads[1892],tile_quads[1893],tile_quads[1894],
    tile_quads[1895],tile_quads[1895],
}
local fr_walking_southeast = {
    tile_quads[1897],tile_quads[1898],tile_quads[1899],
    tile_quads[1900],tile_quads[1901],tile_quads[1902],
    tile_quads[1903],tile_quads[1904],
}
local fr_walking_southwest = {
    tile_quads[1905],tile_quads[1906],tile_quads[1907],
    tile_quads[1908],tile_quads[1909],tile_quads[1910],
    tile_quads[1911],tile_quads[1912],
}
local fr_walking_west = {
    tile_quads[1913],tile_quads[1914],tile_quads[1915],
    tile_quads[1916],tile_quads[1917],tile_quads[1918],
    tile_quads[1919],tile_quads[1920],
}
local fr_walking_stone_east = {
	tile_quads[1793],
	tile_quads[1794],
	tile_quads[1795],
	tile_quads[1796],
	tile_quads[1797],
	tile_quads[1798],
	tile_quads[1799],
	tile_quads[1800],
}
local fr_walking_stone_north = {
	tile_quads[1801],
	tile_quads[1802],
	tile_quads[1803],
	tile_quads[1804],
	tile_quads[1805],
	tile_quads[1806],
	tile_quads[1807],
	tile_quads[1808],
}
local fr_walking_stone_northeast = {
	tile_quads[1809],
	tile_quads[1810],
	tile_quads[1811],
	tile_quads[1812],
	tile_quads[1813],
	tile_quads[1814],
	tile_quads[1815],
	tile_quads[1816],
}
local fr_walking_stone_northwest = {
	tile_quads[1817],
	tile_quads[1818],
	tile_quads[1819],
	tile_quads[1820],
	tile_quads[1821],
	tile_quads[1822],
	tile_quads[1823],
	tile_quads[1824],
}
local fr_walking_stone_south = {
	tile_quads[1825],
	tile_quads[1826],
	tile_quads[1827],
	tile_quads[1828],
	tile_quads[1829],
	tile_quads[1830],
	tile_quads[1831],
	tile_quads[1832],
}
local fr_walking_stone_southeast = {
	tile_quads[1833],
	tile_quads[1834],
	tile_quads[1835],
	tile_quads[1836],
	tile_quads[1837],
	tile_quads[1838],
	tile_quads[1839],
	tile_quads[1840],
}
local fr_walking_stone_southwest = {
	tile_quads[1841],
	tile_quads[1842],
	tile_quads[1843],
	tile_quads[1844],
	tile_quads[1845],
	tile_quads[1846],
	tile_quads[1847],
	tile_quads[1848],
}
local fr_walking_stone_west = {
	tile_quads[1849],
	tile_quads[1850],
	tile_quads[1851],
	tile_quads[1852],
	tile_quads[1853],
	tile_quads[1854],
	tile_quads[1855],
	tile_quads[1856],
}

		local Miner = class('Miner', Object)
			function Miner:initialize(cx,cy,i,o,x,y,type)
				Object.initialize(self,cx,cy,i,o,x,y,type)
				self.gx = chunk_width*self.cx+self.i
				self.gy = chunk_width*self.cy+self.o
				self.endx = 0
				self.endy = 0
				self.workplace = nil
				self.lrx, self.lry,self.lrcx,self.lrcy = 0,0,0,0
				self.fx = self.gx*1000
				self.fy = self.gy*1000
				self.previous_cx = cx
				self.previous_cy = cx
				self.waypoint_x = 0
				self.waypoint_y = 0
				self.state = 'Find a job'
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
				self.animated = true				
				self.animation = anim.newAnimation(fr_walking_west,10)
				table.insert(active_entities,self)
			end 
			function Miner:pathfind(xx,yy)
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
					self.state = "No path to workplace"
					return false
				 end			
			end
			
			function Miner:update_direction()
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
							self.animation = anim.newAnimation(fr_walking_stone_west,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_west,0.11)
						end
					end
				elseif (angle > 135-22 and angle < 135+22) then --direction is southwest
					self.move_dir = "southwest"
					if self.previous_dir ~= "southwest" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_stone_southwest,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_southwest,0.11)
						end
					end
				elseif (angle > 225-22 and angle < 225+22) then --direction is northwest
					self.move_dir = "northwest"
					if self.previous_dir ~= "northwest" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_stone_northwest,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_northwest,0.11)
						end
					end
				elseif (angle >= 225+22 and angle <= 315-22) then --direction is north
					self.move_dir = "north"
					if self.previous_dir ~= "north" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_stone_north,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_north,0.11)
						end
					end
				elseif (angle >= 45+22 and angle <= 135-22) then --direction is south
					self.move_dir = "south"
					if self.previous_dir ~= "south" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_stone_south,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_south,0.11)
						end
					end
				elseif ((angle >= 315+22 and angle <= 359) or (angle >=0 and angle <= 45-22)) then --direction is east
					self.move_dir = "east"
					if self.previous_dir ~= "east" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_stone_east,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_east,0.11)
						end
					end
				elseif (angle > 45-22 and angle < 45+22) then--direction is southeast
					self.move_dir = "southeast"
					if self.previous_dir ~= "southeast" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_stone_southeast,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_southeast,0.11)
						end
					end
				elseif (angle > 315-22 and angle < 315+22) then --direction is northeast
					self.move_dir = "northeast"
					if self.previous_dir ~= "northeast" then
						if self.state == "Going to stockpile" then
							self.animation = anim.newAnimation(fr_walking_stone_northeast,0.11)
						else
							self.animation = anim.newAnimation(fr_walking_northeast,0.11)
						end
					end
				end
                self.previous_dir = self.move_dir
			end
			function Miner:job_update()	
				object[self.lrcx][self.lrcy][self.lrx][self.lry] = nil
			end
			function Miner:update()
				if self.state ~= "No path to workplace" and self.state ~= "Working" then
					if self.state == "Find a job" then
						_G.JobController:find_job(self,"Miner")
					elseif self.state == "Go to stockpile" then
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
							if not closest_node then print("Closest node not found") else                                    
							self:pathfind(closest_node.gx,closest_node.gy) print("Found path!") end
							self.move_dir = "none"
						end
					elseif self.state == "Go to workplace" then
                        if self:pathfind(self.workplace.gx-1,self.workplace.gy+1) then
                            self.state = "Going to workplace"
                            self.move_dir = "none"
                        end
					elseif self.move_dir == "none" and self.state == "Going to workplace" then
						self:update_direction()
                        print(self.move_dir)
					elseif self.move_dir == "none" and self.state == "Going to stockpile" then
						self:update_direction()
					end
					self.timr = self.timr + 1
					self.timr = self.timr % 60
					if self.state == "Going to workplace" or self.state == "Going to stockpile" then
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
								self.lrcx, self.lrcy, self.lrx, self.lry = self.cx,self.cy,xx,yy
							end
							if object[self.cx][self.cy][self.originalx][self.originaly] == self 
							and (self.originalx ~= math.round(self.gx)%chunk_width or self.originaly ~= math.round(self.gy)%chunk_width)
							then
								object[self.cx][self.cy][self.originalx][self.originaly] = nil
							end
						if self.previous_cx ~= self.cx or self.previous_cy ~= self.cy then
							object[self.cx][self.cy][xx][yy] = self			
								self.lrcx, self.lrcy, self.lrx, self.lry = self.cx,self.cy,xx,yy
						    self.qid = object_batch[self.cx][self.cy]:add(self.animation:getFrameInfo(self.x, self.y))
						end							
						self.x = IsoX + ((self.fx*0.001)%chunk_width - (self.fy*0.001)%chunk_width) * tile_width  * 0.5 -34 --fixme magic numbers?
						self.y = IsoY + ((self.fx*0.001)%chunk_width + (self.fy*0.001)%chunk_width) * tile_height * 0.5 -50+8
						if self.originalx ~= math.round(self.gx)%chunk_width or self.originaly ~= math.round(self.gy)%chunk_width then
							self.originalx = math.round(self.gx)%chunk_width
							self.originaly = math.round(self.gy)%chunk_width
						end
					end
					if self.fx*0.001 == self.waypoint_x and self.fy*0.001 == self.waypoint_y and self.move_dir ~= "none" then
						if self.state == "Going to workplace" then
							if self.count == self.nd_len then 
								self.workplace:work(self)
								self.nd = {}
								self.waypoint_x, self.waypoint_y = nil, nil
								self.move_dir = "none"			
								self.count = 1					
								return 
							else	
								self.waypoint_x = self.nd[self.count]._x
								self.waypoint_y = self.nd[self.count]._y
								--self.previous_dir = self.move_dir
								self.move_dir = "none"									
							end
							self.count = self.count + 1
						elseif self.state == "Going to stockpile" then
							if self.count == self.nd_len then
								_G.stockpile:store('iron')
								self.state = "Go to workplace"
								self.nd = {}
								self.waypoint_x, self.waypoint_y = nil, nil
								self.move_dir = "none"				
								self.count = 1		
								return 
							else
								self.waypoint_x = self.nd[self.count]._x
								self.waypoint_y = self.nd[self.count]._y
								--self.previous_dir = self.move_dir
								self.move_dir = "none"									
							end
							self.count = self.count + 1
						end
					end
				end
			end
			function Miner:animate()
				self:update()
				self.animation:update(dt)
			end
return Miner