local settingsFrames = require("states.ui.settings.settings_frames")
local frames, _ = settingsFrames[1], settingsFrames[2]
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local config = require("config_file")

local function clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end

local elements = {}

local function register(element)
    elements[#elements + 1] = element
end

local rowBackgroundImage = love.graphics.newImage("assets/ui/settings_element_background.png")
local scaleBarImage = love.graphics.newImage("assets/ui/scale_bar.png")

-- SOUND EFFECTS VOLUME

local frElement1 = frames["frSettingsItem_1"]
local rowBackground = loveframes.Create("image")
rowBackground:SetState(states.STATE_SETTINGS)
rowBackground:SetImage(rowBackgroundImage)
rowBackground:SetScaleX(frElement1.width / rowBackground:GetImageWidth())
rowBackground:SetScaleY(frElement1.height / rowBackground:GetImageHeight())
rowBackground:SetPos(frElement1.x, frElement1.y)
rowBackground.disablehover = true
register(rowBackground)

local labelColor = {1, 1, 1}

local frLabel1 = frames["frSettingsLabel_1"]
local soundLabel = loveframes.Create("text")
soundLabel:SetState(states.STATE_SETTINGS)
soundLabel:SetFont(loveframes.font_vera_bold)
soundLabel:SetPos(frLabel1.x, frLabel1.y)
soundLabel:SetText({{
    color = labelColor
}, "Sound volume"})
register(soundLabel)

local frScaleBar1 = frames["frSettingsScale_1"]
local scaleBarSound = loveframes.Create("image")
scaleBarSound:SetState(states.STATE_SETTINGS)
scaleBarSound:SetImage(scaleBarImage)
scaleBarSound:SetScaleX(frScaleBar1.width / scaleBarSound:GetImageWidth())
scaleBarSound:SetScaleY(frScaleBar1.height / scaleBarSound:GetImageHeight())
scaleBarSound:SetPos(frScaleBar1.x, frScaleBar1.y)
scaleBarSound.OnClick = function(self)
    local mx, _ = love.mouse.getPosition()
    self:OnSliderTrigger(mx)
end
scaleBarSound.OnSliderTrigger = function()
end
register(scaleBarSound)

local scaleHandImage = love.graphics.newImage("assets/ui/scale_hand.png")
local scaleHandImageHover = love.graphics.newImage("assets/ui/scale_hand_hover.png")
local scaleHandImageDown = love.graphics.newImage("assets/ui/scale_hand_down.png")
local frScaleHand1 = frames["frSettingsScaleHand_1"]
local scaleHandSoundVolume = loveframes.Create("image")
scaleHandSoundVolume:SetState(states.STATE_SETTINGS)
scaleHandSoundVolume:SetImage(scaleHandImage)
scaleHandSoundVolume:SetScaleY(frScaleHand1.height / scaleHandSoundVolume:GetImageHeight())
scaleHandSoundVolume:SetScaleX(scaleHandSoundVolume:GetScaleY())
scaleHandSoundVolume:SetPos(frScaleHand1.x + frScaleHand1.width - scaleHandSoundVolume:GetImageHeight() / 2,
    frScaleHand1.y)
register(scaleHandSoundVolume)
scaleHandSoundVolume.OnMouseEnter = function(self)
    if not self.isHolding then
        self:SetImage(scaleHandImageHover)
    end
end
scaleHandSoundVolume.OnMouseDown = function(self)
    self.isHolding = true
    self:SetImage(scaleHandImageDown)
end
scaleHandSoundVolume.OnClick = function(self)
    self.isHolding = false
end
scaleHandSoundVolume.Update = function(self, overrideRawValue)
    if not love.mouse.isDown(1) and self.isHolding then
        self:SetImage(scaleHandImage)
        self.isHolding = false
    elseif overrideRawValue then
        local rawValue = overrideRawValue
        local min, max = frScaleHand1.x, frScaleHand1.x + frScaleHand1.width - self:GetImageHeight() / 2
        rawValue = clamp(rawValue, min, max)
        self.value = (rawValue - scaleBarSound.x) / (max - scaleBarSound.x)
        _G.OPTIONS.SFX_VOLUME = self.value
        self:SetX(rawValue, true)
    elseif self.isHolding then
        local min, max = frScaleHand1.x, frScaleHand1.x + frScaleHand1.width - self:GetImageHeight() / 2
        local mx, _ = love.mouse.getPosition()
        local rawValue = clamp(mx, min, max)
        self.value = (rawValue - scaleBarSound.x) / (max - scaleBarSound.x)
        _G.OPTIONS.SFX_VOLUME = self.value
        config.sound.effects = self.value * 100
        self:SetX(rawValue, true)
    end
end
scaleBarSound.OnSliderTrigger = function(self, rawValue)
    scaleHandSoundVolume:Update(rawValue)
end
scaleHandSoundVolume.OnMouseExit = function(self)
    if not self.isHolding then
        self:SetImage(scaleHandImage)
    end
end

local min, max = frScaleHand1.x, frScaleHand1.x + frScaleHand1.width - scaleHandSoundVolume:GetImageHeight() / 2
scaleHandSoundVolume:SetX(clamp(frScaleBar1.x + (frScaleBar1.width * config.sound.effects / 100), min, max))

-- SPEECH VOLUME

local frElement2 = frames["frSettingsItem_2"]
local rowBackground2 = loveframes.Create("image")
rowBackground2:SetState(states.STATE_SETTINGS)
rowBackground2:SetImage(rowBackgroundImage)
rowBackground2:SetScaleX(frElement2.width / rowBackground:GetImageWidth())
rowBackground2:SetScaleY(frElement2.height / rowBackground:GetImageHeight())
rowBackground2:SetPos(frElement2.x, frElement2.y)
rowBackground2.disablehover = true
register(rowBackground2)

local frLabel2 = frames["frSettingsLabel_2"]
local speechLabel = loveframes.Create("text")
speechLabel:SetState(states.STATE_SETTINGS)
speechLabel:SetFont(loveframes.font_vera_bold)
speechLabel:SetPos(frLabel2.x, frLabel2.y)
speechLabel:SetText({{
    color = labelColor
}, "Speech volume"})
register(speechLabel)

local frScaleBar2 = frames["frSettingsScale_2"]
local scaleBarSpeech = loveframes.Create("image")
scaleBarSpeech:SetState(states.STATE_SETTINGS)
scaleBarSpeech:SetImage(scaleBarImage)
scaleBarSpeech:SetScaleX(frScaleBar2.width / scaleBarSpeech:GetImageWidth())
scaleBarSpeech:SetScaleY(frScaleBar2.height / scaleBarSpeech:GetImageHeight())
scaleBarSpeech:SetPos(frScaleBar2.x, frScaleBar2.y)
scaleBarSpeech.OnClick = function(self)
    local mx, _ = love.mouse.getPosition()
    self:OnSliderTrigger(mx)
end
scaleBarSpeech.OnSliderTrigger = function()
end
register(scaleBarSpeech)

local frScaleHand2 = frames["frSettingsScaleHand_2"]
local scaleHandSpeechVolume = loveframes.Create("image")
scaleHandSpeechVolume:SetState(states.STATE_SETTINGS)
scaleHandSpeechVolume:SetImage(scaleHandImage)
scaleHandSpeechVolume:SetScaleY(frScaleHand2.height / scaleHandSpeechVolume:GetImageHeight())
scaleHandSpeechVolume:SetScaleX(scaleHandSpeechVolume:GetScaleY())
scaleHandSpeechVolume:SetPos(frScaleHand2.x, frScaleHand2.y)
scaleHandSpeechVolume:SetPos(frScaleHand2.x + frScaleHand2.width - scaleHandSpeechVolume:GetImageHeight() / 2,
    frScaleHand2.y)
register(scaleHandSpeechVolume)
scaleHandSpeechVolume.OnMouseEnter = function(self)
    if not self.isHolding then
        self:SetImage(scaleHandImageHover)
    end
end
scaleHandSpeechVolume.OnMouseDown = function(self)
    self.isHolding = true
    self:SetImage(scaleHandImageDown)
end
scaleHandSpeechVolume.OnClick = function(self)
    self.isHolding = false
end
scaleHandSpeechVolume.Update = function(self, overrideRawValue)
    if not love.mouse.isDown(1) and self.isHolding then
        self:SetImage(scaleHandImage)
        self.isHolding = false
    elseif overrideRawValue then
        local rawValue = overrideRawValue
        local min, max = frScaleBar2.x, frScaleBar2.x + frScaleBar2.width - self:GetImageHeight() / 2
        rawValue = clamp(rawValue, min, max)
        self.value = (rawValue - scaleBarSpeech.x) / (max - scaleBarSpeech.x)
        _G.OPTIONS.SPEECH_VOLUME = self.value
        self:SetX(rawValue, true)
    elseif self.isHolding then
        local min, max = frScaleBar2.x, frScaleBar2.x + frScaleBar2.width - self:GetImageHeight() / 2
        local mx, _ = love.mouse.getPosition()
        local rawValue = clamp(mx, min, max)
        self.value = (rawValue - scaleBarSpeech.x) / (max - scaleBarSpeech.x)
        _G.OPTIONS.SPEECH_VOLUME = self.value
        config.sound.speech = self.value * 100
        self:SetX(rawValue, true)
    end
end
scaleBarSpeech.OnSliderTrigger = function(self, rawValue)
    scaleHandSpeechVolume:Update(rawValue)
end
scaleHandSpeechVolume.OnMouseExit = function(self)
    if not self.isHolding then
        self:SetImage(scaleHandImage)
    end
end

local min, max = frScaleHand2.x, frScaleHand2.x + frScaleHand2.width - scaleHandSpeechVolume:GetImageHeight() / 2
scaleHandSpeechVolume:SetX(clamp(frScaleBar2.x + (frScaleBar2.width * config.sound.speech / 100), min, max))

-- MUSIC VOLUME

local frElement3 = frames["frSettingsItem_3"]
local rowBackground3 = loveframes.Create("image")
rowBackground3:SetState(states.STATE_SETTINGS)
rowBackground3:SetImage(rowBackgroundImage)
rowBackground3:SetScaleX(frElement3.width / rowBackground:GetImageWidth())
rowBackground3:SetScaleY(frElement3.height / rowBackground:GetImageHeight())
rowBackground3:SetPos(frElement3.x, frElement3.y)
rowBackground3.disablehover = true
register(rowBackground3)

local frLabel3 = frames["frSettingsLabel_3"]
local musicLabel = loveframes.Create("text")
musicLabel:SetState(states.STATE_SETTINGS)
musicLabel:SetFont(loveframes.font_vera_bold)
musicLabel:SetPos(frLabel3.x, frLabel3.y)
musicLabel:SetText({{
    color = labelColor
}, "Music volume"})
register(musicLabel)

local frScaleBar3 = frames["frSettingsScale_3"]
local scaleBarMusic = loveframes.Create("image")
scaleBarMusic:SetState(states.STATE_SETTINGS)
scaleBarMusic:SetImage(scaleBarImage)
scaleBarMusic:SetScaleX(frScaleBar3.width / scaleBarMusic:GetImageWidth())
scaleBarMusic:SetScaleY(frScaleBar3.height / scaleBarMusic:GetImageHeight())
scaleBarMusic:SetPos(frScaleBar3.x, frScaleBar3.y)
scaleBarMusic.OnClick = function(self)
    local mx, _ = love.mouse.getPosition()
    self:OnSliderTrigger(mx)
end
scaleBarMusic.OnSliderTrigger = function()
end
register(scaleBarMusic)

local frScaleHand3 = frames["frSettingsScaleHand_3"]
local scaleHandMusicVolume = loveframes.Create("image")
scaleHandMusicVolume:SetState(states.STATE_SETTINGS)
scaleHandMusicVolume:SetImage(scaleHandImage)
scaleHandMusicVolume:SetScaleY(frScaleHand3.height / scaleHandMusicVolume:GetImageHeight())
scaleHandMusicVolume:SetScaleX(scaleHandMusicVolume:GetScaleY())
scaleHandMusicVolume:SetPos(frScaleHand3.x, frScaleHand3.y)
scaleHandMusicVolume:SetPos(frScaleHand3.x + frScaleHand3.width - scaleHandSpeechVolume:GetImageHeight() / 2,
    frScaleHand3.y)
register(scaleHandMusicVolume)
scaleHandMusicVolume.OnMouseEnter = function(self)
    if not self.isHolding then
        self:SetImage(scaleHandImageHover)
    end
end
scaleHandMusicVolume.OnMouseDown = function(self)
    self.isHolding = true
    self:SetImage(scaleHandImageDown)
end
scaleHandMusicVolume.OnClick = function(self)
    self.isHolding = false
end
scaleHandMusicVolume.Update = function(self, overrideRawValue)
    if not love.mouse.isDown(1) and self.isHolding then
        self:SetImage(scaleHandImage)
        self.isHolding = false
    elseif overrideRawValue then
        local rawValue = overrideRawValue
        local min, max = frScaleHand3.x, frScaleHand3.x + frScaleHand3.width - self:GetImageHeight() / 2
        rawValue = clamp(rawValue, min, max)
        self.value = (rawValue - scaleBarMusic.x) / (max - scaleBarMusic.x)
        _G.OPTIONS.MUSIC_VOLUME = self.value
        self:SetX(rawValue, true)
        if _G.CURRENT_MUSIC then
            _G.CURRENT_MUSIC:setVolume(_G.OPTIONS.MUSIC_VOLUME)
        end
    elseif self.isHolding then
        local min, max = frScaleHand3.x, frScaleHand3.x + frScaleHand3.width - self:GetImageHeight() / 2
        local mx, _ = love.mouse.getPosition()
        local rawValue = clamp(mx, min, max)
        self.value = (rawValue - scaleBarMusic.x) / (max - scaleBarMusic.x)
        _G.OPTIONS.MUSIC_VOLUME = self.value
        config.sound.music = self.value * 100
        self:SetX(rawValue, true)
        if _G.CURRENT_MUSIC then
            _G.CURRENT_MUSIC:setVolume(_G.OPTIONS.MUSIC_VOLUME)
        end
    end
end
scaleBarMusic.OnSliderTrigger = function(self, rawValue)
    scaleHandMusicVolume:Update(rawValue)
end
scaleHandMusicVolume.OnMouseExit = function(self)
    if not self.isHolding then
        self:SetImage(scaleHandImage)
    end
end

local min, max = frScaleHand3.x, frScaleHand3.x + frScaleHand3.width - scaleHandMusicVolume:GetImageHeight() / 2
scaleHandMusicVolume:SetX(clamp(frScaleBar3.x + (frScaleBar3.width * config.sound.music / 100), min ,max))

return elements

