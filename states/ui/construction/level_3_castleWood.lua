local el, backButton, destroyButton, setBuildingsTooltips = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")
local SID = require("objects.Controllers.LanguageController").lines

local woodenWallButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/wooden/wooden_wall_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 1, true, nil)
woodenWallButton:setOnClick(
    function(self)
        ActionBar:selectButton(woodenWallButton)
        _G.BuildController:set(
            "WoodenWall", function()
                woodenWallButton:unselect()
            end)
    end)

woodenWallButton:setOnUnselect(function()
    local WallController = require("objects.Controllers.WallController")
    WallController.clicked = false
end)


local walkableWoodenWallButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/wooden/wooden_wall_walkable_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 2, false, nil)
walkableWoodenWallButton:setOnClick(
    function(self)
        ActionBar:selectButton(walkableWoodenWallButton)
        _G.BuildController:set(
            "WalkableWoodenWall", function()
                walkableWoodenWallButton:unselect()
            end)
    end)
walkableWoodenWallButton:setOnUnselect(function()
    local WallController = require("objects.Controllers.WallController")
    WallController.clicked = false
end)

local woodenTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/wooden/wooden_tower.png"),
    states.STATE_INGAME_CONSTRUCTION, 3, false, nil)
woodenTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "WoodenTower", function()
                woodenTowerButton:unselect()
            end)
        ActionBar:selectButton(woodenTowerButton)
    end)

local woodenPermimeterTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/wooden/wooden_perimeter_tower.png"),
    states.STATE_INGAME_CONSTRUCTION, 4, false, nil)
woodenPermimeterTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "WoodenPerimeterTower", function()
                woodenPermimeterTowerButton:unselect()
            end)
        ActionBar:selectButton(woodenPermimeterTowerButton)
    end)

local woodenDefenseTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/wooden/wooden_defense_tower.png"),
    states.STATE_INGAME_CONSTRUCTION, 5, false, nil)
woodenDefenseTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "WoodenDefenseTower", function()
                woodenDefenseTowerButton:unselect()
            end)
        ActionBar:selectButton(woodenDefenseTowerButton)
    end)

local woodenGateEastButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/wooden/wooden_gate_east.png"),
    states.STATE_INGAME_CONSTRUCTION, 6, false, nil)
woodenGateEastButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "WoodenGateEast", function()
                woodenGateEastButton:unselect()
            end)
        ActionBar:selectButton(woodenGateEastButton)
    end)

local woodenGateSouthButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/wooden/wooden_gate_south.png"),
    states.STATE_INGAME_CONSTRUCTION, 7, false, nil)
woodenGateSouthButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "WoodenGateSouth", function()
                woodenGateSouthButton:unselect()
            end)
        ActionBar:selectButton(woodenGateSouthButton)
    end)

local woodenGateEastBigButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/wooden/wooden_gate_east_big.png"),
    states.STATE_INGAME_CONSTRUCTION, 8, false, nil)
woodenGateEastBigButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "WoodenGateEastBig", function()
                woodenGateEastBigButton:unselect()
            end)
        ActionBar:selectButton(woodenGateEastBigButton)
    end)

local woodenGateSouthBigButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fortifications/wooden/wooden_gate_south_big.png"),
    states.STATE_INGAME_CONSTRUCTION, 9, false, nil)
woodenGateSouthBigButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "WoodenGateSouthBig", function()
                woodenGateSouthBigButton:unselect()
            end)
        ActionBar:selectButton(woodenGateSouthBigButton)
    end)

local buildings = {
    { button = walkableWoodenWallButton,    id = "WalkableWoodenWall",   name = SID.buildings.walkableWoodenWall.name,    description = SID.buildings.walkableWoodenWall.description,    tier = 1 },
    { button = woodenTowerButton,           id = "WoodenTower",          name = SID.buildings.woodenTower.name,           description = SID.buildings.woodenTower.description,           tier = 1 },
    { button = woodenGateEastButton,        id = "WoodenGateEast",       name = SID.buildings.woodenGateEast.name,        description = SID.buildings.woodenGateEast.description,        tier = 1 },
    { button = woodenGateSouthButton,       id = "WoodenGateSouth",      name = SID.buildings.woodenGateSouth.name,       description = SID.buildings.woodenGateSouth.description,       tier = 1 },
    { button = woodenGateEastBigButton,     id = "WoodenGateEastBig",    name = SID.buildings.woodenGateEastBig.name,     description = SID.buildings.woodenGateEastBig.description,     tier = 1 },
    { button = woodenGateSouthBigButton,    id = "WoodenGateSouthBig",   name = SID.buildings.woodenGateSouthBig.name,    description = SID.buildings.woodenGateSouthBig.description,    tier = 1 },
    { button = woodenPermimeterTowerButton, id = "WoodenPerimeterTower", name = SID.buildings.woodenPermimeterTower.name, description = SID.buildings.woodenPermimeterTower.description, tier = 1 },
    { button = woodenDefenseTowerButton,    id = "WoodenDefenseTower",   name = SID.buildings.woodenDefenseTower.name,    description = SID.buildings.woodenDefenseTower.description,    tier = 1 },
    { button = woodenWallButton,            id = "WoodenWall",           name = SID.buildings.woodenWall.name,            description = SID.buildings.woodenWall.description,            tier = 1 }
}

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "woodenBuildings" then return end

    setBuildingsTooltips(buildings)
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnGoldChanged, displayTooltips)
_G.bus.on(Events.OnTierUpgraded, displayTooltips)

el.buttons.woodenBuildings:setOnClick(function(self)
    ActionBar:showGroup("woodenBuildings", _G.fx["metpush15"])
    displayTooltips()
end)


ActionBar:registerGroup("woodenBuildings",
    { woodenWallButton, walkableWoodenWallButton, woodenTowerButton, woodenGateEastButton,
        woodenGateSouthButton, woodenGateEastBigButton, woodenGateSouthBigButton, woodenPermimeterTowerButton, woodenDefenseTowerButton, backButton, destroyButton })
