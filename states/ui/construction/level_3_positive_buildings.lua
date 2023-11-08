local el, backButton, destroyButton, setBuildingsTooltips = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')
local SID = require("objects.Controllers.LanguageController").lines

local maypoleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/maypole_ab.png"), states.STATE_INGAME_CONSTRUCTION, 1, false, nil)
maypoleButton:disable()
maypoleButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "Maypole", function()
                maypoleButton:unselect()
            end
        )
        ActionBar:selectButton(maypoleButton)
    end
)

local smallPondButton = ActionBarButton:new(love.graphics.newImage("assets/ui/small_pond_ab.png"), states.STATE_INGAME_CONSTRUCTION, 2, false, nil)
smallPondButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "SmallPond", function()
                smallPondButton:unselect()
            end
        )
        ActionBar:selectButton(smallPondButton)
    end
)

local largePondButton = ActionBarButton:new(love.graphics.newImage("assets/ui/large_pond_ab.png"), states.STATE_INGAME_CONSTRUCTION, 3, false, nil)
largePondButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "LargePond", function()
                largePondButton:unselect()
            end
        )
        ActionBar:selectButton(largePondButton)
    end
)

local smallGardenButton = ActionBarButton:new(love.graphics.newImage("assets/ui/small_garden_ab.png"), states.STATE_INGAME_CONSTRUCTION, 4, false, nil)
smallGardenButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "SmallGarden", function()
                smallGardenButton:unselect()
            end
        )
        ActionBar:selectButton(smallGardenButton)
    end
)

local mediumGardenButton = ActionBarButton:new(love.graphics.newImage("assets/ui/medium_garden_ab.png"), states.STATE_INGAME_CONSTRUCTION, 5, false, nil)
mediumGardenButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "MediumGarden", function()
                mediumGardenButton:unselect()
            end
        )
        ActionBar:selectButton(mediumGardenButton)
    end
)

local largeGardenButton = ActionBarButton:new(love.graphics.newImage("assets/ui/large_garden_ab.png"), states.STATE_INGAME_CONSTRUCTION, 6, false, nil)
largeGardenButton:setOnClick(
    function(self)
        _G.BuildController:set(
            "LargeGarden", function()
                largeGardenButton:unselect()
            end
        )
        ActionBar:selectButton(largeGardenButton)
    end
)

local buildings = {
    { button = maypoleButton,      id = "Maypole",      name = SID.buildings.maypole.name,      description = SID.buildings.maypole.description,      tier = 4 },
    { button = smallPondButton,    id = "SmallPond",    name = SID.buildings.smallPond.name,    description = SID.buildings.smallPond.description,    tier = 4 },
    { button = largePondButton,    id = "LargePond",    name = SID.buildings.largePond.name,    description = SID.buildings.largePond.description,    tier = 4 },
    { button = smallGardenButton,  id = "SmallGarden",  name = SID.buildings.smallGarden.name,  description = SID.buildings.smallGarden.description,  tier = 4 },
    { button = mediumGardenButton, id = "MediumGarden", name = SID.buildings.mediumGarden.name, description = SID.buildings.mediumGarden.description, tier = 4 },
    { button = largeGardenButton,  id = "LargeGarden",  name = SID.buildings.largeGarden.name,  description = SID.buildings.largeGarden.description,  tier = 4 }
}

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "positiveBuildings" then return end

    setBuildingsTooltips(buildings)
end

local Events = require("objects.Enums.Events")
_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnGoldChanged, displayTooltips)
_G.bus.on(Events.OnTierUpgraded, displayTooltips)

ActionBar:registerGroup("positiveBuildings", { maypoleButton, smallPondButton, largePondButton, smallGardenButton, mediumGardenButton, largeGardenButton, backButton, destroyButton }, displayTooltips)
