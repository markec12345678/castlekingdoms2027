local actionBar = require("states.ui.ActionBar")
local RationController = require("objects.Controllers.RationController")

local PopularityController = _G.class("PopularityController")
PopularityController.static.POPULARITY_INTERVAL = 30
function PopularityController:initialize()
    self.timer = 0
    self.moodFoodFactor = RationController.moodFactor
    self.moodTaxFactor = _G.TaxController.moodFactor
end

function PopularityController:serialize()
    local data = {}

    data.timer = self.timer
    data.moodFoodFactor = self.moodFoodFactor
    data.moodTaxFactor = self.moodTaxFactor

    return data
end

function PopularityController:deserialize(data)
    for k, v in pairs(data) do
        self[k] = v
    end
end

function PopularityController:update()
    self.timer = self.timer + love.timer.getDelta()
    if self.timer >= self.class.POPULARITY_INTERVAL then
        _G.state.popularity = 50 + _G.TaxController:getMoodFactor() + RationController:getMoodLevel()
        self.timer = 0
        actionBar:updatePopularityCount()
    end
end

return PopularityController:new()
