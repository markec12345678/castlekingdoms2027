local el, backButton = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')

local stockpileButton = ActionBarButton:new(love.graphics.newImage('assets/ui/stockpile_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)

stockpileButton:setOnClick(function(self)
    _G.BuildController:set("stockpile", function()
        stockpileButton:unselect()
    end)
    ActionBar:selectButton(stockpileButton)
end)
stockpileButton:setTooltip("Stockpile",
    "Requires 4 Stone\nIncreases resource capacity\nMust be placed adjacent to a stockpile")

local woodcutterButton = ActionBarButton:new(love.graphics.newImage('assets/ui/woodcutter_hut_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true)

woodcutterButton:setOnClick(function(self)
    _G.BuildController:set("woodcutter_hut", function()
        woodcutterButton:unselect()
    end)
    ActionBar:selectButton(woodcutterButton)
end)
woodcutterButton:setTooltip("Woodcutter's Hut", "Requires 3 Wood\nCuts down nearby trees to produce wood")

local quarryButton = ActionBarButton:new(love.graphics.newImage('assets/ui/quarry_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, true)

quarryButton:setOnClick(function(self)
    _G.BuildController:set("quarry", function()
        quarryButton:unselect()
    end)
    ActionBar:selectButton(quarryButton)
end)
quarryButton:setTooltip("Quarry", "Requires 24 Wood\nProduces stone blocks from the ground resource")

local oxButton = ActionBarButton:new(love.graphics.newImage('assets/ui/ox_ab.png'), states.STATE_INGAME_CONSTRUCTION, 4, true)
oxButton:setTooltip("Ox Tether (can only be placed near a quarry)", "5 Wood\nTransport stone from the quarry to the stockpile")
oxButton:setOnClick(function(self)
    _G.BuildController:set("ox_tether", function()
        oxButton:unselect()
    end)
    ActionBar:selectButton(oxButton)
end)

local ironMine = ActionBarButton:new(love.graphics.newImage('assets/ui/iron_mine_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 5, true)

ironMine:setOnClick(function(self)
    _G.BuildController:set("iron_mine", function()
        ironMine:unselect()
    end)
    ActionBar:selectButton(ironMine)
end)
ironMine:setTooltip("Iron Mine", "Requires 10 Wood, 10 Stone\nProduces iron ingots from ground iron ore")

el.buttons.hammerButton:setOnClick(function(self)
    ActionBar:showGroup("resource")
end)

ActionBar:registerGroup("resource", {stockpileButton, woodcutterButton, quarryButton, oxButton, ironMine, backButton})
