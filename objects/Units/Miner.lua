local object, tile_quads = ...
local Unit = require("objects.Units.Unit")

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

		local Miner = class('Miner', Unit)
			function Miner:initialize(cx,cy,i,o,x,y,type)
				Unit.initialize(self,cx,cy,i,o,x,y,type)
				self.state = 'Find a job'
				self.marked = 0
				self.count = 1
				self.timr = 0
				self.animated = true				
				self.animation = anim.newAnimation(fr_walking_west,10)
			end 
			function Miner:dir_sub_update(dir)
				if dir == "west" then
                    if self.state == "Going to stockpile" then
                        self.animation = anim.newAnimation(fr_walking_stone_west,0.11) 
                    else
                        self.animation = anim.newAnimation(fr_walking_west,0.11)
                    end
				elseif dir == "southwest" then
                    if self.state == "Going to stockpile" then
                        self.animation = anim.newAnimation(fr_walking_stone_southwest,0.11)
                    else
                        self.animation = anim.newAnimation(fr_walking_southwest,0.11)
                    end
				elseif dir == "northwest" then
                    if self.state == "Going to stockpile" then
                        self.animation = anim.newAnimation(fr_walking_stone_northwest,0.11)
                    else
                        self.animation = anim.newAnimation(fr_walking_northwest,0.11)
                    end
				elseif dir == "north" then
                    if self.state == "Going to stockpile" then
                        self.animation = anim.newAnimation(fr_walking_stone_north,0.11)
                    else
                        self.animation = anim.newAnimation(fr_walking_north,0.11)
                    end
				elseif dir == "south" then
                    if self.state == "Going to stockpile" then
                        self.animation = anim.newAnimation(fr_walking_stone_south,0.11)
                    else
                        self.animation = anim.newAnimation(fr_walking_south,0.11)
                    end
				elseif dir == "east" then
                    if self.state == "Going to stockpile" then
                        self.animation = anim.newAnimation(fr_walking_stone_east,0.11)
                    else
                        self.animation = anim.newAnimation(fr_walking_east,0.11)
                    end
				elseif dir == "southeast" then
                    if self.state == "Going to stockpile" then
                        self.animation = anim.newAnimation(fr_walking_stone_southeast,0.11)
                    else
                        self.animation = anim.newAnimation(fr_walking_southeast,0.11)
                    end
				elseif dir == "northeast" then
                    if self.state == "Going to stockpile" then
                        self.animation = anim.newAnimation(fr_walking_stone_northeast,0.11)
                    else
                        self.animation = anim.newAnimation(fr_walking_northeast,0.11)
                    end
				end
			end
			function Miner:job_update()	
				removeObjectAt(self.lrcx, self.lrcy, self.lrx, self.lry, self)
			end
			function Miner:update()
				if self.path_state == "Waiting for path" then
					self:pathfind()
				elseif self.state ~= "No path to workplace" and self.state ~= "Working" then
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
							self:requestPath(closest_node.gx,closest_node.gy) print("Found path!") end
							self.move_dir = "none"
						end
					elseif self.state == "Go to workplace" then
                        self:requestPath(self.workplace.gx-1,self.workplace.gy+1)
                            self.state = "Going to workplace"
                            self.move_dir = "none"                        
					elseif self.move_dir == "none" and self.state == "Going to workplace" then
						self:update_direction()
                        print(self.move_dir)
					elseif self.move_dir == "none" and self.state == "Going to stockpile" then
						self:update_direction()
					end
					self.timr = self.timr + 1
					self.timr = self.timr % 60
					if self.state == "Going to workplace" or self.state == "Going to stockpile" then
						self:move()
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
								self.waypoint_x = self.nd[self.count][1]
								self.waypoint_y = self.nd[self.count][2]
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
								self.waypoint_x = self.nd[self.count][1]
								self.waypoint_y = self.nd[self.count][2]
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