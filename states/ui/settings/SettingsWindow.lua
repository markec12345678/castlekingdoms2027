local SID = require("objects.Controllers.LanguageController").lines
local descriptionColor = { 0.325, 0.274, 0.231 }
local warningColor = { 0.8, 0.274, 0.231 }

local SettingsWindow = _G.class("SettingsWindow")
function SettingsWindow:addTitleElements(frames, titleText, descriptionText)
    self.frames = frames
    self.titleText = titleText
    self.descriptionText = descriptionText
end

function SettingsWindow:initialize()
    self.category = {
        sound = {
            title = SID.settings.categories.sound.title,
            description = { {
                color = descriptionColor
            }, SID.settings.categories.sound.description },
            elements = require("states.ui.settings.window_sound") or {}
        },
        graphics = {
            title = SID.settings.categories.graphics.title,
            description = { {
                color = descriptionColor
            }, SID.settings.categories.graphics.description, {
                color = warningColor
            }, "Not yet implemented" },
            elements = require("states.ui.settings.window_graphics") or {}
        },
        hotkeys = {
            title = SID.settings.categories.hotkeys.title,
            description = { {
                color = descriptionColor
            }, SID.settings.categories.hotkeys.description, {
                color = warningColor
            }, "Not yet implemented" },
            elements = require("states.ui.settings.window_hotkeys") or {}
        },
        video = {
            title = SID.settings.categories.video.title,
            description = { {
                color = descriptionColor
            }, SID.settings.categories.video.description, {
                color = warningColor
            }, "Not yet implemented" },
            elements = require("states.ui.settings.window_video") or {}
        },
        interface = {
            title = SID.settings.categories.interface.title,
            description = { {
                color = descriptionColor
            }, SID.settings.categories.interface.description, {
                color = warningColor
            }, "Not yet implemented" },
            elements = require("states.ui.settings.window_interface") or {}
        }
    }
end

function SettingsWindow:hideAllElements()
    for _, c in pairs(self.category) do
        for _, v in pairs(c.elements) do
            v.visible = false
        end
    end
end

function SettingsWindow:showElements(elements)
    for _, v in pairs(elements) do
        v.visible = true
    end
end

function SettingsWindow:switch(category)
    assert(type(category) == "string", "Category should be a string")
    if self.category[category] == nil then
        error("invalid category: " .. category)
    end
    self:hideAllElements()
    self.titleText:SetText(self.category[category].title)
    self.descriptionText:SetText(self.category[category].description)
    self:showElements(self.category[category].elements)
end

function SettingsWindow:onClick()
end

function SettingsWindow:setValues()
end

function SettingsWindow:hide()
end

function SettingsWindow:show()
end

return SettingsWindow:new()
