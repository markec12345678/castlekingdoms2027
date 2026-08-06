local el, setBuildingsTooltips, disableUnavailableButtons = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')
local Events = require('objects.Enums.Events')
local SID = require("objects.Controllers.LanguageController").lines

local granaryButton = ActionBarButton:new(love.graphics.newImage('assets/ui/granary_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)

granaryButton:setOnClick(function(self)
    _G.BuildController:set("Granary", function()
        granaryButton:select()
    end)
    ActionBar:selectButton(granaryButton)
end)

local hunterButton = ActionBarButton:new(love.graphics.newImage('assets/ui/hunter_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true)

hunterButton:setOnClick(function(self)
    _G.BuildController:set("HunterHut", function()
        hunterButton:select()
    end)
    ActionBar:selectButton(hunterButton)
end)

local appleFarmButton = ActionBarButton:new(love.graphics.newImage('assets/ui/apple_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, true)
appleFarmButton:setOnClick(function(self)
    _G.BuildController:set("Orchard", function()
        appleFarmButton:select()
    end)
    ActionBar:selectButton(appleFarmButton)
end)

local cheeseFarmButton = ActionBarButton:new(love.graphics.newImage('assets/ui/cheese_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 4, true)
cheeseFarmButton:setOnClick(function(self)
    _G.BuildController:set("DairyFarm", function()
        cheeseFarmButton:select()
    end)
    ActionBar:selectButton(cheeseFarmButton)
end)

local wheatFarmButton = ActionBarButton:new(love.graphics.newImage('assets/ui/wheat_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 5, true)
wheatFarmButton:setOnClick(function(self)
    _G.BuildController:set("WheatFarm", function()
        wheatFarmButton:select()
    end)
    ActionBar:selectButton(wheatFarmButton)
end)

local hopsFarmButton = ActionBarButton:new(love.graphics.newImage('assets/ui/hops_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 6, false, nil)
hopsFarmButton:setOnClick(function(self)
    _G.BuildController:set("HopsFarm", function()
        hopsFarmButton:select()
    end)
    ActionBar:selectButton(hopsFarmButton)
end)

local buildings = {
    { button = granaryButton,    id = "Granary",   name = SID.buildings.granary.name,   description = SID.buildings.granary.description,   tier = 1 },
    { button = appleFarmButton,  id = "Orchard",   name = SID.buildings.orchard.name,   description = SID.buildings.orchard.description,   tier = 1 },
    { button = hunterButton,     id = "HunterHut", name = SID.buildings.hunterHut.name, description = SID.buildings.hunterHut.description, tier = 1 },
    { button = wheatFarmButton,  id = "WheatFarm", name = SID.buildings.wheatFarm.name, description = SID.buildings.wheatFarm.description, tier = 3 },
    { button = cheeseFarmButton, id = "DairyFarm", name = SID.buildings.dairyFarm.name, description = SID.buildings.dairyFarm.description, tier = 2 },
    { button = hopsFarmButton,   id = "HopsFarm",  name = SID.buildings.hopsFarm.name,  description = SID.buildings.hopsFarm.description,  tier = 3 }
}

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "farms" then return end

    setBuildingsTooltips(buildings)

    local buttonList = {
        hunter = hunterButton,
        appleFarm = appleFarmButton,
        dairyFarm = cheeseFarmButton,
        wheatFarm = wheatFarmButton,
        hopsFarm = hopsFarmButton,
        granary = granaryButton
    }

    disableUnavailableButtons(buttonList)
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnGoldChanged, displayTooltips)
_G.bus.on(Events.OnTierUpgraded, displayTooltips)

el.buttons.appleButton:setOnClick(function(self)
    ActionBar:showGroup("farms", _G.fx["metpush15"])
    displayTooltips()
end)

local createBackButton = require("states.ui.construction.back_button_factory")
local createDestroyButton = require("states.ui.construction.destroy_button_factory")
ActionBar:registerGroup("farms",
    { hunterButton, appleFarmButton, cheeseFarmButton, wheatFarmButton, hopsFarmButton, granaryButton, createBackButton(),
        createDestroyButton() })
