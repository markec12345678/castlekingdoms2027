local el, backButton, destroyButton, getCostAndType = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")

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
    { button = windmillButton, name = "Windmill", description = "Processes wheat into flour.", tier = 3 },
    { button = bakeryButton,   name = "Bakery",   description = "Processes flour into bread.", tier = 3 },
    { button = breweryButton,  name = "Brewery",  description = "Processes hops into ale.",    tier = 3 },
    { button = innButton,      name = "Inn",      description = "Distributes ale.",            tier = 3 }
}

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "sickle" then return end
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
    local lockedList = _G.MissionController:getLockedBuildings()
    local buttonList = {
        windmill = windmillButton,
        bakery = bakeryButton,
        inn = innButton,
        brewery = breweryButton
    }

    if lockedList ~= nil then
        for _, value in ipairs(lockedList) do
            local button = buttonList[value]
            if button then
                button:disable("Not available in this mission")
            end
        end
    end
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
