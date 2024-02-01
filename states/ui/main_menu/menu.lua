local Gamestate = require("libraries.gamestate")
local SaveManager = require("objects.Controllers.SaveManager")
local loveframes = require("libraries.loveframes")
local game = require("states.game")
local base = require("states.ui.base")
local states = require("states.ui.states")
local SID = require("objects.Controllers.LanguageController").lines

local w, h = base.w, base.h
local MENU_SCALE = 50
local backgroundImage = love.graphics.newImage("assets/ui/menu_flag.png")

local scale = (h.percent[MENU_SCALE]) / backgroundImage:getHeight()
local SPACING = 20 * scale

local offsetX, offsetY = 76, 130
local paddingRight, paddingBottom = 70, 150
local frMenu = {
    x = offsetX * scale + w.percent[50] - (backgroundImage:getWidth() / 2) * scale,
    y = offsetY * scale + 720 * scale,
    width = backgroundImage:getWidth() * scale - offsetX * scale - paddingRight * scale,
    height = backgroundImage:getHeight() * scale - offsetY * scale - paddingBottom * scale
}

local baseWidth = 210 * scale
local baseHeight = math.min(53 * scale, 53)

local freebuildButton = loveframes.Create("button")
freebuildButton:SetState(states.STATE_MAIN_MENU)
freebuildButton:SetPos(frMenu.x, frMenu.y - baseHeight - SPACING)
freebuildButton:SetSize(baseWidth, baseHeight)
freebuildButton:SetText(SID.ui.mainMenu.freebuild)
freebuildButton:SetSkin("StoneKingdoms")
freebuildButton.OnClick = function(self)
    loveframes.SetState(states.STATE_FREE_BUILD_WINDOW)
end

local optionsImage = love.graphics.newImage("assets/ui/button_options.png")
local campaignButton = loveframes.Create("button")
campaignButton:SetState(states.STATE_MAIN_MENU)
campaignButton:SetPos(frMenu.x, frMenu.y)
campaignButton:SetSize(baseWidth, baseHeight)
campaignButton:SetText(SID.ui.mainMenu.campaign)
campaignButton:SetSkin("StoneKingdoms")
campaignButton.OnClick = function(self)
    loveframes.SetState(states.STATE_ECONOMIC_MISSION_PICKER)
end

local loadButton = loveframes.Create("button")
loadButton:SetState(states.STATE_MAIN_MENU)
loadButton:SetPos(frMenu.x, frMenu.y + baseHeight + SPACING)
loadButton:SetSize(baseWidth, baseHeight)
loadButton:SetText(SID.ui.mainMenu.load)
loadButton:SetSkin("StoneKingdoms")
loadButton.OnClick = function(self)
    loveframes.SetState(states.STATE_MAIN_MENU_LOAD_SAVE)
    SaveManager:updateInterface()
end

local optionsButton = loveframes.Create("button")
optionsButton:SetState(states.STATE_MAIN_MENU)
optionsButton:SetPos(frMenu.x, frMenu.y + (baseHeight * 2) + SPACING * 2)
optionsButton:SetSize(baseWidth, baseHeight)
optionsButton:SetText(SID.ui.mainMenu.options)
optionsButton:SetSkin("StoneKingdoms")
optionsButton.OnClick = function(self)
    loveframes.SetState(states.STATE_SETTINGS)
end

local exitButton = loveframes.Create("button")
exitButton:SetState(states.STATE_MAIN_MENU)
exitButton:SetPos(frMenu.x, frMenu.y + (baseHeight * 3) + SPACING * 5)
exitButton:SetSize(baseWidth, baseHeight)
exitButton:SetText(SID.ui.mainMenu.exit)
exitButton:SetSkin("StoneKingdoms")
exitButton.OnClick = function(self)
    love.event.quit("quit", 0)
end

return frMenu
