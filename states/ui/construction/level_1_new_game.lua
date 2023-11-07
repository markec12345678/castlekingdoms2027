local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local SID = require("objects.Controllers.LanguageController").lines

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
    { button = castleButton,    name = SID.buildings.castle.name,    description = SID.buildings.castle.description },
    { button = stockpileButton, name = SID.buildings.stockpile.name, description = SID.buildings.stockpile.description },
    { button = granaryButton,   name = SID.buildings.granary.name,   description = SID.buildings.granary.description }
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
