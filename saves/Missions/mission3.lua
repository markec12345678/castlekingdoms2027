local Mission = _G.class('Mission')
local FOOD = require("objects.Enums.Food")
local RESOURCES = require("objects.Enums.Resources")

function Mission:initialize()
    self.name = "Feast or famine"
    self.description = [[
    In this mission, you will need to focus on food production to sustain your growing population. Your goal is to produce 250 units of bread, 100 units of meat, 200 units of cheese, and 250 units of apples within the next 20 years.

    To achieve this, you will need to develop a robust agriculture system to grow crops and raise livestock. This will require the construction of farms, mills, and pastures, as well as the recruitment of skilled laborers.

    In addition to food production, you will also need to consider the storage and distribution of these resources. This may involve building granaries and markets to store and sell your products.

    Keep in mind that your success in this mission will depend on your ability to balance your resources and prioritize your goals. You will need to carefully manage your finances and make strategic decisions to ensure the prosperity of your kingdom. Good luck!
    ]]
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
        ["taskValue"] = 250,
        ["taskResource"] = FOOD.apples,
        ["taskDone"] = false,
        ["resourceType"] = "food"
    }
    self.goals["Quest2"] = {
        ["taskText"] = "Produce Cheese: ",
        ["taskValue"] = 200,
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
        ["taskValue"] = 250,
        ["taskResource"] = FOOD.bread,
        ["taskDone"] = false,
        ["resourceType"] = "food"
    }
end

return Mission:new()
