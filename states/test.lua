local test = {}
local loveframes = require("libraries.loveframes")
local ActionBar = require("states.ui.ActionBar")
local states = require("states.ui.states")
local core = require("misc")
local thread, thread2, objects, terrain
local SaveManager = require("objects.Controllers.SaveManager")
local savegame

_G.dt = 0.016

function test:enter()
    local State = require("objects.State")
    _G.state = State:new()
    objects = love.filesystem.load("objects/objects.lua")(objectAtlas)
    package.loaded["objects.objects"] = objects
    terrain = require("terrain.terrain")
    _G.BrushController = require("objects.Controllers.BrushController")
    _G.DestructionController = require("objects.Controllers.DestructionController"):new()
    RationController = require("objects.Controllers.RationController")
    _G.TaxController = require("objects.Controllers.TaxController")
    _G.TimeController = require("objects.Controllers.TimeController")
    _G.PopularityController = require("objects.Controllers.PopularityController")
    _G.ScribeController = require("objects.Controllers.ScribeController")
    _G.BuildController = love.filesystem.load("objects/Controllers/BuildController.lua")(
        package.loaded["objects.objects"].object, objectAtlas)
    _G.JobController = require("objects.Controllers.JobController")
    _G.BuildingManager = require("objects.Controllers.BuildingManager")
    _G.DebugView = require("objects.Controllers.DebugView")
    ----Pathfinding setup
    thread = love.thread.newThread("libraries/pathfinding_thread.lua")
    thread:start("1")
    thread2 = love.thread.newThread("libraries/pathfinding_thread.lua")
    thread2:start("2")
    _G.finder = require("objects.Controllers.PathController")
    _G.state.newGame = savegame == "map_Fernhaven"
    for cx = 0, _G.chunksWide - 1 do
        for cy = 0, _G.chunksHigh - 1 do
            _G.allocateMesh(cx, cy)
        end
    end
    if _G.state.newGame then
        SaveManager:load(savegame)

        _G.BuildController:set("SaxonHall")
    else

        SaveManager:load(savegame)
    end
    core.update()
    objects.update(_G.dt)
    _G.BuildController:update()
    loveframes.update()
    _G.finder:update()
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

    require('spec.objects_spec')
    love.event.quit(0)
end

return test
