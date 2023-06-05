local b = require 'busted'
local assert = require 'luassert'
local spy = require 'luassert.spy'
local bitser = require("libraries.bitser")

local describe, it, setup, teardown = b.describe, b.it, b.setup, b.teardown
local State = require("objects.State")
local WoodcutterHut = require("objects.Structures.WoodcutterHut")
local Structure = require("objects.Structure")
local PineTree = require("objects.Environment.PineTree")

-- =======================================================================--
describe("woodcutter hut", function()
    local hut, worker
    _G.campfire = { peasants = 0, maxPeasants = 0 }
    setup(function()
        _G.state = State:new()
        _G.channel.mapUpdate:push("final")
        _G.channel2.mapUpdate:push("final")
    end)
    teardown(function()
        _G.state:destroy()
    end)
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
    local serial
    describe("serialization", function()
        _G.state.rawObjectIds = {}
        _G.state.deserializedObjectCount = 0
        _G.state.deserDebug = {}
        it("should serialize", function()
            local data = hut:serialize()
            serial = bitser.dumps(data)
            for xx = 0, hut.class.WIDTH - 1 do
                for yy = 0, hut.class.LENGTH - 1 do
                    local buildingX = hut.gx + xx
                    local buildingY = hut.gy + yy
                    local objects = _G.allObjectsFromSubclassAtGlobal(buildingX, buildingY, Structure)
                    for i, v in ipairs(objects) do
                        local ref = _G.state:serializeObject(v)
                        _G.state.rawObjectIds[ref._ref] = v:serialize()
                    end
                end
            end
        end)
        it("worker should serialize", function()
            local ref = _G.state:serializeObject(worker)
            _G.state.rawObjectIds[ref._ref] = worker:serialize()
        end)
        it("float should serialize", function()
            local ref = _G.state:serializeObject(hut.float)
            _G.state.rawObjectIds[ref._ref] = hut.float:serialize()
        end)
        it("should deserialize", function()
            local obj = bitser.loads(serial)
            assert.is_true(obj ~= nil)
            assert.are.same(WoodcutterHut.name, obj.className)
            local object = _G.getClassByName(obj.className)
            assert.is_true(object ~= nil)
            hut = object:deserialize(obj)
        end)
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
