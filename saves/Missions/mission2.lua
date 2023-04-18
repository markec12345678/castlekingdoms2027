local Mission = _G.class('Mission')
local FOOD = require("objects.Enums.Food")
local RESOURCES = require("objects.Enums.Resources")
local WEAPON = require("objects.Enums.Weapon")
local TimeController = require("objects.Controllers.TimeController")

function Mission:initialize()
    self.name = ""            --name or id of the mission
    self.description = ""     -- description of the mission
    self.goals = {}           -- goals of the mission
    self.lockedTradeFood = {} --turns off designated resources from market/trading
    self.lockedTradeResources = { "iron" }
    self.lockedTradeWeapons = {
        "bow",
        "spear",
        "mace",
        "shield" }
    self.timeLimit = 20 -- if 0 there is no limit
    self.startDate = TimeController:setCurrentDate(1, 1000)
    self.goalsList = ""
    self.startPopularity = 50
    self.startGold = 0
    self.startPopulation = 0
    self.startResources = {
        [RESOURCES.wood] = 30,
        [RESOURCES.hop] = 0,
        [RESOURCES.stone] = 50,
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

    self.goals["Quest1"] = {
        ["taskText"] = "Produce Bow: ",
        ["taskValue"] = 40,
        ["taskResource"] = WEAPON.bow,
        ["taskDone"] = false,
        ["resourceType"] = "weapons"
    }
    self.goals["Quest2"] = {
        ["taskText"] = "Produce Spear: ",
        ["taskValue"] = 40,
        ["taskResource"] = WEAPON.spear,
        ["taskDone"] = false,
        ["resourceType"] = "weapons"
    }
    self.goals["Quest3"] = {
        ["taskText"] = "Produce Mace: ",
        ["taskValue"] = 40,
        ["taskResource"] = WEAPON.mace,
        ["taskDone"] = false,
        ["resourceType"] = "weapons"
    }
    self.goals["Quest4"] = {
        ["taskText"] = "Produce Armor: ",
        ["taskValue"] = 40,
        ["taskResource"] = WEAPON.shield,
        ["taskDone"] = false,
        ["resourceType"] = "weapons"
    }
end

return Mission:new()
