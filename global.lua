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
            _G.terrain = newAutotable(2) 
            if love.filesystem.exists("status.bin") then status = bitser.loadLoveFile("status.bin") else
            status = newAutotable(2) end   
            _G.chunk_objects = newAutotable(2); 
    ----Offset
            IsoX = 0;
            IsoY = -1400;
    ----View
            scale_x = 1;
            scale_y = 1;
            scroll_speed = 10;
            window_height = 800;
            window_width = 1200;  
            view_xview = -100;
	        view_yview = 1200;
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
        width = width or 1
        height = height or 1
        min_dt = 1/60;
        next_time = 0;
    ----Objects related    
        building_selection = 398; --fixme are we still using this?
        tile_offset, tile_offset_x = {}, {};
        wood = 10;
    ----Pathfinding data structures
        _G.channel = {}
        _G.channel.request = love.thread.getChannel ( "request" )
        _G.channel.receive = love.thread.getChannel ( "receive" )
        _G.channel.map_update = love.thread.getChannel ( "map_update" )
        function setWalkable(gx,gy,walkable) 
            _G.channel.map_update:push({gx,gy,walkable})
        end
        collision_map = ffi.new("unsigned char[2048][2048]", {})            
    ----Resources
        resources = {
            ['wood'] = 0,
            ['stone'] = 0,
            ['iron'] = 0,
            ['flour'] = 0,
            ['wheat'] = 0,
        }
        _G.not_full_stockpiles = {
            ["wood"] = 0,
            ["stone"] = 0,
            ["wheat"] = 0,
            ["iron"] = 0,
            ["flour"] = 0
            }
    ----Libraries        
        anim = require('libraries.anim8') 
        class = require('libraries.middleclass') 
        inspect = require('libraries.inspect')