local game = {}
local Gamestate = require('libraries.gamestate')
local core = require("misc")
local thread, objects, terrain
local ui = {
    show = {
        construction = false
    }
}

local function manual_gc(time_budget, safetynet_megabytes, disable_otherwise)
    local max_steps = 1000
    local steps = 0
    local start_time = love.timer.getTime()
    while love.timer.getTime() - start_time < time_budget and steps < max_steps do
        collectgarbage("step", 1)
        steps = steps + 1
    end
    -- safety net
    if collectgarbage("count") / 1024 > safetynet_megabytes then
        collectgarbage("collect")
    end
    -- don't collect gc outside this margin
    if disable_otherwise then
        collectgarbage("stop")
    end
end

function game:init()
    objects = love.filesystem.load('objects/objects.lua')(object_image)
    package.loaded['objects.objects'] = objects
    terrain = require('terrain.terrain')
    terrain.genMap()
    _G.chunkUpdateList = require('objects.chunk_system')
    _G.BuildController = love.filesystem.load("objects/Controllers/BuildController.lua")(
        package.loaded['objects.objects'].object, object_image)
    _G.JobController = require('objects.Controllers.JobController')
    ----Pathfinding setup
    thread = love.thread.newThread("libraries/pathfinding_thread.lua")
    thread:start()
    _G.finder = require('objects.Controllers.PathController')
    _G.BuildController:set("castle")
end

function game:update(dt)
    prof.push("core")
    core.update()
    prof.pop("core")
    prof.push("objects")
    objects.update()
    prof.pop("objects")
    prof.push("bcontr")
    _G.BuildController:update()
    prof.pop("bcontr")
    prof.push("pathfind")
    _G.finder:update()
    prof.pop("pathfind")
    prof.push("gc")
    manual_gc(0.7e-3, 20000)
    prof.pop("gc")
    local error = thread:getError()
    assert(not error, error)
end

function game:enter()
    collectgarbage()
    collectgarbage()
end

function game:draw()
    if not _G.test_mode then
        love.graphics.push();
        love.graphics.translate((love.graphics.getWidth() / 2), (love.graphics.getHeight() / 2));
        terrain.draw()
        objects.draw()
        _G.BuildController:draw()
        love.graphics.pop()
        core.draw()
    end
end

function game:mousepressed(x, y, button, istouch)
    terrain.mousepressed(x, y, button, istouch)
    objects.mousepressed(x, y, button, istouch)
    if button == 2 and not _G.BuildController.start then
        _G.BuildController.active = false
    end
end

function game:wheelmoved(x, y)
    core.scale(y)
end

function game:keyreleased(key, scancode)
    if not _G.BuildController.start then
        if key == "q" then
            _G.BuildController:set('orchard')
        elseif key == "w" then
            _G.BuildController:set('stockpile')
        elseif key == "e" then
            _G.BuildController:set('granary')
        elseif key == "t" then
            _G.BuildController:set('quarry')
        elseif key == "y" then
            _G.BuildController:set('iron_mine')
        elseif key == "u" then
            _G.BuildController:set('woodcutter_hut')
        elseif key == "r" then
            _G.foodpile:store('bread')
            _G.foodpile:store('apples')
            _G.foodpile:store('cheese')
            print(inspect(_G.resources))
            print(inspect(_G.food))
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

return game
