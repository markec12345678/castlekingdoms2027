local el, backButton = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')

local granaryButton = ActionBarButton:new(love.graphics.newImage('assets/ui/granary_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)

granaryButton:setOnClick(function(self)
    _G.BuildController:set("granary", function()
        granaryButton:unselect()
    end)
    ActionBar:selectButton(granaryButton)
end)
granaryButton:setTooltip("Granary", "Requires 10 Wood\nIncreases food capacity")

local hunterButton = ActionBarButton:new(love.graphics.newImage('assets/ui/hunter_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true, nil, true)
hunterButton:setTooltip("Hunter's hut", "Not implemented yet")

local appleFarmButton = ActionBarButton:new(love.graphics.newImage('assets/ui/apple_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, true)

appleFarmButton:setOnClick(function(self)
    _G.BuildController:set("orchard", function()
        appleFarmButton:unselect()
    end)
    ActionBar:selectButton(appleFarmButton)
end)
appleFarmButton:setTooltip("Orchard", "Requires 3 Wood\nProduces apples")

local cheeseFarmButton = ActionBarButton:new(love.graphics.newImage('assets/ui/cheese_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 4, true, nil, true)
cheeseFarmButton:setTooltip("Dairy farm", "Not implemented yet")

local wheatFarmButton = ActionBarButton:new(love.graphics.newImage('assets/ui/wheat_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 5, true)

wheatFarmButton:setOnClick(function(self)
    _G.BuildController:set("wheat_farm", function()
        wheatFarmButton:unselect()
    end)
    ActionBar:selectButton(wheatFarmButton)
end)
wheatFarmButton:setTooltip("Wheat farm", "Requires 4 Wood\nProduces wheat which can be processed into flour")

local hopsFarmButton = ActionBarButton:new(love.graphics.newImage('assets/ui/hops_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 6, true, nil, true)
hopsFarmButton:setTooltip("Hops farm", "Not implemented yet")

el.buttons.appleButton:setOnClick(function(self)
    ActionBar:showGroup("farms")
end)

ActionBar:registerGroup("farms", {hunterButton, appleFarmButton, cheeseFarmButton, wheatFarmButton, hopsFarmButton,
                                  granaryButton, backButton})
