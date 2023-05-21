local el, backButton, destroyButton, getCostAndType = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")

local woodenWallButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_wall_ab.png"),
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


local walkableWoodenWallButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_wall_walkable_ab.png"),
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

local woodenTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_tower.png"),
    states.STATE_INGAME_CONSTRUCTION, 3, false, nil)
woodenTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "WoodenTower", function()
                woodenTowerButton:unselect()
            end)
        ActionBar:selectButton(woodenTowerButton)
    end)

local woodenGateEastButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_gate_east.png"),
    states.STATE_INGAME_CONSTRUCTION, 4, false, nil)
woodenGateEastButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "WoodenGateEast", function()
                woodenGateEastButton:unselect()
            end)
        ActionBar:selectButton(woodenGateEastButton)
    end)

local woodenGateSouthButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_gate_south.png"),
    states.STATE_INGAME_CONSTRUCTION, 5, false, nil)
woodenGateSouthButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "WoodenGateSouth", function()
                woodenGateSouthButton:unselect()
            end)
        ActionBar:selectButton(woodenGateSouthButton)
    end)

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "woodenBuildings" then return end
    local buildings = {
        { button = walkableWoodenWallButton, name = "WalkableWoodenWall", description = "A defensive wall made that is walkable on the top." },
        { button = woodenTowerButton,        name = "WoodenTower",        description = "A wooden tower that is missing some stairs apparently." },
        { button = woodenGateEastButton,     name = "WoodenGateEast",     description = "A wooden gate that can let friendly units pass through." },
        { button = woodenGateSouthButton,    name = "WoodenGateSouth",    description = "A wooden gate that can let friendly units pass through." },
        { button = woodenWallButton,         name = "WoodenWall",         description = "A defensive wall made from sharpened tree trunks." }
    }
    for _, building in ipairs(buildings) do
        local tooltipText = getCostAndType(building.name, building.description)
        building.button:setTooltip(building.name, tooltipText)
    end
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnGoldChanged, displayTooltips)

el.buttons.woodenBuildings:setOnClick(function(self)
    ActionBar:showGroup("woodenBuildings", _G.fx["metpush15"])
    displayTooltips()
end)


ActionBar:registerGroup("woodenBuildings",
    { woodenWallButton, walkableWoodenWallButton, woodenTowerButton, woodenGateEastButton,
        woodenGateSouthButton, backButton, destroyButton })
