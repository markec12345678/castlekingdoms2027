local settingsFrames = require("states.ui.settings.settings_frames")
local frames, _ = settingsFrames[1], settingsFrames[2]
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")

local widgetAlignment = {
    LEFT = 0,
    RIGHT = -1
}

local images = {
    rowBackground = love.graphics.newImage("assets/ui/settings_element_background.png"),
    scaleBar = love.graphics.newImage("assets/ui/scale_bar.png"),

    button = love.graphics.newImage("assets/ui/button.png"),
    buttonHover = love.graphics.newImage("assets/ui/button_hover.png"),
    buttonDown = love.graphics.newImage("assets/ui/button.png"),

    scaleHand = love.graphics.newImage("assets/ui/scale_hand.png"),
    scaleHandHover = love.graphics.newImage("assets/ui/scale_hand_hover.png"),
    scaleHandDown = love.graphics.newImage("assets/ui/scale_hand_down.png")
}

local function clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end

local function register(elements, element)
    elements[#elements + 1] = element
end

-- SLIDER WIDGET

local function addSlider(elements, index, label, defaultValue, useBackground, cb)
    local settingFrame = frames["frSettingsItem_" .. index]
    if useBackground then
        local rowBackground = loveframes.Create("image")
        rowBackground:SetState(states.STATE_SETTINGS)
        rowBackground:SetImage(images.rowBackground)
        rowBackground:SetScaleX(settingFrame.width / rowBackground:GetImageWidth())
        rowBackground:SetScaleY(settingFrame.height / rowBackground:GetImageHeight())
        rowBackground:SetPos(settingFrame.x, settingFrame.y)
        rowBackground.disablehover = true
        register(elements, rowBackground)
    end
    
    local labelColor = {1, 1, 1}
    
    local frLabel = frames["frSettingsLabel_" .. index]
    local sliderLabel = loveframes.Create("text")
    sliderLabel:SetState(states.STATE_SETTINGS)
    sliderLabel:SetFont(loveframes.font_vera_bold)
    sliderLabel:SetPos(frLabel.x, frLabel.y)
    sliderLabel:SetText({{
        color = labelColor
    }, label})
    register(elements, sliderLabel)
    
    local frScaleBar = frames["frSettingsScale_" .. index]
    local sliderScaleBar = loveframes.Create("image")
    sliderScaleBar:SetState(states.STATE_SETTINGS)
    sliderScaleBar:SetImage(images.scaleBar)
    sliderScaleBar:SetScaleX(frScaleBar.width / sliderScaleBar:GetImageWidth())
    sliderScaleBar:SetScaleY(frScaleBar.height / sliderScaleBar:GetImageHeight())
    sliderScaleBar:SetPos(frScaleBar.x, frScaleBar.y)
    sliderScaleBar.OnClick = function(self)
        local mx, _ = love.mouse.getPosition()
        self:OnSliderTrigger(mx)
    end
    sliderScaleBar.OnSliderTrigger = function()
    end
    register(elements, sliderScaleBar)

    local frScaleHand = frames["frSettingsScaleHand_" .. index]
    local scaleHandValue = loveframes.Create("image")
    
    scaleHandValue:SetState(states.STATE_SETTINGS)
    scaleHandValue:SetImage(images.scaleHand)
    scaleHandValue:SetScaleY(frScaleHand.height / scaleHandValue:GetImageHeight())
    scaleHandValue:SetScaleX(scaleHandValue:GetScaleY())
    
    local min, max = frScaleHand.x, frScaleHand.x + frScaleHand.width - scaleHandValue:GetImageHeight() / 2
    local initialX = clamp(frScaleBar.x + (frScaleBar.width * defaultValue / 100), min, max)
    scaleHandValue:SetPos(initialX, frScaleHand.y)
    scaleHandValue:SetX(initialX, false)
    register(elements, scaleHandValue)

    local sliderValueLabelY = scaleHandValue.y + (scaleHandValue.height * scaleHandValue:GetScaleY()) + scaleHandValue:GetScaleY()

    local sliderValueLabel = loveframes.Create("text")
    sliderValueLabel:SetState(states.STATE_SETTINGS)
    sliderValueLabel:SetFont(loveframes.font_vera_bold)
    sliderValueLabel:SetPos(initialX - (sliderValueLabel.width / 2), sliderValueLabelY)
    sliderValueLabel:SetText({{
        color = labelColor
    }, defaultValue .. "%"})
    sliderValueLabel:SetX((scaleHandValue.x + ((scaleHandValue.width * scaleHandValue:GetScaleX()) / 2)) - (sliderValueLabel.width / 2), false)
    register(elements, sliderValueLabel)

    scaleHandValue.OnMouseEnter = function(self)
        if not self.isHolding then
            self:SetImage(images.scaleHandHover)
        end
    end
    scaleHandValue.OnMouseDown = function(self)
        self.isHolding = true
        self:SetImage(images.scaleHandDown)
    end
    scaleHandValue.OnClick = function(self)
        self.isHolding = false
    end
    scaleHandValue.Update = function(self, overrideRawValue)
        if not love.mouse.isDown(1) and self.isHolding then
            self:SetImage(images.scaleHand)
            self.isHolding = false
        elseif overrideRawValue then
            local rawValue = overrideRawValue
            rawValue = clamp(rawValue, min, max)
            self:SetX(rawValue, false)
            self.value = math.floor(((rawValue - sliderScaleBar.x) / (max - sliderScaleBar.x)) * 100) / 100
            sliderValueLabel:SetText({{
                color = labelColor
            }, (self.value * 100) .. "%"})
            sliderValueLabel:SetX((self.x + ((self.width * self:GetScaleX()) / 2)) - (sliderValueLabel.width / 2), false)
            cb(self.value)
        elseif self.isHolding then
            local mx, _ = love.mouse.getPosition()
            local rawValue = clamp(mx, min, max)
            self:SetX(rawValue, false)
            self.value = math.floor(((rawValue - sliderScaleBar.x) / (max - sliderScaleBar.x)) * 100) / 100
            sliderValueLabel:SetText({{
                color = labelColor
            }, (self.value * 100) .. "%"})
            sliderValueLabel:SetX((self.x + ((self.width * self:GetScaleX()) / 2)) - (sliderValueLabel.width / 2), false)
            cb(self.value)
        end
    end
    sliderScaleBar.OnSliderTrigger = function(self, rawValue)
        scaleHandValue:Update(rawValue)
    end
    scaleHandValue.OnMouseExit = function(self)
        if not self.isHolding then
            self:SetImage(images.scaleHand)
        end
    end
end

-- BUTTON WIDGET

local function addButton(elements, index, buttonLabel, alignment, useBackground, cb)
    local buttonWidth = images.button:getWidth()
    local buttonHeight = images.button:getHeight()

    local xscale = 0.7
    local yscale = 0.7

    local settingFrame = frames["frSettingsItem_" .. index]

    local xoffset = 0
    local xpadding = 0

    local rowBackground = loveframes.Create("image")
    rowBackground:SetState(states.STATE_SETTINGS)
    rowBackground:SetImage(images.rowBackground)

    if useBackground then
        xpadding = 10
        rowBackground:SetScaleX(settingFrame.width / rowBackground:GetImageWidth())
        rowBackground:SetScaleY(settingFrame.height / rowBackground:GetImageHeight())
        rowBackground:SetPos(settingFrame.x, settingFrame.y)
        rowBackground.disablehover = true
        register(elements, rowBackground)
    end
    
    local button = {
        back = nil,
        label = nil
    }

    local textWidth = loveframes.font_vera_bold:getWidth(buttonLabel)
    local textHeight = loveframes.font_vera_bold:getHeight()

    local labelColor = {1, 1, 1}
    local bw = buttonWidth * xscale
    local bh = buttonHeight * yscale

    if alignment == widgetAlignment.RIGHT then
        xoffset = settingFrame.width - bw - xpadding
    else
        xoffset = xpadding
    end

    button.back = loveframes.Create("image")
    button.back:SetState(states.STATE_SETTINGS)
    button.back:SetImage(images.button)
    button.back:SetScaleX(xscale)
    button.back:SetScaleY(yscale)

    button.back:SetPos(settingFrame.x + xoffset, (settingFrame.y + (settingFrame.height - bh) / 2))
    button.back.OnMouseEnter = function(self) self:SetImage(images.buttonHover) end
    button.back.OnMouseDown = function(self) self:SetImage(images.buttonDown) end
    button.back.OnMouseExit = function(self) self:SetImage(images.button) end
    button.back.OnClick = cb
    register(elements, button.back)

    button.label = loveframes.Create("text", button.back)
    button.label:SetState(states.STATE_SETTINGS)
    button.label.disablehover = true
    button.label:SetFont(loveframes.font_vera_bold)
    button.label:SetPos(settingFrame.x + xoffset + (bw - textWidth) / 2,
                        (settingFrame.y + (settingFrame.height - bh) / 2  + (bh - textHeight) / 2))
    button.label:SetText({{ color = labelColor }, buttonLabel })
    register(elements, button.label)

    return button
end

return {
    addSlider = addSlider,
    addButton = addButton,
    alignment = widgetAlignment,
    images = images
}