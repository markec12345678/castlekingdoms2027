

function setup_terrain()
	--Terrain Initialize
	----Tiles
	        tile_width = 32;
	        tile_height = 16;
	        tile_variations = 1;

    ----Chunks
	        chunk_width = 320;
	        chunk_height = 320;
	        chunk_size = chunk_width*chunk_height;
	        IsoX = 400;
            IsoY = 0;
	----Rows and columns
            cols = chunk_width;
            rows = chunk_height;
	----Chunk 2D array
	        terrain_chunk = {}          

            for y = 0,cols do
                local row = {}
                    for x = 0,rows do
                        row[x]=love.math.random(8);
                    end
                terrain_chunk[y]=row;
            end
            array_x = 0;
            array_y = 0;

	----Generate spriteBatch
	        terrain_image = love.graphics.newImage( "assets/tiles/terrain_strip2.png" );
	        tile_quads = {};
	        tile_quads[1] = love.graphics.newQuad(0 * tile_width, 0 * tile_height, tile_width-2, tile_height, terrain_image:getWidth(), terrain_image:getHeight())
	        tile_quads[2] = love.graphics.newQuad(1 * (tile_width-2), 0 * tile_height, tile_width-2, tile_height, terrain_image:getWidth(), terrain_image:getHeight())
	        tile_quads[3] = love.graphics.newQuad(2 * (tile_width-2), 0 * tile_height, tile_width-2, tile_height, terrain_image:getWidth(), terrain_image:getHeight())
	        tile_quads[4] = love.graphics.newQuad(3 * (tile_width-2), 0 * tile_height, tile_width-2, tile_height, terrain_image:getWidth(), terrain_image:getHeight())
	        tile_quads[5] = love.graphics.newQuad(4 * (tile_width-2), 0 * tile_height, tile_width-2, tile_height, terrain_image:getWidth(), terrain_image:getHeight())
	        tile_quads[6] = love.graphics.newQuad(5 * (tile_width-2), 0 * tile_height, tile_width-2, tile_height, terrain_image:getWidth(), terrain_image:getHeight())
	        tile_quads[7] = love.graphics.newQuad(6 * (tile_width-2), 0 * tile_height, tile_width-2, tile_height, terrain_image:getWidth(), terrain_image:getHeight())
	        tile_quads[8] = love.graphics.newQuad(7 * (tile_width-2), 0 * tile_height, tile_width-2, tile_height, terrain_image:getWidth(), terrain_image:getHeight())
	        terrain_batch = love.graphics.newSpriteBatch(terrain_image, chunk_width*chunk_height)
	----Generate terrain    
            update_terrain();
end


function update_terrain()
  terrain_batch:clear()
  for i=chunk_width-1,0,-1 do
    for o=chunk_height-1,0,-1 do
      terrain_batch:add(
		  				tile_quads[terrain_chunk[i][o]], 
      					(-view_xview)+IsoX + (i - o) * tile_width  * 0.5,
      					(-view_yview)+IsoY + (i + o) * tile_height * 0.5
						  )
    end
  end
  terrain_batch:flush()
end

function draw_terrain()
  love.graphics.draw(terrain_batch,    -view_xview, -view_yview, 0, 1, 1) 
end





















