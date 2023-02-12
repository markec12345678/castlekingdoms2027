local el, backButton, destroyButton, getCostAndType = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')

local stockpileButton = ActionBarButton:new(love.graphics.newImage('assets/ui/stockpile_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)


stockpileButton:setOnClick(function(self)
    _G.BuildController:set("Stockpile", function()
        stockpileButton:select()
    end)
    ActionBar:selectButton(stockpileButton)
end)


local woodcutterButton = ActionBarButton:new(love.graphics.newImage('assets/ui/woodcutter_hut_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true)

woodcutterButton:setOnClick(function(self)
    _G.BuildController:set("WoodcutterHut", function()
        woodcutterButton:select()
    end)
    ActionBar:selectButton(woodcutterButton)
end)


local quarryButton = ActionBarButton:new(love.graphics.newImage('assets/ui/quarry_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, true)

quarryButton:setOnClick(function(self)
    _G.BuildController:set("Quarry", function()
        quarryButton:select()
    end)
    ActionBar:selectButton(quarryButton)
end)


local oxButton = ActionBarButton:new(love.graphics.newImage('assets/ui/ox_ab.png'), states.STATE_INGAME_CONSTRUCTION, 4,
    true)

oxButton:setOnClick(function(self)
    _G.BuildController:set("OxTether", function()
        oxButton:select()
    end)
    ActionBar:selectButton(oxButton)
end)

local ironMine = ActionBarButton:new(love.graphics.newImage('assets/ui/iron_mine_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 5, true)

ironMine:setOnClick(function(self)
    _G.BuildController:set("Mine", function()
        ironMine:select()
    end)
    ActionBar:selectButton(ironMine)
end)

local marketButton = ActionBarButton:new(love.graphics.newImage('assets/ui/market_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 6, false)

marketButton:setOnClick(function(self)
    _G.BuildController:set("Market", function()
        marketButton:unselect()
    end)
    ActionBar:selectButton(marketButton)
end)

local function displayTooltips()
    woodcutterButton:setTooltip("Woodcutter's Hut",
        getCostAndType("WoodcutterHut") .. "\nCuts down nearby trees to produce wood")
    oxButton:setTooltip("Ox Tether (can only be placed near a quarry)",
        getCostAndType("OxTether") .. "\nTransport stone from the quarry to the stockpile")
    quarryButton:setTooltip("Quarry", getCostAndType("Quarry") .. "\nProduces stone blocks from the ground resource")
    stockpileButton:setTooltip("Stockpile",
        getCostAndType("Stockpile") .. "\nIncreases resource capacity\nMust be placed adjacent to a stockpile")
    ironMine:setTooltip("Iron Mine", getCostAndType("Mine") .. "\nProduces iron ingots from ground iron ore")
    marketButton:setTooltip("Market", getCostAndType("Market") .. "\nAllows you to trade your goods")
end

el.buttons.hammerButton:setOnClick(function(self)
    ActionBar:showGroup("resource", _G.fx["metpush12"])
    displayTooltips()
end)

ActionBar:registerGroup("resource",
    {stockpileButton, woodcutterButton, quarryButton, oxButton, ironMine, marketButton, backButton, destroyButton})
