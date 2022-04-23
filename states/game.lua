local game = {}
local Gamestate = require('libraries.gamestate')
local loveframes = require('libraries.loveframes')
require('states.ui.init')
local action_bar = require('states.ui.ActionBar')
local states = require('states.ui.states')
local core = require("misc")
local thread, thread2, objects, terrain
require("shaders.postshader")

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
    prof.push("ui")
    loveframes.update()
    prof.pop("ui")
    prof.push("pathfind")
    _G.finder:update()
    prof.pop("pathfind")
    -- prof.push("gc")
    -- manual_gc(0.7e-3, 20000)
    -- prof.pop("gc")
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
        prof.push("ui_draw")
        loveframes.draw()
        prof.pop("ui_draw")
        if _G.state.scale_x >= 2.1 then
            love.postshader.draw()
        end
    end
end

function game:mousepressed(x, y, button, istouch)
    if loveframes.mousepressed(x, y, button) then
        return
    end
    if terrain.mousepressed(x, y, button, istouch) then
        return
    end
    if objects.mousepressed(x, y, button, istouch) then
        return
    end
    if button == 2 and not _G.BuildController.start then
        _G.BuildController.active = false
        if _G.BuildController.on_build_callback then
            _G.BuildController.on_build_callback()
            _G.BuildController.on_build_callback = nil
        end
    end
end

function game:keypressed(key, scancode, is_repeat)
    action_bar:keypressed(key, scancode)
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
        if key == "v" then
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
