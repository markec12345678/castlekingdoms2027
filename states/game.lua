local game = {}
local Gamestate = require('libraries.gamestate')
local loveframes = require('libraries.loveframes')
require('states.ui.action_bar')
require('states.ui.construction.level_1')
local ui_action_bar = require('states.ui.action_bar_frames')
local states = require('states.ui.states')
local core = require("misc")
local thread, thread2, objects, terrain
require("shaders.postshader")

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
    thread:start("1")
    thread2 = love.thread.newThread("libraries/pathfinding_thread.lua")
    thread2:start("2")
    _G.finder = require('objects.Controllers.PathController')
    if new_game then
        terrain.genMap()
        _G.BuildController:set("castle")
        _G.speech_fx["place_a_keep"]:play()
    else
        for cx = 0, _G.chunks_wide - 1 do
            for cy = 0, _G.chunks_high - 1 do
                _G.allocateMesh(cx, cy)
            end
        end
        _G.state:load("status.bin")
    end
    _G.action_bar = love.graphics.newImage("assets/ui/action_bar.png")
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
    loveframes.update()
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
    loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
end

function game:draw()
    if not _G.test_mode then
        if _G.state.scale_x >= 2.1 then
            love.postshader.setBuffer("render")
        end
        love.graphics.push()
        love.graphics.translate((love.graphics.getWidth() / 2), (love.graphics.getHeight() / 2))
        objects.draw()
        _G.BuildController:draw()
        love.graphics.pop()
        if _G.state.scale_x >= 2.1 then
            love.postshader.addTiltshift()
        end
        core.draw()
        -- love.graphics.draw(action_bar, (1920 - 1215) / 2, 1080 - 198)
        loveframes.draw()
        -- love.graphics.setColor(1, 0, 0)
        -- for _, fr in pairs(ui_action_bar) do
        --     love.graphics.rectangle("line", fr.x, fr.y, fr.width, fr.height)
        -- end
        -- love.graphics.setColor(1, 1, 1)
        if _G.state.scale_x >= 2.1 then
            love.postshader.draw()
        end
    end
end

function game:mousepressed(x, y, button, istouch)
    -- TODO: Check if event is consumed
    loveframes.mousepressed(x, y, button)
    terrain.mousepressed(x, y, button, istouch)
    objects.mousepressed(x, y, button, istouch)
    if button == 2 and not _G.BuildController.start then
        _G.BuildController.active = false
    end
end

function game:mousereleased(x, y, button, istouch)
    -- TODO: Check if event is consumed
    loveframes.mousereleased(x, y, button)
end

function game:wheelmoved(x, y)
    core.scale(y)
end

function game:keyreleased(key, scancode)
    local ob = _G.saw
    if not _G.BuildController.start then
        if key == "q" then
            _G.BuildController:set('orchard')
        elseif key == "d" then
            _G.BuildController:set('house')
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
        elseif key == "s" then
            _G.BuildController:set('bakery')
            -- elseif key == "o" then
            --     _G.saw.offset_y = _G.saw.offset_y + 1
            -- elseif key == "l" then
            --     _G.saw.offset_y = _G.saw.offset_y - 1
            -- elseif key == "k" then
            --     _G.saw.offset_x = _G.saw.offset_x + 1
            -- elseif key == ";" then
            --     _G.saw.offset_x = _G.saw.offset_x - 1
        elseif key == "p" then
            print("x,y", _G.saw.offset_x, _G.saw.offset_y)
        elseif key == "v" then
            _G.foodpile:take()
        elseif key == "r" then
            _G.foodpile:store('bread')
            _G.foodpile:store('apples')
            _G.foodpile:store('cheese')
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
