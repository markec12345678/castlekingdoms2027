local el, backButton, destroyButton = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local keepImage = love.graphics.newImage("assets/ui/keep_ab.png")
local fortressImage = love.graphics.newImage("assets/ui/fortress_ab.png")
local strongholdImage = love.graphics.newImage("assets/ui/stronghold_ab.png")
local castleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_keep_ab.png"), states.STATE_INGAME_CONSTRUCTION, 1, false, nil)

castleButton:setOnClick(
    function()
        local upgraded = _G.BuildController:upgradeKeep(2)
        if upgraded then
            castleButton:setImage(keepImage)
            castleButton:setTooltip("Keep", "Requires 100 Stone and 50 Wood")
            castleButton:setOnClick(
                function()
                    local upgraded = _G.BuildController:upgradeKeep(3)
                    if upgraded then
                        castleButton:setImage(fortressImage)
                        castleButton:setTooltip("Fortress", "Requires 200 Stone")
                        castleButton:setOnClick(
                            function()
                                local upgraded = _G.BuildController:upgradeKeep(4)
                                if upgraded then
                                    castleButton:setImage(strongholdImage)
                                    castleButton:setTooltip("Stronghold", "Not implemented yet (It's too big!)")
                                    castleButton.disabled = true
                                    castleButton.foreground.disablehover = true
                                    castleButton.foreground:SetColor(0.6, 0.6, 0.6, 0.6)
                                    castleButton:setOnClick(function() end)
                                end
                            end
                        )
                    end
                end
            )
        end
    end)
castleButton:setTooltip("WoodenKeep", "Requires 50 Wood")

local woodenWallButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_wall_ab.png"), states.STATE_INGAME_CONSTRUCTION, 2, true, nil)
woodenWallButton:setOnClick(
    function(self)
        ActionBar:selectButton(woodenWallButton)
        _G.BuildController:set(
            "wooden_wall", function()
            woodenWallButton:unselect()
        end)
    end)
woodenWallButton:setTooltip("Wooden Wall", "A defensive wall made from sharpened tree trunks")
woodenWallButton:setOnUnselect(function()
    local WallController = require("objects.Controllers.WallController")
    WallController.clicked = false
end)


local walkableWoodenWallButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_wall_walkable_ab.png"), states.STATE_INGAME_CONSTRUCTION, 3, false, nil)
walkableWoodenWallButton:setOnClick(
    function(self)
        ActionBar:selectButton(walkableWoodenWallButton)
        _G.BuildController:set(
            "walkable_wooden_wall", function()
            walkableWoodenWallButton:unselect()
        end)
    end)
walkableWoodenWallButton:setTooltip("Walkable Wooden Wall", "A defensive wall made that is walkable on the top")
walkableWoodenWallButton:setOnUnselect(function()
    local WallController = require("objects.Controllers.WallController")
    WallController.clicked = false
end)


local woodenTowerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_tower.png"), states.STATE_INGAME_CONSTRUCTION, 4, false, nil)
woodenTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "wooden_tower", function()
            woodenTowerButton:unselect()
        end)
        ActionBar:selectButton(woodenTowerButton)
    end)
woodenTowerButton:setTooltip("Wooden Tower", "A wooden tower that is missing some stairs apparently")

local woodenGateEastButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_gate_east.png"), states.STATE_INGAME_CONSTRUCTION, 5, false, nil)
woodenGateEastButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "wooden_gate_east", function()
            woodenGateEastButton:unselect()
        end)
        ActionBar:selectButton(woodenGateEastButton)
    end)
woodenGateEastButton:setTooltip("Wooden Gate", "A wooden gate that can let friendly units pass through")


local woodenGateSouthButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_gate_south.png"), states.STATE_INGAME_CONSTRUCTION, 6, false, nil)
woodenGateSouthButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "wooden_gate_south", function()
            woodenGateSouthButton:unselect()
        end)
        ActionBar:selectButton(woodenGateSouthButton)
    end)
woodenGateSouthButton:setTooltip("Wooden Gate", "A wooden gate that can let friendly units pass through")


el.buttons.castleButton:setOnClick(
    function(self)
        ActionBar:showGroup("castle")
    end)

ActionBar:registerGroup("castle", {castleButton, woodenWallButton, walkableWoodenWallButton, woodenTowerButton, woodenGateEastButton, woodenGateSouthButton, backButton, destroyButton})
