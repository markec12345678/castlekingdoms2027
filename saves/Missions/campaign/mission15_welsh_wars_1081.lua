-- saves/Missions/campaign/mission15_welsh_wars_1081.lua
-- Castle Kingdoms 2027 - Historical Campaign Mission 15: Welsh Border Wars (1081)
--
-- Historical: 1081 — William invades Wales to suppress Welsh raids.
-- Mountain warfare against guerrilla fighters.

local mission = {
    key = "mission15_welsh_wars_1081",
    name = "Welsh Border Wars",
    nameSlv = "Valižanski obmejni spopadi",
    description = "1081. Invade Wales and suppress the guerrilla raids. Build border castles to secure the frontier.",
    descriptionSlv = "1081. Vdari v Wales in zatiri gverilske napade. Zgradi obmejne gradove za zavarovanje meje.",

    map = "welsh_borders",
    startingResources = { gold = 700, wood = 50, stone = 30, food = 40, iron = 15 },

    objectives = {
        { id = 1, type = "build", building = "SquareTower", count = 4, description = "Build 4 border towers", descriptionSlv = "Zgradi 4 obmejne stolpe", critical = true },
        { id = 2, type = "destroy_units", unit = "Archer", count = 30, description = "Defeat 30 Welsh archers", descriptionSlv = "Premagaj 30 valižanskih lokostrelcev", critical = true },
        { id = 3, type = "build", building = "Barracks", count = 2, description = "Build 2 barracks for garrison", descriptionSlv = "Zgradi 2 baraki za garnizijo", critical = true },
        { id = 4, type = "protect_building", building = "Keep", duration = 480, description = "Defend your keep for 8 minutes", descriptionSlv = "Branite svoj grad 8 minut", critical = true },
    },

    rewards = { gold = 600, stone = 40, iron = 20 },

    events = {
        { time = 0, type = "dialogue", text = "William: 'These mountains hide Welsh raiders. Flush them out!'" },
        { time = 120, type = "enemy_attack", units = {"Archer", "Archer", "Archer"}, location = "west" },
        { time = 240, type = "enemy_attack", units = {"Archer", "Peasant", "Peasant"}, location = "north" },
        { time = 360, type = "enemy_attack", units = {"Archer", "Archer", "Spearman"}, location = "south" },
    },

    historicalNote = "William invaded Wales in 1081 but found the mountainous terrain difficult. He built border castles (Marcher lordships) to control Welsh raids. Full conquest of Wales took until 1282 under Edward I.",
}

return mission
