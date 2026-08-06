local actionBar = require("states.ui.ActionBar")

local COVERED_POPULATION_PER_INN = 30
local UPDATE_PERIOD = 1

local AleController = _G.class("AleController")
function AleController:initialize()
    self.registeredInns = {}
    self.updateTimer = UPDATE_PERIOD
end

function AleController:registerInn(inn)
    self.registeredInns[inn] = inn
end

function AleController:removeInn(inn)
    self.registeredInns[inn] = nil
end

function AleController:update()
    if self.updateTimer >= UPDATE_PERIOD then
        self.updateTimer = 0
        local coverage, bonus = self:getAleCoverageStats()
        actionBar:updateAleCoverage(coverage, bonus)
    else 
        self.updateTimer = self.updateTimer + _G.dt
    end
end

function AleController:getActiveInnCount()
    local activeInns = 0
    
    for _,registeredInn in pairs(self.registeredInns) do
        if registeredInn.partyObj.animated then
            activeInns = activeInns + 1
        end
    end
    
    return activeInns
end

function AleController:getCoverage()
    return math.min(1.0, self:getActiveInnCount() * COVERED_POPULATION_PER_INN / _G.state.population) * 100
end

function AleController:getAleCoverageStats()
    local coverage = self:getCoverage()
    local bonus = 0
    if coverage >= 100 then
        bonus = 4
    elseif coverage >= 75 then
        bonus = 3
    elseif coverage >= 50 then
        bonus = 2
    elseif coverage >= 25 then
        bonus = 1
    end
    return coverage, bonus
end

return AleController:new()
