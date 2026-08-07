-- saves/Missions/campaign/mission12_london_1066.lua
-- Castle Kingdoms 2027 - Historical Campaign Mission 12: Coronation in London (December 1066)
--
-- Historical: Christmas Day 1066 — William is crowned King of England at Westminster Abbey.
-- Player must secure London and prepare for coronation.

local mission = {
    key = "mission12_london_1066",
    name = "Coronation in London",
    nameSlv = "Kronanje v Londonu",
    description = "December 1066. Secure London and prepare for William's coronation at Westminster Abbey. Build defenses against Saxon rebels.",
    descriptionSlv = "December 1066. Zavaruj London in pripravi se na Viljemovo kronanje v opatiji Westminster. Zgradi obrambo proti saškim upornikom.",

    map = "london",
    startingResources = {
        gold = 1200,
        wood = 80,
        stone = 60,
        food = 60,
    },

    objectives = {
        { id = 1, type = "build", building = "Keep", count = 1, description = "Build the Tower of London", descriptionSlv = "Zgradi Tower of London", critical = true },
        { id = 2, type = "gather_resources", resource = "stone", count = 200, description = "Gather 200 stone for fortifications", descriptionSlv = "Zberi 200 kamna za utrdbe", critical = true },
        { id = 3, type = "build", building = "SquareTower", count = 3, description = "Build 3 defense towers", descriptionSlv = "Zgradi 3 obrambne stolpe", critical = false },
        { id = 4, type = "protect_building", building = "Keep", duration = 600, description = "Keep the Tower standing for 10 minutes", descriptionSlv = "Ohrani Tower nedotaknjen 10 minut", critical = true },
    },

    rewards = { gold = 800, stone = 50 },

    events = {
        { time = 0, type = "dialogue", text = "William: 'London must be secured before my coronation!'" },
        { time = 120, type = "enemy_attack", units = {"Peasant", "Peasant", "Archer"}, location = "north" },
        { time = 300, type = "dialogue", text = "Bishop: 'Your Majesty, Westminster Abbey awaits.'" },
    },

    historicalNote = "William was crowned King of England on Christmas Day 1066 at Westminster Abbey. The Tower of London was begun in 1078 as a symbol of Norman power.",
}

return mission
