-- saves/Missions/campaign/mission16_robert_rebellion_1078.lua
-- Stronghold 2027 - Historical Campaign Mission 16: Robert's Rebellion (1078-1080)
--
-- Historical: 1078-1080 — Robert Curthose, William's eldest son, rebels against his father.
-- Family conflict with siege warfare.

local mission = {
    key = "mission16_robert_rebellion_1078",
    name = "Robert's Rebellion",
    nameSlv = "Robertova vstaja",
    description = "1078. Robert Curthose, William's son, has rebelled! Besiege his castle at Gerberoy and bring him to justice.",
    descriptionSlv = "1078. Robert Curthose, Viljemov sin, se je uprl! Oblegaj njegov grad v Gerberoyju in ga privedi do pravice.",

    map = "gerberoy",
    startingResources = { gold = 900, wood = 60, stone = 40, food = 50, iron = 25 },

    objectives = {
        { id = 1, type = "build", building = "Trebuchet", count = 2, description = "Build 2 trebuchets for siege", descriptionSlv = "Zgradi 2 trebuchet-a za obleganje", critical = true },
        { id = 2, type = "destroy_buildings", building = "SquareTower", count = 2, description = "Destroy 2 rebel towers", descriptionSlv = "Uniči 2 uporniška stolpa", critical = true },
        { id = 3, type = "destroy_buildings", building = "Keep", count = 1, description = "Destroy Robert's keep", descriptionSlv = "Uniči Robertov grad", critical = true },
        { id = 4, type = "kill_unit", unit = "Knight", count = 5, description = "Defeat 5 rebel knights", descriptionSlv = "Premagaj 5 uporniških vitezov", critical = false },
    },

    rewards = { gold = 1200, iron = 40 },

    events = {
        { time = 0, type = "dialogue", text = "William: 'My own son against me! He shall kneel or fall!'" },
        { time = 180, type = "dialogue", text = "Robert: 'You deny me my birthright, father! I will take what is mine!'" },
        { time = 360, type = "enemy_attack", units = {"Knight", "Knight", "Swordsman"}, location = "gate" },
    },

    historicalNote = "Robert Curthose rebelled against William in 1078 after a prank by his brothers. The siege of Gerberoy (1079) saw William unhorsed and wounded by his own son. They reconciled in 1080.",
}

return mission
