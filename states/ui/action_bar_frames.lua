local action_bar = require('states.ui.action_bar')

local ACTION_BAR_X_OFFSET = 240
local ACTION_BAR_Y_OFFSET = 134
local ACTION_BAR_WIDTH = 981 - ACTION_BAR_X_OFFSET
local ACTION_BAR_HEIGHT = 193 - ACTION_BAR_Y_OFFSET
local ACTION_BUTTON_WIDTH = 299 - ACTION_BAR_X_OFFSET
local ACTION_BUTTON_SPACING = 3
local scale = action_bar.scalex

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

local fr_action_1 = {
    x = fr_action_bar.x,
    y = fr_action_bar.y,
    width = ACTION_BUTTON_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}

local fr_action_2 = {
    x = fr_action_bar.x + (ACTION_BUTTON_WIDTH + ACTION_BUTTON_SPACING) * scale * (2 - 1),
    y = fr_action_bar.y,
    width = ACTION_BUTTON_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}

local fr_action_3 = {
    x = fr_action_bar.x + (ACTION_BUTTON_WIDTH + ACTION_BUTTON_SPACING) * scale * (3 - 1),
    y = fr_action_bar.y,
    width = ACTION_BUTTON_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}

local fr_action_4 = {
    x = fr_action_bar.x + (ACTION_BUTTON_WIDTH + ACTION_BUTTON_SPACING) * scale * (4 - 1),
    y = fr_action_bar.y,
    width = ACTION_BUTTON_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}

local fr_action_5 = {
    x = fr_action_bar.x + (ACTION_BUTTON_WIDTH + ACTION_BUTTON_SPACING) * scale * (5 - 1),
    y = fr_action_bar.y,
    width = ACTION_BUTTON_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}

local fr_action_6 = {
    x = fr_action_bar.x + (ACTION_BUTTON_WIDTH + ACTION_BUTTON_SPACING) * scale * (6 - 1),
    y = fr_action_bar.y,
    width = ACTION_BUTTON_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}

local fr_action_7 = {
    x = fr_action_bar.x + (ACTION_BUTTON_WIDTH + ACTION_BUTTON_SPACING) * scale * (7 - 1),
    y = fr_action_bar.y,
    width = ACTION_BUTTON_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}

local fr_action_8 = {
    x = fr_action_bar.x + (ACTION_BUTTON_WIDTH + ACTION_BUTTON_SPACING) * scale * (8 - 1),
    y = fr_action_bar.y,
    width = ACTION_BUTTON_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}

local fr_action_9 = {
    x = fr_action_bar.x + (ACTION_BUTTON_WIDTH + ACTION_BUTTON_SPACING) * scale * (9 - 1),
    y = fr_action_bar.y,
    width = ACTION_BUTTON_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}

local fr_action_10 = {
    x = fr_action_bar.x + (ACTION_BUTTON_WIDTH + ACTION_BUTTON_SPACING) * scale * (10 - 1),
    y = fr_action_bar.y,
    width = ACTION_BUTTON_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}

local fr_action_11 = {
    x = fr_action_bar.x + (ACTION_BUTTON_WIDTH + ACTION_BUTTON_SPACING) * scale * (11 - 1),
    y = fr_action_bar.y,
    width = ACTION_BUTTON_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}

local fr_action_12 = {
    x = fr_action_bar.x + (ACTION_BUTTON_WIDTH + ACTION_BUTTON_SPACING) * scale * (12 - 1),
    y = fr_action_bar.y,
    width = ACTION_BUTTON_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}

local AB_INSIDE_PADDING = 7 * fr_full.scale

local fr_action_1_img = {
    x = fr_action_1.x + AB_INSIDE_PADDING,
    y = fr_action_1.y + AB_INSIDE_PADDING,
    width = fr_action_1.width - AB_INSIDE_PADDING * 2,
    height = fr_action_1.height - AB_INSIDE_PADDING * 2
}

local fr_action_2_img = {
    x = fr_action_2.x + AB_INSIDE_PADDING,
    y = fr_action_2.y + AB_INSIDE_PADDING,
    width = fr_action_2.width - AB_INSIDE_PADDING * 2,
    height = fr_action_2.height - AB_INSIDE_PADDING * 2
}

local fr_action_3_img = {
    x = fr_action_3.x + AB_INSIDE_PADDING,
    y = fr_action_3.y + AB_INSIDE_PADDING,
    width = fr_action_3.width - AB_INSIDE_PADDING * 2,
    height = fr_action_3.height - AB_INSIDE_PADDING * 2
}

local fr_action_4_img = {
    x = fr_action_4.x + AB_INSIDE_PADDING,
    y = fr_action_4.y + AB_INSIDE_PADDING,
    width = fr_action_4.width - AB_INSIDE_PADDING * 2,
    height = fr_action_4.height - AB_INSIDE_PADDING * 2
}

local fr_action_5_img = {
    x = fr_action_5.x + AB_INSIDE_PADDING,
    y = fr_action_5.y + AB_INSIDE_PADDING,
    width = fr_action_5.width - AB_INSIDE_PADDING * 2,
    height = fr_action_5.height - AB_INSIDE_PADDING * 2
}

local fr_action_6_img = {
    x = fr_action_6.x + AB_INSIDE_PADDING,
    y = fr_action_6.y + AB_INSIDE_PADDING,
    width = fr_action_6.width - AB_INSIDE_PADDING * 2,
    height = fr_action_6.height - AB_INSIDE_PADDING * 2
}

local fr_action_7_img = {
    x = fr_action_7.x + AB_INSIDE_PADDING,
    y = fr_action_7.y + AB_INSIDE_PADDING,
    width = fr_action_7.width - AB_INSIDE_PADDING * 2,
    height = fr_action_7.height - AB_INSIDE_PADDING * 2
}

local fr_action_8_img = {
    x = fr_action_8.x + AB_INSIDE_PADDING,
    y = fr_action_8.y + AB_INSIDE_PADDING,
    width = fr_action_8.width - AB_INSIDE_PADDING * 2,
    height = fr_action_8.height - AB_INSIDE_PADDING * 2
}

local fr_action_9_img = {
    x = fr_action_9.x + AB_INSIDE_PADDING,
    y = fr_action_9.y + AB_INSIDE_PADDING,
    width = fr_action_9.width - AB_INSIDE_PADDING * 2,
    height = fr_action_9.height - AB_INSIDE_PADDING * 2
}

local fr_action_10_img = {
    x = fr_action_10.x + AB_INSIDE_PADDING,
    y = fr_action_10.y + AB_INSIDE_PADDING,
    width = fr_action_10.width - AB_INSIDE_PADDING * 2,
    height = fr_action_10.height - AB_INSIDE_PADDING * 2
}

local fr_action_11_img = {
    x = fr_action_11.x + AB_INSIDE_PADDING,
    y = fr_action_11.y + AB_INSIDE_PADDING,
    width = fr_action_11.width - AB_INSIDE_PADDING * 2,
    height = fr_action_11.height - AB_INSIDE_PADDING * 2
}

local fr_action_12_img = {
    x = fr_action_12.x + AB_INSIDE_PADDING,
    y = fr_action_12.y + AB_INSIDE_PADDING,
    width = fr_action_12.width - AB_INSIDE_PADDING * 2,
    height = fr_action_12.height - AB_INSIDE_PADDING * 2
}

return {
    fr_full = fr_full,
    fr_action_bar = fr_action_bar,
    fr_action_1 = fr_action_1,
    fr_action_2 = fr_action_2,
    fr_action_3 = fr_action_3,
    fr_action_4 = fr_action_4,
    fr_action_5 = fr_action_5,
    fr_action_6 = fr_action_6,
    fr_action_7 = fr_action_7,
    fr_action_8 = fr_action_8,
    fr_action_9 = fr_action_9,
    fr_action_10 = fr_action_10,
    fr_action_11 = fr_action_11,
    fr_action_12 = fr_action_12,
    fr_action_1_img = fr_action_1_img,
    fr_action_2_img = fr_action_2_img,
    fr_action_3_img = fr_action_3_img,
    fr_action_4_img = fr_action_4_img,
    fr_action_5_img = fr_action_5_img,
    fr_action_6_img = fr_action_6_img,
    fr_action_7_img = fr_action_7_img,
    fr_action_8_img = fr_action_8_img,
    fr_action_9_img = fr_action_9_img,
    fr_action_10_img = fr_action_10_img,
    fr_action_11_img = fr_action_11_img,
    fr_action_12_img = fr_action_12_img
}
