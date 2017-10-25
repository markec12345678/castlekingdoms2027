
local first_location_x, first_location_y, last_location_x, last_location_y = 0;
local location_distance = 0;
local angle; 

	--Terrain Initialize
	----Rows and columns
            local cols = chunk_width;
            local rows = chunk_height;
	----Chunk 2D array
			local terrain = newAutotable(4);
			local status = newAutotable(2);
			-- for y = 0,10 do
            --     local row = {}
            --         for x = 0,10 do
			-- 			local chunk = {} 
			-- 			for yy = 0,cols do
			-- 				local rowss = {}
			-- 					for xx = 0,rows do
			-- 						rowss[x]=love.math.random(10);
			-- 					end
			-- 				chunk[y]=row;
			-- 			end
            --             row[x]=chunk;
            --         end
            --     terrain[y]=row;
            -- end
			
			for i=0,chunk_width-1,1 do
    			for o=0,chunk_height-1,1 do
					terrain[1][1][i][o]=love.math.random(1);
				end
			end

			-- Statuses:
			-- loaded saved
			-- loaded unsaved
			-- unloaded - chunk exist on hard disk
			-- nil - chunk needs to be generated first
			status[1][1] = "loaded unsaved"
			
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
			local terrain_batch = newAutotable(2);
			terrain_batch[0][0] = love.graphics.newSpriteBatch(terrain_image, chunk_width*chunk_height)
			
			

function getTerrainChunk()
	return chunk or {};
end

function getLocationDistance()
	return location_distance or 0;
end

local function generateTerrain()

end

local function update_terrain(chunk_x,chunk_y)
	if terrain_batch[chunk_x][chunk_y] == nil then 
		terrain_batch[chunk_x][chunk_y] = love.graphics.newSpriteBatch(terrain_image, chunk_width*chunk_height)
	end
	terrain_batch[chunk_x][chunk_y]:clear(); 
	for i=0,chunk_width-1,1 do
		for o=0,chunk_height-1,1 do
		terrain_batch[chunk_x][chunk_y]:add(
							tile_quads[terrain[chunk_x][chunk_y][i][o]], 
							IsoX + (i - o) * tile_width  * 0.5,
							IsoY + (i + o) * tile_height * 0.5 - tile_offset[terrain[chunk_x][chunk_y][i][o]]
							);
		end
	end				  
	terrain_batch[chunk_x][chunk_y]:flush()
end

local function draw_terrain()
  love.graphics.draw(terrain_batch[0][0], 
     				-view_xview+(current_chunk_x-current_chunk_y)*chunk_width*30*0.5, 
					-view_yview+(current_chunk_x+current_chunk_y)*chunk_height*16*0.5
					, 0, scale_x, scale_y); 
  --love.graphics.draw(terrain_batch,    -view_xview+(current_chunk_x-1)*chunk_width*30, -view_yview+(current_chunk_y-1)*chunk_height*16, 0, scale_x, scale_y); 
end

update_terrain(0,0);

local tableOfFunctions = {update = t_updateLoop, draw = draw_terrain,chunk = chunk}
return tableOfFunctions, update_terrain














