require('global');
local iso = require("iso");
local terrain, update_terrain = require("terrain");
local objects, update_objects = require("objects");
terrain_chunks = nil;
--terrain_chunks = {next = terrain_chunks, chunkx = 0, chunky = 0}
chunkUpdateList()
testvar = -4;
--debug.setmetatable(nil, { __index={} }); -- to avoid nil errors
function love.load()
    next_time = love.timer.getTime();
    min_dt = 1/60;
	--Version, title and window information
	    width, height, flags = love.window.getMode();
      --love.window.setMode(800, 600, {vsync=true, fullscreen=false})
	    love.window.setTitle( "Stronghold Empires");
	    image = love.graphics.newImage( "assets/tiles/collection148.png" )
	    view_xview = 0;
	    view_yview = 0;
	    mx = 0;
	    my = 0;
	    LocalX = 0;
	    LocalY = 0;
      time = 0;
      dttime = 0;

    require("socket"); --ONLY FOR BENCHMARK
	--setup_terrain();
    --setup_objects();
end


-----UPDATE LOOP
function love.update(dt)
    next_time = next_time + min_dt;
    ---------------------------------------
    mx, my = love.mouse.getPosition();  
    LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)); 
    CenterX = math.round(ScreenToIsoX(window_width/2-16+view_xview, window_height/2-8+view_yview)); CenterY = math.round(ScreenToIsoY(window_width/2-16+view_xview, window_height/2-8+view_yview));
    ---------------------------------------
    xchunk = math.floor(CenterX/(chunk_width-1));
    ychunk = math.floor(CenterY/(chunk_width-1));
    current_chunk_x = xchunk;
    current_chunk_y = ychunk;
    if previous_chunk_x ~= current_chunk_x or previous_chunk_y ~= current_chunk_y then 
        --terrain.update()
        chunkUpdateList()
    end
    previous_chunk_x = current_chunk_x;
    previous_chunk_y = current_chunk_y;
    ---------------------------------------
    iso.update();    
    objects.update();
    
--xchunk = math.ceil((view_xview+800)/(chunk_width*tile_width));
--ychunk = math.ceil((view_yview+600)/(chunk_width*tile_height));

    ---------------------------------------
    if love.keyboard.isDown('w')  then --BENCHMARK
    print("_____________")
        printList(terrain_chunks);
    print("_____________")
    end

end

function love.wheelmoved(x, y)
    iso.scale(y);
end
-----DRAW LOOP
function love.draw()

    terrain.draw();
    objects.draw();
    love.graphics.draw(image,IsoToScreenX(LocalX,LocalY)-view_xview,IsoToScreenY(LocalX,LocalY)-view_yview,nil,scale_x);
    love.graphics.draw(image,IsoToScreenX(CenterX,CenterY)-view_xview,IsoToScreenY(CenterX,CenterY)-view_yview,nil,scale_x);
    --draw_objects();
    
    local stats = love.graphics.getStats()
 
    local str = string.format("\n Texture memory used: %.2f MB", stats.texturememory / 1024 / 1024)
    local str2 = string.format("\n Amount of drawcalls: %d", stats.drawcalls)
    local name, version, vendor, device = love.graphics.getRendererInfo()
    local limits = love.graphics.getSystemLimits( )
    
        love.graphics.print(
         "\n LocalX: " .. LocalX ..
         "\n LocalY: " .. LocalY ..
         "\n scale_x: " .. scale_x ..
         "\n scale_y: " .. scale_y ..
         "\n previous distance: " .. (getPreviousDistance()) .. " meters" ..
         "\n location_distance: " .. (getLocation() or 0) .. " meters" ..
         "\n dir: " .. getPreviousDir() .. " " ..
         str .. " " ..
         str2 .. " " ..
         "\n Center chunk: [" .. xchunk .. "][".. ychunk .."]" ..
         "\n GPU: " .. device .. " " ..
         "\n CPU cores: " .. love.system.getProcessorCount( ) .. 
         "\n Max atlas size: " .. limits.texturesize .. " " ..
         "\nCurrent FPS: "..tostring(love.timer.getFPS( ))
         , 0, 0);
        -- LIMIT THE FPS TO 60
            local cur_time = love.timer.getTime();
            if next_time <= cur_time then
                next_time = cur_time;
                return;
            end
            love.timer.sleep(next_time - cur_time);
   
    
end
-----MOUSE RELEASED
function love.mousereleased(x, y, button, istouch)
    objects.mousereleased(x,y,button,istouch);
end
-----MOUSE PRESSED
function love.mousepressed(x, y, button, istouch)
    objects.mousepressed(x,y,button,istouch);
end

function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
	end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
	local dt = 0
 
	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
 
		-- Call update and draw 
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw() end             
			love.graphics.present()
		end
	end

end