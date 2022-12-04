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
            castleButton:setTooltip("Keep", getCostAndType("keep"))
            castleButton:setOnClick(
                function()
                    local upgraded = _G.BuildController:upgradeKeep(3)
                    if upgraded then
                        castleButton:setImage(fortressImage)
                        castleButton:setTooltip("Fortress", getCostAndType("fortress"))
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
            "wooden_wall", function()
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
            "walkable_wooden_wall", function()
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
            "wooden_tower", function()
            woodenTowerButton:unselect()
        end)
        ActionBar:selectButton(woodenTowerButton)
    end)

local woodenGateEastButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_gate_east.png"),
    states.STATE_INGAME_CONSTRUCTION, 5, false, nil)
woodenGateEastButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "wooden_gate_east", function()
            woodenGateEastButton:unselect()
        end)
        ActionBar:selectButton(woodenGateEastButton)
    end)

local woodenGateSouthButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_gate_south.png"),
    states.STATE_INGAME_CONSTRUCTION, 6, false, nil)
woodenGateSouthButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "wooden_gate_south", function()
            woodenGateSouthButton:unselect()
        end)
        ActionBar:selectButton(woodenGateSouthButton)
    end)

local function displayTooltips()
    castleButton:setTooltip("WoodenKeep", getCostAndType("wooden_keep"))
    walkableWoodenWallButton:setTooltip("Walkable Wooden Wall",
        getCostAndType("walkable_wooden_wall") .. "\nA defensive wall made that is walkable on the top")
    woodenTowerButton:setTooltip("Wooden Tower",
        getCostAndType("wooden_tower") .. "\nA wooden tower that is missing some stairs apparently")
    woodenGateEastButton:setTooltip("Wooden Gate",
        getCostAndType("wooden_gate_east") .. "\nA wooden gate that can let friendly units pass through")
    woodenGateSouthButton:setTooltip("Wooden Gate",
        getCostAndType("wooden_gate_south") .. "\nA wooden gate that can let friendly units pass through")
    woodenWallButton:setTooltip("Wooden Wall",
        getCostAndType("wooden_wall") .. "\nA defensive wall made from sharpened tree trunks")
end

el.buttons.castleButton:setOnClick(
    function(self)
        ActionBar:showGroup("castle")
        displayTooltips()
    end)

ActionBar:registerGroup("castle",
    {castleButton, woodenWallButton, walkableWoodenWallButton, woodenTowerButton, woodenGateEastButton,
        woodenGateSouthButton, backButton, destroyButton})
