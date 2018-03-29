local object, tile_quads = ...
local Object = require("objects.Object")

local Castle_alias = class('Castle_alias', Object)
			function Castle_alias:initialize(tile,gx,gy,parent,offset_y,offset_x)
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
					setWalkable(self.gx,self.gy,1)
				self.parent = parent
                self.qid = nil
                self.tile = tile
				self.offset_x = offset_x or 0
				self.offset_y = -(offset_y or 0)
				addObjectAt(cx, cy, i, o, self)	
			end


local Castle = class('Castle', Object)
			function Castle:initialize(cx,cy,i,o,x,y,type)
                local mytype = "Static structure"
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.gx = chunk_width*self.cx+self.i
				self.gy = chunk_width*self.cy+self.o
					setWalkable(self.gx,self.gy,1)
				self.health = 1000
                self.qid = nil
                self.tile = tile_quads[2285]
				self.offset_x = 0
				self.offset_y = -93
                self.level = 1
                self.rotation = 1				

				Castle_alias:new(tile_quads[2279],self.gx,self.gy+6,self,125+16)  
				Castle_alias:new(tile_quads[2280],self.gx,self.gy+5,self,125+8)  
				Castle_alias:new(tile_quads[2281],self.gx,self.gy+4,self,125)  
				Castle_alias:new(tile_quads[2282],self.gx,self.gy+3,self,117)  
				Castle_alias:new(tile_quads[2283],self.gx,self.gy+2,self,109) 
				Castle_alias:new(tile_quads[2284],self.gx,self.gy+1,self,101)  

				Castle_alias:new(tile_quads[2286],self.gx+1,self.gy,self,101,16) 
				Castle_alias:new(tile_quads[2287],self.gx+2,self.gy,self,109,16)  
				Castle_alias:new(tile_quads[2288],self.gx+3,self.gy,self,117,16)   
				Castle_alias:new(tile_quads[2289],self.gx+4,self.gy,self,125,16)  
				Castle_alias:new(tile_quads[2290],self.gx+5,self.gy,self,125+8,16) 
				Castle_alias:new(tile_quads[2291],self.gx+6,self.gy,self,125+16,16)  

				Castle_alias:new(tile_quads[0],self.gx-5+6,self.gy+6,self)
				Castle_alias:new(tile_quads[0],self.gx-4+6,self.gy+6,self)
				Castle_alias:new(tile_quads[0],self.gx-3+6,self.gy+6,self)
				Castle_alias:new(tile_quads[0],self.gx-2+6,self.gy+6,self)
				Castle_alias:new(tile_quads[0],self.gx-1+6,self.gy+6,self)
				
				Castle_alias:new(tile_quads[0],self.gx+6,self.gy+6,self)
				
				Castle_alias:new(tile_quads[0],self.gx+6,self.gy-1+6,self)
				Castle_alias:new(tile_quads[0],self.gx+6,self.gy-2+6,self)
				Castle_alias:new(tile_quads[0],self.gx+6,self.gy-3+6,self)
				Castle_alias:new(tile_quads[0],self.gx+6,self.gy-4+6,self)
				Castle_alias:new(tile_quads[0],self.gx+6,self.gy-5+6,self)

				local ccx,ccy
				for xx = -2, 8 do
					for yy = -2, 8 do 			
						if yy == 7 or xx == 7 or xx == -1 or yy == -1 then
						ccx, ccy = terrainSetTileAt(self.gx+xx,self.gy+yy,math.random(6,8))
						elseif math.random(1,3) == 1 then
						ccx, ccy = terrainSetTileAt(self.gx+xx,self.gy+yy,math.random(6,8))
						end
					end
				end

				update_terrain(ccx,ccy)
			end

return Castle