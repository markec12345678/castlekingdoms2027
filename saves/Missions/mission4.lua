local Mission = _G.class('Mission')
local FOOD = require("objects.Enums.Food")
local RESOURCES = require("objects.Enums.Resources")
local WEAPON = require("objects.Enums.Weapon")
local TimeController = require("objects.Controllers.TimeController")

function Mission:initialize()
    self.name = ""        --name or id of the mission
    self.description = "" -- description of the mission
    self.goals = {}       -- goals of the mission
    self.timeLimit = 0    -- if 0 there is no limit
    self.startDate = TimeController:setCurrentDate(7, 762)
    self.goalsList = ""
    self.startPopularity = 50
    self.startGold = 500
    self.startPopulation = 0
    self.startResources = {
        [RESOURCES.wood] = 25,
        [RESOURCES.hop] = 0,
        [RESOURCES.stone] = 40,
        [RESOURCES.iron] = 0,
        [RESOURCES.tar] = 0,
        [RESOURCES.flour] = 0,
        [RESOURCES.ale] = 0,
        [RESOURCES.wheat] = 0,
    }
    self.startFood = {
        [FOOD.meat] = 0,
        [FOOD.apples] = 0,
        [FOOD.bread] = 30,
        [FOOD.cheese] = 0
    }
    self.goals["Quest1"] = {
        ["taskText"] = "Acquire Gold: ",
        ["taskValue"] = 5000,
        ["taskResource"] = _G.state.gold,
        ["taskDone"] = false,
        ["resourceType"] = "gold"
    }
end

return Mission:new()
