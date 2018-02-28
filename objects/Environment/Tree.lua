local object_batch, active_objects, tile_quads, object = ...
local Object = require("objects.Object")

local frames_static = {tile_quads[1450],tile_quads[1455],tile_quads[1456],
				tile_quads[1457],tile_quads[1458],tile_quads[1459],tile_quads[1460],
				tile_quads[1461],tile_quads[1462],tile_quads[1451],tile_quads[1452],
				tile_quads[1453],tile_quads[1454],tile_quads[1452],tile_quads[1462],tile_quads[1460]} 
local frames_falling = {tile_quads[1436],tile_quads[1441],tile_quads[1442],tile_quads[1443]}
local frames_chop = {tile_quads[1444],tile_quads[1445],tile_quads[1446],tile_quads[1447],
				tile_quads[1448],tile_quads[1437],tile_quads[1438],tile_quads[1439],tile_quads[1440]}

local Tree = class('Tree', Object)
			function Tree:initialize(cx,cy,i,o,x,y,type)
				Object.initialize(self,cx,cy,i,o,x,y,type)
				self.gx = chunk_width*self.cx+self.i --warning fucking genius
				self.gy = chunk_width*self.cy+self.o
				self.health = 100				
				self.animation = anim.newAnimation(frames_static,0.13)
				self.offset_x = 0
				self.falling = false
				self.chop = false
				self.stump = false 
				self.animated = true
				self.marked = false
				self.tile = nil
				self.active = false
				self.chunk_key = false
				self.cut_down = function()
					self.falling = false
					self.chop = true
					
					self.animation = anim.newAnimation(frames_chop,0.1)
					self.animation:pause()
					end
				self.finish = function() --TODO: turn into stump object
					self.animation = anim.newAnimation({tile_quads[1449]},0.1)
					self.animation:pause()
					self.stump = true
					self.animation:update(dt)
					self.animated = false --mark for removal from list
					self:animate() --animate, because the list will remove us before we show the stump
					self.type = "Stump"
					self.tile = tile_quads[1449]
					end	
				if self.gx < 2048 and self.gx >= 0 and self.gy < 2048 and self.gy >= 0 then
					_G.collision_map[self.gx][self.gy] = 1 
					setWalkable(self.gx,self.gy,1)
				end
				if _G.chunk_objects[self.cx][self.cy] == nil then _G.chunk_objects[self.cx][self.cy] = {} end
				self.chunk_key = #chunk_objects[self.cx][self.cy] + 1
				_G.chunk_objects[self.cx][self.cy][self.chunk_key] = self
			end			
			function Tree:animate() 
				self.animation:update(dt) 					
			end
			function Tree:destroy()
				if self.chunk_key then table.remove(_G.chunk_objects,self.chunk_key) end
				object[self.cx][self.cy][self.i][self.o] = nil
				self = nil
			end
			function Tree:cut()
				if self.health > 0 then
					status[self.cx][self.cy] = 1
					self.health = self.health - 50
				elseif self.health <= 0 and self.falling == false and self.chop == false and self.stump == false then				
					status[self.cx][self.cy] = 1
					
					self.animation = anim.newAnimation(frames_falling,0.13,self.cut_down)
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
						else
							self.finish()
							self.chop = false
							return 2
						end
					end
				end

return Tree