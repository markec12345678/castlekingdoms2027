local object, tile_quads, object_batch = ...
local Object = require("objects.Object")

local fr_lifter_part1 = {
	tile_quads[139],tile_quads[150],tile_quads[161],
	tile_quads[172],tile_quads[183],tile_quads[194],
	tile_quads[205],tile_quads[207],tile_quads[208],
	tile_quads[140],
	tile_quads[141],
	tile_quads[142],
	tile_quads[143],
	tile_quads[144],
	tile_quads[145],
	tile_quads[146],
	tile_quads[147],
	tile_quads[148],
	tile_quads[149],
}
local fr_lifter_part2 = {	
	tile_quads[151],
	tile_quads[152],
	tile_quads[153],
	tile_quads[154],
	tile_quads[155],
	tile_quads[156],
	tile_quads[157],
	tile_quads[158],
	tile_quads[159],
	tile_quads[160],
	tile_quads[162],
	tile_quads[163],
	tile_quads[164],
	tile_quads[165],
	tile_quads[166],
	tile_quads[167],
	tile_quads[168],
	tile_quads[169],
	tile_quads[170],
	tile_quads[171],
}
local fr_lifter_part3 = {	
	tile_quads[173],
	tile_quads[174],
	tile_quads[175],
	tile_quads[176],
	tile_quads[177],
	tile_quads[178],
	tile_quads[179],
	tile_quads[180],
	tile_quads[181],
	tile_quads[182],
	tile_quads[184],
	tile_quads[185],
	tile_quads[186],
	tile_quads[187],
	tile_quads[188],
	tile_quads[189],
	tile_quads[190],
	tile_quads[191],
	tile_quads[192],
	tile_quads[193],
	tile_quads[195],
	tile_quads[196],
	tile_quads[197],
	tile_quads[198],
	tile_quads[199],
	tile_quads[200],
	tile_quads[201],
	tile_quads[202],
	tile_quads[203],
	tile_quads[204],
	tile_quads[206]
}
local fr_hook_part1 = {
	tile_quads[2301],
	tile_quads[270],
	tile_quads[281],
	tile_quads[292],
	tile_quads[303],
	tile_quads[314],
	tile_quads[325],
	tile_quads[328],
	tile_quads[329],
	tile_quads[330],
	tile_quads[271],
	tile_quads[272],
	tile_quads[273],
	tile_quads[274],
	tile_quads[275],
	tile_quads[276],
	tile_quads[277],
	tile_quads[278],
	tile_quads[279],
	tile_quads[280],
	tile_quads[282],
	tile_quads[283],
	tile_quads[284],
	tile_quads[285],
	tile_quads[286],
	tile_quads[287],
	tile_quads[288],
	tile_quads[289],
	tile_quads[290],
	tile_quads[291],
	tile_quads[293],
	tile_quads[294],
	tile_quads[295],
	tile_quads[296],
	tile_quads[297],
	tile_quads[298],
	tile_quads[299],
	tile_quads[300],
	tile_quads[301],
	tile_quads[302],
	tile_quads[304],
	tile_quads[305],
	tile_quads[306],
	tile_quads[307],
	tile_quads[308],
}
local fr_hook_part2 = {	
	tile_quads[309],
	tile_quads[310],
	tile_quads[311],
	tile_quads[312],
	tile_quads[313],
	tile_quads[315],
	tile_quads[316],
	tile_quads[317],
	tile_quads[318],
	tile_quads[319],
	tile_quads[320],
	tile_quads[321],
	tile_quads[322],
	tile_quads[323],
	tile_quads[324],
	tile_quads[326],
	tile_quads[327]
}
local fr_shaper = {	
	tile_quads[331],
	tile_quads[342],
	tile_quads[353],
	tile_quads[364],
	tile_quads[375],
	tile_quads[386],
	tile_quads[390],
	tile_quads[391],
	tile_quads[392],
	tile_quads[332],
	tile_quads[333],
	tile_quads[334],
	tile_quads[335],
	tile_quads[336],
	tile_quads[337],
	tile_quads[338],
	tile_quads[339],
	tile_quads[340],
	tile_quads[341],
	tile_quads[343],
	tile_quads[344],
	tile_quads[345],
	tile_quads[346],
	tile_quads[347],
	tile_quads[348],
	tile_quads[349],
	tile_quads[350],
	tile_quads[351],
	tile_quads[352],
	tile_quads[354],
	tile_quads[355],
	tile_quads[356],
	tile_quads[357],
	tile_quads[358],
	tile_quads[359],
	tile_quads[360],
	tile_quads[361],
	tile_quads[362],
	tile_quads[363],
	tile_quads[365],
	tile_quads[366],
	tile_quads[367],
	tile_quads[368],
	tile_quads[369],
	tile_quads[370],
	tile_quads[371],
	tile_quads[372],
	tile_quads[373],
	tile_quads[374],
	tile_quads[376],
	tile_quads[377],
	tile_quads[378],
	tile_quads[379],
	tile_quads[380],
	tile_quads[381],
	tile_quads[382],
	tile_quads[383],
	tile_quads[384],
	tile_quads[385],
	tile_quads[387],
	tile_quads[388],
}
local fr_puller = {
	tile_quads[209],
	tile_quads[220],
	tile_quads[231],
	tile_quads[242],
	tile_quads[253],
	tile_quads[264],
	tile_quads[267],
	tile_quads[268],
	tile_quads[269],
	tile_quads[210],
	tile_quads[211],
	tile_quads[212],
	tile_quads[213],
	tile_quads[214],
	tile_quads[215],
	tile_quads[216],
	tile_quads[217],
	tile_quads[218],
	tile_quads[219],
	tile_quads[221],
	tile_quads[222],
	tile_quads[223],
	tile_quads[224],
	tile_quads[225],
	tile_quads[226],
	tile_quads[227],
	tile_quads[228],
	tile_quads[229],
	tile_quads[230],
	tile_quads[232],
	tile_quads[233],
	tile_quads[234],
	tile_quads[235],
	tile_quads[236],
	tile_quads[237],
	tile_quads[238],
	tile_quads[239],
	tile_quads[240],
	tile_quads[241],
	tile_quads[243],
	tile_quads[244],
	tile_quads[245],
	tile_quads[246],
	tile_quads[247],
	tile_quads[248],
	tile_quads[249],
	tile_quads[250],
	tile_quads[251],
	tile_quads[252],
	tile_quads[254],
	tile_quads[255],
	tile_quads[256],
	tile_quads[257],
	tile_quads[258],
	tile_quads[259],
	tile_quads[260],
	tile_quads[261],
	tile_quads[262],
	tile_quads[263],
	tile_quads[265],
	tile_quads[266]
}
local Quarry_lifter = class('Quarry_lifter', Object)
			function Quarry_lifter:initialize(gx,gy,parent,offset_x,offset_y)
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
					self.parent.puller:activate()
					self.animation = anim.newAnimation(fr_lifter_part3,0.11,self.part3_end)
				end
				self.part1_end = function ()
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
			function Quarry_lifter:animate() 
				self.animation:update(dt) 			
			end
			function Quarry_lifter:activate()
				self.animation = anim.newAnimation(fr_lifter_part1, 0.11,self.part1_end)
			end

local Quarry_hook = class('Quarry_hook', Object)
			function Quarry_hook:initialize(gx,gy,parent,offset_x,offset_y)
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
			function Quarry_hook:animate() 
				self.animation:update(dt) 					
			end
			function Quarry_hook:activate()
				self.animation:gotoFrame(2)
				self.animation:resume()
			end

local Quarry_shaper = class('Quarry_shaper', Object)
			function Quarry_shaper:initialize(gx,gy,parent,offset_x,offset_y)
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
			function Quarry_shaper:animate() 
				self.animation:update(dt) 					
			end
			function Quarry_shaper:activate()
				self.animation:resume()
			end

local Quarry_puller = class('Quarry_puller', Object)
			function Quarry_puller:initialize(gx,gy,parent,offset_x,offset_y)
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
					self.animation:gotoFrame(1)
					self.animation:pause()
				end
				self.animation = anim.newAnimation(fr_puller,0.11,self.anim_end)
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
			function Quarry_puller:animate() 
				self.animation:update(dt) 					
			end
			function Quarry_puller:activate()
				self.animation:resume()
			end

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
				self.lifter = Quarry_lifter:new(self.gx+3,self.gy+3,self,self.offset_x,self.offset_y)
				self.hook =  Quarry_hook:new(self.gx+1,self.gy+1,self,self.offset_x,self.offset_y)
				self.shaper = Quarry_shaper:new(self.gx+2,self.gy+2,self,self.offset_x,self.offset_y)
				self.puller = Quarry_puller:new(self.gx+4,self.gy+2,self,self.offset_x,self.offset_y)
				local ccx, ccy
                for xx = -1, 4 do
					for yy = -1, 4 do 					
						ccx, ccy = terrainSetTileAt(self.gx+xx,self.gy+yy,math.random(6,8))
					end
				end
				update_terrain(ccx,ccy)
			end

return Quarry