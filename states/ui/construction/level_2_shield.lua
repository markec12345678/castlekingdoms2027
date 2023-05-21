local el, backButton, destroyButton, getCostAndType = ...

local states = require("states.ui.states")
local ActionBarButton = require("states.ui.ActionBarButton")
local ActionBar = require("states.ui.ActionBar")
local Events = require("objects.Enums.Events")

local armouryButton = ActionBarButton:new(love.graphics.newImage("assets/ui/armoury_arms_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 1, true, nil)
armouryButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "Armoury", function()
                armouryButton:unselect()
            end)
        ActionBar:selectButton(armouryButton)
    end)

local fletcherButton = ActionBarButton:new(love.graphics.newImage("assets/ui/fletcher_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 2, true, nil)
fletcherButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "FletcherWorkshop", function()
                fletcherButton:unselect()
            end)
        ActionBar:selectButton(fletcherButton)
    end)

local poleturnerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/poleturner_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 3, true, nil)
poleturnerButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "PoleturnerWorkshop", function()
                poleturnerButton:unselect()
            end)
        ActionBar:selectButton(poleturnerButton)
    end)

local blacksmithButton = ActionBarButton:new(love.graphics.newImage("assets/ui/blacksmith_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 4, true)
blacksmithButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "BlacksmithWorkshop", function()
                blacksmithButton:unselect()
            end)
        ActionBar:selectButton(blacksmithButton)
    end)

local armorerButton = ActionBarButton:new(love.graphics.newImage("assets/ui/armorer_ab.png"),
    states.STATE_INGAME_CONSTRUCTION, 5, false)
armorerButton:setOnClick(function(self)
    _G.BuildController:set("Armorer", function()
        armorerButton:select()
    end)
    ActionBar:selectButton(armorerButton)
end)

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "shield" then return end
    local buildings = {
        {
            button = armouryButton,
            name = "Armoury",
            description =
            "Weapons and armour is stored here, which is used by troops from the barracks upon recruitment."
        },
        {
            button = fletcherButton,
            name = "FletcherWorkshop",
            description =
            "Produces bows and crossbows from wood."
        },
        { button = poleturnerButton, name = "PoleturnerWorkshop", description = "Produces spears and pikes from wood." },
        { button = blacksmithButton, name = "BlacksmithWorkshop", description = "Produces swords and maces from iron." },
        { button = armorerButton,    name = "Armorer",            description = "Makes armor from iron." }
    }

    for _, building in ipairs(buildings) do
        local tooltipText = getCostAndType(building.name, building.description)
        building.button:setTooltip(building.name, tooltipText)
    end
    local lockedList = _G.MissionController:getLockedBuildings()
    local buttonList = {
        armoury = armouryButton,
        fletcherWorkshop = fletcherButton,
        poleturnerWorkshop = poleturnerButton,
        blacksmithWorkshop = blacksmithButton,
        armorerWorkshop = armorerButton,
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
_G.bus.on(Events.OnGoldChanged, displayTooltips)

el.buttons.shieldButton:setOnClick(function(self)
    ActionBar:showGroup("shield", _G.fx["metpush1"])
    displayTooltips()
end)


ActionBar:registerGroup("shield",
    { armouryButton, fletcherButton, poleturnerButton, blacksmithButton, armorerButton, backButton, destroyButton })
