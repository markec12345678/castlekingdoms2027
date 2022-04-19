local el = ...

local loveframes = require('libraries.loveframes')
local states = require('states.ui.states')
local ab = require('states.ui.action_bar_frames')
local ActionBarButton = require('states.ui.ActionBarButton')

local img_ab_background, img_ab_background_hover, img_ab_background_selected = ActionBarButton.background_image,
    ActionBarButton.background_hover_image, ActionBarButton.background_selected_image

local hunter_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/hunter_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1)
hunter_btn:hide()

local apple_farm_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/apple_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2)
apple_farm_btn:hide()

apple_farm_btn:set_on_click(function(self)
    self.selected = true
    self:SetImage(ActionBarButton.background_selected_image)
end)

local cheese_farm_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/cheese_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3)
cheese_farm_btn:hide()

local wheat_farm_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/wheat_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 4)
wheat_farm_btn:hide()

local hops_farm_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/hops_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 5)
hops_farm_btn:hide()

local back_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/back_ab.png'), states.STATE_INGAME_CONSTRUCTION,
    12)
back_btn:hide()
back_btn:set_on_click(function(self)
    for _, v in pairs(el.buttons) do
        v:show()
    end
    -- TODO: Implement ActionBarButton:hide_group("farms")
    hunter_btn:hide()
    apple_farm_btn:hide()
    cheese_farm_btn:hide()
    wheat_farm_btn:hide()
    hops_farm_btn:hide()
    back_btn:hide()
end)

el.buttons.castle_btn.stop_propagation = true
el.buttons.castle_btn:set_on_click(function(self)
    for _, v in pairs(el.buttons) do
        v:hide()
    end
    hunter_btn:show()
    apple_farm_btn:show()
    cheese_farm_btn:show()
    wheat_farm_btn:show()
    hops_farm_btn:show()
    back_btn:show()
end)

local img_keybinds = love.graphics.newImage('assets/ui/keybindings_action_bar.png')
local keybinds = loveframes.Create("image")
keybinds:SetState(states.STATE_INGAME_CONSTRUCTION)
keybinds:SetImage(img_keybinds)
keybinds.disablehover = true
keybinds:SetOffsetY(img_keybinds:getHeight())
keybinds:SetPos(ab.fr_action_1.x + ab.fr_action_1.width - 14 * el.parent_scale,
    ab.fr_action_bar.y + ab.fr_action_bar.height - 3 * el.parent_scale)
keybinds:SetScale(el.parent_scale)
