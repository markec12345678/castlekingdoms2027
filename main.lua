
local terrain, update_terrain = require("terrain");
local iso = require("iso");
local objects = require("objects");
scale_x = 1;
scale_y = 1;

function love.load()
      
      next_time = love.timer.getTime();
	--Version, title and window information
	    width, height, flags = love.window.getMode();
      love.window.setMode(1680, 1050, {vsync=true, fullscreen=true})
      min_dt = 1/60;
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
	--Request other files
	
    
    
    require("socket"); --ONLY FOR BENCHMARK
	--setup_terrain();
    --setup_objects();
end




------------------[ UPDATE ]------------------
function love.update(dt)
    next_time = next_time + min_dt;
    ---------------------------------------
    mx, my = love.mouse.getPosition();  
    LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)); 
    ---------------------------------------
    iso.update();
    terrain.update();
    ---------------------------------------
    if love.keyboard.isDown('w')  then --BENCHMARK
        for i=0,chunk_width-1,1 do
          for o=0,chunk_height-1,1 do
              terrain.chunk[i][o]=11;
          end
        end
        dttime = love.timer.getAverageDelta();
    end

end

function love.wheelmoved(x, y)
    iso.scale(y);
end


function love.draw()

    terrain.draw();
    love.graphics.draw(image,IsoToScreenX(LocalX,LocalY)-view_xview,IsoToScreenY(LocalX,LocalY)-view_yview,nil,scale_x);
    --draw_objects();

        love.graphics.print("v"..getTerrainChunk()[1][1] ..
         "\n LocalX: " .. LocalX ..
         "\n LocalY: " .. LocalY ..
         "\n scale_x: " .. scale_x ..
         "\n scale_y: " .. scale_y ..
         "\n time: " .. getLocationDistance() .. " meters" ..
         "\n dttime: " .. getLocationAngle() .. " ms" ..
         "\nCurrent FPS: "..tostring(love.timer.getFPS( )), 0, 0);
    
    -- LIMIT THE FPS TO 60
    
    local cur_time = love.timer.getTime();
    if next_time <= cur_time then
        next_time = cur_time;
        return;
    end
     love.timer.sleep(next_time - cur_time);
    
end

