local object, tile_quads, object_batch = ...
local Object = require("objects.Object")
local tiles, quad_array = indexBuildingQuads("farm (3)")


local Orchard_alias = class('Orchard_alias', Object)
			function Orchard_alias:initialize(tile,gx,gy,parent,offset_y,offset_x)
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
                self.qid = 0
                self.tile = tile
				self.base_offset_y = offset_y or 0
				self.additional_offset_y = 0
				self.offset_x = offset_x or 0
				self.offset_y = self.additional_offset_y-self.base_offset_y 
				for k,v in ipairs(_G.stockpile.node_list) do
					if v.gx == self.gx and v.gy == self.gy then
						table.remove(_G.stockpile.node_list, k)
						break
					end
				end
				addObjectAt(cx, cy, i, o, self)	
			end

local Orchard = class('Orchard', Object)
			function Orchard:initialize(cx,cy,i,o,x,y,type)
				_G.JobController:add("Stonemason",self)
                local mytype = "Static structure"
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.gx = chunk_width*self.cx+self.i
				self.gy = chunk_width*self.cy+self.o
					setWalkable(self.gx,self.gy,1)
				self.health = 400
                self.qid = nil
				self.tile = quad_array[tiles + 1]
				self.stone_quantity = 0
				self.working = false
				self.offset_x = 0
				self.offset_y = -7*16-6
                self.level = 1
                self.rotation = 1
				self.lifter = Orchard_lifter:new(self.gx+3,self.gy+3,self,self.offset_x-64-16,self.offset_y)
				self.lifter:deactivate()
				self.shaper = Orchard_shaper:new(self.gx+2,self.gy+2,self,self.offset_x-64-16,self.offset_y)
				self.shaper:deactivate()
				self.puller = Orchard_puller:new(self.gx+4,self.gy+2,self,self.offset_x-64-16,self.offset_y)
				self.puller:deactivate()
				self.hook =  Orchard_hook:new(self.gx+1,self.gy+1,self,self.offset_x-64-16,self.offset_y)
				local ccx, ccy
                for xx = -1, 6 do
					for yy = -1, 6 do 					
						ccx, ccy = terrainSetTileAt(self.gx+xx,self.gy+yy,math.random(6,8))
					end
				end
				update_terrain(ccx,ccy)

				for tile=1, tiles do
					Orchard_alias:new(quad_array[tile],self.gx,self.gy+(tiles-tile+1),self,-self.offset_y+8*(tiles-tile+1))
				end
				
				for tile=1, tiles do
					Orchard_alias:new(quad_array[tiles + 1 + tile],self.gx+tile,self.gy,self,-self.offset_y+8*tile,14)
				end
                -- Orchard_alias:new(tile_quads[2302],self.gx,self.gy+5,self,118+8*5)				
                -- Orchard_alias:new(tile_quads[2303],self.gx,self.gy+4,self,118+8*4)
                -- Orchard_alias:new(tile_quads[2304],self.gx,self.gy+3,self,118+8*3)
                -- Orchard_alias:new(tile_quads[2305],self.gx,self.gy+2,self,118+8*2)
                -- Orchard_alias:new(tile_quads[2306],self.gx,self.gy+1,self,118+8*1)

                -- Orchard_alias:new(tile_quads[2308],self.gx+1,self.gy,self,118+8*1,14)
                -- Orchard_alias:new(tile_quads[2309],self.gx+2,self.gy,self,118+8*2,14)
                -- Orchard_alias:new(tile_quads[2310],self.gx+3,self.gy,self,118+8*3,14)
                -- Orchard_alias:new(tile_quads[2311],self.gx+4,self.gy,self,118+8*4,14)
                -- Orchard_alias:new(tile_quads[2312],self.gx+5,self.gy,self,118+8*5,14)
				
                Orchard_alias:new(tile_quads["empty"],self.gx+5,self.gy+1,self,12+8*4,16)
                Orchard_alias:new(tile_quads["empty"],self.gx+5,self.gy+2,self,12+8*4,16)
                Orchard_alias:new(tile_quads["empty"],self.gx+5,self.gy+3,self,12+8*4,16)
                Orchard_alias:new(tile_quads["empty"],self.gx+5,self.gy+4,self,12+8*4,16)
                Orchard_alias:new(tile_quads["empty"],self.gx+5,self.gy+5,self,12+8*4,16)
                Orchard_alias:new(tile_quads["empty"],self.gx+1,self.gy+5,self,12+8*4,16)
                Orchard_alias:new(tile_quads["empty"],self.gx+2,self.gy+5,self,12+8*4,16)
                Orchard_alias:new(tile_quads["empty"],self.gx+3,self.gy+5,self,12+8*4,16)
                Orchard_alias:new(tile_quads["empty"],self.gx+4,self.gy+5,self,12+8*4,16)

				self.free_spots = 3
				self.lift_worker = nil
				self.pull_worker = nil
				self.shape_worker = nil
			end
			function Orchard:join(worker)
				if self.free_spots == 3 then
					self.lift_worker = worker
					worker.workplace = self
					self.free_spots = self.free_spots - 1
				elseif self.free_spots == 2 then
					self.pull_worker = worker
					worker.workplace = self
					self.free_spots = self.free_spots - 1
				elseif self.free_spots == 1 then
					self.shape_worker = worker
					worker.workplace = self
					self.free_spots = self.free_spots - 1
				end
			end
			function Orchard:work(worker)
				if self.lift_worker == worker then
					worker.state = "Working"
					worker.tile = tile_quads["empty"]
					worker.animated = false
					worker.gx = self.gx+3
					worker.gy = self.gy+2
					worker:job_update()
					self.lifter.tile = tile_quads["anim_quarry_lower (1)"]
				elseif self.pull_worker == worker then
					worker.state = "Working"
					worker.tile = tile_quads["empty"]
					worker.animated = false
					worker.gx = self.gx+4
					worker.gy = self.gy+3
					worker:job_update()
					self.puller.tile = tile_quads["anim_quarry_pull (1)"]
				elseif self.shape_worker == worker then
					worker.state = "Working"
					worker.tile = tile_quads["empty"]
					worker.animated = false
					worker.gx = self.gx+3
					worker.gy = self.gy+4
					worker:job_update()
					self.shaper.tile = tile_quads["anim_quarry_cut (1)"]
				end
				if self.shape_worker and self.shape_worker.state == "Working" and not self.working and
				   self.lift_worker.state == "Working" and
				   self.pull_worker.state == "Working" then
					self.working = true
					self.lifter:activate()
				end
			end
			function Orchard:send_to_stockpile()
				self.stone_quantity = 0
				local i,o,cx,cy
				self.lift_worker.state = "Go to stockpile"
				self.lift_worker.animated = true
				self.lift_worker.gx = self.gx+6
				self.lift_worker.gy = self.gy+2
				self.lift_worker.fx = (self.gx+6)*1000
				self.lift_worker.fy = (self.gy+2)*1000
				i = (self.lift_worker.gx) % (chunk_width)
				o = (self.lift_worker.gy) % (chunk_width)
				cx = math.floor(self.lift_worker.gx/chunk_width)
				cy = math.floor(self.lift_worker.gy/chunk_width)
					addObjectAt(cx, cy, i, o, self.lift_worker)
				
				self.pull_worker.state = "Go to stockpile"
				self.pull_worker.animated = true
				self.pull_worker.gx = self.gx+5
				self.pull_worker.gy = self.gy-1
				self.pull_worker.fx = (self.gx+5)*1000
				self.pull_worker.fy = (self.gy-1)*1000
				i = (self.pull_worker.gx) % (chunk_width)
				o = (self.pull_worker.gy) % (chunk_width)
				cx = math.floor(self.pull_worker.gx/chunk_width)
				cy = math.floor(self.pull_worker.gy/chunk_width)
					addObjectAt(cx, cy, i, o, self.pull_worker)

				self.shape_worker.state = "Go to stockpile"
				self.shape_worker.animated = true
				self.shape_worker.gx = self.gx+1
				self.shape_worker.gy = self.gy+6
				self.shape_worker.fx = (self.gx+1)*1000
				self.shape_worker.fy = (self.gy+6)*1000
				i = (self.shape_worker.gx) % (chunk_width)
				o = (self.shape_worker.gy) % (chunk_width)
				cx = math.floor(self.shape_worker.gx/chunk_width)
				cy = math.floor(self.shape_worker.gy/chunk_width)
					addObjectAt(cx, cy, i, o, self.shape_worker)				

				self.lifter:deactivate()
				self.puller:deactivate()
				self.shaper:deactivate()
				self.working = false
			end

return Orchard