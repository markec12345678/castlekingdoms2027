local loveframes = require('libraries.loveframes')
local states = require('states.ui.states')
local base = require('states.ui.base')
local w, h = base.w, base.h

local img_action_bar = love.graphics.newImage('assets/ui/action_bar.png')

local ACTION_BAR_USER_SCALE = 60

if ACTION_BAR_USER_SCALE > 100 or ACTION_BAR_USER_SCALE < 5 then
    error("Action bar scale must be between 5 and 100")
end

local scale = (w.percent[ACTION_BAR_USER_SCALE]) / img_action_bar:getWidth()
local action_bar = loveframes.Create("image")
action_bar:SetState(states.STATE_INGAME_CONSTRUCTION)
action_bar:SetImage(img_action_bar)
action_bar:SetOffsetX(action_bar:GetImageWidth() / 2)
action_bar:SetScaleX(scale)
action_bar:SetScaleY(scale)
action_bar:SetPos(w.percent[50], h.percent[100] - action_bar:GetImageHeight() * action_bar:GetScaleY())

local ActionBar = _G.class('ActionBar')
function ActionBar:initialize()
end

return action_bar
