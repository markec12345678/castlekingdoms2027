
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end
function love.load()
      min_dt = 1/60;
      next_time = love.timer.getTime();
	--Version, title and window information
	    width, height, flags = love.window.getMode();
      love.window.setMode(1680, 1050, {vsync=true, fullscreen=true})
	    love.window.setTitle( "Stronghold Empires");
	    image = love.graphics.newImage( "assets/tiles/collection148.png" )
	    view_xview = 0;
	    view_yview = 0;
	    mx = 0;
	    my = 0;
	    LocalX = 0;
	    LocalY = 0;
      scale_x = 1;
      scale_y = 1;
      time = 0;
      dttime = 0;
	--Request other files
	require("terrain");
    require("objects");
    require("iso");
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
  if love.keyboard.isDown("up")  then
    view_yview = view_yview-5;  
  end
  if love.keyboard.isDown("down")  then
    view_yview = view_yview+5;  
  end
  if love.keyboard.isDown("left")  then
    view_xview = view_xview -5;  
  end
  if love.keyboard.isDown("right")  then
    view_xview = view_xview +5;  
  end
  if love.keyboard.isDown("escape")  then
    love.event.quit();
  end
  if love.mouse.isDown(1) then
    if LocalX >=0 and LocalY>=0 and LocalX<chunk_width and LocalY<chunk_height then
    mx, my = love.mouse.getPosition(); 
		LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); 
		LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)); 
		last_location_x = LocalX;
		last_location_y = LocalY; 
		location_distance = ((last_location_x-first_location_x)+(last_location_y-first_location_y));
		angle = math.atan2 (last_location_y - first_location_y,last_location_x-first_location_x) --* 2;
		angle = (angle *180)/math.pi;
		angle = math.round (angle);
		if angle<0 then angle = 360+angle end
    generate_wall_piece();
    --terrain_chunk[LocalX][LocalY] = 12;
    --update_terrain();
    end
  end
  if love.keyboard.isDown('w')  then --BENCHMARK
    update_objects();
    dttime = love.timer.getAverageDelta();
  end

end

--------------[ MOUSE PRESSED ]---------------
--function love.mousepressed(x, y, button, istouch)
--   if button == 1 and LocalX >0 and LocalY>0 and LocalX<chunk_width and LocalY<chunk_height then 
--     
--   end
--end

function love.wheelmoved(x, y)
    if y > 0 and scale_x < 1 then 
        scale_x = scale_x + 0.1;
        scale_y = scale_y + 0.1;
    elseif y < 0 and scale_y > 0.3 then
        scale_x = scale_x - 0.1;
        scale_y = scale_y - 0.1;
    end
end



function love.draw()

    draw_terrain();
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

