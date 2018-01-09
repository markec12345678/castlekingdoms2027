local object_batch, active_objects, tile_quads = ...
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
				self.cut_down = function() 
					print("Cut!")
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
					print("Done!")
					end
				table.insert(active_objects,self)
				end
			function Tree:ser()
				local table_to_serialize = {}
				table_to_serialize.cx = self.cx
				table_to_serialize.cy = self.cy
				table_to_serialize.i = self.i
				table_to_serialize.o = self.o
				table_to_serialize.x = self.x
				table_to_serialize.y = self.y
				table_to_serialize.type = self.type
				table_to_serialize.stump = self.stump
				table_to_serialize.health = self.health
				table_to_serialize.y = self.y
				table_to_serialize.class = "Tree"
				--TODO: turn from tree to stump when cut down to ease on serialization
				return table_to_serialize				
				end
			function Tree:animate()
				self.animation:update(dt)
				object_batch[self.cx][self.cy]
					:set(self.qid,self.animation:getFrameInfo(self.x-self.offset_x,self.y))
				self.offset_x = 0
				end
			function Tree:cut() --TODO return value to chopper
				if self.health > 0 then
					self.health = self.health - 10
					self.offset_x = 4+math.random(2)
					--self.animation:gotoFrame(4)
					print("Cutting down!", self.gx,self.gy)
				elseif self.health <= 0 and self.falling == false and self.chop == false and self.stump == false then
					self.frames = {tile_quads[1436],tile_quads[1441],
					tile_quads[1442],tile_quads[1443]}
					self.animation = anim.newAnimation(self.frames,0.13,self.cut_down)
					self.falling = true
					end
				if self.chop then 
						print("Chopping!")
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