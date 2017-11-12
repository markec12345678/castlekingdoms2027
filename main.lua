local lib, errmsg = package.loadlib(love.filesystem.getSource() .. "./libraries/nuklear.dll", "luaopen_nuklear")
assert(lib, errmsg)
local nk = lib()
--assert(lib, errmsg)
--local nk = lib()
--local nk = require("libraries.nuklear");
require('global');
Gamestate = require('gamestate');
local core = require("iso");
local terrain, update_terrain = require("terrain");
local objects, update_objects = require("objects");
tile_image = {};
local menu = {};
local game = {};
local ui = {};
love.graphics.setBackgroundColor( 45,85,9 )
function love.load()
	nk.init()
    Gamestate.registerEvents()
    Gamestate.switch(game)
end
-----------------/||\------------------
-----------------GAME------------------
function game:update(dt)
    core.update();    
    objects.update();
	nk.frameBegin()
	if nk.windowBegin('building_toolbox', 0, height-110, width, height,
			'border', 'movable') then
		nk.layoutRow('dynamic', 30, 1)
		nk.label('Building selection: '..(core.getBuildingSelection() or ""))
		nk.layoutRow('dynamic', 60, 8)
		if nk.button('Small castle') then
			--print('Sample!')
		end
		if nk.button('Stockpile') then
			--print('Button!')
		end
		if nk.button('Granary') then
			--print('Button!')
		end
	end
	nk.windowEnd()
	nk.frameEnd()
end
-----WHEEL MOVE
function game:wheelmoved(x, y)
    core.scale(y);
end
-----ENTER
function game:enter()
    tile_image[0] = love.graphics.newImage( "assets/tiles/collection1489.png" )
    tile_image[1] = tile_image[0];
    tile_image[2] = love.graphics.newImage( "assets/tiles/collection1499.png" )
end
-----DRAW LOOP
function game:draw()
    terrain.draw()
    objects.draw()
    core.draw();
	nk.draw()
end
-----MOUSE RELEASED
function game:mousereleased(x, y, button, istouch)
    objects.mousereleased(x,y,button,istouch);
	if nk.mousereleased(x, y, button, istouch) then
		return -- event consumed
	end
end
-----MOUSE PRESSED
function game:mousepressed(x, y, button, istouch)
    objects.mousepressed(x,y,button,istouch);
	if nk.mousepressed(x, y, button, istouch) then
		return -- event consumed
	end
end

function game:keypressed(key, scancode, isrepeat)
	if nk.keypressed(key, scancode, isrepeat) then
		return -- event consumed
	end
end

function game:keyreleased(key, scancode)
	if nk.keyreleased(key, scancode) then
		return -- event consumed
	end
end

function game:mousemoved(x, y, dx, dy, istouch)
	if nk.mousemoved(x, y, dx, dy, istouch) then
		return -- event consumed
	end
end

function game:textinput(text)
	if nk.textinput(text) then
		return -- event consumed
	end
end

function game:wheelmoved(x, y)
	if nk.wheelmoved(x, y) then
		return -- event consumed
	end
end
-----------------GAME------------------
-----------------\||/------------------













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