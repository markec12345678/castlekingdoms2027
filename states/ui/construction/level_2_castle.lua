local el, setBuildingsTooltips, disableUnavailableButtons = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")
local SID = require("objects.Controllers.LanguageController").lines
local createBackButton = require("states.ui.construction.back_button_factory")

local castleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/wooden_keep_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 1, false, nil)
local barracksButton = ActionBarButton:new(love.graphics.newImage("assets/ui/barracks_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 4, false, nil)
barracksButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "Barracks", function()
                barracksButton:unselect()
            end)
        ActionBar:selectButton(barracksButton)
    end)

local stoneBarracksButton = ActionBarButton:new(love.graphics.newImage("assets/ui/stoneBarracks_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 5, false, nil)
stoneBarracksButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "StoneBarracks", function()
                stoneBarracksButton:unselect()
            end)
        ActionBar:selectButton(stoneBarracksButton)
    end)

local engineersGuildButton = ActionBarButton:new(love.graphics.newImage("assets/ui/engineersGuild_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 6, false, nil)
engineersGuildButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "EngineersGuild", function()
                engineersGuildButton:unselect()
            end)
        ActionBar:selectButton(engineersGuildButton)
    end)

local tunnelersGuildButton = ActionBarButton:new(love.graphics.newImage("assets/ui/tunnelersGuild_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 7, false, nil)
tunnelersGuildButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "TunnelersGuild", function()
                tunnelersGuildButton:unselect()
            end)
        ActionBar:selectButton(tunnelersGuildButton)
    end)

local stableButton = ActionBarButton:new(love.graphics.newImage("assets/ui/stable_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 8, false, nil)
stableButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "Stable", function()
                stableButton:unselect()
            end)
        ActionBar:selectButton(stableButton)
    end)

local woodenBuildings = ActionBarButton:new(love.graphics.newImage('assets/ui/fortifications/wooden/wooden_wall_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true)
woodenBuildings:setTooltip(SID.tips.actionBar.woodenStructures.title, SID.tips.actionBar.woodenStructures.title.desc)

woodenBuildings:setOnClick(function(self)
    ActionBar:showGroup("woodenBuildings")
end)

local stoneBuildings = ActionBarButton:new(love.graphics.newImage('assets/ui/fortifications/stone/stone_wall_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, true)
stoneBuildings:setTooltip(SID.tips.actionBar.stoneStructures.title, SID.tips.actionBar.stoneStructures.title.desc)

stoneBuildings:setOnClick(function(self)
    ActionBar:showGroup("stoneBuildings")
end)


local buildings = {
    { button = castleButton,         id = "WoodenKeep",     name = SID.buildings.woodenKeep.name,     description = SID.buildings.woodenKeep.description,     tier = 1 },
    { button = barracksButton,       id = "Barracks",       name = SID.buildings.barracks.name,       description = SID.buildings.barracks.description,       tier = 2 },
    { button = stoneBarracksButton,  id = "StoneBarracks",  name = SID.buildings.stoneBarracks.name,  description = SID.buildings.stoneBarracks.description,  tier = 3 },
    { button = engineersGuildButton, id = "EngineersGuild", name = SID.buildings.engineersGuild.name, description = SID.buildings.engineersGuild.description, tier = 4 },
    { button = tunnelersGuildButton, id = "TunnelersGuild", name = SID.buildings.tunnelersGuild.name, description = SID.buildings.tunnelersGuild.description, tier = 4 },
    { button = stableButton,         id = "Stable",         name = SID.buildings.stable.name,         description = SID.buildings.stable.description,         tier = 3 }

}

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "castle" then return end

    setBuildingsTooltips(buildings)

    local buttonList = {
        castle = castleButton,
        woodenBuildings = woodenBuildings,
        stoneBuildings = stoneBuildings,
        woodenbarracks = barracksButton,
        stoneBarracks = stoneBarracksButton,
        engineersGuild = engineersGuildButton,
        tunnelersGuild = tunnelersGuildButton,
        stable = stableButton,
    }

    disableUnavailableButtons(buttonList)
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnGoldChanged, displayTooltips)
_G.bus.on(Events.OnTierUpgraded, displayTooltips)

el.buttons.castleButton:setOnClick(
    function(self)
        ActionBar:showGroup("castle", _G.fx["metpush7"])
        displayTooltips()
    end)

local elements = {
    buttons = {
        stoneBuildings = stoneBuildings,
        woodenBuildings = woodenBuildings
    },
}


local createDestroyButton = require("states.ui.construction.destroy_button_factory")
ActionBar:registerGroup("castle",
    { castleButton, woodenBuildings, stoneBuildings, barracksButton, stoneBarracksButton, engineersGuildButton,
        tunnelersGuildButton, stableButton, createBackButton(), createDestroyButton() })

package.loaded["states.ui.construction.level_3_castleWood"] = love.filesystem.load(
    "states/ui/construction/level_3_castleWood.lua")(elements, setBuildingsTooltips)
package.loaded["states.ui.construction.level_3_castleStone"] = love.filesystem.load(
    "states/ui/construction/level_3_castleStone.lua")(elements, setBuildingsTooltips)

local keepImage = love.graphics.newImage("assets/ui/keep_ab.png")
local fortressImage = love.graphics.newImage("assets/ui/fortress_ab.png")
local strongholdImage = love.graphics.newImage("assets/ui/stronghold_ab.png")
local woodenImage = love.graphics.newImage("assets/ui/wooden_keep_ab.png")

function _G.updateKeepUpgradeButton(tier)
    if tier == 1 then
        buildings[1].id = "WoodenKeep"
        buildings[1].name = SID.buildings.woodenKeep.name
        buildings[1].description = SID.buildings.woodenKeep.description
        castleButton:setImage(woodenImage)
        castleButton:setOnClick(
            function()
                local upgraded = _G.BuildController:upgradeKeep(2)
                if upgraded then
                    castleButton:setImage(keepImage)
                    buildings[1].id = "Keep"
                    buildings[1].name = SID.buildings.keep.name
                    buildings[1].description = SID.buildings.keep.description
                    displayTooltips()
                    ActionBar:unlockTier(2)
                    castleButton:setOnClick(
                        function()
                            local upgraded = _G.BuildController:upgradeKeep(3)
                            if upgraded then
                                castleButton:setImage(fortressImage)
                                buildings[1].id = "Fortress"
                                buildings[1].name = SID.buildings.fortress.name
                                buildings[1].description = SID.buildings.fortress.description
                                displayTooltips()
                                ActionBar:unlockTier(3)
                                castleButton:setOnClick(
                                    function()
                                        local upgraded = _G.BuildController:upgradeKeep(4)
                                        if upgraded then
                                            castleButton:setImage(strongholdImage)
                                            buildings[1].id = "Stronghold"
                                            buildings[1].name = SID.buildings.stronghold.name
                                            buildings[1].description = SID.buildings.stronghold.description
                                            displayTooltips()
                                            ActionBar:unlockTier(4)
                                            castleButton.enabled = true
                                            castleButton.foreground.disablehover = true
                                            castleButton.foreground:SetColor(0.6, 0.6, 0.6, 0.6)
                                            castleButton:setOnClick(function()
                                            end)
                                        end
                                    end
                                )
                            end
                        end
                    )
                end
            end
        )
    elseif tier == 2 then
        castleButton:setImage(keepImage)
        buildings[1].id = "Keep"
        buildings[1].name = SID.buildings.keep.name
        buildings[1].description = SID.buildings.keep.description
        castleButton:setOnClick(
            function()
                local upgraded = _G.BuildController:upgradeKeep(3)
                if upgraded then
                    castleButton:setImage(fortressImage)
                    buildings[1].id = "Fortress"
                    buildings[1].name = SID.buildings.fortress.name
                    buildings[1].description = SID.buildings.fortress.description
                    displayTooltips()
                    ActionBar:unlockTier(3)
                    castleButton:setOnClick(
                        function()
                            local upgraded = _G.BuildController:upgradeKeep(4)
                            if upgraded then
                                castleButton:setImage(strongholdImage)
                                buildings[1].id = "Stronghold"
                                buildings[1].name = SID.buildings.stronghold.name
                                buildings[1].description = SID.buildings.stronghold.description
                                displayTooltips()
                                ActionBar:unlockTier(4)
                                castleButton.enabled = true
                                castleButton.foreground.disablehover = true
                                castleButton.foreground:SetColor(0.6, 0.6, 0.6, 0.6)
                                castleButton:setOnClick(function()
                                end)
                            end
                        end
                    )
                end
            end
        )
    elseif tier == 3 then
        castleButton:setImage(fortressImage)
        buildings[1].id = "Fortress"
        buildings[1].name = SID.buildings.fortress.name
        buildings[1].description = SID.buildings.fortress.description
        castleButton:setOnClick(
            function()
                local upgraded = _G.BuildController:upgradeKeep(4)
                if upgraded then
                    castleButton:setImage(strongholdImage)
                    buildings[1].id = "Stronghold"
                    buildings[1].name = SID.buildings.stronghold.name
                    buildings[1].description = SID.buildings.stronghold.description
                    displayTooltips()
                    ActionBar:unlockTier(4)
                    castleButton.enabled = true
                    castleButton.foreground.disablehover = true
                    castleButton.foreground:SetColor(0.6, 0.6, 0.6, 0.6)
                    castleButton:setOnClick(function()
                    end)
                end
            end
        )
    elseif tier == 4 then
        castleButton:setImage(strongholdImage)
        buildings[1].id = "Stronghold"
        buildings[1].name = SID.buildings.stronghold.name
        buildings[1].description = SID.buildings.stronghold.description
        castleButton:setOnClick(function()
        end)
    end
end

return castleButton, buildings, displayTooltips
