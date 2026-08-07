-- saves/Missions/campaign/mission18_danish_invasion_1075.lua
-- Castle Kingdoms 2027 - Historical Campaign Mission 18: Danish Invasion (1075)
--
-- Historical: 1075 — Danes allied with English rebels land at York.
-- Coastal defense against Viking invasion.

local mission = {
    key = "mission18_danish_invasion_1075",
    name = "Danish Invasion",
    nameSlv = "Danska invazija",
    description = "1075. Danish Vikings have landed at York, allied with Saxon rebels! Defend the coast and drive them back to the sea.",
    descriptionSlv = "1075. Danski Vikingi so pristali v Yorku, zavezniški saškim upornikom! Brani obalo in jih odpelji nazaj v morje.",

    map = "york_coast",
    startingResources = { gold = 600, wood = 50, stone = 30, food = 35, iron = 15 },

    objectives = {
        { id = 1, type = "build", building = "RoundTower", count = 3, description = "Build 3 coastal towers", descriptionSlv = "Zgradi 3 obalne stolpe", critical = true },
        { id = 2, type = "destroy_units", unit = "Maceman", count = 20, description = "Defeat 20 Danish warriors", descriptionSlv = "Premagaj 20 danskih bojevnikov", critical = true },
        { id = 3, type = "destroy_units", unit = "Knight", count = 5, description = "Defeat 5 Viking champions", descriptionSlv = "Premagaj 5 vikinških prvakov", critical = true },
        { id = 4, type = "protect_building", building = "Keep", duration = 600, description = "Hold your keep for 10 minutes", descriptionSlv = "Drži svoj grad 10 minut", critical = true },
    },

    rewards = { gold = 900, iron = 30 },

    events = {
        { time = 0, type = "dialogue", text = "William: 'Vikings at our shores again! To arms!'" },
        { time = 120, type = "enemy_attack", units = {"Maceman", "Maceman", "Maceman"}, location = "beach" },
        { time = 300, type = "enemy_attack", units = {"Knight", "Maceman", "Archer"}, location = "north" },
        { time = 480, type = "enemy_attack", units = {"Knight", "Knight", "Maceman", "Maceman"}, location = "beach" },
    },

    historicalNote = "In 1075, a Danish fleet of 200 ships joined the Revolt of the Earls against William. York was sacked, but William bought off the Danes and crushed the rebellion. This was the last major Viking invasion of England.",
}

return mission
