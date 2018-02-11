local object, tile_quads, object_batch = ...
local Object = require("objects.Object")

local quad_map_wood = {
	 [1] = tile_quads[1667],
	 [2] = tile_quads[1666],
	 [3] = tile_quads[1665],
	 [4] = tile_quads[1664],
	 [5] = tile_quads[1663],
	 [6] = tile_quads[1662],
	 [7] = tile_quads[1661],
	 [8] = tile_quads[1660],
	 [9] = tile_quads[1659],
	 [10] = tile_quads[1657],
	 [11] = tile_quads[1656],
	 [12] = tile_quads[1655],
	 [13] = tile_quads[1654],
	 [14] = tile_quads[1653],
	 [15] = tile_quads[1652],
	 [16] = tile_quads[1651],
	 [17] = tile_quads[1650],
	 [18] = tile_quads[1649],
	 [19] = tile_quads[1648],
	 [20] = tile_quads[1646],
	 [21] = tile_quads[1645],
	 [22] = tile_quads[1644],
	 [23] = tile_quads[1643],
	 [24] = tile_quads[1642],
	 [25] = tile_quads[1641],
	 [26] = tile_quads[1640],
	 [27] = tile_quads[1639],
	 [28] = tile_quads[1638],
	 [29] = tile_quads[1637],	 
	 [30] = tile_quads[1635],
	 [31] = tile_quads[1634],
	 [32] = tile_quads[1633],
	 [33] = tile_quads[1632],
	 [34] = tile_quads[1631],
	 [35] = tile_quads[1630],
	 [36] = tile_quads[1629],
	 [37] = tile_quads[1628],
	 [38] = tile_quads[1627],
	 [39] = tile_quads[1626],
	 [40] = tile_quads[1672],
	 [41] = tile_quads[1671],
	 [42] = tile_quads[1670],
	 [43] = tile_quads[1669],
	 [44] = tile_quads[1668],
	 [45] = tile_quads[1658],
	 [46] = tile_quads[1647],
	 [47] = tile_quads[1636],
	 [48] = tile_quads[1625],
}

local Stockpile_alias = class('Stockpile_alias', Object)
			function Stockpile_alias:initialize(tile,gx,gy,parent,offset_y,offset_x)
                local mytype = "Static structure"
				local i = (gx) % (chunk_width)
				local o = (gy) % (chunk_width)
				local cx = math.floor(gx/chunk_width)
				local cy = math.floor(gy/chunk_width)				 
				local x = IsoX + (i - o) * tile_width  * 0.5
				local y = IsoY + (i + o) * tile_height * 0.5
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.gx = gx
				self.gy = gy
				_G.nodes[self.gx][self.gy].walkable = 1
				self.parent = parent
                self.qid = nil
                self.tile = tile
				self.offset_x = offset_x or 0
				self.offset_y = -(offset_y or 0)
				object[cx][cy][i][o] = self	
			end


local Stockpile = class('Stockpile', Object)
			function Stockpile:initialize(cx,cy,i,o,x,y,type)
                local mytype = "Static structure"
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.gx = chunk_width*self.cx+self.i
				self.gy = chunk_width*self.cy+self.o
				_G.nodes[self.gx][self.gy].walkable = 1
				self.health = 1000
                self.qid = nil
                self.tile = tile_quads[2296]
				self.offset_x = 0
				self.offset_y = -12
                self.level = 1
                self.rotation = 1
				self.stockpile = {}
				self.stockpile[1] = {id = nil, empty = true, type = nil, quantity = 0}
				self.stockpile[2] = {id = nil, empty = true, type = nil, quantity = 0}
				self.stockpile[3] = {id = nil, empty = true, type = nil, quantity = 0}
				self.stockpile[4] = {id = nil, empty = true, type = nil, quantity = 0}

				self.stockpile[1].id = Stockpile_alias:new(tile_quads[0],self.gx+1,self.gy+1,self,32-2,-16)
				self.stockpile[2].id = Stockpile_alias:new(tile_quads[0],self.gx+1,self.gy+4,self,32-2,-16)
				self.stockpile[3].id = Stockpile_alias:new(tile_quads[0],self.gx+4,self.gy+1,self,32-2,-16)
				self.stockpile[4].id = Stockpile_alias:new(tile_quads[0],self.gx+4,self.gy+4,self,32-2,-16)
				
				local ccx, ccy
                for xx = -1, 5 do
					for yy = -1, 5 do 					
						ccx, ccy = terrainSetTileAt(self.gx+xx,self.gy+yy,math.random(6,8))
					end
				end
				update_terrain(ccx,ccy)

                Stockpile_alias:new(tile_quads[2292],self.gx,self.gy+4,self,12+8*4)
                Stockpile_alias:new(tile_quads[2293],self.gx,self.gy+3,self,12+8*3)
                Stockpile_alias:new(tile_quads[2294],self.gx,self.gy+2,self,12+8*2)
                Stockpile_alias:new(tile_quads[2295],self.gx,self.gy+1,self,12+8*1)

                Stockpile_alias:new(tile_quads[2297],self.gx+1,self.gy,self,12+8*1,16)
                Stockpile_alias:new(tile_quads[2298],self.gx+2,self.gy,self,12+8*2,16)
                Stockpile_alias:new(tile_quads[2299],self.gx+3,self.gy,self,12+8*3,16)
                Stockpile_alias:new(tile_quads[2300],self.gx+4,self.gy,self,12+8*4,16)

                Stockpile_alias:new(tile_quads[0],self.gx+4,self.gy+4,self,12+8*4,16)
                Stockpile_alias:new(tile_quads[0],self.gx+4,self.gy+4-1,self,12+8*4,16)
                Stockpile_alias:new(tile_quads[0],self.gx+4,self.gy+4-2,self,12+8*4,16)
                Stockpile_alias:new(tile_quads[0],self.gx+4,self.gy+4-3,self,12+8*4,16)
                Stockpile_alias:new(tile_quads[0],self.gx+4-1,self.gy+4,self,12+8*4,16)
                Stockpile_alias:new(tile_quads[0],self.gx+4-2,self.gy+4,self,12+8*4,16)
                Stockpile_alias:new(tile_quads[0],self.gx+4-3,self.gy+4,self,12+8*4,16)
                --TODO: add aliases from bottom side		
			end
			function Stockpile:store(resource)
				if resource == 'wood' then 
					local found = false
					for index = 1, 4 do
						if self.stockpile[index].type == 'wood' and self.stockpile[index].quantity < 48 then
							self.stockpile[index].quantity = self.stockpile[index].quantity + 1					
							found = true
							self:update_stockpile(index)
						end
					end 
					if not found then
						for index = 1, 4 do
							print(index)
							if self.stockpile[index].empty then
								self.stockpile[index].empty = false
								self.stockpile[index].type = 'wood'
								self.stockpile[index].quantity = 1
								self:update_stockpile(index)
								break
							end
						end
					end
				end
			end
			function Stockpile:update_stockpile(index)
				self.stockpile[index].id.tile = quad_map_wood[self.stockpile[index].quantity]
				object_batch[self.stockpile[index].id.cx][self.stockpile[index].id.cy]
					:set(self.stockpile[index].id.qid, self.stockpile[index].id.tile,self.stockpile[index].id.x,self.stockpile[index].id.y)
			end

return Stockpile