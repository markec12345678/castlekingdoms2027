local game = {}
local Gamestate = require('libraries.gamestate')
local core = require("misc")
local thread, objects, terrain
local ui = {show = {construction = false}}

function game:init()
    objects = love.filesystem.load('objects/objects.lua')(object_image)
    package.loaded['objects.objects'] = objects
    terrain = require('terrain.terrain')
    terrain.genMap()
    _G.chunkUpdateList = require('objects.chunk_system')
    _G.BuildController = love.filesystem.load("objects/Controllers/BuildController.lua")(package.loaded['objects.objects'].object, object_image)
    _G.JobController = require('objects.Controllers.JobController')
    ----Pathfinding setup
    thread = love.thread.newThread ( "libraries/pathfinding_thread.lua" )
    thread:start ()
    _G.finder = require('objects.Controllers.PathController')
end

function game:update(dt)
    core.update()
    objects.update()
    _G.BuildController:update()
    _G.finder:update()

    nk.frameBegin()
    nk.windowBegin('Main', 0, window_height - 160, 200, 160, 'border', 'title')
    nk.layoutRow('dynamic', 30, 1)
    if nk.button('Construction') then
	ui.show.construction = not ui.show.construction
    end
    nk.windowEnd()

    if ui.show.construction then
	if nk.windowBegin('Construction', 100, 100, 200, 160, 'border', 'title', 'movable', 'closable') then
	    nk.layoutRow('dynamic', 30, 1)
	    if nk.button('Castle') then
		_G.BuildController:set('castle')
		_G.BuildController.start = true
	    end
	    if nk.button('Stockpile') then
		_G.BuildController:set('stockpile')
		_G.BuildController.start = true
	    end
	else
	    ui.show.construction = false
	end
	nk.windowEnd()
    end
    nk.frameEnd()

    local error = thread:getError()
    assert( not error, error )
end

function game:enter()
end

function game:draw()
    if not _G.test_mode then
	love.graphics.push();
	love.graphics.translate((love.graphics.getWidth()/2),(love.graphics.getHeight()/2));
	terrain.draw()
	objects.draw()
	_G.BuildController:draw()
	love.graphics.pop()
	core.draw()

	nk.draw()
    end
end

function game:mousepressed(x, y, button, istouch)
    if nk.mousepressed(x, y, button, istouch) then return end

    terrain.mousepressed(x,y,button,istouch)
    objects.mousepressed(x,y,button,istouch)
    if button == 2 and not _G.BuildController.start then _G.BuildController.active = false end
end

function game:wheelmoved(x, y)
    if nk.wheelmoved(x, y) then return end

    core.scale(y)
end

function game:keyreleased(key, scancode)
    if nk.keyreleased(key, scancode) then return end

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
	elseif key == "f" then
	    local fullscreen, fstype = love.window.getFullscreen()
	    if fullscreen then
		love.window.setFullscreen(false)
	    else
		love.window.setFullscreen(true)
	    end
	end
    end
end

function game:keypressed(key, scancode, isrepeat)
	nk.keypressed(key, scancode, isrepeat)
end

function game:mousereleased(x, y, button, istouch)
	nk.mousereleased(x, y, button, istouch)
end

function game:mousemoved(x, y, dx, dy, istouch)
	nk.mousemoved(x, y, dx, dy, istouch)
end

function game:textinput(text)
	nk.textinput(text)
end

return game
