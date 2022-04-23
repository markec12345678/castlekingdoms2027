local action_bar = require('states.ui.ActionBar')
action_bar = action_bar.element
local ACTION_BAR_X_OFFSET = 240
local ACTION_BAR_Y_OFFSET = 134
local ACTION_BAR_WIDTH = 981 - ACTION_BAR_X_OFFSET
local ACTION_BAR_HEIGHT = 193 - ACTION_BAR_Y_OFFSET
local ACTION_BUTTON_WIDTH = 299 - ACTION_BAR_X_OFFSET
local ACTION_BUTTON_SPACING = 3
local scale = action_bar.scalex
local AB_INSIDE_PADDING = 7 * scale

local fr_full = {
    x = action_bar:GetX() - action_bar:GetOffsetX() * scale,
    y = action_bar:GetY() - action_bar:GetOffsetY() * scale,
    width = action_bar:GetWidth() * scale,
    height = action_bar:GetHeight() * scale,
    scale = scale
}

local fr_action_bar = {
    x = fr_full.x + ACTION_BAR_X_OFFSET * scale,
    y = fr_full.y + ACTION_BAR_Y_OFFSET * scale,
    width = ACTION_BAR_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}
local frames = {
    fr_full = fr_full,
    fr_action_bar = fr_action_bar
}
for i = 1, 12 do
    local fr_action_obj = {
        x = fr_action_bar.x + (ACTION_BUTTON_WIDTH + ACTION_BUTTON_SPACING) * scale * (i - 1),
        y = fr_action_bar.y,
        width = ACTION_BUTTON_WIDTH * scale,
        height = ACTION_BAR_HEIGHT * scale
    }
    frames["fr_action_" .. i .. "_img"] = {
        x = fr_action_obj.x + AB_INSIDE_PADDING,
        y = fr_action_obj.y + AB_INSIDE_PADDING,
        width = fr_action_obj.width - AB_INSIDE_PADDING * 2,
        height = fr_action_obj.height - AB_INSIDE_PADDING * 2
    }
    frames["fr_action_" .. i] = fr_action_obj
end

return frames
