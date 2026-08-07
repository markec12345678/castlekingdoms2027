-- saves/Missions/campaign/mission17_scottish_borders_1072.lua
-- Castle Kingdoms 2027 - Historical Campaign Mission 17: Scottish Campaign (1072)
--
-- Historical: 1072 — William invades Scotland, forcing King Malcolm III to submit.
-- Long-distance campaign with supply lines.

local mission = {
    key = "mission17_scottish_borders_1072",
    name = "Scottish Campaign",
    nameSlv = "Škotska kampanja",
    description = "1072. March into Scotland and force King Malcolm III to submit. Manage long supply lines through hostile territory.",
    descriptionSlv = "1072. Vdiraj na Škotsko in prisili kralja Malcolma III. k pokorščini. Upravljaj dolge oskrbovalne linije skozi sovražno ozemlje.",

    map = "scottish_borders",
    startingResources = { gold = 500, wood = 40, stone = 15, food = 20, iron = 10 },

    objectives = {
        { id = 1, type = "build", building = "Stockpile", count = 3, description = "Build 3 supply depots", descriptionSlv = "Zgradi 3 oskrbovalna skladišča", critical = true },
        { id = 2, type = "gather_resources", resource = "food", count = 150, description = "Gather 150 food for the army", descriptionSlv = "Zberi 150 hrane za vojsko", critical = true },
        { id = 3, type = "build", building = "Barracks", count = 1, description = "Build a forward barracks", descriptionSlv = "Zgradi naprejšnjo barako", critical = true },
        { id = 4, type = "destroy_units", unit = "Pikeman", count = 15, description = "Defeat 15 Scottish pikemen", descriptionSlv = "Premagaj 15 škotskih kopjašev", critical = true },
        { id = 5, type = "kill_unit", unit = "Lord", count = 1, description = "Force Malcolm's surrender", descriptionSlv = "Prisili Malcolma k predaji", critical = true },
    },

    rewards = { gold = 800, wood = 30 },

    events = {
        { time = 0, type = "dialogue", text = "William: 'Scotland awaits. Malcolm will kneel!'" },
        { time = 240, type = "enemy_attack", units = {"Pikeman", "Pikeman", "Pikeman", "Archer"}, location = "north" },
        { time = 480, type = "dialogue", text = "Malcolm: 'I submit, King William. Scotland is yours.'" },
    },

    historicalNote = "In 1072, William invaded Scotland with a fleet and army. Malcolm III submitted at Abernethy, giving his son Duncan as hostage. This established English overlordship over Scotland.",
}

return mission
