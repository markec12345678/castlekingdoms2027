local Mission = _G.class('Mission')
local FOOD = require("objects.Enums.Food")
local RESOURCES = require("objects.Enums.Resources")
local WEAPON = require("objects.Enums.Weapon")
local SID = require("objects.Controllers.LanguageController").lines

function Mission:initialize()
    self.name = SID.mission5.name
    self.description = SID.mission5.desc
    self.goals = {}           -- goals of the mission
    self.lockedBuildings = {} --turns off designated buildings
    self.lockedTradeList = {} --turns off designated resources from market/trading
    self.lockedWeapons = {}   --turns off designated weapons from production f.e crossbows
    self.timeLimit = 10       -- if 0 there is no limit
    self.NoTimeLimit = false
    self.startDate = { month = 9, year = 1017 }
    self.goalsList = ""
    self.startPopularity = 50
    self.startGold = 0
    self.startPopulation = 0
    self.startResources = {
        ["wood"] = 40,
        ['hop'] = 0,
        ["stone"] = 0,
        ["iron"] = 0,
        ["tar"] = 0,
        ["flour"] = 0,
        ["ale"] = 0,
        ["wheat"] = 0,
        ["gold"] = self.startGold
    }
    self.startFood = {
        [FOOD.meat] = 50,
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

    self.goals["Quest1"] = {
        ["taskText"] = "Build: ",
        ["taskValue"] = 1,
        ["taskResource"] = "Cathedral",
        ["taskDone"] = false,
        ["resourceType"] = "buildings"
    }
end

return Mission:new()
