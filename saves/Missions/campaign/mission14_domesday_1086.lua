-- saves/Missions/campaign/mission14_domesday_1086.lua
-- Stronghold 2027 - Historical Campaign Mission 14: The Domesday Survey (1086)
--
-- Historical: 1086 — William orders a comprehensive survey of all land and property in England.
-- This economic mission focuses on building a prosperous kingdom.

local mission = {
    key = "mission14_domesday_1086",
    name = "The Domesday Book",
    nameSlv = "Sodni dan Knjiga",
    description = "1086. King William orders a survey of all England. Build a thriving economy, populate your lands, and amass wealth for the crown.",
    descriptionSlv = "1086. Kralj Viljem ukaze popis vse Anglije. Zgradi cvetoče gospodarstvo, poseli svoja ozemlja in zberi bogastvo za krono.",

    map = "winchester",
    startingResources = { gold = 400, wood = 60, stone = 40, food = 30 },

    objectives = {
        { id = 1, type = "gather_resources", resource = "gold", count = 3000, description = "Collect 3000 gold for the crown", descriptionSlv = "Zberi 3000 zlata za krono", critical = true },
        { id = 2, type = "population", count = 50, description = "Reach population of 50", descriptionSlv = "Dosegni populacijo 50", critical = true },
        { id = 3, type = "build", building = "Market", count = 2, description = "Build 2 markets for trade", descriptionSlv = "Zgradi 2 tržnice za trgovino", critical = false },
        { id = 4, type = "build", building = "WheatFarm", count = 5, description = "Build 5 wheat farms", descriptionSlv = "Zgradi 5 pšeničnih kmetij", critical = true },
        { id = 5, type = "gather_resources", resource = "food", count = 200, description = "Stockpile 200 food", descriptionSlv = "Naloži 200 hrane", critical = true },
    },

    rewards = { gold = 1500, wood = 50 },

    events = {
        { time = 0, type = "dialogue", text = "William: 'Every blade of grass must be counted!'" },
        { time = 300, type = "economic_event", event = "bumper_harvest" },
        { time = 600, type = "dialogue", text = "Scribe: 'My lord, the survey is complete. England is wealthy indeed.'" },
    },

    historicalNote = "The Domesday Book (1086) was a comprehensive survey of England's land and resources. It recorded 13,418 settlements and remains one of the most remarkable administrative achievements of the medieval world.",
}

return mission
