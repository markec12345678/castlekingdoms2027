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
                                    castleButton:setOnClick(function()
                                    end)
                                end
                            end
                        )
                    end
                end
            )
        end
    end)
--castleButton:setTooltip("WoodenKeep", "Requires 50 Wood")

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

local function displayTooltips()
    castleButton:setTooltip("WoodenKeep", getCostAndType("WoodenKeep"))
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

local woodenBuildings = ActionBarButton:new(love.graphics.newImage('assets/ui/wooden_wall_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true)
woodenBuildings:setTooltip("Wooden Structures", "Towers, gates and walls.")

woodenBuildings:setOnClick(function(self)
    ActionBar:showGroup("woodenBuildings")
end)

local stoneBuildings = ActionBarButton:new(love.graphics.newImage('assets/ui/stone_wall_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, true)
stoneBuildings:setTooltip("Stone Structures", "Towers, gates and walls.")

stoneBuildings:setOnClick(function(self)
    ActionBar:showGroup("stoneBuildings")
end)

local elements = {
    buttons = {
        stoneBuildings = stoneBuildings,
        woodenBuildings = woodenBuildings
    },
}


ActionBar:registerGroup("castle",
    { castleButton, woodenBuildings, stoneBuildings, barracksButton, stoneBarracksButton, engineersGuildButton,
        tunnelersGuildButton, backButton, destroyButton })

package.loaded["states.ui.construction.level_3_castleWood"] = love.filesystem.load(
        "states/ui/construction/level_3_castleWood.lua")(elements, backButton, destroyButton, getCostAndType)
package.loaded["states.ui.construction.level_3_castleStone"] = love.filesystem.load(
        "states/ui/construction/level_3_castleStone.lua")(elements, backButton, destroyButton, getCostAndType)
