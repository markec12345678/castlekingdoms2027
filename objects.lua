local first_location_x, first_location_y, last_location_x, last_location_y = 0;
local previous_distance, location_distance = 0;
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
			tile_quads[1] = love.graphics.newQuad(420, 1850, 30, 107, imageW,imageH)
			tile_offset[1] = 107-16
			tile_quads[2] = love.graphics.newQuad(450, 1850, 30, 107, imageW,imageH)
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

local function generate_wall_piece()
    local i;
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
	previous_distance = location_distance;
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
   if button == 1 and LocalX >=0 and LocalY>=0 and LocalX<chunk_width and LocalY<chunk_height then -- TODO: remove localx,localy etc for chunks 
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
function getLocation()
	return location_distance;
end
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














