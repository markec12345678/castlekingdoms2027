-- saves/Missions/campaign/mission21_legacy_conqueror.lua
-- Stronghold 2027 - Historical Campaign Mission 21: Legacy of the Conqueror (Epilogue)
--
-- Historical: After William's death (1087), his sons William Rufus and Henry inherit England.
-- This epilogue mission celebrates the player's journey through the Norman Conquest.

local mission = {
    key = "mission21_legacy_conqueror",
    name = "Legacy of the Conqueror",
    nameSlv = "Dediščina Osvajalca",
    description = "Epilogue. Build a magnificent capital to honor William's legacy. This sandbox mission celebrates your conquest of England.",
    descriptionSlv = "Epilog. Zgradi veličastno prestolnico v čast Viljemovi dediščini. Ta sandbox misija praznuje tvojo osvojitev Anglije.",

    map = "london_grand",
    startingResources = { gold = 3000, wood = 200, stone = 150, food = 100, iron = 80 },

    objectives = {
        { id = 1, type = "build", building = "Keep", count = 1, description = "Build the Grand Keep", descriptionSlv = "Zgradi Veliki grad", critical = true },
        { id = 2, type = "build", building = "Cathedral", count = 1, description = "Build a Cathedral", descriptionSlv = "Zgradi Katedralo", critical = true },
        { id = 3, type = "population", count = 100, description = "Reach population of 100", descriptionSlv = "Dosegni populacijo 100", critical = true },
        { id = 4, type = "gather_resources", resource = "gold", count = 5000, description = "Accumulate 5000 gold", descriptionSlv = "Zberi 5000 zlata", critical = false },
        { id = 5, type = "build", building = "Market", count = 3, description = "Build 3 markets", descriptionSlv = "Zgradi 3 tržnice", critical = false },
        { id = 6, type = "build", building = "SquareTower", count = 6, description = "Build 6 grand towers", descriptionSlv = "Zgradi 6 velikih stolpov", critical = false },
    },

    rewards = { gold = 5000 },

    events = {
        { time = 0, type = "dialogue", text = "Narrator: 'William the Conqueror's legacy endures. England is forever changed.'" },
        { time = 120, type = "dialogue", text = "Narrator: 'From Hastings to the Domesday Book, you have shaped history.'" },
        { time = 300, type = "economic_event", event = "gold_rush" },
        { time = 600, type = "dialogue", text = "Narrator: 'The Conqueror's bloodline will rule England for centuries. Well done, my lord.'" },
    },

    dialogues = {
        { speaker = "William Rufus", text = "Oče bi bil ponosen. Anglija je naša." },
        { speaker = "Henry Beauclerc", text = "In nekoč bo tudi moja. Taka je usoda kraljev." },
    },

    historicalNote = "William the Conqueror died in 1087. His son William Rufus (William II) ruled until 1100, then Henry I (Beauclerc) until 1135. The Norman dynasty William founded ruled England until 1154, when the Plantagenets took over. His legacy shaped English law, language, and culture forever.",
}

return mission
