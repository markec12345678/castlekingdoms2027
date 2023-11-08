local el, backButton, destroyButton, setBuildingsTooltips = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")
local SID = require("objects.Controllers.LanguageController").lines

local HovelButton = ActionBarButton:new(love.graphics.newImage("assets/ui/hovel_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 1, true, nil)
HovelButton:setOnClick(
    function(self)
        ActionBar:selectButton(HovelButton)
        _G.BuildController:set(
            "House", function()
                HovelButton:unselect()
            end)
        ActionBar:selectButton(HovelButton)
    end)

local FlatButton = ActionBarButton:new(love.graphics.newImage("assets/ui/flat_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 2, true, nil)
FlatButton:setOnClick(
    function(self)
        ActionBar:selectButton(FlatButton)
        _G.BuildController:set(
            "Flat", function()
                FlatButton:unselect()
            end)
        ActionBar:selectButton(FlatButton)
    end)

local ResidenceButton = ActionBarButton:new(love.graphics.newImage("assets/ui/residence_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 3, true, nil)
ResidenceButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "Residence", function()
                ResidenceButton:unselect()
            end)
        ActionBar:selectButton(ResidenceButton)
    end)

local BigResidenceButton = ActionBarButton:new(love.graphics.newImage("assets/ui/bigresidence_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 4, true, nil)
BigResidenceButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "BigResidence", function()
                BigResidenceButton:unselect()
            end)
        ActionBar:selectButton(BigResidenceButton)
    end)

local buildings = {
    { button = HovelButton,        id = "House",        name = SID.buildings.hovel.name,        description = SID.buildings.hovel.description,        tier = 1 },
    { button = FlatButton,         id = "Flat",         name = SID.buildings.flat.name,         description = SID.buildings.flat.description,         tier = 2 },
    { button = ResidenceButton,    id = "Residence",    name = SID.buildings.residence.name,    description = SID.buildings.residence.description,    tier = 3 },
    { button = BigResidenceButton, id = "BigResidence", name = SID.buildings.bigResidence.name, description = SID.buildings.bigResidence.description, tier = 4 },
}

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "houses" then return end

    setBuildingsTooltips(buildings)
end

el.buttons.hovelButton:setOnClick(function(self)
    ActionBar:showGroup("houses", _G.fx["metpush15"])
    displayTooltips()
end)

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnTierUpgraded, displayTooltips)

ActionBar:registerGroup("houses",
    { HovelButton, FlatButton, ResidenceButton, BigResidenceButton,
        backButton, destroyButton })
