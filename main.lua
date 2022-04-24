if _G.test_mode then
    require('libraries.love.love_graphics')
end

require('global')
local Gamestate = require('libraries.gamestate')

local main_menu = require('states.main_menu')
local test = require('states.test')

function love.load()
    Gamestate.registerEvents()
    if _G.test_mode then
        Gamestate.switch(test)
        return
    else
        Gamestate.switch(main_menu)
    end
    local loader = require('libraries.lily')
    loader.newImage("assets/tiles/stronghold_assets_packed_v5.png"):onComplete(function(_, image)
        _G.object_image = image
    end)
    local cursor_img = love.image.newImageData("assets/ui/cursor.png")
    local cursor = love.mouse.newCursor(cursor_img, 2, 2)
    love.mouse.setCursor(cursor)
    _G.fx = require("sounds.fx")
    require("sounds.fx_volume")
    _G.speech_fx = require("sounds.speech")
end

function love.quit()
    return true
end

local cnt = 0
local previous_frame = 0
function love.run()
    if love.math then
        love.math.setRandomSeed(os.time())
    end
    if love.load then
        love.load()
    end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then
        love.timer.step()
    end
    _G.dt = 0
    local consecutive_large_dts = 0
    -- Main loop time.
    local next_time = 0

    while true do
        -- Process events.
        love.event.pump()
        for name, a, b, c, d, e, f in love.event.poll() do
            if name == "quit" then
                if not love.quit or not love.quit() then
                    return a
                end
            end
            love.handlers[name](a, b, c, d, e, f)
        end

        -- Update dt, as we'll be passing it to update
        next_time = next_time + 1 / _G.MAX_FPS
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
            if dt > 0.5 and consecutive_large_dts < 3 then
                -- We prefer the game to slow down on large short spikes
                -- so the units don't teleport around
                dt = 0.016
                consecutive_large_dts = consecutive_large_dts + 1
            elseif dt <= 0.5 then
                consecutive_large_dts = 0
            end
        end
        if _G.paused then
            _G.dt = 0
        end
        cnt = cnt + 1
        if cnt == 10 then
            _G.previous_frame_time = tonumber(math.floor(previous_frame / 10))
            cnt = 0
            previous_frame = 0
        end
        -- Call update and draw
        local start_time_FPS = love.timer.getTime()
        prof.push("frame")
        prof.push("update")
        if love.update then
            love.update(dt)
        end -- will pass 0 if love.timer is disabled
        prof.pop("update")
        prof.push("draw")
        if love.graphics and love.graphics.isActive() then
            if _G.loaded then
                love.graphics.clear(love.graphics.getBackgroundColor())
            end
            love.graphics.origin()
            if love.draw then
                love.draw()
            end
        end
        previous_frame = previous_frame + 1 / (love.timer.getTime() - start_time_FPS)

        local cur_time = love.timer.getTime()
        if next_time <= cur_time then
            next_time = cur_time
        else
            _G.manual_gc(next_time - cur_time, nil, true)
        end
        love.graphics.present()
        prof.pop("draw")
        prof.pop("frame")
    end
end
