local widgets = require("states.ui.settings.widgets")
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local config = require("config_file")
local LanguageController = require("objects.Controllers.LanguageController")

function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

local translations = LanguageController.translations
local currentTranslation = _G.currentLang
local currentTranslationIndex = indexOf(translations, _G.currentLang)

local settingsWidgets = {
    translation = {
        buttons = {
            prev = nil,
            next = nil,
            apply = nil
        },
        label = nil
    },

    elements = {},

    registerElement = function(self, element)
        self.elements[#self.elements + 1] = element
    end
}

function changeCurrentTranslation(index)
    if index > #translations then
        index = 1
    elseif index < 1 then
        index = #translations
    end

    currentTranslationIndex = index
    currentTranslation = translations[currentTranslationIndex]
    settingsWidgets.translation.label:SetText(LanguageController.translationNames[currentTranslation])

    if _G.currentLang ~= currentTranslation then
        settingsWidgets.translation.buttons.apply:Enable()
    else
        settingsWidgets.translation.buttons.apply:Disable()
    end
end

local function addTranslationButton(row, w, h, text, xboffset, xscale, yscale, cb)
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

local function addLabel(row, w, h, text, xboffset, xscale, yscale)
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

local buttonWidth = widgets.images.button:getWidth()
local buttonHeight = widgets.images.button:getHeight()

local translationsRow = widgets.addRow(settingsWidgets.elements, 1, true)
widgets.addLabel(settingsWidgets.elements, translationsRow, LanguageController.lines.settings.categories.interface.items.language)

xboffset = 10 + buttonWidth * 0.3
settingsWidgets.translation.buttons.next = addTranslationButton(translationsRow, buttonWidth, buttonHeight, ">", xboffset, 0.3, 0.7, function(self)
    changeCurrentTranslation(currentTranslationIndex + 1)
end)

xboffset = xboffset + buttonWidth * 0.7
settingsWidgets.translation.label = addLabel(translationsRow, buttonWidth, buttonHeight, LanguageController.translationNames[translations[currentTranslationIndex]], xboffset, 0.7, 0.7)

xboffset = xboffset + buttonWidth * 0.3
settingsWidgets.translation.buttons.prev = addTranslationButton(translationsRow, buttonWidth, buttonHeight, "<", xboffset, 0.3, 0.7, function(self)
    changeCurrentTranslation(currentTranslationIndex - 1)
end)

local applyRow = widgets.addRow(settingsWidgets.elements, 2, false)
settingsWidgets.translation.buttons.apply = widgets.addButton(settingsWidgets.elements, applyRow, LanguageController.lines.settings.apply, widgets.alignment.RIGHT, function(self)
    config.general.language = currentTranslation
    _G.currentLang = currentTranslation
    config:save(config)
    love.event.quit("restart")
end)

settingsWidgets.translation.buttons.apply:Disable()

return settingsWidgets.elements
