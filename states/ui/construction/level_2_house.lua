local el, backButton, destroyButton, setBuildingsTooltips, disableUnavailableButtons = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')
local Events = require('objects.Enums.Events')
local SID = require("objects.Controllers.LanguageController").lines

-- Hovel
local hovelButton = ActionBarButton:new(love.graphics.newImage('assets/ui/hovel_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)
hovelButton:setTooltip("Houses", "Houses to increase your population")

-- PositiveBuilding
local positiveBuildingButton = ActionBarButton:new(love.graphics.newImage('assets/ui/large_garden_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true)
positiveBuildingButton:setTooltip("Good Things", "Gardens, Statues and Entertainment to increse your popularity.")

-- Chapel
local chapelButton = ActionBarButton:new(love.graphics.newImage('assets/ui/chapel_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, true)

chapelButton:setOnClick(function(self)
    _G.BuildController:set("Chapel", function()
        chapelButton:select()
    end)
    ActionBar:selectButton(chapelButton)
end)

-- Church
local churchButton = ActionBarButton:new(love.graphics.newImage('assets/ui/church_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 4, true)

churchButton:setOnClick(function(self)
    _G.BuildController:set("Church", function()
        churchButton:select()
    end)
    ActionBar:selectButton(churchButton)
end)

-- Cathedral
local cathedralButton = ActionBarButton:new(love.graphics.newImage('assets/ui/cathedral_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 5, true)

cathedralButton:setOnClick(function(self)
    _G.BuildController:set("Cathedral", function()
        cathedralButton:select()
    end)
    ActionBar:selectButton(cathedralButton)
end)

-- Apothecary
local apothecaryButton = ActionBarButton:new(love.graphics.newImage('assets/ui/apothecary_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 6, true)

apothecaryButton:setOnClick(function(self)
    _G.BuildController:set("Apothecary", function()
        apothecaryButton:select()
    end)
    ActionBar:selectButton(apothecaryButton)
end)

local buildings = {
    {
        button = chapelButton,
        name = SID.buildings.chapel.name,
        description = SID.buildings.chapel.description,
        tier = 2
    },
    {
        button = churchButton,
        name = SID.buildings.church.name,
        description = SID.buildings.church.description,
        tier = 3
    },
    {
        button = cathedralButton,
        name = SID.buildings.cathedral.name,
        description = SID.buildings.cathedral.description,
        tier = 4
    },
    {
        button = apothecaryButton,
        name = SID.buildings.apothecary.name,
        description = SID.buildings.apothecary.description,
        tier = 4
    }
}

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "house" then return end

    setBuildingsTooltips(buildings)

    local buttonList = {
        houses = hovelButton,
        positiveBuildings = positiveBuildingButton,
        chapel = chapelButton,
        church = churchButton,
        cathedral = cathedralButton,
    }

    disableUnavailableButtons(buttonList)
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnGoldChanged, displayTooltips)
_G.bus.on(Events.OnTierUpgraded, displayTooltips)

el.buttons.houseButton:setOnClick(function(self)
    ActionBar:showGroup("house", _G.fx["metpush13"])
    displayTooltips()
end)

hovelButton:setOnClick(function(self)
    ActionBar:showGroup("houses")
end)

positiveBuildingButton:setOnClick(function(self)
    ActionBar:showGroup("positiveBuildings")
end)

local elements = {
    buttons = {
        hovelButton = hovelButton,
        positiveBuildingButton = positiveBuildingButton
    },
}

ActionBar:registerGroup("house",
    { hovelButton, positiveBuildingButton, chapelButton, churchButton, cathedralButton, apothecaryButton, backButton,
        destroyButton })

package.loaded["states.ui.construction.level_3_positive_buildings"] = love.filesystem.load(
    "states/ui/construction/level_3_positive_buildings.lua")(elements, backButton, destroyButton, setBuildingsTooltips)
package.loaded["states.ui.construction.level_3_house"] = love.filesystem.load(
    "states/ui/construction/level_3_house.lua")(elements, backButton, destroyButton, setBuildingsTooltips)
