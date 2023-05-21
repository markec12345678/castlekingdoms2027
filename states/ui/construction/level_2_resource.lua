local el, backButton, destroyButton, getCostAndType = ...

local states = require('states.ui.states')
local ActionBarButton = require('states.ui.ActionBarButton')
local ActionBar = require('states.ui.ActionBar')
local Events = require('objects.Enums.Events')

local stockpileButton = ActionBarButton:new(love.graphics.newImage('assets/ui/stockpile_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 1, true)

stockpileButton:setOnClick(function(self)
    _G.BuildController:set("Stockpile", function()
        stockpileButton:select()
    end)
    ActionBar:selectButton(stockpileButton)
end)


local woodcutterButton = ActionBarButton:new(love.graphics.newImage('assets/ui/woodcutter_hut_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 2, true)

woodcutterButton:setOnClick(function(self)
    _G.BuildController:set("WoodcutterHut", function()
        woodcutterButton:select()
    end)
    ActionBar:selectButton(woodcutterButton)
end)


local quarryButton = ActionBarButton:new(love.graphics.newImage('assets/ui/quarry_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 3, true)

quarryButton:setOnClick(function(self)
    _G.BuildController:set("Quarry", function()
        quarryButton:select()
    end)
    ActionBar:selectButton(quarryButton)
end)


local oxButton = ActionBarButton:new(love.graphics.newImage('assets/ui/ox_ab.png'), states.STATE_INGAME_CONSTRUCTION, 4,
    true)

oxButton:setOnClick(function(self)
    _G.BuildController:set("OxTether", function()
        oxButton:select()
    end)
    ActionBar:selectButton(oxButton)
end)

local ironMine = ActionBarButton:new(love.graphics.newImage('assets/ui/iron_mine_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 5, true)

ironMine:setOnClick(function(self)
    _G.BuildController:set("Mine", function()
        ironMine:select()
    end)
    ActionBar:selectButton(ironMine)
end)

local pitchRigButton = ActionBarButton:new(love.graphics.newImage('assets/ui/pitch_rig_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 6, true, nil, true)

local marketButton = ActionBarButton:new(love.graphics.newImage('assets/ui/market_ab.png'),
    states.STATE_INGAME_CONSTRUCTION, 7, false)

marketButton:setOnClick(function(self)
    _G.BuildController:set("Market", function()
        marketButton:unselect()
    end)
    ActionBar:selectButton(marketButton)
end)

local function displayTooltips()
    if ActionBar:getCurrentGroup() ~= "resource" then return end
    local buildings = {
        { button = woodcutterButton, name = "WoodcutterHut", description = "Cuts down nearby trees to produce wood." },
        {
            button = oxButton,
            name = "OxTether",
            description =
            "Transport stone from the quarry to the stockpile."
        },
        {
            button = quarryButton,
            name = "Quarry",
            description =
            "Produces stone blocks from the ground resource."
        },
        {
            button = stockpileButton,
            name = "Stockpile",
            description =
            "Increases resource capacity.\nMust be placed adjacent to a stockpile."
        },
        { button = ironMine,         name = "Mine",          description = "Produces iron ingots from ground iron ore." },
        { button = marketButton,     name = "Market",        description = "Allows you to trade your goods." }
    }
    for _, building in ipairs(buildings) do
        local tooltipText = getCostAndType(building.name, building.description)
        building.button:setTooltip(building.name, tooltipText)
    end
    local lockedList = _G.MissionController:getLockedBuildings()
    local buttonList = {
        stockpile = stockpileButton,
        woodcutter = woodcutterButton,
        quarry = quarryButton,
        ox = oxButton,
        ironMine = ironMine,
        pitchRig = pitchRigButton,
        market = marketButton
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
    pitchRigButton:setTooltip("Pitch Rig", "Not implemented yet.")
end

_G.bus.on(Events.OnResourceStore, displayTooltips)
_G.bus.on(Events.OnResourceTake, displayTooltips)
_G.bus.on(Events.OnGoldChanged, displayTooltips)

el.buttons.hammerButton:setOnClick(function(self)
    ActionBar:showGroup("resource", _G.fx["metpush12"])
    displayTooltips()
end)
ActionBar:registerGroup("resource",
    { stockpileButton, woodcutterButton, quarryButton, oxButton, ironMine, pitchRigButton, marketButton, backButton,
        destroyButton })
