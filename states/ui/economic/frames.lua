local frames = {}

local loveframes = require("libraries.loveframes")
local base = require("states.ui.base")
local w, h = base.w, base.h
local states = require("states.ui.states")

local patternImage = love.graphics.newImage("assets/ui/pause_pattern.png")
local patternBg = loveframes.Create("image")
patternBg:SetState(states.STATE_ECONOMIC_MISSION_PICKER)
patternBg:SetImage(patternImage)
local scaleY = (h.percent[100]) / (patternImage:getHeight() - 2)
local scaleX = (w.percent[100]) / (patternImage:getWidth() - 2)
patternBg:SetScale(scaleX, scaleY)
patternBg:SetPos(-2, -2)
patternBg.disablehover = true

local WINDOW_SCALE = math.round(0.67962962963 * love.graphics.getHeight())
local backgroundImage = love.graphics.newImage("assets/ui/economic_missions/window.png")
local windowBg = loveframes.Create("image")
windowBg:SetState(states.STATE_ECONOMIC_MISSION_PICKER)
windowBg:SetImage(backgroundImage)
windowBg:SetOffsetX(windowBg:GetImageWidth() / 2)
windowBg:SetOffsetY(windowBg:GetImageHeight() / 2)
local scale = WINDOW_SCALE / backgroundImage:getHeight()
windowBg:SetScale(scale, scale)
windowBg:SetPos(w.percent[50], h.percent[50])
windowBg.disablehover = true

local frWindow = {
    x = windowBg.x - (windowBg:GetImageWidth() / 2) * scale,
    y = windowBg.y - (windowBg:GetImageHeight() / 2) * scale,
    width = windowBg:GetImageWidth() * scale,
    height = windowBg:GetImageHeight() * scale
}
frames["frWindow"] = frWindow

local frStart = {
    x = frWindow.x + 829 * scale,
    y = frWindow.y + 635 * scale,
    width = 120 * scale,
    height = 45 * scale
}
frames["frStart"] = frStart

local frTitle = {
    x = frWindow.x + 290 * scale,
    y = frWindow.y + 64 * scale,
    width = 949 * scale - 290 * scale,
    height = 150 * scale - 124 * scale
}
frames["frTitle"] = frTitle

local frDescription = {
    x = frWindow.x + 332 * scale,
    y = frWindow.y + 160 * scale,
    width = 920 * scale - 332 * scale,
    height = 120 * scale
}
frames["frDescription"] = frDescription

local frList = {
    x = frWindow.x + 19 * scale,
    y = frWindow.y + 86 * scale,
    width = 253 * scale,
    height = 347 * scale
}
frames["frList"] = frList

local LIST_ITEM_HEIGHT = 58
local LIST_PADDING = -14
local LIST_ITEM_COUNT = 12
for i = 1, LIST_ITEM_COUNT do
    local frListItem = {
        x = frList.x,
        y = frList.y + (i - 1) * LIST_ITEM_HEIGHT * scale + (i - 1) * LIST_PADDING * scale,
        width = frList.width,
        height = LIST_ITEM_HEIGHT * scale
    }
    frames["frListItem_" .. i] = frListItem
end

return { frames, scale }
