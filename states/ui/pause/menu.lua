local Gamestate = require("libraries.gamestate")
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local base = require("states.ui.base")
local bitser = require("libraries.bitser")
local w, h = base.w, base.h
local PAUSE_MENU_SCALE = 50
local backgroundImage = love.graphics.newImage("assets/ui/menu_flag.png")

local patternImage = love.graphics.newImage("assets/ui/pause_pattern.png")
local patternBg = loveframes.Create("image")
patternBg:SetState(states.STATE_PAUSE_MENU)
patternBg:SetImage(patternImage)
local scaleY = (h.percent[100]) / (patternImage:getHeight() - 2)
local scaleX = (w.percent[100]) / (patternImage:getWidth() - 2)
patternBg:SetScale(scaleX, scaleY)
patternBg:SetPos(-2, -2)

local menuBg = loveframes.Create("image")
menuBg:SetState(states.STATE_PAUSE_MENU)
menuBg:SetImage(backgroundImage)
menuBg:SetOffsetX(menuBg:GetImageWidth() / 2)
local scale = (h.percent[PAUSE_MENU_SCALE]) / backgroundImage:getHeight()
menuBg:SetScale(scale, scale)
menuBg:SetPos(w.percent[50], 0)

local offsetX, offsetY = 76, 118
local paddingRight, paddingBottom = 70, 150
local frMenu = {
    x = offsetX * scale + menuBg.x - (menuBg:GetImageWidth() / 2) * scale,
    y = offsetY * scale + menuBg.y,
    width = menuBg:GetImageWidth() * scale - offsetX * scale - paddingRight * scale,
    height = menuBg:GetImageHeight() * scale - offsetY * scale - paddingBottom * scale
}

loveframes.TogglePause = function()
    if _G.paused then
        _G.paused = false
        local ActionBar = require("states.ui.ActionBar")
        ActionBar:switchMode()
        loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
    else
        _G.paused = true
        loveframes.SetState(states.STATE_PAUSE_MENU)
    end
end

local resumeImage = love.graphics.newImage("assets/ui/button_resume.png")
local resumeImageHover = love.graphics.newImage("assets/ui/button_resume_hover.png")
local resumeImageDown = love.graphics.newImage("assets/ui/button_resume_down.png")
local resume = loveframes.Create("image")
resume:SetState(states.STATE_PAUSE_MENU)
resume:SetImage(resumeImage)
resume:SetScaleX(frMenu.width / resume:GetImageWidth())
resume:SetScaleY(resume:GetScaleX())
resume:SetPos(frMenu.x, frMenu.y)
resume.OnMouseEnter = function(self)
    self:SetImage(resumeImageHover)
end
resume.OnMouseDown = function(self)
    self:SetImage(resumeImageDown)
end
resume.OnClick = function(self)
    loveframes.TogglePause()
end
resume.OnMouseExit = function(self)
    self:SetImage(resumeImage)
end

local saveImage = love.graphics.newImage("assets/ui/button_save.png")
local saveImageHover = love.graphics.newImage("assets/ui/button_save_hover.png")
local saveImageDown = love.graphics.newImage("assets/ui/button_save_down.png")
local SaveManager = require("objects.Controllers.SaveManager")
local save = loveframes.Create("image")
save:SetState(states.STATE_PAUSE_MENU)
save:SetImage(saveImage)
save:SetScaleX(frMenu.width / save:GetImageWidth())
save:SetScaleY(save:GetScaleX())
save:SetPos(frMenu.x, frMenu.y + saveImage:getHeight() * save:GetScaleX() + 2 * 10 * save:GetScaleX())
save.OnMouseEnter = function(self)
    if _G.state.firstBuildings then return end
    self:SetImage(saveImageHover)
end
save.OnMouseDown = function(self)
    if _G.state.firstBuildings then return end
    self:SetImage(saveImageDown)
end
save.OnClick = function(self)
    if _G.state.firstBuildings then return end
    _G.playSpeech("General_Saving")
    SaveManager:save()
    loveframes.TogglePause()
end
save.OnMouseExit = function(self)
    self:SetImage(saveImage)
end

local optionsImage = love.graphics.newImage("assets/ui/button_options.png")
local optionsImageHover = love.graphics.newImage("assets/ui/button_options_hover.png")
local optionsImageDown = love.graphics.newImage("assets/ui/button_options_down.png")
local options = loveframes.Create("image")
options:SetState(states.STATE_PAUSE_MENU)
options:SetImage(optionsImage)
options:SetScaleX(frMenu.width / options:GetImageWidth())
options:SetScaleY(options:GetScaleX())
options:SetPos(frMenu.x, frMenu.y + optionsImage:getHeight() * options:GetScaleX() * 2 + 3 * 10 * options:GetScaleX())
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

local loadImage = love.graphics.newImage("assets/ui/button_load.png")
local loadImageHover = love.graphics.newImage("assets/ui/button_load_hover.png")
local loadImageDown = love.graphics.newImage("assets/ui/button_load_down.png")
local load = loveframes.Create("image")
load:SetState(states.STATE_PAUSE_MENU)
load:SetImage(loadImage)
load:SetScaleX(frMenu.width / load:GetImageWidth())
load:SetScaleY(load:GetScaleX())
load:SetPos(frMenu.x, frMenu.y + loadImage:getHeight() * load:GetScaleX() * 3 + 4 * 10 * load:GetScaleX())
load.OnMouseEnter = function(self)
    self:SetImage(loadImageHover)
end
load.OnMouseDown = function(self)
    self:SetImage(loadImageDown)
end
load.OnClick = function(self)
    print("loading not implemented fully")
    loveframes.TogglePause()
end
load.OnMouseExit = function(self)
    self:SetImage(loadImage)
end

local exitImage = love.graphics.newImage("assets/ui/button_exit.png")
local exitImageHover = love.graphics.newImage("assets/ui/button_exit_hover.png")
local exitImageDown = love.graphics.newImage("assets/ui/button_exit_down.png")
local exit = loveframes.Create("image")
exit:SetState(states.STATE_PAUSE_MENU)
exit:SetImage(exitImage)
exit:SetScaleX(frMenu.width / exit:GetImageWidth())
exit:SetScaleY(exit:GetScaleX())
exit:SetPos(frMenu.x, frMenu.y + exitImage:getHeight() * exit:GetScaleX() * 4 + 4 * 10 * exit:GetScaleX() * 2)
exit.OnMouseEnter = function(self)
    self:SetImage(exitImageHover)
end
exit.OnMouseDown = function(self)
    self:SetImage(exitImageDown)
end
exit.OnClick = function(self)
    loveframes.TogglePause()
    local menu = require("states.start_menu")
    Gamestate.switch(menu)
end
exit.OnMouseExit = function(self)
    self:SetImage(exitImage)
end

return frMenu
