local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local framesActionBar = require("states.ui.action_bar_frames")
local actionBar = require("states.ui.ActionBar")
local scale = actionBar.element.scalex

local group = {}

local ActionBarButton = require("states.ui.ActionBarButton")
local backButton = ActionBarButton:new(love.graphics.newImage("assets/ui/back_ab.png"), states.STATE_CATHEDRAL, 12)
backButton:setOnClick(function(self)
    actionBar:switchMode()
end)
actionBar:registerGroup("cathedral", { backButton })

local monkIcon = love.graphics.newImage("assets/ui/guilds/monk_icon.png")
local monkIconHover = love.graphics.newImage("assets/ui/guilds/monk_icon_hover.png")

local goldIcon = loveframes.Create("image")
local currentCost = loveframes.Create("text")
local currentStockPeasants = loveframes.Create("text")
local currentName = loveframes.Create("text")

local frMonkButton = {
    x = framesActionBar.frFull.x + 550 * scale,
    y = framesActionBar.frFull.y + 95 * scale,
    width = monkIcon:getWidth() * scale,
    height = monkIcon:getHeight() * scale
}

local monkIocnButton = loveframes.Create("image")
monkIocnButton:SetState(states.STATE_CATHEDRAL)
monkIocnButton:SetImage(monkIcon)
monkIocnButton:SetScaleX(frMonkButton.width / monkIocnButton:GetImageWidth())
monkIocnButton:SetScaleY(monkIocnButton:GetScaleX())
monkIocnButton:SetPos(frMonkButton.x, frMonkButton.y)

monkIocnButton.OnMouseEnter = function(self)
        monkIocnButton:SetImage(monkIconHover)
        currentCost:SetText({ {
            color = { 0.99, 0.96, 0.78, 1 }
        }, "12 gold" })
        currentName:SetText({ {
            color = { 0.99, 0.96, 0.78, 1 }
        }, "Monk" })
end

monkIocnButton.OnClick = function(self)
    _G.JobController:makeSoldier("Monk")
end

monkIocnButton.OnMouseExit = function(self)
        monkIocnButton:SetImage(monkIcon)
        currentCost:SetText({ {
            color = { 0.99, 0.96, 0.78, 1 }
        }, "" })
        currentName:SetText({ {
            color = { 0.99, 0.96, 0.78, 1 }
        }, "" })
end


return group
