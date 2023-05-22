local el, backButton, destroyButton, getCostAndType = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')
local Events = require('objects.Enums.Events')

local granaryButton = ActionBarButton:new(love.graphics.newImage('assets/ui/granary_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)

granaryButton:setOnClick(function(self)
    _G.BuildController:set("Granary", function()
        granaryButton:select()
    end)
    ActionBar:selectButton(granaryButton)
end)

local hunterButton = ActionBarButton:new(love.graphics.newImage('assets/ui/hunter_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true, nil, true)

local appleFarmButton = ActionBarButton:new(love.graphics.newImage('assets/ui/apple_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, true)
appleFarmButton:setOnClick(function(self)
    _G.BuildController:set("Orchard", function()
        appleFarmButton:select()
    end)
    ActionBar:selectButton(appleFarmButton)
end)

local cheeseFarmButton = ActionBarButton:new(love.graphics.newImage('assets/ui/cheese_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 4, true)
cheeseFarmButton:setOnClick(function(self)
    _G.BuildController:set("DairyFarm", function()
        cheeseFarmButton:select()
    end)
    ActionBar:selectButton(cheeseFarmButton)
end)

local wheatFarmButton = ActionBarButton:new(love.graphics.newImage('assets/ui/wheat_farm_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 5, true)
wheatFarmButton:setOnClick(function(self)
    _G.BuildController:set("WheatFarm", function()
        wheatFarmButton:select()
    end)
    ActionBar:selectButton(wheatFarmButton)
end)

local hopsFarmButton = ActionBarButton:new(love.graphics.newImage('assets/ui/hops_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 6, false, nil)
hopsFarmButton:setOnClick(function(self)
    _G.BuildController:set("HopsFarm", function()
        hopsFarmButton:select()
    end)
    ActionBar:selectButton(hopsFarmButton)
end)



local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "farms" then return end
    local buildings = {
        { button = granaryButton,   name = "Granary", description = "Increases food capacity." },
        { button = appleFarmButton, name = "Orchard", description = "Produces apples." },
        {
            button = wheatFarmButton,
            name = "WheatFarm",
            description = "Produces wheat which can be processed into flour."
        },
        { button = cheeseFarmButton, name = "DairyFarm", description = "Produces cheese." },
        { button = hopsFarmButton,   name = "HopsFarm",  description = "Produces hops which can be processed into ale." }
    }

    for _, building in ipairs(buildings) do
        local tooltipText = getCostAndType(building.name, building.description)
        building.button:setTooltip(building.name, tooltipText)
    end
    hunterButton:setTooltip("Hunter's hut", "Not implemented yet.")
    local lockedList = _G.MissionController:getLockedBuildings()
    local buttonList = {
        --hunter = hunterButton, NOT IMPLEMENTED YET
        appleFarm = appleFarmButton,
        dairyFarm = cheeseFarmButton,
        wheatFarm = wheatFarmButton,
        hopsFarm = hopsFarmButton,
        granary = granaryButton
    }
    for enabledButton, _ in pairs(buttonList) do
        local button = buttonList[enabledButton]
        if button then
            button.disabled = false
            button.background.enabled = not button.disabled
            button.foreground:SetColor(1, 1, 1, 1)
        end
    end
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

el.buttons.appleButton:setOnClick(function(self)
    ActionBar:showGroup("farms", _G.fx["metpush15"])
    displayTooltips()
end)

ActionBar:registerGroup("farms",
    { hunterButton, appleFarmButton, cheeseFarmButton, wheatFarmButton, hopsFarmButton, granaryButton, backButton,
        destroyButton })
