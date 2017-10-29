--local first_location.x, first_location.y, last_location.x, last_location.y = 0;
local previous_distance, location_distance = 0;
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
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end
local first_location = location:new();
local last_location = location:new();

	math.randomseed(os.time())

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
	        local object_image = love.graphics.newImage( "assets/tiles/image_strip.png" );
	        local tile_quads = {};
			local tile_offset = {};
			local tile_offset_x = {};
			local imageW,imageH = object_image:getWidth(), object_image:getHeight();
			-- Wall piece built [1]
				tile_quads[0]  = love.graphics.newQuad(0,0,0,0,0,0)
				tile_quads[1]  = love.graphics.newQuad(420, 1850, 30, 107, imageW,imageH) 
				tile_offset[1] = 107-16
			-- Wall piece framework [2]
				tile_quads[2]  = love.graphics.newQuad(450, 1850, 30, 107, imageW,imageH)
				tile_offset[2] = 107-16
			-- Tree fully grown , type 1 [3]				
				tile_quads[3]  = love.graphics.newQuad(1100, 383, 181, 142, imageW,imageH)
				tile_offset[3] = 117
				tile_offset_x[3] = 73
			-- Tree fully grown , type 2 [4]				
				tile_quads[4]  = love.graphics.newQuad(733, 1127, 167, 130, imageW,imageH)
				tile_offset[4] = 114
				tile_offset_x[4] = 70
			-- Wall shadow - tremporary [5]
				tile_quads[5]  = love.graphics.newQuad(482, 1933, 567-482, 1954-1933, imageW,imageH)

			object_batch[0][0] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
			shadow_batch[0][0] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)		

function genObjects(cx,cy)
	local chunk_x = cx or current_chunk_x;
	local chunk_y = cy or current_chunk_y;
	
	if object_batch[chunk_x][chunk_y] == nil then 
		object_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)
	end
	object_batch[chunk_x][chunk_y]:clear();	
		for i=0,chunk_width-1,1 do
			for o=0,chunk_height-1,1 do
				local rand = love.math.random(400);
						if rand == 5 then
                        object[cx][cy][i][o]=3; elseif rand == 6 then
						object[cx][cy][i][o]=4; else
						object[cx][cy][i][o]=0; end
						--TODO add shadow gen here	
				object_batch[chunk_x][chunk_y]:add(
									tile_quads[object[cx][cy][i][o]], 
									IsoX + (i - o) * tile_width  * 0.5 - (tile_offset_x[object[chunk_x][chunk_y][i][o]] or 0),
									IsoY + (i + o) * tile_height * 0.5 - (tile_offset[object[chunk_x][chunk_y][i][o]] or 0)
									);
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
	shadow_batch[chunk_x][chunk_y] =  shadow_batch[chunk_x][chunk_y] or love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height);
  object_batch[chunk_x][chunk_y]:clear(); 
  shadow_batch[chunk_x][chunk_y]:clear();
  for i=0,chunk_width-1,1 do
    for o=0,chunk_height-1,1 do
        if object[chunk_x][chunk_y][i][o] ~= 0 then
				if object[chunk_x][chunk_y][i][o] == 1 then 
                    shadow_batch[chunk_x][chunk_y]:add(
		  				tile_quads[5], 
      					IsoX + (i - o) * tile_width  * 0.5+16,
      					IsoY + (i + o) * tile_height * 0.5-4
						  ); end						
                    object_batch[chunk_x][chunk_y]:add(
		  				tile_quads[object[chunk_x][chunk_y][i][o] or 1], 
      					IsoX + (i - o) * tile_width  * 0.5 - (tile_offset_x[object[chunk_x][chunk_y][i][o]] or 0),
      					IsoY + (i + o) * tile_height * 0.5 - (tile_offset[object[chunk_x][chunk_y][i][o]] or 0)
						  );
        end
    end
  end				  
  object_batch[chunk_x][chunk_y]:flush()
  shadow_batch[chunk_x][chunk_y]:flush()
end



local function remove_diagonal_walls()
	--STEP 1 
	--	GET TOP and BOTTOM BORDER TILE COORDINATES
	--TODO check for middle vertical tile
	--testvar = testvar + 1;
	--testvar = testvar % 10;
	local p, distance;
	local top_tile_x, top_tile_y = 0;
	local bot_tile_x, bot_tile_y = 0;
	if (first_location.x - first_location.y) > 0 then --TILE is right side from the center
		top_tile_x = first_location.x - first_location.y;
		top_tile_y = 0;
		bot_tile_x = chunk_width-1;
		bot_tile_y = (first_location.y)+((chunk_width-1)-first_location.x); 
		distance = bot_tile_x-top_tile_x;
		for p=0,distance,1 do
			if object[first_location.cx][first_location.cy][top_tile_x + p][top_tile_y + p] == 2 then	
				object[first_location.cx][first_location.cy][top_tile_x + p][top_tile_y + p] = 0;
			end
		end
	elseif (first_location.x - first_location.y) < 0 then --TILE is left side from the center
		top_tile_x = 0;
		top_tile_y = first_location.y - first_location.x;
		bot_tile_x = first_location.x+((chunk_width-1)-first_location.y);
		bot_tile_y = chunk_width-1; 
		distance = bot_tile_y-top_tile_y;
		for p=0,distance,1 do
			if object[first_location.cx][first_location.cy][top_tile_x + p][top_tile_y + p] == 2 then	
				object[first_location.cx][first_location.cy][top_tile_x + p][top_tile_y + p] = 0;
			end
		end
	else
		top_tile_y, top_tile_x = 0, 0;
		bot_tile_y, bot_tile_x = chunk_width-1, chunk_width-1
		distance = chunk_width;
		for p=0,distance,1 do
			if object[first_location.cx][first_location.cy][top_tile_x + p][top_tile_y + p] == 2 then	
				object[first_location.cx][first_location.cy][top_tile_x + p][top_tile_y + p] = 0;
			end
		end
	end
	--STEP 2
	--  GET LEFT and RIGHT BORDER TILE COORDINATES
	local left_tile_x = 0;
	local left_tile_y = first_location.x + first_location.y;
	local right_tile_x = first_location.x + first_location.y;
	local right_tile_y = 0;
	local m;
	if right_tile_x <= chunk_width-1 then --TILE is top side or center
		for m=0,right_tile_x,1 do
			if object[first_location.cx][first_location.cy][left_tile_x +m][left_tile_y - m] == 2 then	
				object[first_location.cx][first_location.cy][left_tile_x + m][left_tile_y - m] = 0;
			end
		end
	else --TILE is bot side
		left_tile_x = first_location.x + first_location.y - chunk_width-1;
		left_tile_y = chunk_width-1;
		right_tile_x = chunk_width-1; 
		right_tile_y = first_location.x + first_location.y - chunk_width-1;
		for m=0,right_tile_x-right_tile_y,1 do
			if object[first_location.cx][first_location.cy][left_tile_x +m+1][left_tile_y - m+1] == 2 then	
				object[first_location.cx][first_location.cy][left_tile_x + m +1][left_tile_y - m+1] = 0;
			end
		end
	end
end

local function generate_wall_piece()
	--NOTE-- EAST
	if ((angle >= 315+22 and angle <= 359) or (angle >=0 and angle <= 45-22)) then
		location_distance = last_location.gx-first_location.gx;
		if previous_dir == 'west' then
			for o=0,first_location.x,1 do
				if object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location.y,1 do
				if object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location.y,chunk_height,1 do
				if object[first_location.cx][first_location.cy][first_location.x][o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][o] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'south west' or previous_dir == 'north east' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		previous_dir = 'east';	
		if previous_distance > location_distance then
			for i=location_distance+1,previous_distance,1 do	
				if object[first_location.cx][first_location.cy][first_location.x+i][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x+i][first_location.y] = 0;
				end
			end
		else
			local total_chunks_to_traverse = (last_location.cx-first_location.cx);
			if total_chunks_to_traverse <= 0 then
				for i=0,location_distance,1 do
					if object[first_location.cx][first_location.cy][first_location.x+i][first_location.y] == 0 then	
						object[first_location.cx][first_location.cy][first_location.x+i][first_location.y] = 2; 
					end
	    			update_objects(first_location.cx,first_location.cy);
				end
			else
				for p=1,total_chunks_to_traverse do --start from 1 because we skip the first chunk
					-- if p ~= total_chunks_to_traverse then 
					-- 	for i=0,chunk_width,1 do
					-- 		if object[first_location.cx+p][first_location.cy][first_location.x+i][first_location.y] == 0 then	
					-- 			object[first_location.cx+p][first_location.cy][first_location.x+i][first_location.y] = 2; 
					-- 		end
					-- 	end
					-- else
					print("Chunk: "..p,LocalX%chunk_width)
						for i=0,LocalX % chunk_width,1 do
							if object[first_location.cx+p][first_location.cy][first_location.x+i][first_location.y] == 0 then	
								object[first_location.cx+p][first_location.cy][i][first_location.y] = 2; 
							end
						end
					-- end					
	    			update_objects(first_location.cx+p,first_location.cy);
				end
			end
			
			print("Chunks to traverse: "..total_chunks_to_traverse.." because "..last_location.cx,first_location.cx)
		end
	--NOTE-- WEST
	elseif (angle >= 135+22 and angle <= 225-22) then
		location_distance = last_location.x-first_location.x;
		if previous_dir == 'east' then
			for o=first_location.x,chunk_width,1 do
				if object[first_location.cx][first_location.cy][o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location.y,1 do
				if object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location.y,chunk_height,1 do
				if object[first_location.cx][first_location.cy][first_location.x][o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][o] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'south west' or previous_dir == 'north east' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		previous_dir = 'west';	
		if location_distance < 0 then location_distance = location_distance * (-1) end
		if previous_distance > location_distance then
			for i=location_distance+1,previous_distance,1 do	
				if object[first_location.cx][first_location.cy][first_location.x-i][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x-i][first_location.y] = 0;
				end
			end
		else
			for i=0,location_distance,1 do
				if object[first_location.cx][first_location.cy][first_location.x-i][first_location.y] == 0 then	
					object[first_location.cx][first_location.cy][first_location.x-i][first_location.y] = 2; 
				end
			end
		end
	--NOTE-- NORTH
	elseif (angle >= 225+22 and angle <= 315-22) then
		location_distance = last_location.y-first_location.y;
		if previous_dir == 'west' then
			for o=0,first_location.x,1 do
				if object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'east' then
			for o=first_location.x,chunk_width,1 do
				if object[first_location.cx][first_location.cy][o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location.y,chunk_height,1 do
				if object[first_location.cx][first_location.cy][first_location.x][o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][o] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'south west' or previous_dir == 'north east' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		previous_dir = 'north';	
		if location_distance < 0 then location_distance = location_distance * (-1) end
		if previous_distance > location_distance then
			for i=location_distance+1,previous_distance,1 do	
				if object[first_location.cx][first_location.cy][first_location.x][first_location.y-i] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][first_location.y-i] = 0;
				end
			end
		else
			for i=0,location_distance,1 do
				if object[first_location.cx][first_location.cy][first_location.x][first_location.y-i] == 0 then	
					object[first_location.cx][first_location.cy][first_location.x][first_location.y-i] = 2; 
				end
			end
		end
	--NOTE-- SOUTH
	elseif (angle >= 45+22 and angle <= 135-22) then
		location_distance = last_location.y-first_location.y;
		if previous_dir == 'west' then
			for o=0,first_location.x,1 do
				if object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'east' then
			for o=first_location.x,chunk_width,1 do
				if object[first_location.cx][first_location.cy][o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location.y,1 do
				if object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'south west' or previous_dir == 'north east' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		previous_dir = 'south';	
		if previous_distance > location_distance then
			for i=location_distance+1,previous_distance,1 do	
				if object[first_location.cx][first_location.cy][first_location.x][first_location.y+i] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][first_location.y+i] = 0;
				end
			end
		else
			for i=0,location_distance,1 do
				if object[first_location.cx][first_location.cy][first_location.x][first_location.y+i] == 0 then	
					object[first_location.cx][first_location.cy][first_location.x][first_location.y+i] = 2; 
				end
			end
		end
	--NOTE-- SOUTH EAST
	elseif (angle > 45-22 and angle < 45+22) then
		if previous_dir == 'west' then
			for o=0,first_location.x,1 do
				if object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location.y,1 do
				if object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location.y,chunk_height,1 do
				if object[first_location.cx][first_location.cy][first_location.x][o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][o] = 0;
				end
			end
		elseif previous_dir == 'east' then
			for o=first_location.x,chunk_width,1 do
				if object[first_location.cx][first_location.cy][o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'south west' or previous_dir == 'north east' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		previous_dir = 'south east';	
		if previous_distance > location_distance then
			for i=math.round(location_distance/2)+1,math.round(previous_distance/2),1 do	
				if object[first_location.cx][first_location.cy][first_location.x+i][first_location.y+i] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x+i][first_location.y+i] = 0;
				end
			end
		else
			for i=0,(location_distance/2),1 do
				if object[first_location.cx][first_location.cy][first_location.x+i][first_location.y+i] == 0 then	
					object[first_location.cx][first_location.cy][first_location.x+i][first_location.y+i] = 2; 
				end
			end
		end
	--NOTE-- NORTH WEST
	elseif (angle > 225-22 and angle < 225+22) then
		if previous_dir == 'west' then
			for o=0,first_location.x,1 do
				if object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location.y,1 do
				if object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location.y,chunk_height,1 do
				if object[first_location.cx][first_location.cy][first_location.x][o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][o] = 0;
				end
			end
		elseif previous_dir == 'east' then
			for o=first_location.x,chunk_width,1 do
				if object[first_location.cx][first_location.cy][o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'south west' or previous_dir == 'north east' then
			remove_diagonal_walls();
		end

		if location_distance < 0 then location_distance = location_distance * (-1) end
		previous_dir = 'north west';	
		if previous_distance > location_distance then
			for i=math.round(location_distance/2)+1,math.round(previous_distance/2),1 do	
				if object[first_location.cx][first_location.cy][first_location.x-i][first_location.y-i] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x-i][first_location.y-i] = 0;
				end
			end
		else
			for i=0,(location_distance/2),1 do
				if object[first_location.cx][first_location.cy][first_location.x-i][first_location.y-i] == 0 then	
					object[first_location.cx][first_location.cy][first_location.x-i][first_location.y-i] = 2; 
				end
			end
		end
	--NOTE-- SOUTH WEST
	elseif (angle > 135-22 and angle < 135+22) then
		location_distance = math.floor((last_location.x - first_location.x + first_location.y - last_location.y)/2);
		if previous_dir == 'west' then
			for o=0,first_location.x,1 do
				if object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location.y,1 do
				if object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location.y,chunk_height,1 do
				if object[first_location.cx][first_location.cy][first_location.x][o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][o] = 0;
				end
			end
		elseif previous_dir == 'east' then
			for o=first_location.x,chunk_width,1 do
				if object[first_location.cx][first_location.cy][o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'north east' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		if location_distance < 0 then location_distance = location_distance * (-1) end
		previous_dir = 'south west';	
		if previous_distance > location_distance then
			for i=location_distance+1,previous_distance,1 do	
				if object[first_location.cx][first_location.cy][first_location.x-i][first_location.y+i] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x-i][first_location.y+i] = 0;
				end
			end
		else
			for i=0,location_distance,1 do
				if object[first_location.cx][first_location.cy][first_location.x-i][first_location.y+i] == 0 then	
					object[first_location.cx][first_location.cy][first_location.x-i][first_location.y+i] = 2; 
				end
			end
		end
	--NOTE-- NORTH EAST
	elseif (angle > 315-22 and angle < 315+22) then
		location_distance = math.floor((last_location.x - first_location.x + first_location.y - last_location.y)/2);
		if previous_dir == 'west' then
			for o=0,first_location.x,1 do
				if object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x-o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location.y,1 do
				if object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][first_location.y-o] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location.y,chunk_height,1 do
				if object[first_location.cx][first_location.cy][first_location.x][o] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x][o] = 0;
				end
			end
		elseif previous_dir == 'east' then
			for o=first_location.x,chunk_width,1 do
				if object[first_location.cx][first_location.cy][o][first_location.y] == 2 then	
					object[first_location.cx][first_location.cy][o][first_location.y] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'south west' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		--if location_distance < 0 then location_distance = location_distance * (-1) end
		previous_dir = 'north east';	
		if previous_distance > location_distance then
			for i=location_distance+1,previous_distance,1 do	
				if object[first_location.cx][first_location.cy][first_location.x+i][first_location.y-i] == 2 then	
					object[first_location.cx][first_location.cy][first_location.x+i][first_location.y-i] = 0;
				end
			end
		else
			for i=0,location_distance,1 do
				if object[first_location.cx][first_location.cy][first_location.x+i][first_location.y-i] == 0 then	
					object[first_location.cx][first_location.cy][first_location.x+i][first_location.y-i] = 2; 
				end
			end
		end
	end
	previous_distance = location_distance;
	if object[first_location.cx][first_location.cy][first_location.x][first_location.y] == 0 then
	object[first_location.cx][first_location.cy][first_location.x][first_location.y] = 2; end
	    update_objects();
end

local function build_wall_piece()
    local i,o;
		for i=0,chunk_width-1,1 do
			for o=0,chunk_width-1,1 do
				if object[first_location.cx][first_location.cy][i][o] == 2 then
					object[first_location.cx][first_location.cy][i][o] = 1;
				end
			end
		end
		previous_distance = 0;
	    update_objects(first_location.cx,first_location.cy);
end

local function draw_object()
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	local l1 = terrain_chunks
		while l1 do
			if l1.chunkx ~= nil and shadow_batch[l1.chunkx][l1.chunky] ~= nil then  
				love.graphics.draw(shadow_batch[l1.chunkx][l1.chunky], 
						-view_xview+(l1.chunkx-l1.chunky)*chunk_width*30*0.5, 
						-view_yview+(l1.chunkx+l1.chunky)*chunk_height*16*0.5
						, 0, scale_x, scale_y);
			end;
				l1 = l1.next 
		end
  	--love.graphics.draw(shadow_batch[0][0],    -view_xview, -view_yview, 0, scale_x, scale_y);
	love.graphics.setCanvas()
	
	love.graphics.setColor(255,255,255,50)
	love.graphics.draw(canvas,0,0)
	love.graphics.setColor(255,255,255,255)
	local l = terrain_chunks
	while l do
			if l.chunkx == nil or object_batch[l.chunkx][l.chunky] == nil then break end;
  			love.graphics.draw(object_batch[l.chunkx][l.chunky], 
     				-view_xview+(l.chunkx-l.chunky)*chunk_width*30*0.5, 
					-view_yview+(l.chunkx+l.chunky)*chunk_height*16*0.5
					, 0, scale_x, scale_y);
			l = l.next 
	end
end

local function mousereleased(x, y, button, istouch)
   if button == 1 then 
   		-- TODO remove localx,localy when implementing chunks 
		mx, my = love.mouse.getPosition(); 
		LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); 
		LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)); 
		last_location.gx = LocalX;
		last_location.gy = LocalY;
		last_location.x = LocalX % chunk_width;
		last_location.y = LocalY % chunk_width; 
		last_location.cx = math.ceil(LocalX/chunk_width);
		last_location.cy = math.ceil(LocalY/chunk_width);
		location_distance = ((last_location.x-first_location.x)+(last_location.y-first_location.y));
		location_distance = ((last_location.gx-first_location.gx)+(last_location.gy-first_location.gy));
		print(location_distance)
		angle = math.atan2 (last_location.gy - first_location.gy,last_location.gx-first_location.gx);
		angle = (angle *180)/math.pi;
		angle = math.round (angle);
		if angle<0 then angle = 360+angle end
        build_wall_piece();
		print(angle)
   end
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
		print("First location: "..first_location.cx,first_location.cy)
   end
end

local function update()
  	if love.mouse.isDown(1) then
    	mx, my = love.mouse.getPosition(); 
		LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); 
		LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview));  
		last_location.gx = LocalX;
		last_location.gy = LocalY;
		last_location.x = LocalX % (chunk_width);
		last_location.y = LocalY % (chunk_width); 
		last_location.cx = math.floor(LocalX/chunk_width);
		last_location.cy = math.floor(LocalY/chunk_width);
		location_distance = ((last_location.gx-first_location.gx)+(last_location.gy-first_location.gy));
		--print("Location: "..location_distance)
		angle = math.atan2 (last_location.gy - first_location.gy,last_location.gx-first_location.gx) --* 2;
		angle = (angle *180)/math.pi;
		angle = math.round (angle);
		if angle<0 then angle = 360+angle end
        generate_wall_piece();
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

local tableOfFunctions = {
                        update = update, 
                        draw = draw_object,
                        chunk = object[first_location.cx][first_location.cy], 
                        mousereleased = mousereleased, 
                        mousepressed = mousepressed, 
                        generate_wall_piece = generate_wall_piece,
                        
                        }
return tableOfFunctions, update_objects














