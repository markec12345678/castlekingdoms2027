local el, backButton, destroyButton, getCostAndType = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')

local hovelButton = ActionBarButton:new(love.graphics.newImage('assets/ui/hovel_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)

hovelButton:setOnClick(function(self)
    _G.BuildController:set("house", function()
        hovelButton:select()
    end)
    ActionBar:selectButton(hovelButton)
end)

local function displayTooltips()
    hovelButton:setTooltip("Hovel", getCostAndType("house") .. "\nIncreases maximum population limit")
end

el.buttons.houseButton:setOnClick(function(self)
    ActionBar:showGroup("house")
    displayTooltips()
end)

ActionBar:registerGroup("house", {hovelButton, backButton, destroyButton})
