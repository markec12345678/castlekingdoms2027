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
local loader = require("libraries.lily")
local config = require("config_file")

--extend native error handler
require("objects.Controllers.ErrorHandler")

function love.load()
    local function getAvailableResolutions()
        local result = {}
        local modes = love.window.getFullscreenModes(config.video.display)
        for i, mode in ipairs(modes) do
            result[#result + 1] = mode
        end
        return result
    end

    local function isResolutonSupported(resolutions)
        local resolutionW, resolutionH = config.video.resolutionWidth, config.video.resolutionHeight
        for i, r in ipairs(resolutions) do
            if (r.width == resolutionW and r.height == resolutionH) then
                return true
            end
        end

        return false
    end

    local supportedResolutions = getAvailableResolutions()
    if next(supportedResolutions) == nil then
        local width, height, flags = love.window.getMode()
        local currentDisplay = flags.display
        config.video.display = currentDisplay
        config:save()
        supportedResolutions = getAvailableResolutions()
    end

    if not isResolutonSupported(supportedResolutions) then
        local maxResolution = supportedResolutions[1]
        config.video.resolutionWidth, config.video.resolutionHeight = maxResolution.width, maxResolution.height
        config:save()
        love.event.quit("restart")
    end

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
        _G.objectAtlas = love.graphics.newImage("assets/tiles/stronghold_assets_packed_v12-hd.png")
        Gamestate.switch(test)
        return
    else
        local splashscreen = require("states.splash_screen")
        Gamestate.switch(splashscreen)
    end
    loader.newImage("assets/tiles/stronghold_assets_packed_v12-hd.png"):onComplete(function(_, image)
        print("loading...")
        _G.objectAtlas = image
        print("loaded object atlas")
        loader.quit()
    end)
    local cursorImg = love.image.newImageData("assets/ui/cursor.png")
    local cursor = love.mouse.newCursor(cursorImg, 2, 2)
    love.mouse.setCursor(cursor)
    require("sounds.fx_volume")
    _G.speechFx = require("sounds.speech")
    KeybindManager:loadKeybinds()
end

function love.quit()
    loader.quit()
    if _G.state then _G.state:destroy() end
    love.event.quit("quit", 0)
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

    return function()
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
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
        if love.graphics then
            love.graphics.present()
        end
        prof.pop("draw")
        if _G.debugMode then
            prof.push("lurker")
            lurker.update()
            prof.pop("lurker")
        end
        prof.pop("frame")
    end
end
