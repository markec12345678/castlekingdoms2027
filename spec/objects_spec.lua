require 'objects.objects'
require 'busted.runner' ()
local b = require 'busted'

local describe, it = b.describe, b.it
local object = _G.state.object
local addObjectAt = _G.addObjectAt
local obj = {
    data = 2,
    destroy = function()
    end
}
require("spec.eventbus_spec")
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
