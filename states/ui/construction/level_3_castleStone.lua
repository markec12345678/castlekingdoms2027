local el, backButton, destroyButton, setBuildingsTooltips = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")
local SID = require("objects.Controllers.LanguageController").lines

local perimeterTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/stone/perimeter_tower_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 3, false, nil)
perimeterTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "PerimeterTower", function()
                perimeterTowerButton:unselect()
            end)
        ActionBar:selectButton(perimeterTowerButton)
    end)

local defenseTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/stone/defense_tower_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 4, false, nil)
defenseTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "DefenseTower", function()
                defenseTowerButton:unselect()
            end)
        ActionBar:selectButton(defenseTowerButton)
    end)
local squareTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/stone/square_tower_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 5, false, nil)
squareTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "SquareTower", function()
                squareTowerButton:unselect()
            end)
        ActionBar:selectButton(squareTowerButton)
    end)
local roundTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/stone/round_tower_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 6, false, nil)
roundTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "RoundTower", function()
                roundTowerButton:unselect()
            end)
        ActionBar:selectButton(roundTowerButton)
    end)

local stoneGateEastButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/stone/stone_gate_east_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 7, false, nil)
stoneGateEastButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "StoneGateEast", function()
                stoneGateEastButton:unselect()
            end)
        ActionBar:selectButton(stoneGateEastButton)
    end)

local stoneGateSouthButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/stone/stone_gate_south_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 8, false, nil)
stoneGateSouthButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "StoneGateSouth", function()
                stoneGateSouthButton:unselect()
            end)
        ActionBar:selectButton(stoneGateSouthButton)
    end)

local stoneGateEastBigButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/stone/stone_gate_big_east_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 9, false, nil)
stoneGateEastBigButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "StoneGateBigEast", function()
                stoneGateEastBigButton:unselect()
            end)
        ActionBar:selectButton(stoneGateEastBigButton)
    end)

local stoneGateSouthBigButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/stone/stone_gate_big_south_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 10, false, nil)
stoneGateSouthBigButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "StoneGateBigSouth", function()
                stoneGateSouthBigButton:unselect()
            end)
        ActionBar:selectButton(stoneGateSouthBigButton)
    end)

local buildings = {
    { button = perimeterTowerButton,    id = "PerimeterTower",    name = SID.buildings.perimeterTower.name,    description = SID.buildings.perimeterTower.description,    tier = 3 },
    { button = defenseTowerButton,      id = "DefenseTower",      name = SID.buildings.defenseTower.name,      description = SID.buildings.defenseTower.description,      tier = 3 },
    { button = squareTowerButton,       id = "SquareTower",       name = SID.buildings.squareTower.name,       description = SID.buildings.squareTower.description,       tier = 4 },
    { button = roundTowerButton,        id = "RoundTower",        name = SID.buildings.roundTower.name,        description = SID.buildings.roundTower.description,        tier = 4 },
    { button = stoneGateSouthButton,    id = "StoneGateSouth",    name = SID.buildings.stoneGateSouth.name,    description = SID.buildings.stoneGateSouth.description,    tier = 3 },
    { button = stoneGateEastButton,     id = "StoneGateEast",     name = SID.buildings.stoneGateEast.name,     description = SID.buildings.stoneGateEast.description,     tier = 3 },
    { button = stoneGateEastBigButton,  id = "StoneGateBigEast",  name = SID.buildings.stoneGateEastBig.name,  description = SID.buildings.stoneGateEastBig.description,  tier = 4 },
    { button = stoneGateSouthBigButton, id = "StoneGateBigSouth", name = SID.buildings.stoneGateSouthBig.name, description = SID.buildings.stoneGateSouthBig.description, tier = 4 }
}

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "stoneBuildings" then return end

    setBuildingsTooltips(buildings)
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnGoldChanged, displayTooltips)
_G.bus.on(Events.OnTierUpgraded, displayTooltips)

el.buttons.stoneBuildings:setOnClick(function(self)
    ActionBar:showGroup("stoneBuildings", _G.fx["metpush15"])
    displayTooltips()
end)

ActionBar:registerGroup("stoneBuildings",
    { perimeterTowerButton, defenseTowerButton, squareTowerButton, roundTowerButton, stoneGateEastButton,
        stoneGateSouthButton, stoneGateEastBigButton, stoneGateSouthBigButton, backButton,
        destroyButton })
