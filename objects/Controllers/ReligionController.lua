local actionBar = require("states.ui.ActionBar")

local ReligionController = _G.class("ReligionController")

ReligionController.static.BLESSING_DURATION = 150
local BLESSING_TARGET_DURATION = 30
local UPDATE_PERIOD = 5

function ReligionController:initialize()
    self.alreadyBlessing = {}
    self.updateTimer = UPDATE_PERIOD
end

function ReligionController:update()
    if self.updateTimer >= UPDATE_PERIOD then
        self.updateTimer = 0
        local coverage, bonus = self:getCoverageStats()
        actionBar:updateBlessingCoverage(coverage, bonus)
    else 
        self.updateTimer = self.updateTimer + _G.dt
    end
end

function ReligionController:addToBlessingTargets(building)
    self.alreadyBlessing[building] = _G.state.gameTime
end

function ReligionController:getBuildingToBless(centerGX, centerGY, radius)
    local buildings = _G.BuildingManager:getAllPlayerBuildings()
    self:cleanAlreadyBlessing()
    return self:selectBuildingToBless(centerGX, centerGY, radius, buildings, true)
end

function ReligionController:cleanAlreadyBlessing()
    for building, targetingTime in pairs(self.alreadyBlessing) do
        if  _G.state.gameTime - targetingTime > BLESSING_TARGET_DURATION then
            self.alreadyBlessing[building] = nil
        end
    end
end

function ReligionController:selectBuildingToBless(centerGX, centerGY, radius, buildings, tryNotToBlessSameBuilding)
    local selectedBuildingIndex = -1
    local oldestBlessed = math.huge
    local skippedDueAlreadyBlessing = {}
    for i, building in ipairs(buildings) do
        local dist = _G.manhattanDistance(centerGX, centerGY, building.gx, building.gy)
        if dist < radius and 
           building.lastBlessed < oldestBlessed and
           self:isBuildingBlessable(building.class.name) then
            if not tryNotToBlessSameBuilding or not self.alreadyBlessing[building] then
                oldestBlessed = building.lastBlessed
                selectedBuildingIndex = i
            else
                table.insert(skippedDueAlreadyBlessing, building)
            end
        end
    end

    if selectedBuildingIndex ~= -1 then
        local selectedBuilding = buildings[selectedBuildingIndex]
        self:addToBlessingTargets(selectedBuilding)
        return selectedBuilding
    elseif tryNotToBlessSameBuilding then
        return self:selectBuildingToBless(centerGX, centerGY, radius, skippedDueAlreadyBlessing, false)
    else
        return nil
    end
end

function ReligionController:isBuildingBlessable(name)
    return (name ~= "Stockpile" and 
            name ~= "Chapel" and 
            name ~= "Church" and 
            name ~= "Cathedral")
end

function ReligionController:getCoverageStats()
    local buildings = _G.BuildingManager:getAllPlayerBuildings()
    local numberOfBuildingsToBless = 0
    for _, building in ipairs(buildings) do
        if self:isBuildingBlessable(building.class.name) then
            numberOfBuildingsToBless = numberOfBuildingsToBless + 1
        end
    end
    local numberOfBlessedBuildings = 0
    for _, building in ipairs(buildings) do
        if _G.state.gameTime - building.lastBlessed < ReligionController.static.BLESSING_DURATION then
            numberOfBlessedBuildings = numberOfBlessedBuildings + 1
        end
    end

    local coverage = (numberOfBlessedBuildings / numberOfBuildingsToBless) * 100
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

function ReligionController:serialize()
    local data = {}
    data.updateTimer = self.updateTimer
    local alreadyBlessingList = {}
    for building, timestamp in pairs(self.alreadyBlessing) do
        if not building.toBeDeleted then
            alreadyBlessingList[#alreadyBlessingList + 1] = {["building"] = _G.state:serializeObject(building), ["timestamp"] = timestamp}
        end
    end
    data.alreadyBlessing = alreadyBlessingList
    return data
end

function ReligionController:deserialize(data)
    self.updateTimer = data.updateTimer
    for _, v in ipairs(data.alreadyBlessing) do
        self.alreadyBlessing[_G.state:dereferenceObject(v.building)] = v.timestamp
    end
end

return ReligionController:new()