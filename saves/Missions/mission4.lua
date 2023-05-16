local Mission = _G.class('Mission')
local FOOD = require("objects.Enums.Food")
local RESOURCES = require("objects.Enums.Resources")
local WEAPON = require("objects.Enums.Weapon")

function Mission:initialize()
    self.name = "The Kingdom's Fortune" --name or id of the mission
    self.description = [[
        In this mission, your goal is to accumulate a substantial amount of wealth by acquiring 5000 units of gold. Unlike previous missions, there is no time limit on this objective, so you will have the freedom to pursue your goals at your own pace.

        To achieve this, you will need to develop a strong economy by building and managing workshops, investing in trade and commerce, and making strategic financial decisions.

        Keep in mind that your success in this mission will depend on your ability to make wise investments and manage your finances carefully. You will need to balance your resources and take calculated risks to ensure the prosperity of your kingdom. Good luck!
    ]]                 -- description of the mission
    self.goals = {}    -- goals of the mission
    self.timeLimit = 0 -- if 0 there is no limit
    self.startDate = { month = 7, year = 762 }
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
        ["taskResource"] = "gold",
        ["taskDone"] = false,
        ["resourceType"] = "gold"
    }
end

return Mission:new()
