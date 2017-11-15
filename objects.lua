--local first_location.x, first_location.y, last_location.x, last_location.y = 0;
local previous_distance, location_distance = 0;
local previous_total_chunks_to_traverse = 0;
local previous_dir = 'none';
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
			local object = newAutotable(4)
	----Generate spriteBatch
			local object_batch = newAutotable(2)   
			local shadow_batch = newAutotable(2)
			local canvas = love.graphics.newCanvas()  
			local object_image = love.graphics.newImage( "assets/tiles/object_texture.png" ); 
			object_image:setFilter('nearest','nearest')
	        local tile_quads = require('objects_quads');
			if tile_quads ~= nil then print("true") end 
			

			object_batch[0][0] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
			shadow_batch[0][0] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)		
			print(object_batch[0][0]:getBufferSize())
--- NOTE Object classes START
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
		Object.initialize(self,gx,gy,i,o,x,y,type)
		self.health = 100;
		self.frames = {tile_quads[1450],tile_quads[1458],tile_quads[1454]} 
		self.animation = anim.newAnimation(self.frames,0.1);
	end
	function Tree:animate()
		self.animation:update(dt);
	end
	function Tree:getQuad()
		return tile_quads[1450]
	end
--- NOTE Object classes END
function genObjects(cx,cy)
	local chunk_x = cx or current_chunk_x;
	local chunk_y = cy or current_chunk_y;
	
	if object_batch[chunk_x][chunk_y] == nil then 
		object_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
	end
	object_batch[chunk_x][chunk_y]:clear();	
		for i=0,chunk_width-1,1 do
			for o=0,chunk_height-1,1 do
				local rand = math.random(400);
						if rand == 5 then
						object[cx][cy][i][o] = Tree:new(cx,cy,i,o,
						IsoX + (i - o) * tile_width  * 0.5 - (tile_offset_x[object[chunk_x][chunk_y][i][o]] or 0),
						IsoY + (i + o) * tile_height * 0.5 - (tile_offset[object[chunk_x][chunk_y][i][o]] or 0),"Pine tree")
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
	-- local chunk_x = cx or current_chunk_x;
	-- local chunk_y = cy or current_chunk_y;

	-- object_batch[chunk_x][chunk_y] =  object_batch[chunk_x][chunk_y] or love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height);
	-- --shadow_batch[chunk_x][chunk_y] =  shadow_batch[chunk_x][chunk_y] or love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height);
  	-- object_batch[chunk_x][chunk_y]:clear(); 
  	-- --shadow_batch[chunk_x][chunk_y]:clear();
  	-- for i=0,chunk_width-1,1 do
    -- 	for o=0,chunk_height-1,1 do
	-- 		if object[chunk_x][chunk_y][i][o] ~= nil then					
	-- 					-- object_batch[chunk_x][chunk_y]:add(
	-- 					-- 	object[chunk_x][chunk_y][i][o]:getQuad() or 0, 
	-- 					-- 	IsoX + (i - o) * tile_width  * 0.5 - (tile_offset_x[object[chunk_x][chunk_y][i][o]] or 0),
	-- 					-- 	IsoY + (i + o) * tile_height * 0.5 - (tile_offset[object[chunk_x][chunk_y][i][o]] or 0)
	-- 					-- 		);
	-- 				object[cx][cy][i][o].qid = object_batch[chunk_x][chunk_y]:
	-- 				add(object[cx][cy][i][o].animation:getFrameInfo(object[cx][cy][i][o].x,object[cx][cy][i][o].y));
	-- 		end
    -- 	end
  	-- end				  
 	 --object_batch[chunk_x][chunk_y]:flush()
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
    love.graphics.draw(object_image,tile_quads[building_selection],IsoToScreenX(LocalX,LocalY)-view_xview-(tile_offset_x[building_selection] or 0),IsoToScreenY(LocalX,LocalY)-view_yview-(tile_offset[building_selection] or 0),nil,scale_x);
	
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
   if button == 1 then 
		mx, my = love.mouse.getPosition(); 
		LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); 
		LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)); 
		first_location.gx = LocalX;
		first_location.gy = LocalY;
		first_location.x = LocalX % (chunk_width);
		first_location.y = LocalY % (chunk_width);
		first_location.cx = math.floor(LocalX/chunk_width);
		first_location.cy = math.floor(LocalY/chunk_width);

		--TODO check first if tile is taken
			object[first_location.cx][first_location.cy][first_location.x][first_location.y] = building_selection
			if building_selection >= 398 and building_selection <= 401 then
				building_selection = 398 + math.random(3);
			end
			update_objects(first_location.cx,first_location.cy)
   end
   if button == 2 then
		building_selection = building_selection + 1;
		building_selection = (building_selection % 3);
		if building_selection == 2 then
		--TODO proper system for changing build selection
			px_img_y_offset = 8;
			lx_offset = -6;
			ly_offset = 0;
		elseif building_selection == 1 or building_selection == 0 then
			px_img_y_offset = 0;
			lx_offset = 0;
			ly_offset = 0;
		end
   end
end
local anim = 0;
local function update()
    if previous_chunk_x ~= current_chunk_x or previous_chunk_y ~= current_chunk_y then 
        chunkUpdateList()
    end
    previous_chunk_x = current_chunk_x;
    previous_chunk_y = current_chunk_y;
	anim = anim + 1;
	anim = anim % 6;
	local chunk_x = current_chunk_x;
	local chunk_y = current_chunk_y;
	if anim == 0 then 
		for i=0,chunk_width-1,1 do
			for o=0,chunk_height-1,1 do
				if object[chunk_x][chunk_y][i][o] ~= nil then
					object[chunk_x][chunk_y][i][o]:animate();
					object_batch[chunk_x][chunk_y]
					:set(object[chunk_x][chunk_y][i][o].qid,
						object[chunk_x][chunk_y][i][o].animation
					:getFrameInfo(object[chunk_x][chunk_y][i][o].x,
								object[chunk_x][chunk_y][i][o].y))
				end
			end
		end	
		update_objects();
	end

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
update_objects(); --note do we need this?

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














