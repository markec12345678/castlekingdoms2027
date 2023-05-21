local el, backButton, destroyButton, getCostAndType = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")

local perimeterTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/perimeter_tower_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 3, false, nil)
perimeterTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "PerimeterTower", function()
                perimeterTowerButton:unselect()
            end)
        ActionBar:selectButton(perimeterTowerButton)
    end)

local defenseTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/defense_tower_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 4, false, nil)
defenseTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "DefenseTower", function()
                defenseTowerButton:unselect()
            end)
        ActionBar:selectButton(defenseTowerButton)
    end)
local squareTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/square_tower_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 5, false, nil)
squareTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "SquareTower", function()
                squareTowerButton:unselect()
            end)
        ActionBar:selectButton(squareTowerButton)
    end)
local roundTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/round_tower_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 6, false, nil)
roundTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "RoundTower", function()
                roundTowerButton:unselect()
            end)
        ActionBar:selectButton(roundTowerButton)
    end)

local stoneGateEastButton = ActionBarButton:new(love.graphics.newImage("assets/ui/stone_gate_east_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 7, false, nil)
stoneGateEastButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "StoneGateEast", function()
                stoneGateEastButton:unselect()
            end)
        ActionBar:selectButton(stoneGateEastButton)
    end)

local stoneGateSouthButton = ActionBarButton:new(love.graphics.newImage("assets/ui/stone_gate_south_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 8, false, nil)
stoneGateSouthButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "StoneGateSouth", function()
                stoneGateSouthButton:unselect()
            end)
        ActionBar:selectButton(stoneGateSouthButton)
    end)

local stoneGateEastBigButton = ActionBarButton:new(love.graphics.newImage("assets/ui/stone_gate_big_east_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 9, false, nil)
stoneGateEastBigButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "StoneGateBigEast", function()
                stoneGateEastBigButton:unselect()
            end)
        ActionBar:selectButton(stoneGateEastBigButton)
    end)

local stoneGateSouthBigButton = ActionBarButton:new(love.graphics.newImage("assets/ui/stone_gate_big_south_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 10, false, nil)
stoneGateSouthBigButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "StoneGateBigSouth", function()
                stoneGateSouthBigButton:unselect()
            end)
        ActionBar:selectButton(stoneGateSouthBigButton)
    end)

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "stoneBuildings" then return end
    local buildings = {
        { button = perimeterTowerButton,    name = "PerimeterTower",    description = "A small perimeter tower - good for the observation." },
        { button = defenseTowerButton,      name = "DefenseTower",      description = "A defense tower made for defense." },
        { button = squareTowerButton,       name = "SquareTower",       description = "Crucial for your castle - you can place war machines on the top." },
        { button = roundTowerButton,        name = "RoundTower",        description = "The strongest tower - you can place war machines on the top." },
        { button = stoneGateSouthButton,    name = "StoneGateSouth",    description = "A stone gate that can let friendly units pass through." },
        { button = stoneGateEastButton,     name = "StoneGateEast",     description = "A stone gate that can let friendly units pass through." },
        { button = stoneGateEastBigButton,  name = "StoneGateBigEast",  description = "A strong stone gate that can let friendly units pass through." },
        { button = stoneGateSouthBigButton, name = "StoneGateBigSouth", description = "A strong stone gate that can let friendly units pass through." }
    }

    for _, building in ipairs(buildings) do
        local tooltipText = getCostAndType(building.name, building.description)
        building.button:setTooltip(building.name, tooltipText)
    end
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnGoldChanged, displayTooltips)

el.buttons.stoneBuildings:setOnClick(function(self)
    ActionBar:showGroup("stoneBuildings", _G.fx["metpush15"])
    displayTooltips()
end)

ActionBar:registerGroup("stoneBuildings",
    { perimeterTowerButton, defenseTowerButton, squareTowerButton, roundTowerButton, stoneGateEastButton,
        stoneGateSouthButton, stoneGateEastBigButton, stoneGateSouthBigButton, backButton,
        destroyButton })
