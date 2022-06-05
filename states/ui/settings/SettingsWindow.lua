local descriptionColor = {0.325, 0.274, 0.231}
local warningColor = {0.8, 0.274, 0.231}

local SettingsWindow = _G.class("SettingsWindow")
function SettingsWindow:addTitleElements(frames, titleText, descriptionText)
    self.frames = frames
    self.titleText = titleText
    self.descriptionText = descriptionText
end
function SettingsWindow:initialize()
    self.category = {
        sound = {
            title = "SOUND LEVELS",
            description = {{
                color = descriptionColor
            }, "Here you can change the sound levels of sound effects or speech to your liking."},
            elements = require("states.ui.settings.window_sound") or {}
        },
        graphics = {
            title = "GRAPHIC SETTINGS",
            description = {{
                color = descriptionColor
            }, "Modify rendering quality, chunk size and toggle animations in order to balance performance.\n", {
                color = warningColor
            }, "Not yet implemented"},
            elements = require("states.ui.settings.window_graphics") or {}
        },
        hotkeys = {
            title = "KEYBOARD HOTKEYS & SHORTCUTS",
            description = {{
                color = descriptionColor
            }, "Edit or add new keyboard hotkeys and shortcuts.\n", {
                color = warningColor
            }, "Not yet implemented"},
            elements = require("states.ui.settings.window_graphics") or {}
        },
        video = {
            title = "VIDEO SETTINGS",
            description = {{
                color = descriptionColor
            }, "Change fullscreen settings, window resolution and toggle VSync.\n", {
                color = warningColor
            }, "Not yet implemented"},
            elements = require("states.ui.settings.window_graphics") or {}
        },
        interface = {
            title = "INTERFACE SETTINGS",
            description = {{
                color = descriptionColor
            }, "Toggle interface elements and modify their scale.\n", {
                color = warningColor
            }, "Not yet implemented"},
            elements = require("states.ui.settings.window_graphics") or {}
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
