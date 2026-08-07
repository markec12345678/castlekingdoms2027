-- saves/Missions/campaign/mission13_harrying_north_1069.lua
-- Castle Kingdoms 2027 - Historical Campaign Mission 13: Harrying of the North (1069-1070)
--
-- Historical: Winter 1069-1070 — William devastates Yorkshire to crush rebellion.
-- This brutal campaign destroyed villages and farms across northern England.

local mission = {
    key = "mission13_harrying_north_1069",
    name = "Harrying of the North",
    nameSlv = "Pustošenje severa",
    description = "Winter 1069. Crush the Saxon rebellion in Yorkshire. Destroy enemy strongholds and establish Norman control.",
    descriptionSlv = "Zima 1069. Zlomi saški upor v Yorkshireu. Uniči sovražne trdnjave in vzpostavi normanski nadzor.",

    map = "yorkshire",
    startingResources = { gold = 600, wood = 40, stone = 20, food = 30, iron = 10 },

    objectives = {
        { id = 1, type = "destroy_buildings", building = "Keep", count = 2, description = "Destroy 2 rebel keeps", descriptionSlv = "Uniči 2 uporniška gradu", critical = true },
        { id = 2, type = "destroy_buildings", building = "Barracks", count = 3, description = "Destroy 3 rebel barracks", descriptionSlv = "Uniči 3 uporniške barake", critical = true },
        { id = 3, type = "build", building = "Keep", count = 1, description = "Build your keep in York", descriptionSlv = "Zgradi svoj grad v Yorku", critical = true },
        { id = 4, type = "gather_resources", resource = "gold", count = 1000, description = "Collect 1000 gold in tribute", descriptionSlv = "Zberi 1000 zlata v tributu", critical = false },
    },

    rewards = { gold = 1000, iron = 30 },

    events = {
        { time = 0, type = "dialogue", text = "William: 'The north must learn obedience. No mercy!'" },
        { time = 180, type = "enemy_attack", units = {"Spearman", "Spearman", "Archer", "Maceman"}, location = "east" },
        { time = 360, type = "dialogue", text = "Norman Knight: 'My lord, the rebels scatter before us!'" },
    },

    historicalNote = "The Harrying of the North (1069-1070) was William's brutal suppression of northern rebellion. Villages were burned, crops destroyed, and thousands starved. It remains one of the darkest episodes of the Norman Conquest.",
}

return mission
