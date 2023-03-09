local settingsFrames = require("states.ui.settings.settings_frames")
local frames, _ = settingsFrames[1], settingsFrames[2]
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local config = require("config_file")

local resolutions = {}
local currentResolutionIndex = 0

local widgets = {
    resolution = {
        background = nil,
        label = nil,
        buttons = {
            prev = nil,
            current = nil,
            next = nil
        }
    },

    elements = {},

    registerElement = function(self, element)
        self.elements[#self.elements + 1] = element
    end
}

local config = {
    rowBackgroundImage = love.graphics.newImage("assets/ui/settings_element_background.png"),
    buttonImage = love.graphics.newImage("assets/ui/button_hover.png"),
    buttonImageHover = love.graphics.newImage("assets/ui/button.png"),
    buttonImageDown = love.graphics.newImage("assets/ui/button.png"),
    frElement1 = frames["frSettingsItem_1"],
    frLabel1 = frames["frSettingsLabel_1"],
}

local function getAvailableResolutions()
    local result = {}
    local modes = love.window.getFullscreenModes(1)
    for i, mode in ipairs(modes) do
        result[#result + 1] = mode
    end
    return result
end

local function getCurrentResolution()
    local resolutionW, resolutionH
    resolutionW, resolutionH = love.window.getMode()
    for i, r in ipairs(resolutions) do
        if (r.width == resolutionW and r.height == resolutionH) then
            return i
        end
    end

    return #resolutions
end

local function addResolutionsBackground()
    local rowBackground = loveframes.Create("image")
    rowBackground:SetState(states.STATE_SETTINGS)
    rowBackground:SetImage(config.rowBackgroundImage)
    rowBackground:SetScaleX(config.frElement1.width / rowBackground:GetImageWidth())
    rowBackground:SetScaleY(config.frElement1.height / rowBackground:GetImageHeight())
    rowBackground:SetPos(config.frElement1.x, config.frElement1.y)
    rowBackground.disablehover = true
    widgets:registerElement(rowBackground)

    local labelColor = {1, 1, 1}

    local text = "Resolution"
    local textWidth = loveframes.font_vera_bold:getWidth(text)
    local label = loveframes.Create("text")
    label:SetState(states.STATE_SETTINGS)
    label:SetFont(loveframes.font_vera_bold)
    label:SetPos(config.frLabel1.x, config.frLabel1.y)
    label:SetText({{ color = labelColor }, text})
    widgets:registerElement(label)
end

local function addResoltionButton(w, h, text, xboffset, xscale, yscale, cb)
    local button = {
        back = nil,
        label = nil
    }

    local textWidth = loveframes.font_vera_bold:getWidth(text)
    local textHeight = loveframes.font_vera_bold:getHeight()

    local labelColor = {1, 1, 1}
    local bw = w * xscale
    local bh = h * yscale

    button.back = loveframes.Create("image")
    button.back:SetState(states.STATE_SETTINGS)
    button.back:SetImage(config.buttonImage)
    button.back:SetPos(config.frElement1.x + config.frElement1.width - xboffset, config.frElement1.y + (config.frElement1.height - bh) / 2)
    button.back:SetScaleX(xscale)
    button.back:SetScaleY(yscale)
    button.back.OnMouseEnter = function(self) self:SetImage(config.buttonImageHover) end
    button.back.OnMouseDown = function(self) self:SetImage(config.buttonImageDown) end
    button.back.OnMouseExit = function(self) self:SetImage(config.buttonImage) end
    button.back.OnClick = cb
    widgets:registerElement(button.back)

    button.label = loveframes.Create("text", button.back)
    button.label:SetState(states.STATE_SETTINGS)
    button.label.disablehover = true
    button.label:SetFont(loveframes.font_vera_bold)
    button.label:SetPos(config.frElement1.x + config.frElement1.width - xboffset + (bw - textWidth) / 2,
                        config.frElement1.y + (config.frElement1.height - bh) / 2  + (bh - textHeight) / 2)
    button.label:SetText({{ color = labelColor }, text })
    widgets:registerElement(button.label)

    return button
end

local function addResolutionsButtons()
    local buttonWidth = config.buttonImage:getWidth()
    local buttonHeight = config.buttonImage:getHeight()

    local xboffset = 10 + buttonWidth * 0.3
    widgets.resolution.buttons.next = addResoltionButton(buttonWidth, buttonHeight, ">", xboffset, 0.3, 0.7, function (self)
        if currentResolutionIndex == 1 then
            return
        end

        currentResolutionIndex = currentResolutionIndex - 1
        local currentResolution = resolutions[currentResolutionIndex]
        local text = tostring(currentResolution.width).." x "..tostring(currentResolution.height)
        widgets.resolution.buttons.current.label:SetText(text)
    end)

    xboffset = xboffset + buttonWidth * 0.7
    local currentResolution = resolutions[currentResolutionIndex]
    local text = tostring(currentResolution.width).."x"..tostring(currentResolution.height)
    widgets.resolution.buttons.current = addResoltionButton(buttonWidth, buttonHeight, text, xboffset, 0.7, 0.7, function (self)
        local currentResolution = resolutions[currentResolutionIndex]
        love.window.setMode(currentResolution.width, currentResolution.height)
    end)

    xboffset = xboffset + buttonWidth * 0.3
    widgets.resolution.buttons.prev = addResoltionButton(buttonWidth, buttonHeight, "<", xboffset, 0.3, 0.7, function (self)
        if currentResolutionIndex == #resolutions then
            return
        end

        currentResolutionIndex = currentResolutionIndex + 1
        local currentResolution = resolutions[currentResolutionIndex]
        local text = tostring(currentResolution.width).."x"..tostring(currentResolution.height)
        widgets.resolution.buttons.current.label:SetText(text)
    end)
end

resolutions = getAvailableResolutions()
currentResolutionIndex = getCurrentResolution()
addResolutionsBackground()
addResolutionsButtons()

return widgets.elements
