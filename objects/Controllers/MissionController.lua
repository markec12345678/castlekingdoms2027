local MissionController = _G.class('MissionController')
local FOOD = require("objects.Enums.Food")
local RESOURCES = require("objects.Enums.Resources")
local WEAPON = require("objects.Enums.Weapon")
local TimeController = require("objects.Controllers.TimeController")
local Events = require("objects.Enums.Events")
local bitser = require("libraries.bitser")
local path = "CampaignData.bin"

local missionNumber
local mission
local missionsCompletedLoaded = { false, false, false, false, false }
local saved = false
function MissionController:initialize()
    self.locked = false
    self.name = ""            --name or id of the mission
    self.description = ""     -- description of the mission
    self.goals = {}           -- goals of the mission
    self.lockedBuildings = {} --turns off designated buildings

    self.lockedTradeFood = {} --turns off designated resources from market/trading
    self.lockedTradeResources = {}
    self.lockedTradeWeapons = {}

    self.lockedProductionWeapons = {} --turns off designated weapons from production f.e crossbows
    self.timeLimit = 1                -- if 0 there is no limit
    self.NoTimeLimit = false
    self.startDate = TimeController:setCurrentDate(1, 1000)
    self.goalsList = ""
    self.startPopularity = 50
    self.startGold = 1000
    self.youWin = false
    self.startPopulation = 0
    self.startResources = {
        [RESOURCES.wood] = 0,
        [RESOURCES.hop] = 0,
        [RESOURCES.stone] = 0,
        [RESOURCES.iron] = 0,
        [RESOURCES.tar] = 0,
        [RESOURCES.flour] = 0,
        [RESOURCES.ale] = 0,
        [RESOURCES.wheat] = 0,
    }
    self.startFood = {
        [FOOD.meat] = 0,
        [FOOD.apples] = 0,
        [FOOD.bread] = 0,
        [FOOD.cheese] = 0
    }
    self.startWeapon = {
        [WEAPON.bow] = 0,
        [WEAPON.crossbow] = 0,
        [WEAPON.spear] = 0,
        [WEAPON.pike] = 0,
        [WEAPON.mace] = 0,
        [WEAPON.sword] = 0,
        [WEAPON.leatherArmor] = 0,
        [WEAPON.shield] = 0
    }
    self.startAnimals = {
        -- type and count of the animals
        -- spawn using designated XY or using areas placed in the editor or map/text file

    };
    self.startBuildings = {
        -- type and coords of the designated buildings to be placed on the map
        -- spawn using designated XY or using areas placed in the editor or map/text file
    };
end

function MissionController:setMissionState(name)
    name = name or "mission1"
    self.missionName = name
    mission = require("saves.Missions." .. name)
    missionNumber = tonumber(name:gsub("%D", ""))
    print("Mission number: " .. missionNumber)
    _G.state.gold = mission.startGold
    self.goals = mission.goals
    self.startDate = mission.startDate.year
    TimeController:setCurrentDate(mission.startDate.month, mission.startDate.year)
    if mission.timeLimit > 0 then
        self.timeLimit = mission.startDate.year + mission.timeLimit
    else
        self.timeLimit = 0
        self.NoTimeLimit = true
    end
    self.startResources = mission.startResources
    self.startFood = mission.startFood
    self.lockedTradeResources = mission.lockedTradeResources
    self.lockedTradeFood = mission.lockedTradeFood
    self.lockedTradeWeapons = mission.lockedTradeWeapons
    self.lockedBuildings = mission.lockedBuildings
end

function MissionController:setGoods()
    for key, value in pairs(self.startResources) do
        for _ = 1, value do
            _G.stockpile:store(key)
        end
    end
end

function MissionController:setFood()
    for key, value in pairs(self.startFood) do
        for _ = 1, value do
            _G.foodpile:store(key)
        end
    end
end

function MissionController:getLockedTradeResources()
    return self.lockedTradeResources
end

function MissionController:getLockedTradeFood()
    return self.lockedTradeFood
end

function MissionController:getLockedTradeWeapons()
    return self.lockedTradeWeapons
end

function MissionController:getLockedBuildings()
    return self.lockedBuildings
end

function MissionController:Display()
    if not _G.state.missionNr then return end
    if self.youWin == false then
        self.goalsList = "Tasks: "

        for key, value in pairs(self.goals) do
            if value["resourceType"] ~= "buildings" and value["resourceType"] ~= "gold" then
                if key and value["taskValue"] >= _G.state[value["resourceType"]][value["taskResource"]] then
                    value["taskDone"] = false
                else
                    value["taskDone"] = true
                end
                if value["taskDone"] == false then
                    self.goalsList = self.goalsList
                        .. "\n" ..
                        value["taskText"] ..
                        _G.state[value["resourceType"]][value["taskResource"]] .. " / " .. value["taskValue"]
                else
                    self.goalsList = self.goalsList
                        .. "\n" ..
                        value["taskText"] .. "Done"
                end
            end
            if value["resourceType"] == "gold" then
                if value["taskValue"] >= _G.state.gold then
                    value["taskDone"] = false
                else
                    value["taskDone"] = true
                end
                if value["taskDone"] == false then
                    self.goalsList = self.goalsList
                        .. "\n" ..
                        value["taskText"] ..
                        _G.state.gold .. " / " .. value["taskValue"]
                else
                    self.goalsList = self.goalsList
                        .. "\n" ..
                        value["taskText"] .. "Done"
                end
            end
            if value["resourceType"] == "buildings" then
                if _G.BuildingManager:count(value["taskResource"]) ~= nil then
                    if BuildingManager:count(value["taskResource"]) == value["taskValue"] and value["taskDone"] == false then
                        value["taskDone"] = true
                        self.goalsList = self.goalsList ..
                            "\n" ..
                            "Build: " ..
                            value["taskResource"] ..
                            ":" .. "Done"
                    else
                        value["taskDone"] = false
                        self.goalsList = self.goalsList ..
                            "\n" ..
                            "Build: " ..
                            value["taskResource"] ..
                            ": " ..
                            tostring(BuildingManager:count(value["taskResource"])) .. " / " .. value["taskValue"]
                    end
                end
            end
        end
        if (self.timeLimit) > 0 and self.NoTimeLimit == false then
            self.goalsList = self.goalsList .. "\n" ..
                "Time Left : " .. tostring(self.timeLimit - TimeController:getCurrentYear()) .. " years"
        end

        for key, value in pairs(self.goals) do
            if value["taskDone"] == false then
                self.youWin = false;
                break;
            end
            self.youWin = true;
        end
    end

    if self.youWin then
        self.goalsList = "VICTORY!" .. "\n" ..
            "keep playing or get back" .. "\n" .. "to the menu to play" .. "\n" .. "the next mission"

        if saved == false then
            if love.filesystem.getInfo(path) ~= nil then
                local campaignDataLoaded = bitser.loadLoveFile(path)
                missionsCompletedLoaded = campaignDataLoaded.missionsCompleted
            else
                print("No campaign progress yet!")
            end
            missionsCompletedLoaded[missionNumber + 1] = true
            local campaignData = {
                currentMission = self.missionName,
                missionsCompleted = missionsCompletedLoaded,
            }
            bitser.dumpLoveFile(path, campaignData, true)
            print("Campaign data saved successfully.")
            saved = true
            _G.bus.emit(Events.OnMissionCompleted, self.missionName)
        end
    end
    if self.timeLimit - TimeController:getCurrentYear() <= 0 and self.NoTimeLimit == false then
        self.goalsList = "DEFEATED!"
    end
end

return MissionController:new()
