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
    local new_game = not (love.filesystem.getInfo and love.filesystem.getInfo("status.bin"))
    local State = require('objects.State')
    _G.state = State:new()
    objects = love.filesystem.load('objects/objects.lua')(object_image)
    package.loaded['objects.objects'] = objects
    terrain = require('terrain.terrain')
    _G.chunkUpdateList = require('objects.chunk_system')
    _G.BuildController = love.filesystem.load("objects/Controllers/BuildController.lua")(
        package.loaded['objects.objects'].object, object_image)
    _G.JobController = require('objects.Controllers.JobController')
    ----Pathfinding setup
    thread = love.thread.newThread("libraries/pathfinding_thread.lua")
    thread:start()
    _G.finder = require('objects.Controllers.PathController')
    if new_game then
        terrain.genMap()
        _G.BuildController:set("castle")
    else
        for cx = 0, _G.chunks_wide - 1 do
            for cy = 0, _G.chunks_high - 1 do
                _G.allocateMesh(cx, cy)
            end
        end
        _G.state:load("status.bin")
    end
end

function game:update(dt)
    prof.push("core")
    core.update()
    prof.pop("core")
    prof.push("objects")
    objects.update(dt)
    prof.pop("objects")
    terrain.update()
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
    local ob = _G.saw
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
        elseif key == "i" then
            _G.BuildController:set('wheat_farm')
        elseif key == "a" then
            _G.BuildController:set('windmill')
            -- _G.saw.unit_offset_x = _G.saw.unit_offset_x + 1
            -- _G.saw:calculate_position()
        elseif key == "s" then
            _G.BuildController:set('bakery')
            -- _G.saw.unit_offset_x = _G.saw.unit_offset_x - 1
            -- _G.saw:calculate_position()
        elseif key == "d" then
            -- _G.saw.unit_offset_y = _G.saw.unit_offset_y + 1
            -- _G.saw:calculate_position()
        elseif key == "f" then
            -- _G.saw.unit_offset_y = _G.saw.unit_offset_y - 1
            -- _G.saw:calculate_position()
        elseif key == "o" then
            -- _G.saw.fy = _G.saw.fy + 100
            -- print("(((((((((((((((((((((")
            -- print("\t", ob.x, ob.y)
            -- print(ob.gx, ob.gy, ob.cx, ob.cy, ob.i, ob.o, ob.vert_id)
            -- _G.saw:update_position()
            -- print("\t", ob.x, ob.y)
            -- print(ob.gx, ob.gy, ob.cx, ob.cy, ob.i, ob.o, ob.vert_id)
            -- print(")))))))))))))))))))))")
            -- _G.saw.offset_y = _G.saw.offset_y + 1
        elseif key == "l" then
            -- _G.saw.fy = _G.saw.fy - 100
            -- print("(((((((((((((((((((((")
            -- print("\t", ob.x, ob.y)
            -- print(ob.gx, ob.gy, ob.cx, ob.cy, ob.i, ob.o, ob.vert_id)
            -- _G.saw:update_position()
            -- print("\t", ob.x, ob.y)
            -- print(ob.gx, ob.gy, ob.cx, ob.cy, ob.i, ob.o, ob.vert_id)
            -- print(")))))))))))))))))))))")
            -- _G.saw.offset_y = _G.saw.offset_y - 1
        elseif key == "k" then
            -- _G.saw.fx = _G.saw.fx + 1000
            -- _G.saw:update_position()
            -- print("\t", ob.x, ob.y)
            -- print(ob.gx, ob.gy, ob.cx, ob.cy)
            -- _G.saw.offset_x = _G.saw.offset_x + 1
        elseif key == ";" then
            -- _G.saw.fx = _G.saw.fx - 1000
            -- _G.saw:update_position()
            -- print("\t", ob.x, ob.y)
            -- print(ob.gx, ob.gy, ob.cx, ob.cy)
            -- _G.saw.offset_x = _G.saw.offset_x - 1
        elseif key == "p" then
            print("x,y", _G.saw.offset_x, _G.saw.offset_y)
        elseif key == "r" then
            _G.foodpile:store('bread')
            _G.foodpile:store('apples')
            _G.foodpile:store('cheese')
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
