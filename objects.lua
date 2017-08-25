local first_location_x, first_location_y, last_location_x, last_location_y = 0;
local previous_distance, location_distance = 0;
local previous_dir = 'none';
local angle; 


    --2D array stuff
	----Rows and columns
            local cols = chunk_width;
            local rows = chunk_height;
	----Chunk 2D array
	        local object_chunk = {}          

            for y = 0,cols do
                local row = {}
                    for x = 0,rows do
                        row[x]=0;
                    end
                object_chunk[y]=row;
            end

	----Generate spriteBatch
	        local object_image = love.graphics.newImage( "assets/tiles/image_strip.png" );
	        local tile_quads = {};
			local tile_offset = {};
			local imageW,imageH = object_image:getWidth(), object_image:getHeight();
			-- Wall piece framework [1]
				tile_quads[1]  = love.graphics.newQuad(420, 1850, 30, 107, imageW,imageH) 
				tile_offset[1] = 107-16
			-- Wall piece built [2]
				tile_quads[2]  = love.graphics.newQuad(450, 1850, 30, 107, imageW,imageH)
				tile_offset[2] = 107-16
			local object_batch = love.graphics.newSpriteBatch(object_image, chunk_width*chunk_height)              

local function update_objects()
  object_batch:clear(); 
  for i=0,chunk_width-1,1 do
    for o=0,chunk_height-1,1 do
        if object_chunk[i][o] ~= 0 then
                    object_batch:add(
		  				tile_quads[object_chunk[i][o]], 
      					IsoX + (i - o) * tile_width  * 0.5,
      					IsoY + (i + o) * tile_height * 0.5 - (tile_offset[object_chunk[i][o]] or 0)
						  );
        end
    end
  end				  
  object_batch:flush()
end

--NOTE wall remove for diagonal direcitons
local function remove_diagonal_walls()
	--STEP 1 
	--	GET TOP and BOTTOM BORDER TILE COORDINATES
	--TODO check for middle vertical tile
	--testvar = testvar + 1;
	--testvar = testvar % 10;
	local p, distance;
	local top_tile_x, top_tile_y = 0;
	local bot_tile_x, bot_tile_y = 0;
	if (first_location_x - first_location_y) > 0 then --TILE is right side from the center
		top_tile_x = first_location_x - first_location_y;
		top_tile_y = 0;
		bot_tile_x = chunk_width-1;
		bot_tile_y = (first_location_y)+((chunk_width-1)-first_location_x); 
		distance = bot_tile_x-top_tile_x;
		for p=0,distance,1 do
			if object_chunk[top_tile_x + p][top_tile_y + p] == 2 then	
				object_chunk[top_tile_x + p][top_tile_y + p] = 0;
			end
		end
	elseif (first_location_x - first_location_y) < 0 then --TILE is left side from the center
		top_tile_x = 0;
		top_tile_y = first_location_y - first_location_x;
		bot_tile_x = first_location_x+((chunk_width-1)-first_location_y);
		bot_tile_y = chunk_width-1; 
		distance = bot_tile_y-top_tile_y;
		for p=0,distance,1 do
			if object_chunk[top_tile_x + p][top_tile_y + p] == 2 then	
				object_chunk[top_tile_x + p][top_tile_y + p] = 0;
			end
		end
	else
		top_tile_y, top_tile_x = 0, 0;
		bot_tile_y, bot_tile_x = chunk_width-1, chunk_width-1
		distance = chunk_width;
		for p=0,distance,1 do
			if object_chunk[top_tile_x + p][top_tile_y + p] == 2 then	
				object_chunk[top_tile_x + p][top_tile_y + p] = 0;
			end
		end
	end
	--STEP 2
	--  GET LEFT and RIGHT BORDER TILE COORDINATES
	local left_tile_x = 0;
	local left_tile_y = first_location_x + first_location_y;
	local right_tile_x = first_location_x + first_location_y;
	local right_tile_y = 0;
	local m;
	if right_tile_x <= chunk_width-1 then --TILE is top side or center
		for m=0,right_tile_x,1 do
			if object_chunk[left_tile_x +m][left_tile_y - m] == 2 then	
				object_chunk[left_tile_x + m][left_tile_y - m] = 0;
			end
		end
	else --TILE is bot side
		left_tile_x = first_location_x + first_location_y - chunk_width-1;
		left_tile_y = chunk_width-1;
		right_tile_x = chunk_width-1; 
		right_tile_y = first_location_x + first_location_y - chunk_width-1;
		for m=0,right_tile_x-right_tile_y,1 do
			if object_chunk[left_tile_x +m+1][left_tile_y - m+1] == 2 then	
				object_chunk[left_tile_x + m +1][left_tile_y - m+1] = 0;
			end
		end
	end
end

local function generate_wall_piece()
    local i, o;
	--NOTE-- EAST
	if ((angle >= 315+22 and angle <= 359) or (angle >=0 and angle <= 45-22)) then
		location_distance = last_location_x-first_location_x;
		if previous_dir == 'west' then
			for o=0,first_location_x,1 do
				if object_chunk[first_location_x-o][first_location_y] == 2 then	
					object_chunk[first_location_x-o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location_y,1 do
				if object_chunk[first_location_x][first_location_y-o] == 2 then	
					object_chunk[first_location_x][first_location_y-o] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location_y,chunk_height,1 do
				if object_chunk[first_location_x][o] == 2 then	
					object_chunk[first_location_x][o] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'south west' or previous_dir == 'north east' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		previous_dir = 'east';	
		if previous_distance > location_distance then
			for i=location_distance+1,previous_distance,1 do	
				if object_chunk[first_location_x+i][first_location_y] == 2 then	
					object_chunk[first_location_x+i][first_location_y] = 0;
				end
			end
		else
			for i=0,location_distance,1 do
				if object_chunk[first_location_x+i][first_location_y] == 0 then	
					object_chunk[first_location_x+i][first_location_y] = 2; 
				end
			end
		end
	--NOTE-- WEST
	elseif (angle >= 135+22 and angle <= 225-22) then
		location_distance = last_location_x-first_location_x;
		if previous_dir == 'east' then
			for o=first_location_x,chunk_width,1 do
				if object_chunk[o][first_location_y] == 2 then	
					object_chunk[o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location_y,1 do
				if object_chunk[first_location_x][first_location_y-o] == 2 then	
					object_chunk[first_location_x][first_location_y-o] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location_y,chunk_height,1 do
				if object_chunk[first_location_x][o] == 2 then	
					object_chunk[first_location_x][o] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'south west' or previous_dir == 'north east' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		previous_dir = 'west';	
		if location_distance < 0 then location_distance = location_distance * (-1) end
		if previous_distance > location_distance then
			for i=location_distance+1,previous_distance,1 do	
				if object_chunk[first_location_x-i][first_location_y] == 2 then	
					object_chunk[first_location_x-i][first_location_y] = 0;
				end
			end
		else
			for i=0,location_distance,1 do
				if object_chunk[first_location_x-i][first_location_y] == 0 then	
					object_chunk[first_location_x-i][first_location_y] = 2; 
				end
			end
		end
	--NOTE-- NORTH
	elseif (angle >= 225+22 and angle <= 315-22) then
		location_distance = last_location_y-first_location_y;
		if previous_dir == 'west' then
			for o=0,first_location_x,1 do
				if object_chunk[first_location_x-o][first_location_y] == 2 then	
					object_chunk[first_location_x-o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'east' then
			for o=first_location_x,chunk_width,1 do
				if object_chunk[o][first_location_y] == 2 then	
					object_chunk[o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location_y,chunk_height,1 do
				if object_chunk[first_location_x][o] == 2 then	
					object_chunk[first_location_x][o] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'south west' or previous_dir == 'north east' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		previous_dir = 'north';	
		if location_distance < 0 then location_distance = location_distance * (-1) end
		if previous_distance > location_distance then
			for i=location_distance+1,previous_distance,1 do	
				if object_chunk[first_location_x][first_location_y-i] == 2 then	
					object_chunk[first_location_x][first_location_y-i] = 0;
				end
			end
		else
			for i=0,location_distance,1 do
				if object_chunk[first_location_x][first_location_y-i] == 0 then	
					object_chunk[first_location_x][first_location_y-i] = 2; 
				end
			end
		end
	--NOTE-- SOUTH
	elseif (angle >= 45+22 and angle <= 135-22) then
		location_distance = last_location_y-first_location_y;
		if previous_dir == 'west' then
			for o=0,first_location_x,1 do
				if object_chunk[first_location_x-o][first_location_y] == 2 then	
					object_chunk[first_location_x-o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'east' then
			for o=first_location_x,chunk_width,1 do
				if object_chunk[o][first_location_y] == 2 then	
					object_chunk[o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location_y,1 do
				if object_chunk[first_location_x][first_location_y-o] == 2 then	
					object_chunk[first_location_x][first_location_y-o] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'south west' or previous_dir == 'north east' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		previous_dir = 'south';	
		if previous_distance > location_distance then
			for i=location_distance+1,previous_distance,1 do	
				if object_chunk[first_location_x][first_location_y+i] == 2 then	
					object_chunk[first_location_x][first_location_y+i] = 0;
				end
			end
		else
			for i=0,location_distance,1 do
				if object_chunk[first_location_x][first_location_y+i] == 0 then	
					object_chunk[first_location_x][first_location_y+i] = 2; 
				end
			end
		end
	--NOTE-- SOUTH EAST
	elseif (angle > 45-22 and angle < 45+22) then
		if previous_dir == 'west' then
			for o=0,first_location_x,1 do
				if object_chunk[first_location_x-o][first_location_y] == 2 then	
					object_chunk[first_location_x-o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location_y,1 do
				if object_chunk[first_location_x][first_location_y-o] == 2 then	
					object_chunk[first_location_x][first_location_y-o] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location_y,chunk_height,1 do
				if object_chunk[first_location_x][o] == 2 then	
					object_chunk[first_location_x][o] = 0;
				end
			end
		elseif previous_dir == 'east' then
			for o=first_location_x,chunk_width,1 do
				if object_chunk[o][first_location_y] == 2 then	
					object_chunk[o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'south west' or previous_dir == 'north east' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		previous_dir = 'south east';	
		if previous_distance > location_distance then
			for i=math.round(location_distance/2)+1,math.round(previous_distance/2),1 do	
				if object_chunk[first_location_x+i][first_location_y+i] == 2 then	
					object_chunk[first_location_x+i][first_location_y+i] = 0;
				end
			end
		else
			for i=0,(location_distance/2),1 do
				if object_chunk[first_location_x+i][first_location_y+i] == 0 then	
					object_chunk[first_location_x+i][first_location_y+i] = 2; 
				end
			end
		end
	--NOTE-- NORTH WEST
	elseif (angle > 225-22 and angle < 225+22) then
		if previous_dir == 'west' then
			for o=0,first_location_x,1 do
				if object_chunk[first_location_x-o][first_location_y] == 2 then	
					object_chunk[first_location_x-o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location_y,1 do
				if object_chunk[first_location_x][first_location_y-o] == 2 then	
					object_chunk[first_location_x][first_location_y-o] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location_y,chunk_height,1 do
				if object_chunk[first_location_x][o] == 2 then	
					object_chunk[first_location_x][o] = 0;
				end
			end
		elseif previous_dir == 'east' then
			for o=first_location_x,chunk_width,1 do
				if object_chunk[o][first_location_y] == 2 then	
					object_chunk[o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'south west' or previous_dir == 'north east' then
			remove_diagonal_walls();
		end

		if location_distance < 0 then location_distance = location_distance * (-1) end
		previous_dir = 'north west';	
		if previous_distance > location_distance then
			for i=math.round(location_distance/2)+1,math.round(previous_distance/2),1 do	
				if object_chunk[first_location_x-i][first_location_y-i] == 2 then	
					object_chunk[first_location_x-i][first_location_y-i] = 0;
				end
			end
		else
			for i=0,(location_distance/2),1 do
				if object_chunk[first_location_x-i][first_location_y-i] == 0 then	
					object_chunk[first_location_x-i][first_location_y-i] = 2; 
				end
			end
		end
	--NOTE-- SOUTH WEST
	elseif (angle > 135-22 and angle < 135+22) then
		location_distance = math.floor((last_location_x - first_location_x + first_location_y - last_location_y)/2);
		if previous_dir == 'west' then
			for o=0,first_location_x,1 do
				if object_chunk[first_location_x-o][first_location_y] == 2 then	
					object_chunk[first_location_x-o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location_y,1 do
				if object_chunk[first_location_x][first_location_y-o] == 2 then	
					object_chunk[first_location_x][first_location_y-o] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location_y,chunk_height,1 do
				if object_chunk[first_location_x][o] == 2 then	
					object_chunk[first_location_x][o] = 0;
				end
			end
		elseif previous_dir == 'east' then
			for o=first_location_x,chunk_width,1 do
				if object_chunk[o][first_location_y] == 2 then	
					object_chunk[o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'north east' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		if location_distance < 0 then location_distance = location_distance * (-1) end
		previous_dir = 'south west';	
		if previous_distance > location_distance then
			for i=location_distance+1,previous_distance,1 do	
				if object_chunk[first_location_x-i][first_location_y+i] == 2 then	
					object_chunk[first_location_x-i][first_location_y+i] = 0;
				end
			end
		else
			for i=0,location_distance,1 do
				if object_chunk[first_location_x-i][first_location_y+i] == 0 then	
					object_chunk[first_location_x-i][first_location_y+i] = 2; 
				end
			end
		end
	--NOTE-- NORTH EAST
	elseif (angle > 315-22 and angle < 315+22) then
		location_distance = math.floor((last_location_x - first_location_x + first_location_y - last_location_y)/2);
		if previous_dir == 'west' then
			for o=0,first_location_x,1 do
				if object_chunk[first_location_x-o][first_location_y] == 2 then	
					object_chunk[first_location_x-o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'north' then
			for o=0,first_location_y,1 do
				if object_chunk[first_location_x][first_location_y-o] == 2 then	
					object_chunk[first_location_x][first_location_y-o] = 0;
				end
			end
		elseif previous_dir == 'south' then
			for o=first_location_y,chunk_height,1 do
				if object_chunk[first_location_x][o] == 2 then	
					object_chunk[first_location_x][o] = 0;
				end
			end
		elseif previous_dir == 'east' then
			for o=first_location_x,chunk_width,1 do
				if object_chunk[o][first_location_y] == 2 then	
					object_chunk[o][first_location_y] = 0;
				end
			end
		elseif previous_dir == 'south east' or previous_dir == 'south west' or previous_dir == 'north west' then
			remove_diagonal_walls();
		end

		--if location_distance < 0 then location_distance = location_distance * (-1) end
		previous_dir = 'north east';	
		if previous_distance > location_distance then
			for i=location_distance+1,previous_distance,1 do	
				if object_chunk[first_location_x+i][first_location_y-i] == 2 then	
					object_chunk[first_location_x+i][first_location_y-i] = 0;
				end
			end
		else
			for i=0,location_distance,1 do
				if object_chunk[first_location_x+i][first_location_y-i] == 0 then	
					object_chunk[first_location_x+i][first_location_y-i] = 2; 
				end
			end
		end
	end
	previous_distance = location_distance;
	if object_chunk[first_location_x][first_location_y] == 0 then
	object_chunk[first_location_x][first_location_y] = 2; end
	    update_objects();
end

local function build_wall_piece()
    local i;
		for i=0,location_distance,1 do	
			if object_chunk[first_location_x+i][first_location_y] == 2 then
				object_chunk[first_location_x+i][first_location_y] = 1;
			end
		end
		previous_distance = 0;
	    update_objects();
end

local function draw_object()
  love.graphics.draw(object_batch,    -view_xview, -view_yview, 0, scale_x, scale_y); 
end

local function mousereleased(x, y, button, istouch)
   if button == 1 and LocalX >=0 and LocalY>=0 and LocalX<chunk_width and LocalY<chunk_height then 
   		-- TODO remove localx,localy when implementing chunks 
		mx, my = love.mouse.getPosition(); 
		LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); 
		LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)); 
		last_location_x = LocalX;
		last_location_y = LocalY; 
		location_distance = ((last_location_x-first_location_x)+(last_location_y-first_location_y));
		angle = math.atan2 (last_location_y - first_location_y,last_location_x-first_location_x);
		angle = (angle *180)/math.pi;
		angle = math.round (angle);
		if angle<0 then angle = 360+angle end
        build_wall_piece();
   end
end

local function mousepressed(x, y, button, istouch)
   if button == 1 and LocalX >=0 and LocalY>=0 and LocalX<chunk_width and LocalY<chunk_height then 
		mx, my = love.mouse.getPosition(); 
		LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); 
		LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)); 
		first_location_x = LocalX;
		first_location_y = LocalY;
   end
end

local function update()
  if love.mouse.isDown(1) then
    if LocalX >=0 and LocalY>=0 and LocalX<chunk_width and LocalY<chunk_height then
    mx, my = love.mouse.getPosition(); 
		LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); 
		LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)); 
		last_location_x = LocalX;
		last_location_y = LocalY; 
		location_distance = ((last_location_x-first_location_x)+(last_location_y-first_location_y));
		angle = math.atan2 (last_location_y - first_location_y,last_location_x-first_location_x) --* 2;
		angle = (angle *180)/math.pi;
		angle = math.round (angle);
		if angle<0 then angle = 360+angle end
        generate_wall_piece();
    end
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
update_objects();

local tableOfFunctions = {
                        update = update, 
                        draw = draw_object,
                        chunk = object_chunk, 
                        mousereleased = mousereleased, 
                        mousepressed = mousepressed, 
                        generate_wall_piece = generate_wall_piece,
                        
                        }
return tableOfFunctions, update_objects














