-- saves/Missions/campaign/mission20_normandy_defense_1087.lua
-- Castle Kingdoms 2027 - Historical Campaign Mission 20: Defense of Normandy (1087)
--
-- Historical: 1087 — William defends Normandy against French invasion.
-- Final mission — William's last battle before his death.

local mission = {
    key = "mission20_normandy_defense_1087",
    name = "Defense of Normandy",
    nameSlv = "Obramba Normandije",
    description = "1087. King Philip of France has invaded Normandy! Defend your ancestral homeland in William's final campaign.",
    descriptionSlv = "1087. Kralj Filip Francoski je vdrl v Normandijo! Brani svojo domovino prednikov v Viljemovi zadnji kampanji.",

    map = "rouen",
    startingResources = { gold = 1500, wood = 80, stone = 60, food = 60, iron = 40 },

    objectives = {
        { id = 1, type = "build", building = "SquareTower", count = 5, description = "Build 5 defense towers", descriptionSlv = "Zgradi 5 obrambnih stolpov", critical = true },
        { id = 2, type = "build", building = "StoneBarracks", count = 1, description = "Build a stone barracks", descriptionSlv = "Zgradi kamnito barako", critical = true },
        { id = 3, type = "destroy_units", unit = "Knight", count = 15, description = "Defeat 15 French knights", descriptionSlv = "Premagaj 15 francoskih vitezov", critical = true },
        { id = 4, type = "destroy_units", unit = "Crossbowman", count = 20, description = "Defeat 20 crossbowmen", descriptionSlv = "Premagaj 20 samostrelcev", critical = true },
        { id = 5, type = "protect_building", building = "Keep", duration = 720, description = "Hold Rouen for 12 minutes", descriptionSlv = "Drži Rouen 12 minut", critical = true },
        { id = 6, type = "kill_unit", unit = "Lord", count = 1, description = "Defeat the French commander", descriptionSlv = "Premagaj francoskega poveljnika", critical = true },
    },

    rewards = { gold = 2000, iron = 50 },

    events = {
        { time = 0, type = "dialogue", text = "William: 'Philip dares invade MY lands? He will learn the cost!'" },
        { time = 120, type = "enemy_attack", units = {"Knight", "Knight", "Crossbowman", "Crossbowman"}, location = "south" },
        { time = 300, type = "enemy_attack", units = {"Knight", "Knight", "Knight", "Crossbowman"}, location = "east" },
        { time = 480, type = "enemy_attack", units = {"Knight", "Knight", "Knight", "Knight", "Crossbowman"}, location = "south" },
        { time = 600, type = "dialogue", text = "William: 'Mantes burns — but Normandy stands! Victory!'" },
    },

    historicalNote = "In 1087, King Philip I of France raided Normandy and burned the town of Mantes. William, now overweight and aging, led a counterattack but was injured when his horse stumbled on the burning ruins. He died in Rouen on September 9, 1087, ending the reign of the Conqueror.",
}

return mission
