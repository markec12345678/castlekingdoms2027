
local first_location_x, first_location_y, last_location_x, last_location_y = 0;
local location_distance = 0;
local angle; 


	--Terrain Initialize
	----Rows and columns
            local cols = chunk_width;
            local rows = chunk_height;
	----Chunk 2D array
	        local terrain_chunk = {}          

            for y = 0,cols do
                local row = {}
                    for x = 0,rows do
                        row[x]=love.math.random(10);
                    end
                terrain_chunk[y]=row;
            end

	----Generate spriteBatch
	        local terrain_image = love.graphics.newImage( "assets/tiles/image_strip.png" );
	        local tile_quads = {};
			local tile_offset = {};
			local imageW,imageH = terrain_image:getWidth(), terrain_image:getHeight();
	        tile_quads[1] = love.graphics.newQuad(0, 1850, 30, 16, imageW,imageH)
			tile_offset[1] = 0
			tile_offset[2] = 0
			tile_offset[3] = 0
			tile_offset[4] = 0
			tile_offset[5] = 0
			tile_offset[6] = 0
			tile_offset[7] = 0
			tile_offset[8] = 0
			tile_offset[9] = 0
			tile_offset[10] = 0
			tile_quads[2] = love.graphics.newQuad(0, 1866, 30, 16, imageW,imageH)
			tile_quads[3] = love.graphics.newQuad(30, 1850, 30, 16, imageW,imageH)
			tile_quads[4] = love.graphics.newQuad(0, 1882, 30, 16, imageW,imageH)
			tile_quads[5] = love.graphics.newQuad(30, 1866, 30, 16, imageW,imageH)
			tile_quads[6] = love.graphics.newQuad(0, 1898, 30, 16, imageW,imageH)
			tile_quads[7] = love.graphics.newQuad(60, 1850, 30, 16, imageW,imageH)
			tile_quads[8] = love.graphics.newQuad(30, 1882, 30, 16, imageW,imageH)
			tile_quads[9] = love.graphics.newQuad(0, 1914, 30, 16, imageW,imageH)
			tile_quads[10] = love.graphics.newQuad(60, 1866, 30, 16, imageW,imageH)
			tile_quads[11] = love.graphics.newQuad(420, 1850, 30, 107, imageW,imageH)
			tile_offset[11] = 107-16
			tile_quads[12] = love.graphics.newQuad(450, 1850, 30, 107, imageW,imageH)
			tile_offset[12] = 107-16
			local terrain_batch = love.graphics.newSpriteBatch(terrain_image, chunk_width*chunk_height)              

--note I don't need these functions 
--warning ss
--fixme I don't need these ?
--todo yeah
function getTerrainChunk()
	return terrain_chunk or {};
end

function getLocationDistance()
	return location_distance or 0;
end



local function update_terrain()
  terrain_batch:clear(); 
  for i=0,chunk_width-1,1 do
    for o=0,chunk_height-1,1 do
      terrain_batch:add(
		  				tile_quads[terrain_chunk[i][o]], 
      					IsoX + (i - o) * tile_width  * 0.5,
      					IsoY + (i + o) * tile_height * 0.5 - tile_offset[terrain_chunk[i][o]]
						  );
    end
  end				  
  terrain_batch:flush()
end

local function draw_terrain()
  love.graphics.draw(terrain_batch,    -view_xview, -view_yview, 0, scale_x, scale_y); 
end

update_terrain();

local tableOfFunctions = {update = t_updateLoop, draw = draw_terrain,chunk = terrain_chunk}
return tableOfFunctions, update_terrain














