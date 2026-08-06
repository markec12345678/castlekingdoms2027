local widgets = require("states.ui.settings.widgets")
local settingsFrames = require("states.ui.settings.settings_frames")
local frames, _ = settingsFrames[1], settingsFrames[2]
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local config = require("config_file")
local SID = require("objects.Controllers.LanguageController").lines

local resolutions = {}
local currentResolutionIndex = 0
local currentDisplayIndex = config.video.display

local oldFullscreen = config.video.fullscreen
local fullscreen = config.video.fullscreen

local oldBorderless = config.video.borderless
local borderless = config.video.borderless

local oldVsync = config.video.vsync
local vsync = config.video.vsync

local settingsWidgets = {
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

local function getAvailableResolutions()
    local result = {}
    local modes = love.window.getFullscreenModes(config.video.display)
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

local function getAvailableDisplays()
    local result = {}
    local count = love.window.getDisplayCount()
    for i = 1, count do
        result[#result + 1] = "[" .. i .. "] " .. love.window.getDisplayName(i)
    end
    return result
end

resolutions = getAvailableResolutions()
currentResolutionIndex = getCurrentResolution()
local displays = getAvailableDisplays()
local currentDisplay = displays[currentDisplayIndex]

local oldResolutionIndex = currentResolutionIndex
local oldDisplayIndex = currentDisplayIndex

local function toggleApplyButton()
    local enabled = false

    if fullscreen ~= oldFullscreen or currentResolutionIndex ~= oldResolutionIndex then
        enabled = true
    end

    if currentDisplayIndex ~= oldDisplayIndex then
        enabled = true
    end

    if borderless ~= oldBorderless then
        enabled = true
    end

    if vsync ~= oldVsync then
        enabled = true
    end

    if enabled then
        settingsWidgets.resolution.buttons.apply:Enable()
    else
        settingsWidgets.resolution.buttons.apply:Disable()
    end
end

local function changeCurrentResolution(index)
    if index > #resolutions then
        index = 1
    elseif index < 1 then
        index = #resolutions
    end

    currentResolutionIndex = index
    local currentResolution = resolutions[currentResolutionIndex]
    local text = tostring(currentResolution.width) .. " x " .. tostring(currentResolution.height)
    settingsWidgets.resolution.buttons.current:SetText(text)

    toggleApplyButton()
end

local function changeCurrentDisplay(index)
    if index > #displays then
        index = 1
    elseif index < 1 then
        index = #displays
    end

    currentDisplayIndex = index
    currentDisplay = displays[currentDisplayIndex]
    settingsWidgets.resolution.buttons.monitorCurrent:SetText(currentDisplay)

    toggleApplyButton()
end

local function addResolutionButton(row, w, h, text, xboffset, xscale, yscale, cb)
    local button = {
        back = nil,
        label = nil,
        enabled = true,
        Disable = function(self)
            self.enabled = false
            self.back.disablehover = true
            self.back:SetImage(widgets.images.buttonDisabled)
        end,
        Enable = function(self)
            self.enabled = true
            self.back.disablehover = false
            self.back:SetImage(widgets.images.button)
        end
    }

    local textWidth = loveframes.font_vera_bold:getWidth(text)
    local textHeight = loveframes.font_vera_bold:getHeight()

    local labelColor = { 1, 1, 1 }
    local bw = w * xscale
    local bh = h * yscale

    button.back = loveframes.Create("image")
    button.back:SetState(states.STATE_SETTINGS)
    if button.enabled then
        button.back:SetImage(widgets.images.button)
    else
        button.back:SetImage(widgets.images.buttonDisabled)
    end
    button.back:SetPos(row.x + row.width - xboffset, row.y + (row.height - bh) / 2)
    button.back:SetScaleX(xscale)
    button.back:SetScaleY(yscale)
    button.back.OnMouseEnter = function(self) self:SetImage(widgets.images.buttonHover) end
    button.back.OnMouseDown = function(self) self:SetImage(widgets.images.buttonDown) end
    button.back.OnMouseExit = function(self) self:SetImage(widgets.images.button) end
    button.back.OnClick = function(self)
        if not button.enabled then return end
        cb(self)
    end
    settingsWidgets:registerElement(button.back)

    button.label = loveframes.Create("text", button.back)
    button.label:SetState(states.STATE_SETTINGS)
    button.label.disablehover = true
    button.label:SetFont(loveframes.font_vera_bold)
    button.label:SetPos(row.x + row.width - xboffset + (bw - textWidth) / 2,
        row.y + (row.height - bh) / 2 + (bh - textHeight) / 2)
    button.label:SetText({ { color = labelColor }, text })
    settingsWidgets:registerElement(button.label)

    return button
end

local function addResolutionLabel(row, w, h, text, xboffset, xscale, yscale)
    local labelColor = { 1, 1, 1 }
    local bw = w * xscale
    local bh = h * yscale

    local button = {
        label = nil,
        SetText = function(self, text)
            local textWidth = loveframes.font_vera_bold:getWidth(text)
            local textHeight = loveframes.font_vera_bold:getHeight()
            self.label:SetPos(row.x + row.width - xboffset + (bw - textWidth) / 2,
                row.y + (row.height - bh) / 2 + (bh - textHeight) / 2)
            self.label:SetText({ { color = labelColor }, text })
        end
    }

    button.label = loveframes.Create("text", button.back)
    button.label:SetState(states.STATE_SETTINGS)
    button.label.disablehover = true
    button.label:SetFont(loveframes.font_vera_bold)
    button:SetText(text)
    settingsWidgets:registerElement(button.label)

    return button
end

local function addResolutionsButtons()
    local fullscreenRow = widgets.addRow(settingsWidgets.elements, 1, true)

    local rowWidthOneThird = fullscreenRow.width / 3

    settingsWidgets.resolution.buttons.fullscreen = widgets.addCheckbox(settingsWidgets.elements, fullscreenRow, 0, SID.settings.categories.graphics.items.fullScreen, fullscreen, function(self, value)
        fullscreen = value
        if not fullscreen then
            settingsWidgets.resolution.buttons.next:Enable()
            settingsWidgets.resolution.buttons.prev:Enable()
        else
            settingsWidgets.resolution.buttons.next:Disable()
            settingsWidgets.resolution.buttons.prev:Disable()
        end

        toggleApplyButton()
    end)

    settingsWidgets.resolution.buttons.borderless = widgets.addCheckbox(settingsWidgets.elements, fullscreenRow, rowWidthOneThird, SID.settings.categories.graphics.items.borderless, borderless,
        function(self, value)
            borderless = value
            toggleApplyButton()
        end)

    settingsWidgets.resolution.buttons.vsync = widgets.addCheckbox(settingsWidgets.elements, fullscreenRow, rowWidthOneThird * 2, SID.settings.categories.graphics.items.vsync, vsync,
        function(self, value)
            vsync = value
            toggleApplyButton()
        end)

    local resolutionsRow = widgets.addRow(settingsWidgets.elements, 2, true, SID.settings.categories.graphics.items.resolution)

    local buttonWidth = widgets.images.button:getWidth()
    local buttonHeight = widgets.images.button:getHeight()

    local xboffset = 10 + buttonWidth * 0.3
    settingsWidgets.resolution.buttons.next = addResolutionButton(resolutionsRow, buttonWidth, buttonHeight, ">", xboffset, 0.3, 0.7, function(self)
        changeCurrentResolution(currentResolutionIndex - 1)
    end)

    xboffset = xboffset + buttonWidth * 0.7
    local currentResolution = resolutions[currentResolutionIndex]
    local text = tostring(currentResolution.width) .. "x" .. tostring(currentResolution.height)
    settingsWidgets.resolution.buttons.current = addResolutionLabel(resolutionsRow, buttonWidth, buttonHeight, text, xboffset, 0.7, 0.7)

    xboffset = xboffset + buttonWidth * 0.3
    settingsWidgets.resolution.buttons.prev = addResolutionButton(resolutionsRow, buttonWidth, buttonHeight, "<", xboffset, 0.3, 0.7, function(self)
        changeCurrentResolution(currentResolutionIndex + 1)
    end)

    if not fullscreen then
        settingsWidgets.resolution.buttons.next:Enable()
        settingsWidgets.resolution.buttons.prev:Enable()
    else
        settingsWidgets.resolution.buttons.next:Disable()
        settingsWidgets.resolution.buttons.prev:Disable()
    end

    local applyRowIndex = 3

    if #displays > 1 then
        local monitorsRow = widgets.addRow(settingsWidgets.elements, 3, true, SID.settings.categories.graphics.items.display)
        xboffset = 10 + buttonWidth * 0.3
        settingsWidgets.resolution.buttons.monitorNext = addResolutionButton(monitorsRow, buttonWidth, buttonHeight, ">", xboffset, 0.3, 0.7, function(self)
            changeCurrentDisplay(currentDisplayIndex - 1)
        end)

        xboffset = xboffset + buttonWidth * 0.7
        settingsWidgets.resolution.buttons.monitorCurrent = addResolutionLabel(monitorsRow, buttonWidth, buttonHeight, displays[currentDisplayIndex], xboffset, 0.7, 0.7)

        xboffset = xboffset + buttonWidth * 0.3
        settingsWidgets.resolution.buttons.monitorPrev = addResolutionButton(monitorsRow, buttonWidth, buttonHeight, "<", xboffset, 0.3, 0.7, function(self)
            changeCurrentDisplay(currentDisplayIndex + 1)
        end)

        applyRowIndex = 4
    end

    local applyRow = widgets.addRow(settingsWidgets.elements, applyRowIndex, false)
    settingsWidgets.resolution.buttons.apply = widgets.addButton(settingsWidgets.elements, applyRow, SID.settings.categories.graphics.items.apply, widgets.alignment.RIGHT, function(self)
        local currentResolution = resolutions[currentResolutionIndex]
        config.video.resolutionWidth, config.video.resolutionHeight = currentResolution.width, currentResolution.height
        oldFullscreen = fullscreen
        oldResolutionIndex = currentResolutionIndex
        config.video.fullscreen = fullscreen
        oldBorderless = borderless
        config.video.borderless = borderless
        oldVsync = vsync
        config.video.vsync = vsync
        oldDisplayIndex = currentDisplayIndex
        config.video.display = currentDisplayIndex
        config:save()
        love.event.quit("restart")
    end)

    settingsWidgets.resolution.buttons.apply:Disable()
end

addResolutionsButtons()

return settingsWidgets.elements
