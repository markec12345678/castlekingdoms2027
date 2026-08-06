local Mission = _G.class('Mission')
local FOOD = require("objects.Enums.Food")
local RESOURCES = require("objects.Enums.Resources")
local WEAPON = require("objects.Enums.Weapon")
local SID = require("objects.Controllers.LanguageController").lines

function Mission:initialize()
    self.name = SID.mission4.name
    self.description = SID.mission4.desc -- description of the mission
    self.goals = {}                      -- goals of the mission
    self.timeLimit = 0                   -- if 0 there is no limit
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
        ["taskText"] = "Acquire Gold from tax: ",
        ["taskValue"] = 3000,
        ["taskResource"] = "gold",
        ["taskDone"] = false,
        ["resourceType"] = "goldTax"
    }
    self.goals["Quest2"] = {
        ["taskText"] = "Acquire Gold from trade: ",
        ["taskValue"] = 2000,
        ["taskResource"] = "gold",
        ["taskDone"] = false,
        ["resourceType"] = "goldTrade"
    }
end

return Mission:new()
