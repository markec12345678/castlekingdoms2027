local actionBar = require("states.ui.ActionBar")
local RationController = require("objects.Controllers.RationController")
local Events = require "objects.Enums.Events"

local PopularityController = _G.class("PopularityController")
PopularityController.static.POPULARITY_INTERVAL = 3
function PopularityController:initialize()
    self.timer = 0
    self.moodFoodFactor = RationController.moodFactor
    self.moodTaxFactor = _G.TaxController.moodFactor
    self.speedPopModifier = 2
    self.previousSpeedPopModifier = 2
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

function PopularityController:calculatePositiveBuildingPopularity()
    local positiveBuildingFactor = _G.BuildingManager:getCountOfPositiveBuildings() - (math.ceil(_G.state.population / 16) - 1)
    if positiveBuildingFactor > 5 then
        positiveBuildingFactor = 5
    elseif positiveBuildingFactor < 0 then
        positiveBuildingFactor = 0
    end
    return positiveBuildingFactor
end

function PopularityController:update()
    self:calculatePositiveBuildingPopularity()
    local popularityOldValue = _G.state.popularity
    if not _G.campfireFloatPop then return end
    self.timer = self.timer + _G.dt
    if self.timer >= self.class.POPULARITY_INTERVAL then
        _G.state.popularity = 50 + _G.TaxController:getMoodFactor() + RationController:getMoodLevel()
        _G.bus.emit(Events.OnPopulationChange, popularityOldValue, _G.state.popularity)
        self.timer = 0
        actionBar:updatePopularityCount()
        local x = _G.state.popularity
        if _G.state.popularity >= 50 then
            self.speedPopModifier = ((100 - x) / 25) * ((100 - x) / 25) * ((100 - x) / 25) * 0.08 + 0.09
        else
            self.speedPopModifier = ((x) / 50) * ((x) / 10) * 0.08 + 0.1
        end
        if self.previousSpeedPopModifier ~= self.speedPopModifier then
            _G.campfireFloatPop:updateSpeed(self.speedPopModifier)
        end
        self.previousSpeedPopModifier = self.speedPopModifier
    end
end

return PopularityController:new()
