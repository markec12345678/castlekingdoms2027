local el = ...

local loveframes = require('libraries.loveframes')
local states = require('states.ui.states')
local ab = require('states.ui.action_bar_frames')
local ActionBarButton = require('states.ui.ActionBarButton')
local action_bar = require('states.ui.ActionBar')

local hunter_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/hunter_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1)
hunter_btn:hide()

local apple_farm_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/apple_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2)
apple_farm_btn:hide()

apple_farm_btn:set_on_click(function(self)
    _G.BuildController:set("orchard", function()
        apple_farm_btn:unselect()
    end)
    action_bar:select_button(apple_farm_btn)
end)

local cheese_farm_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/cheese_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3)
cheese_farm_btn:hide()

local wheat_farm_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/wheat_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 4)
wheat_farm_btn:hide()

wheat_farm_btn:set_on_click(function(self)
    _G.BuildController:set("wheat_farm", function()
        wheat_farm_btn:unselect()
    end)
    action_bar:select_button(wheat_farm_btn)
end)

local hops_farm_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/hops_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 5)
hops_farm_btn:hide()

local back_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/back_ab.png'), states.STATE_INGAME_CONSTRUCTION,
    12)
back_btn:hide()
back_btn:set_on_click(function(self)
    action_bar:show_group("main")
end)

el.buttons.castle_btn.stop_propagation = true
el.buttons.castle_btn:set_on_click(function(self)
    action_bar:show_group("farms")
end)

action_bar:register_group("farms",
    {hunter_btn, apple_farm_btn, cheese_farm_btn, wheat_farm_btn, hops_farm_btn, back_btn})

local img_keybinds = love.graphics.newImage('assets/ui/keybindings_action_bar.png')
local keybinds = loveframes.Create("image")
keybinds:SetState(states.STATE_INGAME_CONSTRUCTION)
keybinds:SetImage(img_keybinds)
keybinds.disablehover = true
keybinds:SetOffsetY(img_keybinds:getHeight())
keybinds:SetPos(ab.fr_action_1.x + ab.fr_action_1.width - 14 * el.parent_scale,
    ab.fr_action_bar.y + ab.fr_action_bar.height - 3 * el.parent_scale)
keybinds:SetScale(el.parent_scale)
