local settingsFrames = require("states.ui.settings.settings_frames")
local frames, scale = settingsFrames[1], settingsFrames[2]
local SettingsWindow = require("states.ui.settings.SettingsWindow")
local loveframes = require("libraries.loveframes")
local base = require("states.ui.base")
local states = require("states.ui.states")
local config = require("config_file")
local w, h = base.w, base.h

local patternImage = love.graphics.newImage("assets/ui/pause_pattern.png")
local patternBg = loveframes.Create("image")
patternBg:SetState(states.STATE_SETTINGS)
patternBg:SetImage(patternImage)
local scaleY = (h.percent[100]) / (patternImage:getHeight() - 2)
local scaleX = (w.percent[100]) / (patternImage:getWidth() - 2)
patternBg:SetScale(scaleX, scaleY)
patternBg:SetPos(-2, -2)
patternBg.disablehover = true

local titleText = loveframes.Create("text")
titleText:SetState(states.STATE_SETTINGS)
titleText:SetFont(loveframes.font_vera_bold_large)
titleText:SetShadow(true)
titleText:SetPos(frames["frTitle"].x, frames["frTitle"].y)
titleText:SetShadowColor(0.35, 0.3, 0.26, 1)

local descriptionText = loveframes.Create("text")
descriptionText:SetState(states.STATE_SETTINGS)
descriptionText:SetFont(loveframes.font_vera_bold)
descriptionText:SetPos(frames["frDescription"].x, frames["frDescription"].y)
descriptionText:SetShadow(true)
descriptionText:SetMaxWidth(frames["frDescription"].width)
descriptionText:SetShadowColor(0, 0, 0, 1)

SettingsWindow:addTitleElements(frames, titleText, descriptionText)

local frSound = frames["frListItem_1"]
local soundButtonImage = love.graphics.newImage("assets/ui/sound_button.png")
local soundButtonImageHover = love.graphics.newImage("assets/ui/settings_element_hover.png")
local soundButtonImageDown = love.graphics.newImage("assets/ui/sound_button.png")
local soundButton = loveframes.Create("image")
soundButton:SetState(states.STATE_SETTINGS)
soundButton:SetImage(soundButtonImage)
soundButton:SetScaleX(frSound.width / soundButton:GetImageWidth())
soundButton:SetScaleY(soundButton:GetScaleX())
soundButton:SetPos(frSound.x, frSound.y)
soundButton.OnMouseEnter = function(self)
    self:SetImage(soundButtonImageHover)
end
soundButton.OnMouseDown = function(self)
    self:SetImage(soundButtonImageDown)
end
soundButton.OnClick = function(self)
    SettingsWindow:switch("sound")
end
soundButton.OnMouseExit = function(self)
    self:SetImage(soundButtonImage)
end

local frGraphics = frames["frListItem_2"]
local graphicsButtonImage = love.graphics.newImage("assets/ui/graphics_button.png")
local graphicsButtonImageHover = love.graphics.newImage("assets/ui/settings_element_hover.png")
local graphicsButtonImageDown = love.graphics.newImage("assets/ui/graphics_button.png")
local graphicsButton = loveframes.Create("image")
graphicsButton:SetState(states.STATE_SETTINGS)
graphicsButton:SetImage(graphicsButtonImage)
graphicsButton:SetScaleX(frGraphics.width / graphicsButton:GetImageWidth())
graphicsButton:SetScaleY(graphicsButton:GetScaleX())
graphicsButton:SetPos(frGraphics.x, frGraphics.y)
graphicsButton.OnMouseEnter = function(self)
    self:SetImage(graphicsButtonImageHover)
end
graphicsButton.OnMouseDown = function(self)
    self:SetImage(graphicsButtonImageDown)
end
graphicsButton.OnClick = function(self)
    SettingsWindow:switch("graphics")
end
graphicsButton.OnMouseExit = function(self)
    self:SetImage(graphicsButtonImage)
end

local frHotkeys = frames["frListItem_3"]
local hotkeysButtonImage = love.graphics.newImage("assets/ui/hotkeys_button.png")
local hotkeysButtonImageHover = love.graphics.newImage("assets/ui/settings_element_hover.png")
local hotkeysButtonImageDown = love.graphics.newImage("assets/ui/hotkeys_button.png")
local hotkeysButton = loveframes.Create("image")
hotkeysButton:SetState(states.STATE_SETTINGS)
hotkeysButton:SetImage(hotkeysButtonImage)
hotkeysButton:SetScaleX(frHotkeys.width / hotkeysButton:GetImageWidth())
hotkeysButton:SetScaleY(hotkeysButton:GetScaleX())
hotkeysButton:SetPos(frHotkeys.x, frHotkeys.y)
hotkeysButton.OnMouseEnter = function(self)
    self:SetImage(hotkeysButtonImageHover)
end
hotkeysButton.OnMouseDown = function(self)
    self:SetImage(hotkeysButtonImageDown)
end
hotkeysButton.OnClick = function(self)
    SettingsWindow:switch("hotkeys")
end
hotkeysButton.OnMouseExit = function(self)
    self:SetImage(hotkeysButtonImage)
end

local frVideo = frames["frListItem_4"]
local videoButtonImage = love.graphics.newImage("assets/ui/video_button.png")
local videoButtonImageHover = love.graphics.newImage("assets/ui/settings_element_hover.png")
local videoButtonImageDown = love.graphics.newImage("assets/ui/video_button.png")
local videoButton = loveframes.Create("image")
videoButton:SetState(states.STATE_SETTINGS)
videoButton:SetImage(videoButtonImage)
videoButton:SetScaleX(frVideo.width / videoButton:GetImageWidth())
videoButton:SetScaleY(videoButton:GetScaleX())
videoButton:SetPos(frVideo.x, frVideo.y)
videoButton.OnMouseEnter = function(self)
    self:SetImage(videoButtonImageHover)
end
videoButton.OnMouseDown = function(self)
    self:SetImage(videoButtonImageDown)
end
videoButton.OnClick = function(self)
    SettingsWindow:switch("video")
end
videoButton.OnMouseExit = function(self)
    self:SetImage(videoButtonImage)
end

local frInterface = frames["frListItem_5"]
local interfaceButtonImage = love.graphics.newImage("assets/ui/interface_button.png")
local interfaceButtonImageHover = love.graphics.newImage("assets/ui/settings_element_hover.png")
local interfaceButtonImageDown = love.graphics.newImage("assets/ui/interface_button.png")
local interfaceButton = loveframes.Create("image")
interfaceButton:SetState(states.STATE_SETTINGS)
interfaceButton:SetImage(interfaceButtonImage)
interfaceButton:SetScaleX(frInterface.width / interfaceButton:GetImageWidth())
interfaceButton:SetScaleY(interfaceButton:GetScaleX())
interfaceButton:SetPos(frInterface.x, frInterface.y)
interfaceButton.OnMouseEnter = function(self)
    self:SetImage(interfaceButtonImageHover)
end
interfaceButton.OnMouseDown = function(self)
    self:SetImage(interfaceButtonImageDown)
end
interfaceButton.OnClick = function(self)
    SettingsWindow:switch("interface")
end
interfaceButton.OnMouseExit = function(self)
    self:SetImage(interfaceButtonImage)
end

local closeWindowButtonImage = love.graphics.newImage("assets/ui/close_window_normal.png")
local closeWindowButtonImageHover = love.graphics.newImage("assets/ui/close_window_hover.png")
local closeWindowButtonImageDown = love.graphics.newImage("assets/ui/close_window_down.png")

local frCloseButton = {
    x = frames["frWindow"].x + 957 * scale,
    y = frames["frWindow"].y + 34 * scale,
    width = closeWindowButtonImage:getWidth() * scale,
    height = closeWindowButtonImage:getHeight() * scale
}
-- frames["frCloseButton"] = frCloseButton

local closeWindowButton = loveframes.Create("image")
closeWindowButton:SetState(states.STATE_SETTINGS)
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
closeWindowButton.Update = function(self)
    if love.keyboard.isDown("escape") then
        self:OnClick()
    end
end
closeWindowButton.OnClick = function(self)
    local Gamestate = require("libraries.gamestate")
    config:save(config)
    if Gamestate.current() == require("states.start_menu") then
        loveframes.SetState(states.STATE_MAIN_MENU)
    elseif Gamestate.current() == require("states.game") then
        loveframes.SetState(states.STATE_PAUSE_MENU)
    end
end
closeWindowButton.OnMouseExit = function(self)
    self:SetImage(closeWindowButtonImage)
end

SettingsWindow:switch("sound")

return frames
