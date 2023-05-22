local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")

local castleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_castle_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 1, true, nil)

castleButton:setOnClick(function(self)
    _G.BuildController:set("SaxonHall", function()
        castleButton:select()
    end)
    ActionBar:selectButton(castleButton)
end)

local stockpileButton = ActionBarButton:new(love.graphics.newImage('assets/ui/stockpile_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true)

stockpileButton:setOnClick(function(self)
    _G.BuildController:set("Stockpile", function()
        stockpileButton:select()
    end)
    ActionBar:selectButton(stockpileButton)
end)

local granaryButton = ActionBarButton:new(love.graphics.newImage('assets/ui/granary_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, true)

granaryButton:setOnClick(function(self)
    _G.BuildController:set("Granary", function()
        granaryButton:select()
    end)
    ActionBar:selectButton(granaryButton)
end)

local buildings = {
    { button = castleButton,    name = "SaxonHall", description = "Your Saxon hall is the center of your castle." },
    { button = stockpileButton, name = "Stockpile", description = "The stockpile holds your construction resources." },
    { button = granaryButton,   name = "Granary",   description = "The granary is where you store your kingdom's food reserves." }
}

for _, building in ipairs(buildings) do
    building.button:setTooltip(building.name, building.description)
end

ActionBar:registerGroup("start",
    { castleButton, stockpileButton, granaryButton })

return {
    castleButton = castleButton,
    stockpileButton = stockpileButton,
    granaryButton = granaryButton
}
