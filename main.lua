
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end


function love.load()

	--Version, title and window information
	    version = 0.001;
	    width, height, flags = love.window.getMode();
	    love.window.setTitle( "Stronghold Empires ".."v"..version);
	    image = love.graphics.newImage( "assets/tiles/collection148.png" )
	    view_xview = 0;
	    view_yview = 0;
	    mx = 0;
	    my = 0;
	    LocalX = 0;
	    LocalY = 0;

	--Request other files
		require("terrain");
    require("iso");
		setup_terrain();
end




function love.update(dt)
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

  if love.keyboard.isDown("up") or love.keyboard.isDown("down") or love.keyboard.isDown("left") or love.keyboard.isDown("right") then
  	update_terrain();
  end

  mx, my = love.mouse.getPosition( )  
   LocalX = math.round(ScreenToIsoX(mx-16+view_xview, my-8+view_yview)); LocalY = math.round(ScreenToIsoY(mx-16+view_xview, my-8+view_yview)); 

end





function love.draw()

    draw_terrain();
    love.graphics.draw(image,IsoToScreenX(LocalX,LocalY)-view_xview,IsoToScreenY(LocalX,LocalY)-view_yview)



        love.graphics.print("v"..terrain_chunk[1][1] ..
         "\n LocalX: " .. LocalX ..
         "\n LocalY: " .. LocalY ..
         "\n view_xview: " .. view_xview ..
         "\n view_yview: " .. view_yview ..
         "\nCurrent FPS: "..tostring(love.timer.getFPS( )), 0, 0);
 
end