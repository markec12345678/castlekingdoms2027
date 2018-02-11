local object, tile_quads = ...
local Object = require("objects.Object")

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

                Stockpile_alias:new(tile_quads[2292],self.gx,self.gy+4,self,12+8*4)
                Stockpile_alias:new(tile_quads[2293],self.gx,self.gy+3,self,12+8*3)
                Stockpile_alias:new(tile_quads[2294],self.gx,self.gy+2,self,12+8*2)
                Stockpile_alias:new(tile_quads[2295],self.gx,self.gy+1,self,12+8*1)

                Stockpile_alias:new(tile_quads[2297],self.gx+1,self.gy,self,12+8*1,16)
                Stockpile_alias:new(tile_quads[2298],self.gx+2,self.gy,self,12+8*2,16)
                Stockpile_alias:new(tile_quads[2299],self.gx+3,self.gy,self,12+8*3,16)
                Stockpile_alias:new(tile_quads[2300],self.gx+4,self.gy,self,12+8*4,16)
                --TODO: add aliases from bottom side
                for xx = -1, 5 do
					for yy = -1, 5 do --TODO: make it use gx,gy so it's cross chunk compatible	
						terrain[cx][cy][self.i+xx][self.o+yy]  = math.random(6,8)
					end
				end
                update_terrain(cx,cy)
			end

return Stockpile