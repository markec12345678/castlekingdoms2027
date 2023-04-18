local el, backButton, destroyButton, getCostAndType = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")
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

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "castle" then return end
    local buildings = {
        {button = castleButton, name = "WoodenKeep", description = ""},
        {button = barracksButton, name = "Barracks", description = "\nA building allowing you to recruit units."},
        {button = stoneBarracksButton, name = "StoneBarracks", description = "\nA building allowing you to recruit units."},
        {button = engineersGuildButton, name = "EngineersGuild", description = "\nA building allowing you to recruit siege units."},
        {button = tunnelersGuildButton, name = "TunnelersGuild", description = "\nA building allowing you to recruit tunnelers."}
    }

    for _, building in ipairs(buildings) do
        local table = getCostAndType(building.name)
        building.button:setTooltip(building.name, table.costAndType .. building.description)
        if not table.affordable then
            building.button.tooltip:SetText({{color = {1, 0, 0, 1}}, table.costAndType}, building.name)
        end
    end
    local lockedList = _G.MissionController:getLockedBuildings()
    local buttonList = {
        castle = castleButton,
        woodenBuildings = woodenBuildings,
        stoneBuildings = stoneBuildings,
        woodenbarracks = barracksButton,
        stoneBarracks = stoneBarracksButton,
        engineersGuild = engineersGuildButton,
        tunnelersGuild = tunnelersGuildButton
    }
    if lockedList ~= nil then
        for _, value in ipairs(lockedList) do
            local button = buttonList[value]
            if button then
                button.disabled = true
                button.background.enabled = not button.disabled
                button.foreground:SetColor(0.6, 0.6, 0.6, 0.6)
                button:setTooltip("Not available in this mission")
            end
        end
    end
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)

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


ActionBar:registerGroup("castle",
    {castleButton, woodenBuildings, stoneBuildings, barracksButton, stoneBarracksButton, engineersGuildButton,
        tunnelersGuildButton, backButton, destroyButton})

package.loaded["states.ui.construction.level_3_castleWood"] = love.filesystem.load(
    "states/ui/construction/level_3_castleWood.lua")(elements, backButton, destroyButton, getCostAndType)
package.loaded["states.ui.construction.level_3_castleStone"] = love.filesystem.load(
    "states/ui/construction/level_3_castleStone.lua")(elements, backButton, destroyButton, getCostAndType)
