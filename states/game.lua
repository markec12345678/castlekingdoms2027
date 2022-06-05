local game = {}
local loveframes = require("libraries.loveframes")
local ActionBar = require("states.ui.ActionBar")
local states = require("states.ui.states")
local core = require("misc")
local thread, thread2, objects, terrain
require("shaders.postshader")
local renderLoadingScreen = require("states.ui.loading_screen")
local renderLoadingBar = require("states.ui.loading_bar")
local initialized = false
local loadState, progress = 1, 15
local SaveManager = require("objects.Controllers.SaveManager")
local savegame

local function updateProgress(prgs, lState)
    progress = prgs or progress
    loadState = lState or loadState
    game:draw()
    love.graphics.present()
end

local function delayedInit()
    local State = require("objects.State")
    _G.state = State:new()
    updateProgress(20)
    objects = love.filesystem.load("objects/objects.lua")(objectAtlas)
    package.loaded["objects.objects"] = objects
    terrain = require("terrain.terrain")
    updateProgress(30)
    _G.BrushController = require("objects.Controllers.BrushController")
    _G.BuildController = love.filesystem.load("objects/Controllers/BuildController.lua")(
        package.loaded["objects.objects"].object, objectAtlas)
    _G.JobController = require("objects.Controllers.JobController")
    updateProgress(35)
    ----Pathfinding setup
    thread = love.thread.newThread("libraries/pathfinding_thread.lua")
    thread:start("1")
    thread2 = love.thread.newThread("libraries/pathfinding_thread.lua")
    thread2:start("2")
    updateProgress(40)
    _G.finder = require("objects.Controllers.PathController")
    local newGame = not savegame
    if newGame then
        updateProgress(50, 2)
        terrain.genMap()
        updateProgress(60, 3)
        terrain.loadFernhaven()
        updateProgress(70)
        _G.BuildController:set("saxon_hall")
    else
        for cx = 0, _G.chunksWide - 1 do
            for cy = 0, _G.chunksHigh - 1 do
                _G.allocateMesh(cx, cy)
            end
        end
        updateProgress(70, 3)
        SaveManager:load(savegame)
    end
    core.update()
    updateProgress(80, 4)
    objects.update(_G.dt)
    updateProgress(90, 5)
    terrain.update()
    updateProgress(95)
    _G.BuildController:update()
    loveframes.update()
    _G.finder:update()
    updateProgress(97)
    _G.state.map:forceRefresh()
    terrain.update()
    updateProgress(100)
    love.timer.sleep(0.4)
    local error = thread:getError()
    assert(not error, error)
    loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
    _G.loaded = true
    _G.playSpeech("place_a_keep")
end

function game:init()
end

function game:update(dt)
    if not initialized then
        initialized = true
        delayedInit()
    else
        prof.push("core")
        core.update()
        prof.pop("core")
        if not _G.paused then
            prof.push("objects")
            objects.update(dt)
            prof.pop("objects")
            terrain.update()
            prof.push("bcontr")
            _G.BuildController:update()
            prof.pop("bcontr")
            _G.BrushController:update()
        end
        prof.push("ui")
        loveframes.update()
        prof.pop("ui")
        prof.push("pathfind")
        _G.finder:update()
        prof.pop("pathfind")
        local error = thread:getError()
        assert(not error, error)
    end
end

function game:enter(_, savegameName)
    savegame = savegameName
    collectgarbage()
    collectgarbage()
    if _G.loaded then
        _G.paused = false
        loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
    end
end

function game:draw()
    if not _G.testMode then
        if _G.loaded then
            if _G.state.scaleX >= 2.1 or _G.paused then
                love.postshader.setBuffer("render")
            end
            love.graphics.push()
            love.graphics.translate((love.graphics.getWidth() / 2), (love.graphics.getHeight() / 2))
            objects.draw()
            if not _G.paused then
                _G.BuildController:draw()
                _G.BrushController:draw()
            end
            love.graphics.pop()
            if _G.paused then
                love.postshader.addTiltshift(12)
            elseif _G.state.scaleX >= 2.1 then
                love.postshader.addTiltshift(4)
            end
            core.draw()
            prof.push("ui_draw")
            loveframes.draw()
            prof.pop("ui_draw")
            if _G.state.scaleX >= 2.1 or _G.paused then
                love.postshader.draw()
            end
        else
            renderLoadingScreen("")
            renderLoadingBar(loadState, progress)
            loveframes.draw()
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
        if _G.BuildController.onBuildCallback then
            _G.BuildController.onBuildCallback()
            _G.BuildController.onBuildCallback = nil
        end
    end
    _G.BrushController:mousepressed(button)
end

function game:keypressed(key, scancode, isRepeat)
    ActionBar:keypressed(key, scancode)
    if key == "escape" and
        (loveframes.GetState() == states.STATE_PAUSE_MENU or loveframes.GetState() == states.STATE_INGAME_CONSTRUCTION) then
        loveframes.TogglePause()
    end
end

function game:mousereleased(x, y, button, istouch)
    -- TODO: Check if event is consumed
    loveframes.mousereleased(x, y, button)
    _G.BrushController:mousereleased(button)
end

function game:wheelmoved(x, y)
    core.scale(y)
end

function game:keyreleased(key, scancode)
    if not _G.BuildController.start then
        if key == "v" then
            _G.foodpile:take()
        elseif key == "r" then
            _G.foodpile:store("bread")
            _G.foodpile:store("apples")
            _G.foodpile:store("cheese")
            print(_G.inspect(_G.food))
        elseif key == "f" then
            local fullscreen, _ = love.window.getFullscreen()
            if fullscreen then
                love.window.setFullscreen(false)
            else
                love.window.setFullscreen(true)
            end
            -- Only temporary until UI for it is created
        elseif key == "b" then
            _G.BrushController:cycleObjects()
        elseif key == "n" and _G.BrushController.active then
            _G.BrushController:cycleShapes()
        elseif (key == "+" or key == "kp+") and _G.BrushController.active then
            _G.BrushController:sizeInc()
        elseif (key == "-" or key == "kp-") and _G.BrushController.active then
            _G.BrushController:sizeDec()
        elseif key == "m" and _G.BrushController.active then
            _G.BrushController:cycleDensity()
        elseif key == "v" and _G.BrushController.active then
            _G.BrushController:cycleType()
        end
    end
end

return game
