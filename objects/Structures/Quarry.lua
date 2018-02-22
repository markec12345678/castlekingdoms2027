local object, tile_quads, object_batch = ...
local Object = require("objects.Object")

local fr_lifter = {
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
	tile_quads[206],
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
				self.animation = anim.newAnimation(fr_lifter, 0.11)--, 'pauseAtEnd')
				self.gx = gx
				self.gy = gy
				_G.nodes[self.gx][self.gy].walkable = 1
				self.parent = parent
                self.qid = 0
				self.offset_x = 48+offset_x
				self.offset_y = 74+offset_y
				object[cx][cy][i][o] = self	
				if _G.chunk_objects[self.cx][self.cy] == nil then _G.chunk_objects[self.cx][self.cy] = {} end
				self.chunk_key = #chunk_objects[self.cx][self.cy] + 1
				_G.chunk_objects[self.cx][self.cy][self.chunk_key] = self
			end	
			function Quarry_lifter:animate() 
				self.animation:update(dt) 					
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
				Quarry_lifter:new(self.gx+1,self.gy+1,self,self.offset_x,self.offset_y)
				local ccx, ccy
                for xx = -1, 4 do
					for yy = -1, 4 do 					
						ccx, ccy = terrainSetTileAt(self.gx+xx,self.gy+yy,math.random(6,8))
					end
				end
				update_terrain(ccx,ccy)
			end

return Quarry