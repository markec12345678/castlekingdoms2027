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

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "sickle" then return end
    local buildings = {
        {button = windmillButton, name = "Windmill", description = "\nProcesses wheat into flour."},
        {button = bakeryButton, name = "Bakery", description = "\nProcesses flour into bread."},
        {button = breweryButton, name = "Brewery", description = "\nProcesses hops into ale."},
        {button = innButton, name = "Inn", description = "\nDistributes ale."}
    }

    for _, building in ipairs(buildings) do
        local table = getCostAndType(building.name)
        building.button:setTooltip(building.name, table.costAndType .. building.description)
        if not table.affordable then
            building.button.tooltip:SetText({{color = {1, 0, 0, 1}}, table.costAndType}, building.name)
        end
    end
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)

el.buttons.sickleButton:setOnClick(function(self)
    ActionBar:showGroup("sickle", _G.fx["metpush5"])
    displayTooltips()
end)


ActionBar:registerGroup("sickle", {windmillButton, bakeryButton, innButton, breweryButton, backButton, destroyButton})
