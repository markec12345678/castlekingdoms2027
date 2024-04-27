local test = {}
local loveframes = require("libraries.loveframes")
local ActionBar = require("states.ui.ActionBar")
local states = require("states.ui.states")
local core = require("misc")
local objects

_G.dt = 0.016

function test:enter()
    _G.updateKeepUpgradeButton = function()
    end
    _G.chunksWide, _G.chunksHigh = 2, 2
    local State = require("objects.State")
    _G.state = State:new()
    objects = love.filesystem.load("objects/objects.lua")(objectAtlas)
    package.loaded["objects.objects"] = objects
    require("terrain.terrain")
    _G.BrushController = require("objects.Controllers.BrushController")
    _G.DestructionController = require("objects.Controllers.DestructionController"):new()
    RationController = require("objects.Controllers.RationController")
    _G.AleController = require("objects.Controllers.AleController")
    _G.ReligionController = require("objects.Controllers.ReligionController")
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
    _G.finder = require("objects.Controllers.PathController")
    _G.state.newGame = true
    _G.state.viewYview = -50
    _G.state:allocateMeshes()
    for i = 0, _G.chunksWide - 1 do
        for o = 0, _G.chunksHigh - 1 do
            _G.state.Terrain:genTerrain(i, o)
        end
    end
    _G.channel.mapUpdate:push("final")
    _G.channel2.mapUpdate:push("final")
    core.update()
    objects.update(_G.dt)
    _G.BuildController:update()
    loveframes.update()
    _G.finder:update()
    love.timer.sleep(0.4)
    local error = _G.state.thread:getError()
    assert(not error, error)
    error = _G.state.thread2:getError()
    assert(not error, error)
    loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
    ActionBar:updateGoldCount()
    ActionBar:updatePopularityCount()
    _G.loaded = true
    _G.playSfx = function()
    end
    _G.playInterfaceSfx = function()
    end
    _G.playSpeech = function()
    end
    require('spec.objects_spec')
    love.event.quit("quit", 0)
end

return test
