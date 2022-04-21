local action_bar = require('states.ui.ActionBar')
require('states.ui.construction.level_1')
local loveframes = require('libraries.loveframes')
local states = require('states.ui.states')
local ab = require('states.ui.action_bar_frames')
local el = action_bar.element

local img_keybinds = love.graphics.newImage('assets/ui/keybindings_action_bar.png')
local keybinds = loveframes.Create("image")
keybinds:SetState(states.STATE_INGAME_CONSTRUCTION)
keybinds:SetImage(img_keybinds)
keybinds.disablehover = true
keybinds:SetOffsetY(img_keybinds:getHeight())
keybinds:SetPos(ab.fr_action_1.x + ab.fr_action_1.width - 14 * el.scalex,
    ab.fr_action_bar.y + ab.fr_action_bar.height - 3 * el.scalex)
keybinds:SetScale(el.scalex)
