local el, back_btn = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local action_bar = require('states.ui.ActionBar')

local granary_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/granary_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)

granary_btn:set_on_click(function(self)
    _G.BuildController:set("granary", function()
        granary_btn:unselect()
    end)
    action_bar:select_button(granary_btn)
end)
granary_btn:set_tooltip("Granary", "Requires 10 Wood\nIncreases food capacity")

local hunter_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/hunter_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true, nil, true)
hunter_btn:set_tooltip("Hunter's hut", "Not implemented yet")

local apple_farm_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/apple_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, true)

apple_farm_btn:set_on_click(function(self)
    _G.BuildController:set("orchard", function()
        apple_farm_btn:unselect()
    end)
    action_bar:select_button(apple_farm_btn)
end)
apple_farm_btn:set_tooltip("Orchard", "Requires 3 Wood\nProduces apples")

local cheese_farm_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/cheese_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 4, true, nil, true)
cheese_farm_btn:set_tooltip("Dairy farm", "Not implemented yet")

local wheat_farm_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/wheat_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 5, true)

wheat_farm_btn:set_on_click(function(self)
    _G.BuildController:set("wheat_farm", function()
        wheat_farm_btn:unselect()
    end)
    action_bar:select_button(wheat_farm_btn)
end)
wheat_farm_btn:set_tooltip("Wheat farm", "Requires 4 Wood\nProduces wheat which can be processed into flour")

local hops_farm_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/hops_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 6, true, nil, true)
hops_farm_btn:set_tooltip("Hops farm", "Not implemented yet")

el.buttons.apple_btn:set_on_click(function(self)
    action_bar:show_group("farms")
end)

action_bar:register_group("farms", {hunter_btn, apple_farm_btn, cheese_farm_btn, wheat_farm_btn, hops_farm_btn,
                                    granary_btn, back_btn})
