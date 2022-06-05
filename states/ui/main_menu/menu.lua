local Gamestate = require("libraries.gamestate")
local SaveManager = require("objects.Controllers.SaveManager")
local loveframes = require("libraries.loveframes")
local game = require("states.game")
local base = require("states.ui.base")
local states = require("states.ui.states")
local w, h = base.w, base.h
local MENU_SCALE = 50
local backgroundImage = love.graphics.newImage("assets/ui/menu_flag.png")

local menuBg = loveframes.Create("image")
menuBg:SetState(states.STATE_MAIN_MENU)
menuBg:SetImage(backgroundImage)
menuBg:SetOffsetX(menuBg:GetImageWidth() / 2)
local scale = (h.percent[MENU_SCALE]) / backgroundImage:getHeight()
menuBg:SetScale(scale, scale)
menuBg:SetPos(w.percent[50], 146 * scale)
local SPACING = 20 * scale

local offsetX, offsetY = 76, 130
local paddingRight, paddingBottom = 70, 150
local frMenu = {
    x = offsetX * scale + menuBg.x - (menuBg:GetImageWidth() / 2) * scale,
    y = offsetY * scale + menuBg.y,
    width = menuBg:GetImageWidth() * scale - offsetX * scale - paddingRight * scale,
    height = menuBg:GetImageHeight() * scale - offsetY * scale - paddingBottom * scale
}

local newGameImage = love.graphics.newImage("assets/ui/button_new_game.png")
local newGameImageHover = love.graphics.newImage("assets/ui/button_new_game_hover.png")
local newGameImageDown = love.graphics.newImage("assets/ui/button_new_game_down.png")
local newGame = loveframes.Create("image")
newGame:SetState(states.STATE_MAIN_MENU)
newGame:SetImage(newGameImage)
newGame:SetScaleX(frMenu.width / newGame:GetImageWidth())
newGame:SetScaleY(newGame:GetScaleX())
newGame:SetPos(frMenu.x, frMenu.y)
newGame.OnMouseEnter = function(self)
    self:SetImage(newGameImageHover)
end
newGame.OnMouseDown = function(self)
    self:SetImage(newGameImageDown)
end
newGame.OnClick = function(self)
    _G.playSpeech("General_Loading")
    loveframes.SetState() -- Undraw the menu while loading
    Gamestate.switch(game, SaveManager.defaultMap.name)
end
newGame.OnMouseExit = function(self)
    self:SetImage(newGameImage)
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
    love.event.quit()
end
exit.OnMouseExit = function(self)
    self:SetImage(exitImage)
end

return frMenu
