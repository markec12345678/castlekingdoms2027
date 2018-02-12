local object_batch, active_objects, tile_quads, object = ...
local Object = require("objects.Object")
local Tree = class('Tree', Object)
			function Tree:initialize(cx,cy,i,o,x,y,type)
				Object.initialize(self,cx,cy,i,o,x,y,type)
				self.gx = chunk_width*self.cx+self.i --warning fucking genius
				self.gy = chunk_width*self.cy+self.o
				self.health = 100
				self.frames = {tile_quads[1450],tile_quads[1455],tile_quads[1456]
				,tile_quads[1457],tile_quads[1458],tile_quads[1459],tile_quads[1460]
				,tile_quads[1461],tile_quads[1462],tile_quads[1451],tile_quads[1452]
				,tile_quads[1453],tile_quads[1454],tile_quads[1452],tile_quads[1462],tile_quads[1460]} 
				self.animation = anim.newAnimation(self.frames,0.13)
				self.offset_x = 0
				self.falling = false
				self.chop = false
				self.stump = false 
				self.animated = true
				self.marked = false
				self.active = false
				self.cut_down = function()
					self.falling = false
					self.chop = true
					self.frames = {tile_quads[1444],tile_quads[1445],tile_quads[1446],tile_quads[1447],
					tile_quads[1448],tile_quads[1437],tile_quads[1438],tile_quads[1439],tile_quads[1440]}
					self.animation = anim.newAnimation(self.frames,0.1)
					self.animation:pause()
					end
				self.finish = function()
					self.frames = {tile_quads[1449]}
					self.animation = anim.newAnimation(self.frames,0.1)
					self.animation:pause()
					self.stump = true
					self.animation:update(dt)
					self.animated = false --mark for removal from list
					self:animate() --animate, because the list will remove us before we show the stump
					self.type = "Stump"
					end	
				if self.gx < 2048 and self.gx >= 0 and self.gy < 2048 and self.gy >= 0 then
				_G.collision_map[self.gx][self.gy] = 1 _G.nodes[self.gx][self.gy].walkable = 1 end
				if _G.chunk_objects[self.cx][self.cy] == nil then _G.chunk_objects[self.cx][self.cy] = {} end
				table.insert(_G.chunk_objects[self.cx][self.cy],self)
			end
			function Tree:activate()
				-- if not self.active then
				-- 	table.insert(active_objects,self)
				-- 	self.active = true
				-- end
			end
			function Tree:serialize()
				local table_to_serialize = {}
				-- table_to_serialize.cx = self.cx
				-- table_to_serialize.cy = self.cy
				-- table_to_serialize.i = self.i
				-- table_to_serialize.o = self.o
				-- table_to_serialize.x = self.x
				-- table_to_serialize.y = self.y
				-- table_to_serialize.type = self.type
				-- table_to_serialize.health = self.health
				-- table_to_serialize.animated = self.animated
				-- table_to_serialize.chop = self.chop
				-- if self.chop then table_to_serialize.current_frame = self.animation:getCurrentFrame() end
				-- table_to_serialize.class = "Tree"
				--TODO: turn from tree to stump when cut down to ease on serialization
				return table_to_serialize			
				end
			function Tree:deserialize(table_to_deserialize)
				self.cx = table_to_deserialize.cx
				self.cy = table_to_deserialize.cy
				self.i = table_to_deserialize.i
				self.o = table_to_deserialize.o
				self.x = table_to_deserialize.x
				self.y = table_to_deserialize.y
				self.type = table_to_deserialize.type
				self.health = table_to_deserialize.health
				self.chop = table_to_deserialize.chop		
				self.animated = table_to_deserialize.animated
				if self.type == "Stump" then self.finish() 	
				elseif self.chop then 
					self.frames = {tile_quads[1444],tile_quads[1445],tile_quads[1446],tile_quads[1447],
					tile_quads[1448],tile_quads[1437],tile_quads[1438],tile_quads[1439],tile_quads[1440]}
					self.animation = anim.newAnimation(self.frames,0.1)
					self.animation:pause()
					self.animation:gotoFrame(table_to_deserialize.current_frame)
				else self.animation:gotoFrame(math.random(6)) end
				object[self.cx][self.cy][self.i][self.o] = self				
				if self.animated then table.insert(active_objects,self) end	
				end
			function Tree:animate() 
					self.animation:update(dt) 					
				end
			function Tree:cut()
				if self.health > 0 then
					status[self.cx][self.cy] = 1
					self.health = self.health - 50
				elseif self.health <= 0 and self.falling == false and self.chop == false and self.stump == false then				
					status[self.cx][self.cy] = 1
					self.frames = {tile_quads[1436],tile_quads[1441],
					tile_quads[1442],tile_quads[1443]}
					self.animation = anim.newAnimation(self.frames,0.13,self.cut_down)
					self.falling = true
					if (self.cx > current_chunk_x+1) or (self.cx < current_chunk_x-1)
					or (self.cy > current_chunk_y+1) or (self.cy < current_chunk_y-1) then
						self.chop = true
						self.falling = false
					end
				end
				if self.chop then 						
					status[self.cx][self.cy] = 1
						if self.animation:getTotalFrames() ~= self.animation:getCurrentFrame() then
							self.animation:gotoFrame(self.animation:getCurrentFrame()+1)
							wood = wood + 1
						else
							self.finish()
							self.chop = false
							wood = wood + 1
							return 2
						end
					end
				end

return Tree