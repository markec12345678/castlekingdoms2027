-- saves/Missions/campaign/mission19_earls_revolt_1075.lua
-- Castle Kingdoms 2027 - Historical Campaign Mission 19: Revolt of the Earls (1075)
--
-- Historical: 1075 — Earls Ralph de Gael and Roger de Breteuil rebel against William.
-- Internal political conflict with castle sieges.

local mission = {
    key = "mission19_earls_revolt_1075",
    name = "Revolt of the Earls",
    nameSlv = "Vstaja grofov",
    description = "1075. Earls Ralph and Roger have rebelled! Capture their castles and end the rebellion before it spreads.",
    descriptionSlv = "1075. Grofa Ralph in Roger sta se uprla! Zasedi njihova gradova in končaj upor, preden se razširi.",

    map = "norfolk",
    startingResources = { gold = 1000, wood = 60, stone = 40, food = 50, iron = 30 },

    objectives = {
        { id = 1, type = "build", building = "BatteringRam", count = 1, description = "Build a battering ram", descriptionSlv = "Zgradi ovno", critical = true },
        { id = 2, type = "destroy_buildings", building = "StoneGateSouth", count = 2, description = "Break 2 castle gates", descriptionSlv = "Prebij 2 gradski vrata", critical = true },
        { id = 3, type = "destroy_buildings", building = "Keep", count = 1, description = "Capture Earl Ralph's keep", descriptionSlv = "Zasedi grad grofa Ralpha", critical = true },
        { id = 4, type = "destroy_buildings", building = "Keep", count = 1, description = "Capture Earl Roger's keep", descriptionSlv = "Zasedi grad grofa Rogerja", critical = true },
        { id = 5, type = "kill_unit", unit = "Knight", count = 10, description = "Defeat 10 rebel knights", descriptionSlv = "Premagaj 10 uporniških vitezov", critical = false },
    },

    rewards = { gold = 1500, stone = 50, iron = 40 },

    events = {
        { time = 0, type = "dialogue", text = "William: 'These earls forget who made them! Crush them!'" },
        { time = 240, type = "dialogue", text = "Earl Ralph: 'We will not be ruled by a bastard!'" },
        { time = 420, type = "enemy_attack", units = {"Knight", "Knight", "Spearman", "Archer"}, location = "east" },
    },

    historicalNote = "The Revolt of the Earls (1075) was a rebellion by Ralph de Gael, Earl of Norfolk, and Roger de Breteuil, Earl of Hereford. William crushed it easily — Ralph fled to Denmark, Roger was imprisoned for life.",
}

return mission
