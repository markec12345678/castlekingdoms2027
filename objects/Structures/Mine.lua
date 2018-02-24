local object, tile_quads, object_batch = ...
local Object = require("objects.Object")

local fr_bucket= {	
	tile_quads[1],
	tile_quads[12],
	tile_quads[14],
	tile_quads[15],
	tile_quads[16],
	tile_quads[17],
	tile_quads[18],
	tile_quads[19],
	tile_quads[20],
	tile_quads[2],
	tile_quads[3],
	tile_quads[4],
	tile_quads[5],
	tile_quads[6],
	tile_quads[7],
	tile_quads[8],
	tile_quads[9],
	tile_quads[10],
	tile_quads[11],
	tile_quads[13],
}
local Mine_lifter = class('Mine_lifter', Object)
			function Mine_lifter:initialize(gx,gy,parent,offset_x,offset_y)
                local mytype = "Lifter"
				local i = (gx) % (chunk_width)
				local o = (gy) % (chunk_width)
				local cx = math.floor(gx/chunk_width)
				local cy = math.floor(gy/chunk_width)				 
				local x = IsoX + (i - o) * tile_width  * 0.5
				local y = IsoY + (i + o) * tile_height * 0.5
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.animated = true
				self.part3_end = function ()
					self.animation = anim.newAnimation(fr_lifter_part1,0.11,function () self.animation:gotoFrame(1) end)
					self.animation:pause()
				end
				self.part2_end = function ()
					self.animation = anim.newAnimation(fr_lifter_part3,0.11,self.part3_end)
				end
				self.part1_end = function ()
					self.parent.puller:activate()
					self.parent.hook:activate()
					self.animation = anim.newAnimation(fr_lifter_part2,0.11,self.part2_end)
				end
				self.animation = anim.newAnimation(fr_lifter_part1, 0.11,self.part1_end)--, 'pauseAtEnd')
				self.gx = gx
				self.gy = gy
				_G.nodes[self.gx][self.gy].walkable = 1
				self.parent = parent
                self.qid = 0
				self.offset_x = 48+offset_x
				self.offset_y = 74+offset_y-64+32
				object[cx][cy][i][o] = self	
				if _G.chunk_objects[self.cx][self.cy] == nil then _G.chunk_objects[self.cx][self.cy] = {} end
				self.chunk_key = #chunk_objects[self.cx][self.cy] + 1
				_G.chunk_objects[self.cx][self.cy][self.chunk_key] = self
			end	
			function Mine_lifter:animate() 
				self.animation:update(dt) 			
			end
			function Mine_lifter:activate()
				self.animated = true
				self.animation = anim.newAnimation(fr_lifter_part1, 0.11,self.part1_end)
			end
			function Mine_lifter:deactivate()
				self.animation:pause()
				self.tile = tile_quads[0]
				self.animated = false
			end

local Mine_hook = class('Mine_hook', Object)
			function Mine_hook:initialize(gx,gy,parent,offset_x,offset_y)
                local mytype = "Hook"
				local i = (gx) % (chunk_width)
				local o = (gy) % (chunk_width)
				local cx = math.floor(gx/chunk_width)
				local cy = math.floor(gy/chunk_width)				 
				local x = IsoX + (i - o) * tile_width  * 0.5
				local y = IsoY + (i + o) * tile_height * 0.5
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.animated = true
				self.part2_end = function ()
					self.animation = anim.newAnimation(fr_hook_part1,0.11,self.part1_end)
					self.animation:pause()
					--self.parent.shaper.animation = anim.newAnimation(fr_shaper_part2,0.11,self.parent.shaper.anim_end)
				end
				self.part1_end = function () 
					self.parent.shaper:activate()
					self.animation = anim.newAnimation(fr_hook_part2,0.12,self.part2_end)				
				end
				self.animation = anim.newAnimation(fr_hook_part1,0.11,self.part1_end)
				self.animation:pause()
				self.gx = gx
				self.gy = gy
				_G.nodes[self.gx][self.gy].walkable = 1
				self.parent = parent
                self.qid = 0
				self.offset_x = 32+offset_x
				self.offset_y = 57+offset_y-15
				object[cx][cy][i][o] = self	
				if _G.chunk_objects[self.cx][self.cy] == nil then _G.chunk_objects[self.cx][self.cy] = {} end
				self.chunk_key = #chunk_objects[self.cx][self.cy] + 1
				_G.chunk_objects[self.cx][self.cy][self.chunk_key] = self
			end	
			function Mine_hook:animate() 
				self.animation:update(dt) 					
			end
			function Mine_hook:activate()
				self.animation:gotoFrame(2)
				self.animation:resume()
			end

local Mine_shaper = class('Mine_shaper', Object)
			function Mine_shaper:initialize(gx,gy,parent,offset_x,offset_y)
                local mytype = "Shaper"
				local i = (gx) % (chunk_width)
				local o = (gy) % (chunk_width)
				local cx = math.floor(gx/chunk_width)
				local cy = math.floor(gy/chunk_width)				 
				local x = IsoX + (i - o) * tile_width  * 0.5
				local y = IsoY + (i + o) * tile_height * 0.5
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.animated = true
				self.anim_end = function() 
					self.parent.lifter:activate()
					self.animation:gotoFrame(1)
					self.animation:pause()
					self.parent.stone_quantity = self.parent.stone_quantity + 1
					if self.parent.stone_quantity == 3 then
						self.parent:send_to_stockpile()
					end
				end
				self.animation = anim.newAnimation(fr_shaper,0.11,self.anim_end)
				self.animation:pause()
				self.gx = gx
				self.gy = gy
				_G.nodes[self.gx][self.gy].walkable = 1
				self.parent = parent
                self.qid = 0
				self.offset_x = -15+offset_x
				self.offset_y = 57+offset_y-2
				object[cx][cy][i][o] = self	
				if _G.chunk_objects[self.cx][self.cy] == nil then _G.chunk_objects[self.cx][self.cy] = {} end
				self.chunk_key = #chunk_objects[self.cx][self.cy] + 1
				_G.chunk_objects[self.cx][self.cy][self.chunk_key] = self
			end	
			function Mine_shaper:animate() 
				self.animation:update(dt) 					
			end
			function Mine_shaper:activate()
				self.animated = true
				self.animation:resume()
			end
			function Mine_shaper:deactivate()
				self.animation:pause()
				self.tile = tile_quads[0]
				self.animated = false
			end

local Mine_puller = class('Mine_puller', Object)
			function Mine_puller:initialize(gx,gy,parent,offset_x,offset_y)
                local mytype = "Puller"
				local i = (gx) % (chunk_width)
				local o = (gy) % (chunk_width)
				local cx = math.floor(gx/chunk_width)
				local cy = math.floor(gy/chunk_width)				 
				local x = IsoX + (i - o) * tile_width  * 0.5
				local y = IsoY + (i + o) * tile_height * 0.5
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.animated = true
				self.anim_end = function () 
					self.animation = anim.newAnimation(fr_puller_part1,0.11,self.part1_end)
					self.animation:gotoFrame(1)
					self.animation:pause()
				end
				self.part1_end = function ()
					self.animation = anim.newAnimation(fr_puller_part2,0.11,self.anim_end)
				end
				self.animation = anim.newAnimation(fr_puller_part1,0.11,self.part1_end)
				self.animation:pause()
				self.gx = gx
				self.gy = gy
				_G.nodes[self.gx][self.gy].walkable = 1
				self.parent = parent
                self.qid = 0
				self.offset_x = 92+offset_x-16-16
				self.offset_y = 58+offset_y-32-16
				object[cx][cy][i][o] = self	
				if _G.chunk_objects[self.cx][self.cy] == nil then _G.chunk_objects[self.cx][self.cy] = {} end
				self.chunk_key = #chunk_objects[self.cx][self.cy] + 1
				_G.chunk_objects[self.cx][self.cy][self.chunk_key] = self
			end	
			function Mine_puller:animate() 
				self.animation:update(dt) 					
			end
			function Mine_puller:activate()
				self.animated = true
				self.animation:resume()
			end
			function Mine_puller:deactivate()
				self.tile = tile_quads[0]
				self.animated = false
			end
local Mine_alias = class('Mine_alias', Object)
			function Mine_alias:initialize(tile,gx,gy,parent,offset_y,offset_x)
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
				object[cx][cy][i][o] = self	
			end

local Mine = class('Mine', Object)
			function Mine:initialize(cx,cy,i,o,x,y,type)
				_G.JobController:add("Stonemason",self)
                local mytype = "Static structure"
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.gx = chunk_width*self.cx+self.i
				self.gy = chunk_width*self.cy+self.o
				_G.nodes[self.gx][self.gy].walkable = 1
				self.health = 400
                self.qid = nil
                self.tile = tile_quads[2307]
				self.stone_quantity = 0
				self.working = false
				self.offset_x = 0
				self.offset_y = -7*16-6
                self.level = 1
                self.rotation = 1
				self.lifter = Mine_lifter:new(self.gx+3,self.gy+3,self,self.offset_x-64-16,self.offset_y)
				self.lifter:deactivate()
				self.shaper = Mine_shaper:new(self.gx+2,self.gy+2,self,self.offset_x-64-16,self.offset_y)
				self.shaper:deactivate()
				self.puller = Mine_puller:new(self.gx+4,self.gy+2,self,self.offset_x-64-16,self.offset_y)
				self.puller:deactivate()
				self.hook =  Mine_hook:new(self.gx+1,self.gy+1,self,self.offset_x-64-16,self.offset_y)
				local ccx, ccy
                for xx = -1, 6 do
					for yy = -1, 6 do 					
						ccx, ccy = terrainSetTileAt(self.gx+xx,self.gy+yy,math.random(6,8))
					end
				end
				update_terrain(ccx,ccy)

                Mine_alias:new(tile_quads[2302],self.gx,self.gy+5,self,118+8*5)				
                Mine_alias:new(tile_quads[2303],self.gx,self.gy+4,self,118+8*4)
                Mine_alias:new(tile_quads[2304],self.gx,self.gy+3,self,118+8*3)
                Mine_alias:new(tile_quads[2305],self.gx,self.gy+2,self,118+8*2)
                Mine_alias:new(tile_quads[2306],self.gx,self.gy+1,self,118+8*1)

                Mine_alias:new(tile_quads[2308],self.gx+1,self.gy,self,118+8*1,14)
                Mine_alias:new(tile_quads[2309],self.gx+2,self.gy,self,118+8*2,14)
                Mine_alias:new(tile_quads[2310],self.gx+3,self.gy,self,118+8*3,14)
                Mine_alias:new(tile_quads[2311],self.gx+4,self.gy,self,118+8*4,14)
                Mine_alias:new(tile_quads[2312],self.gx+5,self.gy,self,118+8*5,14)
				
                Mine_alias:new(tile_quads[0],self.gx+5,self.gy+1,self,12+8*4,16)
                Mine_alias:new(tile_quads[0],self.gx+5,self.gy+2,self,12+8*4,16)
                Mine_alias:new(tile_quads[0],self.gx+5,self.gy+3,self,12+8*4,16)
                Mine_alias:new(tile_quads[0],self.gx+5,self.gy+4,self,12+8*4,16)
                Mine_alias:new(tile_quads[0],self.gx+5,self.gy+5,self,12+8*4,16)
                Mine_alias:new(tile_quads[0],self.gx+1,self.gy+5,self,12+8*4,16)
                Mine_alias:new(tile_quads[0],self.gx+2,self.gy+5,self,12+8*4,16)
                Mine_alias:new(tile_quads[0],self.gx+3,self.gy+5,self,12+8*4,16)
                Mine_alias:new(tile_quads[0],self.gx+4,self.gy+5,self,12+8*4,16)

				self.free_spots = 3
				self.lift_worker = nil
				self.pull_worker = nil
				self.shape_worker = nil
			end
			function Mine:join(worker)
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
			function Mine:work(worker)
				if self.lift_worker == worker then
					worker.state = "Working"
					worker.tile = tile_quads[0]
					worker.animated = false
					worker.gx = self.gx+3
					worker.gy = self.gy+2
					worker:job_update()
					self.lifter.tile = tile_quads[139]
				elseif self.pull_worker == worker then
					worker.state = "Working"
					worker.tile = tile_quads[0]
					worker.animated = false
					worker.gx = self.gx+4
					worker.gy = self.gy+3
					worker:job_update()
					self.puller.tile = tile_quads[246]
				elseif self.shape_worker == worker then
					worker.state = "Working"
					worker.tile = tile_quads[0]
					worker.animated = false
					worker.gx = self.gx+3
					worker.gy = self.gy+4
					worker:job_update()
					self.shaper.tile = tile_quads[331]
				end
				if self.shape_worker and self.shape_worker.state == "Working" and not self.working and
				   self.lift_worker.state == "Working" and
				   self.pull_worker.state == "Working" then
					self.working = true
					self.lifter:activate()
				end
			end
			function Mine:send_to_stockpile()
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
					object[cx][cy][i][o] = self.lift_worker
				
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
					object[cx][cy][i][o] = self.pull_worker

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
					object[cx][cy][i][o] = self.shape_worker				

				self.lifter:deactivate()
				self.puller:deactivate()
				self.shaper:deactivate()
				self.working = false
			end

return Mine