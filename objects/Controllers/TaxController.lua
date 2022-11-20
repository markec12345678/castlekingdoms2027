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
end

function TaxController:serialize()
    local data = {}

    data.taxLevel = self.taxLevel
    data.timer = self.timer
    data.taxText = self.taxText
    data.goldFactor = self.goldFactor
    data.moodFactor = self.moodFactor
    data.taxOption = self.taxOption

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
    self.timer = self.timer + love.timer.getDelta()
    if _G.state.gold < (math.round(_G.state.population * self.goldFactor, 0) * -1) then
        _G.TaxController:setTaxLevel("NoTaxes")
        elements.SetTax(4)
    end
    if self.timer >= self.class.TAX_INTERVAL then
        _G.state.gold = _G.state.gold + math.round(_G.state.population * self.goldFactor, 0)
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
        actionBar:updateGoldCount()
    end
end

return TaxController:new()
