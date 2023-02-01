local loveframes = require("libraries.loveframes")
local states = require("states.ui.states")
local base = require("states.ui.base")
local w, h = base.w, base.h

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
        self.element:SetImage(ActionBar.actionBarGranaryImage)
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
    else
        self:showGroup("main")
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

    self.popularityText:SetText(_G.state.popularity)
end

function ActionBar:updateGoldCount()
    if _G.state.gold >= 10 then
        self.goldText:SetFont(loveframes.slanted_xsmall_green)
    else
        self.goldText:SetFont(loveframes.slanted_xsmall_red)
    end
    -- Poor man's right align
    if _G.state.gold >= 1000 then
        self.goldText:SetText(_G.state.gold)
    elseif _G.state.gold >= 100 then
        self.goldText:SetText(" " .. _G.state.gold)
    elseif _G.state.gold >= 10 then
        self.goldText:SetText("  " .. _G.state.gold)
    elseif _G.state.gold >= 0 then
        self.goldText:SetText("   " .. _G.state.gold)
    end
end

function ActionBar:updatePopulationCount()
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
        if button then
            button:press()
        end
    end
end

function ActionBar:keypressed(key, scancode)
    if key == "1" then
        self:activateButton(1)
    elseif key == "2" then
        self:activateButton(2)
    elseif key == "3" then
        self:activateButton(3)
    elseif key == "4" then
        self:activateButton(4)
    elseif key == "5" then
        self:activateButton(5)
    elseif key == "6" then
        self:activateButton(6)
    elseif key == "7" then
        self:activateButton(7)
    elseif key == "8" then
        self:activateButton(8)
    elseif key == "9" then
        self:activateButton(9)
    elseif key == "0" then
        self:activateButton(10)
    elseif key == "-" then
        self:activateButton(11)
    elseif key == "=" or key == "`" then
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
end

function ActionBar:registerGroup(name, listOfElements)
    self.groups[name] = {}
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

function ActionBar:showGroup(name)
    self.currentGroup = name
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
