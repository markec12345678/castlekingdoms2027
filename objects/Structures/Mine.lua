local object, tile_quads, object_batch = ...
local Object = require("objects.Object")

local fr_pouring= {	
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
local fr_bucket = {	
	tile_quads[21],
	tile_quads[22],
	tile_quads[23],
	tile_quads[24],
	tile_quads[25],
	tile_quads[26],
	tile_quads[27],
	tile_quads[28],
}
local fr_casting_iron = {	
	tile_quads[29],
	tile_quads[40],
	tile_quads[46],
	tile_quads[47],
	tile_quads[48],
	tile_quads[49],
	tile_quads[50],
	tile_quads[51],
	tile_quads[52],
	tile_quads[30],
	tile_quads[31],
	tile_quads[32],
	tile_quads[33],
	tile_quads[34],
	tile_quads[35],
	tile_quads[36],
	tile_quads[37],
	tile_quads[38],
	tile_quads[39],
	tile_quads[41],
	tile_quads[42],
	tile_quads[43],
	tile_quads[44],
	tile_quads[45],
}
local fr_miner_going_down = {
	tile_quads[53],
	tile_quads[64],
	tile_quads[75],
	tile_quads[85],
	tile_quads[86],
	tile_quads[87],
	tile_quads[88],
	tile_quads[89],
	tile_quads[90],
	tile_quads[55],
	tile_quads[56],
	tile_quads[57],
	tile_quads[58],
	tile_quads[59],
	tile_quads[60],
	tile_quads[61],
	tile_quads[62],
	tile_quads[63],
	tile_quads[65],
	tile_quads[66],
	tile_quads[67],
	tile_quads[68],
	tile_quads[69],
	tile_quads[70],
	tile_quads[71],
	tile_quads[72],
	tile_quads[73],
	tile_quads[74],
	tile_quads[76],
	tile_quads[77],
	tile_quads[78],
	tile_quads[79],
	tile_quads[80],
	tile_quads[81],
	tile_quads[82],
	tile_quads[83],
	tile_quads[84],
}local fr_miner_going_up = {
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[53],
	tile_quads[84],
	tile_quads[83],
	tile_quads[82],
	tile_quads[81],
	tile_quads[80],
	tile_quads[79],
	tile_quads[78],
	tile_quads[77],
	tile_quads[76],
	tile_quads[74],
	tile_quads[73],
	tile_quads[72],
	tile_quads[71],
	tile_quads[70],
	tile_quads[69],
	tile_quads[68],
	tile_quads[67],
	tile_quads[66],
	tile_quads[65],
	tile_quads[63],
	tile_quads[62],
	tile_quads[61],
	tile_quads[60],
	tile_quads[59],
	tile_quads[58],
	tile_quads[57],
	tile_quads[56],
	tile_quads[55],
	tile_quads[90],
	tile_quads[89],
	tile_quads[88],
	tile_quads[87],
	tile_quads[86],
	tile_quads[85],
	tile_quads[75],
	tile_quads[64],
}
local fr_miner_pulling = {
    tile_quads[91],
    tile_quads[95],
    tile_quads[96],
    tile_quads[97],
    tile_quads[98],
    tile_quads[99],
    tile_quads[100],
    tile_quads[101],
    tile_quads[102],
    tile_quads[92],
    tile_quads[93],
    tile_quads[94],
}
local fr_stack = {
    tile_quads[132],
    tile_quads[133],
    tile_quads[134],
    tile_quads[135],
    tile_quads[136],
    tile_quads[137],
    tile_quads[138],
    tile_quads[131],
}

local Mine_going_down = class('Mine_going_down', Object)
			function Mine_going_down:initialize(gx,gy,parent,offset_x,offset_y)
                local mytype = "Animation"
				local i = (gx) % (chunk_width)
				local o = (gy) % (chunk_width)
				local cx = math.floor(gx/chunk_width)
				local cy = math.floor(gy/chunk_width)				 
				local x = IsoX + (i - o) * tile_width  * 0.5
				local y = IsoY + (i + o) * tile_height * 0.5
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.animated = true
				self.anim_end = function ()
					self.animation:pause()
                    self:deactivate()
                    self.parent.puller:activate()
                    self.parent.bucket:activate()            
				end
				self.part1_end = function()
					self.animation = anim.newAnimation(fr_miner_going_up, 0.11, self.anim_end)
				end
				self.animation = anim.newAnimation(fr_miner_going_down, 0.11, self.part1_end)
				self.gx = gx
				self.gy = gy
					setWalkable(self.gx,self.gy,1)
				self.parent = parent
                self.qid = 0
				self.offset_x = 13+offset_x-48
				self.offset_y = 6+offset_y-32-16
				addObjectAt(cx, cy, i, o, self)	
				if _G.chunk_objects[self.cx][self.cy] == nil then _G.chunk_objects[self.cx][self.cy] = {} end
				self.chunk_key = #chunk_objects[self.cx][self.cy] + 1
				_G.chunk_objects[self.cx][self.cy][self.chunk_key] = self
			end	
			function Mine_going_down:animate() 
				self.animation:update(dt) 			
			end
			function Mine_going_down:activate()       
				self.animated = true
				self.animation = anim.newAnimation(fr_miner_going_down, 0.11,self.part1_end)
			end
			function Mine_going_down:deactivate()
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
				self.part1_end = function ()
                    self.animation:pause()
                    self.parent.pourer:activate()
                    self:deactivate()
                    self.parent.bucket:deactivate()
				end
				self.animation = anim.newAnimation(fr_miner_pulling,0.11,self.part1_end)
				self.animation:pause()
				self.gx = gx
				self.gy = gy
					setWalkable(self.gx,self.gy,1)
				self.parent = parent
                self.qid = 0
				self.offset_x = 13+offset_x+32+32-48
				self.offset_y = -2+offset_y-32+8
				addObjectAt(cx, cy, i, o, self)	
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
local Mine_bucket = class('Mine_bucket', Object)
			function Mine_bucket:initialize(gx,gy,parent,offset_x,offset_y)
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
				end
				self.animation = anim.newAnimation(fr_bucket,0.19)		
				self.animation:pause()
				self.gx = gx
				self.gy = gy
					setWalkable(self.gx,self.gy,1)
				self.parent = parent
                self.qid = 0
				self.offset_x = -3+offset_x+48+32-48
				self.offset_y = -8+offset_y-32
				addObjectAt(cx, cy, i, o, self)	
				if _G.chunk_objects[self.cx][self.cy] == nil then _G.chunk_objects[self.cx][self.cy] = {} end
				self.chunk_key = #chunk_objects[self.cx][self.cy] + 1
				_G.chunk_objects[self.cx][self.cy][self.chunk_key] = self
			end	
			function Mine_bucket:animate() 
				self.animation:update(dt) 					
			end
			function Mine_bucket:activate()
                self.animated = true
				self.animation:gotoFrame(1)
				self.animation:resume()
			end
			function Mine_bucket:deactivate()
				self.animation:pause()
				self.tile = tile_quads[0]
				self.animated = false
			end

local Mine_pourer = class('Mine_pourer', Object)
			function Mine_pourer:initialize(gx,gy,parent,offset_x,offset_y)
                local mytype = "Animation"
				local i = (gx) % (chunk_width)
				local o = (gy) % (chunk_width)
				local cx = math.floor(gx/chunk_width)
				local cy = math.floor(gy/chunk_width)				 
				local x = IsoX + (i - o) * tile_width  * 0.5
				local y = IsoY + (i + o) * tile_height * 0.5
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.animated = true
				self.part2_end = function ()
					self:deactivate()
					--self.parent.shaper.animation = anim.newAnimation(fr_shaper_part2,0.11,self.parent.shaper.anim_end)
				end
				self.part1_end = function () 
					self.animation = anim.newAnimation({tile_quads[13]},0.1,self.part2_end)		
					self.parent.casting:activate()
					if self.parent.stack.quantity < 7 then
						self.parent.going_down:activate()
					else
						self.parent.unloading = true
						self.parent:send_to_stockpile()
					end		
				end
				self.animation = anim.newAnimation(fr_pouring,0.11,self.part1_end)		
				self.animation:pause()
				self.gx = gx
				self.gy = gy
					setWalkable(self.gx,self.gy,1)
				self.parent = parent
                self.qid = 0
				self.offset_x = 13+offset_x+48+32-48
				self.offset_y = -13+offset_y-16
				addObjectAt(cx, cy, i, o, self)		
				if _G.chunk_objects[self.cx][self.cy] == nil then _G.chunk_objects[self.cx][self.cy] = {} end
				self.chunk_key = #chunk_objects[self.cx][self.cy] + 1
				_G.chunk_objects[self.cx][self.cy][self.chunk_key] = self
			end	
			function Mine_pourer:animate() 
				self.animation:update(dt) 					
			end
			function Mine_pourer:activate()
				self.animation = anim.newAnimation(fr_pouring,0.11,self.part1_end)		
                self.animated = true
				self.animation:gotoFrame(1)
				self.animation:resume()
			end
			function Mine_pourer:deactivate()
				self.animation:pause()
				self.tile = tile_quads[0]
				self.animated = false
			end
local Mine_casting = class('Mine_casting', Object)
			function Mine_casting:initialize(gx,gy,parent,offset_x,offset_y)
                local mytype = "Animation"
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
					if not self.parent.stack.animated then
						self.parent.stack:activate()	
					end
					self.parent.stack:stack()
					self:deactivate()		
				end
				self.animation = anim.newAnimation(fr_casting_iron,0.11,self.part1_end)		
				self.animation:pause()
				self.gx = gx
				self.gy = gy
					setWalkable(self.gx,self.gy,1)
				self.parent = parent
                self.qid = 0
				self.offset_x = 49+offset_x-16-48
				self.offset_y = 11+offset_y-64
				addObjectAt(cx, cy, i, o, self)	
				if _G.chunk_objects[self.cx][self.cy] == nil then _G.chunk_objects[self.cx][self.cy] = {} end
				self.chunk_key = #chunk_objects[self.cx][self.cy] + 1
				_G.chunk_objects[self.cx][self.cy][self.chunk_key] = self
			end	
			function Mine_casting:animate() 
				self.animation:update(dt) 					
			end
			function Mine_casting:activate()
                self.animated = true
				self.animation:gotoFrame(1)
				self.animation:resume()
			end
			function Mine_casting:deactivate()
				self.animation:pause()
				self.tile = tile_quads[0]
				self.animated = false
			end
local Mine_stack = class('Mine_stack', Object)
			function Mine_stack:initialize(gx,gy,parent,offset_x,offset_y)
                local mytype = "Animatino"
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
					--self.parent.stack:activate()			
				end
				self.animation = anim.newAnimation(fr_stack,0.11,self.part1_end)		
				self.animation:pause()
				self.quantity = 0
				self.gx = gx
				self.gy = gy
					setWalkable(self.gx,self.gy,1)
				self.parent = parent
                self.qid = 0
				self.offset_x = 49+offset_x-16-48
				self.offset_y = 11+offset_y-32-8+3
				addObjectAt(cx, cy, i, o, self)		
				if _G.chunk_objects[self.cx][self.cy] == nil then _G.chunk_objects[self.cx][self.cy] = {} end
				self.chunk_key = #chunk_objects[self.cx][self.cy] + 1
				_G.chunk_objects[self.cx][self.cy][self.chunk_key] = self
			end	
			function Mine_stack:stack()
				self.quantity = self.quantity + 1
				self.animation:gotoFrame(self.quantity)
			end
			function Mine_stack:animate() 
				self.animation:update(dt) 					
			end
			function Mine_stack:activate()
                self.animated = true
				self.animation:gotoFrame(1)
				self.animation:pause()
			end
			function Mine_stack:deactivate()
				self.animation:pause()
				self.tile = tile_quads[0]
				self.animated = false
			end
			function Mine_stack:take()
				self.quantity = self.quantity - 1
				if self.quantity == 0 then 
					self:deactivate()
					self.parent.unloading = false
					return
				end
				self.animation:gotoFrame(self.quantity)
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

local Mine = class('Mine', Object)
			function Mine:initialize(cx,cy,i,o,x,y,type)
				_G.JobController:add("Miner",self)
                local mytype = "Static structure"
				Object.initialize(self,cx,cy,i,o,x,y,mytype)
				self.gx = chunk_width*self.cx+self.i
				self.gy = chunk_width*self.cy+self.o
					setWalkable(self.gx,self.gy,1)
				self.health = 400
                self.qid = nil
                self.tile = tile_quads[2316]
				self.stone_quantity = 0
				self.working = false
				self.unloading = false
				self.offset_x = 0
				self.offset_y = -64+16+4
                self.level = 1
                self.rotation = 1
				self.pourer = Mine_pourer:new(self.gx+1,self.gy+1,self,self.offset_x-64-16,self.offset_y)
                self.pourer:deactivate()
				self.going_down = Mine_going_down:new(self.gx+3,self.gy+3,self,self.offset_x,self.offset_y)
				self.going_down:deactivate()
				self.puller = Mine_puller:new(self.gx+2,self.gy+1,self,self.offset_x-64-16,self.offset_y)
				self.puller:deactivate()
				self.bucket = Mine_bucket:new(self.gx+2,self.gy+2,self,self.offset_x-64-16,self.offset_y)
				self.bucket:deactivate()
				self.casting = Mine_casting:new(self.gx+2,self.gy+3,self,self.offset_x,self.offset_y)
                self.casting:deactivate()
				self.stack = Mine_stack:new(self.gx+3,self.gy+2,self,self.offset_x,self.offset_y)
                self.stack:deactivate()
				local ccx, ccy
                for xx = -1, 4 do
					for yy = -1, 4 do 					
						ccx, ccy = terrainSetTileAt(self.gx+xx,self.gy+yy,math.random(6,8))
					end
				end
				update_terrain(ccx,ccy)

                Mine_alias:new(tile_quads[2313],self.gx,self.gy+3,self,-(-64+16+4)+8*3)				
                Mine_alias:new(tile_quads[2314],self.gx,self.gy+2,self,-(-64+16+4)+8*2)
                Mine_alias:new(tile_quads[2315],self.gx,self.gy+1,self,-(-64+16+4)+8*1)

                Mine_alias:new(tile_quads[2317],self.gx+1,self.gy,self,-(-64+16+4)+8*1,14)
                Mine_alias:new(tile_quads[2318],self.gx+2,self.gy,self,-(-64+16+4)+8*2,14)
                Mine_alias:new(tile_quads[2319],self.gx+3,self.gy,self,-(-64+16+4)+8*3,14)
				
                Mine_alias:new(tile_quads[0],self.gx+1,self.gy+3,self,12+8*4,16)
                Mine_alias:new(tile_quads[0],self.gx+3,self.gy+1,self,12+8*4,16)

				self.free_spots = 1
				self.worker = nil
			end
			function Mine:join(worker)
				if self.free_spots == 1 then
					self.worker = worker
					worker.workplace = self
					self.free_spots = self.free_spots - 1
				end
			end
			function Mine:work(worker)
				if self.unloading then 					
					self.worker.state = "Go to stockpile"
					self.stack:take()
					return
				end
				worker.state = "Working"
				worker.tile = tile_quads[0]
				worker.animated = false
				worker.gx = self.gx+1
				worker.gy = self.gy+2
				worker:job_update()
				--self.lifter.tile = tile_quads[139]
				
				if not self.working and self.worker.state == "Working" then
					self.working = true
					self.going_down:activate()
				end
			end
			function Mine:send_to_stockpile()
				local i,o,cx,cy
				self.worker.state = "Go to stockpile"
				self.worker.animated = true
				self.worker.gx = self.gx-1
				self.worker.gy = self.gy+1
				self.worker.fx = (self.gx-1)*1000
				self.worker.fy = (self.gy+1)*1000
				i = (self.worker.gx) % (chunk_width)
				o = (self.worker.gy) % (chunk_width)
				cx = math.floor(self.worker.gx/chunk_width)
				cy = math.floor(self.worker.gy/chunk_width)
					addObjectAt(cx, cy, i, o, self.worker)					
				self.stack:take()
				self.going_down:deactivate()
				self.working = false
			end

return Mine