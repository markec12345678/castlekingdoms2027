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
    _G.updateKeepUpgradeButton = function()
    end
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
    _G.MissionController = require("objects.Controllers.MissionController")
    _G.PopularityController = require("objects.Controllers.PopularityController")
    _G.ScribeController = require("objects.Controllers.ScribeController")
    _G.BuildController = love.filesystem.load("objects/Controllers/BuildController.lua")(
        package.loaded["objects.objects"].object, objectAtlas)
    _G.JobController = require("objects.Controllers.JobController")
    _G.BuildingManager = require("objects.Controllers.BuildingManager")
    _G.DebugView = require("objects.Controllers.DebugView")
    _G.Commander = require("objects.Controllers.Commander")
    ----Pathfinding setup
    thread = love.thread.newThread("libraries/pathfinding_thread.lua")
    thread:start("1", 512)
    thread2 = love.thread.newThread("libraries/pathfinding_thread.lua")
    thread2:start("2", 512)
    _G.finder = require("objects.Controllers.PathController")
    _G.state.newGame = savegame == "map_Fernhaven"
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
    _G.playSfx = function()
    end
    _G.playInterfaceSfx = function()
    end
    _G.playSpeech = function()
    end
    _G.channel.mapUpdate:push("final")
    _G.channel2.mapUpdate:push("final")
    require('spec.objects_spec')
    love.event.quit("quit", 0)
end

return test
