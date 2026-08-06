local b = require 'busted'
local assert = require 'luassert'
local Events = require('objects.Enums.Events')

local describe, it = b.describe, b.it
local eventbus = require("libraries.eventbus")

-- =======================================================================--
describe("eventbus", function()
    local timesCalled
    local parameter
    local func = function(resource)
        timesCalled = timesCalled + 1
        parameter = resource
    end
    it("creates a handler for the eventbus only once", function()
        eventbus.on(Events.OnResourceStore, func)
    end)
    it("gets called on the emitted event with the right parameter", function()
        timesCalled = 0
        eventbus.emit(Events.OnResourceStore, "wood")
        assert.is_true(timesCalled == 1)
        assert.is_true(parameter == "wood")
    end)
    it("can get called multiple times", function()
        timesCalled = 0
        eventbus.emit(Events.OnResourceStore, "wood")
        assert.is_true(parameter == "wood")
        eventbus.emit(Events.OnResourceStore, "wood")
        assert.is_true(parameter == "wood")
        eventbus.emit(Events.OnResourceStore, "stone")
        assert.is_true(timesCalled == 3)
        assert.is_true(parameter == "stone")
    end)
    it("will not unsubscribe from the handler with the wrong event", function()
        timesCalled = 0
        assert.is_not_true(eventbus.off(Events.OnResourceTake, func))
        eventbus.emit(Events.OnResourceStore, "wood")
        assert.is_true(timesCalled == 1)
    end)
    it("can unsubscribe from the handler with the right key", function()
        timesCalled = 0
        assert.is_true(eventbus.off(Events.OnResourceStore, func), "eventbus did not unsubscribe properly")
        eventbus.emit(Events.OnResourceStore, "wood")
        assert.is_true(timesCalled == 0, "expected handler to be called 0 times, got " .. timesCalled)
    end)
end)
-- =======================================================================--
