local loveframes = require('libraries.loveframes')
local states = require('states.ui.states')
local base = require('states.ui.base')
local bitser = require("libraries.bitser")
local w, h = base.w, base.h
local PAUSE_MENU_SCALE = 50
local background_image = love.graphics.newImage("assets/ui/menu_flag.png")

local pattern_image = love.graphics.newImage("assets/ui/pause_pattern.png")
local pattern_bg = loveframes.Create("image")
pattern_bg:SetState(states.STATE_PAUSE_MENU)
pattern_bg:SetImage(pattern_image)
local scale_y = (h.percent[100]) / (pattern_image:getHeight() - 2)
local scale_x = (w.percent[100]) / (pattern_image:getWidth() - 2)
pattern_bg:SetScale(scale_x, scale_y)
pattern_bg:SetPos(-2, -2)

local menu_bg = loveframes.Create("image")
menu_bg:SetState(states.STATE_PAUSE_MENU)
menu_bg:SetImage(background_image)
menu_bg:SetOffsetX(menu_bg:GetImageWidth() / 2)
local scale = (h.percent[PAUSE_MENU_SCALE]) / background_image:getHeight()
menu_bg:SetScale(scale, scale)
menu_bg:SetPos(w.percent[50], 0)

local offset_x, offset_y = 76, 118
local padding_right, padding_bottom = 70, 150
local fr_menu = {
    x = offset_x * scale + menu_bg.x - (menu_bg:GetImageWidth() / 2) * scale,
    y = offset_y * scale + menu_bg.y,
    width = menu_bg:GetImageWidth() * scale - offset_x * scale - padding_right * scale,
    height = menu_bg:GetImageHeight() * scale - offset_y * scale - padding_bottom * scale
}

loveframes.TogglePause = function()
    if _G.paused then
        _G.paused = false
        loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
    else
        _G.paused = true
        loveframes.SetState(states.STATE_PAUSE_MENU)
    end
end

local resume_image = love.graphics.newImage("assets/ui/button_resume.png")
local resume_image_hover = love.graphics.newImage("assets/ui/button_resume_hover.png")
local resume_image_down = love.graphics.newImage("assets/ui/button_resume_down.png")
local resume = loveframes.Create("image")
resume:SetState(states.STATE_PAUSE_MENU)
resume:SetImage(resume_image)
resume:SetScaleX(fr_menu.width / resume:GetImageWidth())
resume:SetScaleY(resume:GetScaleX())
resume:SetPos(fr_menu.x, fr_menu.y)
resume.OnMouseEnter = function(self)
    self:SetImage(resume_image_hover)
end
resume.OnMouseDown = function(self)
    self:SetImage(resume_image_down)
end
resume.OnClick = function(self)
    loveframes.TogglePause()
end
resume.OnMouseExit = function(self)
    self:SetImage(resume_image)
end

local save_image = love.graphics.newImage("assets/ui/button_save.png")
local save_image_hover = love.graphics.newImage("assets/ui/button_save_hover.png")
local save_image_down = love.graphics.newImage("assets/ui/button_save_down.png")
local save = loveframes.Create("image")
save:SetState(states.STATE_PAUSE_MENU)
save:SetImage(save_image)
save:SetScaleX(fr_menu.width / save:GetImageWidth())
save:SetScaleY(save:GetScaleX())
save:SetPos(fr_menu.x, fr_menu.y + save_image:getHeight() * save:GetScaleX() + 2 * 10 * save:GetScaleX())
save.OnMouseEnter = function(self)
    self:SetImage(save_image_hover)
end
save.OnMouseDown = function(self)
    self:SetImage(save_image_down)
end
save.OnClick = function(self)
    print("Saving game..")
    local state = _G.state:save("status.bin")
    bitser.dumpLoveFile("status.bin", state)
    loveframes.TogglePause()
end
save.OnMouseExit = function(self)
    self:SetImage(save_image)
end

local options_image = love.graphics.newImage("assets/ui/button_options.png")
local options_image_hover = love.graphics.newImage("assets/ui/button_options_hover.png")
local options_image_down = love.graphics.newImage("assets/ui/button_options_down.png")
local options = loveframes.Create("image")
options:SetState(states.STATE_PAUSE_MENU)
options:SetImage(options_image)
options:SetScaleX(fr_menu.width / options:GetImageWidth())
options:SetScaleY(options:GetScaleX())
options:SetPos(fr_menu.x, fr_menu.y + options_image:getHeight() * options:GetScaleX() * 2 + 3 * 10 * options:GetScaleX())
options.OnMouseEnter = function(self)
    self:SetImage(options_image_hover)
end
options.OnMouseDown = function(self)
    self:SetImage(options_image_down)
end
options.OnClick = function(self)
    print("click")
end
options.OnMouseExit = function(self)
    self:SetImage(options_image)
end

local load_image = love.graphics.newImage("assets/ui/button_load.png")
local load_image_hover = love.graphics.newImage("assets/ui/button_load_hover.png")
local load_image_down = love.graphics.newImage("assets/ui/button_load_down.png")
local load = loveframes.Create("image")
load:SetState(states.STATE_PAUSE_MENU)
load:SetImage(load_image)
load:SetScaleX(fr_menu.width / load:GetImageWidth())
load:SetScaleY(load:GetScaleX())
load:SetPos(fr_menu.x, fr_menu.y + load_image:getHeight() * load:GetScaleX() * 3 + 4 * 10 * load:GetScaleX())
load.OnMouseEnter = function(self)
    self:SetImage(load_image_hover)
end
load.OnMouseDown = function(self)
    self:SetImage(load_image_down)
end
load.OnClick = function(self)
    print("loading not implemented fully")
    loveframes.TogglePause()
end
load.OnMouseExit = function(self)
    self:SetImage(load_image)
end

local exit_image = love.graphics.newImage("assets/ui/button_exit.png")
local exit_image_hover = love.graphics.newImage("assets/ui/button_exit_hover.png")
local exit_image_down = love.graphics.newImage("assets/ui/button_exit_down.png")
local exit = loveframes.Create("image")
exit:SetState(states.STATE_PAUSE_MENU)
exit:SetImage(exit_image)
exit:SetScaleX(fr_menu.width / exit:GetImageWidth())
exit:SetScaleY(exit:GetScaleX())
exit:SetPos(fr_menu.x, fr_menu.y + exit_image:getHeight() * exit:GetScaleX() * 4 + 4 * 10 * exit:GetScaleX() * 2)
exit.OnMouseEnter = function(self)
    self:SetImage(exit_image_hover)
end
exit.OnMouseDown = function(self)
    self:SetImage(exit_image_down)
end
exit.OnClick = function(self)
    love.event.quit()
end
exit.OnMouseExit = function(self)
    self:SetImage(exit_image)
end

return fr_menu
