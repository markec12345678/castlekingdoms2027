local actionBar = require("states.ui.ActionBar")
local TaxController = _G.class("TaxController")
TaxController.static.TAX_LEVELS = {
    GenerousBribe = -1.0,
    LargeBribe = -0.8,
    SmallBribe = -0.6,
    NoTaxes = 0,
    LowTaxes = 0.6,
    AverageTaxes = 0.8,
    HighTaxes = 1.0,
    MeanTaxes = 1.2,
    ExtortionateTaxes = 1.4,
    DownrightCruelTaxes = 1.6
}
TaxController.static.TAX_INTERVAL = 30
function TaxController:initialize()
    self.taxLevel = self.class.TAX_LEVELS.NoTaxes
    self.timer = 0
    self.taxText = "No Tax"
    self.goldFactor = 0
    self.moodFactor = 0
    self.taxOption = 4
    self.autoTax = false
end

function TaxController:serialize()
    local data = {}

    data.taxLevel = self.taxLevel
    data.timer = self.timer
    data.taxText = self.taxText
    data.goldFactor = self.goldFactor
    data.moodFactor = self.moodFactor
    data.taxOption = self.taxOption
    data.autoTax = self.autoTax

    return data
end

function TaxController:deserialize(data)
    for k, v in pairs(data) do
        self[k] = v
    end
    local elements = require("states.ui.keep.keep_tax")
    elements.SetTax(self.taxOption)
end

function TaxController:setTaxLevel(level)
    self.taxLevel = self.class.TAX_LEVELS[level]
end

function TaxController:getTaxLevel()
    return self.taxLevel
end

-- Returns how much gold will be taken/given at next month
function TaxController:getNextTaxSize()
    return math.round(_G.state.population * self.taxLevel, 0)
end

-- Returns progress to next tax handout
function TaxController:getTaxProgress()
    return math.round((self.timer * 100) / self.class.TAX_INTERVAL, 2)
end

function TaxController:getMoodFactor()
    return self.moodFactor
end

function TaxController:update()
    local elements = require("states.ui.keep.keep_tax")
    self.timer = self.timer + _G.dt
    if _G.state.gold < (math.round(_G.state.population * self.goldFactor, 0) * -1) then
        _G.TaxController:setTaxLevel("NoTaxes")
        elements.SetTax(4)
    end
    if self.timer >= self.class.TAX_INTERVAL then
        _G.state.gold = _G.state.gold + math.round((_G.state.population - _G.state.peasants) * self.goldFactor, 0)
        self.timer = 0
        elements.tax:SetText({{
            color = {0, 0, 0, 1}
        }, self.taxText})
        elements.population:SetText({{
            color = {0, 0, 0, 1}
        }, _G.state.population})
        elements.gold:SetText({{
            color = {0, 0, 0, 1}
        }, math.round(_G.state.population * self.goldFactor, 0)})
        if _G.TaxController.autoTax then
            if _G.state.popularity >= 66 then
                _G.TaxController:setTaxLevel("Downright Cruel Taxes")
                elements.SetTax(10)
            end
            if _G.state.popularity >= 62 and _G.state.popularity < 66 then
                _G.TaxController:setTaxLevel("Extortionate Taxes")
                elements.SetTax(9)
            end
            if _G.state.popularity >= 58 and _G.state.popularity < 62 then
                _G.TaxController:setTaxLevel("Mean Taxes")
                elements.SetTax(8)
            end
            if _G.state.popularity >= 56 and _G.state.popularity < 58 then
                _G.TaxController:setTaxLevel("High Taxes")
                elements.SetTax(7)
            end
            if _G.state.popularity >= 54 and _G.state.popularity < 56 then
                _G.TaxController:setTaxLevel("Average Taxes")
                elements.SetTax(6)
            end
            if _G.state.popularity >= 52 and _G.state.popularity < 54 then
                _G.TaxController:setTaxLevel("Low Taxes")
                elements.SetTax(5)
            end
            if _G.state.popularity < 50 then
                _G.TaxController:setTaxLevel("No Taxes")
                elements.SetTax(4)
            end
        end
        actionBar:updateGoldCount()
    end
end

return TaxController:new()
