local el, backButton, destroyButton, getCostAndType = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')

local maypoleButton = ActionBarButton:new(love.graphics.newImage("assets/ui/maypole_ab.png"), states.STATE_INGAME_CONSTRUCTION, 1, false, nil)
maypoleButton:setTooltip("Maypole", "Requires 2 wood and 30 gold.")
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
smallPondButton:setTooltip("Small Pond", "Requires 30 gold.")
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
largePondButton:setTooltip("Large Pond", "Requires 30 gold.")
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
smallGardenButton:setTooltip("Small Garden", "Requires 30 gold.")
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
mediumGardenButton:setTooltip("Medium Garden", "Requires 30 gold.")
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
largeGardenButton:setTooltip("Large Garden", "Requires 30 gold.")
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

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "woodenBuildings" then return end
    local buildings = {
        {button = maypoleButton, name = "Maypole", description = "\nA tall wooden pole, around which a maypole dance often takes place."},
        {button = smallPondButton, name = "Small Pond", description = "\nA small pond."},
        {button = largePondButton, name = "Large Pond", description = "\nA large pond."},
        {button = smallGardenButton, name = "Small Garden", description = "\nA small garden."},
        {button = mediumGardenButton, name = "Medium Garden", description = "\nA medium-sized garden."},
        {button = largeGardenButton, name = "Large Garden", description = "\nA large garden."}
    }
    for _, building in ipairs(buildings) do
        local table = getCostAndType(building.name)
        building.button:setTooltip(building.name, table.costAndType .. building.description)
        if not table.affordable then
            building.button.tooltip:SetText({{color = {1, 0, 0, 1}}, table.costAndType}, building.name)
        end
    end
end

local Events = require("objects.Enums.Events")
_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)

ActionBar:registerGroup("positiveBuildings", {maypoleButton, smallPondButton, largePondButton, smallGardenButton, mediumGardenButton, largeGardenButton, backButton, destroyButton})
