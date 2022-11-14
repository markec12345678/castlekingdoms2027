local el, backButton, destroyButton = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")

local castleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_castle_ab.png"), states.STATE_INGAME_CONSTRUCTION, 1)

castleButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "saxon_hall", function()
            castleButton:unselect()
        end)
        ActionBar:selectButton(castleButton)
    end)
castleButton:setTooltip("Saxon Hall", "Requires 50 Wood\nHas no purpose at the moment")

local woodenWallButton = ActionBarButton:new(
    love.graphics.newImage("assets/ui/wooden_wall_ab.png"), states.STATE_INGAME_CONSTRUCTION, 2, false, nil, true)
woodenWallButton:setTooltip("Wooden wall", "Unimplemented")

el.buttons.castleButton:setOnClick(
    function(self)
        ActionBar:showGroup("castle")
    end)

local marketButton = ActionBarButton:new(love.graphics.newImage('assets/ui/market_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, false)

marketButton:setOnClick(function(self)
    _G.BuildController:set("market", function()
        marketButton:unselect()
    end)
    ActionBar:selectButton(marketButton)
end)
marketButton:setTooltip("Market", "Requires 15 Wood\nAllows you to trade your goods")

el.buttons.castleButton:setOnClick(
    function(self)
        ActionBar:showGroup("castle")
    end)


ActionBar:registerGroup("castle", { castleButton, woodenWallButton, marketButton, backButton })
