local el, back_btn = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local action_bar = require('states.ui.ActionBar')

local windmill_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/windmill_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)

windmill_btn:set_on_click(function(self)
    _G.BuildController:set("windmill", function()
        windmill_btn:unselect()
    end)
    action_bar:select_button(windmill_btn)
end)
windmill_btn:set_tooltip("Windmill", "Requires 8 Wood\nProcesses wheat into flour")

local bakery_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/bakery_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true)

bakery_btn:set_on_click(function(self)
    _G.BuildController:set("bakery", function()
        bakery_btn:unselect()
    end)
    action_bar:select_button(bakery_btn)
end)
bakery_btn:set_tooltip("Bakery", "Requires 10 Wood, 2 Stone\nProcesses flour into bread")

el.buttons.sickle_btn:set_on_click(function(self)
    action_bar:show_group("sickle")
end)

action_bar:register_group("sickle", {windmill_btn, bakery_btn, back_btn})
