local states = require('states.ui.states')
local ab = require('states.ui.action_bar_frames')
local ActionBarButton = require('states.ui.ActionBarButton')
local action_bar = require('states.ui.ActionBar')

local castle_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/castle_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1)

local hammer_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/hammer_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2)

local apple_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/apple_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3)

local house_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/house_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 4)

local shield_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/shield_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 5)

local sickle_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/sickle_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 6)

action_bar:register_group("main", {castle_btn, hammer_btn, apple_btn, house_btn, shield_btn, sickle_btn})

local back_btn = ActionBarButton:new(love.graphics.newImage('assets/ui/back_ab.png'), states.STATE_INGAME_CONSTRUCTION,
    12)
back_btn:hide()
back_btn:set_on_click(function(self)
    action_bar:show_group("main")
end)
local elements = {
    buttons = {
        castle_btn = castle_btn,
        hammer_btn = hammer_btn,
        apple_btn = apple_btn,
        house_btn = house_btn,
        shield_btn = shield_btn,
        sickle_btn = sickle_btn
    },
    parent_scale = ab.fr_full.scale
}

package.loaded['states.ui.construction.level_2_castle'] = love.filesystem.load(
    'states/ui/construction/level_2_castle.lua')(elements, back_btn)

package.loaded['states.ui.construction.level_2_farms'] = love.filesystem
                                                             .load('states/ui/construction/level_2_farms.lua')(elements,
    back_btn)

package.loaded['states.ui.construction.level_2_resource'] = love.filesystem.load(
    'states/ui/construction/level_2_resource.lua')(elements, back_btn)
