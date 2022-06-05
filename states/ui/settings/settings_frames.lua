local frames = {}

local loveframes = require("libraries.loveframes")
local base = require("states.ui.base")
local w, h = base.w, base.h
local states = require("states.ui.states")

local WINDOW_SCALE = math.round(0.67962962963 * love.graphics.getHeight())
local backgroundImage = love.graphics.newImage("assets/ui/settings_window.png")
local windowBg = loveframes.Create("image")
windowBg:SetState(states.STATE_SETTINGS)
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

local frTitle = {
    x = frWindow.x + 290 * scale,
    y = frWindow.y + 114 * scale,
    width = 949 * scale - 290 * scale,
    height = 150 * scale - 124 * scale
}
frames["frTitle"] = frTitle

local frDescription = {
    x = frWindow.x + 290 * scale,
    y = frWindow.y + 148 * scale,
    width = 949 * scale - 290 * scale,
    height = 178 * scale - 124 * scale
}
frames["frDescription"] = frDescription

local frList = {
    x = frWindow.x + 19 * scale,
    y = frWindow.y + 86 * scale,
    width = 243 * scale,
    height = 347 * scale
}
frames["frList"] = frList

local LIST_ITEM_HEIGHT = 68
local LIST_PADDING = 2
local LIST_ITEM_COUNT = 5
for i = 1, LIST_ITEM_COUNT do
    local frListItem = {
        x = frList.x,
        y = frList.y + (i - 1) * LIST_ITEM_HEIGHT * scale + (i - 1) * LIST_PADDING * scale,
        width = frList.width,
        height = LIST_ITEM_HEIGHT * scale
    }
    frames["frListItem_" .. i] = frListItem
end

local frSubWindow = {
    x = frDescription.x,
    y = frDescription.y + frDescription.height + 20 * scale,
    width = frDescription.width,
    height = 650 * scale - frWindow.y
}
frames["frSubWindow"] = frSubWindow

local SETTINGS_ITEM_HEIGHT = 60
local SETTINGS_PADDING = 30
local LABEL_PADDING_LEFT = 10
local HORIZONTAL_MARGIN = 20
local IMG_SCALE_HEIGHT = 19
local IMG_HAND_HEIGHT = 30

local SETTINGS_ITEM_COUNT = 5
for i = 1, SETTINGS_ITEM_COUNT do
    local frItem = {
        x = frSubWindow.x,
        y = frSubWindow.y + (i - 1) * SETTINGS_ITEM_HEIGHT * scale + (i - 1) * SETTINGS_PADDING * scale,
        width = frSubWindow.width,
        height = LIST_ITEM_HEIGHT * scale
    }
    local LABEL_WIDTH = math.floor(frItem.width / 6)
    frames["frSettingsItem_" .. i] = frItem
    local textHeight = loveframes.font_vera_boldHeight + 2
    local frLabel = {
        x = frItem.x + LABEL_PADDING_LEFT * scale,
        y = frItem.y + (frItem.height / 2) - textHeight / 2,
        width = LABEL_WIDTH,
        height = textHeight
    }
    frames["frSettingsLabel_" .. i] = frLabel
    local frScale = {
        x = frLabel.x + frLabel.width + HORIZONTAL_MARGIN * scale,
        y = frItem.y + (frItem.height / 2) - (IMG_SCALE_HEIGHT * scale) / 2,
        width = frItem.width - HORIZONTAL_MARGIN * scale * 2 - frLabel.width - LABEL_PADDING_LEFT * scale,
        height = IMG_SCALE_HEIGHT * scale
    }
    frames["frSettingsScale_" .. i] = frScale
    local frScaleHand = {
        x = frScale.x,
        y = frItem.y + (frItem.height / 2) - (IMG_HAND_HEIGHT * scale) / 2,
        width = frScale.width,
        height = IMG_HAND_HEIGHT * scale
    }
    frames["frSettingsScaleHand_" .. i] = frScaleHand

end
return {frames, scale}
