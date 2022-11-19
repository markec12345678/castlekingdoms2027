local Gamestate = require("libraries.gamestate")
local RationController = _G.class("RationController")
RationController.static.RATION_LEVELS = {
    NoRations = 0,
    SmallRations = 0.5,
    NormalRations = 1,
    ExtraRations = 1.5,
    LargeRations = 2
}
RationController.static.MOOD_LEVELS = {
    NoRationsMood = -8,
    SmallRationsMood = -4,
    NormalRationsMood = 0,
    ExtraRationsMood = 4,
    LargeRationsMood = 8
}
RationController.static.RATION_INTERVAL = 3000
function RationController:initialize()
    self.rationLevel = self.class.RATION_LEVELS.NormalRations
    self.timer = 0
    self.moodFoodFactor = self.class.MOOD_LEVELS.NormalRationsMood
    self.granaries = {}
end

function RationController:serialize()
    local data = {}

    data.rationLevel = self.rationLevel
    data.timer = self.timer
    data.moodFoodFactor = self.moodFoodFactor
    data.granaries = self.granaries

    return data
end

function RationController:deserialize(data)
    for k, v in pairs(data) do
        self[k] = v
    end
end

function RationController:setRationLevel(level)
    self.rationLevel = self.class.RATION_LEVELS[level]
end

function RationController:getRationLevel()
    return self.rationLevel
end

function RationController:setMoodLevel(level)
    self.moodFoodFactor = self.class.MOOD_LEVELS[level]
end

function RationController:getMoodLevel()
    return self.moodFoodFactor
end

-- Returns how much food will be taken at next ration handout
function RationController:getNextRationSize()
    return math.round(_G.state.population * self.rationLevel, 0)
end

-- Returns progress to next ration handout
function RationController:getRationProgress()
    return math.round((self.timer * 100) / self.class.RATION_INTERVAL, 2)
end

function RationController:setGranaryToFadeOut(granary)
    self.granaries[granary] = 3
end

function RationController:update()
    self.timer = self.timer + 1 + love.timer.getDelta()
    if self.timer >= self.class.RATION_INTERVAL then
        _G.foodpile:take(nil, math.round(_G.state.population * self.rationLevel, 0))
        self.timer = 0
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
