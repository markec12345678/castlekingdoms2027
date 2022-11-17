local el, backButton, destroyButton = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")

local castleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_castle_ab.png"), states.STATE_INGAME_CONSTRUCTION, 1, false, nil)

castleButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "saxon_hall", function()
            castleButton:unselect()
        end)
        ActionBar:selectButton(castleButton)
    end)
castleButton:setTooltip("Saxon Hall", "Requires 50 Wood\nHas no purpose at the moment")

local woodenWallButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_wall_ab.png"), states.STATE_INGAME_CONSTRUCTION, 2, true, nil)
woodenWallButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "wooden_wall", function()
            woodenWallButton:unselect()
        end)
        ActionBar:selectButton(woodenWallButton)
    end)
woodenWallButton:setTooltip("Wooden Wall", "A defensive wall made from sharpened tree trunks")
woodenWallButton:setOnUnselect(function()
    local WallController = require("objects.Controllers.WallController")
    WallController.clicked = false
end)


local woodenTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_tower.png"), states.STATE_INGAME_CONSTRUCTION, 3, false, nil)
woodenTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "wooden_tower", function()
            woodenTowerButton:unselect()
        end)
        ActionBar:selectButton(woodenTowerButton)
    end)
woodenTowerButton:setTooltip("Wooden Tower", "A wooden tower that is missing some stairs apparently")


el.buttons.castleButton:setOnClick(
    function(self)
        ActionBar:showGroup("castle")
    end)

ActionBar:registerGroup("castle", {castleButton, woodenWallButton, woodenTowerButton, backButton, destroyButton})
