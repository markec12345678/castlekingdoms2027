local b = require 'busted'
local assert = require 'luassert'
local spy = require 'luassert.spy'
local bitser = require("libraries.bitser")

local describe, it, setup, teardown = b.describe, b.it, b.setup, b.teardown
local State = require("objects.State")
local Orchard = require("objects.Structures.Orchard")
local Structure = require("objects.Structure")

-- =======================================================================--
describe("orchard", function()
    setup(function()
        _G.state = State:new()
        _G.channel.mapUpdate:push("final")
        _G.channel2.mapUpdate:push("final")
    end)
    teardown(function()
        _G.state:destroy()
    end)
    local farm, worker
    _G.campfire = { peasants = 0, maxPeasants = 0 }
    it("is being placed on the map", function()
        farm = Orchard:new(10, 10)
        assert:set_parameter("TableFormatLevel", 0)
        assert.are.same(farm, _G.state.object[0][0][10][10][1])
    end)
    it("creates a job listing in job controller", function()
        assert:set_parameter("TableFormatLevel", 0)
        assert.are.same(farm, _G.JobController.list["OrchardFarmer"][1], "The orchard we created is not in job controller")
    end)
    it("gets a worker", function()
        _G.spawnPointX, _G.spawnPointY = 5, 5
        _G.JobController.unlimitedWorkers = true
        worker = _G.JobController:makeWorker()
        assert.is_true(farm.appleWorker ~= nil)
        assert.are.same(farm.appleWorker, worker)
    end)
    local serial
    describe("serialization", function()
        _G.state.rawObjectIds = {}
        _G.state.deserializedObjectCount = 0
        _G.state.deserDebug = {}
        it("should serialize", function()
            local data = farm:serialize()
            serial = bitser.dumps(data)
            for xx = 0, farm.class.WIDTH - 1 do
                for yy = 0, farm.class.LENGTH - 1 do
                    local buildingX = farm.gx + xx
                    local buildingY = farm.gy + yy
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
            local ref = _G.state:serializeObject(farm.float)
            _G.state.rawObjectIds[ref._ref] = farm.float:serialize()
        end)
        it("should deserialize", function()
            local obj = bitser.loads(serial)
            assert.is_true(obj ~= nil)
            assert.are.same(Orchard.name, obj.className)
            local object = _G.getClassByName(obj.className)
            assert.is_true(object ~= nil)
            object:deserialize(obj)
        end)
    end)
    describe("worker", function()
        it("will go to workplace", function()
            worker:update()
            assert.are.same("Going to workplace", worker.state)
        end)
        it("will arrive at workplace", function()
            repeat
                -- simulate game loop
                _G.finder:update()
                worker:animate()
            until worker.state ~= "Going to workplace"
            assert.are.same("Going to apple tree", worker.state)
        end)
        it("will go through all apple trees", function()
            local farmStates = {}
            repeat
                farmStates[farm.state] = true
                _G.finder:update()
                worker:animate()
            until farm.state == 0
            farmStates[farm.state] = true
            assert.is_true(farmStates[0], "went to 1st apple tree")
            assert.is_true(farmStates[1], "went to 2nd apple tree")
            assert.is_true(farmStates[2], "went to 3rd apple tree")
            assert.is_true(farmStates[3], "went to 4th apple tree")
            assert.is_true(farmStates[4], "went to 5th apple tree")
            assert.is_true(farmStates[5], "went to 6th apple tree")
            assert.is_true(farmStates[6], "went to 7th apple tree")
            assert.is_true(farmStates[7], "went to 8th apple tree")
            assert.is_true(farmStates[8], "went to 9th apple tree")
            assert.are.same(0, farm.state)
            assert.are.same("Go to granary", worker.state)
        end)
        local Granary = require("objects.Structures.Granary")
        Granary:new(30, 30)
        it("will find granary, go to it and store apples", function()
            repeat
                _G.finder:update()
                worker:animate()
            until worker.state ~= "Go to granary" and worker.state ~= "Going to granary"
            assert.are.same("Go to workplace", worker.state)
            assert.are.same(_G.state.food["apples"], 4, "expected to store 4 apples, but got " .. _G.state.food["apples"] .. " instead")
        end)
    end)
    it("will arrive at workplace after storing in the granary", function()
        repeat
            -- simulate game loop
            _G.finder:update()
            worker:animate()
        until worker.state ~= "Going to workplace"
        assert.are.same("Going to apple tree", worker.state)
        assert.are.same(1, farm.state)
    end)
end)
-- =======================================================================--
