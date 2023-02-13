local el, backButton, destroyButton, getCostAndType = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local keepImage = love.graphics.newImage("assets/ui/keep_ab.png")
local fortressImage = love.graphics.newImage("assets/ui/fortress_ab.png")
local strongholdImage = love.graphics.newImage("assets/ui/stronghold_ab.png")
local castleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_keep_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 1, false, nil)

castleButton:setOnClick(
    function()
        local upgraded = _G.BuildController:upgradeKeep(2)
        if upgraded then
            castleButton:setImage(keepImage)
            castleButton:setTooltip("Keep", getCostAndType("Keep"))
            castleButton:setOnClick(
                function()
                    local upgraded = _G.BuildController:upgradeKeep(3)
                    if upgraded then
                        castleButton:setImage(fortressImage)
                        castleButton:setTooltip("Fortress", getCostAndType("Fortress"))
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
--castleButton:setTooltip("WoodenKeep", "Requires 50 Wood")

local woodenWallButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_wall_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 2, true, nil)
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
    states.STATE_INGAME_CONSTRUCTION, 3, false, nil)
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
    states.STATE_INGAME_CONSTRUCTION, 4, false, nil)
woodenTowerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "WoodenTower", function()
            woodenTowerButton:unselect()
        end)
        ActionBar:selectButton(woodenTowerButton)
    end)

local woodenGateEastButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_gate_east.png"),
    states.STATE_INGAME_CONSTRUCTION, 5, false, nil)
woodenGateEastButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "WoodenGateEast", function()
            woodenGateEastButton:unselect()
        end)
        ActionBar:selectButton(woodenGateEastButton)
    end)

local woodenGateSouthButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_gate_south.png"),
    states.STATE_INGAME_CONSTRUCTION, 6, false, nil)
woodenGateSouthButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "WoodenGateSouth", function()
            woodenGateSouthButton:unselect()
        end)
        ActionBar:selectButton(woodenGateSouthButton)
    end)

local barracksButton = ActionBarButton:new(love.graphics.newImage("assets/ui/barracks_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 7, false, nil)
barracksButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "Barracks", function()
            barracksButton:unselect()
        end)
        ActionBar:selectButton(barracksButton)
    end)

local stoneBarracksButton = ActionBarButton:new(love.graphics.newImage("assets/ui/stoneBarracks_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 8, false, nil)
stoneBarracksButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "StoneBarracks", function()
            stoneBarracksButton:unselect()
        end)
        ActionBar:selectButton(stoneBarracksButton)
    end)

local engineersGuildButton = ActionBarButton:new(love.graphics.newImage("assets/ui/engineersGuild_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 9, false, nil)
engineersGuildButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "EngineersGuild", function()
            engineersGuildButton:unselect()
        end)
        ActionBar:selectButton(engineersGuildButton)
    end)

local tunnelersGuildButton = ActionBarButton:new(love.graphics.newImage("assets/ui/tunnelersGuild_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 10, false, nil)
tunnelersGuildButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "TunnelersGuild", function()
            tunnelersGuildButton:unselect()
        end)
        ActionBar:selectButton(tunnelersGuildButton)
    end)

local function displayTooltips()
    castleButton:setTooltip("WoodenKeep", getCostAndType("WoodenKeep"))
    walkableWoodenWallButton:setTooltip("Walkable Wooden Wall",
        getCostAndType("WalkableWoodenWall") .. "\nA defensive wall made that is walkable on the top.")
    woodenTowerButton:setTooltip("Wooden Tower",
        getCostAndType("WoodenTower") .. "\nA wooden tower that is missing some stairs apparently.")
    woodenGateEastButton:setTooltip("Wooden Gate",
        getCostAndType("WoodenGateEast") .. "\nA wooden gate that can let friendly units pass through.")
    woodenGateSouthButton:setTooltip("Wooden Gate",
        getCostAndType("WoodenGateSouth") .. "\nA wooden gate that can let friendly units pass through.")
    woodenWallButton:setTooltip("Wooden Wall",
        getCostAndType("WoodenWall") .. "\nA defensive wall made from sharpened tree trunks.")
    barracksButton:setTooltip("Barracks",
        getCostAndType("Barracks") .. "\nA building allowing you to recruit units.")
    stoneBarracksButton:setTooltip("StoneBarracks",
        getCostAndType("StoneBarracks") .. "\nA building allowing you to recruit units.")
    engineersGuildButton:setTooltip("EngineersGuild",
        getCostAndType("EngineersGuild") .. "\nA building allowing you to recruit siege units.")
    tunnelersGuildButton:setTooltip("TunnelersGuild",
        getCostAndType("TunnelersGuild") .. "\nA building allowing you to recruit tunnelers.")
end

el.buttons.castleButton:setOnClick(
    function(self)
        ActionBar:showGroup("castle", _G.fx["metpush7"])
        displayTooltips()
    end)

ActionBar:registerGroup("castle",
    { castleButton, woodenWallButton, walkableWoodenWallButton, woodenTowerButton, woodenGateEastButton,
        woodenGateSouthButton, barracksButton, stoneBarracksButton, engineersGuildButton, tunnelersGuildButton,
        backButton, destroyButton })
