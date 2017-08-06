function setup_objects()
	--Objects Initialize	
	----Rows and columns
            canvas = love.graphics.newCanvas(1680, 1050)
            cols = chunk_width;
            rows = chunk_height;
            ogX = 700;
            ogY = 500;
	----Chunk 2D array
	        object_chunk = {}          
            imageData = love.graphics.newImage(love.image.newImageData( 1,1 )); 
            for y = 0,cols do
                local row = {}
                    for x = 0,rows do
                        row[x]=imageData;
                    end
                object_chunk[y]=row;
            end

	----Generate spriteBatch
            object_image = {}
	        object_image[1] = love.graphics.newImage( "assets/trees/0_0img0.png" );

	----Generate terrain    
            update_objects();           
end


function update_objects()
  object_chunk[0][0] = object_image[1];
  for i=0,chunk_width-1,1 do
        for o=0,chunk_height-1,1 do
        if love.math.random(100) == 1 then
            object_chunk[i][o] = object_image[1]; 
        end
    end
  end
  love.graphics.setCanvas(canvas)
            love.graphics.clear()
            love.graphics.setBlendMode("alpha")
        for i=0,chunk_width,1 do
        for o=0,chunk_height,1 do           
            love.graphics.draw(object_chunk[i][o], ogX+ogIsoToScreenX(i,o)-77+16, ogY+ogIsoToScreenY(i,o)-138+8); 
            
        end
        end
        love.graphics.setCanvas()
end

function draw_objects()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(canvas,-view_xview-ogX,-view_yview-ogY)
    love.graphics.setBlendMode("alpha")
end

