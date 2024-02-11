local Gamestate = require("libraries.gamestate")
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local base = require("states.ui.base")
local SID = require("objects.Controllers.LanguageController").lines
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

local baseHeight = math.min(53 * scale, 53)

local buttonLabels = {
    Resume = SID.ui.mainMenu.resume,
    Save = SID.ui.mainMenu.save,
    Load = SID.ui.mainMenu.load,
    Options = SID.ui.mainMenu.options,
    Exit = SID.ui.mainMenu.exit
}

local buttonLabelWidth = 0
local font = baseHeight < 50 and loveframes.font_times_new_normal_large or loveframes.font_times_new_normal_large_48

for _, value in pairs(buttonLabels) do
    buttonLabelWidth = math.max(buttonLabelWidth, font:getWidth(value))
end

local baseWidth = math.max(198 * scale, buttonLabelWidth + 30)

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

local resume = loveframes.Create("button")
resume:SetState(states.STATE_PAUSE_MENU)
resume:SetPos(frMenu.x, frMenu.y)
resume:SetSize(baseWidth, baseHeight)
resume:SetText(buttonLabels.Resume)
resume:SetSkin("StoneKingdoms")
resume.OnClick = function(self)
    loveframes.TogglePause()
end

local save = loveframes.Create("button")
save:SetState(states.STATE_PAUSE_MENU)
save:SetPos(frMenu.x, frMenu.y + baseHeight + 2 * 10 * scale)
save:SetSize(baseWidth, baseHeight)
save:SetText(buttonLabels.Save)
save:SetSkin("StoneKingdoms")
save.OnClick = function(self)
    if _G.BuildController.start then return end
    _G.playSpeech("General_Saving")
    local SaveManager = require("objects.Controllers.SaveManager")
    SaveManager:save()
    loveframes.TogglePause()
end

local options = loveframes.Create("button")
options:SetState(states.STATE_PAUSE_MENU)
options:SetPos(frMenu.x, frMenu.y + baseHeight * 2 + 3 * 10 * scale)
options:SetSize(baseWidth, baseHeight)
options:SetText(buttonLabels.Options)
options:SetSkin("StoneKingdoms")
options.OnClick = function(self)
    loveframes.SetState(states.STATE_SETTINGS)
end

local load = loveframes.Create("button")
load:SetState(states.STATE_PAUSE_MENU)
load:SetPos(frMenu.x, frMenu.y + baseHeight * 3 + 4 * 10 * scale)
load:SetSize(baseWidth, baseHeight)
load:SetText(buttonLabels.Load)
load:SetSkin("StoneKingdoms")
load.OnClick = function(self)
    loveframes.SetState(states.STATE_MAIN_MENU_LOAD_SAVE)
    local SaveManager = require("objects.Controllers.SaveManager")
    SaveManager:updateInterface(true)
end

local exit = loveframes.Create("button")
exit:SetState(states.STATE_PAUSE_MENU)
exit:SetPos(frMenu.x, frMenu.y + baseHeight * 4 + 4 * 10 * scale * 2)
exit:SetSize(baseWidth, baseHeight)
exit:SetText(buttonLabels.Exit)
exit:SetSkin("StoneKingdoms")
exit.OnClick = function(self)
    loveframes.TogglePause()
    if _G.state then _G.state:destroy() end
    local menu = require("states.start_menu")
    Gamestate.switch(menu)
end

return frMenu
