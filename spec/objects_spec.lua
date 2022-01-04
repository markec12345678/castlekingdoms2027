local ob = require 'objects.objects'
require 'busted.runner'()

local describe, it = _G.describe, _G.it
_G.BuildController = love.filesystem.load("objects/Controllers/BuildController.lua")(
    package.loaded['objects.objects'].object, nil)
local object = ob.object
local object_batch = ob.batch
local addObjectAt = ob.addObjectAt
local update_objects = ob.update_objects
local mousepressed = ob.mousepressed
local obj = {
    data = 2,
    destroy = function()
    end
}
-- =======================================================================--
describe("addObjectAt", function()
    it("creates a table at the index, if it doesn't exist already", function()
        object[1][1][1][1] = nil
        addObjectAt(1, 1, 1, 1, obj)
        assert.is_true(type(object[1][1][1][1]) == "table")
        assert.is_true(object[1][1][1][1][1] == obj)
    end)
    it("returns the added object", function()
        object[1][1][1][1] = nil
        assert.is_true(obj == addObjectAt(1, 1, 1, 1, obj))
    end)
end)
-- =======================================================================--
describe("removeObjectAt", function()
    describe("removes the object at the index if object_to_remove is not specified", function()
        it("leaves an empty table at the index if there are no more objects", function()
            object[1][1][1][1] = nil
            addObjectAt(1, 1, 1, 1, obj)
            assert.is_true(object[1][1][1][1][1] == obj)
            _G.removeObjectAt(1, 1, 1, 1, obj)
            assert.is_true(object[1][1][1][1][1] == nil)
        end)
    end)
    describe(
        "removes every object at the index if object_to_remove is specified and calls destroy() method for each of them",
        function()
            it("leaves an empty table at the index", function()
                object[1][1][1][1] = nil
                addObjectAt(1, 1, 1, 1, obj)
                addObjectAt(1, 1, 1, 1, {
                    data2 = 3,
                    destroy = function()
                    end
                })
                _G.removeObjectAt(1, 1, 1, 1)
                assert.is_true(object[1][1][1][1][1] == nil)
            end)
        end)
end)
-- =======================================================================--
describe("isObjectAt", function()
    it("returns the compared object if it is in this object index", function()
        object[1][1][1][1] = nil
        local obj1 = {
            data = 2
        }
        local obj2 = {
            data = 3
        }
        addObjectAt(1, 1, 1, 1, obj1)
        addObjectAt(1, 1, 1, 1, obj2)
        assert.is_true(obj1 == _G.isObjectAt(1, 1, 1, 1, obj1))
    end)
    it("returns false if the object is not in this object index", function()
        object[1][1][1][1] = nil
        local obj1 = {
            data = 2
        }
        local obj2 = {
            data = 3
        }
        local obj3 = {
            data = 4
        }
        addObjectAt(1, 1, 1, 1, obj1)
        addObjectAt(1, 1, 1, 1, obj2)
        assert.is_true(_G.isObjectAt(1, 1, 1, 1, obj3) == false)
    end)
end)
-- =======================================================================--
describe("objectFromTypeAt", function()
    it("returns an object of the same type if it's in the object index", function()
        object[1][1][1][1] = nil
        local obj1 = {
            data = 2,
            class = {
                name = "worker"
            }
        }
        local obj2 = {
            data = 2,
            class = {
                name = "soldier"
            }
        }
        addObjectAt(1, 1, 1, 1, obj2)
        addObjectAt(1, 1, 1, 1, obj1)
        assert.is_true(obj1 == _G.objectFromTypeAt(1, 1, 1, 1, "worker"))
    end)
    it("returns false if an object from the type is not in this object index", function()
        object[1][1][1][1] = nil
        local obj1 = {
            data = 2,
            class = {
                name = "worker"
            }
        }
        local obj2 = {
            data = 2,
            class = {
                name = "soldier"
            }
        }
        addObjectAt(1, 1, 1, 1, obj2)
        addObjectAt(1, 1, 1, 1, obj1)
        assert.is_true(_G.objectFromTypeAt(1, 1, 1, 1, "animal") == false)
    end)
end)
-- =======================================================================--
describe("objectAt", function()
    it("returns true if there are objects in this object index", function()
        object[1][1][1][1] = nil
        local obj1 = {
            data = 2,
            class = {
                name = "worker"
            }
        }
        local obj2 = {
            data = 2,
            class = {
                name = "soldier"
            }
        }
        addObjectAt(1, 1, 1, 1, obj2)
        addObjectAt(1, 1, 1, 1, obj1)
        assert.is_true(_G.objectAt(1, 1, 1, 1) == true)
    end)
    it("returns false if there are NO objects in this object index", function()
        object[1][1][1][1] = nil
        assert.is_true(_G.objectAt(1, 1, 1, 1) == false)
        object[1][1][1][1] = {}
        assert.is_true(_G.objectAt(1, 1, 1, 1) == false)
    end)
end)
-- =======================================================================--
describe("genObjects", function()
    it("makes a new sprite batch at chunk_x, chunk_y if it doesn't exist already", function()
        object_batch[1][1] = nil
        genObjects(1, 1)
        assert.is_true(object_batch[1][1] ~= nil)
    end)
end)
-- =======================================================================--
describe("update_objects", function()
    it("removes the objects from this chunk that don't belong there", function()
        local obj1 = {
            data = 2,
            cx = 1,
            cy = 2,
            x = 13,
            y = 123,
            class = {
                name = "worker"
            }
        }
        local obj2 = {
            data = 2,
            cx = 1,
            cy = 1,
            x = 68,
            y = 45,
            class = {
                name = "soldier"
            }
        }
        addObjectAt(1, 1, 1, 1, obj1)
        addObjectAt(1, 1, 1, 1, obj2)
        assert.is_true(#object[1][1][1][1] == 2)
        update_objects(1, 1)
        assert.is_true(#object[1][1][1][1] == 1)
        assert.is_true(_G.objectFromTypeAt(1, 1, 1, 1, "soldier").class.name == "soldier")
        assert.is_true(_G.objectFromTypeAt(1, 1, 1, 1, "worker") == false)
    end)
end)
-- =======================================================================--
describe("mousepressed", function()
    it("calls BuildController's build method if left mouse button(1) is pressed", function()
        spy.on(_G.BuildController, 'build')
        mousepressed(12, 32, 1)
        assert.spy(_G.BuildController.build).was.called()
        genObjects(1, 1)
        genObjects(2, 2)
        genObjects(1, 2)
        genObjects(2, 1)
        mousepressed(-500, -500, 2)
        mousepressed(-500, -500, 3)
        mousepressed(-500, -500, 4)
    end)
end)
-- =======================================================================--
