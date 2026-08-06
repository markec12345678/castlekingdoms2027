local actionBar = require('states.ui.ActionBar')
actionBar = actionBar.element
local ACTION_BAR_X_OFFSET = 240
local ACTION_BAR_Y_OFFSET = 134
local ACTION_BAR_WIDTH = 981 - ACTION_BAR_X_OFFSET
local ACTION_BAR_HEIGHT = 193 - ACTION_BAR_Y_OFFSET
local ACTION_BUTTON_WIDTH = 299 - ACTION_BAR_X_OFFSET
local ACTION_BUTTON_SPACING = 3
local scale = actionBar.scalex
local AB_INSIDE_PADDING = 7 * scale

local frFull = {
    x = actionBar:GetX() - actionBar:GetOffsetX() * scale,
    y = actionBar:GetY() - actionBar:GetOffsetY() * scale,
    width = actionBar:GetWidth() * scale,
    height = actionBar:GetHeight() * scale,
    scale = scale
}

local frActionBar = {
    x = frFull.x + ACTION_BAR_X_OFFSET * scale,
    y = frFull.y + ACTION_BAR_Y_OFFSET * scale,
    width = ACTION_BAR_WIDTH * scale,
    height = ACTION_BAR_HEIGHT * scale
}
local frames = {
    frFull = frFull,
    frActionBar = frActionBar
}
for i = 1, 12 do
    local frActionObj = {
        x = frActionBar.x + (ACTION_BUTTON_WIDTH + ACTION_BUTTON_SPACING) * scale * (i - 1),
        y = frActionBar.y,
        width = ACTION_BUTTON_WIDTH * scale,
        height = ACTION_BAR_HEIGHT * scale
    }
    frames["frAction_" .. i .. "Img"] = {
        x = frActionObj.x + AB_INSIDE_PADDING,
        y = frActionObj.y + AB_INSIDE_PADDING,
        width = frActionObj.width - AB_INSIDE_PADDING * 2,
        height = frActionObj.height - AB_INSIDE_PADDING * 2
    }
    frames["frAction_" .. i] = frActionObj
end

return frames
