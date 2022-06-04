local frames = {}
local SaveManager = require("objects.Controllers.SaveManager")
local loveframes = require("libraries.loveframes")
local base = require("states.ui.base")
local states = require("states.ui.states")
local w, h = base.w, base.h
local WINDOW_SCALE = math.round(0.56574074074 * love.graphics.getHeight())
local backgroundImage = love.graphics.newImage("assets/ui/load_game_window.png")
local LoadListItem = require("states.ui.LoadListItem")

local patternImage = love.graphics.newImage("assets/ui/pause_pattern.png")
local patternBg = loveframes.Create("image")
patternBg:SetState(states.STATE_MAIN_MENU_LOAD_SAVE)
patternBg:SetImage(patternImage)
local scaleY = (h.percent[100]) / (patternImage:getHeight() - 2)
local scaleX = (w.percent[100]) / (patternImage:getWidth() - 2)
patternBg:SetScale(scaleX, scaleY)
patternBg:SetPos(-2, -2)

local windowBg = loveframes.Create("image")
windowBg:SetState(states.STATE_MAIN_MENU_LOAD_SAVE)
windowBg:SetImage(backgroundImage)
windowBg:SetOffsetX(windowBg:GetImageWidth() / 2)
windowBg:SetOffsetY(windowBg:GetImageHeight() / 2)
local scale = WINDOW_SCALE / backgroundImage:getHeight()
windowBg:SetScale(scale, scale)
windowBg:SetPos(w.percent[50], h.percent[50])

local frWindow = {
    x = windowBg.x - (windowBg:GetImageWidth() / 2) * scale,
    y = windowBg.y - (windowBg:GetImageHeight() / 2) * scale,
    width = windowBg:GetImageWidth() * scale,
    height = windowBg:GetImageHeight() * scale
}
frames["frWindow"] = frWindow

local frList = {
    x = frWindow.x + 27 * scale,
    y = frWindow.y + 137 * scale,
    width = 648 * scale,
    height = 448 * scale
}
frames["frList"] = frList

local LIST_PADDING = 2
local LIST_ITEM_HEIGHT = 56
local LIST_ITEM_COUNT_PER_PAGE = 8
for i = 1, LIST_ITEM_COUNT_PER_PAGE do
    local frListItem = {
        x = frList.x - LIST_PADDING * scale,
        y = frList.y + (i - 1) * LIST_ITEM_HEIGHT * scale,
        width = frList.width + LIST_PADDING * 2 * scale,
        height = LIST_ITEM_HEIGHT * scale
    }
    frames["frListItem_" .. i] = frListItem
    local textHeight = loveframes.font_vera_boldHeight + 2
    local frColumnSaveName = {
        x = frList.x + 15 * scale,
        y = frListItem.y + (frListItem.height / 2) - textHeight / 2,
        width = 321 * scale - 15 * scale,
        height = textHeight
    }
    frames["frColumnSaveName_" .. i] = frColumnSaveName

    local frColumnMap = {
        x = frList.x + 339 * scale,
        y = frListItem.y + (frListItem.height / 2) - textHeight / 2,
        width = 75 * scale,
        height = textHeight
    }
    frames["frColumnMap_" .. i] = frColumnMap

    local frColumnDate = {
        x = frList.x + 433 * scale,
        y = frListItem.y + (frListItem.height / 2) - textHeight,
        width = 95 * scale,
        height = textHeight * 2
    }
    frames["frColumnDate_" .. i] = frColumnDate

    local frColumnVersion = {
        x = frList.x + 550 * scale,
        y = frListItem.y + (frListItem.height / 2) - textHeight / 2,
        width = 93 * scale,
        height = textHeight
    }
    local DELETE_BUTTON_WIDTH = 26
    frames["frColumnVersion_" .. i] = frColumnVersion
    local frColumnDelete = {
        x = frColumnVersion.x + frColumnVersion.width - DELETE_BUTTON_WIDTH * scale,
        y = frColumnVersion.y - frColumnVersion.height / 2,
        width = DELETE_BUTTON_WIDTH * scale,
        height = frColumnVersion.height * 2
    }
    frames["frColumnDelete" .. i] = frColumnDelete
    local item = LoadListItem:new(i, states.STATE_MAIN_MENU_LOAD_SAVE, frListItem, frColumnSaveName, frColumnMap,
        frColumnDate, frColumnVersion, frColumnDelete)
    SaveManager:registerListItem(item, i)
end
local closeWindowButtonImage = love.graphics.newImage("assets/ui/close_window_normal.png")
local closeWindowButtonImageHover = love.graphics.newImage("assets/ui/close_window_hover.png")
local closeWindowButtonImageDown = love.graphics.newImage("assets/ui/close_window_down.png")

local frCloseButton = {
    x = frWindow.x + 637 * scale,
    y = frWindow.y + 35 * scale,
    width = closeWindowButtonImage:getWidth() * scale,
    height = closeWindowButtonImage:getHeight() * scale
}

local closeWindowButton = loveframes.Create("image", windowBg)
closeWindowButton:SetState(states.STATE_MAIN_MENU_LOAD_SAVE)
closeWindowButton:SetImage(closeWindowButtonImage)
closeWindowButton:SetScaleX(frCloseButton.width / closeWindowButton:GetImageWidth())
closeWindowButton:SetScaleY(closeWindowButton:GetScaleX())
closeWindowButton:SetPos(frCloseButton.x, frCloseButton.y)
closeWindowButton.OnMouseEnter = function(self)
    self:SetImage(closeWindowButtonImageHover)
end
closeWindowButton.OnMouseDown = function(self)
    self:SetImage(closeWindowButtonImageDown)
end
closeWindowButton.OnClick = function(self)
    loveframes.SetState(states.STATE_MAIN_MENU)
end
closeWindowButton.OnMouseExit = function(self)
    self:SetImage(closeWindowButtonImage)
end

return frames
