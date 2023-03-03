local el, backButton, destroyButton, getCostAndType = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')

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
    granaryButton:setTooltip("Granary", getCostAndType("Granary") .. "\nIncreases food capacity.")
    hunterButton:setTooltip("Hunter's hut", "Not implemented yet.")
    appleFarmButton:setTooltip("Orchard", getCostAndType("Orchard") .. "\nProduces apples.")
    cheeseFarmButton:setTooltip("Dairy farm", "Not implemented yet.")
    wheatFarmButton:setTooltip("Wheat farm",
        getCostAndType("WheatFarm") .. "\nProduces wheat which can be processed into flour.")
    hopsFarmButton:setTooltip("Hops farm",
        getCostAndType("HopsFarm") .. "\nProduces hops which can be processed into ale.")
end

el.buttons.appleButton:setOnClick(function(self)
    ActionBar:showGroup("farms", _G.fx["metpush15"])
    displayTooltips()
end)

ActionBar:registerGroup("farms",
    { hunterButton, appleFarmButton, cheeseFarmButton, wheatFarmButton, hopsFarmButton, granaryButton, backButton,
        destroyButton })
