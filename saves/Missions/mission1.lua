local Mission = _G.class('Mission')
local FOOD = require("objects.Enums.Food")
local RESOURCES = require("objects.Enums.Resources")
local WEAPON = require("objects.Enums.Weapon")
local TimeController = require("objects.Controllers.TimeController")

function Mission:initialize()
    self.name = ""        --name or id of the mission
    self.description = "" -- description of the mission
    self.goals = {}       -- goals of the mission
    self.lockedBuildings = {
        "ironMine",
        "market"
    } --turns off designated buildings
    self.lockedTradeResources = {
        "wood",
        "stone"
    }
    self.lockedWeapons = {} --turns off designated weapons from production f.e crossbows
    self.timeLimit = 0      -- if 0 there is no limit
    self.startDate = TimeController:setCurrentDate(1, 1000)
    self.goalsList = ""
    self.startPopularity = 50
    self.startGold = 1000
    self.startPopulation = 5
    self.startResources = {
        [RESOURCES.wood] = 10,
        [RESOURCES.hop] = 0,
        [RESOURCES.stone] = 10,
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
        ["taskText"] = "Collect Wood: ",
        ["taskValue"] = 50,
        ["taskResource"] = RESOURCES.wood,
        ["taskDone"] = false,
        ["resourceType"] = "resources",
    }
    self.goals["Quest2"] = {
        ["taskText"] = "Collect Stone: ",
        ["taskValue"] = 20,
        ["taskResource"] = RESOURCES.stone,
        ["taskDone"] = false,
        ["resourceType"] = "resources",
    }
    self.goals["Quest3"] = {
        ["taskText"] = "Build: ",
        ["taskValue"] = 5,
        ["taskResource"] = "WoodcutterHut",
        ["taskDone"] = false,
        ["resourceType"] = "buildings"
    }
end

return Mission:new()
