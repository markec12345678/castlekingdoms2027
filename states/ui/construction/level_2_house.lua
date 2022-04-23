local el, back_btn = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local action_bar = require('states.ui.ActionBar')

local hovel_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/hovel_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)

hovel_btn:set_on_click(function(self)
    _G.BuildController:set("house", function()
        hovel_btn:unselect()
    end)
    action_bar:select_button(hovel_btn)
end)
hovel_btn:set_tooltip("Hovel", "Requires 3 Wood\nIncreases maximum population limit")

el.buttons.house_btn:set_on_click(function(self)
    action_bar:show_group("house")
end)

action_bar:register_group("house", {hovel_btn, back_btn})
