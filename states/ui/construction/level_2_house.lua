local el, backButton, destroyButton, getCostAndType = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')
local Events = require('objects.Enums.Events')

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
    if ActionBar:getCurrentGroup() ~= "house" then return end
    local buildings = {
        {button = hovelButton, name = "House", description = "\nIncreases maximum population limit."},
        {button = chapelButton, name = "Chapel", description = "\nIncrease your popularity with religion. Currently not functional."},
        {button = churchButton, name = "Church", description = "\nIncrease your popularity with religion. Currently not functional."},
        {button = cathedralButton, name = "Cathedral", description = "\nIncrease your popularity with religion. Currently not functional."}
    }

    for _, building in ipairs(buildings) do
        local table = getCostAndType(building.name)
        building.button:setTooltip(building.name, table.costAndType .. building.description)
        if not table.affordable then
            building.button.tooltip:SetText({{color = {1, 0, 0, 1}}, table.costAndType}, building.name)
        end
    end
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)

el.buttons.houseButton:setOnClick(function(self)
    ActionBar:showGroup("house", _G.fx["metpush13"])
    displayTooltips()
end)

ActionBar:registerGroup("house", {hovelButton, chapelButton, churchButton, cathedralButton, backButton, destroyButton})
