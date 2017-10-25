	----Tiles
	        tile_width = 30;
	        tile_height = 16;
    ----Chunks
	        chunk_width = 64;
	        chunk_height = 64;
	        chunk_size = chunk_width*chunk_height;
                current_chunk_x = 0;
                current_chunk_y = 0;
                CenterX = 0;
                CenterY = 0;
                list = nil; --warning REMOVE THIS, I WAS JUST TESTING LINKED LISTS, YES THEY WORK FINE
                list = {next = list, chunkx = current_chunk_x, chunky = current_chunk_y}                
                list = {next = list, chunkx = current_chunk_x-1, chunky = current_chunk_y+1}                
                list = {next = list, chunkx = current_chunk_x+1, chunky = current_chunk_y-1}                
                list = {next = list, chunkx = current_chunk_x+1, chunky = current_chunk_y+1}
                local l = list
                while l do
                print(l.chunkx.."|"..l.chunky)
                l = l.next
                end
    ----Offset
            IsoX = 0;
            IsoY = 0;
    ----View
            scale_x = 1;
            scale_y = 1;
            scroll_speed = 10;
            window_height = 800;
            window_width = 1200;
