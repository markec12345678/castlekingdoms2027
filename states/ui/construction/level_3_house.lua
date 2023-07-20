local el, backButton, destroyButton, getCostAndType = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")

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
    {
        button = HovelButton,
        name = "House",
        description =
        "A small hut - gives shelter to 4 people.",
        tier = 1
    },
    {
        button = FlatButton,
        name = "Flat",
        description =
        "A small, cosy flat - gives shelter to 8 people",
        tier = 2
    },
    {
        button = ResidenceButton,
        name = "Residence",
        description =
        "A nice and elegant house - gives shelter to 12 peole.",
        tier = 3
    },
    {
        button = BigResidenceButton,
        name = "BigResidence",
        description =
        "A big residence - gives shelter to 16 people",
        tier = 4
    },
}

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "houses" then return end
    for _, building in ipairs(buildings) do
        local tooltipText = getCostAndType(building.name, building.description)
        building.button:setTooltip(building.name, tooltipText)
        if building.tier <= _G.state.tier then
            building.button:enable()
        else
            building.button:disable()
            building.button:setTooltip("You need to upgrade your keep to build this")
        end
    end
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
