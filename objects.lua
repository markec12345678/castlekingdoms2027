--local first_location.x, first_location.y, last_location.x, last_location.y = 0;
local previous_distance, location_distance = 0;
local previous_total_chunks_to_traverse = 0;
local previous_dir = 'none';
local Grid = require ("libraries.jumper.grid")
local Pathfinder = require ("libraries.jumper.pathfinder")

local pf = require("libraries.lua-star")


collision_map = newAutotable(2)
--TODO Remove this old pathfinder


		for i=-20,256,1 do
			for o=-20,256,1 do
				collision_map[i][o] = 0;
			end
		end
local grid = Grid(collision_map)
local finder = Pathfinder(grid,'JPS', 0);

local angle; 
local location = {
	gx = 0,
	gy = 0,
	x = 0,
	y = 0,
	cx = 0, 
	cy = 0
}
function location:new (o)
	o = o or {}  
	setmetatable(o, self)
	self.__index = self
	return o
end
local first_location = location:new();
local last_location = location:new();

    --2D array stuff
	----Rows and columns
            local cols = chunk_width;
            local rows = chunk_height;
	----Chunk 2D array 	
			local active_objects = newAutotable(2);
			local object = newAutotable(4)
	----Generate spriteBatch
			local object_batch = newAutotable(2)   
			local shadow_batch = newAutotable(2)
			local canvas = love.graphics.newCanvas()  
			local object_image = love.graphics.newImage( "assets/tiles/object_texture.png" ); 
			object_image:setFilter('nearest','nearest')
	        local tile_quads = require('objects_quads');
			--if tile_quads ~= nil then print("true") end 
		
			object_batch[0][0] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
			shadow_batch[0][0] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)		
			print(object_batch[0][0]:getBufferSize())

			
function isPositionOpenfunc(x, y)
    -- should return true if the map position at x, y is open to walk
	-- TODO transform x,y (global) to local coordinates and add chunk coords
	--return true;
		local xx = x % (chunk_width);
		local yy = y % (chunk_width);
		local cx = math.floor(x/chunk_width);
		local cy = math.floor(y/chunk_width);
		if object[cx][cy][xx][yy] == nil then
    return true else return false; end
end

--- NOTE Object classes START ---
--- NOTE --------------------------
--- NOTE --------------------------
		local Object = class('Object');
			function Object:initialize(cx,cy,i,o,x,y,type)
				self.cx = cx;
				self.cy = cy;
				self.i = i;
				self.o = o;
				self.x = x;
				self.y = y;
				self.type = type;
				self.qid = 0;
				end
		local Tree = class('Tree', Object);
			function Tree:initialize(cx,cy,i,o,x,y,type)
				Object.initialize(self,cx,cy,i,o,x,y,type)
				self.gx = chunk_width*self.cx+self.i; --warning fucking genius
				self.gy = chunk_width*self.cy+self.o;
				collision_map[self.gx][self.gy] = 1; 
				self.health = 100;
				self.frames = {tile_quads[1450],tile_quads[1455],tile_quads[1456]
				,tile_quads[1457],tile_quads[1458],tile_quads[1459],tile_quads[1460]
				,tile_quads[1461],tile_quads[1462],tile_quads[1451],tile_quads[1452]
				,tile_quads[1453],tile_quads[1454],tile_quads[1452],tile_quads[1462],tile_quads[1460]}; 
				self.animation = anim.newAnimation(self.frames,0.13);
				self.offset_x = 0;
				self.falling = false;
				self.chop = false;
				self.stump = false; 
				self.animated = true;
				self.marked = false;
				self.cut_down = function() 
					print("Cut!")
					self.falling = false;
					self.chop = true;
					self.frames = {tile_quads[1444],tile_quads[1445],tile_quads[1446],tile_quads[1447],
					tile_quads[1448],tile_quads[1437],tile_quads[1438],tile_quads[1439],tile_quads[1440]}
					self.animation = anim.newAnimation(self.frames,0.1)
					self.animation:pause();
					end
				self.finish = function()
					self.frames = {tile_quads[1449]};
					self.animation = anim.newAnimation(self.frames,0.1);
					self.animation:pause();
					self.stump = true;
					self.animation:update(dt);
					self.animated = false; --mark for removal from list
					self:animate(); --animate, because the list will remove us before we show the stump
					self.type = "Stump";
					print("Done!")
					end
				table.insert(active_objects,self);
				end
			function Tree:animate()
				self.animation:update(dt);
				object_batch[self.cx][self.cy]
					:set(self.qid,self.animation:getFrameInfo(self.x-self.offset_x,self.y));
				self.offset_x = 0;
				end
			function Tree:cut() --TODO return value to chopper
				if self.health > 0 then
					self.health = self.health - 10;
					self.offset_x = 4+math.random(2);
					--self.animation:gotoFrame(4);
					print("Cutting down!", self.gx,self.gy)
				elseif self.health <= 0 and self.falling == false and self.chop == false and self.stump == false then
					self.frames = {tile_quads[1436],tile_quads[1441],
					tile_quads[1442],tile_quads[1443]}
					self.animation = anim.newAnimation(self.frames,0.13,self.cut_down)
					self.falling = true;
					end
				if self.chop then 
						print("Chopping!")
						if self.animation:getTotalFrames() ~= self.animation:getCurrentFrame() then
							self.animation:gotoFrame(self.animation:getCurrentFrame()+1)
						else
							self.finish();
							self.chop = false;
							return 2;
						end
					end
				end
		local Woodcutter = class('Woodcutter', Object);
			function Woodcutter:initialize(cx,cy,i,o,x,y,type)
				Object.initialize(self,cx,cy,i,o,x,y,type)
				self.gx = chunk_width*self.cx+self.i; --warning fucking genius
				self.gy = chunk_width*self.cy+self.o;
				self.endx = 0;
				self.endy = 0;
				self.fx = self.gx*1000;
				self.fy = self.gy*1000;
				self.waypoint_x = 0;
				self.waypoint_y = 0;
				self.state = 'Looking to chop tree';
				self.path = 0;
				self.straight_walk_speed = 40;
				self.diagonal_walk_speed = 25;
				self.originalx = i; self.originaly = o;
				self.nd = newAutotable(1);
				self.nd_len = 0;
				self.count = 1;
				self.timr = 0;
				self.move_dir = "none";
				self.update_dir = true;
				self.previous_dir = "none";
				self.target_tree = 0;
				self.cut = function() 
					if self.state == "Cutting down" then
					print("Trying to cut down "..self.target_tree.type)
					local tree_progress = 0;
					if self.target_tree.type == "Pine tree" then
					tree_progress = self.target_tree:cut() else 
					self.state = "Looking to chop tree"	
						self.move_dir = "none"
						end
					if tree_progress == 2 then
						--self.animation = anim.newAnimation(self.fr_walking_north,0.15)
						self.i = (self.fx*0.001)%chunk_width;
						self.o = (self.fy*0.001)%chunk_width;
						self.state = "Looking to chop tree"	
						self.move_dir = "na"
						self.count = 0;
						tree_progress = 3;				
						end
						else print("State", self.state)
						end
				end
				self.fr_walking_east = {
					tile_quads[2201],tile_quads[2202],tile_quads[2203],
					tile_quads[2204],tile_quads[2205],tile_quads[2206],
					tile_quads[2207],tile_quads[2208]
				}
				self.fr_walking_north = {
					tile_quads[2209],tile_quads[2210],tile_quads[2211],
					tile_quads[2212],tile_quads[2213],tile_quads[2214],
					tile_quads[2215],tile_quads[2216]
				}
				self.fr_walking_northeast = {
					tile_quads[2217],tile_quads[2218],tile_quads[2219],
					tile_quads[2220],tile_quads[2221],tile_quads[2222],
					tile_quads[2223],tile_quads[2224]
				}
				self.fr_walking_northwest = {
					tile_quads[2225],tile_quads[2226],tile_quads[2227],
					tile_quads[2228],tile_quads[2229],tile_quads[2230],
					tile_quads[2231],tile_quads[2232]
				}
				self.fr_walking_south = {
					tile_quads[2233],tile_quads[2234],tile_quads[2235],
					tile_quads[2236],tile_quads[2237],tile_quads[2238],
					tile_quads[2239],tile_quads[2240]
				}
				self.fr_walking_southeast = {
					tile_quads[2241],tile_quads[2242],tile_quads[2243],
					tile_quads[2244],tile_quads[2245],tile_quads[2246],
					tile_quads[2247],tile_quads[2248]
				}
				self.fr_walking_southwest = {
					tile_quads[2249],tile_quads[2250],tile_quads[2251],
					tile_quads[2252],tile_quads[2253],tile_quads[2254],
					tile_quads[2255],tile_quads[2256]
				}
				self.fr_walking_west = {
					tile_quads[2257],tile_quads[2258],tile_quads[2259],
					tile_quads[2260],tile_quads[2261],tile_quads[2262],
					tile_quads[2263],tile_quads[2264]
				}
				self.fr_cutting_northeast = { --warning actually north --TODO: why not name it north then?
					tile_quads[2056],tile_quads[2057],tile_quads[2058],
					tile_quads[2059],tile_quads[2060],tile_quads[2061],
					tile_quads[2062],tile_quads[2063]
				}
				self.animation = anim.newAnimation(self.fr_walking_west,10);
				table.insert(active_objects,self);
				end 
			function Woodcutter:pathfind(xx,yy)
					local mapwidth = 10000
					local mapheight = 10000
					print("Self:",self.gx,self.gy)
					local paths = pf:find(mapwidth, mapheight, self.gx,self.gy, xx,yy, isPositionOpenfunc)
					if paths then
						print("Found a path my lord!");
						local count = 0;
						local first = true; --skip the first node, because it's our position
						for _, p in ipairs(paths) do
							print("So:",p.x,p.y)
							if not first then
								self.nd[count] = p;
								self.nd_len = count;
								count = count + 1;
							else first = false end							
						end
						self.waypoint_x = self.nd[0].x; 
					 	self.waypoint_y = self.nd[0].y;
						print("Waypoint: "..self.waypoint_x,self.waypoint_y)						
					 	self.move_dir = "none"											  
					else 
						print("Nope, need to find another tree (need to code it first)")
						self.state = "No trees"
					end					
				end
			function Woodcutter:find_tree() --TODO fix so it finds the nearest tree...
					for index, obj in ipairs ( active_objects ) do 
						if obj.type == 'Pine tree' and obj.marked == false then
							if obj.cx == self.cx and obj.cy == self.cy then --TODO only works in current chunk
								self.target_tree = obj; print("Target tree:", self.target_tree)
								self.endx = obj.gx;
								self.endy = obj.gy;
								self:pathfind(self.endx,self.endy+1);
								print("Found tree at "..self.endx.."  "..self.endy);
								self.state = "Going to tree";
								obj.marked = true;
								return;
							end
						end
					end
				end
			function Woodcutter:update() --TODO I need to update cx,cy somewhere when the woodcutter moves from chunk to chunk
				if object[self.cx][self.cy][math.round((self.fx*0.001)%chunk_width)][math.round((self.fy*0.001)%chunk_width)] == nil then
					object[self.cx][self.cy][math.round((self.fx*0.001)%chunk_width)][math.round((self.fy*0.001)%chunk_width)] = self;
					print("------------------------------Pre updated at ",self.cx,self.cy,math.round(self.fx*0.001)%chunk_width,math.round(self.fy*0.001)%chunk_width)
					object[self.cx][self.cy][self.originalx][self.originaly] = nil;
					self.originalx = math.round((self.fx*0.001)%chunk_width);
					self.originaly = math.round((self.fy*0.001)%chunk_width);
				end
				if self.state ~= "No trees" then
						if self.state == "Looking to chop tree" then
							self:find_tree();
						elseif self.move_dir == "none" and self.state == "Going to tree" then
							local wx = self.waypoint_x;
							local wy = self.waypoint_y;
							local angle = math.atan2 (wy - (self.fy*0.001),wx-(self.fx*0.001));
							angle = (angle *180)/math.pi;
							angle = math.round (angle);
							print("Calculated angle with wy("..wy.."), self.fy*0.001("..((self.fy*0.001))..
							"),wx("..wx..") and self.fx*0.001("..((self.fx*0.001))..")")
							if angle<0 then angle = 360+angle end
								if (angle >= 135+22 and angle <= 225-22) then --direction is west 
									self.move_dir = "west";
									if self.previous_dir ~= "west" then
										self.animation = anim.newAnimation(self.fr_walking_west,0.11) 
									end
								elseif (angle > 135-22 and angle < 135+22) then --direction is southwest
									self.move_dir = "southwest";
									if self.previous_dir ~= "southwest" then
										self.animation = anim.newAnimation(self.fr_walking_southwest,0.11)
									end
								elseif (angle > 225-22 and angle < 225+22) then --direction is northwest
									self.move_dir = "northwest";
									if self.previous_dir ~= "northwest" then
										self.animation = anim.newAnimation(self.fr_walking_northwest,0.11)
									end
								elseif (angle >= 225+22 and angle <= 315-22) then --direction is north
									self.move_dir = "north";
									if self.previous_dir ~= "north" then
										self.animation = anim.newAnimation(self.fr_walking_north,0.11)
									end
								elseif (angle >= 45+22 and angle <= 135-22) then --direction is south
									self.move_dir = "south";
									if self.previous_dir ~= "south" then
										self.animation = anim.newAnimation(self.fr_walking_south,0.11)
									end
								elseif ((angle >= 315+22 and angle <= 359) or (angle >=0 and angle <= 45-22)) then --direction is east
									self.move_dir = "east";
									if self.previous_dir ~= "east" then
										self.animation = anim.newAnimation(self.fr_walking_east,0.11)
									end
								elseif (angle > 45-22 and angle < 45+22) then--direction is southeast
									self.move_dir = "southeast";
									if self.previous_dir ~= "southeast" then
										self.animation = anim.newAnimation(self.fr_walking_southeast,0.11)
									end
								elseif (angle > 315-22 and angle < 315+22) then --direction is northeast
									self.move_dir = "northeast";
									if self.previous_dir ~= "northeast" then
										self.animation = anim.newAnimation(self.fr_walking_northeast,0.11)
									end
								end
							print("Move dir is now "..self.move_dir, angle)
						end
						self.x = IsoX + ((self.fx*0.001)%chunk_width - (self.fy*0.001)%chunk_width) * tile_width  * 0.5 - 47 --fixme magic numbers?
						self.y = IsoY + ((self.fx*0.001)%chunk_width + (self.fy*0.001)%chunk_width) * tile_height * 0.5 - 53
						self.timr = self.timr + 1;
						self.timr = self.timr % 60;
						if self.state == "Going to tree" then
							if self.move_dir == "west" then
								self.fx = self.fx - self.straight_walk_speed
							elseif self.move_dir == "south" then
								self.fy = self.fy + self.straight_walk_speed
							elseif self.move_dir == "north" then
								self.fy = self.fy - self.straight_walk_speed
							elseif self.move_dir == "east" then
								self.fx = self.fx + self.straight_walk_speed
							elseif self.move_dir == "northwest" then
								self.fx = self.fx - self.diagonal_walk_speed
								self.fy = self.fy - self.diagonal_walk_speed
							elseif self.move_dir == "northeast" then
								self.fx = self.fx + self.diagonal_walk_speed
								self.fy = self.fy - self.diagonal_walk_speed
							elseif self.move_dir == "southwest" then
								self.fx = self.fx - self.diagonal_walk_speed
								self.fy = self.fy + self.diagonal_walk_speed
							elseif self.move_dir == "southeast" then
								self.fx = self.fx + self.diagonal_walk_speed
								self.fy = self.fy + self.diagonal_walk_speed
							end
							if (self.fx*0.001)==math.floor(self.fx*0.001) then print("Position ",self.fx*0.001,self.fy*0.001) end
						end
						if self.fx*0.001 == self.waypoint_x and self.fy*0.001 == self.waypoint_y and self.state ~= "Cutting down" and self.move_dir ~= "none" then
								if self.count == self.nd_len then 
									self.state = "Cutting down"
									self.animation = anim.newAnimation(self.fr_cutting_northeast,0.12,self.cut)
									self.nd = {};
									return 
								end
								self.count = self.count + 1;
								print("Reached checkpoint "..self.count);
								self.waypoint_x = self.nd[self.count].x; --TODO check for nil before indexing
								self.waypoint_y = self.nd[self.count].y;
								print("Waypoint is now "..self.waypoint_x,self.waypoint_y);
								self.previous_dir = self.move_dir;
								self.move_dir = "none";
								if self.waypoint_x == self.fx*0.001 and self.waypoint_y == self.fy*0.001 then								
									if self.count == self.nd_len then 
										self.state = "Cutting down"
										self.animation = anim.newAnimation(self.fr_cutting_northeast,0.12,self.cut)
										self.nd = {};
										return 
									end
									self.count = self.count + 1;
									print("Reached checkpoint "..self.count)
									self.waypoint_x = self.nd[self.count].x; 
									self.waypoint_y = self.nd[self.count].y;
								end
						end
					end
				end
			function Woodcutter:animate()
				self:update();
				self.animation:update(dt);
				object_batch[self.cx][self.cy]
					:set(self.qid,self.animation:getFrameInfo(self.x,self.y));
				end
--- NOTE --------------------------
--- NOTE --------------------------
--- NOTE Object classes END ---
function genObjects(cx,cy)
	local chunk_x = cx or current_chunk_x;
	local chunk_y = cy or current_chunk_y;
	
	if object_batch[chunk_x][chunk_y] == nil then 
		object_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
	end
	object_batch[chunk_x][chunk_y]:clear();	
		for i=0,chunk_width-1,1 do
			for o=0,chunk_height-1,1 do
				local rand = math.random(25);
						if rand == 5 then
						object[cx][cy][i][o] = Tree:new(cx,cy,i,o, --TODO fix tile_offset/_x
						IsoX + (i - o) * tile_width  * 0.5 - (tile_offset_x[object[chunk_x][chunk_y][i][o]] or 50),
						IsoY + (i + o) * tile_height * 0.5 - (tile_offset[object[chunk_x][chunk_y][i][o]] or 170),"Pine tree")
						object[cx][cy][i][o].animation:gotoFrame(math.random(6))
						--table.insert(active_objects,object[cx][cy][i][o])
						end 
						--TODO add shadow gen here	
				if object[cx][cy][i][o] == nil or object[cx][cy][i][o] == 0 then else
					object[cx][cy][i][o].qid = object_batch[chunk_x][chunk_y]:
					add(object[cx][cy][i][o].animation:getFrameInfo(object[cx][cy][i][o].x,object[cx][cy][i][o].y));
				end
			end
		end
end
function objectClean(cx,cy)
	object[cx][cy] = nil;
	object_batch[cx][cy] = nil;
	shadow_batch[cx][cy] = nil;
end

local function update_objects(cx,cy)
	local chunk_x = cx or current_chunk_x;
	local chunk_y = cy or current_chunk_y;

	object_batch[chunk_x][chunk_y] =  object_batch[chunk_x][chunk_y] or love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height);
	--shadow_batch[chunk_x][chunk_y] =  shadow_batch[chunk_x][chunk_y] or love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height);
  	object_batch[chunk_x][chunk_y]:clear(); 
  	--shadow_batch[chunk_x][chunk_y]:clear();
  	for i=0,chunk_width-1,1 do
    	for o=0,chunk_height-1,1 do
			-- print("Trying to spawn woodcutter", first_location.x, first_location.y)
			if object[chunk_x][chunk_y][i][o] ~= nil then
				--if object[chunk_x][chunk_y][i][o].type == "Woodcutter" then love.event.quit() end
					object[chunk_x][chunk_y][i][o].qid = object_batch[chunk_x][chunk_y]:
					add(object[chunk_x][chunk_y][i][o].animation
					:getFrameInfo(object[chunk_x][chunk_y][i][o].x,
								  object[chunk_x][chunk_y][i][o].y));
				--elseif object[chunk_x][chunk_y][i][o] == "Pine tree" then
					-- object[cx][cy][i][o].qid = object_batch[chunk_x][chunk_y]:
					-- add(object[cx][cy][i][o].animation:getFrameInfo(object[cx][cy][i][o].x,object[cx][cy][i][o].y));
				--end
			end
    	end
  	end				  
 	 object_batch[chunk_x][chunk_y]:flush()
 	 --shadow_batch[chunk_x][chunk_y]:flush()
end

--TODO remove
local function build_wall_piece(cx,cy)
	cx = cx or 0;
	cy = cy or 0;
		for i=0,chunk_width-1,1 do
			for o=0,chunk_width-1,1 do
				if object[cx][cy][i][o] == 2 then
					object[cx][cy][i][o] = 1;
				end
			end
		end
		previous_distance = 0;
	    update_objects(cx,cy);
end

local function draw_object()
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	local l1 = terrain_chunks
		while l1 do
			if l1.chunkx ~= nil and shadow_batch[l1.chunkx][l1.chunky] ~= nil then  
				love.graphics.draw(shadow_batch[l1.chunkx][l1.chunky], 
						-view_xview+(l1.chunkx-l1.chunky)*chunk_width*tile_width*0.5*scale_x, 
						-view_yview+(l1.chunkx+l1.chunky)*chunk_height*tile_height*0.5*scale_y
						, 0, scale_x, scale_y);
			end;
				l1 = l1.next 
				--TODO sort the linked list first so depth order is right between chunks
		end
  	--love.graphics.draw(shadow_batch[0][0],    -view_xview, -view_yview, 0, scale_x, scale_y);
	love.graphics.setCanvas()
    --love.graphics.draw(object_image,tile_quads[building_selection],IsoToScreenX(LocalX,LocalY)-view_xview-(tile_offset_x[building_selection] or 0),IsoToScreenY(LocalX,LocalY)-view_yview-(tile_offset[building_selection] or 0),nil,scale_x);
	
	love.graphics.setColor(255,255,255,70)
	love.graphics.draw(canvas,0,0)
	love.graphics.setColor(255,255,255,255)
	local l = terrain_chunks
	while l do
			if l.chunkx == nil or object_batch[l.chunkx][l.chunky] == nil then break end;
  			love.graphics.draw(object_batch[l.chunkx][l.chunky], 
     				-view_xview+(l.chunkx-l.chunky)*chunk_width*tile_width*0.5*scale_x, 
					-view_yview+(l.chunkx+l.chunky)*chunk_height*tile_height*0.5*scale_y
					, 0, scale_x, scale_y);
			l = l.next 
	end
	love.graphics.setColor(255,255,255,255)
end

local function mousereleased(x, y, button, istouch)
--    if button == 1 then 
--    		-- TODO remove localx,localy when implementing chunks 
-- 		mx, my = love.mouse.getPosition(); 
-- 		LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); 
-- 		LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)); 
-- 		last_location.gx = LocalX;
-- 		last_location.gy = LocalY;
-- 		last_location.x = LocalX % chunk_width;
-- 		last_location.y = LocalY % chunk_width; 
-- 		last_location.cx = math.ceil(LocalX/chunk_width);
-- 		last_location.cy = math.ceil(LocalY/chunk_width);
-- 		location_distance = ((last_location.x-first_location.x)+(last_location.y-first_location.y));
-- 		location_distance = ((last_location.gx-first_location.gx)+(last_location.gy-first_location.gy));
-- 		print(location_distance)
-- 		angle = math.atan2 (last_location.gy - first_location.gy,last_location.gx-first_location.gx);
-- 		angle = (angle *180)/math.pi;
-- 		angle = math.round (angle);
-- 		if angle<0 then angle = 360+angle end
--         build_wall_piece(first_location.cx,first_location.cy);
-- 		if previous_dir == "east" then build_wall_piece(1,0) end
-- 		print(angle)
--    end
end

local function mousepressed(x, y, button, istouch)
	mx, my = x,y;
		LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); 
		LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)); 
		first_location.gx = LocalX;
		first_location.gy = LocalY;
		first_location.x = LocalX % (chunk_width);
		first_location.y = LocalY % (chunk_width);
		first_location.cx = math.floor(LocalX/chunk_width);
		first_location.cy = math.floor(LocalY/chunk_width);
   if button == 1 then 
		if object[first_location.cx][first_location.cy][first_location.x][first_location.y] ~= nil then
		object[first_location.cx][first_location.cy][first_location.x][first_location.y]:cut(); end --todo remove this in prod
   elseif button == 2 then
		--if object[first_location.cx][first_location.cy][first_location.x][first_location.y] ~ then
			print("Trying to spawn woodcutter", first_location.x, first_location.y)
			object[first_location.cx][first_location.cy][first_location.x][first_location.y] =  
						Woodcutter:new(first_location.cx,first_location.cy,first_location.x,first_location.y, --TODO fix tile_offset/_x
						IsoX + (first_location.x - first_location.y) * tile_width  * 0.5 -47,
						IsoY + (first_location.x + first_location.y) * tile_height * 0.5 -77,"Woodcutter")
					object[first_location.cx][first_location.cy][first_location.x][first_location.y].qid = object_batch[first_location.cx][first_location.cy]:
					add(object[first_location.cx][first_location.cy][first_location.x][first_location.y].animation
					:getFrameInfo(object[first_location.cx][first_location.cy][first_location.x][first_location.y].x,
								  object[first_location.cx][first_location.cy][first_location.x][first_location.y].y));
		--end 
   end
end 
local previous_count = 0; --note remove this in prod
local upd = 0;
local function update()
    if previous_chunk_x ~= current_chunk_x or previous_chunk_y ~= current_chunk_y then 
        chunkUpdateList()
    end
    previous_chunk_x = current_chunk_x;
    previous_chunk_y = current_chunk_y;
	
	local counter = 0 --note remove this in prod
	--upd = upd + 1;
	--upd = upd % 10;
	--if upd == 0 then
	update_objects(11,11); --end

	for index, obj in ipairs ( active_objects ) do 
				counter = counter + 1; --note remove this in prod
				if (obj.cx > current_chunk_x+1) or (obj.cx < current_chunk_x-1)
				or (obj.cy > current_chunk_y+1) or (obj.cy < current_chunk_y-1) or obj.animated == false then
					table.remove(active_objects,index)
				else
					obj:animate();
				end
	end
	if previous_count ~= counter then --note remove this in prod
	print("Amount of animated objects: "..counter) end --note remove this in prod
	previous_count = counter; --note remove this in prod
end


--warning These functions must be removed later
function getLocation()
	return location_distance or 0;
end
function getLocationAngle()
	return angle or 0;
end
function getPreviousDir()
	return previous_dir or 0;
end
function getPreviousDistance()
	return previous_distance or 0;
end
--warning end

chunkUpdateList()

local tableOfFunctions = {
                        update = update, 
                        draw = draw_object,
                        chunk = object[first_location.cx][first_location.cy], 
                        mousereleased = mousereleased, 
                        mousepressed = mousepressed, 
                        generate_wall_piece = generate_wall_piece,
                        
                        }
return tableOfFunctions, update_objects














