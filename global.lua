	----Functions
            

            function printList(list)
                local l = list;
                while l do
                    print("Chunk: "..(l.chunkx or "none").."|"..(l.chunky or "none"))
                    l = l.next
                end
            end

            function listInsert(list,key1,value1,key2,value2)
                list = {next = list, key1 = value1, key2 = value2}
            end
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
                previous_chunk_x = 0;
                previous_chunk_y = 0;                
                                collectgarbage();
                -- list = nil; --warning REMOVE THIS
                -- list = {next = list, chunkx = current_chunk_x, chunky = current_chunk_y}                
                -- list = {next = list, chunkx = current_chunk_x-1, chunky = current_chunk_y+1}                
                -- list = {next = list, chunkx = current_chunk_x+1, chunky = current_chunk_y-1}                
                -- list = {next = list, chunkx = current_chunk_x+1, chunky = current_chunk_y+1}
                -- local l = list
                
                
                
                -- local l = list
                -- while l do
                -- print(l.chunkx.."|"..l.chunky)
                -- l = l.next
                -- end
                
    ----Offset
            IsoX = 0;
            IsoY = 0;
    ----View
            scale_x = 1;
            scale_y = 1;
            scroll_speed = 10;
            window_height = 800;
            window_width = 1200;
