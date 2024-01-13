local Gamestate = require("libraries.gamestate")
local SaveManager = require("objects.Controllers.SaveManager")
local loveframes = require("libraries.loveframes")
local game = require("states.game")
local base = require("states.ui.base")
local states = require("states.ui.states")
local w, h = base.w, base.h
local MENU_SCALE = 50
local backgroundImage = love.graphics.newImage("assets/ui/menu_flag.png")

local scale = (h.percent[MENU_SCALE]) / backgroundImage:getHeight()
local SPACING = 20 * scale

local offsetX, offsetY = 76, 130
local paddingRight, paddingBottom = 70, 150
local frMenu = {
    x = offsetX * scale + w.percent[50] - (backgroundImage:getWidth() / 2) * scale,
    y = offsetY * scale + 720 * scale,
    width = backgroundImage:getWidth() * scale - offsetX * scale - paddingRight * scale,
    height = backgroundImage:getHeight() * scale - offsetY * scale - paddingBottom * scale
}


local freebuildButtonImage = love.graphics.newImage("assets/ui/freebuild_button.png")
local freebuildButtonImageHover = love.graphics.newImage("assets/ui/freebuild_hover_button.png")
local freebuildButton = loveframes.Create("image")
freebuildButton:SetState(states.STATE_MAIN_MENU)
freebuildButton:SetImage(freebuildButtonImage)
freebuildButton:SetScaleX(frMenu.width / freebuildButton:GetImageWidth())
freebuildButton:SetScaleY(freebuildButton:GetScaleX())
freebuildButton:SetPos(frMenu.x, frMenu.y - freebuildButtonImage:getHeight() * freebuildButton:GetScaleX() - SPACING)
freebuildButton.OnMouseEnter = function(self)
    self:SetImage(freebuildButtonImageHover)
end
freebuildButton.OnClick = function(self)
    loveframes.SetState(states.STATE_FREE_BUILD_WINDOW)
end
freebuildButton.OnMouseExit = function(self)
    self:SetImage(freebuildButtonImage)
end

local campaignButtonImage = love.graphics.newImage("assets/ui/campaign_button.png")
local campaignButtonImageHover = love.graphics.newImage("assets/ui/campaign_hover_button.png")
local campaignButton = loveframes.Create("image")
campaignButton:SetState(states.STATE_MAIN_MENU)
campaignButton:SetImage(campaignButtonImage)
campaignButton:SetScaleX(frMenu.width / campaignButton:GetImageWidth())
campaignButton:SetScaleY(campaignButton:GetScaleX())
campaignButton:SetPos(frMenu.x, frMenu.y)
campaignButton.OnMouseEnter = function(self)
    self:SetImage(campaignButtonImageHover)
end
campaignButton.OnClick = function(self)
    loveframes.SetState(states.STATE_ECONOMIC_MISSION_PICKER)
end
campaignButton.OnMouseExit = function(self)
    self:SetImage(campaignButtonImage)
end

local loadImage = love.graphics.newImage("assets/ui/button_load.png")
local loadImageHover = love.graphics.newImage("assets/ui/button_load_hover.png")
local loadImageDown = love.graphics.newImage("assets/ui/button_load_down.png")
local load = loveframes.Create("image")
load:SetState(states.STATE_MAIN_MENU)
load:SetImage(loadImage)
load:SetScaleX(frMenu.width / load:GetImageWidth())
load:SetScaleY(load:GetScaleX())
load:SetPos(frMenu.x, frMenu.y + loadImage:getHeight() * load:GetScaleX() + SPACING)
load.OnMouseEnter = function(self)
    self:SetImage(loadImageHover)
end
load.OnMouseDown = function(self)
    self:SetImage(loadImageDown)
end
load.OnClick = function(self)
    loveframes.SetState(states.STATE_MAIN_MENU_LOAD_SAVE)
    SaveManager:updateInterface()
end
load.OnMouseExit = function(self)
    self:SetImage(loadImage)
end

local optionsImage = love.graphics.newImage("assets/ui/button_options.png")
local optionsImageHover = love.graphics.newImage("assets/ui/button_options_hover.png")
local optionsImageDown = love.graphics.newImage("assets/ui/button_options_down.png")
local options = loveframes.Create("image")
options:SetState(states.STATE_MAIN_MENU)
options:SetImage(optionsImage)
options:SetScaleX(frMenu.width / options:GetImageWidth())
options:SetScaleY(options:GetScaleX())
options:SetPos(frMenu.x, frMenu.y + optionsImage:getHeight() * options:GetScaleX() * 2 + SPACING * 2)
options.OnMouseEnter = function(self)
    self:SetImage(optionsImageHover)
end
options.OnMouseDown = function(self)
    self:SetImage(optionsImageDown)
end
options.OnClick = function(self)
    loveframes.SetState(states.STATE_SETTINGS)
end
options.OnMouseExit = function(self)
    self:SetImage(optionsImage)
end

local exitImage = love.graphics.newImage("assets/ui/button_exit.png")
local exitImageHover = love.graphics.newImage("assets/ui/button_exit_hover.png")
local exitImageDown = love.graphics.newImage("assets/ui/button_exit_down.png")
local exit = loveframes.Create("image")
exit:SetState(states.STATE_MAIN_MENU)
exit:SetImage(exitImage)
exit:SetScaleX(frMenu.width / exit:GetImageWidth())
exit:SetScaleY(exit:GetScaleX())
exit:SetPos(frMenu.x, frMenu.y + exitImage:getHeight() * exit:GetScaleX() * 3 + SPACING * 5)
exit.OnMouseEnter = function(self)
    self:SetImage(exitImageHover)
end
exit.OnMouseDown = function(self)
    self:SetImage(exitImageDown)
end
exit.OnClick = function(self)
    love.event.quit("quit", 0)
end
exit.OnMouseExit = function(self)
    self:SetImage(exitImage)
end

return frMenu
