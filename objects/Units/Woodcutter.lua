local object, tile_quads = ...
local Unit = require("objects.Units.Unit")
local fr_walking_plank_east = indexQuad("body_woodcutter_walk_plank_e", 16)
local fr_walking_plank_north = indexQuad("body_woodcutter_walk_plank_n", 16)
local fr_walking_plank_west = indexQuad("body_woodcutter_walk_plank_w", 16)
local fr_walking_plank_south = indexQuad("body_woodcutter_walk_plank_s", 16)
local fr_walking_plank_northeast = indexQuad("body_woodcutter_walk_plank_ne", 16)
local fr_walking_plank_northwest = indexQuad("body_woodcutter_walk_plank_nw", 16)
local fr_walking_plank_southeast = indexQuad("body_woodcutter_walk_plank_se", 16)
local fr_walking_plank_southwest = indexQuad("body_woodcutter_walk_plank_sw", 16)
local fr_walking_east = indexQuad("body_woodcutter_walk_e", 16)
local fr_walking_north = indexQuad("body_woodcutter_walk_n", 16)
local fr_walking_northeast = indexQuad("body_woodcutter_walk_ne", 16)
local fr_walking_northwest = indexQuad("body_woodcutter_walk_nw", 16)
local fr_walking_south = indexQuad("body_woodcutter_walk_s", 16)
local fr_walking_southeast = indexQuad("body_woodcutter_walk_se", 16)
local fr_walking_southwest = indexQuad("body_woodcutter_walk_sw", 16)
local fr_walking_west = indexQuad("body_woodcutter_walk_w", 16)
local fr_cutting_northeast = indexQuad("body_woodcutter_cut_ne", 16)


local Woodcutter = class('Woodcutter', Unit)
function Woodcutter:initialize(cx,cy,i,o,x,y,type)
	Unit.initialize(self,cx,cy,i,o,x,y,type, "No trees")
	self.an_walking_plank_west = anim.newAnimation(fr_walking_plank_west,0.11) 
	self.an_walking_west = anim.newAnimation(fr_walking_west,0.11)
	self.an_walking_plank_southwest = anim.newAnimation(fr_walking_plank_southwest,0.11)
	self.an_walking_southwest = anim.newAnimation(fr_walking_southwest,0.11)
	self.an_walking_plank_northwest = anim.newAnimation(fr_walking_plank_northwest,0.11)
	self.an_walking_northwest = anim.newAnimation(fr_walking_northwest,0.11)
	self.an_walking_plank_north = anim.newAnimation(fr_walking_plank_north,0.11)
	self.an_walking_north = anim.newAnimation(fr_walking_north,0.11)
	self.an_walking_plank_south = anim.newAnimation(fr_walking_plank_south,0.11)
	self.an_walking_south = anim.newAnimation(fr_walking_south,0.11)
	self.an_walking_plank_east = anim.newAnimation(fr_walking_plank_east,0.11)
	self.an_walking_east = anim.newAnimation(fr_walking_east,0.11)
	self.an_walking_plank_southeast = anim.newAnimation(fr_walking_plank_southeast,0.11)
	self.an_walking_southeast = anim.newAnimation(fr_walking_southeast,0.11)
	self.an_walking_plank_northeast = anim.newAnimation(fr_walking_plank_northeast,0.11)
	self.an_walking_northeast = anim.newAnimation(fr_walking_northeast,0.11)
	self.state = 'Looking to chop tree'
	self.marked = 0
	self.count = 1
	self.timr = 0
	self.offset_x = -5
	self.offset_y = -10
	self.target_tree = 0
	self.cut = function() 
		if self.state == "Cutting down" then
			local tree_progress = 0
			if self.target_tree.type == "Pine tree" then
			tree_progress = self.target_tree:cut() else
			self.state = "Looking to chop tree"
				self.move_dir = "none"
			end
			if tree_progress == 2 then
				self.i = (self.fx*0.001)%chunk_width
				self.o = (self.fy*0.001)%chunk_width
				self.move_dir = "none"
				self.count = 1
				tree_progress = 3
					if _G.stockpile then
						self.state = "Going to stockpile"
						local closest_node
						local distance = math.huge
						for k,v in ipairs(_G.stockpile.node_list) do
							local tmp = manhattan_distance(v.gx,v.gy,self.gx,self.gy)
							if tmp < distance then
								distance = tmp
								closest_node = v
							end
						end
						if not closest_node then self.state = "Looking to chop tree" else      
						self:requestPath(closest_node.gx,closest_node.gy) end
					else self.state = "Looking to chop tree" end
			end
		else --print("State", self.state)
		end
	end
	self.animation = anim.newAnimation(fr_walking_west,10)
end 
function Woodcutter:check_trees(cx,cy)
	local chunkx,chunky = cx or self.cx, cy or self.cy
	local closest_object, closest_distance = nil,10000000
	if _G.chunk_objects[chunkx][chunky] then
		for index, obj in pairs ( _G.chunk_objects[chunkx][chunky] ) do 
			if obj.type == 'Pine tree' and obj.marked == false then
				-- TODO: Fix magic numbers CRITICAL
				if obj.gx > 0 and obj.gx < 2047 and obj.gy > 0 and obj.gy < 2047 then --and _G.nodes[obj.gx][obj.gy+1].walkable == 0 then --fixme
					local dist = manhattan_distance(self.gx,self.gy, obj.gx, obj.gy)
					if dist < closest_distance then 
						closest_object = obj
						closest_distance = dist
					end
				end
			end
		end
	end
	if not closest_object then return false,false else return closest_object,closest_distance end
end
function Woodcutter:find_tree()
	local closest_object, closest_distance = nil,10000000
	local objt,disto
		objt,disto = self:check_trees(self.cx,self.cy)
		if disto and disto < closest_distance then  
				closest_object = objt
				closest_distance = disto
		end
		objt,disto = self:check_trees(self.cx+1,self.cy)
		if disto and disto < closest_distance then  
				closest_object = objt
				closest_distance = disto
		end
		objt,disto = self:check_trees(self.cx+1,self.cy+1)
		if disto and disto < closest_distance then  
				closest_object = objt
				closest_distance = disto
		end
		objt,disto = self:check_trees(self.cx+1,self.cy-1)
		if disto and disto < closest_distance then  
				closest_object = objt
				closest_distance = disto
		end
		objt,disto = self:check_trees(self.cx-1,self.cy+1)
		if disto and disto < closest_distance then  
				closest_object = objt
				closest_distance = disto
		end
		objt,disto = self:check_trees(self.cx-1,self.cy)
		if disto and disto < closest_distance then  
				closest_object = objt
				closest_distance = disto
		end
		objt,disto = self:check_trees(self.cx-1,self.cy-1)
		if disto and disto < closest_distance then  
				closest_object = objt
				closest_distance = disto
		end
		objt,disto = self:check_trees(self.cx,self.cy+1)
		if disto and disto < closest_distance then  
				closest_object = objt
				closest_distance = disto
		end
		objt,disto = self:check_trees(self.cx,self.cy-1)
		if disto and disto < closest_distance then  
				closest_object = objt
				closest_distance = disto
		end
	if not closest_object then print("No trees nearby!") self.state = "No trees" return end
	self.target_tree = closest_object 
	self.endx = closest_object.gx
	self.endy = closest_object.gy+1
	self:requestPath(self.endx,self.endy) 
	self.state = "Going to tree"
	closest_object.marked = true
end
function Woodcutter:dir_sub_update()
	if self.move_dir == "west" then
		if self.state == "Going to stockpile" then
			self.animation = self.an_walking_plank_west 
		else
			self.animation = self.an_walking_west
		end
	elseif self.move_dir == "southwest" then
		if self.state == "Going to stockpile" then
			self.animation = self.an_walking_plank_southwest
		else
			self.animation = self.an_walking_southwest
		end
	elseif self.move_dir == "northwest" then
		if self.state == "Going to stockpile" then
			self.animation = self.an_walking_plank_northwest
		else
			self.animation = self.an_walking_northwest
		end
	elseif self.move_dir == "north" then
		if self.state == "Going to stockpile" then
			self.animation = self.an_walking_plank_north
		else
			self.animation = self.an_walking_north
		end
	elseif self.move_dir == "south" then
		if self.state == "Going to stockpile" then
			self.animation = self.an_walking_plank_south
		else
			self.animation = self.an_walking_south
		end
	elseif self.move_dir == "east" then
		if self.state == "Going to stockpile" then
			self.animation = self.an_walking_plank_east
		else
			self.animation = self.an_walking_east
		end
	elseif self.move_dir == "southeast" then
		if self.state == "Going to stockpile" then
			self.animation = self.an_walking_plank_southeast
		else
			self.animation = self.an_walking_southeast
		end
	elseif self.move_dir == "northeast" then
		if self.state == "Going to stockpile" then
			self.animation = self.an_walking_plank_northeast
		else
			self.animation = self.an_walking_northeast
		end
	end
end
function Woodcutter:update()
	if self.path_state == "Waiting for path" then
		self:pathfind()
	elseif self.state ~= "No trees" then
		if self.state == "Looking to chop tree" then
			self:find_tree()
		elseif self.move_dir == "none" and self.state == "Going to tree" then
			self:update_direction()
			self:dir_sub_update()
		elseif self.move_dir == "none" and self.state == "Going to stockpile" then
			self:update_direction()
			self:dir_sub_update()
		end
		self.timr = self.timr + 1
		self.timr = self.timr % 60
		if self.state == "Going to tree" or self.state == "Going to stockpile" then
			self:move()
		end
		if self.fx*0.001 == self.waypoint_x and self.fy*0.001 == self.waypoint_y and self.move_dir ~= "none" then
			if self.state == "Going to tree" then
				if self.count == self.nd_len then
					self.state = "Cutting down"
					self.animation = anim.newAnimation(fr_cutting_northeast,0.12,self.cut)
					self.nd = {}
					self.waypoint_x, self.waypoint_y = nil, nil
					self.move_dir = "none"
					self.count = 1
					return 
				else
					self.waypoint_x = self.nd[self.count][1]
					self.waypoint_y = self.nd[self.count][2]
					self.move_dir = "none"
				end
				self.count = self.count + 1
			elseif self.state == "Going to stockpile" then
				if self.count == self.nd_len then
					_G.stockpile:store('wood')
					_G.stockpile:store('wood')
					self.state = "Looking to chop tree"
					self.nd = {}
					self.waypoint_x, self.waypoint_y = nil, nil
					self.move_dir = "none"
					self.count = 1
					return 
				else
					self.waypoint_x = self.nd[self.count][1]
					self.waypoint_y = self.nd[self.count][2]
					self.move_dir = "none"
				end
				self.count = self.count + 1
			end
		end
	end
end
function Woodcutter:animate()
	self:update()
	self.animation:update(dt)
end
return Woodcutter