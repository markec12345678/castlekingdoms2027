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


local armouryButton = ActionBarButton:new(love.graphics.newImage("assets/ui/armoury_arms_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 2, true, nil)
armouryButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "Armoury", function()
            armouryButton:unselect()
        end)
        ActionBar:selectButton(armouryButton)
    end)

local fletcherButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fletcher_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 3, true, nil)
fletcherButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "FletcherWorkshop", function()
            fletcherButton:unselect()
        end)
        ActionBar:selectButton(fletcherButton)
    end)

    local blacksmithButton = ActionBarButton:new(love.graphics.newImage("assets/ui/blacksmith_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 4)
    blacksmithButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "BlacksmithWorkshop", function()
                blacksmithButton:unselect()
        end)
        ActionBar:selectButton(blacksmithButton)
    end)

local function displayTooltips()
    armorerButton:setTooltip("Armorer", getCostAndType("Armorer") .. "\nMakes armor from iron")
    armouryButton:setTooltip("Armoury",
        getCostAndType("Armoury") ..
        "\nWeapons and armour is stored here, which is used by troops from the barracks upon recruitment")
    fletcherButton:setTooltip("FletcherWorkshop",
        getCostAndType("FletcherWorkshop") ..
        "\nProduces bows and crossbows from wood")
    blacksmithButton:setTooltip("BlacksmithWorkshop", getCostAndType("BlacksmithWorkshop") .. "\nProduces swords and maces from iron")
end

el.buttons.shieldButton:setOnClick(function(self)
    ActionBar:showGroup("shield")
    displayTooltips()
end)


ActionBar:registerGroup("shield", { armorerButton, armouryButton, fletcherButton, blacksmithButton, backButton, destroyButton })
