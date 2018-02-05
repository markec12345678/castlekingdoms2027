	----Functions
            local ffi = require("ffi")
            local bitser = require('libraries.bitser')
            function printList(list)
                local l = list;
                while l do
                    print("Chunk: "..(l.chunkx or "none").."|"..(l.chunky or "none"))
                    l = l.next
                end
            end

            function newAutotable(dim)
                local MT = {};
                for i=1, dim do
                    MT[i] = {__index = function(t, k)
                        if i < dim then
                            t[k] = setmetatable({}, MT[i+1])
                            return t[k];
                        end
                    end}          
                end

                return setmetatable({}, MT[1]);
            end

            function listInsert(list,key1,value1,key2,value2)
                list = {next = list, key1 = value1, key2 = value2}
            end            
            terrain_chunks = nil;
    ----Tiles
	        tile_width = 32;
	        tile_height = 16;
    ----Chunks
            xchunk = 0;
            ychunk = 0;
	        chunk_width = 64;
	        chunk_height = 64;
                current_chunk_x = 0;
                current_chunk_y = 0;
                CenterX = 0;
                CenterY = 0;
                previous_chunk_x = 0;
                previous_chunk_y = 0;       
            chunkUpdateList = function () end;
            previous_terrain_chunks = 0; 
    ----Terrain
            terrain = newAutotable(2) 
            if love.filesystem.exists("status.bin") then status = bitser.loadLoveFile("status.bin") else
            status = newAutotable(2) end   
            _G.chunk_objects = newAutotable(2);     
            print("Fucking done") 
    ----Offset
            IsoX = 0;
            IsoY = 0;
    ----View
            scale_x = 1;
            scale_y = 1;
            scroll_speed = 10;
            window_height = 800;
            window_width = 1200;  
            view_xview = 0;
	        view_yview = 5000;
    ----Mouse
	    mx = 0;
	    my = 0;
	    LocalX = 0;
	    LocalY = 0;
        time = 0;
        dttime = 0;
        lx_offset = 0;
        ly_offset = 0;
        px_img_y_offset = 0;        
        tile_image = {} 
	----Version, title and window information
	    width, height, flags = love.window.getMode();
        min_dt = 1/60;
        next_time = 0;
    ----Objects related    
        building_selection = 398;
        tile_offset, tile_offset_x = {}, {};
        wood = 10;
    ----Pathfinding data structures
        collision_map = ffi.new("unsigned char[2048][2048]", {})
        ffi.cdef[[
        void *calloc(size_t nitems, size_t size);
        void free(void *ptr);
        typedef struct node node;

        struct node { 
            short _x,_y,_h,_g,_f; 
            unsigned char walkable; 
            bool _opened, _closed, init; 
            node* _parent;
        };
        ]]        
        -- local N = 8192
        -- local arr = ffi.cast("unsigned char **", ffi.C.malloc(N*ffi.sizeof("unsigned char*")))
        -- for i = 0, N do
        --     arr[i] = ffi.cast("unsigned char *", ffi.C.malloc(N*ffi.sizeof("unsigned char")))
        -- end
        -- assert(arr ~= nil, "out of memory")

        -- print("array =", arr)
        -- arr[0][2] = 1.5
        -- arr[N-1][3] = 2.5
        -- print("arr[0][2] =", arr[0][2])
        -- print("arr["..(N-1).."][3] =", arr[N-1][3])
    ----Libraries        
        anim = require('libraries.anim8') 
        class = require('libraries.middleclass') 
        inspect = require('libraries.inspect')