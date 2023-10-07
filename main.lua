-- https://stackoverflow.com/a/65066145/5037799
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

if _G.testMode then
    require("spec.love-mocks")
end

require("global")
local LanguageController = require("objects.Controllers.LanguageController")
local Gamestate = require("libraries.gamestate")
local SaveManager = require("objects.Controllers.SaveManager")
local KeybindManager = require("objects.Controllers.KeybindManager")
local test = require("states.test")
local lurker = require("lurker")

--extend native error handler
require("objects.Controllers.ErrorHandler")

function love.load()
    local success = love.filesystem.createDirectory("saves")
    if not success then
        error("couldn't create save directory")
    end
    SaveManager:getSaveFiles()
    Gamestate.registerEvents()
    LanguageController:initialize()
    LanguageController:loadLanguage()
    _G.fx = require("sounds.fx")
    if _G.testMode then
        _G.objectAtlas = love.graphics.newImage("assets/tiles/stronghold_assets_packed_v8-hd.dds")
        Gamestate.switch(test)
        return
    else
        local splashscreen = require("states.splash_screen")
        Gamestate.switch(splashscreen)
    end
    local loader = require("libraries.lily")
    loader.newImage("assets/tiles/stronghold_assets_packed_v8-hd.dds"):onComplete(function(_, image)
        _G.objectAtlas = image
    end)
    local cursorImg = love.image.newImageData("assets/ui/cursor.png")
    local cursor = love.mouse.newCursor(cursorImg, 2, 2)
    love.mouse.setCursor(cursor)
    require("sounds.fx_volume")
    _G.speechFx = require("sounds.speech")
    KeybindManager:loadKeybinds()
end

function love.quit()
    return true
end

local cnt = 0
local previousFrame = 0
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
    local consecutiveLargeDts = 0
    -- Main loop time.
    local nextTime = 0

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
        nextTime = nextTime + 1 / _G.MAX_FPS
        if love.timer then
            love.timer.step()
            _G.dt = love.timer.getDelta()
            if _G.dt > 0.5 and consecutiveLargeDts < 3 then
                -- We prefer the game to slow down on large short spikes
                -- so the units don't teleport around
                _G.dt = 0.016
                consecutiveLargeDts = consecutiveLargeDts + 1
            elseif _G.dt <= 0.5 then
                consecutiveLargeDts = 0
            end
            _G.dt = _G.dt * _G.speedModifier
        end
        if _G.paused then
            _G.dt = 0
        end
        cnt = cnt + 1
        if cnt == 10 then
            _G.previousFrameTime = tonumber(math.floor(previousFrame / 10))
            cnt = 0
            previousFrame = 0
        end
        -- Call update and draw
        local startTimeFPS = love.timer.getTime()
        prof.push("frame")
        prof.push("update")
        if love.update then
            love.update(_G.dt)
        end -- will pass 0 if love.timer is disabled
        prof.pop("update")
        prof.push("draw")
        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then
                love.draw()
            end
        end
        previousFrame = previousFrame + 1 / (love.timer.getTime() - startTimeFPS)

        local curTime = love.timer.getTime()
        if nextTime <= curTime then
            nextTime = curTime
        else
            _G.manualGc(nextTime - curTime, nil, true)
        end
        love.graphics.present()
        prof.pop("draw")
        if _G.debugMode then
            prof.push("lurker")
            lurker.update()
            prof.pop("lurker")
        end
        prof.pop("frame")
    end
end
