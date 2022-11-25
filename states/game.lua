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
local playlist = require("sounds.music_playlist")
local RationController

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
    _G.DestructionController = require("objects.Controllers.DestructionController"):new()
    RationController = require("objects.Controllers.RationController")
    _G.TaxController = require("objects.Controllers.TaxController")
    _G.PopularityController = require("objects.Controllers.PopularityController")
    _G.ScribeController = require("objects.Controllers.ScribeController")
    _G.BuildController = love.filesystem.load("objects/Controllers/BuildController.lua")(
        package.loaded["objects.objects"].object, objectAtlas)
    _G.JobController = require("objects.Controllers.JobController")
    _G.DebugView = require("objects.Controllers.DebugView")
    updateProgress(35)
    ----Pathfinding setup
    thread = love.thread.newThread("libraries/pathfinding_thread.lua")
    thread:start("1")
    thread2 = love.thread.newThread("libraries/pathfinding_thread.lua")
    thread2:start("2")
    updateProgress(40)
    _G.finder = require("objects.Controllers.PathController")
    _G.state.newGame = savegame == "map_Fernhaven"
    for cx = 0, _G.chunksWide - 1 do
        for cy = 0, _G.chunksHigh - 1 do
            _G.allocateMesh(cx, cy)
        end
    end
    if _G.state.newGame then
        SaveManager:load(savegame)
        updateProgress(70)
        _G.BuildController:set("saxon_hall")
    else
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
    ActionBar:updateGoldCount()
    ActionBar:updatePopularityCount()
    _G.loaded = true
    if _G.state.newGame then
        _G.playSpeech("place_a_keep")
    end
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
            local HighlightView = require("objects.Controllers.HighlightView")
            prof.push("objects")
            objects.update(dt)
            prof.pop("objects")
            terrain.update()
            prof.push("bcontr")
            HighlightView:update()
            _G.BuildController:update()
            prof.pop("bcontr")
            _G.DebugView:update()
            _G.BrushController:update()
            if not _G.BuildController.start then
                RationController:update()
                _G.TaxController:update()
                _G.PopularityController:update()
                _G.ScribeController:update()
                _G.DestructionController:update()
            end
        end
        prof.push("ui")
        loveframes.update()
        prof.pop("ui")
        prof.push("pathfind")
        _G.finder:update()
        prof.pop("pathfind")
        local error = thread:getError()
        assert(not error, error)
        if not _G.BuildController.start then
            playlist()
        end
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
            local HighlightView = require("objects.Controllers.HighlightView")
            if _G.state.scaleX >= 2.1 or _G.paused then
                love.postshader.setBuffer("render")
            end
            love.graphics.push()
            love.graphics.translate((love.graphics.getWidth() / 2), (love.graphics.getHeight() / 2))
            objects.draw()
            if not _G.paused then
                HighlightView:draw()
                _G.BuildController:draw()
                _G.DebugView:draw()
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
            if not _G.paused then
                _G.ScribeController:draw()
            end
            if _G.state.scaleX >= 2.1 or _G.paused then
                love.postshader.draw()
            end
            if not _G.paused then
                local WallController = require("objects.Controllers.WallController")
                WallController:drawMouse()
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
    if button == 2 then
        if not _G.BuildController.start then
            _G.BuildController.active = false
            local WallController = require("objects.Controllers.WallController")
            WallController.clicked = false
            if _G.BuildController.onBuildCallback then
                _G.BuildController.onBuildCallback()
                _G.BuildController.onBuildCallback = nil
            end
        end
        ActionBar:unselectAll()
    end
    _G.BrushController:mousepressed(button)
end

function game:keypressed(key, scancode, isRepeat)
    ActionBar:keypressed(key, scancode)
    if key == "+" or key == "kp+" then
        if _G.speedModifier == 0.5 then
            _G.speedModifier = _G.speedModifier + 0.5
        elseif _G.speedModifier < 10 then
            _G.speedModifier = _G.speedModifier + 1
        end
    end
    if key == "=" then
        _G.speedModifier = 1
    end
    if key == "-" or key == "kp-" then
        _G.speedModifier = _G.speedModifier - 0.5
        if _G.speedModifier < 0.5 then
            _G.speedModifier = 0.5
        end
    end
    if key == "escape" then
        if (loveframes.GetState() == states.STATE_PAUSE_MENU or
            loveframes.GetState() == states.STATE_INGAME_CONSTRUCTION) then
            if _G.BuildController.active and not _G.BuildController.start then
                ActionBar:unselectAll()
                _G.BuildController.active = false
                return
            end
            if _G.DestructionController.active then
                -- unselect the demolish button
                ActionBar:unselectAll()
                _G.DestructionController:disable()
                return
            end
        end
        if (loveframes.GetState() == states.STATE_MARKET or
            loveframes.GetState() == states.STATE_STOCKPILE or
            loveframes.GetState() == states.STATE_GRANARY or
            loveframes.GetState() == states.STATE_MARKET_MAIN or
            loveframes.GetState() == states.STATE_MARKET) then
            ActionBar:switchMode()
            return
        end
        loveframes.TogglePause()
    end
    if key == "v" then
        _G.DebugView:toggle()
    end
    if key == "h" then
        _G.state.viewXview = _G.IsoToScreenX(_G.state.keepX, _G.state.keepY)
        _G.state.viewYview = _G.IsoToScreenY(_G.state.keepX, _G.state.keepY)
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
    -- if not _G.BuildController.start then
    if key == "f" then
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
    elseif key == "delete" then
        _G.DestructionController:toggle()
    end
    -- end
end

return game
