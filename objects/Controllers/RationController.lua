local Gamestate = require("libraries.gamestate")
local RationController = _G.class("RationController")
RationController.static.RATION_LEVELS = {
    NoRations = 0,
    SmallRations = 0.5,
    NormalRations = 1,
    ExtraRations = 1.5,
    LargeRations = 2
}
RationController.static.RATION_INTERVAL = 3000
function RationController:initialize()
    self.rationLevel = self.class.RATION_LEVELS.NormalRations
    self.timer = 0
    self.granaries = {}
end

function RationController:setRationLevel(level)
    self.rationLevel = self.class.RATION_LEVELS[level]
end

function RationController:getRationLevel()
    return self.rationLevel
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
        print(timeLeft, timeLeft - love.timer.getDelta())
        self.granaries[granary] = timeLeft - love.timer.getDelta()
        if self.granaries[granary] <= 0 then
            granary:exitHover(true)
            self.granaries[granary] = nil
        end
    end
end

return RationController:new()
