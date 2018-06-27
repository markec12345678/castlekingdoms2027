local test = {}
local Gamestate = require('libraries.gamestate')
local thread

function test:enter()
    print("we in")
	require('spec.objects_spec')
	_G.chunkUpdateList = require('objects.chunk_system')
	_G.BuildController:set('castle')
	_G.BuildController.start = true
	_G.JobController = require('objects.Controllers.JobController')
	----Pathfinding setup
	thread = love.thread.newThread ( "libraries/pathfinding_thread.lua" )
	thread:start ()
	_G.finder = require('objects.Controllers.PathController')
    print("we done")
	love.event.quit(0)
end

return test