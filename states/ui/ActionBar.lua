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
ActionBar.static.actionBarStockpileImage = love.graphics.newImage("assets/ui/action_bar_stockpile.png")
ActionBar.static.actionBarMarketImageMain = love.graphics.newImage("assets/ui/action_bar_market_main.png")
ActionBar.static.actionBarMarketImage = love.graphics.newImage("assets/ui/action_bar_market.png")
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
    local frPopulation = {
        x = element:GetX() - element:GetOffsetX() * scale + 1017 * scale,
        y = element:GetY() - element:GetOffsetY() * scale + 144 * scale,
        width = (1053 - 1020) * scale,
        height = (163 - 145) * scale
    }
    local frGold= {
        x = element:GetX() - element:GetOffsetX() * scale + 1019 * scale,
        y = element:GetY() - element:GetOffsetY() * scale + 130 * scale,
        width = (1053 - 1020) * scale,
        height = (163 - 145) * scale
    }
    local populationText = loveframes.Create("text")
    self.populationText = populationText
    populationText:SetState(states.STATE_INGAME_CONSTRUCTION)
    populationText:SetFont(loveframes.font_vera_italic_large)
    populationText:SetPos(frPopulation.x, frPopulation.y)
    populationText:SetText("")
    populationText:SetShadowColor(240 / 255, 240 / 255, 224 / 255)
    populationText:SetShadow(true)
    local goldText = loveframes.Create("text")
    self.goldText = goldText
    goldText:SetState(states.STATE_INGAME_CONSTRUCTION)
    goldText:SetFont(loveframes.font_vera_italic)
    goldText:SetPos(frGold.x, frGold.y)
    goldText:SetText("")
    goldText:SetShadowColor(240 / 255, 240 / 255, 224 / 255)
    goldText:SetShadow(true)
    self.element = element
    self.groups = {}
    self.currentGroup = "main"
end

function ActionBar:switchMode(mode)
    self:unselectAll()
    if mode == "granary" then
        self:showGroup("granary")
        loveframes.SetState(states.STATE_GRANARY)
        self.populationText:SetState(states.STATE_GRANARY)
        self.goldText:SetState(states.STATE_GRANARY)
        self.element:SetState(states.STATE_GRANARY)
        self.element:SetImage(ActionBar.actionBarGranaryImage)
    elseif mode == "stockpile" then
        self:showGroup("stockpile")
        loveframes.SetState(states.STATE_STOCKPILE)
        self.populationText:SetState(states.STATE_STOCKPILE)
        self.goldText:SetState(states.STATE_STOCKPILE)
        self.element:SetState(states.STATE_STOCKPILE)
        self.element:SetImage(ActionBar.actionBarStockpileImage)
    elseif mode == "house" then
        self:showGroup("house")
        loveframes.SetState(states.STATE_HOUSE)
        self.populationText:SetState(states.STATE_HOUSE)
        self.goldText:SetState(states.STATE_HOUSE)
        self.element:SetState(states.STATE_HOUSE)
        self.element:SetImage(ActionBar.actionBarGranaryImage)
    elseif mode == "market" then
        self:showGroup("market")
        loveframes.SetState(states.STATE_MARKET_MAIN)
        self.populationText:SetState(states.STATE_MARKET_MAIN)
        self.goldText:SetState(states.STATE_MARKET_MAIN)
        self.element:SetState(states.STATE_MARKET_MAIN)
        self.element:SetImage(ActionBar.actionBarMarketImageMain)
    elseif mode == "market_trade" then
        self:showGroup("market_trade")
        loveframes.SetState(states.STATE_MARKET)
        self.populationText:SetState(states.STATE_MARKET)
        self.goldText:SetState(states.STATE_MARKET)
        self.element:SetState(states.STATE_MARKET)
        self.element:SetImage(ActionBar.actionBarMarketImage)
    else
        self:showGroup("main")
        loveframes.SetState(states.STATE_INGAME_CONSTRUCTION)
        self.populationText:SetState(states.STATE_INGAME_CONSTRUCTION)
        self.goldText:SetState(states.STATE_INGAME_CONSTRUCTION)
        self.element:SetState(states.STATE_INGAME_CONSTRUCTION)
        self.element:SetImage(ActionBar.actionBarImage)
    end
end

function ActionBar:updatePopulationCount()
    local color = {176 / 255, 136 / 255, 80 / 255, 1}
    if _G.state.population == _G.state.maxPopulation then
        color = {204 / 255, 0, 0, 1}
    end
    self.populationText:SetText({{
        color = color
    }, _G.state.population .. "/" .. _G.state.maxPopulation})
end
function ActionBar:updateGoldCount()
    local color = {176 / 255, 136 / 255, 80 / 255, 1}
    self.goldText:SetText({{
        color = color
    }, _G.state.gold})
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
