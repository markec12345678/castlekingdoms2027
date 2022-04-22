local el, back_btn = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local action_bar = require('states.ui.ActionBar')

local stockpile_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/stockpile_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)

stockpile_btn:set_on_click(function(self)
    _G.BuildController:set("stockpile", function()
        stockpile_btn:unselect()
    end)
    action_bar:select_button(stockpile_btn)
end)

local woodcutter_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/woodcutter_hut_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true)

woodcutter_btn:set_on_click(function(self)
    _G.BuildController:set("woodcutter_hut", function()
        woodcutter_btn:unselect()
    end)
    action_bar:select_button(woodcutter_btn)
end)

local quarry_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/quarry_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, true)

quarry_btn:set_on_click(function(self)
    _G.BuildController:set("quarry", function()
        quarry_btn:unselect()
    end)
    action_bar:select_button(quarry_btn)
end)

local ox_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/ox_ab.png'), states.STATE_INGAME_CONSTRUCTION, 4,
    true, nil, true)

local iron_mine = ActionBarButton:new(love.graphics.newImage('assets/ui/iron_mine_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 5, true)

iron_mine:set_on_click(function(self)
    _G.BuildController:set("iron_mine", function()
        iron_mine:unselect()
    end)
    action_bar:select_button(iron_mine)
end)

el.buttons.hammer_btn:set_on_click(function(self)
    action_bar:show_group("resource")
end)

action_bar:register_group("resource", {stockpile_btn, woodcutter_btn, quarry_btn, ox_btn, iron_mine, back_btn})
