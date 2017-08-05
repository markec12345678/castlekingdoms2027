
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end

function love.load()
      min_dt = 1/60
      next_time = love.timer.getTime()
	--Version, title and window information
	    width, height, flags = love.window.getMode();
      love.window.setMode(800, 600, {vsync=false})
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
    require("iso");
    require("socket"); --ONLY FOR BENCHMARK
	setup_terrain();
end


local tickPeriod = 1/60 -- seconds per tick
local accumulator = 0.0

function love.update(dt)
  next_time = next_time + min_dt
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
  if love.keyboard.isDown('w')  then --BENCHMARK
    time = socket.gettime();
    update_terrain();
    time = socket.gettime()-time;
    dttime = love.timer.getAverageDelta();
  end
  mx, my = love.mouse.getPosition( )  
  LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)); 

end

function love.wheelmoved(x, y)
    if y > 0 and scale_x < 1 then
        scale_x = scale_x + 0.05;
        scale_y = scale_y + 0.05;
    elseif y < 0 and scale_y > 0.2 then
        scale_x = scale_x - 0.05;
        scale_y = scale_y - 0.05;
    end
end



function love.draw()

    draw_terrain();
    love.graphics.draw(image,IsoToScreenX(LocalX,LocalY)-view_xview,IsoToScreenY(LocalX,LocalY)-view_yview)

        love.graphics.print("v"..terrain_chunk[1][1] ..
         "\n LocalX: " .. LocalX ..
         "\n LocalY: " .. LocalY ..
         "\n scale_x: " .. scale_x ..
         "\n scale_y: " .. scale_y ..
         "\n time: " .. time*1000 .. " ms" ..
         "\n dttime: " .. dttime*1000 .. " ms" ..
         "\nCurrent FPS: "..tostring(love.timer.getFPS( )), 0, 0);
    
    -- LIMIT THE FPS TO 60
    local cur_time = love.timer.getTime()
    if next_time <= cur_time then
        next_time = cur_time;
        return;
    end
     love.timer.sleep(next_time - cur_time);
end

