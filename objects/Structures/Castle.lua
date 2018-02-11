local object, tile_quads = ...
local Object = require("objects.Object")

local Castle_alias = class('Castle_alias')
			function Castle_alias:initialize(tile,gx,gy,parent,offset_y,offset_x)
				offset_x = offset_x or 0
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
				self.offset_x = offset_x
				self.offset_y = -205+16+offset_y
				object[cx][cy][i][o] = self	
			end


local Castle = class('Castle', Object)
			function Castle:initialize(cx,cy,i,o,x,y,type)
                local mytype = "Static structure"
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.gx = chunk_width*self.cx+self.i
				self.gy = chunk_width*self.cy+self.o
				_G.nodes[self.gx][self.gy].walkable = 1
				self.health = 1000
                self.qid = nil
                self.tile = tile_quads[2285]
				self.offset_x = 0
				self.offset_y = -205+16
                self.level = 1
                self.rotation = 1
				Castle_alias:new(tile_quads[2279],self.gx-6,self.gy,self,16*3)  
				Castle_alias:new(tile_quads[2280],self.gx-5,self.gy,self,16*2+8)  
				Castle_alias:new(tile_quads[2281],self.gx-4,self.gy,self,16*2)  
				Castle_alias:new(tile_quads[2282],self.gx-3,self.gy,self,16+8)  
				Castle_alias:new(tile_quads[2283],self.gx-2,self.gy,self,16*1) 
				Castle_alias:new(tile_quads[2284],self.gx-1,self.gy,self,8)  
				Castle_alias:new(tile_quads[2286],self.gx,self.gy-1,self,8,16) 
				Castle_alias:new(tile_quads[2287],self.gx,self.gy-2,self,16*1,16)  
				Castle_alias:new(tile_quads[2288],self.gx,self.gy-3,self,16+8,16)   
				Castle_alias:new(tile_quads[2289],self.gx,self.gy-4,self,16*2,16)  
				Castle_alias:new(tile_quads[2290],self.gx,self.gy-5,self,16*2+8,16) 
				Castle_alias:new(tile_quads[2291],self.gx,self.gy-6,self,16*3,16)  
			end

return Castle