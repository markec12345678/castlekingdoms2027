local b = require 'busted'
local assert = require 'luassert'

local describe, it, setup, teardown = b.describe, b.it, b.setup, b.teardown
local mockActionBar = {
    updatePopulationCount = function() end,
    switchMode = function() end,
    element = {
        scalex = 1
    }
}
package.loaded["states.ui.ActionBar"] = mockActionBar
local State = require("objects.State")
local House = require("objects.Structures.House")
local Flat = require("objects.Structures.Flat")
local Residence = require("objects.Structures.Residence")
local Events = require('objects.Enums.Events')
local eventbus = require("libraries.eventbus")
require("states.ui.houses.house_ui")
-- =======================================================================--
describe("hovel", function()
    local startpop
    setup(function()
        _G.state = State:new()
        _G.channel.mapUpdate:push("final")
        _G.channel2.mapUpdate:push("final")
        require("objects.Structures.Campfire") -- needs the campfire required to listen for max population changes
        startpop = _G.state.maxPopulation
        _G.state.tier = 2
        _G.BuildController.freeBuildings = true
        package.loaded["states.ui.ActionBar"] = mockActionBar
    end)
    teardown(function()
        _G.state:destroy()
        _G.BuildController.freeBuildings = false
        package.loaded["states.ui.ActionBar"] = nil
    end)
    local hovel
    local tierParam, houseParam
    _G.campfire = { peasants = 0, maxPeasants = 0 }
    it("is being placed on the map and increases population", function()
        assert.are.equal(startpop, _G.state.maxPopulation)
        hovel = House:new(10, 10)
        assert.are.equal(startpop, _G.state.maxPopulation)
        _G.BuildingManager:add(hovel)
        assert.are.equal(startpop + 4, _G.state.maxPopulation)
        assert:set_parameter("TableFormatLevel", 0)
        assert.are.equal(hovel, _G.state.object[0][0][10][10][1])
    end)
    it("triggers UpgradeHouse event when clicked", function()
        local upgradeHouseTriggered
        eventbus.on(Events.UpgradeHouse, function(param1, param2)
            upgradeHouseTriggered = true
            tierParam = param1
            houseParam = param2
        end)
        hovel:onClick()
        assert.is_true(upgradeHouseTriggered, "Did not receive UpgradeHouse event")
        assert.are.equal(tierParam, 1, "Expected tier 1, but got something else")
        assert.are.equal(houseParam, hovel, "Expected the hovel for houseParam, but got something else")
    end)
    it("upgrades to a Flat when the upgrade button is clicked", function()
        local upgradeButton = require("states.ui.houses.house_ui")
        upgradeButton:OnClick()
        assert.are.equal(-1, hovel.health, "House is not destroyed, but it should be")
        local newHouse = _G.objectFromClassAtGlobal(10, 10, "Flat")
        assert.is_true(not not newHouse, "Upgraded house is missing")
        assert.are.equal(startpop + 8, _G.state.maxPopulation)
    end)
end)
-- =======================================================================--
describe("flat", function()
    local startpop
    setup(function()
        _G.state = State:new()
        _G.channel.mapUpdate:push("final")
        _G.channel2.mapUpdate:push("final")
        startpop = _G.state.maxPopulation
        _G.state.tier = 3
        _G.BuildController.freeBuildings = true
        package.loaded["states.ui.ActionBar"] = mockActionBar
    end)
    teardown(function()
        _G.state:destroy()
        _G.BuildController.freeBuildings = false
        package.loaded["states.ui.ActionBar"] = nil
    end)
    local flat
    local tierParam, houseParam
    _G.campfire = { peasants = 0, maxPeasants = 0 }
    it("is being placed on the map and increases population", function()
        assert.are.equal(startpop, _G.state.maxPopulation)
        flat = Flat:new(10, 10)
        assert.are.equal(startpop, _G.state.maxPopulation)
        _G.BuildingManager:add(flat)
        assert.are.equal(startpop + 8, _G.state.maxPopulation)
        assert:set_parameter("TableFormatLevel", 0)
        assert.are.equal(flat, _G.state.object[0][0][10][10][1])
    end)
    it("triggers UpgradeHouse event when clicked", function()
        local upgradeHouseTriggered
        eventbus.on(Events.UpgradeHouse, function(param1, param2)
            upgradeHouseTriggered = true
            tierParam = param1
            houseParam = param2
        end)
        flat:onClick()
        assert.is_true(upgradeHouseTriggered, "Did not receive UpgradeHouse event")
        assert.are.equal(tierParam, 2, "Expected tier 1, but got something else")
        assert.are.equal(houseParam, flat, "Expected the hovel for houseParam, but got something else")
    end)
    it("upgrades to a Residence when the upgrade button is clicked", function()
        local upgradeButton = require("states.ui.houses.house_ui")
        upgradeButton:OnClick()
        assert.are.equal(-1, flat.health, "House is not destroyed, but it should be")
        local newHouse = _G.objectFromClassAtGlobal(10, 10, "Residence")
        assert.is_true(not not newHouse, "Upgraded house is missing")
        assert.are.equal(startpop + 12, _G.state.maxPopulation)
    end)
end)
-- =======================================================================--
describe("residence", function()
    local startpop
    setup(function()
        _G.state = State:new()
        _G.channel.mapUpdate:push("final")
        _G.channel2.mapUpdate:push("final")
        startpop = _G.state.maxPopulation
        _G.state.tier = 4
        _G.BuildController.freeBuildings = true
        package.loaded["states.ui.ActionBar"] = mockActionBar
    end)
    teardown(function()
        _G.state:destroy()
        _G.BuildController.freeBuildings = false
        package.loaded["states.ui.ActionBar"] = nil
    end)
    local residence
    local tierParam, houseParam
    _G.campfire = { peasants = 0, maxPeasants = 0 }
    it("is being placed on the map and increases population", function()
        assert.are.equal(startpop, _G.state.maxPopulation)
        residence = Residence:new(10, 10)
        assert.are.equal(startpop, _G.state.maxPopulation)
        _G.BuildingManager:add(residence)
        assert.are.equal(startpop + 12, _G.state.maxPopulation)
        assert:set_parameter("TableFormatLevel", 0)
        assert.are.equal(residence, _G.state.object[0][0][10][10][1])
    end)
    it("triggers UpgradeHouse event when clicked", function()
        local upgradeHouseTriggered
        eventbus.on(Events.UpgradeHouse, function(param1, param2)
            upgradeHouseTriggered = true
            tierParam = param1
            houseParam = param2
        end)
        residence:onClick()
        assert.is_true(upgradeHouseTriggered, "Did not receive UpgradeHouse event")
        assert.are.equal(tierParam, 3, "Expected tier 1, but got something else")
        assert.are.equal(houseParam, residence, "Expected the hovel for houseParam, but got something else")
    end)
    it("upgrades to a BigResidence when the upgrade button is clicked", function()
        local upgradeButton = require("states.ui.houses.house_ui")
        upgradeButton:OnClick()
        assert.are.equal(-1, residence.health, "House is not destroyed, but it should be")
        local newHouse = _G.objectFromClassAtGlobal(10, 10, "BigResidence")
        assert.is_true(not not newHouse, "Upgraded house is missing")
        assert.are.equal(startpop + 16, _G.state.maxPopulation)
    end)
end)
