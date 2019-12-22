if _G.test_mode then 
	require('libraries.love.love_graphics')
end

require('global')
local Gamestate = require('libraries.gamestate')
local loader = require('libraries.lily')

local main_menu = require('states.main_menu')
local game = require('states.game')
local test = require('states.test')

function love.load(arg)	
    Gamestate.registerEvents()
    if _G.test_mode then 
		Gamestate.switch(test)
		return 
	else		
    	Gamestate.switch(main_menu)
	end
	loader.newImage("assets/tiles/object_texture.dxt5"):onComplete(function(userdata,image)
		_G.object_image = image
	end)
end


function love.quit()
    --bitser.dumpLoveFile("status.bin",status)
    return true
end


function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
	end
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
	dt = 0
	-- Main loop time.
	
	while true do
		-- Process events.
		love.event.pump()
		for name, a,b,c,d,e,f in love.event.poll() do
			if name == "quit" then
				if not love.quit or not love.quit() then
					return a
				end
			end
			love.handlers[name](a,b,c,d,e,f)
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
