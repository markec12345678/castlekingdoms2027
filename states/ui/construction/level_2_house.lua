local el, backButton, destroyButton, getCostAndType = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')

-- Hovel
local hovelButton = ActionBarButton:new(love.graphics.newImage('assets/ui/hovel_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)

hovelButton:setOnClick(function(self)
    _G.BuildController:set("House", function()
        hovelButton:select()
    end)
    ActionBar:selectButton(hovelButton)
end)

-- Chapel
local chapelButton = ActionBarButton:new(love.graphics.newImage('assets/ui/chapel_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true)

chapelButton:setOnClick(function(self)
    _G.BuildController:set("Chapel", function()
        chapelButton:select()
    end)
    ActionBar:selectButton(chapelButton)
end)


local function displayTooltips()
    hovelButton:setTooltip("Hovel", getCostAndType("House") .. "\nIncreases maximum population limit")
    chapelButton:setTooltip("Chapel", getCostAndType("Chapel") .. "\nIncrease your popularity with religion. Currently not functional.")
end

el.buttons.houseButton:setOnClick(function(self)
    ActionBar:showGroup("house")
    displayTooltips()
end)

ActionBar:registerGroup("house", {hovelButton, chapelButton, backButton, destroyButton})
