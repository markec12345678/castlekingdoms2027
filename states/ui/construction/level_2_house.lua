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
    { button = hovelButton, name = "House", description = "Increases maximum population limit.", tier = 1 },
    {
        button = chapelButton,
        name = "Chapel",
        description =
        "Increase your popularity with religion. Currently not functional.",
        tier = 2
    },
    {
        button = churchButton,
        name = "Church",
        description =
        "Increase your popularity with religion. Currently not functional.",
        tier = 3
    },
    {
        button = cathedralButton,
        name = "Cathedral",
        description =
        "Increase your popularity with religion. Currently not functional.",
        tier = 4
    },
    {
        button = apothecaryButton,
        name = "Apothecary",
        description =
        "Currently not functional.",
        tier = 4
    }
}

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "house" then return end

    for _, building in ipairs(buildings) do
        local tooltipText = getCostAndType(building.name, building.description)
        building.button:setTooltip(building.name, tooltipText)
        if building.tier <= _G.state.tier then
            building.button:enable()
        else
            building.button:disable()
            building.button:setTooltip("You need to upgrade your keep to build this")
        end
    end
    local lockedList = _G.MissionController:getLockedBuildings()
    local buttonList = {
        hovel = hovelButton,
        positiveBuildings = positiveBuildingButton,
        chapel = chapelButton,
        church = churchButton,
        cathedral = cathedralButton,
    }

    if lockedList ~= nil then
        for _, value in ipairs(lockedList) do
            local button = buttonList[value]
            if button then
                button:disable("Not available in this mission")
            end
        end
    end
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnGoldChanged, displayTooltips)
_G.bus.on(Events.OnTierUpgraded, displayTooltips)

el.buttons.houseButton:setOnClick(function(self)
    ActionBar:showGroup("house", _G.fx["metpush13"])
    displayTooltips()
end)


positiveBuildingButton:setOnClick(function(self)
    ActionBar:showGroup("positiveBuildings")
end)

ActionBar:registerGroup("house",
    { hovelButton, positiveBuildingButton, chapelButton, churchButton, cathedralButton, apothecaryButton, backButton, destroyButton })

package.loaded["states.ui.construction.level_3_positive_buildings"] = love.filesystem.load(
    "states/ui/construction/level_3_positive_buildings.lua")(el, backButton, destroyButton, getCostAndType)
