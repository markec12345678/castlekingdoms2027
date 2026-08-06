local b = require 'busted'
local assert = require 'luassert'
local bitser = require("libraries.bitser")

local describe, it, setup, teardown = b.describe, b.it, b.setup, b.teardown
local State = require("objects.State")
local Object = require("objects.Object")

local structureClasses = {}
_G.recursiveLoadModules("objects/Structures", "", structureClasses)

-- =======================================================================--
for path, structure in pairs(structureClasses) do
    assert:set_parameter("TableFormatLevel", 0)
    describe(structure.name, function()
        setup(function()
            _G.state = State:new()
            _G.channel.mapUpdate:push("final")
            _G.channel2.mapUpdate:push("final")
        end)
        teardown(function()
            _G.state:destroy()
        end)
        local building
        _G.campfire = { peasants = 0, maxPeasants = 0 }
        it("is being placed on the map", function()
            building = structure:new(10, 10)
            assert.are.same(building, _G.state.object[0][0][10][10][1])
        end)
        it("can be destroyed if destructible", function()
            _G.DestructionController:destroyAtLocation(building.gx, building.gy)
            local obj = _G.objectFromClassAtGlobal(building.gx, building.gy, building.class)
            if structure.DESTRUCTIBLE then
                assert.is_true(obj == false)
                assert.is_true(building.toBeDeleted == true)
                if structure.name ~= "Campfire" then
                    for xx = 0, (building.class.EFFECTIVE_WIDTH or building.class.WIDTH) - 1 do
                        for yy = 0, (building.class.EFFECTIVE_LENGTH or building.class.WIDTH) - 1 do
                            local buildingX = building.gx + xx
                            local buildingY = building.gy + yy
                            local objects = _G.allObjectsAtGlobal(buildingX, buildingY)
                            if #objects > 0 then
                                print("_________________-")
                                for k, v in ipairs(objects) do print(v) end
                            end
                            assert.are.equal(#objects, 0)
                        end
                    end
                end
                -- place the building again so we can continue testing
                building = structure:new(10, 10)
                assert.are.same(building, _G.state.object[0][0][10][10][1])
            else
                assert.is_true(obj ~= false)
                assert.are.equal(obj, building)
            end
        end)
        local serial
        describe("serialization", function()
            _G.state.serializedObjectIds = {}
            _G.state.deserializedObjectCount = 0
            _G.state.deserDebug = {}
            _G.BuildController.start = true
            it("should serialize", function()
                local data = _G.state:serialize()
                serial = bitser.dumps(data)
                assert.is_not_nil(serial)
            end)
            it("should deserialize", function()
                local data = bitser.loads(serial)
                _G.state:deserialize(data)
            end)
        end)
    end)
end
-- =======================================================================--
