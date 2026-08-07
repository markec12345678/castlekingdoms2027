-- saves/Missions/campaign/mission1_return_to_fernhaven.lua
-- Castle Kingdoms 2027 - Campaign Mission 1: Return to Fernhaven
--
-- First mission of "The Lord of Fernhaven" campaign.
-- Tutorial mission - teach basic economy.
--
-- This mission uses the NEW MissionFramework format.
-- Load with: MissionFramework.loadMission("campaign.mission1_return_to_fernhaven")

local mission = {
    -- Metadata
    key = "mission1_return_to_fernhaven",
    name = "Return to Fernhaven",
    nameSlv = "Vrnitev v Fernhaven",
    description = "After years of exile, Sir Markus returns to rebuild the ruined castle of Fernhaven.",
    descriptionSlv = "Po letih izgnanstva se Sir Markus vrača, da obnovi opustošeni grad Fernhaven.",

    -- Mission setup
    map = "fernhaven",
    startingResources = {
        gold = 500,
        wood = 30,
        stone = 10,
        food = 20,
    },

    -- Objectives (in order)
    objectives = {
        {
            id = 1,
            type = "gather_resources",
            resource = "wood",
            count = 50,
            description = "Gather 50 wood",
            descriptionSlv = "Zberi 50 lesa",
            critical = true,
        },
        {
            id = 2,
            type = "gather_resources",
            resource = "stone",
            count = 20,
            description = "Gather 20 stone",
            descriptionSlv = "Zberi 20 kamna",
            critical = true,
        },
        {
            id = 3,
            type = "gather_resources",
            resource = "food",
            count = 5,
            description = "Gather 5 food",
            descriptionSlv = "Zberi 5 hrane",
            critical = false,
        },
    },

    -- Scripted events
    events = {
        {
            name = "intro_dialogue_1",
            type = "dialogue",
            triggerTime = 1,
            dialogue = {
                character = "Brother Cedric",
                text = "Sir Markus, Fernhaven leži v ruševinah. A skupaj ga bomo obnovili.",
            },
        },
        {
            name = "intro_dialogue_2",
            type = "dialogue",
            triggerTime = 6,
            dialogue = {
                character = "Sir Markus",
                text = "Začnimo z lesom. Potrebujemo Woodcutter hut.",
            },
        },
        {
            name = "tutorial_wood",
            type = "notification",
            triggerTime = 12,
            message = "Build a Woodcutter Hut near trees to gather wood.",
            notifType = "info",
            duration = 8,
        },
        {
            name = "hint_stone",
            type = "notification",
            triggerTime = 60,
            message = "Don't forget to build a Quarry for stone!",
            notifType = "info",
            duration = 5,
        },
        {
            name = "weather_event",
            type = "set_weather",
            triggerTime = 120,
            weather = "rain",
        },
    },

    -- Story dialogues
    dialogues = {
        {
            character = "Brother Cedric",
            text = "Dobrodošli doma, Sir Markus. Naša dediščina čaka na obnovo.",
        },
    },

    -- Rewards
    rewards = {
        gold = 200,
    },

    -- Mission configuration
    config = {
        timeLimit = 0,
        aiOpponents = {},
        startingBuildings = {},
    },

    -- Next mission
    nextMission = "mission2_first_defenders",
}

return mission
