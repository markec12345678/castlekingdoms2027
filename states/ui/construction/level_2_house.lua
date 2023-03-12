local el, backButton, destroyButton, getCostAndType = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')

-- Hovel
local hovelButton = ActionBarButton:new(love.graphics.newImage('assets/ui/hovel_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)

hovelButton:setOnClick(function(self)
    _G.BuildController:set("House", function()
        hovelButton:select()
    end)
    ActionBar:selectButton(hovelButton)
end)

-- Chapel
local chapelButton = ActionBarButton:new(love.graphics.newImage('assets/ui/chapel_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true)

chapelButton:setOnClick(function(self)
    _G.BuildController:set("Chapel", function()
        chapelButton:select()
    end)
    ActionBar:selectButton(chapelButton)
end)

-- Church
local churchButton = ActionBarButton:new(love.graphics.newImage('assets/ui/church_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, true)

churchButton:setOnClick(function(self)
    _G.BuildController:set("Church", function()
        churchButton:select()
    end)
    ActionBar:selectButton(churchButton)
end)

local cathedralButton = ActionBarButton:new(love.graphics.newImage('assets/ui/cathedral_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 4, true)

cathedralButton:setOnClick(function(self)
    _G.BuildController:set("Cathedral", function()
        cathedralButton:select()
    end)
    ActionBar:selectButton(cathedralButton)
end)


local function displayTooltips()
    hovelButton:setTooltip("Hovel", getCostAndType("House") .. "\nIncreases maximum population limit.")
    chapelButton:setTooltip("Chapel", getCostAndType("Chapel") .. "\nIncrease your popularity with religion. Currently not functional.")
    churchButton:setTooltip("Church", getCostAndType("Church") .. "\nIncrease your popularity with religion. Currently not functional.")
    cathedralButton:setTooltip("Cathedral", getCostAndType("Cathedral") .. "\nIncrease your popularity with religion. Currently not functional.")
end

el.buttons.houseButton:setOnClick(function(self)
    ActionBar:showGroup("house", _G.fx["metpush13"])
    displayTooltips()
end)

ActionBar:registerGroup("house", { hovelButton, chapelButton, churchButton, cathedralButton, backButton, destroyButton })
