local settingsFrames = require("states.ui.settings.settings_frames")
local frames, _ = settingsFrames[1], settingsFrames[2]
local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local config = require("config_file")

local elements = {}
local rowBackgroundImage = love.graphics.newImage("assets/ui/settings_element_background.png")

local function register(element)
    elements[#elements + 1] = element
end

local frElement1 = frames["frSettingsItem_1"]
local rowBackground = loveframes.Create("image")
rowBackground:SetState(states.STATE_SETTINGS)
rowBackground:SetImage(rowBackgroundImage)
rowBackground:SetScaleX(frElement1.width / rowBackground:GetImageWidth())
rowBackground:SetScaleY(frElement1.height / rowBackground:GetImageHeight())
rowBackground:SetPos(frElement1.x, frElement1.y)
rowBackground.disablehover = true
register(rowBackground)

return elements
