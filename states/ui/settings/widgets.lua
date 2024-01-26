local settingsFrames = require("states.ui.settings.settings_frames")
local frames, _ = settingsFrames[1], settingsFrames[2]
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")

local widgetAlignment = {
    LEFT = 0,
    RIGHT = -1
}

local labelColor = { 1, 1, 1 }

local images = {
    rowBackground = love.graphics.newImage("assets/ui/settings_element_background.png"),
    scaleBar = love.graphics.newImage("assets/ui/scale_bar.png"),

    button = love.graphics.newImage("assets/ui/button.png"),
    buttonHover = love.graphics.newImage("assets/ui/button_hover.png"),
    buttonDown = love.graphics.newImage("assets/ui/button.png"),
    buttonDisabled = love.graphics.newImage("assets/ui/button_disabled.png"),

    scaleHand = love.graphics.newImage("assets/ui/scale_hand.png"),
    scaleHandHover = love.graphics.newImage("assets/ui/scale_hand_hover.png"),
    scaleHandDown = love.graphics.newImage("assets/ui/scale_hand_down.png"),

    checkbox = love.graphics.newImage("assets/ui/checkbox.png"),
    checkboxChecked = love.graphics.newImage("assets/ui/checkbox_checked.png")
}

local function clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end

local function register(elements, element)
    elements[#elements + 1] = element
end

-- LABEL

local function addLabel(elements, row, text)
    local labelFrame = frames["frSettingsLabel_" .. row.index]

    local label = loveframes.Create("text")
    label:SetState(states.STATE_SETTINGS)
    label:SetFont(loveframes.font_vera_bold)
    label:SetPos(labelFrame.x, labelFrame.y)
    label:SetText({ { color = labelColor }, text })
    register(elements, label)
end

-- ROW WIDGET

local function addRow(elements, index, useBackground, label)
    local settingFrame = frames["frSettingsItem_" .. index]
    local xpadding = 0
    if useBackground then
        xpadding = 10
        local rowBackground = loveframes.Create("image")
        rowBackground:SetState(states.STATE_SETTINGS)
        rowBackground:SetImage(images.rowBackground)
        rowBackground:SetScaleX(settingFrame.width / rowBackground:GetImageWidth())
        rowBackground:SetScaleY(settingFrame.height / rowBackground:GetImageHeight())
        rowBackground:SetPos(settingFrame.x, settingFrame.y)
        rowBackground.disablehover = true
        register(elements, rowBackground)
    end

    local row = {
        x = settingFrame.x,
        y = settingFrame.y,
        width = settingFrame.width,
        height = settingFrame.height,
        xpadding = xpadding,
        index = index
    }

    if label then
        addLabel(elements, row, label)
    end

    return row
end

-- SLIDER WIDGET

local function addSlider(elements, row, defaultValue, cb)
    local frScaleBar = frames["frSettingsScale_" .. row.index]
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
    register(elements, sliderScaleBar)

    local frScaleHand = frames["frSettingsScaleHand_" .. row.index]
    local scaleHandValue = loveframes.Create("image")

    scaleHandValue:SetState(states.STATE_SETTINGS)
    scaleHandValue:SetImage(images.scaleHand)
    scaleHandValue:SetScaleY(frScaleHand.height / scaleHandValue:GetImageHeight())
    scaleHandValue:SetScaleX(scaleHandValue:GetScaleY())

    local slider = {
        label = nil,
        SetText = function(self, text)
            local textWidth = loveframes.font_vera_bold:getWidth(text)
            self.label:SetText({ {
                color = labelColor
            }, text })
            self.label:SetX((scaleHandValue.x + ((scaleHandValue.width * scaleHandValue:GetScaleX()) / 2)) - (textWidth / 2), false)
        end
    }

    local min, max = frScaleHand.x, frScaleHand.x + frScaleHand.width - scaleHandValue:GetImageHeight() / 2
    local initialX = clamp(frScaleBar.x + (frScaleBar.width * defaultValue / 100), min, max)
    scaleHandValue:SetPos(initialX, frScaleHand.y)
    scaleHandValue:SetX(initialX, false)
    register(elements, scaleHandValue)

    local sliderValueLabelY = scaleHandValue.y + (scaleHandValue.height * scaleHandValue:GetScaleY()) + scaleHandValue:GetScaleY()

    slider.label = loveframes.Create("text")
    slider.label:SetState(states.STATE_SETTINGS)
    slider.label:SetFont(loveframes.font_vera_bold)
    slider.label:SetPos(initialX - (slider.label.width / 2), sliderValueLabelY)
    slider:SetText(defaultValue .. "%")
    register(elements, slider.label)

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
            slider:SetText((self.value * 100) .. "%")
            cb(self.value)
        elseif self.isHolding then
            local mx, _ = love.mouse.getPosition()
            local rawValue = clamp(mx, min, max)
            self:SetX(rawValue, false)
            self.value = math.floor(((rawValue - sliderScaleBar.x) / (max - sliderScaleBar.x)) * 100) / 100
            slider:SetText((self.value * 100) .. "%")
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

    return slider
end

-- BUTTON WIDGET

local function addButton(elements, row, buttonLabel, alignment, cb)
    local buttonWidth = images.button:getWidth()
    local buttonHeight = images.button:getHeight()

    local xscale = 0.7
    local yscale = 0.7

    local xoffset = 0

    local rowBackground = loveframes.Create("image")
    rowBackground:SetState(states.STATE_SETTINGS)
    rowBackground:SetImage(images.rowBackground)

    local button = {
        enabled = true,
        back = nil,
        label = nil,
        Disable = function(self)
            self.enabled = false
            self.back.disablehover = true
            self.back:SetImage(images.buttonDisabled)
        end,
        Enable = function(self)
            self.enabled = true
            self.back.disablehover = false
            self.back:SetImage(images.button)
        end
    }

    local textWidth = loveframes.font_vera_bold:getWidth(buttonLabel)
    local textHeight = loveframes.font_vera_bold:getHeight()

    local bw = buttonWidth * xscale
    local bh = buttonHeight * yscale

    if alignment == widgetAlignment.RIGHT then
        xoffset = row.width - bw - row.xpadding
    else
        xoffset = row.xpadding
    end

    button.back = loveframes.Create("image")
    button.back:SetState(states.STATE_SETTINGS)
    button.back:SetImage(button.enabled and images.button or images.buttonDisabled)
    button.back:SetScaleX(xscale)
    button.back:SetScaleY(yscale)

    button.back:SetPos(row.x + xoffset, (row.y + (row.height - bh) / 2))
    button.back.OnMouseEnter = function(self) self:SetImage(images.buttonHover) end
    button.back.OnMouseDown = function(self) self:SetImage(images.buttonDown) end
    button.back.OnMouseExit = function(self) self:SetImage(images.button) end
    button.back.OnClick = function(self)
        if not button.enabled then return end
        cb(self)
    end
    register(elements, button.back)

    button.label = loveframes.Create("text", button.back)
    button.label:SetState(states.STATE_SETTINGS)
    button.label.disablehover = true
    button.label:SetFont(loveframes.font_vera_bold)
    button.label:SetPos(row.x + xoffset + (bw - textWidth) / 2,
        (row.y + (row.height - bh) / 2 + (bh - textHeight) / 2))
    button.label:SetText({ { color = labelColor }, buttonLabel })
    register(elements, button.label)

    return button
end

-- CHECKBOX WIDGET

local function addCheckbox(elements, row, xoffset, text, initialValue, onClick)
    local yscale = (row.height / images.button:getHeight()) * 0.7
    local xscale = yscale

    local button = {
        back = nil,
        label = nil,
        value = initialValue
    }

    local buttonWidth = images.checkbox:getWidth()
    local buttonHeight = images.checkbox:getHeight()

    local bw = buttonWidth * xscale
    local bh = buttonHeight * yscale

    button.back = loveframes.Create("image")
    button.back:SetState(states.STATE_SETTINGS)
    button.back:SetImage(initialValue and images.checkboxChecked or images.checkbox)
    button.back:SetPos(row.x + (row.xpadding * xscale) + xoffset, (row.y + (row.height - bh) / 2))
    button.back:SetScaleX(xscale)
    button.back:SetScaleY(yscale)
    button.back.OnMouseDown = function(self)
        self:SetImage(button.value and images.checkbox or images.checkboxChecked)
    end
    button.back.OnMouseExit = function(self)
        self:SetImage(button.value and images.checkboxChecked or images.checkbox)
    end
    button.back.OnClick = function(self)
        button.value = not button.value
        self:SetImage(button.value and images.checkboxChecked or images.checkbox)
        onClick(self, button.value)
    end
    register(elements, button.back)

    button.label = loveframes.Create("text", button.back)
    button.label:SetState(states.STATE_SETTINGS)
    button.label.disablehover = true
    button.label:SetFont(loveframes.font_vera_bold)
    button.label:SetText({ { color = labelColor }, text })
    button.label:SetPos(button.back.x + (button.back.width * xscale) + (10 * xscale), button.back.y + ((button.back.height * yscale) / 2) - ((button.label.height * yscale) / 2))
    register(elements, button.label)

    return button
end

return {
    addRow = addRow,
    addLabel = addLabel,
    addSlider = addSlider,
    addButton = addButton,
    addCheckbox = addCheckbox,
    alignment = widgetAlignment,
    images = images
}
