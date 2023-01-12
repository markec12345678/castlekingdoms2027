local el, backButton, destroyButton, getCostAndType = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")

local armorerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/armorer_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 1, true)
armorerButton:setOnClick(function(self)
    _G.BuildController:set("Armorer", function()
        armorerButton:select()
    end)
    ActionBar:selectButton(armorerButton)
end)


local armouryButton = ActionBarButton:new(love.graphics.newImage("assets/ui/armoury_arms_ab.png"), states.STATE_INGAME_CONSTRUCTION, 2, true, nil)
armouryButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "Armoury", function()
            armouryButton:unselect()
        end)
        ActionBar:selectButton(armouryButton)
    end)


local function displayTooltips()
    armorerButton:setTooltip("Armorer", getCostAndType("Armorer") .. "\nMakes armor from iron")
    armouryButton:setTooltip("Armoury",
        getCostAndType("Armoury") .. "\nWeapons and armour is stored here, which is used by troops from the barracks upon recruitment")
end

el.buttons.shieldButton:setOnClick(function(self)
    ActionBar:showGroup("shield")
    displayTooltips()
end)


ActionBar:registerGroup("shield", {armorerButton, armouryButton, backButton, destroyButton})
