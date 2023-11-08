local el, backButton, destroyButton, setBuildingsTooltips, disableUnavailableButtons = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")
local SID = require("objects.Controllers.LanguageController").lines

local windmillButton = ActionBarButton:new(love.graphics.newImage("assets/ui/windmill_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 1, true)

windmillButton:setOnClick(function(self)
    _G.BuildController:set("Windmill", function()
        windmillButton:select()
    end)
    ActionBar:selectButton(windmillButton)
end)

local bakeryButton = ActionBarButton:new(love.graphics.newImage("assets/ui/bakery_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 2, true)

bakeryButton:setOnClick(function(self)
    _G.BuildController:set("Bakery", function()
        bakeryButton:select()
    end)
    ActionBar:selectButton(bakeryButton)
end)

local innButton = ActionBarButton:new(love.graphics.newImage("assets/ui/inn_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 3, true)

innButton:setOnClick(function(self)
    _G.BuildController:set("Inn", function()
        innButton:select()
    end)
    ActionBar:selectButton(innButton)
end)

local breweryButton = ActionBarButton:new(love.graphics.newImage("assets/ui/brewery_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 4, true)

breweryButton:setOnClick(function(self)
    _G.BuildController:set("Brewery", function()
        breweryButton:select()
    end)
    ActionBar:selectButton(breweryButton)
end)

local buildings = {
    { button = windmillButton, id = "Windmill", name = SID.buildings.windmill.name, description = SID.buildings.windmill.description, tier = 3 },
    { button = bakeryButton,   id = "Bakery",   name = SID.buildings.bakery.name,   description = SID.buildings.bakery.description,   tier = 3 },
    { button = breweryButton,  id = "Brewery",  name = SID.buildings.brewery.name,  description = SID.buildings.brewery.description,  tier = 3 },
    { button = innButton,      id = "Inn",      name = SID.buildings.inn.name,      description = SID.buildings.inn.description,      tier = 3 }
}

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "sickle" then return end

    setBuildingsTooltips(buildings)

    local buttonList = {
        windmill = windmillButton,
        bakery = bakeryButton,
        inn = innButton,
        brewery = breweryButton
    }

    disableUnavailableButtons(buttonList)
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnGoldChanged, displayTooltips)
_G.bus.on(Events.OnTierUpgraded, displayTooltips)

el.buttons.sickleButton:setOnClick(function(self)
    ActionBar:showGroup("sickle", _G.fx["metpush5"])
    displayTooltips()
end)


ActionBar:registerGroup("sickle", { windmillButton, bakeryButton, innButton, breweryButton, backButton, destroyButton })
