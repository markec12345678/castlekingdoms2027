local el, backButton, destroyButton, getCostAndType = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")

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

local function displayTooltips()
    windmillButton:setTooltip("Windmill", getCostAndType("Windmill") .. "\nProcesses wheat into flour")
    bakeryButton:setTooltip("Bakery", getCostAndType("Bakery") .. "\nProcesses flour into bread")
end

el.buttons.sickleButton:setOnClick(function(self)
    ActionBar:showGroup("sickle")
    displayTooltips()
end)


ActionBar:registerGroup("sickle", {windmillButton, bakeryButton, backButton, destroyButton})
