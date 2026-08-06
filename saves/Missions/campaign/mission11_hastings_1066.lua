-- saves/Missions/campaign/mission11_hastings_1066.lua
-- Stronghold 2027 - Historical Campaign Mission 11: Battle of Hastings (1066)
--
-- Historical: October 14, 1066 — William the Conqueror defeats King Harold II.
-- This is the decisive battle that began the Norman conquest of England.
--
-- Player role: William the Conqueror — must break the Saxon shield wall.

local mission = {
    key = "mission11_hastings_1066",
    name = "Battle of Hastings",
    nameSlv = "Bitka pri Hastingsu",
    description = "October 14, 1066. Lead William the Conqueror's Norman forces against King Harold's Saxon shield wall. Break their formation and claim the English throne.",
    descriptionSlv = "14. oktober 1066. Vodi normanske sile Viljema Osvajalca proti saškem ščitnem zidu kralja Harolda. Prebij njihovo formacijo in si pridobi angleški prestol.",

    map = "hastings",
    startingResources = {
        gold = 800,
        wood = 50,
        stone = 20,
        food = 40,
    },

    objectives = {
        {
            id = 1,
            type = "destroy_units",
            unit = "enemy_military",
            count = 20,
            description = "Destroy the Saxon shield wall",
            descriptionSlv = "Uniči saški ščitni zid",
            critical = true,
        },
        {
            id = 2,
            type = "kill_unit",
            unit = "Lord",
            count = 1,
            description = "Defeat King Harold",
            descriptionSlv = "Premagaj kralja Harolda",
            critical = true,
        },
        {
            id = 3,
            type = "protect_unit",
            unit = "Lord",
            duration = 300,
            description = "Keep William alive for 5 minutes",
            descriptionSlv = "Ohrani Viljema živega 5 minut",
            critical = true,
        },
    },

    rewards = {
        gold = 500,
        wood = 30,
        stone = 20,
    },

    events = {
        { time = 0, type = "dialogue", text = "William: 'The Saxon shield wall is strong. We must use feigned retreats to break it!'" },
        { time = 60, type = "dialogue", text = "William: 'Archers! Loose your arrows over the shield wall!'" },
        { time = 180, type = "dialogue", text = "William: 'The shield wall weakens! Press the attack!'" },
    },

    dialogues = {
        { speaker = "William the Conqueror", text = "Zmaga bo naša! Angleški prestol je moj!" },
        { speaker = "King Harold", text = "Saški zid stoji trdno! Normani ne bodo prešli!" },
    },

    historicalNote = "The Battle of Hastings was fought on October 14, 1066. William's victory ended Anglo-Saxon rule and began the Norman era. Harold died from an arrow to the eye according to tradition.",
}

return mission
