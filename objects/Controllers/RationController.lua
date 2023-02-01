local FoodController = require("objects.Controllers.FoodController")
local FOOD = require("objects.Enums.Food")

local colorRed = {200 / 255, 90 / 255, 90 / 255, 1}
local colorWhite = {1, 1, 1, 1}
local colorGreen = {130 / 255, 220 / 255, 123 / 255, 1}

local moodImage, moodText = unpack(require("states.ui.granary.food_rations"))
local RationController = _G.class("RationController")

local counter = 100
local integerToFoodType = {}
local gameFoodsCount = 0
local curFood = 1
for _,v in pairs(FOOD) do
    gameFoodsCount = gameFoodsCount + 1
    integerToFoodType[gameFoodsCount] = v
end

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
    local consumedFoods = FoodController:foodsConsumed()
    local ateFood = false

    --Scaling with population (Temporary solution for balancing.)
    local multiplier
    if _G.state.population <= 5 then
        multiplier = 1.2
    elseif _G.state.population >= 20 then
        multiplier = 0.95
    else
        multiplier = 1.05
    end
    -- Count the timer to deltatime multiplied by the amount of people, temporary multiplier and the ration level.
    self.timer = (self.timer + (_G.dt * _G.state.population * multiplier) * self.rationLevel)
    -- If the timer reaches 100, initiate eating of 1 food.
    if self.timer >= counter then
        local loopTime = 1
        -- Ration loop, checks if food is available and then eats it. Otherwise break and no food available.
        while ateFood == false do
            local foodType = integerToFoodType[curFood]
            if _G.state.food[foodType] > 0 then
                _G.foodpile:take(foodType, 1)
                ateFood = true
            else
                -- No food found, check next food.
                curFood = curFood + 1
                if curFood >= gameFoodsCount + 1  then
                    curFood = 1
                end
            end
            -- If there has been more than the amount of foods in the game loops,
            -- exit the loop since there is no food available.
            if loopTime > gameFoodsCount then
                break
            end
            loopTime = loopTime + 1
        end
        curFood = curFood + 1
        if curFood >= gameFoodsCount + 1 then
            curFood = 1
        end

        -- TODO: Change it to only add a food variety bonus after having ate actual foods.
        if self.previousConsumedFoods ~= consumedFoods then
            self.consumedFoodsMood = self.class.FOOD_DIVERSITY[consumedFoods + 1]
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
    self:updateUI()
end

return RationController:new()
