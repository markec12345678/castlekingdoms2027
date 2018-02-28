
math.randomseed(os.time())
math.random()
math.random()
math.random()
require('global')
local object_image
local Gamestate = require('libraries.gamestate')
local core = require("misc")
--local bitser = require('libraries.bitser')
local thread
local objects, terrain
local game, ui = {}, {}
local loader = require('libraries.lily')
-- function write(par)
-- 	f = love.filesystem.newFile("line"..par..".txt")
-- 	f:open("w")
-- 		f:write("This is line !\r\n")
-- 	f:close()
-- 	return true
-- end
-- function remove(par) 
-- 	love.filesystem.remove("line"..par..".txt")
-- 	return true
-- end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(ui)
	loader.newImage("assets/tiles/object_texture.dxt5"):onComplete(function(userdata,image)
		object_image = image
	end)
end


-----------------/||\------------------
-----------------GAME------------------
function game:init()
    objects = love.filesystem.load('objects/objects.lua')(object_image)
	package.loaded['objects.objects'] = objects
	terrain = require('terrain')
	_G.chunkUpdateList = require('objects.chunk_system')
	_G.BuildController = love.filesystem.load("objects/Controllers/BuildController.lua")(package.loaded['objects.objects'].object, object_image):new()
	_G.BuildController:set('castle')
	_G.BuildController.start = true
	_G.JobController = require('objects.Controllers.JobController'):new()
	----Pathfinding setup
	thread = love.thread.newThread ( "libraries/pathfinding_thread.lua" )
	thread:start ()
	_G.channel = {}
	_G.channel.request = love.thread.getChannel ( "request" )
	_G.channel.receive = love.thread.getChannel ( "receive" )
	_G.finder = require('objects.Controllers.PathController'):new()
end

function game:update(dt)
    core.update()
    objects.update()
	_G.BuildController:update()
	_G.finder:update()
	local error = thread:getError()
    assert( not error, error )
end

function game:enter()
end

function game:draw()
love.graphics.push();
love.graphics.translate((love.graphics.getWidth()/2),(love.graphics.getHeight()/2));
    terrain.draw()
    objects.draw()
	_G.BuildController:draw()
	love.graphics.pop()
    core.draw() 
end

function game:mousepressed(x, y, button, istouch)
	terrain.mousepressed(x,y,button,istouch)
	objects.mousepressed(x,y,button,istouch)
	if button == 2 and not _G.BuildController.start then _G.BuildController.active = false end
end

function game:wheelmoved(x, y)
	core.scale(y)
end

function game:keyreleased(key, scancode)
	if not _G.BuildController.start then
		if key == "q" then
			_G.BuildController:set('castle')
		elseif key == "w" then
			_G.BuildController:set('stockpile')
		elseif key == "e" then
			_G.BuildController:set('granary')
		elseif key == "t" then
			_G.BuildController:set('quarry')
		elseif key == "y" then
			_G.BuildController:set('iron_mine')
		elseif key == "r" then
			print(inspect(_G.resources))
		end
	end
end

-----------------GAME------------------
-----------------====------------------
------------------UI-------------------
function ui:update(dt)
	if object_image then Gamestate.switch(game) end
end

function ui:draw()
	love.graphics.print("Loading assets...",100,100)
end
------------------UI-------------------
-----------------\||/------------------


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