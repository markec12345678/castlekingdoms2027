local b = require 'busted'
local assert = require 'luassert'
local spy = require 'luassert.spy'

local describe, it = b.describe, b.it
local WoodcutterHut = require("objects.Structures.WoodcutterHut")
local PineTree = require("objects.Environment.PineTree")

-- =======================================================================--
describe("woodcutter hut", function()
    local hut, worker
    _G.campfire = { peasants = 0, maxPeasants = 0 }
    it("places a woodcutter on the map", function()
        hut = WoodcutterHut:new(10, 10)
        assert:set_parameter("TableFormatLevel", 0)
        assert.are.same(hut, _G.state.object[0][0][10][10][1])
    end)
    it("creates a job listing in job controller", function()
        assert:set_parameter("TableFormatLevel", 0)
        assert.are.same(hut, _G.JobController.list["Woodcutter"][1], "The woodcutter hut we created is not in job controller")
    end)
    it("gets a worker", function()
        _G.spawnPointX, _G.spawnPointY = 5, 5
        _G.JobController.unlimitedWorkers = true
        worker = _G.JobController:makeWorker()
        assert.is_true(hut.worker ~= nil)
        assert.are.same(hut.worker, worker)
    end)
    describe("worker", function()
        it("will go to workplace", function()
            worker:update()
            assert.are.same(worker.state, "Going to workplace")
        end)
        it("will find try to find a tree and fail", function()
            worker.pathState = ""
            worker.state = "Looking to chop tree"
            spy.on(worker, "onNoPathToWorkplace")

            worker:update()

            assert.spy(worker.onNoPathToWorkplace).was.called()
            worker.onNoPathToWorkplace:revert()
        end)
        it("will find try to find a tree and succeed", function()
            local tree = PineTree:new(2, 2, "Medium pine tree")
            worker.pathState = ""
            worker.state = "Looking to chop tree"
            spy.on(worker, "onNoPathToWorkplace")

            worker:update()

            assert.spy(worker.onNoPathToWorkplace).was.called(0)
            assert.are.same(tree, worker.targetTree)
            assert.are.same("Going to tree", worker.state)
        end)
    end)
end)
-- =======================================================================--
