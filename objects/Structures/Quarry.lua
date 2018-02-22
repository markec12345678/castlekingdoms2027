local object, tile_quads, object_batch = ...
local Object = require("objects.Object")

local Quarry = class('Quarry', Object)
			function Quarry:initialize(cx,cy,i,o,x,y,type)
                local mytype = "Static structure"
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.gx = chunk_width*self.cx+self.i
				self.gy = chunk_width*self.cy+self.o
				_G.nodes[self.gx][self.gy].walkable = 1
				self.health = 400
                self.qid = nil
                self.tile = tile_quads[732]
				self.offset_x = -64-16
				self.offset_y = -7*16-6
                self.level = 1
                self.rotation = 1
				local ccx, ccy
                for xx = -1, 4 do
					for yy = -1, 4 do 					
						ccx, ccy = terrainSetTileAt(self.gx+xx,self.gy+yy,math.random(6,8))
					end
				end
				update_terrain(ccx,ccy)
			end

return Quarry