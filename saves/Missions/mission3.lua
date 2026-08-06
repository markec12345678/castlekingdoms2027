local Mission = _G.class('Mission')
local FOOD = require("objects.Enums.Food")
local RESOURCES = require("objects.Enums.Resources")
local SID = require("objects.Controllers.LanguageController").lines
function Mission:initialize()
    self.name = SID.mission3.name
    self.description = SID.mission3.desc
    self.timeLimit = 20
    self.startDate = { month = 5, year = 1140 }
    self.startGold = 1000
    self.goals = {}
    self.startResources = {
        [RESOURCES.wood] = 40,
        [RESOURCES.hop] = 0,
        [RESOURCES.stone] = 0,
        [RESOURCES.iron] = 0,
        [RESOURCES.tar] = 0,
        [RESOURCES.flour] = 0,
        [RESOURCES.ale] = 0,
        [RESOURCES.wheat] = 0,
    }
    self.startFood = {
        [FOOD.meat] = 25,
        [FOOD.apples] = 25,
        [FOOD.bread] = 0,
        [FOOD.cheese] = 0
    }
    self.goals["Quest1"] = {
        ["taskText"] = "Produce Apples: ",
        ["taskValue"] = 150,
        ["taskResource"] = FOOD.apples,
        ["taskDone"] = false,
        ["resourceType"] = "food"
    }
    self.goals["Quest2"] = {
        ["taskText"] = "Produce Cheese: ",
        ["taskValue"] = 100,
        ["taskResource"] = FOOD.cheese,
        ["taskDone"] = false,
        ["resourceType"] = "food"
    }
    self.goals["Quest3"] = {
        ["taskText"] = "Produce Meat: ",
        ["taskValue"] = 100,
        ["taskResource"] = FOOD.meat,
        ["taskDone"] = false,
        ["resourceType"] = "food"
    }
    self.goals["Quest4"] = {
        ["taskText"] = "Produce Bread: ",
        ["taskValue"] = 150,
        ["taskResource"] = FOOD.bread,
        ["taskDone"] = false,
        ["resourceType"] = "food"
    }
end

return Mission:new()
