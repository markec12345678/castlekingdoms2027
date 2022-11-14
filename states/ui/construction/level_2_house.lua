local el, backButton, destroyButton = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')

local hovelButton = ActionBarButton:new(love.graphics.newImage('assets/ui/hovel_ab.png'), states.STATE_INGAME_CONSTRUCTION, 1, true)

hovelButton:setOnClick(function(self)
    _G.BuildController:set("house", function()
        hovelButton:select()
    end)
    ActionBar:selectButton(hovelButton)
end)
hovelButton:setTooltip("Hovel", "Requires 3 Wood\nIncreases maximum population limit")

el.buttons.houseButton:setOnClick(function(self)
    ActionBar:showGroup("house")
end)

ActionBar:registerGroup("house", {hovelButton, backButton, destroyButton})
