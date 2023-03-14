local el, backButton, destroyButton, getCostAndType = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')
local Events = require('objects.Enums.Events')

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

local pitchRigButton = ActionBarButton:new(love.graphics.newImage('assets/ui/pitch_rig_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 6, true, nil, true)

local marketButton = ActionBarButton:new(love.graphics.newImage('assets/ui/market_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 7, false)

marketButton:setOnClick(function(self)
    _G.BuildController:set("Market", function()
        marketButton:unselect()
    end)
    ActionBar:selectButton(marketButton)
end)

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "resource" then return end
    local buildings = {
        {button = woodcutterButton, name = "WoodcutterHut", description = "\nCuts down nearby trees to produce wood."},
        {button = oxButton, name = "OxTether", description = "\nTransport stone from the quarry to the stockpile."},
        {button = quarryButton, name = "Quarry", description = "\nProduces stone blocks from the ground resource."},
        {button = stockpileButton, name = "Stockpile", description = "\nIncreases resource capacity\nMust be placed adjacent to a stockpile."},
        {button = ironMine, name = "Mine", description = "\nProduces iron ingots from ground iron ore."},
        {button = marketButton, name = "Market", description = "\nAllows you to trade your goods."}
    }
    for _, building in ipairs(buildings) do
        local table = getCostAndType(building.name)
        building.button:setTooltip(building.name, table.costAndType .. building.description)
        if not table.affordable then
            building.button.tooltip:SetText({{color = {1, 0, 0, 1}}, table.costAndType}, building.name)
        end
    end
    pitchRigButton:setTooltip("Pitch Rig", "Not implemented yet.")
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)

el.buttons.hammerButton:setOnClick(function(self)
    ActionBar:showGroup("resource", _G.fx["metpush12"])
    displayTooltips()
end)

ActionBar:registerGroup("resource",
    {stockpileButton, woodcutterButton, quarryButton, oxButton, ironMine, pitchRigButton, marketButton, backButton, destroyButton})
