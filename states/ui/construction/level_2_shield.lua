local el, backButton, destroyButton, setBuildingsTooltips, disableUnavailableButtons = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")
local SID = require("objects.Controllers.LanguageController").lines

local armouryButton = ActionBarButton:new(love.graphics.newImage("assets/ui/armoury_arms_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 1, true, nil)
armouryButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "Armoury", function()
                armouryButton:unselect()
            end)
        ActionBar:selectButton(armouryButton)
    end)

local fletcherButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fletcher_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 2, true, nil)
fletcherButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "FletcherWorkshop", function()
                fletcherButton:unselect()
            end)
        ActionBar:selectButton(fletcherButton)
    end)

local poleturnerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/poleturner_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 3, true, nil)
poleturnerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "PoleturnerWorkshop", function()
                poleturnerButton:unselect()
            end)
        ActionBar:selectButton(poleturnerButton)
    end)

local blacksmithButton = ActionBarButton:new(love.graphics.newImage("assets/ui/blacksmith_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 4, true)
blacksmithButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "BlacksmithWorkshop", function()
                blacksmithButton:unselect()
            end)
        ActionBar:selectButton(blacksmithButton)
    end)

local armorerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/armorer_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 5, false)
armorerButton:setOnClick(function(self)
    _G.BuildController:set("Armorer", function()
        armorerButton:select()
    end)
    ActionBar:selectButton(armorerButton)
end)

local buildings = {
    { button = armouryButton,    id = "Armoury",            name = SID.buildings.armoury.name,    description = SID.buildings.armoury.description,    tier = 2 },
    { button = fletcherButton,   id = "FletcherWorkshop",   name = SID.buildings.fletcher.name,   description = SID.buildings.fletcher.description,   tier = 2 },
    { button = poleturnerButton, id = "PoleturnerWorkshop", name = SID.buildings.poleturner.name, description = SID.buildings.poleturner.description, tier = 2 },
    { button = blacksmithButton, id = "BlacksmithWorkshop", name = SID.buildings.blacksmith.name, description = SID.buildings.blacksmith.description, tier = 3 },
    { button = armorerButton,    id = "Armorer",            name = SID.buildings.armorer.name,    description = SID.buildings.armorer.description,    tier = 3 }
}

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "shield" then return end

    setBuildingsTooltips(buildings)

    local buttonList = {
        armoury = armouryButton,
        fletcherWorkshop = fletcherButton,
        poleturnerWorkshop = poleturnerButton,
        blacksmithWorkshop = blacksmithButton,
        armorerWorkshop = armorerButton,
    }

    disableUnavailableButtons(buttonList)
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnGoldChanged, displayTooltips)
_G.bus.on(Events.OnTierUpgraded, displayTooltips)

el.buttons.shieldButton:setOnClick(function(self)
    ActionBar:showGroup("shield", _G.fx["metpush1"])
    displayTooltips()
end)


ActionBar:registerGroup("shield",
    { armouryButton, fletcherButton, poleturnerButton, blacksmithButton, armorerButton, backButton, destroyButton })
