local FoodController = require("objects.Controllers.FoodController")

local colorRed = {200 / 255, 90 / 255, 90 / 255, 1}
local colorWhite = {1, 1, 1, 1}
local colorGreen = {130 / 255, 220 / 255, 123 / 255, 1}

local moodImage, moodText = unpack(require("states.ui.granary.food_rations"))
local RationController = _G.class("RationController")
RationController.static.RATION_LEVELS = {
    NoRations = 0,
    SmallRations = 0.5,
    NormalRations = 1,
    ExtraRations = 1.5,
    LargeRations = 2
}
RationController.static.MOOD_LEVELS = {
    NoRations = -8,
    SmallRations = -4,
    NormalRations = 0,
    ExtraRations = 4,
    LargeRations = 8
}
RationController.static.FOOD_DIVERSITY = {
    0, 0, 1, 3, 5
}
RationController.static.RATION_INTERVAL = 30
function RationController:initialize()
    self.rationLevel = self.class.RATION_LEVELS.NormalRations
    self.timer = 0
    self.moodFoodFactor = self.class.MOOD_LEVELS.NormalRations
    self.granaries = {}
    self.previousConsumedFoods = 1
    self.consumedFoodsMood = 0
end

function RationController:serialize()
    local data = {}

    data.rationLevel = self.rationLevel
    data.timer = self.timer
    data.moodFoodFactor = self.moodFoodFactor
    data.previousConsumedFoods = self.previousConsumedFoods
    data.consumedFoodsMood = self.consumedFoodsMood

    return data
end

function RationController:deserialize(data)
    for k, v in pairs(data) do
        self[k] = v
    end
end

function RationController:setRationLevel(level)
    self.rationLevel = self.class.RATION_LEVELS[level]
    self.moodFoodFactor = self.class.MOOD_LEVELS[level]
    self:updateUI()
    if level == "NoRations" then
        _G.ScribeController:triggerUnhappyEvent()
    elseif level == "LargeRations" then
        _G.ScribeController:triggerHappyEvent()
    end
end

function RationController:getRationLevel()
    return self.rationLevel
end

function RationController:getMoodLevel()
    if self.previousConsumedFoods == 0 or self.rationLevel == self.class.RATION_LEVELS.NoRations then
        return self.class.MOOD_LEVELS.NoRations
    end
    return self.moodFoodFactor + self.consumedFoodsMood
end

-- Returns how much food will be taken at next ration handout
function RationController:getNextRationSize()
    return math.round(_G.state.population * self.rationLevel, 0)
end

-- Returns progress to next ration handout
function RationController:getRationProgress()
    return math.round((self.timer * 100) / self.class.RATION_INTERVAL, 2)
end

function RationController:updateUI()
    local moodLevel = self:getMoodLevel()
    if moodLevel == 0 then
        moodImage:SetNeutralMood()
        moodText:SetText({{
            color = colorWhite
        }, moodLevel})
    elseif moodLevel > 0 then
        moodImage:SetPositiveMood()
        moodText:SetText({{
            color = colorGreen
        }, moodLevel})
    elseif moodLevel < 0 then
        moodImage:SetNegativeMood()
        moodText:SetText({{
            color = colorRed
        }, moodLevel})
    end
end

function RationController:setGranaryToFadeOut(granary)
    self.granaries[granary] = 3
end

function RationController:update()
    self.timer = self.timer + _G.dt
    local consumedFoods = FoodController:foodsConsumed()
    if self.timer >= self.class.RATION_INTERVAL then
        _G.foodpile:take(nil, math.round(_G.state.population * self.rationLevel, 0))
        if self.previousConsumedFoods ~= consumedFoods then
            self.consumedFoodsMood = self.class.FOOD_DIVERSITY[consumedFoods + 1]
            self:updateUI()
        end
        self.timer = 0
        self.previousConsumedFoods = consumedFoods
    end
    for granary, timeLeft in pairs(self.granaries) do
        self.granaries[granary] = timeLeft - love.timer.getDelta()
        if self.granaries[granary] <= 0 then
            granary:exitHover(true)
            self.granaries[granary] = nil
        end
    end
end

return RationController:new()
