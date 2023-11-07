local el, backButton, destroyButton, setBuildingsTooltips, disableUnavailableButtons = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')
local Events = require('objects.Enums.Events')
local SID = require("objects.Controllers.LanguageController").lines

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

local ironMineButton = ActionBarButton:new(love.graphics.newImage('assets/ui/iron_mine_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 5, true)

ironMineButton:setOnClick(function(self)
    _G.BuildController:set("Mine", function()
        ironMineButton:select()
    end)
    ActionBar:selectButton(ironMineButton)
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

local buildings = {
    { button = woodcutterButton, name = SID.buildings.woodcutter.name, description = SID.buildings.woodcutter.description, tier = 1 },
    { button = oxButton,         name = SID.buildings.ox.name,         description = SID.buildings.ox.description,         tier = 2 },
    { button = quarryButton,     name = SID.buildings.quarry.name,     description = SID.buildings.quarry.description,     tier = 2 },
    { button = stockpileButton,  name = SID.buildings.stockpile.name,  description = SID.buildings.stockpile.description,  tier = 1 },
    { button = ironMineButton,   name = SID.buildings.ironMine.name,   description = SID.buildings.ironMine.description,   tier = 3 },
    { button = marketButton,     name = SID.buildings.market.name,     description = SID.buildings.market.description,     tier = 1 }
}

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "resource" then return end

    setBuildingsTooltips(buildings)

    local buttonList = {
        stockpile = stockpileButton,
        woodcutter = woodcutterButton,
        quarry = quarryButton,
        ox = oxButton,
        ironMine = ironMineButton,
        --pitchRig = pitchRigButton, NOT IMPLEMENTED YET
        market = marketButton
    }

    disableUnavailableButtons(buttonList)
    pitchRigButton:setTooltip("Pitch Rig", "Not implemented yet.")
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnGoldChanged, displayTooltips)
_G.bus.on(Events.OnTierUpgraded, displayTooltips)

el.buttons.hammerButton:setOnClick(function(self)
    ActionBar:showGroup("resource", _G.fx["metpush12"])
    displayTooltips()
end)
ActionBar:registerGroup("resource",
    { stockpileButton, woodcutterButton, quarryButton, oxButton, ironMineButton, pitchRigButton, marketButton, backButton,
        destroyButton })
