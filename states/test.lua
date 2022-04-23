local test = {}
local thread

function test:enter()
    require('spec.objects_spec')
    _G.BuildController:set('castle')
    _G.BuildController.start = true
    _G.JobController = require('objects.Controllers.JobController')
    ----Pathfinding setup
    thread = love.thread.newThread('libraries/pathfinding_thread.lua')
    thread:start()
    _G.finder = require('objects.Controllers.PathController')
    love.event.quit(0)
end

return test
