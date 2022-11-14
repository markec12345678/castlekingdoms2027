local el, backButton, destroyButton = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")

local windmillButton = ActionBarButton:new(love.graphics.newImage("assets/ui/windmill_ab.png"), states.STATE_INGAME_CONSTRUCTION, 1, true)

windmillButton:setOnClick(function(self)
    _G.BuildController:set("windmill", function()
        windmillButton:select()
    end)
    ActionBar:selectButton(windmillButton)
end)
windmillButton:setTooltip("Windmill", "Requires 8 Wood\nProcesses wheat into flour")

local bakeryButton = ActionBarButton:new(love.graphics.newImage("assets/ui/bakery_ab.png"), states.STATE_INGAME_CONSTRUCTION, 2, true)

bakeryButton:setOnClick(function(self)
    _G.BuildController:set("bakery", function()
        bakeryButton:select()
    end)
    ActionBar:selectButton(bakeryButton)
end)
bakeryButton:setTooltip("Bakery", "Requires 10 Wood, 2 Stone\nProcesses flour into bread")

el.buttons.sickleButton:setOnClick(function(self)
    ActionBar:showGroup("sickle")
end)


ActionBar:registerGroup("sickle", {windmillButton, bakeryButton, backButton, destroyButton})
