local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local base = require("states.ui.base")
local keybindManager = require("objects.Controllers.KeybindManager")
local EVENT = require("objects.Enums.KeyEvents")
local w, h = base.w, base.h
local Events = require "objects.Enums.Events"

local ACTION_BAR_USER_SCALE_W = 60
local ACTION_BAR_USER_SCALE_H = 20

if ACTION_BAR_USER_SCALE_W > 100 or ACTION_BAR_USER_SCALE_W < 5 then
    error("Action bar scale must be between 5 and 100")
end

local ActionBar = _G.class("ActionBar")
ActionBar.static.actionBarImage = love.graphics.newImage("assets/ui/action_bar.png")
ActionBar.static.actionBarGranaryImage = love.graphics.newImage("assets/ui/action_bar_granary.png")
ActionBar.static.actionBarStockpileImage = love.graphics.newImage("assets/ui/action_bar_market_main.png")
ActionBar.static.actionBarMarketImageMain = love.graphics.newImage("assets/ui/action_bar_market_main.png")
ActionBar.static.actionBarMarketImage = love.graphics.newImage("assets/ui/action_bar_market.png")
ActionBar.static.actionBarArmouryImage = love.graphics.newImage("assets/ui/action_bar_armoury.png")
ActionBar.static.actionBarKeepTaxImage = love.graphics.newImage("assets/ui/action_bar_keep_tax_main.png")
ActionBar.static.actionBarBarracksImage = love.graphics.newImage("assets/ui/action_bar_barracks.png")
ActionBar.static.actionBarHouseImage = love.graphics.newImage("assets/ui/action_bar_house.png")
ActionBar.static.actionBarUnits = love.graphics.newImage("assets/ui/action_bar_units.png")

function ActionBar:initialize()
    local element = loveframes.Create("image")
    element:SetState(states.STATE_INGAME_CONSTRUCTION)
    element:SetImage(ActionBar.actionBarImage)
    element:SetOffsetX(element:GetImageWidth() / 2)
    local scale_1 = (w.percent[ACTION_BAR_USER_SCALE_W]) / ActionBar.actionBarImage:getWidth()
    local scale_2 = (h.percent[ACTION_BAR_USER_SCALE_H]) / ActionBar.actionBarImage:getHeight()
    local scale = math.min(scale_1, scale_2)
    element:SetScale(scale, scale)
    element:SetPos(w.percent[50], h.percent[100] - element:GetImageHeight() * element:GetScaleY())
    local frPopularity = {
        x = element:GetX() - element:GetOffsetX() * scale + 1039 * scale,
        y = element:GetY() - element:GetOffsetY() * scale + 110 * scale,
        width = (1053 - 1020) * scale,
        height = (163 - 145) * scale
    }
    local frGold = {
        x = element:GetX() - element:GetOffsetX() * scale + 1018 * scale,
        y = element:GetY() - element:GetOffsetY() * scale + 133 * scale,
        width = (1053 - 1020) * scale,
        height = (163 - 145) * scale
    }
    local frPopulation = {
        x = element:GetX() - element:GetOffsetX() * scale + 1021 * scale,
        y = element:GetY() - element:GetOffsetY() * scale + 149 * scale,
        width = (1053 - 1020) * scale,
        height = (163 - 145) * scale
    }
    local popularityText = loveframes.Create("text")
    self.popularityText = popularityText
    popularityText:SetState(states.STATE_INGAME_CONSTRUCTION)
    popularityText:SetFont(loveframes.slanted_big_green)
    popularityText:SetPos(frPopularity.x, frPopularity.y)
    popularityText:SetText("")
    local goldText = loveframes.Create("text")
    self.goldText = goldText
    goldText:SetState(states.STATE_INGAME_CONSTRUCTION)
    goldText:SetFont(loveframes.slanted_xsmall_green)
    goldText:SetPos(frGold.x, frGold.y)
    goldText:SetText("")
    local populationText = loveframes.Create("text")
    self.populationText = populationText
    populationText:SetState(states.STATE_INGAME_CONSTRUCTION)
    populationText:SetFont(loveframes.slanted_small_green)
    populationText:SetPos(frPopulation.x, frPopulation.y)
    populationText:SetText("")
    self.element = element
    self.groups = {}
    self.currentGroup = "main"
    self.hasSelectedButton = false
    self.callback = {}
end

function ActionBar:switchMode(mode)
    self:unselectAll()
    if not _G.BuildController.start then
        _G.BuildController:disable()
    end
    local buildingHover = require("states.ui.building_tooltip")
    _G.DestructionController.active = false
    if mode == "granary" then
        self:showGroup("granary")
        loveframes.SetState(states.STATE_GRANARY)
        self.popularityText:SetState(states.STATE_GRANARY)
        self.populationText:SetState(states.STATE_GRANARY)
        self.goldText:SetState(states.STATE_GRANARY)
        self.element:SetState(states.STATE_GRANARY)
        self.element:SetImage(ActionBar.actionBarGranaryImage)
        buildingHover:SetState(states.STATE_GRANARY)
    elseif mode == "stockpile" then
        self:showGroup("stockpile")
        loveframes.SetState(states.STATE_STOCKPILE)
        self.popularityText:SetState(states.STATE_STOCKPILE)
        self.populationText:SetState(states.STATE_STOCKPILE)
        self.goldText:SetState(states.STATE_STOCKPILE)
        self.element:SetState(states.STATE_STOCKPILE)
        self.element:SetImage(ActionBar.actionBarStockpileImage)
        buildingHover:SetState(states.STATE_STOCKPILE)
    elseif mode == "house" then
        self:showGroup("house")
        loveframes.SetState(states.STATE_HOUSE)
        self.popularityText:SetState(states.STATE_HOUSE)
        self.populationText:SetState(states.STATE_HOUSE)
        self.goldText:SetState(states.STATE_HOUSE)
        self.element:SetState(states.STATE_HOUSE)
        self.element:SetImage(ActionBar.actionBarHouseImage)
        buildingHover:SetState(states.STATE_HOUSE)
    elseif mode == "market" then
        self:showGroup("market")
        loveframes.SetState(states.STATE_MARKET_MAIN)
        self.popularityText:SetState(states.STATE_MARKET_MAIN)
        self.populationText:SetState(states.STATE_MARKET_MAIN)
        self.goldText:SetState(states.STATE_MARKET_MAIN)
        self.element:SetState(states.STATE_MARKET_MAIN)
        self.element:SetImage(ActionBar.actionBarMarketImageMain)
        buildingHover:SetState(states.STATE_MARKET_MAIN)
    elseif mode == "market_trade" then
        self:showGroup("market_trade")
        loveframes.SetState(states.STATE_MARKET)
        self.popularityText:SetState(states.STATE_MARKET)
        self.populationText:SetState(states.STATE_MARKET)
        self.goldText:SetState(states.STATE_MARKET)
        self.element:SetState(states.STATE_MARKET)
        self.element:SetImage(ActionBar.actionBarMarketImage)
        buildingHover:SetState(states.STATE_MARKET)
    elseif mode == "keep_tax" then
        self:showGroup("keep_tax")
        loveframes.SetState(states.STATE_KEEP_TAX)
        self.popularityText:SetState(states.STATE_KEEP_TAX)
        self.populationText:SetState(states.STATE_KEEP_TAX)
        self.goldText:SetState(states.STATE_KEEP_TAX)
        self.element:SetState(states.STATE_KEEP_TAX)
        self.element:SetImage(ActionBar.actionBarKeepTaxImage)
        buildingHover:SetState(states.STATE_KEEP_TAX)
    elseif mode == "armoury" then
        self:showGroup("armoury")
        loveframes.SetState(states.STATE_ARMOURY)
        self.popularityText:SetState(states.STATE_ARMOURY)
        self.populationText:SetState(states.STATE_ARMOURY)
        self.goldText:SetState(states.STATE_ARMOURY)
        self.element:SetState(states.STATE_ARMOURY)
        self.element:SetImage(ActionBar.actionBarArmouryImage)
        buildingHover:SetState(states.STATE_ARMOURY)
    elseif mode == "barracks" then
        self:showGroup("barracks")
        loveframes.SetState(states.STATE_BARRACKS)
        self.popularityText:SetState(states.STATE_BARRACKS)
        self.populationText:SetState(states.STATE_BARRACKS)
        self.goldText:SetState(states.STATE_BARRACKS)
        self.element:SetState(states.STATE_BARRACKS)
        self.element:SetImage(ActionBar.actionBarBarracksImage)
        buildingHover:SetState(states.STATE_BARRACKS)
    elseif mode == "guilds" then
        self:showGroup("guilds")
        loveframes.SetState(states.STATE_GUILDS)
        self.popularityText:SetState(states.STATE_GUILDS)
        self.populationText:SetState(states.STATE_GUILDS)
        self.goldText:SetState(states.STATE_GUILDS)
        self.element:SetState(states.STATE_GUILDS)
        self.element:SetImage(ActionBar.actionBarArmouryImage)
        buildingHover:SetState(states.STATE_GUILDS)
    elseif mode == "unitsUI" then
        self:showGroup("unitsUI")
        loveframes.SetState(states.STATE_UNITS)
        self.popularityText:SetState(states.STATE_UNITS)
        self.populationText:SetState(states.STATE_UNITS)
        self.goldText:SetState(states.STATE_UNITS)
        self.element:SetState(states.STATE_UNITS)
        self.element:SetImage(ActionBar.actionBarUnits)
        buildingHover:SetState(states.STATE_UNITS)
    elseif mode == "cathedral" then
        self:showGroup("cathedral")
        loveframes.SetState(states.STATE_CATHEDRAL)
        self.popularityText:SetState(states.STATE_CATHEDRAL)
        self.populationText:SetState(states.STATE_CATHEDRAL)
        self.goldText:SetState(states.STATE_CATHEDRAL)
        self.element:SetState(states.STATE_CATHEDRAL)
        self.element:SetImage(ActionBar.actionBarArmouryImage)
        buildingHover:SetState(states.STATE_CATHEDRAL)
    else
        if _G.BuildController.start then
            self:showGroup("start")
        else
            self:showGroup("main")
        end
        loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
        self.popularityText:SetState(states.STATE_INGAME_CONSTRUCTION)
        self.populationText:SetState(states.STATE_INGAME_CONSTRUCTION)
        self.goldText:SetState(states.STATE_INGAME_CONSTRUCTION)
        self.element:SetState(states.STATE_INGAME_CONSTRUCTION)
        self.element:SetImage(ActionBar.actionBarImage)
        buildingHover:SetState(states.STATE_INGAME_CONSTRUCTION)
    end
end

function ActionBar:updatePopularityCount()
    local color
    if _G.state.popularity == nil then
        return
    end

    if _G.state.popularity >= 50 then
        self.popularityText:SetFont(loveframes.slanted_big_green)
    else
        self.popularityText:SetFont(loveframes.slanted_big_red)
    end
    local effects = _G.PopularityController.effects
    local neutral, bad, good = { color = { 0.305 + 0.5, 0.29 + 0.5, 0.125 + 0.5, 1 } }, { color = { 0.79, 0, 0, 1 } }, { color = { 0, 0.89, 0, 1 } }
    local taxColor, rationColor, fearColor, totalColor
    if effects.tax < 0 then
        taxColor = bad
    elseif effects.tax == 0 then
        taxColor = neutral
    elseif effects.tax > 0 then
        taxColor = good
    end
    if effects.rations < 0 then
        rationColor = bad
    elseif effects.rations == 0 then
        rationColor = neutral
    elseif effects.rations > 0 then
        rationColor = good
    end
    if effects.positiveBuildings < 0 then
        fearColor = bad
    elseif effects.positiveBuildings == 0 then
        fearColor = neutral
    elseif effects.positiveBuildings > 0 then
        fearColor = good
    end
    local total = effects.tax + effects.rations + effects.positiveBuildings
    if total < 0 then
        totalColor = bad
    elseif total == 0 then
        totalColor = neutral
    elseif total > 0 then
        totalColor = good
        total = "+" .. tostring(total)
    end
    local tooltip = {
        taxColor, ("\tTaxes: %d\n"):format(effects.tax),
        rationColor, ("\tRations: %d\n"):format(effects.rations),
        fearColor, ("\tFear factor: %d\n"):format(effects.positiveBuildings),
        totalColor, ("\n\tTotal: %s"):format(tostring(total)),
    }

    self.popularityText:setTooltip("Popularity", tooltip)

    self.popularityText:SetText(_G.state.popularity)
end

function ActionBar:updateGoldCount()
    if _G.state.gold >= 10 then
        self.goldText:SetFont(loveframes.slanted_xsmall_green)
    else
        self.goldText:SetFont(loveframes.slanted_xsmall_red)
    end
    -- Poor man's right align
    local roundGold = math.floor(_G.state.gold)
    if _G.state.gold >= 1000 then
        self.goldText:SetText(roundGold)
    elseif _G.state.gold >= 100 then
        self.goldText:SetText(" " .. roundGold)
    elseif _G.state.gold >= 10 then
        self.goldText:SetText("  " .. roundGold)
    elseif _G.state.gold >= 0 then
        self.goldText:SetText("   " .. roundGold)
    end
end

function ActionBar:unlockTier(level)
    _G.state.tier = level
    _G.bus.emit(Events.OnTierUpgraded, level)
end

function ActionBar:updatePopulationCount()
    if _G.debugMode then
        _G.bus.on(Events.OnPopulationChange, print)
    end
    if _G.state.population == _G.state.maxPopulation then
        self.populationText:SetFont(loveframes.slanted_small_red)
    else
        self.populationText:SetFont(loveframes.slanted_small_green)
    end
    self.populationText:SetText(_G.state.population .. "/" .. _G.state.maxPopulation)
end

function ActionBar:activateButton(position)
    if self.groups[self.currentGroup] then
        local button = self.groups[self.currentGroup][position]
        if button and not button.disabled then
            button:press()
        end
    end
end

function ActionBar:keypressed(key, scancode)
    local event = keybindManager:getEventForKeypress(key)
    if event == EVENT.ActionBar1 then
        self:activateButton(1)
    elseif event == EVENT.ActionBar2 then
        self:activateButton(2)
    elseif event == EVENT.ActionBar3 then
        self:activateButton(3)
    elseif event == EVENT.ActionBar4 then
        self:activateButton(4)
    elseif event == EVENT.ActionBar5 then
        self:activateButton(5)
    elseif event == EVENT.ActionBar6 then
        self:activateButton(6)
    elseif event == EVENT.ActionBar7 then
        self:activateButton(7)
    elseif event == EVENT.ActionBar8 then
        self:activateButton(8)
    elseif event == EVENT.ActionBar9 then
        self:activateButton(9)
    elseif event == EVENT.ActionBar10 then
        self:activateButton(10)
    elseif event == EVENT.ActionBar11 then
        self:activateButton(11)
    elseif event == EVENT.ActionBar12 then
        self:activateButton(12)
    end
end

function ActionBar:unselectAll()
    for _, group in pairs(self.groups) do
        for _, el in pairs(group) do
            el:unselect()
        end
    end
    self.hasSelectedButton = false
end

function ActionBar:selectButton(element)
    if not element.background.visible then
        error("trying to select an invisible button")
    end
    for _, el in pairs(self.groups[element.group]) do
        if el ~= element then
            el:unselect()
        end
    end
    element:select()
    self.hasSelectedButton = true
    _G.playInterfaceSfx(_G.fx["woodpush2"], 1)
end

function ActionBar:registerGroup(name, listOfElements, callback)
    if callback and type(callback) ~= "function" then error("expected function as a parameter, not " .. type(callback)) end
    self.groups[name] = {}
    self.callback[name] = callback
    for _, v in ipairs(listOfElements) do
        v.group = name
        self.groups[name][v.position] = v
    end
end

function ActionBar:hideGroup(name)
    for _, el in pairs(self.groups[name]) do
        el:hide()
    end
end

function ActionBar:getCurrentGroup()
    return self.currentGroup
end

function ActionBar:showGroup(name, playSound)
    if playSound then
        _G.playInterfaceSfx(playSound, 1)
    end
    self.currentGroup = name
    if self.callback[name] then
        self.callback[name]()
    end
    for k, _ in pairs(self.groups) do
        if k ~= name then
            self:hideGroup(k)
        end
    end
    if name then
        for _, el in pairs(self.groups[name]) do
            el:show()
        end
    end
end

function ActionBar:hide()
    self.element.visible = false
end

function ActionBar:show()
    self.element.visible = true
end

return ActionBar:new()
