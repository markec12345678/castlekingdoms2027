local el, back_btn = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local action_bar = require('states.ui.ActionBar')

local castle_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/wooden_castle_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1)

castle_btn:set_on_click(function(self)
    _G.BuildController:set("castle", function()
        castle_btn:unselect()
    end)
    action_bar:select_button(castle_btn)
end)

local wooden_wall_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/wooden_wall_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true, nil, true)

el.buttons.castle_btn:set_on_click(function(self)
    action_bar:show_group("castle")
end)

action_bar:register_group("castle", {castle_btn, wooden_wall_btn, back_btn})
